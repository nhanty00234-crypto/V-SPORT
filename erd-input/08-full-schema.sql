-- ============================================================
-- 08-full-schema.sql
-- V-SPORT / QuanLiSport Database -- Complete DDL
-- Extracted from: Tài nguyên/QuanLiSport_V4.sql + 35+ migration files
-- Source files scanned: sql/*.sql, Tài nguyên/*.sql
-- Data source: Source code only (no live DB connection)
-- IMPORTANT: Does NOT include INSERT data, passwords, API keys,
--            PayOS keys, customer data, or connection strings.
-- ============================================================
-- Generation date: 2026-08-02
-- Database: QuanLiSport (Microsoft SQL Server)
-- Schema: dbo
-- ============================================================

USE QuanLiSport;
GO

-- ============================================================
-- SECTION 1: BASE SCHEMA (from QuanLiSport_V4.sql)
-- ============================================================

-- 1. Roles
IF OBJECT_ID('dbo.Roles', 'U') IS NULL
CREATE TABLE dbo.Roles (
    RoleID   INT           IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50)  NOT NULL
);
GO

-- 2. CoSo (Facility/Venue) - created before Accounts due to circular FK
IF OBJECT_ID('dbo.CoSo', 'U') IS NULL
CREATE TABLE dbo.CoSo (
    CoSoID                INT           IDENTITY(1,1) PRIMARY KEY,
    TenCoSo               NVARCHAR(255) NULL,
    DiaChi                NVARCHAR(500) NULL,
    SoDienThoai           NVARCHAR(20)  NULL,
    TrangThai             NVARCHAR(50)  NULL,
    GioMoCua              TIME          NULL,
    GioDongCua            TIME          NULL,
    HinhAnh               NVARCHAR(500) NULL,
    MoTa                  NVARCHAR(MAX) NULL,
    LoaiHinhKinhDoanh     NVARCHAR(100) NULL,
    SoLuongSanDuKien      INT           NULL,
    AccountID_QuanLy      INT           NULL
    -- FK to Accounts added below after Accounts table is created
);
GO

-- 3. Accounts (all roles: admin, manager, staff, customer)
IF OBJECT_ID('dbo.Accounts', 'U') IS NULL
CREATE TABLE dbo.Accounts (
    AccountID       INT           IDENTITY(1,1) PRIMARY KEY,
    Username        VARCHAR(50)   NULL UNIQUE,
    Password        VARCHAR(MAX)  NOT NULL,
    FailedLoginCount TINYINT      NULL,
    IsLocked        BIT           NULL,
    LastLogin       DATETIME      NULL,
    GoogleID        VARCHAR(100)  NULL UNIQUE,
    FacebookID      VARCHAR(100)  NULL UNIQUE,
    FullName        NVARCHAR(255) NULL,
    PhoneNumber     NVARCHAR(20)  NULL,
    Email           VARCHAR(100)  NULL UNIQUE,
    RoleID          INT           NULL,
    CoSoID          INT           NULL,
    ZaloID          NVARCHAR(100) NULL,
    MessengerID     NVARCHAR(100) NULL,
    DiemUyTin       INT           DEFAULT 100,
    DiemTrinhDo     INT           DEFAULT 1000,
    MaNganHang      NVARCHAR(50)  NULL,
    SoTaiKhoan      NVARCHAR(50)  NULL,
    ViTriSoTruong   NVARCHAR(100) NULL,
    NhanThongBaoSOS BIT           DEFAULT 1,
    NgaySinh        DATE          NULL,
    GioiTinh        NVARCHAR(10)  NULL,
    CreatedAt       DATETIME      NULL,
    CONSTRAINT FK_Accounts_Roles FOREIGN KEY (RoleID)  REFERENCES dbo.Roles(RoleID),
    CONSTRAINT FK_Accounts_CoSo  FOREIGN KEY (CoSoID)  REFERENCES dbo.CoSo(CoSoID)
);
GO

-- Add circular FK: CoSo.AccountID_QuanLy -> Accounts
IF OBJECT_ID('dbo.FK_CoSo_AccountQuanLy', 'F') IS NULL
    ALTER TABLE dbo.CoSo
        ADD CONSTRAINT FK_CoSo_AccountQuanLy
        FOREIGN KEY (AccountID_QuanLy) REFERENCES dbo.Accounts(AccountID);
GO

-- 4. MonTheThao (Sport types)
IF OBJECT_ID('dbo.MonTheThao', 'U') IS NULL
CREATE TABLE dbo.MonTheThao (
    MonTheThaoID INT          IDENTITY(1,1) PRIMARY KEY,
    TenMon       NVARCHAR(50) NOT NULL
);
GO

-- 5. MonTheThaoYeuThich (Favorite sports - N-N join table)
IF OBJECT_ID('dbo.MonTheThaoYeuThich', 'U') IS NULL
CREATE TABLE dbo.MonTheThaoYeuThich (
    AccountID    INT      NOT NULL,
    MonTheThaoID INT      NOT NULL,
    NgayThem     DATETIME NULL,
    CONSTRAINT PK_MonTheThaoYeuThich PRIMARY KEY (AccountID, MonTheThaoID),
    CONSTRAINT FK_MonTheThaoYeuThich_Account     FOREIGN KEY (AccountID)    REFERENCES dbo.Accounts(AccountID)    ON DELETE CASCADE,
    CONSTRAINT FK_MonTheThaoYeuThich_MonTheThao  FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID) ON DELETE CASCADE
);
GO

-- 6. LoaiSan (Court type - by sport and pricing)
IF OBJECT_ID('dbo.LoaiSan', 'U') IS NULL
CREATE TABLE dbo.LoaiSan (
    LoaiSanID         INT           IDENTITY(1,1) PRIMARY KEY,
    MonTheThaoID      INT           NULL,
    TenLoai           NVARCHAR(100) NULL,
    GiaKhongDen       DECIMAL(18,2) NULL,
    GiaCoDen          DECIMAL(18,2) NULL,
    GioBatDauLenDen   TIME          DEFAULT '17:30:00',
    CONSTRAINT FK_LoaiSan_MonTheThao FOREIGN KEY (MonTheThaoID) REFERENCES dbo.MonTheThao(MonTheThaoID)
);
GO

-- 7. San (Individual courts)
IF OBJECT_ID('dbo.San', 'U') IS NULL
CREATE TABLE dbo.San (
    SanID     INT           IDENTITY(1,1) PRIMARY KEY,
    TenSan    NVARCHAR(100) NULL,
    LoaiSanID INT           NULL,
    CoSoID    INT           NOT NULL,
    TrangThai NVARCHAR(50)  DEFAULT N'Sẵn sàng',
    MoTa      NVARCHAR(MAX) NULL,
    HinhAnh   NVARCHAR(500) NULL,
    CONSTRAINT FK_San_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES dbo.LoaiSan(LoaiSanID),
    CONSTRAINT FK_San_CoSo    FOREIGN KEY (CoSoID)    REFERENCES dbo.CoSo(CoSoID)
);
GO

-- 8. DanhMucSanPham (Product categories)
IF OBJECT_ID('dbo.DanhMucSanPham', 'U') IS NULL
CREATE TABLE dbo.DanhMucSanPham (
    DanhMucID   INT           IDENTITY(1,1) PRIMARY KEY,
    TenDanhMuc  NVARCHAR(100) NOT NULL
);
GO

-- 9. SanPham_DichVu (Products and services sold at facilities)
IF OBJECT_ID('dbo.SanPham_DichVu', 'U') IS NULL
CREATE TABLE dbo.SanPham_DichVu (
    SanPhamID   INT           IDENTITY(1,1) PRIMARY KEY,
    DanhMucID   INT           NULL,
    CoSoID      INT           NULL,
    TenSanPham  NVARCHAR(200) NULL,
    DonGia      DECIMAL(18,2) NULL,
    DonViTinh   NVARCHAR(50)  NULL,
    SoLuongTon  INT           DEFAULT 0,
    TrangThai   NVARCHAR(50)  NULL,
    CONSTRAINT FK_SanPham_DichVu_DanhMuc FOREIGN KEY (DanhMucID) REFERENCES dbo.DanhMucSanPham(DanhMucID),
    CONSTRAINT FK_SanPham_DichVu_CoSo    FOREIGN KEY (CoSoID)    REFERENCES dbo.CoSo(CoSoID)
);
GO

-- 10. LichDatSan (Booking records - central table)
IF OBJECT_ID('dbo.LichDatSan', 'U') IS NULL
CREATE TABLE dbo.LichDatSan (
    DatSanID         INT           IDENTITY(1,1) PRIMARY KEY,
    AccountID        INT           NULL,
    SanID            INT           NULL,
    NgayDat          DATE          NULL,
    GioBatDau        TIME          NULL,
    GioKetThuc       TIME          NULL,
    ApDungGiaCoDen   BIT           DEFAULT 0,
    TongTienDuKien   DECIMAL(18,2) NULL,
    TrangThai        NVARCHAR(50)  DEFAULT N'Chờ xác nhận',
    GhiChu           NVARCHAR(500) NULL,
    NguonDatSan      NVARCHAR(50)  NULL,
    CONSTRAINT FK_LichDatSan_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_LichDatSan_San     FOREIGN KEY (SanID)     REFERENCES dbo.San(SanID)
);
GO

-- 11. GhepKeo (Match-making requests)
IF OBJECT_ID('dbo.GhepKeo', 'U') IS NULL
CREATE TABLE dbo.GhepKeo (
    KeoID              INT           IDENTITY(1,1) PRIMARY KEY,
    DatSanID           INT           NULL,
    AccountID_NguoiTao INT           NULL,
    MonTheThaoID       INT           NULL,
    MoTa               NVARCHAR(MAX) NULL,
    TrinhDo            NVARCHAR(50)  NULL,
    TrangThai          NVARCHAR(50)  DEFAULT N'Đang tìm',
    CONSTRAINT FK_GhepKeo_LichDatSan    FOREIGN KEY (DatSanID)           REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_GhepKeo_AccountNguoiTao FOREIGN KEY (AccountID_NguoiTao) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_GhepKeo_MonTheThao    FOREIGN KEY (MonTheThaoID)        REFERENCES dbo.MonTheThao(MonTheThaoID)
);
GO

-- 12. ChiTietGhepKeo (Match participants)
IF OBJECT_ID('dbo.ChiTietGhepKeo', 'U') IS NULL
CREATE TABLE dbo.ChiTietGhepKeo (
    ChiTietKeoID          INT           IDENTITY(1,1) PRIMARY KEY,
    KeoID                 INT           NULL,
    AccountID_NguoiThamGia INT          NULL,
    TrangThaiThamGia      NVARCHAR(50)  DEFAULT N'Chờ duyệt',
    ViTriThamGia          NVARCHAR(100) NULL,
    CONSTRAINT FK_ChiTietGhepKeo_GhepKeo  FOREIGN KEY (KeoID)                  REFERENCES dbo.GhepKeo(KeoID),
    CONSTRAINT FK_ChiTietGhepKeo_Account  FOREIGN KEY (AccountID_NguoiThamGia) REFERENCES dbo.Accounts(AccountID)
);
GO

-- 13. DanhGia (Reviews after booking)
IF OBJECT_ID('dbo.DanhGia', 'U') IS NULL
CREATE TABLE dbo.DanhGia (
    DanhGiaID                INT           IDENTITY(1,1) PRIMARY KEY,
    DatSanID                 INT           NULL,
    AccountID_NguoiDanhGia   INT           NULL,
    AccountID_NguoiBiDanhGia INT           NULL,
    SoSao                    INT           NULL,
    BinhLuan                 NVARCHAR(MAX) NULL,
    NgayDanhGia              DATETIME      NULL,
    CONSTRAINT FK_DanhGia_LichDatSan              FOREIGN KEY (DatSanID)                 REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_DanhGia_AccountNguoiDanhGia     FOREIGN KEY (AccountID_NguoiDanhGia)   REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_DanhGia_AccountNguoiBiDanhGia   FOREIGN KEY (AccountID_NguoiBiDanhGia) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_DanhGia_SoSao CHECK ([SoSao] >= 1 AND [SoSao] <= 5)
);
GO

-- 14. LichSuELO (ELO / skill score history)
IF OBJECT_ID('dbo.LichSuELO', 'U') IS NULL
CREATE TABLE dbo.LichSuELO (
    LichSuELOID INT           IDENTITY(1,1) PRIMARY KEY,
    AccountID   INT           NULL,
    DatSanID    INT           NULL,
    DiemTruoc   INT           NULL,
    DiemSau     INT           NULL,
    ThayDoi     INT           NULL,
    LyDo        NVARCHAR(255) NULL,
    ThoiGian    DATETIME      NULL,
    CONSTRAINT FK_LichSuELO_Account    FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_LichSuELO_LichDatSan FOREIGN KEY (DatSanID)  REFERENCES dbo.LichDatSan(DatSanID)
);
GO

-- 15. NhatKyChat (Chatbot conversation log)
IF OBJECT_ID('dbo.NhatKyChat', 'U') IS NULL
CREATE TABLE dbo.NhatKyChat (
    NhatKyChatID INT           IDENTITY(1,1) PRIMARY KEY,
    AccountID    INT           NULL,
    Kenh         NVARCHAR(50)  NULL,
    TurnSo       INT           NULL,
    VaiTro       NVARCHAR(20)  NULL,
    NoiDung      NVARCHAR(MAX) NULL,
    TrangThaiBot NVARCHAR(50)  NULL,
    ThoiGian     DATETIME      NULL,
    CONSTRAINT FK_NhatKyChat_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID)
);
GO

-- 16. TheGiuXe (Parking spaces)
IF OBJECT_ID('dbo.TheGiuXe', 'U') IS NULL
CREATE TABLE dbo.TheGiuXe (
    TheID          INT           IDENTITY(1,1) PRIMARY KEY,
    CoSoID         INT           NULL,
    MaSoThe        VARCHAR(20)   NULL,
    LoaiXe         NVARCHAR(50)  NULL,
    TrangThai      NVARCHAR(50)  DEFAULT N'Trống',
    SucChua        INT           NULL,
    GiaVeTheoLuot  DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT FK_TheGiuXe_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID)
);
GO

-- 17. LichXeRaVao (Vehicle entry/exit log)
IF OBJECT_ID('dbo.LichXeRaVao', 'U') IS NULL
CREATE TABLE dbo.LichXeRaVao (
    LichXeID           INT           IDENTITY(1,1) PRIMARY KEY,
    TheID              INT           NULL,
    DatSanID           INT           NULL,
    BienSoXe           NVARCHAR(20)  NULL,
    KieuGuiXe          NVARCHAR(50)  NULL,
    GioVao             DATETIME      NULL,
    GioRa              DATETIME      NULL,
    PhiGuiXe           DECIMAL(18,2) DEFAULT 0,
    AccountID_NhanVien INT           NULL,
    CONSTRAINT FK_LichXeRaVao_TheGiuXe  FOREIGN KEY (TheID)              REFERENCES dbo.TheGiuXe(TheID),
    CONSTRAINT FK_LichXeRaVao_LichDatSan FOREIGN KEY (DatSanID)           REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_LichXeRaVao_NhanVien  FOREIGN KEY (AccountID_NhanVien) REFERENCES dbo.Accounts(AccountID)
);
GO

-- 18. KhuyenMai (Promotions and discount codes)
IF OBJECT_ID('dbo.KhuyenMai', 'U') IS NULL
CREATE TABLE dbo.KhuyenMai (
    KhuyenMaiID INT           IDENTITY(1,1) PRIMARY KEY,
    MaCode      VARCHAR(50)   NULL UNIQUE,
    MoTa        NVARCHAR(MAX) NULL,
    LoaiGiam    NVARCHAR(50)  NULL,
    GiaTriGiam  DECIMAL(18,2) NULL,
    NgayBatDau  DATE          NULL,
    NgayKetThuc DATE          NULL,
    SoLanToiDa  INT           NULL,
    SoLanDaDung INT           DEFAULT 0,
    CoSoID      INT           NULL,
    TrangThai   NVARCHAR(50)  DEFAULT N'Hoạt động',
    CONSTRAINT FK_KhuyenMai_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID)
);
GO

-- 19. HoaDon (Invoices / bills)
IF OBJECT_ID('dbo.HoaDon', 'U') IS NULL
CREATE TABLE dbo.HoaDon (
    HoaDonID              INT           IDENTITY(1,1) PRIMARY KEY,
    DatSanID              INT           NULL,
    AccountID_KhachHang   INT           NULL,
    AccountID_NhanVien    INT           NULL,
    NgayLap               DATETIME      NULL,
    TongTienSan           DECIMAL(18,2) NULL,
    TongTienDichVu        DECIMAL(18,2) NULL,
    PhiGuiXe              DECIMAL(18,2) NULL,
    KhuyenMaiID           INT           NULL,
    GiamGia               DECIMAL(18,2) NULL,
    TongThanhToan         DECIMAL(18,2) NULL,
    PhuongThucThanhToan   NVARCHAR(50)  NULL,
    TrangThaiThanhToan    NVARCHAR(50)  NULL,
    CONSTRAINT FK_HoaDon_LichDatSan       FOREIGN KEY (DatSanID)            REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_HoaDon_AccountKhachHang FOREIGN KEY (AccountID_KhachHang) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_HoaDon_AccountNhanVien  FOREIGN KEY (AccountID_NhanVien)  REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_HoaDon_KhuyenMai        FOREIGN KEY (KhuyenMaiID)         REFERENCES dbo.KhuyenMai(KhuyenMaiID)
);
GO

-- 20. ChiTietHoaDon (Invoice line items)
IF OBJECT_ID('dbo.ChiTietHoaDon', 'U') IS NULL
CREATE TABLE dbo.ChiTietHoaDon (
    ChiTietID              INT           IDENTITY(1,1) PRIMARY KEY,
    HoaDonID               INT           NULL,
    SanPhamID              INT           NULL,
    SoLuong                INT           NULL,
    DonGiaTaiThoiDiemBan   DECIMAL(18,2) NULL,
    ThanhTien              DECIMAL(18,2) NULL,
    CONSTRAINT FK_ChiTietHoaDon_HoaDon  FOREIGN KEY (HoaDonID)  REFERENCES dbo.HoaDon(HoaDonID),
    CONSTRAINT FK_ChiTietHoaDon_SanPham FOREIGN KEY (SanPhamID) REFERENCES dbo.SanPham_DichVu(SanPhamID)
);
GO

-- 21. ChiaHoaDon (Bill splitting per person - DEPRECATED, replaced by NhomChiaTien)
IF OBJECT_ID('dbo.ChiaHoaDon', 'U') IS NULL
CREATE TABLE dbo.ChiaHoaDon (
    ChiaHoaDonID INT           IDENTITY(1,1) PRIMARY KEY,
    HoaDonID     INT           NULL,
    AccountID    INT           NULL,
    SoTienPhanBo DECIMAL(18,2) NULL,
    DaTra        BIT           DEFAULT 0,
    ThoiGianTra  DATETIME      NULL,
    GhiChu       NVARCHAR(500) NULL,
    CONSTRAINT FK_ChiaHoaDon_HoaDon  FOREIGN KEY (HoaDonID)  REFERENCES dbo.HoaDon(HoaDonID),
    CONSTRAINT FK_ChiaHoaDon_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID)
);
GO

-- 22. MaQR (QR codes for ChiaHoaDon payments)
IF OBJECT_ID('dbo.MaQR', 'U') IS NULL
CREATE TABLE dbo.MaQR (
    MaQRID       INT           IDENTITY(1,1) PRIMARY KEY,
    ChiaHoaDonID INT           NULL,
    NoiDungQR    NVARCHAR(MAX) NULL,
    NgayTao      DATETIME      NULL,
    NgayHetHan   DATETIME      NULL,
    DaQuet       BIT           DEFAULT 0,
    CONSTRAINT FK_MaQR_ChiaHoaDon FOREIGN KEY (ChiaHoaDonID) REFERENCES dbo.ChiaHoaDon(ChiaHoaDonID)
);
GO

-- 23. YeuCauSOS (Emergency player recruitment requests)
IF OBJECT_ID('dbo.YeuCauSOS', 'U') IS NULL
CREATE TABLE dbo.YeuCauSOS (
    YeuCauSOSID    INT           IDENTITY(1,1) PRIMARY KEY,
    AccountID_Tao  INT           NULL,
    DatSanID       INT           NULL,
    MonTheThaoID   INT           NULL,
    SoNguoiCanTuyen INT          NULL,
    ViTriCanTuyen  NVARCHAR(100) NULL,
    GhiChu         NVARCHAR(MAX) NULL,
    TrangThai      NVARCHAR(50)  DEFAULT N'Đang tuyển',
    ThoiGianTao    DATETIME      NULL,
    CONSTRAINT FK_YeuCauSOS_AccountTao   FOREIGN KEY (AccountID_Tao) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_YeuCauSOS_LichDatSan   FOREIGN KEY (DatSanID)      REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_YeuCauSOS_MonTheThao   FOREIGN KEY (MonTheThaoID)  REFERENCES dbo.MonTheThao(MonTheThaoID)
);
GO

-- 24. NhatKySOSGui (SOS notification send log)
IF OBJECT_ID('dbo.NhatKySOSGui', 'U') IS NULL
CREATE TABLE dbo.NhatKySOSGui (
    NhatKySOSGuiID   INT           IDENTITY(1,1) PRIMARY KEY,
    YeuCauSOSID      INT           NULL,
    AccountID_NhanGui INT          NULL,
    ThoiGianGui      DATETIME      NULL,
    DaXem            BIT           DEFAULT 0,
    PhanHoi          NVARCHAR(MAX) NULL,
    CONSTRAINT FK_NhatKySOSGui_YeuCauSOS FOREIGN KEY (YeuCauSOSID)       REFERENCES dbo.YeuCauSOS(YeuCauSOSID),
    CONSTRAINT FK_NhatKySOSGui_Account   FOREIGN KEY (AccountID_NhanGui) REFERENCES dbo.Accounts(AccountID)
);
GO

-- 25. ThongBao (System notifications)
IF OBJECT_ID('dbo.ThongBao', 'U') IS NULL
CREATE TABLE dbo.ThongBao (
    ThongBaoID  INT           IDENTITY(1,1) PRIMARY KEY,
    AccountID   INT           NULL,
    TieuDe      NVARCHAR(200) NULL,
    NoiDung     NVARCHAR(MAX) NULL,
    LoaiThongBao NVARCHAR(50) NULL,
    DaDoc       BIT           DEFAULT 0,
    ThoiGianGui DATETIME      NULL,
    CONSTRAINT FK_ThongBao_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID)
);
GO

-- 26. CaLamViec (Staff work shifts)
IF OBJECT_ID('dbo.CaLamViec', 'U') IS NULL
CREATE TABLE dbo.CaLamViec (
    CaLamViecID INT           IDENTITY(1,1) PRIMARY KEY,
    AccountID   INT           NULL,
    CoSoID      INT           NULL,
    NgayLam     DATE          NULL,
    GioBatDau   TIME          NULL,
    GioKetThuc  TIME          NULL,
    GhiChu      NVARCHAR(500) NULL,
    CONSTRAINT FK_CaLamViec_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_CaLamViec_CoSo    FOREIGN KEY (CoSoID)    REFERENCES dbo.CoSo(CoSoID)
);
GO

-- 27. HoanTien (Refund requests)
IF OBJECT_ID('dbo.HoanTien', 'U') IS NULL
CREATE TABLE dbo.HoanTien (
    HoanTienID      INT           IDENTITY(1,1) PRIMARY KEY,
    HoaDonID        INT           NULL,
    AccountID       INT           NULL,
    SoTienHoan      DECIMAL(18,2) NULL,
    LyDo            NVARCHAR(MAX) NULL,
    TrangThai       NVARCHAR(50)  DEFAULT N'Chờ xử lý',
    ThoiGianYeuCau  DATETIME      NULL,
    ThoiGianHoan    DATETIME      NULL,
    CONSTRAINT FK_HoanTien_HoaDon  FOREIGN KEY (HoaDonID)  REFERENCES dbo.HoaDon(HoaDonID),
    CONSTRAINT FK_HoanTien_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID)
);
GO

-- ============================================================
-- SECTION 2: MIGRATION FILES (applied in chronological order)
-- ============================================================

-- sql/create_audit_log.sql
IF OBJECT_ID('dbo.AuditLog', 'U') IS NULL
CREATE TABLE dbo.AuditLog (
    AuditLogID    BIGINT        IDENTITY(1,1) PRIMARY KEY,
    ActorAccountID INT          NULL,
    ActorName     NVARCHAR(255) NULL,
    ActorRole     INT           NULL,
    CoSoID        INT           NULL,
    Action        NVARCHAR(100) NULL,
    EntityType    NVARCHAR(100) NULL,
    EntityID      NVARCHAR(50)  NULL,
    EntityName    NVARCHAR(500) NULL,
    Details       NVARCHAR(MAX) NULL,
    IpAddress     NVARCHAR(50)  NULL,
    CreatedAt     DATETIME2     DEFAULT GETDATE()
);
GO

-- sql/migration_soft_delete.sql
-- Adds IsDeleted/DeletedAt/DeletedBy to: San, LoaiSan, SanPham_DichVu, CaLamViec, ThongBao, LichDatSan, CoSo
-- Adds DeletedAt/DeletedBy to: Accounts (no IsDeleted on Accounts)

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.San') AND name = 'IsDeleted')
    ALTER TABLE dbo.San ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.San') AND name = 'DeletedAt')
    ALTER TABLE dbo.San ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.San') AND name = 'DeletedBy')
    ALTER TABLE dbo.San ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LoaiSan') AND name = 'IsDeleted')
    ALTER TABLE dbo.LoaiSan ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LoaiSan') AND name = 'DeletedAt')
    ALTER TABLE dbo.LoaiSan ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LoaiSan') AND name = 'DeletedBy')
    ALTER TABLE dbo.LoaiSan ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SanPham_DichVu') AND name = 'IsDeleted')
    ALTER TABLE dbo.SanPham_DichVu ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SanPham_DichVu') AND name = 'DeletedAt')
    ALTER TABLE dbo.SanPham_DichVu ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SanPham_DichVu') AND name = 'DeletedBy')
    ALTER TABLE dbo.SanPham_DichVu ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CaLamViec') AND name = 'IsDeleted')
    ALTER TABLE dbo.CaLamViec ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CaLamViec') AND name = 'DeletedAt')
    ALTER TABLE dbo.CaLamViec ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CaLamViec') AND name = 'DeletedBy')
    ALTER TABLE dbo.CaLamViec ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ThongBao') AND name = 'IsDeleted')
    ALTER TABLE dbo.ThongBao ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ThongBao') AND name = 'DeletedAt')
    ALTER TABLE dbo.ThongBao ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ThongBao') AND name = 'DeletedBy')
    ALTER TABLE dbo.ThongBao ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'IsDeleted')
    ALTER TABLE dbo.LichDatSan ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'DeletedAt')
    ALTER TABLE dbo.LichDatSan ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'DeletedBy')
    ALTER TABLE dbo.LichDatSan ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'IsDeleted')
    ALTER TABLE dbo.CoSo ADD IsDeleted BIT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'DeletedAt')
    ALTER TABLE dbo.CoSo ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'DeletedBy')
    ALTER TABLE dbo.CoSo ADD DeletedBy INT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'DeletedAt')
    ALTER TABLE dbo.Accounts ADD DeletedAt DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'DeletedBy')
    ALTER TABLE dbo.Accounts ADD DeletedBy INT NULL;
GO

-- sql/migration_avatar_url.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'AvatarUrl')
    ALTER TABLE dbo.Accounts ADD AvatarUrl NVARCHAR(500) NULL;
GO

-- sql/migration_hoadon_loai.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoaDon') AND name = 'LoaiHoaDon')
    ALTER TABLE dbo.HoaDon ADD LoaiHoaDon NVARCHAR(50) NULL DEFAULT 'MAIN';
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoaDon') AND name = 'ParentHoaDonID')
    ALTER TABLE dbo.HoaDon ADD ParentHoaDonID INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoaDon') AND name = 'GhiChu')
    ALTER TABLE dbo.HoaDon ADD GhiChu NVARCHAR(500) NULL;
IF OBJECT_ID('dbo.FK_HoaDon_Parent', 'F') IS NULL
    ALTER TABLE dbo.HoaDon ADD CONSTRAINT FK_HoaDon_Parent FOREIGN KEY (ParentHoaDonID) REFERENCES dbo.HoaDon(HoaDonID);
GO

-- sql/migration_reservation_hold.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'HoldExpiresAt')
    ALTER TABLE dbo.LichDatSan ADD HoldExpiresAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'DepositAmount')
    ALTER TABLE dbo.LichDatSan ADD DepositAmount DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PaymentMethodConfirmed')
    ALTER TABLE dbo.LichDatSan ADD PaymentMethodConfirmed NVARCHAR(50) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'TransactionCode')
    ALTER TABLE dbo.LichDatSan ADD TransactionCode NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'ConfirmedAt')
    ALTER TABLE dbo.LichDatSan ADD ConfirmedAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'ConfirmedBy')
    ALTER TABLE dbo.LichDatSan ADD ConfirmedBy INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'ConfirmSource')
    ALTER TABLE dbo.LichDatSan ADD ConfirmSource NVARCHAR(20) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'NoShowAt')
    ALTER TABLE dbo.LichDatSan ADD NoShowAt DATETIME2 NULL;
IF OBJECT_ID('dbo.FK_LichDatSan_ConfirmedBy', 'F') IS NULL
    ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_ConfirmedBy FOREIGN KEY (ConfirmedBy) REFERENCES dbo.Accounts(AccountID);
GO

-- sql/migration_booking_service_preorder.sql
IF OBJECT_ID('dbo.LichDatSan_DichVu', 'U') IS NULL
CREATE TABLE dbo.LichDatSan_DichVu (
    Id          INT           IDENTITY(1,1) PRIMARY KEY,
    DatSanID    INT           NOT NULL,
    SanPhamID   INT           NOT NULL,
    Quantity    INT           NOT NULL,
    UnitPrice   DECIMAL(18,2) NOT NULL,
    TotalPrice  DECIMAL(18,2) NOT NULL,
    Status      NVARCHAR(50)  DEFAULT N'Chờ chuẩn bị',
    Note        NVARCHAR(500) NULL,
    CreatedAt   DATETIME2     NULL,
    DeliveredAt DATETIME2     NULL,
    DeliveredBy INT           NULL,
    CONSTRAINT FK_LichDatSan_DichVu_DatSan   FOREIGN KEY (DatSanID)    REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_LichDatSan_DichVu_SanPham  FOREIGN KEY (SanPhamID)   REFERENCES dbo.SanPham_DichVu(SanPhamID),
    CONSTRAINT FK_LichDatSan_DichVu_DeliveredBy FOREIGN KEY (DeliveredBy) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_LDSDV_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_LDSDV_Status   CHECK (Status IN (N'Chờ chuẩn bị', N'Đã giao', N'Đã hủy'))
);
GO

-- sql/migration_admin_trash.sql
IF OBJECT_ID('dbo.AdminTrash', 'U') IS NULL
CREATE TABLE dbo.AdminTrash (
    TrashID     INT           IDENTITY(1,1) PRIMARY KEY,
    EntityType  NVARCHAR(100) NULL,
    EntityID    INT           NULL,
    DisplayName NVARCHAR(255) NULL,
    SourceTable NVARCHAR(100) NULL,
    OldStatus   NVARCHAR(100) NULL,
    DeletedBy   INT           NULL,
    DeletedAt   DATETIME2     NULL,
    Reason      NVARCHAR(500) NULL,
    IsRestored  BIT           DEFAULT 0,
    RestoredBy  INT           NULL,
    RestoredAt  DATETIME2     NULL
);
GO

-- sql/migration_bank_transfer.sql
IF OBJECT_ID('dbo.CoSoNganHang', 'U') IS NULL
CREATE TABLE dbo.CoSoNganHang (
    CoSoID        INT           NOT NULL PRIMARY KEY,
    BankName      NVARCHAR(100) NULL,
    BankShortCode NVARCHAR(20)  NULL,
    AccountName   NVARCHAR(200) NULL,
    AccountNumber NVARCHAR(50)  NULL,
    UpdatedAt     DATETIME2     NULL,
    CONSTRAINT FK_CoSoNganHang_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID)
);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoaDon') AND name = 'PaymentReference')
    ALTER TABLE dbo.HoaDon ADD PaymentReference NVARCHAR(255) NULL;
GO

-- sql/migration_booking_extension.sql
IF OBJECT_ID('dbo.BookingExtension', 'U') IS NULL
CREATE TABLE dbo.BookingExtension (
    ExtensionID              INT           IDENTITY(1,1) PRIMARY KEY,
    DatSanID                 INT           NULL,
    OldGioKetThuc            TIME          NULL,
    NewGioKetThuc            TIME          NULL,
    OldGioKetThucDateTime    DATETIME2     NULL,
    NewGioKetThucDateTime    DATETIME2     NULL,
    AdditionalAmount         DECIMAL(18,2) NULL,
    OperatorAccountID        INT           NULL,
    CreatedAt                DATETIME2     NULL,
    CONSTRAINT FK_BookingExtension_LichDatSan FOREIGN KEY (DatSanID)          REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_BookingExtension_Operator   FOREIGN KEY (OperatorAccountID) REFERENCES dbo.Accounts(AccountID)
);
GO

-- sql/migration_court_checkout.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'ActualStartAt')
    ALTER TABLE dbo.LichDatSan ADD ActualStartAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'ActualEndAt')
    ALTER TABLE dbo.LichDatSan ADD ActualEndAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PricingFinalizedAt')
    ALTER TABLE dbo.LichDatSan ADD PricingFinalizedAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LoaiSan') AND name = 'GioKetThucLenDen')
    ALTER TABLE dbo.LoaiSan ADD GioKetThucLenDen TIME NULL;

IF OBJECT_ID('dbo.CourtChargeSegment', 'U') IS NULL
CREATE TABLE dbo.CourtChargeSegment (
    SegmentID       INT           IDENTITY(1,1) PRIMARY KEY,
    HoaDonID        INT           NULL,
    DatSanID        INT           NULL,
    SegmentOrder    INT           NULL,
    StartAt         DATETIME2     NULL,
    EndAt           DATETIME2     NULL,
    DurationMinutes INT           NULL,
    RateType        NVARCHAR(30)  NULL,
    HourlyRate      DECIMAL(18,2) NULL,
    Amount          DECIMAL(18,2) NULL,
    CreatedAt       DATETIME2     NULL,
    CONSTRAINT FK_CourtChargeSegment_HoaDon     FOREIGN KEY (HoaDonID)  REFERENCES dbo.HoaDon(HoaDonID),
    CONSTRAINT FK_CourtChargeSegment_LichDatSan FOREIGN KEY (DatSanID)  REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT CK_CourtChargeSegment_RateType   CHECK (RateType IN ('WITHOUT_LIGHT', 'WITH_LIGHT'))
);
GO

-- sql/migration_payos_config.sql
-- NOTE: Columns store PayOS API credentials per facility.
-- Column names listed; actual values are NEVER stored in source code.
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'PayOS_ClientID')
    ALTER TABLE dbo.CoSo ADD PayOS_ClientID NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'PayOS_ApiKey')
    ALTER TABLE dbo.CoSo ADD PayOS_ApiKey NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'PayOS_ChecksumKey')
    ALTER TABLE dbo.CoSo ADD PayOS_ChecksumKey NVARCHAR(500) NULL;
GO

-- sql/migration_payos_payment_attempt.sql
IF OBJECT_ID('dbo.PayOSPaymentAttempt', 'U') IS NULL
CREATE TABLE dbo.PayOSPaymentAttempt (
    AttemptID     BIGINT        IDENTITY(1,1) PRIMARY KEY,
    HoaDonID      INT           NULL,
    DatSanID      INT           NULL,
    CoSoID        INT           NULL,
    OrderCode     BIGINT        NULL UNIQUE,
    PaymentLinkID NVARCHAR(100) NULL,
    CheckoutUrl   NVARCHAR(1000) NULL,
    QrCode        NVARCHAR(MAX) NULL,
    Status        NVARCHAR(30)  NULL,
    Amount        DECIMAL(18,2) NULL,
    Description   NVARCHAR(100) NULL,
    CreatedAt     DATETIME2     NULL,
    PaidAt        DATETIME2     NULL,
    CancelledAt   DATETIME2     NULL,
    LastCheckedAt DATETIME2     NULL,
    FailureReason NVARCHAR(500) NULL,
    CONSTRAINT FK_PayOSPaymentAttempt_HoaDon     FOREIGN KEY (HoaDonID)  REFERENCES dbo.HoaDon(HoaDonID),
    CONSTRAINT FK_PayOSPaymentAttempt_LichDatSan FOREIGN KEY (DatSanID)  REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_PayOSPaymentAttempt_CoSo       FOREIGN KEY (CoSoID)    REFERENCES dbo.CoSo(CoSoID)
);
GO

-- sql/migration_customer_reputation_cancel_flow.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'LateCancelCount')
    ALTER TABLE dbo.Accounts ADD LateCancelCount INT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'NoShowCount')
    ALTER TABLE dbo.Accounts ADD NoShowCount INT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'CompletedBookingCount')
    ALTER TABLE dbo.Accounts ADD CompletedBookingCount INT NULL DEFAULT 0;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'CancelType')
    ALTER TABLE dbo.LichDatSan ADD CancelType NVARCHAR(50) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'CancelReason')
    ALTER TABLE dbo.LichDatSan ADD CancelReason NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'CancelledAt')
    ALTER TABLE dbo.LichDatSan ADD CancelledAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'CancelledBy')
    ALTER TABLE dbo.LichDatSan ADD CancelledBy INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'RequiresRefundReview')
    ALTER TABLE dbo.LichDatSan ADD RequiresRefundReview BIT NULL DEFAULT 0;
IF OBJECT_ID('dbo.FK_LichDatSan_CancelledBy', 'F') IS NULL
    ALTER TABLE dbo.LichDatSan ADD CONSTRAINT FK_LichDatSan_CancelledBy FOREIGN KEY (CancelledBy) REFERENCES dbo.Accounts(AccountID);

IF OBJECT_ID('dbo.CustomerReputationHistory', 'U') IS NULL
CREATE TABLE dbo.CustomerReputationHistory (
    ReputationHistoryID BIGINT        IDENTITY(1,1) PRIMARY KEY,
    AccountID           INT           NULL,
    DatSanID            INT           NULL,
    ActionType          NVARCHAR(30)  NULL,
    ScoreDelta          INT           NULL,
    ScoreBefore         INT           NULL,
    ScoreAfter          INT           NULL,
    Reason              NVARCHAR(500) NULL,
    CreatedAt           DATETIME2     NULL,
    CreatedBy           INT           NULL,
    IpAddress           NVARCHAR(50)  NULL,
    CONSTRAINT FK_CustomerReputationHistory_Account    FOREIGN KEY (AccountID)  REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_CustomerReputationHistory_DatSan     FOREIGN KEY (DatSanID)   REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_CustomerReputationHistory_CreatedBy  FOREIGN KEY (CreatedBy)  REFERENCES dbo.Accounts(AccountID)
);
GO

-- sql/migration_facility_geolocation.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'ViDo')
    ALTER TABLE dbo.CoSo ADD ViDo DECIMAL(12,9) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.CoSo') AND name = 'KinhDo')
    ALTER TABLE dbo.CoSo ADD KinhDo DECIMAL(12,9) NULL;
GO

-- sql/migration_customer_profile.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'CoverImageUrl')
    ALTER TABLE dbo.Accounts ADD CoverImageUrl NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'ChieuCaoCm')
    ALTER TABLE dbo.Accounts ADD ChieuCaoCm INT NULL CONSTRAINT CK_Accounts_ChieuCao CHECK (ChieuCaoCm >= 50 AND ChieuCaoCm <= 260);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'CanNangKg')
    ALTER TABLE dbo.Accounts ADD CanNangKg INT NULL CONSTRAINT CK_Accounts_CanNang CHECK (CanNangKg >= 20 AND CanNangKg <= 300);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'GhiChuDacBiet')
    ALTER TABLE dbo.Accounts ADD GhiChuDacBiet NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'ViTriYeuThich')
    ALTER TABLE dbo.Accounts ADD ViTriYeuThich NVARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'MonTheThaoYeuThichID')
    ALTER TABLE dbo.Accounts ADD MonTheThaoYeuThichID INT NULL CONSTRAINT FK_Accounts_MonTheThao_YeuThich FOREIGN KEY REFERENCES dbo.MonTheThao(MonTheThaoID);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'TrinhDoChoi')
    ALTER TABLE dbo.Accounts ADD TrinhDoChoi VARCHAR(30) NULL CONSTRAINT CK_Accounts_TrinhDoChoi CHECK (TrinhDoChoi IN (N'Mới chơi', N'Cơ bản', N'Trung bình', N'Khá', N'Nâng cao'));
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'MucTieuChoi')
    ALTER TABLE dbo.Accounts ADD MucTieuChoi NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'TanSuatChoi')
    ALTER TABLE dbo.Accounts ADD TanSuatChoi VARCHAR(30) NULL;
GO

-- sql/migration_matchmaking_complete_flow.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.GhepKeo') AND name = 'SoNguoiCanTim')
    ALTER TABLE dbo.GhepKeo ADD SoNguoiCanTim INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.GhepKeo') AND name = 'HinhThucDuyet')
    ALTER TABLE dbo.GhepKeo ADD HinhThucDuyet NVARCHAR(20) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.GhepKeo') AND name = 'CreatedAt')
    ALTER TABLE dbo.GhepKeo ADD CreatedAt DATETIME2 NULL;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.ChiTietGhepKeo') AND name = 'UX_ChiTietGhepKeo_Active_Keo_Account')
    CREATE UNIQUE INDEX UX_ChiTietGhepKeo_Active_Keo_Account
        ON dbo.ChiTietGhepKeo (KeoID, AccountID_NguoiThamGia)
        WHERE TrangThaiThamGia <> N'DaRoi';
GO

-- sql/migration_team_management.sql
IF OBJECT_ID('dbo.Teams', 'U') IS NULL
CREATE TABLE dbo.Teams (
    TeamID          INT           IDENTITY(1,1) PRIMARY KEY,
    TeamName        NVARCHAR(50)  NULL,
    Description     NVARCHAR(225) NULL,
    SportID         INT           NULL,
    CaptainAccountID INT          NULL,
    LocationText    NVARCHAR(255) NULL,
    AvatarPath      NVARCHAR(500) NULL,
    CoverImagePath  NVARCHAR(500) NULL,
    MaxMembers      INT           NULL,
    Status          VARCHAR(30)   DEFAULT 'ACTIVE',
    CreatedAt       DATETIME2     NULL,
    UpdatedAt       DATETIME2     NULL,
    IsDeleted       BIT           DEFAULT 0,
    DeletedAt       DATETIME2     NULL,
    DeletedBy       INT           NULL,
    CONSTRAINT FK_Teams_MonTheThao       FOREIGN KEY (SportID)          REFERENCES dbo.MonTheThao(MonTheThaoID),
    CONSTRAINT FK_Teams_CaptainAccount   FOREIGN KEY (CaptainAccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_Teams_MaxMembers       CHECK (MaxMembers >= 2 AND MaxMembers <= 30),
    CONSTRAINT CK_Teams_Status           CHECK (Status IN ('ACTIVE','INACTIVE','DISBANDED','SUSPENDED'))
);
GO

IF OBJECT_ID('dbo.TeamMembers', 'U') IS NULL
CREATE TABLE dbo.TeamMembers (
    TeamMemberID INT          IDENTITY(1,1) PRIMARY KEY,
    TeamID       INT          NULL,
    AccountID    INT          NULL,
    MemberRole   VARCHAR(30)  NULL,
    MemberStatus VARCHAR(30)  DEFAULT 'ACTIVE',
    JoinedAt     DATETIME2    NULL,
    LeftAt       DATETIME2    NULL,
    AddedBy      INT          NULL,
    CONSTRAINT FK_TeamMembers_Teams   FOREIGN KEY (TeamID)    REFERENCES dbo.Teams(TeamID),
    CONSTRAINT FK_TeamMembers_Account FOREIGN KEY (AccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_TeamMembers_MemberRole   CHECK (MemberRole   IN ('CAPTAIN','CO_CAPTAIN','MEMBER')),
    CONSTRAINT CK_TeamMembers_MemberStatus CHECK (MemberStatus IN ('ACTIVE','LEFT','REMOVED'))
);
GO

IF OBJECT_ID('dbo.TeamInvitations', 'U') IS NULL
CREATE TABLE dbo.TeamInvitations (
    InvitationID       INT          IDENTITY(1,1) PRIMARY KEY,
    TeamID             INT          NULL,
    InvitedAccountID   INT          NULL,
    InvitedByAccountID INT          NULL,
    ProposedRole       VARCHAR(30)  DEFAULT 'MEMBER',
    Status             VARCHAR(30)  DEFAULT 'PENDING',
    Message            NVARCHAR(500) NULL,
    CreatedAt          DATETIME2    NULL,
    ExpiresAt          DATETIME2    NULL,
    RespondedAt        DATETIME2    NULL,
    CONSTRAINT FK_TeamInvitations_Teams             FOREIGN KEY (TeamID)             REFERENCES dbo.Teams(TeamID),
    CONSTRAINT FK_TeamInvitations_InvitedAccount    FOREIGN KEY (InvitedAccountID)   REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_TeamInvitations_InvitedByAccount  FOREIGN KEY (InvitedByAccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_TeamInvitations_ProposedRole      CHECK (ProposedRole IN ('CO_CAPTAIN','MEMBER')),
    CONSTRAINT CK_TeamInvitations_Status            CHECK (Status IN ('PENDING','ACCEPTED','REJECTED','CANCELLED','EXPIRED'))
);
GO

IF OBJECT_ID('dbo.TeamJoinRequests', 'U') IS NULL
CREATE TABLE dbo.TeamJoinRequests (
    JoinRequestID        INT          IDENTITY(1,1) PRIMARY KEY,
    TeamID               INT          NULL,
    RequesterAccountID   INT          NULL,
    Message              NVARCHAR(500) NULL,
    Status               VARCHAR(30)  DEFAULT 'PENDING',
    CreatedAt            DATETIME2    NULL,
    ReviewedAt           DATETIME2    NULL,
    ReviewedByAccountID  INT          NULL,
    CONSTRAINT FK_TeamJoinRequests_Teams              FOREIGN KEY (TeamID)              REFERENCES dbo.Teams(TeamID),
    CONSTRAINT FK_TeamJoinRequests_RequesterAccount   FOREIGN KEY (RequesterAccountID)  REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_TeamJoinRequests_ReviewedByAccount  FOREIGN KEY (ReviewedByAccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_TeamJoinRequests_Status             CHECK (Status IN ('PENDING','APPROVED','REJECTED','CANCELLED'))
);
GO

-- Add team references to GhepKeo and ChiTietGhepKeo
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.GhepKeo') AND name = 'TeamIDNguoiTao')
    ALTER TABLE dbo.GhepKeo ADD TeamIDNguoiTao INT NULL CONSTRAINT FK_GhepKeo_TeamNguoiTao FOREIGN KEY REFERENCES dbo.Teams(TeamID);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ChiTietGhepKeo') AND name = 'TeamIDNguoiThamGia')
    ALTER TABLE dbo.ChiTietGhepKeo ADD TeamIDNguoiThamGia INT NULL CONSTRAINT FK_ChiTietGhepKeo_Team FOREIGN KEY REFERENCES dbo.Teams(TeamID);
GO

-- sql/migration_facility_capability.sql
IF OBJECT_ID('dbo.CoSoCapability', 'U') IS NULL
CREATE TABLE dbo.CoSoCapability (
    CapabilityID   INT           IDENTITY(1,1) PRIMARY KEY,
    CoSoID         INT           NULL,
    CapabilityType NVARCHAR(50)  NULL,
    TrangThai      NVARCHAR(20)  DEFAULT 'PENDING',
    RequestedAt    DATETIME2     NULL,
    ApprovedBy     INT           NULL,
    ApprovedAt     DATETIME2     NULL,
    RejectReason   NVARCHAR(500) NULL,
    Note           NVARCHAR(500) NULL,
    UpdatedAt      DATETIME2     NULL,
    CONSTRAINT FK_CoSoCapability_CoSo       FOREIGN KEY (CoSoID)     REFERENCES dbo.CoSo(CoSoID),
    CONSTRAINT FK_CoSoCapability_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT UQ_CoSoCapability_CoSo_Type  UNIQUE (CoSoID, CapabilityType)
);
GO

-- sql/migration_qr_request.sql
IF OBJECT_ID('dbo.QRRequest', 'U') IS NULL
CREATE TABLE dbo.QRRequest (
    RequestID         INT           IDENTITY(1,1) PRIMARY KEY,
    SanID             INT           NULL,
    CoSoID            INT           NULL,
    GuestToken        VARCHAR(64)   NULL,
    CustomerID        INT           NULL,
    RequestType       VARCHAR(20)   NULL,
    ItemsJson         NVARCHAR(MAX) NULL,
    Note              NVARCHAR(500) NULL,
    Status            VARCHAR(20)   DEFAULT 'NEW',
    CreatedAt         DATETIME2     NULL,
    UpdatedAt         DATETIME2     NULL,
    HandledByStaffID  INT           NULL,
    CONSTRAINT FK_QRRequest_San   FOREIGN KEY (SanID)   REFERENCES dbo.San(SanID),
    CONSTRAINT FK_QRRequest_CoSo  FOREIGN KEY (CoSoID)  REFERENCES dbo.CoSo(CoSoID),
    CONSTRAINT CK_QRRequest_RequestType CHECK (RequestType IN ('CALL_STAFF','ORDER_ITEM','SERVICE_REQUEST')),
    CONSTRAINT CK_QRRequest_Status      CHECK (Status      IN ('NEW','IN_PROGRESS','DONE','CANCELLED'))
);
GO

-- sql/migration_san_qr.sql
IF OBJECT_ID('dbo.SanQR', 'U') IS NULL
CREATE TABLE dbo.SanQR (
    SanQRID         INT              IDENTITY(1,1) PRIMARY KEY,
    SanID           INT              NULL UNIQUE,
    Token           UNIQUEIDENTIFIER DEFAULT NEWID(),
    TrangThai       NVARCHAR(20)     DEFAULT 'ACTIVE',
    CreatedAt       DATETIME2        NULL,
    CreatedBy       INT              NULL,
    UpdatedAt       DATETIME2        NULL,
    UpdatedBy       INT              NULL,
    RegenerateCount INT              DEFAULT 0,
    CONSTRAINT FK_SanQR_San       FOREIGN KEY (SanID)     REFERENCES dbo.San(SanID),
    CONSTRAINT FK_SanQR_CreatedBy FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_SanQR_UpdatedBy FOREIGN KEY (UpdatedBy) REFERENCES dbo.Accounts(AccountID)
);
GO

IF OBJECT_ID('dbo.SanQRTokenHistory', 'U') IS NULL
CREATE TABLE dbo.SanQRTokenHistory (
    HistoryID   INT              IDENTITY(1,1) PRIMARY KEY,
    SanQRID     INT              NULL,
    SanID       INT              NULL,
    Token       UNIQUEIDENTIFIER NULL,
    TrangThai   NVARCHAR(20)     DEFAULT 'ISSUED',
    IssuedAt    DATETIME2        NULL,
    RevokedAt   DATETIME2        NULL,
    RevokedBy   INT              NULL,
    RevokeReason NVARCHAR(255)   NULL,
    CONSTRAINT FK_SanQRTokenHistory_SanQR     FOREIGN KEY (SanQRID)   REFERENCES dbo.SanQR(SanQRID),
    CONSTRAINT FK_SanQRTokenHistory_San       FOREIGN KEY (SanID)     REFERENCES dbo.San(SanID),
    CONSTRAINT FK_SanQRTokenHistory_RevokedBy FOREIGN KEY (RevokedBy) REFERENCES dbo.Accounts(AccountID)
);
GO

-- sql/migration_san_qr_hardening.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SanQR') AND name = 'ShortCode')
    ALTER TABLE dbo.SanQR ADD ShortCode NVARCHAR(12) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'TokenHash')
    ALTER TABLE dbo.SanQRTokenHistory ADD TokenHash NVARCHAR(64) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.SanQRTokenHistory') AND name = 'ShortCode')
    ALTER TABLE dbo.SanQRTokenHistory ADD ShortCode NVARCHAR(12) NULL;
-- Token column made nullable (already NULL in base create above)
GO

-- sql/migration_sport_service_module.sql
IF OBJECT_ID('dbo.SportService', 'U') IS NULL
CREATE TABLE dbo.SportService (
    ServiceID            INT           IDENTITY(1,1) PRIMARY KEY,
    CoSoID               INT           NULL,
    ServiceType          NVARCHAR(30)  NULL,
    ServiceName          NVARCHAR(150) NULL,
    SportType            NVARCHAR(50)  NULL,
    Description          NVARCHAR(MAX) NULL,
    BasePrice            DECIMAL(12,2) NULL,
    Unit                 NVARCHAR(30)  NULL,
    EstimatedMinutes     INT           NULL,
    MaxRequestsPerDay    INT           NULL,
    ReceiveTimeStart     TIME          NULL,
    ReceiveTimeEnd       TIME          NULL,
    ImageUrl             NVARCHAR(500) NULL,
    IsAcceptingRequests  BIT           DEFAULT 1,
    Policy               NVARCHAR(MAX) NULL,
    CustomerNote         NVARCHAR(MAX) NULL,
    IsDeleted            BIT           DEFAULT 0,
    CreatedAt            DATETIME2     NULL,
    UpdatedAt            DATETIME2     NULL,
    CONSTRAINT FK_SportService_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID),
    CONSTRAINT CK_SportService_ServiceType CHECK (ServiceType IN ('CANG_LUOI','THAY_QUAN_CAN','SUA_VOT','BAO_DUONG','HUAN_LUYEN_VIEN','KHAC'))
);
GO

IF OBJECT_ID('dbo.RacketStringingConfig', 'U') IS NULL
CREATE TABLE dbo.RacketStringingConfig (
    ConfigID              INT           IDENTITY(1,1) PRIMARY KEY,
    ServiceID             INT           NULL UNIQUE,
    RacketTypes           NVARCHAR(MAX) NULL,
    StringingPrice        DECIMAL(12,2) NULL,
    MinTension            DECIMAL(5,2)  NULL,
    MaxTension            DECIMAL(5,2)  NULL,
    TensionUnit           NVARCHAR(5)   DEFAULT 'kg',
    AllowCustomerString   BIT           NULL,
    SellsString           BIT           NULL,
    AvgCompletionMinutes  INT           NULL,
    MaxRacketsPerOrder    INT           NULL,
    OldRacketPolicy       NVARCHAR(MAX) NULL,
    StringBreakPolicy     NVARCHAR(MAX) NULL,
    CONSTRAINT FK_RacketStringingConfig_SportService FOREIGN KEY (ServiceID) REFERENCES dbo.SportService(ServiceID),
    CONSTRAINT CK_RacketStringingConfig_TensionUnit  CHECK (TensionUnit IN ('kg','lbs'))
);
GO

IF OBJECT_ID('dbo.ServiceMaterial', 'U') IS NULL
CREATE TABLE dbo.ServiceMaterial (
    MaterialID  INT           IDENTITY(1,1) PRIMARY KEY,
    CoSoID      INT           NULL,
    Name        NVARCHAR(150) NULL,
    Brand       NVARCHAR(100) NULL,
    Code        NVARCHAR(50)  NULL,
    Color       NVARCHAR(50)  NULL,
    SportType   NVARCHAR(50)  NULL,
    Price       DECIMAL(12,2) NULL,
    ExtraFee    DECIMAL(12,2) NULL,
    Status      NVARCHAR(20)  DEFAULT 'DANG_CO',
    Description NVARCHAR(MAX) NULL,
    IsDeleted   BIT           DEFAULT 0,
    CreatedAt   DATETIME2     NULL,
    UpdatedAt   DATETIME2     NULL,
    CONSTRAINT FK_ServiceMaterial_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID),
    CONSTRAINT CK_ServiceMaterial_Status CHECK (Status IN ('DANG_CO','TAM_HET','NGUNG_SU_DUNG'))
);
GO

IF OBJECT_ID('dbo.ServiceOrder', 'U') IS NULL
CREATE TABLE dbo.ServiceOrder (
    OrderID              INT           IDENTITY(1,1) PRIMARY KEY,
    CustomerID           INT           NULL,
    CoSoID               INT           NULL,
    ServiceID            INT           NULL,
    BookingID            INT           NULL,
    Status               NVARCHAR(30)  NULL,
    RequestedAt          DATETIME2     NULL,
    AppointmentDate      DATE          NULL,
    DropOffTime          NVARCHAR(20)  NULL,
    ExpectedPickupTime   DATETIME2     NULL,
    ActualReceivedTime   DATETIME2     NULL,
    CompletedTime        DATETIME2     NULL,
    DeliveredTime        DATETIME2     NULL,
    CancelledTime        DATETIME2     NULL,
    CustomerNote         NVARCHAR(MAX) NULL,
    ManagerNote          NVARCHAR(MAX) NULL,
    EstimatedPrice       DECIMAL(12,2) NULL,
    ConfirmedPrice       DECIMAL(12,2) NULL,
    CancellationReason   NVARCHAR(500) NULL,
    CreatedAt            DATETIME2     NULL,
    UpdatedAt            DATETIME2     NULL,
    CONSTRAINT FK_ServiceOrder_Customer    FOREIGN KEY (CustomerID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_ServiceOrder_CoSo        FOREIGN KEY (CoSoID)     REFERENCES dbo.CoSo(CoSoID),
    CONSTRAINT FK_ServiceOrder_SportService FOREIGN KEY (ServiceID)  REFERENCES dbo.SportService(ServiceID),
    CONSTRAINT FK_ServiceOrder_LichDatSan  FOREIGN KEY (BookingID)  REFERENCES dbo.LichDatSan(DatSanID)
);
GO

IF OBJECT_ID('dbo.RacketStringingOrderDetail', 'U') IS NULL
CREATE TABLE dbo.RacketStringingOrderDetail (
    DetailID             INT           IDENTITY(1,1) PRIMARY KEY,
    OrderID              INT           NULL UNIQUE,
    RacketType           NVARCHAR(100) NULL,
    RacketBrand          NVARCHAR(100) NULL,
    RacketModel          NVARCHAR(100) NULL,
    MaterialID           INT           NULL,
    CustomerBringsString BIT           NULL,
    TensionValue         DECIMAL(5,2)  NULL,
    TensionUnit          NVARCHAR(5)   NULL,
    StringColor          NVARCHAR(50)  NULL,
    Quantity             INT           NULL,
    TechnicalNote        NVARCHAR(MAX) NULL,
    CONSTRAINT FK_RacketStringingOrderDetail_ServiceOrder    FOREIGN KEY (OrderID)    REFERENCES dbo.ServiceOrder(OrderID),
    CONSTRAINT FK_RacketStringingOrderDetail_ServiceMaterial FOREIGN KEY (MaterialID) REFERENCES dbo.ServiceMaterial(MaterialID),
    CONSTRAINT CK_RacketStringingOrderDetail_TensionUnit     CHECK (TensionUnit IN ('kg','lbs')),
    CONSTRAINT CK_RacketStringingOrderDetail_Quantity        CHECK (Quantity > 0)
);
GO

-- ServiceOrderStatusHistory - DDL inferred from Java model (no migration SQL found)
IF OBJECT_ID('dbo.ServiceOrderStatusHistory', 'U') IS NULL
CREATE TABLE dbo.ServiceOrderStatusHistory (
    HistoryID   INT           IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT           NOT NULL,
    FromStatus  NVARCHAR(30)  NULL,
    ToStatus    NVARCHAR(30)  NOT NULL,
    ChangedBy   INT           NULL,
    ChangedAt   DATETIME2     NULL,
    Note        NVARCHAR(500) NULL,
    CONSTRAINT FK_ServiceOrderStatusHistory_ServiceOrder FOREIGN KEY (OrderID)    REFERENCES dbo.ServiceOrder(OrderID),
    CONSTRAINT FK_ServiceOrderStatusHistory_ChangedBy    FOREIGN KEY (ChangedBy) REFERENCES dbo.Accounts(AccountID)
);
GO
-- WARNING: DDL above is INFERRED from Java model. Actual DB may differ.

-- sql/migration_notification_marketing_refund_review.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Accounts') AND name = 'NhanThongBaoMarketing')
    ALTER TABLE dbo.Accounts ADD NhanThongBaoMarketing BIT NULL DEFAULT 1;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('dbo.DanhGia') AND name = 'UQ_DanhGia_DatSan_Account')
    ALTER TABLE dbo.DanhGia ADD CONSTRAINT UQ_DanhGia_DatSan_Account UNIQUE (DatSanID, AccountID_NguoiDanhGia);
GO

-- sql/migration_thongbao_table.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ThongBao') AND name = 'MaBanGhi')
    ALTER TABLE dbo.ThongBao ADD MaBanGhi NVARCHAR(100) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.ThongBao') AND name = 'DuongDan')
    ALTER TABLE dbo.ThongBao ADD DuongDan NVARCHAR(500) NULL;
GO

-- sql/migration_group_bill_split.sql
IF OBJECT_ID('dbo.NhomChiaTien', 'U') IS NULL
CREATE TABLE dbo.NhomChiaTien (
    NhomChiaTienID    INT           IDENTITY(1,1) PRIMARY KEY,
    HoaDonID          INT           NULL,
    DatSanID          INT           NULL,
    CreatedByAccountID INT          NULL,
    SplitType         NVARCHAR(20)  NULL,
    TongTien          DECIMAL(18,2) NULL,
    TrangThai         NVARCHAR(20)  DEFAULT 'DRAFT',
    ExpiresAt         DATETIME2     NULL,
    CreatedAt         DATETIME2     NULL,
    UpdatedAt         DATETIME2     NULL,
    CONSTRAINT FK_NhomChiaTien_HoaDon           FOREIGN KEY (HoaDonID)          REFERENCES dbo.HoaDon(HoaDonID),
    CONSTRAINT FK_NhomChiaTien_LichDatSan       FOREIGN KEY (DatSanID)           REFERENCES dbo.LichDatSan(DatSanID),
    CONSTRAINT FK_NhomChiaTien_CreatedByAccount FOREIGN KEY (CreatedByAccountID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_NhomChiaTien_SplitType  CHECK (SplitType  IN ('EQUAL','CUSTOM','ITEMIZED')),
    CONSTRAINT CK_NhomChiaTien_TrangThai  CHECK (TrangThai  IN ('DRAFT','ACTIVE','PARTIALLY_PAID','PAID','CANCELLED','EXPIRED'))
);
GO

IF OBJECT_ID('dbo.NhomChiaTienChiTiet', 'U') IS NULL
CREATE TABLE dbo.NhomChiaTienChiTiet (
    ChiTietID          INT           IDENTITY(1,1) PRIMARY KEY,
    NhomChiaTienID     INT           NULL,
    AccountID          INT           NULL,
    DisplayName        NVARCHAR(100) NULL,
    ShareToken         CHAR(43)      NULL UNIQUE,
    SoTien             DECIMAL(18,2) NULL,
    TrangThai          NVARCHAR(50)  DEFAULT 'PENDING',
    PaymentMethod      NVARCHAR(50)  NULL,
    PaymentTransactionID NVARCHAR(100) NULL,
    PayerAccountID     INT           NULL,
    PaidAt             DATETIME2     NULL,
    ConfirmedByStaffID INT           NULL,
    CreatedAt          DATETIME2     NULL,
    UpdatedAt          DATETIME2     NULL,
    CONSTRAINT FK_NhomChiaTienChiTiet_NhomChiaTien    FOREIGN KEY (NhomChiaTienID)     REFERENCES dbo.NhomChiaTien(NhomChiaTienID),
    CONSTRAINT FK_NhomChiaTienChiTiet_Account          FOREIGN KEY (AccountID)          REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_NhomChiaTienChiTiet_PayerAccount     FOREIGN KEY (PayerAccountID)     REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT FK_NhomChiaTienChiTiet_ConfirmedByStaff FOREIGN KEY (ConfirmedByStaffID) REFERENCES dbo.Accounts(AccountID),
    CONSTRAINT CK_NhomChiaTienChiTiet_TrangThai CHECK (TrangThai IN ('PENDING','PROCESSING','PAID','CANCELLED','EXPIRED')),
    CONSTRAINT CK_NhomChiaTienChiTiet_SoTien    CHECK (SoTien > 0)
);
GO

-- sql/migration_khuyenmai_hinhanh.sql
IF OBJECT_ID('dbo.KhuyenMaiHinhAnh', 'U') IS NULL
CREATE TABLE dbo.KhuyenMaiHinhAnh (
    HinhAnhID   INT           IDENTITY(1,1) PRIMARY KEY,
    KhuyenMaiID INT           NULL,
    HinhAnhUrl  NVARCHAR(500) NULL,
    SoThuTu     INT           NULL,
    CONSTRAINT FK_KhuyenMaiHinhAnh_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID)
);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.KhuyenMai') AND name = 'HienThiCongKhai')
    ALTER TABLE dbo.KhuyenMai ADD HienThiCongKhai BIT NULL;
GO

-- sql/migration_promotional_codes.sql
IF OBJECT_ID('dbo.LichSuKhuyenMai', 'U') IS NULL
CREATE TABLE dbo.LichSuKhuyenMai (
    LichSuKhuyenMaiID INT       IDENTITY(1,1) PRIMARY KEY,
    KhuyenMaiID       INT       NULL,
    AccountID         INT       NULL,
    ThoiGianSuDung    DATETIME2 NULL,
    HoaDonID          INT       NULL,
    -- ANOMALY: FK_LichSuKM_Account references TaiKhoan(AccountID) in source SQL
    -- This may be a bug (old table name) or TaiKhoan may be a synonym/view for Accounts
    CONSTRAINT FK_LichSuKhuyenMai_KhuyenMai FOREIGN KEY (KhuyenMaiID) REFERENCES dbo.KhuyenMai(KhuyenMaiID)
    -- FK to AccountID deliberately NOT recreated here due to TaiKhoan anomaly
);
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.KhuyenMai') AND name = 'GiaTriToiThieu')
    ALTER TABLE dbo.KhuyenMai ADD GiaTriToiThieu DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.KhuyenMai') AND name = 'GiamToiDa')
    ALTER TABLE dbo.KhuyenMai ADD GiamToiDa DECIMAL(18,2) NULL;
GO

-- sql/migration_refund_workflows.sql
-- Adds columns to HoanTien; note TaiKhoan FK anomaly in original file
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'DatSanID')
    ALTER TABLE dbo.HoanTien ADD DatSanID INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'NguoiDuyetID')
    ALTER TABLE dbo.HoanTien ADD NguoiDuyetID INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'GhiChu')
    ALTER TABLE dbo.HoanTien ADD GhiChu NVARCHAR(500) NULL;
IF OBJECT_ID('dbo.FK_HoanTien_LichDatSan', 'F') IS NULL
    ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_LichDatSan FOREIGN KEY (DatSanID)     REFERENCES dbo.LichDatSan(DatSanID);
IF OBJECT_ID('dbo.FK_HoanTien_NguoiDuyet', 'F') IS NULL
    ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_NguoiDuyet FOREIGN KEY (NguoiDuyetID) REFERENCES dbo.Accounts(AccountID);
GO

-- sql/migration_refund_customer_selfservice.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'SoTienDaThanhToan')
    ALTER TABLE dbo.HoanTien ADD SoTienDaThanhToan DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'SoTienDeNghiHoan')
    ALTER TABLE dbo.HoanTien ADD SoTienDeNghiHoan DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'SoTienDuocDuyet')
    ALTER TABLE dbo.HoanTien ADD SoTienDuocDuyet DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'CoSoID')
    ALTER TABLE dbo.HoanTien ADD CoSoID INT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'QrNhanTienPath')
    ALTER TABLE dbo.HoanTien ADD QrNhanTienPath NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'GhiChuKhachHang')
    ALTER TABLE dbo.HoanTien ADD GhiChuKhachHang NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'LyDoTuChoi')
    ALTER TABLE dbo.HoanTien ADD LyDoTuChoi NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'CompletedAt')
    ALTER TABLE dbo.HoanTien ADD CompletedAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'ApprovedAt')
    ALTER TABLE dbo.HoanTien ADD ApprovedAt DATETIME2 NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.HoanTien') AND name = 'UpdatedAt')
    ALTER TABLE dbo.HoanTien ADD UpdatedAt DATETIME2 NULL;
IF OBJECT_ID('dbo.FK_HoanTien_CoSo', 'F') IS NULL
    ALTER TABLE dbo.HoanTien ADD CONSTRAINT FK_HoanTien_CoSo FOREIGN KEY (CoSoID) REFERENCES dbo.CoSo(CoSoID);
GO

-- migrate_customer_embedded_payos_payment.sql
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosOrderCode')
    ALTER TABLE dbo.LichDatSan ADD PayosOrderCode BIGINT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosPaymentLinkId')
    ALTER TABLE dbo.LichDatSan ADD PayosPaymentLinkId VARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosQrPayload')
    ALTER TABLE dbo.LichDatSan ADD PayosQrPayload NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosCheckoutUrl')
    ALTER TABLE dbo.LichDatSan ADD PayosCheckoutUrl NVARCHAR(1024) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosBin')
    ALTER TABLE dbo.LichDatSan ADD PayosBin VARCHAR(20) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosAccountNumber')
    ALTER TABLE dbo.LichDatSan ADD PayosAccountNumber VARCHAR(64) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosAccountName')
    ALTER TABLE dbo.LichDatSan ADD PayosAccountName NVARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosAmount')
    ALTER TABLE dbo.LichDatSan ADD PayosAmount DECIMAL(18,2) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosDescription')
    ALTER TABLE dbo.LichDatSan ADD PayosDescription NVARCHAR(255) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.LichDatSan') AND name = 'PayosExpiresAt')
    ALTER TABLE dbo.LichDatSan ADD PayosExpiresAt DATETIME2 NULL;
GO

-- ============================================================
-- SECTION 3: VIEWS
-- ============================================================

-- sql/fix_view_yeuCauNghi.sql
IF OBJECT_ID('dbo.V_YeuCauNghi_ChiTiet', 'V') IS NOT NULL
    DROP VIEW dbo.V_YeuCauNghi_ChiTiet;
GO
CREATE VIEW dbo.V_YeuCauNghi_ChiTiet AS
SELECT
    ycn.YeuCauNghiID, ycn.AccountID, ycn.CoSoID, ycn.NgayNghi,
    ycn.LoaiNghi, ycn.LyDo, ycn.MucDoKhanCap, ycn.TrangThai,
    ycn.GhiChuQuanLy, ycn.NgayXuLy, ycn.XuLyBy, ycn.NgayGui,
    ycn.CreatedAt, ycn.UpdatedAt, ycn.IsDeleted, ycn.DeletedAt, ycn.DeletedBy,
    tk.FullName   AS TenNhanVien,
    tk.Username   AS username,
    cs.TenCoSo,
    r.RoleName,
    ql.FullName   AS QuanLyXuLy,
    0             AS SoCaBiAnhHuong
FROM dbo.YeuCauNghi ycn
LEFT JOIN dbo.Accounts  tk ON ycn.AccountID = tk.AccountID
LEFT JOIN dbo.Roles      r ON tk.RoleID      = r.RoleID
LEFT JOIN dbo.CoSo      cs ON ycn.CoSoID    = cs.CoSoID
LEFT JOIN dbo.Accounts  ql ON ycn.XuLyBy    = ql.AccountID
WHERE ycn.IsDeleted = 0;
GO

-- ============================================================
-- END OF SCHEMA
-- ============================================================
-- Tables with DDL fully inferred from Java model (no migration SQL found):
--   YeuCauNghi, CaLamViecAudit, CaLamViecAvailability,
--   CaLamViecSwapRequest, SoftHold, ServiceOrderStatusHistory
-- These tables exist per Java @Entity annotations but their CREATE TABLE
-- statements were not found in any scanned SQL file.
-- ============================================================
