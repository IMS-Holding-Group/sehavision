"""
SehaVision AI Service - Flask Backend
نظام متقدم للتعرف على الأدوية باستخدام الذكاء الاصطناعي
"""
import os
import sys
from datetime import datetime
import traceback

# Add current directory to path for imports (must be before other imports)
# This ensures that 'services', 'utils', and 'config' modules can be found
current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

# Change working directory to ensure relative paths work correctly
os.chdir(current_dir)

from flask import Flask, request, jsonify, send_file
from flask_cors import CORS

# Import local modules with better error handling
try:
    from services.ocr_service import OCRService
    from services.drug_recognition import DrugRecognitionService
    from services.database_service import DatabaseService
    from utils.image_processor import ImageProcessor
    from config.config import Config
except ImportError as e:
    error_msg = str(e)
    current_path = os.path.abspath(__file__)
    print(f"\n{'='*60}")
    print("ERROR: Failed to import required modules")
    print(f"{'='*60}")
    print(f"Current file: {current_path}")
    print(f"Current directory: {current_dir}")
    print(f"Python path (first 3 entries):")
    for i, path in enumerate(sys.path[:3]):
        print(f"  {i+1}. {path}")
    print(f"\nImport error: {error_msg}")
    print(f"\nPlease make sure you're running the script from the correct directory:")
    print(f"  cd {current_dir}")
    print(f"  python app.py")
    print(f"{'='*60}\n")
    raise

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Initialize services
ocr_service = OCRService()
drug_recognition_service = DrugRecognitionService()
database_service = DatabaseService()
image_processor = ImageProcessor()

# Create uploads directory
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads', 'ai_scans')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Serve uploaded files
@app.route('/uploads/ai_scans/<filename>')
def uploaded_file(filename):
    """Serve uploaded scan images"""
    return send_file(os.path.join(UPLOAD_FOLDER, filename))

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'OK',
        'service': 'SehaVision AI Service',
        'timestamp': datetime.now().isoformat(),
        'version': '1.0.0'
    })

