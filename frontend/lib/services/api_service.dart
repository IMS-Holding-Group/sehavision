import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

class ApiService {
  // Auto-detect base URL based on platform
  // For Android emulator: 10.0.2.2
  // For iOS simulator: localhost
  // For real device: Use your computer's local IP (e.g., 192.168.1.XXX)
  // Change this to your computer's IP address when testing on real device
  static String get baseUrl {
    if (kDebugMode) {
      // In debug mode, try to auto-detect
      // For emulator/simulator
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      } else if (Platform.isIOS) {
        return 'http://localhost:3000/api';
      }
    }
    // For production or real device, use environment variable or default
    // TODO: Replace with your actual server IP or domain
    // Example: 'http://192.168.1.100:3000/api' (your computer's local IP)
    // Or use: const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000/api')
    return const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000/api',
    );
  }

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

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(token: token),
            body: json.encode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(token: token),
            body: json.encode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
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

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(token: token),
            body: json.encode(data),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, String> fields,
    Map<String, File> files, {
    String? token,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add headers
      request.headers.addAll(_getHeaders(token: token));
      request.headers.remove('Content-Type'); // Let multipart set this

      // Add fields
      request.fields.addAll(fields);

      // Add files
      for (final entry in files.entries) {
        final file = entry.value;
        final fieldName = entry.key;
        final fileName = path.basename(file.path);

        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            filename: fileName,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      if (kDebugMode) {
        print('📥 API Response Status: ${response.statusCode}');
        print('📥 API Response Body: ${response.body}');
      }
      
      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = {'success': true, 'data': data, ...data};
        if (kDebugMode) {
          print('📥 Processed Response: $result');
        }
        return result;
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Request failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing response: $e');
        print('❌ Response body: ${response.body}');
      }
      return {
        'success': false,
        'error': 'Invalid response format: ${e.toString()}',
        'statusCode': response.statusCode,
      };
    }
  }

  static Map<String, dynamic> _handleError(dynamic error) {
    if (error is SocketException) {
      return {'success': false, 'error': 'No internet connection'};
    } else if (error is HttpException) {
      return {'success': false, 'error': 'HTTP error occurred'};
    } else if (error is FormatException) {
      return {'success': false, 'error': 'Invalid response format'};
    } else {
      return {'success': false, 'error': 'Network error: ${error.toString()}'};
    }
  }

  // Helper method to check if response is successful
  static bool isSuccess(Map<String, dynamic> response) {
    return response['success'] == true;
  }

  // Helper method to get error message
  static String getErrorMessage(Map<String, dynamic> response) {
    return response['error'] ?? 'Unknown error occurred';
  }

  // Helper method to get data
  static dynamic getData(Map<String, dynamic> response) {
    return response['data'] ?? response;
  }
}
