package org.example.dao.impl;

import org.example.dao.BangLuongDAO;
import org.example.model.BangLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BangLuongDAOImpl implements BangLuongDAO {

    @Override
    public void upsert(BangLuong bl) throws Exception {
        // Tính lại kỳ đã tính trước đó phải ghi đè, không nhân bản dòng — khoá bởi
        // UNIQUE(KyLuongID, AccountID).
        String sql = "MERGE BangLuong AS t " +
                "USING (SELECT ? AS KyLuongID, ? AS AccountID) AS s " +
                "  ON t.KyLuongID = s.KyLuongID AND t.AccountID = s.AccountID " +
                "WHEN MATCHED THEN UPDATE SET " +
                "  LuongCoBan = ?, TongPhuCap = ?, TongKhauTru = ?, TongLuongThuc = ?, " +
                "  SoCaLamViec = ?, TrangThai = ?, GhiChu = ? " +
                "WHEN NOT MATCHED THEN INSERT " +
                "  (KyLuongID, AccountID, LuongCoBan, TongPhuCap, TongKhauTru, TongLuongThuc, SoCaLamViec, TrangThai, GhiChu) " +
                "  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, bl.getKyLuongId());
            ps.setInt(2, bl.getAccountId());
            ps.setBigDecimal(3, nz(bl.getLuongCoBan()));
            ps.setBigDecimal(4, nz(bl.getTongPhuCap()));
            ps.setBigDecimal(5, nz(bl.getTongKhauTru()));
            ps.setBigDecimal(6, nz(bl.getTongLuongThuc()));
            ps.setInt(7, bl.getSoCaLamViec());
            ps.setString(8, bl.getTrangThai());
            ps.setNString(9, bl.getGhiChu());
            ps.setInt(10, bl.getKyLuongId());
            ps.setInt(11, bl.getAccountId());
            ps.setBigDecimal(12, nz(bl.getLuongCoBan()));
            ps.setBigDecimal(13, nz(bl.getTongPhuCap()));
            ps.setBigDecimal(14, nz(bl.getTongKhauTru()));
            ps.setBigDecimal(15, nz(bl.getTongLuongThuc()));
            ps.setInt(16, bl.getSoCaLamViec());
            ps.setString(17, bl.getTrangThai());
            ps.setNString(18, bl.getGhiChu());
            ps.executeUpdate();
        }
    }

    @Override
    public List<BangLuong> listByKy(int kyLuongId) throws Exception {
        String sql = "SELECT b.*, a.FullName, a.AvatarUrl, a.MaNganHang, a.SoTaiKhoan, a.QrImagePath " +
                "FROM BangLuong b JOIN Accounts a ON a.AccountID = b.AccountID " +
                "WHERE b.KyLuongID = ? ORDER BY a.FullName";
        List<BangLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, kyLuongId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(mapWithAccount(rs));
            }
        }
        return out;
    }

    @Override
    public BangLuong findById(int bangLuongId, int coSoId) throws Exception {
        // JOIN KyLuong để chắc chắn dòng lương này thuộc cơ sở của manager đang đăng nhập.
        String sql = "SELECT b.*, a.FullName, a.AvatarUrl, a.MaNganHang, a.SoTaiKhoan, a.QrImagePath " +
                "FROM BangLuong b " +
                "JOIN KyLuong k ON k.KyLuongID = b.KyLuongID " +
                "JOIN Accounts a ON a.AccountID = b.AccountID " +
                "WHERE b.BangLuongID = ? AND k.CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, bangLuongId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapWithAccount(rs) : null;
            }
        }
    }

    @Override
    public void updateTrangThai(int bangLuongId, String trangThai) throws Exception {
        String sql = "UPDATE BangLuong SET TrangThai = ? WHERE BangLuongID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, bangLuongId);
            ps.executeUpdate();
        }
    }

    @Override
    public void updateTrangThaiTheoKy(int kyLuongId, String trangThai) throws Exception {
        // Không ghi đè dòng đã xác nhận chuyển khoản — đó là trạng thái "tiến" hơn DaPhat.
        String sql = "UPDATE BangLuong SET TrangThai = ? WHERE KyLuongID = ? AND TrangThai <> ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, kyLuongId);
            ps.setString(3, BangLuong.DA_CHUYEN);
            ps.executeUpdate();
        }
    }

    @Override
    public List<BangLuong> listByAccount(int accountId) throws Exception {
        String sql = "SELECT b.*, k.TenKy, k.NgayPhatLuong " +
                "FROM BangLuong b JOIN KyLuong k ON k.KyLuongID = b.KyLuongID " +
                "WHERE b.AccountID = ? ORDER BY k.NgayBatDau DESC, b.BangLuongID DESC";
        List<BangLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BangLuong bl = mapCore(rs);
                    bl.setTenKy(rs.getNString("TenKy"));
                    bl.setNgayPhatLuong(rs.getDate("NgayPhatLuong").toLocalDate());
                    out.add(bl);
                }
            }
        }
        return out;
    }

    private static BangLuong mapWithAccount(ResultSet rs) throws SQLException {
        BangLuong bl = mapCore(rs);
        bl.setHoTen(rs.getNString("FullName"));
        bl.setAvatarUrl(rs.getNString("AvatarUrl"));
        bl.setMaNganHang(rs.getString("MaNganHang"));
        bl.setSoTaiKhoan(rs.getString("SoTaiKhoan"));
        bl.setQrImagePath(rs.getNString("QrImagePath"));
        return bl;
    }

    private static BangLuong mapCore(ResultSet rs) throws SQLException {
        BangLuong bl = new BangLuong();
        bl.setBangLuongId(rs.getInt("BangLuongID"));
        bl.setKyLuongId(rs.getInt("KyLuongID"));
        bl.setAccountId(rs.getInt("AccountID"));
        bl.setLuongCoBan(rs.getBigDecimal("LuongCoBan"));
        bl.setTongPhuCap(rs.getBigDecimal("TongPhuCap"));
        bl.setTongKhauTru(rs.getBigDecimal("TongKhauTru"));
        bl.setTongLuongThuc(rs.getBigDecimal("TongLuongThuc"));
        bl.setSoCaLamViec(rs.getInt("SoCaLamViec"));
        bl.setTrangThai(rs.getString("TrangThai"));
        bl.setGhiChu(rs.getNString("GhiChu"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        bl.setCreatedAt(ts == null ? null : ts.toLocalDateTime());
        return bl;
    }

    private static BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
