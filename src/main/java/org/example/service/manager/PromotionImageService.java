package org.example.service.manager;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.KhuyenMaiHinhAnhDAO;
import org.example.dao.impl.KhuyenMaiHinhAnhDAOImpl;
import org.example.model.KhuyenMaiHinhAnh;
import org.example.util.DBUtil;
import org.example.util.ImageInspector;
import org.example.util.PromotionUploadPaths;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Nghiệp vụ quản lý gallery ảnh của một khuyến mãi (KhuyenMai): giới hạn 5 ảnh / 25MB tổng,
 * ghi file + metadata trong cùng một transaction (khóa hàng bằng UPDLOCK/HOLDLOCK để chặn
 * 2 upload đồng thời cùng vượt giới hạn), dọn file mồ côi (orphan) nếu một trong hai bước
 * upload file/ghi DB thất bại. Không xử lý quyền sở hữu CoSoID - servlet gọi vào đây phải
 * tự kiểm tra khuyenMaiId thuộc CoSoID của Manager trước (KhuyenMaiDAO.findByIdAndCoSoId).
 */
public class PromotionImageService {

    private static final Logger logger = LogManager.getLogger(PromotionImageService.class);

    public static final int MAX_IMAGES = 5;
    public static final long MAX_FILE_BYTES = 5L * 1024 * 1024;
    public static final long MAX_TOTAL_BYTES = 25L * 1024 * 1024;
    public static final int MIN_WIDTH = 800;
    public static final int MIN_HEIGHT = 450;
    public static final int RECOMMENDED_WIDTH = 1600;
    public static final int RECOMMENDED_HEIGHT = 900;

    private final KhuyenMaiHinhAnhDAO imageDAO;

    public PromotionImageService() {
        this(new KhuyenMaiHinhAnhDAOImpl());
    }

    public PromotionImageService(KhuyenMaiHinhAnhDAO imageDAO) {
        this.imageDAO = imageDAO;
    }

    public static class PromotionImageException extends RuntimeException {
        public PromotionImageException(String message) {
            super(message);
        }
    }

    /** Ảnh thô đọc từ multipart Part, tách khỏi jakarta.servlet để Service không phụ thuộc servlet API. */
    public static final class UploadedImageFile {
        public final byte[] bytes;
        public final String submittedFileName;

        public UploadedImageFile(byte[] bytes, String submittedFileName) {
            this.bytes = bytes;
            this.submittedFileName = submittedFileName;
        }
    }

    public List<KhuyenMaiHinhAnh> listImages(int khuyenMaiId) {
        return imageDAO.findByKhuyenMaiId(khuyenMaiId);
    }

