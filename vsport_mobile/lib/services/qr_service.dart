import '../models/models.dart';
import 'api_client.dart';

/// Quét QR tại sân và gửi yêu cầu tới nhân viên.
///
/// App KHÔNG tự gửi courtId — chỉ gửi lại [sessionToken] (chính mã QR đã quét) để server tự
/// resolve ra sân, đúng yêu cầu bảo mật của backend.
class QrService {
  QrService._();

  static final QrService instance = QrService._();

  final ApiClient _api = ApiClient.instance;

  Future<QrContext> resolve(String code) async {
    final data = await _api.get('/qr/${Uri.encodeComponent(code)}') as Map<String, dynamic>;
    return QrContext.fromJson(data);
  }

  Future<ServiceRequest> createRequest({
    required String sessionToken,
    required String type,
    String? note,
    List<Map<String, int>>? items,
  }) async {
    final data = await _api.post('/service-requests', body: {
      'sessionToken': sessionToken,
      'type': type,
      'note': note,
      if (items != null) 'items': items,
    }) as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }

  Future<List<ServiceRequest>> myRequests(String qrCode) async {
    final data = await _api.get('/service-requests', query: {'qrCode': qrCode}) as List;
    return data.map((e) => ServiceRequest.fromJson(e as Map<String, dynamic>)).toList();
  }
}
