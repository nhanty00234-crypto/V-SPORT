-- =============================================================================
-- diagnose_and_repair_ghost_booking.sql
--
-- Bối cảnh (2026-07-16): Khách hàng A đã đạt giới hạn 3 lượt đặt/ngày nhưng bước
-- "Chọn ngày & giờ" (giữ chỗ tạm - SoftHold) vẫn tạo được hold thành công vì bước
-- đó không kiểm tra giới hạn. Khách hàng B chọn đúng slot bị chặn bởi hold "ma"
-- này, nhận lỗi "Đã có người đang giữ khung giờ này". Hold không được release khi
-- request đặt sân thật (DatSanServlet) sau đó bị từ chối vì giới hạn, nên tồn tại
-- tới khi tự hết hạn theo TTL (SOFT_HOLD_TIMEOUT_MINUTES = 2 phút).
--
-- ĐÃ XÁC NHẬN QUA AUDIT READ-ONLY: bản ghi block slot SanID=20 (Sân cầu lông -
-- Sân 1, Sân Long Điền), 2026-07-16, 10:00-10:30 là SoftHoldID=74, AccountID=32,
-- CreatedTime=2026-07-16 02:47:19 (server time UTC). Không có row LichDatSan nào
-- cho slot này - ĐÂY KHÔNG PHẢI "ghost booking" (LichDatSan) mà là "ghost SoftHold".
-- Root cause code đã được vá ở SoftHoldDAOImpl.createHold() (thêm kiểm tra giới
-- hạn 3 booking/ngày trước khi tạo hold) và DatSanServlet (giải phóng hold ngay
-- khi submit thật, bất kể kết quả).
--
-- Audit cũng phát hiện thêm 2 bản ghi LichDatSan "Chờ thanh toán" legacy (DatSanID
-- 45, 46 - CoSoID=7) có HoldExpiresAt = NULL, ngày đã qua từ lâu (2026-07-09/11) -
-- không bao giờ được BookingLifecycleService.runExpirySweep() quét (điều kiện cũ
-- yêu cầu HoldExpiresAt IS NOT NULL). Không chặn overlap (NULL không thỏa điều
-- kiện overlap ở bất kỳ query nào), nhưng kẹt vĩnh viễn ở "Chờ thanh toán" và
-- không có tab Manager nào hiển thị rõ. Đã vá runExpirySweep() để quét thêm
-- trường hợp NULL + đã qua giờ kết thúc theo lịch.
--
-- Nguyên tắc: KHÔNG DELETE lịch sử booking. Chỉ chuyển trạng thái khi đã chứng
-- minh không có thanh toán thật/invoice PAID/active session/webhook hợp lệ.
-- SoftHold KHÔNG phải dữ liệu nghiệp vụ/lịch sử (không invoice, không cam kết
-- khách hàng, TTL 2 phút theo thiết kế) nên DELETE các hold đã hết hạn là thao
-- tác bảo trì thường quy - giống hệt SoftHoldDAOImpl.deleteExpiredHoldsStatic()
-- đã chạy sẵn mỗi khi có người tạo hold mới.
-- =============================================================================

SET XACT_ABORT ON;

-- Đổi các biến này trước khi chạy REPAIR. Mặc định: không repair gì (chỉ DIAGNOSTIC).
DECLARE @TargetDatSanID INT = -1;      -- DatSanID cụ thể cần chuyển "Quá hạn" (Trường hợp B)
DECLARE @RunSoftHoldCleanup BIT = 0;   -- 1 = xóa các SoftHold đã hết hạn TTL (thao tác bảo trì thường quy)


-- =============================================================================
-- PHẦN 1: DIAGNOSTIC (SELECT-ONLY, luôn an toàn để chạy)
-- =============================================================================

