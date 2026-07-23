-- Migration: Bảng QRRequest cho luồng QR-03A (gọi nhân viên / gọi món / yêu cầu dịch vụ tại sân)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.

USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'QRRequest')
BEGIN
    CREATE TABLE QRRequest (
        RequestID       INT IDENTITY(1,1) PRIMARY KEY,
        SanID           INT NOT NULL,
        CoSoID          INT NOT NULL,
        GuestToken      VARCHAR(64) NOT NULL,
        CustomerID      INT NULL,
        RequestType     VARCHAR(20) NOT NULL,
        ItemsJson       NVARCHAR(MAX) NULL,
        Note            NVARCHAR(255) NULL,
        Status          VARCHAR(20) NOT NULL DEFAULT 'NEW',
        CreatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),
        HandledByStaffID INT NULL,
        CONSTRAINT FK_QRRequest_San FOREIGN KEY (SanID) REFERENCES San(SanID),
        CONSTRAINT FK_QRRequest_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID),
        CONSTRAINT CK_QRRequest_Type CHECK (RequestType IN ('CALL_STAFF','ORDER_ITEM','SERVICE_REQUEST')),
        CONSTRAINT CK_QRRequest_Status CHECK (Status IN ('NEW','IN_PROGRESS','DONE','CANCELLED'))
    );
    CREATE INDEX IX_QRRequest_CoSo_Status ON QRRequest(CoSoID, Status);
    CREATE INDEX IX_QRRequest_GuestToken ON QRRequest(GuestToken);
    PRINT N'Đã tạo bảng QRRequest.';
END
ELSE
    PRINT N'Bảng QRRequest đã tồn tại, bỏ qua.';
GO
