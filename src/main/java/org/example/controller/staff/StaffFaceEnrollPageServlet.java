package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import java.io.IOException;

@WebServlet("/staff/enroll-face")
public class StaffFaceEnrollPageServlet extends HttpServlet {
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_LE_TAN) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap"); return;
        }
        TaiKhoan faceData = taiKhoanDAO.getFaceData(user.getAccountId());
        req.setAttribute("faceData", faceData);
        req.getRequestDispatcher("/staff/FaceEnroll.jsp").forward(req, resp);
    }
}
