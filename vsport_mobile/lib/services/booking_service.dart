import '../models/models.dart';
import 'api_client.dart';

/// Đặt sân, lịch sử, hủy và thanh toán. Không tính giá phía client — luôn dùng số tiền server trả.
class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  final ApiClient _api = ApiClient.instance;

  Future<Map<String, dynamic>> quote({
    required int courtId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? promotionCode,
  }) async {
    return await _api.post('/bookings/quote', body: {
      'courtId': courtId,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
      'promotionCode': promotionCode,
    }) as Map<String, dynamic>;
  }

  /// [paymentMethod]: 'payos' (giữ chỗ + thanh toán online) hoặc 'counter' (thanh toán tại quầy).
  Future<Booking> create({
    required int courtId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? note,
    String? promotionCode,
    String paymentMethod = 'counter',
  }) async {
    final data = await _api.post('/bookings', body: {
      'courtId': courtId,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
      'note': note,
      'promotionCode': promotionCode,
      'paymentMethod': paymentMethod,
    }) as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  Future<List<Booking>> myBookings({String? status, int page = 1, int size = 20}) async {
    final data = await _api.get('/bookings/me', query: {
      'status': status,
      'page': '$page',
      'size': '$size',
    }) as Map<String, dynamic>;
    return (data['items'] as List).map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Booking> detail(int bookingId) async {
    final data = await _api.get('/bookings/$bookingId') as Map<String, dynamic>;
    return Booking.fromJson(data);
  }

  Future<CancelPreview> cancelPreview(int bookingId) async {
    final data = await _api.get('/bookings/$bookingId/cancel-preview') as Map<String, dynamic>;
    return CancelPreview.fromJson(data);
  }

  Future<void> cancel(int bookingId, {String? reason}) async {
    await _api.post('/bookings/$bookingId/cancel', body: {'reason': reason});
  }

  Future<PaymentInfo> createPayment(int bookingId) async {
    final data = await _api.post('/bookings/$bookingId/payment') as Map<String, dynamic>;
    return PaymentInfo.fromJson(data);
  }

  Future<PaymentStatus> paymentStatus(int bookingId) async {
    final data = await _api.get('/bookings/$bookingId/payment-status') as Map<String, dynamic>;
    return PaymentStatus.fromJson(data);
  }
}
