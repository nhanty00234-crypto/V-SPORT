package org.example.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

/**
 * Tiện ích upload ảnh lên Cloudinary.
 * Thay thế việc lưu ảnh vào thư mục local của server.
 */
public class CloudinaryUtil {

    private static final String CLOUD_NAME = "c8p6g4bt";
    private static final String API_KEY    = "485869782983651";
    private static final String API_SECRET = "hHBZP3lFc_Dv9EtzcCgeAB6x0E0";

    private static final Cloudinary cloudinary;

    static {
        cloudinary = new Cloudinary(ObjectUtils.asMap(
                "cloud_name", CLOUD_NAME,
                "api_key",    API_KEY,
                "api_secret", API_SECRET,
                "secure",     true
        ));
    }

    private CloudinaryUtil() {}

    /**
     * Upload ảnh từ Part (multipart) lên Cloudinary.
     *
     * @param imagePart  Part chứa file ảnh từ servlet multipart request
     * @param folder     Tên thư mục trên Cloudinary (ví dụ: "avatars", "courts")
     * @return           URL công khai (secure_url) của ảnh đã upload
     * @throws IOException nếu upload thất bại
     */
    public static String uploadImage(Part imagePart, String folder) throws IOException {
        try (InputStream inputStream = imagePart.getInputStream()) {
            byte[] imageBytes = inputStream.readAllBytes();

            Map<?, ?> result = cloudinary.uploader().upload(imageBytes, ObjectUtils.asMap(
                    "folder",          "v-sport/" + folder,
                    "resource_type",   "image",
                    "allowed_formats", new String[]{"jpg", "jpeg", "png", "webp", "gif"}
            ));

            Object secureUrl = result.get("secure_url");
            if (secureUrl == null) {
                throw new IOException("Cloudinary không trả về URL ảnh sau khi upload.");
            }
            return secureUrl.toString();
        } catch (IOException e) {
            throw e;
        } catch (Exception e) {
            throw new IOException("Lỗi khi upload ảnh lên Cloudinary: " + e.getMessage(), e);
        }
    }
}
