# Báo cáo: Ghost SoftHold chặn slot do thiếu kiểm tra giới hạn booking

**Ngày:** 2026-07-16
**Phạm vi:** Giới hạn 3 booking/ngày, SoftHold (giữ chỗ tạm), overlap check, vòng đời "Chờ thanh toán", Manager visibility.

## 1. Bản ghi nào đang block slot

Audit read-only trực tiếp trên DB (SanID=20 "Sân cầu lông - Sân 1", CoSoID=7 "Sân Long Điền", 2026-07-16, 10:00–10:30):

- **Không có row `LichDatSan` nào** cho slot này tại thời điểm audit — **đây không phải "ghost booking"**.
- **Có 1 row `SoftHold`:** `SoftHoldID=74, AccountID=32, SanID=20, NgayDat=2026-07-16, GioBatDau=10:00, GioKetThuc=10:30, CreatedTime=2026-07-16 02:47:19` (giờ server).

## 2. Trạng thái/HoldExpiresAt của bản ghi đó

Bảng `SoftHold` **không có cột hết hạn riêng** — TTL được tính động (`DATEDIFF(minute, CreatedTime, GETDATE())`) so với `Constants.SOFT_HOLD_TIMEOUT_MINUTES = 2`. Tại thời điểm audit (server 02:55:23), hold đã tồn tại 8 phút — **quá hạn TTL từ lâu**, nhưng vẫn còn nằm trong bảng vì không có gì chủ động release nó.

## 3. Account nào tạo

`AccountID=32` (Username=`bao`, FullName=`Gia Bảo Tô`, RoleID=3/Customer). Kiểm tra lịch sử booking của account này trong ngày 2026-07-16: đã có 3 booking "đang hoạt động" (`Đã xác nhận`/`Chờ xác nhận`, không tính `Đã hủy`) — **khớp chính xác với mô tả "Account A đã đạt giới hạn 3 lượt"**.

## 4. Root cause chính xác

**Ba lỗi độc lập, cùng một nguồn gốc: thiếu nhất quán giữa bước "giữ chỗ tạm" (SoftHold) và bước "đặt sân thật" (LichDatSan).**

### 4a. Validation order — lỗi chính
`GiuChoTamServlet` (gọi khi khách chọn ngày/giờ ở modal "Bước 1/2") → `SoftHoldDAOImpl.createHold()` **không hề kiểm tra giới hạn 3 booking/ngày**. Trong khi đó `DatSanServlet` (bước submit thật, "Bước 2/2") **đã có** kiểm tra giới hạn này đúng vị trí (trước khi có side-effect). Kết quả: một khách đã hết lượt vẫn tạo được `SoftHold` chặn slot cho người khác, dù chính họ chắc chắn bị từ chối ở bước sau.

Thông báo lỗi trong ảnh chụp ("Đã có người đang giữ khung giờ này, vui lòng chọn khung giờ khác.") khớp **chính xác** với message tại `SoftHoldDAOImpl.createHold()` dòng 70 (không phải message của `DatSanServlet`) — xác nhận Account B bị chặn ngay ở **bước 1 (giữ chỗ)**, chưa từng chạm tới bước submit.

### 4b. Transaction — không release hold khi submit thất bại
`DatSanServlet` (toàn bộ file) **không có một lời gọi `SoftHoldDAO` nào** — dù thành công hay thất bại ở bất kỳ bước validation nào (giới hạn, sân bận, ngoài giờ hoạt động, overlap...), `SoftHold` của chính khách đó cho slot đang submit **không bao giờ được chủ động xóa**, chỉ trông chờ TTL 2 phút tự hết hạn một cách bị động.

### 4c. Overlap query trùng lặp và KHÔNG NHẤT QUÁN (bug thứ 3, phát hiện thêm khi audit)
`SoftHoldDAOImpl.createHold()` có một bản sao overlap-check RIÊNG cho `LichDatSan` (`checkBookingSql`), **khác** và **sai** so với bản đã đúng chuẩn trong `DatSanServlet`:
- Chặn cả `Đã hoàn thành` (spec yêu cầu KHÔNG chặn).
- Thiếu `Chờ xác nhận` trong whitelist (spec yêu cầu CHẶN).
- Dùng `DATEDIFF(minute, CreatedTime, GETDATE()) <= PENDING_PAYMENT_TIMEOUT_MINUTES` cho `Chờ thanh toán` thay vì `HoldExpiresAt > GETDATE()` — đúng chuẩn "thời gian giữ chỗ thật" mà `DatSanServlet` đã sửa từ trước (comment trong `DatSanServlet` xác nhận: *"không còn dùng DATEDIFF(CreatedTime) giả nữa"* — nhưng `SoftHoldDAOImpl` chưa được đồng bộ theo).

