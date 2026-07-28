package org.example.dao;

import org.example.model.KhuyenMai;

import java.sql.Connection;
import java.time.LocalDate;
import java.util.List;

public interface KhuyenMaiDAO {

    /** Lấy danh sách khuyến mãi của cơ sở, phân trang. */
    List<KhuyenMai> findByCoSoId(int coSoId, int page, int pageSize);

    List<KhuyenMai> findByCoSoId(int coSoId);

    KhuyenMai findById(int khuyenMaiId);

    KhuyenMai findByIdAndCoSoId(int khuyenMaiId, int coSoId);

    /** Tìm theo mã code, trong phạm vi cơ sở. */
    KhuyenMai findByCodeAndCoSoId(String maCode, int coSoId);

    /** Kiểm tra mã code đã tồn tại toàn hệ thống chưa (unique). */
    boolean existsByCode(String maCode);

    /** Kiểm tra mã code đã tồn tại, trừ bản ghi có id này (dùng khi update). */
    boolean existsByCodeExcluding(String maCode, int excludeId);

    int insert(KhuyenMai km);

    boolean update(KhuyenMai km);

    boolean updateTrangThai(int khuyenMaiId, int coSoId, String trangThai);

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
}
