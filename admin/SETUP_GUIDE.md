# دليل تشغيل تطبيق SehaVision Admin Panel

## 📋 المتطلبات الأساسية

1. **Flutter SDK** (الإصدار 3.0.0 أو أحدث)
2. **Android Studio** مع Android SDK
3. **Android Emulator** أو جهاز Android حقيقي
4. **Node.js** (للـ Backend)
5. **Git** (اختياري)

---

## 🚀 خطوات التشغيل الكاملة

### 1️⃣ إعداد الـ Backend

#### أ. الانتقال إلى مجلد الـ Backend
```bash
cd VSCode/Projects/flutterprojects/sehavision/backend
```

#### ب. تثبيت المكتبات
```bash
npm install
```

#### ج. إنشاء المستخدم الإداري
```bash
npm run init-admin
```

أو إذا لم يعمل:
```bash
node scripts/init-admin.js
```

**البيانات الافتراضية:**
- البريد: `admin@sehavision.com`
- كلمة المرور: ``

#### د. تشغيل الـ Backend
```bash
npm start
```

**يجب أن ترى:**
```
SehaVision Backend running on port 3000
Health check: http://localhost:3000/api/health
Emulator access: http://10.0.2.2:3000/api
```

**⚠️ مهم:** اترك هذا Terminal مفتوحاً - الـ Backend يجب أن يعمل أثناء استخدام التطبيق!

---

### 2️⃣ إعداد Android Emulator

#### أ. فتح Android Studio
1. افتح **Android Studio**
2. من القائمة العلوية: **Tools** → **Device Manager**

#### ب. إنشاء Emulator جديد (إذا لم يكن موجوداً)
1. اضغط على **Create Device**
2. اختر **Phone** → **Pixel 5** (أو أي جهاز آخر)
3. اضغط **Next**
4. اختر **System Image**:
   - **API Level 33** (Android 13) أو أحدث
   - **Release Name: Tiramisu** أو أحدث
5. اضغط **Next** ثم **Finish**

#### ج. إعدادات Emulator المهمة

**1. إعدادات الشبكة:**
- الـ Emulator يستخدم `10.0.2.2` للوصول إلى `localhost` على جهازك
- تأكد من أن الـ Backend يعمل على `0.0.0.0` (تم إصلاحه في الكود)

**2. إعدادات الأداء:**
- **Graphics**: اختر **Hardware - GLES 2.0** (أسرع)
- **RAM**: 2048 MB على الأقل
- **VM heap**: 512 MB

**3. إعدادات الإضافات:**
- **Extended Controls** (الثلاث نقاط) → **Settings** → **Proxy**
  - تأكد من عدم وجود Proxy يعيق الاتصال

#### د. تشغيل Emulator
1. من **Device Manager**، اضغط على زر **▶️ Play** بجانب Emulator
2. انتظر حتى يفتح الـ Emulator بالكامل

**للتحقق من أن Emulator يعمل:**
```bash
flutter devices
```

يجب أن ترى:
```
Pixel 5 (mobile) • emulator-5554 • android-x64 • Android 13 (API 33)
```

---

### 3️⃣ إعداد تطبيق Flutter Admin

#### أ. الانتقال إلى مجلد Admin
```bash
cd VSCode/Projects/flutterprojects/sehavision/admin
```

#### ب. تثبيت المكتبات
```bash
flutter pub get
```

**إذا ظهرت أخطاء:**
```bash
flutter clean
flutter pub get
```

#### ج. التحقق من الاتصال
```bash
flutter doctor
```

**يجب أن ترى:**
- ✅ Flutter SDK
- ✅ Android toolchain
- ✅ Android Studio
- ✅ Connected device (Emulator)

---

### 4️⃣ تشغيل التطبيق

#### أ. التأكد من أن Emulator يعمل
- افتح **Android Studio** → **Device Manager**
- تأكد من أن Emulator يعمل (شاشة مفتوحة)

#### ب. تشغيل التطبيق
```bash
cd VSCode/Projects/flutterprojects/sehavision/admin
flutter run
```

**أو من VS Code:**
1. اضغط `F5` أو
2. **Run** → **Start Debugging**

#### ج. اختيار الجهاز
إذا كان لديك أكثر من جهاز:
```bash
flutter devices
flutter run -d emulator-5554
```

---

### 5️⃣ اختبار الاتصال

#### أ. تسجيل الدخول
- افتح التطبيق على الـ Emulator
- استخدم البيانات:
  - **البريد**: `admin@sehavision.com`
  - **كلمة المرور**: ``

#### ب. التحقق من الاتصال
إذا ظهرت رسالة خطأ:
- ✅ تأكد من أن الـ Backend يعمل على المنفذ 3000
- ✅ تأكد من أن الـ Emulator يعمل
- ✅ تحقق من عنوان IP: `http://10.0.2.2:3000/api`

---

## 🔧 حل المشاكل الشائعة

### ❌ مشكلة: "Connection refused" أو "Failed host lookup"

