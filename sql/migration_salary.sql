-- sql/migration_salary.sql
-- Module tính lương nhân viên. Idempotent: chạy lại nhiều lần không lỗi.

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CauHinhLuong')
BEGIN
  CREATE TABLE CauHinhLuong (
    CauHinhLuongID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID      INT NOT NULL REFERENCES Accounts(AccountID),
    CoSoID         INT NOT NULL REFERENCES CoSo(CoSoID),
    LuongCoBan     DECIMAL(18,0) NOT NULL DEFAULT 0,
    PhuCapMoiCa    DECIMAL(18,0) NOT NULL DEFAULT 0,
    HanMucUng      DECIMAL(18,0) NOT NULL DEFAULT 0,
    GhiChu         NVARCHAR(500) NULL,
    CreatedAt      DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt      DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_CauHinhLuong_Account_CoSo UNIQUE (AccountID, CoSoID)
  );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'KyLuong')
BEGIN
  CREATE TABLE KyLuong (
    KyLuongID     INT IDENTITY(1,1) PRIMARY KEY,
    CoSoID        INT NOT NULL REFERENCES CoSo(CoSoID),
    TenKy         NVARCHAR(100) NOT NULL,
    NgayBatDau    DATE NOT NULL,
    NgayKetThuc   DATE NOT NULL,
    NgayPhatLuong DATE NOT NULL,
    TrangThai     VARCHAR(20) NOT NULL DEFAULT 'Draft',  -- Draft | DangTinh | DaPhat
    CreatedBy     INT NOT NULL REFERENCES Accounts(AccountID),
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE()
  );
  CREATE INDEX IX_KyLuong_CoSo ON KyLuong(CoSoID, NgayBatDau DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'BangLuong')
BEGIN
  CREATE TABLE BangLuong (
    BangLuongID   INT IDENTITY(1,1) PRIMARY KEY,
    KyLuongID     INT NOT NULL REFERENCES KyLuong(KyLuongID),
    AccountID     INT NOT NULL REFERENCES Accounts(AccountID),
    LuongCoBan    DECIMAL(18,0) NOT NULL DEFAULT 0,
    TongPhuCap    DECIMAL(18,0) NOT NULL DEFAULT 0,
    TongKhauTru   DECIMAL(18,0) NOT NULL DEFAULT 0,
    TongLuongThuc DECIMAL(18,0) NOT NULL DEFAULT 0,
    SoCaLamViec   INT NOT NULL DEFAULT 0,
    TrangThai     VARCHAR(30) NOT NULL DEFAULT 'ChuaTinh',
    -- ChuaTinh | DaTinh | DaPhat | XacNhanDaChuyenKhoan
    GhiChu        NVARCHAR(500) NULL,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_BangLuong_Ky_Account UNIQUE (KyLuongID, AccountID)
  );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'YeuCauUngLuong')
BEGIN
  CREATE TABLE YeuCauUngLuong (
    YeuCauUngLuongID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID        INT NOT NULL REFERENCES Accounts(AccountID),
    CoSoID           INT NOT NULL REFERENCES CoSo(CoSoID),
    SoTienUng        DECIMAL(18,0) NOT NULL,
    LyDo             NVARCHAR(500) NULL,
    TrangThai        VARCHAR(20) NOT NULL DEFAULT 'ChoDuyet',
    -- ChoDuyet | DaDuyet | TuChoi | DaHuy
    GhiChuQuanLy     NVARCHAR(500) NULL,
    XuLyBy           INT NULL REFERENCES Accounts(AccountID),
    NgayXuLy         DATETIME NULL,
    CreatedAt        DATETIME NOT NULL DEFAULT GETDATE()
  );
  CREATE INDEX IX_YeuCauUngLuong_CoSo_TrangThai ON YeuCauUngLuong(CoSoID, TrangThai, CreatedAt DESC);
  CREATE INDEX IX_YeuCauUngLuong_Account ON YeuCauUngLuong(AccountID, CreatedAt DESC);
END;

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Accounts') AND name = 'QrImagePath')
BEGIN
  ALTER TABLE Accounts ADD QrImagePath NVARCHAR(500) NULL;
END;
