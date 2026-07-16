# Báo cáo: Loại bỏ hoàn toàn "Xóa vĩnh viễn" khỏi module Thùng rác

**Ngày:** 2026-07-16
**Phạm vi:** Toàn bộ nghiệp vụ hard delete gắn với tính năng Thùng rác (Manager) và các endpoint trực tiếp liên quan.

## 1. Các trang có nút "Xóa vĩnh viễn" trước đây

Chỉ có **một** trang duy nhất trong toàn hệ thống hiển thị nút "Xóa vĩnh viễn":

- `/manager/thung-rac` (`ThungRac.jsp`) — cả 4 tab: Sân thi đấu, Loại sân, Kho & Dịch vụ, Nhân sự.

Đã kiểm tra và xác nhận **không có** ở:
- `/admin/thung-rac` (`ThungRacAdmin.jsp`, `AdminTrashServlet.java`) — chỉ có `action=restore`, chưa từng có hard delete.
- `AuditLog.jsp` (manager & admin) — chỉ hiển thị/lọc **lịch sử** các bản ghi audit cũ có action `PERMANENT_DELETE`, không phải một hành động xóa.

## 2. Bảng call-path đầy đủ (trước khi sửa)

| Entity | Frontend action | Servlet action | Service method | DAO method | SQL |
|---|---|---|---|---|---|
| Sân | `performAction('delete','san',id)` | `ThungRacManagerServlet` → `action=delete&type=san` | — | `SanDAOImpl.hardDelete` | `em.remove()` + dọn `SoftHold`, `LichDatSan.SanID=NULL` |
| Loại sân | `performAction('delete','loaisan',id)` | `ThungRacManagerServlet` → `action=delete&type=loaisan` | — | `LoaiSanDAOImpl.hardDelete` | `em.remove()` + `San.LoaiSanID=NULL` |
| Kho & Dịch vụ | `performAction('delete','sanpham',id)` | `ThungRacManagerServlet` → `action=delete&type=sanpham` | — | `SanPhamDichVuDAOImpl.hardDelete` | `em.remove()` + `ChiTietHoaDon.SanPhamID=NULL` |
| Nhân sự | `performAction('delete','nhansu',id)` | `ThungRacManagerServlet` → `action=delete&type=nhansu` **và** `NhanSuManagerServlet` → `action=permanentDelete` (endpoint song song, không có UI gọi nhưng gọi được trực tiếp bằng URL) | `NhanSuService.permanentlyDeleteStaff` | `TaiKhoanDAOImpl.permanentDeleteAccount` | ~28 câu `DELETE FROM`/`UPDATE ... SET ... = NULL` dọn FK (ThongBao, YeuCauNghi, CaLamViec, HoaDon, LichDatSan, ChiaHoaDon, ...) rồi `em.remove(acc)` |

## 3. Frontend đã xóa (`ThungRac.jsp`)

- Mô tả trang: "...hoặc xóa vĩnh viễn các thông tin đã bị xóa mềm." → **"Nơi xem và khôi phục các thông tin đã bị xóa mềm."**
- 4 nút "Xóa vĩnh viễn" (icon `delete_forever`, mỗi tab một nút) — xóa hoàn toàn thẻ `<button>`, không dùng `display:none`/JSTL ẩn.
- Cột "Hành động" mỗi dòng giờ chỉ còn nút **Khôi phục**, layout `flex justify-end gap-2` tự co giãn đúng, không lệch/thừa khoảng trống vì `gap` chỉ áp dụng khi có ≥2 phần tử con.

## 4. JavaScript đã xóa

Trong `performAction(action, type, id)`:
- Toàn bộ khối `if (action === 'delete') { ... confirm(...) ... }` (2 thông điệp cảnh báo khác nhau cho `nhansu` và các loại còn lại) — xóa sạch, không còn nhánh nào tham chiếu tới hành động `delete`.
- Không có modal riêng, không có hàm `hardDelete()/deletePermanently()/openPermanentDeleteModal()` nào khác trong file — dự án dùng `confirm()` inline, đã xóa cùng khối trên.
- Kiểm tra: `node --check` trên phần `<script>` trích xuất — **pass**, không lỗi cú pháp, không còn tham chiếu tới phần tử đã xóa.

