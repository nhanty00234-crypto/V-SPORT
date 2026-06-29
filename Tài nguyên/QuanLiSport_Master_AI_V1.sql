-- ====================================================================================
-- DỰ ÁN: HỆ SINH THÁI QUẢN LÝ CHUỖI THỂ THAO (QUANLISPORT)
-- TÍCH HỢP: ĐA CƠ SỞ, ĐA MÔN THỂ THAO, AI MATCHMAKING & AI BOOKING
-- NGÀY TẠO: MAY 2026
-- ====================================================================================

-- TẠO DATABASE (Nếu chưa có)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLiSport')
BEGIN
    CREATE DATABASE QuanLiSport;
END
GO

USE QuanLiSport;
GO

-- =====================================================================
-- 1. XÓA BẢNG CŨ CHỐNG LỖI CONFLICT (Xóa từ bảng con đến bảng cha)
-- =====================================================================
IF OBJECT_ID('ChiTietHoaDon', 'U') IS NOT NULL DROP TABLE ChiTietHoaDon;
IF OBJECT_ID('HoaDon', 'U') IS NOT NULL DROP TABLE HoaDon;
IF OBJECT_ID('LichXeRaVao', 'U') IS NOT NULL DROP TABLE LichXeRaVao;
IF OBJECT_ID('TheGiuXe', 'U') IS NOT NULL DROP TABLE TheGiuXe;
IF OBJECT_ID('DanhGia', 'U') IS NOT NULL DROP TABLE DanhGia;
IF OBJECT_ID('ChiTietGhepKeo', 'U') IS NOT NULL DROP TABLE ChiTietGhepKeo;
IF OBJECT_ID('GhepKeo', 'U') IS NOT NULL DROP TABLE GhepKeo;
IF OBJECT_ID('LichDatSan', 'U') IS NOT NULL DROP TABLE LichDatSan;
IF OBJECT_ID('SanPham_DichVu', 'U') IS NOT NULL DROP TABLE SanPham_DichVu;
IF OBJECT_ID('DanhMucSanPham', 'U') IS NOT NULL DROP TABLE DanhMucSanPham;
IF OBJECT_ID('San', 'U') IS NOT NULL DROP TABLE San;
IF OBJECT_ID('KhungGioGia', 'U') IS NOT NULL DROP TABLE KhungGioGia;
IF OBJECT_ID('LoaiSan', 'U') IS NOT NULL DROP TABLE LoaiSan;
IF OBJECT_ID('MonTheThao', 'U') IS NOT NULL DROP TABLE MonTheThao;
IF OBJECT_ID('Accounts', 'U') IS NOT NULL DROP TABLE Accounts;
IF OBJECT_ID('Roles', 'U') IS NOT NULL DROP TABLE Roles;
IF OBJECT_ID('CoSo', 'U') IS NOT NULL DROP TABLE CoSo;
GO

-- =====================================================================
-- 2. HỆ THỐNG LÕI: CƠ SỞ & NGƯỜI DÙNG
-- =====================================================================
CREATE TABLE CoSo (
    CoSoID INT PRIMARY KEY IDENTITY(1,1),
    TenCoSo NVARCHAR(100) NOT NULL, -- VD: CNH Sport Vũng Tàu, CNH Sport Bà Rịa
    DiaChi NVARCHAR(255),
    SoDienThoai VARCHAR(15),
    TrangThai NVARCHAR(50) DEFAULT N'Hoạt động'
);

CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL -- VD: Admin, Staff, Customer
);

CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    PhoneNumber VARCHAR(15),
    Email VARCHAR(100),
    RoleID INT,
    CoSoID INT NULL, -- NULL: Khách hàng/Admin tổng | CÓ ID: Staff của cơ sở đó
    
    -- [TRƯỜNG DỮ LIỆU TÍCH HỢP AI AGENT]
    ZaloID VARCHAR(100) NULL,             -- AI Booking: Chatbot Zalo
    MessengerID VARCHAR(100) NULL,        -- AI Booking: Chatbot Messenger
    DiemUyTin INT DEFAULT 100,            -- AI Matchmaking: Uy tín (Trừ nếu bùng kèo)
    DiemTrinhDo INT DEFAULT 1000,         -- AI Matchmaking: Hệ số ELO
    MaNganHang VARCHAR(20) NULL,          -- AI Kế toán: Mã ngân hàng (VD: VCB, MB)
    SoTaiKhoan VARCHAR(50) NULL,          -- AI Kế toán: STK để sinh mã QR chia tiền
    ViTriSoTruong NVARCHAR(50) NULL,      -- AI SOS: Vị trí đá (Thủ môn, Hậu vệ...)
    NhanThongBaoSOS BIT DEFAULT 1,        -- AI SOS: 1 (Bật), 0 (Tắt)
    
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Acc_Role FOREIGN KEY (RoleID) REFERENCES Roles(RoleID),
    CONSTRAINT FK_Acc_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 3. HỆ THỐNG SÂN BÃI ĐA MÔN THỂ THAO
