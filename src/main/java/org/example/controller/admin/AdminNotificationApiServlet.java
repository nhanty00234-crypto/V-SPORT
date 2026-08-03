package org.example.controller.admin;

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
 * API thông báo cho Admin.
 * GET  ?format=json&limit=N  → JSON danh sách thông báo + unread count
 * POST ?action=markRead&id=N → đánh dấu đã đọc
 * POST ?action=markAllRead   → đánh dấu tất cả đã đọc
 */
@WebServlet("/admin/api/notifications")
public class AdminNotificationApiServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = getAdminUser(req);
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
        TaiKhoan user = getAdminUser(req);
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

    private TaiKhoan getAdminUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        if (s == null) return null;
        TaiKhoan u = (TaiKhoan) s.getAttribute("user");
        return (u != null && u.getRoleId() == 1) ? u : null;
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
