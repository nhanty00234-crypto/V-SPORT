package org.example.util;

import java.io.File;
import java.nio.file.Path;

/**
 * Thư mục lưu ảnh khuyến mãi PHẢI nằm ngoài src/main/webapp và ngoài thư mục build WAR:
 * nếu nằm trong webapp, mỗi lần deploy lại (redeploy WAR) ảnh đã upload sẽ bị mất. Vì vậy,
 * khác với các servlet upload khác trong dự án (CustomerProfileServlet, UpdateProfileServlet,
 * QuanLySanManagerServlet dùng getServletContext().getRealPath("/uploads/...")), module này
 * dùng một thư mục cấu hình được qua biến môi trường/system property, không có fallback vào
 * webapp real path.
 *
 * DuongDan lưu trong DB chỉ là đường dẫn tương đối bên trong thư mục gốc này (ví dụ
 * "promotions/25/<uuid>.webp"), không phải filesystem path tuyệt đối - path tuyệt đối không
 * bao giờ được trả ra ngoài (API Customer/Manager).
 */
public final class PromotionUploadPaths {

    private static final String ENV_VAR = "VSPORT_UPLOAD_DIR";
    private static final String PROP_KEY = "vsport.upload.dir";
    private static final String SUBFOLDER = "promotions";

    private PromotionUploadPaths() {
    }

    public static File baseDir() {
        String configured = System.getenv(ENV_VAR);
        if (configured == null || configured.trim().isEmpty()) {
            configured = System.getProperty(PROP_KEY);
        }
        if (configured == null || configured.trim().isEmpty()) {
            configured = new File(System.getProperty("user.home"), "vsport-uploads").getAbsolutePath();
        }
        return new File(configured.trim());
    }

    /** Thư mục vật lý chứa ảnh của một khuyến mãi cụ thể, tạo mới nếu chưa có. */
    public static File promotionDir(int khuyenMaiId) {
        File dir = new File(new File(baseDir(), SUBFOLDER), String.valueOf(khuyenMaiId));
        return dir;
    }

    /** Đường dẫn tương đối để lưu vào cột DuongDan, ví dụ "promotions/25/<uuid>.webp". */
    public static String relativePath(int khuyenMaiId, String fileName) {
        return SUBFOLDER + "/" + khuyenMaiId + "/" + fileName;
    }

    /** URL công khai để Customer/Manager tải ảnh qua servlet stream (không phải filesystem path). */
    public static String publicUrl(String contextPath, String relativePath) {
        return (contextPath == null ? "" : contextPath) + "/media/" + relativePath;
    }

    /**
     * Quy đổi một relativePath (đã lưu trong DB, đáng tin) hoặc một chuỗi do client cung cấp
     * (KHÔNG đáng tin - có thể chứa "../") thành File thật, đảm bảo kết quả luôn nằm trong
     * baseDir()/promotions. Trả về null nếu phát hiện path traversal hoặc path rỗng.
     */
    public static File resolveSafely(String relativePath) {
        if (relativePath == null || relativePath.isBlank()) return null;
        String normalized = relativePath.replace('\\', '/');
        if (normalized.contains("..")) return null;

        File root = new File(baseDir(), SUBFOLDER).getAbsoluteFile();
        File candidate = new File(baseDir(), normalized).getAbsoluteFile();

        Path rootPath = root.toPath().normalize();
        Path candidatePath = candidate.toPath().normalize();
        if (!candidatePath.startsWith(rootPath)) return null;
        return candidatePath.toFile();
    }
}
