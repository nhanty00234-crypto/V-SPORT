package org.example.controller.api.v1.web;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.*;
import org.example.dao.impl.*;
import org.example.model.*;
import org.example.util.Constants;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Session-based REST endpoints cho Next.js Admin panel.
 * GET /api/v1/web/admin/dashboard
 * GET /api/v1/web/admin/chi-nhanh    — all branches with stats
 * GET /api/v1/web/admin/owner        — all owner accounts
 * GET /api/v1/web/admin/nhan-su      — all user accounts
 * GET /api/v1/web/admin/hoa-don      — all invoices
 * GET /api/v1/web/admin/lich-dat-san — all bookings
 * GET /api/v1/web/admin/audit-log    — global audit log
 * GET /api/v1/web/admin/thung-rac    — deleted items
 */
@WebServlet("/api/v1/web/admin/*")
public class WebAdminApiServlet extends HttpServlet {

    private final TaiKhoanDAOImpl taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CoSoDAOImpl coSoDAO = new CoSoDAOImpl();
    private final HoaDonDAO hoaDonDAO = new HoaDonDAOImpl();
    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();
    private final AuditLogDAO auditLogDAO = new AuditLogDAOImpl();
    private final SanDAO sanDAO = new SanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        TaiKhoan user = requireAdmin(req, resp);
        if (user == null) return;

        String path = req.getPathInfo();
        if (path == null) path = "/";

