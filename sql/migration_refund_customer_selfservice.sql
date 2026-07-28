-- ============================================================
-- Migration: Hoàn tiền Customer self-service — mở rộng bảng HoanTien
-- đã có sẵn (không tạo bảng thứ hai). Idempotent: chạy nhiều lần
-- không lỗi. Xem sql/migration_refund_workflows.sql +
-- sql/migration_notification_marketing_refund_review.sql cho các
-- cột đã tồn tại trước migration này.
--
-- QUAN TRỌNG — 2 luồng RefundService cũ đang ghi TrangThai xung đột:
--   org.example.service.RefundService          -> "Chờ xử lý"/"Đã duyệt"/"Từ chối"/"Đã hoàn tiền"
--   org.example.service.refund.RefundService    -> "CHO_XU_LY"/"DA_DUYET"/"TU_CHUOI"
-- Migration này CHUẨN HÓA lại toàn bộ dữ liệu cũ về 7 trạng thái code
-- mới (org.example.util.RefundStatus) và từ nay chỉ dùng service mới
-- viết trong task này. Hai class RefundService cũ được giữ nguyên,
-- không xóa, không sửa (tránh phá luồng hiện có), nhưng KHÔNG được
-- gọi thêm từ code mới.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Các cột dữ liệu tiền còn thiếu theo yêu cầu nghiệp vụ mới
-- ------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'SoTienDaThanhToan')
BEGIN
    ALTER TABLE dbo.HoanTien ADD SoTienDaThanhToan DECIMAL(18,2) NULL;
    PRINT 'Added: HoanTien.SoTienDaThanhToan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'SoTienDeNghiHoan')
BEGIN
    ALTER TABLE dbo.HoanTien ADD SoTienDeNghiHoan DECIMAL(18,2) NULL;
    PRINT 'Added: HoanTien.SoTienDeNghiHoan';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'SoTienDuocDuyet')
BEGIN
    ALTER TABLE dbo.HoanTien ADD SoTienDuocDuyet DECIMAL(18,2) NULL;
    PRINT 'Added: HoanTien.SoTienDuocDuyet';
END
GO

-- Backfill: dữ liệu cũ chỉ có 1 cột SoTienHoan — coi đó vừa là số đề nghị vừa là số đã trả.
UPDATE dbo.HoanTien
   SET SoTienDeNghiHoan = SoTienHoan
 WHERE SoTienDeNghiHoan IS NULL;
GO
UPDATE dbo.HoanTien
   SET SoTienDaThanhToan = SoTienHoan
 WHERE SoTienDaThanhToan IS NULL;
GO

-- ------------------------------------------------------------
-- 2. CoSoID trực tiếp trên HoanTien (Manager lọc theo cơ sở mình
--    hiện phải JOIN 3 bảng — thêm cột chống denormalize để IDOR
--    check tại tầng SQL nhanh và chắc chắn hơn, không chỉ ở JSP)
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'CoSoID')
BEGIN
    ALTER TABLE dbo.HoanTien ADD CoSoID INT NULL;
    PRINT 'Added: HoanTien.CoSoID';
END
GO

-- Backfill CoSoID từ HoaDon -> LichDatSan -> San -> CoSo cho dữ liệu cũ.
UPDATE ht
   SET ht.CoSoID = s.CoSoID
  FROM dbo.HoanTien ht
  JOIN dbo.HoaDon hd ON ht.HoaDonID = hd.HoaDonID
  JOIN dbo.LichDatSan lds ON hd.DatSanID = lds.DatSanID
  JOIN dbo.San s ON lds.SanID = s.SanID
 WHERE ht.CoSoID IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'IX_HoanTien_CoSoID')
BEGIN
    CREATE NONCLUSTERED INDEX IX_HoanTien_CoSoID ON dbo.HoanTien (CoSoID);
    PRINT 'Created index: IX_HoanTien_CoSoID';
