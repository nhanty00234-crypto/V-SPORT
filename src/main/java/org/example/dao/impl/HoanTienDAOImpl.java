package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.HoanTienDAO;
import org.example.model.Hoantien;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HoanTienDAOImpl implements HoanTienDAO {

    private static final Logger logger = LogManager.getLogger(HoanTienDAOImpl.class);

    private static final String INSERT_SQL =
        "INSERT INTO HoanTien (HoaDonID, AccountID, SoTienHoan, LyDo, TrangThai, ThoiGianYeuCau, " +
        "NganHangNhan, SoTaiKhoanNhan, ChuTaiKhoanNhan) VALUES (?, ?, ?, ?, ?, GETDATE(), ?, ?, ?)";

    @Override
    public int insert(Hoantien ht) {
        try (Connection conn = DBUtil.getConnection()) {
            return insert(conn, ht);
        } catch (SQLException e) {
            logger.error("insert HoanTien: {}", e.getMessage(), e);
            return 0;
        }
    }

    @Override
    public int insert(Connection conn, Hoantien ht) {
        try (PreparedStatement ps = conn.prepareStatement(INSERT_SQL, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ht.getHoaDonId());
            ps.setInt(2, ht.getAccountId());
            ps.setBigDecimal(3, ht.getSoTienHoan());
            ps.setNString(4, truncate(ht.getLyDo(), 255));
            ps.setNString(5, ht.getTrangThai() != null ? ht.getTrangThai() : "Chờ xử lý");
            ps.setNString(6, truncate(ht.getNganHangNhan(), 100));
            ps.setNString(7, truncate(ht.getSoTaiKhoanNhan(), 30));
            ps.setNString(8, truncate(ht.getChuTaiKhoanNhan(), 100));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert HoanTien (conn): {}", e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public Hoantien findById(int hoanTienId) {
        String sql = "SELECT ht.*, hd.DatSanID FROM HoanTien ht " +
                     "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
                     "WHERE ht.HoanTienID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoanTienId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findById HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public boolean existsByHoaDonId(int hoaDonId) {
        String sql = "SELECT 1 FROM HoanTien WHERE HoaDonID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hoaDonId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.error("existsByHoaDonId HoaDonID={}: {}", hoaDonId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<Hoantien> findByCoSoId(int coSoId, int page, int pageSize) {
        List<Hoantien> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql =
            "SELECT ht.*, hd.DatSanID FROM HoanTien ht " +
            "JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "JOIN LichDatSan lds ON hd.DatSanID = lds.DatSanID " +
            "JOIN San s ON lds.SanID = s.SanID " +
            "WHERE s.CoSoID = ? " +
            "ORDER BY ht.ThoiGianYeuCau DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Hoantien> findByAccountId(int accountId, int page, int pageSize) {
        List<Hoantien> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql =
            "SELECT ht.*, hd.DatSanID FROM HoanTien ht " +
            "LEFT JOIN HoaDon hd ON ht.HoaDonID = hd.HoaDonID " +
            "WHERE ht.AccountID = ? " +
            "ORDER BY ht.ThoiGianYeuCau DESC " +
            "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByAccountId accountId={}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public boolean updateTrangThai(int hoanTienId, String trangThaiMoi,
                                    int accountIdNguoiXuLy, String ghiChuXuLy,
                                    String maGiaoDichHoan) {
        // Kiểm tra chuyển trạng thái hợp lệ theo state machine
        String allowedSource = switch (trangThaiMoi) {
            case "Đã duyệt", "Từ chối" -> "Chờ xử lý";
            case "Đã hoàn tiền" -> "Đã duyệt";
            default -> null;
        };
        if (allowedSource == null) {
            logger.warn("updateTrangThai: trạng thái không hợp lệ '{}'", trangThaiMoi);
            return false;
        }

        String sql =
            "UPDATE HoanTien SET TrangThai = ?, AccountID_NguoiXuLy = ?, " +
            "GhiChuXuLy = ?, MaGiaoDichHoan = ?, ThoiGianXuLy = GETDATE() " +
            (trangThaiMoi.equals("Đã hoàn tiền") ? ", ThoiGianHoan = GETDATE() " : "") +
            "WHERE HoanTienID = ? AND TrangThai = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, trangThaiMoi);
            ps.setInt(2, accountIdNguoiXuLy);
            ps.setNString(3, truncate(ghiChuXuLy, 500));
            ps.setString(4, truncate(maGiaoDichHoan, 100));
            ps.setInt(5, hoanTienId);
            ps.setNString(6, allowedSource);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateTrangThai HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateBankInfo(int hoanTienId, int accountId,
                                   String nganHangNhan, String soTaiKhoanNhan, String chuTaiKhoanNhan) {
        String sql =
            "UPDATE HoanTien SET NganHangNhan = ?, SoTaiKhoanNhan = ?, ChuTaiKhoanNhan = ? " +
            "WHERE HoanTienID = ? AND AccountID = ? AND TrangThai = N'Chờ xử lý'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, truncate(nganHangNhan, 100));
            ps.setNString(2, truncate(soTaiKhoanNhan, 30));
            ps.setNString(3, truncate(chuTaiKhoanNhan, 100));
            ps.setInt(4, hoanTienId);
            ps.setInt(5, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateBankInfo HoanTienID={}: {}", hoanTienId, e.getMessage(), e);
            return false;
        }
    }

    private Hoantien map(ResultSet rs) throws SQLException {
        Hoantien ht = new Hoantien();
        ht.setHoanTienId(rs.getInt("HoanTienID"));
        ht.setHoaDonId(rs.getInt("HoaDonID"));
        ht.setAccountId(rs.getInt("AccountID"));
        BigDecimal st = rs.getBigDecimal("SoTienHoan");
        ht.setSoTienHoan(st != null ? st : BigDecimal.ZERO);
        ht.setLyDo(rs.getString("LyDo"));
        ht.setTrangThai(rs.getString("TrangThai"));
        ht.setThoiGianYeuCau(rs.getTimestamp("ThoiGianYeuCau"));
        ht.setThoiGianHoan(rs.getTimestamp("ThoiGianHoan"));

        int xuLy = rs.getInt("AccountID_NguoiXuLy");
        if (!rs.wasNull()) ht.setAccountIdNguoiXuLy(xuLy);
        ht.setGhiChuXuLy(rs.getString("GhiChuXuLy"));
        ht.setMaGiaoDichHoan(rs.getString("MaGiaoDichHoan"));
        ht.setThoiGianXuLy(rs.getTimestamp("ThoiGianXuLy"));
        ht.setNganHangNhan(rs.getString("NganHangNhan"));
        ht.setSoTaiKhoanNhan(rs.getString("SoTaiKhoanNhan"));
        ht.setChuTaiKhoanNhan(rs.getString("ChuTaiKhoanNhan"));
        return ht;
    }

    private String truncate(String s, int max) {
        if (s == null) return null;
        s = s.trim();
        return s.length() > max ? s.substring(0, max) : s;
    }
}
