import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _getHeaders(token: token))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final url = '$baseUrl$endpoint';
      print('🌐 API Request: POST $url');
      print('📦 Request body: ${json.encode(data)}');
      
      final response = await http
          .post(
            Uri.parse(url),
            headers: _getHeaders(token: token),
            body: json.encode(data),
          )
          .timeout(timeout);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ API Error: $e');
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(token: token),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      // Handle empty response body
      if (response.body.isEmpty) {
        return {
          'success': false,
          'error': 'Empty response from server',
          'statusCode': response.statusCode,
        };
      }

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Spread the data so we can access fields directly (token, user, etc.)
        return {'success': true, ...data};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Invalid response format: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }

  static Map<String, dynamic> _handleError(dynamic error) {
    String errorMessage = 'Network error: ${error.toString()}';
    String errorStr = error.toString().toLowerCase();
    
    // Provide more helpful error messages
    if (errorStr.contains('failed host lookup') || 
        errorStr.contains('connection refused') ||
        errorStr.contains('socketexception') ||
        errorStr.contains('network is unreachable')) {
      errorMessage = 'لا يمكن الاتصال بالخادم.\n'
          'تأكد من:\n'
          '1. تشغيل الـ Backend: cd backend && npm start\n'
          '2. أن الـ Backend يعمل على المنفذ 3000\n'
          '3. أن عنوان IP صحيح: http://10.0.2.2:3000/api';
    } else if (errorStr.contains('timeout')) {
      errorMessage = 'انتهت مهلة الاتصال. تحقق من اتصال الشبكة';
    } else if (errorStr.contains('os error')) {
      errorMessage = 'خطأ في الاتصال بالشبكة. تحقق من اتصال الإنترنت';
    }
    
    return {'success': false, 'error': errorMessage};
  }
}

