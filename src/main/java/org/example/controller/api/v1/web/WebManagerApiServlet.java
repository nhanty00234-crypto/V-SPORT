package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.HoaDonDAO;
import org.example.dao.LichDatSanDAO;
import org.example.dao.SanDAO;
import org.example.dao.impl.HoaDonDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.SanDAOImpl;
import org.example.model.HoaDon;
import org.example.model.Lichdatsan;
import org.example.model.San;
import org.example.model.TaiKhoan;
import org.example.service.manager.NhanSuService;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Session-based REST endpoints cho Next.js Manager portal.
 * Tất cả endpoint đọc user từ HttpSession và kiểm tra roleId == ROLE_MANAGER.
 *
 * GET /api/v1/web/manager/dashboard — tổng quan vận hành (stats + recent invoices)
 */
@WebServlet("/api/v1/web/manager/*")
public class WebManagerApiServlet extends HttpServlet {

    private final SanDAO sanDAO = new SanDAOImpl();
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final HoaDonDAO hoaDonDAO = new HoaDonDAOImpl();
    private final NhanSuService nhanSuService = new NhanSuService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireManager(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        switch (path) {
            case "/dashboard":
                handleDashboard(resp, user);
                break;
            default:
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Not found\"}");
        }
    }

    private void handleDashboard(HttpServletResponse resp, TaiKhoan user) throws IOException {
        Integer coSoId = user.getCoSoId();
        if (coSoId == null) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Tài khoản chưa liên kết cơ sở\"}");
            return;
        }

        try {
            List<San> dsSan = sanDAO.getSansByCoSo(coSoId);
            long totalFields = dsSan.size();
            long activeFields = dsSan.stream()
                .filter(s -> "Sẵn sàng".equals(s.getTrangThai()) || "Đang dùng".equals(s.getTrangThai()))
                .count();

            List<Lichdatsan> todayList = lichDatSanDAO.getLichDatSanTodayByCoSo(coSoId);
            long todayCount = todayList.size();

            BigDecimal revenueToday = hoaDonDAO.getRevenueTodayByCoSo(coSoId);
            BigDecimal totalRevenue = hoaDonDAO.getTotalDoanhThuByCoSo(coSoId);

            List<?> staffList = nhanSuService.getStaffListByBranch(coSoId);
            long totalStaff = staffList != null ? staffList.size() : 0;

            List<HoaDon> recentInvoices = hoaDonDAO.getRecentInvoicesByCoSo(coSoId, 5);

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"coSoId\":").append(coSoId).append(",");
            sb.append("\"managerName\":\"").append(escape(user.getFullName() != null ? user.getFullName() : user.getUsername())).append("\",");
            sb.append("\"totalFields\":").append(totalFields).append(",");
            sb.append("\"activeFields\":").append(activeFields).append(",");
            sb.append("\"todayBookings\":").append(todayCount).append(",");
            sb.append("\"revenueToday\":").append(revenueToday != null ? revenueToday.longValue() : 0).append(",");
            sb.append("\"totalRevenue\":").append(totalRevenue != null ? totalRevenue.longValue() : 0).append(",");
            sb.append("\"totalStaff\":").append(totalStaff).append(",");
            sb.append("\"recentInvoices\":[");
            for (int i = 0; i < recentInvoices.size(); i++) {
                HoaDon h = recentInvoices.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"id\":").append(h.getHoaDonId()).append(",");
                sb.append("\"total\":").append((long) h.getTongThanhToan()).append(",");
                sb.append("\"status\":\"").append(escape(h.getTrangThaiThanhToan())).append("\",");
                sb.append("\"date\":\"").append(h.getNgayLap() != null ? h.getNgayLap().toString() : "").append("\"");
                sb.append("}");
            }
            sb.append("]}");

            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private TaiKhoan requireManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_MANAGER) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Không có quyền truy cập\"}");
            return null;
        }
        return user;
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
