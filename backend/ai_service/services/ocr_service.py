"""
Advanced OCR Service with Arabic and English support
خدمة OCR متقدمة مع دعم العربية والإنجليزية
"""
import cv2
import numpy as np
import time
from typing import Dict, Optional
import os

try:
    import pytesseract
    TESSERACT_AVAILABLE = True
except ImportError:
    TESSERACT_AVAILABLE = False
    print("Warning: pytesseract not available. Install with: pip install pytesseract")

try:
    import easyocr
    EASYOCR_AVAILABLE = True
except ImportError:
    EASYOCR_AVAILABLE = False
    print("Warning: easyocr not available. Install with: pip install easyocr")

from config.config import Config

class OCRService:
    def __init__(self):
        self.config = Config()
        self.tesseract_available = TESSERACT_AVAILABLE
        self.easyocr_available = EASYOCR_AVAILABLE
        
        # Initialize EasyOCR reader if available
        if self.easyocr_available and Config.OCR_ENGINE == 'easyocr':
            try:
                self.easyocr_reader = easyocr.Reader(['en', 'ar'], gpu=False)
                print("EasyOCR initialized successfully")
            except Exception as e:
                print(f"Failed to initialize EasyOCR: {e}")
                self.easyocr_available = False
        
        # Set Tesseract path if on Windows
        if os.name == 'nt':
            # Common Tesseract installation paths on Windows
            possible_paths = [
                r'C:\Program Files\Tesseract-OCR\tesseract.exe',
                r'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe',
            ]
            for path in possible_paths:
                if os.path.exists(path):
                    pytesseract.pytesseract.tesseract_cmd = path
                    break
    
    def preprocess_image(self, image_path: str) -> np.ndarray:
        """Preprocess image for better OCR results"""
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Could not read image: {image_path}")
        
        # Convert to grayscale
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        # Apply denoising
        denoised = cv2.fastNlMeansDenoising(gray, None, 10, 7, 21)
        
        # Apply adaptive thresholding
        thresh = cv2.adaptiveThreshold(
            denoised, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
            cv2.THRESH_BINARY, 11, 2
        )
        
        # Apply morphological operations to clean up
        kernel = np.ones((2, 2), np.uint8)
        cleaned = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)
        
        return cleaned
    
    def extract_text_tesseract(self, image_path: str) -> Dict:
        """Extract text using Tesseract OCR"""
        if not self.tesseract_available:
            return {
                'success': False,
                'error': 'Tesseract OCR not available'
            }
        
        try:
            start_time = time.time()
            
            # Preprocess image
            processed_img = self.preprocess_image(image_path)
            
            # Extract text with Arabic and English
            custom_config = r'--oem 3 --psm 6 -l eng+ara'
            text = pytesseract.image_to_string(processed_img, config=custom_config)
            
            # Get detailed data for confidence
            data = pytesseract.image_to_data(processed_img, config=custom_config, output_type=pytesseract.Output.DICT)
            
            # Calculate average confidence
            confidences = [int(conf) for conf in data['conf'] if int(conf) > 0]
            avg_confidence = sum(confidences) / len(confidences) / 100.0 if confidences else 0.5
            
            processing_time = (time.time() - start_time) * 1000  # in milliseconds
            
            return {
                'success': True,
                'text': text.strip(),
                'confidence': avg_confidence,
                'processing_time': processing_time,
                'engine': 'tesseract'
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'text': '',
                'confidence': 0.0
            }
    
    def extract_text_easyocr(self, image_path: str) -> Dict:
        """Extract text using EasyOCR"""
        if not self.easyocr_available:
            return {
                'success': False,
                'error': 'EasyOCR not available'
            }
        
        try:
            start_time = time.time()
            
            # Read image
            img = cv2.imread(image_path)
            if img is None:
                raise ValueError(f"Could not read image: {image_path}")
            
            # Extract text
            results = self.easyocr_reader.readtext(img)
            
            # Combine all detected text
            text_parts = []
            confidences = []
            
            for (bbox, text, confidence) in results:
                text_parts.append(text)
                confidences.append(confidence)
            
            combined_text = ' '.join(text_parts)
            avg_confidence = sum(confidences) / len(confidences) if confidences else 0.5
            
            processing_time = (time.time() - start_time) * 1000  # in milliseconds
            
            return {
                'success': True,
                'text': combined_text.strip(),
                'confidence': avg_confidence,
                'processing_time': processing_time,
                'engine': 'easyocr',
                'detections': results
            }
        except Exception as e:
            return {
                'success': False,
                'error': str(e),
                'text': '',
                'confidence': 0.0
            }
    
    def extract_text(self, image_path: str) -> Dict:
        """
        Extract text from image using the configured OCR engine
        استخراج النص من الصورة باستخدام محرك OCR المحدد
        """
        if Config.OCR_ENGINE == 'easyocr' and self.easyocr_available:
            return self.extract_text_easyocr(image_path)
        elif self.tesseract_available:
            return self.extract_text_tesseract(image_path)
        else:
            return {
                'success': False,
                'error': 'No OCR engine available. Please install pytesseract or easyocr',
                'text': '',
                'confidence': 0.0
            }

