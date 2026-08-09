import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/models.dart';
import '../../services/catalog_service.dart';
import '../../widgets/common.dart';
import 'facility_detail_screen.dart';

/// Tìm cơ sở theo từ khóa / môn thể thao / vị trí. Dùng chung điều kiện lọc với trang tìm kiếm Web.
class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({super.key, this.initialSportId, this.initialSportName});

  final int? initialSportId;
  final String? initialSportName;

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  final _keywordController = TextEditingController();

  late Future<List<FacilitySummary>> _future;
  int? _sportId;
  bool _nearbyOnly = false;
  bool _promotionOnly = false;

  @override
  void initState() {
    super.initState();
    _sportId = widget.initialSportId;
    _future = _load();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  Future<List<FacilitySummary>> _load() async {
    double? lat;
    double? lng;
    if (_nearbyOnly) {
      final pos = await _position();
      if (pos == null) {
        throw Exception('Không lấy được vị trí. Hãy bật GPS và cấp quyền cho ứng dụng.');
      }
      lat = pos.latitude;
      lng = pos.longitude;
    }
    return CatalogService.instance.facilities(
      keyword: _keywordController.text.trim(),
      sportId: _sportId,
      latitude: lat,
      longitude: lng,
      promotionOnly: _promotionOnly,
      size: 50,
    );
  }

  Future<Position?> _position() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
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
        title: Text(widget.initialSportName == null ? 'Tìm sân' : 'Sân ${widget.initialSportName}'),
        automaticallyImplyLeading: Navigator.of(context).canPop(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _keywordController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Tên cơ sở hoặc địa chỉ',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _reload),
              ),
              onSubmitted: (_) => _reload(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Gần tôi'),
                  selected: _nearbyOnly,
                  onSelected: (v) {
                    setState(() => _nearbyOnly = v);
                    _reload();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Có khuyến mãi'),
                  selected: _promotionOnly,
                  onSelected: (v) {
                    setState(() => _promotionOnly = v);
                    _reload();
                  },
                ),
                if (_sportId != null) ...[
                  const SizedBox(width: 8),
                  InputChip(
                    label: Text(widget.initialSportName ?? 'Môn #$_sportId'),
                    onDeleted: () {
                      setState(() => _sportId = null);
                      _reload();
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: AsyncView<List<FacilitySummary>>(
              future: _future,
              onRetry: _reload,
              builder: (context, items) {
                if (items.isEmpty) return const EmptyState('Không tìm thấy cơ sở phù hợp.');
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final f = items[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: RemoteImage(url: f.image, width: 56, height: 56),
                        title: Text(f.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.address ?? ''),
                            Text([
                              if (f.sports.isNotEmpty) f.sports.join(', '),
                              if (f.minPrice > 0) 'từ ${formatMoney(f.minPrice)}',
                              if (f.distanceKm != null) '${f.distanceKm} km',
                            ].join(' · ')),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: f.hasPromotion ? const Icon(Icons.local_offer, color: Colors.orange) : null,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => FacilityDetailScreen(facilityId: f.facilityId),
                        )),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
