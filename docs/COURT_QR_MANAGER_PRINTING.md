# QR-02 — Manager quản lý, tạo ảnh, tải và in mã QR theo từng sân

Nền tảng: QR-01 (`f275065`) + QR-01B hardening (bundled vào `d4b92c7`/`9b6061d`, doc `54f09a1`).
Không viết lại domain QR, không đổi token strategy, không đổi migration.

## 1. Route Manager

| Route | Method | Mục đích |
|---|---|---|
| `/manager/ma-qr-san` | GET | Trang danh sách (HTML), hoặc `?ajax=1` trả JSON |
| `/manager/ma-qr-san` | POST | Action: `create`, `enable`, `disable`, `regenerate`, `batchCreate` |
| `/manager/ma-qr-san-anh` | GET | Ảnh PNG (`?sanId=&mode=preview\|download`) |
| `/manager/ma-qr-san-in` | GET | Trang in một mã (`?sanId=`) |
| `/manager/ma-qr-san-in-hang-loat` | GET/POST | Trang in hàng loạt (`sanIds[]`, `layout=1\|2\|4`) |

Không có `/api/manager/...` prefix riêng trong project - theo đúng convention hiện có (`NhanSuManagerServlet` dùng `?ajax=1` trên cùng route GET).

## 2. Quyền

`FilterQuyenManager` (`@WebFilter("/manager/*")`) đã tự động bảo vệ mọi route trên - kiểm tra session `"user"` tồn tại và `roleId == Constants.ROLE_MANAGER`. Không cần thêm capability gate riêng (QR là chức năng quản lý sân cơ bản, không phải module tùy chọn).

## 3. Session trust boundary

Mọi servlet QR-02 lấy `coSoId`/`accountId` CHỈ từ:
```java
TaiKhoan manager = (TaiKhoan) request.getSession().getAttribute("user");
int coSoId = manager.getCoSoId();
int actorAccountId = manager.getAccountId();
```
Không bao giờ đọc từ `request.getParameter("coSoId"/"managerCoSoId"/"actorAccountId")`. Xác nhận qua TEST07 (`SanQRManagerFeatureTest`): Manager cơ sở khác gọi `disable` trên sân không thuộc mình → `FORBIDDEN`, không side-effect.

## 4. DTO

`SanQRManagerDTO` (`org.example.dto.qr`) — list/detail: **không có raw token**, short code chỉ ở dạng mask (`VS-••••XX`) trong list. Full short code chỉ set khi trả detail (hiện tại UI chưa cần hiển thị full code ở drawer — có thể bổ sung ở bản sau nếu nghiệp vụ cần). Cờ hành động (`canCreate/canEnable/canDisable/canRegenerate/canPrint`) tính sẵn phía server dựa theo trạng thái QR, JSP/JS chỉ hiển thị nút tương ứng, không tự suy luận quyền phía client.

## 5. List/filter/pagination

Danh sách sân lấy qua `SanService.getSansByCoSo(coSoId)` (đã giới hạn theo CoSoID tại tầng DAO). Không phân trang server-side riêng cho QR (số sân một cơ sở thường nhỏ, ~vài chục) - filter (tên sân, môn thể thao, trạng thái QR/sân) áp dụng phía server trên tập đã giới hạn theo CoSoID, không tải chéo cơ sở khác bất kể trường hợp nào.

## 6. QR lifecycle UI

Action whitelist cố định: `create|enable|disable|regenerate|batchCreate` — không có `action=updateStatus&status=...` tự do. Server (`SanQRService`) tự quyết định transition hợp lệ; Servlet chỉ forward tham số `sanId` + action, map `Result.errorCode` sang HTTP status (`NOT_FOUND→404`, `FORBIDDEN→403`, `INVALID_TRANSITION/CONFLICT→409`, `SYSTEM→500`).

Regenerate có modal cảnh báo bắt buộc đọc trước khi xác nhận, disable double-click qua cờ `regenBusy` phía client + idempotent phía server.

