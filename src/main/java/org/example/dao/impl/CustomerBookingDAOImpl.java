package org.example.dao.impl;

import org.example.dao.CustomerBookingDAO;
import org.example.dto.CustomerBookingHistoryItem;
import org.example.util.DBUtil;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerBookingDAOImpl implements CustomerBookingDAO {
    private static final Logger LOGGER = Logger.getLogger(CustomerBookingDAOImpl.class.getName());

    @Override
    public List<CustomerBookingHistoryItem> getBookingHistory(int accountId) {
        List<CustomerBookingHistoryItem> list = new ArrayList<>();
        String sql = "SELECT lds.DatSanID, lds.SanID, hd.HoaDonID, s.TenSan, cs.TenCoSo, cs.DiaChi, " +
                     "lds.NgayDat, lds.GioBatDau, lds.GioKetThuc, lds.TrangThai, " +
                     "hd.PhuongThucThanhToan, hd.TongThanhToan, ht.TrangThai AS RefundStatus, ht.SoTienDaThanhToan " +
                     "FROM LichDatSan lds " +
                     "LEFT JOIN San s ON s.SanID = lds.SanID " +
                     "LEFT JOIN CoSo cs ON cs.CoSoID = s.CoSoID " +
                     "LEFT JOIN HoaDon hd ON hd.DatSanID = lds.DatSanID " +
                     "LEFT JOIN HoanTien ht ON ht.DatSanID = lds.DatSanID " +
                     "WHERE lds.AccountID = ? " +
                     "ORDER BY lds.NgayDat DESC, lds.GioBatDau DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToItem(rs));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting booking history for accountId=" + accountId, e);
        }
        return list;
    }

    @Override
    public CustomerBookingHistoryItem getBookingByDatSanId(int datSanId, int accountId) {
        String sql = "SELECT lds.DatSanID, lds.SanID, hd.HoaDonID, s.TenSan, cs.TenCoSo, cs.DiaChi, " +
                     "lds.NgayDat, lds.GioBatDau, lds.GioKetThuc, lds.TrangThai, " +
                     "hd.PhuongThucThanhToan, hd.TongThanhToan, ht.TrangThai AS RefundStatus, ht.SoTienDaThanhToan, lds.TongTienDuKien " +
                     "FROM LichDatSan lds " +
                     "LEFT JOIN San s ON s.SanID = lds.SanID " +
                     "LEFT JOIN CoSo cs ON cs.CoSoID = s.CoSoID " +
                     "LEFT JOIN HoaDon hd ON hd.DatSanID = lds.DatSanID " +
                     "LEFT JOIN HoanTien ht ON ht.DatSanID = lds.DatSanID " +
                     "WHERE lds.DatSanID = ? AND lds.AccountID = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerBookingHistoryItem item = mapRowToItem(rs);

                    // Fallback to TongTienDuKien if hd.TongThanhToan is null/zero but a total estimate exists.
                    if (item.getAmountPaid() == null || item.getAmountPaid().compareTo(BigDecimal.ZERO) == 0) {
                        item.setAmountPaid(rs.getBigDecimal("TongTienDuKien"));
                    }
                    return item;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error getting booking by datSanId=" + datSanId + ", accountId=" + accountId, e);
        }
        return null;
    }

    private CustomerBookingHistoryItem mapRowToItem(ResultSet rs) throws Exception {
        CustomerBookingHistoryItem item = new CustomerBookingHistoryItem();
        item.setDatSanId(rs.getInt("DatSanID"));
        item.setSanId(rs.getInt("SanID"));
        
        int hoaDonId = rs.getInt("HoaDonID");
        if (!rs.wasNull()) {
            item.setHoaDonId(hoaDonId);
        }
        
        item.setTenSan(rs.getString("TenSan"));
        item.setTenCoSo(rs.getString("TenCoSo"));
        item.setDiaChi(rs.getString("DiaChi"));
        
        if (rs.getDate("NgayDat") != null) {
            item.setNgayDat(rs.getDate("NgayDat").toString());
        }
        if (rs.getTime("GioBatDau") != null) {
            item.setGioBatDau(rs.getTime("GioBatDau").toString());
        }
        if (rs.getTime("GioKetThuc") != null) {
            item.setGioKetThuc(rs.getTime("GioKetThuc").toString());
        }
        
        item.setBookingStatus(rs.getString("TrangThai"));
        
        BigDecimal tongThanhToan = rs.getBigDecimal("TongThanhToan");
        if (tongThanhToan != null && tongThanhToan.compareTo(BigDecimal.ZERO) > 0) {
            item.setPaid(true);
            item.setAmountPaid(tongThanhToan);
        } else {
            item.setPaid(false);
            item.setAmountPaid(BigDecimal.ZERO);
            
            // Check if HoanTien has SoTienDaThanhToan
            BigDecimal st = rs.getBigDecimal("SoTienDaThanhToan");
            if (st != null && st.compareTo(BigDecimal.ZERO) > 0) {
                item.setPaid(true);
                item.setAmountPaid(st);
            }
        }
        
        item.setPaymentMethod(rs.getString("PhuongThucThanhToan"));
        item.setRefundStatus(rs.getString("RefundStatus"));
        
        return item;
    }
}
