-- Migration: Cấu hình PayOS riêng theo từng Cơ Sở (Admin quản lý qua giao diện)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Nếu 3 cột này đã được thêm thủ công trước đó, script sẽ bỏ qua (không ghi đè).

USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'CoSo') AND name = N'PayOS_ClientID')
BEGIN
    ALTER TABLE CoSo ADD PayOS_ClientID NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột PayOS_ClientID vào CoSo.';
END
ELSE
    PRINT N'Cột PayOS_ClientID đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'CoSo') AND name = N'PayOS_ApiKey')
BEGIN
    ALTER TABLE CoSo ADD PayOS_ApiKey NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột PayOS_ApiKey vào CoSo.';
END
ELSE
    PRINT N'Cột PayOS_ApiKey đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'CoSo') AND name = N'PayOS_ChecksumKey')
BEGIN
    ALTER TABLE CoSo ADD PayOS_ChecksumKey NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột PayOS_ChecksumKey vào CoSo.';
END
ELSE
    PRINT N'Cột PayOS_ChecksumKey đã tồn tại, bỏ qua.';
GO
