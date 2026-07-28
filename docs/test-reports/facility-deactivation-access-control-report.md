# Báo cáo: Enforcement khi cơ sở (CoSo) bị ngừng hoạt động

**Ngày:** 2026-07-16
**Phạm vi:** Toàn bộ luồng xóa mềm/khôi phục cơ sở và cơ chế chặn truy cập của tài khoản thuộc cơ sở đã ngừng hoạt động.

## 1. CoSo legacy: còn row hay đã hard-delete?

Audit read-only trên database thật (không sửa dữ liệu ở bước này):

```
CoSoID=6  IsDeleted=NULL  TrangThai=Đang hoạt động  Account=4  San=6  Booking=52  Invoice=11
CoSoID=7  IsDeleted=NULL  TrangThai=Đang hoạt động  Account=3  San=6  Booking=82  Invoice=47
CoSoID=8  IsDeleted=0     TrangThai=Đang hoạt động  Account=1  San=2  Booking=0   Invoice=0
CoSoID=9  IsDeleted=0     TrangThai=Tạm nghỉ        Account=1  San=2  Booking=0   Invoice=0
CoSoID=10 IsDeleted=0     TrangThai=Đang hoạt động  Account=1  San=1  Booking=10  Invoice=1
CoSoID=11 IsDeleted=1     TrangThai=Từ chối         Account=1  San=0  Booking=0   Invoice=0
CoSoID=14 IsDeleted=1     TrangThai=Từ chối         Account=1  San=0  Booking=0   Invoice=0
CoSoID=15 IsDeleted=NULL  TrangThai=Đang hoạt động  Account=0  San=2  Booking=0   Invoice=0
```

**CoSoID=6 ("sân bà địa"), nơi tài khoản trong ảnh chụp màn hình đang hoạt động, hiện KHÔNG ở trạng thái đã xóa** (`IsDeleted=NULL`, tương đương `false`). Không có row `CoSo` nào bị hard-delete (0 orphan Account, 0 orphan San — xem mục 2).

## 2. Account nào đang orphan/inactive

- **Orphan (CoSoID không khớp bất kỳ row CoSo nào):** 0 Account, 0 San. Không có Trường hợp B (hard-delete để lại orphan data) trong hệ thống hiện tại.
- **Account thuộc CoSo đã soft-delete hợp lệ (CoSoID 11, 14):** đây là 2 yêu cầu mở cơ sở (OwnerRequest) đã bị Admin **từ chối** (`TrangThai='Từ chối'`), không phải "cơ sở đang hoạt động rồi bị xóa". Tài khoản chủ sở hữu tương ứng (AccountID 33, 45) đã `IsLocked=true` sẵn, `LastLogin=NULL` (chưa từng đăng nhập thật), 0 San/Booking/Invoice liên quan. Đây là dữ liệu hợp lệ, đúng convention có sẵn của `AdminOwnerServlet`, **không cần vá**.

**Tài khoản trong ảnh chụp màn hình** (`Tạ Hoàng Kim Châu`, Username=`LeTan03`, AccountID=15, RoleID=4) thuộc **CoSoID=6 đang hoạt động thật** — không phải trường hợp "cơ sở đã xóa" như mô tả ban đầu.

## 3. Root cause chính xác

**Không phải lỗi dữ liệu.** Root cause là **thiếu hoàn toàn cơ chế enforcement** — nếu Admin xóa mềm một cơ sở đúng cách (qua `FacilityTrashService.softDeleteFacility`, vốn đã đúng chuẩn `IsDeleted=1/DeletedAt/DeletedBy` transactional), **không có bất kỳ lớp nào trong ứng dụng kiểm tra lại trạng thái CoSo** sau đó:

1. **Login** (`TaiKhoanDAOImpl.dangNhapKhachHang`) chỉ kiểm tra `Account.isLocked`/`Account.isDeleted`, **không JOIN/kiểm tra `CoSo.IsDeleted`**. Một tài khoản Staff/Manager/Bảo vệ của cơ sở đã xóa vẫn đăng nhập được bình thường.
2. **Không có filter nào** áp dụng cho `/staff/*` (chỉ có `EncodingAndCacheControlFilter` set UTF-8 + header cache, không auth). `FilterQuyenManager` (`/manager/*`) chỉ kiểm tra `roleId==2`, không kiểm tra CoSo.
3. **Không service nào** gọi kiểm tra trạng thái cơ sở trước khi thực hiện check-in, thanh toán, duyệt đặt sân, v.v.

