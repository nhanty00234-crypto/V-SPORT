package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.service.reset.SimpleRateLimiter;
import org.example.util.AuthPortalPolicy;
import org.example.util.EmailTemplates;
import org.example.util.EmailUtil;
import org.example.util.PhoneUtil;
import org.example.util.ValidationUtil;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.List;

/**
 * Luồng quên mật khẩu cho cả hai cổng — MỘT bước duy nhất, không OTP:
 *  - Customer: GET/POST /quenmatkhau (tìm theo email hoặc số điện thoại)
 *  - Internal: GET/POST /he-thong/quen-mat-khau (chỉ email)
 *
 * Khi tài khoản hợp lệ đúng portal: hệ thống tự sinh mật khẩu mới, lưu ngay
 * vào DB rồi gửi mật khẩu đó qua email — người dùng đăng nhập lại bằng mật
 * khẩu mới này. Mọi trường hợp không hợp lệ trả về message generic tại chỗ,
 * không tiết lộ role/trạng thái tài khoản.
 * Email mới chỉ gửi tới email đã đăng ký; không có SMS provider nên phone
 * chỉ dùng để TÌM tài khoản (không fake SMS).
 */
@WebServlet({"/quenmatkhau", "/he-thong/quen-mat-khau"})
public class QuenMatKhauServlet extends HttpServlet {

    private static final Logger LOGGER = LogManager.getLogger(QuenMatKhauServlet.class);

    private static final String RATE_LIMIT_MSG =
            "Bạn đã yêu cầu quá nhiều lần. Vui lòng thử lại sau ít phút.";

    private static final int ID_MAX_REQUESTS = 5;
    private static final int IP_MAX_REQUESTS = 12;
    private static final long WINDOW_MS = 15 * 60_000L;

    private TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    private String resolvePortal(HttpServletRequest req) {
        if ("/he-thong/quen-mat-khau".equals(req.getServletPath())) {
            return AuthPortalPolicy.PORTAL_INTERNAL;
        }
        return AuthPortalPolicy.parsePortal(req.getParameter("portal"));
    }

