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
import org.example.dto.payment.PayOSConfigurationStatus;
import org.example.dto.payment.PayOSConfigurationUpdateResult;
import org.example.model.TaiKhoan;
import org.example.service.PayOSConfigurationService;

import java.io.IOException;

@WebServlet(urlPatterns = { "/admin/chi-nhanh/payos" })
public class PayOSConfigAdminServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(PayOSConfigAdminServlet.class);
    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();

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

        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        if (coSoId == null) {
            writeJson(resp, 400, errorJson("CoSoID không hợp lệ."));
            return;
        }

        String clientId = req.getParameter("clientId");
        String apiKey = req.getParameter("apiKey");
        String checksumKey = req.getParameter("checksumKey");

        try {
            PayOSConfigurationUpdateResult result = payOSConfigurationService.updateConfiguration(
                    coSoId, clientId, apiKey, checksumKey, req, admin);

            if (!result.isSuccess()) {
                writeJson(resp, result.getHttpStatus(), errorJson(result.getMessage()));
                return;
            }

            JsonObject body = new JsonObject();
            body.addProperty("success", true);
            body.addProperty("message", result.getMessage());
            body.add("configuration", toJson(result.getStatus()));
            writeJson(resp, 200, body);
        } catch (Exception e) {
            logger.error("Lỗi khi cập nhật cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            writeJson(resp, 500, errorJson("Lỗi hệ thống khi cập nhật cấu hình PayOS."));
        }
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
