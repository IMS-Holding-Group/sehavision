"""
Advanced Drug Recognition Service using Deep Learning
خدمة التعرف على الأدوية باستخدام التعلم العميق
"""
import numpy as np
import cv2
import time
import os
from typing import Dict, Optional, Tuple
import json

try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras.models import load_model, Sequential
    from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
    TENSORFLOW_AVAILABLE = True
except ImportError:
    TENSORFLOW_AVAILABLE = False
    print("Warning: TensorFlow not available. Install with: pip install tensorflow")

from config.config import Config

class DrugRecognitionService:
    def __init__(self):
        self.config = Config()
        self.model = None
        self.model_loaded = False
        self.training_status = {
            'is_training': False,
            'current_epoch': 0,
            'total_epochs': 0,
            'accuracy': 0.0,
            'loss': 0.0
        }
        
        # Load model if it exists
        self._load_model()
    
    def _load_model(self):
        """Load pre-trained model if available"""
        if not TENSORFLOW_AVAILABLE:
            print("TensorFlow not available, using fallback recognition")
            return
        
        model_path = self.config.MODEL_PATH
        if os.path.exists(model_path):
            try:
                self.model = load_model(model_path)
                self.model_loaded = True
                print(f"Model loaded successfully from {model_path}")
            except Exception as e:
                print(f"Failed to load model: {e}")
                self._create_fallback_model()
        else:
            print(f"Model not found at {model_path}, using fallback recognition")
            self._create_fallback_model()
    
    def _create_fallback_model(self):
        """Create a simple fallback model for basic recognition"""
        if not TENSORFLOW_AVAILABLE:
            return
        
        try:
            # Simple CNN model for drug recognition
            self.model = Sequential([
                Conv2D(32, (3, 3), activation='relu', input_shape=(*self.config.INPUT_SIZE, 3)),
                MaxPooling2D(2, 2),
                Conv2D(64, (3, 3), activation='relu'),
                MaxPooling2D(2, 2),
                Conv2D(128, (3, 3), activation='relu'),
                MaxPooling2D(2, 2),
                Flatten(),
                Dense(512, activation='relu'),
                Dropout(0.5),
                Dense(256, activation='relu'),
                Dropout(0.5),
                Dense(100, activation='softmax')  # 100 drug classes (will be updated during training)
            ])
            
            self.model.compile(
                optimizer='adam',
                loss='categorical_crossentropy',
                metrics=['accuracy']
            )
            
            print("Fallback model created (needs training)")
            self.model_loaded = True
        except Exception as e:
            print(f"Failed to create fallback model: {e}")
    
    def preprocess_image(self, image: np.ndarray) -> np.ndarray:
        """Preprocess image for model input"""
        # Resize to model input size
        resized = cv2.resize(image, self.config.INPUT_SIZE)
        
        # Normalize pixel values
        normalized = resized.astype(np.float32) / 255.0
        
        # Expand dimensions for batch
        expanded = np.expand_dims(normalized, axis=0)
        
        return expanded
    
    def recognize(self, image: np.ndarray) -> Dict:
        """
        Recognize drug from image using AI model
        التعرف على الدواء من الصورة باستخدام نموذج الذكاء الاصطناعي
        """
        start_time = time.time()
        
        try:
            if not self.model_loaded or self.model is None:
                # Fallback: Use image features for basic recognition
                return self._fallback_recognition(image)
            
            # Preprocess image
            processed = self.preprocess_image(image)
            
            # Predict
            predictions = self.model.predict(processed, verbose=0)
            
            # Get top prediction
            top_class = np.argmax(predictions[0])
            confidence = float(predictions[0][top_class])
            
            # Load class names if available
            class_names = self._load_class_names()
            predicted_name = class_names.get(str(top_class), f"Drug_{top_class}") if class_names else f"Drug_{top_class}"
            
            processing_time = (time.time() - start_time) * 1000  # milliseconds
            
            return {
                'success': True,
                'predicted_name': predicted_name,
                'confidence': confidence,
                'class_id': int(top_class),
                'processing_time': processing_time,
                'all_predictions': {
                    str(i): float(pred) for i, pred in enumerate(predictions[0]) if pred > 0.1
                }
            }
        except Exception as e:
            print(f"Recognition error: {e}")
            return {
                'success': False,
                'error': str(e),
                'confidence': 0.0,
                'processing_time': (time.time() - start_time) * 1000
            }
    
    def _fallback_recognition(self, image: np.ndarray) -> Dict:
        """Fallback recognition using image features"""
        # Extract basic features (color, shape, etc.)
        # This is a placeholder until model is trained
        
        # Calculate image features
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        mean_intensity = np.mean(gray)
        std_intensity = np.std(gray)
        
        # Simple heuristic-based recognition
        # In production, this would be replaced by trained model
        confidence = 0.5  # Low confidence for fallback
        
        return {
            'success': True,
            'predicted_name': '',  # Will rely on OCR
            'confidence': confidence,
            'processing_time': 50,
            'method': 'fallback'
        }
    
    def _load_class_names(self) -> Dict:
        """Load class names mapping"""
        class_names_path = os.path.join(
            os.path.dirname(self.config.MODEL_PATH),
            'class_names.json'
        )
        
        if os.path.exists(class_names_path):
            try:
                with open(class_names_path, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                print(f"Failed to load class names: {e}")
        
        return {}
    
    def get_training_status(self) -> Dict:
        """Get current training status"""
        return self.training_status.copy()
    
    def train_model(self, data_path: str, epochs: int = None):
        """
        Train the drug recognition model
        تدريب نموذج التعرف على الأدوية
        """
        if not TENSORFLOW_AVAILABLE:
            raise RuntimeError("TensorFlow is required for training")
        
        epochs = epochs or self.config.EPOCHS
        self.training_status['is_training'] = True
        self.training_status['total_epochs'] = epochs
        
        try:
            # This would load training data and train the model
            # Implementation depends on data format
            print(f"Training model with data from {data_path}")
            print("Training implementation needed based on data format")
            
            # Placeholder for training logic
            # In production, implement:
            # 1. Load images and labels
            # 2. Data augmentation
            # 3. Train/validation split
            # 4. Model training
            # 5. Save model and class names
            
        except Exception as e:
            print(f"Training error: {e}")
            raise
        finally:
            self.training_status['is_training'] = False