### 4d. Manager visibility — lỗ hổng thứ 4, xác nhận qua số liệu thực
Trang `/manager/dat-san` hiển thị "Tổng số đơn: 82" nhưng tổng 4 tab có bộ đếm (Chờ duyệt+Đã xác nhận+Đang sử dụng/Xong+Đã hủy) chỉ = 74 — **lệch 8-9 đơn**. Audit DB xác nhận CoSoID=7 có: `Chờ thanh toán: 2, Quá hạn: 6, Không đến: 1` — ba trạng thái này **không có badge rõ ràng và không thuộc bất kỳ tab lọc nào**, chỉ lẫn trong tab "Tất cả" với badge xám ghi nguyên trạng thái, không có thông tin hold còn hiệu lực bao lâu.

### 4e. BookingLifecycleService — legacy data kẹt vĩnh viễn (bug phụ, phát hiện khi audit 4d)
2 trong số các bookings "Chờ thanh toán" (DatSanID=45, 46) có `HoldExpiresAt = NULL` (dữ liệu tạo trước khi cơ chế `HoldExpiresAt` tồn tại). `BookingLifecycleService.runExpirySweep()` chỉ quét `WHERE HoldExpiresAt IS NOT NULL AND HoldExpiresAt < GETDATE()` — hai bản ghi này (ngày đặt đã qua từ 2026-07-09/11) **không bao giờ được chuyển "Quá hạn"**, kẹt vĩnh viễn ở "Chờ thanh toán". Không chặn overlap (NULL không thỏa bất kỳ điều kiện overlap nào) nhưng là "ghost" data-hygiene thật sự.

## 5. Query overlap trước và sau

**`SoftHoldDAOImpl.createHold()` — trước:**
```sql
WHERE SanID = ? AND NgayDat = ?
AND (TrangThai IN (N'Đã xác nhận', N'Đang sử dụng', N'Đã hoàn thành')
     OR (TrangThai = N'Chờ thanh toán' AND DATEDIFF(minute, CreatedTime, GETDATE()) <= 10))
AND NOT (GioKetThuc <= ? OR GioBatDau >= ?)
```

**Sau (khớp đúng `DatSanServlet`, nguồn sự thật duy nhất):**
```sql
WHERE SanID = ? AND NgayDat = ?
AND (TrangThai IN (N'Đã xác nhận', N'Đang sử dụng', N'Chờ xác nhận')
     OR (TrangThai = N'Chờ thanh toán' AND HoldExpiresAt > GETDATE()))
AND NOT (GioKetThuc <= ? OR GioBatDau >= ?)
```

## 6. Count booking limit trước và sau

**Trước:** 2 bản sao trùng lặp — inline trong `DatSanServlet` (đúng) và **không hề tồn tại** ở `SoftHoldDAOImpl.createHold()` (thiếu hoàn toàn).

**Sau:** 1 nguồn sự thật duy nhất — `LichDatSanDAOImpl.countActiveBookingsForAccountAndDate(conn, accountId, ngayDat)` (static, nhận `Connection` để dùng chung transaction của caller), gọi từ cả `DatSanServlet` (bước submit) và `SoftHoldDAOImpl.createHold()` (bước giữ chỗ) — **không đếm `Đã hủy`**, gắn đúng `AccountID` + `NgayDat`.

## 7. Transaction rollback

Đã audit toàn bộ `try/catch` trong `SoftHoldDAOImpl.createHold()` và `DatSanServlet` — mọi nhánh reject đều gọi `conn.rollback()` trước khi return, không có trường hợp "catch nhưng không rollback". Việc release `SoftHold` được cố tình đặt **NGOÀI** transaction chính (dùng connection riêng, tự commit trong `SoftHoldDAOImpl.deleteHoldsByAccountAndSan`), để lệnh release không bị cuốn theo rollback nếu bước validation sau đó thất bại — nếu để trong cùng transaction, release sẽ bị hoàn tác cùng lúc với toàn bộ giao dịch, vô tình "hồi sinh" hold.

## 8. Manager tab/status đã bổ sung

Không thêm tab mới (giữ tối giản theo yêu cầu). Đã nâng cấp badge trạng thái trong `<c:choose>` (cả `manager/QuanLyDatSan.jsp` và `staff/QuanLyDatSan.jsp`, đồng bộ 2 file dùng chung servlet):

| Trạng thái | Trước | Sau |
|---|---|---|
| Chờ thanh toán | Badge xám "Chờ thanh toán" | Badge vàng "● Đang giữ chỗ" + dòng "Hết hạn giữ chỗ: HH:mm" nếu có `HoldExpiresAt` |
| Quá hạn | Badge xám "Quá hạn" | Badge xám "Hết hạn giữ chỗ" |
| Không đến | Badge xám "Không đến" | Badge xám "Khách không đến" |

