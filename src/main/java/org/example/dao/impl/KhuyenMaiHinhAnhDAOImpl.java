package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiHinhAnhDAO;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.util.DBUtil;

import java.sql.*;
import java.util.*;

public class KhuyenMaiHinhAnhDAOImpl implements KhuyenMaiHinhAnhDAO {

    private static final Logger logger = LogManager.getLogger(KhuyenMaiHinhAnhDAOImpl.class);

    @Override
    public List<KhuyenMaiHinhAnh> findByKhuyenMaiId(int khuyenMaiId) {
        List<KhuyenMaiHinhAnh> list = new ArrayList<>();
        String sql = "SELECT * FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID = ? ORDER BY ThuTu ASC, HinhAnhID ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            logger.error("findByKhuyenMaiId khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public Map<Integer, List<KhuyenMaiHinhAnh>> findByKhuyenMaiIds(Collection<Integer> khuyenMaiIds) {
        Map<Integer, List<KhuyenMaiHinhAnh>> result = new LinkedHashMap<>();
        if (khuyenMaiIds == null || khuyenMaiIds.isEmpty()) return result;
        List<Integer> ids = new ArrayList<>(new LinkedHashSet<>(khuyenMaiIds));
        String placeholders = String.join(",", Collections.nCopies(ids.size(), "?"));
        String sql = "SELECT * FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID IN (" + placeholders + ") " +
                     "ORDER BY KhuyenMaiID ASC, ThuTu ASC, HinhAnhID ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 0; i < ids.size(); i++) ps.setInt(i + 1, ids.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    KhuyenMaiHinhAnh img = map(rs);
                    result.computeIfAbsent(img.getKhuyenMaiId(), k -> new ArrayList<>()).add(img);
                }
            }
        } catch (SQLException e) {
            logger.error("findByKhuyenMaiIds: {}", e.getMessage(), e);
        }
        return result;
    }

    @Override
    public KhuyenMaiHinhAnh findByIdAndKhuyenMaiId(int hinhAnhId, int khuyenMaiId) {
        String sql = "SELECT * FROM KhuyenMaiHinhAnh WHERE HinhAnhID = ? AND KhuyenMaiID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hinhAnhId);
            ps.setInt(2, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            logger.error("findByIdAndKhuyenMaiId hinhAnhId={} khuyenMaiId={}: {}", hinhAnhId, khuyenMaiId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public int countByKhuyenMaiId(int khuyenMaiId) {
        String sql = "SELECT COUNT(*) FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("countByKhuyenMaiId khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public long sumDungLuongByKhuyenMaiId(int khuyenMaiId) {
        String sql = "SELECT COALESCE(SUM(DungLuong), 0) FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            logger.error("sumDungLuongByKhuyenMaiId khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return 0L;
    }

    @Override
    public int countByKhuyenMaiIdForUpdate(Connection conn, int khuyenMaiId) {
        String sql = "SELECT COUNT(*) FROM KhuyenMaiHinhAnh WITH (UPDLOCK, HOLDLOCK) WHERE KhuyenMaiID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("countByKhuyenMaiIdForUpdate khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public long sumDungLuongByKhuyenMaiIdForUpdate(Connection conn, int khuyenMaiId) {
        String sql = "SELECT COALESCE(SUM(DungLuong), 0) FROM KhuyenMaiHinhAnh WITH (UPDLOCK, HOLDLOCK) WHERE KhuyenMaiID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            logger.error("sumDungLuongByKhuyenMaiIdForUpdate khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return 0L;
    }

    @Override
    public int maxThuTu(Connection conn, int khuyenMaiId) {
        String sql = "SELECT COALESCE(MAX(ThuTu), -1) FROM KhuyenMaiHinhAnh WITH (UPDLOCK, HOLDLOCK) WHERE KhuyenMaiID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("maxThuTu khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return -1;
    }

    @Override
    public int insert(Connection conn, KhuyenMaiHinhAnh img) {
        String sql = "INSERT INTO KhuyenMaiHinhAnh " +
                "(KhuyenMaiID, DuongDan, TenFileGoc, MimeType, DungLuong, ChieuRong, ChieuCao, ThuTu, LaAnhBia) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, img.getKhuyenMaiId());
            ps.setNString(2, img.getDuongDan());
            ps.setNString(3, img.getTenFileGoc());
            ps.setString(4, img.getMimeType());
            if (img.getDungLuong() != null) ps.setLong(5, img.getDungLuong()); else ps.setNull(5, Types.BIGINT);
            if (img.getChieuRong() != null) ps.setInt(6, img.getChieuRong()); else ps.setNull(6, Types.INTEGER);
            if (img.getChieuCao() != null) ps.setInt(7, img.getChieuCao()); else ps.setNull(7, Types.INTEGER);
            ps.setInt(8, img.getThuTu());
            ps.setBoolean(9, img.isLaAnhBia());
            int rows = ps.executeUpdate();
            if (rows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            logger.error("insert KhuyenMaiHinhAnh khuyenMaiId={}: {}", img.getKhuyenMaiId(), e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public boolean delete(Connection conn, int hinhAnhId, int khuyenMaiId) {
        String sql = "DELETE FROM KhuyenMaiHinhAnh WHERE HinhAnhID = ? AND KhuyenMaiID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hinhAnhId);
            ps.setInt(2, khuyenMaiId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("delete hinhAnhId={} khuyenMaiId={}: {}", hinhAnhId, khuyenMaiId, e.getMessage(), e);
        }
        return false;
    }

    @Override
    public boolean clearCover(Connection conn, int khuyenMaiId) {
        String sql = "UPDATE KhuyenMaiHinhAnh SET LaAnhBia = 0, UpdatedAt = SYSDATETIME() WHERE KhuyenMaiID = ? AND LaAnhBia = 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, khuyenMaiId);
            ps.executeUpdate();
            return true;
        } catch (SQLException e) {
            logger.error("clearCover khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean setCover(Connection conn, int hinhAnhId, int khuyenMaiId) {
        String sql = "UPDATE KhuyenMaiHinhAnh SET LaAnhBia = 1, UpdatedAt = SYSDATETIME() WHERE HinhAnhID = ? AND KhuyenMaiID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, hinhAnhId);
            ps.setInt(2, khuyenMaiId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("setCover hinhAnhId={} khuyenMaiId={}: {}", hinhAnhId, khuyenMaiId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean updateThuTu(Connection conn, int hinhAnhId, int khuyenMaiId, int thuTu) {
        String sql = "UPDATE KhuyenMaiHinhAnh SET ThuTu = ?, UpdatedAt = SYSDATETIME() WHERE HinhAnhID = ? AND KhuyenMaiID = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, thuTu);
            ps.setInt(2, hinhAnhId);
            ps.setInt(3, khuyenMaiId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("updateThuTu hinhAnhId={} khuyenMaiId={}: {}", hinhAnhId, khuyenMaiId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<KhuyenMaiHinhAnh> deleteAllByKhuyenMaiId(Connection conn, int khuyenMaiId) {
        List<KhuyenMaiHinhAnh> removed = new ArrayList<>();
        String selectSql = "SELECT * FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID = ?";
        String deleteSql = "DELETE FROM KhuyenMaiHinhAnh WHERE KhuyenMaiID = ?";
        try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
            selectPs.setInt(1, khuyenMaiId);
            try (ResultSet rs = selectPs.executeQuery()) {
                while (rs.next()) removed.add(map(rs));
            }
            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setInt(1, khuyenMaiId);
                deletePs.executeUpdate();
            }
        } catch (SQLException e) {
            logger.error("deleteAllByKhuyenMaiId khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
        }
        return removed;
    }

    private KhuyenMaiHinhAnh map(ResultSet rs) throws SQLException {
        KhuyenMaiHinhAnh img = new KhuyenMaiHinhAnh();
        img.setHinhAnhId(rs.getInt("HinhAnhID"));
        img.setKhuyenMaiId(rs.getInt("KhuyenMaiID"));
        img.setDuongDan(rs.getString("DuongDan"));
        img.setTenFileGoc(rs.getString("TenFileGoc"));
        img.setMimeType(rs.getString("MimeType"));
        long dungLuong = rs.getLong("DungLuong");
        if (!rs.wasNull()) img.setDungLuong(dungLuong);
        int chieuRong = rs.getInt("ChieuRong");
        if (!rs.wasNull()) img.setChieuRong(chieuRong);
        int chieuCao = rs.getInt("ChieuCao");
        if (!rs.wasNull()) img.setChieuCao(chieuCao);
        img.setThuTu(rs.getInt("ThuTu"));
        img.setLaAnhBia(rs.getBoolean("LaAnhBia"));
        Timestamp createdAt = rs.getTimestamp("CreatedAt");
        if (createdAt != null) img.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp updatedAt = rs.getTimestamp("UpdatedAt");
        if (updatedAt != null) img.setUpdatedAt(updatedAt.toLocalDateTime());
        return img;
    }
}
