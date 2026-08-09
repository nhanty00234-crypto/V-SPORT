import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Nơi duy nhất lưu access/refresh token. Dùng Keychain (iOS) / EncryptedSharedPreferences
/// (Android) — không bao giờ ghi token vào SharedPreferences thường hay log ra console.
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  static const _accessKey = 'vsport_access_token';
  static const _refreshKey = 'vsport_refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
