-- Migration: Bổ sung các cột phục vụ tách/chia hóa đơn (Service Bill Separation)
USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'LoaiHoaDon')
BEGIN
    ALTER TABLE HoaDon ADD LoaiHoaDon VARCHAR(20) DEFAULT 'MAIN' WITH VALUES;
    PRINT N'Đã thêm cột LoaiHoaDon vào bảng HoaDon.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'ParentHoaDonID')
BEGIN
    ALTER TABLE HoaDon ADD ParentHoaDonID INT NULL CONSTRAINT FK_HoaDon_Parent FOREIGN KEY REFERENCES HoaDon(HoaDonID);
    PRINT N'Đã thêm cột ParentHoaDonID vào bảng HoaDon.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'GhiChu')
BEGIN
    ALTER TABLE HoaDon ADD GhiChu NVARCHAR(255) NULL;
    PRINT N'Đã thêm cột GhiChu vào bảng HoaDon.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_HoaDon_Parent_Loai' AND object_id = OBJECT_ID(N'HoaDon'))
BEGIN
    CREATE INDEX IX_HoaDon_Parent_Loai ON HoaDon(ParentHoaDonID, LoaiHoaDon);
    PRINT N'Đã tạo index IX_HoaDon_Parent_Loai.';
END
GO
