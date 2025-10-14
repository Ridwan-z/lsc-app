import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final StorageService _storage = StorageService();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _storage.getSecure(AppConfig.keyToken);
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      var url = Uri.parse('${AppConfig.baseUrl}$endpoint');

      if (queryParams != null) {
        url = url.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .put(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to parse response: $e'};
    }
  }
}
