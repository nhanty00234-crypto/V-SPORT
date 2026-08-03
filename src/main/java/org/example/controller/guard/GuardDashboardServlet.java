package org.example.controller.guard;

import org.example.dao.CaLamViecDAO;
import org.example.dao.SuCoDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.dao.impl.SuCoDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/guard/dashboard")
public class GuardDashboardServlet extends HttpServlet {

    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final SuCoDAO suCoDAO = new SuCoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_BAO_VE) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        CaLamViec caHomNay = caLamViecDAO.getCaHomNay(user.getAccountId(), LocalDate.now());
        int suCoHomNay = suCoDAO.countTodayByBaoVe(user.getAccountId());

        req.setAttribute("caHomNay", caHomNay);
        req.setAttribute("suCoHomNay", suCoHomNay);
        req.setAttribute("guardPage", "dashboard");
        req.getRequestDispatcher("/guard/Dashboard.jsp").forward(req, resp);
    }
}
