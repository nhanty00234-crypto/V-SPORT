# Thiết kế: Tự động hóa luồng đặt sân (Reservation Hold)

**Ngày**: 2026-07-09
**Trạng thái**: Đã duyệt (chờ implement)
**Phạm vi**: Backend (Servlet/JDBC/SQL Server) + Manager UI + Staff Check-in UI

## 1. Mục tiêu & phi mục tiêu

**Mục tiêu**: Giảm thao tác thủ công của Manager/Staff bằng cách tự động hóa vòng đời booking:
giữ chỗ tạm thời → thanh toán/cọc → tự xác nhận → tự hết hạn nếu quá giờ → check-in một chạm.
Backend là nguồn kiểm tra cuối cùng cho mọi bước, không tin dữ liệu từ frontend.

**Phi mục tiêu**:
- Không tích hợp cổng thanh toán thật (PayOS/VNPay) ngay trong scope này — chỉ thiết kế endpoint sẵn sàng nhận webhook sau này, còn hiện tại dùng xác nhận thủ công của Lễ tân.
- Không đổi route/URL hiện có (`/manager/dat-san`, `/staff/dat-san`, `/staff/checkin`, `customer/DatSan.jsp`).
- Không xóa cứng bất kỳ booking nào — chỉ đổi trạng thái.
- Không đổi luồng check-in walk-in (`checkInWalkIn`) — ngoài phạm vi.

## 2. Hiện trạng liên quan (tóm tắt khảo sát)

- Java EE thuần (Servlet + JSP + JDBC qua `DBUtil`/HikariCP), **không Spring, không scheduler/cron**. SQL Server.
- `LichDatSan.TrangThai` là chuỗi tiếng Việt tự do: `"Chờ xác nhận"`, `"Chờ thanh toán"`, `"Đã xác nhận"`, `"Đang sử dụng"`, `"Đã hoàn thành"`, `"Đã hủy"`. `Constants.java` định nghĩa một phần, lệch pha với thực tế code — cần thận trọng khi thêm giá trị mới.
- Đã có `SoftHold` (giữ chỗ 2 phút lúc điền form, độc lập, giữ nguyên không đổi).
- `DatSanServlet.handleDatSan` (`DatSanServlet.java:224-598`) đã có transaction + `SELECT San WITH (UPDLOCK, ROWLOCK)` + overlap-check + deadlock-retry — **tái sử dụng, mở rộng, không viết lại**.
- `"Chờ thanh toán"` hiện tại chỉ là "self-healing ảo": bị bỏ qua trong overlap-check sau 10 phút (`DATEDIFF`) nhưng **không bao giờ thật sự đổi trạng thái hay được dọn dẹp** — đây là gap chính cần vá.
- Trang duyệt hiện tại (`QuanLyDatSanServlet` + `manager/QuanLyDatSan.jsp`) dùng chung cho mọi loại đơn, JS lọc client-side theo trạng thái.
- `CheckInDAO.checkInPreBooked` (`CheckInDAO.java:94-304`) hiện tolerant cho phép check-in cả khi `TrangThai = "Chờ xác nhận"` — **sẽ bị loại bỏ trong thiết kế này** (xem mục 8).
- `AuditLog` + `AuditLogService` đã có sẵn hạ tầng nhưng chưa được gọi ở luồng duyệt/từ chối đặt sân.

## 3. Nguyên tắc thiết kế

1. Tái dùng tối đa: pattern lock `San`, `SoftHold`, trạng thái tiếng Việt hiện có, hạ tầng `AuditLog`.
2. Chỉ thêm 2 giá trị `TrangThai` mới (`"Quá hạn"`, `"Không đến"`) — không đổi/xóa giá trị cũ.
3. Mọi mốc thời gian (`HoldExpiresAt`, so sánh hết hạn) tính bằng `GETDATE()` phía SQL Server — không bao giờ tin thời gian từ client.
4. Không hard-code số phút/giờ — tất cả qua `Constants.java`.
5. Auto-expire chạy theo lưới an toàn kép: background thread (chính) + lazy-cleanup tại các điểm đọc (dự phòng), dùng chung 1 service, không trùng lặp logic.
6. Mặc định an toàn: no-show **không** tự động hủy trừ khi bật config tường minh.
7. Backend luôn là nguồn sự thật cuối cùng — mọi bước (tạo hold, xác nhận thanh toán, check-in) đều re-validate điều kiện trong transaction, không tin trạng thái do frontend gửi lên.

