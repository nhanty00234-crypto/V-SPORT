# Báo cáo: Điều tra lỗi 403 tại `/staff/checkin` (Manager + Staff)

**Ngày:** 2026-07-16
**Phạm vi:** `/staff/checkin` (CheckInServlet) — quyền truy cập Manager (RoleID=2) và Staff/Lễ tân (RoleID=4).

## 1. Tóm tắt kết luận

**Không có bug trong logic phân quyền `/staff/checkin` cho Manager (2) và Staff/Lễ tân (4).** Logic này đã đúng từ trước, và có bằng chứng nó **đã chạy thành công trong thực tế** ngày hôm trước.

Lỗi 403 trong báo cáo ban đầu xảy ra vì tài khoản dùng để test (`Minh01`) **thực chất có RoleID = 5 (Bảo vệ)**, không phải RoleID = 4 (Lễ tân) như giả định. Hệ thống đã chặn đúng theo thiết kế: Bảo vệ không nằm trong danh sách role được phép Check-in.

Trong quá trình audit, phát hiện và đã sửa **một lỗ hổng IDOR thật** (không liên quan đến lỗi 403 ban đầu): action `addServices` (nhánh không SPLIT) không kiểm tra `CoSoID` trước khi cập nhật dịch vụ của một đơn đặt sân — đã vá.

## 2. Class/method/line gây ra thông báo 403

