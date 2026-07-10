package org.example.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.LichDatSanDAO;
import org.example.dao.impl.LichDatSanDAOImpl;
import org.example.model.Lichdatsan;
import org.example.service.PayOSService;
import vn.payos.exception.PayOSException;
import vn.payos.model.webhooks.WebhookData;

import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Webhook PUBLIC nhận thông báo thanh toán từ PayOS.
 * Route: /payos/webhook (không yêu cầu đăng nhập, không qua session).
 *
 * Chỉ xác nhận booking khi:
 * - Chữ ký webhook hợp lệ (xác thực bằng PayOS SDK, không tự verify thủ công)
 * - Booking tồn tại và đang ở trạng thái "Chờ thanh toán"
 * - Số tiền webhook khớp với TongTienDuKien trong DB
 * - Webhook thể hiện thanh toán thành công (code = "00")
 */
@WebServlet(urlPatterns = { "/payos/webhook" })
public class PayOSWebhookServlet extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(PayOSWebhookServlet.class.getName());
    private static final String PAYOS_SUCCESS_CODE = "00";

    private final LichDatSanDAO lichDatSanDAO = new LichDatSanDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String rawBody = readRawBody(req);

        WebhookData data;
        try {
            data = PayOSService.getInstance().verifyWebhook(rawBody);
        } catch (PayOSException e) {
            LOGGER.log(Level.WARNING, "PayOS webhook: xác thực chữ ký thất bại - " + e.getMessage());
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("text/plain; charset=UTF-8");
            resp.getWriter().write("Invalid webhook");
            return;
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "PayOS webhook: lỗi không xác định khi xác thực", e);
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("text/plain; charset=UTF-8");
            resp.getWriter().write("Invalid webhook");
            return;
        }

        Long orderCode = data.getOrderCode();
        Long amount = data.getAmount();
        String code = data.getCode();
        int datSanId = orderCode.intValue();

        LOGGER.info(String.format(
                "PayOS webhook nhan: orderCode=%d amount=%d code=%s -> DatSanID=%d",
                orderCode, amount, code, datSanId));

        Lichdatsan lich = lichDatSanDAO.getLichById(datSanId);
        if (lich == null) {
            LOGGER.warning(String.format(
                    "PayOS webhook: khong tim thay booking DatSanID=%d (orderCode=%d), bo qua",
                    datSanId, orderCode));
            respondOk(resp, "Booking not found, ignored");
            return;
        }

        String currentStatus = lich.getTrangThai();
        LOGGER.info(String.format("PayOS webhook: DatSanID=%d trang thai hien tai=%s", datSanId, currentStatus));

        if ("Đã xác nhận".equals(currentStatus)) {
            LOGGER.info(String.format(
                    "PayOS webhook: DatSanID=%d da 'Da xac nhan' truoc do, bo qua (idempotent)", datSanId));
            respondOk(resp, "Already confirmed");
            return;
        }

        if ("Đã hủy".equals(currentStatus)) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d da bi huy truoc do, khong doi lai thanh 'Da xac nhan'", datSanId));
            respondOk(resp, "Already cancelled, ignored");
            return;
        }

        if (!"Chờ thanh toán".equals(currentStatus)) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d dang o trang thai khong mong doi '%s', bo qua",
                    datSanId, currentStatus));
            respondOk(resp, "Unexpected status, ignored");
            return;
        }

        BigDecimal expectedAmount = lich.getTongTienDuKien();
        if (expectedAmount == null || BigDecimal.valueOf(amount).compareTo(expectedAmount) != 0) {
            // Số tiền không khớp: KHÔNG update DB để tránh xác nhận sai tiền.
            // Trả 200 OK (thay vì 400) vì amount trong webhook là cố định - PayOS retry
            // lại sẽ luôn mismatch giống hệt, retry không giúp giải quyết vấn đề. Booking
            // vẫn giữ nguyên "Chờ thanh toán" (an toàn), cảnh báo được ghi log để vận hành
            // theo dõi thủ công thay vì dựa vào cơ chế retry của webhook.
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d SO TIEN KHONG KHOP (webhook=%d, DB=%s), khong xac nhan",
                    datSanId, amount, expectedAmount));
            respondOk(resp, "Amount mismatch, ignored");
            return;
        }

        if (!PAYOS_SUCCESS_CODE.equals(code)) {
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d webhook code='%s' khong phai thanh cong, khong xac nhan",
                    datSanId, code));
            respondOk(resp, "Payment not successful, ignored");
            return;
        }

        boolean updated = confirmBookingPaid(datSanId);
        if (updated) {
            LOGGER.info(String.format(
                    "PayOS webhook: DatSanID=%d da duoc xac nhan 'Da xac nhan' thanh cong", datSanId));
            respondOk(resp, "Confirmed");
        } else {
            // Trạng thái đã đổi giữa lúc đọc và lúc update (race condition) - an toàn,
            // không throw lỗi để tránh PayOS retry vô ích.
            LOGGER.warning(String.format(
                    "PayOS webhook: DatSanID=%d update that bai (trang thai da doi truoc do)", datSanId));
            respondOk(resp, "Update skipped");
        }
    }

    private boolean confirmBookingPaid(int datSanId) {
        String sql = "UPDATE LichDatSan " +
                "SET TrangThai = N'Đã xác nhận', " +
                "    GhiChu = CONCAT(ISNULL(GhiChu, N''), N' [PayOS webhook xác nhận thanh toán thành công]') " +
                "WHERE DatSanID = ? AND TrangThai = N'Chờ thanh toán'";
        try (java.sql.Connection conn = org.example.util.DBUtil.getConnection();
                java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, datSanId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (java.sql.SQLException e) {
            LOGGER.log(Level.SEVERE, "PayOS webhook: loi SQL khi update DatSanID=" + datSanId, e);
            return false;
        }
    }

    private String readRawBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new java.io.InputStreamReader(req.getInputStream(), StandardCharsets.UTF_8))) {
            char[] buffer = new char[1024];
            int read;
            while ((read = reader.read(buffer)) != -1) {
                sb.append(buffer, 0, read);
            }
        }
        return sb.toString();
    }

    private void respondOk(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_OK);
        resp.setContentType("text/plain; charset=UTF-8");
        resp.getWriter().write(message);
    }
}
