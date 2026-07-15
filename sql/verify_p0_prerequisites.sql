-- Verify: kiểm tra (READ-ONLY, không ALTER/DROP gì) rằng các migration trước đây đã chạy
-- và cung cấp đúng cột/index mà đợt sửa P0 (2026-07-15, booking/payment audit) phụ thuộc vào.
-- KHÔNG có migration schema mới trong đợt P0 này - mọi cột/index cần thiết đã được thêm bởi
-- sql/migration_reservation_hold.sql, sql/migration_hoadon_loai.sql, sql/migration_court_checkout.sql
-- ở các đợt trước. Script này chỉ để XÁC NHẬN trước khi triển khai code mới, không thay đổi gì.
--
-- Chạy thủ công (SSMS hoặc sqlcmd) TRƯỚC khi deploy code P0 mới. Nếu bất kỳ dòng nào báo "THIẾU",
-- phải chạy migration tương ứng trước - xem cột "Migration nguồn" bên dưới.

USE QuanLiSport;
GO

PRINT N'=== 1. Cột LichDatSan cần cho PayOS/no-show/checkout (nguồn: migration_reservation_hold.sql) ===';
SELECT
    expected.col AS ColumnName,
    CASE WHEN c.name IS NULL THEN N'THIẾU' ELSE N'OK' END AS Status
FROM (VALUES (N'HoldExpiresAt'), (N'DepositAmount'), (N'PaymentMethodConfirmed'),
             (N'TransactionCode'), (N'ConfirmedAt'), (N'ConfirmedBy'), (N'ConfirmSource'), (N'NoShowAt')) AS expected(col)
LEFT JOIN sys.columns c ON c.object_id = OBJECT_ID(N'LichDatSan') AND c.name = expected.col;
GO

PRINT N'=== 2. Cột LichDatSan cần cho checkout finalize (nguồn: migration_court_checkout.sql) ===';
SELECT
    expected.col AS ColumnName,
    CASE WHEN c.name IS NULL THEN N'THIẾU' ELSE N'OK' END AS Status
FROM (VALUES (N'ActualStartAt'), (N'ActualEndAt'), (N'PricingFinalizedAt')) AS expected(col)
LEFT JOIN sys.columns c ON c.object_id = OBJECT_ID(N'LichDatSan') AND c.name = expected.col;
GO

PRINT N'=== 3. Cột HoaDon.LoaiHoaDon (nguồn: migration_hoadon_loai.sql) ===';
SELECT
    CASE WHEN COL_LENGTH(N'HoaDon', N'LoaiHoaDon') IS NULL THEN N'THIẾU' ELSE N'OK' END AS LoaiHoaDon_Status,
    CASE WHEN COL_LENGTH(N'HoaDon', N'ParentHoaDonID') IS NULL THEN N'THIẾU' ELSE N'OK' END AS ParentHoaDonID_Status;
GO

PRINT N'=== 4. Unique filtered index chống MAIN invoice trùng (nguồn: migration_court_checkout.sql) ===';
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM sys.indexes WHERE name = N'UX_HoaDon_OneMainPerBooking' AND object_id = OBJECT_ID(N'HoaDon')
    ) THEN N'OK - index đang hoạt động'
    ELSE N'THIẾU - có thể do migration chưa chạy HOẶC đã tự bỏ qua vì có MAIN invoice trùng sẵn trong dữ liệu (xem mục 5)'
    END AS UX_HoaDon_OneMainPerBooking_Status;
GO

PRINT N'=== 5. Kiểm tra MAIN invoice trùng (nếu có dòng nào ở đây, PHẢI xử lý thủ công trước khi tạo unique index) ===';
IF COL_LENGTH(N'HoaDon', N'LoaiHoaDon') IS NOT NULL
BEGIN
    SELECT DatSanID, COUNT(*) AS SoLuongMainInvoiceTrung
    FROM HoaDon
    WHERE LoaiHoaDon = N'MAIN' AND DatSanID IS NOT NULL
    GROUP BY DatSanID
    HAVING COUNT(*) > 1;
END
GO

PRINT N'=== 6. Bảng CourtChargeSegment (dùng bởi CheckoutService.finalizeLocked) ===';
SELECT CASE WHEN OBJECT_ID(N'CourtChargeSegment', N'U') IS NULL THEN N'THIẾU' ELSE N'OK' END AS CourtChargeSegment_Status;
GO

PRINT N'=== 7. Cột legacy actual_start_time/TimeMode/ReservedDurationMinutes (dùng bởi check-in) ===';
SELECT
    expected.col AS ColumnName,
    CASE WHEN c.name IS NULL THEN N'THIẾU' ELSE N'OK' END AS Status
FROM (VALUES (N'actual_start_time'), (N'actual_end_time'), (N'TimeMode'), (N'ReservedDurationMinutes')) AS expected(col)
LEFT JOIN sys.columns c ON c.object_id = OBJECT_ID(N'LichDatSan') AND c.name = expected.col;
GO

PRINT N'Kiểm tra hoàn tất. Nếu có dòng "THIẾU", chạy migration tương ứng (mục 6 trong báo cáo cuối) trước khi deploy code P0 mới.';
GO
