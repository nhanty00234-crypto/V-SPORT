package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/admin/tong-quan")
public class AdminDashboardServlet extends HttpServlet {

    private final TaiKhoanDAOImpl taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CoSoDAOImpl coSoDAO = new CoSoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;

        if (user == null || user.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        List<TaiKhoan> allAccounts = taiKhoanDAO.getAllAccounts();
        List<CoSo> allBranches = coSoDAO.getAllCoSo();

        long totalOwners   = allAccounts.stream().filter(a -> a.getRoleId() == 6).count();
        long totalManagers = allAccounts.stream().filter(a -> a.getRoleId() == 2).count();
        long totalStaff    = allAccounts.stream().filter(a -> a.getRoleId() == 4 || a.getRoleId() == 5).count();
        long totalCustomers = allAccounts.stream().filter(a -> a.getRoleId() == 3).count();

        long activeBranches = allBranches.stream().filter(b -> "Đang hoạt động".equals(b.getTrangThai())).count();

        // 5 tài khoản mới nhất
        List<TaiKhoan> recentAccounts = allAccounts.stream()
                .sorted((a, b) -> Integer.compare(b.getAccountId(), a.getAccountId()))
                .limit(5)
                .collect(Collectors.toList());

        req.setAttribute("totalAccounts", allAccounts.size());
        req.setAttribute("totalOwners", totalOwners);
        req.setAttribute("totalManagers", totalManagers);
        req.setAttribute("totalStaff", totalStaff);
        req.setAttribute("totalCustomers", totalCustomers);
        req.setAttribute("totalBranches", allBranches.size());
        req.setAttribute("activeBranches", activeBranches);
        req.setAttribute("recentAccounts", recentAccounts);
        req.setAttribute("allBranches", allBranches);

        req.getRequestDispatcher("/admin/TongQuan.jsp").forward(req, resp);
    }
}
