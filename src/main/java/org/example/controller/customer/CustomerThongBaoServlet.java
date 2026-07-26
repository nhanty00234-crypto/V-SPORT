package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.model.ThongBao;
import org.example.service.NotificationService;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;
import java.util.List;

/**
 * GET  /customer/thong-bao          — trang danh sách thông báo có phân trang
 * POST /customer/thong-bao?action=markRead&id=N  — đánh dấu 1 thông báo đã đọc (IDOR-safe)
 * POST /customer/thong-bao?action=markAllRead    — đánh dấu tất cả đã đọc
 */
@WebServlet("/customer/thong-bao")
public class CustomerThongBaoServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getAuthenticatedCustomer(req, resp);
        if (user == null) return;

        int accountId = user.getAccountId();

        // JSON API cho dropdown header: ?format=json&limit=N
        if ("json".equals(req.getParameter("format"))) {
            int limit = 8;
            try {
                String lStr = req.getParameter("limit");
                if (lStr != null) limit = Math.min(20, Math.max(1, Integer.parseInt(lStr)));
            } catch (NumberFormatException ignored) {}
            // Sử dụng SQL TOP limit thông qua findLatestByAccountId
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
                sb.append("\"tieuDe\":\"").append(escJson(tb.getTieuDe())).append("\",");
                sb.append("\"noiDung\":\"").append(escJson(tb.getNoiDung())).append("\",");
                sb.append("\"daDoc\":").append(tb.getDaDoc()).append(',');
                sb.append("\"duongDan\":\"").append(escJson(tb.getDuongDan())).append("\",");
                sb.append("\"loai\":\"").append(escJson(tb.getLoaiThongBao())).append("\",");
                long ms = tb.getThoiGianGui() != null ? tb.getThoiGianGui().getTime() : 0;
                sb.append("\"thoiGian\":").append(ms);
                sb.append('}');
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
            return;
        }

        int pageSize = 15;
        int page = 1;
        try {
            String p = req.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p));
        } catch (NumberFormatException ignored) {}

        int totalItems = notificationService.countTotal(accountId);
        int totalPages = Math.max(1, (int) Math.ceil((double) totalItems / pageSize));
        if (page > totalPages) page = totalPages;

        List<ThongBao> list = notificationService.getNotifications(accountId, page, pageSize);
        int unreadCount = notificationService.countUnread(accountId);

        req.setAttribute("notifications", list);
        req.setAttribute("unreadCount", unreadCount);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("hasMore", page < totalPages);

        req.getRequestDispatcher("/customer/ThongBao.jsp").forward(req, resp);
    }

    private static String escJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getAuthenticatedCustomer(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        int accountId = user.getAccountId();

        if ("markRead".equals(action)) {
            String idStr = req.getParameter("id");
            if (idStr != null) {
                try {
                    int thongBaoId = Integer.parseInt(idStr);
                    notificationService.markAsRead(thongBaoId, accountId);
                } catch (NumberFormatException ignored) {}
            }
        } else if ("markAllRead".equals(action)) {
            notificationService.markAllAsRead(accountId);
        }

        // Redirect back sau POST để tránh resubmit
        resp.sendRedirect(req.getContextPath() + "/customer/thong-bao");
    }

    private TaiKhoan getAuthenticatedCustomer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            String redirect = RoleRedirectUtil.buildLoginRedirect(req.getContextPath(),
                    req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : ""));
            resp.sendRedirect(redirect);
            return null;
        }
        if (user.getRoleId() != RoleRedirectUtil.ROLE_CUSTOMER) {
            try { resp.sendError(HttpServletResponse.SC_FORBIDDEN); } catch (Exception ignored) {}
            return null;
        }
        return user;
    }
}
