import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => message;
}

/// HTTP API client managing Bearer JWT and X-Tenant-ID headers for VicobaPlus
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  String? _activeGroupId;
  String? _customBaseUrl;

  VoidCallback? onUnauthorized;

  String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    if (kIsWeb || Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return ApiConstants.localhostBaseUrl;
    }
    return ApiConstants.defaultBaseUrl;
  }

  void setCustomBaseUrl(String? url) {
    _customBaseUrl = url;
  }

  void setAuth(String? token, String? activeGroupId) {
    _token = token;
    _activeGroupId = activeGroupId;
  }

  Future<void> initFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('vicoba_token');
    _activeGroupId = prefs.getString('vicoba_active_context_id');
    _customBaseUrl = prefs.getString('vicoba_custom_base_url');
  }

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (_activeGroupId != null && _activeGroupId!.isNotEmpty) {
      headers['X-Tenant-ID'] = _activeGroupId!;
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await http.get(uri, headers: _buildHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Unable to connect to server. Check your network or server URL.',
      );
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Unable to connect to server. Check your network or server URL.',
      );
    }
  }

  Future<dynamic> put(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await http.put(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Unable to connect to server. Check your network or server URL.',
      );
    }
  }

  Future<dynamic> patch(String endpoint, {dynamic body, Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await http.patch(
        uri,
        headers: _buildHeaders(),
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Unable to connect to server. Check your network or server URL.',
      );
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(endpoint, queryParams);
    try {
      final response = await http.delete(uri, headers: _buildHeaders());
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'Unable to connect to server. Check your network or server URL.',
      );
    }
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final fullUrl = '$baseUrl$endpoint';
    final parsed = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      final cleanParams = queryParams.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      return parsed.replace(queryParameters: cleanParams);
    }
    return parsed;
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    if (statusCode == 401) {
      onUnauthorized?.call();
      throw ApiException(
        statusCode: 401,
        message: 'Session expired or invalid credentials. Please log in again.',
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } catch (e) {
        return response.body;
      }
    }

    // Try parsing Spring Boot error JSON: {"message": "...", "status": 400, "error": "..."}
    String message = 'Server error occurred (Code $statusCode)';
    dynamic details;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        message = decoded['message'] ?? decoded['error'] ?? message;
        details = decoded;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw ApiException(
      statusCode: statusCode,
      message: message,
      details: details,
    );
  }
}
