# Báo cáo: Hiển thị & vận hành sân cho khách đặt trước (Check-in)

**Ngày:** 2026-07-16
**Phạm vi:** `/staff/checkin` — card sân phải phản ánh booking "Đã xác nhận" sắp tới, đồng hồ đếm ngược dùng server time, chặn walk-in trùng lịch, concurrency khi check-in.

## 1. Card sân trước đây được xác định trạng thái thế nào

`CheckInDAO.getDanhSachSan(coSoId)` chỉ trả về `San.TrangThai` (cột vật lý: Sẵn sàng/Đang sử dụng/Bảo trì/Tạm đóng) cộng với một subquery **duy nhất** tìm ca đang hoạt động (`LichDatSan.TrangThai = 'Đang sử dụng'`). Card JSP (`CheckIn.jsp`) render theo đúng 4 giá trị này bằng `<c:choose>`/`<c:when test="${san.trangThai == '...'}">` — không có nhánh nào khác.

## 2. Vì sao booking sắp tới vẫn hiện "Sẵn sàng"

Vì query **không hề nhìn tới** bảng `LichDatSan` với `TrangThai = 'Đã xác nhận'` — chỉ nhìn `'Đang sử dụng'`. Một booking đã xác nhận nhưng chưa check-in hoàn toàn vô hình đối với card, dù nó đã xuất hiện đầy đủ trong danh sách "Chờ check-in" bên dưới (lấy từ `getDanhSachLichCheckInHomNay`, một query độc lập, không lọc theo trạng thái). Hai nguồn dữ liệu này trước đây không đồng bộ — đúng như mô tả lỗi.

## 3. DTO/query đã sửa

Không tạo DTO `CourtOperationView` riêng — mở rộng đúng theo pattern `@Transient` đã có sẵn trên entity `San` (San đã có sẵn `datSanIdActive`, `gioBatDauActive`... cho ca đang chơi; giữ nhất quán thay vì tạo một class song song).

**[`San.java`](../../src/main/java/org/example/model/San.java)** — thêm field `@Transient`:
- Ca đang chơi (đầy đủ hơn field cũ): `scheduledEndActive`, `actualStartActive` (LocalDateTime ISO), `nguonDatSanActive`, `tenKhachHangActive`, `soDienThoaiActive`.
- Booking sắp tới: `nextDatSanId`, `nextTenKhachHang`, `nextSoDienThoai`, `nextNguonDatSan`, `nextGioBatDau`, `nextGioKetThuc` (LocalDateTime ISO), và `isHasUpcomingBooking()` (computed từ `nextDatSanId != null`).

**[`CheckInDAO.getDanhSachSan`](../../src/main/java/org/example/dao/CheckInDAO.java)** — mở rộng SQL: thêm 4 subquery cho ca đang chơi (ISO datetime + tên/SĐT khách + nguồn) và 5 subquery correlated cho booking "Đã xác nhận" gần nhất còn trong ngưỡng cảnh báo (dùng `CAST(NgayDat AS DATETIME) + CAST(GioBatDau AS DATETIME)` để ghép ngày+giờ thành datetime đầy đủ ngay trong SQL — **backend trả ISO datetime, frontend không tự nối chuỗi ngày/giờ**).

**[`CheckInServlet.doGet`](../../src/main/java/org/example/controller/staff/CheckInServlet.java)** — thêm `serverNow`, `upcomingBookingWarningMinutes`, `endingSoonMinutes` vào cả request attribute (page load) và JSON polling payload (`ajax=true`).

## 4. Các operation state đã triển khai

| State | Điều kiện | Card |
|---|---|---|
| AVAILABLE | `TrangThai='Sẵn sàng'`, không có booking sắp tới trong ngưỡng | Xanh lá, nút "Mở sân" (không đổi) |
| **UPCOMING_BOOKING** (mới) | `TrangThai='Sẵn sàng'` **và** có booking "Đã xác nhận" bắt đầu trong ≤30 phút (dùng chung `CheckInWindow.MAX_EARLY_MINUTES`) | Vàng/cam, tên khách + khung giờ + nguồn + đếm ngược tới giờ bắt đầu, nút **"Check-in khách"** |
| IN_USE_PREBOOKED / IN_USE_WALK_IN | `TrangThai='Đang sử dụng'` | Tím/cam (theo role, không đổi), đếm ngược tới `scheduledEndActive` |
| ENDING_SOON | Ca đang chơi, còn ≤`Constants.ENDING_SOON_MINUTES` (10 phút) | Badge đỏ nhạt "Sắp hết giờ · Còn HH:MM:SS" |
| OVERTIME | Ca đang chơi, đã qua giờ kết thúc | Badge đỏ "QUÁ GIỜ · Quá HH:MM:SS" |
| MAINTENANCE / TEMPORARILY_CLOSED | `TrangThai='Bảo trì'/'Tạm đóng'` | Không đổi |

