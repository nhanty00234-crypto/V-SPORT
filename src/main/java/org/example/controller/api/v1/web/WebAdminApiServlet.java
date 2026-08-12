package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Session-based REST endpoints cho Next.js Admin panel.
 *
 * GET /api/v1/web/admin/dashboard — thống kê toàn hệ thống
 */
@WebServlet("/api/v1/web/admin/*")
public class WebAdminApiServlet extends HttpServlet {

    private final TaiKhoanDAOImpl taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CoSoDAOImpl coSoDAO = new CoSoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireAdmin(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        switch (path) {
            case "/dashboard":
                handleDashboard(resp);
                break;
            default:
                resp.setStatus(404);
                resp.getWriter().write("{\"error\":\"Not found\"}");
        }
    }

    private void handleDashboard(HttpServletResponse resp) throws IOException {
        try {
            List<TaiKhoan> allAccounts = taiKhoanDAO.getAllAccounts();
            List<CoSo> allBranches = coSoDAO.getAllCoSo();

            long totalAccounts  = allAccounts.size();
            long totalOwners    = allAccounts.stream().filter(a -> a.getRoleId() == 6).count();
            long totalManagers  = allAccounts.stream().filter(a -> a.getRoleId() == 2).count();
            long totalStaff     = allAccounts.stream().filter(a -> a.getRoleId() == 4 || a.getRoleId() == 5).count();
            long totalCustomers = allAccounts.stream().filter(a -> a.getRoleId() == 3).count();
            long totalBranches  = allBranches.size();
            long activeBranches = allBranches.stream().filter(b -> "Đang hoạt động".equals(b.getTrangThai())).count();

            List<TaiKhoan> recentAccounts = allAccounts.stream()
                .sorted(Comparator.comparingInt(TaiKhoan::getAccountId).reversed())
                .limit(5)
                .collect(Collectors.toList());

            StringBuilder sb = new StringBuilder("{");
            sb.append("\"totalAccounts\":").append(totalAccounts).append(",");
            sb.append("\"totalOwners\":").append(totalOwners).append(",");
            sb.append("\"totalManagers\":").append(totalManagers).append(",");
            sb.append("\"totalStaff\":").append(totalStaff).append(",");
            sb.append("\"totalCustomers\":").append(totalCustomers).append(",");
            sb.append("\"totalBranches\":").append(totalBranches).append(",");
            sb.append("\"activeBranches\":").append(activeBranches).append(",");
            sb.append("\"recentAccounts\":[");
            for (int i = 0; i < recentAccounts.size(); i++) {
                TaiKhoan a = recentAccounts.get(i);
                if (i > 0) sb.append(",");
                sb.append("{");
                sb.append("\"id\":").append(a.getAccountId()).append(",");
                sb.append("\"fullName\":\"").append(escape(a.getFullName() != null ? a.getFullName() : a.getUsername())).append("\",");
                sb.append("\"email\":\"").append(escape(a.getEmail() != null ? a.getEmail() : "")).append("\",");
                sb.append("\"roleId\":").append(a.getRoleId());
                sb.append("}");
            }
            sb.append("]}");

            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500);
            resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private TaiKhoan requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return null;
        }
        if (user.getRoleId() != Constants.ROLE_ADMIN) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"Không có quyền truy cập\"}");
            return null;
        }
        return user;
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
