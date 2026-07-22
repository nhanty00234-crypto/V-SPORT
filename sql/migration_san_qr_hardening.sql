-- Migration: Hardening cho SanQR (QR-01B - verify + harden nền tảng QR).
-- Bổ sung sau khi migration_san_qr.sql đã chạy và được xác nhận trên DB thật:
--   1. SanQR.ShortCode - mã ngắn dự phòng khi Customer không quét được QR (không
--      cấp camera / camera lỗi / QR mờ). Sinh bằng SecureRandom, loại bỏ ký tự dễ
--      nhầm (0/O, 1/I/L), không chứa SanID. Unique trong số các QR đang tồn tại.
--   2. SanQRTokenHistory.TokenHash - thay cho việc lưu Token plaintext. Token đang
--      ACTIVE/DISABLED (trên chính bảng SanQR) vẫn cần ở dạng gốc để in lại QR -
--      đó là định danh công khai không nhạy cảm hơn chính tờ QR giấy. Nhưng LỊCH
--      SỬ token cũ (đã REVOKED) không có lý do nghiệp vụ nào cần đọc lại giá trị
--      gốc - chỉ cần so khớp "token vừa quét có từng là token cũ của sân này hay
--      không" để trả lỗi rõ ràng. Vì vậy lưu SHA-256(token cũ) thay vì plaintext.
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS/cột đã tồn tại nên
-- an toàn khi chạy lại. Không xóa dữ liệu hiện có.

USE QuanLiSport;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SanQR') AND name = 'ShortCode'
)
BEGIN
    ALTER TABLE dbo.SanQR ADD ShortCode NVARCHAR(12) NULL;
    PRINT N'Đã thêm cột SanQR.ShortCode.';
END
ELSE
    PRINT N'Cột SanQR.ShortCode đã tồn tại, bỏ qua.';
GO

-- Unique index cho ShortCode - đặt filtered (WHERE ShortCode IS NOT NULL) vì các
-- bản ghi tạo trước migration này (nếu có) sẽ có ShortCode = NULL tạm thời, và
-- SQL Server cho phép nhiều NULL trong unique index mặc định nên không cần lo
-- việc backfill NULL gây trùng.
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SanQR') AND name = 'UQ_SanQR_ShortCode'
)
BEGIN
    CREATE UNIQUE INDEX UQ_SanQR_ShortCode ON dbo.SanQR (ShortCode) WHERE ShortCode IS NOT NULL;
    PRINT N'Đã tạo unique index UQ_SanQR_ShortCode.';
END
ELSE
    PRINT N'Index UQ_SanQR_ShortCode đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'TokenHash'
)
BEGIN
    -- Cho phép NULL trong lúc chuyển đổi: các dòng lịch sử tạo bởi migration_san_qr.sql
    -- (trước hardening) chỉ có Token plaintext, không có hash. Ứng dụng ở tầng Service
    -- sẽ không còn ghi Token plaintext cho bản ghi MỚI kể từ sau migration này - xem
    -- SanQRService.java. Không backfill hash ngược cho dữ liệu cũ vì tại thời điểm
    -- hardening (ngay sau QR-01) DB thực tế chưa có token nào bị revoke.
    ALTER TABLE dbo.SanQRTokenHistory ADD TokenHash NVARCHAR(64) NULL;
    PRINT N'Đã thêm cột SanQRTokenHistory.TokenHash.';
END
ELSE
    PRINT N'Cột SanQRTokenHistory.TokenHash đã tồn tại, bỏ qua.';
GO

-- Cột Token (plaintext, tạo bởi migration_san_qr.sql) không còn được entity
-- SanQRTokenHistory ghi nữa kể từ hardening này (chỉ ghi TokenHash) - phải nới
-- NOT NULL thành nullable, nếu không mọi INSERT mới sẽ vi phạm constraint.
-- Cột được GIỮ LẠI (không DROP) để không phá dữ liệu lịch sử plaintext nếu đã
-- có trước khi hardening này chạy trên một môi trường khác.
IF EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'Token' AND is_nullable = 0
)
BEGIN
    ALTER TABLE dbo.SanQRTokenHistory ALTER COLUMN Token UNIQUEIDENTIFIER NULL;
    PRINT N'Đã nới SanQRTokenHistory.Token thành nullable (entity không còn ghi plaintext).';
END
ELSE
    PRINT N'SanQRTokenHistory.Token đã nullable hoặc không tồn tại, bỏ qua.';
GO

-- UQ_SanQRTokenHistory_Token (tạo bởi migration_san_qr.sql) là unique index
-- KHÔNG filtered trên cột Token. SQL Server coi mọi giá trị NULL trong một
-- unique index không-filtered là "bằng nhau" kể từ dòng NULL thứ 2 trở đi (khác
-- ANSI NULL semantics thông thường) - vì entity giờ luôn ghi Token = NULL cho
-- MỌI bản ghi mới, dòng lịch sử thứ 2 trở đi sẽ bị chặn bởi chính index này.
-- Phải xoá index cũ và tạo lại dạng FILTERED (WHERE Token IS NOT NULL), cùng
-- kiểu với UQ_SanQR_ShortCode ở trên - cho phép nhiều NULL, chỉ áp unique cho
-- các dòng Token cũ (nếu có) từng ghi plaintext trước hardening này.
IF EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'UQ_SanQRTokenHistory_Token'
      AND has_filter = 0
)
BEGIN
    DROP INDEX UQ_SanQRTokenHistory_Token ON dbo.SanQRTokenHistory;
    CREATE UNIQUE INDEX UQ_SanQRTokenHistory_Token ON dbo.SanQRTokenHistory (Token) WHERE Token IS NOT NULL;
    PRINT N'Đã chuyển UQ_SanQRTokenHistory_Token sang filtered index (cho phép nhiều NULL).';
END
ELSE
    PRINT N'UQ_SanQRTokenHistory_Token đã filtered hoặc không tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'IX_SanQRTokenHistory_TokenHash'
)
BEGIN
    CREATE INDEX IX_SanQRTokenHistory_TokenHash ON dbo.SanQRTokenHistory (TokenHash);
    PRINT N'Đã tạo index IX_SanQRTokenHistory_TokenHash.';
END
ELSE
    PRINT N'Index IX_SanQRTokenHistory_TokenHash đã tồn tại, bỏ qua.';
GO

-- ShortCode cũng cần lịch sử tương tự Token, để nhận diện "mã ngắn cũ" sau
-- regenerate giống hệt cách xử lý Token cũ.
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'ShortCode'
)
BEGIN
    ALTER TABLE dbo.SanQRTokenHistory ADD ShortCode NVARCHAR(12) NULL;
    PRINT N'Đã thêm cột SanQRTokenHistory.ShortCode.';
END
ELSE
    PRINT N'Cột SanQRTokenHistory.ShortCode đã tồn tại, bỏ qua.';
GO

-- Rollback (thủ công, chỉ chạy nếu cần gỡ migration này và chưa có dữ liệu quan trọng):
--   DROP INDEX IX_SanQRTokenHistory_TokenHash ON dbo.SanQRTokenHistory;
--   ALTER TABLE dbo.SanQRTokenHistory DROP COLUMN TokenHash, ShortCode;
--   DROP INDEX UQ_SanQR_ShortCode ON dbo.SanQR;
--   ALTER TABLE dbo.SanQR DROP COLUMN ShortCode;