REVOKED là terminal — drawer chỉ hiển thị "Mã đã bị vô hiệu hóa vĩnh viễn, chỉ có thể xem lịch sử", không có nút enable/regenerate nào render ra cho trạng thái này (JS kiểm tra `statusText === 'Đã vô hiệu hóa'` trước khi build actions).

"Vô hiệu hóa vĩnh viễn" (ACTIVE/DISABLED → REVOKED) **KHÔNG được triển khai trong QR-02** — không có nghiệp vụ này trong `SanQRService` hiện tại và không có nút xóa cứng nào trong UI, đúng theo lựa chọn "để ngoài phạm vi" khi task cho phép.

## 7. Batch create

`SanQRManagerServlet.batchCreate()`: lấy toàn bộ sân của CoSoID, lọc ra sân CHƯA có QR bằng `SanQRService.findExistingBySanIds`, gọi `getOrCreate` cho từng sân — một sân lỗi không làm hỏng kết quả các sân khác (partial success), trả về `{created, alreadyExisted, failed, errors[]}`. Không bao giờ regenerate QR đã tồn tại. Xác nhận qua TEST08.

## 8. ZXing / dependency

Không thêm dependency mới. Dự án đã có `com.google.zxing:core/javase:3.5.3` (dùng cho VietQR PayOS) và `org.example.util.QrCodeRenderer.toPngBytes(payload, size)` — tái sử dụng trực tiếp cho ảnh QR sân.

## 9. Public URL strategy

```
{scheme}://{host}:{port}{contextPath}/qr/{token}
```
Suy từ chính `HttpServletRequest` hiện tại (không có cấu hình `APP_PUBLIC_BASE_URL` trong project). Route `/qr/{token}` (resolve công khai cho Customer quét) **thuộc phạm vi QR-03, KHÔNG được implement ở đây** — đây là chủ ý, không phải thiếu sót: ảnh QR sinh ra ở QR-02 chỉ "hoạt động đầy đủ" sau khi QR-03 xong route đó, nhưng ảnh vẫn sinh/tải/in đúng ngay bây giờ.

## 10. PNG generation

`SanQRImageServlet` (`/manager/ma-qr-san-anh`): nhận `sanId`, tự tra `San`→ownership (`SanService.getSanById` ném exception nếu sai cơ sở) → tra `SanQR` hiện có qua `SanQRService.findReadOnlyBySanId` (đọc thuần, không lock/không tạo mới) → build public URL → `QrCodeRenderer.toPngBytes`. `mode=preview` (360px, inline) hoặc `mode=download` (1024px, attachment, `Cache-Control: no-store`). Không nhận token thô qua query ở bất kỳ đâu.

## 11. PNG decode test

`SanQRManagerFeatureTest.test02_pngDecodesToCorrectPublicUrl`: sinh PNG thật bằng `QrCodeRenderer`, decode ngược bằng ZXing `MultiFormatReader`, xác nhận nội dung decode **khớp chính xác** URL đã encode, path sau `/qr/` chỉ chứa đúng token (không lẫn SanID/CoSoID/short code). `test03` xác nhận sau `regenerate`, ảnh QR mới decode ra URL mới, còn token cũ resolve `REVOKED`.

## 12. Download endpoint

`?mode=download` → `Content-Disposition: attachment; filename="VSPORT-{ten-san-sanitized}-QR.png"` (tên file khử dấu tiếng Việt + loại ký tự nguy hiểm bằng regex, không dùng tên sân thô làm path). `Cache-Control: no-store` để tránh cache token cũ sau regenerate.

## 13. Print one

`SanQRPrintServlet.Single` (`/manager/ma-qr-san-in`) → `MaQrSanIn.jsp`: layout tối giản (không sidebar/header Manager), `.no-print` ẩn toolbar khi in, `@page { size: 100mm 150mm }`, chỉ hiển thị tên cơ sở/sân/môn, ảnh QR, short code, hướng dẫn — không in SanID/CoSoID/AccountID/token dạng text/booking/payment/audit.

