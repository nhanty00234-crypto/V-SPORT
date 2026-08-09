import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/booking_service.dart';
import '../../widgets/common.dart';
import 'booking_detail_screen.dart';

/// Lịch sử đặt sân của chính khách đang đăng nhập (GET /api/v1/bookings/me).
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  static const _statuses = <String?>[
    null,
    'Chờ thanh toán',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Đã hoàn thành',
    'Đã hủy',
  ];

  String? _status;
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = BookingService.instance.myBookings(size: 50);
  }

  void _reload() => setState(() => _future = BookingService.instance.myBookings(status: _status, size: 50));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch đặt của tôi')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final s = _statuses[i];
                return ChoiceChip(
                  label: Text(s ?? 'Tất cả'),
                  selected: _status == s,
                  onSelected: (_) {
                    setState(() => _status = s);
                    _reload();
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncView<List<Booking>>(
              future: _future,
              onRetry: _reload,
              builder: (context, items) {
                if (items.isEmpty) return const EmptyState('Chưa có lượt đặt sân nào.');
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final b = items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: RemoteImage(url: b.image, width: 48, height: 48),
                          title: Text('${b.courtName ?? 'Sân'} · ${b.facilityName ?? ''}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${formatDate(b.bookingDate)}  ${b.startTime}–${b.endTime}'),
                              Text(formatMoney(b.totalAmount)),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: StatusChip(b.status),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.bookingId)))
                              .then((_) => _reload()),
                        ),
                      );
                    },
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
