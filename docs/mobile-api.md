# V-SPORT Mobile REST API (`/api/v1`)

API dành riêng cho **Customer App (Flutter)**. Web JSP/Servlet giữ nguyên không đổi (session +
JSESSIONID + filter cũ). Hai nền tảng dùng CHUNG Model / DAO / Service / Database.

```
                SQL SERVER
                     ↑
                    DAO
                     ↑
                  SERVICE
                 ↑        ↑
          WEB SERVLET   REST API (/api/v1)
                ↑            ↑
               JSP       FLUTTER APP
```

## Quy ước chung

**Base URL:** `http(s)://<host>:<port>/Backend_java/api/v1`

**Envelope thành công**

```json
{ "success": true, "message": "…", "data": { } }
```

**Envelope lỗi**

```json
{ "success": false, "message": "…", "errorCode": "COURT_UNAVAILABLE" }
```

**HTTP status:** 200 OK · 201 Created · 400 Bad Request · 401 Unauthorized · 403 Forbidden ·
404 Not Found · 409 Conflict · 502 Bad Gateway (lỗi cổng thanh toán) · 500 Internal Server Error.

**errorCode thường gặp:** `VALIDATION_ERROR`, `UNAUTHORIZED`, `TOKEN_EXPIRED`, `INVALID_TOKEN`,
`FORBIDDEN`, `NOT_CUSTOMER`, `ACCOUNT_LOCKED`, `NOT_FOUND`, `CONFLICT`, `SLOT_TAKEN`,
`COURT_UNAVAILABLE`, `BOOKING_LIMIT`, `REPUTATION_BLOCKED`, `PAYMENT_ERROR`, `PAYMENT_CONFLICT`,
`PROMOTION_INVALID`, `QR_INVALID`, `DUPLICATE`, `INTERNAL_ERROR`.

**Xác thực:** `Authorization: Bearer <accessToken>` (JWT HS256, stateless — không thêm bảng DB).
Chỉ tài khoản **RoleID = 3 (CUSTOMER)** được dùng; token của Admin/Manager/Staff/Guard bị chặn 403
`NOT_CUSTOMER`. Access token sống 1 giờ, refresh token 30 ngày.

> Cấu hình bắt buộc ở môi trường thật: biến môi trường `JWT_SECRET`. Nếu thiếu, hệ thống sinh
> secret ngẫu nhiên trong bộ nhớ và mọi token mất hiệu lực sau khi restart Tomcat.
> CORS: `API_ALLOWED_ORIGINS` (danh sách phân tách bằng dấu phẩy); bỏ trống thì chỉ cho localhost.

**Ngày giờ:** múi giờ `Asia/Ho_Chi_Minh`. `bookingDate` = `yyyy-MM-dd`, `startTime`/`endTime` =
`HH:mm`, dấu thời gian = `yyyy-MM-ddTHH:mm:ss`.

**AccountID không bao giờ nhận từ client** — luôn suy ra từ token. **Giá luôn do server tính.**

---

## 1. Auth

### POST `/auth/login` — không cần token

```json
{ "email": "khach@gmail.com", "password": "..." }
```
hoặc
```json
{ "phone": "0901234567", "password": "..." }
```

`data`:

```json
{
  "accessToken": "...", "refreshToken": "...", "tokenType": "Bearer", "expiresIn": 3600,
  "customer": { "accountId": 12, "fullName": "...", "email": "...", "phone": "...",
                "avatar": "https://...", "reputationScore": 100, "reputationLabel": "Uy tín tốt",
                "canBook": true }
}
```

Lỗi: 401 `INVALID_CREDENTIALS` (một thông báo chung cho mọi nguyên nhân — chống dò tài khoản),
403 `NOT_CUSTOMER`, 403 `ACCOUNT_LOCKED`. Có rate limit theo tài khoản và theo IP.

### POST `/auth/refresh` — không cần token

```json
{ "refreshToken": "..." }
```
Trả về đúng cấu trúc như login.

### POST `/auth/logout`
Token stateless nên đây là no-op phía server; app tự xoá secure storage.

---

## 2. Customer

