import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/booking_service.dart';
import '../../widgets/common.dart';
import 'payment_screen.dart';

/// Chi tiết một lượt đặt sân + hành động thanh toán / hủy.
/// Backend luôn kiểm tra đơn thuộc đúng khách đang đăng nhập (đơn của người khác trả 404).
class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final int bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Future<Booking> _future;

  @override
  void initState() {
    super.initState();
    _future = BookingService.instance.detail(widget.bookingId);
  }

  void _reload() => setState(() => _future = BookingService.instance.detail(widget.bookingId));

  Future<void> _cancel() async {
    CancelPreview? preview;
    try {
      preview = await BookingService.instance.cancelPreview(widget.bookingId);
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
      return;
    }
    if (!mounted) return;

    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn đặt sân'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(preview!.policyMessage ?? ''),
            if (preview.paid) Text('Dự kiến hoàn: ${formatMoney(preview.refundableAmount)}'),
            if (preview.cancellationFee > 0) Text('Phí hủy: ${formatMoney(preview.cancellationFee)}'),
            if (preview.reputationPenalty > 0) Text('Trừ ${preview.reputationPenalty} điểm uy tín'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Lý do hủy (tuỳ chọn)', isDense: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Đóng')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xác nhận hủy')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await BookingService.instance.cancel(widget.bookingId, reason: reasonController.text.trim());
      if (!mounted) return;
      showSnack(context, 'Đã hủy đơn đặt sân.');
      _reload();
    } on ApiException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đơn #${widget.bookingId}')),
      body: AsyncView<Booking>(
        future: _future,
        onRetry: _reload,
        builder: (context, b) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                RemoteImage(url: b.image, width: 72, height: 72),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.courtName ?? 'Sân', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(b.facilityName ?? ''),
                      Text(b.facilityAddress ?? '', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _row('Trạng thái', null, trailing: StatusChip(b.status)),
            _row('Ngày', formatDate(b.bookingDate)),
            _row('Giờ', '${b.startTime} – ${b.endTime}'),
            _row('Môn', b.sportName ?? '—'),
            _row('Tổng tiền', formatMoney(b.totalAmount)),
            if (b.note != null && b.note!.isNotEmpty) _row('Ghi chú', b.note!),
            if (b.holdRemainingSeconds != null)
              _row('Giữ chỗ còn', '${(b.holdRemainingSeconds! / 60).ceil()} phút'),
            const SizedBox(height: 24),
            if (b.payable)
              FilledButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Thanh toán PayOS'),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => PaymentScreen(bookingId: b.bookingId)))
                    .then((_) => _reload()),
              ),
            if (b.cancellable) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Hủy đơn'),
                onPressed: _cancel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? value, {Widget? trailing}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(label, style: const TextStyle(color: Colors.black54))),
            Expanded(child: trailing ?? Text(value ?? '—')),
          ],
        ),
      );
}
