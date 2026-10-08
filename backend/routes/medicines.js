const express = require('express');
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');
const { validateRequest, schemas } = require('../middleware/validation');
const { logActivity } = require('../utils/logger');

const router = express.Router();

// Get all medicines (exclude deleted by default)
router.get('/', (req, res) => {
    const { search, limit = 50, offset = 0, include_deleted = false } = req.query;

    let query = `
        SELECT 
            m.*,
            u.name as created_by_name,
            u.email as created_by_email,
            d.name as deleted_by_name
        FROM medicines m
        LEFT JOIN users u ON m.created_by = u.id
        LEFT JOIN users d ON m.deleted_by = d.id
    `;
    let params = [];
    let conditions = [];

    if (include_deleted !== 'true') {
        conditions.push('m.is_deleted = 0');
    }

    if (search) {
        conditions.push('(m.name LIKE ? OR m.brand LIKE ? OR m.barcode LIKE ?)');
        const searchTerm = `%${search}%`;
        params.push(searchTerm, searchTerm, searchTerm);
    }

    if (conditions.length > 0) {
        query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY m.name LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    db.all(query, params, (err, rows) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        // Parse JSON fields
        const medicines = rows.map(row => ({
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : null,
            image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
        }));

        res.json({ medicines });
    });
});

// Get medicine by ID
router.get('/:id', (req, res) => {
    const { id } = req.params;

    db.get('SELECT * FROM medicines WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        // Parse JSON fields
        const medicine = {
            ...row,
            interactions: row.interactions ? JSON.parse(row.interactions) : null,
            image_paths: row.image_paths ? JSON.parse(row.image_paths) : []
        };

        res.json({ medicine });
    });
});

// Create medicine
router.post('/', authenticateToken, validateRequest(schemas.medicine), (req, res) => {
    const {
        name, brand, barcode, dosage, instructions, warnings,
        interactions, expiry_date, image_paths
    } = req.body;

    // Check if barcode already exists
    if (barcode) {
        db.get('SELECT id FROM medicines WHERE barcode = ?', [barcode], (err, row) => {
            if (err) {
                return res.status(500).json({ error: 'Database error' });
            }

            if (row) {
                return res.status(400).json({ error: 'Medicine with this barcode already exists' });
            }

            createMedicine();
        });
    } else {
        createMedicine();
    }

    function createMedicine() {
        const interactionsJson = interactions ? JSON.stringify(interactions) : null;
        const imagePathsJson = image_paths ? JSON.stringify(image_paths) : null;
        const userId = req.user ? req.user.id : null;

        db.run(
            `INSERT INTO medicines (name, brand, barcode, dosage, instructions, warnings, interactions, expiry_date, image_paths, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [name, brand || null, barcode || null, dosage || null, instructions || null,
                warnings || null, interactionsJson, expiry_date || null, imagePathsJson, userId],
            function (err) {
                if (err) {
                    return res.status(500).json({ error: 'Failed to create medicine' });
                }

                const medicineId = this.lastID;

                // Log activity
                if (userId) {
                    logActivity({
                        user_id: userId,
                        action: 'create',
                        entity_type: 'medicine',
                        entity_id: medicineId,
                        details: { name, brand, barcode },
                        ip_address: req.ip || req.connection.remoteAddress,
                        user_agent: req.get('user-agent')
                    }).catch(err => console.error('Failed to log activity:', err));
                }

                res.status(201).json({
                    message: 'Medicine created successfully',
                    medicine: {
                        id: medicineId,
                        name, brand, barcode, dosage, instructions, warnings,
                        interactions, expiry_date, image_paths
                    }
                });
            }
        );
    }
});

// Update medicine
router.put('/:id', authenticateToken, validateRequest(schemas.medicine), (req, res) => {
    const { id } = req.params;
    const {
        name, brand, barcode, dosage, instructions, warnings,
        interactions, expiry_date, image_paths
    } = req.body;

    // Check if medicine exists
    db.get('SELECT id FROM medicines WHERE id = ?', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        // Check if barcode already exists (excluding current medicine)
        if (barcode) {
            db.get('SELECT id FROM medicines WHERE barcode = ? AND id != ?', [barcode, id], (err, row) => {
                if (err) {
                    return res.status(500).json({ error: 'Database error' });
                }

                if (row) {
                    return res.status(400).json({ error: 'Medicine with this barcode already exists' });
                }

                updateMedicine();
            });
        } else {
            updateMedicine();
        }

        function updateMedicine() {
            const interactionsJson = interactions ? JSON.stringify(interactions) : null;
            const imagePathsJson = image_paths ? JSON.stringify(image_paths) : null;
            const userId = req.user ? req.user.id : null;

            db.run(
                `UPDATE medicines SET 
         name = ?, brand = ?, barcode = ?, dosage = ?, instructions = ?, 
         warnings = ?, interactions = ?, expiry_date = ?, image_paths = ?, 
         updated_at = CURRENT_TIMESTAMP
         WHERE id = ?`,
                [name, brand || null, barcode || null, dosage || null, instructions || null,
                    warnings || null, interactionsJson, expiry_date || null, imagePathsJson, id],
                function (err) {
                    if (err) {
                        return res.status(500).json({ error: 'Failed to update medicine' });
                    }

                    // Log activity
                    if (userId) {
                        logActivity({
                            user_id: userId,
                            action: 'update',
                            entity_type: 'medicine',
                            entity_id: parseInt(id),
                            details: { name, brand, barcode },
                            ip_address: req.ip || req.connection.remoteAddress,
                            user_agent: req.get('user-agent')
                        }).catch(err => console.error('Failed to log activity:', err));
                    }

                    res.json({
                        message: 'Medicine updated successfully',
                        medicine: {
                            id: parseInt(id),
                            name, brand, barcode, dosage, instructions, warnings,
                            interactions, expiry_date, image_paths
                        }
                    });
                }
            );
        }
    });
});

// Delete medicine (soft delete)
router.delete('/:id', authenticateToken, (req, res) => {
    const { id } = req.params;
    const userId = req.user ? req.user.id : null;

    db.get('SELECT id, name, brand FROM medicines WHERE id = ? AND is_deleted = 0', [id], (err, row) => {
        if (err) {
            return res.status(500).json({ error: 'Database error' });
        }

        if (!row) {
            return res.status(404).json({ error: 'Medicine not found' });
        }

        // Soft delete
        db.run(
            'UPDATE medicines SET is_deleted = 1, deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE id = ?',
            [userId, id],
            function (err) {
                if (err) {
                    return res.status(500).json({ error: 'Failed to delete medicine' });
                }

                // Log activity
                if (userId) {
                    logActivity({
                        user_id: userId,
                        action: 'delete',
                        entity_type: 'medicine',
                        entity_id: parseInt(id),
                        details: { name: row.name, brand: row.brand },
                        ip_address: req.ip || req.connection.remoteAddress,
                        user_agent: req.get('user-agent')
                    }).catch(err => console.error('Failed to log activity:', err));
                }

                res.json({ message: 'Medicine deleted successfully' });
            }
        );
    });
});

module.exports = router;
