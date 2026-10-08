import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final appLoc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (appLoc != null) return appLoc;
    // Fallback to Arabic if not found
    return AppLocalizations(const Locale('ar', 'SA'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('ar', 'SA'),
  ];

  // Common
  String get appName => _localizedValues[locale.languageCode]!['appName']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get add => _localizedValues[locale.languageCode]!['add']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get warning => _localizedValues[locale.languageCode]!['warning']!;

  // Authentication
  String get login => _localizedValues[locale.languageCode]!['login']!;
  String get register => _localizedValues[locale.languageCode]!['register']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get email => _localizedValues[locale.languageCode]!['email']!;
  String get password => _localizedValues[locale.languageCode]!['password']!;
  String get confirmPassword =>
      _localizedValues[locale.languageCode]!['confirmPassword']!;
  String get name => _localizedValues[locale.languageCode]!['name']!;
  String get phone => _localizedValues[locale.languageCode]!['phone']!;
  String get rememberMe => _localizedValues[locale.languageCode]!['rememberMe']!;
  String get forgotPassword =>
      _localizedValues[locale.languageCode]!['forgotPassword']!;
  String get dontHaveAccount =>
      _localizedValues[locale.languageCode]!['dontHaveAccount']!;
  String get alreadyHaveAccount =>
      _localizedValues[locale.languageCode]!['alreadyHaveAccount']!;

  // Navigation
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get scan => _localizedValues[locale.languageCode]!['scan']!;
  String get reminders => _localizedValues[locale.languageCode]!['reminders']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;

  // Medicine
  String get medicine => _localizedValues[locale.languageCode]!['medicine']!;
  String get medicines => _localizedValues[locale.languageCode]!['medicines']!;
  String get medicineName =>
      _localizedValues[locale.languageCode]!['medicineName']!;
  String get brand => _localizedValues[locale.languageCode]!['brand']!;
  String get dosage => _localizedValues[locale.languageCode]!['dosage']!;
  String get instructions =>
      _localizedValues[locale.languageCode]!['instructions']!;
  String get warnings => _localizedValues[locale.languageCode]!['warnings']!;
  String get interactions =>
      _localizedValues[locale.languageCode]!['interactions']!;
  String get expiryDate =>
      _localizedValues[locale.languageCode]!['expiryDate']!;
  String get barcode => _localizedValues[locale.languageCode]!['barcode']!;

  // Scan
  String get scanMedicine =>
      _localizedValues[locale.languageCode]!['scanMedicine']!;
  String get scanBarcode =>
      _localizedValues[locale.languageCode]!['scanBarcode']!;
  String get scanImage => _localizedValues[locale.languageCode]!['scanImage']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['takePhoto']!;
  String get selectFromGallery =>
      _localizedValues[locale.languageCode]!['selectFromGallery']!;
  String get processing =>
      _localizedValues[locale.languageCode]!['processing']!;
  String get medicineRecognized =>
      _localizedValues[locale.languageCode]!['medicineRecognized']!;
  String get medicineNotRecognized =>
      _localizedValues[locale.languageCode]!['medicineNotRecognized']!;

  // Reminders
  String get reminder => _localizedValues[locale.languageCode]!['reminder']!;
  String get addReminder =>
      _localizedValues[locale.languageCode]!['addReminder']!;
  String get reminderTitle =>
      _localizedValues[locale.languageCode]!['reminderTitle']!;
  String get reminderDescription =>
      _localizedValues[locale.languageCode]!['reminderDescription']!;
  String get scheduledTime =>
      _localizedValues[locale.languageCode]!['scheduledTime']!;
  String get frequency => _localizedValues[locale.languageCode]!['frequency']!;
  String get once => _localizedValues[locale.languageCode]!['once']!;
  String get daily => _localizedValues[locale.languageCode]!['daily']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;

  // Settings
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get lightTheme =>
      _localizedValues[locale.languageCode]!['lightTheme']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme']!;
  String get systemTheme =>
      _localizedValues[locale.languageCode]!['systemTheme']!;
  String get textToSpeech =>
      _localizedValues[locale.languageCode]!['textToSpeech']!;
  String get enableTTS => _localizedValues[locale.languageCode]!['enableTTS']!;
  String get notifications =>
      _localizedValues[locale.languageCode]!['notifications']!;
  String get enableNotifications =>
      _localizedValues[locale.languageCode]!['enableNotifications']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;

  // AR
  String get arMode => _localizedValues[locale.languageCode]!['arMode']!;
  String get arOverlay => _localizedValues[locale.languageCode]!['arOverlay']!;
  String get pointCamera =>
      _localizedValues[locale.languageCode]!['pointCamera']!;

  // Accessibility
  String get readAloud => _localizedValues[locale.languageCode]!['readAloud']!;
  String get stopReading =>
      _localizedValues[locale.languageCode]!['stopReading']!;
  String get accessibility =>
      _localizedValues[locale.languageCode]!['accessibility']!;
  String get largeText => _localizedValues[locale.languageCode]!['largeText']!;
  String get highContrast =>
      _localizedValues[locale.languageCode]!['highContrast']!;
  
  // Additional
  String get loginToAccount => _localizedValues[locale.languageCode]!['loginToAccount']!;
  String get optional => _localizedValues[locale.languageCode]!['optional']!;
  String get agreeToTerms => _localizedValues[locale.languageCode]!['agreeToTerms']!;
  String get createNewAccount => _localizedValues[locale.languageCode]!['createNewAccount']!;
  String get joinSehaVision => _localizedValues[locale.languageCode]!['joinSehaVision']!;
  String get goodMorning => _localizedValues[locale.languageCode]!['goodMorning']!;
  String get goodAfternoon => _localizedValues[locale.languageCode]!['goodAfternoon']!;
  String get goodEvening => _localizedValues[locale.languageCode]!['goodEvening']!;
  String get healthStats => _localizedValues[locale.languageCode]!['healthStats']!;
  String get recentMedicines => _localizedValues[locale.languageCode]!['recentMedicines']!;
  String get upcomingReminders => _localizedValues[locale.languageCode]!['upcomingReminders']!;
  String get registeredMedicines => _localizedValues[locale.languageCode]!['registeredMedicines']!;
  String get activeReminders => _localizedValues[locale.languageCode]!['activeReminders']!;
  String get viewAll => _localizedValues[locale.languageCode]!['viewAll']!;
  String get noMedicinesRegistered => _localizedValues[locale.languageCode]!['noMedicinesRegistered']!;
  String get startScanningMedicine => _localizedValues[locale.languageCode]!['startScanningMedicine']!;
  String get noReminders => _localizedValues[locale.languageCode]!['noReminders']!;
  String get addNewReminder => _localizedValues[locale.languageCode]!['addNewReminder']!;
  String get appearance => _localizedValues[locale.languageCode]!['appearance']!;
  String get account => _localizedValues[locale.languageCode]!['account']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get alwaysEnabled => _localizedValues[locale.languageCode]!['alwaysEnabled']!;
  String get arabic => _localizedValues[locale.languageCode]!['arabic']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get changePassword => _localizedValues[locale.languageCode]!['changePassword']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacyPolicy']!;
  String get termsOfService => _localizedValues[locale.languageCode]!['termsOfService']!;
  String get editProfile => _localizedValues[locale.languageCode]!['editProfile']!;
  String get profileUpdated => _localizedValues[locale.languageCode]!['profileUpdated']!;
  String get passwordChanged => _localizedValues[locale.languageCode]!['passwordChanged']!;
  String get logoutConfirm => _localizedValues[locale.languageCode]!['logoutConfirm']!;
  String get searchMedicine => _localizedValues[locale.languageCode]!['searchMedicine']!;
  String get agreeToTermsRequired => _localizedValues[locale.languageCode]!['agreeToTermsRequired']!;
  String get enableVoiceAnnouncements => _localizedValues[locale.languageCode]!['enableVoiceAnnouncements']!;
  String get speechRate => _localizedValues[locale.languageCode]!['speechRate']!;
  String get voicePitch => _localizedValues[locale.languageCode]!['voicePitch']!;
  String get volumeLevel => _localizedValues[locale.languageCode]!['volumeLevel']!;
  String get supportAndHelp => _localizedValues[locale.languageCode]!['supportAndHelp']!;
  String get currentPassword => _localizedValues[locale.languageCode]!['currentPassword']!;
  String get newPassword => _localizedValues[locale.languageCode]!['newPassword']!;
  String get user => _localizedValues[locale.languageCode]!['user']!;
  String get privacyPolicyContent => _localizedValues[locale.languageCode]!['privacyPolicyContent']!;
  String get termsOfServiceContent => _localizedValues[locale.languageCode]!['termsOfServiceContent']!;
  String get helpAndSupportContent => _localizedValues[locale.languageCode]!['helpAndSupportContent']!;
  String get quickActions => _localizedValues[locale.languageCode]!['quickActions']!;
  String get useCameraToRecognize => _localizedValues[locale.languageCode]!['useCameraToRecognize']!;
  String get reminderForMedicines => _localizedValues[locale.languageCode]!['reminderForMedicines']!;
  String get welcomeToSehaVision => _localizedValues[locale.languageCode]!['welcomeToSehaVision']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get appVersion => _localizedValues[locale.languageCode]!['appVersion']!;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'SehaVision',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'search': 'Search',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'name': 'Name',
      'phone': 'Phone',
      'rememberMe': 'Remember me',
      'forgotPassword': 'Forgot Password?',
      'dontHaveAccount': "Don't have an account?",
      'alreadyHaveAccount': 'Already have an account?',
      'home': 'Home',
      'scan': 'Scan',
      'reminders': 'Reminders',
      'settings': 'Settings',
      'medicine': 'Medicine',
      'medicines': 'Medicines',
      'medicineName': 'Medicine Name',
      'brand': 'Brand',
      'dosage': 'Dosage',
      'instructions': 'Instructions',
      'warnings': 'Warnings',
      'interactions': 'Interactions',
      'expiryDate': 'Expiry Date',
      'barcode': 'Barcode',
      'scanMedicine': 'Scan Medicine',
      'scanBarcode': 'Scan Barcode',
      'scanImage': 'Scan Image',
      'takePhoto': 'Take Photo',
      'selectFromGallery': 'Select from Gallery',
      'processing': 'Processing...',
      'medicineRecognized': 'Medicine Recognized',
      'medicineNotRecognized': 'Medicine Not Recognized',
      'reminder': 'Reminder',
      'addReminder': 'Add Reminder',
      'reminderTitle': 'Reminder Title',
      'reminderDescription': 'Description',
      'scheduledTime': 'Scheduled Time',
      'frequency': 'Frequency',
      'once': 'Once',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'language': 'Language',
      'theme': 'Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'textToSpeech': 'Text to Speech',
      'enableTTS': 'Enable TTS',
      'notifications': 'Notifications',
      'enableNotifications': 'Enable Notifications',
      'about': 'About',
      'version': 'Version',
      'arMode': 'AR Mode',
      'arOverlay': 'AR Overlay',
      'pointCamera': 'Point camera at medicine',
      'readAloud': 'Read Aloud',
      'stopReading': 'Stop Reading',
      'accessibility': 'Accessibility',
      'largeText': 'Large Text',
      'highContrast': 'High Contrast',
      'loginToAccount': 'Login to your account',
      'optional': 'Optional',
      'agreeToTerms': 'I agree to the Terms and Privacy Policy',
      'createNewAccount': 'Create New Account',
      'joinSehaVision': 'Join SehaVision to start recognizing medicines',
      'goodMorning': 'Good Morning',
      'goodAfternoon': 'Good Afternoon',
      'goodEvening': 'Good Evening',
      'healthStats': 'Your Health Stats',
      'recentMedicines': 'Recent Medicines',
      'upcomingReminders': 'Upcoming Reminders',
      'registeredMedicines': 'Registered Medicines',
      'activeReminders': 'Active Reminders',
      'viewAll': 'View All',
      'noMedicinesRegistered': 'No medicines registered',
      'startScanningMedicine': 'Start scanning a new medicine',
      'noReminders': 'No reminders',
      'addNewReminder': 'Add a new reminder',
      'appearance': 'Appearance',
      'account': 'Account',
      'darkMode': 'Dark Mode',
      'alwaysEnabled': 'Always Enabled',
      'arabic': 'Arabic',
      'english': 'English',
      'profile': 'Profile',
      'changePassword': 'Change Password',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'editProfile': 'Edit Profile',
      'profileUpdated': 'Profile updated successfully',
      'passwordChanged': 'Password changed successfully',
      'logoutConfirm': 'Are you sure you want to logout?',
      'searchMedicine': 'Search for medicine',
      'agreeToTermsRequired': 'Please agree to the Terms and Conditions',
      'enableVoiceAnnouncements': 'Enable voice announcements',
      'speechRate': 'Speech Rate',
      'voicePitch': 'Voice Pitch',
      'volumeLevel': 'Volume Level',
      'supportAndHelp': 'Support & Help',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'user': 'User',
      'privacyPolicyContent': 'Privacy Policy\n\nThis application collects and processes personal data in accordance with applicable privacy laws.\n\nData Collection:\n• User account information (name, email, phone)\n• Medicine scan data\n• Reminder preferences\n\nData Usage:\n• Provide and improve services\n• Send notifications\n• Analyze app usage\n\nFor support, contact us at support@sehavision.com',
      'termsOfServiceContent': 'Terms of Service\n\nBy using SehaVision, you agree to the following terms:\n\n1. Use the app for informational purposes only\n2. Always consult healthcare professionals for medical advice\n3. The app does not replace professional medical consultation\n\nLimitations:\n• The app is provided "as is" without warranties\n• We are not responsible for medical decisions based on app information\n• Service availability is not guaranteed\n\nFor questions about these terms, contact us at legal@sehavision.com',
      'helpAndSupportContent': 'SehaVision is a medicine recognition app that helps you identify medicines using AI and AR technology.\n\nFeatures:\n• Scan medicine packages with your phone camera\n• Get detailed information about medicines\n• Set medicine reminders\n• Check drug interactions\n• Text-to-speech for accessibility\n\nFor support, please contact us at support@sehavision.com',
      'quickActions': 'Quick Actions',
      'useCameraToRecognize': 'Use camera to recognize medicine',
      'reminderForMedicines': 'Reminder for medicine times',
      'welcomeToSehaVision': 'Welcome to SehaVision',
      'close': 'Close',
      'appVersion': 'App Version',
    },
    'ar': {
      'appName': 'SehaVision',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'add': 'إضافة',
      'search': 'بحث',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'warning': 'تحذير',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'logout': 'تسجيل الخروج',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirmPassword': 'تأكيد كلمة المرور',
      'name': 'الاسم',
      'phone': 'الهاتف',
      'rememberMe': 'تذكرني',
      'forgotPassword': 'نسيت كلمة المرور؟',
      'dontHaveAccount': 'ليس لديك حساب؟',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟',
      'home': 'الرئيسية',
      'scan': 'مسح',
      'reminders': 'التذكيرات',
      'settings': 'الإعدادات',
      'medicine': 'الدواء',
      'medicines': 'الأدوية',
      'medicineName': 'اسم الدواء',
      'brand': 'العلامة التجارية',
      'dosage': 'الجرعة',
      'instructions': 'التعليمات',
      'warnings': 'التحذيرات',
      'interactions': 'التفاعلات',
      'expiryDate': 'تاريخ الانتهاء',
      'barcode': 'الباركود',
      'scanMedicine': 'مسح الدواء',
      'scanBarcode': 'مسح الباركود',
      'scanImage': 'مسح الصورة',
      'takePhoto': 'التقاط صورة',
      'selectFromGallery': 'اختيار من المعرض',
      'processing': 'جاري المعالجة...',
      'medicineRecognized': 'تم التعرف على الدواء',
      'medicineNotRecognized': 'لم يتم التعرف على الدواء',
      'reminder': 'تذكير',
      'addReminder': 'إضافة تذكير',
      'reminderTitle': 'عنوان التذكير',
      'reminderDescription': 'الوصف',
      'scheduledTime': 'الوقت المحدد',
      'frequency': 'التكرار',
      'once': 'مرة واحدة',
      'daily': 'يومياً',
      'weekly': 'أسبوعياً',
      'monthly': 'شهرياً',
      'language': 'اللغة',
      'theme': 'المظهر',
      'lightTheme': 'فاتح',
      'darkTheme': 'داكن',
      'systemTheme': 'النظام',
      'textToSpeech': 'تحويل النص إلى كلام',
      'enableTTS': 'تفعيل تحويل النص إلى كلام',
      'notifications': 'الإشعارات',
      'enableNotifications': 'تفعيل الإشعارات',
      'about': 'حول التطبيق',
      'version': 'الإصدار',
      'arMode': 'الواقع المعزز',
      'arOverlay': 'طبقة الواقع المعزز',
      'pointCamera': 'وجه الكاميرا نحو الدواء',
      'readAloud': 'قراءة بصوت عالي',
      'stopReading': 'إيقاف القراءة',
      'accessibility': 'إمكانية الوصول',
      'largeText': 'نص كبير',
      'highContrast': 'تباين عالي',
      'loginToAccount': 'سجل الدخول إلى حسابك',
      'optional': 'اختياري',
      'agreeToTerms': 'أوافق على الشروط والأحكام وسياسة الخصوصية',
      'createNewAccount': 'إنشاء حساب جديد',
      'joinSehaVision': 'انضم إلى SehaVision لبدء التعرف على الأدوية',
      'goodMorning': 'صباح الخير',
      'goodAfternoon': 'مساء الخير',
      'goodEvening': 'مساء الخير',
      'healthStats': 'إحصائيات صحتك',
      'recentMedicines': 'الأدوية الأخيرة',
      'upcomingReminders': 'التذكيرات القادمة',
      'registeredMedicines': 'الأدوية المسجلة',
      'activeReminders': 'التذكيرات النشطة',
      'viewAll': 'عرض الكل',
      'noMedicinesRegistered': 'لا توجد أدوية مسجلة',
      'startScanningMedicine': 'ابدأ بمسح دواء جديد',
      'noReminders': 'لا توجد تذكيرات',
      'addNewReminder': 'أضف تذكير جديد',
      'appearance': 'المظهر',
      'account': 'الحساب',
      'darkMode': 'المظهر الداكن',
      'alwaysEnabled': 'مفعل دائماً',
      'arabic': 'العربية',
      'english': 'English',
      'profile': 'الملف الشخصي',
      'changePassword': 'تغيير كلمة المرور',
      'privacyPolicy': 'سياسة الخصوصية',
      'termsOfService': 'شروط الخدمة',
      'editProfile': 'تعديل الملف الشخصي',
      'profileUpdated': 'تم تحديث الملف الشخصي بنجاح',
      'passwordChanged': 'تم تغيير كلمة المرور بنجاح',
      'logoutConfirm': 'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
      'searchMedicine': 'البحث عن دواء',
      'agreeToTermsRequired': 'يرجى الموافقة على الشروط والأحكام',
      'enableVoiceAnnouncements': 'تفعيل الإعلانات الصوتية',
      'speechRate': 'سرعة الكلام',
      'voicePitch': 'نبرة الصوت',
      'volumeLevel': 'مستوى الصوت',
      'supportAndHelp': 'الدعم والمساعدة',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'user': 'المستخدم',
      'privacyPolicyContent': 'سياسة الخصوصية\n\nيجمع هذا التطبيق ويعالج البيانات الشخصية وفقاً لقوانين الخصوصية المعمول بها.\n\nجمع البيانات:\n• معلومات حساب المستخدم (الاسم، البريد الإلكتروني، الهاتف)\n• بيانات مسح الأدوية\n• تفضيلات التذكير\n\nاستخدام البيانات:\n• توفير وتحسين الخدمات\n• إرسال الإشعارات\n• تحليل استخدام التطبيق\n\nللحصول على الدعم، يرجى التواصل معنا على support@sehavision.com',
      'termsOfServiceContent': 'شروط الخدمة\n\nباستخدام SehaVision، فإنك توافق على الشروط التالية:\n\n1. استخدام التطبيق لأغراض إعلامية فقط\n2. استشر دائماً المتخصصين في الرعاية الصحية للحصول علمشورة الطبية\n3. التطبيق لا يحل محل الاستشارة الطبية المهنية\n\nالقيود:\n• التطبيق مقدم "كما هو" بدون ضمانات\n• لسنا مسؤولين عن أي قرارات طبية تتخذ بناءً على معلومات التطبيق\n• توفر الخدمة غير مضمون\n\nللأسئلة حول هذه الشروط، يرجى التواصل معنا على legal@sehavision.com',
      'helpAndSupportContent': 'SehaVision هو تطبيق للتعرف على الأدوية يساعدك في تحديد الأدوية باستخدام تقنية الذكاء الاصطناعي والواقع المعزز.\n\nالمميزات:\n• مسح عبوات الأدوية بكاميرا الهاتف\n• الحصول على معلومات مفصلة عن الدواء\n• تعيين تذكيرات للأدوية\n• فحص التفاعلات الدوائية\n• تحويل النص إلى كلام لإمكانية الوصول\n\nللحصول على الدعم، يرجى التواصل معنا على support@sehavision.com',
      'quickActions': 'الإجراءات السريعة',
      'useCameraToRecognize': 'استخدم الكاميرا للتعرف على الدواء',
      'reminderForMedicines': 'تذكير لمواعيد الأدوية',
      'welcomeToSehaVision': 'مرحبا بك في SehaVision',
      'close': 'إغلاق',
      'appVersion': 'إصدار التطبيق',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}

