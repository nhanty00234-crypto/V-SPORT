package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.model.TaiKhoan;
import org.example.service.manager.SanQRService;
import org.example.service.manager.SanService;
import org.example.util.Constants;
import org.example.util.QrCodeRenderer;

import java.io.IOException;
import java.text.Normalizer;
import java.util.regex.Pattern;

/**
 * Sinh ảnh PNG mã QR của một sân, chỉ cho Manager sở hữu sân đó. KHÔNG nhận
 * token thô qua query - chỉ nhận sanId, tự tra token phía server (xem
 * SanQRService.findReadOnlyBySanId) rồi build URL công khai để encode - token
 * không bao giờ xuất hiện trong request/response ngoài chính ảnh QR.
 *
 * Query: ?sanId=..&mode=preview|download
 * preview -> Content-Disposition: inline, size nhỏ (360px)
 * download -> Content-Disposition: attachment, size lớn (1024px), no-store
 */
@WebServlet({"/manager/ma-qr-san-anh"})
public class SanQRImageServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(SanQRImageServlet.class);
    private static final Pattern UNSAFE_FILENAME_CHARS = Pattern.compile("[^a-zA-Z0-9_-]");

    private final SanService sanService;
    private final SanQRService sanQRService;

    public SanQRImageServlet() {
        this.sanService = new SanService();
        this.sanQRService = new SanQRService();
    }

    public SanQRImageServlet(SanService sanService, SanQRService sanQRService) {
        this.sanService = sanService;
        this.sanQRService = sanQRService;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
        if (manager == null || manager.getRoleId() != Constants.ROLE_MANAGER || manager.getCoSoId() == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int sanId;
        try {
            sanId = Integer.parseInt(request.getParameter("sanId"));
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "sanId không hợp lệ.");
            return;
        }

        San san;
        try {
            san = sanService.getSanById(sanId, manager.getCoSoId());
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý sân này.");
            return;
        }

        SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
        if (sanQR == null || SanQR.REVOKED.equals(sanQR.getTrangThai())) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Sân chưa có mã QR hợp lệ.");
            return;
        }

        String publicUrl = buildPublicUrl(request, sanQR.getToken().toString());
        boolean download = "download".equalsIgnoreCase(request.getParameter("mode"));
        int size = download ? 1024 : 360;

        byte[] png;
        try {
            png = QrCodeRenderer.toPngBytes(publicUrl, size);
        } catch (Exception e) {
            logger.error("Lỗi sinh ảnh QR sanId={}: {}", sanId, e.getMessage(), e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Không thể tạo ảnh QR. Vui lòng thử lại.");
            return;
        }

        response.setContentType("image/png");
        response.setHeader("Cache-Control", "no-store");
        if (download) {
            response.setHeader("Content-Disposition", "attachment; filename=\"" + safeFileName(san.getTenSan()) + "\"");
        } else {
            response.setHeader("Content-Disposition", "inline");
        }
        response.setContentLength(png.length);
        response.getOutputStream().write(png);
        response.getOutputStream().flush();
    }

    private String safeFileName(String tenSan) {
        String base = tenSan == null ? "san" : tenSan;
        String normalized = Normalizer.normalize(base, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "")
                .replace('đ', 'd').replace('Đ', 'D');
        String sanitized = UNSAFE_FILENAME_CHARS.matcher(normalized.replace(' ', '-')).replaceAll("");
        if (sanitized.isBlank()) sanitized = "san";
        return "VSPORT-" + sanitized + "-QR.png";
    }

    /**
     * Build URL public {scheme}://{host}:{port}{contextPath}/qr/{token}. Route
     * /qr/{token} thuộc phạm vi QR-03 (resolve công khai) - KHÔNG được triển
     * khai ở QR-02 - ảnh QR sinh ra hôm nay sẽ chỉ hoạt động khi QR-03 xong,
     * đây là hành vi CHỦ Ý theo đúng thứ tự task, không phải thiếu sót.
     * Không có cấu hình APP_PUBLIC_BASE_URL trong project -> luôn suy từ chính
     * request hiện tại (dev và prod đều theo domain thật sự đang được truy cập).
     */
    private String buildPublicUrl(HttpServletRequest request, String token) {
        String scheme = request.getScheme();
        String host = request.getServerName();
        int port = request.getServerPort();
        StringBuilder sb = new StringBuilder();
        sb.append(scheme).append("://").append(host);
        boolean defaultPort = ("http".equals(scheme) && port == 80) || ("https".equals(scheme) && port == 443);
        if (!defaultPort) sb.append(':').append(port);
        sb.append(request.getContextPath()).append("/qr/").append(token);
        return sb.toString();
    }
}
