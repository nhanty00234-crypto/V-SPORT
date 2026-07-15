-- Migration: Bảng theo dõi vòng đời thanh toán PayOS cho luồng Checkout Manager/Staff
-- (KHÔNG dùng cho luồng đặt sân online của khách hàng - luồng đó vẫn dùng DatSanID làm orderCode
--  và credentials PayOS toàn cục qua biến môi trường, không đổi trong migration này.)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.

USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'PayOSPaymentAttempt')
BEGIN
    CREATE TABLE PayOSPaymentAttempt (
        AttemptID       BIGINT IDENTITY(1,1) PRIMARY KEY,
        HoaDonID        INT NOT NULL,
        DatSanID        INT NOT NULL,
        CoSoID          INT NOT NULL,
        OrderCode       BIGINT NOT NULL,
        PaymentLinkID   NVARCHAR(100) NULL,
        CheckoutUrl     NVARCHAR(1000) NULL,
        -- QrCode: PayOS chỉ trả chuỗi QR (payload VietQR) tại thời điểm TẠO link; API "get theo
        -- orderCode" (dùng khi tái sử dụng / polling) KHÔNG trả lại QR. Phải lưu lại ở đây để mở lại
        -- modal / tái sử dụng attempt PENDING không cần tạo link mới (mục VII của yêu cầu).
        QrCode          NVARCHAR(MAX) NULL,
        Status          NVARCHAR(30) NOT NULL,
        Amount          DECIMAL(18,2) NOT NULL,
        Description     NVARCHAR(100) NOT NULL,
        CreatedAt       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
        PaidAt          DATETIME2 NULL,
        CancelledAt     DATETIME2 NULL,
        LastCheckedAt   DATETIME2 NULL,
        FailureReason   NVARCHAR(500) NULL,
        CONSTRAINT FK_PayOSPaymentAttempt_HoaDon FOREIGN KEY (HoaDonID) REFERENCES HoaDon(HoaDonID),
        CONSTRAINT FK_PayOSPaymentAttempt_LichDatSan FOREIGN KEY (DatSanID) REFERENCES LichDatSan(DatSanID),
        CONSTRAINT FK_PayOSPaymentAttempt_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
    );
    PRINT N'Đã tạo bảng PayOSPaymentAttempt.';
END
ELSE
    PRINT N'Bảng PayOSPaymentAttempt đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_PayOSPaymentAttempt_OrderCode')
BEGIN
    CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OrderCode ON PayOSPaymentAttempt(OrderCode);
    PRINT N'Đã tạo UNIQUE INDEX UQ_PayOSPaymentAttempt_OrderCode.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PayOSPaymentAttempt_HoaDonID')
BEGIN
    CREATE INDEX IX_PayOSPaymentAttempt_HoaDonID ON PayOSPaymentAttempt(HoaDonID);
    PRINT N'Đã tạo INDEX IX_PayOSPaymentAttempt_HoaDonID.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_PayOSPaymentAttempt_PaymentLinkID')
BEGIN
    CREATE INDEX IX_PayOSPaymentAttempt_PaymentLinkID ON PayOSPaymentAttempt(PaymentLinkID);
    PRINT N'Đã tạo INDEX IX_PayOSPaymentAttempt_PaymentLinkID.';
END
GO

-- Chỉ cho phép TỐI ĐA một attempt đang "sống" (CREATING/PENDING) cho mỗi hóa đơn - chặn double-click
-- và hai nhân viên bấm gần như đồng thời tạo ra hai payment link cho cùng một HoaDonID ở tầng DB,
-- không chỉ dựa vào lock ứng dụng.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UQ_PayOSPaymentAttempt_OneActivePerInvoice')
BEGIN
    CREATE UNIQUE INDEX UQ_PayOSPaymentAttempt_OneActivePerInvoice
        ON PayOSPaymentAttempt(HoaDonID)
        WHERE Status IN (N'CREATING', N'PENDING');
    PRINT N'Đã tạo UNIQUE FILTERED INDEX UQ_PayOSPaymentAttempt_OneActivePerInvoice.';
END
GO
