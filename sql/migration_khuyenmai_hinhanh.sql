-- Migration: Bổ sung quản lý hình ảnh cho mã khuyến mãi (KhuyenMai)
-- - Bảng dbo.KhuyenMaiHinhAnh: tối đa 5 ảnh/chương trình, không lưu binary (chỉ lưu DuongDan tương đối).
-- - Cột dbo.KhuyenMai.HienThiCongKhai: cờ cho phép Customer nhìn thấy khuyến mãi này (độc lập với
--   TrangThai "Hoạt động"/"Tạm dừng" vốn chỉ điều khiển việc mã có áp dụng được hay không).
-- Idempotent: chạy lại nhiều lần không lỗi, không mất dữ liệu.
USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'KhuyenMaiHinhAnh')
BEGIN
    CREATE TABLE dbo.KhuyenMaiHinhAnh (
        HinhAnhID     INT IDENTITY(1,1) PRIMARY KEY,
        KhuyenMaiID   INT NOT NULL,
        DuongDan      NVARCHAR(500) NOT NULL,
        TenFileGoc    NVARCHAR(255) NULL,
        MimeType      NVARCHAR(100) NULL,
        DungLuong     BIGINT NULL,
        ChieuRong     INT NULL,
        ChieuCao      INT NULL,
        ThuTu         INT NOT NULL DEFAULT 0,
        LaAnhBia      BIT NOT NULL DEFAULT 0,
        CreatedAt     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        UpdatedAt     DATETIME2 NULL,
        CONSTRAINT FK_KhuyenMaiHinhAnh_KhuyenMai FOREIGN KEY (KhuyenMaiID)
            REFERENCES dbo.KhuyenMai(KhuyenMaiID)
    );

    CREATE INDEX IX_KhuyenMaiHinhAnh_KhuyenMaiID ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID);
    CREATE INDEX IX_KhuyenMaiHinhAnh_KhuyenMaiID_ThuTu ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID, ThuTu);

    -- SQL Server hỗ trợ unique filtered index để đảm bảo mỗi KhuyenMaiID chỉ có tối đa
    -- một ảnh bìa (LaAnhBia=1) ngay ở tầng DB, thay vì chỉ dựa vào transaction ở Service.
    CREATE UNIQUE INDEX UQ_KhuyenMaiHinhAnh_MotAnhBia
        ON dbo.KhuyenMaiHinhAnh (KhuyenMaiID)
        WHERE LaAnhBia = 1;

    PRINT N'Đã tạo bảng KhuyenMaiHinhAnh và các index thành công.';
END
ELSE
    PRINT N'Bảng KhuyenMaiHinhAnh đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.KhuyenMai') AND name = N'HienThiCongKhai'
)
BEGIN
    ALTER TABLE dbo.KhuyenMai ADD HienThiCongKhai BIT NOT NULL CONSTRAINT DF_KhuyenMai_HienThiCongKhai DEFAULT 1;
    PRINT N'Đã thêm cột HienThiCongKhai vào KhuyenMai (mặc định 1 - công khai).';
END
ELSE
    PRINT N'Cột HienThiCongKhai đã tồn tại, bỏ qua.';
GO

-- Rollback (chạy thủ công nếu cần):
-- DROP INDEX UQ_KhuyenMaiHinhAnh_MotAnhBia ON dbo.KhuyenMaiHinhAnh;
-- DROP TABLE dbo.KhuyenMaiHinhAnh;
-- ALTER TABLE dbo.KhuyenMai DROP CONSTRAINT DF_KhuyenMai_HienThiCongKhai;
-- ALTER TABLE dbo.KhuyenMai DROP COLUMN HienThiCongKhai;