    private String requestJspFor(String portal) {
        return AuthPortalPolicy.PORTAL_INTERNAL.equals(portal)
                ? "/auth/QuenMatKhauNoiBo.jsp"
                : "/auth/QuenMatKhau.jsp";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Điều hướng sang trang chủ với biến auth để mở modal quên mật khẩu
        resp.sendRedirect(req.getContextPath() + "/index.jsp?auth=forgot-password");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String portal = resolvePortal(req);
        boolean internal = AuthPortalPolicy.PORTAL_INTERNAL.equals(portal);
        req.setAttribute("portal", portal);
        boolean isAjax = "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));

        // Internal chỉ tìm theo email công việc
        String method = (!internal && "phone".equals(req.getParameter("method"))) ? "phone" : "email";
        String email = trim(req.getParameter("email"));
        String phone = trim(req.getParameter("phone"));

        req.setAttribute("method", method);
        req.setAttribute("resetEmailInput", email);
        req.setAttribute("resetPhoneInput", phone);

        // ===== Validate format (không phải enumeration) =====
        String normalizedPhone = null;
        if ("email".equals(method)) {
            if (!ValidationUtil.isValidEmail(email)) {
                forwardError(req, resp, portal, "Email không hợp lệ. Vui lòng kiểm tra lại.");
                return;
            }
        } else {
            normalizedPhone = PhoneUtil.normalizeVN(phone);
            if (normalizedPhone == null) {
                forwardError(req, resp, portal, "Số điện thoại không hợp lệ. Vui lòng nhập số di động Việt Nam (0, +84 hoặc 84).");
                return;
            }
        }

        // ===== Rate limit server-side (theo identifier và theo IP) =====
        long now = System.currentTimeMillis();
        String idKey = "reset-id:" + method + ":" +
                ("email".equals(method) ? email.toLowerCase() : normalizedPhone);
        String ipKey = "reset-ip:" + req.getRemoteAddr();
        if (!SimpleRateLimiter.SHARED.tryAcquire(idKey, ID_MAX_REQUESTS, WINDOW_MS, now)
                || !SimpleRateLimiter.SHARED.tryAcquire(ipKey, IP_MAX_REQUESTS, WINDOW_MS, now)) {
            LOGGER.warn("PASSWORD_RESET_RATE_LIMITED portal={} method={}", portal, method);
            forwardError(req, resp, portal, RATE_LIMIT_MSG);
            return;
        }

        // ===== Tìm tài khoản và áp portal policy (không tiết lộ kết quả) =====
        TaiKhoan account = null;
        try {
            if ("email".equals(method)) {
                account = taiKhoanDAO.timTaiKhoanTheoEmail(email);
            } else {
                List<TaiKhoan> matches = taiKhoanDAO
                        .timTaiKhoanHoatDongTheoPhone(PhoneUtil.lookupVariants(normalizedPhone));
                account = matches.size() == 1 ? matches.get(0) : null;
            }
        } catch (Throwable t) {
            LOGGER.error("Lỗi tra cứu tài khoản quên mật khẩu: {}", t.getMessage(), t);
            forwardError(req, resp, portal, "Hệ thống đang bận. Vui lòng thử lại sau.");
            return;
        }

        // Đã gỡ bỏ chính sách AuthPortalPolicy.isRoleAllowed theo yêu cầu
        boolean eligible = account != null
                && !account.isLocked()
                && account.getEmail() != null
                && ValidationUtil.isValidEmail(account.getEmail());

        // Không đủ điều kiện: giữ nguyên trang nhập, KHÔNG tạo challenge, KHÔNG gửi mail.
        // Message generic — không tiết lộ role/trạng thái/tồn tại chi tiết.
        if (!eligible) {
            LOGGER.info("PASSWORD_RESET_REQUESTED portal={} method={} account=none-or-ineligible",
                    portal, method);
            forwardError(req, resp, portal, "email".equals(method)
                    ? "Không thể gửi mã đến email này. Vui lòng kiểm tra lại thông tin."
                    : "Không thể gửi mã với số điện thoại này. Vui lòng kiểm tra lại thông tin.");
            return;
        }

        // ===== Sinh mật khẩu mới, lưu ngay vào DB (đã hash bên trong DAO) =====
        String newPassword = generateStrongPassword();
        boolean updated;
        try {
            updated = Boolean.TRUE.equals(taiKhoanDAO.capNhatMatKhau(account.getEmail(), newPassword));
        } catch (Throwable t) {
            LOGGER.error("Lỗi cập nhật mật khẩu mới cho tài khoản {}: {}", account.getAccountId(), t.getMessage(), t);
            forwardError(req, resp, portal, "Hệ thống đang bận. Vui lòng thử lại sau.");
            return;
        }
        if (!updated) {
            LOGGER.error("PASSWORD_RESET_UPDATE_FAILED portal={} accountId={}", portal, account.getAccountId());
            forwardError(req, resp, portal, "Hệ thống đang bận. Vui lòng thử lại sau.");
            return;
        }

        // Gửi ĐỒNG BỘ mật khẩu mới qua email. Mật khẩu đã đổi trong DB dù email
        // có gửi được hay không — báo lỗi để người dùng liên hệ hỗ trợ thay vì
        // âm thầm để lộ trạng thái không nhất quán.
        String loginUrl = req.getScheme() + "://" + req.getServerName()
                + (req.getServerPort() == 80 || req.getServerPort() == 443 ? "" : ":" + req.getServerPort())
                + req.getContextPath() + (internal ? "/he-thong/dang-nhap" : "/dangnhap");
        try {
            EmailUtil.sendHtmlEmail(account.getEmail(), "V-SPORT — Mật khẩu mới",
                    EmailTemplates.matKhauMoiQuenMatKhau(
                            account.getFullName() != null ? account.getFullName() : "Quý khách",
                            newPassword, loginUrl));
        } catch (Exception e) {
            LOGGER.error("Lỗi gửi email mật khẩu mới cho tài khoản {}: {}", account.getAccountId(), e.getMessage());
            forwardError(req, resp, portal,
                    "Mật khẩu đã được đặt lại nhưng không thể gửi email. Vui lòng liên hệ hỗ trợ để lấy mật khẩu mới.");
            return;
        }
        LOGGER.info("PASSWORD_RESET_COMPLETED portal={} method={} accountId={}",
                portal, method, account.getAccountId());

        String successMsg = "Mật khẩu mới đã được gửi đến email của bạn. Vui lòng đăng nhập bằng mật khẩu mới.";
        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            String redirectUrl = req.getContextPath() + (internal ? "/he-thong/dang-nhap" : "/dangnhap");
            resp.getWriter().write("{\"success\": true, \"redirectUrl\": \"" + redirectUrl
                    + "\", \"thongbao\": \"" + escapeJson(successMsg) + "\"}");
            return;
        }
        req.setAttribute("thongbao", successMsg);
        req.getRequestDispatcher(internal ? "/auth/DangNhapNoiBo.jsp" : "/auth/DangNhap.jsp").forward(req, resp);
    }

    /** Sinh mật khẩu ngẫu nhiên đủ mạnh (thoả ValidationUtil.isStrongPassword). */
    private static String generateStrongPassword() {
        String upper = "ABCDEFGHJKLMNPQRSTUVWXYZ";
        String lower = "abcdefghijkmnpqrstuvwxyz";
        String digit = "23456789";
        String special = "!@#$%^&*";
        String all = upper + lower + digit + special;
        SecureRandom random = new SecureRandom();

        char[] pwd = new char[10];
        pwd[0] = upper.charAt(random.nextInt(upper.length()));
        pwd[1] = lower.charAt(random.nextInt(lower.length()));
        pwd[2] = digit.charAt(random.nextInt(digit.length()));
        pwd[3] = special.charAt(random.nextInt(special.length()));
        for (int i = 4; i < pwd.length; i++) {
            pwd[i] = all.charAt(random.nextInt(all.length()));
        }
        for (int i = pwd.length - 1; i > 0; i--) {
            int j = random.nextInt(i + 1);
            char tmp = pwd[i]; pwd[i] = pwd[j]; pwd[j] = tmp;
        }
        return new String(pwd);
    }

    private void forwardError(HttpServletRequest req, HttpServletResponse resp, String portal, String msg)
            throws ServletException, IOException {
        if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\": false, \"loi\": \"" + escapeJson(msg) + "\"}");
            return;
        }
        req.setAttribute("loi", msg);
        req.getRequestDispatcher(requestJspFor(portal)).forward(req, resp);
    }

    private static String escapeJson(String s) {
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }
}