## 5. Servlet action đã xóa

**`ThungRacManagerServlet.java`** (`/manager/thung-rac`, `doPost`):
- Xóa toàn bộ nhánh `else if ("delete".equals(action))` (San/LoaiSan/SanPham/NhanSu hard delete + audit log `ACTION_PERMANENT_DELETE`).
- Thay bằng defensive rejection cho request cũ/trực tiếp (`action=delete`, `hardDelete`, `permanentDelete`): không xóa gì, chỉ set `errorMsg = "Hệ thống không hỗ trợ xóa vĩnh viễn."` rồi redirect về trang (đúng convention hiện có của servlet này — form POST + redirect, không phải JSON API).

**`NhanSuManagerServlet.java`** (`/manager/nhan-su`, `doPost`):
- Endpoint `action=permanentDelete` (không có UI nào gọi nhưng gọi trực tiếp bằng URL vẫn thực thi hard delete trước khi sửa) — thay logic gọi `permanentlyDeleteStaff` bằng phản hồi từ chối:
  ```json
  HTTP 405
  {"success":false,"code":"PERMANENT_DELETE_DISABLED","message":"Hệ thống không hỗ trợ xóa vĩnh viễn."}
  ```
  Trả JSON đúng Content-Type, không phải trang lỗi HTML mặc định của Tomcat.

## 6. Service method đã xóa

- `NhanSuService.permanentlyDeleteStaff(int accountId, int managerCoSoId)` — xóa toàn bộ, bao gồm kiểm tra quyền chi nhánh và guard "không xóa Admin/Manager" (không còn cần thiết vì không còn đường gọi tới).
- Đã xác nhận **không cascade** tới `CaLamViecDAO`/`ThongBaoDAO`/`YeuCauNghiDAO` — các DELETE liên quan tới những bảng này nằm hoàn toàn trong `TaiKhoanDAOImpl.permanentDeleteAccount` (mục 7), không phải lời gọi riêng từ service.
- Giữ nguyên `deleteStaff` (soft delete), `restoreStaff`, `getDeletedStaffListByBranch`, `deleteShiftPattern` (dùng `CaLamViecDAO.hardDelete` cho tính năng khác — xem mục 9).

## 7. DAO/SQL hard delete đã xóa

| File | Method xóa | SQL/thao tác xóa theo |
|---|---|---|
| `TaiKhoanDAO.java` / `TaiKhoanDAOImpl.java` | `permanentDeleteAccount(int id)` | ~28 câu `DELETE FROM`/`UPDATE...=NULL` dọn FK (MonTheThaoYeuThich, ChiTietHoaDon, MaQR, ChiaHoaDon, HoanTien, LichSuELO, NhatKyChat, NhatKySOSGui, YeuCauSOS, ThongBao, SoftHold, YeuCauNghi(_Audit), CaLamViec(_Availability/_SwapRequest/_Audit)) + `em.remove(acc)` |
| `SanDAO.java` / `SanDAOImpl.java` | `hardDelete(int id)` | `DELETE FROM SoftHold WHERE SanID=?`, `UPDATE LichDatSan SET SanID=NULL`, `em.remove(san)` |
| `LoaiSanDAO.java` / `LoaiSanDAOImpl.java` | `hardDelete(int id)` | `UPDATE San SET LoaiSanID=NULL`, `em.remove(loaiSan)` |
| `SanPhamDichVuDAO.java` / `SanPhamDichVuDAOImpl.java` | `hardDelete(int id)` | `UPDATE ChiTietHoaDon SET SanPhamID=NULL`, `em.remove(sanPham)` |

Không thay các câu này bằng UPDATE mới — các entity đã có sẵn `softDelete()`/`restore()` riêng, tiếp tục dùng nguyên trạng.

## 8. Defensive rejection cho action cũ

