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

@WebServlet("/dangnhap")
public class DangNhapServlet extends HttpServlet {

    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();

        if (session.getAttribute("user") != null) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            // Một form duy nhất cho tất cả roles – chuyển về trang chủ với modal đăng nhập
            resp.sendRedirect(req.getContextPath() + "/index.jsp?auth=login");
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

        TaiKhoan taiKhoan = TaiKhoanDAO.dangNhapKhachHang(usernameOrEmail, password);

        if (taiKhoan != null) {
            // Một cổng đăng nhập duy nhất cho tất cả roles (Admin, Quản lý, Khách hàng, ...)
            // Không phân biệt loginType – mọi tài khoản hợp lệ đều được chấp nhận.

            // Thiết lập phiên đăng nhập (Session) khi thông tin hợp lệ
            HttpSession session = req.getSession();
            session.setAttribute("user", taiKhoan);

            // Xác định đường dẫn điều hướng sau đăng nhập dựa vào Role ID
            String redirectUrl;
            if (taiKhoan.getRoleId() == 1) { // Admin
                redirectUrl = req.getContextPath() + "/admin/nhan-su";
            } else if (taiKhoan.getRoleId() == 2) { // Manager (Quản lý)
                redirectUrl = req.getContextPath() + "/manager/nhan-su";
            } else if (taiKhoan.getRoleId() == 4 || taiKhoan.getRoleId() == 5) { // Lễ tân & Bảo vệ (Staff)
                redirectUrl = req.getContextPath() + "/staff/dashboard";
            } else { // Khách hàng
                redirectUrl = req.getContextPath() + "/index.jsp";
            }

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
                resp.getWriter().write("{\"success\": false, \"loi\": \"Tên đăng nhập hoặc mật khẩu không chính xác!\"}");
                return;
            }

            req.setAttribute("loi", "Tên đăng nhập hoặc mật khẩu không chính xác!");
            req.setAttribute("username", usernameOrEmail);
            req.getRequestDispatcher("/auth/DangNhap.jsp").forward(req, resp);
        }
    }
}

