package org.example.controller.api.v1.facility;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ApiMappers;
import org.example.api.BaseApiServlet;
import org.example.api.ImageUrls;
import org.example.dto.api.ApiDtos;
import org.example.model.CoSo;
import org.example.model.KhuyenMai;
import org.example.model.LoaiSan;
import org.example.model.San;
import org.example.service.customer.CustomerCatalogService;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * GET /api/v1/facilities                      — tìm cơ sở (keyword, sportId, lat/lng, promotionOnly, page, size)
 * GET /api/v1/facilities/nearby               — như trên nhưng BẮT BUỘC lat/lng, sắp xếp theo khoảng cách
 * GET /api/v1/facilities/{id}                 — chi tiết cơ sở (sân, môn, khuyến mãi hiện hành)
 * GET /api/v1/facilities/{id}/courts?sportId= — danh sách sân có thể đặt của cơ sở
 *
 * Endpoint công khai (không cần token) — dữ liệu này Web cũng cho khách vãng lai xem.
 * KHÔNG trả bất kỳ thông tin nội bộ nào của Manager (tài khoản quản lý, cấu hình PayOS, ...).
 */
@WebServlet("/api/v1/facilities/*")
public class FacilityApiServlet extends BaseApiServlet {

    private static final double MAX_RADIUS_KM = 200.0;

