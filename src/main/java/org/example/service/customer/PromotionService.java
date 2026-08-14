package org.example.service.customer;

import org.example.model.KhuyenMai;
import org.example.util.DBUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

public class PromotionService {

    private static final Logger logger = LogManager.getLogger(PromotionService.class);

    public static class PromotionResult {
        private final boolean valid;
        private final String message;
        private final BigDecimal discountAmount;
        private final BigDecimal finalAmount;
        private final KhuyenMai khuyenMai;

        public PromotionResult(boolean valid, String message, BigDecimal discountAmount, BigDecimal finalAmount, KhuyenMai khuyenMai) {
            this.valid = valid;
            this.message = message;
            this.discountAmount = discountAmount;
            this.finalAmount = finalAmount;
            this.khuyenMai = khuyenMai;
        }

        public boolean isValid() { return valid; }
        public String getMessage() { return message; }
        public BigDecimal getDiscountAmount() { return discountAmount; }
        public BigDecimal getFinalAmount() { return finalAmount; }
        public KhuyenMai getKhuyenMai() { return khuyenMai; }
    }

    /**
     * Pure calculation logic for unit testing & validation
     */
    public PromotionResult calculateDiscount(KhuyenMai km, BigDecimal originalAmount, Integer coSoId, LocalDate bookingDate,
                                              BigDecimal giaTriToiThieu, BigDecimal giamToiDa, int userUsageCount, int maxUsagePerUser) {
        if (km == null) {
            return new PromotionResult(false, "Mã khuyến mãi không tồn tại.", BigDecimal.ZERO, originalAmount, null);
        }
        if (!"Hoạt động".equalsIgnoreCase(km.getTrangThai()) && !"ACTIVE".equalsIgnoreCase(km.getTrangThai())) {
            return new PromotionResult(false, "Mã khuyến mãi hiện không khả dụng.", BigDecimal.ZERO, originalAmount, km);
        }
        if (bookingDate != null) {
            if (km.getNgayBatDau() != null && bookingDate.isBefore(km.getNgayBatDau())) {
                return new PromotionResult(false, "Mã khuyến mãi chưa đến thời gian áp dụng.", BigDecimal.ZERO, originalAmount, km);
            }
            if (km.getNgayKetThuc() != null && bookingDate.isAfter(km.getNgayKetThuc())) {
                return new PromotionResult(false, "Mã khuyến mãi đã hết hạn sử dụng.", BigDecimal.ZERO, originalAmount, km);
            }
        }
        if (km.getCoSoID() != null && coSoId != null && !km.getCoSoID().equals(coSoId)) {
            return new PromotionResult(false, "Mã khuyến mãi không áp dụng cho cơ sở này.", BigDecimal.ZERO, originalAmount, km);
        }
        if (km.getSoLanToiDa() != null && km.getSoLanDaDung() >= km.getSoLanToiDa()) {
            return new PromotionResult(false, "Mã khuyến mãi đã hết tổng lượt sử dụng trên hệ thống.", BigDecimal.ZERO, originalAmount, km);
        }
        if (giaTriToiThieu != null && originalAmount.compareTo(giaTriToiThieu) < 0) {
            return new PromotionResult(false, "Đơn hàng phải từ " + String.format("%,.0f", giaTriToiThieu) + " VNĐ mới được áp dụng mã này.", BigDecimal.ZERO, originalAmount, km);
        }
        if (maxUsagePerUser > 0 && userUsageCount >= maxUsagePerUser) {
            return new PromotionResult(false, "Bạn đã sử dụng hết số lần cho phép của mã khuyến mãi này.", BigDecimal.ZERO, originalAmount, km);
        }

        BigDecimal discount = BigDecimal.ZERO;
        String loaiGiam = km.getLoaiGiam() != null ? km.getLoaiGiam().trim().toUpperCase() : "";

        if (loaiGiam.contains("PERCENT") || loaiGiam.contains("PHAN_TRAM") || loaiGiam.contains("%")) {
            BigDecimal rate = BigDecimal.valueOf(km.getGiaTriGiam()).divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP);
            discount = originalAmount.multiply(rate).setScale(0, RoundingMode.HALF_UP);
        } else {
            discount = BigDecimal.valueOf(km.getGiaTriGiam()).setScale(0, RoundingMode.HALF_UP);
        }

