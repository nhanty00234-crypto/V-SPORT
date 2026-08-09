import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';

/// Lỗi API đã được chuẩn hóa từ envelope {success,message,errorCode} của backend.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.errorCode});

  final String message;
  final int? statusCode;
  final String? errorCode;

  bool get isNetwork => statusCode == null;

  @override
  String toString() => message;
}

/// Người dùng cần đăng nhập lại (refresh token hỏng/hết hạn).
class SessionExpiredException extends ApiException {
  SessionExpiredException() : super('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.', statusCode: 401);
}

/// HTTP client dùng chung: gắn Bearer token, tự refresh khi access token hết hạn,
/// bóc envelope JSON và biến lỗi thành [ApiException] để UI xử lý một chỗ.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  final SecureStorageService _storage = SecureStorageService.instance;

  /// Được gán từ main.dart để điều hướng về màn hình đăng nhập khi phiên hết hạn.
  void Function()? onSessionExpired;

  Future<dynamic> get(String path, {Map<String, String?>? query, bool auth = true}) =>
      _send('GET', path, query: query, auth: auth);

  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _send('POST', path, body: body, auth: auth);

  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      _send('PUT', path, body: body, auth: auth);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String?>? query,
    Object? body,
    bool auth = true,
    bool isRetry = false,
  }) async {
    final uri = _buildUri(path, query);
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json; charset=utf-8';
    if (auth) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _http.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw ApiException('Không có kết nối mạng. Vui lòng kiểm tra Internet và thử lại.');
    } on TimeoutException {
      throw ApiException('Máy chủ phản hồi quá lâu. Vui lòng thử lại.');
    } catch (e) {
      throw ApiException('Không thể kết nối máy chủ. ($e)');
    }

    final decoded = _decode(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded is Map<String, dynamic> ? decoded['data'] : decoded;
    }

    final errorCode = decoded is Map<String, dynamic> ? decoded['errorCode'] as String? : null;
    final message = (decoded is Map<String, dynamic> ? decoded['message'] as String? : null) ??
        'Đã xảy ra lỗi (HTTP ${response.statusCode}).';

    // Access token hết hạn -> thử refresh đúng MỘT lần rồi gọi lại request gốc.
    if (response.statusCode == 401 && errorCode == 'TOKEN_EXPIRED' && auth && !isRetry) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        return _send(method, path, query: query, body: body, auth: auth, isRetry: true);
      }
      await _storage.clear();
      onSessionExpired?.call();
      throw SessionExpiredException();
    }
    if (response.statusCode == 401 && auth) {
      await _storage.clear();
      onSessionExpired?.call();
      throw SessionExpiredException();
    }

    throw ApiException(message, statusCode: response.statusCode, errorCode: errorCode);
  }

  Future<bool> _refreshToken() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final response = await _http
          .post(
            _buildUri('/auth/refresh', null),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'refreshToken': refresh}),
          )
          .timeout(ApiConfig.timeout);
      if (response.statusCode != 200) return false;
      final decoded = _decode(response);
      final data = decoded is Map<String, dynamic> ? decoded['data'] as Map<String, dynamic>? : null;
      if (data == null) return false;
      await _storage.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      return null;
    }
  }

  Uri _buildUri(String path, Map<String, String?>? query) {
    final cleaned = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && value.isNotEmpty) cleaned[key] = value;
    });
    final uri = Uri.parse('${ApiConfig.apiBase}$path');
    return cleaned.isEmpty ? uri : uri.replace(queryParameters: {...uri.queryParameters, ...cleaned});
  }
}
