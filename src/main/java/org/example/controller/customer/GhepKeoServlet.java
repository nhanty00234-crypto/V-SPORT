package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CoSoDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.RoleRedirectUtil;

import java.io.IOException;

/**
 * Trang "Ghép kèo" cho Customer (mục 5, 6 spec redesign). Hiện tại chỉ hiển thị
 * UI placeholder (tab Kèo đang mở / Tạo kèo / Tìm đối thủ gần nhất / Kèo của tôi) với
 * empty state - CHƯA có backend ghép kèo/matching thật (entity GhepKeo/ChiTietGhepKeo/LichSuElo
 * đã tồn tại trong model nhưng logic nghiệp vụ nằm ngoài phạm vi redesign UI này).
 */
@WebServlet("/customer/ghep-keo")
public class GhepKeoServlet extends HttpServlet {

    private final CoSoDAO coSoDAO = new CoSoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan sessionUser = session != null ? (TaiKhoan) session.getAttribute("user") : null;

        if (sessionUser == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        if (sessionUser.getRoleId() != RoleRedirectUtil.ROLE_CUSTOMER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Trang này chỉ dành cho tài khoản Khách hàng.");
            return;
        }

        String tab = req.getParameter("tab");
        req.setAttribute("initialTab", tab != null ? tab : "dang-mo");
        req.setAttribute("dsCoSo", coSoDAO.getAllCoSo());

        req.getRequestDispatcher("/customer/GhepKeo.jsp").forward(req, resp);
    }
}
