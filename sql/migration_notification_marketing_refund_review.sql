-- ============================================================
-- Migration: Notification marketing pref, HoanTien new cols,
--            DanhGia unique constraint
-- Idempotent: chạy nhiều lần không có lỗi.
-- ============================================================

-- ============================================================
-- 1. Accounts.NhanThongBaoMarketing (BIT DEFAULT 1)
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.Accounts')
      AND name = N'NhanThongBaoMarketing'
)
BEGIN
    ALTER TABLE dbo.Accounts
        ADD NhanThongBaoMarketing BIT NOT NULL
            CONSTRAINT DF_Accounts_NhanThongBaoMarketing DEFAULT (1);
    PRINT 'Added: Accounts.NhanThongBaoMarketing';
END
ELSE
BEGIN
    PRINT 'Skip: Accounts.NhanThongBaoMarketing already exists';
END
GO

-- ============================================================
-- 2. HoanTien — 7 cột mới cho quản lý xử lý hoàn tiền
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'AccountID_NguoiXuLy')
BEGIN
    ALTER TABLE dbo.HoanTien ADD AccountID_NguoiXuLy INT NULL;
    PRINT 'Added: HoanTien.AccountID_NguoiXuLy';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'GhiChuXuLy')
BEGIN
    ALTER TABLE dbo.HoanTien ADD GhiChuXuLy NVARCHAR(500) NULL;
    PRINT 'Added: HoanTien.GhiChuXuLy';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'MaGiaoDichHoan')
BEGIN
    ALTER TABLE dbo.HoanTien ADD MaGiaoDichHoan NVARCHAR(100) NULL;
    PRINT 'Added: HoanTien.MaGiaoDichHoan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'ThoiGianXuLy')
BEGIN
    ALTER TABLE dbo.HoanTien ADD ThoiGianXuLy DATETIME NULL;
    PRINT 'Added: HoanTien.ThoiGianXuLy';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'NganHangNhan')
BEGIN
    ALTER TABLE dbo.HoanTien ADD NganHangNhan NVARCHAR(100) NULL;
    PRINT 'Added: HoanTien.NganHangNhan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'SoTaiKhoanNhan')
BEGIN
    ALTER TABLE dbo.HoanTien ADD SoTaiKhoanNhan NVARCHAR(30) NULL;
    PRINT 'Added: HoanTien.SoTaiKhoanNhan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'ChuTaiKhoanNhan')
BEGIN
    ALTER TABLE dbo.HoanTien ADD ChuTaiKhoanNhan NVARCHAR(100) NULL;
    PRINT 'Added: HoanTien.ChuTaiKhoanNhan';
END
GO

-- Index để Manager lọc nhanh theo trạng thái
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'IX_HoanTien_TrangThai')
BEGIN
    CREATE NONCLUSTERED INDEX IX_HoanTien_TrangThai ON dbo.HoanTien (TrangThai);
    PRINT 'Created index: IX_HoanTien_TrangThai';
END
GO

-- ============================================================
-- 3. DanhGia — unique constraint (DatSanID, AccountID_NguoiDanhGia)
--    để đảm bảo mỗi booking chỉ đánh giá một lần
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.DanhGia')
      AND name = N'UQ_DanhGia_DatSan_Account'
)
BEGIN
    ALTER TABLE dbo.DanhGia
        ADD CONSTRAINT UQ_DanhGia_DatSan_Account
            UNIQUE (DatSanID, AccountID_NguoiDanhGia);
    PRINT 'Added unique constraint: UQ_DanhGia_DatSan_Account';
END
ELSE
BEGIN
    PRINT 'Skip: UQ_DanhGia_DatSan_Account already exists';
END
GO

-- ============================================================
-- 4. ThongBao — unique constraint (AccountID, LoaiThongBao, MaBanGhi)
--    để ngăn duplicate notification khi request được retry đồng thời
--    (application-level dedup hiện tại chỉ SELECT-then-INSERT, không atomic).
-- ============================================================
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE object_id = OBJECT_ID(N'dbo.ThongBao')
      AND name = N'UQ_ThongBao_Account_Loai_MaBanGhi'
)
BEGIN
    ALTER TABLE dbo.ThongBao
        ADD CONSTRAINT UQ_ThongBao_Account_Loai_MaBanGhi
            UNIQUE (AccountID, LoaiThongBao, MaBanGhi);
    PRINT 'Added unique constraint: UQ_ThongBao_Account_Loai_MaBanGhi';
END
ELSE
BEGIN
    PRINT 'Skip: UQ_ThongBao_Account_Loai_MaBanGhi already exists';
END
GO

PRINT '=== Migration migration_notification_marketing_refund_review: DONE ===';
GO
