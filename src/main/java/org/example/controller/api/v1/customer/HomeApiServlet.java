package org.example.controller.api.v1.customer;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ApiMappers;
import org.example.api.BaseApiServlet;
import org.example.api.ImageUrls;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dto.api.ApiDtos;
import org.example.model.CoSo;
import org.example.model.KhuyenMai;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.service.NotificationService;
import org.example.service.customer.CustomerCatalogService;
import org.example.util.Constants;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;

/**
 * GET /api/v1/home — gộp dữ liệu màn hình Trang chủ trong MỘT lần gọi (giảm round-trip cho app):
 * hồ sơ khách, môn thể thao, cơ sở nổi bật (ưu tiên gần vị trí nếu app gửi latitude/longitude),
 * khuyến mãi công khai, lịch đặt sắp tới và số thông báo chưa đọc.
 *
 * Mọi phần dữ liệu đều lấy từ chính các service/DAO mà Web dùng — đây chỉ là lớp gộp kết quả.
 */
@WebServlet("/api/v1/home")
public class HomeApiServlet extends BaseApiServlet {

    private static final int FEATURED_LIMIT = 10;
    private static final int PROMOTION_LIMIT = 10;
    private static final int UPCOMING_LIMIT = 5;

    private final CustomerCatalogService catalogService = new CustomerCatalogService();
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp, () -> {
            TaiKhoan me = requireCustomer(req);
            Double lat = optionalDouble(req, "latitude");
            Double lng = optionalDouble(req, "longitude");

            ApiDtos.HomeDto dto = new ApiDtos.HomeDto();
            dto.customer = ApiMappers.customer(req, me);

            dto.sports = new ArrayList<>();
            for (CustomerCatalogService.SportSummary s : catalogService.listAvailableSports()) {
                ApiDtos.SportDto sd = new ApiDtos.SportDto();
                sd.sportId = s.sportId;
                sd.name = s.name;
                sd.courtCount = s.courtCount;
                sd.facilityCount = s.facilityCount;
                dto.sports.add(sd);
            }

            dto.featuredFacilities = featuredFacilities(req, lat, lng);

            dto.promotions = new ArrayList<>();
            for (KhuyenMai km : khuyenMaiDAO.findPublicActiveAll(
                    LocalDate.now(CustomerCatalogService.VN_ZONE), PROMOTION_LIMIT)) {
                dto.promotions.add(ApiMappers.promotion(req, km, null));
            }

            dto.upcomingBookings = upcomingBookings(req, me);
            dto.unreadNotifications = notificationService.countUnread(me.getAccountId());

            ok(resp, dto);
        });
    }

    private List<ApiDtos.FacilitySummaryDto> featuredFacilities(HttpServletRequest req, Double lat, Double lng) {
        List<CoSo> facilities = catalogService.searchFacilities(null, null);
        List<Integer> ids = facilities.stream().map(CoSo::getCoSoID).toList();
        Map<Integer, CustomerCatalogService.FacilityStats> stats = catalogService.facilityStats(ids);
        Map<Integer, List<KhuyenMai>> promos = catalogService.publicPromotions(ids);

        List<ApiDtos.FacilitySummaryDto> out = new ArrayList<>();
        for (CoSo cs : facilities) {
            CustomerCatalogService.FacilityStats st = stats.get(cs.getCoSoID());
            ApiDtos.FacilitySummaryDto d = new ApiDtos.FacilitySummaryDto();
            d.facilityId = cs.getCoSoID();
            d.name = cs.getTenCoSo();
            d.address = cs.getDiaChi();
            d.phone = cs.getSoDienThoai();
            d.latitude = cs.getViDo() != null ? cs.getViDo().doubleValue() : null;
            d.longitude = cs.getKinhDo() != null ? cs.getKinhDo().doubleValue() : null;
            d.image = ImageUrls.absolutize(req, cs.getHinhAnh());
            d.openTime = fmt(cs.getGioMoCua());
            d.closeTime = fmt(cs.getGioDongCua());
            d.openNow = CustomerCatalogService.isOpenNow(cs.getGioMoCua(), cs.getGioDongCua());
            d.minPrice = st != null ? st.minPrice : 0;
            d.readyCourtCount = st != null ? st.readyCourtCount : 0;
            d.sports = st != null ? new ArrayList<>(st.sportNames) : List.of();
            d.hasPromotion = promos.containsKey(cs.getCoSoID());
            if (lat != null && lng != null && d.latitude != null && d.longitude != null) {
                d.distanceKm = Math.round(
                        CustomerCatalogService.haversineKm(lat, lng, d.latitude, d.longitude) * 100.0) / 100.0;
            }
            out.add(d);
        }

        if (lat != null && lng != null) {
            out.sort(Comparator.comparing(d -> d.distanceKm == null ? Double.MAX_VALUE : d.distanceKm));
        } else {
            // Không có vị trí: ưu tiên cơ sở đang mở cửa và có nhiều sân sẵn sàng.
            out.sort(Comparator.<ApiDtos.FacilitySummaryDto, Boolean>comparing(d -> !d.openNow)
                    .thenComparing(d -> -d.readyCourtCount));
        }
        return out.subList(0, Math.min(FEATURED_LIMIT, out.size()));
    }

    private List<ApiDtos.BookingDto> upcomingBookings(HttpServletRequest req, TaiKhoan me) {
        LocalDate today = LocalDate.now(CustomerCatalogService.VN_ZONE);
        List<Lichdatsan> upcoming = new ArrayList<>();
        for (Lichdatsan l : lichDatSanDAO.getLichByAccountId(me.getAccountId())) {
            if (l.getNgayDat() == null || l.getNgayDat().isBefore(today)) continue;
            String st = l.getTrangThai();
            if (!Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN.equals(st)
                    && !Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(st)
                    && !Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(st)
                    && !Constants.TRANG_THAI_DAT_SAN_DANG_SU_DUNG.equals(st)) {
                continue;
            }
            upcoming.add(l);
            if (upcoming.size() >= UPCOMING_LIMIT) break;
        }

        Map<Integer, CustomerCatalogService.CourtContext> ctx = catalogService.courtContexts(
                upcoming.stream().map(Lichdatsan::getSanId).filter(java.util.Objects::nonNull).toList());

        List<ApiDtos.BookingDto> out = new ArrayList<>();
        for (Lichdatsan l : upcoming) {
            CustomerCatalogService.CourtContext c = ctx.get(l.getSanId());
            ApiDtos.BookingDto d = new ApiDtos.BookingDto();
            d.bookingId = l.getDatSanId();
            d.courtId = l.getSanId() != null ? l.getSanId() : 0;
            d.bookingDate = l.getNgayDat();
            d.startTime = l.getGioBatDau();
            d.endTime = l.getGioKetThuc();
            d.status = l.getTrangThai();
            d.totalAmount = l.getTongTienDuKien();
            if (c != null) {
                d.courtName = c.courtName;
                d.facilityId = c.facilityId;
                d.facilityName = c.facilityName;
                d.facilityAddress = c.facilityAddress;
                d.sportName = c.sportName;
                d.image = ImageUrls.absolutize(req, c.courtImage != null ? c.courtImage : c.facilityImage);
            }
            out.add(d);
        }
        return out;
    }

    private static String fmt(LocalTime t) {
        return t == null ? null : String.format("%02d:%02d", t.getHour(), t.getMinute());
    }
}
