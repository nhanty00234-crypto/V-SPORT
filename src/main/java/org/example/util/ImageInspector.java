package org.example.util;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Set;

/**
 * Xác thực ảnh dựa trên nội dung byte thật (magic bytes + decode), không tin Content-Type
 * do client khai báo. Hỗ trợ JPEG, PNG, WEBP.
 *
 * ImageIO của JDK không đọc được WEBP (dự án không có thư viện webp-imageio/TwelveMonkeys),
 * nên WEBP được xác thực + đọc kích thước bằng cách parse thủ công cấu trúc chunk RIFF/WEBP
 * (VP8/VP8L/VP8X) thay vì decode toàn bộ ảnh - đủ để chặn file giả mạo đuôi .webp và biết
 * được chiều rộng/cao mà không cần thêm dependency mới.
 */
public final class ImageInspector {

    public static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "image/jpeg", "image/jpg", "image/png", "image/webp");

    private ImageInspector() {
    }

    public static final class Result {
        public final boolean valid;
        public final String error;
        public final String detectedMimeType;
        public final String extension;
        public final int width;
        public final int height;

        private Result(boolean valid, String error, String detectedMimeType, String extension, int width, int height) {
            this.valid = valid;
            this.error = error;
            this.detectedMimeType = detectedMimeType;
            this.extension = extension;
            this.width = width;
            this.height = height;
        }

        static Result fail(String error) {
            return new Result(false, error, null, null, 0, 0);
        }

        static Result ok(String mimeType, String extension, int width, int height) {
            return new Result(true, null, mimeType, extension, width, height);
        }
    }

    /**
     * @param bytes           toàn bộ nội dung file (đã giới hạn kích thước trước khi gọi hàm này)
     * @param minWidth        chiều rộng tối thiểu bắt buộc
     * @param minHeight       chiều cao tối thiểu bắt buộc
     */
    public static Result inspect(byte[] bytes, int minWidth, int minHeight) {
        if (bytes == null || bytes.length < 12) {
            return Result.fail("Tệp không phải ảnh hợp lệ.");
        }

        if (isJpeg(bytes)) {
            return inspectViaImageIO(bytes, "image/jpeg", ".jpg", minWidth, minHeight);
        }
        if (isPng(bytes)) {
            return inspectViaImageIO(bytes, "image/png", ".png", minWidth, minHeight);
        }
        if (isWebp(bytes)) {
            return inspectWebp(bytes, minWidth, minHeight);
        }
        return Result.fail("Chỉ chấp nhận ảnh định dạng JPG, JPEG, PNG hoặc WEBP.");
    }

    private static boolean isJpeg(byte[] b) {
        return b.length >= 3 && (b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF;
    }

    private static boolean isPng(byte[] b) {
        return b.length >= 8 && (b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G'
                && b[4] == 0x0D && b[5] == 0x0A && b[6] == 0x1A && b[7] == 0x0A;
    }

    private static boolean isWebp(byte[] b) {
        return b.length >= 12 && b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F'
                && b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P';
    }

    private static Result inspectViaImageIO(byte[] bytes, String mimeType, String extension, int minWidth, int minHeight) {
        BufferedImage image;
        try {
            image = ImageIO.read(new ByteArrayInputStream(bytes));
        } catch (IOException e) {
            return Result.fail("Không thể đọc ảnh, tệp có thể bị hỏng.");
        }
        if (image == null) {
            return Result.fail("Không thể đọc ảnh, tệp có thể bị hỏng.");
        }
        int width = image.getWidth();
        int height = image.getHeight();
        if (width < minWidth || height < minHeight) {
            return Result.fail("Ảnh quá nhỏ, tối thiểu " + minWidth + "x" + minHeight + " (ảnh hiện tại " + width + "x" + height + ").");
        }
        return Result.ok(mimeType, extension, width, height);
    }

    private static Result inspectWebp(byte[] b, int minWidth, int minHeight) {
        int width;
        int height;
        try {
            if (b.length >= 30 && b[12] == 'V' && b[13] == 'P' && b[14] == '8' && b[15] == ' ') {
                // VP8 (lossy): bitstream bắt đầu ở offset 20, start code 0x9d 0x01 0x2a ở offset 23-25.
                if ((b[23] & 0xFF) != 0x9d || (b[24] & 0xFF) != 0x01 || (b[25] & 0xFF) != 0x2a) {
                    return Result.fail("Tệp WEBP không hợp lệ.");
                }
                width = ((b[26] & 0xFF) | ((b[27] & 0xFF) << 8)) & 0x3FFF;
                height = ((b[28] & 0xFF) | ((b[29] & 0xFF) << 8)) & 0x3FFF;
            } else if (b.length >= 25 && b[12] == 'V' && b[13] == 'P' && b[14] == '8' && b[15] == 'L') {
                // VP8L (lossless): signature 0x2F ở offset 20, kích thước đóng gói 4 byte tiếp theo.
                if ((b[20] & 0xFF) != 0x2F) {
                    return Result.fail("Tệp WEBP không hợp lệ.");
                }
                long bits = (b[21] & 0xFFL) | ((b[22] & 0xFFL) << 8) | ((b[23] & 0xFFL) << 16) | ((b[24] & 0xFFL) << 24);
                width = (int) ((bits & 0x3FFF) + 1);
                height = (int) (((bits >> 14) & 0x3FFF) + 1);
            } else if (b.length >= 30 && b[12] == 'V' && b[13] == 'P' && b[14] == '8' && b[15] == 'X') {
                // VP8X (extended): canvas width-1/height-1 là 2 số 24-bit little-endian.
                width = ((b[24] & 0xFF) | ((b[25] & 0xFF) << 8) | ((b[26] & 0xFF) << 16)) + 1;
                height = ((b[27] & 0xFF) | ((b[28] & 0xFF) << 8) | ((b[29] & 0xFF) << 16)) + 1;
            } else {
                return Result.fail("Tệp WEBP không hợp lệ hoặc chưa được hỗ trợ.");
            }
        } catch (ArrayIndexOutOfBoundsException e) {
            return Result.fail("Tệp WEBP không hợp lệ.");
        }

        if (width <= 0 || height <= 0) {
            return Result.fail("Không thể đọc kích thước ảnh WEBP.");
        }
        if (width < minWidth || height < minHeight) {
            return Result.fail("Ảnh quá nhỏ, tối thiểu " + minWidth + "x" + minHeight + " (ảnh hiện tại " + width + "x" + height + ").");
        }
        return Result.ok("image/webp", ".webp", width, height);
    }
}