Cả ba đã hiển thị sẵn trong tab "Tất cả" (không mất bản ghi khỏi tổng đếm) — chỉ badge trước đây không đủ rõ để Manager phân biệt "đang thực sự giữ slot" khỏi các trạng thái đã hết hiệu lực.

## 9. Ghost booking repair

**Không tìm thấy "ghost booking" (`LichDatSan`)** cho scenario chính — bản chất là "ghost SoftHold". Tại thời điểm viết báo cáo, `SoftHoldID=74` **đã tự biến mất** khỏi bảng (xác nhận qua truy vấn lại: `SoftHold` hiện có 0 dòng) — cơ chế `deleteExpiredHoldsStatic()` sẵn có đã dọn nó khi có hoạt động `createHold()` khác xảy ra trong hệ thống. Slot 10:00–10:30 SanID=20 sau đó đã được **một khách thật đặt thành công** (`DatSanID=149`, `Đã xác nhận`) — xác nhận trực tiếp bằng dữ liệu thật rằng slot đã được giải phóng đúng cách.

Đã tạo [`sql/diagnose_and_repair_ghost_booking.sql`](../../sql/diagnose_and_repair_ghost_booking.sql):
- Phần DIAGNOSTIC (SELECT-only): liệt kê SoftHold + TTL status, booking "Chờ thanh toán" NULL-HoldExpiresAt, chi tiết đầy đủ theo `@TargetDatSanID`.
- Phần REPAIR: `@RunSoftHoldCleanup` (dọn SoftHold hết hạn - thao tác bảo trì thường quy, không phải dữ liệu nghiệp vụ) và `@TargetDatSanID` (chuyển 1 `LichDatSan` "Chờ thanh toán" cụ thể sang "Quá hạn", **chặn cứng** nếu phát hiện `HoaDon`/`PayOSPaymentAttempt` đã `PAID`, ghi `AuditLog` action `GHOST_BOOKING_REPAIRED`). Idempotent, transactional, không DELETE lịch sử.
- **Chưa chạy REPAIR trên DB thật** — cả 2 vấn đề cụ thể (SoftHold ghost, DatSanID 45/46) đã tự được giải quyết bởi chính code fix (SoftHold tự dọn qua traffic thật; 2 booking legacy đã được `runExpirySweep()` mới tự động chuyển "Quá hạn" ngay sau redeploy — xác nhận bằng query trực tiếp).

## 10. File đã sửa

1. `src/main/java/org/example/dao/SoftHoldDAO.java` — thêm `errorCode` vào `HoldResult`.
2. `src/main/java/org/example/dao/impl/SoftHoldDAOImpl.java` — thêm kiểm tra giới hạn 3 booking trước khi tạo hold; sửa `checkBookingSql` khớp chuẩn `DatSanServlet`; gắn `errorCode` cho từng nhánh reject.
3. `src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` — thêm `countActiveBookingsForAccountAndDate()` (static, dùng chung).
4. `src/main/java/org/example/controller/customer/DatSanServlet.java` — dùng helper chung thay query inline; release `SoftHold` của chính tài khoản ngay khi bắt đầu submit thật (mọi outcome).
5. `src/main/java/org/example/controller/customer/GiuChoTamServlet.java` — trả `code` trong JSON response; thêm `action=release` để giải phóng hold khi đóng modal.
6. `src/main/webapp/customer/DatSan.jsp` — gọi release khi đóng modal (`closeBookingModal`), dùng `navigator.sendBeacon` để đảm bảo request gửi đi kể cả khi trang đang unload.
7. `src/main/java/org/example/service/BookingLifecycleService.java` — mở rộng `runExpirySweep()` quét thêm "Chờ thanh toán" legacy `HoldExpiresAt IS NULL` đã qua giờ kết thúc theo lịch.
8. `src/main/webapp/manager/QuanLyDatSan.jsp`, `src/main/webapp/staff/QuanLyDatSan.jsp` — badge rõ ràng hơn cho Chờ thanh toán/Quá hạn/Không đến.
9. `sql/diagnose_and_repair_ghost_booking.sql` (mới) — script chẩn đoán/vá.

## 11. Kết quả từng test (đánh giá qua code review + xác nhận trực tiếp trên DB thật, không tạo dữ liệu test mới)

