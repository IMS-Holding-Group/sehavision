# دليل التثبيت - SehaVision AI Service (Windows)

## المتطلبات الأساسية

### 1. تثبيت Python 3.10.6

#### خطوات التثبيت:

1. **تحميل Python 3.10.6:**
   - افتح المتصفح واذهب إلى: https://www.python.org/downloads/release/python-3106/
   - أو مباشرة: https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe
   - حمّل الملف `python-3.10.6-amd64.exe` (أو `python-3.10.6.exe` إذا كان نظامك 32-bit)

2. **تشغيل ملف التثبيت:**
   - انقر نقراً مزدوجاً على الملف المحمّل
   - **مهم جداً**: تأكد من تحديد خيار **"Add Python 3.10 to PATH"** في أسفل نافذة التثبيت
   - اختر **"Install Now"** للتثبيت الافتراضي
   - أو اختر **"Customize installation"** للتخصيص

3. **انتظار اكتمال التثبيت:**
   - انتظر حتى يكتمل التثبيت
   - عند الانتهاء، انقر على **"Close"**

4. **التحقق من التثبيت:**
   - افتح **Command Prompt** (cmd) أو **PowerShell**
   - اكتب الأمر التالي واضغط Enter:
     ```cmd
     python --version
     ```
   - يجب أن ترى: `Python 3.10.6`
   
   - أيضاً تحقق من pip:
     ```cmd
     pip --version
     ```
   - يجب أن ترى إصدار pip

5. **إذا لم يعمل الأمر `python`:**
   - جرب `py --version` بدلاً منه
   - إذا لم يعمل، قد تحتاج لإضافة Python إلى PATH يدوياً:
     1. افتح **Control Panel** > **System** > **Advanced system settings**
     2. انقر على **Environment Variables**
     3. في **System variables**، ابحث عن **Path** وانقر **Edit**
     4. أضف المسارات التالية:
        - `C:\Python310\`
        - `C:\Python310\Scripts\`
     5. انقر **OK** في جميع النوافذ
     6. أعد فتح Command Prompt وجرب مرة أخرى

### 2. تثبيت Tesseract OCR

1. **تحميل Tesseract:**
   - افتح المتصفح واذهب إلى: https://github.com/UB-Mannheim/tesseract/wiki
   - حمّل أحدث إصدار (مثلاً: `tesseract-ocr-w64-setup-5.x.x.exe`)

2. **تثبيت Tesseract:**
   - انقر نقراً مزدوجاً على الملف المحمّل
   - أثناء التثبيت، تأكد من تحديد **"Additional language data"** واختر **Arabic**
   - قم بتثبيته في المسار الافتراضي: `C:\Program Files\Tesseract-OCR`
   - أو إذا غيرت المسار، سجل المسار الجديد

3. **التحقق من التثبيت:**
   - افتح Command Prompt
   - اكتب:
     ```cmd
     tesseract --version
     ```
   - يجب أن ترى معلومات الإصدار

## خطوات التثبيت

### 1. الانتقال إلى مجلد AI Service

افتح Command Prompt وانتقل إلى مجلد المشروع:

```cmd
cd C:\Users\TRSI\VSCode\Projects\flutterprojects\sehavision\backend\ai_service
```

(غيّر المسار حسب موقع مشروعك)

### 2. تثبيت المكتبات المطلوبة

قم بتثبيت جميع المكتبات المطلوبة:

```cmd
pip install -r requirements.txt
```

**ملاحظة:** قد يستغرق التثبيت بضع دقائق، خاصة TensorFlow

### 3. تشغيل سكريبت الإعداد (اختياري)

```cmd
python setup.py
```

هذا السكريبت سينشئ المجلدات المطلوبة تلقائياً.

## التشغيل

```cmd
python app.py
```

الخدمة ستعمل على: `http://localhost:5000`

## التحقق من التثبيت

### 1. التحقق من Python:
```cmd
python --version
```
يجب أن يظهر: `Python 3.10.6`

### 2. التحقق من Tesseract:
```cmd
tesseract --version
```
يجب أن يظهر معلومات الإصدار

### 3. التحقق من AI Service:

افتح المتصفح واذهب إلى:
```
http://localhost:5000/health
```

يجب أن ترى:
```json
{
  "status": "OK",
  "service": "SehaVision AI Service",
  "timestamp": "...",
  "version": "1.0.0"
}
```

## استكشاف الأخطاء

### خطأ: "python is not recognized"
- تأكد من تثبيت Python 3.10.6
- تأكد من تحديد "Add Python to PATH" أثناء التثبيت
- جرب `py --version` بدلاً من `python --version`
- أعد تشغيل Command Prompt بعد إضافة Python إلى PATH

### خطأ: "Tesseract not found"
- تأكد من تثبيت Tesseract
- تحقق من المسار في `config/config.py` إذا كان التثبيت في مسار غير افتراضي
- أعد تشغيل Command Prompt بعد التثبيت

### خطأ: "Module not found"
- تأكد من تثبيت جميع المكتبات: `pip install -r requirements.txt`
- تأكد من أنك في المجلد الصحيح: `backend/ai_service`
- جرب تحديث pip: `python -m pip install --upgrade pip`

### خطأ: "Port already in use"
- المنفذ 5000 مستخدم من قبل تطبيق آخر
- أوقف التطبيق الذي يستخدم المنفذ 5000
- أو غيّر المنفذ في `app.py` (السطر الأخير)

### خطأ أثناء تثبيت TensorFlow
- تأكد من استخدام Python 3.10.6
- جرب: `pip install --upgrade pip`
- ثم: `pip install tensorflow==2.15.0`

## التكامل مع Node.js Backend

1. تأكد من تشغيل AI Service على المنفذ 5000
2. شغّل Node.js backend:
   ```cmd
   cd ..\..
   npm start
   ```
3. النظام سيتصل بـ AI Service تلقائياً عند المسح

## التدريب على النموذج (اختياري)

### ملفات التدريب:

الملفات المتوفرة للتدريب:
- ✅ `train_model.py` - سكريبت التدريب الرئيسي
- ✅ `setup_training_data.py` - سكريبت إعداد هيكل المجلدات
- ✅ `TRAINING_GUIDE.md` - دليل شامل للتدريب

### الخطوة 1: إعداد هيكل بيانات التدريب

```cmd
python setup_training_data.py
```

هذا سينشئ مجلدات مثال للأدوية في `training_data/`

### الخطوة 2: جمع صور الأدوية

لكل دواء تريد تدريبه:

1. **أضف صور عبوات الأدوية** في المجلد المناسب:
   ```
   training_data/paracetamol/
     image1.jpg
     image2.jpg
     image3.jpg
     ...
   ```

2. **متطلبات الصور:**
   - الحد الأدنى: 50-100 صورة لكل دواء
   - لنتائج ممتازة: 200+ صورة لكل دواء
   - صور واضحة تظهر اسم الدواء/العلامة التجارية

### الخطوة 3: تشغيل التدريب

```cmd
python train_model.py --data-dir training_data --epochs 50 --batch-size 32
```

**ملاحظة:** 
- التدريب قد يستغرق وقتاً طويلاً حسب عدد الصور ومواصفات جهازك
- بعد التدريب، النموذج سيحفظ في `models/drug_recognition_model.h5`

**للمزيد من التفاصيل:** راجع `TRAINING_GUIDE.md`

## الدعم

للمساعدة، راجع `README.md` أو `QUICKSTART.md`
