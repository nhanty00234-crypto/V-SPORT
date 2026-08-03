package org.example.controller.guard;

import org.example.dao.CaLamViecDAO;
import org.example.dao.impl.CaLamViecDAOImpl;
import org.example.model.CaLamViec;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/guard/diem-danh")
public class GuardDiemDanhServlet extends HttpServlet {

    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        CaLamViec caHomNay = caLamViecDAO.getCaHomNay(user.getAccountId(), LocalDate.now());
        List<CaLamViec> lichSu = caLamViecDAO.getCaByAccountIDAndDateRange(
                user.getAccountId(),
                LocalDate.now().minusDays(7),
                LocalDate.now().minusDays(1));

        req.setAttribute("caHomNay", caHomNay);
        req.setAttribute("lichSuCa", lichSu);
        req.setAttribute("guardPage", "diem-danh");
        req.getRequestDispatcher("/guard/DiemDanh.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan user = getUser(req, resp);
        if (user == null) return;

        String action = req.getParameter("action");
        String caIdStr = req.getParameter("caLamViecId");
        if (caIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/guard/diem-danh?error=missing_id");
            return;
        }

        int caId = Integer.parseInt(caIdStr);
        boolean ok;
        if ("checkin".equals(action)) {
            ok = caLamViecDAO.checkInCa(caId);
            req.getSession().setAttribute("flashSuccess", ok ? "Đã vào ca thành công!" : "Không thể vào ca lúc này.");
        } else if ("checkout".equals(action)) {
            ok = caLamViecDAO.checkOutCa(caId);
            req.getSession().setAttribute("flashSuccess", ok ? "Đã kết thúc ca!" : "Không thể kết thúc ca lúc này.");
        }

        resp.sendRedirect(req.getContextPath() + "/guard/diem-danh");
    }

    private TaiKhoan getUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_BAO_VE) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