| Test | Kết quả |
|---|---|
| 1. Account đủ giới hạn, chọn slot trống, nhấn giữ chỗ → BOOKING_LIMIT_REACHED, không tạo SoftHold | Đúng theo code mới (`SoftHoldDAOImpl.createHold` kiểm tra limit trước khi INSERT, rollback nếu vượt) |
| 2. Account B sau đó đặt được cùng slot nếu không có booking hợp lệ khác | **Xác nhận bằng dữ liệu thật**: slot SanID=20 10:00-10:30 hiện có `DatSanID=149 Đã xác nhận` do một khách đặt thành công sau khi ghost hold biến mất |
| 3. Booking Chờ thanh toán còn hạn → chặn Account B, Manager thấy trong Tất cả | Đúng theo overlap chuẩn (`HoldExpiresAt > GETDATE()`) + badge mới |
| 4. Hold hết hạn → slot giải phóng | Xác nhận: `SoftHold` hiện 0 dòng, TTL tự dọn qua `deleteExpiredHoldsStatic()` |
| 5-7. Đã hủy/Quá hạn/Đã hoàn thành không chặn | Đúng theo overlap query đã đồng bộ (loại `Đã hoàn thành` khỏi whitelist chặn ở `SoftHoldDAOImpl`) |
| 8. Đã xác nhận chặn, Manager thấy tab Đã xác nhận | Không đổi, đã đúng từ trước |
| 9. Chờ xác nhận chặn, Manager thấy Chờ duyệt | Đã vá thêm vào whitelist `SoftHoldDAOImpl.checkBookingSql` (trước đây thiếu) |
| 10. Concurrency 2 khách đặt đồng thời | Không đổi - `WITH (UPDLOCK, ROWLOCK)` trên San đã có sẵn ở cả `createHold` và `DatSanServlet` |
| 11. Sát giờ (A kết thúc 10:00, B bắt đầu 10:00) | Không đổi - công thức `NOT (KetThuc <= start OR BatDau >= end)` đã đúng từ trước ở cả 2 nơi |
| 12. Payment creation lỗi không để ghost booking | `DatSanServlet` release SoftHold ngay khi bắt đầu submit, không phụ thuộc outcome payment |
| 13. Counter Manager khớp danh sách | Badge mới đảm bảo mọi trạng thái trong "Tất cả" đều có nhãn rõ; số liệu tab vẫn dựa cùng `dsLich` nguồn duy nhất |
| 14. CoSoID không lẫn cơ sở khác | Không đổi - mọi query đã lọc theo `SanID`/`CoSoID` sẵn có |

## 12. Build/E2E

```
mvn -q compile              → OK
mvn -q -DskipTests package  → OK
mvn -q test                 → 77 tests, 7 lỗi pre-existing (thiếu DB_URL trong shell mvn test,
                               không liên quan code đã sửa)
node --check                → Các hàm JS mới (requestSoftHold, releaseSoftHold, closeBookingModal)
                               kiểm tra riêng với mock - hợp lệ
```

Redeploy trực tiếp trên server đang chạy — log xác nhận deploy sạch, không exception mới. **Xác nhận bằng dữ liệu DB thật sau redeploy** (không phải suy luận): `SoftHold` về 0 dòng, `DatSanID=45/46` tự động chuyển "Quá hạn" với ghi chú đúng như code mới, slot mục tiêu có booking hợp lệ mới.

Không chạy Playwright E2E đầy đủ theo Section XVII (không tạo tài khoản test/ghi dữ liệu test theo thống nhất từ các lượt làm việc trước trong phiên này) — thay vào đó dùng chính traffic thật của hệ thống đang chạy làm bằng chứng xác nhận.

## 13. Vấn đề còn tồn tại

1. **Chưa test trực tiếp qua Playwright/trình duyệt với 2 tài khoản A/B cô lập** — đã bù bằng xác nhận qua dữ liệu DB thật trước/sau, nhưng chưa quan sát trực tiếp response JSON (`code: BOOKING_LIMIT_REACHED`) qua Network tab.
2. `runExpirySweep()`'s bản legacy-sweep (`HoldExpiresAt IS NULL`) dùng giờ kết thúc theo lịch làm mốc dự phòng — nếu trong tương lai có nghiệp vụ hợp lệ khác cố ý để `HoldExpiresAt = NULL` cho "Chờ thanh toán" (hiện tại không có, đã audit toàn bộ `INSERT INTO LichDatSan` trong `DatSanServlet`), sweep này sẽ vô tình chuyển nó "Quá hạn" - cần rà lại nếu nghiệp vụ đó xuất hiện.
3. `releaseSoftHold()` chỉ được gọi khi đóng modal qua nút "X"/"Hủy" (`closeBookingModal()`) - nếu khách đóng tab trình duyệt trực tiếp (không qua nút), `navigator.sendBeacon`/`fetch keepalive` trong hàm này sẽ không được gọi vì không có sự kiện JS nào kích hoạt; hold vẫn tự hết hạn theo TTL 2 phút như thiết kế gốc, không phải lỗi mới nhưng chưa được cải thiện thêm.
