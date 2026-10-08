# SehaVision

تطبيق موبايل شامل للتعرف على الأدوية باستخدام الذكاء الاصطناعي والواقع المعزز، مبني باستخدام Flutter و Node.js.

## الميزات

- **التعرف على الأدوية**: مسح عبوات الأدوية باستخدام الكاميرا مع التعرف المدعوم بالذكاء الاصطناعي
- **الواقع المعزز**: طبقة AR لعرض معلومات الأدوية
- **التحويل إلى كلام**: ميزة إمكانية الوصول للمستخدمين ضعاف البصر
- **تذكيرات الأدوية**: نظام إشعارات محلي لتذكيرات الأدوية
- **مصادقة المستخدم**: تسجيل دخول/تسجيل آمن باستخدام رموز JWT
- **لوحة الإدارة**: إدارة خلفية لبيانات الأدوية
- **تفاعل الأدوية**: فحص التفاعلات المحتملة بين الأدوية
- **دعم متعدد اللغات**: دعم اللغة الإنجليزية والعربية
- **ثيم فاتح/داكن**: مظهر التطبيق قابل للتخصيص

## التقنيات المستخدمة

### الواجهة الأمامية (Flutter)
- **الإطار**: Flutter 3.13 مع Dart
- **إدارة الحالة**: Provider
- **التخزين المحلي**: SharedPreferences
- **عميل HTTP**: حزمة http
- **الكاميرا**: حزمة camera
- **اختيار الصور**: حزمة image_picker
- **التحويل إلى كلام**: حزمة flutter_tts
- **الإشعارات المحلية**: حزمة flutter_local_notifications
- **دعم AR**: حزمة ar_flutter_plugin
- **تكامل الذكاء الاصطناعي**: حزمة tflite_flutter

### الخادم الخلفي (Node.js)
- **بيئة التشغيل**: Node.js
- **الإطار**: Express.js
- **قاعدة البيانات**: SQLite
- **المصادقة**: JWT (jsonwebtoken)
- **تشفير كلمات المرور**: bcrypt
- **رفع الملفات**: multer
- **التحقق**: express-validator
- **الاختبار**: Jest مع supertest

### خدمة الذكاء الاصطناعي (Python/Flask) 🆕
- **الإطار**: Flask
- **OCR**: Tesseract + EasyOCR (دعم العربية والإنجليزية)
- **التعلم العميق**: TensorFlow/Keras
- **نموذج التعرف**: CNN مع Transfer Learning (MobileNetV2)
- **معالجة الصور**: OpenCV
- **التكامل**: API RESTful متكامل مع Node.js

## هيكل المشروع

```
sehavision/
├── frontend/                 # تطبيق Flutter
│   ├── lib/
│   │   ├── models/          # نماذج البيانات
│   │   ├── providers/       # إدارة الحالة
│   │   ├── screens/         # شاشات الواجهة
│   │   ├── services/        # خدمات API
│   │   └── utils/           # الأدوات والثيمات
│   ├── assets/              # الصور، الخطوط، إلخ
│   └── pubspec.yaml         # تبعيات Flutter
├── backend/                 # خادم Node.js الخلفي
│   ├── routes/              # مسارات API
│   ├── middleware/          # البرمجيات الوسيطة المخصصة
│   ├── config/              # ملفات التكوين
│   ├── scripts/             # سكريبتات قاعدة البيانات
│   ├── tests/               # اختبارات الوحدة
│   ├── ai_service/          # 🆕 خدمة الذكاء الاصطناعي (Python/Flask)
│   │   ├── app.py           # Flask application
│   │   ├── services/        # خدمات OCR والتعرف
│   │   ├── config/          # إعدادات AI
│   │   ├── train_model.py   # سكريبت التدريب
│   │   └── requirements.txt  # تبعيات Python
│   └── package.json         # تبعيات Node.js
└── README.md               # هذا الملف
```

## التثبيت والإعداد الشامل

### المتطلبات الأساسية