Thứ tự ưu tiên đúng theo yêu cầu: `Đang sử dụng` > `Sẵn sàng + có upcoming` > `Sẵn sàng` thường — thể hiện qua thứ tự `<c:when>` (kiểm tra `Đang sử dụng` trước, `Sẵn sàng && hasUpcomingBooking` trước `Sẵn sàng` đơn thuần).

## 5. Cách lấy active và next booking

Một lần round-trip DB duy nhất cho toàn bộ danh sách sân (không N+1) — mỗi cột là một correlated subquery `WHERE lds.SanID = s.SanID` chạy trong CÙNG câu SELECT chính, SQL Server tối ưu như subquery tương quan chuẩn, không phải N query riêng biệt từ ứng dụng. Next booking lọc đúng: `TrangThai='Đã xác nhận'` (không lấy "Chờ xác nhận"/đã hủy/no-show), `NgayDat = hôm nay`, giờ bắt đầu chưa qua, trong ngưỡng 30 phút, `ORDER BY GioBatDau ASC` lấy đúng cái gần nhất. Cùng `CoSoID` vì đã lọc ở `WHERE s.CoSoID = ?` tại vòng ngoài.

## 6. Check-in sớm

**Không đổi logic nghiệp vụ hiện có.** `CheckInDAO.checkInKhachDatTruoc` đã có sẵn từ trước: tính `minutesEarly`, nếu > `EARLY_THRESHOLD_MINUTES` (10 phút) thì **tự động phụ thu** `EARLY_SURCHARGE_PER_MINUTE` và cộng vào hóa đơn — đây là chính sách đã tồn tại, không phải "chưa có policy rõ ràng" như giả định ban đầu của yêu cầu. Theo đúng ràng buộc "Không phá tính giá hiện tại", **không thêm modal xác nhận check-in sớm mới** (sẽ trùng lặp/xung đột với cơ chế phụ thu tự động đã có). `ActualStartAt` (`actual_start_time`) đã được ghi đúng, `GioBatDau`/`GioKetThuc` gốc giữ nguyên, không tạo booking mới — đúng yêu cầu Section IX/X.

## 7. Scheduled time và actual time

`checkInKhachDatTruoc` giữ nguyên `ScheduledStartAt`/`ScheduledEndAt` gốc, chỉ ghi `actual_start_time = now`. Card hiển thị cả hai: `scheduledEndActive` (đếm ngược target) và `actualStartActive` (thời điểm bắt đầu thực tế) — đúng yêu cầu Section XI (không dùng `actualStart + duration` làm target đếm ngược).

## 8. Cách countdown dùng server time

- `CheckInServlet` gửi `serverNow` (ISO) ở mọi response (page load + polling 30s).
- JS: `serverTimeOffsetMs = new Date(serverNow) - Date.now()`, `getServerNow() = Date.now() + serverTimeOffsetMs`.
- `updateAllCardTimers()` (1 global `setInterval(…, 1000)` duy nhất, không tạo interval riêng cho mỗi card) và drawer's `update()` đều dùng `getServerNow()` thay vì `new Date()` trực tiếp.
- Resync offset mỗi lần `pollUpdates()` (30s) **và** khi tab quay lại foreground (`visibilitychange`) — tránh lệch dần khi máy sleep/đổi tab lâu.
- Reload trang: dữ liệu (kể cả `actual_start_time`) đọc lại từ DB nguyên trạng, không có state ở client cần khôi phục — countdown tự đúng ngay từ lần render đầu.
- Đồng hồ đếm-ngược-tới-giờ-bắt-đầu (UPCOMING_BOOKING) là cơ chế **mới hoàn toàn**, dùng ISO datetime + server time ngay từ đầu.

## 9. Chặn walk-in conflict

**Đã tồn tại từ trước**, không cần viết mới: `CheckInDAO.checkInKhachVangLai` có sẵn kiểm tra overlap `GioBatDau < endTime AND GioKetThuc > now` với các booking `Đã xác nhận`/`Chờ xác nhận`/`Chờ thanh toán` (còn hạn), ném `BookingConflictException` nếu trùng — chạy trong transaction phía backend (không chỉ disable nút ở frontend). Route: `checkInWalkIn` (form POST cổ điển, forward lại trang kèm `errorMsg`, không phải JSON AJAX) — giữ nguyên convention hiện có, không đổi sang response JSON 409 vì đây không phải endpoint AJAX và đổi kiến trúc này rủi ro "phá luồng khách vãng lai" ngoài phạm vi cần thiết để sửa lỗi được báo cáo.

