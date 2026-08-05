-- =============================================================================
-- verify_qr_flow.sql
-- Chỉ SELECT để kiểm tra luồng QR sân đang chạy đúng bằng dữ liệu thật.
-- Không tạo bảng, không sửa/xóa dữ liệu.
-- =============================================================================

-- 1) QR đang hoạt động, liên kết đúng sân + cơ sở
SELECT TOP 50
    q.SanQRID, q.SanID, q.ShortCode, q.TrangThai AS QRTrangThai,
    s.TenSan, s.CoSoID, s.TrangThai AS SanTrangThai,
    c.TenCoSo, c.TrangThai AS CoSoTrangThai
FROM dbo.SanQR q
JOIN dbo.San s ON s.SanID = q.SanID
JOIN dbo.CoSo c ON c.CoSoID = s.CoSoID
ORDER BY q.SanQRID DESC;

-- 2) QR đã bị thu hồi (lịch sử token)
SELECT TOP 50 HistoryID, SanQRID, SanID, ShortCode, TrangThai, IssuedAt, RevokedAt, RevokeReason
FROM dbo.SanQRTokenHistory
WHERE TrangThai = N'REVOKED'
ORDER BY RevokedAt DESC;

-- 3) Staff/Manager thuộc cơ sở (Accounts.CoSoID)
SELECT AccountID, FullName, Username, RoleID, CoSoID
FROM dbo.Accounts
WHERE CoSoID IS NOT NULL
ORDER BY CoSoID, RoleID;

-- 4) Sản phẩm/dịch vụ của 1 cơ sở kèm tồn kho (đổi @CoSoID)
DECLARE @CoSoID INT = 1;
SELECT SanPhamID, TenSanPham, DonGia, SoLuongTon, TrangThai
FROM dbo.SanPham_DichVu
WHERE CoSoID = @CoSoID
ORDER BY TrangThai, TenSanPham;

-- 5) 20 yêu cầu QR mới nhất (mọi cơ sở) - trạng thái, người xử lý, thời gian
SELECT TOP 20
    RequestID, SanID, CoSoID, GuestToken, CustomerID, RequestType,
    LEFT(ItemsJson, 200) AS ItemsJsonPreview, Note, Status,
    CreatedAt, UpdatedAt, HandledByStaffID
FROM QRRequest
ORDER BY CreatedAt DESC;

-- 6) Yêu cầu QR đang chờ xử lý theo cơ sở (đổi @CoSoID)
SELECT RequestID, SanID, RequestType, Status, CreatedAt,
       DATEDIFF(SECOND, CreatedAt, SYSUTCDATETIME()) AS DaChoGiay
FROM QRRequest
WHERE CoSoID = @CoSoID AND Status IN ('NEW', 'IN_PROGRESS')
ORDER BY CreatedAt ASC;

-- 7) Ai đang xử lý yêu cầu nào (map sang tên nhân viên)
SELECT r.RequestID, r.Status, r.HandledByStaffID, a.FullName AS TenNhanVien
FROM QRRequest r
LEFT JOIN dbo.Accounts a ON a.AccountID = r.HandledByStaffID
WHERE r.Status IN ('IN_PROGRESS', 'DONE')
ORDER BY r.UpdatedAt DESC;

-- 8) Phiên sân đang "Đang sử dụng" (nơi QRRequest ORDER_ITEM sẽ gắn vào khi Staff xác nhận)
SELECT DatSanID, SanID, AccountID, TrangThai, NgayDat, GioBatDau, GioKetThuc
FROM dbo.LichDatSan
WHERE TrangThai = N'Đang sử dụng';

-- 9) Dịch vụ đã gắn vào phiên sân qua QR (LichDatSan_DichVu), kèm trạng thái giao hàng
SELECT TOP 50 Id, DatSanID, SanPhamID, Quantity, UnitPrice, TotalPrice, Status, CreatedAt, DeliveredAt, DeliveredBy
FROM dbo.LichDatSan_DichVu
ORDER BY Id DESC;

-- 10) Hóa đơn hiện tại của 1 phiên sân (MAIN + SPLIT do QR tạo), đổi @DatSanID
DECLARE @DatSanID INT = 1;
SELECT HoaDonID, DatSanID, TongTienSan, TongTienDichVu, TongThanhToan, TrangThaiThanhToan
FROM dbo.HoaDon
WHERE DatSanID = @DatSanID
ORDER BY HoaDonID;

-- 11) Chi tiết hóa đơn tương ứng
SELECT ct.ChiTietID, ct.HoaDonID, ct.SanPhamID, sp.TenSanPham, ct.SoLuong, ct.DonGiaTaiThoiDiemBan, ct.ThanhTien
FROM dbo.ChiTietHoaDon ct
JOIN dbo.HoaDon hd ON hd.HoaDonID = ct.HoaDonID
JOIN dbo.SanPham_DichVu sp ON sp.SanPhamID = ct.SanPhamID
WHERE hd.DatSanID = @DatSanID
ORDER BY ct.ChiTietID;

-- 12) Trạng thái thanh toán tổng hợp theo cơ sở hôm nay (không lộ PayOS secret)
SELECT hd.HoaDonID, hd.DatSanID, hd.TrangThaiThanhToan, hd.TongThanhToan, hd.NgayLap
FROM dbo.HoaDon hd
JOIN dbo.LichDatSan lds ON lds.DatSanID = hd.DatSanID
JOIN dbo.San s ON s.SanID = lds.SanID
WHERE s.CoSoID = @CoSoID AND CAST(hd.NgayLap AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY hd.NgayLap DESC;