## 4. Trạng thái (`LichDatSan.TrangThai`)

| Trạng thái nghiệp vụ | Giá trị lưu DB | Ghi chú |
|---|---|---|
| HELD / PENDING_PAYMENT | `"Chờ thanh toán"` (tái dùng) | Có `HoldExpiresAt` thật, chặn slot chỉ khi còn hạn |
| PENDING_APPROVAL (COD/trả sau) | `"Chờ xác nhận"` (tái dùng) | Luồng duyệt/từ chối hiện tại giữ nguyên |
| CONFIRMED | `"Đã xác nhận"` (tái dùng) | Xuất hiện ở tab Check-in "Chờ check-in" |
| CHECKED_IN | `"Đang sử dụng"` (tái dùng) | Không đổi |
| COMPLETED | `"Đã hoàn thành"` (tái dùng) | Không đổi |
| CANCELLED | `"Đã hủy"` (tái dùng) | Không đổi |
| **EXPIRED** | **`"Quá hạn"`** (MỚI) | Hold quá `HoldExpiresAt` chưa thanh toán → không chặn slot |
| **NO_SHOW** | **`"Không đến"`** (MỚI) | Đã xác nhận nhưng không đến, quá grace period |

## 5. Schema thay đổi

```sql
ALTER TABLE LichDatSan ADD
    HoldExpiresAt           DATETIME2       NULL,   -- deadline giữ chỗ; luôn set = DATEADD(MINUTE, @BOOKING_HOLD_MINUTES, GETDATE())
    DepositAmount            DECIMAL(18,2)   NULL,
    PaymentMethodConfirmed   NVARCHAR(50)    NULL,   -- 'Tiền mặt' / 'Chuyển khoản' / 'PayOS' ...
    TransactionCode          NVARCHAR(100)   NULL,
    ConfirmedAt               DATETIME2      NULL,
    ConfirmedBy                INT           NULL REFERENCES Accounts(AccountID), -- NULL nếu WEBHOOK
    ConfirmSource               NVARCHAR(20) NULL,   -- 'WEBHOOK' | 'STAFF_MANUAL' | 'MANAGER_APPROVE'
    NoShowAt                     DATETIME2   NULL;
```

Quy ước đặt tên: PascalCase cho toàn bộ cột mới (khớp `TimeMode`, `ReservedDurationMinutes` — các cột thêm gần đây nhất). Cột snake_case cũ (`actual_start_time`, `actual_end_time`) giữ nguyên, không đổi tên, ghi chú là ngoại lệ lịch sử trong mapping layer.

`HoaDon.TrangThaiThanhToan` thêm giá trị mới `"Đã cọc"` (bên cạnh `"Chưa thanh toán"`, `"Đã thanh toán"`, `"Hoàn tiền"`, `"Ghi nợ"` hiện có), dùng khi `DepositAmount < giá cuối cùng`.

## 6. Config (bổ sung vào `Constants.java`, không hard-code)

```java
int BOOKING_HOLD_MINUTES = 10;
int NO_SHOW_GRACE_MINUTES = 15;
int COD_APPROVAL_EXPIRE_HOURS = 2;      // rút ra từ magic number hiện có trong sqlExpirePending
boolean NO_SHOW_AUTO_MODE = false;      // mặc định KHÔNG tự động no-show
```

## 7. Thuật toán tạo booking (mở rộng `DatSanServlet.handleDatSan`)

