-- ====================================================================================
-- DỰ ÁN: HỆ SINH THÁI QUẢN LÝ CHUỖI THỂ THAO (QUANLISPORT)
-- TÍCH HỢP: ĐA CƠ SỞ, ĐA MÔN THỂ THAO, AI MATCHMAKING & AI BOOKING
-- PHIÊN BẢN: V2 - BỔ SUNG CỘT/BẢNG THEO PHÂN TÍCH USE CASE + BẢO MẬT
-- NGÀY CẬP NHẬT: MAY 2026
-- ====================================================================================
-- BẢO MẬT MẬT KHẨU:
--   Cột Password lưu chuỗi HASH (bcrypt hoặc Argon2) do ứng dụng tính toán trước khi INSERT.
--   TUYỆT ĐỐI không lưu mật khẩu dạng plaintext.
--   Cột PasswordSalt dùng khi ứng dụng tự quản lý salt (không cần nếu dùng bcrypt vì bcrypt tự nhúng salt).
--   Ứng dụng cần kiểm tra FailedLoginCount >= 5 → khóa tài khoản tạm thời.
-- ====================================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'QuanLiSport')
BEGIN
    CREATE DATABASE QuanLiSport;
END
GO

USE QuanLiSport;
GO

-- =====================================================================
-- 1. XÓA BẢNG CŨ (từ con → cha) TRÁNH CONFLICT
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
IF OBJECT_ID('KhungGioGia',         'U') IS NOT NULL DROP TABLE KhungGioGia;
IF OBJECT_ID('LoaiSan',             'U') IS NOT NULL DROP TABLE LoaiSan;
IF OBJECT_ID('MonTheThao',          'U') IS NOT NULL DROP TABLE MonTheThao;
IF OBJECT_ID('Accounts',            'U') IS NOT NULL DROP TABLE Accounts;
IF OBJECT_ID('Roles',               'U') IS NOT NULL DROP TABLE Roles;
IF OBJECT_ID('CoSo',                'U') IS NOT NULL DROP TABLE CoSo;
GO

-- =====================================================================
-- 2. HỆ THỐNG LÕI: CƠ SỞ & NGƯỜI DÙNG
-- =====================================================================

CREATE TABLE CoSo (
    CoSoID       INT PRIMARY KEY IDENTITY(1,1),
    TenCoSo      NVARCHAR(100) NOT NULL,          -- VD: CNH Sport Vũng Tàu
    DiaChi       NVARCHAR(255),
    SoDienThoai  VARCHAR(15),
    TrangThai    NVARCHAR(50)  DEFAULT N'Hoạt động',
    -- [BỔ SUNG V2 - Hiển thị app & giờ hoạt động]
    GioMoCua     TIME          NULL,               -- VD: 06:00
    GioDongCua   TIME          NULL,               -- VD: 23:00
    HinhAnh      NVARCHAR(500) NULL,               -- URL ảnh đại diện cơ sở
    MoTa         NVARCHAR(MAX) NULL                -- Mô tả cơ sở (hiển thị trên app)
);

CREATE TABLE Roles (
    RoleID   INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL                 -- VD: Admin, Staff, Customer
);

