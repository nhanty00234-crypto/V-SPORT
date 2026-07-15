package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.EmailUtil;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.util.Random;
import java.util.Set;
import org.example.util.CloudinaryUtil;

@WebServlet({"/admin/update-profile", "/manager/update-profile", "/staff/update-profile", "/account/update-profile"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2 * 1024 * 1024,
        maxRequestSize = 3 * 1024 * 1024
)
public class UpdateProfileServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(UpdateProfileServlet.class);
    private static final long EMAIL_OTP_TTL_MS = 5 * 60 * 1000L;
    private static final Set<String> ALLOWED_AVATAR_TYPES = Set.of("image/jpeg", "image/png", "image/webp", "image/gif");
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
        if ("updateAvatar".equals(action)) {
            try {
                Part avatarPart = req.getPart("avatar");
                if (avatarPart == null || avatarPart.getSize() <= 0) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Vui lòng chọn ảnh đại diện.\"}");
                    return;
                }

                if (!ALLOWED_AVATAR_TYPES.contains(avatarPart.getContentType())) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Chỉ hỗ trợ ảnh JPG, PNG, WEBP hoặc GIF.\"}");
                    return;
                }

                TaiKhoan account = taiKhoanDAO.getAccountById(sessionUser.getAccountId());
                if (account == null) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy tài khoản trong hệ thống.\"}");
                    return;
                }

                String avatarUrl = CloudinaryUtil.uploadImage(avatarPart, "avatars");
                account.setAvatarUrl(avatarUrl);

                boolean success = taiKhoanDAO.updateAccount(account);
                if (success) {
                    session.setAttribute("user", account);
                    resp.getWriter().write("{\"success\":true,\"message\":\"Cập nhật ảnh đại diện thành công.\",\"avatarUrl\":\"" + json(avatarUrl) + "\"}");
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu ảnh đại diện vào cơ sở dữ liệu.\"}");
                }
            } catch (IllegalArgumentException e) {
                resp.getWriter().write("{\"success\":false,\"message\":\"" + json(e.getMessage()) + "\"}");
            } catch (Exception e) {
                logger.error("Lỗi cập nhật ảnh đại diện", e);
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + json(e.getMessage()) + "\"}");
            }

        } else if ("updateInfo".equals(action)) {
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
                    boolean emailChanged = account.getEmail() == null || !email.equalsIgnoreCase(account.getEmail());
                    if (emailChanged && taiKhoanDAO.kiemtraEmail(email)) {
                        resp.getWriter().write("{\"success\":false,\"message\":\"Email đã tồn tại trên hệ thống!\"}");
                        return;
                    }

                    if (emailChanged) {
                        String otp = generateOtp();
                        session.setAttribute("profileEmailOtp", otp);
                        session.setAttribute("profileEmailOtpTime", System.currentTimeMillis());
                        session.setAttribute("profilePendingFullName", fullName);
                        session.setAttribute("profilePendingEmail", email);
                        session.setAttribute("profilePendingPhone", phoneNumber);

                        final String targetEmail = email;
                        final String targetName = fullName;
                        new Thread(() -> {
                            try {
                                EmailUtil.sendEmail(
                                        targetEmail,
                                        "Xác thực thay đổi email V-SPORT",
                                        "Chào " + targetName + ",\n\n"
                                                + "Mã OTP xác thực thay đổi email của bạn là: " + otp + "\n"
                                                + "Mã có hiệu lực trong 5 phút. Nếu bạn không yêu cầu thao tác này, vui lòng bỏ qua email."
                                );
                            } catch (Exception e) {
                                logger.error("Lỗi gửi OTP đổi email đến {}: {}", targetEmail, e.getMessage(), e);
                            }
                        }).start();

                        resp.getWriter().write("{\"success\":true,\"requiresOtp\":true,\"message\":\"Mã OTP đã được gửi đến email mới. Vui lòng xác thực để hoàn tất thay đổi.\",\"email\":\"" + json(targetEmail) + "\"}");
                        return;
                    }

                    account.setFullName(fullName);
                    account.setPhoneNumber(phoneNumber);

                    boolean success = taiKhoanDAO.updateAccount(account);
                    if (success) {
                        session.setAttribute("user", account);
                        resp.getWriter().write(profileSuccessJson("Cập nhật hồ sơ cá nhân thành công.", account));
                    } else {
                        resp.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu thay đổi vào cơ sở dữ liệu.\"}");
                    }
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy tài khoản trong hệ thống.\"}");
                }
            } catch (Exception e) {
                logger.error("Lỗi khi cập nhật thông tin cá nhân", e);
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + json(e.getMessage()) + "\"}");
            }

        } else if ("verifyEmailOtp".equals(action)) {
            String otp = req.getParameter("otp");
            if (otp != null) otp = otp.trim();

            String sessionOtp = (String) session.getAttribute("profileEmailOtp");
            Long otpTime = (Long) session.getAttribute("profileEmailOtpTime");
            String fullName = (String) session.getAttribute("profilePendingFullName");
            String email = (String) session.getAttribute("profilePendingEmail");
            String phoneNumber = (String) session.getAttribute("profilePendingPhone");

            if (sessionOtp == null || otpTime == null || fullName == null || email == null || phoneNumber == null) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy yêu cầu đổi email đang chờ xác thực.\"}");
                return;
            }

            if (System.currentTimeMillis() - otpTime > EMAIL_OTP_TTL_MS) {
                clearProfileOtpSession(session);
                resp.getWriter().write("{\"success\":false,\"message\":\"Mã OTP đã hết hạn. Vui lòng lưu lại hồ sơ để nhận mã mới.\"}");
                return;
            }

            if (otp == null || !otp.equals(sessionOtp)) {
                resp.getWriter().write("{\"success\":false,\"message\":\"Mã OTP không chính xác.\"}");
                return;
            }

            try {
                TaiKhoan account = taiKhoanDAO.getAccountById(sessionUser.getAccountId());
                if (account == null) {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy tài khoản trong hệ thống.\"}");
                    return;
                }

                if (!email.equalsIgnoreCase(account.getEmail()) && taiKhoanDAO.kiemtraEmail(email)) {
                    clearProfileOtpSession(session);
                    resp.getWriter().write("{\"success\":false,\"message\":\"Email đã tồn tại trên hệ thống!\"}");
                    return;
                }

                account.setFullName(fullName);
                account.setEmail(email);
                account.setPhoneNumber(phoneNumber);

                boolean success = taiKhoanDAO.updateAccount(account);
                if (success) {
                    clearProfileOtpSession(session);
                    session.setAttribute("user", account);
                    resp.getWriter().write(profileSuccessJson("Cập nhật hồ sơ cá nhân thành công.", account));
                } else {
                    resp.getWriter().write("{\"success\":false,\"message\":\"Không thể lưu thay đổi vào cơ sở dữ liệu.\"}");
                }
            } catch (Exception e) {
                logger.error("Lỗi xác thực OTP đổi email", e);
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + json(e.getMessage()) + "\"}");
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
                resp.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống: " + json(e.getMessage()) + "\"}");
            }

        } else {
            resp.getWriter().write("{\"success\":false,\"message\":\"Hành động không hợp lệ.\"}");
        }
    }

    private String generateOtp() {
        return String.valueOf(new Random().nextInt(900000) + 100000);
    }

    private void clearProfileOtpSession(HttpSession session) {
        session.removeAttribute("profileEmailOtp");
        session.removeAttribute("profileEmailOtpTime");
        session.removeAttribute("profilePendingFullName");
        session.removeAttribute("profilePendingEmail");
        session.removeAttribute("profilePendingPhone");
    }

    private String profileSuccessJson(String message, TaiKhoan account) {
        return "{\"success\":true,\"message\":\"" + json(message) + "\","
                + "\"fullName\":\"" + json(account.getFullName()) + "\","
                + "\"email\":\"" + json(account.getEmail()) + "\","
                + "\"phoneNumber\":\"" + json(account.getPhoneNumber()) + "\","
                + "\"avatarUrl\":\"" + json(account.getAvatarUrl()) + "\"}";
    }

    // Phương thức saveAvatarFile đã được thay thế bằng CloudinaryUtil.uploadImage()



    private String json(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}