→ Kết luận: `CoSoID=6` hiện tại không bị xóa nên hoạt động đúng là **bình thường**, nhưng nếu Admin xóa nó (hoặc bất kỳ cơ sở nào khác) **trước khi có bản vá này**, mọi tài khoản của cơ sở đó — kể cả phiên đã đăng nhập — sẽ tiếp tục hoạt động vô thời hạn. Đây chính là lỗ hổng "nghiêm trọng" được mô tả, dù ảnh chụp cụ thể chưa phản ánh đúng trạng thái DB tại thời điểm audit.

## 4. Login trước/sau

**Trước:** `dangNhapKhachHang` trả về account hợp lệ bất kể `CoSo.IsDeleted`.

**Sau** ([DangNhapServlet.java](../../src/main/java/org/example/controller/DangNhapServlet.java)): ngay sau khi xác thực mật khẩu thành công, nếu `taiKhoan.getCoSoId() != null` và `FacilityAccessService.isFacilityActive(coSoId) == false` → **không tạo session**, trả:
- Form POST: forward `/auth/DangNhap.jsp` với `loi = "Cơ sở của tài khoản này đã ngừng hoạt động. Vui lòng liên hệ quản trị viên."` (tái dùng đúng cơ chế hiển thị lỗi có sẵn của trang, không tạo UI mới).
- AJAX: JSON `{"success": false, "code": "FACILITY_INACTIVE", "loi": "..."}`.

Account không gắn cơ sở (Customer, Admin) không bị ảnh hưởng.

## 5. Filter trước/sau

**Trước:** không có filter nào kiểm tra trạng thái CoSo cho `/manager/*`, `/staff/*`.

**Sau:** [`ActiveFacilityFilter.java`](../../src/main/java/org/example/filter/ActiveFacilityFilter.java) (mới) — `@WebFilter({"/manager/*", "/staff/*"})`. Với mỗi request có session hợp lệ và `user.getCoSoId() != null`, đọc **trực tiếp từ database** (không cache) trạng thái CoSo:
- `ACTIVE` → cho qua bình thường.
- `DELETED`/`NOT_FOUND` → log cảnh báo (`accountId, roleId, coSoId, path`, không log password/session ID), `session.invalidate()`, rồi:
  - AJAX (`X-Requested-With`, `Accept: application/json`, `ajax=true`, hoặc có param `action`) → HTTP 403 JSON `{"success":false,"code":"FACILITY_INACTIVE",...}`.
  - HTML → `sendRedirect("/dangnhap?facilityInactive=true")`.

Không áp dụng cho `/admin/*` (không khớp url-pattern), login/logout, asset — đúng yêu cầu.

## 6. Session invalidation

`ActiveFacilityFilter` gọi `session.invalidate()` **ngay tại request đầu tiên phát hiện CoSo inactive**, không chờ session timeout. Vì mỗi request Manager/Staff/Bảo vệ đều đi qua filter và luôn đọc DB trực tiếp, một phiên đang mở sẽ bị chặn đúng ở **request kế tiếp** sau khi Admin xóa cơ sở — khớp yêu cầu "Xóa cơ sở thành công → request tiếp theo của tài khoản cơ sở đó bị đăng xuất."

## 7. Service authorization (defense-in-depth)

Filter là lớp phòng thủ trung tâm và đã bao phủ **toàn bộ** route `/manager/*`/`/staff/*` hiện có trong hệ thống (đã liệt kê đầy đủ: `QuanLyDatSanServlet` dùng chung `/manager/dat-san` + `/staff/dat-san`, `CheckInServlet`, `DashboardServlet`, `StaffDashboardServlet`, `HoaDonManagerServlet`, `KhoDichVuManagerServlet`, `NhanSuManagerServlet`, `QuanLyCaLamManagerServlet`, `QuanLySanManagerServlet`, `ThungRacManagerServlet`, `YeuCauNghiManagerServlet`, `StaffCaLamServlet`, `HoaDonDetailServlet`, `HoaDonPrintServlet`, `BookingServiceStaffServlet`, `YeuCauNghiStaffServlet` — không có route nào nằm ngoài `/manager/*`/`/staff/*`).

