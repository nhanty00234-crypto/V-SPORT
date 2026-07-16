-- =============================================================================
-- repair_legacy_deleted_facility.sql
--
-- Mục đích: chẩn đoán và (nếu thực sự cần) vá dữ liệu CoSo/Account legacy sau khi
-- phát hiện lỗi "tài khoản của cơ sở đã xóa vẫn hoạt động được".
--
-- KẾT QUẢ AUDIT NGÀY 2026-07-16 (đã chạy DIAGNOSTIC bên dưới trên DB thật, chỉ đọc):
--   - Không có Account/San nào orphan (CoSoID không khớp bất kỳ row CoSo nào).
--   - Không có CoSo nào bị hard-delete còn sót dữ liệu con orphan.
--   - Hai CoSo đang ở trạng thái IsDeleted=1 (CoSoID 11, 14) là các yêu cầu mở cơ sở
--     (OwnerRequest) đã bị Admin từ chối (TrangThai='Từ chối') - đã đúng convention,
--     0 San/Booking/Invoice, tài khoản chủ sở hữu tương ứng đã IsLocked=1 sẵn.
--   => KHÔNG CẦN REPAIR dữ liệu tại thời điểm audit. Root cause thực sự của báo cáo
--      "Staff Portal vẫn hoạt động ở cơ sở đã xóa" là THIẾU cơ chế enforcement
--      (login, filter, service) chứ không phải dữ liệu CoSo/Account bị sai - xem
--      docs/test-reports/facility-deactivation-access-control-report.md.
--
-- Script này được giữ lại làm công cụ vận hành cho TƯƠNG LAI: nếu một CoSo từng bị
-- hard-delete (KHÔNG nên xảy ra nữa vì FacilityTrashService chỉ soft-delete, nhưng
-- dữ liệu cũ trước khi có cơ chế này vẫn có thể tồn tại), dùng phần REPAIR bên dưới
-- để đưa CoSo về tombstone (IsDeleted=1) đúng cách, sau khi xác nhận đúng CoSoID.
--
-- Nguyên tắc bắt buộc:
--   - Không DELETE bất kỳ dòng nào.
--   - Không cập nhật/xóa dữ liệu con (San, LichDatSan, HoaDon, ...).
--   - Không tạo lại CoSo/Account/HoaDon nếu thiếu dữ liệu xác thực (không tự bịa).
--   - Idempotent: chạy lại nhiều lần không gây lỗi/không đổi thêm gì nếu đã đúng.
--   - Có transaction + XACT_ABORT.
--   - Luôn chạy DIAGNOSTIC trước, xác nhận đúng @TargetCoSoID rồi mới chạy REPAIR.
-- =============================================================================

SET XACT_ABORT ON;

-- Đổi giá trị này thành CoSoID cần kiểm tra/vá trước khi chạy REPAIR bên dưới.
DECLARE @TargetCoSoID INT = -1; -- -1 = chưa chọn target, phần REPAIR sẽ tự bỏ qua.


-- =============================================================================
-- PHẦN 1: DIAGNOSTIC (SELECT-ONLY, luôn an toàn để chạy)
-- =============================================================================

PRINT '--- 1a. Toàn bộ CoSo và trạng thái ---';
SELECT
    CoSoID,
    TenCoSo,
    TrangThai,
    IsDeleted,
    DeletedAt,
    DeletedBy,
    AccountID_QuanLy
FROM dbo.CoSo
ORDER BY CoSoID;

PRINT '--- 1b. Account orphan: CoSoID không NULL nhưng không khớp CoSo nào ---';
SELECT
    a.AccountID, a.Username, a.RoleID, a.CoSoID, a.IsDeleted AS AccountIsDeleted, a.IsLocked
FROM dbo.Accounts a
LEFT JOIN dbo.CoSo cs ON cs.CoSoID = a.CoSoID
WHERE a.CoSoID IS NOT NULL AND cs.CoSoID IS NULL
ORDER BY a.CoSoID, a.AccountID;

PRINT '--- 1c. San orphan: CoSoID không khớp CoSo nào ---';
SELECT s.SanID, s.TenSan, s.CoSoID
FROM dbo.San s
LEFT JOIN dbo.CoSo cs ON cs.CoSoID = s.CoSoID
WHERE cs.CoSoID IS NULL
ORDER BY s.CoSoID, s.SanID;