Giữ nguyên bước 1-5 hiện có (validate input, lock `San WITH (UPDLOCK, ROWLOCK)`, check `San.TrangThai`, check giờ hoạt động cơ sở, check `SoftHold`). Thay đổi duy nhất ở overlap-check và bước insert:

```sql
-- Overlap check (thay điều kiện DATEDIFF<=10 giả bằng HoldExpiresAt thật)
SELECT 1 FROM LichDatSan
WHERE SanID = @SanID AND NgayDat = @NgayDat
  AND (
        TrangThai IN (N'Đã xác nhận', N'Đang sử dụng', N'Chờ xác nhận')
        OR (TrangThai = N'Chờ thanh toán' AND HoldExpiresAt > GETDATE())
      )
  AND GioBatDau < @newGioKetThuc AND GioKetThuc > @newGioBatDau;
```

- Overlap → `ConflictException`: *"Khung giờ này đã có người đặt hoặc đang được giữ tạm thời."*
- Không overlap, chọn cọc online → INSERT `TrangThai='Chờ thanh toán'`, `HoldExpiresAt = DATEADD(MINUTE, @BOOKING_HOLD_MINUTES, GETDATE())`. Ghi audit `CREATE_HOLD_BOOKING` (actor CUSTOMER).
- Không overlap, chọn trả sau (COD) → INSERT `TrangThai='Chờ xác nhận'` y hệt luồng hiện tại, không set `HoldExpiresAt`.
- Response: `bookingId, holdExpiresAt, remainingSeconds (= DATEDIFF(SECOND, GETDATE(), HoldExpiresAt), tính tại thời điểm trả response), message`.

**Bất biến bắt buộc**: `HoldExpiresAt` luôn tính bằng `GETDATE()`/SQL Server, không bao giờ nhận giá trị từ request. Nếu request có gửi field tương tự, backend bỏ qua hoàn toàn.

**Yêu cầu rà soát trước khi merge**: grep toàn bộ `INSERT INTO LichDatSan` trong codebase (dự kiến gồm `DatSanServlet` và `CheckInDAO.checkInWalkIn`). Bất kỳ nơi nào tạo booking chưa lock `San WITH (UPDLOCK, ROWLOCK)` trước khi check overlap phải được bổ sung lock theo đúng pattern này — nếu không, walk-in và đặt online có thể race nhau trên cùng slot.

## 8. Xác nhận thanh toán/cọc — `confirmBookingPayment`

Dùng chung cho cả nút xác nhận thủ công (bây giờ) lẫn webhook thật (sau này), phân biệt bằng `source`.

```
Input: bookingId, paymentAmount, paymentMethod, transactionCode (nullable),
       source ('WEBHOOK' | 'STAFF_MANUAL'), confirmedByAccountId (NULL nếu WEBHOOK)
```

Transaction:
1. `SELECT LichDatSan WITH (UPDLOCK, ROWLOCK) WHERE DatSanID=@id`.
2. Nếu đã `"Đã xác nhận"` → trả thành công idempotent (an toàn cho webhook retry).
3. Nếu `"Quá hạn"` → **không** chuyển lại `"Đã xác nhận"`. Ghi audit `LATE_PAYMENT_CALLBACK` (actor theo `source`, kèm đầy đủ `paymentAmount`/`transactionCode` để đối soát tiền). Trả lỗi: *"Booking đã quá hạn giữ chỗ, không thể xác nhận. Vui lòng liên hệ khách để đặt lại hoặc xử lý hoàn tiền."*
4. Nếu không phải `"Chờ thanh toán"` (và không rơi vào case 2/3) → lỗi nghiệp vụ chung.
5. Nếu `HoldExpiresAt < GETDATE()` (chưa kịp bị sweep chuyển "Quá hạn") → tự chuyển `"Quá hạn"` ngay tại đây rồi trả lỗi giống case 3.
6. UPDATE `TrangThai='Đã xác nhận'`, `DepositAmount`, `PaymentMethodConfirmed`, `TransactionCode`, `ConfirmedAt=GETDATE()`, `ConfirmedBy`, `ConfirmSource`.
7. Tạo/cập nhật `HoaDon` (tái dùng helper tạo hoá đơn hiện có trong `duyetLichDatSan`, refactor thành method dùng chung): `TrangThaiThanhToan = 'Đã cọc'` nếu `paymentAmount < giá cuối cùng`, ngược lại `'Đã thanh toán'`.
8. Audit `CONFIRM_PAYMENT` (actor STAFF hoặc WEBHOOK theo `source`).