    private final CustomerCatalogService catalogService = new CustomerCatalogService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            String[] seg = pathSegments(req);
            if (seg.length == 0) {
                listFacilities(req, resp, false);
            } else if (seg.length == 1 && "nearby".equals(seg[0])) {
                listFacilities(req, resp, true);
            } else if (seg.length == 1) {
                facilityDetail(req, resp, requireInt(seg[0], "facilityId"));
            } else if (seg.length == 2 && "courts".equals(seg[1])) {
                courtsOfFacility(req, resp, requireInt(seg[0], "facilityId"));
            } else {
                throw notFound("Endpoint không tồn tại.");
            }
        });
    }

    // ------------------------------------------------------------------

    private void listFacilities(HttpServletRequest req, HttpServletResponse resp, boolean requireCoordinates)
            throws IOException {
        String keyword = trimToNull(req.getParameter("keyword"));
        Integer sportId = optionalInt(req, "sportId");
        Double lat = optionalDouble(req, "latitude");
        Double lng = optionalDouble(req, "longitude");
        Double radiusKm = optionalDouble(req, "radiusKm");
        boolean promotionOnly = "true".equalsIgnoreCase(req.getParameter("promotionOnly"));
        int page = pageParam(req);
        int size = sizeParam(req);

        if (requireCoordinates && (lat == null || lng == null)) {
            throw badRequest("Endpoint nearby cần cả latitude và longitude.");
        }
        if ((lat == null) != (lng == null)) {
            throw badRequest("Cần cung cấp cả latitude và longitude.");
        }
        if (lat != null && (lat < -90 || lat > 90)) throw badRequest("latitude phải nằm trong khoảng [-90, 90].");
        if (lng != null && (lng < -180 || lng > 180)) throw badRequest("longitude phải nằm trong khoảng [-180, 180].");
        if (radiusKm != null) {
            if (lat == null) throw badRequest("radiusKm chỉ dùng khi có latitude/longitude.");
            if (radiusKm <= 0 || radiusKm > MAX_RADIUS_KM) {
                throw badRequest("radiusKm phải lớn hơn 0 và tối đa " + (int) MAX_RADIUS_KM + " km.");
            }
        }

        List<CoSo> facilities = catalogService.searchFacilities(keyword, sportId);
        List<Integer> ids = facilities.stream().map(CoSo::getCoSoID).toList();
        Map<Integer, CustomerCatalogService.FacilityStats> stats = catalogService.facilityStats(ids);
        Map<Integer, List<KhuyenMai>> promotions = catalogService.publicPromotions(ids);

        List<ApiDtos.FacilitySummaryDto> items = new ArrayList<>();
        for (CoSo cs : facilities) {
            CustomerCatalogService.FacilityStats st = stats.get(cs.getCoSoID());
            boolean hasPromotion = promotions.containsKey(cs.getCoSoID());
            if (promotionOnly && !hasPromotion) continue;

            ApiDtos.FacilitySummaryDto dto = summary(req, cs, st, hasPromotion);
            if (lat != null && dto.latitude != null && dto.longitude != null) {
                double dist = CustomerCatalogService.haversineKm(lat, lng, dto.latitude, dto.longitude);
                if (radiusKm != null && dist > radiusKm) continue;
                dto.distanceKm = Math.round(dist * 100.0) / 100.0;
            } else if (requireCoordinates) {
                continue; // nearby: bỏ cơ sở chưa có tọa độ
            }
            items.add(dto);
        }

        if (lat != null) {
            items.sort(Comparator.comparing(d -> d.distanceKm == null ? Double.MAX_VALUE : d.distanceKm));
        }

        int total = items.size();
        int from = Math.min((page - 1) * size, total);
        int to = Math.min(from + size, total);
        ok(resp, new ApiDtos.PageDto<>(page, size, total, items.subList(from, to)));
    }

    private void facilityDetail(HttpServletRequest req, HttpServletResponse resp, int facilityId) throws IOException {
        CoSo cs = catalogService.findFacility(facilityId);
        if (cs == null) throw notFound("Không tìm thấy cơ sở hoặc cơ sở không khả dụng.");

        Map<Integer, LoaiSan> courtTypes = catalogService.courtTypeMap();
        Map<Integer, String> sportNames = catalogService.sportNameMap();
        List<San> courts = catalogService.listBookableCourts(facilityId, null);

        ApiDtos.FacilityDetailDto dto = new ApiDtos.FacilityDetailDto();
        dto.facilityId = cs.getCoSoID();
        dto.name = cs.getTenCoSo();
        dto.address = cs.getDiaChi();
        dto.phone = cs.getSoDienThoai();
        dto.description = cs.getMoTa();
        dto.latitude = cs.getViDo() != null ? cs.getViDo().doubleValue() : null;
        dto.longitude = cs.getKinhDo() != null ? cs.getKinhDo().doubleValue() : null;
        dto.image = ImageUrls.absolutize(req, cs.getHinhAnh());
        dto.openTime = format(cs.getGioMoCua());
        dto.closeTime = format(cs.getGioDongCua());
        dto.openNow = CustomerCatalogService.isOpenNow(cs.getGioMoCua(), cs.getGioDongCua());
        dto.status = cs.getTrangThai();

        dto.courts = new ArrayList<>();
        Set<Integer> sportIds = new HashSet<>();
        for (San s : courts) {
            LoaiSan ls = courtTypes.get(s.getLoaiSanID());
            dto.courts.add(court(req, s, ls, sportNames));
            if (ls != null) sportIds.add(ls.getMonTheThaoID());
        }
        dto.sports = new ArrayList<>();
        for (Integer sid : sportIds) {
            ApiDtos.SportDto sp = new ApiDtos.SportDto();
            sp.sportId = sid;
            sp.name = sportNames.get(sid);
            dto.sports.add(sp);
        }

        dto.promotions = new ArrayList<>();
        for (KhuyenMai km : catalogService.publicPromotions(List.of(facilityId))
                .getOrDefault(facilityId, List.of())) {
            dto.promotions.add(ApiMappers.promotion(req, km, null));
        }

        ok(resp, dto);
    }

    private void courtsOfFacility(HttpServletRequest req, HttpServletResponse resp, int facilityId)
            throws IOException {
        if (catalogService.findFacility(facilityId) == null) {
            throw notFound("Không tìm thấy cơ sở hoặc cơ sở không khả dụng.");
        }
        Integer sportId = optionalInt(req, "sportId");
        Map<Integer, LoaiSan> courtTypes = catalogService.courtTypeMap();
        Map<Integer, String> sportNames = catalogService.sportNameMap();

        List<ApiDtos.CourtDto> out = new ArrayList<>();
        for (San s : catalogService.listBookableCourts(facilityId, sportId)) {
            out.add(court(req, s, courtTypes.get(s.getLoaiSanID()), sportNames));
        }
        ok(resp, out);
    }

    // ------------------------------------------------------------------

    private ApiDtos.FacilitySummaryDto summary(HttpServletRequest req, CoSo cs,
                                               CustomerCatalogService.FacilityStats st, boolean hasPromotion) {
        ApiDtos.FacilitySummaryDto dto = new ApiDtos.FacilitySummaryDto();
        dto.facilityId = cs.getCoSoID();
        dto.name = cs.getTenCoSo();
        dto.address = cs.getDiaChi();
        dto.phone = cs.getSoDienThoai();
        dto.latitude = cs.getViDo() != null ? cs.getViDo().doubleValue() : null;
        dto.longitude = cs.getKinhDo() != null ? cs.getKinhDo().doubleValue() : null;
        dto.image = ImageUrls.absolutize(req, cs.getHinhAnh());
        dto.openTime = format(cs.getGioMoCua());
        dto.closeTime = format(cs.getGioDongCua());
        dto.openNow = CustomerCatalogService.isOpenNow(cs.getGioMoCua(), cs.getGioDongCua());
        dto.minPrice = st != null ? st.minPrice : 0;
        dto.readyCourtCount = st != null ? st.readyCourtCount : 0;
        dto.sports = st != null ? new ArrayList<>(st.sportNames) : List.of();
        dto.hasPromotion = hasPromotion;
        return dto;
    }

    private ApiDtos.CourtDto court(HttpServletRequest req, San s, LoaiSan ls, Map<Integer, String> sportNames) {
        ApiDtos.CourtDto dto = new ApiDtos.CourtDto();
        dto.courtId = s.getSanID();
        dto.name = s.getTenSan();
        dto.facilityId = s.getCoSoID();
        dto.courtTypeId = s.getLoaiSanID();
        dto.status = s.getTrangThai();
        dto.image = ImageUrls.absolutize(req, s.getHinhAnh());
        dto.description = s.getMoTa();
        if (ls != null) {
            dto.courtTypeName = ls.getTenLoai();
            dto.sportId = ls.getMonTheThaoID();
            dto.sportName = sportNames.get(ls.getMonTheThaoID());
            dto.priceWithoutLight = BigDecimal.valueOf(ls.getGiaKhongDen());
            dto.priceWithLight = BigDecimal.valueOf(ls.getGiaCoDen());
            dto.lightingStart = format(ls.getGioBatDauLenDen());
            dto.lightingEnd = format(ls.getGioKetThucLenDen());
        }
        return dto;
    }

    private static String format(LocalTime t) {
        return t == null ? null : String.format("%02d:%02d", t.getHour(), t.getMinute());
    }

    private static String trimToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
