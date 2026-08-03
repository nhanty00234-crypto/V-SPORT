package org.example.util;

import java.io.File;
import java.nio.file.Path;

/**
 * Ảnh QR ngân hàng tĩnh do nhân viên tự upload — dữ liệu NHẠY CẢM (gắn tài khoản ngân hàng
 * thật). Lưu ngoài webroot/WAR bằng cùng cơ chế VSPORT_UPLOAD_DIR như RefundQrUploadPaths,
 * và PHẢI serve qua NhanVienQrServeServlet có kiểm tra quyền — không bao giờ qua route public.
 */
public final class StaffQrUploadPaths {

    private static final String ENV_VAR = "VSPORT_UPLOAD_DIR";
    private static final String PROP_KEY = "vsport.upload.dir";
    private static final String SUBFOLDER = "nhan-vien-qr";

    private StaffQrUploadPaths() {
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

    /** Thư mục vật lý chứa ảnh QR của một nhân viên, chưa chắc đã tồn tại. */
    public static File nhanVienDir(int accountId) {
        return new File(new File(baseDir(), SUBFOLDER), String.valueOf(accountId));
    }

    /** Đường dẫn tương đối lưu vào cột Accounts.QrImagePath. */
    public static String relativePath(int accountId, String fileName) {
        return SUBFOLDER + "/" + accountId + "/" + fileName;
    }

    /** Quy đổi relativePath (đọc từ DB) thành File thật, chặn path traversal. Null nếu không hợp lệ. */
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
