package org.example.service.manager;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.CheckInDAO;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.model.SanQRTokenHistory;
import org.example.util.JPAUtil;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Vòng đời QR bảo mật của một sân (QR-01). Mọi transition đều: (1) khóa hàng
 * bằng PESSIMISTIC_WRITE chống 2 request cùng regenerate/bật/tắt một sân
 * (double-click, tab trùng), (2) xác nhận sân thuộc đúng cơ sở của Manager gọi
 * lệnh, (3) ghi lịch sử token khi regenerate trong CÙNG transaction.
 *
 * Không có endpoint "setStatus(sanQRId, status)" tự do - chỉ có các hành động
 * nghiệp vụ cụ thể (enable/disable/regenerate), mỗi hành động tự quyết định
 * transition nào hợp lệ.
 */
public class SanQRService {

    private static final Logger logger = LogManager.getLogger(SanQRService.class);

    public enum ErrorCode { NOT_FOUND, FORBIDDEN, INVALID_TRANSITION, CONFLICT, SYSTEM }

    public static class Result {
        public final boolean success;
        public final ErrorCode errorCode;
        public final String errorMessage;
        public final SanQR sanQR;

        private Result(boolean success, ErrorCode errorCode, String errorMessage, SanQR sanQR) {
            this.success = success;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
            this.sanQR = sanQR;
        }

        static Result ok(SanQR q) { return new Result(true, null, null, q); }
        public static Result fail(ErrorCode code, String message) { return new Result(false, code, message, null); }
    }

    /** Kết quả resolve QR khi Customer quét - phân biệt rõ lý do thất bại để UI (task sau) hiển thị đúng thông báo. */
    public enum ResolveOutcome { OK, NOT_FOUND, REVOKED, DISABLED, FACILITY_INACTIVE }

    public static class ResolveResult {
        public final ResolveOutcome outcome;
        public final SanQR sanQR;
        public final San san;

        private ResolveResult(ResolveOutcome outcome, SanQR sanQR, San san) {
            this.outcome = outcome;
            this.sanQR = sanQR;
            this.san = san;
        }

        static ResolveResult of(ResolveOutcome outcome, SanQR sanQR, San san) {
            return new ResolveResult(outcome, sanQR, san);
        }
    }

