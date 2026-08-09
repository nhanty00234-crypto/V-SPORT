import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/models.dart';
import '../../services/catalog_service.dart';
import '../../widgets/common.dart';
import '../booking/booking_detail_screen.dart';
import '../facility/facility_detail_screen.dart';
import '../facility/facility_list_screen.dart';
import '../notifications/notification_screen.dart';

/// Trang chủ: gọi MỘT endpoint /api/v1/home để lấy toàn bộ dữ liệu thật (không mock).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<HomeData> _load() async {
    final position = await _tryGetPosition();
    return CatalogService.instance.home(latitude: position?.latitude, longitude: position?.longitude);
  }

  /// Vị trí là tùy chọn: từ chối quyền vẫn dùng app bình thường, chỉ mất phần "gần bạn".
  Future<Position?> _tryGetPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('V-SPORT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NotificationScreen()))
                .then((_) => _reload()),
          ),
        ],
      ),
      body: AsyncView<HomeData>(
        future: _future,
        onRetry: _reload,
        builder: (context, data) => RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Xin chào, ${data.customer.fullName ?? 'bạn'}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Điểm uy tín: ${data.customer.reputationScore} · ${data.customer.reputationLabel ?? ''}',
                  style: const TextStyle(color: Colors.black54)),
              if (!data.customer.canBook)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Tài khoản đang bị hạn chế đặt sân do điểm uy tín thấp.',
                      style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 20),
              if (data.upcomingBookings.isNotEmpty) ...[
                const _SectionTitle('Lịch sắp tới'),
                ...data.upcomingBookings.map((b) => Card(
                      child: ListTile(
                        leading: RemoteImage(url: b.image, width: 48, height: 48),
                        title: Text('${b.courtName ?? 'Sân'} · ${b.facilityName ?? ''}'),
                        subtitle: Text('${formatDate(b.bookingDate)}  ${b.startTime}–${b.endTime}'),
                        trailing: StatusChip(b.status),
                        onTap: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => BookingDetailScreen(bookingId: b.bookingId)))
                            .then((_) => _reload()),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
              const _SectionTitle('Môn thể thao'),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.sports.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = data.sports[i];
                    return ActionChip(
                      label: Text('${s.name} (${s.courtCount})'),
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => FacilityListScreen(initialSportId: s.sportId, initialSportName: s.name),
                      )),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (data.promotions.isNotEmpty) ...[
                const _SectionTitle('Ưu đãi'),
                ...data.promotions.map((p) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_offer_outlined),
                        title: Text(p.code),
                        subtitle: Text(p.description ?? ''),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
              const _SectionTitle('Cơ sở nổi bật'),
              ...data.featuredFacilities.map((f) => Card(
                    child: ListTile(
                      leading: RemoteImage(url: f.image, width: 56, height: 56),
                      title: Text(f.name),
                      subtitle: Text([
                        f.address ?? '',
                        if (f.distanceKm != null) '${f.distanceKm} km',
                        if (f.minPrice > 0) 'từ ${formatMoney(f.minPrice)}',
                      ].where((e) => e.isNotEmpty).join(' · ')),
                      trailing: Icon(f.openNow ? Icons.check_circle : Icons.schedule,
                          color: f.openNow ? Colors.green : Colors.grey),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => FacilityDetailScreen(facilityId: f.facilityId),
                      )),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
}
