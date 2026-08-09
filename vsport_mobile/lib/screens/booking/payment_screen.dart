import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/booking_service.dart';
import '../../widgets/common.dart';

/// Màn hình thanh toán PayOS.
///
/// Backend tạo payment link bằng credentials của cơ sở (secret KHÔNG bao giờ xuống app) và trả về
/// payload VietQR thô; app chỉ render payload đó thành ảnh QR. Trạng thái thanh toán được hỏi
/// định kỳ qua /payment-status — việc xác nhận PAID hoàn toàn do server quyết định.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<PaymentInfo> _future;
  Timer? _poller;
  String _status = 'pending';
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _future = BookingService.instance.createPayment(widget.bookingId);
    _poller = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _poller?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      final s = await BookingService.instance.paymentStatus(widget.bookingId);
      if (!mounted) return;
      setState(() {
        _status = s.status;
        _statusMessage = s.message;
      });
      if (s.paid || s.status == 'cancelled' || s.status == 'expired') {
        _poller?.cancel();
        if (s.paid && mounted) {
          showSnack(context, 'Thanh toán thành công!');
          Navigator.of(context).pop(true);
        }
      }
    } on ApiException {
      // Lỗi mạng tạm thời — lần poll sau sẽ thử lại.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: AsyncView<PaymentInfo>(
        future: _future,
        onRetry: () => setState(() => _future = BookingService.instance.createPayment(widget.bookingId)),
        builder: (context, p) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: p.qrPayload == null || p.qrPayload!.isEmpty
                  ? const Text('Không nhận được mã QR từ cổng thanh toán.')
                  : QrImageView(data: p.qrPayload!, size: 240),
            ),
            const SizedBox(height: 24),
            Text('Số tiền: ${formatMoney(p.amount)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (p.description != null) Text('Nội dung: ${p.description}', textAlign: TextAlign.center),
            if (p.accountNumber != null) Text('STK: ${p.accountNumber}', textAlign: TextAlign.center),
            if (p.accountName != null) Text('Chủ TK: ${p.accountName}', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_status == 'pending')
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 8),
                Flexible(child: Text(_statusMessage ?? 'Đang chờ thanh toán...')),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton(onPressed: _checkStatus, child: const Text('Kiểm tra ngay')),
            const SizedBox(height: 12),
            const Text(
              'Quét mã bằng ứng dụng ngân hàng. Hệ thống tự xác nhận khi nhận được tiền.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
