package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.KhuyenMaiHinhAnhDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.KhuyenMaiHinhAnhDAOImpl;
import org.example.model.KhuyenMai;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.service.customer.PromotionImagePresenter;
import org.example.util.Constants;

import java.io.IOException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Nguồn dữ liệu khuyến mãi công khai cho Customer - dùng chung cho Home "featuredPromotions"
 * (gọi với limit nhỏ, không truyền coSoId) và /customer/uu-dai (limit lớn hơn cho danh sách
 * đầy đủ). Toàn bộ dữ liệu đọc thật từ DB qua KhuyenMaiDAO.findPublicActive*, không hardcode/
 * mock. Chỉ trả khuyến mãi đang hoạt động, còn hiệu lực, còn lượt, công khai và thuộc cơ sở
 * đang hoạt động (điều kiện lọc nằm trong DAO).
 *
 * GET /api/customer/promotions?limit=N            -> công khai trên toàn hệ thống
 * GET /api/customer/promotions?coSoId=X&limit=N    -> công khai của riêng một cơ sở
 */
@WebServlet("/api/customer/promotions")
public class CustomerPromotionApiServlet extends HttpServlet {

    private static final int DEFAULT_LIMIT = 12;

    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final KhuyenMaiHinhAnhDAO khuyenMaiHinhAnhDAO = new KhuyenMaiHinhAnhDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int limit = parseLimit(req.getParameter("limit"));
        Integer coSoId = parsePositiveInt(req.getParameter("coSoId"));

        List<KhuyenMai> promos;
        try {
            LocalDate today = LocalDate.now();
            if (coSoId != null) {
                promos = khuyenMaiDAO.findPublicActiveByCoSoId(coSoId, today);
                if (promos.size() > limit) promos = promos.subList(0, limit);
            } else {
                promos = khuyenMaiDAO.findPublicActiveAll(today, limit);
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJson(resp, Map.of("success", false, "error", "Lỗi máy chủ nội bộ khi tải khuyến mãi."));
            return;
        }

        List<Map<String, Object>> promotions = new ArrayList<>();
        if (!promos.isEmpty()) {
            List<Integer> ids = new ArrayList<>();
            for (KhuyenMai km : promos) ids.add(km.getKhuyenMaiID());
            Map<Integer, List<KhuyenMaiHinhAnh>> imagesByPromo = khuyenMaiHinhAnhDAO.findByKhuyenMaiIds(ids);
            for (KhuyenMai km : promos) {
                List<KhuyenMaiHinhAnh> images = imagesByPromo.getOrDefault(km.getKhuyenMaiID(), List.of());
                promotions.add(PromotionImagePresenter.toCustomerJson(req.getContextPath(), km, images));
            }
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("promotions", promotions);

        resp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        writeJson(resp, result);
    }

    private int parseLimit(String raw) {
        if (raw == null || raw.isBlank()) return DEFAULT_LIMIT;
        try {
            int v = Integer.parseInt(raw.trim());
            if (v <= 0) return DEFAULT_LIMIT;
            return Math.min(v, Constants.MAX_PAGE_SIZE);
        } catch (NumberFormatException e) {
            return DEFAULT_LIMIT;
        }
    }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void writeJson(HttpServletResponse resp, Object body) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(gson.toJson(body));
    }
}