-- =====================================================================
CREATE TABLE MonTheThao (
    MonTheThaoID INT PRIMARY KEY IDENTITY(1,1),
    TenMon NVARCHAR(50) NOT NULL -- VD: Bóng đá, Cầu lông, Pickleball, Tennis
);

CREATE TABLE LoaiSan (
    LoaiSanID INT PRIMARY KEY IDENTITY(1,1),
    MonTheThaoID INT NOT NULL,
    TenLoai NVARCHAR(50) NOT NULL,       -- VD: Sân 5 người, Sân chuẩn Pickleball
    GiaGocTheoGio DECIMAL(18, 2) NOT NULL,
    CONSTRAINT FK_LoaiSan_Mon FOREIGN KEY (MonTheThaoID) REFERENCES MonTheThao(MonTheThaoID)
);

CREATE TABLE KhungGioGia (
    KhungGioID INT PRIMARY KEY IDENTITY(1,1),
    LoaiSanID INT,
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    NgayTrongTuan NVARCHAR(20),          -- VD: 'T2-T6', 'T7-CN', 'All'
    GiaApDung DECIMAL(18, 2) NOT NULL,   -- Giá theo giờ cao điểm/thấp điểm
    CONSTRAINT FK_KhungGio_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES LoaiSan(LoaiSanID)
);

