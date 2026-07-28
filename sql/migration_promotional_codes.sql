-- Migration: Bổ sung bảng LichSuKhuyenMai quản lý giới hạn sử dụng mã khuyến mãi theo tài khoản
USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'LichSuKhuyenMai')
BEGIN
    CREATE TABLE LichSuKhuyenMai (
        HistoryID INT IDENTITY(1,1) PRIMARY KEY,
        KhuyenMaiID INT NOT NULL,
        AccountID INT NOT NULL,
        DatSanID INT NULL,
        DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
        UsedAt DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_LichSuKM_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES KhuyenMai(KhuyenMaiID),
        CONSTRAINT FK_LichSuKM_Account FOREIGN KEY (AccountID) REFERENCES TaiKhoan(AccountID)
    );

    CREATE INDEX IX_LichSuKM_Account_KM ON LichSuKhuyenMai(AccountID, KhuyenMaiID);
    PRINT N'Đã tạo bảng LichSuKhuyenMai và index thành công.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'KhuyenMai') AND name = N'GiaTriToiThieu')
BEGIN
    ALTER TABLE KhuyenMai ADD GiaTriToiThieu DECIMAL(18,2) NULL DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'KhuyenMai') AND name = N'GiamToiDa')
BEGIN
    ALTER TABLE KhuyenMai ADD GiamToiDa DECIMAL(18,2) NULL DEFAULT 0;
END
GO
