package org.example.service;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Nguồn sự thật duy nhất để biết một CoSo còn hoạt động hay không. Dùng bởi
 * ActiveFacilityFilter (mọi request /manager/*, /staff/*), login (DangNhapServlet)
 * và các service nghiệp vụ nhạy cảm (thanh toán, PayOS) làm phòng thủ nhiều lớp
 * cho trường hợp một route không đi qua filter.
 *
 * Luôn đọc trực tiếp từ database (không cache) để tránh stale state ngay sau khi
 * Admin vừa xóa/khôi phục một cơ sở.
 */
public class FacilityAccessService {

    private static final Logger logger = LogManager.getLogger(FacilityAccessService.class);

    public enum FacilityStatus { ACTIVE, DELETED, NOT_FOUND }

    public static class FacilityInactiveException extends RuntimeException {
        private final FacilityStatus status;

        public FacilityInactiveException(FacilityStatus status, String message) {
            super(message);
            this.status = status;
        }

        public FacilityStatus getStatus() {
            return status;
        }
    }

    public FacilityStatus getFacilityStatus(int coSoId) {
        String sql = "SELECT ISNULL(IsDeleted, 0) AS IsDeleted FROM CoSo WHERE CoSoID = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return FacilityStatus.NOT_FOUND;
                }
                return rs.getBoolean("IsDeleted") ? FacilityStatus.DELETED : FacilityStatus.ACTIVE;
            }
        } catch (Exception e) {
            logger.error("Lỗi kiểm tra trạng thái cơ sở CoSoID={}: {}", coSoId, e.getMessage(), e);
            // Fail closed: không xác minh được thì coi như không hoạt động, tránh lộ dữ liệu vận hành.
            return FacilityStatus.NOT_FOUND;
        }
    }

    public boolean isFacilityActive(int coSoId) {
        return getFacilityStatus(coSoId) == FacilityStatus.ACTIVE;
    }

    /**
     * Ném FacilityInactiveException nếu coSoId không còn ACTIVE. Account không gắn
     * cơ sở nào (Customer, Admin - coSoId null) luôn được coi là hợp lệ ở đây.
     */
    public void requireActiveFacility(Integer coSoId) {
        if (coSoId == null) {
            return;
        }
        FacilityStatus status = getFacilityStatus(coSoId);
        if (status != FacilityStatus.ACTIVE) {
            throw new FacilityInactiveException(status,
                    status == FacilityStatus.NOT_FOUND
                            ? "Cơ sở không tồn tại."
                            : "Cơ sở đã ngừng hoạt động.");
        }
    }
}
