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
import org.example.service.DanhGiaService;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;

/**
 * POST /customer/danh-gia-san — customer gửi đánh giá booking đã hoàn thành.
 * Luôn redirect sau POST để tránh resubmit.
 */
@WebServlet("/customer/danh-gia-san")
public class CustomerDanhGiaServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(CustomerDanhGiaServlet.class);

    private final DanhGiaService service = new DanhGiaService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(RoleRedirectUtil.buildLoginRedirect(req.getContextPath(),
                    req.getContextPath() + "/customer/lich-su-dat-san"));
            return;
        }
        if (user.getRoleId() != RoleRedirectUtil.ROLE_CUSTOMER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int datSanId = parseIntOrDefault(req.getParameter("datSanId"), 0);
        if (datSanId <= 0) {
            session.setAttribute("flashError", "Yêu cầu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/customer/lich-su-dat-san");
            return;
        }

        int soSao = parseIntOrDefault(req.getParameter("soSao"), 0);
        String binhLuan = req.getParameter("binhLuan");

        DanhGiaService.DgResult result = service.submitReview(datSanId, user.getAccountId(), soSao, binhLuan);

        if (result.success) {
            session.setAttribute("flashSuccess", result.message);
        } else {
            session.setAttribute("flashError", result.errors.isEmpty() ? result.message : result.errors.get(0));
        }

        String redirect = req.getParameter("redirect");
        if (redirect == null || redirect.isBlank() || !redirect.startsWith("/")) {
            redirect = "/customer/lich-su-dat-san";
        }
        resp.sendRedirect(req.getContextPath() + redirect);
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null || s.isBlank()) return def;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return def; }
    }
}
