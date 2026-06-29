package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;

@WebServlet({"/admin/update-profile", "/manager/update-profile"})
public class UpdateProfileServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(UpdateProfileServlet.class);
    private TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession();
        TaiKhoan sessionUser = (TaiKhoan) session.getAttribute("user");

        if (sessionUser == null) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.\"}");
            return;
        }

        String action = req.getParameter("action");
        if ("updateInfo".equals(action)) {
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phoneNumber = req.getParameter("phoneNumber");

            if (fullName != null) fullName = fullName.trim();
            if (email != null) email = email.trim();
            if (phoneNumber != null) phoneNumber = phoneNumber.trim();

            if (fullName == null || fullName.isEmpty() ||
                email == null || email.isEmpty() ||
                phoneNumber == null || phoneNumber.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng điền đầy đủ thông tin!\"}");
                return;
            }

            if (!org.example.util.ValidationUtil.isValidEmail(email)) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Email không hợp lệ và không được chứa khoảng trắng!\"}");
                return;
            }

            if (!org.example.util.ValidationUtil.isValidVNPhone(phoneNumber)) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Số điện thoại không hợp lệ!\"}");
                return;
            }

            try {
                TaiKhoan account = taiKhoanDAO.getAccountById(sessionUser.getAccountId());
                if (account != null) {
                    if (!email.equalsIgnoreCase(account.getEmail()) && taiKhoanDAO.kiemtraEmail(email)) {
                        resp.getWriter().write("{\"success\":false,\"message\":\"Email đã tồn tại trên hệ thống!\"}");
                        return;
                    }
                    account.setFullName(fullName);
                    account.setEmail(email);
                    account.setPhoneNumber(phoneNumber);

                    boolean success = taiKhoanDAO.updateAccount(account);
                    if (success) {
                        session.setAttribute("user", account);
                        resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật hồ sơ cá nhân thành công.\"}");
                    } else {
                        resp.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu thay đổi vào cơ sở dữ liệu.\"}");
                    }
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy tài khoản trong hệ thống.\"}");
                }
            } catch (Exception e) {
                logger.error("Lỗi khi cập nhật thông tin cá nhân", e);
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
            }

        } else if ("changePassword".equals(action)) {
            String currentPassword = req.getParameter("currentPassword");
            String newPassword = req.getParameter("newPassword");

            if (currentPassword != null) currentPassword = currentPassword.trim();
            if (newPassword != null) newPassword = newPassword.trim();

            if (currentPassword == null || currentPassword.isEmpty() ||
                newPassword == null || newPassword.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!\"}");
                return;
            }

            if (!org.example.util.ValidationUtil.isStrongPassword(newPassword)) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu mới phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt.\"}");
                return;
            }

            try {
                TaiKhoan account = taiKhoanDAO.getAccountById(sessionUser.getAccountId());
                if (account != null) {
                    if (!BCrypt.checkpw(currentPassword, account.getPassword())) {
                        resp.getWriter().write("{\"success\":false,\"message\":\"Mật khẩu hiện tại không chính xác!\"}");
                        return;
                    }

                    String hashedNewPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt(12));
                    account.setPassword(hashedNewPassword);

                    boolean success = taiKhoanDAO.updateAccount(account);
                    if (success) {
                        session.setAttribute("user", account);
                        resp.getWriter().write("{\"success\":true,\"message\":\"Đổi mật khẩu tài khoản thành công.\"}");
                    } else {
                        resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi cập nhật mật khẩu mới.\"}");
                    }
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy tài khoản trong hệ thống.\"}");
                }
            } catch (Exception e) {
                logger.error("Lỗi khi đổi mật khẩu", e);
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + e.getMessage() + "\"}");
            }

        } else {
            resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không hợp lệ.\"}");
        }
    }
}