PRINT '--- 1d. Account thuộc CoSo đã bị soft-delete (IsDeleted=1) - phải bị chặn login ---';
SELECT
    a.AccountID, a.Username, a.RoleID, a.CoSoID, a.IsLocked,
    cs.TenCoSo, cs.IsDeleted AS CoSoIsDeleted, cs.DeletedAt
FROM dbo.Accounts a
INNER JOIN dbo.CoSo cs ON cs.CoSoID = a.CoSoID
WHERE cs.IsDeleted = 1
ORDER BY a.CoSoID, a.AccountID;

PRINT '--- 1e. Nếu @TargetCoSoID đã chọn (<> -1): chi tiết dữ liệu con của target ---';
IF @TargetCoSoID <> -1
BEGIN
    SELECT 'CoSo' AS Nguon, * FROM dbo.CoSo WHERE CoSoID = @TargetCoSoID;
    SELECT 'Accounts' AS Nguon, AccountID, Username, RoleID, IsDeleted, IsLocked FROM dbo.Accounts WHERE CoSoID = @TargetCoSoID;
    SELECT 'San' AS Nguon, SanID, TenSan, TrangThai, IsDeleted FROM dbo.San WHERE CoSoID = @TargetCoSoID;
    SELECT 'LichDatSan (qua San)' AS Nguon, COUNT(*) AS SoLuong
        FROM dbo.LichDatSan l INNER JOIN dbo.San s ON l.SanID = s.SanID WHERE s.CoSoID = @TargetCoSoID;
    SELECT 'HoaDon (qua LichDatSan/San)' AS Nguon, COUNT(*) AS SoLuong
        FROM dbo.HoaDon h
        INNER JOIN dbo.LichDatSan l ON h.DatSanID = l.DatSanID
        INNER JOIN dbo.San s ON l.SanID = s.SanID
        WHERE s.CoSoID = @TargetCoSoID;
END


-- =============================================================================
-- PHẦN 2: REPAIR (chỉ chạy nếu đã xác nhận đúng @TargetCoSoID ở trên)
-- =============================================================================
-- Kịch bản duy nhất được xử lý: CoSo row VẪN CÒN TỒN TẠI nhưng đang ở trạng thái
-- hoạt động (IsDeleted=0/NULL) trong khi thực tế đã "chết" theo một nguồn xác thực
-- khác (audit log, ghi chú vận hành...) - đưa nó về tombstone IsDeleted=1 đúng cách
-- bằng CHÍNH câu UPDATE mà FacilityTrashService.softDeleteFacility() dùng.
--
-- KHÔNG xử lý kịch bản "CoSo row đã bị hard-delete" (Trường hợp B) ở đây - nếu gặp
-- trường hợp đó, KHÔNG tự INSERT lại một CoSo giả. Phải xác định đủ dữ liệu gốc
-- (audit log/backup) trước, ngoài phạm vi script tự động này.

IF @TargetCoSoID <> -1
BEGIN
    BEGIN TRANSACTION;

    DECLARE @rowsAffected INT;

    UPDATE dbo.CoSo
    SET IsDeleted = 1,
        DeletedAt = SYSUTCDATETIME(),
        DeletedBy = NULL -- Ghi rõ AccountID admin thực hiện nếu biết; NULL đánh dấu "vá tự động, không rõ actor"
    WHERE CoSoID = @TargetCoSoID
      AND (IsDeleted = 0 OR IsDeleted IS NULL);

    SET @rowsAffected = @@ROWCOUNT;

    PRINT 'Rows affected: ' + CAST(@rowsAffected AS VARCHAR(10));

    IF @rowsAffected NOT IN (0, 1)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'Repair bất thường: rowsAffected không phải 0 hoặc 1. Đã rollback.', 1;
    END

    -- Verify sau khi vá
    SELECT CoSoID, TenCoSo, IsDeleted, DeletedAt, DeletedBy FROM dbo.CoSo WHERE CoSoID = @TargetCoSoID;

    COMMIT TRANSACTION;
    PRINT 'Repair hoàn tất cho CoSoID=' + CAST(@TargetCoSoID AS VARCHAR(10)) + ' (idempotent - chạy lại sẽ không đổi gì thêm).';
END
ELSE
BEGIN
    PRINT 'Bỏ qua REPAIR: @TargetCoSoID = -1 (chưa chọn target). Chỉ DIAGNOSTIC đã chạy.';
END
