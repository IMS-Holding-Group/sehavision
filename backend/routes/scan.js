const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const axios = require('axios');
const FormData = require('form-data');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { createWorker } = require('tesseract.js');

const router = express.Router();

// AI Service Configuration
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:5000';
const USE_AI_SERVICE = process.env.USE_AI_SERVICE !== 'false'; // Default to true

// Configure multer for image uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, '..', 'uploads', 'scans');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'scan-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB limit
    },
    fileFilter: (req, file, cb) => {
        // Check mimetype first if available
        if (file.mimetype && file.mimetype.startsWith('image/')) {
            cb(null, true);
            return;
        }

        // If mimetype is missing or invalid, check file extension
        const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
        const fileExtension = path.extname(file.originalname || '').toLowerCase();

        if (allowedExtensions.includes(fileExtension)) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed'), false);
        }
    }
});

// Extract text from image using OCR
const extractTextFromImage = async (imagePath) => {
    try {
        const worker = await createWorker('eng+ara'); // English and Arabic
        const { data: { text } } = await worker.recognize(imagePath);
        await worker.terminate();
        return text.toLowerCase().trim();
    } catch (error) {
        console.error('OCR Error:', error);
        return '';
    }
};

// Search medicine in database by text
const searchMedicineInDatabase = async (searchText) => {
    return new Promise((resolve, reject) => {
        // Extract potential medicine names and keywords from text
        const words = searchText.split(/\s+/).filter(word => word.length > 2);

        // Build search query (SQLite compatible)
        const searchLower = searchText.toLowerCase();
        const firstWord = words[0] || searchLower;

        const query = `
            SELECT * FROM medicines 
            WHERE name LIKE ? OR brand LIKE ? OR name LIKE ? OR brand LIKE ?
            ORDER BY 
                CASE 
                    WHEN name = ? THEN 1
                    WHEN name LIKE ? THEN 2
                    WHEN brand = ? THEN 3
                    WHEN brand LIKE ? THEN 4
                    ELSE 5
                END
            LIMIT 10
        `;

        db.all(query, [
            `%${firstWord}%`, `%${firstWord}%`, `%${searchLower}%`, `%${searchLower}%`,
            searchLower, `%${searchLower}%`, searchLower, `%${searchLower}%`
        ], (err, rows) => {
            if (err) {
                reject(err);
            } else {
                resolve(rows || []);
            }
        });
    });
};

// Enhanced AI recognition with OCR
const recognizeMedicine = async (imagePath) => {
    try {
        // Step 1: Extract text from image using OCR
        const extractedText = await extractTextFromImage(imagePath);

        if (!extractedText || extractedText.length < 3) {
            return {
                success: false,
                error: 'لا يمكن قراءة النص من الصورة. يرجى التأكد من وضوح الصورة',
                confidence: 0
            };
        }

        console.log('Extracted text:', extractedText);

        // Step 2: Search in database
        const medicines = await searchMedicineInDatabase(extractedText);

        if (medicines.length === 0) {
            // Try searching with individual words
            const words = extractedText.split(/\s+/).filter(w => w.length > 3);
            for (const word of words) {
                const results = await searchMedicineInDatabase(word);
                if (results.length > 0) {
                    medicines.push(...results);
                    break;
                }
            }
        }

        if (medicines.length === 0) {
            return {
                success: false,
                error: 'الدواء غير موجود في قاعدة البيانات. النص المستخرج: ' + extractedText.substring(0, 100),
                extractedText: extractedText.substring(0, 100),
                confidence: 0
            };
        }

        // Step 3: Calculate confidence based on text matching
        const bestMatch = medicines[0];
        const confidence = calculateConfidence(extractedText, bestMatch);

        return {
            success: true,
            medicine: {
                ...bestMatch,
                interactions: bestMatch.interactions ? JSON.parse(bestMatch.interactions) : null,
                image_paths: bestMatch.image_paths ? JSON.parse(bestMatch.image_paths) : []
            },
            confidence: confidence,
            processing_time: 2000,
            extractedText: extractedText.substring(0, 100),
            alternatives: medicines.slice(1, 5).map(m => ({
                id: m.id,
                name: m.name,
                brand: m.brand
            }))
        };
    } catch (error) {
        console.error('Recognition error:', error);
        return {
            success: false,
            error: 'خطأ في معالجة الصورة: ' + error.message,
            confidence: 0
        };
    }
};