## 14. Batch print

`SanQRPrintServlet.Batch` (`/manager/ma-qr-san-in-hang-loat`): nhận `sanIds[]`, kiểm tra lại ownership TỪNG sanId qua `SanService.getSanById` — sân sai cơ sở bị **bỏ qua âm thầm** (không lộ, không lỗi 500 hỏng cả batch). Layout `1/2/4 mã mỗi trang A4` qua CSS grid + `page-break-after`.

## 15. Ownership tests

TEST07 (`SanQRManagerFeatureTest`): Manager cơ sở khác gọi action trên sân không thuộc mình → `FORBIDDEN`, QR giữ nguyên trạng thái (không side-effect). `SanQRImageServlet`/`SanQRPrintServlet.Single` dùng `SanService.getSanById(sanId, coSoId)` (ném `ForbiddenException`/`IllegalArgumentException` nếu sai cơ sở) → map sang HTTP 403. `SanQRPrintServlet.Batch` bỏ qua im lặng thay vì lỗi.

## 16. HTTP/Tomcat tests

**Chưa chạy qua Tomcat thật trong phiên này** (môi trường hiện tại không khởi động được SmartTomcat/servlet container) — xác nhận qua unit/service-level test trên DB thật (`SanQRManagerFeatureTest`, 8 test) thay vì HTTP end-to-end. Đây là giới hạn cần Manager/QA xác nhận thủ công sau khi deploy: đăng nhập Manager thật, mở `/manager/ma-qr-san`, thử tạo/tắt/bật/regenerate/tải PNG/in qua trình duyệt.

## 17. Responsive results

`MaQrSan.jsp`: desktop dùng `<table>` (`.desktop-table`, ẩn dưới 640px), mobile dùng card list (`.mobile-cards`, ẩn từ 641px). Drawer full-width dưới 640px. Action buttons chính (batch create/print, đóng drawer) ở `h-11` (44px) theo chuẩn touch target. Không kiểm tra bằng browser automation trong phiên này (static CSS review only) — cần xác nhận trực quan ở 375/390/412/430/768px trước khi release.

## 18. Print/PDF results

Chưa test in vật lý hoặc Save-as-PDF thật trong phiên này (không có Tomcat chạy để mở trình duyệt). CSS `@media print`/`@page` đã viết theo đúng pattern `HoaDonPrint.jsp` đã có trong project (đã qua sản xuất thật cho hóa đơn) — rủi ro thấp nhưng chưa xác nhận thực nghiệm.

## 19. QR-specific test result

`SanQRManagerFeatureTest`: **8/8 PASS**, chạy cùng `SanQRServiceSmokeTest` (24/24 PASS) → tổng **32/32 PASS**, ổn định qua 2 lần chạy liên tiếp.

## 20. Full Maven test result

**176/177 PASS**. 1 lỗi còn lại là `ResetSessionStateTest.resetSession` (`Invalid column name 'TrangThai'`) — lỗi có sẵn từ trước, không liên quan QR, đã xác nhận từ QR-01B, không sửa trong QR-02.

## 21. Package result

`mvn package -DskipTests`: **PASS**, tạo `target/Backend_java-1.0-SNAPSHOT.war`.

## Còn lại cho QR-03

- Route public `/qr/{token}` (resolve công khai) + `resolveActiveShortCode` UI.
- Camera Customer, icon quét QR.
- Nhập short code dự phòng phía Customer.
- Xác thực HTTP/Tomcat + in vật lý thực nghiệm cho toàn bộ QR-02 (mục 16/18 ở trên).
- Cân nhắc thêm nghiệp vụ "Vô hiệu hóa vĩnh viễn" nếu Manager thực sự cần (hiện để ngoài phạm vi).