`CheckInServlet.doGet` [dòng 105](../../src/main/java/org/example/controller/staff/CheckInServlet.java#L105) (và `doPost` dòng 158):

```java
if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
    ...
    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này!");
}
```

Điều kiện này **đã đúng từ trước** — cho phép RoleID 2 và 4. Không có filter nào khác chặn `/staff/*` (rà toàn bộ `web.xml` + filter trong `org.example.filter`: chỉ `EncodingAndCacheControlFilter` áp dụng cho `/*` và chỉ set UTF-8 + header cache, không có auth check).

## 3. Root cause chính xác — chuỗi bằng chứng

1. **Đọc code:** `CheckInServlet.java` dòng 97/153 đã cho phép `roleId == 2 || roleId == 4`. Không có servlet trùng route `/staff/checkin` nào khác (`grep` xác nhận unique `@WebServlet`).
2. **Đọc log server** (`vsport-app.log`, ngày 2026-07-15 14:47–14:49): tài khoản **Long01 (AccountID=41, RoleID=4)** đăng nhập và dùng `/staff/checkin` thành công, bao gồm cả tạo thanh toán PayOS (`action=createPayOSPayment`) tại CoSoID=7 — **không có lỗi 403**.
3. **Đọc log server** ngày 2026-07-16: phiên tạo ra 403 (08:13–08:16, khớp với ảnh chụp màn hình) xuất phát từ tài khoản đăng nhập lúc 08:12:46 là **Minh01**.
4. **Truy vấn trực tiếp database (read-only, không sửa dữ liệu):**
   ```
   AccountID=41  Username=Long01   RoleID=4  CoSoID=7   ← Lễ tân/Staff
   AccountID=42  Username=Minh01   RoleID=5  CoSoID=7   ← Bảo vệ (KHÔNG phải Lễ tân)
   ```
5. **Đọc `RoleRedirectUtil.java`:** RoleID 4 và RoleID 5 dùng chung route Portal (`/staff/dashboard`, sidebar, `/staff/dat-san` — hàm `isStaff()` trả `true` cho cả hai), nên tài khoản Bảo vệ vẫn đăng nhập được vào Staff Portal và thấy menu bình thường. Nhưng `CheckInServlet` cố tình chỉ cho `roleId == 2 || roleId == 4`, nên Bảo vệ bị chặn đúng ở chức năng Check-in — **đây chính là hành vi đúng theo nghiệp vụ đã mô tả** ("Các role khác: Không được truy cập chức năng vận hành Check-in").
6. **Kiểm tra lịch sử git:** commit gần nhất chạm vào `CheckInServlet.java` (`4b185c7`, 23:40 ngày 15/07 — sau lần role=4 test thành công) chỉ sửa việc truyền `CoSoID` vào DAO, audit log, và field response thanh toán — **không đụng khối kiểm tra quyền**.

→ Kết luận: giả định ban đầu ("đăng nhập bằng Lễ tân RoleID=4 rồi bị 403") không khớp với dữ liệu thực tế của phiên tạo ra lỗi. Tài khoản test thực chất là Bảo vệ.

## 4. Permission trước và sau

| | Trước | Sau |
|---|---|---|
| Truy cập trang `/staff/checkin` (GET) | Manager(2), Staff(4) | Không đổi |
| Actions AJAX (processPayment, stopOpenSession, addServices, initBankTransfer, confirmBankTransfer, cancelBankTransfer, createPayOSPayment, getInvoiceDetails, getPayOSPaymentStatus) | Manager(2), Staff(4) | Không đổi |
| `applyEarlyCheckoutAdjustment` (giảm trừ trả sân sớm) | Chỉ Admin(1)/Manager(2) — Staff bị chặn | Không đổi (giữ nguyên, đúng yêu cầu Manager-only) |
| Bảo vệ (RoleID=5) truy cập Check-in | Bị chặn (403) | Không đổi — **giữ nguyên chặn**, đúng theo yêu cầu nghiệp vụ |
| Customer/role khác | Bị chặn | Không đổi |
| `addServices` (nhánh không SPLIT) — CoSoID ownership | **Không kiểm tra** (IDOR) | Kiểm tra `CoSoID`, trả 403 JSON nếu sai cơ sở |

## 5. Filter đã sửa

Không sửa filter nào — không có filter nào chặn `/staff/*`, và các filter hiện có (`FilterQuyenManager` → `/manager/*`, `FilterQuyenAdmin` → `/admin/*`, `FilterBaoMat` → `/views/*`) hoạt động đúng phạm vi, không giao thoa với route đang xét.

## 6. Servlet guard đã sửa

Không sửa guard chính (`roleId == 2 || roleId == 4`) vì đã đúng.

## 7. AJAX authorization đã sửa (lỗ hổng IDOR phát hiện thêm)

**File:** [`LichDatSanDAO.java`](../../src/main/java/org/example/dao/LichDatSanDAO.java), [`LichDatSanDAOImpl.java`](../../src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java), [`CheckInServlet.java`](../../src/main/java/org/example/controller/staff/CheckInServlet.java)

**Vấn đề:** action `addServices` khi `billMode` không phải `SPLIT` gọi `LichDatSanDAO.updateDichVuDatSan(datSanId, productIds, quantities)` — phương thức này lấy `CoSoID` của đơn đặt sân từ DB nhưng **không hề so sánh với `CoSoID` của người gọi**. Một Lễ tân/Manager ở CoSoID=7 gửi `datSanId` thuộc CoSoID khác vẫn có thể ghi đè dịch vụ của đơn đó (IDOR).

**Đối chiếu:** các action khác trong cùng servlet (`checkInKhachDatTruoc`, `huyLichKhachBung`, `payInvoice`, `applyEarlyCheckoutAdjustment`, `addServicesSplitBill`) đều đã truyền và kiểm tra `coSoId` đúng cách — đây là điểm duy nhất bị bỏ sót.

**Cách sửa:**
- Thêm overload `updateDichVuDatSan(datSanId, productIds, quantities, Integer requiredCoSoId)` trong `LichDatSanDAO`/`LichDatSanDAOImpl`, ném `SecurityException("Đơn đặt sân không thuộc cơ sở của bạn.")` nếu `CoSoID` của đơn không khớp `requiredCoSoId`.
- Chữ ký 3-tham số cũ giữ nguyên (delegate sang overload mới với `requiredCoSoId = null` → không kiểm tra), để **không phá luồng Customer** ở `DatSanServlet.handlePostDatDichVu` — nơi quyền sở hữu đã được xác minh riêng theo `AccountID` (khách hàng không gắn với một CoSoID cố định).
- `CheckInServlet.handleAddServices` gọi overload mới với `user.getCoSoId()`, và thêm `catch (SecurityException e)` trả **JSON 403** (`{"success":false,"code":"FORBIDDEN",...}`) thay vì rơi vào nhánh lỗi 400 chung chung.

## 8. CoSoID ownership

Đã rà toàn bộ các action dùng chung Manager/Staff trong `CheckInServlet`:

| Action | Truyền `CoSoID` xuống DAO? |
|---|---|
| checkInPreBooked | Có |
| checkInWalkIn | Có (kiểm tra tại servlet: `targetSan.getCoSoID() != user.getCoSoId()`) |
| cancelNoShow | Có |
| payInvoice | Có |
| applyEarlyCheckoutAdjustment | Có |
| processPayment | Có |
| stopOpenSession | Có |
| addServices (SPLIT) | Có |
| addServices (không SPLIT) | **Thiếu → đã vá (mục 7)** |
| initBankTransfer / confirmBankTransfer / cancelBankTransfer | Có |
| createPayOSPayment | Có |
| getPayOSPaymentStatus | Có (`attempt.coSoId != user.getCoSoId()` → 403 JSON) |

## 9. Layout Manager/Staff

Không thay đổi. `CheckIn.jsp` dùng chung nội dung nghiệp vụ cho cả hai role; không có vấn đề layout được phát hiện trong lần audit này (ngoài phạm vi báo cáo 403).

## 10. File đã sửa

- `src/main/java/org/example/dao/LichDatSanDAO.java` — thêm overload interface.
- `src/main/java/org/example/dao/impl/LichDatSanDAOImpl.java` — thêm kiểm tra `CoSoID`.
- `src/main/java/org/example/controller/staff/CheckInServlet.java` — truyền `CoSoID`, bắt `SecurityException` → 403 JSON.

## 11. Kết quả Staff RoleID = 4

Không cần đăng nhập lại để re-test (theo yêu cầu của chủ dự án — dùng log lịch sử làm bằng chứng). Log ngày 2026-07-15 xác nhận tài khoản Lễ tân thật (`Long01`, CoSoID=7) đã dùng `/staff/checkin` và `createPayOSPayment` thành công. Logic phân quyền cho role này **không bị thay đổi** bởi các sửa đổi trong báo cáo này.

## 12. Kết quả Manager RoleID = 2

Không bị ảnh hưởng. Log cho thấy Manager (`tienncty00325@gmail.com`, RoleID=2, CoSoID=7) vẫn dùng `/staff/checkin` bình thường trong ngày 2026-07-16 (mở sân walk-in, stopOpenSession, processPayment) trước và sau các thay đổi.

## 13. Kết quả Customer RoleID = 3 / Bảo vệ RoleID = 5

Không đổi — vẫn bị chặn đúng theo thiết kế (Customer không có trong danh sách cho phép; Bảo vệ vào được Staff Portal nhưng vẫn bị `CheckInServlet` chặn ở đúng chức năng Check-in).

## 14. Kết quả sai CoSoID

- Trước: action `addServices` (không SPLIT) sai CoSoID vẫn thực thi được (IDOR).
- Sau: trả JSON `{"success":false,"code":"FORBIDDEN","message":"Đơn đặt sân không thuộc cơ sở của bạn."}`, HTTP 403 — nhất quán với các action khác trong cùng servlet.

## 15. Build/test

```
mvn -q compile        → OK
mvn -q -DskipTests package → OK
mvn -q test            → 77 tests, 7 lỗi (đều là script thao tác DB trực tiếp thất bại do
                          thiếu biến môi trường DB_URL trong shell chạy `mvn test`, không
                          liên quan đến các file đã sửa — không có test nào tham chiếu
                          CheckInServlet/LichDatSanDAOImpl/updateDichVuDatSan)
```

Không chạy Playwright E2E theo yêu cầu của chủ dự án (dùng bằng chứng log server thay thế).

## 16. Permission Manager-only vẫn giữ nguyên

- `applyEarlyCheckoutAdjustment` (giảm trừ trả sân sớm): chỉ Admin(1)/Manager(2) — Staff vẫn bị chặn (`CheckInServlet.java` dòng 330).
- Cấu hình PayOS (Admin-only): không nằm trong `CheckInServlet`, không bị đụng tới.
- Vùng `/manager/*`, `/admin/*`: filter tương ứng không bị sửa.

## 17. Việc KHÔNG làm (theo đúng ràng buộc đề bài)

- Không mở quyền Check-in cho Bảo vệ (RoleID=5) hay bất kỳ role nào ngoài Manager/Staff.
- Không sửa dữ liệu tài khoản `Minh01` trong DB.
- Không tắt/bỏ bất kỳ filter hay kiểm tra CoSoID nào.
- Không đổi mật khẩu tài khoản nào.
- Không đụng luồng PayOS, tiền mặt, hóa đơn, phân trang hay UI hiện có ngoài 1 nhánh lỗi (SecurityException) mới thêm.
