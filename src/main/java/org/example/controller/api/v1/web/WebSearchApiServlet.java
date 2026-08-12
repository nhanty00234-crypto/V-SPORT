package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.api.ImageUrls;
import org.example.dao.KhuyenMaiDAO;
import org.example.dao.LoaiSanDAO;
import org.example.dao.impl.KhuyenMaiDAOImpl;
import org.example.dao.impl.LoaiSanDAOImpl;
import org.example.model.CoSo;
import org.example.model.KhuyenMai;
import org.example.model.MonTheThao;
import org.example.service.customer.CustomerCatalogService;

import java.io.IOException;
import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * JSON search endpoint cho Next.js web frontend.
 *
 * GET /api/v1/web/search?q=&sportId=&openNow= → danh sách cơ sở + môn thể thao
 */
@WebServlet("/api/v1/web/search")
public class WebSearchApiServlet extends HttpServlet {

    private final CustomerCatalogService catalogService = new CustomerCatalogService();
    private final KhuyenMaiDAO khuyenMaiDAO = new KhuyenMaiDAOImpl();
    private final LoaiSanDAO loaiSanDAO = new LoaiSanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String q = req.getParameter("q");
        String sportParam = req.getParameter("sportId");
        boolean openNow = "true".equals(req.getParameter("openNow")) || "1".equals(req.getParameter("openNow"));

        Integer sportId = null;
        if (sportParam != null && !sportParam.isBlank()) {
            try { sportId = Integer.parseInt(sportParam); } catch (NumberFormatException ignored) {}
        }

        // Load sports list
        List<MonTheThao> sports;
        try { sports = loaiSanDAO.getAllMonTheThao(); } catch (Exception e) { sports = List.of(); }

        // Search facilities
        List<CoSo> results = catalogService.searchFacilities(q, sportId);
        List<Integer> ids = results.stream().map(CoSo::getCoSoID).toList();
        Map<Integer, CustomerCatalogService.FacilityStats> stats = catalogService.facilityStats(ids);
        Map<Integer, List<KhuyenMai>> promos = catalogService.publicPromotions(ids);

        // Apply openNow filter
        if (openNow) {
            results = results.stream()
                    .filter(cs -> CustomerCatalogService.isOpenNow(cs.getGioMoCua(), cs.getGioDongCua()))
                    .toList();
        }

        StringBuilder sb = new StringBuilder();
        sb.append("{");

        // Sports list
        sb.append("\"sports\":[");
        for (int i = 0; i < sports.size(); i++) {
            if (i > 0) sb.append(",");
            MonTheThao m = sports.get(i);
            sb.append("{\"id\":").append(m.getMonTheThaoID())
                    .append(",\"name\":").append(jsonStr(m.getTenMonTheThao())).append("}");
        }
        sb.append("],");

        // Facilities
        sb.append("\"facilities\":[");
        for (int i = 0; i < results.size(); i++) {
            if (i > 0) sb.append(",");
            CoSo cs = results.get(i);
            CustomerCatalogService.FacilityStats st = stats.get(cs.getCoSoID());
            boolean hasPromo = promos.containsKey(cs.getCoSoID());
            boolean isOpen = CustomerCatalogService.isOpenNow(cs.getGioMoCua(), cs.getGioDongCua());

            sb.append("{")
                    .append("\"id\":").append(cs.getCoSoID()).append(",")
                    .append("\"name\":").append(jsonStr(cs.getTenCoSo())).append(",")
                    .append("\"address\":").append(jsonStr(cs.getDiaChi())).append(",")
                    .append("\"phone\":").append(jsonStr(cs.getSoDienThoai())).append(",")
                    .append("\"image\":").append(jsonStr(ImageUrls.absolutize(req, cs.getHinhAnh()))).append(",")
                    .append("\"openTime\":").append(jsonStr(cs.getGioMoCua() != null ? cs.getGioMoCua().toString() : null)).append(",")
                    .append("\"closeTime\":").append(jsonStr(cs.getGioDongCua() != null ? cs.getGioDongCua().toString() : null)).append(",")
                    .append("\"openNow\":").append(isOpen).append(",")
                    .append("\"hasPromotion\":").append(hasPromo).append(",")
                    .append("\"minPrice\":").append(st != null ? st.minPrice : 0).append(",")
                    .append("\"readyCourtCount\":").append(st != null ? st.readyCourtCount : 0).append(",")
                    .append("\"sports\":").append(sportsJson(st != null ? (java.util.Collection<String>) st.sportNames : List.of())).append(",")
                    .append("\"latitude\":").append(cs.getViDo() != null ? cs.getViDo() : "null").append(",")
                    .append("\"longitude\":").append(cs.getKinhDo() != null ? cs.getKinhDo() : "null")
                    .append("}");
        }
        sb.append("],\"total\":").append(results.size()).append("}");

        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(sb.toString());
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private static String jsonStr(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r") + "\"";
    }

    private static String sportsJson(Collection<String> sports) {
        StringBuilder sb = new StringBuilder("[");
        int i = 0;
        for (String s : sports) {
            if (i++ > 0) sb.append(",");
            sb.append(jsonStr(s));
        }
        return sb.append("]").toString();
    }
}
