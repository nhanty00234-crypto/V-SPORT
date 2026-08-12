package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CustomerReputationHistoryDAO;
import org.example.dao.LichDatSanDAO;
import org.example.dao.ThongBaoDAO;
import org.example.dao.impl.CustomerReputationHistoryDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dao.impl.ThongBaoDAOImpl;
import org.example.model.CustomerReputationHistory;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.model.ThongBao;
import org.example.service.NotificationService;
import org.example.service.customer.CustomerCatalogService;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Session-based REST endpoints cho Next.js web frontend.
 * Tất cả endpoint đọc user từ HttpSession ("user"), không dùng JWT.
 *
 * GET /api/v1/web/customer/me            — hồ sơ + thống kê
 * GET /api/v1/web/customer/bookings      — lịch sử đặt sân (?page=1&status=)
 * GET /api/v1/web/customer/reputation   — điểm uy tín + lịch sử
 * GET /api/v1/web/customer/notifications — thông báo (?page=1&limit=20)
 * POST /api/v1/web/customer/notifications/read-all — đánh dấu đã đọc hết
 */
@WebServlet("/api/v1/web/customer/*")
public class WebCustomerApiServlet extends HttpServlet {

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final CustomerReputationHistoryDAO reputationDAO = new CustomerReputationHistoryDAOImpl();
    private final ThongBaoDAO thongBaoDAO = new ThongBaoDAOImpl();
    private final NotificationService notificationService = new NotificationService();
    private final CustomerCatalogService catalogService = new CustomerCatalogService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireSession(req, resp);
        if (user == null) return;