## 9. Auto-expire — lưới an toàn kép

Service dùng chung, gọi từ 2 nơi để không trùng lặp logic:

```java
class BookingLifecycleService {
    void runExpiryAndNoShowSweep(Connection conn) {
        expireOverdueHolds(conn);        // "Chờ thanh toán" quá hạn → "Quá hạn"
        expireOverdueCodApprovals(conn); // "Chờ xác nhận" quá COD_APPROVAL_EXPIRE_HOURS
        if (Constants.NO_SHOW_AUTO_MODE) {
            markNoShowBookings(conn);    // chỉ chạy nếu bật config
        }
        updateExpiredBookingsAndFields(conn); // logic cũ giữ nguyên (Đang sử dụng→Đã hoàn thành)
    }
}
```

- **Cơ chế chính**: `BookingSchedulerListener` (`@WebListener`, `ServletContextListener`) khởi động `ScheduledExecutorService` chạy `runExpiryAndNoShowSweep()` mỗi 60 giây, `shutdown()` sạch ở `contextDestroyed`.
- **Lưới an toàn**: gọi cùng method này tại các entry-point đang có lazy-cleanup sẵn (`getAllLichDatSan`, `getLichDatSanByCoSo`, trang đặt sân, trang check-in).

`expireOverdueHolds`:
```sql
UPDATE LichDatSan
SET TrangThai = N'Quá hạn',
    GhiChu = CONCAT(ISNULL(GhiChu,''), N' | Tự hủy do quá hạn thanh toán')
WHERE TrangThai = N'Chờ thanh toán' AND HoldExpiresAt < GETDATE();
```
Ghi `AUTO_EXPIRE_BOOKING` (actor SYSTEM) cho mỗi row bị đổi.

`expireOverdueCodApprovals`: giữ nguyên đích trạng thái hiện tại của `sqlExpirePending` (không đổi semantics), chỉ rút số giờ ra `COD_APPROVAL_EXPIRE_HOURS` và bổ sung ghi `AUTO_EXPIRE_COD_APPROVAL` (actor SYSTEM) — hiện đang thiếu audit log cho luồng này.

`markNoShowBookings` (chỉ chạy khi `NO_SHOW_AUTO_MODE=true`) — dùng idiom chuẩn SQL Server để ghép NgayDat+GioBatDau (không cộng trực tiếp DATE+TIME):
```sql
UPDATE LichDatSan
SET TrangThai = N'Không đến', NoShowAt = GETDATE(),
    GhiChu = CONCAT(ISNULL(GhiChu,''), N' | Tự động đánh dấu không đến sau ', @NoShowGraceMinutes, N' phút')
WHERE TrangThai = N'Đã xác nhận'
  AND NgayDat = CAST(GETDATE() AS DATE)
  AND DATEADD(MINUTE, @NoShowGraceMinutes,
        DATEADD(SECOND, DATEDIFF(SECOND, 0, GioBatDau), CAST(NgayDat AS DATETIME2))
      ) < GETDATE();
```
Ghi `MARK_NO_SHOW` (actor SYSTEM).

Khi `NO_SHOW_AUTO_MODE=false` (mặc định): không có UPDATE nào chạy. Badge "Khách trễ / Có thể không đến" được tính runtime (không lưu DB) bằng cùng điều kiện thời gian ở trên, hiển thị ở Manager UI + Check-in UI kèm nút thủ công "Đánh dấu Không đến" → ghi `MANUAL_NO_SHOW` (actor STAFF).

