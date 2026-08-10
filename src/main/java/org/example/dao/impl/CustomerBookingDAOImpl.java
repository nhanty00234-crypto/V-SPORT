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
        String sql = "SELECT lds.booking_id, lds.court_id, hd.invoice_id, s.court_name, cs.facility_name, cs.address, " +
                     "lds.booking_date, lds.start_time, lds.end_time, lds.status, " +
                     "hd.payment_method, hd.grand_total, ht.status AS RefundStatus, ht.paid_amount " +
                     "FROM bookings lds " +
                     "LEFT JOIN courts s ON s.court_id = lds.court_id " +
                     "LEFT JOIN facilities cs ON cs.facility_id = s.facility_id " +
                     "LEFT JOIN invoices hd ON hd.booking_id = lds.booking_id " +
                     "LEFT JOIN refunds ht ON ht.booking_id = lds.booking_id " +
                     "WHERE lds.account_id = ? " +
                     "ORDER BY lds.booking_date DESC, lds.start_time DESC";

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
        String sql = "SELECT lds.booking_id, lds.court_id, hd.invoice_id, s.court_name, cs.facility_name, cs.address, " +
                     "lds.booking_date, lds.start_time, lds.end_time, lds.status, " +
                     "hd.payment_method, hd.grand_total, ht.status AS RefundStatus, ht.paid_amount, lds.estimated_total " +
                     "FROM bookings lds " +
                     "LEFT JOIN courts s ON s.court_id = lds.court_id " +
                     "LEFT JOIN facilities cs ON cs.facility_id = s.facility_id " +
                     "LEFT JOIN invoices hd ON hd.booking_id = lds.booking_id " +
                     "LEFT JOIN refunds ht ON ht.booking_id = lds.booking_id " +
                     "WHERE lds.booking_id = ? AND lds.account_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            ps.setInt(2, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CustomerBookingHistoryItem item = mapRowToItem(rs);

                    // Fallback to TongTienDuKien if hd.TongThanhToan is null/zero but a total estimate exists.
                    if (item.getAmountPaid() == null || item.getAmountPaid().compareTo(BigDecimal.ZERO) == 0) {
                        item.setAmountPaid(rs.getBigDecimal("estimated_total"));
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
        item.setDatSanId(rs.getInt("booking_id"));
        item.setSanId(rs.getInt("court_id"));
        
        int hoaDonId = rs.getInt("invoice_id");
        if (!rs.wasNull()) {
            item.setHoaDonId(hoaDonId);
        }
        
        item.setTenSan(rs.getString("court_name"));
        item.setTenCoSo(rs.getString("facility_name"));
        item.setDiaChi(rs.getString("address"));
        
        if (rs.getDate("booking_date") != null) {
            item.setNgayDat(rs.getDate("booking_date").toString());
        }
        if (rs.getTime("start_time") != null) {
            item.setGioBatDau(rs.getTime("start_time").toString());
        }
        if (rs.getTime("end_time") != null) {
            item.setGioKetThuc(rs.getTime("end_time").toString());
        }
        
        item.setBookingStatus(rs.getString("status"));
        
        BigDecimal tongThanhToan = rs.getBigDecimal("grand_total");
        if (tongThanhToan != null && tongThanhToan.compareTo(BigDecimal.ZERO) > 0) {
            item.setPaid(true);
            item.setAmountPaid(tongThanhToan);
        } else {
            item.setPaid(false);
            item.setAmountPaid(BigDecimal.ZERO);
            
            // Check if HoanTien has SoTienDaThanhToan
            BigDecimal st = rs.getBigDecimal("paid_amount");
            if (st != null && st.compareTo(BigDecimal.ZERO) > 0) {
                item.setPaid(true);
                item.setAmountPaid(st);
            }
        }
        
        item.setPaymentMethod(rs.getString("payment_method"));
        item.setRefundStatus(rs.getString("RefundStatus"));
        
        return item;
    }
}
