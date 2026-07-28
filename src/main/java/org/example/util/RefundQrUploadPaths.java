package org.example.util;

import java.io.File;
import java.nio.file.Path;

/**
 * Ảnh QR nhận tiền hoàn — dữ liệu NHẠY CẢM (gắn với tài khoản ngân hàng thật của Customer),
 * khác hẳn ảnh khuyến mãi công khai (PromotionUploadPaths). Lưu ngoài webroot/build WAR bằng
 * cùng cơ chế biến môi trường VSPORT_UPLOAD_DIR, nhưng PHẢI serve qua servlet có kiểm tra
 * quyền sở hữu (RefundQrServeServlet) — không bao giờ qua route public/cache dài hạn như
 * /media/promotions/*.
 */
public final class RefundQrUploadPaths {

    private static final String ENV_VAR = "VSPORT_UPLOAD_DIR";
    private static final String PROP_KEY = "vsport.upload.dir";
    private static final String SUBFOLDER = "refund-qr";

    private RefundQrUploadPaths() {
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

    /** Thư mục vật lý chứa QR của một yêu cầu hoàn tiền cụ thể, tạo mới nếu chưa có. */
    public static File refundDir(int hoanTienId) {
        return new File(new File(baseDir(), SUBFOLDER), String.valueOf(hoanTienId));
    }

    /** Đường dẫn tương đối để lưu vào cột QrNhanTienPath, ví dụ "refund-qr/42/<uuid>.webp". */
    public static String relativePath(int hoanTienId, String fileName) {
        return SUBFOLDER + "/" + hoanTienId + "/" + fileName;
    }

    /**
     * Quy đổi relativePath (đáng tin, đọc từ DB) thành File thật, đảm bảo luôn nằm trong
     * baseDir()/refund-qr. Trả về null nếu phát hiện path traversal hoặc path rỗng.
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
