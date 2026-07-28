package org.example.controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.util.PromotionUploadPaths;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

/**
 * Stream ảnh khuyến mãi từ thư mục upload NGOÀI webapp (xem PromotionUploadPaths) - ảnh
 * không nằm trong src/main/webapp nên Tomcat không tự phục vụ tĩnh như /uploads/covers,
 * /uploads/courts của các module khác; servlet này đóng vai trò đó cho riêng module khuyến
 * mãi. Chỉ trả về file nằm trong thư mục promotions đã cấu hình (chặn path traversal qua
 * PromotionUploadPaths.resolveSafely) - không bao giờ lộ filesystem path tuyệt đối ra response.
 */
@WebServlet("/media/promotions/*")
public class PromotionImageServeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.isBlank() || "/".equals(pathInfo)) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String relativePath = "promotions" + pathInfo;
        File file = PromotionUploadPaths.resolveSafely(relativePath);
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
        // Tên file là UUID duy nhất theo từng phiên bản ảnh (thay ảnh = file mới) nên có thể
        // cache dài hạn an toàn - không có tình huống cùng URL nhưng nội dung đổi.
        resp.setHeader("Cache-Control", "public, max-age=31536000, immutable");
        Files.copy(file.toPath(), resp.getOutputStream());
    }

    private static String guessContentType(String fileName) {
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".webp")) return "image/webp";
        return null;
    }
}
