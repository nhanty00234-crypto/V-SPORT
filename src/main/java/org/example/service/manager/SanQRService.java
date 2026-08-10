package org.example.service.manager;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.LockModeType;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.CheckInDAO;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.model.CoSo;
import org.example.model.LoaiSan;
import org.example.model.MonTheThao;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.model.SanQRTokenHistory;
import org.example.service.AuditLogService;
import org.example.util.JPAUtil;
import org.example.util.SanQRSecurityUtil;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Vòng đời QR bảo mật của một sân (QR-01 + hardening QR-01B). Mọi transition
 * đều: (1) khóa hàng bằng PESSIMISTIC_WRITE chống 2 request cùng
 * regenerate/bật/tắt một sân (double-click, tab trùng), (2) xác nhận sân
 * thuộc đúng cơ sở của Manager gọi lệnh, (3) ghi lịch sử token/short code khi
 * regenerate trong CÙNG transaction, (4) ghi AuditLog trong CÙNG transaction.
 *
 * Không có endpoint "setStatus(sanQRId, status)" tự do - chỉ có các hành động
 * nghiệp vụ cụ thể (enable/disable/regenerate), mỗi hành động tự quyết định
 * transition nào hợp lệ.
 *
 * ── TRUST BOUNDARY (đọc kỹ trước khi gọi từ Servlet mới) ──────────────────
 * Tham số {@code managerCoSoId} PHẢI là giá trị lấy từ
 * {@code ((TaiKhoan) session.getAttribute("user")).getCoSoId()} phía server -
 * KHÔNG BAO GIỜ được lấy từ request.getParameter/request.getHeader/JSON body
 * do client gửi lên. Tương tự {@code actorAccountId} PHẢI là
 * {@code TaiKhoan.getAccountId()} của chính session đang đăng nhập, không
 * phải giá trị do client tự khai. Service tự nó KHÔNG có quyền truy cập
 * HttpSession nên không thể tự enforce điều này - trách nhiệm thuộc về
 * Servlet gọi vào đây. Nếu một Servlet tương lai đọc CoSoID/AccountID từ
 * tham số HTTP thay vì session, đó là lỗ hổng bỏ qua ownership hoàn toàn
 * (Manager A có thể tự xưng là Manager B). Xem SanQRServiceSmokeTest để biết
 * ví dụ cụ thể: dùng managerCoSoId SAI (không khớp San.CoSoID thật) luôn trả
 * FORBIDDEN, không có đường vòng nào bỏ qua kiểm tra này ở tầng Service.
 */
public class SanQRService {

    private static final Logger logger = LogManager.getLogger(SanQRService.class);

    public static final String ACTION_CREATE_QR = "CREATE_QR";
    public static final String ACTION_ENABLE_QR = "ENABLE_QR";
    public static final String ACTION_DISABLE_QR = "DISABLE_QR";
    public static final String ACTION_REGENERATE_QR = "REGENERATE_QR";
    public static final String ENTITY_SAN_QR = "court_qr_codes";

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

    /**
     * Public: dùng cho endpoint quét QR / nhập short code. CHỈ chứa DTO an
     * toàn để trả ra ngoài - không có entity, không có ID nội bộ.
     */
    public static class PublicResolveResult {
        public final ResolveOutcome outcome;
        public final SanQRResolveDTO dto;

        private PublicResolveResult(ResolveOutcome outcome, SanQRResolveDTO dto) {
            this.outcome = outcome;
            this.dto = dto;
        }
    }

    private static final int MAX_SHORT_CODE_GENERATION_ATTEMPTS = 20;