## 10. Check-in — quyết định cuối cùng

1. Booking online đã cọc/thanh toán (`confirmBookingPayment` thành công) → tự `"Đã xác nhận"` → được check-in.
2. Booking COD/trả sau → vào tab "Cần xử lý" → Manager/Staff duyệt (luồng hiện tại, không đổi) → `"Đã xác nhận"` → được check-in.
3. Booking còn `"Chờ xác nhận"` (chưa duyệt) → **không được check-in**.
4. **Bỏ hoàn toàn nhánh tolerant trong `CheckInDAO.checkInPreBooked`** (`CheckInDAO.java:142-147`) đang cho phép check-in với `TrangThai = "Chờ xác nhận"`. Điều kiện mới: chỉ chấp nhận `TrangThai = "Đã xác nhận"`.
5. Nếu gọi check-in trực tiếp (bypass UI) với booking chưa duyệt → backend trả lỗi rõ:
   *"Đơn đặt sân chưa được xác nhận, vui lòng duyệt trước khi check-in."*

**Payment-lock tại check-in** (`CheckInDAO.java:165-180`): chỉ bắt buộc Lễ tân tick `daThuTienMat` khi `HoaDon.TrangThaiThanhToan = 'Chưa thanh toán'`. Nếu `'Đã cọc'` hoặc `'Đã thanh toán'` → bỏ qua yêu cầu tick, cho check-in thẳng. Toàn bộ phần còn lại của `checkInPreBooked` (early-surcharge, late-checkin tolerance, cập nhật `San.TrangThai`, optimistic concurrency check) giữ nguyên 100%.

## 11. Tính tiền còn lại khi đã cọc

`DepositAmount` lưu ở `LichDatSan`. Tại checkout (`CheckInDAO.payInvoice`/`processPayment`):
`SoTienCanThu = GiaCuoiCung - ISNULL(DepositAmount, 0)` — **không** tính lại từ đầu như chưa cọc. UI hóa đơn/check-in hiển thị 3 dòng: Tổng tiền / Đã cọc / Còn lại.

## 12. Manager UI — "Quản lý đặt sân"

Route giữ nguyên (`/manager/dat-san`, `/staff/dat-san`). Title: "Quản lý đặt sân". Subtitle: "Theo dõi đặt sân online, giữ chỗ, xác nhận và check-in."

Classifier dùng chung (Java, tái dùng qua JSP EL — tránh lặp logic ở JS như hiện tại):
```java
BookingTabClassifier.classify(trangThai, holdExpiresAt, ngayDat, gioBatDau)
  → "CAN_XU_LY" | "DA_XAC_NHAN" | "DANG_CHOI_XONG" | "QUA_HAN_HUY"
```

| Tab | Điều kiện | Action |
|---|---|---|
| Cần xử lý | `"Chờ xác nhận"` | Duyệt / Từ chối (giữ nguyên, thêm audit `MANAGER_APPROVE_COD`/`MANAGER_REJECT_COD`) |
| ↳ badge phụ | `"Đã xác nhận"` quá `NO_SHOW_GRACE_MINUTES`, hôm nay | Nút "Đánh dấu Không đến" (thủ công) |
| ↳ badge phụ (chỉ hiển thị) | `"Chờ thanh toán"` còn < 3 phút | Không có action, chỉ để theo dõi |
| Đã xác nhận | `"Đã xác nhận"` (chưa bị flag no-show) | — |
| Đang chơi/Xong | `"Đang sử dụng"`, `"Đã hoàn thành"` | — |
| Quá hạn/Hủy | `"Quá hạn"`, `"Đã hủy"`, `"Không đến"` | — |

Mỗi dòng hiển thị thêm: nguồn đặt (`NguonDatSan`), trạng thái thanh toán/cọc, đếm ngược nếu đang giữ chỗ.

## 13. Staff Check-in UI (`/staff/checkin`)

Tabs: Đang chơi / Chờ check-in / Đã xong hôm nay.

