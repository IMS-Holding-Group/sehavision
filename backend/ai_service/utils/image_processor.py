"""
Image Processing Utilities
أدوات معالجة الصور
"""
import cv2
import numpy as np
from typing import Tuple

class ImageProcessor:
    def __init__(self):
        self.max_size = (1920, 1080)
        self.target_size = (800, 600)
    
    def preprocess(self, image_path: str) -> np.ndarray:
        """
        Preprocess image for recognition
        معالجة الصورة للتعرف
        """
        # Read image
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Could not read image: {image_path}")
        
        # Resize if too large
        height, width = img.shape[:2]
        if width > self.max_size[0] or height > self.max_size[1]:
            scale = min(self.max_size[0] / width, self.max_size[1] / height)
            new_width = int(width * scale)
            new_height = int(height * scale)
            img = cv2.resize(img, (new_width, new_height), interpolation=cv2.INTER_AREA)
        
        # Enhance image quality
        img = self._enhance_image(img)
        
        return img
    
    def _enhance_image(self, img: np.ndarray) -> np.ndarray:
        """Enhance image for better recognition"""
        # Convert to LAB color space
        lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
        l, a, b = cv2.split(lab)
        
        # Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
        l = clahe.apply(l)
        
        # Merge channels
        enhanced = cv2.merge([l, a, b])
        enhanced = cv2.cvtColor(enhanced, cv2.COLOR_LAB2BGR)
        
        # Denoise
        denoised = cv2.fastNlMeansDenoisingColored(enhanced, None, 10, 10, 7, 21)
        
        return denoised
    
    def save_image(self, image: np.ndarray, path: str, quality: int = 85):
        """Save processed image"""
        cv2.imwrite(path, image, [cv2.IMWRITE_JPEG_QUALITY, quality])
    
    def resize(self, image: np.ndarray, size: Tuple[int, int]) -> np.ndarray:
        """Resize image"""
        return cv2.resize(image, size, interpolation=cv2.INTER_AREA)
    
    def crop(self, image: np.ndarray, x: int, y: int, width: int, height: int) -> np.ndarray:
        """Crop image"""
        return image[y:y+height, x:x+width]

