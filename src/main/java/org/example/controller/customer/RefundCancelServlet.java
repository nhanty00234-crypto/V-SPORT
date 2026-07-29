package org.example.controller.customer;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dao.CustomerBookingDAO;
import org.example.dao.HoanTienDAO;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.CustomerBookingDAOImpl;
import org.example.dao.impl.HoanTienDAOImpl;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.dto.CustomerBookingHistoryItem;
import org.example.model.Hoantien;
import org.example.model.Lichdatsan;
import org.example.model.TaiKhoan;
import org.example.util.DBUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(urlPatterns = {"/customer/refund-cancel/preview", "/customer/refund-cancel/confirm"})
public class RefundCancelServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(RefundCancelServlet.class.getName());
    private final Gson gson = new Gson();
    private final CustomerBookingDAO bookingDAO = new CustomerBookingDAOImpl();
    private final HoanTienDAO hoanTienDAO = new HoanTienDAOImpl();

    /**
     * Chính sách hủy kiểu nhà xe Phương Trang: phí giữ lại tăng dần khi hủy càng gần giờ khởi hành.
     * >=24h: 0% phí; 12-24h: 30%; 4-12h: 50%; <4h hoặc đã qua giờ: 100% (không hoàn).
     */
    private static BigDecimal cancellationFeeRate(double hoursBeforeStart) {
        if (hoursBeforeStart >= 24) return BigDecimal.ZERO;
        if (hoursBeforeStart >= 12) return new BigDecimal("0.30");
        if (hoursBeforeStart >= 4) return new BigDecimal("0.50");
        return BigDecimal.ONE;
    }

    private static String cancellationPolicyMessage(double hoursBeforeStart, BigDecimal feeRate) {
        if (hoursBeforeStart < 0) {
            return "Đã qua giờ bắt đầu — không được hoàn tiền.";
        }
        int pct = feeRate.multiply(new BigDecimal(100)).intValue();
        if (pct <= 0) {
            return "Hủy trước 24 giờ so với giờ bắt đầu — hoàn 100% số tiền đã thanh toán.";
        }
        return String.format("Hủy khi còn %.1f giờ trước giờ bắt đầu — phí hủy %d%%, hoàn %d%% số tiền đã thanh toán.",
                hoursBeforeStart, pct, 100 - pct);
    }

    /** Trả về null nếu không parse được ngày/giờ đặt sân (không áp phí, coi như hủy sớm để an toàn cho khách). */
    private static Double hoursBeforeStart(CustomerBookingHistoryItem booking) {
        try {
            LocalDate ngayDat = LocalDate.parse(booking.getNgayDat());
            LocalTime gioBatDau = LocalTime.parse(booking.getGioBatDau());
            LocalDateTime start = LocalDateTime.of(ngayDat, gioBatDau);
            return java.time.Duration.between(LocalDateTime.now(), start).toMinutes() / 60.0;
        } catch (Exception e) {
            return null;
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/customer/refund-cancel/preview".equals(path)) {
            handlePreview(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/customer/refund-cancel/confirm".equals(path)) {
            handleConfirm(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    private void handlePreview(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = req.getSession(false);
        TaiKhoan user = (session != null) ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Vui lòng đăng nhập.")));
            return;
        }

        String datSanIdStr = req.getParameter("datSanId");
        int accountId = user.getAccountId();
        
        LOGGER.info(String.format("[refund-cancel-preview] accountId=%d, datSanId=%s", accountId, datSanIdStr));

        if (datSanIdStr == null || datSanIdStr.isBlank()) {
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Thiếu mã đặt sân.")));
            return;
        }

        try {
            int datSanId = Integer.parseInt(datSanIdStr);
            CustomerBookingHistoryItem booking = bookingDAO.getBookingByDatSanId(datSanId, accountId);
            
            if (booking == null) {
                LOGGER.info(String.format("[refund-cancel-preview] NOT_FOUND datSanId=%d, accountId=%d", datSanId, accountId));
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Không tìm thấy đơn đặt sân.")));
                return;
            }

            // check if paid
            // A booking is considered paid if it's "Đã xác nhận" or if amountPaid > 0
            boolean paid = booking.isPaid();
            if (!paid && ("Đã xác nhận".equals(booking.getBookingStatus()) || "Đang sử dụng".equals(booking.getBookingStatus()))) {
                paid = true;
            }

            BigDecimal amountPaid = booking.getAmountPaid();
            if (amountPaid == null) amountPaid = BigDecimal.ZERO;

            LOGGER.info(String.format("[refund-cancel-preview] found datSanId=%d, paid=%b, amountPaid=%s", datSanId, paid, amountPaid.toString()));

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("datSanId", datSanId);
            response.put("paid", paid);
            response.put("amountPaid", amountPaid);

            if (!paid) {
                response.put("refundableAmount", BigDecimal.ZERO);
                response.put("cancellationFee", BigDecimal.ZERO);
                response.put("message", "Lịch chưa thanh toán nên không phát sinh hoàn tiền.");
            } else {
                Double hoursBeforeStart = hoursBeforeStart(booking);
                BigDecimal feeRate = hoursBeforeStart != null ? cancellationFeeRate(hoursBeforeStart) : BigDecimal.ZERO;
                BigDecimal cancellationFee = amountPaid.multiply(feeRate).setScale(0, RoundingMode.HALF_UP);
                BigDecimal refundableAmount = amountPaid.subtract(cancellationFee);

                response.put("cancellationFee", cancellationFee);
                response.put("refundableAmount", refundableAmount);
                if (hoursBeforeStart != null) {
                    response.put("hoursBeforeStart", Math.round(hoursBeforeStart * 10.0) / 10.0);
                    response.put("message", cancellationPolicyMessage(hoursBeforeStart, feeRate));
                } else {
                    response.put("message", "Bạn có thể gửi yêu cầu hoàn tiền qua hệ thống.");
                }
            }

            resp.getWriter().write(gson.toJson(response));
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in preview", e);
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Lỗi hệ thống.")));
        }
    }

    private void handleConfirm(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = req.getSession(false);
        TaiKhoan user = (session != null) ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Vui lòng đăng nhập.")));
            return;
        }

        int accountId = user.getAccountId();
        String datSanIdStr = req.getParameter("datSanId");
        String lyDoHuy = req.getParameter("lyDoHuy");
        String refundRequestedStr = req.getParameter("refundRequested");
        boolean refundRequested = !"false".equalsIgnoreCase(refundRequestedStr);

        if (datSanIdStr == null || datSanIdStr.isBlank()) {
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Thiếu mã đặt sân.")));
            return;
        }

        try {
            int datSanId = Integer.parseInt(datSanIdStr);
            CustomerBookingHistoryItem booking = bookingDAO.getBookingByDatSanId(datSanId, accountId);
            
            if (booking == null) {
                resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Không tìm thấy đơn đặt sân.")));
                return;
            }

            boolean paid = booking.isPaid();
            if (!paid && ("Đã xác nhận".equals(booking.getBookingStatus()) || "Đang sử dụng".equals(booking.getBookingStatus()))) {
                paid = true;
            }
            BigDecimal amountPaid = booking.getAmountPaid();
            if (amountPaid == null) amountPaid = BigDecimal.ZERO;

            Double hoursBeforeStart = hoursBeforeStart(booking);
            BigDecimal feeRate = hoursBeforeStart != null ? cancellationFeeRate(hoursBeforeStart) : BigDecimal.ZERO;
            BigDecimal cancellationFee = amountPaid.multiply(feeRate).setScale(0, RoundingMode.HALF_UP);
            BigDecimal refundableAmount = amountPaid.subtract(cancellationFee);

            LOGGER.info(String.format("[refund-cancel-confirm] accountId=%d, datSanId=%d, paid=%b, amountPaid=%s, cancellationFee=%s, refundableAmount=%s",
                    accountId, datSanId, paid, amountPaid.toString(), cancellationFee.toString(), refundableAmount.toString()));

            // transaction
            try (Connection conn = DBUtil.getConnection()) {
                conn.setAutoCommit(false);
                
                try {
                    // Update booking status
                    String updateLich = "UPDATE LichDatSan SET TrangThai = N'Đã hủy', GhiChu = ? WHERE DatSanID = ? AND AccountID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateLich)) {
                        ps.setString(1, lyDoHuy);
                        ps.setInt(2, datSanId);
                        ps.setInt(3, accountId);
                        ps.executeUpdate();
                    }

                    boolean refundCreated = false;
                    int hoanTienId = 0;
                    
                    if (paid && refundRequested && refundableAmount.compareTo(BigDecimal.ZERO) > 0) {
                        // Create refund record
                        // First check if already exists
                        String checkHt = "SELECT HoanTienID FROM HoanTien WHERE DatSanID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(checkHt)) {
                            ps.setInt(1, datSanId);
                            try (ResultSet rs = ps.executeQuery()) {
                                if (rs.next()) {
                                    hoanTienId = rs.getInt("HoanTienID");
                                    refundCreated = true;
                                }
                            }
                        }
                        
                        if (!refundCreated && booking.getHoaDonId() != null) {
                            String insertHt = "INSERT INTO HoanTien (DatSanID, AccountID, HoaDonID, CoSoID, SoTienHoan, SoTienDaThanhToan, SoTienDeNghiHoan, TrangThai, LyDo, ThoiGianYeuCau) " +
                                              "VALUES (?, ?, ?, (SELECT CoSoID FROM San WHERE SanID = ?), ?, ?, ?, 'CHO_BO_SUNG_THONG_TIN', ?, GETDATE())";
                            try (PreparedStatement ps = conn.prepareStatement(insertHt, PreparedStatement.RETURN_GENERATED_KEYS)) {
                                ps.setInt(1, datSanId);
                                ps.setInt(2, accountId);
                                ps.setInt(3, booking.getHoaDonId());
                                ps.setInt(4, booking.getSanId());
                                ps.setBigDecimal(5, refundableAmount);
                                ps.setBigDecimal(6, amountPaid);
                                ps.setBigDecimal(7, refundableAmount);
                                ps.setString(8, lyDoHuy);
                                ps.executeUpdate();

                                try (ResultSet keys = ps.getGeneratedKeys()) {
                                    if (keys.next()) {
                                        hoanTienId = keys.getInt(1);
                                        refundCreated = true;
                                    }
                                }
                            }
                        }
                    }

                    conn.commit();
                    
                    LOGGER.info(String.format("[refund-cancel-confirm] cancelled datSanId=%d, refundCreated=%b, hoanTienId=%d", datSanId, refundCreated, hoanTienId));
                    
                    Map<String, Object> response = new HashMap<>();
                    response.put("success", true);
                    if (refundCreated) {
                        response.put("redirectUrl", req.getContextPath() + "/customer/hoan-tien?id=" + hoanTienId);
                    } else {
                        response.put("redirectUrl", req.getContextPath() + "/customer/gio-hang");
                    }
                    resp.getWriter().write(gson.toJson(response));
                    
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error in confirm", e);
            resp.getWriter().write(gson.toJson(Map.of("success", false, "message", "Lỗi hệ thống.")));
        }
    }
}
