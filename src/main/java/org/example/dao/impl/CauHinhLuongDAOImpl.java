package org.example.dao.impl;

import org.example.dao.CauHinhLuongDAO;
import org.example.model.CauHinhLuong;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CauHinhLuongDAOImpl implements CauHinhLuongDAO {

    @Override
    public CauHinhLuong findByAccount(int accountId, int coSoId) throws Exception {
        String sql = "SELECT CauHinhLuongID, AccountID, CoSoID, LuongCoBan, PhuCapMoiCa, HanMucUng, " +
                "GhiChu, CreatedAt, UpdatedAt FROM CauHinhLuong WHERE AccountID = ? AND CoSoID = ?";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    @Override
    public List<CauHinhLuong> listByCoSo(int coSoId) throws Exception {
        // LEFT JOIN để nhân viên chưa cấu hình vẫn hiển thị (manager cần thấy ai còn thiếu).
        String sql = "SELECT a.AccountID, a.FullName, a.RoleID, " +
                "       ISNULL(ch.CauHinhLuongID, 0) AS CauHinhLuongID, " +
                "       ISNULL(ch.LuongCoBan, 0)  AS LuongCoBan, " +
                "       ISNULL(ch.PhuCapMoiCa, 0) AS PhuCapMoiCa, " +
                "       ISNULL(ch.HanMucUng, 0)   AS HanMucUng, " +
                "       ch.GhiChu, ch.CreatedAt, ch.UpdatedAt " +
                "FROM Accounts a " +
                "LEFT JOIN CauHinhLuong ch ON ch.AccountID = a.AccountID AND ch.CoSoID = ? " +
                "WHERE a.CoSoID = ? AND a.RoleID IN (4, 5) " +
                "  AND (a.IsDeleted = 0 OR a.IsDeleted IS NULL) " +
                "ORDER BY a.RoleID, a.FullName";
        List<CauHinhLuong> out = new ArrayList<>();
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CauHinhLuong ch = new CauHinhLuong();
                    ch.setCauHinhLuongId(rs.getInt("CauHinhLuongID"));
                    ch.setAccountId(rs.getInt("AccountID"));
                    ch.setCoSoId(coSoId);
                    ch.setLuongCoBan(rs.getBigDecimal("LuongCoBan"));
                    ch.setPhuCapMoiCa(rs.getBigDecimal("PhuCapMoiCa"));
                    ch.setHanMucUng(rs.getBigDecimal("HanMucUng"));
                    ch.setGhiChu(rs.getNString("GhiChu"));
                    ch.setCreatedAt(toLdt(rs.getTimestamp("CreatedAt")));
                    ch.setUpdatedAt(toLdt(rs.getTimestamp("UpdatedAt")));
                    ch.setHoTen(rs.getNString("FullName"));
                    ch.setTenVaiTro(rs.getInt("RoleID") == 5 ? "Bảo vệ" : "Lễ tân");
                    out.add(ch);
                }
            }
        }
        return out;
    }

    @Override
    public void upsert(CauHinhLuong ch) throws Exception {
        // MERGE tránh race giữa 2 tab manager cùng lưu một nhân viên (UNIQUE sẽ ném lỗi nếu
        // dùng SELECT-rồi-INSERT).
        String sql = "MERGE CauHinhLuong AS t " +
                "USING (SELECT ? AS AccountID, ? AS CoSoID) AS s " +
                "  ON t.AccountID = s.AccountID AND t.CoSoID = s.CoSoID " +
                "WHEN MATCHED THEN UPDATE SET " +
                "  LuongCoBan = ?, PhuCapMoiCa = ?, HanMucUng = ?, GhiChu = ?, UpdatedAt = GETDATE() " +
                "WHEN NOT MATCHED THEN INSERT (AccountID, CoSoID, LuongCoBan, PhuCapMoiCa, HanMucUng, GhiChu) " +
                "  VALUES (?, ?, ?, ?, ?, ?);";
        try (Connection c = DBUtil.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, ch.getAccountId());
            ps.setInt(2, ch.getCoSoId());
            ps.setBigDecimal(3, nz(ch.getLuongCoBan()));
            ps.setBigDecimal(4, nz(ch.getPhuCapMoiCa()));
            ps.setBigDecimal(5, nz(ch.getHanMucUng()));
            ps.setNString(6, ch.getGhiChu());
            ps.setInt(7, ch.getAccountId());
            ps.setInt(8, ch.getCoSoId());
            ps.setBigDecimal(9, nz(ch.getLuongCoBan()));
            ps.setBigDecimal(10, nz(ch.getPhuCapMoiCa()));
            ps.setBigDecimal(11, nz(ch.getHanMucUng()));
            ps.setNString(12, ch.getGhiChu());
            ps.executeUpdate();
        }
    }

    private static CauHinhLuong map(ResultSet rs) throws SQLException {
        CauHinhLuong ch = new CauHinhLuong();
        ch.setCauHinhLuongId(rs.getInt("CauHinhLuongID"));
        ch.setAccountId(rs.getInt("AccountID"));
        ch.setCoSoId(rs.getInt("CoSoID"));
        ch.setLuongCoBan(rs.getBigDecimal("LuongCoBan"));
        ch.setPhuCapMoiCa(rs.getBigDecimal("PhuCapMoiCa"));
        ch.setHanMucUng(rs.getBigDecimal("HanMucUng"));
        ch.setGhiChu(rs.getNString("GhiChu"));
        ch.setCreatedAt(toLdt(rs.getTimestamp("CreatedAt")));
        ch.setUpdatedAt(toLdt(rs.getTimestamp("UpdatedAt")));
        return ch;
    }

    private static LocalDateTime toLdt(Timestamp ts) {
        return ts == null ? null : ts.toLocalDateTime();
    }

    private static BigDecimal nz(BigDecimal v) {
        return v == null ? BigDecimal.ZERO : v;
    }
}
