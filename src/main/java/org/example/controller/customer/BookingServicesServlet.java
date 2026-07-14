package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.SanDAO;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.impl.SanDAOImpl;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.model.San;
import org.example.model.SanPham_DichVu;
import org.example.util.Constants;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;

/**
 * GET /customer/booking-services?sanId=...
 *
 * Trả về JSON danh sách dịch vụ (SanPham_DichVu) đang kinh doanh, thuộc ĐÚNG Cơ Sở
 * của sân được truyền vào. Dùng bởi DatSan.jsp để hiển thị block "Dịch vụ đi kèm"
 * khi khách chọn sân, TRƯỚC khi đơn đặt sân được tạo (nên chưa có DatSanID).
 *
 * Endpoint tách riêng khỏi DatSanServlet theo yêu cầu: nhiệm vụ duy nhất là đọc
 * danh mục dịch vụ theo cơ sở, không đụng logic đặt sân/thanh toán.
 */
@WebServlet("/customer/booking-services")
public class BookingServicesServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingServicesServlet.class.getName());

    private static final com.google.gson.Gson gson = new com.google.gson.Gson();

    private final SanDAO sanDAO = new SanDAOImpl();
    private final SanPhamDichVuDAO sanPhamDichVuDAO = new SanPhamDichVuDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        int sanId;
        try {
            sanId = Integer.parseInt(req.getParameter("sanId"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Thiếu hoặc sai tham số sanId.\"}");
            return;
        }

        try {
            San san = sanDAO.getSanById(sanId);
            if (san == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                resp.getWriter().write("{\"error\":\"Không tìm thấy sân.\"}");
                return;
            }

            List<SanPham_DichVu> all = sanPhamDichVuDAO.findByCoSo(san.getCoSoID());
            List<SanPham_DichVu> active = all.stream()
                    .filter(sp -> Constants.TRANG_THAI_SP_DANG_KINH_DOANH.equals(sp.getTrangThai()))
                    .collect(Collectors.toList());

            List<Map<String, Object>> items = new ArrayList<>();
            for (SanPham_DichVu sp : active) {
                Map<String, Object> m = new HashMap<>();
                m.put("sanPhamId", sp.getSanPhamID());
                m.put("tenSanPham", sp.getTenSanPham());
                m.put("donGia", sp.getDonGia());
                m.put("donViTinh", sp.getDonViTinh());
                m.put("soLuongTon", sp.getSoLuongTon());
                items.add(m);
            }

            Map<String, Object> data = new HashMap<>();
            data.put("coSoId", san.getCoSoID());
            data.put("services", items);
            resp.getWriter().write(gson.toJson(data));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách dịch vụ theo sân", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"Có lỗi xảy ra khi tải danh sách dịch vụ.\"}");
        }
    }
}
