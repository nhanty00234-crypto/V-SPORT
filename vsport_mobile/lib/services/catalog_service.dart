import '../models/models.dart';
import 'api_client.dart';

/// Môn thể thao, cơ sở, sân, lịch trống — toàn bộ dữ liệu danh mục lấy từ backend.
class CatalogService {
  CatalogService._();

  static final CatalogService instance = CatalogService._();

  final ApiClient _api = ApiClient.instance;

  Future<HomeData> home({double? latitude, double? longitude}) async {
    final data = await _api.get('/home', query: {
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
    }) as Map<String, dynamic>;
    return HomeData.fromJson(data);
  }

  Future<List<Sport>> sports() async {
    final data = await _api.get('/sports', auth: false) as List;
    return data.map((e) => Sport.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FacilitySummary>> facilities({
    String? keyword,
    int? sportId,
    double? latitude,
    double? longitude,
    bool promotionOnly = false,
    int page = 1,
    int size = 20,
  }) async {
    final data = await _api.get('/facilities', auth: false, query: {
      'keyword': keyword,
      'sportId': sportId?.toString(),
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'promotionOnly': promotionOnly ? 'true' : null,
      'page': '$page',
      'size': '$size',
    }) as Map<String, dynamic>;
    return (data['items'] as List).map((e) => FacilitySummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<FacilitySummary>> nearby({required double latitude, required double longitude, double? radiusKm}) async {
    final data = await _api.get('/facilities/nearby', auth: false, query: {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'radiusKm': radiusKm?.toString(),
      'size': '50',
    }) as Map<String, dynamic>;
    return (data['items'] as List).map((e) => FacilitySummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<FacilityDetail> facilityDetail(int facilityId) async {
    final data = await _api.get('/facilities/$facilityId', auth: false) as Map<String, dynamic>;
    return FacilityDetail.fromJson(data);
  }

  Future<List<Court>> courts(int facilityId, {int? sportId}) async {
    final data = await _api.get('/facilities/$facilityId/courts',
        auth: false, query: {'sportId': sportId?.toString()}) as List;
    return data.map((e) => Court.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Availability> availability(int courtId, String date) async {
    final data = await _api.get('/courts/$courtId/availability', auth: false, query: {'date': date})
        as Map<String, dynamic>;
    return Availability.fromJson(data);
  }

  Future<List<Promotion>> promotions({int? facilityId}) async {
    final data = await _api.get('/promotions', auth: false, query: {'facilityId': facilityId?.toString()}) as List;
    return data.map((e) => Promotion.fromJson(e as Map<String, dynamic>)).toList();
  }
}
