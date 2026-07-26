package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.TaiKhoan;
import org.example.service.NotificationPreferenceService;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;

/**
 * GET  /customer/notification-settings  — hiển thị trang cài đặt, truyền preference từ DB
 * POST /customer/notification-settings  — lưu preference vào DB (PRG)
 *
 * Phân loại:
 *  - Giao dịch (booking, payment, refund): luôn bật, không toggle được.
 *  - Marketing (owner promotions): tắt/bật được, lưu cột NhanThongBaoMarketing (BIT, DEFAULT 1).
 *
 * Không chứa JDBC trực tiếp — uỷ thác cho NotificationPreferenceService → DBUtil.
 */
@WebServlet("/customer/notification-settings")
public class CustomerNotificationSettingsServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(CustomerNotificationSettingsServlet.class);

    private final NotificationPreferenceService prefService = new NotificationPreferenceService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getAuthenticatedCustomer(req, resp);
        if (user == null) return;

        boolean nhanThongBaoMarketing = prefService.loadMarketingPref(user.getAccountId());
        req.setAttribute("nhanThongBaoMarketing", nhanThongBaoMarketing);
        req.getRequestDispatcher("/customer/CaiDatThongBao.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getAuthenticatedCustomer(req, resp);
        if (user == null) return;

        // Checkbox không gửi value khi unchecked — nên "on" = checked, null = unchecked
        String marketingParam = req.getParameter("nhanThongBaoMarketing");
        boolean enable = "on".equals(marketingParam) || "true".equals(marketingParam) || "1".equals(marketingParam);

        prefService.saveMarketingPref(user.getAccountId(), enable);
        resp.sendRedirect(req.getContextPath() + "/customer/notification-settings?saved=1");
    }

    private TaiKhoan getAuthenticatedCustomer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            String uri = req.getRequestURI() + (req.getQueryString() != null ? "?" + req.getQueryString() : "");
            resp.sendRedirect(RoleRedirectUtil.buildLoginRedirect(req.getContextPath(), uri));
            return null;
        }
        if (user.getRoleId() != RoleRedirectUtil.ROLE_CUSTOMER) {
            try { resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Trang này chỉ dành cho Khách hàng."); } catch (Exception ignored) {}
            return null;
        }
        return user;
    }
}
