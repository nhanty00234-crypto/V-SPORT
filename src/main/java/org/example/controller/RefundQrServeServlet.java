package org.example.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.service.RefundQrService;
import org.example.util.Constants;
import org.example.util.RefundQrUploadPaths;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

/**
 * Stream ảnh QR nhận tiền hoàn — dữ liệu nhạy cảm, KHÁC PromotionImageServeServlet (public,
 * cache dài hạn): mỗi request đều kiểm tra quyền truy cập (chỉ Customer sở hữu HoanTien hoặc
 * Manager đúng CoSoID được xem), không cache, không lộ filesystem path.
 *
 * GET /media/refund-qr?hoanTienId=X
 */
@WebServlet("/media/refund-qr")
public class RefundQrServeServlet extends HttpServlet {

    private final RefundQrService refundQrService = new RefundQrService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        int hoanTienId;
        try {
            hoanTienId = Integer.parseInt(req.getParameter("hoanTienId"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String relativePath = null;
        if (user.getRoleId() == Constants.ROLE_KHACH_HANG) {
            relativePath = refundQrService.getQrPathForOwner(hoanTienId, user.getAccountId());
        } else if (user.getRoleId() == Constants.ROLE_MANAGER) {
            int coSoId = getCoSoId(session);
            if (coSoId > 0) {
                relativePath = refundQrService.getQrPathForManager(hoanTienId, coSoId);
            }
        }

        if (relativePath == null || relativePath.isBlank()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File file = RefundQrUploadPaths.resolveSafely(relativePath);
        if (file == null || !file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = guessContentType(file.getName());
        if (contentType == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        resp.setContentType(contentType);
        resp.setContentLengthLong(file.length());
        // Dữ liệu nhạy cảm gắn với tài khoản ngân hàng thật — không cache ở proxy/browser.
        resp.setHeader("Cache-Control", "private, no-store, no-cache, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        Files.copy(file.toPath(), resp.getOutputStream());
    }

    private int getCoSoId(HttpSession session) {
        CoSo coSo = (CoSo) session.getAttribute("coSo");
        if (coSo != null) return coSo.getCoSoID();
        Object id = session.getAttribute("coSoId");
        if (id instanceof Integer) return (Integer) id;
        if (id instanceof String) {
            try { return Integer.parseInt((String) id); } catch (NumberFormatException ignored) {}
        }
        return 0;
    }

    private static String guessContentType(String fileName) {
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".webp")) return "image/webp";
        return null;
    }
}
