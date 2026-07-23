# QR-03A — Luồng QR tại sân (gọi nhân viên / gọi món / yêu cầu dịch vụ)

Ngày: 2026-07-23

## Mục tiêu

Sau khi Manager đã có QR sân (Task QR-01/QR-02), khách tại sân quét QR để:
1. Gọi nhân viên.
2. Gọi món/sản phẩm (từ `SanPham_DichVu` của cơ sở).
3. Yêu cầu dịch vụ đơn giản (ghi chú tự do).
4. Theo dõi trạng thái yêu cầu của mình.

Staff có trang riêng tiếp nhận và xử lý các yêu cầu này theo cơ sở. Trang Check-in có badge/shortcut tới danh sách yêu cầu mới.

## Ngoài phạm vi

Thanh toán trả sau, PayOS từ QR, tạo/cập nhật hóa đơn, trừ tồn kho, giỏ hàng online, QR check-in tự động, QR mở sân, QR mở khóa cửa, WebSocket mới, membership/loyalty QR. Không sửa QR domain (`SanQR*`), không sửa `ServiceOrder`/Task 6/Task 7, không sửa trang Quản lý Mã QR sân.

## Data model

Bảng mới `QRRequest`, độc lập với `ServiceOrder`:

```
QRRequest
- RequestID (PK, auto)
- SanID (FK -> San)
- CoSoID (FK -> CoSo)                 -- denormalized từ San, để staff query nhanh theo cơ sở
- GuestToken (varchar 64, not null)   -- UUID sinh phía client, lưu localStorage, định danh phiên khách (không cần đăng nhập)
- CustomerID (FK -> KhachHang, nullable) -- gán nếu khách đang đăng nhập, không bắt buộc
- RequestType (enum: CALL_STAFF, ORDER_ITEM, SERVICE_REQUEST)
- ItemsJson (text, nullable)          -- cho ORDER_ITEM: [{sanPhamId, tenSanPham, donGia, soLuong}] snapshot tại thời điểm gọi
- Note (varchar 255, nullable)
- Status (enum: NEW, IN_PROGRESS, DONE, CANCELLED)
- CreatedAt, UpdatedAt (timestamp)
- HandledByStaffID (FK -> TaiKhoan, nullable)
```

Không đụng tồn kho/hóa đơn — `ItemsJson` chỉ là snapshot hiển thị.

## Endpoints

Customer-facing (`controller/customer`):
- `GET /qr/{shortCode}` — `SanQRResolveServlet`, dùng `SanQRService.resolveByShortCode` sẵn có, render `QuetQR.jsp` hoặc trang lỗi (REVOKED/DISABLED/NOT_FOUND).
- `POST /api/qr/yeu-cau` — `QRRequestApiServlet`, tạo `QRRequest`; validate QR còn ACTIVE trước khi ghi.
- `GET /api/qr/yeu-cau?guestToken=&sanId=` — `QRRequestStatusApiServlet`, danh sách yêu cầu của guestToken đó (polling).
- `GET /api/qr/san-pham?sanId=` — `SanPhamQRApiServlet`, danh sách `SanPham_DichVu` ACTIVE theo CoSoID của sân.

Staff-facing (`controller/staff`):
- `GET /staff/yeu-cau-qr` — `YeuCauQRServlet`, render trang, CoSoID lấy từ session (không tin param).
- `GET /api/staff/yeu-cau-qr?status=` — `YeuCauQRApiServlet`, danh sách theo cơ sở + tab.
- `POST /api/staff/yeu-cau-qr/{id}/action` — `YeuCauQRActionApiServlet`, action=start/complete/cancel, ghi `HandledByStaffID`.
- `GET /api/staff/yeu-cau-qr/count` — `YeuCauQRCountApiServlet`, số lượng NEW theo cơ sở (badge, polling ~10s).

## UI

- CheckIn.jsp: ảnh QR nhỏ (48×48, dùng lại `SanQRImageServlet`) trên mỗi card sân; badge "Yêu cầu mới: N" ở sidebar + dashboard, click sang `/staff/yeu-cau-qr`. Polling 10s.
- `QuetQR.jsp`: mobile-first, tên sân + 3 nút (Gọi nhân viên / Gọi món / Yêu cầu dịch vụ). Gọi món có danh sách sản phẩm + số lượng.
- `TrangThaiYeuCau.jsp`: danh sách yêu cầu của guestToken, badge trạng thái, polling 5s.
- `/staff/yeu-cau-qr`: tabs Mới/Đang xử lý/Hoàn thành/Đã huỷ, nút hành động theo tab, polling 10s cho tab Mới.

Style tái dùng token màu/spacing hiện có trong CheckIn.jsp (`.badge-green/amber/blue`), không tạo hệ màu mới.

## Auth / bảo mật

- CoSoID cho staff luôn lấy từ session, không tin request param (theo nguyên tắc chống IDOR đã áp dụng cho QR domain).
- `SanQRResolveServlet` chỉ resolve, không tạo side-effect (không check-in tự động).
- API tạo request validate lại QR ACTIVE trước khi ghi, tránh spam khi QR đã bị revoke/disable.

## Luồng chấp nhận (định nghĩa "xong")

Customer quét QR → nhận diện đúng sân → gọi nhân viên hoặc gọi món → Staff đúng cơ sở nhận yêu cầu → Staff bắt đầu xử lý → Staff hoàn thành → Customer theo dõi được trạng thái (qua polling, không cần đăng nhập).
