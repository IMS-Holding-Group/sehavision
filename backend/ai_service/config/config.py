"""
Configuration for AI Service
"""
import os

class Config:
    # Flask settings
    FLASK_DEBUG = os.environ.get('FLASK_DEBUG', 'True')
    AI_SERVICE_PORT = int(os.environ.get('AI_SERVICE_PORT', 5000))
    
    # Paths
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads', 'ai_scans')
    MODELS_FOLDER = os.path.join(BASE_DIR, 'ai_service', 'models')
    TRAINING_DATA_FOLDER = os.path.join(BASE_DIR, 'ai_service', 'training_data')
    
    # Database
    DATABASE_PATH = os.path.join(BASE_DIR, 'database', 'sehavision.db')
    
    # OCR Settings
    OCR_LANGUAGES = ['eng', 'ara']  # English and Arabic
    OCR_ENGINE = 'tesseract'  # or 'easyocr'
    
    # AI Model Settings
    MODEL_TYPE = 'cnn'  # 'cnn', 'yolo', or 'custom'
    MODEL_PATH = os.path.join(MODELS_FOLDER, 'drug_recognition_model.h5')
    INPUT_SIZE = (224, 224)  # Image input size for model
    
    # Training Settings
    BATCH_SIZE = 32
    EPOCHS = 50
    LEARNING_RATE = 0.001
    VALIDATION_SPLIT = 0.2
    
    # Image Processing
    MAX_IMAGE_SIZE = (1920, 1080)
    IMAGE_QUALITY = 85
    
    # Confidence thresholds
    MIN_CONFIDENCE = 0.3
    HIGH_CONFIDENCE = 0.8