// Calculate confidence score based on text matching
const calculateConfidence = (extractedText, medicine) => {
    const textLower = extractedText.toLowerCase();
    const nameLower = (medicine.name || '').toLowerCase();
    const brandLower = (medicine.brand || '').toLowerCase();

    let score = 0;

    // Exact match
    if (textLower.includes(nameLower) || textLower.includes(brandLower)) {
        score += 0.5;
    }

    // Word match
    const textWords = textLower.split(/\s+/);
    const nameWords = nameLower.split(/\s+/);
    const brandWords = brandLower.split(/\s+/);

    let matchedWords = 0;
    textWords.forEach(word => {
        if (nameWords.includes(word) || brandWords.includes(word)) {
            matchedWords++;
        }
    });

    score += (matchedWords / Math.max(textWords.length, nameWords.length + brandWords.length)) * 0.5;

    return Math.min(0.95, Math.max(0.5, score));
};

// Call AI Service for advanced recognition
const callAIService = async (imagePath) => {
    try {
        const formData = new FormData();
        formData.append('image', fs.createReadStream(imagePath));

        const response = await axios.post(`${AI_SERVICE_URL}/recognize`, formData, {
            headers: formData.getHeaders(),
            timeout: 30000 // 30 seconds timeout
        });

        return response.data;
    } catch (error) {
        console.error('AI Service error:', error.message);
        if (error.response) {
            console.error('AI Service response:', error.response.data);
        }
        return null;
    }
};

// Scan medicine by image
router.post('/image', authenticateToken, upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No image file provided' });
        }

        const imagePath = req.file.path;

        // Process image with Sharp (resize, optimize)
        const processedImagePath = path.join(
            path.dirname(imagePath),
            'processed-' + path.basename(imagePath)
        );

        await sharp(imagePath)
            .resize(800, 600, { fit: 'inside', withoutEnlargement: true })
            .jpeg({ quality: 85 })
            .toFile(processedImagePath);

        let recognitionResult = null;

        // Try AI Service first if enabled
        if (USE_AI_SERVICE) {
            try {
                recognitionResult = await callAIService(processedImagePath);
                if (recognitionResult && recognitionResult.success) {
                    // AI Service returned successful result
                    return res.json({
                        success: true,
                        medicine: recognitionResult.medicine,
                        confidence: recognitionResult.confidence,
                        scan_image: `/uploads/scans/${path.basename(processedImagePath)}`,
                        processing_time: recognitionResult.processing_time || 0,
                        extractedText: recognitionResult.ocr_text || '',
                        ai_prediction: recognitionResult.ai_prediction || '',
                        alternatives: recognitionResult.alternatives || [],
                        method: 'ai_service'
                    });
                }
            } catch (aiError) {
                console.log('AI Service unavailable, falling back to OCR:', aiError.message);
            }
        }

        // Fallback to original OCR-based recognition
        recognitionResult = await recognizeMedicine(processedImagePath);

        if (recognitionResult.success) {
            res.json({
                success: true,
                medicine: recognitionResult.medicine,
                confidence: recognitionResult.confidence,
                scan_image: `/uploads/scans/${path.basename(processedImagePath)}`,
                processing_time: recognitionResult.processing_time,
                extractedText: recognitionResult.extractedText,
                alternatives: recognitionResult.alternatives || [],
                method: 'ocr_fallback'
            });
        } else {
            res.status(400).json({
                success: false,
                error: recognitionResult.error || 'Could not recognize medicine in image',
                extractedText: recognitionResult.extractedText,
                scan_image: `/uploads/scans/${path.basename(processedImagePath)}`
            });
        }

    } catch (error) {
        console.error('Scan error:', error);
        res.status(500).json({ error: 'Image processing failed' });
    }
});

// Scan medicine by barcode
router.post('/barcode', authenticateToken, (req, res) => {
    const { barcode } = req.body;

    if (!barcode) {
        return res.status(400).json({ error: 'Barcode is required' });
    }

    db.get('SELECT * FROM medicines WHERE barcode = ?', [barcode], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({
                success: false,
                error: 'Medicine not found for this barcode'
            });
        }

        const medicine = {
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : null,
            image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
        };

        res.json({
            success: true,
            medicine,
            confidence: 1.0,
            scan_method: 'barcode'
        });
    });
});

// Get scan history for user
router.get('/history', authenticateToken, (req, res) => {
    const { limit = 20, offset = 0 } = req.query;

    // For now, we'll return a simple history
    // In production, you should store scan history in a separate table
    res.json({
        scans: [],
        message: 'Scan history feature coming soon'
    });
});

module.exports = router;
