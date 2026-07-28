package org.example.dao.impl;

<<<<<<< HEAD
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiDAO;
import org.example.model.KhuyenMai;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
=======
import org.example.dao.KhuyenMaiDAO;
import org.example.model.KhuyenMai;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Types;
>>>>>>> fix/teacher-review-remediation
import java.util.ArrayList;
import java.util.List;

public class KhuyenMaiDAOImpl implements KhuyenMaiDAO {

    private static final Logger logger = LogManager.getLogger(KhuyenMaiDAOImpl.class);

<<<<<<< HEAD
    @Override
    public List<KhuyenMai> findByCoSoId(int coSoId, int page, int pageSize) {
        List<KhuyenMai> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql = "SELECT * FROM KhuyenMai WHERE CoSoID = ? " +
                     "ORDER BY NgayBatDau DESC " +
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
=======
    private static final String SELECT_COLS =
            "KhuyenMaiID, MaCode, MoTa, LoaiGiam, GiaTriGiam, NgayBatDau, NgayKetThuc, " +
            "SoLanToiDa, SoLanDaDung, CoSoID, TrangThai, GiaTriToiThieu, GiamToiDa ";

    private KhuyenMai mapRow(ResultSet rs) throws java.sql.SQLException {
        KhuyenMai km = new KhuyenMai();
        km.setKhuyenMaiID(rs.getInt("KhuyenMaiID"));
        km.setMaCode(rs.getString("MaCode"));
        km.setMoTa(rs.getString("MoTa"));
        km.setLoaiGiam(rs.getString("LoaiGiam"));
        km.setGiaTriGiam(rs.getDouble("GiaTriGiam"));
        if (rs.getDate("NgayBatDau") != null) km.setNgayBatDau(rs.getDate("NgayBatDau").toLocalDate());
        if (rs.getDate("NgayKetThuc") != null) km.setNgayKetThuc(rs.getDate("NgayKetThuc").toLocalDate());
        int maxCount = rs.getInt("SoLanToiDa");
        if (!rs.wasNull()) km.setSoLanToiDa(maxCount);
        km.setSoLanDaDung(rs.getInt("SoLanDaDung"));
        int csId = rs.getInt("CoSoID");
        if (!rs.wasNull()) km.setCoSoID(csId);
        km.setTrangThai(rs.getString("TrangThai"));
        km.setGiaTriToiThieu(rs.getBigDecimal("GiaTriToiThieu"));
        km.setGiamToiDa(rs.getBigDecimal("GiamToiDa"));
        return km;
    }

    @Override
    public List<KhuyenMai> findByCoSoId(int coSoId) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT " + SELECT_COLS + "FROM KhuyenMai WHERE CoSoID = ? ORDER BY KhuyenMaiID DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (Exception e) {
            logger.error("Error fetching KhuyenMai by coSoId {}: {}", coSoId, e.getMessage(), e);
>>>>>>> fix/teacher-review-remediation
        }
        return list;
    }

    @Override
<<<<<<< HEAD
    public KhuyenMai findById(int id) {
        String sql = "SELECT * FROM KhuyenMai WHERE KhuyenMaiID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findById KhuyenMaiID={}: {}", id, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public KhuyenMai findByCodeAndCoSoId(String maCode, int coSoId) {
        String sql = "SELECT * FROM KhuyenMai WHERE MaCode = ? AND CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByCodeAndCoSoId: {}", e.getMessage(), e);
=======
    public KhuyenMai findByIdAndCoSoId(int khuyenMaiId, int coSoId) {
        String sql = "SELECT " + SELECT_COLS + "FROM KhuyenMai WHERE KhuyenMaiID = ? AND CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (Exception e) {
            logger.error("Error fetching KhuyenMai {} for coSoId {}: {}", khuyenMaiId, coSoId, e.getMessage(), e);
>>>>>>> fix/teacher-review-remediation
        }
        return null;
    }