@app.route('/recognize', methods=['POST'])
def recognize_drug():
    """
    Recognize drug from image
    التعرف على الدواء من الصورة
    """
    try:
        if 'image' not in request.files:
            return jsonify({
                'success': False,
                'error': 'No image file provided',
                'error_ar': 'لم يتم توفير صورة'
            }), 400

        file = request.files['image']
        if file.filename == '':
            return jsonify({
                'success': False,
                'error': 'Empty file',
                'error_ar': 'ملف فارغ'
            }), 400

        # Save uploaded file
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_%f')
        filename = f'scan_{timestamp}.jpg'
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)

        # Process image
        processed_image = image_processor.preprocess(filepath)
        processed_path = os.path.join(UPLOAD_FOLDER, f'processed_{filename}')
        image_processor.save_image(processed_image, processed_path)

        # Step 1: Extract text using OCR (Arabic + English)
        ocr_result = ocr_service.extract_text(processed_path)
        
        # Step 2: Use AI model for drug recognition
        ai_result = drug_recognition_service.recognize(processed_image)
        
        # Step 3: Search in database
        search_text = ocr_result.get('text', '') if ocr_result.get('success') else ''
        ai_prediction = ai_result.get('predicted_name', '') if ai_result.get('success') else ''
        
        # Clean AI prediction name (remove underscores, normalize)
        if ai_prediction:
            ai_prediction_clean = ai_prediction.replace('_', ' ').strip()
            search_text = f"{search_text} {ai_prediction_clean}".strip()
        
        medicines = []
        if search_text:
            medicines = database_service.search_medicines(search_text)
        
        # If no results and we have AI prediction, try searching with AI prediction only
        if not medicines and ai_prediction:
            ai_search = ai_prediction.replace('_', ' ').strip()
            medicines = database_service.search_medicines(ai_search)
        
        # If still no results, try partial matches
        if not medicines and ai_prediction:
            # Try searching for partial name matches
            ai_words = ai_prediction.replace('_', ' ').split()
            for word in ai_words:
                if len(word) > 3:
                    medicines = database_service.search_medicines(word)
                    if medicines:
                        break
        
        # Step 4: Combine results and calculate confidence
        if medicines:
            best_match = medicines[0]
            confidence = calculate_confidence(ocr_result, ai_result, best_match, search_text)
            
            return jsonify({
                'success': True,
                'medicine': {
                    'id': best_match.get('id'),
                    'name': best_match.get('name'),
                    'name_ar': best_match.get('name_ar'),
                    'brand': best_match.get('brand'),
                    'brand_ar': best_match.get('brand_ar'),
                    'description': best_match.get('description'),
                    'description_ar': best_match.get('description_ar'),
                    'dosage': best_match.get('dosage'),
                    'side_effects': best_match.get('side_effects'),
                    'interactions': best_match.get('interactions'),
                    'image_paths': best_match.get('image_paths', [])
                },
                'confidence': confidence,
                'ocr_text': ocr_result.get('text', '')[:200] if ocr_result.get('success') else '',
                'ai_prediction': ai_result.get('predicted_name', '') if ai_result.get('success') else '',
                'alternatives': medicines[1:6] if len(medicines) > 1 else [],
                'processing_time': ocr_result.get('processing_time', 0) + ai_result.get('processing_time', 0),
                'scan_image': f'/uploads/ai_scans/{filename}'
            })
        else:
            return jsonify({
                'success': False,
                'error': 'Drug not found in database',
                'error_ar': 'الدواء غير موجود في قاعدة البيانات',
                'ocr_text': ocr_result.get('text', '')[:200] if ocr_result.get('success') else '',
                'ai_prediction': ai_result.get('predicted_name', '') if ai_result.get('success') else '',
                'suggestions': 'Try taking a clearer picture or check the drug name spelling',
                'suggestions_ar': 'حاول التقاط صورة أوضح أو تحقق من تهجئة اسم الدواء'
            }), 404

    except Exception as e:
        print(f"Error in recognize_drug: {str(e)}")
        print(traceback.format_exc())
        return jsonify({
            'success': False,
            'error': f'Processing error: {str(e)}',
            'error_ar': f'خطأ في المعالجة: {str(e)}'
        }), 500

def calculate_confidence(ocr_result, ai_result, medicine, search_text):
    """Calculate confidence score based on OCR, AI, and database match"""
    confidence = 0.0
    
    # OCR confidence (0-0.4)
    if ocr_result.get('success'):
        ocr_conf = ocr_result.get('confidence', 0.5)
        confidence += ocr_conf * 0.4
    
    # AI model confidence (0-0.4)
    if ai_result.get('success'):
        ai_conf = ai_result.get('confidence', 0.5)
        confidence += ai_conf * 0.4
    
    # Database match confidence (0-0.2)
    medicine_name = (medicine.get('name', '') + ' ' + medicine.get('name_ar', '')).lower()
    medicine_brand = (medicine.get('brand', '') + ' ' + medicine.get('brand_ar', '')).lower()
    search_lower = search_text.lower()
    
    if search_lower in medicine_name or search_lower in medicine_brand:
        confidence += 0.2
    elif any(word in medicine_name or word in medicine_brand for word in search_lower.split() if len(word) > 3):
        confidence += 0.1
    
    return min(0.98, max(0.3, confidence))

@app.route('/ocr', methods=['POST'])
def ocr_only():
    """Extract text from image using OCR only"""
    try:
        if 'image' not in request.files:
            return jsonify({'success': False, 'error': 'No image provided'}), 400
        
        file = request.files['image']
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_%f')
        filename = f'ocr_{timestamp}.jpg'
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)
        
        result = ocr_service.extract_text(filepath)
        return jsonify(result)
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/train/status', methods=['GET'])
def training_status():
    """Get training status"""
    return jsonify({
        'status': drug_recognition_service.get_training_status()
    })

if __name__ == '__main__':
    port = int(os.environ.get('AI_SERVICE_PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    
    print(f"Starting SehaVision AI Service on port {port}")
    print(f"Upload folder: {UPLOAD_FOLDER}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)