CREATE TABLE Accounts (
    AccountID            INT PRIMARY KEY IDENTITY(1,1),
    Username             VARCHAR(50)   UNIQUE NOT NULL,

    -- [BẢO MẬT] Password lưu dạng HASH (bcrypt/Argon2), KHÔNG lưu plaintext
    -- Ứng dụng phải hash trước khi INSERT/UPDATE
    -- Độ dài 255 đủ cho bcrypt ($2b$12$... = 60 ký tự) hoặc Argon2 (~95 ký tự)
    Password             VARCHAR(255)  NOT NULL,
    PasswordSalt         VARCHAR(100)  NULL,        -- Dùng nếu tự quản lý salt; để NULL nếu dùng bcrypt
    FailedLoginCount     TINYINT       DEFAULT 0,   -- Đếm lần đăng nhập sai; khóa khi >= 5
    IsLocked             BIT           DEFAULT 0,   -- 1 = tài khoản bị khóa
    LastLogin            DATETIME      NULL,        -- Ghi nhận lần đăng nhập thành công gần nhất

    FullName             NVARCHAR(100),
    PhoneNumber          VARCHAR(15),
    Email                VARCHAR(100),
    RoleID               INT,
    CoSoID               INT NULL,                  -- NULL: Khách/Admin tổng | Có ID: Staff cơ sở

    -- [AI AGENT FIELDS]
    ZaloID               VARCHAR(100)  NULL,        -- AI Booking: Chatbot Zalo
    MessengerID          VARCHAR(100)  NULL,        -- AI Booking: Chatbot Messenger
    DiemUyTin            INT           DEFAULT 100, -- AI Matchmaking: Uy tín (trừ nếu bùng kèo)
    DiemTrinhDo          INT           DEFAULT 1000,-- AI Matchmaking: Hệ số ELO
    MaNganHang           VARCHAR(20)   NULL,        -- AI Kế toán: Mã ngân hàng (VCB, MB...)
    SoTaiKhoan           VARCHAR(50)   NULL,        -- AI Kế toán: STK để sinh mã QR chia tiền
    ViTriSoTruong        NVARCHAR(50)  NULL,        -- AI SOS: Vị trí sở trường (Thủ môn, Hậu vệ...)
    NhanThongBaoSOS      BIT           DEFAULT 1,   -- AI SOS: 1=Bật, 0=Tắt

    -- [BỔ SUNG V2 - Matchmaking theo độ tuổi & giới tính]
    NgaySinh             DATE          NULL,
    GioiTinh             NVARCHAR(10)  NULL,        -- Nam / Nữ / Khác

    CreatedAt            DATETIME      DEFAULT GETDATE(),

    CONSTRAINT FK_Acc_Role FOREIGN KEY (RoleID)  REFERENCES Roles(RoleID),
    CONSTRAINT FK_Acc_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 3. HỆ THỐNG SÂN BÃI ĐA MÔN THỂ THAO
-- =====================================================================

CREATE TABLE MonTheThao (
    MonTheThaoID INT PRIMARY KEY IDENTITY(1,1),
    TenMon       NVARCHAR(50) NOT NULL               -- Bóng đá, Cầu lông, Pickleball, Tennis
);

CREATE TABLE LoaiSan (
    LoaiSanID        INT PRIMARY KEY IDENTITY(1,1),
    MonTheThaoID     INT           NOT NULL,
    TenLoai          NVARCHAR(50)  NOT NULL,          -- VD: Sân 5 người, Sân chuẩn Pickleball
    GiaGocTheoGio    DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_LoaiSan_Mon FOREIGN KEY (MonTheThaoID) REFERENCES MonTheThao(MonTheThaoID)
);

CREATE TABLE KhungGioGia (
    KhungGioID   INT PRIMARY KEY IDENTITY(1,1),
    LoaiSanID    INT           NOT NULL,
    -- [BỔ SUNG V2] CoSoID cho phép cài giá riêng theo từng chi nhánh cùng loại sân
    CoSoID       INT           NULL,
    GioBatDau    TIME          NOT NULL,
    GioKetThuc   TIME          NOT NULL,
    NgayTrongTuan NVARCHAR(20) NULL,                  -- 'T2-T6', 'T7-CN', 'All'
    GiaApDung    DECIMAL(18,2) NOT NULL,
    CONSTRAINT FK_KhungGio_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES LoaiSan(LoaiSanID),
    CONSTRAINT FK_KhungGio_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

CREATE TABLE San (
    SanID      INT PRIMARY KEY IDENTITY(1,1),
    TenSan     NVARCHAR(50)  NOT NULL,                -- VD: Sân A1, Sân B2
    LoaiSanID  INT,
    CoSoID     INT           NOT NULL,
    TrangThai  NVARCHAR(50)  DEFAULT N'Sẵn sàng',
    -- [BỔ SUNG V2 - Hiển thị app]
    MoTa       NVARCHAR(MAX) NULL,
    HinhAnh    NVARCHAR(500) NULL,                    -- URL ảnh sân (hiển thị trên app)
    CONSTRAINT FK_San_LoaiSan FOREIGN KEY (LoaiSanID) REFERENCES LoaiSan(LoaiSanID),
    CONSTRAINT FK_San_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 4. KHO HÀNG & DỊCH VỤ
-- =====================================================================

CREATE TABLE DanhMucSanPham (
    DanhMucID  INT PRIMARY KEY IDENTITY(1,1),
    TenDanhMuc NVARCHAR(100) NOT NULL                 -- Nước giải khát, Cho thuê thiết bị...
);

CREATE TABLE SanPham_DichVu (
    SanPhamID    INT PRIMARY KEY IDENTITY(1,1),
    DanhMucID    INT           NOT NULL,
    CoSoID       INT           NOT NULL,
    TenSanPham   NVARCHAR(100) NOT NULL,
    DonGia       DECIMAL(18,2) NOT NULL,
    DonViTinh    NVARCHAR(20),                        -- Chai, Cái, Giờ, Đôi
    SoLuongTon   INT           DEFAULT 0,
    TrangThai    NVARCHAR(50)  DEFAULT N'Đang kinh doanh',
    CONSTRAINT FK_SP_DanhMuc FOREIGN KEY (DanhMucID) REFERENCES DanhMucSanPham(DanhMucID),
    CONSTRAINT FK_SP_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 5. LỊCH ĐẶT SÂN & AI MATCHMAKING
-- =====================================================================

CREATE TABLE LichDatSan (
    DatSanID        INT PRIMARY KEY IDENTITY(1,1),
    AccountID       INT,
    SanID           INT,
    NgayDat         DATE          NOT NULL,
    GioBatDau       TIME          NOT NULL,
    GioKetThuc      TIME          NOT NULL,
    HeSoGia         FLOAT         DEFAULT 1.0,        -- AI Dynamic Pricing ghi đè
    TongTienDuKien  DECIMAL(18,2),
    TrangThai       NVARCHAR(50)  DEFAULT N'Chờ xác nhận',
    GhiChu          NVARCHAR(255),
    -- [BỔ SUNG V2 - Phân tích kênh đặt sân]
    NguonDatSan     NVARCHAR(50)  NULL,               -- 'App', 'Zalo', 'Walk-in', 'Phone'
    CONSTRAINT FK_DatSan_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_DatSan_San     FOREIGN KEY (SanID)     REFERENCES San(SanID)
);

CREATE TABLE GhepTran (
    KeoID               INT PRIMARY KEY IDENTITY(1,1),
    DatSanID            INT,
    AccountID_NguoiTao  INT,
    -- [BỔ SUNG V2] Lọc kèo theo môn thể thao
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
    -- [BỔ SUNG V2] Vị trí trong trận (Thủ môn, Tiền đạo...)
    ViTriThamGia           NVARCHAR(50) NULL,
    CONSTRAINT FK_CTGK_Keo     FOREIGN KEY (KeoID)                  REFERENCES GhepKeo(KeoID),
    CONSTRAINT FK_CTGK_Account FOREIGN KEY (AccountID_NguoiThamGia) REFERENCES Accounts(AccountID)
);

CREATE TABLE DanhGia (
    DanhGiaID                INT PRIMARY KEY IDENTITY(1,1),
    DatSanID                 INT,
    AccountID_NguoiDanhGia   INT,
    AccountID_NguoiBiDanhGia INT  NULL,               -- NULL = chỉ đánh giá sân
    SoSao                    INT  CHECK (SoSao BETWEEN 1 AND 5),
    BinhLuan                 NVARCHAR(MAX),
    NgayDanhGia              DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_DanhGia_DatSan         FOREIGN KEY (DatSanID)                 REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_DanhGia_NguoiDanhGia   FOREIGN KEY (AccountID_NguoiDanhGia)   REFERENCES Accounts(AccountID),
    CONSTRAINT FK_DanhGia_NguoiBiDanhGia FOREIGN KEY (AccountID_NguoiBiDanhGia) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 6. LỊCH SỬ ELO (AI Matchmaking - theo dõi biến động điểm)
-- =====================================================================

CREATE TABLE LichSuELO (
    LichSuELOID  INT PRIMARY KEY IDENTITY(1,1),
    AccountID    INT           NOT NULL,
    DatSanID     INT           NULL,                  -- Trận đấu liên quan (nếu có)
    DiemTruoc    INT           NOT NULL,
    DiemSau      INT           NOT NULL,
    ThayDoi      INT           NOT NULL,              -- = DiemSau - DiemTruoc (âm hoặc dương)
    LyDo         NVARCHAR(255) NULL,                  -- VD: 'Thắng kèo', 'Thua kèo', 'Điều chỉnh'
    ThoiGian     DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_LichSuELO_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_LichSuELO_DatSan  FOREIGN KEY (DatSanID)  REFERENCES LichDatSan(DatSanID)
);

-- =====================================================================
-- 7. NHẬT KÝ CHAT CHATBOT (AI Booking Agent)
-- =====================================================================

CREATE TABLE NhatKyChat (
    NhatKyChatID INT PRIMARY KEY IDENTITY(1,1),
    AccountID    INT           NULL,                  -- NULL nếu khách chưa đăng nhập
    Kenh         NVARCHAR(20)  NOT NULL,              -- 'Zalo', 'Messenger', 'App'
    TurnSo       INT           NOT NULL,              -- Thứ tự lượt hội thoại
    VaiTro       NVARCHAR(10)  NOT NULL,              -- 'user' hoặc 'assistant'
    NoiDung      NVARCHAR(MAX) NOT NULL,
    TrangThaiBot NVARCHAR(50)  NULL,                  -- Trạng thái booking qua từng turn
    ThoiGian     DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_Chat_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 8. BÃI XE THÔNG MINH
-- =====================================================================

CREATE TABLE TheGiuXe (
    TheID       INT PRIMARY KEY IDENTITY(1,1),
    CoSoID      INT           NOT NULL,
    MaSoThe     VARCHAR(20)   NOT NULL,
    LoaiXe      NVARCHAR(20),                         -- Xe máy, Ô tô, Xe đạp
    TrangThai   NVARCHAR(20)  DEFAULT N'Trống',
    -- [BỔ SUNG V2]
    SucChua     INT           NULL,                   -- Tổng số chỗ tối đa (để biết bãi đầy chưa)
    CONSTRAINT FK_TheGiuXe_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

CREATE TABLE LichXeRaVao (
    LichXeID          INT PRIMARY KEY IDENTITY(1,1),
    TheID             INT,
    -- [BỔ SUNG V2] Liên kết với booking để biết xe này thuộc đặt sân nào
    DatSanID          INT           NULL,
    BienSoXe          VARCHAR(20),
    -- [BỔ SUNG V2] Phân loại để tính phí khác nhau
    KieuGuiXe         NVARCHAR(20)  NULL,             -- 'Xe máy', 'Ô tô'
    GioVao            DATETIME      DEFAULT GETDATE(),
    GioRa             DATETIME      NULL,
    PhiGuiXe          DECIMAL(18,2) DEFAULT 0,	
    AccountID_NhanVien INT          NULL,
    CONSTRAINT FK_Xe_The      FOREIGN KEY (TheID)              REFERENCES TheGiuXe(TheID),
    CONSTRAINT FK_Xe_DatSan   FOREIGN KEY (DatSanID)           REFERENCES LichDatSan(DatSanID),
    CONSTRAINT FK_Xe_NhanVien FOREIGN KEY (AccountID_NhanVien) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 9. HÓA ĐƠN & THANH TOÁN
-- =====================================================================

CREATE TABLE KhuyenMai (
    KhuyenMaiID  INT PRIMARY KEY IDENTITY(1,1),
    MaCode       VARCHAR(50)   UNIQUE NOT NULL,       -- Mã nhập vào VD: SUMMER20
    MoTa         NVARCHAR(255),
    LoaiGiam     NVARCHAR(20)  NOT NULL,              -- 'PhanTram' hoặc 'SoTien'
    GiaTriGiam   DECIMAL(18,2) NOT NULL,
    NgayBatDau   DATE          NOT NULL,
    NgayKetThuc  DATE          NOT NULL,
    SoLanToiDa   INT           NULL,                  -- NULL = không giới hạn
    SoLanDaDung  INT           DEFAULT 0,
    CoSoID       INT           NULL,                  -- NULL = áp dụng toàn chuỗi
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
    -- [BỔ SUNG V2] Phí xe riêng & mã khuyến mãi
    PhiGuiXe               DECIMAL(18,2) DEFAULT 0,
    KhuyenMaiID            INT           NULL,        -- FK đến bảng KhuyenMai
    GiamGia                DECIMAL(18,2) DEFAULT 0,
    TongThanhToan          DECIMAL(18,2),
    PhuongThucThanhToan    NVARCHAR(50),              -- 'Tiền mặt', 'QR', 'Chuyển khoản'
    TrangThaiThanhToan     NVARCHAR(50),              -- 'Chưa thanh toán', 'Đã thanh toán'
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

-- =====================================================================
-- 10. AI BILL SPLITTING - CHIA TIỀN & MÃ QR
-- =====================================================================

CREATE TABLE ChiaHoaDon (
    ChiaHoaDonID  INT PRIMARY KEY IDENTITY(1,1),
    HoaDonID      INT           NOT NULL,
    AccountID     INT           NOT NULL,             -- Người được phân bổ nợ
    SoTienPhanBo  DECIMAL(18,2) NOT NULL,
    DaTra         BIT           DEFAULT 0,            -- 0=Chưa trả, 1=Đã trả
    ThoiGianTra   DATETIME      NULL,
    GhiChu        NVARCHAR(255) NULL,
    CONSTRAINT FK_Chia_HoaDon  FOREIGN KEY (HoaDonID)  REFERENCES HoaDon(HoaDonID),
    CONSTRAINT FK_Chia_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE MaQR (
    MaQRID       INT PRIMARY KEY IDENTITY(1,1),
    ChiaHoaDonID INT           NOT NULL,
    NoiDungQR    NVARCHAR(500) NOT NULL,              -- Chuỗi dữ liệu QR (VietQR format)
    NgayTao      DATETIME      DEFAULT GETDATE(),
    NgayHetHan   DATETIME      NULL,                  -- QR có thể hết hạn
    DaQuet       BIT           DEFAULT 0,             -- 0=Chưa quét, 1=Đã thanh toán
    CONSTRAINT FK_QR_Chia FOREIGN KEY (ChiaHoaDonID) REFERENCES ChiaHoaDon(ChiaHoaDonID)
);

-- =====================================================================
-- 11. AI SOS AGENT - TUYỂN NGƯỜI KHẨN CẤP
-- =====================================================================

CREATE TABLE YeuCauSOS (
    YeuCauSOSID     INT PRIMARY KEY IDENTITY(1,1),
    AccountID_Tao   INT           NOT NULL,
    DatSanID        INT           NULL,               -- Trận cần tuyển thêm người
    MonTheThaoID    INT           NULL,
    SoNguoiCanTuyen INT           NOT NULL,
    ViTriCanTuyen   NVARCHAR(100) NULL,               -- 'Thủ môn', 'Hậu vệ'...
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
    AccountID_NhanGui INT         NOT NULL,           -- Người được gửi thông báo SOS
    ThoiGianGui     DATETIME      DEFAULT GETDATE(),
    DaXem           BIT           DEFAULT 0,
    PhanHoi         NVARCHAR(50)  NULL,               -- 'Đồng ý', 'Từ chối', NULL=Chưa phản hồi
    CONSTRAINT FK_SOSGui_YeuCau  FOREIGN KEY (YeuCauSOSID)      REFERENCES YeuCauSOS(YeuCauSOSID),
    CONSTRAINT FK_SOSGui_Account FOREIGN KEY (AccountID_NhanGui) REFERENCES Accounts(AccountID)
);

-- =====================================================================
-- 12. HỆ THỐNG THÔNG BÁO PUSH & CA LÀM VIỆC
-- =====================================================================

CREATE TABLE ThongBao (
    ThongBaoID   INT PRIMARY KEY IDENTITY(1,1),
    AccountID    INT           NOT NULL,              -- Người nhận
    TieuDe       NVARCHAR(200) NOT NULL,
    NoiDung      NVARCHAR(MAX),
    LoaiThongBao NVARCHAR(50)  NULL,                  -- 'SOS', 'Booking', 'ELO', 'KhuyenMai'
    DaDoc        BIT           DEFAULT 0,
    ThoiGianGui  DATETIME      DEFAULT GETDATE(),
    CONSTRAINT FK_TB_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);

CREATE TABLE CaLamViec (
    CaLamViecID     INT PRIMARY KEY IDENTITY(1,1),
    AccountID       INT           NOT NULL,           -- Nhân viên
    CoSoID          INT           NOT NULL,
    NgayLam         DATE          NOT NULL,
    GioBatDau       TIME          NOT NULL,
    GioKetThuc      TIME          NOT NULL,
    GhiChu          NVARCHAR(255) NULL,
    CONSTRAINT FK_Ca_Account FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID),
    CONSTRAINT FK_Ca_CoSo    FOREIGN KEY (CoSoID)    REFERENCES CoSo(CoSoID)
);

-- =====================================================================
-- 13. HOÀN TIỀN (Khi hủy đặt sân)
-- =====================================================================

CREATE TABLE HoanTien (
    HoanTienID      INT PRIMARY KEY IDENTITY(1,1),
    HoaDonID        INT           NOT NULL,
    AccountID       INT           NOT NULL,           -- Người được hoàn
    SoTienHoan      DECIMAL(18,2) NOT NULL,
    LyDo            NVARCHAR(255) NULL,               -- 'Hủy trước 24h', 'Lỗi hệ thống'...
    TrangThai       NVARCHAR(50)  DEFAULT N'Chờ xử lý',
    ThoiGianYeuCau  DATETIME      DEFAULT GETDATE(),
    ThoiGianHoan    DATETIME      NULL,
    CONSTRAINT FK_HoanTien_HoaDon   FOREIGN KEY (HoaDonID)  REFERENCES HoaDon(HoaDonID),
    CONSTRAINT FK_HoanTien_Account  FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
GO

-- =====================================================================
-- 14. DỮ LIỆU MẪU CƠ BẢN
-- =====================================================================

INSERT INTO Roles (RoleName) VALUES (N'Admin'), (N'Staff'), (N'Customer');

INSERT INTO CoSo (TenCoSo, DiaChi, SoDienThoai, GioMoCua, GioDongCua)
VALUES
    (N'CNH Sport Vũng Tàu',  N'123 Lê Lợi, Vũng Tàu',     '0909000001', '06:00', '23:00'),
    (N'CNH Sport Bà Rịa',    N'456 Phạm Văn Đồng, Bà Rịa', '0909000002', '06:00', '22:30');

INSERT INTO MonTheThao (TenMon) VALUES (N'Bóng đá'), (N'Cầu lông'), (N'Pickleball'), (N'Tennis');

-- Tài khoản Admin mẫu
-- LƯU Ý: Cột Password bên dưới là GIẢ LẬP. 
-- Trong thực tế, ứng dụng PHẢI hash 'Admin@2026' bằng bcrypt/Argon2 rồi mới INSERT.
INSERT INTO Accounts (Username, Password, FullName, PhoneNumber, RoleID, CoSoID)
VALUES ('admin', '$2b$12$PLACEHOLDER_HASH_REPLACE_THIS', N'Quản trị viên', '0909999999', 1, NULL);

GO

PRINT N'✅ QuanLiSport V2 khởi tạo thành công!';
PRINT N'⚠️  Nhắc nhở bảo mật: Hãy hash mật khẩu bằng bcrypt/Argon2 ở tầng ứng dụng trước khi lưu vào DB.';
GO
ALTER TABLE TheGiuXe
ADD GiaVeTheoLuot DECIMAL(18,2) DEFAULT 0;