    /**
     * Thêm một hoặc nhiều ảnh cho khuyenMaiId (dùng cả lúc tạo mới và khi bổ sung khi sửa).
     * Ảnh không hợp lệ (sai định dạng, quá cỡ, quá nhỏ) làm toàn bộ batch bị từ chối - không
     * ghi phần nào xuống đĩa/DB - để Manager biết chính xác ảnh nào lỗi và thử lại.
     */
    public List<KhuyenMaiHinhAnh> addImages(int khuyenMaiId, List<UploadedImageFile> files) {
        List<UploadedImageFile> nonEmpty = new ArrayList<>();
        if (files != null) {
            for (UploadedImageFile f : files) {
                if (f != null && f.bytes != null && f.bytes.length > 0) nonEmpty.add(f);
            }
        }
        if (nonEmpty.isEmpty()) return List.of();
        if (nonEmpty.size() > MAX_IMAGES) {
            throw new PromotionImageException("Chỉ được tải tối đa " + MAX_IMAGES + " ảnh mỗi lần.");
        }

        List<ImageInspector.Result> validated = new ArrayList<>();
        long batchBytes = 0;
        for (UploadedImageFile f : nonEmpty) {
            if (f.bytes.length > MAX_FILE_BYTES) {
                throw new PromotionImageException(
                        "Ảnh '" + safeDisplayName(f.submittedFileName) + "' vượt quá 5MB.");
            }
            ImageInspector.Result r = ImageInspector.inspect(f.bytes, MIN_WIDTH, MIN_HEIGHT);
            if (!r.valid) {
                throw new PromotionImageException(
                        "Ảnh '" + safeDisplayName(f.submittedFileName) + "': " + r.error);
            }
            validated.add(r);
            batchBytes += f.bytes.length;
        }

        Connection conn = null;
        List<File> writtenFiles = new ArrayList<>();
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            int existingCount = imageDAO.countByKhuyenMaiIdForUpdate(conn, khuyenMaiId);
            long existingBytes = imageDAO.sumDungLuongByKhuyenMaiIdForUpdate(conn, khuyenMaiId);
            int nextThuTu = imageDAO.maxThuTu(conn, khuyenMaiId) + 1;

            if (existingCount + nonEmpty.size() > MAX_IMAGES) {
                throw new PromotionImageException(
                        "Chương trình đã có " + existingCount + " ảnh, chỉ được tối đa " + MAX_IMAGES + " ảnh.");
            }
            if (existingBytes + batchBytes > MAX_TOTAL_BYTES) {
                throw new PromotionImageException("Tổng dung lượng ảnh vượt quá 25MB cho một chương trình.");
            }

            boolean needCover = existingCount == 0;
            File promotionDir = PromotionUploadPaths.promotionDir(khuyenMaiId);
            if (!promotionDir.exists() && !promotionDir.mkdirs()) {
                throw new IOException("Không thể tạo thư mục lưu ảnh khuyến mãi.");
            }

            List<KhuyenMaiHinhAnh> inserted = new ArrayList<>();
            for (int i = 0; i < nonEmpty.size(); i++) {
                UploadedImageFile f = nonEmpty.get(i);
                ImageInspector.Result r = validated.get(i);

                String fileName = UUID.randomUUID() + r.extension;
                File target = new File(promotionDir, fileName);
                try (FileOutputStream fos = new FileOutputStream(target)) {
                    fos.write(f.bytes);
                }
                writtenFiles.add(target);

                KhuyenMaiHinhAnh img = new KhuyenMaiHinhAnh();
                img.setKhuyenMaiId(khuyenMaiId);
                img.setDuongDan(PromotionUploadPaths.relativePath(khuyenMaiId, fileName));
                img.setTenFileGoc(safeDisplayName(f.submittedFileName));
                img.setMimeType(r.detectedMimeType);
                img.setDungLuong((long) f.bytes.length);
                img.setChieuRong(r.width);
                img.setChieuCao(r.height);
                img.setThuTu(nextThuTu + i);
                img.setLaAnhBia(needCover && i == 0);

                int newId = imageDAO.insert(conn, img);
                if (newId <= 0) {
                    throw new SQLException("Không thể lưu metadata ảnh khuyến mãi.");
                }
                img.setHinhAnhId(newId);
                inserted.add(img);
            }

            conn.commit();
            return inserted;
        } catch (PromotionImageException e) {
            rollbackQuietly(conn);
            throw e;
        } catch (Exception e) {
            rollbackQuietly(conn);
            // Upload thành công nhưng DB thất bại (hoặc lỗi khác giữa chừng) -> xóa file mồ côi đã ghi.
            for (File f : writtenFiles) {
                if (!f.delete()) logger.warn("Không xóa được file mồ côi khi rollback upload ảnh khuyến mãi.");
            }
            logger.error("addImages khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
            throw new PromotionImageException("Không thể lưu ảnh khuyến mãi. Vui lòng thử lại.");
        } finally {
            closeQuietly(conn);
        }
    }

    public void deleteImage(int khuyenMaiId, int hinhAnhId) {
        KhuyenMaiHinhAnh existing = imageDAO.findByIdAndKhuyenMaiId(hinhAnhId, khuyenMaiId);
        if (existing == null) {
            throw new PromotionImageException("Không tìm thấy ảnh.");
        }
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            boolean deleted = imageDAO.delete(conn, hinhAnhId, khuyenMaiId);
            if (!deleted) {
                throw new SQLException("Không thể xóa metadata ảnh.");
            }
            conn.commit();
        } catch (Exception e) {
            rollbackQuietly(conn);
            logger.error("deleteImage hinhAnhId={} khuyenMaiId={}: {}", hinhAnhId, khuyenMaiId, e.getMessage(), e);
            throw new PromotionImageException("Không thể xóa ảnh. Vui lòng thử lại.");
        } finally {
            closeQuietly(conn);
        }