Bổ sung phòng thủ nhiều lớp tại **điểm xử lý tiền quan trọng nhất** — [`CheckInServlet.java`](../../src/main/java/org/example/controller/staff/CheckInServlet.java) `doGet`/`doPost`: kiểm tra `facilityAccessService.isFacilityActive(user.getCoSoId())` ngay sau bước phân quyền role, **bao trùm mọi action** trong servlet (check-in, thêm dịch vụ, thanh toán tiền mặt, PayOS, chuyển khoản...) chỉ bằng 1 điểm kiểm tra dùng chung, không lặp điều kiện ở từng handler.

**Quyết định phạm vi:** không thêm `requireActiveFacility()` riêng lẻ vào từng servlet Manager/Staff còn lại, vì filter đã bao phủ 100% route trong codebase này (đã audit đầy đủ, không có route nào "lọt lưới"). Việc lặp lại kiểm tra tương tự ở >10 servlet khác sẽ là "copy điều kiện khắp nơi" — đi ngược lại chính yêu cầu "Dùng helper/service dùng chung" của đề bài.

## 8. Query dữ liệu vận hành (operational data)

**Không sửa từng DAO/query riêng lẻ** để thêm điều kiện `cs.IsDeleted=0` cho các trang Manager/Staff dashboard, check-in, duyệt đặt sân, hóa đơn, kho/dịch vụ, nhân sự, lịch làm việc... Lý do: mỗi tài khoản Manager/Staff/Bảo vệ chỉ gắn với **đúng một** CoSoID cố định (`user.getCoSoId()`), và `ActiveFacilityFilter` + kiểm tra login đã đảm bảo **không tài khoản nào của một cơ sở inactive có thể chạm tới bất kỳ route nào** trong các trang trên — nên các DAO/query này không bao giờ được gọi với `coSoId` của một cơ sở đã xóa trong thực tế. Sửa từng query riêng lẻ sẽ là phòng thủ trùng lặp không cần thiết, tăng rủi ro thiếu sót thay vì giảm.

## 9. Xóa mềm CoSo (Admin)

`FacilityTrashService.softDeleteFacility` **đã đúng chuẩn từ trước** khi audit (transaction, `UPDATE CoSo SET IsDeleted=1, DeletedAt=SYSUTCDATETIME(), DeletedBy=?` với điều kiện `IsDeleted=0 OR IsDeleted IS NULL`, kiểm tra `rowsAffected`, ghi 1 dòng `AdminTrash` idempotent). Đã bổ sung:

- **Guard hoạt động nguy hiểm** (mục X yêu cầu): trước khi UPDATE, đếm `San.TrangThai='Đang sử dụng'` và `PayOSPaymentAttempt.Status='PENDING'` theo `CoSoID`. Nếu có, rollback và trả lỗi `"Không thể ngừng hoạt động cơ sở vì đang có N sân sử dụng và M giao dịch chờ thanh toán. Vui lòng xử lý xong trước khi ngừng hoạt động."` — không còn force-delete ngầm giữa lúc có tiền/booking đang xử lý.
- **Audit log**: `QuanLyChiNhanhServlet` (điểm gọi `softDeleteFacility`) giờ ghi `AuditLogService.log(..., ACTION_SOFT_DELETE, ENTITY_CO_SO, ...)` sau khi thành công (tái dùng constant có sẵn, không tạo `FACILITY_DEACTIVATED` mới để giữ nhất quán với cách San/LoaiSan/SanPham/NhanSu đang soft-delete).

## 10. Khôi phục CoSo (Admin)