"Chờ check-in" = `TrangThai = "Đã xác nhận"` AND `NgayDat = hôm nay` (bỏ nhánh tolerant — mục 10). Mỗi item: Tên sân, Tên khách, SĐT, khung giờ, trạng thái thanh toán/cọc (kèm số tiền còn lại nếu có), nguồn đặt, nút Check-in. Badge "Khách trễ" nếu quá grace period.

## 14. Bảng badge trạng thái (dùng chung 2 UI)

| Badge | Điều kiện |
|---|---|
| Đang giữ chỗ (còn Xp Ys) | `"Chờ thanh toán"`, còn hạn |
| Cần duyệt (trả sau) | `"Chờ xác nhận"` |
| Đã xác nhận — Đã cọc Xđ, còn lại Yđ | `"Đã xác nhận"` + `DepositAmount < giá cuối cùng` |
| Đã xác nhận — Đã thanh toán đủ | `"Đã xác nhận"` + đã thu đủ |
| Khách trễ — có thể không đến | quá grace, `NO_SHOW_AUTO_MODE=false` |
| Quá hạn | `"Quá hạn"` |
| Không đến | `"Không đến"` |
| Đã hủy | `"Đã hủy"` |

## 15. Audit log — action & actor

| Action | Actor | Khi nào |
|---|---|---|
| `CREATE_HOLD_BOOKING` | CUSTOMER | Tạo booking `"Chờ thanh toán"` |
| `CONFIRM_PAYMENT` | STAFF / WEBHOOK | Xác nhận cọc/thanh toán thành công |
| `LATE_PAYMENT_CALLBACK` | WEBHOOK / STAFF | Callback đến sau khi đã `"Quá hạn"` |
| `AUTO_EXPIRE_BOOKING` | SYSTEM | Hết hạn giữ chỗ (10') |
| `AUTO_EXPIRE_COD_APPROVAL` | SYSTEM | COD quá `COD_APPROVAL_EXPIRE_HOURS` chưa duyệt |
| `MARK_NO_SHOW` | SYSTEM | Chỉ khi `NO_SHOW_AUTO_MODE=true` |
| `MANUAL_NO_SHOW` | STAFF | Staff bấm tay (mặc định) |
| `MANAGER_APPROVE_COD` / `MANAGER_REJECT_COD` | MANAGER/STAFF | Duyệt/từ chối COD (bổ sung log còn thiếu) |

## 16. Validation bắt buộc (tổng hợp)

1. Không đặt trùng sân cùng khung giờ (overlap-check mục 7).
2. Không đặt sân đang bảo trì/tạm đóng (`San.TrangThai != 'Sẵn sàng'`).
3. Không đặt trong quá khứ.
4. Không đặt ngoài giờ hoạt động cơ sở.
5. Không giữ chỗ quá hạn chặn slot người khác (`"Quá hạn"` luôn bị loại khỏi overlap-check).
6. Không thanh toán booking đã `"Quá hạn"` (mục 8, case 3/5).
7. Không check-in booking chưa `"Đã xác nhận"` (mục 10).
8. Không check-in nếu sân đang `"Đang sử dụng"`.
9. Không cho Manager cơ sở A thấy booking cơ sở B (giữ nguyên cơ chế `user.getCoSoId()` từ session hiện có).
10. Không xóa cứng booking, chỉ đổi trạng thái.
11. `HoldExpiresAt` luôn tính bằng `GETDATE()` server, không nhận từ client.

## 17. Test plan

### Bộ gốc
| TC ID | Expected |
|---|---|
| TC_BOOKING_CONCURRENT_01 | 2 request cùng slot cùng lúc → chỉ 1 `HELD` thành công, còn lại `ConflictException` |
| TC_BOOKING_HOLD_01 | Đặt thành công → `TrangThai="Chờ thanh toán"`, `HoldExpiresAt = now+10'` |
| TC_BOOKING_EXPIRE_01 | Quá `HoldExpiresAt` chưa thanh toán → `"Quá hạn"`, slot mở lại |
| TC_BOOKING_PAYMENT_01 | Thanh toán trước hạn → `"Đã xác nhận"`, `PaymentStatus` đúng |
| TC_BOOKING_PAYMENT_02 | Thanh toán sau hạn → fail, message đúng |
| TC_BOOKING_OVERLAP_01 | Confirmed 18-20h, đặt 19-21h → fail |
| TC_BOOKING_ADJACENT_01 | Confirmed 18-20h, đặt 20-21h → pass |
| TC_MANAGER_UI_01 | Đơn có cọc thành công → không ở "Cần xử lý", ở "Đã xác nhận" |
| TC_MANAGER_UI_02 | Đơn trả sau chưa duyệt → ở "Cần xử lý" |
| TC_CHECKIN_01 | Confirmed hôm nay → xuất hiện "Chờ check-in" |
| TC_CHECKIN_02 | Check-in thành công → booking + sân chuyển "Đang sử dụng" |

### Bộ bổ sung (từ rà soát nghiệp vụ)
| TC ID | Expected |
|---|---|
| TC_EXPIRED_NOT_BLOCKING | Booking `"Quá hạn"` cùng slot → khách khác đặt được bình thường |
| TC_COD_AUTO_EXPIRE_AUDIT | COD quá `COD_APPROVAL_EXPIRE_HOURS` → chuyển trạng thái đúng hiện tại + có `AUTO_EXPIRE_COD_APPROVAL` |
| TC_NOSHOW_DEFAULT_MANUAL | Quá grace, `NO_SHOW_AUTO_MODE=false` → `TrangThai` không đổi, chỉ badge; Staff bấm tay mới chuyển `"Không đến"` |
| TC_NOSHOW_AUTO_MODE | `NO_SHOW_AUTO_MODE=true` → tự chuyển `"Không đến"`, có `MARK_NO_SHOW` |
| TC_LATE_PAYMENT_CALLBACK | Webhook đến sau khi `"Quá hạn"` → fail rõ, KHÔNG chuyển lại `"Đã xác nhận"`, có `LATE_PAYMENT_CALLBACK` |
| TC_DEPOSIT_REMAINING | Cọc 100k/tổng 300k, checkout → chỉ thu thêm 200k |
| TC_WALKIN_VS_ONLINE_RACE | Walk-in + đặt online cùng slot cùng lúc → chỉ 1 bên thắng |
| TC_HOLDEXPIRES_SERVER_TIME | Client gửi `holdExpiresAt` giả → backend bỏ qua, tự tính bằng `GETDATE()` |
| TC_CHECKIN_PENDING_REJECTED | Check-in booking còn `"Chờ xác nhận"` (bypass UI) → lỗi *"Đơn đặt sân chưa được xác nhận, vui lòng duyệt trước khi check-in."* |
| TC_CHECKIN_PAID_NO_CASH_TICK | Booking `"Đã cọc"`/`"Đã thanh toán"` → check-in không yêu cầu tick tiền mặt |
| TC_CHECKIN_UNPAID_REQUIRES_TICK | Booking `"Chưa thanh toán"` → check-in vẫn bắt buộc tick như hiện tại |
| TC_NOSHOW_DATETIME_BOUNDARY | `GioBatDau` gần 00:00 → sweep so sánh đúng, không lỗi kiểu DATE/TIME |

## 18. Rủi ro & việc cần làm khi implement

- **Bắt buộc rà soát** mọi điểm `INSERT INTO LichDatSan` trước khi merge (mục 7) — đặc biệt `checkInWalkIn`.
- `Constants.java` hiện lệch pha với trạng thái thực tế trong code — khi thêm 2 giá trị mới cần đồng bộ lại, không thêm chồng thêm lệch.
- Cần đo tải khi bật `ScheduledExecutorService` mỗi 60s trên môi trường có nhiều cơ sở — sweep nên có `WHERE` index-friendly (`TrangThai`, `HoldExpiresAt`) để tránh full scan.
