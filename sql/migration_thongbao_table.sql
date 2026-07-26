-- ============================================================
-- Migration: Tạo bảng ThongBao (nếu chưa có) + thêm cột còn thiếu
-- Idempotent: chạy nhiều lần không có lỗi.
-- Chạy script này TRƯỚC migration_notification_marketing_refund_review.sql
-- ============================================================

-- ============================================================
-- 1. Tạo bảng ThongBao nếu chưa tồn tại
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND type = 'U')
BEGIN
    CREATE TABLE dbo.ThongBao (
        ThongBaoID      INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
        AccountID       INT             NOT NULL,
        TieuDe          NVARCHAR(255)   NOT NULL,
        NoiDung         NVARCHAR(1000)  NULL,
        LoaiThongBao    NVARCHAR(100)   NULL,
        DaDoc           BIT             NOT NULL DEFAULT (0),
        ThoiGianGui     DATETIME        NOT NULL DEFAULT (GETDATE()),
        MaBanGhi        NVARCHAR(100)   NULL,
        DuongDan        NVARCHAR(500)   NULL,
        IsDeleted       BIT             NOT NULL DEFAULT (0),
        DeletedAt       DATETIME        NULL,
        DeletedBy       INT             NULL
    );
    PRINT 'Created table: ThongBao';
END
ELSE
BEGIN
    PRINT 'Skip: ThongBao already exists';
END
GO

-- ============================================================
-- 2. Thêm cột còn thiếu nếu bảng đã tồn tại từ trước (thiếu cột soft-delete)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'IsDeleted')
BEGIN
    ALTER TABLE dbo.ThongBao ADD IsDeleted BIT NOT NULL DEFAULT (0);
    PRINT 'Added: ThongBao.IsDeleted';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'DeletedAt')
BEGIN
    ALTER TABLE dbo.ThongBao ADD DeletedAt DATETIME NULL;
    PRINT 'Added: ThongBao.DeletedAt';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'DeletedBy')
BEGIN
    ALTER TABLE dbo.ThongBao ADD DeletedBy INT NULL;
    PRINT 'Added: ThongBao.DeletedBy';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'MaBanGhi')
BEGIN
    ALTER TABLE dbo.ThongBao ADD MaBanGhi NVARCHAR(100) NULL;
    PRINT 'Added: ThongBao.MaBanGhi';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'DuongDan')
BEGIN
    ALTER TABLE dbo.ThongBao ADD DuongDan NVARCHAR(500) NULL;
    PRINT 'Added: ThongBao.DuongDan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'LoaiThongBao')
BEGIN
    ALTER TABLE dbo.ThongBao ADD LoaiThongBao NVARCHAR(100) NULL;
    PRINT 'Added: ThongBao.LoaiThongBao';
END
GO

-- ============================================================
-- 3. Index tăng tốc query theo AccountID (thường xuyên dùng)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'IX_ThongBao_AccountID_ThoiGian')
BEGIN
    CREATE NONCLUSTERED INDEX IX_ThongBao_AccountID_ThoiGian
        ON dbo.ThongBao (AccountID, ThoiGianGui DESC)
        INCLUDE (DaDoc, IsDeleted);
    PRINT 'Created index: IX_ThongBao_AccountID_ThoiGian';
END
GO

-- ============================================================
-- 4. Index cho countUnread (DaDoc = 0)
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ThongBao') AND name = N'IX_ThongBao_Unread')
BEGIN
    CREATE NONCLUSTERED INDEX IX_ThongBao_Unread
        ON dbo.ThongBao (AccountID, DaDoc)
        WHERE IsDeleted = 0;
    PRINT 'Created index: IX_ThongBao_Unread';
END
GO

PRINT '=== Migration migration_thongbao_table: DONE ===';
GO