        resp.setContentType("application/json;charset=UTF-8");
        switch (path) {
            case "/dashboard":    handleDashboard(resp); break;
            case "/chi-nhanh":   handleChiNhanh(resp); break;
            case "/owner":       handleOwner(resp); break;
            case "/nhan-su":     handleNhanSu(resp); break;
            case "/hoa-don":     handleHoaDon(resp); break;
            case "/lich-dat-san": handleLichDatSan(resp); break;
            case "/audit-log":   handleAuditLog(req, resp); break;
            case "/thung-rac":   handleThungRac(resp); break;
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
                .limit(5).collect(Collectors.toList());

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
                sb.append("{\"id\":").append(a.getAccountId())
                  .append(",\"fullName\":\"").append(escape(a.getFullName() != null ? a.getFullName() : a.getUsername())).append("\"")
                  .append(",\"email\":\"").append(escape(a.getEmail() != null ? a.getEmail() : "")).append("\"")
                  .append(",\"roleId\":").append(a.getRoleId())
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleChiNhanh(HttpServletResponse resp) throws IOException {
        try {
            List<CoSo> list = coSoDAO.getAllCoSoIncludingPending();
            StringBuilder sb = new StringBuilder("{\"branches\":[");
            for (int i = 0; i < list.size(); i++) {
                CoSo c = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(c.getCoSoID())
                  .append(",\"ten\":\"").append(escape(c.getTenCoSo())).append("\"")
                  .append(",\"diaChi\":\"").append(escape(c.getDiaChi())).append("\"")
                  .append(",\"soDienThoai\":\"").append(escape(c.getSoDienThoai())).append("\"")
                  .append(",\"trangThai\":\"").append(escape(c.getTrangThai())).append("\"")
                  .append(",\"soLuongSan\":").append(c.getSoLuongSanDuKien())
                  .append(",\"loaiHinh\":\"").append(escape(c.getLoaiHinhKinhDoanh())).append("\"")
                  .append(",\"accountIdQuanLy\":").append(c.getAccountID_QuanLy() != null ? c.getAccountID_QuanLy() : 0)
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleOwner(HttpServletResponse resp) throws IOException {
        try {
            List<TaiKhoan> all = taiKhoanDAO.getAllAccounts();
            List<TaiKhoan> owners = all.stream().filter(a -> a.getRoleId() == 6).collect(Collectors.toList());
            writeAccountList(resp, owners);
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleNhanSu(HttpServletResponse resp) throws IOException {
        try {
            List<TaiKhoan> all = taiKhoanDAO.getAllAccounts();
            writeAccountList(resp, all);
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void writeAccountList(HttpServletResponse resp, List<TaiKhoan> list) throws IOException {
        StringBuilder sb = new StringBuilder("{\"accounts\":[");
        for (int i = 0; i < list.size(); i++) {
            TaiKhoan a = list.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"id\":").append(a.getAccountId())
              .append(",\"username\":\"").append(escape(a.getUsername())).append("\"")
              .append(",\"fullName\":\"").append(escape(a.getFullName() != null ? a.getFullName() : "")).append("\"")
              .append(",\"email\":\"").append(escape(a.getEmail() != null ? a.getEmail() : "")).append("\"")
              .append(",\"phone\":\"").append(escape(a.getPhoneNumber() != null ? a.getPhoneNumber() : "")).append("\"")
              .append(",\"roleId\":").append(a.getRoleId())
              .append(",\"coSoId\":").append(a.getCoSoId() != null ? a.getCoSoId() : 0)
              .append("}");
        }
        sb.append("]}");
        resp.getWriter().write(sb.toString());
    }

    private void handleHoaDon(HttpServletResponse resp) throws IOException {
        try {
            List<HoaDon> list = hoaDonDAO.getAllHoaDon();
            BigDecimal total = hoaDonDAO.getTotalDoanhThu();
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"totalRevenue\":").append(total != null ? total.longValue() : 0).append(",");
            sb.append("\"invoices\":[");
            int max = Math.min(list.size(), 200);
            for (int i = 0; i < max; i++) {
                HoaDon h = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(h.getHoaDonId())
                  .append(",\"datSanId\":").append(h.getDatSanId())
                  .append(",\"accountId\":").append(h.getAccountIdKhachHang())
                  .append(",\"total\":").append((long) h.getTongThanhToan())
                  .append(",\"status\":\"").append(escape(h.getTrangThaiThanhToan())).append("\"")
                  .append(",\"date\":\"").append(h.getNgayLap() != null ? h.getNgayLap().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleLichDatSan(HttpServletResponse resp) throws IOException {
        try {
            List<Lichdatsan> list = lichDatSanDAO.getAllLichDatSan();
            StringBuilder sb = new StringBuilder("{\"bookings\":[");
            int max = Math.min(list.size(), 200);
            for (int i = 0; i < max; i++) {
                Lichdatsan l = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(l.getDatSanId())
                  .append(",\"accountId\":").append(l.getAccountId())
                  .append(",\"sanId\":").append(l.getSanId())
                  .append(",\"ngayDat\":\"").append(l.getNgayDat() != null ? l.getNgayDat().toString() : "").append("\"")
                  .append(",\"gioBatDau\":\"").append(l.getGioBatDau() != null ? l.getGioBatDau().toString() : "").append("\"")
                  .append(",\"gioKetThuc\":\"").append(l.getGioKetThuc() != null ? l.getGioKetThuc().toString() : "").append("\"")
                  .append(",\"tongTien\":").append(l.getTongTienDuKien() != null ? l.getTongTienDuKien() : 0)
                  .append(",\"trangThai\":\"").append(escape(l.getTrangThai())).append("\"");
                if (l.getAccount() != null) {
                    sb.append(",\"tenKhach\":\"").append(escape(l.getAccount().getFullName())).append("\"");
                } else {
                    sb.append(",\"tenKhach\":\"\"");
                }
                if (l.getSan() != null) {
                    sb.append(",\"tenSan\":\"").append(escape(l.getSan().getTenSan())).append("\"");
                } else {
                    sb.append(",\"tenSan\":\"\"");
                }
                sb.append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleAuditLog(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            String pageStr = req.getParameter("page");
            int page = pageStr != null ? Integer.parseInt(pageStr) : 1;
            List<AuditLog> list = auditLogDAO.findAll(page, 50);
            StringBuilder sb = new StringBuilder("{\"logs\":[");
            for (int i = 0; i < list.size(); i++) {
                AuditLog a = list.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(a.getAuditLogId())
                  .append(",\"actorName\":\"").append(escape(a.getActorName())).append("\"")
                  .append(",\"actorRole\":").append(a.getActorRole())
                  .append(",\"action\":\"").append(escape(a.getAction())).append("\"")
                  .append(",\"entityType\":\"").append(escape(a.getEntityType())).append("\"")
                  .append(",\"entityName\":\"").append(escape(a.getEntityName())).append("\"")
                  .append(",\"details\":\"").append(escape(a.getDetails())).append("\"")
                  .append(",\"ipAddress\":\"").append(escape(a.getIpAddress())).append("\"")
                  .append(",\"coSoId\":").append(a.getCoSoId() != null ? a.getCoSoId() : 0)
                  .append(",\"createdAt\":\"").append(a.getCreatedAt() != null ? a.getCreatedAt().toString() : "").append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    private void handleThungRac(HttpServletResponse resp) throws IOException {
        try {
            List<TaiKhoan> deletedAccounts = taiKhoanDAO.getDeletedAccounts();
            List<CoSo> deletedBranches = coSoDAO.findDeleted();
            StringBuilder sb = new StringBuilder("{");
            sb.append("\"accounts\":[");
            for (int i = 0; i < deletedAccounts.size(); i++) {
                TaiKhoan a = deletedAccounts.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(a.getAccountId())
                  .append(",\"fullName\":\"").append(escape(a.getFullName() != null ? a.getFullName() : "")).append("\"")
                  .append(",\"email\":\"").append(escape(a.getEmail() != null ? a.getEmail() : "")).append("\"")
                  .append(",\"roleId\":").append(a.getRoleId())
                  .append("}");
            }
            sb.append("],\"branches\":[");
            for (int i = 0; i < deletedBranches.size(); i++) {
                CoSo c = deletedBranches.get(i);
                if (i > 0) sb.append(",");
                sb.append("{\"id\":").append(c.getCoSoID())
                  .append(",\"ten\":\"").append(escape(c.getTenCoSo())).append("\"")
                  .append(",\"trangThai\":\"").append(escape(c.getTrangThai())).append("\"")
                  .append("}");
            }
            sb.append("]}");
            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            resp.setStatus(500); resp.getWriter().write("{\"error\":\"" + escape(e.getMessage()) + "\"}");
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
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}
