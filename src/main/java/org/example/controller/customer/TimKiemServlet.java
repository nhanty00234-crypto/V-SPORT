package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CoSoDAO;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.KhuyenMaiHinhAnhDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.KhuyenMaiHinhAnhDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.model.CoSo;
import org.example.model.KhuyenMai;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.model.TaiKhoan;
import org.example.model.MonTheThao;
import org.example.service.customer.PromotionImagePresenter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Trang tìm kiếm thật của Customer Portal: /customer/tim-kiem?q=&sportId=&openNow=
 * GET only. Đọc query param, validate, gọi DAO thật (CoSoDAO.searchCoSo — JPQL
 * bind parameter, không nối chuỗi SQL), forward dữ liệu thật sang TimKiem.jsp.
 * Cho phép khách chưa đăng nhập xem (cùng chính sách với /customer/dat-san).
 */
@WebServlet("/customer/tim-kiem")
public class TimKiemServlet extends HttpServlet {

    private static final Logger LOGGER = LogManager.getLogger(TimKiemServlet.class);
    private static final int MAX_KEYWORD_LENGTH = 120;

    private final CoSoDAO coSoDAO = new CoSoDAOImpl();
    private final LoaiSanDAO loaiSanDAO = new LoaiSanDAOImpl();
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final KhuyenMaiHinhAnhDAO khuyenMaiHinhAnhDAO = new KhuyenMaiHinhAnhDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String rawQuery = req.getParameter("q");
        String query = rawQuery != null ? rawQuery.trim() : "";
        if (query.length() > MAX_KEYWORD_LENGTH) {
            query = query.substring(0, MAX_KEYWORD_LENGTH);
        }

        Integer sportId = parsePositiveInt(req.getParameter("sportId"));
        // Nếu không có sportId trong request, dùng môn yêu thích từ session (nếu đã đăng nhập).
        // sportId explicit từ request luôn thắng preference.
        if (sportId == null) {
            HttpSession sess = req.getSession(false);
            TaiKhoan sessionUser = sess != null ? (TaiKhoan) sess.getAttribute("user") : null;
            if (sessionUser != null) sportId = sessionUser.getMonTheThaoYeuThichId();
        }
        Integer coSoId = parsePositiveInt(req.getParameter("coSoId"));
        boolean openNow = "true".equals(req.getParameter("openNow")) || "1".equals(req.getParameter("openNow"));

        List<MonTheThao> dsMon;
        try {
            dsMon = loaiSanDAO.getAllMonTheThao();
        } catch (Exception e) {
            LOGGER.error("TIM_KIEM_LOAD_SPORTS_ERROR", e);
            dsMon = new ArrayList<>();
        }

        List<CoSo> results;
        try {
            results = coSoDAO.searchCoSo(query, sportId);
        } catch (Exception e) {
            LOGGER.error("TIM_KIEM_SEARCH_ERROR query={} sportId={}", query, sportId, e);
            req.setAttribute("searchError", true);
            results = new ArrayList<>();
        }