| Endpoint | Request cũ | Phản hồi mới |
|---|---|---|
| `POST /manager/thung-rac` `action=delete\|hardDelete\|permanentDelete` | Form POST (không phải JSON) | Không xóa gì; `errorMsg` + redirect về `/manager/thung-rac` (đúng convention servlet, không phải JSON) |
| `POST /manager/nhan-su` `action=permanentDelete` | AJAX/fetch (JSON-style) | HTTP 405 + `{"success":false,"code":"PERMANENT_DELETE_DISABLED",...}` |

## 9. Audit & permission đã thay đổi

- `AuditLogService.ACTION_PERMANENT_DELETE` (hằng số Java, giá trị `"PERMANENT_DELETE"`) — xóa vì không còn nơi nào ghi log hành động này nữa (chỉ có duy nhất 1 lời gọi, nằm trong nhánh servlet đã xóa ở mục 5).
- **Không xóa** bản ghi audit `PERMANENT_DELETE` đã có trong DB — dữ liệu lịch sử giữ nguyên.
- **Không đổi** dropdown filter và badge hiển thị `"PERMANENT_DELETE"` trong `AuditLog.jsp` (manager & admin) — hai file này dùng chuỗi literal, không phụ thuộc hằng số Java vừa xóa, nên vẫn lọc/xem được lịch sử cũ bình thường.
- Không còn permission `PERMANENT_DELETE`/`HARD_DELETE` nào được cấp cho Manager/Admin từ UI Thùng rác.
- Quyền **Khôi phục** không đổi (Manager, đúng CoSoID).

## 10. File đã sửa

1. `src/main/webapp/manager/ThungRac.jsp`
2. `src/main/java/org/example/controller/manager/ThungRacManagerServlet.java`
3. `src/main/java/org/example/controller/manager/NhanSuManagerServlet.java`
4. `src/main/java/org/example/service/manager/NhanSuService.java`
5. `src/main/java/org/example/dao/TaiKhoanDAO.java`
6. `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java`
7. `src/main/java/org/example/dao/SanDAO.java`
8. `src/main/java/org/example/dao/impl/SanDAOImpl.java`
9. `src/main/java/org/example/dao/LoaiSanDAO.java`
10. `src/main/java/org/example/dao/impl/LoaiSanDAOImpl.java`
11. `src/main/java/org/example/dao/SanPhamDichVuDAO.java`
12. `src/main/java/org/example/dao/impl/SanPhamDichVuDAOImpl.java`
13. `src/main/java/org/example/service/AuditLogService.java`

Không có test cũ nào tham chiếu các method trên (`grep` xác nhận `src/test/` trống kết quả).

## 11. Kết quả từng tab (kiểm tra tĩnh)

Đã đọc lại toàn bộ `ThungRac.jsp` sau khi sửa: cả 4 tab (Sân thi đấu, Loại sân, Kho & Dịch vụ, Nhân sự) chỉ còn đúng 1 nút **Khôi phục** mỗi dòng, không còn text/icon/nhánh JS nào nhắc tới "Xóa vĩnh viễn". File JSP hợp lệ về cấu trúc thẻ.

## 12. Kết quả Khôi phục

Không thay đổi code của nhánh `action=restore` ở cả `ThungRacManagerServlet` và `NhanSuManagerServlet` — logic khôi phục (kiểm tra CoSoID, gọi `restore()`/`restoreStaff()`, ghi audit `ACTION_RESTORE`) giữ nguyên 100%.

## 13. Kết quả request hard delete trực tiếp

Xác minh bằng code review (không có server thật để gửi request có session hợp lệ trong phiên này — xem mục 15): nếu ai đó gửi thẳng `action=delete`/`hardDelete`/`permanentDelete` tới 2 endpoint trên, code hiện tại **không gọi bất kỳ DAO/SQL xóa nào** — chỉ set thông báo lỗi hoặc trả JSON 405, đúng yêu cầu "không giữ bất kỳ logic hard delete nào phía sau".

## 14. Build/test/E2E

