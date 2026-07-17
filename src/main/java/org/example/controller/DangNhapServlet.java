package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.service.FacilityAccessService;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;

@WebServlet({"/dangnhap", "/he-thong/dang-nhap"})
public class DangNhapServlet extends HttpServlet {

    private static final Logger LOGGER = LogManager.getLogger(DangNhapServlet.class);
    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();
    private final FacilityAccessService facilityAccessService = new FacilityAccessService();

    /** Portal của request: theo route GET hoặc hidden input POST (allowlist, không cấp role). */
    private String resolvePortal(HttpServletRequest req) {
        if ("/he-thong/dang-nhap".equals(req.getServletPath())) {
            return org.example.util.AuthPortalPolicy.PORTAL_INTERNAL;
        }
        return org.example.util.AuthPortalPolicy.parsePortal(req.getParameter("portal"));
    }

    /** JSP đăng nhập tương ứng với portal. */
    private String loginJspFor(String portal) {
        return org.example.util.AuthPortalPolicy.PORTAL_INTERNAL.equals(portal)
                ? "/auth/DangNhapNoiBo.jsp"
                : "/auth/DangNhap.jsp";
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Phòng ngừa link logout sai trỏ về đây
        if ("logout".equals(req.getParameter("action"))) {
            resp.sendRedirect(req.getContextPath() + "/logout");
            return;
        }

        String portal = resolvePortal(req);
        req.setAttribute("portal", portal);

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            String redirectUrl = req.getContextPath()
                    + org.example.util.RoleRedirectUtil.getHomePathByRoleId(user.getRoleId());
            resp.sendRedirect(redirectUrl);
        } else if ("true".equals(req.getParameter("facilityInactive"))) {
            // ActiveFacilityFilter vừa invalidate session vì cơ sở của tài khoản đã ngừng hoạt động.
            req.setAttribute("loi", "Cơ sở của tài khoản này đã ngừng hoạt động. Vui lòng liên hệ quản trị viên.");
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
        } else {
            // Trang đăng nhập toàn màn hình (thay cho modal auth trên trang chủ).
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String portal = resolvePortal(req);
        req.setAttribute("portal", portal);
        String loginMethod = "phone".equals(req.getParameter("loginMethod")) ? "phone" : "account";
        boolean isPhoneLogin = "phone".equals(loginMethod);
        String usernameOrEmail = req.getParameter("username");
        String rawPhone = req.getParameter("phone");
        String password = req.getParameter("password");
        req.setAttribute("loginMethod", loginMethod);

        String requestedWith = req.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith);

