-- ============================================================
-- Migration: Chia tiền nhóm (Group Bill Split) — bảng hoàn toàn mới.
-- Đối chiếu trước khi tạo: model org.example.model.ChiaHoaDon là
-- DEAD CODE (không @Entity, không DAO, không migration nào từng
-- tạo bảng ChiaHoaDon thật) — KHÔNG tái sử dụng, đặt tên khác để
-- tránh nhầm lẫn với khái niệm cũ chưa từng triển khai.
-- KHÔNG liên quan/không đụng tới "Tách hóa đơn dịch vụ" phía Staff
-- (HoaDon.LoaiHoaDon='SPLIT', ParentHoaDonID — xem
-- migration_service_bill_separation.sql) — đó là nghiệp vụ khác,
-- giữ nguyên không đổi.
-- Idempotent: chạy nhiều lần không lỗi.
-- ============================================================

-- ------------------------------------------------------------
-- 1. NhomChiaTien (tương đương "BillSplit" trong spec)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'NhomChiaTien')
BEGIN
    CREATE TABLE dbo.NhomChiaTien (
        NhomChiaTienID      INT IDENTITY(1,1) PRIMARY KEY,
        HoaDonID            INT NOT NULL,
        DatSanID            INT NOT NULL,
        CreatedByAccountID  INT NOT NULL,
        SplitType           NVARCHAR(20) NOT NULL,   -- EQUAL | CUSTOM | ITEMIZED (ITEMIZED chưa triển khai)
        TongTien             DECIMAL(18,2) NOT NULL,
        TrangThai            NVARCHAR(20) NOT NULL DEFAULT N'DRAFT', -- DRAFT|ACTIVE|PARTIALLY_PAID|PAID|CANCELLED|EXPIRED
        ExpiresAt            DATETIME NULL,
        CreatedAt            DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt            DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_NhomChiaTien_HoaDon FOREIGN KEY (HoaDonID) REFERENCES dbo.HoaDon(HoaDonID),
        CONSTRAINT FK_NhomChiaTien_DatSan FOREIGN KEY (DatSanID) REFERENCES dbo.LichDatSan(DatSanID),
        CONSTRAINT FK_NhomChiaTien_Creator FOREIGN KEY (CreatedByAccountID) REFERENCES dbo.Accounts(AccountID),
        CONSTRAINT CK_NhomChiaTien_SplitType CHECK (SplitType IN (N'EQUAL', N'CUSTOM', N'ITEMIZED')),
        CONSTRAINT CK_NhomChiaTien_TrangThai CHECK (TrangThai IN (N'DRAFT', N'ACTIVE', N'PARTIALLY_PAID', N'PAID', N'CANCELLED', N'EXPIRED'))
    );
    PRINT 'Created table: NhomChiaTien';
END
GO

-- Mỗi HoaDon chỉ có một NhomChiaTien đang hoạt động (ACTIVE/PARTIALLY_PAID) tại một thời điểm.
-- Filtered unique index — cho phép nhiều bản ghi DRAFT/CANCELLED/EXPIRED/PAID cũ tồn tại song song.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.NhomChiaTien') AND name = N'UX_NhomChiaTien_HoaDon_Active')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_NhomChiaTien_HoaDon_Active
        ON dbo.NhomChiaTien (HoaDonID)
        WHERE TrangThai IN (N'ACTIVE', N'PARTIALLY_PAID');
    PRINT 'Created index: UX_NhomChiaTien_HoaDon_Active';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.NhomChiaTien') AND name = N'IX_NhomChiaTien_DatSan')
BEGIN
    CREATE NONCLUSTERED INDEX IX_NhomChiaTien_DatSan ON dbo.NhomChiaTien (DatSanID);
    PRINT 'Created index: IX_NhomChiaTien_DatSan';
END
GO

-- ------------------------------------------------------------
-- 2. NhomChiaTienChiTiet (tương đương "BillSplitShare" trong spec)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'NhomChiaTienChiTiet')
BEGIN
    CREATE TABLE dbo.NhomChiaTienChiTiet (
        ChiTietID              INT IDENTITY(1,1) PRIMARY KEY,
        NhomChiaTienID         INT NOT NULL,
        AccountID              INT NULL,             -- NULL nếu participant chưa/không có tài khoản V-SPORT
        DisplayName            NVARCHAR(100) NOT NULL,
        ShareToken             CHAR(43) NOT NULL,     -- base64url(32 random bytes) — không log đầy đủ, xem RefundSecurity util
        SoTien                 DECIMAL(18,2) NOT NULL,
        TrangThai              NVARCHAR(20) NOT NULL DEFAULT N'PENDING', -- PENDING|PROCESSING|PAID|CANCELLED|EXPIRED
        PaymentMethod          NVARCHAR(30) NULL,      -- PayOS|TAI_SAN (Constants.PT_*)
        PaymentTransactionID   NVARCHAR(100) NULL,      -- orderCode PayOS hoặc mã xác nhận Staff
        PayerAccountID         INT NULL,               -- người thực trả (có thể khác AccountID nếu ai đó trả hộ)
        PaidAt                 DATETIME NULL,
        ConfirmedByStaffID     INT NULL,               -- Staff xác nhận khi thanh toán tại sân
        CreatedAt              DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedAt              DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_NhomChiaTienChiTiet_Nhom FOREIGN KEY (NhomChiaTienID) REFERENCES dbo.NhomChiaTien(NhomChiaTienID),
        CONSTRAINT FK_NhomChiaTienChiTiet_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
        CONSTRAINT FK_NhomChiaTienChiTiet_Payer FOREIGN KEY (PayerAccountID) REFERENCES dbo.Accounts(AccountID),
        CONSTRAINT FK_NhomChiaTienChiTiet_Staff FOREIGN KEY (ConfirmedByStaffID) REFERENCES dbo.Accounts(AccountID),
        CONSTRAINT CK_NhomChiaTienChiTiet_TrangThai CHECK (TrangThai IN (N'PENDING', N'PROCESSING', N'PAID', N'CANCELLED', N'EXPIRED')),
        CONSTRAINT CK_NhomChiaTienChiTiet_SoTien CHECK (SoTien > 0)
    );
    PRINT 'Created table: NhomChiaTienChiTiet';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.NhomChiaTienChiTiet') AND name = N'UX_NhomChiaTienChiTiet_ShareToken')
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX UX_NhomChiaTienChiTiet_ShareToken ON dbo.NhomChiaTienChiTiet (ShareToken);
    PRINT 'Created index: UX_NhomChiaTienChiTiet_ShareToken';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.NhomChiaTienChiTiet') AND name = N'IX_NhomChiaTienChiTiet_Nhom')
BEGIN
    CREATE NONCLUSTERED INDEX IX_NhomChiaTienChiTiet_Nhom ON dbo.NhomChiaTienChiTiet (NhomChiaTienID);
    PRINT 'Created index: IX_NhomChiaTienChiTiet_Nhom';
END
GO

PRINT '=== Migration migration_group_bill_split: DONE ===';
GO