| Method | URL | Auth | Ghi chú |
|---|---|---|---|
| GET | `/customer/me` | ✔ | Hồ sơ khách hàng |
| PUT | `/customer/me` | ✔ | Body: `fullName`, `phone`, `gender` (Nam/Nữ/Khác), `dateOfBirth`, `avatar` |
| GET | `/customer/reputation` | ✔ | Điểm uy tín + ngưỡng chặn đặt sân |
| GET | `/customer/reputation/history` | ✔ | Lịch sử biến động điểm |
| GET | `/home` | ✔ | Gộp dữ liệu Trang chủ; query tuỳ chọn `latitude`, `longitude` |

---

## 3. Danh mục (công khai, không cần token)

| Method | URL | Query |
|---|---|---|
| GET | `/sports` | — |
| GET | `/facilities` | `keyword`, `sportId`, `latitude`, `longitude`, `radiusKm`, `promotionOnly`, `page`, `size` |
| GET | `/facilities/nearby` | bắt buộc `latitude` + `longitude`; thêm `radiusKm` |
| GET | `/facilities/{id}` | — |
| GET | `/facilities/{id}/courts` | `sportId` |
| GET | `/courts/{id}` | — |
| GET | `/courts/{id}/availability` | `date=yyyy-MM-dd` (mặc định hôm nay), `slotMinutes` (30/60/…; mặc định 60) |

`/facilities` trả `{page,size,total,items:[…]}`. Mỗi cơ sở gồm toạ độ, ảnh (URL HTTP tuyệt đối),
giờ mở/đóng, `openNow`, `minPrice`, `readyCourtCount`, `sports`, `hasPromotion`, và `distanceKm`
khi có toạ độ (Haversine — cùng công thức với bản đồ Web).

`/courts/{id}/availability` `data`:

```json
{
  "courtId": 10, "courtName": "Sân 1", "facilityId": 3, "date": "2026-08-10",
  "openTime": "06:00", "closeTime": "22:00", "slotMinutes": 60,
  "slots": [ { "startTime": "07:00", "endTime": "08:00", "available": true,
               "reason": null, "price": 100000 } ]
}
```

Điều kiện chặn slot dùng **đúng** truy vấn overlap + SoftHold của luồng đặt sân Web, và giá dùng
**đúng** `CourtPricingService` (giá không đèn / có đèn theo khung giờ).

---

## 4. Đặt sân

| Method | URL | Auth |
|---|---|---|
| POST | `/bookings` | ✔ |
| POST | `/bookings/quote` | ✔ |
| GET | `/bookings/me` | ✔ |
| GET | `/bookings/{id}` | ✔ |
| GET | `/bookings/{id}/cancel-preview` | ✔ |
| POST | `/bookings/{id}/cancel` | ✔ |
| POST | `/bookings/{id}/payment` | ✔ |
| GET | `/bookings/{id}/payment-status` | ✔ |

### POST `/bookings`

```json
{
  "courtId": 10,
  "bookingDate": "2026-08-10",
  "startTime": "18:00",
  "endTime": "20:00",
  "note": null,
  "promotionCode": null,
  "paymentMethod": "payos"
}
```

`paymentMethod`: `"payos"` → trạng thái `Chờ thanh toán` kèm hạn giữ chỗ; bất kỳ giá trị nào khác
(hoặc bỏ trống) → `Chờ xác nhận` (thanh toán tại quầy). **201 Created**, `data` là BookingDto.

Server kiểm tra tuần tự (dùng chung `BookingCreationService` với Web): điểm uy tín → thứ tự giờ →
thời lượng 30 phút–4 giờ → không đặt quá khứ / quá 30 ngày → khoá hàng `San` (UPDLOCK) → giới hạn
3 lượt/ngày → trạng thái sân → giờ mở/đóng cửa → trùng lịch → SoftHold của người khác → tính giá →
INSERT. Có retry deadlock.

Lỗi: 409 `SLOT_TAKEN` / `BOOKING_LIMIT`, 403 `REPUTATION_BLOCKED` / `COURT_UNAVAILABLE`,
404 `NOT_FOUND`, 400 `VALIDATION_ERROR`.

> **Khuyến mãi:** giống Web, `promotionCode` chỉ được *kiểm tra và hiển thị* mức giảm; số tiền
> giảm thực tế do luồng hoá đơn hiện có xử lý. Mobile không tạo quy tắc giảm giá mới.

