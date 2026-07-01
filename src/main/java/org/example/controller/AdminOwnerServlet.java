package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.util.DBUtil;
import org.example.util.EmailUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;

@WebServlet("/admin/quan-ly-owner")
public class AdminOwnerServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(AdminOwnerServlet.class);
    private final CoSoDAOImpl coSoDAO = new CoSoDAOImpl();
    private final TaiKhoanDAOImpl taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan admin = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (admin == null || admin.getRoleId() != 1) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return;
        }

        String action = req.getParameter("action");
        if (action != null) {
            handleAction(req, resp, action, admin);
            return;
        }

        loadPageData(req, resp);
    }

    private void handleAction(HttpServletRequest req, HttpServletResponse resp, String action, TaiKhoan admin) throws IOException {
        int coSoId = 0;
        try { coSoId = Integer.parseInt(req.getParameter("id")); } catch (Exception e) {
            req.getSession().setAttribute("error", "ID không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/quan-ly-owner");
            return;
        }

        CoSo coSo = coSoDAO.getCoSoById(coSoId);
        if (coSo == null) {
            req.getSession().setAttribute("error", "Không tìm thấy cơ sở.");
            resp.sendRedirect(req.getContextPath() + "/admin/quan-ly-owner");
            return;
        }

        switch (action) {
            case "duyet":
                if ("Chờ duyệt".equals(coSo.getTrangThai())) {
                    coSo.setTrangThai("Đang hoạt động");
                    coSoDAO.updateCoSo(coSo);
                    syncCourts(coSoId, coSo.getLoaiHinhKinhDoanh(), coSo.getSoLuongSanDuKien());
                    if (coSo.getAccountID_QuanLy() != null) {
                        unlockAndNotify(coSo.getAccountID_QuanLy());
                    }
                    req.getSession().setAttribute("message", "Đã duyệt cơ sở \"" + coSo.getTenCoSo() + "\" và kích hoạt tài khoản quản lý.");
                } else {
                    req.getSession().setAttribute("error", "Cơ sở này không ở trạng thái chờ duyệt.");
                }
                break;

            case "tu-choi":
                if ("Chờ duyệt".equals(coSo.getTrangThai())) {
                    coSo.setTrangThai("Từ chối");
                    coSoDAO.updateCoSo(coSo);
                    req.getSession().setAttribute("message", "Đã từ chối đăng ký cơ sở \"" + coSo.getTenCoSo() + "\".");
                } else {
                    req.getSession().setAttribute("error", "Chỉ có thể từ chối cơ sở đang chờ duyệt.");
                }
                break;

            case "khoa":
                if (coSo.getAccountID_QuanLy() != null) {
                    TaiKhoan mgr = taiKhoanDAO.getAccountById(coSo.getAccountID_QuanLy());
                    if (mgr != null) {
                        mgr.setIsLocked(true);
                        taiKhoanDAO.updateAccount(mgr);
                        req.getSession().setAttribute("message", "Đã khóa tài khoản owner \"" + mgr.getFullName() + "\".");
                    }
                }
                break;

            case "mo-khoa":
                if (coSo.getAccountID_QuanLy() != null) {
                    TaiKhoan mgr = taiKhoanDAO.getAccountById(coSo.getAccountID_QuanLy());
                    if (mgr != null) {
                        mgr.setIsLocked(false);
                        taiKhoanDAO.updateAccount(mgr);
                        req.getSession().setAttribute("message", "Đã mở khóa tài khoản owner \"" + mgr.getFullName() + "\".");
                    }
                }
                break;

            default:
                req.getSession().setAttribute("error", "Hành động không hợp lệ.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/quan-ly-owner");
    }

    private void loadPageData(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<CoSo> allBranches = coSoDAO.getAllCoSo();
        List<TaiKhoan> allAccounts = taiKhoanDAO.getAllAccounts();

        // Map accountId -> TaiKhoan for quick lookup
        Map<Integer, TaiKhoan> accountMap = new HashMap<>();
        for (TaiKhoan tk : allAccounts) {
            accountMap.put(tk.getAccountId(), tk);
        }

        List<Map<String, Object>> pending  = new ArrayList<>();
        List<Map<String, Object>> approved = new ArrayList<>();
        List<Map<String, Object>> rejected = new ArrayList<>();

        for (CoSo cs : allBranches) {
            // Only process branches that came from owner registration (have a linked manager)
            if (cs.getAccountID_QuanLy() == null) continue;
            TaiKhoan mgr = accountMap.get(cs.getAccountID_QuanLy());
            if (mgr == null) continue;

            Map<String, Object> row = new HashMap<>();
            row.put("coSo", cs);
            row.put("manager", mgr);

            switch (cs.getTrangThai()) {
                case "Chờ duyệt": pending.add(row); break;
                case "Đang hoạt động": approved.add(row); break;
                case "Từ chối": rejected.add(row); break;
            }
        }

        req.setAttribute("pending",  pending);
        req.setAttribute("approved", approved);
        req.setAttribute("rejected", rejected);
        req.getRequestDispatcher("/admin/QuanLyOwner.jsp").forward(req, resp);
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private void unlockAndNotify(int accountId) {
        TaiKhoan mgr = taiKhoanDAO.getAccountById(accountId);
        if (mgr == null) return;
        mgr.setIsLocked(false);
        taiKhoanDAO.updateAccount(mgr);
        final String email   = mgr.getEmail();
        final String name    = mgr.getFullName();
        new Thread(() -> {
            try {
                EmailUtil.sendEmail(email,
                    "Tài khoản đối tác V-SPORT đã được phê duyệt",
                    "Chào " + name + ",\n\n" +
                    "Cơ sở thể thao của bạn đã được quản trị viên phê duyệt thành công.\n" +
                    "Bạn có thể đăng nhập tại: http://localhost:8080/Backend_java\n" +
                    "  - Email: " + email + "\n" +
                    "  - Mật khẩu mặc định: 123456\n\n" +
                    "Vui lòng đổi mật khẩu sau khi đăng nhập lần đầu.\n\nTrân trọng,\nBan quản trị V-SPORT");
            } catch (Exception e) {
                logger.error("Lỗi gửi email phê duyệt tới {}", email, e);
            }
        }).start();
    }

    private void syncCourts(int coSoId, String loaiHinh, int total) {
        if (loaiHinh == null || loaiHinh.isBlank() || total <= 0) return;
        String[] sports = Arrays.stream(loaiHinh.split(",")).map(String::trim).toArray(String[]::new);
        Map<String, Integer> sportCounts = new LinkedHashMap<>();
        int base = total / sports.length, rem = total % sports.length;
        for (int i = 0; i < sports.length; i++) sportCounts.put(sports[i], base + (i < rem ? 1 : 0));

        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null) return;
            Map<String, Integer> sportTypeMap = new HashMap<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT m.TenMon, l.LoaiSanID FROM LoaiSan l JOIN MonTheThao m ON l.MonTheThaoID = m.MonTheThaoID");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) sportTypeMap.put(rs.getNString(1), rs.getInt(2));
            }
            int defaultType = 1;
            try (PreparedStatement ps = conn.prepareStatement("SELECT TOP 1 LoaiSanID FROM LoaiSan");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) defaultType = rs.getInt(1);
            }
            for (Map.Entry<String, Integer> e : sportCounts.entrySet()) {
                String sport = e.getKey(); int expected = e.getValue();
                int typeId = sportTypeMap.getOrDefault(sport, defaultType);
                List<Integer> existing = new ArrayList<>();
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT s.SanID FROM San s JOIN LoaiSan l ON s.LoaiSanID=l.LoaiSanID " +
                        "JOIN MonTheThao m ON l.MonTheThaoID=m.MonTheThaoID WHERE s.CoSoID=? AND m.TenMon=? ORDER BY s.SanID")) {
                    ps.setInt(1, coSoId); ps.setNString(2, sport);
                    try (ResultSet rs = ps.executeQuery()) { while (rs.next()) existing.add(rs.getInt(1)); }
                }
                int cur = existing.size();
                if (cur < expected) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO San(TenSan,LoaiSanID,CoSoID,TrangThai,MoTa,HinhAnh) VALUES(?,?,?,?,?,?)")) {
                        for (int i = cur; i < expected; i++) {
                            int idx = i + 1;
                            ps.setNString(1, sport + " " + (idx < 10 ? "0" + idx : idx));
                            ps.setInt(2, typeId); ps.setInt(3, coSoId);
                            ps.setNString(4, "Sẵn sàng"); ps.setNString(5, ""); ps.setNString(6, "");
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
            }
        } catch (Exception ex) {
            logger.error("syncCourts error coSoId={}", coSoId, ex);
        }
    }
}