        if (giamToiDa != null && giamToiDa.compareTo(BigDecimal.ZERO) > 0 && discount.compareTo(giamToiDa) > 0) {
            discount = giamToiDa;
        }

        if (discount.compareTo(originalAmount) > 0) {
            discount = originalAmount;
        }

        BigDecimal finalAmount = originalAmount.subtract(discount);
        return new PromotionResult(true, "Áp dụng mã khuyến mãi thành công! Bạn được giảm " + String.format("%,.0f", discount) + " VNĐ.", discount, finalAmount, km);
    }

    public PromotionResult calculateDiscount(KhuyenMai km, BigDecimal originalAmount, Integer coSoId, LocalDate bookingDate) {
        return calculateDiscount(km, originalAmount, coSoId, bookingDate, null, null, 0, 0);
    }

    public PromotionResult validateAndCalculate(String maCode, BigDecimal originalAmount, Integer coSoId, LocalDate bookingDate, Integer accountId) {
        if (maCode == null || maCode.trim().isEmpty()) {
            return new PromotionResult(false, "Mã khuyến mãi không được để rỗng.", BigDecimal.ZERO, originalAmount, null);
        }

        String cleanCode = maCode.trim().toUpperCase();
        String sqlKM = "SELECT KhuyenMaiID, MaCode, MoTa, LoaiGiam, GiaTriGiam, NgayBatDau, NgayKetThuc, SoLanToiDa, SoLanDaDung, CoSoID, TrangThai, GiaTriToiThieu, GiamToiDa FROM KhuyenMai WHERE UPPER(MaCode) = ?";
        String sqlUserCount = "SELECT COUNT(*) FROM LichSuKhuyenMai WHERE AccountID = ? AND KhuyenMaiID = ?";

        try (Connection conn = DBUtil.getConnection()) {
            KhuyenMai km = null;
            BigDecimal giaTriToiThieu = null;
            BigDecimal giamToiDa = null;
            try (PreparedStatement ps = conn.prepareStatement(sqlKM)) {
                ps.setString(1, cleanCode);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return new PromotionResult(false, "Mã khuyến mãi '" + cleanCode + "' không tồn tại.", BigDecimal.ZERO, originalAmount, null);
                    }
                    km = new KhuyenMai();
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
                    giaTriToiThieu = rs.getBigDecimal("GiaTriToiThieu");
                    giamToiDa = rs.getBigDecimal("GiamToiDa");
                }
            }

            int userUsageCount = 0;
            if (accountId != null && accountId > 0 && km != null) {
                try (PreparedStatement ps = conn.prepareStatement(sqlUserCount)) {
                    ps.setInt(1, accountId);
                    ps.setInt(2, km.getKhuyenMaiID());
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) userUsageCount = rs.getInt(1);
                    }
                }
            }

            return calculateDiscount(km, originalAmount, coSoId, bookingDate, giaTriToiThieu, giamToiDa, userUsageCount, 1);
        } catch (SQLException e) {
            logger.error("Error validating promotion code {}: {}", cleanCode, e.getMessage(), e);
            return new PromotionResult(false, "Lỗi kiểm tra mã khuyến mãi.", BigDecimal.ZERO, originalAmount, null);
        }
    }

    public PromotionResult validateAndCalculate(String maCode, BigDecimal originalAmount, Integer coSoId, LocalDate bookingDate) {
        return validateAndCalculate(maCode, originalAmount, coSoId, bookingDate, null);
    }
}