END
GO

-- ------------------------------------------------------------
-- 3. QR nhận tiền, ghi chú khách hàng, lý do từ chối tách riêng
--    (GhiChuXuLy hiện tại dùng chung cho mọi ghi chú Manager —
--    LyDoTuChoi tách riêng để hiển thị rõ ràng, không lẫn với
--    ghi chú duyệt/hoàn tất).
-- ------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'QrNhanTienPath')
BEGIN
    ALTER TABLE dbo.HoanTien ADD QrNhanTienPath NVARCHAR(300) NULL;
    PRINT 'Added: HoanTien.QrNhanTienPath';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'GhiChuKhachHang')
BEGIN
    ALTER TABLE dbo.HoanTien ADD GhiChuKhachHang NVARCHAR(500) NULL;
    PRINT 'Added: HoanTien.GhiChuKhachHang';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'LyDoTuChoi')
BEGIN
    ALTER TABLE dbo.HoanTien ADD LyDoTuChoi NVARCHAR(500) NULL;
    PRINT 'Added: HoanTien.LyDoTuChoi';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'CompletedAt')
BEGIN
    ALTER TABLE dbo.HoanTien ADD CompletedAt DATETIME NULL;
    PRINT 'Added: HoanTien.CompletedAt';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'ApprovedAt')
BEGIN
    ALTER TABLE dbo.HoanTien ADD ApprovedAt DATETIME NULL;
    PRINT 'Added: HoanTien.ApprovedAt';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.HoanTien') AND name = N'UpdatedAt')
BEGIN
    ALTER TABLE dbo.HoanTien ADD UpdatedAt DATETIME NOT NULL CONSTRAINT DF_HoanTien_UpdatedAt DEFAULT (GETDATE());
    PRINT 'Added: HoanTien.UpdatedAt';
END
GO

-- ------------------------------------------------------------
-- 4. Chuẩn hóa toàn bộ giá trị TrangThai cũ (2 luồng xung đột)
--    về đúng 7 mã trạng thái mới (org.example.util.RefundStatus).
--    Idempotent: chỉ UPDATE các dòng còn ở dạng cũ.
-- ------------------------------------------------------------
UPDATE dbo.HoanTien SET TrangThai = N'CHO_XU_LY'      WHERE TrangThai IN (N'Chờ xử lý', N'CHO_XU_LY');
UPDATE dbo.HoanTien SET TrangThai = N'DA_DUYET'       WHERE TrangThai IN (N'Đã duyệt', N'DA_DUYET');
UPDATE dbo.HoanTien SET TrangThai = N'TU_CHOI'        WHERE TrangThai IN (N'Từ chối', N'TU_CHUOI', N'TU_CHOI');
UPDATE dbo.HoanTien SET TrangThai = N'DA_HOAN_TIEN'   WHERE TrangThai IN (N'Đã hoàn tiền', N'DA_HOAN_TIEN', N'DA_HOAN');
GO

-- ApprovedAt backfill từ ThoiGianXuLy khi trạng thái hiện tại là DA_DUYET trở lên (dữ liệu cũ
-- không phân biệt ApprovedAt/CompletedAt riêng — chấp nhận xấp xỉ bằng ThoiGianXuLy).
UPDATE dbo.HoanTien
   SET ApprovedAt = ThoiGianXuLy
 WHERE ApprovedAt IS NULL AND TrangThai IN (N'DA_DUYET', N'DANG_HOAN_TIEN', N'DA_HOAN_TIEN') AND ThoiGianXuLy IS NOT NULL;
GO
UPDATE dbo.HoanTien
   SET CompletedAt = ThoiGianHoan
 WHERE CompletedAt IS NULL AND TrangThai = N'DA_HOAN_TIEN' AND ThoiGianHoan IS NOT NULL;
GO

PRINT '=== Migration migration_refund_customer_selfservice: DONE ===';
GO