PRINT '--- 1a. SoftHold hiện có, đánh dấu hàng nào đã hết hạn TTL ---';
SELECT
    SoftHoldID, AccountID, SanID, NgayDat, GioBatDau, GioKetThuc, CreatedTime,
    DATEDIFF(MINUTE, CreatedTime, GETDATE()) AS MinutesElapsed,
    CASE WHEN DATEDIFF(MINUTE, CreatedTime, GETDATE()) > 2 THEN N'ĐÃ HẾT HẠN (ghost)' ELSE N'Còn hiệu lực' END AS Status
FROM dbo.SoftHold
ORDER BY SoftHoldID DESC;

PRINT '--- 1b. Chi tiết Account tạo mỗi SoftHold + số booking đang hoạt động của họ trong ngày đó ---';
SELECT
    sh.SoftHoldID, sh.AccountID, a.Username, a.FullName, sh.SanID, sh.NgayDat,
    (SELECT COUNT(*) FROM dbo.LichDatSan l WHERE l.AccountID = sh.AccountID AND l.NgayDat = sh.NgayDat AND l.TrangThai <> N'Đã hủy') AS ActiveBookingCountThatDay
FROM dbo.SoftHold sh
LEFT JOIN dbo.Accounts a ON a.AccountID = sh.AccountID
ORDER BY sh.SoftHoldID DESC;

PRINT '--- 1c. LichDatSan "Chờ thanh toán" với HoldExpiresAt NULL (legacy, không được sweep) ---';
SELECT
    lds.DatSanID, lds.SanID, lds.AccountID, lds.NgayDat, lds.GioBatDau, lds.GioKetThuc,
    lds.TrangThai, lds.HoldExpiresAt, lds.CreatedTime,
    CASE WHEN CAST(lds.NgayDat AS DATETIME) + CAST(lds.GioKetThuc AS DATETIME) < GETDATE()
         THEN N'Đã qua giờ - đủ điều kiện chuyển Quá hạn' ELSE N'Chưa qua giờ' END AS RepairEligibility,
    (SELECT COUNT(*) FROM dbo.HoaDon h WHERE h.DatSanID = lds.DatSanID AND h.TrangThaiThanhToan = N'Đã thanh toán') AS PaidInvoiceCount,
    (SELECT COUNT(*) FROM dbo.PayOSPaymentAttempt p WHERE p.DatSanID = lds.DatSanID AND p.Status = N'PAID') AS PaidPayOSAttemptCount
FROM dbo.LichDatSan lds
WHERE lds.TrangThai = N'Chờ thanh toán' AND lds.HoldExpiresAt IS NULL
ORDER BY lds.DatSanID DESC;

PRINT '--- 1d. Nếu @TargetDatSanID đã chọn (<> -1): chi tiết đầy đủ để xác nhận an toàn trước khi repair ---';
IF @TargetDatSanID <> -1
BEGIN
    SELECT 'LichDatSan' AS Nguon, * FROM dbo.LichDatSan WHERE DatSanID = @TargetDatSanID;
    SELECT 'HoaDon' AS Nguon, * FROM dbo.HoaDon WHERE DatSanID = @TargetDatSanID;
    SELECT 'PayOSPaymentAttempt' AS Nguon, * FROM dbo.PayOSPaymentAttempt WHERE DatSanID = @TargetDatSanID;
    SELECT 'AuditLog lien quan' AS Nguon, * FROM dbo.AuditLog WHERE EntityType = 'LichDatSan' AND EntityID = CAST(@TargetDatSanID AS NVARCHAR(50));
END


-- =============================================================================
-- PHẦN 2: REPAIR
-- =============================================================================

-- 2a. Dọn SoftHold đã hết hạn TTL (thao tác bảo trì thường quy, không phải dữ liệu nghiệp vụ).
IF @RunSoftHoldCleanup = 1
BEGIN
    BEGIN TRANSACTION;
    DELETE FROM dbo.SoftHold WHERE DATEDIFF(MINUTE, CreatedTime, GETDATE()) > 2;
    PRINT 'SoftHold cleanup: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' hàng đã hết hạn TTL đã được xóa.';
    COMMIT TRANSACTION;
