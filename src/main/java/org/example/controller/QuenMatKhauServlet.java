package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;

import java.io.IOException;

@WebServlet("/quenmatkhau")
public class QuenMatKhauServlet extends HttpServlet {

    private TaiKhoanDAO TaiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("resend".equals(action)) {
            String email = req.getParameter("email");
            if (email != null && !email.isEmpty()) {
                String otp = TaiKhoanDAO.sendForgotPasswordOTP(email);
                req.getSession().setAttribute("otp", otp);
                req.setAttribute("msg", "Mã OTP đã được gửi lại!");
                req.setAttribute("email", email);
                req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
                return;
            }
        }
        req.getRequestDispatcher("/auth/QuenMatKhau.jsp").forward(req, resp);
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String requestedWith = req.getHeader("X-Requested-With");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith);

        if (!TaiKhoanDAO.kiemtraEmail(email)) {
            if (isAjax) {
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"success\": false, \"loi\": \"Email không tồn tại trong hệ thống!\"}");
                return;
            }
            req.setAttribute("loi", "Email không tồn tại trong hệ thống!");
            req.setAttribute("oldEmail", email);
            req.getRequestDispatcher("/auth/QuenMatKhau.jsp").forward(req, resp);
            return;
        }

        String otpString = TaiKhoanDAO.sendForgotPasswordOTP(email);
        
        req.getSession().setAttribute("otp", otpString);
        req.getSession().setAttribute("authType", "FORGOT_PASSWORD");
        req.getSession().setAttribute("resetEmail", email);
        
        if (isAjax) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"success\": true, \"email\": \"" + email + "\"}");
            return;
        }
        
        req.setAttribute("email", email);
        req.getRequestDispatcher("/auth/NhapMa.jsp").forward(req, resp);
    }
}

