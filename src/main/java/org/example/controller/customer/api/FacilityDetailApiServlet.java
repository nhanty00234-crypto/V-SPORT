package org.example.controller.customer.api;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.CoSoCapabilityDAO;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.KhuyenMaiHinhAnhDAO;
import org.example.dao.impl.CoSoCapabilityDAOImpl;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.KhuyenMaiHinhAnhDAOImpl;
import org.example.model.KhuyenMai;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.service.customer.PromotionImagePresenter;
import org.example.util.Constants;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Read-only JSON endpoint phục vụ court detail bottom sheet ở trang chủ Customer.
 * Cùng convention với MapApiServlet (/api/customer/facilities/map): JDBC qua DBUtil,
 * Gson, UTF-8, error shape {success:false, error}. Chỉ trả cơ sở đang hoạt động,
 * chưa xóa; không lộ dữ liệu nội bộ (giá nhập, tồn kho, account quản lý...).
 */
@WebServlet("/api/customer/facilities/detail")
public class FacilityDetailApiServlet extends HttpServlet {

    private final CoSoCapabilityDAO capabilityDAO = new CoSoCapabilityDAOImpl();
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final KhuyenMaiHinhAnhDAO khuyenMaiHinhAnhDAO = new KhuyenMaiHinhAnhDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int coSoId;
        String idParam = req.getParameter("coSoId");
        try {
            if (idParam == null || idParam.trim().isEmpty()) {
                sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "Thiếu tham số coSoId.");
                return;
            }
            coSoId = Integer.parseInt(idParam.trim());
            if (coSoId <= 0) {
                sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "coSoId không hợp lệ.");
                return;
            }
        } catch (NumberFormatException e) {
            sendErrorResponse(resp, HttpServletResponse.SC_BAD_REQUEST, "coSoId không hợp lệ.");
            return;
        }

        Integer sportIdFilter = null;
        String sportIdParam = req.getParameter("sportId");
        if (sportIdParam != null && !sportIdParam.trim().isEmpty()) {
            try {
                int v = Integer.parseInt(sportIdParam.trim());
                if (v > 0) sportIdFilter = v;
            } catch (NumberFormatException ignored) {}
        }

        Map<String, Object> facility = new HashMap<>();
        List<Map<String, Object>> courts = new ArrayList<>();
        List<Map<String, Object>> services = new ArrayList<>();
        Set<String> images = new LinkedHashSet<>();
        Set<String> sportsSet = new LinkedHashSet<>();

        String facilitySql = "SELECT c.facility_id, c.facility_name, c.address, c.phone_number, c.description, c.latitude, c.longitude, c.image_path, " +
                "       c.opening_time, c.closing_time, " +
                "       (SELECT MIN(ls.price_without_light) FROM court_types ls WHERE ls.facility_id = c.facility_id AND (ls.is_deleted = 0 OR ls.is_deleted IS NULL)) AS MinPrice, " +
                "       (SELECT COUNT(*) FROM courts s WHERE s.facility_id = c.facility_id AND s.status = N'Sẵn sàng' AND (s.is_deleted = 0 OR s.is_deleted IS NULL)) AS ReadyCourtCount " +
                "FROM facilities c " +
                "WHERE c.facility_id = ? AND (c.is_deleted = 0 OR c.is_deleted IS NULL) AND c.status = N'Đang hoạt động'";

        String courtsSql = "SELECT s.court_id, s.court_name, s.status, s.image_path, s.description, " +
                "       ls.type_name, ls.price_without_light, ls.price_with_light, mt.sport_name " +
                "FROM courts s " +
                "LEFT JOIN court_types ls ON s.court_type_id = ls.court_type_id " +
                "LEFT JOIN sports mt ON ls.sport_id = mt.sport_id " +
                "WHERE s.facility_id = ? " +
                "  AND (s.is_deleted = 0 OR s.is_deleted IS NULL) " +
                "  AND (ls.is_deleted = 0 OR ls.is_deleted IS NULL)" +
                (sportIdFilter != null ? " AND ls.sport_id = ?" : "") +
                " ORDER BY s.court_name";

        String servicesSql = "SELECT TOP 30 sp.product_name, sp.unit_price, sp.unit_of_measure " +
                "FROM products_services sp " +
                "WHERE sp.facility_id = ? AND (sp.is_deleted = 0 OR sp.is_deleted IS NULL) AND sp.stock_quantity > 0 " +
                "ORDER BY sp.product_name";

        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection()) {

            try (java.sql.PreparedStatement ps = conn.prepareStatement(facilitySql)) {
                ps.setInt(1, coSoId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        sendErrorResponse(resp, HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy cơ sở hoặc cơ sở đã ngừng hoạt động.");
                        return;
                    }
                    java.sql.Time gioMo = rs.getTime("opening_time");
                    java.sql.Time gioDong = rs.getTime("closing_time");
                    LocalTime openLocal = gioMo != null ? gioMo.toLocalTime() : null;
                    LocalTime closeLocal = gioDong != null ? gioDong.toLocalTime() : null;
                    LocalTime nowTime = ZonedDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toLocalTime();

                    facility.put("coSoId", rs.getInt("facility_id"));
                    facility.put("tenCoSo", rs.getString("facility_name"));
                    facility.put("address", rs.getString("address"));
                    facility.put("phone", emptyToNull(rs.getString("phone_number")));
                    facility.put("description", emptyToNull(rs.getString("description")));
                    java.math.BigDecimal viDo = rs.getBigDecimal("latitude");
                    java.math.BigDecimal kinhDo = rs.getBigDecimal("longitude");
                    facility.put("latitude", viDo != null ? viDo.doubleValue() : null);
                    facility.put("longitude", kinhDo != null ? kinhDo.doubleValue() : null);
                    facility.put("openingTime", gioMo != null ? gioMo.toString().substring(0, 5) : "");
                    facility.put("closingTime", gioDong != null ? gioDong.toString().substring(0, 5) : "");
                    facility.put("openNow", isOpenNow(openLocal, closeLocal, nowTime));
                    double minPrice = rs.getDouble("MinPrice");
                    facility.put("minPrice", rs.wasNull() ? null : minPrice);
                    facility.put("readyCourtCount", rs.getInt("ReadyCourtCount"));

                    String hinhAnh = rs.getString("image_path");
                    List<String> coSoImages = org.example.controller.manager.CoSoGalleryServlet.parseJson(hinhAnh);
                    String firstImage = coSoImages.isEmpty() ? "" : coSoImages.get(0);
                    facility.put("imageUrl", firstImage);
                    for (String img : coSoImages) addImage(images, img);

                    // Tab "Cửa hàng" chỉ tồn tại khi capability bán hàng đã được duyệt
                    // (isApprovedAny tự kiểm tra CoSo còn hoạt động/chưa xóa). Danh sách
                    // sản phẩm thật được lazy-load riêng qua FacilityShopApiServlet khi
                    // Customer bấm vào tab - không tải kèm ở đây.
                    facility.put("shopAvailable", capabilityDAO.isApprovedAny(coSoId, Constants.SHOP_MODULE_CAPABILITIES));
                }
            }

            try (java.sql.PreparedStatement ps = conn.prepareStatement(courtsSql)) {
                ps.setInt(1, coSoId);
                if (sportIdFilter != null) ps.setInt(2, sportIdFilter);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> court = new HashMap<>();
                        court.put("sanId", rs.getInt("court_id"));
                        court.put("tenSan", rs.getString("court_name"));
                        court.put("trangThai", rs.getString("status"));
                        court.put("loaiSan", rs.getString("type_name"));
                        String tenMon = emptyToNull(rs.getString("sport_name"));
                        court.put("monTheThao", tenMon);
                        if (tenMon != null) sportsSet.add(tenMon);
                        court.put("giaKhongDen", rs.getDouble("price_without_light"));
                        court.put("giaCoDen", rs.getDouble("price_with_light"));
                        court.put("moTa", emptyToNull(rs.getString("description")));
                        courts.add(court);
                        addImage(images, rs.getString("image_path"));
                    }
                }
            }
            facility.put("sports", new ArrayList<>(sportsSet));

            try (java.sql.PreparedStatement ps = conn.prepareStatement(servicesSql)) {
                ps.setInt(1, coSoId);
                try (java.sql.ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> sv = new HashMap<>();
                        sv.put("tenSanPham", rs.getString("product_name"));
                        sv.put("donGia", rs.getDouble("unit_price"));
                        sv.put("donViTinh", emptyToNull(rs.getString("unit_of_measure")));
                        services.add(sv);
                    }
                }
            }
        } catch (Exception e) {
            sendErrorResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi máy chủ nội bộ khi tải thông tin cơ sở.");
            return;
        }

        facility.put("courts", courts);
        facility.put("services", services);
        facility.put("images", new ArrayList<>(images));
        facility.put("activePromotions", buildActivePromotions(req, coSoId));

        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(new com.google.gson.Gson().toJson(facility));
    }

    /** Chỉ trả khuyến mãi đang hoạt động/còn hiệu lực/còn lượt/công khai (KhuyenMaiDAO.findPublicActiveByCoSoId). */
    private List<Map<String, Object>> buildActivePromotions(HttpServletRequest req, int coSoId) {
        List<Map<String, Object>> result = new ArrayList<>();
        try {
            List<KhuyenMai> promos = khuyenMaiDAO.findPublicActiveByCoSoId(coSoId, LocalDate.now());
            if (promos.isEmpty()) return result;
            List<Integer> ids = new ArrayList<>();
            for (KhuyenMai km : promos) ids.add(km.getKhuyenMaiID());
            Map<Integer, List<KhuyenMaiHinhAnh>> imagesByPromo = khuyenMaiHinhAnhDAO.findByKhuyenMaiIds(ids);
            for (KhuyenMai km : promos) {
                List<KhuyenMaiHinhAnh> images = imagesByPromo.getOrDefault(km.getKhuyenMaiID(), List.of());
                result.add(PromotionImagePresenter.toCustomerJson(req.getContextPath(), km, images));
            }
        } catch (Exception e) {
            // Không để lỗi truy vấn khuyến mãi làm hỏng toàn bộ response chi tiết cơ sở.
        }
        return result;
    }

    private static String emptyToNull(String s) {
        return s == null || s.trim().isEmpty() ? null : s.trim();
    }

    /** Chỉ nhận URL/đường dẫn ảnh hợp lệ (http(s) hoặc đường dẫn nội bộ có '/'). */
    private static void addImage(Set<String> images, String raw) {
        if (raw == null) {
            return;
        }
        String v = raw.trim();
        if (v.isEmpty()) {
            return;
        }
        if (v.startsWith("http://") || v.startsWith("https://") || v.contains("/")) {
            images.add(v);
        }
    }

    private void sendErrorResponse(HttpServletResponse resp, int status, String message) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        resp.getWriter().write(new com.google.gson.Gson().toJson(error));
    }

    private boolean isOpenNow(LocalTime open, LocalTime close, LocalTime now) {
        if (open == null || close == null) {
            return true;
        }
        if (open.isBefore(close)) {
            return !now.isBefore(open) && !now.isAfter(close);
        } else {
            return !now.isBefore(open) || !now.isAfter(close);
        }
    }
}
