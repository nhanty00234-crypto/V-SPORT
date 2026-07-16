package org.example.dao;

import org.example.model.CoSo;
import java.util.List;

public interface CoSoDAO {
    List<CoSo> getAllCoSo();

    /**
     * Toàn bộ CoSo chưa bị xóa mềm, KHÔNG lọc theo TrangThai — dùng riêng cho
     * trang Quản lý Owner (cần thấy cả "Chờ duyệt"/"Từ chối" để build các tab).
     * Không dùng cho trang Quản lý Cơ sở/Nhân sự/booking (dùng getAllCoSo()).
     */
    List<CoSo> getAllCoSoIncludingPending();

    CoSo getCoSoById(int id);
    boolean addCoSo(CoSo coSo);
    boolean updateCoSo(CoSo coSo);
    boolean deleteCoSo(int id);

    // Soft-delete support (Task 5)
    boolean softDelete(int coSoId, int actorId);
    boolean restore(int coSoId);
    boolean hardDeleteCascade(int coSoId);
    List<CoSo> findDeleted();
    List<Integer> findDeletedIdsOlderThan(int days);

    // Soft-archive all rejected CoSo for an account except the one being approved
    boolean archiveRejectedForAccount(int accountId, int excludeCoSoId, int actorId);

    /**
     * Kiểm tra account đã có cơ sở khác đang "Chờ duyệt" hoặc "Đang hoạt động"
     * hay chưa (dùng khi thu hồi một OwnerRequest bị từ chối từ thùng rác,
     * tránh tạo ra hai yêu cầu/cơ sở cùng hoạt động cho một account).
     */
    boolean hasActiveOrPendingCoSo(int accountId, int excludeCoSoId);
}
