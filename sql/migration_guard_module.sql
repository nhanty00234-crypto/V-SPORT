-- Migration: GUARD Module (Bảo vệ)
-- Tạo bảng SuCo để bảo vệ báo cáo sự cố
-- Điểm danh ca dùng lại cột TrangThai trong CaLamViec (CheckedIn / CheckedOut)
-- + thêm 2 cột GioVaoThuc, GioRaThuc vào CaLamViec

ALTER TABLE CaLamViec
    ADD COLUMN IF NOT EXISTS GioVaoThuc DATETIME NULL,
    ADD COLUMN IF NOT EXISTS GioRaThuc  DATETIME NULL;

CREATE TABLE IF NOT EXISTS SuCo (
    SuCoID        INT AUTO_INCREMENT PRIMARY KEY,
    CoSoID        INT NOT NULL,
    SanID         INT NULL,
    BaoVeID       INT NOT NULL,
    LoaiSuCo      ENUM('VI_PHAM_NOI_QUY','HU_HONG_THIET_BI','SU_CO_AN_NINH','KHAC') NOT NULL,
    MucDo         ENUM('THAP','TRUNG_BINH','CAO') NOT NULL DEFAULT 'THAP',
    MoTa          TEXT NOT NULL,
    AnhUrl        VARCHAR(500) NULL,
    TrangThai     ENUM('CHO_XU_LY','DANG_XU_LY','DA_XONG') NOT NULL DEFAULT 'CHO_XU_LY',
    GhiChuXuLy   TEXT NULL,
    ThoiGianTao   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ThoiGianXuLy  DATETIME NULL,
    XuLyBoi       INT NULL,
    CONSTRAINT fk_suco_coso   FOREIGN KEY (CoSoID)  REFERENCES CoSo(CoSoID),
    CONSTRAINT fk_suco_baove  FOREIGN KEY (BaoVeID) REFERENCES Accounts(AccountID),
    INDEX idx_suco_coso_ngay (CoSoID, ThoiGianTao),
    INDEX idx_suco_baove (BaoVeID),
    INDEX idx_suco_trangthai (TrangThai)
);