        // Batch-query first sport per facility from actual courts (source of truth: San→LoaiSan→MonTheThao).
        // A single GROUP BY query for all result IDs avoids N+1. IDs are ints — no injection risk.
        java.util.Map<Integer, String> facilityFirstSport = new java.util.HashMap<>();
        if (results != null && !results.isEmpty()) {
            StringBuilder ids = new StringBuilder();
            for (CoSo c : results) {
                if (ids.length() > 0) ids.append(',');
                ids.append(c.getCoSoID());
            }
            String sportBatchSql =
                "SELECT s.facility_id, MIN(mt.sport_name) AS sport_name " +
                "FROM courts s " +
                "JOIN court_types ls ON s.court_type_id = ls.court_type_id " +
                "JOIN sports mt ON ls.sport_id = mt.sport_id " +
                "WHERE s.facility_id IN (" + ids + ") " +
                "  AND (s.is_deleted = 0 OR s.is_deleted IS NULL) " +
                "  AND (ls.is_deleted = 0 OR ls.is_deleted IS NULL) " +
                "GROUP BY s.facility_id";
            try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
                 java.sql.Statement st = conn.createStatement();
                 java.sql.ResultSet rs = st.executeQuery(sportBatchSql)) {
                while (rs.next()) {
                    facilityFirstSport.put(rs.getInt("facility_id"), rs.getString("sport_name"));
                }
            } catch (Exception e) {
                LOGGER.warn("TIM_KIEM_SPORT_BATCH_WARN", e);
            }
        }
        req.setAttribute("facilityFirstSport", facilityFirstSport);

        // coSoId (đến từ nút "Lọc chi tiết" mở từ một cơ sở cụ thể, hoặc share-link)
        // thu hẹp thêm kết quả về đúng cơ sở đó, không cần DAO riêng.
        if (coSoId != null && results != null) {
            List<CoSo> narrowed = new ArrayList<>();
            for (CoSo c : results) {
                if (c.getCoSoID() == coSoId) narrowed.add(c);
            }
            results = narrowed;
        }

        // openNow lọc theo giờ mở/đóng cửa thật của từng cơ sở tại thời điểm request.
        if (openNow && results != null) {
            java.time.LocalTime now = java.time.LocalTime.now();
            List<CoSo> filtered = new ArrayList<>();
            for (CoSo c : results) {
                if (c.getGioMoCua() != null && c.getGioDongCua() != null
                        && !now.isBefore(c.getGioMoCua()) && !now.isAfter(c.getGioDongCua())) {
                    filtered.add(c);
                }
            }
            results = filtered;
        }

        req.setAttribute("facilityPromotions", buildFacilityPromotions(req, results));

        req.setAttribute("query", query);
        req.setAttribute("sportId", sportId);
        req.setAttribute("coSoId", coSoId);
        req.setAttribute("openNow", openNow);
        req.setAttribute("dsMon", dsMon);
        req.setAttribute("results", results);

        req.getRequestDispatcher("/customer/TimKiem.jsp").forward(req, resp);
    }

    /**
     * Với mỗi cơ sở trong kết quả tìm kiếm, gắn 1 khuyến mãi đại diện (mới bắt đầu nhất,
     * công khai/còn hiệu lực) kèm ảnh bìa thật từ DB - request attribute "facilityPromotions"
     * (Map CoSoID -> {khuyenMaiId, maCode, moTa, coverImageUrl}) để TimKiem.jsp hiển thị badge
     * khuyến mãi khi frontend được nối tiếp. Không có khuyến mãi -> không có key cho CoSoID đó.
     */
    private Map<Integer, Map<String, Object>> buildFacilityPromotions(HttpServletRequest req, List<CoSo> facilities) {
        Map<Integer, Map<String, Object>> byFacility = new LinkedHashMap<>();
        if (facilities == null || facilities.isEmpty()) return byFacility;
        try {
            List<Integer> ids = new ArrayList<>();
            for (CoSo c : facilities) ids.add(c.getCoSoID());
            List<KhuyenMai> promos = khuyenMaiDAO.findPublicActiveByCoSoIds(ids, LocalDate.now());
            if (promos.isEmpty()) return byFacility;

            List<Integer> promoIds = new ArrayList<>();
            for (KhuyenMai km : promos) promoIds.add(km.getKhuyenMaiID());
            Map<Integer, List<KhuyenMaiHinhAnh>> imagesByPromo = khuyenMaiHinhAnhDAO.findByKhuyenMaiIds(promoIds);

            for (KhuyenMai km : promos) {
                // promos đã ORDER BY CoSoID, NgayBatDau DESC - giữ bản ghi đầu tiên mỗi CoSoID.
                byFacility.computeIfAbsent(km.getCoSoID(), id -> {
                    List<KhuyenMaiHinhAnh> images = imagesByPromo.getOrDefault(km.getKhuyenMaiID(), List.of());
                    Map<String, Object> dto = new LinkedHashMap<>();
                    dto.put("khuyenMaiId", km.getKhuyenMaiID());
                    dto.put("maCode", km.getMaCode());
                    dto.put("moTa", km.getMoTa());
                    dto.put("coverImageUrl", images.isEmpty() ? null
                            : PromotionImagePresenter.coverImageUrl(req.getContextPath(), images));
                    return dto;
                });
            }
        } catch (Exception e) {
            LOGGER.warn("TIM_KIEM_PROMOTION_BATCH_WARN", e);
        }
        return byFacility;
    }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
