-- Migration: Tạo bảng LichDatSan_DichVu (Phase 8A - dịch vụ khách đặt trước khi đặt sân)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Bảng này TÁCH BIỆT hoàn toàn khỏi HoaDon/ChiTietHoaDon: chỉ ghi nhận "khách đặt trước
-- những gì", không đụng vào tồn kho (SanPham_DichVu.SoLuongTon) và không đụng vào
-- kế toán/hóa đơn. Dịch vụ được thanh toán tại quầy, không qua PayOS.
-- Áp dụng cho: V-SPORT QuanLiSport_V4 trở lên

USE QuanLiSport;
GO

IF OBJECT_ID(N'LichDatSan_DichVu', N'U') IS NULL
BEGIN
    CREATE TABLE LichDatSan_DichVu (
        Id            INT IDENTITY(1,1) PRIMARY KEY,
        DatSanID      INT NOT NULL,
        SanPhamID     INT NOT NULL,
        Quantity      INT NOT NULL,
        UnitPrice     DECIMAL(18,2) NOT NULL,
        TotalPrice    DECIMAL(18,2) NOT NULL,
        Status        NVARCHAR(50) NOT NULL DEFAULT N'Chờ chuẩn bị',
        Note          NVARCHAR(255) NULL,
        CreatedAt     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        DeliveredAt   DATETIME2 NULL,
        DeliveredBy   INT NULL,
        CONSTRAINT FK_LDSDV_DatSan
            FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
        CONSTRAINT FK_LDSDV_SanPham
            FOREIGN KEY (SanPhamID) REFERENCES SanPham_DichVu(SanPhamID),
        CONSTRAINT FK_LDSDV_DeliveredBy
            FOREIGN KEY (DeliveredBy) REFERENCES Accounts(AccountID),
        CONSTRAINT CK_LDSDV_Quantity CHECK (Quantity > 0),
        CONSTRAINT CK_LDSDV_Status CHECK (Status IN (N'Chờ chuẩn bị', N'Đã giao', N'Đã hủy'))
    );
    PRINT N'Đã tạo bảng LichDatSan_DichVu.';
END
ELSE
    PRINT N'Bảng LichDatSan_DichVu đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_LDSDV_DatSanID' AND object_id = OBJECT_ID(N'LichDatSan_DichVu')
)
BEGIN
    CREATE INDEX IX_LDSDV_DatSanID ON LichDatSan_DichVu (DatSanID);
    PRINT N'Đã tạo index IX_LDSDV_DatSanID.';
END
GO

PRINT N'Migration booking-service-preorder hoàn tất.';
GO
