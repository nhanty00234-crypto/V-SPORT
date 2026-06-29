-- ====================================================================================
-- DỰ ÁN: HỆ SINH THÁI QUẢN LÝ CHUỖI THỂ THAO (QUANLISPORT)
-- PHIÊN BẢN: V4 - TÍCH HỢP SOCIAL LOGIN, INTERESTS & TỐI ƯU GIỜ LÊN ĐÈN THEO LOẠI SÂN
-- NGÀY CẬP NHẬT: MAY 2026
-- ====================================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLiSport')
BEGIN
    CREATE DATABASE QuanLiSport;
END
GO

USE QuanLiSport;
GO

-- =====================================================================
-- 1. XÓA BẢNG CŨ (Xóa từ con → cha để tránh xung đột Khóa ngoại)
-- =====================================================================
IF OBJECT_ID('HoanTien',            'U') IS NOT NULL DROP TABLE HoanTien;
IF OBJECT_ID('KhuyenMai',           'U') IS NOT NULL DROP TABLE KhuyenMai;
IF OBJECT_ID('CaLamViec',           'U') IS NOT NULL DROP TABLE CaLamViec;
IF OBJECT_ID('ThongBao',            'U') IS NOT NULL DROP TABLE ThongBao;
IF OBJECT_ID('NhatKySOSGui',        'U') IS NOT NULL DROP TABLE NhatKySOSGui;
IF OBJECT_ID('YeuCauSOS',           'U') IS NOT NULL DROP TABLE YeuCauSOS;
IF OBJECT_ID('MaQR',                'U') IS NOT NULL DROP TABLE MaQR;
IF OBJECT_ID('ChiaHoaDon',          'U') IS NOT NULL DROP TABLE ChiaHoaDon;
IF OBJECT_ID('LichSuELO',           'U') IS NOT NULL DROP TABLE LichSuELO;
IF OBJECT_ID('NhatKyChat',          'U') IS NOT NULL DROP TABLE NhatKyChat;
IF OBJECT_ID('ChiTietHoaDon',       'U') IS NOT NULL DROP TABLE ChiTietHoaDon;
IF OBJECT_ID('HoaDon',              'U') IS NOT NULL DROP TABLE HoaDon;
IF OBJECT_ID('LichXeRaVao',         'U') IS NOT NULL DROP TABLE LichXeRaVao;
IF OBJECT_ID('TheGiuXe',            'U') IS NOT NULL DROP TABLE TheGiuXe;
IF OBJECT_ID('DanhGia',             'U') IS NOT NULL DROP TABLE DanhGia;
IF OBJECT_ID('ChiTietGhepKeo',      'U') IS NOT NULL DROP TABLE ChiTietGhepKeo;
IF OBJECT_ID('GhepKeo',             'U') IS NOT NULL DROP TABLE GhepKeo;
IF OBJECT_ID('LichDatSan',          'U') IS NOT NULL DROP TABLE LichDatSan;
IF OBJECT_ID('SanPham_DichVu',      'U') IS NOT NULL DROP TABLE SanPham_DichVu;
IF OBJECT_ID('DanhMucSanPham',      'U') IS NOT NULL DROP TABLE DanhMucSanPham;
IF OBJECT_ID('San',                 'U') IS NOT NULL DROP TABLE San;
IF OBJECT_ID('LoaiSan',             'U') IS NOT NULL DROP TABLE LoaiSan;
IF OBJECT_ID('MonTheThaoYeuThich',  'U') IS NOT NULL DROP TABLE MonTheThaoYeuThich;
IF OBJECT_ID('MonTheThao',          'U') IS NOT NULL DROP TABLE MonTheThao;
IF OBJECT_ID('Accounts',            'U') IS NOT NULL DROP TABLE Accounts;
IF OBJECT_ID('Roles',               'U') IS NOT NULL DROP TABLE Roles;
IF OBJECT_ID('CoSo',                'U') IS NOT NULL DROP TABLE CoSo;
GO

-- =====================================================================
-- 2. HỆ THỐNG LÕI: CƠ SỞ & PHÂN QUYỀN
-- =====================================================================

CREATE TABLE Roles (
    RoleID   INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL                 
);