        String sub = subPath(req);
        if ("me".equals(sub)) {
            handleMe(req, resp, user);
        } else if ("bookings".equals(sub)) {
            handleBookings(req, resp, user);
        } else if ("reputation".equals(sub)) {
            handleReputation(req, resp, user);
        } else if ("notifications".equals(sub)) {
            handleNotifications(req, resp, user);
        } else {
            json(resp, 404, "{\"error\":\"Endpoint không tồn tại.\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireSession(req, resp);
        if (user == null) return;

        String sub = subPath(req);
        if ("notifications/read-all".equals(sub)) {
            thongBaoDAO.markAllAsRead(user.getAccountId());
            json(resp, 200, "{\"success\":true}");
        } else {
            json(resp, 404, "{\"error\":\"Endpoint không tồn tại.\"}");
        }
    }

    @Override
    protected void doOptions(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    // ------------------------------------------------------------------
    // Handlers
    // ------------------------------------------------------------------

    private void handleMe(HttpServletRequest req, HttpServletResponse resp, TaiKhoan u) throws IOException {
        int unread = notificationService.countUnread(u.getAccountId());
        List<Lichdatsan> bookings = lichDatSanDAO.getLichByAccountId(u.getAccountId());
        long total = bookings.size();
        long upcoming = bookings.stream()
                .filter(l -> l.getNgayDat() != null && !l.getNgayDat().isBefore(LocalDate.now()))
                .filter(l -> {
                    String st = l.getTrangThai();
                    return Constants.TRANG_THAI_DAT_SAN_CHO_XAC_NHAN.equals(st)
                            || Constants.TRANG_THAI_DAT_SAN_DA_XAC_NHAN.equals(st)
                            || Constants.TRANG_THAI_DAT_SAN_CHO_THANH_TOAN.equals(st);
                }).count();

        StringBuilder sb = new StringBuilder();
        sb.append("{")
                .append("\"id\":").append(u.getAccountId()).append(",")
                .append("\"fullName\":").append(jsonStr(u.getFullName())).append(",")
                .append("\"email\":").append(jsonStr(u.getEmail())).append(",")
                .append("\"phone\":").append(jsonStr(u.getPhoneNumber())).append(",")
                .append("\"avatarUrl\":").append(jsonStr(u.getAvatarUrl())).append(",")
                .append("\"role\":").append(jsonStr(roleName(u.getRoleId()))).append(",")
                .append("\"reputationScore\":").append(u.getDiemUyTin()).append(",")
                .append("\"totalBookings\":").append(total).append(",")
                .append("\"upcomingBookings\":").append(upcoming).append(",")
                .append("\"unreadNotifications\":").append(unread)
                .append("}");
        json(resp, 200, sb.toString());
    }

    private void handleBookings(HttpServletRequest req, HttpServletResponse resp, TaiKhoan u) throws IOException {
        String statusFilter = req.getParameter("status");
        int page = parseInt(req.getParameter("page"), 1);
        int pageSize = 10;

        List<Lichdatsan> all = lichDatSanDAO.getLichByAccountId(u.getAccountId());
        List<Lichdatsan> filtered = all.stream()
                .filter(l -> !l.isDeleted())
                .filter(l -> statusFilter == null || statusFilter.isBlank() || statusFilter.equals(l.getTrangThai()))
                .toList();

        int total = filtered.size();
        int from = Math.max(0, (page - 1) * pageSize);
        int to = Math.min(total, from + pageSize);
        List<Lichdatsan> paged = filtered.subList(from, to);

        List<Integer> courtIds = paged.stream()
                .filter(l -> l.getSanId() != null).map(Lichdatsan::getSanId).toList();
        Map<Integer, CustomerCatalogService.CourtContext> ctx = catalogService.courtContexts(courtIds);

        StringBuilder sb = new StringBuilder();
        sb.append("{\"total\":").append(total)
                .append(",\"page\":").append(page)
                .append(",\"pageSize\":").append(pageSize)
                .append(",\"items\":[");
        for (int i = 0; i < paged.size(); i++) {
            if (i > 0) sb.append(",");
            Lichdatsan l = paged.get(i);
            CustomerCatalogService.CourtContext c = l.getSanId() != null ? ctx.get(l.getSanId()) : null;
            sb.append("{")
                    .append("\"bookingId\":").append(l.getDatSanId()).append(",")
                    .append("\"date\":").append(jsonStr(l.getNgayDat() != null ? l.getNgayDat().toString() : null)).append(",")
                    .append("\"startTime\":").append(jsonStr(l.getGioBatDau() != null ? l.getGioBatDau().toString() : null)).append(",")
                    .append("\"endTime\":").append(jsonStr(l.getGioKetThuc() != null ? l.getGioKetThuc().toString() : null)).append(",")
                    .append("\"status\":").append(jsonStr(l.getTrangThai())).append(",")
                    .append("\"totalAmount\":").append(l.getTongTienDuKien() != null ? l.getTongTienDuKien() : BigDecimal.ZERO).append(",")
                    .append("\"courtName\":").append(c != null ? jsonStr(c.courtName) : "null").append(",")
                    .append("\"facilityId\":").append(c != null ? c.facilityId : 0).append(",")
                    .append("\"facilityName\":").append(c != null ? jsonStr(c.facilityName) : "null").append(",")
                    .append("\"facilityAddress\":").append(c != null ? jsonStr(c.facilityAddress) : "null").append(",")
                    .append("\"sportName\":").append(c != null ? jsonStr(c.sportName) : "null")
                    .append("}");
        }
        sb.append("]}");
        json(resp, 200, sb.toString());
    }

    private void handleReputation(HttpServletRequest req, HttpServletResponse resp, TaiKhoan u) throws IOException {
        List<CustomerReputationHistory> history = reputationDAO.getByAccountId(u.getAccountId());
        StringBuilder sb = new StringBuilder();
        sb.append("{\"score\":").append(u.getDiemUyTin()).append(",\"history\":[");
        for (int i = 0; i < history.size(); i++) {
            if (i > 0) sb.append(",");
            CustomerReputationHistory h = history.get(i);
            sb.append("{")
                    .append("\"id\":").append(h.getReputationHistoryId()).append(",")
                    .append("\"change\":").append(h.getScoreDelta()).append(",")
                    .append("\"reason\":").append(jsonStr(h.getReason())).append(",")
                    .append("\"actionType\":").append(jsonStr(h.getActionType())).append(",")
                    .append("\"createdAt\":").append(jsonStr(h.getCreatedAt() != null ? h.getCreatedAt().toString() : null))
                    .append("}");
        }
        sb.append("]}");
        json(resp, 200, sb.toString());
    }

    private void handleNotifications(HttpServletRequest req, HttpServletResponse resp, TaiKhoan u) throws IOException {
        int page = parseInt(req.getParameter("page"), 1);
        int limit = parseInt(req.getParameter("limit"), 20);
        int offset = (page - 1) * limit;

        List<ThongBao> list = thongBaoDAO.findByAccountId(u.getAccountId(), page, limit);
        int unread = notificationService.countUnread(u.getAccountId());

        StringBuilder sb = new StringBuilder();
        sb.append("{\"unread\":").append(unread).append(",\"items\":[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) sb.append(",");
            ThongBao t = list.get(i);
            sb.append("{")
                    .append("\"id\":").append(t.getThongBaoId()).append(",")
                    .append("\"tieuDe\":").append(jsonStr(t.getTieuDe())).append(",")
                    .append("\"noiDung\":").append(jsonStr(t.getNoiDung())).append(",")
                    .append("\"loai\":").append(jsonStr(t.getLoaiThongBao())).append(",")
                    .append("\"daDoc\":").append(t.getDaDoc()).append(",")
                    .append("\"thoiGian\":").append(jsonStr(t.getThoiGianGui() != null ? t.getThoiGianGui().toString() : null)).append(",")
                    .append("\"duongDan\":").append(jsonStr(t.getDuongDan()))
                    .append("}");
        }
        sb.append("]}");
        json(resp, 200, sb.toString());
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    private TaiKhoan requireSession(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        Object user = session != null ? session.getAttribute("user") : null;
        if (!(user instanceof TaiKhoan)) {
            json(resp, 401, "{\"error\":\"Chưa đăng nhập.\"}");
            return null;
        }
        return (TaiKhoan) user;
    }

    private String subPath(HttpServletRequest req) {
        String info = req.getPathInfo();
        if (info == null || info.equals("/")) return "";
        return info.startsWith("/") ? info.substring(1) : info;
    }

    private void json(HttpServletResponse resp, int status, String body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(body);
    }

    private static String jsonStr(String s) {
        if (s == null) return "null";
        return "\"" + s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t") + "\"";
    }

    private static int parseInt(String s, int def) {
        try { return s != null ? Integer.parseInt(s) : def; } catch (NumberFormatException e) { return def; }
    }

    private static String roleName(int roleId) {
        return switch (roleId) { case 1 -> "ADMIN"; case 2 -> "MANAGER"; case 4 -> "STAFF"; default -> "CUSTOMER"; };
    }
}
