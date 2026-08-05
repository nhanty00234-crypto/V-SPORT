package org.example.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.util.Map;

/**
 * Wrapper cho Cloudinary SDK. CLOUDINARY_URL phải được set trong biến môi trường.
 * Format: cloudinary://api_key:api_secret@cloud_name
 *
 * Upload ảnh sẽ lưu lên Cloudinary CDN thay vì filesystem server - tránh mất ảnh khi
 * redeploy WAR và tránh tình trạng user A thấy ảnh của user B trên cùng session.
 */
public final class CloudinaryUtil {

    private static final Logger logger = LogManager.getLogger(CloudinaryUtil.class);
    private static final String CLOUDINARY_URL_ENV = "CLOUDINARY_URL";

    private static volatile Cloudinary instance;

    private CloudinaryUtil() {}

    private static Cloudinary getInstance() {
        if (instance == null) {
            synchronized (CloudinaryUtil.class) {
                if (instance == null) {
                    String cloudinaryUrl = System.getenv(CLOUDINARY_URL_ENV);
                    if (cloudinaryUrl == null || cloudinaryUrl.isBlank()) {
                        throw new IllegalStateException(
                            "Biến môi trường CLOUDINARY_URL chưa được cấu hình. " +
                            "Format: cloudinary://api_key:api_secret@cloud_name");
                    }
                    instance = new Cloudinary(cloudinaryUrl);
                }
            }
        }
        return instance;
    }

    /**
     * Upload mảng byte ảnh lên Cloudinary.
     *
     * @param bytes  nội dung file ảnh
     * @param folder thư mục trên Cloudinary (vd: "vsport/avatars", "vsport/courts")
     * @return secure URL của ảnh đã upload (https://res.cloudinary.com/...)
     */
    public static String uploadImage(byte[] bytes, String folder) throws IOException {
        @SuppressWarnings("unchecked")
        Map<String, Object> result = getInstance().uploader().upload(bytes, ObjectUtils.asMap(
            "folder", folder,
            "resource_type", "image",
            "secure", true
        ));
        String url = (String) result.get("secure_url");
        if (url == null || url.isBlank()) {
            throw new IOException("Cloudinary không trả về URL sau khi upload.");
        }
        return url;
    }

    /**
     * Xóa ảnh trên Cloudinary theo public_id trích xuất từ URL.
     * Không throw exception nếu xóa thất bại - chỉ ghi log.
     */
    public static void deleteByUrl(String cloudinaryUrl) {
        if (cloudinaryUrl == null || cloudinaryUrl.isBlank()) return;
        String publicId = extractPublicId(cloudinaryUrl);
        if (publicId == null) return;
        try {
            getInstance().uploader().destroy(publicId, ObjectUtils.emptyMap());
        } catch (Exception e) {
            logger.warn("Không thể xóa ảnh Cloudinary publicId={}: {}", publicId, e.getMessage());
        }
    }

    /**
     * Kiểm tra xem URL đã là Cloudinary URL chưa (https://res.cloudinary.com/...).
     * Dùng để tương thích ngược với ảnh cũ lưu trên filesystem.
     */
    public static boolean isCloudinaryUrl(String url) {
        return url != null && url.startsWith("https://res.cloudinary.com/");
    }

    /**
     * Trích xuất public_id từ Cloudinary URL.
     * vd: https://res.cloudinary.com/dut8qxmt/image/upload/v1234/vsport/avatars/acc-1-uuid.jpg
     *   → vsport/avatars/acc-1-uuid
     */
    static String extractPublicId(String cloudinaryUrl) {
        if (cloudinaryUrl == null) return null;
        int uploadIdx = cloudinaryUrl.indexOf("/upload/");
        if (uploadIdx < 0) return null;
        String afterUpload = cloudinaryUrl.substring(uploadIdx + "/upload/".length());
        // Bỏ qua version nếu có (vd: v1234567890/)
        if (afterUpload.matches("v\\d+/.*")) {
            afterUpload = afterUpload.substring(afterUpload.indexOf('/') + 1);
        }
        // Bỏ phần mở rộng file
        int dotIdx = afterUpload.lastIndexOf('.');
        if (dotIdx > 0) afterUpload = afterUpload.substring(0, dotIdx);
        return afterUpload.isBlank() ? null : afterUpload;
    }
}
