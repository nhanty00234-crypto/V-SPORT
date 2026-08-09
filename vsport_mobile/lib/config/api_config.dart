import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Cấu hình endpoint backend. KHÔNG hardcode URL rải rác trong các file khác — mọi service
/// đều đọc [ApiConfig.baseUrl].
///
/// Có thể ghi đè khi chạy/đóng gói mà không sửa code:
///   flutter run --dart-define=VSPORT_API_BASE=http://192.168.1.10:8080/Backend_java
///
/// Mặc định theo môi trường chạy thật của dự án (Tomcat 10.1, context path /Backend_java):
///  - Android Emulator: 10.0.2.2 là địa chỉ máy host nhìn từ trong emulator, KHÔNG phải localhost.
///  - iOS Simulator / Desktop / Web: localhost dùng được trực tiếp.
///  - Máy thật: phải trỏ tới IP LAN của máy chạy Tomcat (dùng --dart-define ở trên).
class ApiConfig {
  ApiConfig._();

  static const String _override = String.fromEnvironment('VSPORT_API_BASE');

  /// Context path của WAR trên Tomcat (xem cấu hình SmartTomcat của dự án).
  static const String contextPath = '/Backend_java';

  static const int port = 8080;

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    final host = _defaultHost();
    return 'http://$host:$port$contextPath';
  }

  static String get apiBase => '$baseUrl/api/v1';

  static String _defaultHost() {
    if (kIsWeb) return 'localhost';
    try {
      if (Platform.isAndroid) return '10.0.2.2';
    } catch (_) {
      // Platform không khả dụng (web) — đã xử lý ở trên.
    }
    return 'localhost';
  }

  /// Thời gian chờ tối đa cho một request.
  static const Duration timeout = Duration(seconds: 20);
}