- **Flutter**: 3.0 أو أحدث
- **Node.js**: 16.0 أو أحدث
- **npm**: 8.0 أو أحدث
- **Android Studio**: لتطوير Android (يتضمن Android Emulator)
- **Python 3.10.6**: لخدمة الذكاء الاصطناعي 
- **Tesseract OCR**: للتعرف على النص (اختياري)

---

## 📋 دليل التثبيت خطوة بخطوة

### 1️⃣ تثبيت Node.js

#### Windows:
1. **تحميل Node.js:**
   - اذهب إلى: https://nodejs.org/
   - حمّل النسخة LTS (مثلاً: Node.js 18.x أو 20.x)
   - الملف: `node-v20.x.x-x64.msi`

2. **التثبيت:**
   - شغّل ملف التثبيت
   - اضغط "Next" في جميع الخطوات
   - تأكد من تحديد "Add to PATH"
   - انقر "Install"

3. **التحقق من التثبيت:**
   ```cmd
   node --version
   npm --version
   ```
   يجب أن ترى أرقام الإصدار

---

### 2️⃣ تثبيت Flutter

#### Windows:
1. **تحميل Flutter SDK:**
   - اذهب إلى: https://flutter.dev/docs/get-started/install/windows
   - حمّل Flutter SDK (zip file)
   - استخرج الملف في مكان مناسب (مثلاً: `C:\src\flutter`)

2. **إضافة Flutter إلى PATH:**
   - افتح "Environment Variables"
   - أضف `C:\src\flutter\bin` إلى PATH
   - أعد فتح Command Prompt

3. **التحقق من التثبيت:**
   ```cmd
   flutter doctor
   ```
   يجب أن ترى حالة Flutter

4. **تثبيت Android Studio:**
   - حمّل من: https://developer.android.com/studio
   - ثبّت Android Studio
   - افتح Android Studio → More Actions → SDK Manager
   - ثبّت Android SDK و Android SDK Platform-Tools
   - افتح Android Studio → More Actions → Virtual Device Manager
   - أنشئ Android Emulator (مثلاً: Pixel 5, API 33)

---

### 3️⃣ إعداد الخادم الخلفي (Node.js)

#### الخطوة 1: الانتقال إلى مجلد Backend
```cmd
cd c:\Users\TRSI\VSCode\Projects\flutterprojects\sehavision\backend
```

#### الخطوة 2: تثبيت التبعيات
```cmd
npm install
```
**ملاحظة:** قد يستغرق بضع دقائق

#### الخطوة 3: تهيئة قاعدة البيانات
```cmd
node scripts/init-db.js
```
هذا سينشئ قاعدة البيانات ويضيف بيانات تجريبية

#### الخطوة 4: تشغيل الخادم
```cmd
npm start
```

**النتيجة المتوقعة:**
```
SehaVision Backend running on port 3000
Health check: http://localhost:3000/api/health
```

**✅ الخادم الآن يعمل على:** `http://localhost:3000`

**⚠️ مهم:** اترك هذا النافذة مفتوحة! الخادم يجب أن يبقى يعمل.

---

### 4️⃣ إعداد خدمة الذكاء الاصطناعي (اختياري لكن موصى به)

راجع `backend/ai_service/INSTALLATION.md` للتفاصيل الكاملة.

**باختصار:**
```cmd
cd backend\ai_service
pip install -r requirements.txt
python app.py
```

---

### 5️⃣ إعداد وتشغيل تطبيق Flutter

#### الخطوة 1: فتح Android Emulator

**الطريقة 1: من Android Studio**
1. افتح Android Studio
2. Tools → Device Manager
3. انقر على ▶️ بجانب Emulator المطلوب

**الطريقة 2: من Command Prompt**
```cmd
flutter emulators --launch <emulator_id>
```

**الطريقة 3: قائمة Emulators**
```cmd
flutter emulators
```
ثم اختر Emulator من القائمة