`FacilityTrashService.restoreFacility` **đã đúng chuẩn từ trước**: `UPDATE CoSo SET IsDeleted=0, DeletedAt=NULL, DeletedBy=NULL, TrangThai=OldStatus`, cùng transaction với `UPDATE AdminTrash SET IsRestored=1`, kiểm tra `rowsAffected`. Không sửa hàng loạt `Account.IsDeleted` — tài khoản bị khóa riêng (`IsLocked`) trước khi cơ sở bị xóa **tiếp tục bị khóa** sau khi khôi phục (logic login/`isFacilityActive` chỉ gate theo CoSo, độc lập hoàn toàn với `Account.IsLocked`).

Đã bổ sung audit log `ACTION_RESTORE`/`ENTITY_CO_SO` tại `AdminTrashServlet.handleRestore` (nhánh `CoSo`).

## 11. Legacy repair

Không phát hiện dữ liệu cần vá (mục 1-2). Đã tạo [`sql/repair_legacy_deleted_facility.sql`](../../sql/repair_legacy_deleted_facility.sql) làm công cụ vận hành cho tương lai:
- Phần DIAGNOSTIC (SELECT-only) ghi lại kết quả audit hôm nay làm baseline.
- Phần REPAIR chỉ chạy khi set `@TargetCoSoID` cụ thể, idempotent, có transaction + `XACT_ABORT`, chỉ đưa CoSo về tombstone `IsDeleted=1` nếu row còn tồn tại — không bao giờ tự tạo lại CoSo/Account/HoaDon nếu thiếu dữ liệu.

**Không chạy REPAIR trên DB thật** vì audit xác nhận không có gì cần vá.

## 12. File đã sửa / tạo

Tạo mới:
- `src/main/java/org/example/service/FacilityAccessService.java`
- `src/main/java/org/example/filter/ActiveFacilityFilter.java`
- `sql/repair_legacy_deleted_facility.sql`

Sửa:
- `src/main/java/org/example/controller/DangNhapServlet.java` (kiểm tra facility khi login; forward thông báo khi bị filter redirect)
- `src/main/java/org/example/controller/staff/CheckInServlet.java` (defense-in-depth: kiểm tra facility active trong `doGet`/`doPost`)
- `src/main/java/org/example/service/admin/FacilityTrashService.java` (guard sân/payment đang hoạt động trước khi xóa; N-prefix cho so sánh NVARCHAR)
- `src/main/java/org/example/controller/admin/QuanLyChiNhanhServlet.java` (audit log khi soft-delete cơ sở)
- `src/main/java/org/example/controller/admin/AdminTrashServlet.java` (audit log khi restore cơ sở)
- `src/main/webapp/admin/QuanLyChiNhanh.jsp` (copy modal xác nhận xóa: "Ngừng hoạt động cơ sở?" + liệt kê rõ hậu quả, không dùng nhãn "Xóa vĩnh viễn")
- `src/main/webapp/admin/ThungRacAdmin.jsp` (copy modal khôi phục riêng cho entity CoSo: "Khôi phục cơ sở?")

## 13. Kết quả từng role (đánh giá qua code review + build/test, không live-test)

| Role | Trước | Sau |
|---|---|---|
| Manager của CoSo bị xóa | Login được, dùng dashboard bình thường | Login bị chặn `FACILITY_INACTIVE`; session đang mở bị invalidate ở request kế tiếp tới `/manager/*` |
| Staff/Lễ tân của CoSo bị xóa | Login được, check-in/thanh toán bình thường | Tương tự Manager, cộng thêm double-check tại `CheckInServlet` |
| Bảo vệ của CoSo bị xóa | Login được (dùng chung `/staff/*`) | Tương tự Staff (filter áp dụng theo `user.getCoSoId()`, không phân biệt role) |
| Admin | Không bị ảnh hưởng | Không bị ảnh hưởng (`/admin/*` không khớp filter; Admin không có `CoSoId`) |
| Customer | Không bị ảnh hưởng (không gắn CoSo cố định) | Không bị ảnh hưởng (`coSoId==null` bỏ qua kiểm tra) |
| CoSo khác vẫn hoạt động | N/A | Không bị ảnh hưởng — kiểm tra luôn theo đúng `coSoId` của tài khoản đang request |

## 14. PayOS/background job

