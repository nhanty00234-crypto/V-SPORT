-- Migration: Thêm cột reservation-hold vào bảng LichDatSan
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Áp dụng cho: V-SPORT QuanLiSport_V4 trở lên
-- Liên quan: docs/superpowers/specs/2026-07-09-auto-booking-reservation-hold-design.md (mục 5)

USE QuanLiSport;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'HoldExpiresAt'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD HoldExpiresAt DATETIME2 NULL;
    PRINT N'Đã thêm cột HoldExpiresAt vào LichDatSan.';
END
ELSE
    PRINT N'Cột HoldExpiresAt đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'DepositAmount'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD DepositAmount DECIMAL(18,2) NULL;
    PRINT N'Đã thêm cột DepositAmount vào LichDatSan.';
END
ELSE
    PRINT N'Cột DepositAmount đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'PaymentMethodConfirmed'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD PaymentMethodConfirmed NVARCHAR(50) NULL;
    PRINT N'Đã thêm cột PaymentMethodConfirmed vào LichDatSan.';
END
ELSE
    PRINT N'Cột PaymentMethodConfirmed đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'TransactionCode'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD TransactionCode NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột TransactionCode vào LichDatSan.';
END
ELSE
    PRINT N'Cột TransactionCode đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'ConfirmedAt'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD ConfirmedAt DATETIME2 NULL;
    PRINT N'Đã thêm cột ConfirmedAt vào LichDatSan.';
END
ELSE
    PRINT N'Cột ConfirmedAt đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'ConfirmedBy'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD ConfirmedBy INT NULL;
    PRINT N'Đã thêm cột ConfirmedBy vào LichDatSan.';
END
ELSE
    PRINT N'Cột ConfirmedBy đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'ConfirmSource'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD ConfirmSource NVARCHAR(20) NULL;
    PRINT N'Đã thêm cột ConfirmSource vào LichDatSan.';
END
ELSE
    PRINT N'Cột ConfirmSource đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'LichDatSan') AND name = N'NoShowAt'
)
BEGIN
    ALTER TABLE LichDatSan
    ADD NoShowAt DATETIME2 NULL;
    PRINT N'Đã thêm cột NoShowAt vào LichDatSan.';
END
ELSE
    PRINT N'Cột NoShowAt đã tồn tại, bỏ qua.';
GO

-- FK ConfirmedBy → Accounts.AccountID (chỉ thêm nếu chưa có)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_LichDatSan_ConfirmedBy' AND parent_object_id = OBJECT_ID(N'LichDatSan')
)
BEGIN
    ALTER TABLE LichDatSan
    ADD CONSTRAINT FK_LichDatSan_ConfirmedBy
        FOREIGN KEY (ConfirmedBy) REFERENCES Accounts(AccountID);
    PRINT N'Đã thêm FK ConfirmedBy.';
END
GO

-- Backfill: LichDatSan "Chờ thanh toán" tạo TRƯỚC migration này có HoldExpiresAt = NULL.
-- Overlap-check mới (DatSanServlet.handleDatSan) chỉ chặn "Chờ thanh toán" khi
-- HoldExpiresAt > GETDATE() — NULL > GETDATE() là UNKNOWN (đánh giá là false trong SQL Server),
-- nên các booking "Chờ thanh toán" cũ sẽ KHÔNG chặn slot nếu không backfill cột này.
-- 10 (phút) dưới đây PHẢI khớp với Constants.BOOKING_HOLD_MINUTES bên Java (SQL không gọi
-- được hằng số Java) — nếu đổi BOOKING_HOLD_MINUTES thì phải sửa lại số này tương ứng.
-- Idempotent tự nhiên: chỉ update các row còn HoldExpiresAt IS NULL, chạy lại vô hại.
UPDATE LichDatSan
SET HoldExpiresAt = DATEADD(MINUTE, 10, CreatedTime)
WHERE TrangThai = N'Chờ thanh toán'
  AND HoldExpiresAt IS NULL
  AND CreatedTime IS NOT NULL;
PRINT N'Backfill HoldExpiresAt cho ' + CAST(@@ROWCOUNT AS NVARCHAR) + N' booking "Chờ thanh toán" cũ.';
GO

PRINT N'Migration reservation-hold hoàn tất.';
GO
