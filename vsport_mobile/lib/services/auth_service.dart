import '../models/models.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';

/// Đăng nhập / refresh / đăng xuất và hồ sơ khách hàng.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiClient _api = ApiClient.instance;
  final SecureStorageService _storage = SecureStorageService.instance;

  Customer? currentCustomer;

  Future<Customer> login({String? email, String? phone, required String password}) async {
    final data = await _api.post(
      '/auth/login',
      auth: false,
      body: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
      },
    ) as Map<String, dynamic>;

    await _storage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    currentCustomer = Customer.fromJson(data['customer'] as Map<String, dynamic>);
    return currentCustomer!;
  }

  Future<bool> hasSession() async {
    final token = await _storage.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Dùng ở màn hình Splash: xác nhận token còn dùng được bằng một lần gọi /customer/me.
  Future<Customer?> restoreSession() async {
    if (!await hasSession()) return null;
    try {
      currentCustomer = await me();
      return currentCustomer;
    } on ApiException {
      await logout();
      return null;
    }
  }

  Future<Customer> me() async {
    final data = await _api.get('/customer/me') as Map<String, dynamic>;
    currentCustomer = Customer.fromJson(data);
    return currentCustomer!;
  }

  Future<Customer> updateProfile({String? fullName, String? phone, String? gender, String? dateOfBirth}) async {
    final data = await _api.put('/customer/me', body: {
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    }) as Map<String, dynamic>;
    currentCustomer = Customer.fromJson(data);
    return currentCustomer!;
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Token stateless — đăng xuất phía client là đủ, lỗi mạng không cản trở.
    }
    await _storage.clear();
    currentCustomer = null;
  }
}
