package org.example.dao.impl;

import org.example.dao.CaLamViecSwapRequestDAO;
import org.example.model.CaLamViecSwapRequest;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CaLamViecSwapRequestDAOImpl implements CaLamViecSwapRequestDAO {

    private static final Logger logger = LogManager.getLogger(CaLamViecSwapRequestDAOImpl.class);

    @Override
    public boolean insert(CaLamViecSwapRequest sr) {
        String sql = "INSERT INTO work_shift_swap_requests (requester_account_id, requester_work_shift_id, target_account_id, target_work_shift_id, reason, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, sr.getAccountIdGui());
            ps.setInt(2, sr.getCaLamViecIdGui());
            ps.setInt(3, sr.getAccountIdNhan());
            if (sr.getCaLamViecIdNhan() != null) {
                ps.setInt(4, sr.getCaLamViecIdNhan());
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setString(5, sr.getLyDo());
            ps.setString(6, sr.getTrangThai());
            
            boolean success = ps.executeUpdate() > 0;
            if (success) {
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    if (gk.next()) {
                        sr.setSwapRequestId(gk.getInt(1));
                    }
                }
            }
            return success;
        } catch (SQLException e) {
            logger.error("Error inserting swap request: {}", e.getMessage(), e);
            return false;
        }
    }

    @Override
    public boolean update(CaLamViecSwapRequest sr) {
        String sql = "UPDATE work_shift_swap_requests SET status = ?, approver_account_id = ?, approved_at = ?, manager_note = ? WHERE swap_request_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sr.getTrangThai());
            if (sr.getNguoiDuyet() != null) {
                ps.setInt(2, sr.getNguoiDuyet());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            if (sr.getNgayDuyet() != null) {
                ps.setTimestamp(3, Timestamp.valueOf(sr.getNgayDuyet()));
            } else {
                ps.setNull(3, Types.TIMESTAMP);
            }
            ps.setString(4, sr.getGhiChuQuanLy());
            ps.setInt(5, sr.getSwapRequestId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.error("Error updating swap request ID {}: {}", sr.getSwapRequestId(), e.getMessage(), e);
            return false;
        }
    }

    @Override
    public CaLamViecSwapRequest getById(int swapRequestId) {
        String sql = getSelectQuery() + " WHERE sr.swap_request_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, swapRequestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting swap request by ID {}: {}", swapRequestId, e.getMessage(), e);
        }
        return null;
    }

    @Override
    public List<CaLamViecSwapRequest> getByCoSo(int coSoId) {
        List<CaLamViecSwapRequest> list = new ArrayList<>();
        // Query requests where sender belongs to the branch
        String sql = getSelectQuery() + " JOIN accounts s_acc ON sr.requester_account_id = s_acc.account_id WHERE s_acc.facility_id = ? ORDER BY sr.requested_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting swap requests by branch ID {}: {}", coSoId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public List<CaLamViecSwapRequest> getByAccount(int accountId) {
        List<CaLamViecSwapRequest> list = new ArrayList<>();
        // Query requests where user is either sender or receiver
        String sql = getSelectQuery() + " WHERE sr.requester_account_id = ? OR sr.target_account_id = ? ORDER BY sr.requested_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("Error getting swap requests by account ID {}: {}", accountId, e.getMessage(), e);
        }
        return list;
    }

    @Override
    public boolean updateWithConnection(CaLamViecSwapRequest sr, Connection conn) throws SQLException {
        String sql = "UPDATE work_shift_swap_requests SET status = ?, approver_account_id = ?, approved_at = ?, manager_note = ? WHERE swap_request_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, sr.getTrangThai());
            if (sr.getNguoiDuyet() != null) {
                ps.setInt(2, sr.getNguoiDuyet());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            if (sr.getNgayDuyet() != null) {
                ps.setTimestamp(3, Timestamp.valueOf(sr.getNgayDuyet()));
            } else {
                ps.setNull(3, Types.TIMESTAMP);
            }
            ps.setString(4, sr.getGhiChuQuanLy());
            ps.setInt(5, sr.getSwapRequestId());
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean hasPendingForShift(int caLamViecId) {
        String sql = "SELECT 1 FROM work_shift_swap_requests WHERE requester_work_shift_id = ? AND status IN ('ChoXacNhan', 'ChoQuanLyDuyet')";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, caLamViecId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.error("Error checking pending swap for shift {}: {}", caLamViecId, e.getMessage(), e);
            return false;
        }
    }

    private String getSelectQuery() {
        return "SELECT sr.*, acc1.full_name as SenderName, acc2.full_name as ReceiverName, " +
               "c1.work_date as GuiNgay, c1.start_time as GuiBD, c1.end_time as GuiKT, " +
               "c2.work_date as NhanNgay, c2.start_time as NhanBD, c2.end_time as NhanKT " +
               "FROM work_shift_swap_requests sr " +
               "JOIN accounts acc1 ON sr.requester_account_id = acc1.account_id " +
               "JOIN accounts acc2 ON sr.target_account_id = acc2.account_id " +
               "JOIN work_shifts c1 ON sr.requester_work_shift_id = c1.work_shift_id " +
               "LEFT JOIN work_shifts c2 ON sr.target_work_shift_id = c2.work_shift_id";
    }

    private CaLamViecSwapRequest mapResultSet(ResultSet rs) throws SQLException {
        CaLamViecSwapRequest sr = new CaLamViecSwapRequest();
        sr.setSwapRequestId(rs.getInt("swap_request_id"));
        sr.setAccountIdGui(rs.getInt("requester_account_id"));
        sr.setCaLamViecIdGui(rs.getInt("requester_work_shift_id"));
        sr.setAccountIdNhan(rs.getInt("target_account_id"));
        
        int nhanId = rs.getInt("target_work_shift_id");
        if (!rs.wasNull()) {
            sr.setCaLamViecIdNhan(nhanId);
        }
        
        sr.setLyDo(rs.getNString("reason"));
        sr.setTrangThai(rs.getString("status"));
        
        int nd = rs.getInt("approver_account_id");
        if (!rs.wasNull()) {
            sr.setNguoiDuyet(nd);
        }
        
        Timestamp ng = rs.getTimestamp("requested_at");
        if (ng != null) sr.setNgayGui(ng.toLocalDateTime());
        
        Timestamp ndt = rs.getTimestamp("approved_at");
        if (ndt != null) sr.setNgayDuyet(ndt.toLocalDateTime());
        
        sr.setGhiChuQuanLy(rs.getNString("manager_note"));
        
        sr.setTenNguoiGui(rs.getNString("SenderName"));
        sr.setTenNguoiNhan(rs.getNString("ReceiverName"));
        
        Date gDate = rs.getDate("GuiNgay");
        Time gBD = rs.getTime("GuiBD");
        Time gKT = rs.getTime("GuiKT");
        if (gDate != null && gBD != null && gKT != null) {
            sr.setCaGuiInfo(String.format("Ngày %s (%s - %s)", gDate, gBD, gKT));
        }
        
        Date nDate = rs.getDate("NhanNgay");
        Time nBD = rs.getTime("NhanBD");
        Time nKT = rs.getTime("NhanKT");
        if (nDate != null && nBD != null && nKT != null) {
            sr.setCaNhanInfo(String.format("Ngày %s (%s - %s)", nDate, nBD, nKT));
        } else {
            sr.setCaNhanInfo("Xin gánh ca (Không đổi ca)");
        }
        
        return sr;
    }
}