### POST `/bookings/quote`

Body như trên (không có `paymentMethod`). `data`: `courtAmount`, `discountAmount`, `totalAmount`,
`durationMinutes`, `promotionApplied`, `promotionMessage`.

### GET `/bookings/me?status=&page=&size=`

Chỉ trả đơn của chính khách đang đăng nhập. `status` khớp đúng chuỗi trạng thái của hệ thống
(`Chờ thanh toán`, `Chờ xác nhận`, `Đã xác nhận`, `Đã hoàn thành`, `Đã hủy`, …).

### GET `/bookings/{id}`

404 nếu đơn không thuộc khách đang đăng nhập (không tiết lộ đơn có tồn tại hay không).

BookingDto gồm: `bookingId`, `courtId/courtName`, `facilityId/facilityName/facilityAddress`,
`sportName`, `bookingDate`, `startTime`, `endTime`, `status`, `totalAmount`, `lightingApplied`,
`note`, `source`, `createdAt`, `holdRemainingSeconds`, `cancellable`, `payable`, `image`.

### POST `/bookings/{id}/cancel`

```json
{ "reason": "Bận đột xuất" }
```

Dùng chung `BookingCancellationService`: giới hạn giờ hủy, trừ điểm uy tín, tạo yêu cầu hoàn tiền
nếu đủ điều kiện, ghi AuditLog và gửi thông báo — không có logic hủy riêng cho mobile.
`data`: `refundId`, `newReputationScore`, `refundableAmount`, `cancellationFee`.

### POST `/bookings/{id}/payment`

Không có body. Server đọc lại số tiền từ DB, tạo payment link PayOS bằng credentials **của cơ sở**
(đọc từ DB, không bao giờ gửi xuống app) và trả:

```json
{ "bookingId": 55, "orderCode": 55, "amount": 200000, "description": "VSport DS55",
  "qrPayload": "<payload VietQR thô>", "checkoutUrl": "https://...",
  "bankBin": "...", "accountNumber": "...", "accountName": "...", "expiresAtEpoch": 1760000000 }
```

App tự render `qrPayload` thành ảnh QR. Lỗi: 409 `PAYMENT_CONFLICT` (đơn không còn chờ thanh toán
hoặc hết hạn giữ chỗ), 502 `PAYMENT_ERROR`.

### GET `/bookings/{id}/payment-status`

```json
{ "bookingId": 55, "status": "pending", "paid": false,
  "bookingStatus": "Chờ thanh toán", "remainingSeconds": 480, "message": "Chưa nhận được thanh toán." }
```

`status`: `pending` | `paid` | `cancelled` | `expired` | `settled`.
Khi DB còn pending, server tự truy vấn PayOS rồi finalize bằng **đúng** finalizer dùng chung với
webhook (`PayOSLegacyBookingFinalizationService`). Webhook vẫn là nguồn xác nhận chính; app không
bao giờ tự đánh dấu đã thanh toán.

---

## 5. Khuyến mãi

| Method | URL | Auth |
|---|---|---|
| GET | `/promotions?facilityId=&limit=` | — |
| GET | `/promotions/available` | — |
| POST | `/promotions/validate` | ✔ |

`POST /promotions/validate`:

```json
{ "code": "VSPORT10", "facilityId": 3, "amount": 200000, "bookingDate": "2026-08-10" }
```
→ `{ "valid": true, "message": "...", "discountAmount": 20000, "finalAmount": 180000 }`

---

## 6. QR tại sân & yêu cầu dịch vụ

### GET `/qr/{code}` — cần token

`code` là chuỗi quét được (short code, token UUID, hoặc URL `.../qr/ABC123` — server tự bóc tách).

```json
{
  "resultCode": "OK", "message": "Mã hợp lệ.", "available": true,
  "courtId": 10, "courtName": "Sân 1", "facilityName": "V-Sport Q1", "sportName": "Cầu lông",
  "sessionToken": "ABC123",
  "availableActions": ["CALL_STAFF", "SERVICE_REQUEST", "ORDER_ITEM", "PAYMENT_REQUEST"],
  "activeBookingId": 55,
  "products": [ { "productId": 7, "name": "Nước suối", "price": 10000, "unit": "chai", "stock": 20 } ]
}
```