#### الخطوة 2: التحقق من الأجهزة المتاحة
```cmd
flutter devices
```

يجب أن ترى:
```
Windows (desktop) • windows • windows-x64
Chrome (web)      • chrome  • web-javascript
<emulator_name>   • <id>    • android-arm64
```

#### الخطوة 3: الانتقال إلى مجلد Frontend
```cmd
cd c:\Users\TRSI\VSCode\Projects\flutterprojects\sehavision\frontend
```

#### الخطوة 4: تثبيت تبعيات Flutter
```cmd
flutter pub get
```

#### الخطوة 5: تحديث عنوان API (إذا لزم)

افتح ملف `lib/services/api_service.dart` وتحقق من:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api'; // للـ Emulator
// أو
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api'; // للجهاز الحقيقي
```

**ملاحظة:** 
- `10.0.2.2` = localhost للـ Android Emulator
- للجهاز الحقيقي: استخدم IP جهازك (مثلاً: `192.168.1.5`)

#### الخطوة 6: تشغيل التطبيق

**الطريقة 1: تشغيل على Emulator المفتوح**
```cmd
flutter run
```

**الطريقة 2: تشغيل على جهاز محدد**
```cmd
flutter run -d <device_id>
```

**الطريقة 3: تشغيل على Android فقط**
```cmd
flutter run -d android
```

**النتيجة المتوقعة:**
```
Launching lib\main.dart on <emulator_name> in debug mode...
Running Gradle task 'assembleDebug'...
✓ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app.apk...
Flutter run key commands.
```

**✅ التطبيق الآن يعمل على Emulator!**

---

## 🔧 حل المشاكل الشائعة

### مشكلة: "No devices found"
**الحل:**
1. تأكد من فتح Android Emulator
2. شغّل: `flutter doctor` للتحقق من الإعداد
3. شغّل: `flutter devices` لرؤية الأجهزة المتاحة

### مشكلة: "Connection refused" في التطبيق
**الحل:**
1. تأكد من تشغيل Node.js backend (`npm start`)
2. تحقق من عنوان API في `api_service.dart`
3. للـ Emulator: استخدم `10.0.2.2:3000`
4. للجهاز الحقيقي: استخدم IP جهازك

### مشكلة: "Gradle build failed"
**الحل:**
```cmd
cd android
gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### مشكلة: Emulator بطيء جداً
**الحل:**
1. زد RAM Emulator في AVD Manager
2. فعّل Hardware Acceleration
3. استخدم Emulator أصغر (مثلاً: Pixel 3 بدلاً من Pixel 5)

---

## 📱 تشغيل على جهاز Android حقيقي

### الخطوة 1: تفعيل Developer Options
1. Settings → About Phone
2. اضغط على "Build Number" 7 مرات
3. Settings → Developer Options
4. فعّل "USB Debugging"

### الخطوة 2: الاتصال بالجهاز
1. وصّل الجهاز بالكمبيوتر عبر USB
2. قبول "Allow USB Debugging" على الجهاز
3. شغّل: `flutter devices` للتحقق

### الخطوة 3: تحديث عنوان API
في `api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
```

**لإيجاد IP جهازك:**
```cmd
ipconfig
```
ابحث عن IPv4 Address (مثلاً: 192.168.1.5)

### الخطوة 4: تشغيل التطبيق
```cmd
flutter run -d <device_id>
```

---

## 🎯 ملخص الخطوات السريعة

```cmd
# 1. تشغيل Backend (نافذة 1)
cd backend
npm install
node scripts/init-db.js
npm start

# 2. فتح Android Emulator (نافذة 2)
# من Android Studio أو:
flutter emulators --launch <emulator_id>

# 3. تشغيل Flutter App (نافذة 3)
cd frontend
flutter pub get
flutter run
```

---

## ✅ التحقق من نجاح الإعداد

