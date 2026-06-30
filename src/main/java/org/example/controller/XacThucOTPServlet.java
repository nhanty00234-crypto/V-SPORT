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

import java.io.IOException;

@WebServlet({"/nhapma", "/resend-otp"})
public class XacThucOTPServlet extends HttpServlet {

    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/resend-otp".equals(path)) {
            handleResendOTP(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/resend-otp".equals(path)) {
            handleResendOTP(req, resp);
        } else {
            handleVerifyOTP(req, resp);
        }
    }

    private void handleVerifyOTP(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String userOtp = req.getParameter("otp");
        String sessionOtp = (String) session.getAttribute("otp");
        String authType = (String) session.getAttribute("authType"); // REGISTER, FORGOT_PASSWORD hoặc ADMIN_ADD
        String email = req.getParameter("email");
        req.setAttribute("email", email);

        String requestedWith = req.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith);

        Boolean needResend = (Boolean) session.getAttribute("needResend");
        boolean isAdminOrManagerFlow = "ADMIN_ADD".equals(authType) || "ADMIN_EDIT".equals(authType) || "MANAGER_EDIT".equals(authType);
        if (isAdminOrManagerFlow && needResend != null && needResend) {
            req.setAttribute("loi", "Bạn đã nhập sai 5 lần. Vui lòng nhấn 'Gửi lại ngay' để nhận mã OTP mới.");
            req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
            return;
        }

        if (sessionOtp == null || userOtp == null || !userOtp.equals(sessionOtp)) {
            if (isAdminOrManagerFlow) {
                Integer attempts = (Integer) session.getAttribute("otpAttempts");
                if (attempts == null) {
                    attempts = 0;
                }
                attempts++;
                session.setAttribute("otpAttempts", attempts);

                Integer resendCount = (Integer) session.getAttribute("resendCount");
                if (resendCount == null) {
                    resendCount = 0;
                }

                if (resendCount == 0) {
                    if (attempts >= 5) {
                        session.setAttribute("needResend", true);
                        session.removeAttribute("otp");
                        req.setAttribute("loi", "Bạn đã nhập sai 5 lần. Vui lòng nhấn 'Gửi lại ngay' để nhận mã OTP mới.");
                        req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
                        return;
                    } else {
                        req.setAttribute("loi", "Mã xác thực không chính xác. Bạn còn " + (5 - attempts) + " lần thử.");
                        req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
                        return;
                    }
                } else {
                    if (attempts >= 3) {
                        // Kick back to admin page with error
                        session.removeAttribute("otp");
                        session.removeAttribute("tempAccount");
                        session.removeAttribute("authType");
                        session.removeAttribute("otpAttempts");
                        session.removeAttribute("resendCount");
                        session.removeAttribute("needResend");
                        String errorMsg = ("ADMIN_EDIT".equals(authType) || "MANAGER_EDIT".equals(authType))
                            ? "Cập nhật tài khoản thất bại vì không nhập đúng OTP!"
                            : "Tạo tài khoản thất bại vì không nhập đúng OTP!";
                        session.setAttribute("error", errorMsg);
                        TaiKhoan loggedInUser = (TaiKhoan) session.getAttribute("user");
                        if (loggedInUser != null && loggedInUser.getRoleId() == 2) {
                            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                        } else {
                            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                        }
                        return;
                    } else {
                        req.setAttribute("loi", "Mã xác thực mới không chính xác. Bạn còn " + (3 - attempts) + " lần thử.");
                        req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
                        return;
                    }
                }
            } else {
                if (isAjax) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\": false, \"loi\": \"Mã xác thực không chính xác hoặc đã hết hạn.\"}");
                    return;
                }
                req.setAttribute("loi", "Mã xác thực không chính xác hoặc đã hết hạn.");
                req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
                return;
            }
        }

        // Xóa OTP và attempts sau khi dùng xong
        session.removeAttribute("otp");
        session.removeAttribute("otpAttempts");
        session.removeAttribute("resendCount");
        session.removeAttribute("needResend");

        if ("REGISTER".equals(authType) || "ADMIN_ADD".equals(authType) || "ADMIN_EDIT".equals(authType) || "MANAGER_EDIT".equals(authType)) {
            // Xử lý hoàn tất đăng ký hoặc admin thêm tài khoản
            TaiKhoan tempAccount = (TaiKhoan) session.getAttribute("tempAccount");
            String[] tempSports = (String[]) session.getAttribute("tempSports");

            if (tempAccount == null) {
                if ("ADMIN_ADD".equals(authType) || "ADMIN_EDIT".equals(authType)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                } else if ("MANAGER_EDIT".equals(authType)) {
                    resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                } else {
                    if (isAjax) {
                        resp.setContentType("application/json;charset=UTF-8");
                        resp.getWriter().write("{\"success\": false, \"loi\": \"Phiên làm việc đã hết hạn. Vui lòng đăng ký lại.\"}");
                        return;
                    }
                    resp.sendRedirect(req.getContextPath() + "/dangky");
                }
                return;
            }

            if ("ADMIN_ADD".equals(authType)) {
                // Double check email uniqueness right before adding
                if (tempAccount.getEmail() != null && !tempAccount.getEmail().trim().isEmpty()) {
                    if (TaiKhoanDAO.kiemtraEmail(tempAccount.getEmail().trim())) {
                        session.setAttribute("error", "Email đã tồn tại trên hệ thống!");
                        TaiKhoan loggedInUser = (TaiKhoan) session.getAttribute("user");
                        if (loggedInUser != null && loggedInUser.getRoleId() == 2) {
                            resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                        } else {
                            resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                        }
                        return;
                    }
                }

                // Admin thêm tài khoản trực tiếp sau khi xác thực thành công
                TaiKhoanDAO.addAccountByAdmin(tempAccount);

                session.removeAttribute("tempAccount");
                session.removeAttribute("tempSports");
                session.removeAttribute("authType");

                session.setAttribute("message", "Thêm tài khoản thành công!");
                TaiKhoan loggedInUser = (TaiKhoan) session.getAttribute("user");
                if (loggedInUser != null && loggedInUser.getRoleId() == 2) {
                    resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                }
            } else if ("ADMIN_EDIT".equals(authType) || "MANAGER_EDIT".equals(authType)) {
                // Double check email uniqueness right before updating
                if (tempAccount.getEmail() != null && !tempAccount.getEmail().trim().isEmpty()) {
                    TaiKhoan oldAcc = TaiKhoanDAO.getAccountById(tempAccount.getAccountId());
                    if (oldAcc != null && !tempAccount.getEmail().equalsIgnoreCase(oldAcc.getEmail())) {
                        if (TaiKhoanDAO.kiemtraEmail(tempAccount.getEmail().trim())) {
                            session.setAttribute("error", "Email đã tồn tại trên hệ thống!");
                            if ("MANAGER_EDIT".equals(authType)) {
                                resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                            } else {
                                resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                            }
                            return;
                        }
                    }
                }

                // Cập nhật tài khoản sau khi xác thực OTP thành công
                TaiKhoanDAO.updateAccount(tempAccount);

                session.removeAttribute("tempAccount");
                session.removeAttribute("tempSports");
                session.removeAttribute("authType");

                session.setAttribute("message", "Cập nhật thông tin tài khoản thành công!");
                if (isAjax) {
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"success\": true, \"message\": \"Cập nhật thông tin tài khoản thành công!\"}");
                    return;
                }
                if ("MANAGER_EDIT".equals(authType)) {
                    resp.sendRedirect(req.getContextPath() + "/manager/nhan-su");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                }
            } else {
                // Khách tự đăng ký
                if (tempAccount.getEmail() != null && !tempAccount.getEmail().trim().isEmpty()) {
                    if (TaiKhoanDAO.kiemtraEmail(tempAccount.getEmail().trim())) {
                        if (isAjax) {
                            resp.setContentType("application/json;charset=UTF-8");
                            resp.getWriter().write("{\"success\": false, \"loi\": \"Email đã tồn tại trên hệ thống!\"}");
                            return;
                        }
                        req.setAttribute("loi", "Email đã tồn tại trên hệ thống!");
                        req.getRequestDispatcher("/auth/DangKy.jsp").forward(req, resp);
                        return;
                    }
                }

                String ketQua = TaiKhoanDAO.dangKyKhachHang(
                    tempAccount,
                    tempSports
                );

                session.removeAttribute("tempAccount");
                session.removeAttribute("tempSports");
                session.removeAttribute("authType");

                if (ketQua.contains("thành công")) {
                    if (isAjax) {
                        resp.setContentType("application/json;charset=UTF-8");
                        resp.getWriter().write("{\"success\": true, \"step\": \"register-success\", \"thongbao\": \"Đăng ký thành công! Vui lòng đăng nhập với tài khoản của bạn.\"}");
                        return;
                    }
                    req.setAttribute("thongbao", "Đăng ký thành công! Vui lòng đăng nhập với tài khoản của bạn.");
                    req.setAttribute("username", tempAccount.getUsername());
                    req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
                } else {
                    if (isAjax) {
                        resp.setContentType("application/json;charset=UTF-8");
                        resp.getWriter().write("{\"success\": false, \"loi\": \"Lỗi hệ thống khi lưu tài khoản. Vui lòng thử lại!\"}");
                        return;
                    }
                    req.setAttribute("loi", "Lỗi hệ thống khi lưu tài khoản. Vui lòng thử lại!");
                    req.getRequestDispatcher("/auth/DangKy.jsp").forward(req, resp);
                }
            }

        } else if ("FORGOT_PASSWORD".equals(authType)) {
            // Xác thực thành công cho quên mật khẩu, chuyển sang trang nhập pass mới
            session.setAttribute("isVerified", true); // Đánh dấu đã xác thực OTP thành công
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": true, \"step\": \"reset-password\"}");
                return;
            }
            req.getRequestDispatcher("/auth/NhapMatKauMoi.jsp").forward(req, resp);
        }
    }

    private void handleResendOTP(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        String authType = (String) session.getAttribute("authType");
        
        String email = null;
        String fullName = "";
        
        if ("REGISTER".equals(authType) || "ADMIN_ADD".equals(authType) || "ADMIN_EDIT".equals(authType) || "MANAGER_EDIT".equals(authType)) {
            TaiKhoan tempAccount = (TaiKhoan) session.getAttribute("tempAccount");
            if (tempAccount != null) {
                email = tempAccount.getEmail();
                fullName = tempAccount.getFullName();
            }
        } else if ("FORGOT_PASSWORD".equals(authType)) {
            email = (String) session.getAttribute("resetEmail"); 
            fullName = "Quý khách";
        }
        
        String requestedWith = req.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith);

        if (email == null || email.trim().isEmpty()) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Không tìm thấy thông tin email để gửi lại OTP. Vui lòng thực hiện lại.\"}");
                return;
            }
            req.setAttribute("loi", "Không tìm thấy thông tin email để gửi lại OTP. Vui lòng thực hiện lại.");
            req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
            return;
        }
        
        // Gửi OTP mới
        String otpString = "";
        if ("FORGOT_PASSWORD".equals(authType)) {
            otpString = TaiKhoanDAO.sendForgotPasswordOTP(email);
        } else {
            otpString = TaiKhoanDAO.sendRegistrationOTP(email, fullName);
        }
        
        session.setAttribute("otp", otpString);
        session.setAttribute("otpAttempts", 0); // Reset số lần thử khi gửi lại mã mới
        
        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\": true, \"thongbao\": \"Mã OTP mới đã được gửi thành công đến email của bạn.\"}");
            return;
        }

        req.setAttribute("email", email);
        req.setAttribute("thongbao", "Mã OTP mới đã được gửi thành công đến email của bạn.");
        req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
    }
}

