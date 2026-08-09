import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../services/catalog_service.dart';
import '../../widgets/common.dart';
import '../booking/court_booking_screen.dart';

/// Chi tiết cơ sở: thông tin, khuyến mãi hiện hành và danh sách sân có thể đặt.
class FacilityDetailScreen extends StatefulWidget {
  const FacilityDetailScreen({super.key, required this.facilityId});

  final int facilityId;

  @override
  State<FacilityDetailScreen> createState() => _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends State<FacilityDetailScreen> {
  late Future<FacilityDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = CatalogService.instance.facilityDetail(widget.facilityId);
  }

  void _reload() => setState(() => _future = CatalogService.instance.facilityDetail(widget.facilityId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết cơ sở')),
      body: AsyncView<FacilityDetail>(
        future: _future,
        onRetry: _reload,
        builder: (context, f) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RemoteImage(url: f.image, width: double.infinity, height: 180),
            const SizedBox(height: 12),
            Text(f.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(f.address ?? ''),
            if (f.phone != null) Text('SĐT: ${f.phone}'),
            Text('Giờ mở cửa: ${f.openTime ?? '--'} – ${f.closeTime ?? '--'}'
                '${f.openNow ? '  (đang mở)' : ''}'),
            if (f.description != null && f.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(f.description!),
            ],
            if (f.promotions.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Khuyến mãi', style: TextStyle(fontWeight: FontWeight.bold)),
              ...f.promotions.map((p) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.local_offer_outlined),
                    title: Text(p.code),
                    subtitle: Text(p.description ?? ''),
                  )),
            ],
            const SizedBox(height: 16),
            const Text('Sân có thể đặt', style: TextStyle(fontWeight: FontWeight.bold)),
            if (f.courts.isEmpty)
              const Padding(padding: EdgeInsets.all(12), child: Text('Cơ sở chưa có sân khả dụng.')),
            ...f.courts.map((c) => Card(
                  child: ListTile(
                    leading: RemoteImage(url: c.image, width: 48, height: 48),
                    title: Text(c.name),
                    subtitle: Text([
                      c.sportName ?? '',
                      c.courtTypeName ?? '',
                      if (c.priceWithoutLight != null) 'từ ${formatMoney(c.priceWithoutLight)}/giờ',
                    ].where((e) => e.isNotEmpty).join(' · ')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => CourtBookingScreen(court: c, facilityName: f.name),
                    )),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