    /**
     * Lấy QR hiện có của sân, hoặc tạo mới nếu sân chưa từng có QR (idempotent -
     * gọi nhiều lần không tạo thêm bản ghi nhờ UNIQUE constraint SanID + khóa
     * PESSIMISTIC_WRITE trên San khi kiểm tra-rồi-tạo). Dùng khi Manager mở màn
     * hình quản lý QR của một sân lần đầu tiên (task sau).
     */
    public Result getOrCreate(int sanId, int managerCoSoId, Integer actorAccountId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            San san = em.find(San.class, sanId, LockModeType.PESSIMISTIC_WRITE);
            if (san == null || san.isDeleted()) {
                tx.rollback();
                return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy sân.");
            }
            if (san.getCoSoID() != managerCoSoId) {
                tx.rollback();
                return Result.fail(ErrorCode.FORBIDDEN, "Sân không thuộc cơ sở của bạn.");
            }

            SanQR existing = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.sanId = :sanId", SanQR.class)
                    .setParameter("sanId", sanId)
                    .getResultStream().findFirst().orElse(null);
            if (existing != null) {
                tx.commit();
                return Result.ok(existing);
            }

            SanQR sanQR = new SanQR();
            sanQR.setSanId(sanId);
            sanQR.setToken(UUID.randomUUID());
            sanQR.setTrangThai(SanQR.ACTIVE);
            sanQR.setCreatedBy(actorAccountId);
            sanQR.setUpdatedBy(actorAccountId);
            sanQR.setRegenerateCount(0);
            em.persist(sanQR);
            em.flush(); // cần SanQRID sinh ra trước khi ghi lịch sử

            writeHistoryIssued(em, sanQR);

            tx.commit();
            return Result.ok(sanQR);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi getOrCreate SanQR sanId={}: {}", sanId, e.getMessage(), e);
            return Result.fail(ErrorCode.SYSTEM, "Lỗi hệ thống khi tạo mã QR.");
        } finally {
            em.close();
        }
    }

    /**
     * Tạo lại token (regenerate). Token cũ bị REVOKED vĩnh viễn trong lịch sử -
     * mọi QR giấy đã in với token cũ sẽ bị từ chối rõ ràng khi quét (xem resolve()).
     */
    public Result regenerate(int sanId, int managerCoSoId, Integer actorAccountId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            San san = em.find(San.class, sanId, LockModeType.PESSIMISTIC_WRITE);
            if (san == null || san.isDeleted()) {
                tx.rollback();
                return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy sân.");
            }
            if (san.getCoSoID() != managerCoSoId) {
                tx.rollback();
                return Result.fail(ErrorCode.FORBIDDEN, "Sân không thuộc cơ sở của bạn.");
            }

            SanQR sanQR = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.sanId = :sanId", SanQR.class)
                    .setParameter("sanId", sanId)
                    .getResultStream().findFirst().orElse(null);
            if (sanQR == null) {
                // Chưa từng có QR -> regenerate tương đương tạo mới lần đầu.
                sanQR = new SanQR();
                sanQR.setSanId(sanId);
                sanQR.setToken(UUID.randomUUID());
                sanQR.setTrangThai(SanQR.ACTIVE);
                sanQR.setCreatedBy(actorAccountId);
                sanQR.setUpdatedBy(actorAccountId);
                sanQR.setRegenerateCount(0);
                em.persist(sanQR);
                em.flush();
                writeHistoryIssued(em, sanQR);
                tx.commit();
                return Result.ok(sanQR);
            }
            // Khóa lại chính SanQR đang thao tác để chống 2 request regenerate cùng lúc
            // trên cùng 1 sân (San đã khóa ở trên nhưng khóa lại SanQR cho tường minh).
            sanQR = em.find(SanQR.class, sanQR.getSanQRId(), LockModeType.PESSIMISTIC_WRITE);

            // Thu hồi token cũ trong lịch sử trước khi ghi đè.
            revokeCurrentHistoryEntry(em, sanQR, actorAccountId, "Regenerate bởi Manager");

            sanQR.setToken(UUID.randomUUID());
            sanQR.setTrangThai(SanQR.ACTIVE); // regenerate luôn kích hoạt lại, kể cả đang DISABLED
            sanQR.setUpdatedBy(actorAccountId);
            sanQR.setRegenerateCount(sanQR.getRegenerateCount() + 1);
            em.flush();

            writeHistoryIssued(em, sanQR);

            tx.commit();
            return Result.ok(sanQR);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi regenerate SanQR sanId={}: {}", sanId, e.getMessage(), e);
            return Result.fail(ErrorCode.SYSTEM, "Lỗi hệ thống khi tạo lại mã QR.");
        } finally {
            em.close();
        }
    }

    /** Bật QR đang tắt (không đổi token). */
    public Result enable(int sanId, int managerCoSoId, Integer actorAccountId) {
        return setActive(sanId, managerCoSoId, actorAccountId, true);
    }

    /** Tắt QR tạm thời (không đổi token, không revoke - bật lại được ngay). */
    public Result disable(int sanId, int managerCoSoId, Integer actorAccountId) {
        return setActive(sanId, managerCoSoId, actorAccountId, false);
    }

    private Result setActive(int sanId, int managerCoSoId, Integer actorAccountId, boolean active) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            San san = em.find(San.class, sanId, LockModeType.PESSIMISTIC_WRITE);
            if (san == null || san.isDeleted()) {
                tx.rollback();
                return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy sân.");
            }
            if (san.getCoSoID() != managerCoSoId) {
                tx.rollback();
                return Result.fail(ErrorCode.FORBIDDEN, "Sân không thuộc cơ sở của bạn.");
            }

            SanQR sanQR = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.sanId = :sanId", SanQR.class)
                    .setParameter("sanId", sanId)
                    .getResultStream().findFirst().orElse(null);
            if (sanQR == null) {
                tx.rollback();
                return Result.fail(ErrorCode.NOT_FOUND, "Sân chưa có mã QR. Vui lòng tạo mã trước.");
            }
            sanQR = em.find(SanQR.class, sanQR.getSanQRId(), LockModeType.PESSIMISTIC_WRITE);

            if (SanQR.REVOKED.equals(sanQR.getTrangThai())) {
                tx.rollback();
                return Result.fail(ErrorCode.INVALID_TRANSITION, "Mã QR đã bị thu hồi, vui lòng tạo lại mã mới.");
            }

            sanQR.setTrangThai(active ? SanQR.ACTIVE : SanQR.DISABLED);
            sanQR.setUpdatedBy(actorAccountId);

            tx.commit();
            return Result.ok(sanQR);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi setActive({}) SanQR sanId={}: {}", active, sanId, e.getMessage(), e);
            return Result.fail(ErrorCode.SYSTEM, "Lỗi hệ thống khi cập nhật mã QR.");
        } finally {
            em.close();
        }
    }

    /**
     * Resolve token khi Customer quét bằng camera (endpoint công khai, task sau).
     * Phân biệt rõ 4 lý do thất bại - KHÔNG gộp chung "not found" để tránh dùng
     * lỗi mơ hồ che giấu trạng thái thật (cần cho UI thông báo đúng, và cho log
     * an ninh phát hiện quét token REVOKED lặp lại = có thể là QR giấy cũ chưa
     * thu hồi vật lý, không phải tấn công dò token vì token là UUID không đoán được).
     * Chỉ đọc - không mở transaction ghi, không khóa hàng.
     */
    public ResolveResult resolve(UUID token) {
        if (token == null) {
            return ResolveResult.of(ResolveOutcome.NOT_FOUND, null, null);
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            SanQR sanQR = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.token = :token", SanQR.class)
                    .setParameter("token", token)
                    .getResultStream().findFirst().orElse(null);
            if (sanQR == null) {
                return ResolveResult.of(ResolveOutcome.NOT_FOUND, null, null);
            }
            if (SanQR.REVOKED.equals(sanQR.getTrangThai())) {
                return ResolveResult.of(ResolveOutcome.REVOKED, sanQR, null);
            }
            San san = em.find(San.class, sanQR.getSanId());
            if (san == null || san.isDeleted()) {
                return ResolveResult.of(ResolveOutcome.NOT_FOUND, sanQR, null);
            }
            if (SanQR.DISABLED.equals(sanQR.getTrangThai())) {
                return ResolveResult.of(ResolveOutcome.DISABLED, sanQR, san);
            }
            // Sân bị khóa/bảo trì ở tầng vận hành cũng không cho quét, dù QR còn ACTIVE.
            if (!CheckInDAO.FIELD_STATUS_AVAILABLE.equals(san.getTrangThai())
                    && !CheckInDAO.BOOKING_STATUS_IN_USE.equals(san.getTrangThai())) {
                return ResolveResult.of(ResolveOutcome.FACILITY_INACTIVE, sanQR, san);
            }
            return ResolveResult.of(ResolveOutcome.OK, sanQR, san);
        } catch (Exception e) {
            logger.error("Lỗi resolve SanQR token={}: {}", token, e.getMessage(), e);
            return ResolveResult.of(ResolveOutcome.NOT_FOUND, null, null);
        } finally {
            em.close();
        }
    }

    // ── Helpers (phải gọi bên trong transaction đang mở của lời gọi) ──────────

    private void writeHistoryIssued(EntityManager em, SanQR sanQR) {
        SanQRTokenHistory history = new SanQRTokenHistory();
        history.setSanQRId(sanQR.getSanQRId());
        history.setSanId(sanQR.getSanId());
        history.setToken(sanQR.getToken());
        history.setTrangThai(SanQRTokenHistory.ISSUED);
        em.persist(history);
    }

    private void revokeCurrentHistoryEntry(EntityManager em, SanQR sanQR, Integer actorAccountId, String reason) {
        SanQRTokenHistory current = em.createQuery(
                "SELECT h FROM SanQRTokenHistory h WHERE h.token = :token", SanQRTokenHistory.class)
                .setParameter("token", sanQR.getToken())
                .getResultStream().findFirst().orElse(null);
        if (current != null) {
            current.setTrangThai(SanQRTokenHistory.REVOKED);
            current.setRevokedAt(LocalDateTime.now());
            current.setRevokedBy(actorAccountId);
            current.setRevokeReason(reason);
        }
    }
}