Drawer mở sân walk-in cũng đã có sẵn ô cảnh báo "Lịch tiếp theo bắt đầu lúc..." (`getNextBookingForSan`) khi mở cho một sân có booking sắp tới — không cần thêm mới.

## 10. Concurrency

**Đã tồn tại từ trước**: `checkInKhachDatTruoc`/`checkInKhachVangLai` dùng `WITH (UPDLOCK, ROWLOCK)` khi SELECT, và `UPDATE ... WHERE TrangThai = 'Đã xác nhận'`/`WHERE TrangThai = 'Sẵn sàng'` với affected-rows check — 0 dòng ảnh hưởng ném `ConcurrencyConflictException`. Hai nhân viên bấm check-in cùng lúc: chỉ request đầu tiên thành công, request sau nhận thông báo "Trạng thái đơn đặt sân vừa thay đổi... Vui lòng tải lại." (hiển thị qua `errorMsg`, cùng convention form-POST như trên, không phải JSON 409 vì cùng lý do ở mục 9).

## 11. UI trước/sau

**Trước:** Sân có booking 09:30–10:00 lúc 09:10 → card hiện "Sẵn sàng", nút "Mở sân". Nhân viên phải tự kéo xuống danh sách "Chờ check-in" hoặc mở drawer mới biết.

**Sau:** Card hiện badge vàng "Sắp có lịch đặt", tên khách, khung giờ, nguồn (WEB), đồng hồ đếm ngược "Bắt đầu sau 00:19:42" cập nhật mỗi giây theo server time, nút chính duy nhất **"Check-in khách"** (submit trực tiếp `action=checkInPreBooked`, không cần mở drawer).

Card đang chơi: đổi label "Hết giờ chơi"/countdown chung chung thành "Sắp hết giờ · Còn HH:MM:SS" (≤10 phút) và "QUÁ GIỜ · Quá HH:MM:SS" (quá giờ) — rõ ràng hơn, đúng màu đỏ theo spec.

Danh sách "Chờ check-in": nút đổi từ "Mở sân" → "Check-in khách" khi booking đã ở trạng thái "Đã xác nhận" (giữ "Mở sân" cho "Chờ xác nhận" vì chưa được duyệt).

## 12. File đã sửa

1. `src/main/java/org/example/model/San.java` — thêm field `@Transient` cho active/next booking.
2. `src/main/java/org/example/dao/CheckInDAO.java` — mở rộng SQL `getDanhSachSan`.
3. `src/main/java/org/example/util/Constants.java` — thêm `ENDING_SOON_MINUTES = 10`.
4. `src/main/java/org/example/controller/staff/CheckInServlet.java` — thêm `serverNow`, `upcomingBookingWarningMinutes`, `endingSoonMinutes` vào response/request attribute.
5. `src/main/webapp/staff/CheckIn.jsp` — card UPCOMING_BOOKING (JSP tĩnh + template JS polling), server-time offset, countdown ENDING_SOON/OVERTIME, label nút "Check-in khách", resync khi tab visible.

Không sửa: `CheckoutService.java`, `BookingLifecycleService.java`, `LichDatSanDAO`, pricing/tính giá, PayOS, hóa đơn, phân trang — đúng ràng buộc "không phá".

## 13. Kết quả từng test (đánh giá qua code review, không live-test — xem mục 16)

| Test | Cơ chế đã có/đã sửa | Đánh giá |
|---|---|---|
| 1. Server 09:10, booking 09:30 → UPCOMING_BOOKING | Subquery mới + `<c:when>` mới | Đúng theo code review |
| 2. Check-in 09:10 → ActualStartAt=09:10, ScheduledEndAt=10:00, countdown ~50p | Logic `checkInKhachDatTruoc` có sẵn + card đọc `scheduledEndActive` | Đúng theo code review |
| 3. Check-in 09:25 (trong grace) | Logic có sẵn (`CheckInWindow`, `EARLY_THRESHOLD_MINUTES`) | Không đổi, đã hoạt động trước đây |
| 4. Check-in sau 09:30 (trễ) | `LATE_THRESHOLD_MINUTES` có sẵn, countdown vẫn tới 10:00 | Không đổi |
| 5. 09:55 → ENDING_SOON | `remainingMins <= ENDING_SOON_MINUTES` mới | Đúng theo code review |
| 6. 10:05 → OVERTIME | `now >= endDate` nhánh mới label | Đúng theo code review |
| 7. Reload không reset timer | Dữ liệu đọc lại từ DB, không có state client cần khôi phục | Đúng theo kiến trúc |
| 8. Hai NV check-in đồng thời | `UPDLOCK/ROWLOCK` + affected-rows check có sẵn | Không đổi, đã hoạt động trước đây |
| 9. Walk-in overlap 09:20–10:20 vs booking 09:30 | Conflict check có sẵn trong `checkInKhachVangLai` | Không đổi, đã hoạt động trước đây |
| 10. Walk-in không cố định 09:10 khi booking 09:30 | Conflict check tương tự (cùng cơ chế) | Không đổi |
| 11. Sau thanh toán, card về trạng thái phù hợp | `CheckoutService`/`payInvoice` không đổi, card tự tính lại operationState theo dữ liệu mới ở lần render/poll kế | Đúng theo kiến trúc |
| 12. Manager & Staff đều hoạt động | Route/permission `/staff/checkin` không đổi | Không đổi |
| 13. Sai CoSoID bị chặn | `checkInKhachDatTruoc` kiểm tra `bookingCoSoId != requiredCoSoId` có sẵn | Không đổi |
| 14. Customer/Guard không check-in qua API | Role check `roleId==2 \|\| roleId==4` ở đầu servlet có sẵn | Không đổi |