1. **Backend يعمل:** افتح `http://localhost:3000/api/health` في المتصفح
2. **Emulator يعمل:** يجب أن ترى شاشة Android
3. **Flutter App يعمل:** يجب أن يفتح التطبيق على Emulator
4. **الاتصال يعمل:** جرب تسجيل الدخول في التطبيق

### إعداد خدمة الذكاء الاصطناعي (اختياري لكن موصى به) 🆕

1. انتقل إلى مجلد AI Service:
   ```bash
   cd backend/ai_service
   ```

2. تثبيت Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. تثبيت Tesseract OCR:
   - **Windows**: حمّل من https://github.com/UB-Mannheim/tesseract/wiki
   - **Linux**: `sudo apt-get install tesseract-ocr tesseract-ocr-ara`
   - **macOS**: `brew install tesseract tesseract-lang`

4. تشغيل AI Service:
   ```bash
   # Windows
   start_ai_service.bat
   
   # Linux/macOS
   ./start_ai_service.sh
   ```

   ستعمل خدمة AI على `http://localhost:5000`

   **ملاحظة**: إذا لم تشغّل AI Service، النظام سيعود تلقائياً لـ OCR العادي.

   للمزيد من التفاصيل، راجع `backend/ai_service/README.md` و `backend/ai_service/QUICKSTART.md`

### إعداد الواجهة الأمامية

1. انتقل إلى مجلد الواجهة الأمامية:
   ```bash
   cd frontend
   ```

2. تثبيت تبعيات Flutter:
   ```bash
   flutter pub get
   ```

3. تشغيل التطبيق:
   ```bash
   flutter run
   ```

## نقاط نهاية API

### المصادقة
- `POST /api/auth/register` - تسجيل المستخدم
- `POST /api/auth/login` - تسجيل دخول المستخدم
- `GET /api/auth/profile` - الحصول على ملف المستخدم
- `PUT /api/auth/profile` - تحديث ملف المستخدم
- `PUT /api/auth/change-password` - تغيير كلمة المرور

### الأدوية
- `GET /api/medicines` - الحصول على جميع الأدوية
- `GET /api/medicines/:id` - الحصول على دواء بالمعرف
- `POST /api/medicines` - إنشاء دواء (مدير)
- `PUT /api/medicines/:id` - تحديث دواء (مدير)
- `DELETE /api/medicines/:id` - حذف دواء (مدير)

### المسح
- `POST /api/scan/image` - مسح صورة الدواء
- `POST /api/scan/barcode` - مسح الباركود

### التذكيرات
- `GET /api/reminders` - الحصول على تذكيرات المستخدم
- `POST /api/reminders` - إنشاء تذكير
- `PUT /api/reminders/:id` - تحديث تذكير
- `DELETE /api/reminders/:id` - حذف تذكير
- `PATCH /api/reminders/:id/toggle` - تبديل التذكير

### التفاعلات
- `POST /api/interactions/check` - فحص تفاعلات الأدوية

### الإدارة
- `GET /api/admin/dashboard` - إحصائيات لوحة الإدارة
- `GET /api/admin/users` - الحصول على جميع المستخدمين
- `PUT /api/admin/users/:id/role` - تحديث دور المستخدم
- `DELETE /api/admin/users/:id` - حذف مستخدم

## الاختبار

### اختبارات الخادم الخلفي

تشغيل جميع اختبارات الخادم الخلفي:
```bash
cd backend
npm test
```

تشغيل الاختبارات مع التغطية:
```bash
npm run test:coverage
```

### اختبارات الواجهة الأمامية

تشغيل اختبارات Flutter:
```bash
cd frontend
flutter test
```

## التكوين

### قاعدة البيانات

يتم إنشاء قاعدة بيانات SQLite وتهيئتها تلقائياً بالبيانات العينة عند تشغيل سكريبت التهيئة.

## الاستخدام

### للمستخدمين

