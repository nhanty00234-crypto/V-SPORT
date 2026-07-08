-- Migration: Thêm cột LoaiHoaDon, ParentHoaDonID, GhiChu vào bảng HoaDon
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Áp dụng cho: V-SPORT QuanLiSport_V4 trở lên

USE QuanLiSport;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'LoaiHoaDon'
)
BEGIN
    ALTER TABLE HoaDon
    ADD LoaiHoaDon NVARCHAR(50) NULL CONSTRAINT DF_HoaDon_LoaiHoaDon DEFAULT N'MAIN';
    PRINT N'Đã thêm cột LoaiHoaDon vào HoaDon.';
END
ELSE
    PRINT N'Cột LoaiHoaDon đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'ParentHoaDonID'
)
BEGIN
    ALTER TABLE HoaDon
    ADD ParentHoaDonID INT NULL;
    PRINT N'Đã thêm cột ParentHoaDonID vào HoaDon.';
END
ELSE
    PRINT N'Cột ParentHoaDonID đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'GhiChu'
)
BEGIN
    ALTER TABLE HoaDon
    ADD GhiChu NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột GhiChu vào HoaDon.';
END
ELSE
    PRINT N'Cột GhiChu đã tồn tại, bỏ qua.';
GO

-- FK ParentHoaDonID → HoaDon.HoaDonID (chỉ thêm nếu chưa có)
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys
    WHERE name = N'FK_HoaDon_Parent' AND parent_object_id = OBJECT_ID(N'HoaDon')
)
BEGIN
    ALTER TABLE HoaDon
    ADD CONSTRAINT FK_HoaDon_Parent
        FOREIGN KEY (ParentHoaDonID) REFERENCES HoaDon(HoaDonID);
    PRINT N'Đã thêm FK ParentHoaDonID.';
END
GO

-- Backfill: Tất cả hóa đơn hiện có (không có LoaiHoaDon) đều là hóa đơn sân chính (MAIN)
UPDATE HoaDon
SET LoaiHoaDon = N'MAIN'
WHERE LoaiHoaDon IS NULL;
PRINT N'Backfill LoaiHoaDon = MAIN cho ' + CAST(@@ROWCOUNT AS NVARCHAR) + N' hàng.';
GO
