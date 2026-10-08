import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';

  Locale _locale = const Locale('ar', 'SA');

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'ar';
      final newLocale = Locale(languageCode, languageCode == 'ar' ? 'SA' : 'US');
      if (_locale != newLocale) {
        _locale = newLocale;
        notifyListeners();
      }
    } catch (e) {
      // Use Arabic as default
      _locale = const Locale('ar', 'SA');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    if (_locale == locale) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }

    _locale = locale;
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    if (isEnglish) {
      await setLanguage(const Locale('ar', 'SA'));
    } else {
      await setLanguage(const Locale('en', 'US'));
    }
  }

  String getLanguageName() {
    switch (_locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  TextDirection get textDirection {
    return isArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}
