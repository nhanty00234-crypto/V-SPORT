package org.example.controller.manager;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.model.ThongBao;
import org.example.service.NotificationService;

import java.io.IOException;
import java.util.List;

/**
 * API thông báo cho Manager và Staff.
 * GET  ?format=json&limit=N  → JSON danh sách thông báo + unread count
 * POST ?action=markRead&id=N → đánh dấu đã đọc
 * POST ?action=markAllRead   → đánh dấu tất cả đã đọc
 */
@WebServlet({"/manager/api/notifications", "/staff/api/notifications"})
public class ManagerStaffNotificationApiServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = getUser(req);
        if (user == null) { resp.sendError(HttpServletResponse.SC_UNAUTHORIZED); return; }

        int limit = 8;
        try {
            String lStr = req.getParameter("limit");
            if (lStr != null) limit = Math.min(20, Math.max(1, Integer.parseInt(lStr)));
        } catch (NumberFormatException ignored) {}

        int accountId = user.getAccountId();
        List<ThongBao> items = notificationService.getLatestNotifications(accountId, limit);
        int unread = notificationService.countUnread(accountId);

        resp.setContentType("application/json; charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        StringBuilder sb = new StringBuilder("{\"unread\":").append(unread).append(",\"items\":[");
        for (int i = 0; i < items.size(); i++) {
            ThongBao tb = items.get(i);
            if (i > 0) sb.append(',');
            sb.append('{');
            sb.append("\"id\":").append(tb.getThongBaoId()).append(',');
            sb.append("\"tieuDe\":\"").append(esc(tb.getTieuDe())).append("\",");
            sb.append("\"noiDung\":\"").append(esc(tb.getNoiDung())).append("\",");
            sb.append("\"daDoc\":").append(tb.getDaDoc()).append(',');
            sb.append("\"duongDan\":\"").append(esc(tb.getDuongDan())).append("\",");
            sb.append("\"loai\":\"").append(esc(tb.getLoaiThongBao())).append("\",");
            long ms = tb.getThoiGianGui() != null ? tb.getThoiGianGui().getTime() : 0;
            sb.append("\"thoiGian\":").append(ms);
            sb.append('}');
        }
        sb.append("]}");
        resp.getWriter().write(sb.toString());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = getUser(req);
        if (user == null) { resp.sendError(HttpServletResponse.SC_UNAUTHORIZED); return; }

        String action = req.getParameter("action");
        int accountId = user.getAccountId();

        resp.setContentType("application/json; charset=UTF-8");
        if ("markRead".equals(action)) {
            try {
                int id = Integer.parseInt(req.getParameter("id"));
                boolean ok = notificationService.markAsRead(id, accountId);
                resp.getWriter().write("{\"ok\":" + ok + "}");
            } catch (Exception e) {
                resp.getWriter().write("{\"ok\":false}");
            }
        } else if ("markAllRead".equals(action)) {
            int n = notificationService.markAllAsRead(accountId);
            resp.getWriter().write("{\"ok\":true,\"count\":" + n + "}");
        } else {
            resp.getWriter().write("{\"ok\":false}");
        }
    }

    private TaiKhoan getUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return null;
        TaiKhoan u = (TaiKhoan) s.getAttribute("user");
        if (u == null) return null;
        int role = u.getRoleId();
        // roleId 2=manager, 4=staff-checkin, 5=staff-cashier
        return (role == 2 || role == 4 || role == 5) ? u : null;
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
