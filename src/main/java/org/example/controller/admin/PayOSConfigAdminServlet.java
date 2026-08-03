package org.example.controller.admin;

import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.dto.payment.PayOSConfigurationStatus;
import org.example.dto.payment.PayOSConfigurationUpdateResult;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.service.PayOSConfigChallenge;
import org.example.service.PayOSConfigurationService;
import org.example.service.reset.ResetSecurityUtil;
import org.example.util.EmailUtil;

import java.io.IOException;

@WebServlet(urlPatterns = { "/admin/chi-nhanh/payos" })
public class PayOSConfigAdminServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(PayOSConfigAdminServlet.class);
    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        if (coSoId == null) {
            writeJson(resp, 400, errorJson("CoSoID không hợp lệ."));
            return;
        }

        try {
            PayOSConfigurationStatus status = payOSConfigurationService.getStatus(coSoId);
            JsonObject body = new JsonObject();
            body.addProperty("success", true);
            body.add("configuration", toJson(status));
            writeJson(resp, 200, body);
        } catch (PayOSConfigurationService.PayOSConfigurationException e) {
            writeJson(resp, e.getHttpStatus(), errorJson(e.getMessage()));
        } catch (Exception e) {
            logger.error("Lỗi khi tải cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            writeJson(resp, 500, errorJson("Lỗi hệ thống khi tải cấu hình PayOS."));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan admin = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (admin == null) {
            writeJson(resp, 403, errorJson("Bạn không có quyền thực hiện thao tác này."));
            return;
        }

        String action = req.getParameter("action");
        if ("verify-otp".equals(action)) {
            handleVerifyOtp(req, resp, admin);
        } else if ("resend-otp".equals(action)) {
            handleResendOtp(req, resp, admin);
        } else {
            handleRequestSave(req, resp, admin);
        }
    }

    /** Bước 1: merge/validate. Không đổi gì thật sự -> lưu ngay. Có đổi khóa -> gửi OTP, chưa ghi DB. */
    private void handleRequestSave(HttpServletRequest req, HttpServletResponse resp, TaiKhoan admin)
            throws IOException {
        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        if (coSoId == null) {
            writeJson(resp, 400, errorJson("CoSoID không hợp lệ."));
            return;
        }
        String clientId = req.getParameter("clientId");
        String apiKey = req.getParameter("apiKey");
        String checksumKey = req.getParameter("checksumKey");

        PayOSConfigurationService.PreparedUpdate prepared;
        try {
            prepared = payOSConfigurationService.prepareUpdate(coSoId, clientId, apiKey, checksumKey);
        } catch (PayOSConfigurationService.PayOSConfigurationException e) {
            writeJson(resp, e.getHttpStatus(), errorJson(e.getMessage()));
            return;
        } catch (Exception e) {
            logger.error("Lỗi khi kiểm tra cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            writeJson(resp, 500, errorJson("Lỗi hệ thống khi kiểm tra cấu hình PayOS."));
            return;
        }

        if (prepared.fieldsChanged.isEmpty()) {
            PayOSConfigurationUpdateResult result = payOSConfigurationService.persistPrepared(prepared, req, admin);
            JsonObject body = new JsonObject();
            body.addProperty("success", result.isSuccess());
            body.addProperty("requiresOtp", false);
            if (result.isSuccess()) {
                body.addProperty("message", "Không có thay đổi nào cần lưu.");
                body.add("configuration", toJson(result.getStatus()));
                writeJson(resp, 200, body);
            } else {
                writeJson(resp, result.getHttpStatus(), errorJson(result.getMessage()));
            }
            return;
        }

        // Lấy TaiKhoan mới nhất từ DB để tránh dùng email cũ đang cached trong session
        TaiKhoan adminFresh = loadFreshAdmin(admin);
        String adminEmail = adminFresh.getEmail();
        if (adminEmail == null || adminEmail.trim().isEmpty()) {
            logger.error("Admin AccountID={} không có email, không thể gửi OTP cấu hình PayOS cho CoSoID={}", admin.getAccountId(), coSoId);
            writeJson(resp, 400, errorJson("Tài khoản admin chưa được thiết lập địa chỉ email. Vui lòng cập nhật email cho tài khoản trước khi thực hiện thao tác này."));
            return;
        }

        String otp = ResetSecurityUtil.generateOtp();
        String maskedEmail = ResetSecurityUtil.maskEmail(adminEmail);
        PayOSConfigChallenge challenge = PayOSConfigChallenge.create(
                coSoId, admin.getAccountId(), maskedEmail,
                prepared.finalClientId, prepared.finalApiKey, prepared.finalChecksumKey,
                prepared.fieldsChanged, otp, System.currentTimeMillis());

        try {
            logger.info("Gửi OTP cấu hình PayOS CoSoID={} đến email={}", coSoId, maskedEmail);
            sendOtpEmail(adminFresh, prepared.coSo, otp, "V-SPORT — Mã xác thực cập nhật PayOS");
            logger.info("Gửi OTP thành công đến {}", maskedEmail);
        } catch (Exception e) {
            logger.error("Lỗi gửi email OTP cấu hình PayOS cho CoSoID={}, email={}: {}", coSoId, maskedEmail, e.getMessage(), e);
            writeJson(resp, 502, errorJson("Không thể gửi mã xác thực đến " + maskedEmail + ". Vui lòng kiểm tra cấu hình email hoặc thử lại sau."));
            return;
        }

        req.getSession(true).setAttribute("payosChallenge", challenge);

        JsonObject body = new JsonObject();
        body.addProperty("success", true);
        body.addProperty("requiresOtp", true);
        body.addProperty("maskedEmail", maskedEmail);
        body.addProperty("resendWaitSeconds", challenge.resendWaitSeconds(System.currentTimeMillis()));
        writeJson(resp, 200, body);
    }

    /** Bước 2: xác thực OTP. Đúng -> ghi DB + audit log. Sai/hết hạn/khóa -> không đổi DB. */
    private void handleVerifyOtp(HttpServletRequest req, HttpServletResponse resp, TaiKhoan admin)
            throws IOException {
        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        HttpSession session = req.getSession(false);
        PayOSConfigChallenge challenge = session != null
                ? (PayOSConfigChallenge) session.getAttribute("payosChallenge") : null;

        if (challenge == null || coSoId == null || challenge.getCoSoId() != coSoId
                || challenge.getAdminAccountId() != admin.getAccountId()) {
            writeJson(resp, 400, errorJson("Phiên xác thực OTP đã hết hạn hoặc không hợp lệ. Vui lòng thao tác lại từ đầu."));
            return;
        }

        String otp = req.getParameter("otp");
        PayOSConfigChallenge.VerifyResult result = challenge.verify(otp, System.currentTimeMillis());

        if (result == PayOSConfigChallenge.VerifyResult.OK) {
            PayOSConfigurationUpdateResult updateResult = payOSConfigurationService.persistChallenge(challenge, req, admin);
            session.removeAttribute("payosChallenge");
            if (!updateResult.isSuccess()) {
                writeJson(resp, updateResult.getHttpStatus(), errorJson(updateResult.getMessage()));
                return;
            }
            JsonObject body = new JsonObject();
            body.addProperty("success", true);
            body.addProperty("message", updateResult.getMessage());
            body.add("configuration", toJson(updateResult.getStatus()));
            writeJson(resp, 200, body);
            return;
        }

        if (result == PayOSConfigChallenge.VerifyResult.EXPIRED) {
            session.removeAttribute("payosChallenge");
            writeJson(resp, 400, errorJson("Mã OTP đã hết hạn. Vui lòng đóng và thao tác lại từ đầu."));
            return;
        }
        if (result == PayOSConfigChallenge.VerifyResult.LOCKED) {
            session.removeAttribute("payosChallenge");
            writeJson(resp, 429, errorJson("Bạn đã nhập sai quá 5 lần. Vui lòng đóng và thao tác lại từ đầu."));
            return;
        }
        if (result == PayOSConfigChallenge.VerifyResult.USED) {
            writeJson(resp, 400, errorJson("Mã OTP này đã được sử dụng."));
            return;
        }

        int attemptsLeft = PayOSConfigChallenge.MAX_ATTEMPTS - challenge.getAttemptCount();
        JsonObject body = new JsonObject();
        body.addProperty("success", false);
        body.addProperty("message", "Mã OTP không đúng. Còn " + attemptsLeft + " lần thử.");
        body.addProperty("attemptsLeft", attemptsLeft);
        writeJson(resp, 200, body);
    }

    /** Gửi lại OTP cho challenge đang mở, tôn trọng cooldown 60s và giới hạn 5 lần gửi. */
    private void handleResendOtp(HttpServletRequest req, HttpServletResponse resp, TaiKhoan admin)
            throws IOException {
        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        HttpSession session = req.getSession(false);
        PayOSConfigChallenge challenge = session != null
                ? (PayOSConfigChallenge) session.getAttribute("payosChallenge") : null;

        if (challenge == null || coSoId == null || challenge.getCoSoId() != coSoId
                || challenge.getAdminAccountId() != admin.getAccountId()) {
            writeJson(resp, 400, errorJson("Phiên xác thực OTP đã hết hạn. Vui lòng thao tác lại từ đầu."));
            return;
        }

        long now = System.currentTimeMillis();
        if (!challenge.canResend(now)) {
            JsonObject body = new JsonObject();
            body.addProperty("success", false);
            body.addProperty("message", "Vui lòng chờ trước khi gửi lại mã.");
            body.addProperty("resendWaitSeconds", challenge.resendWaitSeconds(now));
            writeJson(resp, 429, body);
            return;
        }

        // Lấy TaiKhoan mới nhất từ DB để tránh dùng email cũ đang cached trong session
        TaiKhoan adminFreshResend = loadFreshAdmin(admin);
        String adminEmail = adminFreshResend.getEmail();
        if (adminEmail == null || adminEmail.trim().isEmpty()) {
            writeJson(resp, 400, errorJson("Tài khoản admin chưa được thiết lập địa chỉ email."));
            return;
        }

        String otp = ResetSecurityUtil.generateOtp();
        CoSo coSo = null;
        try {
            coSo = payOSConfigurationService.prepareUpdate(coSoId, null, null, null).coSo;
        } catch (Exception ignored) {
            // best-effort chỉ để lấy tên cơ sở cho nội dung email; không chặn resend nếu lỗi
        }
        String maskedEmailResend = ResetSecurityUtil.maskEmail(adminEmail);
        try {
            logger.info("Gửi lại OTP cấu hình PayOS CoSoID={} đến email={}", coSoId, maskedEmailResend);
            sendOtpEmail(adminFreshResend, coSo, otp, "V-SPORT — Mã xác thực cập nhật PayOS (gửi lại)");
            logger.info("Gửi lại OTP thành công đến {}", maskedEmailResend);
        } catch (Exception e) {
            logger.error("Lỗi gửi lại email OTP PayOS cho CoSoID={}, email={}: {}", coSoId, maskedEmailResend, e.getMessage(), e);
            writeJson(resp, 502, errorJson("Không thể gửi lại mã đến " + maskedEmailResend + ". Vui lòng kiểm tra cấu hình email hoặc thử lại sau."));
            return;
        }
        challenge.applyResend(otp, now);

        JsonObject body = new JsonObject();
        body.addProperty("success", true);
        body.addProperty("resendWaitSeconds", challenge.resendWaitSeconds(now));
        writeJson(resp, 200, body);
    }

    /**
     * Lấy TaiKhoan mới nhất từ DB để đảm bảo email là email hiện tại,
     * tránh dùng email cũ đang cached trong session khi admin/manager đã đổi email.
     * Fallback về session nếu DB call thất bại.
     */
    private TaiKhoan loadFreshAdmin(TaiKhoan sessionAdmin) {
        try {
            TaiKhoan fresh = taiKhoanDAO.getAccountById(sessionAdmin.getAccountId());
            if (fresh != null) {
                if (!java.util.Objects.equals(fresh.getEmail(), sessionAdmin.getEmail())) {
                    logger.info("Email admin AccountID={} đã thay đổi từ {} → {}, dùng email mới",
                            sessionAdmin.getAccountId(),
                            ResetSecurityUtil.maskEmail(sessionAdmin.getEmail()),
                            ResetSecurityUtil.maskEmail(fresh.getEmail()));
                }
                return fresh;
            }
        } catch (Exception e) {
            logger.warn("Không thể load TaiKhoan mới từ DB cho AccountID={}, dùng session: {}",
                    sessionAdmin.getAccountId(), e.getMessage());
        }
        return sessionAdmin;
    }

    private void sendOtpEmail(TaiKhoan admin, CoSo coSo, String otp, String subject) throws Exception {
        String coSoName = coSo != null ? coSo.getTenCoSo() : "cơ sở đã chọn";
        String adminName = admin.getFullName() != null ? admin.getFullName() : admin.getUsername();
        String emailSubject = (subject != null && !subject.isBlank()) ? subject : "V-SPORT — Xác thực cấu hình PayOS";
        EmailUtil.sendHtmlEmail(admin.getEmail(), emailSubject,
                org.example.util.EmailTemplates.otpPayOSConfig(adminName, coSoName, otp));
    }

    private JsonObject toJson(PayOSConfigurationStatus status) {
        JsonObject json = new JsonObject();
        json.addProperty("coSoId", status.getCoSoId());
        json.addProperty("coSoName", status.getCoSoName());
        json.addProperty("status", status.getState().name());
        json.addProperty("clientIdConfigured", status.isClientIdConfigured());
        json.addProperty("apiKeyConfigured", status.isApiKeyConfigured());
        json.addProperty("checksumKeyConfigured", status.isChecksumKeyConfigured());
        json.addProperty("clientIdMasked", status.getClientIdMasked());
        json.addProperty("apiKeyMasked", status.getApiKeyMasked());
        json.addProperty("checksumKeyMasked", status.getChecksumKeyMasked());
        json.addProperty("lastUpdatedAt", status.getLastUpdatedAt());
        return json;
    }

    private JsonObject errorJson(String message) {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("message", message);
        return json;
    }

    private void writeJson(HttpServletResponse resp, int httpStatus, JsonObject body) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setStatus(httpStatus);
        resp.getWriter().write(body.toString());
    }

    private Integer parseCoSoId(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        try {
            int value = Integer.parseInt(raw.trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