1. **التسجيل/تسجيل الدخول**: إنشاء حساب أو تسجيل الدخول للوصول إلى الميزات
2. **مسح الأدوية**: استخدام الكاميرا لمسح عبوات الأدوية
3. **عرض المعلومات**: الحصول على معلومات مفصلة عن الأدوية بما في ذلك الجرعة والتحذيرات والتفاعلات
4. **تعيين التذكيرات**: إنشاء تذكيرات للأدوية بجداول مخصصة
5. **فحص التفاعلات**: التحقق من تفاعلات الأدوية قبل تناول أدوية متعددة

### للمديرين

1. **لوحة التحكم**: عرض إحصائيات النظام والنشاط الأخير
2. **إدارة الأدوية**: إضافة أو تعديل أو حذف معلومات الأدوية
3. **إدارة المستخدمين**: عرض المستخدمين وتحديث الأدوار أو إزالة الحسابات
4. **قاعدة بيانات التفاعلات**: إدارة معلومات تفاعلات الأدوية

## الميزات بالتفصيل

### التعرف على الأدوية 🆕
- مسح عبوات الأدوية باستخدام الكاميرا
- **نظام AI متقدم**: OCR متعدد اللغات (عربي/إنجليزي) + نموذج تعلم عميق
- **نموذج CNN قابل للتدريب**: Transfer Learning مع MobileNetV2
- **دقة عالية**: دمج OCR + AI + بحث في قاعدة البيانات
- دعم مسح الباركود
- تسجيل الثقة لدقة التعرف
- **تدريب مخصص**: إمكانية تدريب النموذج على بياناتك الخاصة

### الواقع المعزز
- طبقة AR لعرض معلومات الأدوية
- تصور ثلاثي الأبعاد لتفاصيل الأدوية
- لوحات معلومات تفاعلية

### التحويل إلى كلام
- معدل الكلام والنبرة والحجم قابل للتكوين
- دعم متعدد اللغات
- ميزات إمكانية الوصول للمستخدمين ضعاف البصر

### تذكيرات الأدوية
- جداول تذكير قابلة للتخصيص
- خيارات تردد متعددة (مرة واحدة، يومياً، أسبوعياً، شهرياً)
- إشعارات محلية
- تاريخ وإحصائيات التذكيرات

### تفاعلات الأدوية
- فحص شامل للتفاعلات
- مستويات الخطورة (منخفض، متوسط، عالي، شديد)
- توصيات مفصلة
- قاعدة بيانات تفاعلات مديرها

## الأمان

- مصادقة قائمة على JWT
- تشفير كلمات المرور باستخدام bcrypt
- التحقق من المدخلات وتنظيفها
- منع حقن SQL
- تكوين CORS
- تحديد المعدل (موصى به للإنتاج)

## الأداء

- استعلامات قاعدة بيانات محسنة
- ضغط الصور للرفع
- إدارة حالة فعالة
- تحميل كسول للشاشات
- استراتيجيات التخزين المؤقت

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

1. **الكاميرا لا تعمل**: تأكد من منح أذونات الكاميرا
2. **أخطاء قاعدة البيانات**: تحقق من تهيئة SQLite بشكل صحيح
3. **أخطاء الشبكة**: تحقق من تشغيل خادم الخلفية
4. **أخطاء البناء**: تأكد من تثبيت جميع التبعيات

 
## شرح عملي مبسّط للمبتدئين (خطوة بخطوة)

تهدف هذه الفقرة لتسهيل فهم المشروع لطلاب الجامعات المبتدئين عبر أمثلة عملية بسيطة على أهم الأجزاء.

### 1) ما هي أول الخطوات؟
- **تشغيل الخادم الخلفي**: ندخل إلى مجلد `backend` ونثبت التبعيات ثم نشغّل `npm start` ليُصبح جاهزاً لاستقبال الطلبات.
- **تشغيل تطبيق Flutter**: ندخل إلى `frontend` ثم نشغّل `flutter run` لفتح التطبيق على الجوال أو المحاكي.
- **الفكرة الأساسية**: التطبيق عبارة عن واجهة Flutter تتواصل مع خادم Node.js عبر طلبات HTTP للحصول على بيانات الأدوية والمصادقة وغيرها.

