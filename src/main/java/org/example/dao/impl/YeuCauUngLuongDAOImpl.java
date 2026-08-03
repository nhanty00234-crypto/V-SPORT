package org.example.dao.impl;

import org.example.dao.YeuCauUngLuongDAO;
import org.example.model.YeuCauUngLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class YeuCauUngLuongDAOImpl implements YeuCauUngLuongDAO {

    private static final String BASE_SELECT =
            "SELECT y.YeuCauUngLuongID, y.AccountID, y.CoSoID, y.SoTienUng, y.LyDo, y.TrangThai, " +
            "       y.GhiChuQuanLy, y.XuLyBy, y.NgayXuLy, y.CreatedAt, " +
            "       a.FullName AS HoTen, x.FullName AS TenNguoiXuLy " +
            "FROM YeuCauUngLuong y " +
            "JOIN Accounts a ON a.AccountID = y.AccountID " +
            "LEFT JOIN Accounts x ON x.AccountID = y.XuLyBy ";

    @Override
    public int insert(YeuCauUngLuong yc) throws Exception {
        String sql = "INSERT INTO YeuCauUngLuong (AccountID, CoSoID, SoTienUng, LyDo, TrangThai) " +
                "VALUES (?, ?, ?, ?, ?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, yc.getAccountId());
            ps.setInt(2, yc.getCoSoId());
            ps.setBigDecimal(3, yc.getSoTienUng());
            ps.setNString(4, yc.getLyDo());
            ps.setString(5, YeuCauUngLuong.CHO_DUYET);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    @Override
    public List<YeuCauUngLuong> listByAccount(int accountId) throws Exception {
        String sql = BASE_SELECT + "WHERE y.AccountID = ? ORDER BY y.CreatedAt DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            return readAll(ps);
        }
    }

    @Override
    public List<YeuCauUngLuong> listByCoSo(int coSoId, String trangThai) throws Exception {
        String sql = BASE_SELECT + "WHERE y.CoSoID = ? " +
                (trangThai == null ? "" : "AND y.TrangThai = ? ") +
                "ORDER BY CASE WHEN y.TrangThai = 'ChoDuyet' THEN 0 ELSE 1 END, y.CreatedAt DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            if (trangThai != null) ps.setString(2, trangThai);
            return readAll(ps);
        }
    }

    @Override
    public YeuCauUngLuong findById(int id, int coSoId) throws Exception {
        String sql = BASE_SELECT + "WHERE y.YeuCauUngLuongID = ? AND y.CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    @Override
    public boolean xuLy(int id, int coSoId, String trangThaiMoi, String ghiChuQuanLy, int xuLyBy) throws Exception {
        // Điều kiện TrangThai = 'ChoDuyet' nằm TRONG câu UPDATE: nếu 2 request cùng bấm duyệt,
        // chỉ một request có rowsAffected = 1, request còn lại nhận 0 và báo lỗi.
        String sql = "UPDATE YeuCauUngLuong " +
                "SET TrangThai = ?, GhiChuQuanLy = ?, XuLyBy = ?, NgayXuLy = GETDATE() " +
                "WHERE YeuCauUngLuongID = ? AND CoSoID = ? AND TrangThai = 'ChoDuyet'";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThaiMoi);
            ps.setNString(2, ghiChuQuanLy);
            ps.setInt(3, xuLyBy);
            ps.setInt(4, id);
            ps.setInt(5, coSoId);
            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public boolean huyBoiNhanVien(int id, int accountId) throws Exception {
        String sql = "UPDATE YeuCauUngLuong SET TrangThai = 'DaHuy', NgayXuLy = GETDATE() " +
                "WHERE YeuCauUngLuongID = ? AND AccountID = ? AND TrangThai = 'ChoDuyet'";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, accountId);
            return ps.executeUpdate() == 1;
        }
    }

    @Override
    public BigDecimal tongDaDuyetTrongKhoang(int accountId, LocalDate tuNgay, LocalDate denNgay) throws Exception {
        // CAST CreatedAt về DATE để so khoảng ngày inclusive cả ngày cuối kỳ.
        String sql = "SELECT ISNULL(SUM(SoTienUng), 0) FROM YeuCauUngLuong " +
                "WHERE AccountID = ? AND TrangThai = 'DaDuyet' " +
                "  AND CAST(CreatedAt AS DATE) BETWEEN ? AND ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setDate(2, Date.valueOf(tuNgay));
            ps.setDate(3, Date.valueOf(denNgay));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    @Override
    public BigDecimal tongDaDuyetChuaKhauTru(int accountId) throws Exception {
        // "Chưa khấu trừ" = chưa rơi vào kỳ lương nào đã phát (KyLuong.TrangThai = 'DaPhat').
        String sql = "SELECT ISNULL(SUM(y.SoTienUng), 0) FROM YeuCauUngLuong y " +
                "WHERE y.AccountID = ? AND y.TrangThai IN ('ChoDuyet', 'DaDuyet') " +
                "  AND NOT EXISTS ( " +
                "    SELECT 1 FROM BangLuong b JOIN KyLuong k ON k.KyLuongID = b.KyLuongID " +
                "    WHERE b.AccountID = y.AccountID AND k.TrangThai = 'DaPhat' " +
                "      AND CAST(y.CreatedAt AS DATE) BETWEEN k.NgayBatDau AND k.NgayKetThuc)";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    private static List<YeuCauUngLuong> readAll(PreparedStatement ps) throws SQLException {
        List<YeuCauUngLuong> out = new ArrayList<>();
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) out.add(map(rs));
        }
        return out;
    }

    private static YeuCauUngLuong map(ResultSet rs) throws SQLException {
        YeuCauUngLuong yc = new YeuCauUngLuong();
        yc.setYeuCauUngLuongId(rs.getInt("YeuCauUngLuongID"));
        yc.setAccountId(rs.getInt("AccountID"));
        yc.setCoSoId(rs.getInt("CoSoID"));
        yc.setSoTienUng(rs.getBigDecimal("SoTienUng"));
        yc.setLyDo(rs.getNString("LyDo"));
        yc.setTrangThai(rs.getString("TrangThai"));
        yc.setGhiChuQuanLy(rs.getNString("GhiChuQuanLy"));
        int xuLyBy = rs.getInt("XuLyBy");
        yc.setXuLyBy(rs.wasNull() ? null : xuLyBy);
        Timestamp nx = rs.getTimestamp("NgayXuLy");
        yc.setNgayXuLy(nx == null ? null : nx.toLocalDateTime());
        Timestamp ca = rs.getTimestamp("CreatedAt");
        yc.setCreatedAt(ca == null ? null : ca.toLocalDateTime());
        yc.setHoTen(rs.getNString("HoTen"));
        yc.setTenNguoiXuLy(rs.getNString("TenNguoiXuLy"));
        return yc;
    }
}
