-- Migration: Bổ sung bảng HoanTien quản lý quy trình hoàn tiền (Refund Workflows)
USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'HoanTien')
BEGIN
    CREATE TABLE HoanTien (
        HoanTienID INT IDENTITY(1,1) PRIMARY KEY,
        HoaDonID INT NULL,
        DatSanID INT NULL,
        AccountID INT NOT NULL,
        SoTienHoan DECIMAL(18,2) NOT NULL,
        LyDo NVARCHAR(255) NULL,
        TrangThai NVARCHAR(50) NOT NULL DEFAULT N'CHO_XU_LY', -- CHO_XU_LY, DA_DUYET, TU_CHUOI
        NguoiDuyetID INT NULL,
        ThoiGianYeuCau DATETIME NOT NULL DEFAULT GETDATE(),
        ThoiGianHoan DATETIME NULL,
        GhiChu NVARCHAR(255) NULL,
        CONSTRAINT FK_HoanTien_Account FOREIGN KEY (AccountID) REFERENCES TaiKhoan(AccountID)
    );

    PRINT N'Đã tạo bảng HoanTien thành công.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoanTien') AND name = N'DatSanID')
BEGIN
    ALTER TABLE HoanTien ADD DatSanID INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoanTien') AND name = N'NguoiDuyetID')
BEGIN
    ALTER TABLE HoanTien ADD NguoiDuyetID INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'HoanTien') AND name = N'GhiChu')
BEGIN
    ALTER TABLE HoanTien ADD GhiChu NVARCHAR(255) NULL;
END
GO