END
ELSE
BEGIN
    PRINT 'Bỏ qua SoftHold cleanup: @RunSoftHoldCleanup = 0.';
END

-- 2b. Chuyển một LichDatSan "Chờ thanh toán" cụ thể (đã xác nhận an toàn ở PHẦN 1d) sang "Quá hạn".
-- CHỈ chạy khi đã chứng minh: không có HoaDon PAID, không có PayOSPaymentAttempt PAID, đã qua giờ
-- kết thúc theo lịch. Không xóa bản ghi - chỉ đổi trạng thái, giữ nguyên lịch sử.
IF @TargetDatSanID <> -1
BEGIN
    BEGIN TRANSACTION;

    DECLARE @paidCount INT, @payosCount INT, @rowsAffected INT;

    SELECT @paidCount = COUNT(*) FROM dbo.HoaDon WHERE DatSanID = @TargetDatSanID AND TrangThaiThanhToan = N'Đã thanh toán';
    SELECT @payosCount = COUNT(*) FROM dbo.PayOSPaymentAttempt WHERE DatSanID = @TargetDatSanID AND Status = N'PAID';

    IF @paidCount > 0 OR @payosCount > 0
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'Repair bị chặn: DatSanID này có hóa đơn/thanh toán PayOS đã PAID - không phải ghost, không được đổi trạng thái.', 1;
    END

    UPDATE dbo.LichDatSan
    SET TrangThai = N'Quá hạn',
        GhiChu = CONCAT(ISNULL(GhiChu, N''), N' [Repair thủ công: Quá hạn giữ chỗ - xem sql/diagnose_and_repair_ghost_booking.sql]')
    WHERE DatSanID = @TargetDatSanID
      AND TrangThai = N'Chờ thanh toán';

    SET @rowsAffected = @@ROWCOUNT;
    IF @rowsAffected NOT IN (0, 1)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50000, 'Repair bất thường: rowsAffected không phải 0 hoặc 1. Đã rollback.', 1;
    END

    PRINT 'Rows affected: ' + CAST(@rowsAffected AS VARCHAR(10));
    SELECT DatSanID, TrangThai, GhiChu FROM dbo.LichDatSan WHERE DatSanID = @TargetDatSanID;

    -- Ghi audit (idempotent: chỉ INSERT, không phụ thuộc trạng thái trước đó).
    IF @rowsAffected = 1
    BEGIN
        -- ActorRole NOT NULL trong schema - dùng 1 (Admin) làm sentinel cho hành động repair thủ công.
        INSERT INTO dbo.AuditLog (ActorAccountID, ActorName, ActorRole, Action, EntityType, EntityID, EntityName, Details, CreatedAt)
        SELECT NULL, N'System Repair Script', 1, 'GHOST_BOOKING_REPAIRED', 'LichDatSan', CAST(@TargetDatSanID AS NVARCHAR(50)),
               N'DatSanID=' + CAST(@TargetDatSanID AS NVARCHAR(50)),
               N'Chuyển "Chờ thanh toán" (HoldExpiresAt NULL, đã qua giờ, không có thanh toán PAID) sang "Quá hạn" qua sql/diagnose_and_repair_ghost_booking.sql',
               GETDATE()
        WHERE EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.AuditLog') AND name = 'CreatedAt');
    END

    COMMIT TRANSACTION;
    PRINT 'Repair hoàn tất cho DatSanID=' + CAST(@TargetDatSanID AS VARCHAR(10)) + ' (idempotent - chạy lại sẽ không đổi gì thêm vì điều kiện WHERE TrangThai=''Chờ thanh toán'' không còn khớp).';
END
ELSE
BEGIN
    PRINT 'Bỏ qua LichDatSan repair: @TargetDatSanID = -1 (chưa chọn target).';
END