## 14. Screenshots

Không chụp được — không có phiên đăng nhập Manager/Staff hợp lệ trong lượt làm việc này (xem mục 16).

## 15. Build/E2E

```
mvn -q compile              → OK
mvn -q -DskipTests package  → OK
mvn -q test                 → 77 tests, 7 lỗi pre-existing (thiếu DB_URL trong shell mvn test,
                               không liên quan code đã sửa)
node --check                → Các hàm JS mới/sửa (getServerNow, updateAllCardTimers,
                               pollUpdates, visibilitychange listener) được trích xuất và kiểm tra
                               riêng - hợp lệ. File JSP đầy đủ không thể syntax-check bằng node
                               do trộn JSTL/EL server-side (xem mục 16).
```

Redeploy trực tiếp trên server đang chạy (SmartTomcat, `mvn package` + touch context descriptor) — log xác nhận undeploy/deploy hoàn tất, không exception mới ở thời điểm khởi động. **JSP compile lười (lazy)** — Tomcat chỉ dịch `CheckIn.jsp` thật sự khi có request đầu tiên tới trang, nên bước redeploy này KHÔNG tự chứng minh JSP không có lỗi cú pháp EL/JSTL.

Đã kiểm tra thủ công thay thế: đếm số lượng `<c:when>`/`</c:when>`, `<c:choose>`/`</c:choose>`, `<c:if>`/`</c:if>`, `<form>`/`</form>` trong toàn file — khớp nhau hoàn toàn (9/9, 4/4, 8/8, 11/11). Toàn bộ cú pháp EL mới (`${san.hasUpcomingBooking}`, `${san.nextGioBatDau.toString().substring(11,16)}`, ...) đều theo đúng mẫu đã chứng minh hoạt động ở nơi khác trong cùng file (vd. `${b.gioBatDau.toString().substring(0,5)}` đã có sẵn).

## 16. Vấn đề còn tồn tại

1. **Chưa live-test được** (Playwright hoặc thủ công qua trình duyệt thật): không có mật khẩu tài khoản Manager/Staff hợp lệ trong phiên này, và hệ thống tự chặn ghi dữ liệu test trực tiếp vào DB khi chưa được xác nhận rõ ràng (đã xảy ra ở lượt làm việc trước trong cùng phiên). Khuyến nghị chủ dự án tự mở `/staff/checkin` một lần với một booking "Đã xác nhận" sắp tới để xác nhận trực quan, hoặc cấp quyền tạo tài khoản test cô lập cho lượt sau.
2. `getNextBookingForSan()` trong drawer walk-in (đoạn code đã tồn tại từ trước, không phải tôi thêm) vẫn dùng `new Date()` (client time) làm mốc lọc "sắp tới" — phạm vi phụ, không phải đường hiển thị chính đã sửa; để nguyên nhằm giữ rủi ro thay đổi ở mức tối thiểu.
3. Countdown "Đã chơi HH:MM:SS" cho walk-in không cố định và countdown cho ca "Đang sử dụng" (không phải UPCOMING_BOOKING) tiếp tục dùng cơ chế `parseTimeToDate` cũ (chuỗi "HH:mm", không phải ISO datetime đầy đủ) — đã vá điểm duy nhất cần thiết (`now` lấy từ server time) mà không viết lại toàn bộ 3 nơi render trùng lặp (JSP tĩnh, JS card template, JS booking-list template) sang ISO datetime, để tránh rủi ro hồi quy trên luồng đang hoạt động ổn định.
4. Bộ đếm "Sẵn sàng: N" ở đầu trang vẫn đếm theo `San.TrangThai` thuần (không trừ các sân đang UPCOMING_BOOKING) — cố ý giữ nguyên vì đây là số liệu về trạng thái vật lý sân, tách biệt với operation state hiển thị trên card.
