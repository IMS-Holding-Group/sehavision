import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/medicine.dart';
import '../models/activity_log.dart';
import '../services/api_service.dart';

class AdminProvider with ChangeNotifier {
  List<User> _users = [];
  List<Medicine> _medicines = [];
  List<ActivityLog> _logs = [];
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<Medicine> get medicines => _medicines;
  List<ActivityLog> get logs => _logs;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get('/admin/dashboard', token: token);
      if (response['success'] == true) {
        _dashboardStats = response['data'];
      } else {
        _error = response['error'] ?? 'فشل تحميل البيانات';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء الاتصال';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers(String token, {int page = 1, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': '20',
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await ApiService.get(
        '/admin/users',
        token: token,
        queryParams: queryParams,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _users = (data['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
      } else {
        _error = response['error'] ?? 'فشل تحميل المستخدمين';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء الاتصال';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedicines(String token,
      {int page = 1, String? search, String? filter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': '20',
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (filter != null && filter.isNotEmpty) {
        queryParams['filter'] = filter;
      }

      final response = await ApiService.get(
        '/admin/medicines',
        token: token,
        queryParams: queryParams,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _medicines = (data['medicines'] as List)
            .map((json) => Medicine.fromJson(json))
            .toList();
      } else {
        _error = response['error'] ?? 'فشل تحميل الأدوية';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء الاتصال';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLogs(String token,
      {int page = 1, int? userId, String? action, String? entityType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': '50',
      };
      if (userId != null) {
        queryParams['user_id'] = userId.toString();
      }
      if (action != null && action.isNotEmpty) {
        queryParams['action'] = action;
      }
      if (entityType != null && entityType.isNotEmpty) {
        queryParams['entity_type'] = entityType;
      }

      final response = await ApiService.get(
        '/admin/logs',
        token: token,
        queryParams: queryParams,
      );

      if (response['success'] == true) {
        final data = response['data'];
        _logs = (data['logs'] as List)
            .map((json) => ActivityLog.fromJson(json))
            .toList();
      } else {
        _error = response['error'] ?? 'فشل تحميل السجلات';
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء الاتصال';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedicine(String token, int medicineId) async {
    try {
      final response =
          await ApiService.delete('/admin/medicines/$medicineId', token: token);
      if (response['success'] == true) {
        _medicines.removeWhere((m) => m.id == medicineId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