لماذا بهذه الطريقة؟ لأنها تفصل الواجهة عن الخادم، فنستطيع تطوير كل جزء لوحده وتحديثه بسهولة.

### 2) الواجهة الرئيسية: كيف بُنيت وما فائدتها؟
- توجد شاشات Flutter داخل `frontend/lib/screens/`، وغالباً ستجد شاشة رئيسية مثل `home_screen.dart` تُظهر أهم أقسام التطبيق (مسح الأدوية، البحث، التذكيرات...).
- تُدار الحالة باستخدام `Provider` داخل `frontend/lib/providers/`، وهذا يساعدنا على مشاركة بيانات مثل المستخدم الحالي أو قائمة الأدوية بين الشاشات بسهولة وبدون تكرار.
- الأزرار في الواجهة تستدعي وظائف داخل `services` (مثل `api_service.dart`) لإرسال طلبات إلى الخادم وجلب النتائج.

الفائدة: تنظيم الملفّات بهذه الطريقة يجعل الكود مقروءاً وسهل الصيانة، ويتيح إضافة مزايا مستقبلاً بدون إرباك.

### 3) نظام التسجيل وتسجيل الدخول: كيف يعمل؟
- في الواجهة: شاشة مثل `login_screen.dart` و`register_screen.dart` تحتوي حقول إدخال البريد وكلمة المرور وأزرار إرسال.
- عند الضغط على زر "تسجيل الدخول" مثلاً، يتم استدعاء دالة في `frontend/lib/services/api/auth_service.dart` تُرسل طلب `POST` إلى مسار الخادم `/api/auth/login`.
- الخادم يتحقق من البيانات ويُعيد رمز JWT يدل على هوية المستخدم. نقوم بحفظ هذا الرمز (عادة عبر `SharedPreferences`) لكي نُرسلُه لاحقاً مع أي طلب يحتاج هوية المستخدم.

لماذا JWT؟ لأنه معيار بسيط وواسع الاستخدام لحفظ هوية الجلسة دون تخزين حالات كثيرة على الخادم.

### 4) الأقسام الأساسية للتطبيق وما فائدتها؟
- **المسح والتعرّف**: زر يفتح الكاميرا (باستخدام حزمة `camera`) ويلتقط صورة للدواء، ثم يرسلها إلى الخادم أو نموذج الذكاء الاصطناعي ليُعيد اسم الدواء ومعلوماته. يفيد المستخدم في التعرف السريع على الدواء.
- **البحث عن الأدوية**: حقل بحث يُرسل استعلاماً إلى الخادم لجلب قائمة بالأدوية المطابقة. يساعد على الوصول للمعلومات بدون مسح.
- **التذكيرات**: شاشة لإضافة تذكير بوقت الجرعة، تُنشئ إدخالاً على الخادم وتُفعّل إشعاراً محلياً عبر `flutter_local_notifications` لتنبيه المستخدم.
- **اللغة والثيم**: إعداد يغيّر اللغة (عربي/إنجليزي) والثيم (فاتح/داكن) لتحسين تجربة الاستخدام.

### 5) الأزرار والتفاعلات: كيف نبرمجها؟
- كل زر في Flutter يملك "حدث ضغط" يستدعي دالة. هذه الدالة إمّا تغيّر الحالة عبر `Provider`، أو تستدعي خدمة شبكة داخل `services`، ثم تُحدّث الواجهة بناءً على النتيجة.
- على سبيل المثال: زر "إضافة تذكير" يجمع المدخلات من المستخدم، يرسلها إلى `/api/reminders`، ويحفظ النتيجة محلياً لتحديث القائمة فوراً.

الفائدة: هذا الأسلوب يفصل واجهة المستخدم عن منطق العمل والشبكة، فيسهل اختبار كل جزء.

