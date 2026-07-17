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

@WebServlet("/dangnhap")
public class DangNhapServlet extends HttpServlet {

    private static final Logger LOGGER = LogManager.getLogger(DangNhapServlet.class);
    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();
    private final FacilityAccessService facilityAccessService = new FacilityAccessService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Phòng ngừa link logout sai trỏ về đây
        if ("logout".equals(req.getParameter("action"))) {
            resp.sendRedirect(req.getContextPath() + "/logout");
            return;
        }

        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            String redirectUrl = req.getContextPath()
                    + org.example.util.RoleRedirectUtil.getHomePathByRoleId(user.getRoleId());
            resp.sendRedirect(redirectUrl);
        } else if ("true".equals(req.getParameter("facilityInactive"))) {
            // ActiveFacilityFilter vừa invalidate session vì cơ sở của tài khoản đã ngừng hoạt động.
            req.setAttribute("loi", "Cơ sở của tài khoản này đã ngừng hoạt động. Vui lòng liên hệ quản trị viên.");
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
        } else {
            // Trang đăng nhập toàn màn hình (thay cho modal auth trên trang chủ).
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String usernameOrEmail = req.getParameter("username");
        String password = req.getParameter("password");

        String requestedWith = req.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith);

        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty() ||
                password == null || password.trim().isEmpty()) {

            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Tài khoản và mật khẩu không được để trống!\"}");
                return;
            }

            req.setAttribute("loi", "Tài khoản và mật khẩu không được để trống!");
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
            return;
        }

        TaiKhoan taiKhoan = null;
        String dbErrorMsg = null;
        try {
            taiKhoan = TaiKhoanDAO.dangNhapKhachHang(usernameOrEmail, password);
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
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
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
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
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
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Tên đăng nhập hoặc mật khẩu không đúng.\"}");
                return;
            }

            req.setAttribute("loi", "Tên đăng nhập hoặc mật khẩu không đúng.");
            req.setAttribute("username", usernameOrEmail);
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
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

