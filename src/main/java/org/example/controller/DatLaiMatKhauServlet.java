package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;

import java.io.IOException;

@WebServlet("/nhapmatkhaumoi")
public class DatLaiMatKhauServlet extends HttpServlet {

    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        if (session.getAttribute("isVerified") == null) {
            resp.sendRedirect(req.getContextPath() + "/quenmatkhau");
            return;
        }
        req.getRequestDispatcher("/auth/NhapMatKauMoi.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        
        String requestedWith = req.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith);

        // Bảo mật: Kiểm tra xem đã qua bước OTP chưa
        if (session.getAttribute("isVerified") == null) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Yêu cầu không hợp lệ. Vui lòng xác thực OTP trước.\"}");
                return;
            }
            resp.sendRedirect(req.getContextPath() + "/quenmatkhau");
            return;
        }

        String email = (String) session.getAttribute("resetEmail");
        String newPassword = req.getParameter("password");
        String confirmPassword = req.getParameter("confirm_password");

        if (newPassword != null) newPassword = newPassword.trim();
        if (confirmPassword != null) confirmPassword = confirmPassword.trim();

        // Validate password is not empty or just spaces
        if (newPassword == null || newPassword.isEmpty()) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!\"}");
                return;
            }
            req.setAttribute("loi", "Mật khẩu không được để trống hoặc chỉ chứa khoảng trắng!");
            req.getRequestDispatcher("/auth/NhapMatKauMoi.jsp").forward(req, resp);
            return;
        }

        if (!org.example.util.ValidationUtil.isStrongPassword(newPassword)) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Mật khẩu phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt.\"}");
                return;
            }
            req.setAttribute("loi", "Mật khẩu phải có tối thiểu 8 ký tự, bao gồm cả chữ hoa, chữ thường, số và ký tự đặc biệt.");
            req.getRequestDispatcher("/auth/NhapMatKauMoi.jsp").forward(req, resp);
            return;
        }

        // Optional: Reject passwords with spaces if required by business logic. Usually, spaces are allowed in passphrases, 
        // but trimming leading/trailing is good practice, or ensuring it's not ONLY spaces (handled above).
        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Mật khẩu xác nhận không khớp!\"}");
                return;
            }
            req.setAttribute("loi", "Mật khẩu xác nhận không khớp!");
            req.getRequestDispatcher("/auth/NhapMatKauMoi.jsp").forward(req, resp);
            return;
        }

        boolean success = TaiKhoanDAO.capNhatMatKhau(email, newPassword);

        if (success) {
            session.removeAttribute("isVerified");
            session.removeAttribute("resetEmail");
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": true, \"thongbao\": \"Đổi mật khẩu thành công! Vui lòng đăng nhập lại.\"}");
                return;
            }
            req.setAttribute("msg", "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.");
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
        } else {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Có lỗi xảy ra, vui lòng thử lại sau.\"}");
                return;
            }
            req.setAttribute("loi", "Có lỗi xảy ra, vui lòng thử lại sau.");
            req.getRequestDispatcher("/auth/NhapMatKauMoi.jsp").forward(req, resp);
        }
    }
}

