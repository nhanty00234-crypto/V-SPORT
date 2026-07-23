package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.model.San;
import org.example.model.SanPham_DichVu;
import org.example.model.SanQR;
import org.example.service.manager.SanQRService;
import org.example.util.Constants;
import org.example.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Public read-only API: liệt kê sản phẩm/dịch vụ đang kinh doanh của cơ sở
 * chứa sân {@code sanId}, dùng cho trang quét QR của khách. Không tạo/sửa dữ liệu.
 */
@WebServlet("/api/qr/san-pham")
public class SanPhamQRApiServlet extends HttpServlet {

    private final SanPhamDichVuDAO sanPhamDao = new SanPhamDichVuDAOImpl();
    private final SanQRService sanQRService = new SanQRService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        int sanId;
        try {
            sanId = Integer.parseInt(req.getParameter("sanId"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Thiếu sanId.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        EntityManager em = JPAUtil.getEntityManager();
        San san;
        try {
            san = em.find(San.class, sanId);
        } finally {
            em.close();
        }
        if (san == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.put("success", false);
            out.put("message", "Không tìm thấy sân.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
        if (sanQR == null || !sanQR.isActive()) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            out.put("message", "Mã QR của sân này không còn hiệu lực.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        // findByCoSo đã lọc isDeleted = false; chỉ cần loại thêm sản phẩm "Ngừng kinh doanh".
        List<SanPham_DichVu> items = sanPhamDao.findByCoSo(san.getCoSoID());
        List<Map<String, Object>> data = items.stream()
            .filter(p -> !Constants.TRANG_THAI_SP_NGUNG_KINH_DOANH.equals(p.getTrangThai()))
            .map(p -> {
                Map<String, Object> m = new HashMap<>();
                m.put("sanPhamId", p.getSanPhamID());
                m.put("tenSanPham", p.getTenSanPham());
                m.put("donGia", p.getDonGia());
                return m;
            })
            .collect(Collectors.toList());
        out.put("success", true);
        out.put("data", data);
        resp.getWriter().write(gson.toJson(out));
    }
}