        String identifier = isPhoneLogin ? rawPhone : usernameOrEmail;
        if (identifier == null || identifier.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            String emptyMsg = isPhoneLogin
                    ? "Số điện thoại và mật khẩu không được để trống!"
                    : "Tài khoản và mật khẩu không được để trống!";
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"" + emptyMsg + "\"}");
                return;
            }

            req.setAttribute("loi", emptyMsg);
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
            return;
        }

        String normalizedPhone = null;
        if (isPhoneLogin) {
            normalizedPhone = org.example.util.PhoneUtil.normalizeVN(rawPhone);
            if (normalizedPhone == null) {
                String invalidMsg = "Số điện thoại không hợp lệ. Vui lòng nhập số di động Việt Nam (0, +84 hoặc 84).";
                if (isAjax) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\": false, \"loi\": \"" + invalidMsg + "\"}");
                    return;
                }
                req.setAttribute("loi", invalidMsg);
                req.setAttribute("phone", rawPhone);
                req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
                return;
            }
        }

        TaiKhoan taiKhoan = null;
        boolean ambiguousPhone = false;
        String dbErrorMsg = null;
        try {
            if (isPhoneLogin) {
                // Tái sử dụng đúng pipeline xác thực: tra cứu account rồi so BCrypt,
                // phần kiểm tra trạng thái/cơ sở/session/redirect bên dưới dùng chung.
                java.util.List<TaiKhoan> matches = TaiKhoanDAO
                        .timTaiKhoanHoatDongTheoPhone(org.example.util.PhoneUtil.lookupVariants(normalizedPhone));
                if (matches.size() > 1) {
                    ambiguousPhone = true;
                } else if (matches.size() == 1
                        && org.mindrot.jbcrypt.BCrypt.checkpw(password, matches.get(0).getPassword())) {
                    taiKhoan = matches.get(0);
                }
            } else {
                taiKhoan = TaiKhoanDAO.dangNhapKhachHang(usernameOrEmail, password);
            }
        } catch (ExceptionInInitializerError e) {
            LOGGER.error("Lỗi khởi tạo cấu hình kết nối database: ", e);
            dbErrorMsg = getDatabaseErrorMessage(e);
        } catch (LinkageError e) {
            // Bắt thêm LinkageError để xử lý lỗi NoClassDefFoundError phát sinh từ lỗi ExceptionInInitializerError trước đó.
            LOGGER.error("Lỗi liên kết lớp (có thể do lỗi khởi tạo CSDL trước đó): ", e);
            dbErrorMsg = getDatabaseErrorMessage(e);
        } catch (RuntimeException e) {
            LOGGER.error("Lỗi runtime database: ", e);
            dbErrorMsg = getDatabaseErrorMessage(e);
        } catch (Exception e) {
            LOGGER.error("Lỗi kết nối database thông thường: ", e);
            dbErrorMsg = getDatabaseErrorMessage(e);
        }

        if (dbErrorMsg != null) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"" + dbErrorMsg + "\"}");
                return;
            }
            req.setAttribute("loi", dbErrorMsg);
            req.setAttribute("username", usernameOrEmail);
            req.setAttribute("phone", rawPhone);
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
            return;
        }

        if (ambiguousPhone) {
            // Không tự chọn tài khoản khi một số điện thoại gắn với nhiều account.
            LOGGER.warn("Login blocked - ambiguous phone match for normalized phone (not logged for privacy)");
            String ambiguousMsg = "Số điện thoại này đang được liên kết với nhiều tài khoản. "
                    + "Vui lòng đăng nhập bằng email hoặc tên đăng nhập.";
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"" + ambiguousMsg + "\"}");
                return;
            }
            req.setAttribute("loi", ambiguousMsg);
            req.setAttribute("phone", rawPhone);
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
            return;
        }

        // Chính sách hai cổng: chỉ kiểm tra SAU khi mật khẩu đã xác thực đúng,
        // để không tiết lộ role của tài khoản qua thông báo lỗi. Sai cổng → không tạo session.
        if (taiKhoan != null && !org.example.util.AuthPortalPolicy.isRoleAllowed(portal, taiKhoan.getRoleId())) {
            boolean accountIsInternal = org.example.util.AuthPortalPolicy.isInternalRole(taiKhoan.getRoleId());
            String accountPortal = accountIsInternal
                    ? org.example.util.AuthPortalPolicy.PORTAL_INTERNAL
                    : org.example.util.AuthPortalPolicy.PORTAL_CUSTOMER;
            String wrongPortalMsg = accountIsInternal
                    ? "Tài khoản này thuộc Cổng vận hành V-SPORT. Vui lòng đăng nhập tại Cổng dành cho Quản trị viên, Quản lý và Nhân viên."
                    : "Tài khoản này thuộc Cổng khách hàng V-SPORT. Vui lòng quay lại trang đăng nhập dành cho khách đặt sân.";
            String portalUrl = req.getContextPath()
                    + (accountIsInternal ? "/he-thong/dang-nhap" : "/dangnhap");
            LOGGER.warn("Login blocked - wrong portal: accountId={}, roleId={}, attemptedPortal={}",
                    taiKhoan.getAccountId(), taiKhoan.getRoleId(), portal);
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"code\": \"WRONG_PORTAL\", \"loi\": \""
                        + wrongPortalMsg + "\", \"portalUrl\": \"" + portalUrl + "\"}");
                return;
            }
            req.setAttribute("wrongPortal", accountPortal);
            req.setAttribute("wrongPortalMsg", wrongPortalMsg);
            req.setAttribute("username", usernameOrEmail);
            req.setAttribute("phone", rawPhone);
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
            return;
        }

        if (taiKhoan != null && taiKhoan.getCoSoId() != null
                && !facilityAccessService.isFacilityActive(taiKhoan.getCoSoId())) {
            LOGGER.warn("Login blocked - facility inactive: accountId={}, username={}, roleId={}, coSoId={}",
                    taiKhoan.getAccountId(), taiKhoan.getUsername(), taiKhoan.getRoleId(), taiKhoan.getCoSoId());
            String facilityInactiveMsg = "Cơ sở của tài khoản này đã ngừng hoạt động. Vui lòng liên hệ quản trị viên.";
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"code\": \"FACILITY_INACTIVE\", \"loi\": \""
                        + facilityInactiveMsg + "\"}");
                return;
            }
            req.setAttribute("loi", facilityInactiveMsg);
            req.setAttribute("username", usernameOrEmail);
            req.setAttribute("phone", rawPhone);
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
            return;
        }

        if (taiKhoan != null) {
            // Invalidate session cũ để tránh nhầm tài khoản khi đăng nhập liên tiếp
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("user", taiKhoan);
            session.setAttribute("roleId", taiKhoan.getRoleId());
            session.setAttribute("accountId", taiKhoan.getAccountId());
            session.setAttribute("fullName", taiKhoan.getFullName() != null ? taiKhoan.getFullName() : "");
            session.setAttribute("email", taiKhoan.getEmail() != null ? taiKhoan.getEmail() : "");

            String redirectUrl = req.getContextPath()
                    + org.example.util.RoleRedirectUtil.getHomePathByRoleId(taiKhoan.getRoleId());

            LOGGER.info("Login success: accountId={}, username={}, roleId={}, redirect={}",
                    taiKhoan.getAccountId(), taiKhoan.getUsername(),
                    taiKhoan.getRoleId(), redirectUrl);

            // Phản hồi kết quả đăng nhập thành công
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": true, \"redirectUrl\": \"" + redirectUrl + "\"}");
                return;
            }

            resp.sendRedirect(redirectUrl);

        } else {
            String wrongMsg = isPhoneLogin
                    ? "Số điện thoại hoặc mật khẩu không đúng."
                    : "Tên đăng nhập hoặc mật khẩu không đúng.";
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"" + wrongMsg + "\"}");
                return;
            }

            req.setAttribute("loi", wrongMsg);
            req.setAttribute("username", usernameOrEmail);
            req.setAttribute("phone", rawPhone);
            req.getRequestDispatcher(loginJspFor(portal)).forward(req, resp);
        }
    }

    private boolean isDatabaseConfigError(Throwable e) {
        Throwable current = e;
        while (current != null) {
            String msg = current.getMessage();
            if (msg != null) {
                if (msg.contains("DB_URL") ||
                    msg.contains("DB_USERNAME") ||
                    msg.contains("DB_PASSWORD") ||
                    msg.contains("Cấu hình bắt buộc bị thiếu") ||
                    msg.contains("Error initializing HikariCP data source")) {
                    return true;
                }
            }
            if (current instanceof IllegalStateException) {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }

    private boolean isDatabaseConnectionError(Throwable e) {
        Throwable current = e;
        while (current != null) {
            String msg = current.getMessage();
            if (msg != null) {
                if (msg.contains("Connection refused") ||
                    msg.contains("The TCP/IP connection") ||
                    msg.contains("Login failed") ||
                    msg.contains("HikariPool") ||
                    msg.contains("SQLServerException")) {
                    return true;
                }
            }
            current = current.getCause();
        }
        return false;
    }

    private String getDatabaseErrorMessage(Throwable t) {
        if (isDatabaseConfigError(t)) {
            return "Hệ thống chưa được cấu hình kết nối database. Vui lòng kiểm tra DB_URL, DB_USERNAME, DB_PASSWORD.";
        }
        if (isDatabaseConnectionError(t)) {
            return "Không thể kết nối database. Vui lòng kiểm tra SQL Server hoặc cấu hình kết nối.";
        }
        return "Lỗi kết nối cơ sở dữ liệu. Vui lòng liên hệ quản trị viên hoặc kiểm tra cấu hình hệ thống!";
    }
}

