package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.HoanTienDAO;
import org.example.dao.impl.HoanTienDAOImpl;
import org.example.model.Hoantien;
import org.example.util.ImageInspector;
import org.example.util.RefundQrUploadPaths;
import org.example.util.RefundStatus;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.UUID;

/**
 * Upload/xóa ảnh QR nhận tiền hoàn cho một yêu cầu HoanTien. Tối đa 1 ảnh, 5MB, JPG/PNG/WEBP.
 * Không lưu trong webroot (RefundQrUploadPaths), tên file UUID, chỉ Customer sở hữu yêu cầu mới
 * được upload/thay ảnh, và chỉ khi trạng thái còn cho phép sửa (RefundStatus.EDITABLE_BY_CUSTOMER).
 */
public class RefundQrService {

    private static final Logger logger = LogManager.getLogger(RefundQrService.class);

    public static final long MAX_FILE_BYTES = 5L * 1024 * 1024;

    private final HoanTienDAO hoanTienDAO;

    public RefundQrService() {
        this(new HoanTienDAOImpl());
    }

    public RefundQrService(HoanTienDAO hoanTienDAO) {
        this.hoanTienDAO = hoanTienDAO;
    }

    public static class QrException extends RuntimeException {
        public QrException(String message) {
            super(message);
        }
    }

    /**
     * Upload/thay ảnh QR cho hoanTienId thuộc accountId. Xóa ảnh cũ an toàn sau khi ghi + lưu DB
     * thành công (không để file orphan nếu ảnh mới ghi lỗi giữa chừng).
     *
     * @return relativePath đã lưu vào DB
     */
    public String uploadQr(int hoanTienId, int accountId, byte[] bytes, String submittedFileName) {
        if (bytes == null || bytes.length == 0) {
            throw new QrException("Vui lòng chọn ảnh QR.");
        }
        if (bytes.length > MAX_FILE_BYTES) {
            throw new QrException("Ảnh QR vượt quá 5MB.");
        }

        Hoantien ht = hoanTienDAO.findByIdAndAccountId(hoanTienId, accountId);
        if (ht == null) {
            throw new QrException("Không tìm thấy yêu cầu hoàn tiền.");
        }
        if (!RefundStatus.EDITABLE_BY_CUSTOMER.contains(ht.getTrangThai())) {
            throw new QrException("Yêu cầu đã được xử lý, không thể thay đổi ảnh QR.");
        }

        ImageInspector.Result r = ImageInspector.inspect(bytes, 0, 0);
        if (!r.valid) {
            throw new QrException(r.error);
        }

        String oldRelativePath = ht.getQrNhanTienPath();
        File targetDir = RefundQrUploadPaths.refundDir(hoanTienId);
        if (!targetDir.exists() && !targetDir.mkdirs()) {
            throw new QrException("Không thể tạo thư mục lưu ảnh QR.");
        }

        String fileName = UUID.randomUUID() + r.extension;
        File target = new File(targetDir, fileName);
        try (FileOutputStream fos = new FileOutputStream(target)) {
            fos.write(bytes);
        } catch (IOException e) {
            logger.error("uploadQr hoanTienId={}: ghi file thất bại: {}", hoanTienId, e.getMessage(), e);
            throw new QrException("Không thể lưu ảnh QR. Vui lòng thử lại.");
        }

        String relativePath = RefundQrUploadPaths.relativePath(hoanTienId, fileName);
        boolean ok = hoanTienDAO.updateQrPath(hoanTienId, accountId, relativePath);
        if (!ok) {
            if (!target.delete()) {
                logger.warn("Không xóa được file mồ côi sau khi updateQrPath thất bại (hoanTienId={}).", hoanTienId);
            }
            throw new QrException("Không thể lưu ảnh QR — trạng thái yêu cầu đã thay đổi.");
        }

        if (oldRelativePath != null && !oldRelativePath.isBlank()) {
            File oldFile = RefundQrUploadPaths.resolveSafely(oldRelativePath);
            if (oldFile != null && oldFile.exists() && !oldFile.delete()) {
                logger.warn("Không xóa được ảnh QR cũ (hoanTienId={}, path={}).", hoanTienId, oldRelativePath);
            }
        }

        return relativePath;
    }

    /** Lấy đường dẫn tương đối QR để servlet serve — kiểm tra ownership trước khi trả. */
    public String getQrPathForOwner(int hoanTienId, int accountId) {
        Hoantien ht = hoanTienDAO.findByIdAndAccountId(hoanTienId, accountId);
        return ht != null ? ht.getQrNhanTienPath() : null;
    }

    /** Lấy đường dẫn tương đối QR cho Manager đúng cơ sở — kiểm tra ownership trước khi trả. */
    public String getQrPathForManager(int hoanTienId, int coSoId) {
        Hoantien ht = hoanTienDAO.findByIdAndCoSoId(hoanTienId, coSoId);
        return ht != null ? ht.getQrNhanTienPath() : null;
    }
}
