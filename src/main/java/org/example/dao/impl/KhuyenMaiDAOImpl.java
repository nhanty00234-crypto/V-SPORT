package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiDAO;
import org.example.model.KhuyenMai;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

public class KhuyenMaiDAOImpl implements KhuyenMaiDAO {

    private static final Logger logger = LogManager.getLogger(KhuyenMaiDAOImpl.class);

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
        }
        return list;
    }

    @Override
    public List<KhuyenMai> findByCoSoId(int coSoId) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT * FROM KhuyenMai WHERE CoSoID = ? ORDER BY NgayBatDau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByCoSoId (all) coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
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
    public KhuyenMai findByIdAndCoSoId(int id, int coSoId) {
        String sql = "SELECT * FROM KhuyenMai WHERE KhuyenMaiID = ? AND CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndCoSoId KhuyenMaiID={} coSoId={}: {}", id, coSoId, e.getMessage(), e);
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
        }
        return null;
    }

    @Override
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
        }
        return false;
    }

    @Override
    public int insert(KhuyenMai km) {
        String sql = "INSERT INTO KhuyenMai (MaCode, MoTa, LoaiGiam, GiaTriGiam, NgayBatDau, NgayKetThuc, " +
                     "SoLanToiDa, SoLanDaDung, CoSoID, TrangThai, HienThiCongKhai) VALUES (?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)";
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
            ps.setBoolean(10, km.isHienThiCongKhai());
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
    public boolean updateTrangThai(int khuyenMaiId, int coSoId, String trangThai) {
        String sql = "UPDATE KhuyenMai SET TrangThai=? WHERE KhuyenMaiID=? AND CoSoID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setNString(1, trangThai);
            ps.setInt(2, khuyenMaiId);
            ps.setInt(3, coSoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateTrangThai KhuyenMaiID={}: {}", khuyenMaiId, e.getMessage(), e);
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

    @Override
    public List<KhuyenMai> findPublicActiveByCoSoId(int coSoId, LocalDate today) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT km.* FROM KhuyenMai km " +
                "JOIN CoSo c ON km.CoSoID = c.CoSoID " +
                "WHERE km.CoSoID = ? " +
                "  AND km.TrangThai = N'Hoạt động' " +
                "  AND km.HienThiCongKhai = 1 " +
                "  AND km.NgayBatDau <= ? AND km.NgayKetThuc >= ? " +
                "  AND (km.SoLanToiDa IS NULL OR km.SoLanDaDung < km.SoLanToiDa) " +
                "  AND c.TrangThai = N'Đang hoạt động' AND (c.IsDeleted = 0 OR c.IsDeleted IS NULL) " +
                "ORDER BY km.NgayBatDau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            ps.setDate(2, Date.valueOf(today));
            ps.setDate(3, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findPublicActiveByCoSoId coSoId={}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<KhuyenMai> findPublicActiveByCoSoIds(Collection<Integer> coSoIds, LocalDate today) {
        List<KhuyenMai> list = new ArrayList<>();
        if (coSoIds == null || coSoIds.isEmpty()) return list;
        List<Integer> ids = new ArrayList<>(new java.util.LinkedHashSet<>(coSoIds));
        String placeholders = String.join(",", java.util.Collections.nCopies(ids.size(), "?"));
        String sql = "SELECT km.* FROM KhuyenMai km " +
                "JOIN CoSo c ON km.CoSoID = c.CoSoID " +
                "WHERE km.CoSoID IN (" + placeholders + ") " +
                "  AND km.TrangThai = N'Hoạt động' " +
                "  AND km.HienThiCongKhai = 1 " +
                "  AND km.NgayBatDau <= ? AND km.NgayKetThuc >= ? " +
                "  AND (km.SoLanToiDa IS NULL OR km.SoLanDaDung < km.SoLanToiDa) " +
                "  AND c.TrangThai = N'Đang hoạt động' AND (c.IsDeleted = 0 OR c.IsDeleted IS NULL) " +
                "ORDER BY km.CoSoID ASC, km.NgayBatDau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            for (Integer id : ids) ps.setInt(idx++, id);
            ps.setDate(idx++, Date.valueOf(today));
            ps.setDate(idx, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findPublicActiveByCoSoIds: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<KhuyenMai> findPublicActiveAll(LocalDate today, int limit) {
        List<KhuyenMai> list = new ArrayList<>();
        String sql = "SELECT TOP (?) km.* FROM KhuyenMai km " +
                "JOIN CoSo c ON km.CoSoID = c.CoSoID " +
                "WHERE km.TrangThai = N'Hoạt động' " +
                "  AND km.HienThiCongKhai = 1 " +
                "  AND km.NgayBatDau <= ? AND km.NgayKetThuc >= ? " +
                "  AND (km.SoLanToiDa IS NULL OR km.SoLanDaDung < km.SoLanToiDa) " +
                "  AND c.TrangThai = N'Đang hoạt động' AND (c.IsDeleted = 0 OR c.IsDeleted IS NULL) " +
                "ORDER BY km.NgayBatDau DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, Math.max(1, limit));
            ps.setDate(2, Date.valueOf(today));
            ps.setDate(3, Date.valueOf(today));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findPublicActiveAll: {}", e.getMessage(), e);
        }
        return list;
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
        try {
            km.setGiaTriToiThieu(rs.getBigDecimal("GiaTriToiThieu"));
            km.setGiamToiDa(rs.getBigDecimal("GiamToiDa"));
        } catch (SQLException ignored) {
            // Cột có thể không tồn tại trên một số môi trường DB chưa chạy migration bổ sung.
        }
        try {
            km.setHienThiCongKhai(rs.getBoolean("HienThiCongKhai"));
        } catch (SQLException ignored) {
            // Môi trường chưa chạy migration_khuyenmai_hinhanh.sql - mặc định true (đã set ở model).
        }
        return km;
    }
}
