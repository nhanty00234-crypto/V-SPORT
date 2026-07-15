-- Migration: Luồng chuyển khoản ngân hàng cho modal "Thanh toán & Dịch vụ" (staff checkout)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Áp dụng cho: V-SPORT QuanLiSport_V4 trở lên

USE QuanLiSport;
GO

-- 1. Bảng cấu hình tài khoản ngân hàng nhận tiền theo từng cơ sở (CoSo)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'CoSoNganHang')
BEGIN
    CREATE TABLE CoSoNganHang (
        CoSoID          INT PRIMARY KEY,
        BankName        NVARCHAR(100) NOT NULL,
        BankShortCode   VARCHAR(20)   NOT NULL,  -- mã ngân hàng dùng cho VietQR quick-link, vd 'MBBank'
        AccountName     NVARCHAR(100) NOT NULL,
        AccountNumber   VARCHAR(50)   NOT NULL,
        UpdatedAt       DATETIME2     NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_CoSoNganHang_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
    );
    PRINT N'Đã tạo bảng CoSoNganHang.';
END
ELSE
    PRINT N'Bảng CoSoNganHang đã tồn tại, bỏ qua.';
GO

-- 2. Nội dung chuyển khoản (payment reference) gắn với từng hóa đơn - tạo 1 lần, tái sử dụng khi mở lại modal
IF NOT EXISTS (
    SELECT 1 FROM sys.columns
    WHERE object_id = OBJECT_ID(N'HoaDon') AND name = N'PaymentReference'
)
BEGIN
    ALTER TABLE HoaDon
    ADD PaymentReference NVARCHAR(50) NULL;
    PRINT N'Đã thêm cột PaymentReference vào HoaDon.';
END
ELSE
    PRINT N'Cột PaymentReference đã tồn tại, bỏ qua.';
GO

-- 3. Seed tài khoản ngân hàng PLACEHOLDER cho các cơ sở chưa có cấu hình, để luồng chuyển khoản
--    test được end-to-end ngay. ĐÂY LÀ DỮ LIỆU GIẢ - PHẢI THAY BẰNG TÀI KHOẢN THẬT TRƯỚC KHI GO-LIVE.
INSERT INTO CoSoNganHang (CoSoID, BankName, BankShortCode, AccountName, AccountNumber)
SELECT CoSoID, N'MB Bank', 'MBBank', N'V-SPORT', '0909123456' -- PLACEHOLDER: thay bằng tài khoản thật trước khi go-live
FROM CoSo
WHERE CoSoID NOT IN (SELECT CoSoID FROM CoSoNganHang);
PRINT N'Đã seed tài khoản ngân hàng PLACEHOLDER cho ' + CAST(@@ROWCOUNT AS NVARCHAR) + N' cơ sở (nhớ thay bằng tài khoản thật).';
GO