        File file = PromotionUploadPaths.resolveSafely(existing.getDuongDan());
        if (file != null && file.exists() && !file.delete()) {
            logger.warn("Không xóa được file vật lý sau khi xóa metadata ảnh khuyến mãi (hinhAnhId={}).", hinhAnhId);
        }
    }

    /** Đổi ảnh bìa trong một transaction: bỏ cờ ảnh bìa cũ rồi đặt ảnh mới, đảm bảo luôn chỉ có 1 ảnh bìa. */
    public void setCover(int khuyenMaiId, int hinhAnhId) {
        KhuyenMaiHinhAnh target = imageDAO.findByIdAndKhuyenMaiId(hinhAnhId, khuyenMaiId);
        if (target == null) {
            throw new PromotionImageException("Không tìm thấy ảnh.");
        }
        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            imageDAO.clearCover(conn, khuyenMaiId);
            boolean ok = imageDAO.setCover(conn, hinhAnhId, khuyenMaiId);
            if (!ok) {
                throw new SQLException("Không thể đặt ảnh bìa.");
            }
            conn.commit();
        } catch (Exception e) {
            rollbackQuietly(conn);
            logger.error("setCover hinhAnhId={} khuyenMaiId={}: {}", hinhAnhId, khuyenMaiId, e.getMessage(), e);
            throw new PromotionImageException("Không thể đặt ảnh bìa. Vui lòng thử lại.");
        } finally {
            closeQuietly(conn);
        }
    }

    /** Sắp xếp lại thứ tự ảnh theo danh sách hinhAnhId do Manager kéo-thả. */
    public void reorder(int khuyenMaiId, List<Integer> orderedHinhAnhIds) {
        if (orderedHinhAnhIds == null || orderedHinhAnhIds.isEmpty()) return;
        List<KhuyenMaiHinhAnh> current = imageDAO.findByKhuyenMaiId(khuyenMaiId);
        java.util.Set<Integer> validIds = new java.util.HashSet<>();
        for (KhuyenMaiHinhAnh img : current) validIds.add(img.getHinhAnhId());
        for (Integer id : orderedHinhAnhIds) {
            if (!validIds.contains(id)) {
                throw new PromotionImageException("Danh sách thứ tự ảnh không hợp lệ.");
            }
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            int order = 0;
            for (Integer id : orderedHinhAnhIds) {
                imageDAO.updateThuTu(conn, id, khuyenMaiId, order++);
            }
            conn.commit();
        } catch (Exception e) {
            rollbackQuietly(conn);
            logger.error("reorder khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
            throw new PromotionImageException("Không thể cập nhật thứ tự ảnh. Vui lòng thử lại.");
        } finally {
            closeQuietly(conn);
        }
    }

    /** Xóa vĩnh viễn toàn bộ ảnh (metadata + file) của một khuyến mãi - dùng khi hard-delete KhuyenMai. */
    public void deleteAllImagesForPromotion(int khuyenMaiId) {
        Connection conn = null;
        List<KhuyenMaiHinhAnh> removed;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);
            removed = imageDAO.deleteAllByKhuyenMaiId(conn, khuyenMaiId);
            conn.commit();
        } catch (Exception e) {
            rollbackQuietly(conn);
            logger.error("deleteAllImagesForPromotion khuyenMaiId={}: {}", khuyenMaiId, e.getMessage(), e);
            throw new PromotionImageException("Không thể xóa ảnh của khuyến mãi. Vui lòng thử lại.");
        } finally {
            closeQuietly(conn);
        }
        for (KhuyenMaiHinhAnh img : removed) {
            File file = PromotionUploadPaths.resolveSafely(img.getDuongDan());
            if (file != null && file.exists() && !file.delete()) {
                logger.warn("Không xóa được file vật lý khi hard-delete khuyến mãi (hinhAnhId={}).", img.getHinhAnhId());
            }
        }
    }

    private static String safeDisplayName(String submittedFileName) {
        if (submittedFileName == null || submittedFileName.isBlank()) return "anh";
        String base;
        try {
            base = Paths.get(submittedFileName).getFileName().toString();
        } catch (Exception e) {
            base = submittedFileName.replaceAll("[\\\\/]", "_");
        }
        return base.length() > 255 ? base.substring(0, 255) : base;
    }

    private static void rollbackQuietly(Connection conn) {
        if (conn == null) return;
        try {
            conn.rollback();
        } catch (SQLException ignored) {
        }
    }

    private static void closeQuietly(Connection conn) {
        if (conn == null) return;
        try {
            conn.setAutoCommit(true);
            conn.close();
        } catch (SQLException ignored) {
        }
    }
}