`resultCode` khác `OK`: `NOT_FOUND`, `REVOKED`, `DISABLED`, `FACILITY_INACTIVE` (vẫn trả HTTP 200
kèm `available:false`). Endpoint chỉ đọc — không check-in, không tạo bản ghi.

### POST `/service-requests` — cần token

```json
{
  "sessionToken": "ABC123",
  "type": "CALL_STAFF",
  "note": "Cần thêm khăn",
  "items": [ { "sanPhamId": 7, "soLuong": 2 } ]
}
```

- `type`: `CALL_STAFF` | `ORDER_ITEM` | `SERVICE_REQUEST` | `PAYMENT_REQUEST`.
- `items` chỉ dùng cho `ORDER_ITEM`; **giá không nhận từ client**, Staff xác nhận sẽ lấy giá từ DB.
- `PAYMENT_REQUEST` yêu cầu `note` = `"Tiền mặt"` hoặc `"Chuyển khoản"`.
- **SanID không nhận từ body** — server resolve từ `sessionToken`.
- GuestToken do server sinh từ AccountID + SanID nên khách không thể mạo danh phiên người khác.

Bản ghi vào bảng `QRRequest` qua `QRRequestService` → **màn hình Staff/Manager trên Web nhận được
ngay** như luồng QR của Web. 201 Created; 409 `DUPLICATE` nếu gửi trùng trong thời gian ngắn.

### GET `/service-requests?qrCode=ABC123` — cần token

Danh sách yêu cầu của chính khách tại sân đó kèm trạng thái (`NEW`/`IN_PROGRESS`/`DONE`/`CANCELLED`).

---

## 7. Thông báo

| Method | URL |
|---|---|
| GET | `/notifications/me?page=&size=` |
| POST | `/notifications/{id}/read` |
| POST | `/notifications/read-all` |

`data`: `{ total, unread, page, size, items:[{notificationId,title,content,type,read,sentAt}] }`.
Đọc đúng bảng `ThongBao` mà backend đang ghi (booking approved/rejected, payment success, refund
update, …). Đánh dấu đã đọc có kiểm tra owner (chống IDOR).

---

## 8. Hoàn tiền

| Method | URL | Ghi chú |
|---|---|---|
| GET | `/refunds/me?page=` | Danh sách của chính khách |
| GET | `/refunds/{id}` | 404 nếu không thuộc khách |
| PUT | `/refunds/{id}/bank` | Body: `bankName`, `bankAccountNumber`, `bankAccountHolder` |
| POST | `/refunds/{id}/cancel` | Khách tự hủy khi chưa được xử lý |

Yêu cầu hoàn tiền được tạo **tự động** khi hủy đơn đã thanh toán đủ điều kiện (xem
`POST /bookings/{id}/cancel`). Toàn bộ state machine tái sử dụng `RefundService` hiện có.

---

## 9. Bảo mật

- Mật khẩu vẫn BCrypt theo pipeline hiện tại (`TaiKhoanDAO.dangNhapKhachHang`).
- Không có secret nào (DB, PayOS, mail, JWT) được gửi xuống app; app chỉ biết base URL.
- Mọi endpoint có token đều kiểm tra role CUSTOMER và quyền sở hữu bản ghi.
- REST API không đọc/ghi HttpSession và không redirect JSP — luôn trả JSON.
- Không thêm bảng nào vào database cho tính năng mobile.

## 10. Thay đổi phía backend (tóm tắt)

Nghiệp vụ được hạ từ Servlet xuống Service để Web và Mobile dùng chung — Web giữ nguyên hành vi:

| Service mới | Tách ra từ |
|---|---|
| `service/booking/BookingCreationService` | `DatSanServlet.handleDatSan` |
| `service/booking/CourtAvailabilityService` | (mới, dùng lại pricing + overlap của luồng đặt sân) |
| `service/payos/BookingPaymentLinkService` | `DatSanServlet.createFacilityPayOSLink` + `stashAndPersistQr` |
| `service/payos/BookingPaymentStatusService` | `DatSanServlet.handlePayOSStatus` |
| `service/customer/CustomerCatalogService` | (mới, gom truy vấn danh mục, tránh N+1) |
