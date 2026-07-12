# PayOS Inline QR Checkout — Design

## Vấn đề

Hiện tại khi khách chọn thanh toán PayOS trong modal đặt sân (`DatSan.jsp`), nút "Xác nhận đặt" submit form HTML thường (`form.submit()`), khiến `DatSanServlet` xử lý rồi `resp.sendRedirect(checkoutUrl)` — trình duyệt rời hẳn khỏi web V-SPORT sang trang hosted của PayOS (`pay.payos.vn/...`) để hiện QR. Trải nghiệm bị gián đoạn: mất giao diện, mất context, và sau khi thanh toán/hủy phải redirect ngược lại qua `returnUrl`/`cancelUrl`.

Mục tiêu: giữ khách ở lại modal đặt sân trong suốt quá trình thanh toán — loading mượt → QR hiện tại chỗ → tự phát hiện thanh toán thành công → xác nhận và dẫn vào lịch sử đặt sân.

## Ngoài phạm vi

- Phương thức "Thanh toán tại quầy" (`paymentMethod=sau`) không thay đổi — vẫn giữ hành vi form submit + redirect + flash message như cũ, vì không có bước QR.
- Không thay đổi logic xác thực webhook, logic tính tiền, logic giữ chỗ tạm (`giu-cho-tam`), hay cơ chế tự hủy đơn quá hạn đã có sẵn.
- Không thêm cơ chế hủy đơn chủ động khi người dùng đóng modal giữa chừng (giữ nguyên: đơn ở trạng thái "Chờ thanh toán" tới khi hết hạn theo cơ chế tự động hiện có, hoặc khách tự hủy trong lịch sử đặt sân).

## Kiến trúc

### Backend — `DatSanServlet`

**1. Nhánh xử lý booking PayOS (trong `handleDatSan`, quanh dòng 658-696 hiện tại):**

Phân biệt request AJAX bằng header `X-Requested-With: XMLHttpRequest` (frontend sẽ luôn gửi header này khi submit qua `fetch`). Khi là AJAX và `paymentMethod=payos`:

- Sau khi `PayOSService.createCheckoutUrl(...)` thành công, KHÔNG `sendRedirect`. Thay vào đó set `resp.setContentType("application/json; charset=UTF-8")` và trả JSON:
  ```json
  {
    "success": true,
    "datSanId": 123,
    "qrCode": "<chuỗi VietQR từ CreatePaymentLinkResponse.getQrCode()>",
    "amount": 200000,
    "expiredAt": 1751123456
  }
  ```
  `qrCode` và `expiredAt` lấy từ object `CreatePaymentLinkResponse` mà `PayOSService.createCheckoutUrl` đang trả về dưới dạng `checkoutUrl` — cần sửa `PayOSService.createCheckoutUrl` để trả cả object thay vì chỉ String, hoặc thêm phương thức mới `createCheckoutSession(...)` trả một DTO nhỏ `{checkoutUrl, qrCode, expiredAt}` (giữ `createCheckoutUrl` cũ nguyên vẹn cho chỗ khác nếu có dùng, hoặc thay hẳn — kiểm tra lúc viết plan).
- Khi tạo link PayOS thất bại (exception): trả JSON `{"success": false, "error": "<thông báo lỗi hiện có>"}` với status 200 (frontend tự hiện lỗi trong modal), giữ nguyên logic hủy booking "Chờ thanh toán" đã có khi lỗi.
- Khi validate thất bại trước đó (sai giờ, trùng lịch, dịch vụ không hợp lệ, v.v.) và request là AJAX: trả JSON `{"success": false, "error": "..."}` thay vì `session.setAttribute("error", ...)` + redirect, để lỗi hiện ngay trong modal.
- Request không phải AJAX (fallback không có JS, hoặc `paymentMethod=sau`): giữ nguyên hành vi hiện tại (redirect).

**2. Endpoint mới — kiểm tra trạng thái thanh toán:**

Thêm case `GET /customer/payos-status?datSanId=X` vào `doGet` của `DatSanServlet`:

- Yêu cầu đăng nhập (dùng lại pattern check `user` hiện có), và `datSanId` phải thuộc về `user.getAccountId()` đang đăng nhập (không cho xem trạng thái đơn của người khác).
- Đọc `Lichdatsan` qua `lichDatSanDAO.getLichById(datSanId)`, map `TrangThai` sang JSON:
  ```json
  { "status": "pending" }   // "Chờ thanh toán"
  { "status": "paid" }      // "Đã xác nhận"
  { "status": "cancelled" } // "Đã hủy"
  ```
- Không có side-effect, chỉ đọc. Webhook (`PayOSWebhookServlet`, không đổi) tiếp tục là nơi duy nhất cập nhật trạng thái "Đã xác nhận".

### Frontend — `DatSan.jsp`

**1. `confirmBooking()` (dòng ~1790):**

Khi `isPayOS`:
- Build `FormData` từ `booking-form` (như hiện tại `injectServiceInputsIntoForm` đang chuẩn bị).
- `fetch(form.action, { method: 'POST', headers: {'X-Requested-With': 'XMLHttpRequest'}, body: formData })`.
- Response `success:false` → hiện thông báo lỗi trong `payment-info-payos` (đổi nội dung khối đang hiện "Đang kết nối PayOS..." thành text lỗi màu đỏ + cho phép bấm lại nút xác nhận).
- Response `success:true` → gọi `showPayOSQrState(data)`.

