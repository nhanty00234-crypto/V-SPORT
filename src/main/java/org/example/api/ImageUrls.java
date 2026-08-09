package org.example.api;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Chuẩn hóa đường dẫn ảnh trước khi trả cho mobile (mục XIX spec).
 *
 * Dữ liệu hiện có trong DB pha trộn nhiều dạng:
 *  - URL tuyệt đối (Cloudinary, Unsplash) -> giữ nguyên.
 *  - Đường dẫn tương đối trong webapp ("assets/...", "/uploads/...") -> ghép thành URL HTTP
 *    tuyệt đối theo host của chính request để Flutter tải được.
 *  - Đường dẫn filesystem của server ("C:\...", "/home/...", "src/main/webapp/...") -> trả null,
 *    vì Flutter không thể truy cập được; client sẽ tự hiển thị ảnh mặc định.
 */
public final class ImageUrls {

    private ImageUrls() {}

    public static String absolutize(HttpServletRequest req, String raw) {
        if (raw == null) return null;
        String path = raw.trim();
        if (path.isEmpty()) return null;

        String lower = path.toLowerCase();
        if (lower.startsWith("http://") || lower.startsWith("https://") || lower.startsWith("data:")) {
            return path;
        }
        // Đường dẫn filesystem của server — mobile không dùng được.
        if (path.length() > 1 && path.charAt(1) == ':') return null;   // C:\...
        if (lower.startsWith("/home/") || lower.startsWith("/users/")) return null;
        if (lower.startsWith("src/main/webapp") || lower.startsWith("/src/main/webapp")) return null;

        String relative = path.startsWith("/") ? path : "/" + path;
        String ctx = req.getContextPath() == null ? "" : req.getContextPath();
        if (!ctx.isEmpty() && !relative.startsWith(ctx + "/")) {
            relative = ctx + relative;
        }
        return baseUrl(req) + relative;
    }

    /** Base URL (scheme://host[:port]/contextPath) của chính request hiện tại. */
    public static String baseUrl(HttpServletRequest req) {
        String scheme = req.getScheme();
        int port = req.getServerPort();
        boolean defaultPort = ("http".equals(scheme) && port == 80) || ("https".equals(scheme) && port == 443);
        return scheme + "://" + req.getServerName() + (defaultPort ? "" : ":" + port);
    }
}