### 6) قواعد بسيطة للقراءة والفهم
- ابحث عن الشاشة داخل `screens`، والمزوّدات داخل `providers`، وخدمات الشبكة داخل `services`.
- إذا أردت إضافة زر جديد يقوم بطلب للشبكة: أنشئ دالة في `services`، استدعِها من الشاشة عبر `Provider`، ثم حدّث الحالة.
- راقب رسائل الخطأ القادمة من الخادم واعرض تنبيهاً ودياً للمستخدم عند الحاجة.

### أمثلة من الكود (مع شرح سريع)

#### تشغيل التطبيق، المزودات، والروترات
الكود التالي من `frontend/lib/main.dart` يوضّح كيف نفعّل الـ Providers ونعرّف المسارات:

```52:60:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/main.dart
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => ScanProvider()),
        ChangeNotifierProvider(create: (_) => TTSProvider()),
      ],
      child: Builder(
```

الفكرة: نُسجّل مزودات الحالة مرة واحدة ليتمكّن كل Widget من الوصول للبيانات بدون تمريـرها يدوياً.

```81:88:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/main.dart
            // Routes
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/scan': (context) => const ScanScreen(),
```

الفائدة: تعريف المسارات يجعل الانتقال بين الشاشات منظّماً وواضحاً.

#### خدمة الشبكة ApiService
من `frontend/lib/services/api_service.dart` نعرّف العنوان الأساسي وطلبات HTTP القياسية:

```6:9:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/services/api_service.dart
class ApiService {
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Use 10.0.2.2 for Android emulator
```

هذا يحدد نقطة الاتصال للخادم. أمثلة على الطلبات:

```24:37:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/services/api_service.dart
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(token: token),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }
```

المغزى: كل طلب يمر عبر دوال موحّدة لمعالجة الاستجابة والأخطاء.

#### المزوّد AuthProvider (تسجيل الدخول)
من `frontend/lib/providers/auth_provider.dart`، تسجيل الدخول يحفظ المستخدم والرمز محلياً:

```62:76:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/providers/auth_provider.dart
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        _token = response['token'];
        await _saveUserData();
        _setLoading(false);
        return true;
      } else {
        _setError(response['error'] ?? 'Login failed');
        _setLoading(false);
        return false;
      }
```

الفكرة: نستدعي الـ API، نتحقق من النجاح، ثم نحفظ الحالة في الجهاز حتى تبقى الجلسة نشطة.

#### شاشة تسجيل الدخول (زر الدخول)
من `frontend/lib/screens/auth/login_screen.dart`، هذا يستدعي `AuthProvider.login` ثم يتنقل للرئيسية:

```30:41:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/screens/auth/login_screen.dart
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
```

المغزى: نفصل واجهة الإدخال عن منطق الشبكة عبر المزوّد لسهولة الاختبار والصيانة.

#### الواجهة الرئيسية (شريط التنقل السفلي)
من `frontend/lib/screens/home/home_screen.dart`، يوضّح تبويب الأقسام الأساسية:

```82:101:c:/Users/TRSI/VSCode/Projects/flutterprojects/sehavision/frontend/lib/screens/home/home_screen.dart
  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
              _buildNavItem(1, Icons.camera_alt_rounded, 'مسح'),
              _buildNavItem(2, Icons.notifications_rounded, 'التذكيرات'),
              _buildNavItem(3, Icons.settings_rounded, 'الإعدادات'),
            ],
          ),
        ),
      ),
    );
  }
```

الفائدة: المستخدم يتنقل بسرعة بين الأقسام، والكود يبقى مقسوماً إلى Widgets صغيرة قابلة لإعادة الاستخدام.

 

## سجل التغييرات

### الإصدار 1.0.0
- الإصدار الأول
- التعرف على الأدوية بالذكاء الاصطناعي
- وظائف طبقة AR
- دعم التحويل إلى كلام
- نظام تذكير الأدوية
- مصادقة المستخدم
- لوحة الإدارة
- فحص تفاعل الأدوية
- دعم متعدد اللغات
- ثيم فاتح/داكن