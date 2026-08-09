import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/models.dart';
import '../../services/api_client.dart';
import '../../services/booking_service.dart';
import '../../services/catalog_service.dart';
import '../../widgets/common.dart';
import 'booking_detail_screen.dart';

/// Chọn ngày → xem khung giờ trống (giá do server tính) → đặt sân.
///
/// Cho phép chọn nhiều khung giờ LIỀN NHAU; app chỉ gửi giờ bắt đầu/kết thúc, còn giá và mọi
/// kiểm tra hợp lệ đều do backend quyết định.
class CourtBookingScreen extends StatefulWidget {
  const CourtBookingScreen({super.key, required this.court, this.facilityName});

  final Court court;
  final String? facilityName;

  @override
  State<CourtBookingScreen> createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingScreen> {
  DateTime _date = DateTime.now();
  late Future<Availability> _future;

  final Set<int> _selected = {};
  final _noteController = TextEditingController();
  String _paymentMethod = 'counter';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String get _dateString => DateFormat('yyyy-MM-dd').format(_date);

  Future<Availability> _load() => CatalogService.instance.availability(widget.court.courtId, _dateString);

  void _reload() => setState(() {
        _selected.clear();
        _future = _load();
      });

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      // Backend chỉ cho đặt trong 30 ngày tới — giới hạn luôn ở UI để tránh gọi API vô ích.
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _date = picked);
      _reload();
    }
  }

  /// Chỉ chấp nhận các khung giờ liền nhau (backend cũng yêu cầu một khoảng liên tục).
  bool _isContiguous(List<Slot> slots) {
    if (_selected.length <= 1) return true;
    final indexes = _selected.toList()..sort();
    for (var i = 1; i < indexes.length; i++) {
      if (indexes[i] != indexes[i - 1] + 1) return false;
      if (slots[indexes[i]].startTime != slots[indexes[i - 1]].endTime) return false;
    }
    return true;
  }

  Future<void> _submit(List<Slot> slots) async {
    final indexes = _selected.toList()..sort();
    if (indexes.isEmpty) {
      showSnack(context, 'Vui lòng chọn ít nhất một khung giờ.', error: true);
      return;
    }
    if (!_isContiguous(slots)) {
      showSnack(context, 'Các khung giờ phải liền nhau.', error: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final booking = await BookingService.instance.create(
        courtId: widget.court.courtId,
        bookingDate: _dateString,
        startTime: slots[indexes.first].startTime,
        endTime: slots[indexes.last].endTime,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        paymentMethod: _paymentMethod,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: booking.bookingId)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message, error: true);
      // Khung giờ vừa bị người khác đặt -> nạp lại lịch trống cho đúng thực tế.
      if (e.errorCode == 'SLOT_TAKEN') _reload();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  double _selectedTotal(List<Slot> slots) =>
      _selected.fold<double>(0, (sum, i) => sum + (slots[i].price ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.court.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.facilityName ?? '', style: const TextStyle(fontSize: 13)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat('dd/MM/yyyy').format(_date)),
            trailing: TextButton(onPressed: _pickDate, child: const Text('Đổi ngày')),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncView<Availability>(
              future: _future,
              onRetry: _reload,
              builder: (context, av) {
                if (av.slots.isEmpty) {
                  return const EmptyState('Không có khung giờ nào trong ngày này.');
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: av.slots.length,
                  itemBuilder: (context, i) {
                    final s = av.slots[i];
                    final selected = _selected.contains(i);
                    return Card(
                      color: !s.available ? Colors.grey.shade100 : (selected ? Colors.blue.shade50 : null),
                      child: ListTile(
                        enabled: s.available,
                        leading: Icon(selected ? Icons.check_box : Icons.check_box_outline_blank),
                        title: Text('${s.startTime} – ${s.endTime}'),
                        subtitle: Text(s.available ? formatMoney(s.price) : (s.reason ?? 'Không khả dụng')),
                        onTap: !s.available
                            ? null
                            : () => setState(() => selected ? _selected.remove(i) : _selected.add(i)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: FutureBuilder<Availability>(
              future: _future,
              builder: (context, snapshot) {
                final slots = snapshot.data?.slots ?? const <Slot>[];
                if (slots.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)', isDense: true),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Thanh toán: '),
                          Expanded(
                            child: SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'counter', label: Text('Tại quầy')),
                                ButtonSegment(value: 'payos', label: Text('PayOS')),
                              ],
                              selected: {_paymentMethod},
                              onSelectionChanged: (s) => setState(() => _paymentMethod = s.first),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tạm tính: ${formatMoney(_selectedTotal(slots))}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          FilledButton(
                            onPressed: _submitting || _selected.isEmpty ? null : () => _submit(slots),
                            child: _submitting
                                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Đặt sân'),
                          ),
                        ],
                      ),
                      const Text('Số tiền cuối cùng do máy chủ tính lại khi đặt.',
                          style: TextStyle(fontSize: 11, color: Colors.black45)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
