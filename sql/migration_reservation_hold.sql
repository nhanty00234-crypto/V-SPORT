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

PRINT N'Migration reservation-hold hoàn tất.';
GO
