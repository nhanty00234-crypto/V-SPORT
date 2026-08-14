package org.example.dao.impl;

import org.example.dao.ThongBaoDAO;
import org.example.model.ThongBao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

/**
 * Implementation của ThongBaoDAO sử dụng JDBC
 */
public class ThongBaoDAOImpl implements ThongBaoDAO {

    private static final Logger logger = LogManager.getLogger(ThongBaoDAOImpl.class);

    @Override
    public int insert(ThongBao thongBao) {
        try (Connection conn = org.example.util.DBUtil.getConnection()) {
            return insert(conn, thongBao);
        } catch (SQLException e) {
            int errorCode = e.getErrorCode();
            if (errorCode == 2601 || errorCode == 2627) {
                logger.info("NOTIFICATION_INSERT_IDEMPOTENT_SKIPPED accountId={} eventType={} recordId={}",
                        thongBao.getAccountId(), thongBao.getLoaiThongBao(), thongBao.getMaBanGhi());
                return -1;
            }
            logger.error("NOTIFICATION_INSERT_FAILED sqlState={} errorCode={} message={} accountId={} eventType={} recordId={}",
                    e.getSQLState(), e.getErrorCode(), e.getMessage(), thongBao.getAccountId(), thongBao.getLoaiThongBao(), thongBao.getMaBanGhi(), e);
            return 0;
        }
    }

