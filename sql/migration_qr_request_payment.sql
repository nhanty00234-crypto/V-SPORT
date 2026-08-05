-- Migration: Thêm loại yêu cầu PAYMENT_REQUEST vào QRRequest (khách chọn
-- Chuyển khoản/Tiền mặt trên trang quét QR -> báo nhân viên ra thu tiền/xác
-- nhận thủ công, KHÔNG phải cổng thanh toán thật). Chạy một lần trên DB thực,
-- an toàn khi chạy lại (kiểm tra tên constraint trước khi DROP/ADD).

USE QuanLiSport;
GO

IF EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = 'CK_QRRequest_Type' AND parent_object_id = OBJECT_ID('dbo.QRRequest')
)
BEGIN
    ALTER TABLE dbo.QRRequest DROP CONSTRAINT CK_QRRequest_Type;
    PRINT N'Đã xóa constraint CK_QRRequest_Type cũ.';
END
GO

ALTER TABLE dbo.QRRequest WITH CHECK
    ADD CONSTRAINT CK_QRRequest_Type CHECK (RequestType IN ('CALL_STAFF','ORDER_ITEM','SERVICE_REQUEST','PAYMENT_REQUEST'));
PRINT N'Đã tạo lại constraint CK_QRRequest_Type với PAYMENT_REQUEST.';
GO

-- Rollback (thủ công, chỉ chạy nếu cần gỡ và chưa có dòng PAYMENT_REQUEST nào):
--   ALTER TABLE dbo.QRRequest DROP CONSTRAINT CK_QRRequest_Type;
--   ALTER TABLE dbo.QRRequest WITH CHECK
--     ADD CONSTRAINT CK_QRRequest_Type CHECK (RequestType IN ('CALL_STAFF','ORDER_ITEM','SERVICE_REQUEST'));
