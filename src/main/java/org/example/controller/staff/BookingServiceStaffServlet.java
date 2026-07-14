package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.LichDatSanDichVuDAO;
import org.example.dao.impl.LichDatSanDichVuDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * /staff/booking-service/update-status
 *
 * Quản lý dịch vụ khách đặt trước (Phase 8A) từ phía lễ tân/quản lý.
 * Hoàn toàn TÁCH BIỆT khỏi CheckInServlet/CheckInDAO — chỉ thao tác trên bảng
 * LichDatSan_DichVu (checklist thuần túy), KHÔNG tạo hóa đơn, KHÔNG trừ tồn kho,
 * KHÔNG đụng PayOS/webhook.
 *
 * GET  ?action=list           → JSON danh sách dịch vụ đặt trước hôm nay của Cơ Sở nhân viên.
 * POST action=deliver|cancel  → Cập nhật trạng thái 1 dòng dịch vụ (chỉ Manager/Staff, đúng Cơ Sở).
 */
@WebServlet("/staff/booking-service/update-status")
public class BookingServiceStaffServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(BookingServiceStaffServlet.class.getName());
    private static final com.google.gson.Gson gson = new com.google.gson.Gson();

    private final LichDatSanDichVuDAO dao = new LichDatSanDichVuDAOImpl();

    private TaiKhoan requireStaffOrManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || user.getCoSoId() == null ||
                (user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_LE_TAN)) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.getWriter().write("{\"error\":\"Bạn không có quyền truy cập chức năng này.\"}");
            return null;
        }
        return user;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = requireStaffOrManager(req, resp);
        if (user == null) return;

        resp.setContentType("application/json;charset=UTF-8");
        try {
            List<Map<String, Object>> items = dao.findTodayByCoSo(user.getCoSoId());
            Map<String, Object> data = new HashMap<>();
            data.put("items", items);
            resp.getWriter().write(gson.toJson(data));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi lấy danh sách dịch vụ đặt trước", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"Có lỗi xảy ra khi tải danh sách.\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = requireStaffOrManager(req, resp);
        if (user == null) return;

        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");
        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Thiếu hoặc sai tham số id.\"}");
            return;
        }

        String newStatus;
        if ("deliver".equals(action)) {
            newStatus = "Đã giao";
        } else if ("cancel".equals(action)) {
            newStatus = "Đã hủy";
        } else {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\":\"Hành động không hợp lệ.\"}");
            return;
        }

        try {
            boolean ok = dao.updateStatus(id, newStatus, user.getAccountId(), user.getCoSoId());
            if (ok) {
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.setStatus(HttpServletResponse.SC_CONFLICT);
                resp.getWriter().write("{\"error\":\"Không thể cập nhật (dòng không tồn tại, không thuộc cơ sở của bạn, hoặc đã được xử lý trước đó).\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi khi cập nhật trạng thái dịch vụ đặt trước, id=" + id, e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\":\"Có lỗi xảy ra khi cập nhật.\"}");
        }
    }
}