    @Override
    public int insert(Connection conn, ThongBao thongBao) throws SQLException {
        String sql = "INSERT INTO ThongBao (AccountID, TieuDe, NoiDung, LoaiThongBao, DaDoc, ThoiGianGui, MaBanGhi, DuongDan, IsDeleted) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)";

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, thongBao.getAccountId());
            ps.setNString(2, thongBao.getTieuDe());
            ps.setNString(3, thongBao.getNoiDung());
            ps.setNString(4, thongBao.getLoaiThongBao());
            ps.setBoolean(5, thongBao.getDaDoc());
            ps.setTimestamp(6, new Timestamp(thongBao.getThoiGianGui().getTime()));
            ps.setString(7, thongBao.getMaBanGhi());
            ps.setString(8, thongBao.getDuongDan());

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
            return 0;
        } catch (SQLException e) {
            int errorCode = e.getErrorCode();
            if (errorCode == 2601 || errorCode == 2627) {
                logger.info("NOTIFICATION_INSERT_IDEMPOTENT_SKIPPED accountId={} eventType={} recordId={}",
                        thongBao.getAccountId(), thongBao.getLoaiThongBao(), thongBao.getMaBanGhi());
                return -1;
            }
            logger.error("NOTIFICATION_INSERT_FAILED sqlState={} errorCode={} message={} accountId={} eventType={} recordId={}",
                    e.getSQLState(), e.getErrorCode(), e.getMessage(), thongBao.getAccountId(), thongBao.getLoaiThongBao(), thongBao.getMaBanGhi(), e);
            throw e;
        }
    }

    @Override
    public boolean update(ThongBao thongBao) {
        String sql = "UPDATE ThongBao SET AccountID=?, TieuDe=?, NoiDung=?, LoaiThongBao=?, DaDoc=?, ThoiGianGui=?, MaBanGhi=?, DuongDan=? WHERE ThongBaoID=?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBao.getAccountId());
            ps.setNString(2, thongBao.getTieuDe());
            ps.setNString(3, thongBao.getNoiDung());
            ps.setNString(4, thongBao.getLoaiThongBao());
            ps.setBoolean(5, thongBao.getDaDoc());
            ps.setTimestamp(6, new Timestamp(thongBao.getThoiGianGui().getTime()));
            ps.setString(7, thongBao.getMaBanGhi());
            ps.setString(8, thongBao.getDuongDan());
            ps.setInt(9, thongBao.getThongBaoId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi cập nhật thông báo ID {}: {}", thongBao.getThongBaoId(), e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean hardDelete(int thongBaoId) {
        String sql = "DELETE FROM ThongBao WHERE ThongBaoID = ?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBaoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi xóa thông báo với ID {}: {}", thongBaoId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public ThongBao findById(int thongBaoId) {
        String sql = "SELECT * FROM ThongBao WHERE ThongBaoID = ? AND IsDeleted = 0";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBaoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToThongBao(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy thông báo với ID {}: {}", thongBaoId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<ThongBao> findAll() {
        List<ThongBao> list = new ArrayList<>();
        String sql = "SELECT * FROM ThongBao WHERE IsDeleted = 0 ORDER BY ThoiGianGui DESC";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToThongBao(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy tất cả thông báo: {}", e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<ThongBao> findByAccountID(int accountId) {
        List<ThongBao> list = new ArrayList<>();
        String sql = "SELECT * FROM ThongBao WHERE AccountID = ? AND IsDeleted = 0 ORDER BY ThoiGianGui DESC";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToThongBao(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi lấy thông báo theo account ID {}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<ThongBao> findLatestByAccountId(int accountId, int limit) {
        List<ThongBao> list = new ArrayList<>();
        int safeLimit = Math.max(1, limit);
        String sql = "SELECT TOP (?) * FROM ThongBao WHERE AccountID = ? AND IsDeleted = 0 ORDER BY ThoiGianGui DESC";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, safeLimit);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToThongBao(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi findLatestByAccountId accountId={} limit={}: {}", accountId, safeLimit, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public int countByAccountId(int accountId) {
        String sql = "SELECT COUNT(*) FROM ThongBao WHERE AccountID = ? AND IsDeleted = 0";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Lỗi countByAccountId accountId={}: {}", accountId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public List<ThongBao> findByAccountId(int accountId, int page, int pageSize) {
        List<ThongBao> list = new ArrayList<>();
        int offset = (Math.max(page, 1) - 1) * pageSize;
        String sql = "SELECT * FROM ThongBao WHERE AccountID = ? AND IsDeleted = 0 " +
                     "ORDER BY ThoiGianGui DESC " +
                     "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, offset);
            ps.setInt(3, pageSize);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapResultSetToThongBao(rs));
            }
        } catch (SQLException e) {
            logger.error("Lỗi findByAccountId page={} accountId={}: {}", page, accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public int countUnread(int accountId) {
        String sql = "SELECT COUNT(*) FROM ThongBao WHERE AccountID = ? AND DaDoc = 0 AND IsDeleted = 0";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            logger.error("Lỗi countUnread accountId={}: {}", accountId, e.getMessage(), e);
        }
        return 0;
    }

    @Override
    public boolean markAsRead(int thongBaoId, int accountId) {
        String sql = "UPDATE ThongBao SET DaDoc = 1 WHERE ThongBaoID = ? AND AccountID = ? AND IsDeleted = 0";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, thongBaoId);
            ps.setInt(2, accountId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi markAsRead thongBaoId={} accountId={}: {}", thongBaoId, accountId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public int markAllAsRead(int accountId) {
        String sql = "UPDATE ThongBao SET DaDoc = 1 WHERE AccountID = ? AND DaDoc = 0 AND IsDeleted = 0";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            logger.error("Lỗi markAllAsRead accountId={}: {}", accountId, e.getMessage(), e);
            return 0;
        }
    }

    @Override
    public boolean existsByAccountIdAndLoaiAndMaBanGhi(int accountId, String loaiThongBao, String maBanGhi) {
        String sql = "SELECT 1 FROM ThongBao WHERE AccountID = ? AND LoaiThongBao = ? AND MaBanGhi = ? AND IsDeleted = 0";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setNString(2, loaiThongBao);
            ps.setString(3, maBanGhi);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.error("Lỗi existsByAccountIdAndLoaiAndMaBanGhi accountId={}: {}", accountId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean markAsRead(int thongBaoId) {
        String sql = "UPDATE ThongBao SET DaDoc = 1 WHERE ThongBaoID = ?";

        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, thongBaoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi khi đánh dấu thông báo đã đọc ID {}: {}", thongBaoId, e.getMessage(), e);
            return false;
        }
    }

    private ThongBao mapResultSetToThongBao(ResultSet rs) throws SQLException {
        ThongBao tb = new ThongBao();
        tb.setThongBaoId(rs.getInt("ThongBaoID"));
        tb.setAccountId(rs.getInt("AccountID"));
        tb.setTieuDe(rs.getString("TieuDe"));
        tb.setNoiDung(rs.getString("NoiDung"));
        tb.setLoaiThongBao(rs.getString("LoaiThongBao"));
        tb.setDaDoc(rs.getBoolean("DaDoc"));
        tb.setThoiGianGui(rs.getTimestamp("ThoiGianGui"));
        tb.setMaBanGhi(rs.getString("MaBanGhi"));
        tb.setDuongDan(rs.getString("DuongDan"));
        tb.setDeleted(rs.getBoolean("IsDeleted"));
        Timestamp deletedAtTs = rs.getTimestamp("DeletedAt");
        if (deletedAtTs != null) {
            tb.setDeletedAt(deletedAtTs.toLocalDateTime());
        }
        int deletedBy = rs.getInt("DeletedBy");
        if (!rs.wasNull()) {
            tb.setDeletedBy(deletedBy);
        }
        return tb;
    }

    @Override
    public boolean softDelete(int thongBaoId, int actorId) {
        String sql = "UPDATE ThongBao SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ? " +
                     "WHERE ThongBaoID = ? AND IsDeleted = 0";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, actorId);
            ps.setInt(2, thongBaoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi soft delete thông báo ID {}: {}", thongBaoId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean restore(int thongBaoId) {
        String sql = "UPDATE ThongBao SET IsDeleted = 0, DeletedAt = NULL, DeletedBy = NULL " +
                     "WHERE ThongBaoID = ? AND IsDeleted = 1";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, thongBaoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Lỗi restore thông báo ID {}: {}", thongBaoId, e.getMessage(), e);
            return false;
        }
    }

    @Override
    public List<ThongBao> findDeletedByCoSo(int coSoId) {
        List<ThongBao> list = new ArrayList<>();
        String sql = "SELECT t.* FROM ThongBao t " +
                     "JOIN Accounts a ON t.AccountID = a.AccountID " +
                     "WHERE a.CoSoID = ? AND t.IsDeleted = 1 " +
                     "ORDER BY t.DeletedAt DESC";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToThongBao(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedByCoSo thông báo coSoId {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<Integer> findDeletedIdsOlderThan(int days) {
        List<Integer> ids = new ArrayList<>();
        String sql = "SELECT ThongBaoID FROM ThongBao " +
                     "WHERE IsDeleted = 1 AND DeletedAt < DATEADD(day, -?, GETDATE())";
        try (Connection conn = org.example.util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getInt("ThongBaoID"));
                }
            }
        } catch (SQLException e) {
            logger.error("Lỗi findDeletedIdsOlderThan thông báo days {}: {}", days, e.getMessage(), e);
        }
        return ids;
    }
}