CREATE TABLE CoSo (
    CoSoID              INT PRIMARY KEY IDENTITY(1,1),
    TenCoSo             NVARCHAR(100) NOT NULL,          
    DiaChi              NVARCHAR(255),
    SoDienThoai         VARCHAR(15),
    TrangThai           NVARCHAR(50)  DEFAULT N'Hoạt động',
    GioMoCua            TIME          NULL,               
    GioDongCua          TIME          NULL,               
    HinhAnh             NVARCHAR(500) NULL,               
    MoTa                NVARCHAR(MAX) NULL,
    LoaiHinhKinhDoanh   NVARCHAR(255) NULL, 
    SoLuongSanDuKien    INT           DEFAULT 0,
    AccountID_QuanLy    INT           NULL -- Sẽ thiết lập Khóa ngoại sau khi tạo bảng Accounts
);

-- =====================================================================
-- 3. HỆ THỐNG TÀI KHOẢN (Đã cập nhật GoogleID, FacebookID)
-- =====================================================================

CREATE TABLE Accounts (
    AccountID            INT PRIMARY KEY IDENTITY(1,1),
    Username             VARCHAR(50)   UNIQUE NULL,  -- Cho phép NULL nếu khách đăng ký thuần bằng Social Login
    Password             VARCHAR(255)  NULL,         -- Cho phép NULL nếu chỉ dùng Social Login
    PasswordSalt         VARCHAR(100)  NULL,        
    FailedLoginCount     TINYINT       DEFAULT 0,   
    IsLocked             BIT           DEFAULT 0,   
    LastLogin            DATETIME      NULL,        

    -- [V4 CẬP NHẬT] Đăng nhập bên thứ ba
    GoogleID             VARCHAR(100)  UNIQUE NULL,  -- Lưu định danh từ Google Sign-In
    FacebookID           VARCHAR(100)  UNIQUE NULL,  -- Lưu định danh từ Facebook Login (Kiểu chuỗi lớn tránh tràn số)

    FullName             NVARCHAR(100),
    PhoneNumber          VARCHAR(15),
    Email                VARCHAR(100)  UNIQUE NULL,
    RoleID               INT,
    CoSoID               INT           NULL,                  

    ZaloID               VARCHAR(100)  NULL,        
    MessengerID          VARCHAR(100)  NULL,        
    DiemUyTin            INT           DEFAULT 100, 
    DiemTrinhDo          INT           DEFAULT 1000,
    MaNganHang           VARCHAR(20)   NULL,        
    SoTaiKhoan           VARCHAR(50)   NULL,        
    ViTriSoTruong        NVARCHAR(50)  NULL,        
    NhanThongBaoSOS      BIT           DEFAULT 1,   
    NgaySinh             DATE          NULL,
    GioiTinh             NVARCHAR(10)  NULL,        
    CreatedAt            DATETIME      DEFAULT GETDATE(),

    CONSTRAINT FK_Acc_Role FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    CONSTRAINT FK_Acc_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- Thêm khóa ngoại cho Người quản lý cơ sở hướng về bảng Accounts
ALTER TABLE CoSo ADD CONSTRAINT FK_CoSo_QuanLy FOREIGN KEY (AccountID_QuanLy) REFERENCES Accounts(AccountID);

-- =====================================================================
-- 4. BỘ MÔN THỂ THAO & DANH SÁCH YÊU THÍCH (M-M Relationship)
-- =====================================================================

CREATE TABLE MonTheThao (
    MonTheThaoID INT PRIMARY KEY IDENTITY(1,1),
    TenMon       NVARCHAR(50) NOT NULL               
);

-- [V4 CẬP NHẬT] Bảng trung gian giải quyết bài toán: Một tài khoản thích nhiều môn, một môn có nhiều người thích
CREATE TABLE MonTheThaoYeuThich (
    AccountID    INT NOT NULL,
    MonTheThaoID INT NOT NULL,
    NgayThêm     DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (AccountID, MonTheThaoID),
    CONSTRAINT FK_MTTYT_Account FOREIGN KEY (AccountID)    REFERENCES Accounts(AccountID) ON DELETE CASCADE,
    CONSTRAINT FK_MTTYT_Mon     FOREIGN KEY (MonTheThaoID) REFERENCES MonTheThao(MonTheThaoID) ON DELETE CASCADE
);

-- =====================================================================
-- 5. CẤU HÌNH SÂN & TỐI ƯU CƠ CHẾ GIỜ LÊN ĐÈN
-- =====================================================================

CREATE TABLE LoaiSan (
    LoaiSanID        INT PRIMARY KEY IDENTITY(1,1),
    MonTheThaoID     INT           NOT NULL,
    TenLoai          NVARCHAR(50)  NOT NULL,          
    GiaKhongDen      DECIMAL(18,2) NOT NULL, 
    GiaCoDen         DECIMAL(18,2) NOT NULL, 
    
    -- [V4 CẬP NHẬT GIỜ LÊN ĐÈN]: Chuyển từ bảng 'CoSo' về bảng 'LoaiSan' 
    -- Lý do: Sân Pickleball ngoài trời cần lên đèn lúc 17:30, nhưng sân Cầu lông trong nhà bật đèn 100% full ca từ 06:00 sáng.
    GioBatDauLenDen  TIME          NOT NULL DEFAULT '17:30:00', 
    
    CONSTRAINT FK_LoaiSan_Mon FOREIGN KEY (MonTheThaoID) REFERENCES MonTheThao(MonTheThaoID)
);

CREATE TABLE San (
    SanID      INT PRIMARY KEY IDENTITY(1,1),
    TenSan     NVARCHAR(50)  NOT NULL,                
    LoaiSanID  INT,
    CoSoID     INT           NOT NULL,
    TrangThai  NVARCHAR(50)  DEFAULT N'Sẵn sàng',
    MoTa       NVARCHAR(MAX) NULL,
    HinhAnh    NVARCHAR(500) NULL,                    
    CONSTRAINT FK_San_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES LoaiSan(LoaiSanID),
    CONSTRAINT FK_San_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 6. KHO HÀNG, DỊCH VỤ & LỊCH ĐẶT SÂN
-- =====================================================================

CREATE TABLE DanhMucSanPham (
    DanhMucID  INT PRIMARY KEY IDENTITY(1,1),
    TenDanhMuc NVARCHAR(100) NOT NULL                 
);

CREATE TABLE SanPham_DichVu (
    SanPhamID    INT PRIMARY KEY IDENTITY(1,1),
    DanhMucID    INT           NOT NULL,
    CoSoID       INT           NOT NULL,
    TenSanPham   NVARCHAR(100) NOT NULL,
    DonGia       DECIMAL(18,2) NOT NULL, 
    DonViTinh    NVARCHAR(20),                        
    SoLuongTon   INT           DEFAULT 0,
    TrangThai    NVARCHAR(50)  DEFAULT N'Đang kinh doanh',
    CONSTRAINT FK_SP_DanhMuc FOREIGN KEY (DanhMucID) REFERENCES DanhMucSanPham(DanhMucID),
    CONSTRAINT FK_SP_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

CREATE TABLE LichDatSan (
    DatSanID        INT PRIMARY KEY IDENTITY(1,1),
    AccountID       INT,
    SanID           INT,
    NgayDat         DATE          NOT NULL,
    GioBatDau       TIME          NOT NULL,
    GioKetThuc      TIME          NOT NULL,
    ApDungGiaCoDen  BIT           DEFAULT 0,          -- 0: Không Đèn | 1: Có Đèn
    TongTienDuKien  DECIMAL(18,2),
    TrangThai       NVARCHAR(50)  DEFAULT N'Chờ xác nhận',
    GhiChu          NVARCHAR(255),
    NguonDatSan     NVARCHAR(50)  NULL,               
    CONSTRAINT FK_DatSan_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_DatSan_San     FOREIGN KEY (SanID)     REFERENCES San(SanID)
);

-- =====================================================================
-- 7. CÁC TÍNH NĂNG MỞ RỘNG (GẮN KÈO, RATING, ELO, CHAT, PARKING)
-- =====================================================================

CREATE TABLE GhepKeo (
    KeoID               INT PRIMARY KEY IDENTITY(1,1),
    DatSanID            INT,
    AccountID_NguoiTao  INT,
    MonTheThaoID        INT           NULL,
    MoTa                NVARCHAR(MAX),
    TrinhDo             NVARCHAR(50),
    TrangThai           NVARCHAR(50)  DEFAULT N'Đang tìm',
    CONSTRAINT FK_GhepKeo_DatSan  FOREIGN KEY (DatSanID)           REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_GhepKeo_Account FOREIGN KEY (AccountID_NguoiTao) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_GhepKeo_Mon     FOREIGN KEY (MonTheThaoID)        REFERENCES MonTheThao(MonTheThaoID)
);

CREATE TABLE ChiTietGhepKeo (
    ChiTietKeoID           INT PRIMARY KEY IDENTITY(1,1),
    KeoID                  INT,
    AccountID_NguoiThamGia INT,
    TrangThaiThamGia       NVARCHAR(50) DEFAULT N'Chờ duyệt',
    ViTriThamGia           NVARCHAR(50) NULL,
    CONSTRAINT FK_CTGK_Keo     FOREIGN KEY (KeoID)                  REFERENCES GhepKeo(KeoID),
    CONSTRAINT FK_CTGK_Account FOREIGN KEY (AccountID_NguoiThamGia) REFERENCES Accounts(AccountID)
);

CREATE TABLE DanhGia (
    DanhGiaID                INT PRIMARY KEY IDENTITY(1,1),
    DatSanID                 INT,
    AccountID_NguoiDanhGia   INT,
    AccountID_NguoiBiDanhGia INT  NULL,               
    SoSao                    INT  CHECK (SoSao BETWEEN 1 AND 5),
    BinhLuan                 NVARCHAR(MAX),
    NgayDanhGia              DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_DanhGia_DatSan         FOREIGN KEY (DatSanID)                 REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_DanhGia_NguoiDanhGia   FOREIGN KEY (AccountID_NguoiDanhGia)   REFERENCES Accounts(AccountID),
    CONSTRAINT FK_DanhGia_NguoiBiDanhGia FOREIGN KEY (AccountID_NguoiBiDanhGia) REFERENCES Accounts(AccountID)
);

CREATE TABLE LichSuELO (
    LichSuELOID  INT PRIMARY KEY IDENTITY(1,1),
    AccountID    INT           NOT NULL,
    DatSanID     INT           NULL,                  
    DiemTruoc    INT           NOT NULL,
    DiemSau      INT           NOT NULL,
    ThayDoi      INT           NOT NULL,              
    LyDo         NVARCHAR(255) NULL,                  
    ThoiGian     DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_LichSuELO_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_LichSuELO_DatSan  FOREIGN KEY (DatSanID)  REFERENCES LichDatSan(DatSanID)
);

CREATE TABLE NhatKyChat (
    NhatKyChatID INT PRIMARY KEY IDENTITY(1,1),
    AccountID    INT           NULL,                  
    Kenh         NVARCHAR(20)  NOT NULL,              
    TurnSo       INT           NOT NULL,              
    VaiTro       NVARCHAR(10)  NOT NULL,              
    NoiDung      NVARCHAR(MAX) NOT NULL,
    TrangThaiBot NVARCHAR(50)  NULL,                  
    ThoiGian     DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_Chat_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE TheGiuXe (
    TheID           INT PRIMARY KEY IDENTITY(1,1),
    CoSoID          INT           NOT NULL,
    MaSoThe         VARCHAR(20)   NOT NULL,
    LoaiXe          NVARCHAR(20),                         
    TrangThai       NVARCHAR(20)  DEFAULT N'Trống',
    SucChua         INT           NULL,                   
    GiaVeTheoLuot   DECIMAL(18,2) DEFAULT 0,
    CONSTRAINT FK_TheGiuXe_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

CREATE TABLE LichXeRaVao (
    LichXeID           INT PRIMARY KEY IDENTITY(1,1),
    TheID              INT,
    DatSanID           INT           NULL,
    BienSoXe           VARCHAR(20),
    KieuGuiXe          NVARCHAR(20)  NULL,             
    GioVao             DATETIME      DEFAULT GETDATE(),
    GioRa              DATETIME      NULL,
    PhiGuiXe           DECIMAL(18,2) DEFAULT 0,	
    AccountID_NhanVien INT          NULL,
    CONSTRAINT FK_Xe_The      FOREIGN KEY (TheID)              REFERENCES TheGiuXe(TheID),
    CONSTRAINT FK_Xe_DatSan   FOREIGN KEY (DatSanID)           REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_Xe_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 8. TÀI CHÍNH: HÓA ĐƠN, KHUYẾN MÃI, CHIA BILL, HOÀN TIỀN
-- =====================================================================

CREATE TABLE KhuyenMai (
    KhuyenMaiID  INT PRIMARY KEY IDENTITY(1,1),
    MaCode       VARCHAR(50)   UNIQUE NOT NULL,       
    MoTa         NVARCHAR(255),
    LoaiGiam     NVARCHAR(20)  NOT NULL,              
    GiaTriGiam   DECIMAL(18,2) NOT NULL,
    NgayBatDau   DATE          NOT NULL,
    NgayKetThuc  DATE          NOT NULL,
    SoLanToiDa   INT           NULL,                  
    SoLanDaDung  INT           DEFAULT 0,
    CoSoID       INT           NULL,                  
    TrangThai    NVARCHAR(20)  DEFAULT N'Hoạt động',
    CONSTRAINT FK_KM_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

CREATE TABLE HoaDon (
    HoaDonID               INT PRIMARY KEY IDENTITY(1,1),
    DatSanID               INT           NULL,
    AccountID_KhachHang    INT,
    AccountID_NhanVien     INT,
    NgayLap                DATETIME      DEFAULT GETDATE(),
    TongTienSan            DECIMAL(18,2) DEFAULT 0,
    TongTienDichVu         DECIMAL(18,2) DEFAULT 0,
    PhiGuiXe               DECIMAL(18,2) DEFAULT 0,
    KhuyenMaiID            INT           NULL,        
    GiamGia                DECIMAL(18,2) DEFAULT 0,
    TongThanhToan          DECIMAL(18,2),
    PhuongThucThanhToan    NVARCHAR(50),              
    TrangThaiThanhToan     NVARCHAR(50),              
    CONSTRAINT FK_HD_DatSan    FOREIGN KEY (DatSanID)            REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_HD_Khach     FOREIGN KEY (AccountID_KhachHang) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_HD_NhanVien  FOREIGN KEY (AccountID_NhanVien)  REFERENCES Accounts(AccountID),
    CONSTRAINT FK_HD_KhuyenMai FOREIGN KEY (KhuyenMaiID)         REFERENCES KhuyenMai(KhuyenMaiID)
);

CREATE TABLE ChiTietHoaDon (
    ChiTietID               INT PRIMARY KEY IDENTITY(1,1),
    HoaDonID                INT,
    SanPhamID               INT,
    SoLuong                 INT           NOT NULL,
    DonGiaTaiThoiDiemBan    DECIMAL(18,2),
    ThanhTien               DECIMAL(18,2),
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (HoaDonID)  REFERENCES HoaDon(HoaDonID),
    CONSTRAINT FK_CTHD_SP     FOREIGN KEY (SanPhamID) REFERENCES SanPham_DichVu(SanPhamID)
);

CREATE TABLE ChiaHoaDon (
    ChiaHoaDonID  INT PRIMARY KEY IDENTITY(1,1),
    HoaDonID      INT           NOT NULL,
    AccountID     INT           NOT NULL,             
    SoTienPhanBo  DECIMAL(18,2) NOT NULL,
    DaTra         BIT           DEFAULT 0,            
    ThoiGianTra   DATETIME      NULL,
    GhiChu        NVARCHAR(255) NULL,
    CONSTRAINT FK_Chia_HoaDon  FOREIGN KEY (HoaDonID)  REFERENCES HoaDon(HoaDonID),
    CONSTRAINT FK_Chia_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE MaQR (
    MaQRID       INT PRIMARY KEY IDENTITY(1,1),
    ChiaHoaDonID INT           NOT NULL,
    NoiDungQR    NVARCHAR(500) NOT NULL,              
    NgayTao      DATETIME      DEFAULT GETDATE(),
    NgayHetHan   DATETIME      NULL,                  
    DaQuet       BIT           DEFAULT 0,             
    CONSTRAINT FK_QR_Chia FOREIGN KEY (ChiaHoaDonID) REFERENCES ChiaHoaDon(ChiaHoaDonID)
);

-- =====================================================================
-- 9. HỆ THỐNG SOS, VẬN HÀNH NHÂN SỰ & HOÀN TÁC
-- =====================================================================

CREATE TABLE YeuCauSOS (
    YeuCauSOSID     INT PRIMARY KEY IDENTITY(1,1),
    AccountID_Tao   INT           NOT NULL,
    DatSanID        INT           NULL,               
    MonTheThaoID    INT           NULL,
    SoNguoiCanTuyen INT           NOT NULL,
    ViTriCanTuyen   NVARCHAR(100) NULL,               
    GhiChu          NVARCHAR(MAX) NULL,
    TrangThai       NVARCHAR(50)  DEFAULT N'Đang tuyển',
    ThoiGianTao     DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_SOS_Account FOREIGN KEY (AccountID_Tao) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_SOS_DatSan  FOREIGN KEY (DatSanID)      REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_SOS_Mon     FOREIGN KEY (MonTheThaoID)  REFERENCES MonTheThao(MonTheThaoID)
);

CREATE TABLE NhatKySOSGui (
    NhatKySOSGuiID  INT PRIMARY KEY IDENTITY(1,1),
    YeuCauSOSID     INT           NOT NULL,
    AccountID_NhanGui INT         NOT NULL,           
    ThoiGianGui     DATETIME      DEFAULT GETDATE(),
    DaXem           BIT           DEFAULT 0,
    PhanHoi         NVARCHAR(50)  NULL,               
    CONSTRAINT FK_SOSGui_YeuCau  FOREIGN KEY (YeuCauSOSID)      REFERENCES YeuCauSOS(YeuCauSOSID),
    CONSTRAINT FK_SOSGui_Account FOREIGN KEY (AccountID_NhanGui) REFERENCES Accounts(AccountID)
);

CREATE TABLE ThongBao (
    ThongBaoID   INT PRIMARY KEY IDENTITY(1,1),
    AccountID    INT           NOT NULL,              
    TieuDe       NVARCHAR(200) NOT NULL,
    NoiDung      NVARCHAR(MAX),
    LoaiThongBao NVARCHAR(50)  NULL,                  
    DaDoc        BIT           DEFAULT 0,
    ThoiGianGui  DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_TB_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE CaLamViec (
    CaLamViecID     INT PRIMARY KEY IDENTITY(1,1),
    AccountID       INT           NOT NULL,           
    CoSoID          INT           NOT NULL,
    NgayLam         DATE          NOT NULL,
    GioBatDau       TIME          NOT NULL,
    GioKetThuc      TIME          NOT NULL,
    GhiChu          NVARCHAR(255) NULL,
    CONSTRAINT FK_Ca_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_Ca_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

CREATE TABLE HoanTien (
    HoanTienID      INT PRIMARY KEY IDENTITY(1,1),
    HoaDonID        INT           NOT NULL,
    AccountID       INT           NOT NULL,           
    SoTienHoan      DECIMAL(18,2) NOT NULL,
    LyDo            NVARCHAR(255) NULL,               
    TrangThai       NVARCHAR(50)  DEFAULT N'Chờ xử lý',
    ThoiGianYeuCau  DATETIME      DEFAULT GETDATE(),
    ThoiGianHoan    DATETIME      NULL,
    CONSTRAINT FK_HoanTien_HoaDon   FOREIGN KEY (HoaDonID)  REFERENCES HoaDon(HoaDonID),
    CONSTRAINT FK_HoanTien_Account  FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
GO

-- =====================================================================
-- 10. DỮ LIỆU MẪU ĐẶC TRƯNG (MỚI)
-- =====================================================================

INSERT INTO Roles (RoleName) VALUES (N'Admin'), (N'Staff'), (N'Customer');

INSERT INTO CoSo (TenCoSo, DiaChi, SoDienThoai, GioMoCua, GioDongCua, LoaiHinhKinhDoanh, SoLuongSanDuKien)
VALUES
    (N'CNH Sport Vũng Tàu',  N'123 Lê Lợi, Vũng Tàu',     '0909000001', '06:00', '23:00', N'Phức hợp thể thao ngoài trời & trong nhà', 15),
    (N'CNH Sport Bà Rịa',    N'456 Phạm Văn Đồng, Bà Rịa', '0909000002', '06:00', '22:30', N'Chuyên biệt Cầu lông & Pickleball', 10);

INSERT INTO MonTheThao (TenMon) VALUES (N'Bóng đá'), (N'Cầu lông'), (N'Pickleball'), (N'Tennis');

-- Data mẫu kiểm thử logic Giờ lên đèn riêng biệt cho từng loại hình sân:
INSERT INTO LoaiSan (MonTheThaoID, TenLoai, GiaKhongDen, GiaCoDen, GioBatDauLenDen)
VALUES 
    (1, N'Sân bóng đá 5 người', 150000, 200000, '17:30:00'), -- Ngoài trời: 17:30 bắt đầu tính giá đèn
    (3, N'Sân Pickleball chuẩn', 80000, 120000, '17:00:00'),  -- Ngoài trời: 17:00 tính giá đèn
    (2, N'Sân Cầu lông thảm PVC', 60000, 60000, '06:00:00');  -- Trong nhà: Bật đèn full-time từ lúc mở cửa nên giá cố định

-- Tạo tài khoản Admin mặc định
INSERT INTO Accounts (Username, Password, FullName, PhoneNumber, RoleID, CoSoID)
VALUES ('admin', '$2b$12$PLACEHOLDER_HASH_REPLACE_THIS', N'Quản trị viên', '0909999999', 1, NULL);

GO
PRINT N'✅ Khởi tạo cấu trúc Database QuanLiSport V4 thành công!';
GO