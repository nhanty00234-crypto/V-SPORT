-- sql/rollback_face_salary_guard.sql
-- Gỡ 3 module khỏi database: điểm danh khuôn mặt, tính lương, báo cáo sự cố (+ role Bảo vệ).
-- SQL Server. Idempotent: chạy lại nhiều lần không lỗi.
--
-- ============================================================================
--  ĐỌC TRƯỚC KHI CHẠY
-- ============================================================================
--  Script này XÓA VĨNH VIỄN dữ liệu và KHÔNG hoàn tác được. Trình tự dùng:
--
--    1. Backup database.
--    2. Chạy nguyên file này như hiện tại — nó đang ở chế độ DRY-RUN
--       (kết thúc bằng ROLLBACK), chỉ in ra số bản ghi sẽ bị ảnh hưởng.
--    3. Đọc kỹ kết quả. Nếu đồng ý, sửa dòng cuối từ ROLLBACK thành COMMIT
--       rồi chạy lại.
--
--  Quy ước xử lý tài khoản Bảo vệ (RoleID = 5):
--    - Dữ liệu THUỘC VỀ bảo vệ (ca làm, đơn nghỉ, thông báo) → XÓA.
--    - Dữ liệu NGHIỆP VỤ mà bảo vệ chỉ là người thao tác (hóa đơn, booking,
--      chia tiền) → SET NULL, giữ lại bản ghi. Xóa hóa đơn thật chỉ vì người
--      xác nhận là bảo vệ sẽ mất dữ liệu kinh doanh.
-- ============================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

------------------------------------------------------------------------------
-- BƯỚC 0 — DRY-RUN: xem trước phạm vi ảnh hưởng
------------------------------------------------------------------------------
PRINT '=== Tài khoản Bảo vệ (RoleID = 5) sẽ bị xóa ===';
SELECT AccountID, Username, FullName, Email, CoSoID
FROM   dbo.Accounts
WHERE  RoleID = 5;

PRINT '=== Số bản ghi liên quan tới các tài khoản đó ===';
SELECT 'CaLamViec'             AS BangDuLieu, COUNT(*) AS SoBanGhi FROM dbo.CaLamViec             WHERE AccountID       IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
UNION ALL SELECT 'CaLamViec_Availability',   COUNT(*) FROM dbo.CaLamViec_Availability WHERE AccountID       IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
UNION ALL SELECT 'CaLamViec_Audit',          COUNT(*) FROM dbo.CaLamViec_Audit        WHERE NguoiThucHien   IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
UNION ALL SELECT 'CaLamViec_SwapRequest',    COUNT(*) FROM dbo.CaLamViec_SwapRequest  WHERE AccountID_Gui   IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
                                                                                         OR AccountID_Nhan  IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
                                                                                         OR NguoiDuyet      IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
UNION ALL SELECT 'YeuCauNghi',               COUNT(*) FROM dbo.YeuCauNghi             WHERE AccountID       IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
UNION ALL SELECT 'ThongBao',                 COUNT(*) FROM dbo.ThongBao               WHERE AccountID       IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5)
UNION ALL SELECT 'HoaDon (sẽ SET NULL)',     COUNT(*) FROM dbo.HoaDon                 WHERE AccountID_NhanVien IN (SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5);

BEGIN TRANSACTION;

------------------------------------------------------------------------------
-- BƯỚC 1 — Xóa bảng của 3 module (theo thứ tự FK: con trước, cha sau)
------------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.YeuCauUngLuong;
DROP TABLE IF EXISTS dbo.BangLuong;
DROP TABLE IF EXISTS dbo.KyLuong;
DROP TABLE IF EXISTS dbo.CauHinhLuong;

DROP TABLE IF EXISTS dbo.SuCo;

DROP TABLE IF EXISTS dbo.FaceChallengeToken;
DROP TABLE IF EXISTS dbo.CoSoFaceConfig;

PRINT 'Bước 1: đã xóa bảng lương / sự cố / khuôn mặt.';

------------------------------------------------------------------------------
-- BƯỚC 2 — Xóa cột khuôn mặt trên bảng dùng chung
------------------------------------------------------------------------------
-- Accounts
IF COL_LENGTH('dbo.Accounts', 'FaceDescriptor')  IS NOT NULL ALTER TABLE dbo.Accounts DROP COLUMN FaceDescriptor;
IF COL_LENGTH('dbo.Accounts', 'FaceImagePath')   IS NOT NULL ALTER TABLE dbo.Accounts DROP COLUMN FaceImagePath;
IF COL_LENGTH('dbo.Accounts', 'FaceEnrolledAt')  IS NOT NULL ALTER TABLE dbo.Accounts DROP COLUMN FaceEnrolledAt;

-- CaLamViec. Cột FaceVerified có DEFAULT constraint nên phải gỡ constraint trước.
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql = @sql + N'ALTER TABLE dbo.CaLamViec DROP CONSTRAINT ' + QUOTENAME(dc.name) + N';' + CHAR(10)
FROM   sys.default_constraints dc
JOIN   sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
WHERE  dc.parent_object_id = OBJECT_ID('dbo.CaLamViec')
  AND  c.name IN ('FaceVerified','FaceCheckInImage','FaceConfidence',
                  'FaceLivenessPassed','FaceCheckOutImage','FaceCheckOutConfidence');
IF @sql <> N'' EXEC sp_executesql @sql;

