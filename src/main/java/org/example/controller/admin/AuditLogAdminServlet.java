package org.example.controller.admin;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.impl.AuditLogDAOImpl;
import org.example.model.AuditLog;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/audit-log")
public class AuditLogAdminServlet extends HttpServlet {
    private final AuditLogDAOImpl auditLogDAO = new AuditLogDAOImpl();
    private static final int PAGE_SIZE = 30;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || user.getRoleId() != Constants.ROLE_ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String entityType = req.getParameter("entityType");
        String action     = req.getParameter("action");
        String dateFrom   = req.getParameter("dateFrom");
        String dateTo     = req.getParameter("dateTo");
        int page = 1;
        try { page = Integer.parseInt(req.getParameter("page")); } catch (Exception ignored) {}
        if (page < 1) page = 1;

        List<AuditLog> logs = auditLogDAO.findWithFilters(
                null, entityType, action, dateFrom, dateTo, page, PAGE_SIZE);
        long total = auditLogDAO.countWithFilters(null, entityType, action, dateFrom, dateTo);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);

        req.setAttribute("logs", logs);
        req.setAttribute("total", total);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("entityType", entityType);
        req.setAttribute("action", action);
        req.setAttribute("dateFrom", dateFrom);
        req.setAttribute("dateTo", dateTo);

        req.getRequestDispatcher("/admin/AuditLog.jsp").forward(req, resp);
    }
}
