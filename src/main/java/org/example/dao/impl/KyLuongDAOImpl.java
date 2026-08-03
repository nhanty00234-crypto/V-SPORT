package org.example.dao.impl;

import org.example.dao.KyLuongDAO;
import org.example.model.KyLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class KyLuongDAOImpl implements KyLuongDAO {

    @Override
    public int insert(KyLuong ky) throws Exception {
        String sql = "INSERT INTO KyLuong (CoSoID, TenKy, NgayBatDau, NgayKetThuc, NgayPhatLuong, TrangThai, CreatedBy) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, ky.getCoSoId());
            ps.setNString(2, ky.getTenKy());
            ps.setDate(3, Date.valueOf(ky.getNgayBatDau()));
            ps.setDate(4, Date.valueOf(ky.getNgayKetThuc()));
            ps.setDate(5, Date.valueOf(ky.getNgayPhatLuong()));
            ps.setString(6, ky.getTrangThai() == null ? KyLuong.DRAFT : ky.getTrangThai());
            ps.setInt(7, ky.getCreatedBy());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                return keys.next() ? keys.getInt(1) : 0;
            }
        }
    }

    @Override
    public KyLuong findById(int kyLuongId, int coSoId) throws Exception {
        String sql = "SELECT KyLuongID, CoSoID, TenKy, NgayBatDau, NgayKetThuc, NgayPhatLuong, " +
                "TrangThai, CreatedBy, CreatedAt FROM KyLuong WHERE KyLuongID = ? AND CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, kyLuongId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    @Override
    public List<KyLuong> listByCoSo(int coSoId) throws Exception {
        String sql = "SELECT k.KyLuongID, k.CoSoID, k.TenKy, k.NgayBatDau, k.NgayKetThuc, k.NgayPhatLuong, " +
                "       k.TrangThai, k.CreatedBy, k.CreatedAt, " +
                "       (SELECT COUNT(*) FROM BangLuong b WHERE b.KyLuongID = k.KyLuongID) AS SoNhanVien, " +
                "       (SELECT ISNULL(SUM(b.TongLuongThuc), 0) FROM BangLuong b WHERE b.KyLuongID = k.KyLuongID) AS TongChi " +
                "FROM KyLuong k WHERE k.CoSoID = ? ORDER BY k.NgayBatDau DESC, k.KyLuongID DESC";
        List<KyLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    KyLuong ky = map(rs);
                    ky.setSoNhanVien(rs.getInt("SoNhanVien"));
                    ky.setTongChi(rs.getBigDecimal("TongChi"));
                    out.add(ky);
                }
            }
        }
        return out;
    }

    @Override
    public void updateTrangThai(int kyLuongId, int coSoId, String trangThai) throws Exception {
        String sql = "UPDATE KyLuong SET TrangThai = ? WHERE KyLuongID = ? AND CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, kyLuongId);
            ps.setInt(3, coSoId);
            ps.executeUpdate();
        }
    }

    @Override
    public KyLuong findKyPhatLuongHomNay(int coSoId, LocalDate homNay) throws Exception {
        String sql = "SELECT TOP 1 KyLuongID, CoSoID, TenKy, NgayBatDau, NgayKetThuc, NgayPhatLuong, " +
                "TrangThai, CreatedBy, CreatedAt FROM KyLuong " +
                "WHERE CoSoID = ? AND NgayPhatLuong = ? ORDER BY KyLuongID DESC";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(homNay));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    private static KyLuong map(ResultSet rs) throws SQLException {
        KyLuong ky = new KyLuong();
        ky.setKyLuongId(rs.getInt("KyLuongID"));
        ky.setCoSoId(rs.getInt("CoSoID"));
        ky.setTenKy(rs.getNString("TenKy"));
        ky.setNgayBatDau(rs.getDate("NgayBatDau").toLocalDate());
        ky.setNgayKetThuc(rs.getDate("NgayKetThuc").toLocalDate());
        ky.setNgayPhatLuong(rs.getDate("NgayPhatLuong").toLocalDate());
        ky.setTrangThai(rs.getString("TrangThai"));
        ky.setCreatedBy(rs.getInt("CreatedBy"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        ky.setCreatedAt(ts == null ? null : ts.toLocalDateTime());
        ky.setTongChi(BigDecimal.ZERO);
        return ky;
    }
}
