package org.example.controller.guard;

import org.example.dao.SuCoDAO;
import org.example.dao.impl.SuCoDAOImpl;
import org.example.model.SuCo;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/guard/lich-su-su-co")
public class GuardLichSuSuCoServlet extends HttpServlet {

    private final SuCoDAO suCoDAO = new SuCoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_BAO_VE) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String filter = req.getParameter("trangThai");
        List<SuCo> danhSach = suCoDAO.getByBaoVe(user.getAccountId(), 50);

        req.setAttribute("danhSachSuCo", danhSach);
        req.setAttribute("filterTrangThai", filter);
        req.getRequestDispatcher("/guard/LichSuSuCo.jsp").forward(req, resp);
    }
}
