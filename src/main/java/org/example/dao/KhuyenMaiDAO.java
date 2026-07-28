package org.example.dao;

import org.example.model.KhuyenMai;

<<<<<<< HEAD
import java.sql.Connection;
import java.time.LocalDate;
import java.util.List;

public interface KhuyenMaiDAO {

    /** Lấy danh sách khuyến mãi của cơ sở, phân trang. */
    List<KhuyenMai> findByCoSoId(int coSoId, int page, int pageSize);

    KhuyenMai findById(int khuyenMaiId);

    /** Tìm theo mã code, trong phạm vi cơ sở. */
    KhuyenMai findByCodeAndCoSoId(String maCode, int coSoId);

    /** Kiểm tra mã code đã tồn tại toàn hệ thống chưa (unique). */
    boolean existsByCode(String maCode);

    /** Kiểm tra mã code đã tồn tại, trừ bản ghi có id này (dùng khi update). */
    boolean existsByCodeExcluding(String maCode, int excludeId);

    int insert(KhuyenMai km);

    boolean update(KhuyenMai km);

    boolean delete(int khuyenMaiId, int coSoId);

    /**
     * Tăng SoLanDaDung atomically trong cùng transaction.
     * Kiểm tra đồng thời: còn hoạt động, còn lượt dùng.
     * Trả về true nếu thành công.
     */
    boolean incrementUsage(Connection conn, int khuyenMaiId);

    int countByCoSoId(int coSoId);

    /**
     * Validate và lấy khuyến mãi có thể áp dụng.
     * Kiểm tra: tồn tại, thuộc coSoId, đang hoạt động, trong ngày, chưa hết lượt.
     * Trả về null nếu không hợp lệ.
     */
    KhuyenMai findApplicable(String maCode, int coSoId, LocalDate today);
=======
import java.util.List;

/**
 * DAO thuần CRUD cho bảng KhuyenMai, phục vụ giao diện Manager quản lý mã khuyến mãi.
 * Không chứa logic tính giảm giá — việc validate/tính toán khi áp mã vẫn thuộc
 * org.example.service.customer.PromotionService (không tạo service tính giá thứ hai ở đây).
 */
public interface KhuyenMaiDAO {

    List<KhuyenMai> findByCoSoId(int coSoId);

    KhuyenMai findByIdAndCoSoId(int khuyenMaiId, int coSoId);

    boolean existsByCode(String maCode, Integer excludeKhuyenMaiId);

    int insert(KhuyenMai km);

    boolean update(KhuyenMai km, int coSoId);

    boolean updateTrangThai(int khuyenMaiId, int coSoId, String trangThai);
>>>>>>> fix/teacher-review-remediation
}
