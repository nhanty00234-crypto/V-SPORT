package org.example.dao;

import org.example.model.KhuyenMai;

import java.sql.Connection;
import java.time.LocalDate;
import java.util.Collection;
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

    /**
     * Khuyến mãi Customer được phép nhìn thấy tại một cơ sở cụ thể: đang hoạt động, còn hiệu
     * lực theo ngày, còn lượt sử dụng, HienThiCongKhai=1 và cơ sở đang hoạt động (chưa xóa).
     */
    List<KhuyenMai> findPublicActiveByCoSoId(int coSoId, LocalDate today);

    /** Như findPublicActiveByCoSoId nhưng cho nhiều cơ sở cùng lúc (tránh N+1 ở trang tìm sân). */
    List<KhuyenMai> findPublicActiveByCoSoIds(Collection<Integer> coSoIds, LocalDate today);

    /**
     * Khuyến mãi công khai trên toàn hệ thống (dùng cho Home "featuredPromotions" và
     * /customer/uu-dai), cùng điều kiện như findPublicActiveByCoSoId nhưng không giới hạn CoSoID.
     */
    List<KhuyenMai> findPublicActiveAll(LocalDate today, int limit);
}