    @Override
<<<<<<< HEAD
    public boolean existsByCode(String maCode) {
        String sql = "SELECT 1 FROM KhuyenMai WHERE MaCode = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            logger.error("existsByCode: {}", e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean existsByCodeExcluding(String maCode, int excludeId) {
        String sql = "SELECT 1 FROM KhuyenMai WHERE MaCode = ? AND KhuyenMaiID <> ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        } catch (SQLException e) {
            logger.error("existsByCodeExcluding: {}", e.getMessage(), e);
=======
    public boolean existsByCode(String maCode, Integer excludeKhuyenMaiId) {
        String sql = "SELECT COUNT(*) FROM KhuyenMai WHERE UPPER(MaCode) = ?" +
                (excludeKhuyenMaiId != null ? " AND KhuyenMaiID <> ?" : "");
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode.trim().toUpperCase());
            if (excludeKhuyenMaiId != null) ps.setInt(2, excludeKhuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            logger.error("Error checking duplicate MaCode {}: {}", maCode, e.getMessage(), e);
>>>>>>> fix/teacher-review-remediation
        }
        return false;
    }

    @Override
    public int insert(KhuyenMai km) {
        String sql = "INSERT INTO KhuyenMai (MaCode, MoTa, LoaiGiam, GiaTriGiam, NgayBatDau, NgayKetThuc, " +
<<<<<<< HEAD
                     "SoLanToiDa, SoLanDaDung, CoSoID, TrangThai) VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, km.getMaCode());
            ps.setNString(2, km.getMoTa());
            ps.setString(3, km.getLoaiGiam());
            ps.setDouble(4, km.getGiaTriGiam());
            ps.setDate(5, Date.valueOf(km.getNgayBatDau()));
            ps.setDate(6, Date.valueOf(km.getNgayKetThuc()));
            if (km.getSoLanToiDa() != null) ps.setInt(7, km.getSoLanToiDa());
            else ps.setNull(7, Types.INTEGER);
            if (km.getCoSoID() != null) ps.setInt(8, km.getCoSoID());
            else ps.setNull(8, Types.INTEGER);
            ps.setNString(9, km.getTrangThai() != null ? km.getTrangThai() : "Hoạt động");
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert KhuyenMai: {}", e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public boolean update(KhuyenMai km) {
        String sql = "UPDATE KhuyenMai SET MaCode=?, MoTa=?, LoaiGiam=?, GiaTriGiam=?, " +
                     "NgayBatDau=?, NgayKetThuc=?, SoLanToiDa=?, TrangThai=? " +
                     "WHERE KhuyenMaiID=? AND CoSoID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, km.getMaCode());
            ps.setNString(2, km.getMoTa());
            ps.setString(3, km.getLoaiGiam());
            ps.setDouble(4, km.getGiaTriGiam());
            ps.setDate(5, Date.valueOf(km.getNgayBatDau()));
            ps.setDate(6, Date.valueOf(km.getNgayKetThuc()));
            if (km.getSoLanToiDa() != null) ps.setInt(7, km.getSoLanToiDa());
            else ps.setNull(7, Types.INTEGER);
            ps.setNString(8, km.getTrangThai());
            ps.setInt(9, km.getKhuyenMaiID());
            ps.setInt(10, km.getCoSoID());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("update KhuyenMaiID={}: {}", km.getKhuyenMaiID(), e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean delete(int khuyenMaiId, int coSoId) {
        String sql = "DELETE FROM KhuyenMai WHERE KhuyenMaiID = ? AND CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            ps.setInt(2, coSoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("delete KhuyenMaiID={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean incrementUsage(Connection conn, int khuyenMaiId) {
        // Tăng SoLanDaDung chỉ khi TrangThai='Hoạt động' và (SoLanToiDa IS NULL OR SoLanDaDung < SoLanToiDa)
        String sql =
            "UPDATE KhuyenMai SET SoLanDaDung = SoLanDaDung + 1 " +
            "WHERE KhuyenMaiID = ? AND TrangThai = N'Hoạt động' " +
            "AND (SoLanToiDa IS NULL OR SoLanDaDung < SoLanToiDa)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("incrementUsage KhuyenMaiID={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public int countByCoSoId(int coSoId) {
        String sql = "SELECT COUNT(*) FROM KhuyenMai WHERE CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("countByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public KhuyenMai findApplicable(String maCode, int coSoId, LocalDate today) {
        String sql =
            "SELECT * FROM KhuyenMai WHERE MaCode = ? AND CoSoID = ? " +
            "AND TrangThai = N'Hoạt động' " +
            "AND NgayBatDau <= ? AND NgayKetThuc >= ? " +
            "AND (SoLanToiDa IS NULL OR SoLanDaDung < SoLanToiDa)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, maCode);
            ps.setInt(2, coSoId);
            ps.setDate(3, Date.valueOf(today));
            ps.setDate(4, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findApplicable maCode={} coSoId={}: {}", maCode, coSoId, e.getMessage(), e);
        }
        return null;
    }

    private KhuyenMai map(ResultSet rs) throws SQLException {
        KhuyenMai km = new KhuyenMai();
        km.setKhuyenMaiID(rs.getInt("KhuyenMaiID"));
        km.setMaCode(rs.getString("MaCode"));
        km.setMoTa(rs.getString("MoTa"));
        km.setLoaiGiam(rs.getString("LoaiGiam"));
        km.setGiaTriGiam(rs.getDouble("GiaTriGiam"));
        Date nd = rs.getDate("NgayBatDau");
        if (nd != null) km.setNgayBatDau(nd.toLocalDate());
        Date nkt = rs.getDate("NgayKetThuc");
        if (nkt != null) km.setNgayKetThuc(nkt.toLocalDate());
        int slt = rs.getInt("SoLanToiDa");
        if (!rs.wasNull()) km.setSoLanToiDa(slt);
        km.setSoLanDaDung(rs.getInt("SoLanDaDung"));
        int coSo = rs.getInt("CoSoID");
        if (!rs.wasNull()) km.setCoSoID(coSo);
        km.setTrangThai(rs.getString("TrangThai"));
        return km;
=======
                "SoLanToiDa, SoLanDaDung, CoSoID, TrangThai, GiaTriToiThieu, GiamToiDa) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bindUpsertParams(ps, km);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (Exception e) {
            logger.error("Error inserting KhuyenMai {}: {}", km.getMaCode(), e.getMessage(), e);
        }
        return -1;
    }

    @Override
    public boolean update(KhuyenMai km, int coSoId) {
        String sql = "UPDATE KhuyenMai SET MaCode=?, MoTa=?, LoaiGiam=?, GiaTriGiam=?, NgayBatDau=?, NgayKetThuc=?, " +
                "SoLanToiDa=?, CoSoID=?, TrangThai=?, GiaTriToiThieu=?, GiamToiDa=? " +
                "WHERE KhuyenMaiID=? AND CoSoID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            bindUpsertParams(ps, km);
            ps.setInt(12, km.getKhuyenMaiID());
            ps.setInt(13, coSoId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            logger.error("Error updating KhuyenMai {}: {}", km.getKhuyenMaiID(), e.getMessage(), e);
            return false;
        }
    }

    private void bindUpsertParams(PreparedStatement ps, KhuyenMai km) throws java.sql.SQLException {
        ps.setString(1, km.getMaCode());
        ps.setString(2, km.getMoTa());
        ps.setString(3, km.getLoaiGiam());
        ps.setDouble(4, km.getGiaTriGiam());
        ps.setDate(5, java.sql.Date.valueOf(km.getNgayBatDau()));
        ps.setDate(6, java.sql.Date.valueOf(km.getNgayKetThuc()));
        if (km.getSoLanToiDa() != null) ps.setInt(7, km.getSoLanToiDa());
        else ps.setNull(7, Types.INTEGER);
        ps.setInt(8, km.getCoSoID());
        ps.setString(9, km.getTrangThai());
        BigDecimal minVal = km.getGiaTriToiThieu();
        if (minVal != null) ps.setBigDecimal(10, minVal);
        else ps.setNull(10, Types.DECIMAL);
        BigDecimal capVal = km.getGiamToiDa();
        if (capVal != null) ps.setBigDecimal(11, capVal);
        else ps.setNull(11, Types.DECIMAL);
    }

    @Override
    public boolean updateTrangThai(int khuyenMaiId, int coSoId, String trangThai) {
        String sql = "UPDATE KhuyenMai SET TrangThai = ? WHERE KhuyenMaiID = ? AND CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, trangThai);
            ps.setInt(2, khuyenMaiId);
            ps.setInt(3, coSoId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            logger.error("Error toggling TrangThai for KhuyenMai {}: {}", khuyenMaiId, e.getMessage(), e);
            return false;
        }
>>>>>>> fix/teacher-review-remediation
    }
}