- `createPayOSPayment`/`processPayment`/`initBankTransfer` trong `CheckInServlet` đều nằm sau điểm kiểm tra facility mới thêm ở `doPost` → không tạo được giao dịch mới cho cơ sở inactive.
- `getPayOSPaymentStatus` (polling) cũng nằm trong `doGet`, cùng được bảo vệ.
- **Không sửa webhook PayOS** (nằm ngoài `/manager/*`/`/staff/*`, không có session) — đúng yêu cầu "Webhook đã xác minh vẫn phải ghi nhận thanh toán idempotent, không làm mất tiền". Không đụng vào luồng tài chính này.
- `PayOSPaymentAttempt.Status='PENDING'` giờ còn được dùng làm điều kiện **chặn xóa cơ sở** (mục 9) — tránh tình huống Admin xóa cơ sở giữa lúc khách đang thanh toán dở.

## 15. Build/test/E2E

```
mvn -q compile              → OK
mvn -q -DskipTests package  → OK
mvn -q test                 → 77 tests, 7 lỗi pre-existing (thiếu DB_URL trong shell chạy
                               `mvn test`, không liên quan code đã sửa)
node --check (JS trong QuanLyChiNhanh.jsp, ThungRacAdmin.jsp) → OK
```

**Redeploy trực tiếp trên server đang chạy** (SmartTomcat, `mvn package` rồi touch context descriptor để trigger auto-redeploy) — xác nhận qua `catalina.*.log`: undeploy + deploy hoàn tất, không có exception mới. Request `GET /staff/dashboard` không session → redirect sạch về trang chủ (đúng hành vi bỏ-qua khi chưa đăng nhập của filter), không lỗi console, không SEVERE mới trong log.

**Không thực hiện được live E2E đầy đủ theo Section XIX** (đăng nhập Staff → Admin xóa cơ sở ở tab khác → xác nhận Staff bị đăng xuất → khôi phục → login lại). Lý do: việc này đòi hỏi ghi dữ liệu trực tiếp vào database production (tạo tài khoản test hoặc bật/tắt `IsDeleted` của một cơ sở thật) — hệ thống an toàn tự động của tôi chặn thao tác ghi DB trực tiếp ngoài ứng dụng khi chưa có xác nhận rõ ràng từ chủ dự án cho **thao tác ghi cụ thể** đó, và khi được hỏi, chủ dự án chọn phương án xác minh bằng **code review + build/test + redeploy sanity check** thay vì ghi dữ liệu thật để test. Đã bù đắp bằng cách đọc lại kỹ từng dòng logic mới (đối chiếu với FacilityTrashService, PayOSPaymentAttemptStatus enum, N-prefix NVARCHAR) sau khi viết.

## 16. Vấn đề còn tồn tại / rủi ro đã biết

1. **Chưa có live E2E xác nhận hành vi thực tế** (mục 15) — khuyến nghị chủ dự án tự thực hiện một lần thao tác xóa/khôi phục trên một cơ sở test (ví dụ CoSoID=15, hiện 0 tài khoản, 0 booking) qua Admin UI thật để quan sát trực tiếp, hoặc cho phép tôi tạo tài khoản test cô lập ở lượt làm việc sau.
2. `ActiveFacilityFilter` thêm 1 query DB cho **mỗi** request `/manager/*`/`/staff/*` của tài khoản có CoSoID (theo đúng yêu cầu "ưu tiên kiểm tra database trực tiếp ở phiên bản đầu, tránh stale state"). Nếu sau này cần tối ưu, có thể thêm cache ngắn hạn (vài giây) với cơ chế invalidate chính xác khi Admin xóa/khôi phục — chưa làm ở lượt này vì task ưu tiên đúng-đắn hơn hiệu năng cho v1.
3. Chưa thêm `requireActiveFacility` riêng cho từng servlet Manager/Staff khác ngoài `CheckInServlet` (xem lý do phạm vi ở mục 7) — nếu trong tương lai có route Manager/Staff mới KHÔNG nằm dưới `/manager/*`/`/staff/*`, route đó sẽ không được `ActiveFacilityFilter` bảo vệ tự động và cần tự gọi `FacilityAccessService.requireActiveFacility()`.
