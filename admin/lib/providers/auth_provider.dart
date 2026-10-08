import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_token');
    if (_token != null) {
      await _loadUser();
    }
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token);
    _token = token;
  }

  Future<void> _loadUser() async {
    final response = await ApiService.get('/auth/profile', token: _token);
    if (response['success'] == true) {
      _user = User.fromJson(response['user']);
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response['success'] == true) {
        final userData = response['user'];
        final token = response['token'];
        
        if (userData == null) {
          _error = 'لم يتم استلام بيانات المستخدم';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        if (token == null) {
          _error = 'لم يتم استلام رمز المصادقة';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        _user = User.fromJson(userData);
        
        if (_user?.role != 'admin') {
          _error = 'ليس لديك صلاحيات إدارية';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        await _saveToken(token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'فشل تسجيل الدخول';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء الاتصال';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    _token = null;
    _user = null;
    notifyListeners();
  }
}

