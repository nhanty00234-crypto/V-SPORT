package org.example.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.CoSoDAO;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.util.DBUtil;
import org.example.util.EmailUtil;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = { "/admin/chi-nhanh", "/admin/chi-nhanh/them", "/admin/chi-nhanh/sua",
        "/admin/chi-nhanh/xoa" })
public class QuanLyChiNhanhServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(QuanLyChiNhanhServlet.class);
    private CoSoDAO chiNhanhDAO = new CoSoDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        if (path.equals("/admin/chi-nhanh")) {
            String action = req.getParameter("action");
            if ("duyet".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CoSo chiNhanh = chiNhanhDAO.getCoSoById(id);
                if (chiNhanh != null && "Chờ duyệt".equals(chiNhanh.getTrangThai())) {
                    chiNhanh.setTrangThai("Đang hoạt động");
                    chiNhanhDAO.updateCoSo(chiNhanh);
                    
                    // Sync courts for branch on approval
                    String loaiHinh = chiNhanh.getLoaiHinhKinhDoanh();
                    int total = chiNhanh.getSoLuongSanDuKien();
                    Map<String, Integer> sportCounts = new HashMap<>();
                    if (loaiHinh != null && !loaiHinh.trim().isEmpty() && total > 0) {
                        String[] sports = loaiHinh.split(",");
                        for (int i = 0; i < sports.length; i++) {
                            sports[i] = sports[i].trim();
                        }
                        int base = total / sports.length;
                        int remainder = total % sports.length;
                        for (int i = 0; i < sports.length; i++) {
                            int count = base + (i < remainder ? 1 : 0);
                            sportCounts.put(sports[i], count);
                        }
                    }
                    syncCourtsForBranch(id, sportCounts);

                    if (chiNhanh.getAccountID_QuanLy() != null) {
                        unlockManagerAccount(chiNhanh.getAccountID_QuanLy());
                    }
                    req.getSession().setAttribute("message", "Duyệt cơ sở thành công và tài khoản quản lý đã được kích hoạt!");
                } else {
                    req.getSession().setAttribute("error", "Không thể phê duyệt cơ sở này hoặc cơ sở đã được duyệt trước đó.");
                }
                String from = req.getParameter("from");
                if ("nhan-su".equals(from)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/chi-nhanh");
                }
                return;
            } else if ("khong-duyet".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                CoSo chiNhanh = chiNhanhDAO.getCoSoById(id);
                if (chiNhanh != null && "Chờ duyệt".equals(chiNhanh.getTrangThai())) {
                    chiNhanh.setTrangThai("Từ chối");
                    chiNhanhDAO.updateCoSo(chiNhanh);
                    req.getSession().setAttribute("message", "Đã từ chối duyệt cơ sở.");
                } else {
                    req.getSession().setAttribute("error", "Thao tác từ chối không hợp lệ.");
                }
                String from = req.getParameter("from");
                if ("nhan-su".equals(from)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/chi-nhanh");
                }
                return;
            }

            List<CoSo> dsChiNhanh = chiNhanhDAO.getAllCoSo();
            req.setAttribute("dsChiNhanh", dsChiNhanh);
            req.getRequestDispatcher("/admin/QuanLyChiNhanh.jsp").forward(req, resp);
        } else if (path.equals("/admin/chi-nhanh/sua")) {
            int id = Integer.parseInt(req.getParameter("id"));
            CoSo chiNhanh = chiNhanhDAO.getCoSoById(id);

            int countBongDa = 0;
            int countCauLong = 0;
            int countTennis = 0;
            int countPickleball = 0;

            try (Connection conn = DBUtil.getConnection()) {
                if (conn != null) {
                    String sql = "SELECT m.TenMon, COUNT(s.SanID) " +
                            "FROM San s " +
                            "JOIN LoaiSan l ON s.LoaiSanID = l.LoaiSanID " +
                            "JOIN MonTheThao m ON l.MonTheThaoID = m.MonTheThaoID " +
                            "WHERE s.CoSoID = ? " +
                            "GROUP BY m.TenMon";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, id);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                String tenMon = rs.getNString(1);
                                int count = rs.getInt(2);
                                if ("Bóng đá".equals(tenMon))
                                    countBongDa = count;
                                else if ("Cầu lông".equals(tenMon))
                                    countCauLong = count;
                                else if ("Tennis".equals(tenMon))
                                    countTennis = count;
                                else if ("Pickleball".equals(tenMon))
                                    countPickleball = count;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                logger.error("Lỗi khi tải dữ liệu chi nhánh", e);
            }

            req.setAttribute("chiNhanh", chiNhanh);
            req.setAttribute("countBongDa", countBongDa);
            req.setAttribute("countCauLong", countCauLong);
            req.setAttribute("countTennis", countTennis);
            req.setAttribute("countPickleball", countPickleball);

            req.getRequestDispatcher("/admin/SuaChiNhanh.jsp").forward(req, resp);
        } else if (path.equals("/admin/chi-nhanh/xoa")) {
            int id = Integer.parseInt(req.getParameter("id"));
            if (chiNhanhDAO.deleteCoSo(id)) {
                req.getSession().setAttribute("message", "Xóa cơ sở và toàn bộ tài khoản nhân sự liên quan thành công!");
            } else {
                req.getSession().setAttribute("error", "Lỗi khi xóa cơ sở!");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/chi-nhanh");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        String tenCoSo = req.getParameter("tenCoSo");
        String diaChi = req.getParameter("diaChi");
        String soDienThoai = req.getParameter("soDienThoai");
        String trangThai = req.getParameter("trangThai");

        String gioMoStr = req.getParameter("gioMoCua");
        String gioDongStr = req.getParameter("gioDongCua");
        LocalTime gioMo = (gioMoStr != null && !gioMoStr.isEmpty()) ? LocalTime.parse(gioMoStr) : LocalTime.of(8, 0);
        LocalTime gioDong = (gioDongStr != null && !gioDongStr.isEmpty()) ? LocalTime.parse(gioDongStr)
                : LocalTime.of(22, 0);

        String moTa = req.getParameter("moTa");

        // Xử lý nhiều môn thể thao từ checkbox
        String[] loaiHinhArray = req.getParameterValues("loaiHinhKinhDoanh");
        String loaiHinh = (loaiHinhArray != null) ? String.join(", ", loaiHinhArray) : "";

        Map<String, Integer> sportCounts = new HashMap<>();
        int totalCourts = 0;
        if (loaiHinhArray != null) {
            for (String sport : loaiHinhArray) {
                String paramName = "";
                if ("Bóng đá".equals(sport))
                    paramName = "soLuongSan_BongDa";
                else if ("Cầu lông".equals(sport))
                    paramName = "soLuongSan_CauLong";
                else if ("Tennis".equals(sport))
                    paramName = "soLuongSan_Tennis";
                else if ("Pickleball".equals(sport))
                    paramName = "soLuongSan_Pickleball";

                String valStr = req.getParameter(paramName);
                int count = (valStr != null && !valStr.isEmpty()) ? Integer.parseInt(valStr) : 1;
                sportCounts.put(sport, count);
                totalCourts += count;
            }
        }

        CoSo chiNhanh = new CoSo();
        chiNhanh.setTenCoSo(tenCoSo);
        chiNhanh.setDiaChi(diaChi);
        chiNhanh.setSoDienThoai(soDienThoai);
        chiNhanh.setTrangThai(trangThai);
        chiNhanh.setGioMoCua(gioMo);
        chiNhanh.setGioDongCua(gioDong);
        chiNhanh.setMoTa(moTa);
        chiNhanh.setLoaiHinhKinhDoanh(loaiHinh);
        chiNhanh.setSoLuongSanDuKien(totalCourts);

        if (path.equals("/admin/chi-nhanh/them")) {
            chiNhanhDAO.addCoSo(chiNhanh);
            // Dynamic court synchronization for new branch
            syncCourtsForBranch(chiNhanh.getCoSoID(), sportCounts);
        } else if (path.equals("/admin/chi-nhanh/sua")) {
            int id = Integer.parseInt(req.getParameter("id"));
            chiNhanh.setCoSoID(id);
            chiNhanhDAO.updateCoSo(chiNhanh);
            // Dynamic court synchronization for edited branch
            syncCourtsForBranch(id, sportCounts);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/chi-nhanh");
    }

    private void syncCourtsForBranch(int coSoId, Map<String, Integer> sportCounts) {
        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null)
                return;

            // 1. Get mapping of Sport Name -> LoaiSanID
            Map<String, Integer> sportToTypeMap = new HashMap<>();
            String queryTypesSql = "SELECT m.TenMon, l.LoaiSanID FROM LoaiSan l JOIN MonTheThao m ON l.MonTheThaoID = m.MonTheThaoID ORDER BY CASE WHEN l.CoSoID = ? THEN 1 ELSE 0 END ASC";
            try (PreparedStatement ps = conn.prepareStatement(queryTypesSql)) {
                ps.setInt(1, coSoId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        sportToTypeMap.put(rs.getNString("TenMon"), rs.getInt("LoaiSanID"));
                    }
                }
            }

            // Get fallback default type (first type available in database)
            int defaultType = 1;
            try (PreparedStatement ps = conn.prepareStatement("SELECT TOP 1 LoaiSanID FROM LoaiSan");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    defaultType = rs.getInt(1);
                }
            }

            // Loop over all possible sports
            String[] allSports = { "Bóng đá", "Cầu lông", "Tennis", "Pickleball" };
            for (String sport : allSports) {
                int expectedCount = sportCounts.getOrDefault(sport, 0);
                Integer typeId = sportToTypeMap.get(sport);
                if (typeId == null) {
                    typeId = defaultType;
                }

                // Get existing courts for this sport at this branch
                List<Integer> existingSanIds = new ArrayList<>();
                String querySanSql = "SELECT s.SanID FROM San s " +
                        "JOIN LoaiSan l ON s.LoaiSanID = l.LoaiSanID " +
                        "JOIN MonTheThao m ON l.MonTheThaoID = m.MonTheThaoID " +
                        "WHERE s.CoSoID = ? AND m.TenMon = ? " +
                        "ORDER BY s.SanID ASC";
                try (PreparedStatement ps = conn.prepareStatement(querySanSql)) {
                    ps.setInt(1, coSoId);
                    ps.setNString(2, sport);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            existingSanIds.add(rs.getInt(1));
                        }
                    }
                }

                int currentCount = existingSanIds.size();

                if (currentCount < expectedCount) {
                    // Insert missing courts
                    int toAdd = expectedCount - currentCount;
                    String insertSql = "INSERT INTO San (TenSan, LoaiSanID, CoSoID, TrangThai, MoTa, HinhAnh) VALUES (?, ?, ?, ?, ?, ?)";
                    try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                        for (int i = 0; i < toAdd; i++) {
                            int courtIndex = currentCount + i + 1;
                            String courtName = sport + " " + (courtIndex < 10 ? "0" + courtIndex : courtIndex); // E.g.,
                                                                                                                // "Bóng
                                                                                                                // đá
                                                                                                                // 01"
                            ps.setNString(1, courtName);
                            ps.setInt(2, typeId);
                            ps.setInt(3, coSoId);
                            ps.setNString(4, "Sẵn sàng");
                            ps.setNString(5, "Sân thi đấu tự động tạo cho Cơ Sở.");
                            ps.setNString(6, "");
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                } else if (currentCount > expectedCount) {
                    // Delete excess courts
                    int toDelete = currentCount - expectedCount;
                    String deleteSql = "DELETE FROM San WHERE SanID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                        for (int i = 0; i < toDelete; i++) {
                            int sanIdToDelete = existingSanIds.get(existingSanIds.size() - 1 - i);

                            // Delete bookings
                            try (PreparedStatement psDelBook = conn
                                    .prepareStatement("DELETE FROM LichDatSan WHERE SanID = ?")) {
                                psDelBook.setInt(1, sanIdToDelete);
                                psDelBook.executeUpdate();
                            }

                            ps.setInt(1, sanIdToDelete);
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }
            }
        } catch (Exception e) {
            logger.error("Lỗi khi xử lý thao tác chi nhánh", e);
        }
    }

    private void deleteCourtsForBranch(int coSoId) {
        try (Connection conn = DBUtil.getConnection()) {
            if (conn == null)
                return;

            // Delete associated bookings
            String delBookSql = "DELETE FROM LichDatSan WHERE SanID IN (SELECT SanID FROM San WHERE CoSoID = ?)";
            try (PreparedStatement ps = conn.prepareStatement(delBookSql)) {
                ps.setInt(1, coSoId);
                ps.executeUpdate();
            }

            // Delete courts
            String delSanSql = "DELETE FROM San WHERE CoSoID = ?";
            try (PreparedStatement ps = conn.prepareStatement(delSanSql)) {
                ps.setInt(1, coSoId);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            logger.error("Lỗi khi xóa sân cho cơ sở ID " + coSoId, e);
        }
    }

    private void unlockManagerAccount(int accountId) {
        TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
        TaiKhoan managerAcc = taiKhoanDAO.getAccountById(accountId);
        if (managerAcc != null && managerAcc.getRoleId() == 2) {
            managerAcc.setIsLocked(false);
            taiKhoanDAO.updateAccount(managerAcc);

            // Send notification email
            new Thread(() -> {
                try {
                    EmailUtil.sendEmail(
                        managerAcc.getEmail(),
                        "Tài khoản đối tác V-SPORT đã được phê duyệt",
                        "Chào " + managerAcc.getFullName() + ",\n\n" +
                        "Cơ sở thể thao của bạn đã được quản trị viên phê duyệt thành công.\n" +
                        "Bạn hiện có thể đăng nhập vào hệ thống quản lý V-SPORT bằng tài khoản sau:\n" +
                        "- Tên đăng nhập (Email): " + managerAcc.getEmail() + "\n" +
                        "- Mật khẩu mặc định: 123456\n\n" +
                        "Vui lòng đổi mật khẩu sau khi đăng nhập lần đầu tiên để bảo mật tài khoản.\n\n" +
                        "Trân trọng,\nBan quản trị V-SPORT"
                    );
                } catch (Exception e) {
                    TaiKhoan account = null;
                    logger.error("Lỗi gửi email phê duyệt đến {}", account.getEmail(), e);
                }
            }).start();
        }
    }
}
