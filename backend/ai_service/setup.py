"""
Setup script for SehaVision AI Service
سكريبت الإعداد لخدمة الذكاء الاصطناعي
"""
import os
import sys

def create_directories():
    """Create necessary directories"""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    
    directories = [
        os.path.join(base_dir, 'models'),
        os.path.join(base_dir, 'training_data'),
        os.path.join(base_dir, '..', 'uploads', 'ai_scans'),
    ]
    
    for directory in directories:
        os.makedirs(directory, exist_ok=True)
        print(f"Created directory: {directory}")

def check_dependencies():
    """Check if required dependencies are installed"""
    required_packages = [
        'flask',
        'opencv-python',
        'numpy',
        'tensorflow'
    ]
    
    missing = []
    for package in required_packages:
        try:
            __import__(package.replace('-', '_'))
        except ImportError:
            missing.append(package)
    
    if missing:
        print("Missing packages:")
        for pkg in missing:
            print(f"  - {pkg}")
        print("\nInstall with: pip install -r requirements.txt")
        return False
    
    print("All required packages are installed!")
    return True

if __name__ == '__main__':
    print("SehaVision AI Service Setup")
    print("=" * 40)
    
    print("\n1. Creating directories...")
    create_directories()
    
    print("\n2. Checking dependencies...")
    if not check_dependencies():
        sys.exit(1)
    
    print("\nSetup completed successfully!")
    print("\nNext steps:")
    print("1. Install Tesseract OCR (see INSTALLATION.md)")
    print("2. Setup training data (optional):")
    print("   python setup_training_data.py")
    print("3. Run: python app.py")
    print("\nFor training guide, see: TRAINING_GUIDE.md")