    /**
     * Đọc thuần (không lock, không mở transaction ghi) toàn bộ SanQR hiện có
     * ứng với danh sách sanId truyền vào - dùng để render danh sách Manager
     * (mỗi sân hiển thị trạng thái QR mà KHÔNG tạo QR mới chỉ vì Manager mở
     * trang danh sách). Trả Map rỗng nếu danh sách rỗng. Không kiểm tra
     * ownership ở đây - caller (Servlet) đã tự giới hạn danh sách sanId theo
     * đúng CoSoID của Manager trước khi gọi (ví dụ qua SanService.getSansByCoSo).
     */
    public java.util.Map<Integer, SanQR> findExistingBySanIds(java.util.List<Integer> sanIds) {
        if (sanIds == null || sanIds.isEmpty()) return java.util.Collections.emptyMap();
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.List<SanQR> list = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.sanId IN :ids", SanQR.class)
                    .setParameter("ids", sanIds)
                    .getResultList();
            java.util.Map<Integer, SanQR> map = new java.util.HashMap<>();
            for (SanQR q : list) map.put(q.getSanId(), q);
            return map;
        } finally {
            em.close();
        }
    }

    /** Đọc thuần một SanQR theo sanId, không lock, không tạo mới. Dùng cho detail/image/print - trả null nếu sân chưa có QR. */
    public SanQR findReadOnlyBySanId(int sanId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return findBySanId(em, sanId);
        } finally {
            em.close();
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

            SanQR existing = findBySanId(em, sanId);
            if (existing != null) {
                // Backfill ShortCode cho bản ghi tạo trước khi có hardening (nếu có).
                if (existing.getShortCode() == null) {
                    existing = em.find(SanQR.class, existing.getSanQRId(), LockModeType.PESSIMISTIC_WRITE);
                    existing.setShortCode(generateUniqueShortCode(em));
                }
                tx.commit();
                return Result.ok(existing);
            }

            SanQR sanQR = new SanQR();
            sanQR.setSanId(sanId);
            sanQR.setToken(generateSecureToken());
            sanQR.setShortCode(generateUniqueShortCode(em));
            sanQR.setTrangThai(SanQR.ACTIVE);
            sanQR.setCreatedBy(actorAccountId);
            sanQR.setUpdatedBy(actorAccountId);
            sanQR.setRegenerateCount(0);
            em.persist(sanQR);
            em.flush(); // cần SanQRID sinh ra trước khi ghi lịch sử

            writeHistoryIssued(em, sanQR);

            tx.commit();
            writeAudit(actorAccountId, managerCoSoId, ACTION_CREATE_QR, sanQR,
                    "Tạo mã QR cho sân (SanID=" + sanId + ").");
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
     * Tạo lại token + short code (regenerate). Token/short code cũ bị REVOKED
     * vĩnh viễn trong lịch sử - mọi QR giấy đã in với token cũ sẽ bị từ chối rõ
     * ràng khi quét (xem resolve()). Bản ghi SanQR hiện tại (current row) VẪN
     * LÀ chính nó - chỉ giá trị token/shortCode thay đổi, KHÔNG chuyển sang
     * REVOKED (REVOKED là trạng thái chỉ dành cho từng mục lịch sử token cũ,
     * không phải trạng thái của bản ghi SanQR đang hoạt động - xem lifecycle
     * ở docs/COURT_QR_ARCHITECTURE.md).
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

            SanQR sanQR = findBySanId(em, sanId);
            if (sanQR == null) {
                // Chưa từng có QR -> regenerate tương đương tạo mới lần đầu.
                sanQR = new SanQR();
                sanQR.setSanId(sanId);
                sanQR.setToken(generateSecureToken());
                sanQR.setShortCode(generateUniqueShortCode(em));
                sanQR.setTrangThai(SanQR.ACTIVE);
                sanQR.setCreatedBy(actorAccountId);
                sanQR.setUpdatedBy(actorAccountId);
                sanQR.setRegenerateCount(0);
                em.persist(sanQR);
                em.flush();
                writeHistoryIssued(em, sanQR);
                tx.commit();
                writeAudit(actorAccountId, managerCoSoId, ACTION_CREATE_QR, sanQR,
                        "Tạo mã QR cho sân qua regenerate (SanID=" + sanId + ").");
                return Result.ok(sanQR);
            }

            // REVOKED là terminal - không có cách nào "regenerate" một QR đã bị
            // thu hồi vĩnh viễn ở mức bản ghi (hiện tại chưa có nghiệp vụ đưa
            // current row về REVOKED - xem javadoc lớp - nhưng giữ guard này để
            // lifecycle không bao giờ bị vi phạm nếu QR-02 bổ sung hành động đó).
            if (SanQR.REVOKED.equals(sanQR.getTrangThai())) {
                tx.rollback();
                return Result.fail(ErrorCode.INVALID_TRANSITION,
                        "Mã QR đã bị thu hồi vĩnh viễn, không thể tạo lại. Vui lòng liên hệ quản trị viên.");
            }

            // Khóa lại chính SanQR đang thao tác để chống 2 request regenerate cùng lúc
            // trên cùng 1 sân (San đã khóa ở trên nhưng khóa lại SanQR cho tường minh).
            sanQR = em.find(SanQR.class, sanQR.getSanQRId(), LockModeType.PESSIMISTIC_WRITE);

            // Thu hồi token + short code cũ trong lịch sử trước khi ghi đè.
            revokeCurrentHistoryEntry(em, sanQR, actorAccountId, "Regenerate bởi Manager");

            String oldStatus = sanQR.getTrangThai();
            sanQR.setToken(generateSecureToken());
            sanQR.setShortCode(generateUniqueShortCode(em));
            sanQR.setTrangThai(SanQR.ACTIVE); // regenerate luôn kích hoạt lại, kể cả đang DISABLED
            sanQR.setUpdatedBy(actorAccountId);
            sanQR.setRegenerateCount(sanQR.getRegenerateCount() + 1);
            em.flush();

            writeHistoryIssued(em, sanQR);

            tx.commit();
            writeAudit(actorAccountId, managerCoSoId, ACTION_REGENERATE_QR, sanQR,
                    "Tạo lại mã QR (trạng thái trước: " + oldStatus + ", lần regenerate thứ "
                            + sanQR.getRegenerateCount() + ").");
            return Result.ok(sanQR);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi regenerate SanQR sanId={}: {}", sanId, e.getMessage(), e);
            return Result.fail(ErrorCode.SYSTEM, "Lỗi hệ thống khi tạo lại mã QR.");
        } finally {
            em.close();
        }
    }

    /** Bật QR đang tắt (không đổi token/short code). */
    public Result enable(int sanId, int managerCoSoId, Integer actorAccountId) {
        return setActive(sanId, managerCoSoId, actorAccountId, true);
    }

    /** Tắt QR tạm thời (không đổi token/short code, không revoke - bật lại được ngay). */
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

            SanQR sanQR = findBySanId(em, sanId);
            if (sanQR == null) {
                tx.rollback();
                return Result.fail(ErrorCode.NOT_FOUND, "Sân chưa có mã QR. Vui lòng tạo mã trước.");
            }
            sanQR = em.find(SanQR.class, sanQR.getSanQRId(), LockModeType.PESSIMISTIC_WRITE);

            if (SanQR.REVOKED.equals(sanQR.getTrangThai())) {
                tx.rollback();
                return Result.fail(ErrorCode.INVALID_TRANSITION, "Mã QR đã bị thu hồi, vui lòng tạo lại mã mới.");
            }
            // ACTIVE->ACTIVE và DISABLED->DISABLED không phải lỗi nghiêm trọng
            // (idempotent theo góc nhìn người dùng: bấm 2 lần nút Tắt không nên
            // báo lỗi) nhưng KHÔNG được coi là một "thay đổi" thật - không ghi
            // audit/không bump UpdatedAt để lịch sử phản ánh đúng số lần đổi
            // trạng thái thật sự, không đếm click thừa.
            String targetStatus = active ? SanQR.ACTIVE : SanQR.DISABLED;
            if (targetStatus.equals(sanQR.getTrangThai())) {
                tx.commit();
                return Result.ok(sanQR);
            }

            sanQR.setTrangThai(targetStatus);
            sanQR.setUpdatedBy(actorAccountId);

            tx.commit();
            writeAudit(actorAccountId, managerCoSoId, active ? ACTION_ENABLE_QR : ACTION_DISABLE_QR, sanQR,
                    (active ? "Bật lại" : "Tắt") + " mã QR cho sân (SanID=" + sanId + ").");
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
     * Trả về DTO công khai (không lộ ID/token/entity nội bộ) - xem SanQRResolveDTO.
     * Phân biệt rõ 4 lý do thất bại nội bộ (ResolveOutcome) - KHÔNG gộp chung
     * "not found" để tránh dùng lỗi mơ hồ che giấu trạng thái thật (cần cho log
     * an ninh phát hiện quét token REVOKED lặp lại), nhưng DTO trả ra ngoài chỉ
     * hiện thông báo phù hợp, không lộ lý do kỹ thuật chi tiết hơn mức cần thiết.
     * Chỉ đọc - không mở transaction ghi, không khóa hàng.
     */
    public PublicResolveResult resolve(UUID token) {
        if (token == null) {
            return new PublicResolveResult(ResolveOutcome.NOT_FOUND, SanQRResolveDTO.notFound());
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            SanQR sanQR = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.token = :token", SanQR.class)
                    .setParameter("token", token)
                    .getResultStream().findFirst().orElse(null);
            return resolveInternal(em, sanQR, SanQRSecurityUtil.hashToken(token), null);
        } catch (Exception e) {
            logger.error("Lỗi resolve SanQR token={}: {}", token, e.getMessage(), e);
            return new PublicResolveResult(ResolveOutcome.NOT_FOUND, SanQRResolveDTO.notFound());
        } finally {
            em.close();
        }
    }

    /**
     * Resolve bằng short code (fallback khi không quét được QR - task sau).
     * Không phân biệt hoa/thường (chuẩn hoá qua SanQRSecurityUtil.normalizeShortCode).
     */
    public PublicResolveResult resolveActiveShortCode(String rawShortCode) {
        String normalized = SanQRSecurityUtil.normalizeShortCode(rawShortCode);
        if (normalized == null || normalized.isEmpty()) {
            return new PublicResolveResult(ResolveOutcome.NOT_FOUND, SanQRResolveDTO.notFound());
        }
        EntityManager em = JPAUtil.getEntityManager();
        try {
            SanQR sanQR = em.createQuery(
                    "SELECT q FROM SanQR q WHERE q.shortCode = :code", SanQR.class)
                    .setParameter("code", normalized)
                    .getResultStream().findFirst().orElse(null);
            return resolveInternal(em, sanQR, null, normalized);
        } catch (Exception e) {
            logger.error("Lỗi resolveActiveShortCode: {}", e.getMessage(), e);
            return new PublicResolveResult(ResolveOutcome.NOT_FOUND, SanQRResolveDTO.notFound());
        } finally {
            em.close();
        }
    }

    /**
     * Lõi dùng chung cho resolve(token) và resolveActiveShortCode(). Nếu không
     * tìm thấy bản ghi current (sanQR null) thì tra lịch sử để phân biệt REVOKED
     * (đã từng tồn tại, bị thay - token tra bằng hash, short code tra bằng giá
     * trị chuẩn hoá vì lưu plaintext) với NOT_FOUND thật sự (chưa từng tồn tại /
     * đoán mò).
     */
    private PublicResolveResult resolveInternal(EntityManager em, SanQR sanQR, String tokenHash, String normalizedShortCode) {
        if (sanQR == null) {
            boolean wasIssuedBefore = existsInHistory(em, tokenHash, normalizedShortCode);
            ResolveOutcome outcome = wasIssuedBefore ? ResolveOutcome.REVOKED : ResolveOutcome.NOT_FOUND;
            SanQRResolveDTO dto = wasIssuedBefore ? SanQRResolveDTO.revoked() : SanQRResolveDTO.notFound();
            return new PublicResolveResult(outcome, dto);
        }
        if (SanQR.REVOKED.equals(sanQR.getTrangThai())) {
            return new PublicResolveResult(ResolveOutcome.REVOKED, SanQRResolveDTO.revoked());
        }
        San san = em.find(San.class, sanQR.getSanId());
        if (san == null || san.isDeleted()) {
            return new PublicResolveResult(ResolveOutcome.NOT_FOUND, SanQRResolveDTO.notFound());
        }
        CoSo coSo = em.find(CoSo.class, san.getCoSoID());
        String tenCoSo = coSo != null ? coSo.getTenCoSo() : null;

        if (SanQR.DISABLED.equals(sanQR.getTrangThai())) {
            return new PublicResolveResult(ResolveOutcome.DISABLED, SanQRResolveDTO.disabled(tenCoSo, san.getTenSan()));
        }
        // Sân bị khóa/bảo trì ở tầng vận hành cũng không cho quét, dù QR còn ACTIVE.
        if (!CheckInDAO.FIELD_STATUS_AVAILABLE.equals(san.getTrangThai())
                && !CheckInDAO.BOOKING_STATUS_IN_USE.equals(san.getTrangThai())) {
            return new PublicResolveResult(ResolveOutcome.FACILITY_INACTIVE,
                    SanQRResolveDTO.facilityInactive(tenCoSo, san.getTenSan()));
        }

        String tenMonTheThao = null;
        LoaiSan loaiSan = em.find(LoaiSan.class, san.getLoaiSanID());
        if (loaiSan != null) {
            MonTheThao mon = em.find(MonTheThao.class, loaiSan.getMonTheThaoID());
            if (mon != null) tenMonTheThao = mon.getTenMon();
        }

        return new PublicResolveResult(ResolveOutcome.OK,
                SanQRResolveDTO.okWithSanId(tenCoSo, san.getTenSan(), tenMonTheThao, san.getSanID()));
    }

    /**
     * @param tokenHash SHA-256(token) để so khớp cột tokenHash, hoặc null nếu đang tra theo short code.
     * @param normalizedShortCode short code đã chuẩn hoá (KHÔNG hash - short code lưu plaintext
     *     trong lịch sử, xem writeHistoryIssued) để so khớp cột shortCode, hoặc null nếu đang tra theo token.
     */
    private boolean existsInHistory(EntityManager em, String tokenHash, String normalizedShortCode) {
        if (tokenHash != null) {
            Long count = em.createQuery(
                    "SELECT COUNT(h) FROM SanQRTokenHistory h WHERE h.tokenHash = :hash", Long.class)
                    .setParameter("hash", tokenHash)
                    .getSingleResult();
            if (count != null && count > 0) return true;
        }
        if (normalizedShortCode != null) {
            Long count = em.createQuery(
                    "SELECT COUNT(h) FROM SanQRTokenHistory h WHERE h.shortCode = :code", Long.class)
                    .setParameter("code", normalizedShortCode)
                    .getSingleResult();
            return count != null && count > 0;
        }
        return false;
    }

    // ── Helpers (phải gọi bên trong transaction đang mở của lời gọi, trừ khi ghi chú khác) ──

    private SanQR findBySanId(EntityManager em, int sanId) {
        return em.createQuery("SELECT q FROM SanQR q WHERE q.sanId = :sanId", SanQR.class)
                .setParameter("sanId", sanId)
                .getResultStream().findFirst().orElse(null);
    }

    /** UUID.randomUUID() là UUID version 4 chuẩn (RFC 4122), dùng SecureRandom nội bộ trong JDK - không có thành phần thời gian/địa chỉ máy như UUID v1, không suy ra được từ SanID/CoSoID. */
    private UUID generateSecureToken() {
        return UUID.randomUUID();
    }

    /** Sinh short code unique trong DB, thử tối đa MAX_SHORT_CODE_GENERATION_ATTEMPTS lần trước khi coi là lỗi hệ thống - phải gọi trong transaction đang mở (kiểm tra unique cần thấy dữ liệu mới nhất). */
    private String generateUniqueShortCode(EntityManager em) {
        for (int attempt = 0; attempt < MAX_SHORT_CODE_GENERATION_ATTEMPTS; attempt++) {
            String candidate = SanQRSecurityUtil.generateShortCode();
            Long count = em.createQuery(
                    "SELECT COUNT(q) FROM SanQR q WHERE q.shortCode = :code", Long.class)
                    .setParameter("code", candidate)
                    .getSingleResult();
            if (count == null || count == 0) return candidate;
        }
        throw new IllegalStateException("Không thể sinh short code duy nhất sau "
                + MAX_SHORT_CODE_GENERATION_ATTEMPTS + " lần thử.");
    }

    private void writeHistoryIssued(EntityManager em, SanQR sanQR) {
        SanQRTokenHistory history = new SanQRTokenHistory();
        history.setSanQRId(sanQR.getSanQRId());
        history.setSanId(sanQR.getSanId());
        history.setTokenHash(SanQRSecurityUtil.hashToken(sanQR.getToken()));
        history.setShortCode(sanQR.getShortCode());
        history.setTrangThai(SanQRTokenHistory.ISSUED);
        em.persist(history);
    }

    private void revokeCurrentHistoryEntry(EntityManager em, SanQR sanQR, Integer actorAccountId, String reason) {
        String tokenHash = SanQRSecurityUtil.hashToken(sanQR.getToken());
        SanQRTokenHistory current = em.createQuery(
                "SELECT h FROM SanQRTokenHistory h WHERE h.tokenHash = :hash", SanQRTokenHistory.class)
                .setParameter("hash", tokenHash)
                .getResultStream().findFirst().orElse(null);
        if (current != null) {
            current.setTrangThai(SanQRTokenHistory.REVOKED);
            current.setRevokedAt(LocalDateTime.now());
            current.setRevokedBy(actorAccountId);
            current.setRevokeReason(reason);
        }
    }

    /**
     * Ghi AuditLog SAU KHI transaction chính đã commit thành công (KHÔNG gọi
     * trước tx.commit()). Lý do: AuditLogDAOImpl.save() tự mở một
     * EntityManager/transaction RIÊNG và commit ngay lập tức - nó không tham
     * gia vào transaction chính của SanQRService. Nếu gọi writeAudit() trước
     * tx.commit() rồi transaction chính rollback vì lỗi phát sinh sau đó, bản
     * ghi audit "đã xảy ra" sẽ vẫn tồn tại dù hành động QR thực tế KHÔNG xảy
     * ra - audit log nói dối. Gọi sau tx.commit() đảm bảo audit chỉ được ghi
     * khi hành động chính chắc chắn đã thành công.
     * Đây là chính sách audit chung của cả project (AuditLogService nuốt mọi
     * exception, không bao giờ làm hỏng luồng nghiệp vụ chính) - nếu ghi audit
     * thất bại ở đây, request VẪN trả về thành công cho Manager vì hành động
     * QR thật sự đã xảy ra, chỉ riêng bản ghi audit bị mất (đã log lỗi).
     * Dùng logSystem() vì SanQRService không có HttpServletRequest (Service
     * layer thuần, chưa có Servlet gọi vào ở QR-01B) - actorName là accountId
     * dạng chuỗi, KHÔNG log token/short code đầy đủ, chỉ log SanQRID + trạng thái.
     */
    private void writeAudit(Integer actorAccountId, int coSoId, String action, SanQR sanQR, String details) {
        String actorName = actorAccountId != null ? ("AccountID:" + actorAccountId) : "UNKNOWN";
        AuditLogService.logSystem(actorName, coSoId, action, ENTITY_SAN_QR,
                String.valueOf(sanQR.getSanQRId()), "SanQR#" + sanQR.getSanQRId(), details);
    }
}
