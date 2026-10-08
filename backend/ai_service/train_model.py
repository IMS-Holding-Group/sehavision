"""
Training Script for Drug Recognition Model
سكريبت التدريب لنموذج التعرف على الأدوية
"""
import os
import sys
import json
import numpy as np
import cv2
from pathlib import Path
from datetime import datetime

try:
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras.preprocessing.image import ImageDataGenerator
    from tensorflow.keras.applications import MobileNetV2
    from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
    from tensorflow.keras.models import Model
    from tensorflow.keras.callbacks import ModelCheckpoint, EarlyStopping, ReduceLROnPlateau
    TENSORFLOW_AVAILABLE = True
except ImportError:
    TENSORFLOW_AVAILABLE = False
    print("Error: TensorFlow is required for training. Install with: pip install tensorflow")

from PIL import Image

import sys
import os

# Add current directory to path
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, current_dir)

from config.config import Config

class DrugRecognitionTrainer:
    def __init__(self):
        self.config = Config()
        self.model = None
        self.class_names = {}
        self.num_classes = 0
        
    def clean_corrupted_images(self, data_dir: str):
        """Remove corrupted images from training data"""
        data_path = Path(data_dir)
        corrupted_count = 0
        
        print("🔍 فحص الصور التالفة...")
        
        for drug_dir in data_path.iterdir():
            if not drug_dir.is_dir():
                continue
            
            for img_path in list(drug_dir.glob('*.jpg')) + list(drug_dir.glob('*.jpeg')) + list(drug_dir.glob('*.png')):
                try:
                    with Image.open(img_path) as img:
                        img.verify()  # Verify image
                    # Try to load again to make sure it's valid
                    img = Image.open(img_path)
                    img.load()
                except Exception as e:
                    print(f"⚠️ حذف صورة تالفة: {img_path} - {e}")
                    try:
                        img_path.unlink()
                        corrupted_count += 1
                    except:
                        pass
        
        if corrupted_count > 0:
            print(f"✅ تم حذف {corrupted_count} صورة تالفة")
        else:
            print("✅ لا توجد صور تالفة")
    
    def prepare_data(self, data_dir: str):
        """
        Prepare training data from directory structure:
        data_dir/
            drug_name_1/
                image1.jpg
                image2.jpg
            drug_name_2/
                image1.jpg
                ...
        """
        data_path = Path(data_dir)
        if not data_path.exists():
            raise ValueError(f"Data directory not found: {data_dir}")
        
        # Clean corrupted images first
        self.clean_corrupted_images(data_dir)
        
        # Get all drug classes (subdirectories)
        drug_classes = [d.name for d in data_path.iterdir() if d.is_dir()]
        drug_classes.sort()
        
        self.num_classes = len(drug_classes)
        self.class_names = {str(i): name for i, name in enumerate(drug_classes)}
        
        print(f"Found {self.num_classes} drug classes:")
        for idx, name in self.class_names.items():
            count = len(list((data_path / name).glob('*.jpg')) + 
                       list((data_path / name).glob('*.jpeg')) +
                       list((data_path / name).glob('*.png')))
            print(f"  {idx}: {name} ({count} images)")
        
        return drug_classes
    
    def create_model(self):
        """Create transfer learning model using MobileNetV2"""
        if not TENSORFLOW_AVAILABLE:
            raise RuntimeError("TensorFlow is required")
        
        # Load pre-trained MobileNetV2
        base_model = MobileNetV2(
            weights='imagenet',
            include_top=False,
            input_shape=(*self.config.INPUT_SIZE, 3)
        )
        
        # Freeze base model layers
        base_model.trainable = False
        
        # Add custom layers
        x = base_model.output
        x = GlobalAveragePooling2D()(x)
        x = Dense(512, activation='relu')(x)
        x = Dropout(0.5)(x)
        x = Dense(256, activation='relu')(x)
        x = Dropout(0.3)(x)
        predictions = Dense(self.num_classes, activation='softmax')(x)
        
        # Create model
        self.model = Model(inputs=base_model.input, outputs=predictions)
        
        # Compile model
        self.model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=self.config.LEARNING_RATE),
            loss='categorical_crossentropy',
            metrics=['accuracy', tf.keras.metrics.TopKCategoricalAccuracy(k=3, name='top_3_accuracy')]
        )
        
        print(f"Model created with {self.num_classes} classes")
        self.model.summary()
        
        return self.model
    
    def train(self, data_dir: str, epochs: int = None, batch_size: int = None):
        """
        Train the model
        تدريب النموذج
        """
        if not TENSORFLOW_AVAILABLE:
            raise RuntimeError("TensorFlow is required for training")
        
        epochs = epochs or self.config.EPOCHS
        batch_size = batch_size or self.config.BATCH_SIZE
        
        # Prepare data
        drug_classes = self.prepare_data(data_dir)
        
        # Create model
        self.create_model()
        
        # Data augmentation
        train_datagen = ImageDataGenerator(
            rescale=1./255,
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            horizontal_flip=True,
            zoom_range=0.2,
            brightness_range=[0.8, 1.2],
            validation_split=self.config.VALIDATION_SPLIT
        )
        
        # Training generator
        train_generator = train_datagen.flow_from_directory(
            data_dir,
            target_size=self.config.INPUT_SIZE,
            batch_size=batch_size,
            class_mode='categorical',
            subset='training',
            shuffle=True
        )
        
        # Validation generator
        val_generator = train_datagen.flow_from_directory(
            data_dir,
            target_size=self.config.INPUT_SIZE,
            batch_size=batch_size,
            class_mode='categorical',
            subset='validation',
            shuffle=False
        )
        
        # Callbacks
        os.makedirs(os.path.dirname(self.config.MODEL_PATH), exist_ok=True)
        
        callbacks = [
            ModelCheckpoint(
                self.config.MODEL_PATH,
                monitor='val_accuracy',
                save_best_only=True,
                verbose=1
            ),
            EarlyStopping(
                monitor='val_loss',
                patience=10,
                restore_best_weights=True,
                verbose=1
            ),
            ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=5,
                min_lr=1e-7,
                verbose=1
            )
        ]
        
        # Train model
        print(f"\nStarting training for {epochs} epochs...")
        history = self.model.fit(
            train_generator,
            epochs=epochs,
            validation_data=val_generator,
            callbacks=callbacks,
            verbose=1
        )
        
        # Save class names
        class_names_path = os.path.join(
            os.path.dirname(self.config.MODEL_PATH),
            'class_names.json'
        )
        with open(class_names_path, 'w', encoding='utf-8') as f:
            json.dump(self.class_names, f, ensure_ascii=False, indent=2)
        
        print(f"\nTraining completed!")
        print(f"Model saved to: {self.config.MODEL_PATH}")
        print(f"Class names saved to: {class_names_path}")
        print(f"Final validation accuracy: {max(history.history['val_accuracy']):.4f}")
        
        return history

def main():
    """Main training function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Train drug recognition model')
    parser.add_argument('--data-dir', type=str, required=True,
                       help='Path to training data directory')
    parser.add_argument('--epochs', type=int, default=50,
                       help='Number of training epochs')
    parser.add_argument('--batch-size', type=int, default=32,
                       help='Batch size for training')
    
    args = parser.parse_args()
    
    trainer = DrugRecognitionTrainer()
    
    try:
        trainer.train(
            data_dir=args.data_dir,
            epochs=args.epochs,
            batch_size=args.batch_size
        )
    except Exception as e:
        print(f"Training failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()

