package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;

@WebServlet("/staff/yeu-cau-qr")
public class YeuCauQRServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || (user.getRoleId() != Constants.ROLE_MANAGER && user.getRoleId() != Constants.ROLE_LE_TAN)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        req.getRequestDispatcher("/staff/YeuCauQR.jsp").forward(req, resp);
    }
}