**الحل:**
1. تأكد من أن الـ Backend يعمل:
   ```bash
   cd backend
   npm start
   ```

2. تحقق من أن الـ Backend يستمع على `0.0.0.0`:
   - افتح `backend/server.js`
   - تأكد من: `app.listen(PORT, '0.0.0.0', ...)`

3. اختبر الاتصال من المتصفح:
   ```
   http://localhost:3000/api/health
   ```
   يجب أن ترى: `{"status":"OK",...}`

4. اختبر من الـ Emulator:
   - افتح **Browser** في الـ Emulator
   - اذهب إلى: `http://10.0.2.2:3000/api/health`

### ❌ مشكلة: "Invalid credentials"

**الحل:**
1. أنشئ المستخدم الإداري:
   ```bash
   cd backend
   npm run check-admin
   ```

2. أو أنشئه مباشرة:
   ```bash
   node scripts/check-admin.js
   ```

3. أو استخدم API:
   ```
   POST http://localhost:3000/api/auth/create-admin
   ```

### ❌ مشكلة: Emulator بطيء جداً

**الحل:**
1. **إعدادات Emulator:**
   - **Extended Controls** → **Settings** → **Advanced**
   - **Graphics**: **Hardware - GLES 2.0**
   - **RAM**: 4096 MB
   - **VM heap**: 1024 MB

2. **إعدادات Android Studio:**
   - **File** → **Settings** → **Appearance & Behavior** → **System Settings** → **Memory Settings**
   - زد **IDE max heap size** إلى 2048 MB

3. **إغلاق البرامج غير الضرورية**

### ❌ مشكلة: "No devices found"

**الحل:**
1. تأكد من أن Emulator يعمل:
   ```bash
   flutter devices
   ```

2. أعد تشغيل ADB:
   ```bash
   flutter doctor
   adb kill-server
   adb start-server
   ```

3. أعد تشغيل Android Studio

### ❌ مشكلة: الخطوط لا تظهر

**الحل:**
1. تأكد من أن الخطوط موجودة:
   ```bash
   ls admin/assets/fonts/
   ```
   يجب أن ترى ملفات `.ttf`

2. أعد بناء التطبيق:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### ❌ مشكلة: RTL لا يعمل

**الحل:**
1. تأكد من تثبيت `flutter_localizations`:
   ```bash
   flutter pub get
   ```

2. تحقق من `main.dart`:
   - يجب أن يكون `Directionality(textDirection: TextDirection.rtl)`
   - يجب أن يكون `locale: Locale('ar', 'SA')`

---

## 📱 إعدادات Emulator الموصى بها

### إعدادات الأداء:
- **Graphics**: Hardware - GLES 2.0
- **RAM**: 4096 MB
- **VM heap**: 1024 MB
- **Internal Storage**: 2048 MB
- **SD Card**: 512 MB

### إعدادات الشبكة:
- **Cellular**: Automatic
- **Wi-Fi**: Automatic
- **Proxy**: None (ما لم تكن تحتاج Proxy)

### إعدادات النظام:
- **Android Version**: 13 (API 33) أو أحدث
- **Screen Size**: 1080 x 2340 (Pixel 5)
- **Density**: 420 dpi

---

## 🎯 خطوات سريعة للتشغيل

### في Terminal الأول (Backend):
```bash
cd VSCode/Projects/flutterprojects/sehavision/backend
npm install
npm run init-admin
npm start
```

### في Terminal الثاني (Flutter):
```bash
cd VSCode/Projects/flutterprojects/sehavision/admin
flutter pub get
flutter run
```

### في Android Studio:
1. **Tools** → **Device Manager**
2. اضغط **▶️ Play** على Emulator
3. انتظر حتى يفتح

---

## ✅ Checklist قبل التشغيل

- [ ] Node.js مثبت ويعمل
- [ ] Backend يعمل على المنفذ 3000
- [ ] المستخدم الإداري موجود في قاعدة البيانات
- [ ] Android Emulator يعمل
- [ ] Flutter SDK مثبت
- [ ] `flutter pub get` تم تنفيذه
- [ ] `flutter devices` يظهر Emulator
- [ ] الاتصال بالإنترنت متاح

---

## 🔗 روابط مفيدة

- **Backend Health Check**: http://localhost:3000/api/health
- **Backend API Docs**: http://localhost:3000/
- **Emulator Network**: http://10.0.2.2:3000/api/health

---

## 📞 بيانات الدخول الافتراضية

**المستخدم الإداري:**
- البريد: `admin@sehavision.com`
- كلمة المرور: ``

**المستخدم التجريبي:**
- البريد: `user1@example.com`
- كلمة المرور: ``

---

## 🎨 المميزات المطبقة

✅ **Dark Mode** - ثيم داكن كامل  
✅ **RTL Support** - دعم كامل للعربية  
✅ **IBM Plex Sans Arabic** - خط عربي احترافي  
✅ **Responsive Design** - تصميم متجاوب  
✅ **Modern UI** - واجهة حديثة وأنيقة  

---
