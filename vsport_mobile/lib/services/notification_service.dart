import '../models/models.dart';
import 'api_client.dart';

/// Thông báo do backend hiện có sinh ra (booking, thanh toán, hoàn tiền, yêu cầu dịch vụ...).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final ApiClient _api = ApiClient.instance;

  Future<NotificationPage> list({int page = 1, int size = 20}) async {
    final data = await _api.get('/notifications/me', query: {'page': '$page', 'size': '$size'})
        as Map<String, dynamic>;
    return NotificationPage.fromJson(data);
  }

  Future<void> markRead(int id) => _api.post('/notifications/$id/read');

  Future<void> markAllRead() => _api.post('/notifications/read-all');
}