CREATE TABLE San (
    SanID INT PRIMARY KEY IDENTITY(1,1),
    TenSan NVARCHAR(50) NOT NULL,        -- VD: Sân A1, Sân B2
    LoaiSanID INT,
    CoSoID INT NOT NULL,                 -- Sân này thuộc cơ sở nào
    TrangThai NVARCHAR(50) DEFAULT N'Sẵn sàng',
    CONSTRAINT FK_San_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES LoaiSan(LoaiSanID),
    CONSTRAINT FK_San_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 4. HỆ THỐNG KHO HÀNG & DỊCH VỤ (NƯỚC, ĐỒ THUÊ, PHỤ KIỆN)
-- =====================================================================
CREATE TABLE DanhMucSanPham (
    DanhMucID INT PRIMARY KEY IDENTITY(1,1),
    TenDanhMuc NVARCHAR(100) NOT NULL    -- VD: Nước giải khát, Cho thuê thiết bị, Phụ kiện
);

CREATE TABLE SanPham_DichVu (
    SanPhamID INT PRIMARY KEY IDENTITY(1,1),
    DanhMucID INT NOT NULL,
    CoSoID INT NOT NULL,                 -- Tồn kho tại cơ sở nào
    TenSanPham NVARCHAR(100) NOT NULL,   -- VD: Nước khoáng Lavie, Thuê vợt Pickleball
    DonGia DECIMAL(18, 2) NOT NULL,
    DonViTinh NVARCHAR(20),              -- VD: Chai, Cái, Giờ, Đôi
    SoLuongTon INT DEFAULT 0,
    TrangThai NVARCHAR(50) DEFAULT N'Đang kinh doanh',
    CONSTRAINT FK_SP_DanhMuc FOREIGN KEY (DanhMucID) REFERENCES DanhMucSanPham(DanhMucID),
    CONSTRAINT FK_SP_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 5. LỊCH ĐẶT SÂN & AI MATCHMAKING
-- =====================================================================
CREATE TABLE LichDatSan (
    DatSanID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT,
    SanID INT,
    NgayDat DATE NOT NULL,
    GioBatDau TIME NOT NULL,
    GioKetThuc TIME NOT NULL,
    HeSoGia FLOAT DEFAULT 1.0,           -- AI Dynamic Pricing sẽ ghi đè hệ số vào đây
    TongTienDuKien DECIMAL(18, 2),
    TrangThai NVARCHAR(50) DEFAULT N'Chờ xác nhận', 
    GhiChu NVARCHAR(255),
    CONSTRAINT FK_DatSan_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_DatSan_San FOREIGN KEY (SanID) REFERENCES San(SanID)
);

CREATE TABLE GhepKeo (
    KeoID INT PRIMARY KEY IDENTITY(1,1),
    DatSanID INT,
    AccountID_NguoiTao INT,
    MoTa NVARCHAR(MAX),
    TrinhDo NVARCHAR(50), 
    SoNguoiThieu INT,
    TrangThai NVARCHAR(50) DEFAULT N'Đang tìm', 
    CONSTRAINT FK_GhepKeo_DatSan FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_GhepKeo_Account FOREIGN KEY (AccountID_NguoiTao) REFERENCES Accounts(AccountID)
);

CREATE TABLE ChiTietGhepKeo (
    ChiTietKeoID INT PRIMARY KEY IDENTITY(1,1),
    KeoID INT,
    AccountID_NguoiThamGia INT,
    TrangThaiThamGia NVARCHAR(50) DEFAULT N'Chờ duyệt', 
    CONSTRAINT FK_CTGK_Keo FOREIGN KEY (KeoID) REFERENCES GhepKeo(KeoID),
    CONSTRAINT FK_CTGK_Account FOREIGN KEY (AccountID_NguoiThamGia) REFERENCES Accounts(AccountID)
);

CREATE TABLE DanhGia (
    DanhGiaID INT PRIMARY KEY IDENTITY(1,1),
    DatSanID INT,
    AccountID_NguoiDanhGia INT,
    AccountID_NguoiBiDanhGia INT NULL,   -- Đánh giá đối thủ/đồng đội (NULL nếu chỉ đánh giá sân)
    SoSao INT CHECK (SoSao BETWEEN 1 AND 5),
    BinhLuan NVARCHAR(MAX),
    NgayDanhGia DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_DanhGia_DatSan FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_DanhGia_NguoiDanhGia FOREIGN KEY (AccountID_NguoiDanhGia) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_DanhGia_NguoiBiDanhGia FOREIGN KEY (AccountID_NguoiBiDanhGia) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 6. HỆ THỐNG BÃI XE THÔNG MINH
-- =====================================================================
CREATE TABLE TheGiuXe (
    TheID INT PRIMARY KEY IDENTITY(1,1),
    CoSoID INT NOT NULL,
    MaSoThe VARCHAR(20) NOT NULL,
    LoaiXe NVARCHAR(20),
    TrangThai NVARCHAR(20) DEFAULT N'Trống',
    CONSTRAINT FK_TheGiuXe_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

CREATE TABLE LichXeRaVao (
    LichXeID INT PRIMARY KEY IDENTITY(1,1),
    TheID INT,
    BienSoXe VARCHAR(20),
    GioVao DATETIME DEFAULT GETDATE(),
    GioRa DATETIME,
    PhiGuiXe DECIMAL(18, 2) DEFAULT 0,
    AccountID_NhanVien INT,
    CONSTRAINT FK_Xe_The FOREIGN KEY (TheID) REFERENCES TheGiuXe(TheID),
    CONSTRAINT FK_Xe_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 7. HỆ THỐNG HÓA ĐƠN & THANH TOÁN (BILLING)
-- =====================================================================
CREATE TABLE HoaDon (
    HoaDonID INT PRIMARY KEY IDENTITY(1,1),
    DatSanID INT NULL, 
    AccountID_KhachHang INT,
    AccountID_NhanVien INT,
    NgayLap DATETIME DEFAULT GETDATE(),
    TongTienSan DECIMAL(18, 2) DEFAULT 0,
    TongTienDichVu DECIMAL(18, 2) DEFAULT 0,
    GiamGia DECIMAL(18, 2) DEFAULT 0,
    TongThanhToan DECIMAL(18, 2),
    PhuongThucThanhToan NVARCHAR(50), 
    TrangThaiThanhToan NVARCHAR(50), 
    CONSTRAINT FK_HD_DatSan FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_HD_Khach FOREIGN KEY (AccountID_KhachHang) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_HD_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES Accounts(AccountID)
);

CREATE TABLE ChiTietHoaDon (
    ChiTietID INT PRIMARY KEY IDENTITY(1,1),
    HoaDonID INT,
    SanPhamID INT,
    SoLuong INT NOT NULL,
    DonGiaTaiThoiDiemBan DECIMAL(18, 2),
    ThanhTien DECIMAL(18, 2),
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (HoaDonID) REFERENCES HoaDon(HoaDonID),
    CONSTRAINT FK_CTHD_SP FOREIGN KEY (SanPhamID) REFERENCES SanPham_DichVu(SanPhamID)
);
GO