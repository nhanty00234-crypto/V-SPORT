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
        String sql = "INSERT INTO CaLamViec_SwapRequest (AccountID_Gui, CaLamViecID_Gui, AccountID_Nhan, CaLamViecID_Nhan, LyDo, TrangThai) VALUES (?, ?, ?, ?, ?, ?)";
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
        String sql = "UPDATE CaLamViec_SwapRequest SET TrangThai = ?, NguoiDuyet = ?, NgayDuyet = ?, GhiChuQuanLy = ? WHERE SwapRequestID = ?";
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
        String sql = getSelectQuery() + " WHERE sr.SwapRequestID = ?";
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
        String sql = getSelectQuery() + " JOIN Accounts s_acc ON sr.AccountID_Gui = s_acc.AccountID WHERE s_acc.CoSoID = ? ORDER BY sr.NgayGui DESC";
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
        String sql = getSelectQuery() + " WHERE sr.AccountID_Gui = ? OR sr.AccountID_Nhan = ? ORDER BY sr.NgayGui DESC";
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

    private String getSelectQuery() {
        return "SELECT sr.*, acc1.FullName as SenderName, acc2.FullName as ReceiverName, " +
               "c1.NgayLam as GuiNgay, c1.GioBatDau as GuiBD, c1.GioKetThuc as GuiKT, " +
               "c2.NgayLam as NhanNgay, c2.GioBatDau as NhanBD, c2.GioKetThuc as NhanKT " +
               "FROM CaLamViec_SwapRequest sr " +
               "JOIN Accounts acc1 ON sr.AccountID_Gui = acc1.AccountID " +
               "JOIN Accounts acc2 ON sr.AccountID_Nhan = acc2.AccountID " +
               "JOIN CaLamViec c1 ON sr.CaLamViecID_Gui = c1.CaLamViecID " +
               "LEFT JOIN CaLamViec c2 ON sr.CaLamViecID_Nhan = c2.CaLamViecID";
    }

    private CaLamViecSwapRequest mapResultSet(ResultSet rs) throws SQLException {
        CaLamViecSwapRequest sr = new CaLamViecSwapRequest();
        sr.setSwapRequestId(rs.getInt("SwapRequestID"));
        sr.setAccountIdGui(rs.getInt("AccountID_Gui"));
        sr.setCaLamViecIdGui(rs.getInt("CaLamViecID_Gui"));
        sr.setAccountIdNhan(rs.getInt("AccountID_Nhan"));
        
        int nhanId = rs.getInt("CaLamViecID_Nhan");
        if (!rs.wasNull()) {
            sr.setCaLamViecIdNhan(nhanId);
        }
        
        sr.setLyDo(rs.getNString("LyDo"));
        sr.setTrangThai(rs.getString("TrangThai"));
        
        int nd = rs.getInt("NguoiDuyet");
        if (!rs.wasNull()) {
            sr.setNguoiDuyet(nd);
        }
        
        Timestamp ng = rs.getTimestamp("NgayGui");
        if (ng != null) sr.setNgayGui(ng.toLocalDateTime());
        
        Timestamp ndt = rs.getTimestamp("NgayDuyet");
        if (ndt != null) sr.setNgayDuyet(ndt.toLocalDateTime());
        
        sr.setGhiChuQuanLy(rs.getNString("GhiChuQuanLy"));
        
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
