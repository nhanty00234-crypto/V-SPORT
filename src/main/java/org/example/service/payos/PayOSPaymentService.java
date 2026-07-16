package org.example.service.payos;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.PayOSPaymentAttemptDAO;
import org.example.dao.impl.PayOSPaymentAttemptDAOImpl;
import org.example.dto.payment.PayOSCreatePaymentResult;
import org.example.dto.payment.PayOSCredentials;
import org.example.dto.payment.PayOSPaymentAttemptStatus;
import org.example.dto.payment.PayOSPaymentAttemptView;
import org.example.service.PayOSConfigurationService;
import org.example.service.checkout.CheckoutResult;
import org.example.service.checkout.CheckoutService;
import org.example.util.DBUtil;
import vn.payos.PayOS;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;

import java.math.BigDecimal;
import java.sql.Connection;

/**
 * Tạo hoặc tái sử dụng payment link PayOS cho MAIN invoice của một ca chơi, dùng credentials
 * riêng của CoSo (không dùng biến môi trường toàn cục). KHÔNG đánh dấu hóa đơn đã thanh toán -
 * chỉ PayOSPaymentFinalizationService (gọi từ webhook/polling đã xác thực) mới được làm việc đó.
 */
public class PayOSPaymentService {
    private static final Logger logger = LogManager.getLogger(PayOSPaymentService.class);

    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();
    private final CheckoutService checkoutService = new CheckoutService();
    private final PayOSPaymentAttemptDAO attemptDAO = new PayOSPaymentAttemptDAOImpl();

    public PayOSCreatePaymentResult createOrReusePayment(int datSanId, int coSoId, String publicBaseUrl) {
        PayOSCredentials credentials = payOSConfigurationService.getCredentialsForPayment(coSoId);
        if (credentials == null) {
            return PayOSCreatePaymentResult.fail(409, "PAYOS_NOT_CONFIGURED", "Cơ sở chưa cấu hình đầy đủ PayOS.");
        }

        try (Connection c = DBUtil.getConnection()) {
            c.setAutoCommit(false);
            try {
                CheckoutResult checkout = checkoutService.finalizeLockedForPayment(c, datSanId, coSoId);
                if (checkout.alreadyPaid()) {
                    c.rollback();
                    return PayOSCreatePaymentResult.fail(409, "PAYMENT_ALREADY_PAID", "Hóa đơn đã được thanh toán trước đó.");
                }

                BigDecimal remaining = checkout.remainingAmount();
                if (remaining.signum() <= 0) {
                    c.rollback();
                    return PayOSCreatePaymentResult.fail(409, "PAYMENT_ALREADY_PAID", "Hóa đơn không còn số tiền cần thanh toán.");
                }

                PayOSPaymentAttemptDAO.Row active = attemptDAO.findActiveByHoaDonId(c, checkout.hoaDonId());
                if (active != null && active.status == PayOSPaymentAttemptStatus.PENDING
                        && active.checkoutUrl != null && active.qrCode != null) {
                    c.commit();
                    logger.info("Tái sử dụng PayOS payment attempt orderCode={} hoaDonId={}", active.orderCode, checkout.hoaDonId());
                    return PayOSCreatePaymentResult.ok(toView(active, PayOSPaymentAttemptStatus.PENDING));
                }
                if (active != null) {
                    // CREATING dở dang bất thường (ví dụ lần trước crash giữa insert và PayOS trả lời) -
                    // huỷ để tạo lại sạch, tránh vi phạm unique filtered index "một attempt sống/hóa đơn".
                    attemptDAO.markCancelledOrExpired(c, active.orderCode, PayOSPaymentAttemptStatus.FAILED);
                }

                String description = "VSPORT HD" + checkout.hoaDonId();
                long orderCode = attemptDAO.insertCreating(c, checkout.hoaDonId(), datSanId, coSoId, remaining, description);

                String returnUrl = publicBaseUrl + "/staff/checkin?action=payosReturn&orderCode=" + orderCode;
                String cancelUrl = publicBaseUrl + "/staff/checkin?action=payosCancel&orderCode=" + orderCode;

                CreatePaymentLinkResponse payOSResponse;
                PayOS client = PayOSClientFactory.create(credentials);
                try {
                    CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                            .orderCode(orderCode)
                            .amount(remaining.longValueExact())
                            .description(description)
                            .returnUrl(returnUrl)
                            .cancelUrl(cancelUrl)
                            .build();
                    payOSResponse = client.paymentRequests().create(request);
                } finally {
                    client.close();
                }

                attemptDAO.markPending(c, orderCode, payOSResponse.getPaymentLinkId(),
                        payOSResponse.getCheckoutUrl(), payOSResponse.getQrCode());
                c.commit();

                logger.info("Tạo PayOS payment attempt mới orderCode={} hoaDonId={} coSoId={}", orderCode, checkout.hoaDonId(), coSoId);
                return PayOSCreatePaymentResult.ok(new PayOSPaymentAttemptView(
                        checkout.hoaDonId(), orderCode, payOSResponse.getPaymentLinkId(), payOSResponse.getCheckoutUrl(),
                        payOSResponse.getQrCode(), remaining, description, PayOSPaymentAttemptStatus.PENDING));
            } catch (SecurityException e) {
                c.rollback();
                logger.warn("PAYOS_CREATE_FORBIDDEN datSanId={}, coSoId={} - ca chơi không thuộc cơ sở này", datSanId, coSoId);
                return PayOSCreatePaymentResult.fail(403, "FORBIDDEN", "Ca chơi không thuộc cơ sở của bạn.");
            } catch (IllegalArgumentException e) {
                c.rollback();
                return PayOSCreatePaymentResult.fail(404, "VALIDATION_ERROR", e.getMessage());
            } catch (IllegalStateException e) {
                c.rollback();
                return PayOSCreatePaymentResult.fail(409, "PAYMENT_CONFLICT", e.getMessage());
            } catch (Exception e) {
                c.rollback();
                // Không log e nếu message có thể chứa payload PayOS - chỉ log loại lỗi + datSanId.
                logger.error("PAYOS_CREATE_FAILED datSanId={}, coSoId={}, loại lỗi={}", datSanId, coSoId, e.getClass().getSimpleName());
                return PayOSCreatePaymentResult.fail(502, "PAYOS_CREATE_FAILED", "Không thể tạo mã thanh toán PayOS. Vui lòng thử lại hoặc chọn Tiền mặt.");
            } finally {
                c.setAutoCommit(true);
            }
        } catch (Exception connEx) {
            logger.error("PAYOS_CREATE_FAILED (kết nối DB) datSanId={}", datSanId, connEx);
            return PayOSCreatePaymentResult.fail(500, "DATABASE_ERROR", "Không thể kết nối cơ sở dữ liệu.");
        }
    }

    private PayOSPaymentAttemptView toView(PayOSPaymentAttemptDAO.Row row, PayOSPaymentAttemptStatus status) {
        return new PayOSPaymentAttemptView(row.hoaDonId, row.orderCode, row.paymentLinkId, row.checkoutUrl,
                row.qrCode, row.amount, row.description, status);
    }
}