```
mvn -q compile              → OK
mvn -q -DskipTests package  → OK
mvn -q test                 → 77 tests, 7 lỗi (pre-existing, do thiếu biến môi trường DB_URL
                               trong shell chạy `mvn test`, không liên quan tới các file đã sửa;
                               không có test nào tham chiếu các method vừa xóa)
node --check (inline JS ThungRac.jsp) → OK
```

Grep toàn project sau khi sửa xác nhận **0 tham chiếu còn sót lại** tới: `permanentDeleteAccount`, `permanentlyDeleteStaff`, `sanDAO.hardDelete`, `loaiSanDAO.hardDelete`, `sanPhamDAO.hardDelete`, `ACTION_PERMANENT_DELETE`.

**Redeploy trực tiếp trên server đang chạy** (SmartTomcat, đã `mvn package` rồi touch context descriptor để trigger auto-redeploy — xác nhận qua `catalina.*.log`: "Deployment ... has finished", không có exception mới). Request `GET /manager/thung-rac` không session → redirect sạch về trang chủ, console trình duyệt không lỗi, log server không có SEVERE mới.

**Không thực hiện được:** đăng nhập Manager qua trình duyệt để chạy Playwright-style E2E đầy đủ (test tab-by-tab, khôi phục 1 bản ghi thật, xem Console/Network) — không có mật khẩu tài khoản Manager thật, và theo yêu cầu của chủ dự án, **không tự ý reset mật khẩu tài khoản Manager thật** khi chưa được cho phép. Chủ dự án đã xác nhận bỏ qua bước test sống này, chấp nhận xác minh bằng code review + build/test + kiểm tra JS/HTML tĩnh + redeploy sanity check như trên.

## 15. Hard delete còn tồn tại trong hệ thống và lý do hợp lệ

| DAO/Servlet | Trạng thái | Lý do giữ nguyên |
|---|---|---|
| `CaLamViecDAO.hardDelete` | Còn dùng | Gọi bởi `NhanSuService.deleteShiftPattern()` — tính năng "Xóa ca làm định kỳ" hoàn toàn khác, không thuộc Thùng rác/soft-delete (mẫu ca định kỳ không có khái niệm xóa mềm). |
| `ThongBaoDAO.hardDelete` | Còn dùng | Gọi từ `CaLamService.java`, `YeuCauNghiService.java` — dọn thông báo nội bộ khi xử lý nghiệp vụ ca làm/nghỉ phép, không liên quan Thùng rác. |
| `YeuCauNghiDAO.hardDelete` | Còn dùng | Gọi từ `CaLamValidationEngine.java`, `YeuCauNghiService.java` — nghiệp vụ duyệt/validate yêu cầu nghỉ, không liên quan Thùng rác. |
| `LichDatSanDAO.hardDelete` | **Orphan, không có caller nào** | Không thuộc 4 tab Thùng rác (không có tab "Lịch đặt sân"). Không đụng tới vì ngoài phạm vi yêu cầu — không xóa mù quáng khi chưa được yêu cầu rõ. |
| `CoSoDAO.hardDeleteCascade` (qua `deleteCoSo`) | **Orphan, không có caller nào** | `AdminTrashServlet` (Thùng rác Admin, entity `CoSo`) chỉ hiện thực `action=restore`, chưa từng gọi hard delete. Ngoài phạm vi yêu cầu, không đụng tới. |
| `QuanLyChiNhanhServlet.deleteCourtsForBranch` / auto-sync sân | Còn dùng | Tính năng đồng bộ số lượng sân khi Admin cấu hình lại chi nhánh — cascade riêng, không liên quan tới nút "Xóa vĩnh viễn" của Thùng rác. |
| `AuditLog.jsp` filter/badge `"PERMANENT_DELETE"` | Giữ nguyên | Chỉ hiển thị **lịch sử** audit log đã có trong DB — không phải một hành động xóa. |

Không có hard delete nào còn nằm trên đường gọi từ UI "Xóa vĩnh viễn" của Thùng rác sau khi sửa.