IF COL_LENGTH('dbo.CaLamViec', 'FaceVerified')           IS NOT NULL ALTER TABLE dbo.CaLamViec DROP COLUMN FaceVerified;
IF COL_LENGTH('dbo.CaLamViec', 'FaceCheckInImage')       IS NOT NULL ALTER TABLE dbo.CaLamViec DROP COLUMN FaceCheckInImage;
IF COL_LENGTH('dbo.CaLamViec', 'FaceConfidence')         IS NOT NULL ALTER TABLE dbo.CaLamViec DROP COLUMN FaceConfidence;
IF COL_LENGTH('dbo.CaLamViec', 'FaceLivenessPassed')     IS NOT NULL ALTER TABLE dbo.CaLamViec DROP COLUMN FaceLivenessPassed;
IF COL_LENGTH('dbo.CaLamViec', 'FaceCheckOutImage')      IS NOT NULL ALTER TABLE dbo.CaLamViec DROP COLUMN FaceCheckOutImage;
IF COL_LENGTH('dbo.CaLamViec', 'FaceCheckOutConfidence') IS NOT NULL ALTER TABLE dbo.CaLamViec DROP COLUMN FaceCheckOutConfidence;

-- GHI CHÚ: GioVaoThuc / GioRaThuc trên CaLamViec được GIỮ LẠI. Hai cột này là
-- mốc giờ vào/ra ca chung, không thuộc module khuôn mặt, và còn dữ liệu lịch sử.
-- Sau thay đổi này sẽ không còn code nào ghi vào chúng.

PRINT 'Bước 2: đã xóa cột khuôn mặt trên Accounts và CaLamViec.';

------------------------------------------------------------------------------
-- BƯỚC 3 — Dọn dữ liệu của tài khoản Bảo vệ, rồi xóa tài khoản
------------------------------------------------------------------------------
DECLARE @guards TABLE (AccountID INT PRIMARY KEY);
INSERT INTO @guards (AccountID) SELECT AccountID FROM dbo.Accounts WHERE RoleID = 5;

-- 3a. Dữ liệu nghiệp vụ: gỡ liên kết, giữ bản ghi
UPDATE dbo.HoaDon                SET AccountID_NhanVien   = NULL WHERE AccountID_NhanVien   IN (SELECT AccountID FROM @guards);
UPDATE dbo.LichDatSan            SET ConfirmedBy          = NULL WHERE ConfirmedBy          IN (SELECT AccountID FROM @guards);
UPDATE dbo.LichDatSan            SET CancelledBy          = NULL WHERE CancelledBy          IN (SELECT AccountID FROM @guards);
UPDATE dbo.NhomChiaTienChiTiet   SET ConfirmedByStaffID   = NULL WHERE ConfirmedByStaffID   IN (SELECT AccountID FROM @guards);
UPDATE dbo.CaLamViec_SwapRequest SET NguoiDuyet           = NULL WHERE NguoiDuyet           IN (SELECT AccountID FROM @guards);
UPDATE dbo.YeuCauNghi            SET XuLyBy               = NULL WHERE XuLyBy               IN (SELECT AccountID FROM @guards);

-- 3b. Dữ liệu thuộc về bảo vệ: xóa (con trước, cha sau)
DELETE FROM dbo.CaLamViec_SwapRequest
WHERE AccountID_Gui  IN (SELECT AccountID FROM @guards)
   OR AccountID_Nhan IN (SELECT AccountID FROM @guards)
   OR CaLamViecID_Gui  IN (SELECT CaLamViecID FROM dbo.CaLamViec WHERE AccountID IN (SELECT AccountID FROM @guards))
   OR CaLamViecID_Nhan IN (SELECT CaLamViecID FROM dbo.CaLamViec WHERE AccountID IN (SELECT AccountID FROM @guards));

DELETE FROM dbo.CaLamViec_Availability WHERE AccountID     IN (SELECT AccountID FROM @guards);
DELETE FROM dbo.CaLamViec_Audit        WHERE NguoiThucHien IN (SELECT AccountID FROM @guards);
DELETE FROM dbo.CaLamViec              WHERE AccountID     IN (SELECT AccountID FROM @guards);

DELETE FROM dbo.YeuCauNghi_Audit WHERE NguoiThucHien IN (SELECT AccountID FROM @guards);
DELETE FROM dbo.YeuCauNghi       WHERE AccountID     IN (SELECT AccountID FROM @guards);

DELETE FROM dbo.ThongBao   WHERE AccountID IN (SELECT AccountID FROM @guards);
DELETE FROM dbo.NhatKyChat WHERE AccountID IN (SELECT AccountID FROM @guards);

-- 3c. Xóa tài khoản
DELETE FROM dbo.Accounts WHERE AccountID IN (SELECT AccountID FROM @guards);

PRINT 'Bước 3: đã xóa tài khoản Bảo vệ và dữ liệu liên quan.';

------------------------------------------------------------------------------
-- BƯỚC 4 — Xóa vai trò Bảo vệ khỏi bảng Roles
------------------------------------------------------------------------------
DELETE FROM dbo.Roles WHERE RoleID = 5;

PRINT 'Bước 4: đã xóa vai trò Bảo vệ (RoleID = 5).';

------------------------------------------------------------------------------
-- KẾT THÚC
------------------------------------------------------------------------------
-- Đang ở chế độ DRY-RUN. Đổi dòng dưới thành COMMIT TRANSACTION khi đã sẵn sàng.
ROLLBACK TRANSACTION;
PRINT '*** DRY-RUN: mọi thay đổi đã được hoàn tác. Đổi ROLLBACK thành COMMIT để áp dụng thật. ***';
