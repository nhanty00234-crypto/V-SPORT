package org.example.dao;

import org.example.model.KhuyenMaiHinhAnh;

import java.sql.Connection;
import java.util.Collection;
import java.util.List;
import java.util.Map;

public interface KhuyenMaiHinhAnhDAO {

    /** Danh sách ảnh của một khuyến mãi, sắp theo ThuTu tăng dần. */
    List<KhuyenMaiHinhAnh> findByKhuyenMaiId(int khuyenMaiId);

    /** Lấy ảnh theo nhiều KhuyenMaiID cùng lúc (tránh N+1 khi Customer xem danh sách). */
    Map<Integer, List<KhuyenMaiHinhAnh>> findByKhuyenMaiIds(Collection<Integer> khuyenMaiIds);

    KhuyenMaiHinhAnh findByIdAndKhuyenMaiId(int hinhAnhId, int khuyenMaiId);

    int countByKhuyenMaiId(int khuyenMaiId);

    long sumDungLuongByKhuyenMaiId(int khuyenMaiId);

    /**
     * Đếm số ảnh hiện có, khóa hàng (UPDLOCK/HOLDLOCK) trong transaction của caller để
     * chặn 2 upload đồng thời cùng vượt giới hạn 5 ảnh/25MB. Phải gọi trong cùng
     * transaction với insert() phía sau, và conn phải setAutoCommit(false).
     */
    int countByKhuyenMaiIdForUpdate(Connection conn, int khuyenMaiId);

    long sumDungLuongByKhuyenMaiIdForUpdate(Connection conn, int khuyenMaiId);

    /** ThuTu lớn nhất hiện có, -1 nếu chưa có ảnh nào. Dùng để gán ThuTu cho ảnh mới thêm vào. */
    int maxThuTu(Connection conn, int khuyenMaiId);

    /** Chèn 1 ảnh mới, tham gia transaction do Service quản lý. Trả về HinhAnhID mới, 0 nếu lỗi. */
    int insert(Connection conn, KhuyenMaiHinhAnh img);

    boolean delete(Connection conn, int hinhAnhId, int khuyenMaiId);

    /** Bỏ cờ ảnh bìa của TẤT CẢ ảnh thuộc khuyến mãi này (bước 1 khi đổi ảnh bìa). */
    boolean clearCover(Connection conn, int khuyenMaiId);

    /** Đặt một ảnh cụ thể làm ảnh bìa. Gọi sau clearCover trong cùng transaction. */
    boolean setCover(Connection conn, int hinhAnhId, int khuyenMaiId);

    boolean updateThuTu(Connection conn, int hinhAnhId, int khuyenMaiId, int thuTu);

    /** Xóa toàn bộ metadata ảnh của một khuyến mãi (dùng khi xóa vĩnh viễn khuyến mãi). */
    List<KhuyenMaiHinhAnh> deleteAllByKhuyenMaiId(Connection conn, int khuyenMaiId);
}
