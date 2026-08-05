package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.persistence.EntityManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.LichDatSanDichVuDAO;
import org.example.dao.impl.LichDatSanDichVuDAOImpl;
import org.example.dto.payment.PayOSCreatePaymentResult;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.service.manager.SanQRService;
import org.example.service.payos.PayOSPaymentService;
import org.example.util.JPAUtil;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

/**
 * Nút "Thanh toán" trên trang QR khách. Chỉ nhận sanId (không tin AccountID/CoSoID/DatSanID/số
 * tiền từ client) - tự resolve QR còn hiệu lực -> San -> CoSo -> phiên sân đang "Đang sử dụng"
 * -> tái sử dụng nguyên PayOSPaymentService.createOrReusePayment đã dùng cho luồng check-in,
 * KHÔNG cài lại logic PayOS/hóa đơn ở đây.
 */
@WebServlet("/api/qr/thanh-toan")
public class QRPaymentApiServlet extends HttpServlet {

    private final SanQRService sanQRService = new SanQRService();
    private final LichDatSanDichVuDAO lichDatSanDichVuDAO = new LichDatSanDichVuDAOImpl();
    private final PayOSPaymentService payOSPaymentService = new PayOSPaymentService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        int sanId;
        try {
            sanId = Integer.parseInt(req.getParameter("sanId"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Thiếu sanId.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }

        SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
        if (sanQR == null || !sanQR.isActive()) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            out.put("message", "Mã QR của sân này không còn hiệu lực.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }

        int coSoId;
        EntityManager em = JPAUtil.getEntityManager();
        try {
            San san = em.find(San.class, sanId);
            if (san == null || san.isDeleted()) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.put("success", false);
                out.put("message", "Không tìm thấy sân.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            coSoId = san.getCoSoID();
        } finally {
            em.close();
        }

        Integer datSanId;
        try {
            datSanId = lichDatSanDichVuDAO.findActiveDatSanIdBySan(sanId);
        } catch (SQLException e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.put("success", false);
            out.put("message", "Đã xảy ra lỗi hệ thống.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        if (datSanId == null) {
            out.put("success", false);
            out.put("message", "Hiện chưa có hóa đơn cần thanh toán. Vui lòng liên hệ nhân viên.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }

        String publicBaseUrl = resolvePublicBaseUrl(req);
        PayOSCreatePaymentResult result = payOSPaymentService.createOrReusePayment(datSanId, coSoId, publicBaseUrl);
        if (!result.isSuccess()) {
            resp.setStatus(result.getHttpStatus());
            out.put("success", false);
            out.put("message", result.getMessage());
            resp.getWriter().write(gson.toJson(out));
            return;
        }

        Map<String, Object> data = new HashMap<>();
        data.put("checkoutUrl", result.getPayment().getCheckoutUrl());
        data.put("qrCode", result.getPayment().getQrCode());
        data.put("amount", result.getPayment().getAmount());
        out.put("success", true);
        out.put("data", data);
        resp.getWriter().write(gson.toJson(out));
    }

    private String resolvePublicBaseUrl(HttpServletRequest req) {
        String configured = System.getenv("PUBLIC_BASE_URL");
        if (configured != null && !configured.isBlank()) {
            return configured.trim().replaceAll("/$", "");
        }
        String scheme = req.getScheme();
        String host = req.getServerName();
        int port = req.getServerPort();
        boolean defaultPort = ("http".equals(scheme) && port == 80) || ("https".equals(scheme) && port == 443);
        StringBuilder sb = new StringBuilder();
        sb.append(scheme).append("://").append(host);
        if (!defaultPort) sb.append(':').append(port);
        sb.append(req.getContextPath());
        return sb.toString();
    }
}