Khi không phải PayOS (`sau`): giữ nguyên `form.submit()` như hiện tại.

**2. State mới trong `checkoutPanel`: QR view**

Thêm 1 block ẩn (`id="payos-qr-view"`) trong `checkoutPanel`, cùng cấp với nội dung tóm tắt đơn hiện có. Có 3 sub-state chuyển đổi bằng show/hide + fade (dùng lại pattern `opacity-0`/`scale-95` transition có sẵn trong file, transition ~200-300ms):

- **Loading** (đã có sẵn spinner "Đang tạo mã QR..." trong nút — giữ nguyên, không cần thêm).
- **QR hiển thị**: `<canvas id="payos-qr-canvas">`, số tiền, đồng hồ đếm ngược tới `expiredAt` (cập nhật mỗi giây bằng `setInterval`), text hướng dẫn "Quét mã bằng app ngân hàng bất kỳ".
- **Thành công**: icon check (Material Symbols, animate scale-in), text "Thanh toán thành công", nút "Xem lịch sử đặt sân".
- **Hết hạn**: icon cảnh báo, text "Mã QR đã hết hạn, đơn đặt sân đã bị hủy", nút "Đặt lại".

`showPayOSQrState(data)`:
- Fade `checkoutPanel`'s nội dung form hiện tại ra, fade `payos-qr-view` vào.
- Vẽ QR: dùng thư viện `qrcode` (tải qua `<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js">` — nhúng 1 lần trong `<head>` hoặc cuối `DatSan.jsp`, cùng cách project đang nhúng script CDN khác), gọi `QRCode.toCanvas(canvas, data.qrCode, {width: 220})`.
- Lưu `datSanId`, `expiredAt` vào biến JS module-scope.
- Bắt đầu `setInterval` gọi `pollPayOSStatus()` mỗi 3s, và 1 `setInterval` riêng cập nhật đồng hồ đếm ngược mỗi giây.

`pollPayOSStatus()`:
- `fetch('/customer/payos-status?datSanId=' + id, {headers: {'X-Requested-With': 'XMLHttpRequest'}})`.
- `status: "paid"` → clear cả 2 interval, chuyển sang sub-state "Thành công".
- `status: "cancelled"` → clear cả 2 interval, chuyển sang sub-state "Hết hạn".
- `status: "pending"` → không làm gì, đợi lần poll sau.
- Nếu đồng hồ đếm ngược chạm 0 trước khi có kết quả `cancelled` từ server (chưa kịp có cơ chế tự hủy phía server xử lý) → tự chuyển sang sub-state "Hết hạn" ở client và dừng poll (server có thể vẫn hủy đơn ngay sau đó qua cơ chế tự động hiện có).

**3. Nút "Xem lịch sử đặt sân" (sub-state Thành công):**
- Gọi `closeBookingModal()` rồi `openHistoryModal()` (cả hai hàm đã có sẵn).

**4. Nút "Đặt lại" (sub-state Hết hạn):**
- Ẩn `payos-qr-view`, gọi `backToBookingForm()` (hàm có sẵn) để quay về `bookingFormPanel`, reset nút xác nhận về trạng thái ban đầu.

**5. Đóng modal giữa chừng khi đang ở QR view:**
- `closeBookingModal()` cần clear 2 interval poll/đếm ngược nếu đang chạy (thêm check ở đầu hàm), tránh leak khi modal đã đóng.

## Xử lý lỗi

- Fetch lỗi mạng khi tạo QR: hiện text lỗi trong `payment-info-payos`, cho bấm lại "Xác nhận đặt".
- Fetch lỗi mạng khi poll: bỏ qua lần đó (không đổi state), thử lại ở lần poll tiếp theo — không phá luồng vì đơn vẫn "Chờ thanh toán" ở server cho tới khi có webhook.
- QR library load lỗi (CDN down): hiện text lỗi trong QR view kèm nút thử tải lại, không crash toàn modal.

## Testing

- Đặt sân chọn PayOS → xác nhận: QR hiện trong modal, không rời trang, đồng hồ đếm ngược chạy đúng.
- Giả lập webhook gọi `/payos/webhook` với `code=00` khớp `datSanId`/`amount` → poll phát hiện `paid` trong ≤3s, chuyển sang sub-state Thành công, bấm nút vào đúng lịch sử đặt sân, đơn hiện "Đã xác nhận".
- Để hết `expiredAt` mà không thanh toán → client tự chuyển "Hết hạn"; xác nhận cơ chế tự hủy phía server (đã có) cập nhật đơn thành "Đã hủy" sau đó.
- Trường hợp lỗi tạo link PayOS (env thiếu, PayOS lỗi): lỗi hiện trong modal, không redirect, đơn "Chờ thanh toán" tạm được hủy tự động như logic hiện tại.
- Chọn "Thanh toán tại quầy": hành vi không đổi (vẫn submit + redirect như cũ).
- Đóng modal giữa lúc đang poll rồi thao tác khác trên trang: không còn network request poll chạy ngầm (kiểm tra qua DevTools Network).
