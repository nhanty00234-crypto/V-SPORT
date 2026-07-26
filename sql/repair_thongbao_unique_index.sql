-- ============================================================
-- Script Repair Idempotent: Unique Index cho bảng ThongBao
-- Mục đích: Sửa lỗi UNIQUE constraint cũ (chặn sai khi MaBanGhi NULL hoặc IsDeleted = 1)
-- Chuyển sang FILTERED UNIQUE INDEX:
--   - Cho phép nhiều dòng có MaBanGhi IS NULL
--   - Cho phép các event khác nhau của cùng booking (BOOKING_CREATED vs BOOKING_CONFIRMED)
--   - Ngăn tạo trùng cùng (AccountID, LoaiThongBao, MaBanGhi) khi chưa bị xóa mềm (IsDeleted = 0)
-- ============================================================

-- 1. Xóa constraint cũ nếu đã lỡ tạo theo dạng ALTER TABLE ADD CONSTRAINT UQ_ThongBao_Account_Loai_MaBanGhi
IF EXISTS (
    SELECT 1 FROM sys.key_constraints 
    WHERE object_id = OBJECT_ID(N'dbo.UQ_ThongBao_Account_Loai_MaBanGhi') 
      AND parent_object_id = OBJECT_ID(N'dbo.ThongBao')
)
BEGIN
    ALTER TABLE dbo.ThongBao DROP CONSTRAINT UQ_ThongBao_Account_Loai_MaBanGhi;
    PRINT 'Dropped old table constraint: UQ_ThongBao_Account_Loai_MaBanGhi';
END
GO

-- 2. Xóa index cũ nếu tồn tại dưới dạng non-filtered unique index
IF EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.ThongBao') 
      AND name = N'UQ_ThongBao_Account_Loai_MaBanGhi'
)
BEGIN
    DROP INDEX UQ_ThongBao_Account_Loai_MaBanGhi ON dbo.ThongBao;
    PRINT 'Dropped old index: UQ_ThongBao_Account_Loai_MaBanGhi';
END
GO

-- 3. Tạo FILTERED UNIQUE INDEX chuẩn xác
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE object_id = OBJECT_ID(N'dbo.ThongBao') 
      AND name = N'UQ_ThongBao_Account_Loai_MaBanGhi'
)
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UQ_ThongBao_Account_Loai_MaBanGhi
        ON dbo.ThongBao (AccountID, LoaiThongBao, MaBanGhi)
        WHERE MaBanGhi IS NOT NULL AND IsDeleted = 0;
    PRINT 'Created Filtered Unique Index: UQ_ThongBao_Account_Loai_MaBanGhi';
END
ELSE
BEGIN
    PRINT 'Skip: UQ_ThongBao_Account_Loai_MaBanGhi filtered index already exists';
END
GO

PRINT '=== Migration repair_thongbao_unique_index: COMPLETED ===';
GO
