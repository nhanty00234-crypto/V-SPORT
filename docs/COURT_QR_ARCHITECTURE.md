# Kiến trúc QR bảo mật theo từng sân (QR-01 + QR-01B)

Tài liệu này mô tả nền tảng backend cho luồng:

```
Manager quản lý QR từng sân → Customer quét bằng camera →
Customer gọi Staff/yêu cầu dịch vụ/thanh toán → Staff tiếp nhận và xử lý
```

**Phạm vi tài liệu:** chỉ Task QR-01 (nền tảng domain) + QR-01B (verify + harden
trên DB thật). **Chưa có UI, chưa có camera scanner, chưa có Staff request,
chưa có thanh toán, chưa có PayOS, chưa có notification/WebSocket, chưa
responsive.** Những phần đó thuộc các task sau (QR-02 trở đi).

Không có credential, token thật, hay giá trị nhạy cảm nào được ghi trong tài
liệu này.

---

## 1. Domain model

### 1.1 `SanQR` (1-1 với `San`)

| Cột | Kiểu | Ghi chú |
|---|---|---|
| `SanQRID` | `INT IDENTITY` | PK |
| `SanID` | `INT` | FK → `San`, **UNIQUE** (1 sân = tối đa 1 bản ghi `SanQR`) |
| `Token` | `UNIQUEIDENTIFIER` | UUID v4, `NEWID()` default. Public opaque identifier, **được phép giữ plaintext** để in lại QR. |
| `ShortCode` | `NVARCHAR(12)` | Mã dự phòng dạng `VS-XXXXXX`, unique filtered index. |
| `TrangThai` | `NVARCHAR(20)` | `ACTIVE` / `DISABLED` / `REVOKED` — xem mục 4 (Lifecycle). |
| `CreatedAt`, `CreatedBy`, `UpdatedAt`, `UpdatedBy` | | Audit cột chuẩn của project. |
| `RegenerateCount` | `INT` | Đếm số lần regenerate, phục vụ hiển thị/debug. |

### 1.2 `SanQRTokenHistory` (append-only)

| Cột | Kiểu | Ghi chú |
|---|---|---|
| `HistoryID` | `INT IDENTITY` | PK |
| `SanQRID`, `SanID` | `INT` | FK tham chiếu |
| `Token` | `UNIQUEIDENTIFIER NULL` | **KHÔNG còn được ghi bởi entity kể từ QR-01B** (xem mục 3). Cột giữ lại (không DROP) để không phá dữ liệu nếu môi trường khác đã ghi plaintext trước hardening. |
| `TokenHash` | `NVARCHAR(64) NULL` | SHA-256(token) dạng hex — giá trị THẬT SỰ được dùng để tra cứu lịch sử. |
| `ShortCode` | `NVARCHAR(12) NULL` | Short code plaintext (không hash — xem lý do ở mục 3.2). |
| `TrangThai` | `NVARCHAR(20)` | `ISSUED` / `REVOKED` — trạng thái của TỪNG MỤC lịch sử, không phải của `SanQR`. |
| `IssuedAt`, `RevokedAt`, `RevokedBy`, `RevokeReason` | | |

---

## 2. Kết quả migration trên DB thật

Chạy qua `DBUtil → HikariCP → JPAUtil` (production persistence path thật, không
tạo `EntityManagerFactory` thủ công để né cấu hình).

| Migration | Lần 1 | Lần 2 (idempotency) |
|---|---|---|
| `sql/migration_san_qr.sql` | PASS — tạo `SanQR`, `SanQRTokenHistory`, FK, unique index | PASS — không lỗi, không tạo constraint trùng |
| `sql/migration_san_qr_hardening.sql` | PASS — thêm `ShortCode` (2 bảng), `TokenHash`, nới `Token` thành nullable, chuyển `UQ_SanQRTokenHistory_Token` sang filtered index | PASS — không lỗi |

`sql/verify_san_qr.sql` chạy qua `RunSanQRVerifyTest` xác nhận: 2 bảng tồn
tại, đúng cột/kiểu dữ liệu, đúng FK, đúng unique constraint/index, 0 dòng vi
phạm "1 sân nhiều SanQR" hoặc "token trùng giữa các sân ACTIVE".

**Database:** Microsoft SQL Server (kết nối qua `mssql-jdbc`, dialect
`SQLServerDialect`, Hibernate 6.4.4.Final). Không ghi host/database/credential
cụ thể trong tài liệu này.

---

## 3. Token & Token history — quyết định kỹ thuật

### 3.1 Token là UUID version 4 chuẩn (RFC 4122)

`UUID.randomUUID()` của JDK sinh UUID v4 (dùng `SecureRandom` nội bộ), xác
nhận bằng `token.version() == 4` và `token.variant() == 2` trong
`SanQRServiceSmokeTest` (TEST 03). **Không** dùng `new UUID(timestamp, ...)`,
không dùng SanID/CoSoID để tạo token, không hash trực tiếp SanID. Token không
chứa SanID dưới bất kỳ hình thức nào (TEST 04 kiểm tra không có chuỗi con
trùng SanID trong token).

### 3.2 Token history: hash, không plaintext — short code: plaintext, có lý do

Ban đầu (QR-01) `SanQRTokenHistory.Token` lưu plaintext UUID. QR-01B đã sửa:
entity chỉ còn ghi **`TokenHash` = SHA-256(token)** cho mọi bản ghi lịch sử
mới. Lý do: lịch sử chỉ cần trả lời "token vừa quét có từng active không" để
phân biệt `REVOKED` với `NOT_FOUND` — không có nghiệp vụ nào cần đọc lại giá
trị token cũ ở dạng gốc.

**Short code KHÔNG hash** trong lịch sử — quyết định có chủ đích, không phải
thiếu sót: short code vốn đã được thiết kế để con người gõ tay/đọc trên giấy,
không mang cùng mức nhạy cảm như token URL (không thể dùng để truy cập trực
tiếp qua link, phải qua form nhập tay có rate-limit ở tầng UI của task sau).
So khớp short code cũ dùng giá trị đã chuẩn hoá (`normalizeShortCode`), không
qua hash.

Không dùng salt khi hash token — token đã có 122 bit entropy ngẫu nhiên
(UUID v4), khác với OTP 6 chữ số (chỉ ~20 bit, cần salt chống rainbow-table).

### 3.3 Vấn đề đã phát hiện và sửa trong QR-01B

Migration gốc tạo `UQ_SanQRTokenHistory_Token` là unique index **không
filtered**. SQL Server coi từ dòng NULL thứ 2 trở đi trong một unique index
không-filtered là vi phạm unique. Vì entity giờ luôn ghi `Token = NULL` (chỉ
ghi `TokenHash`), **dòng lịch sử thứ 2 trở đi bị chính DB từ chối** —
`ConstraintViolationException`, `regenerate()` trả `SYSTEM` error. Phát hiện
qua chạy thật `test12_regenerateSucceeds` (không phải đọc code). Sửa bằng
cách `DROP` + tạo lại `UQ_SanQRTokenHistory_Token` dạng
`WHERE Token IS NOT NULL` (cùng kiểu filtered index với `UQ_SanQR_ShortCode`).

---

## 4. Lifecycle

Trạng thái của **bản ghi `SanQR` hiện hành** (current row) — KHÔNG nhầm với
trạng thái từng mục lịch sử:

```
ACTIVE   → DISABLED   (Manager tắt tạm thời, giữ nguyên token)
DISABLED → ACTIVE     (Manager bật lại, giữ nguyên token)
ACTIVE   → ACTIVE     (regenerate: giữ trạng thái, ĐỔI token/shortCode)
DISABLED → ACTIVE     (regenerate: LUÔN kích hoạt lại, ĐỔI token/shortCode)
REVOKED  = terminal    (không có transition nào ra khỏi REVOKED)
```

`REVOKED` **hiện tại chỉ tồn tại trên `SanQRTokenHistory`** (mỗi mục lịch sử
riêng lẻ), **không phải trạng thái mà current `SanQR` row từng đạt tới** qua
bất kỳ hành động nào ở QR-01/QR-01B — `regenerate()` KHÔNG đưa current row về
`REVOKED`, nó cập nhật token/shortCode mới ngay trên cùng row và giữ
`TrangThai = ACTIVE`. Việc quét phải token cũ trả `ResolveOutcome.REVOKED` là
nhờ tra `SanQRTokenHistory`, không phải đọc `SanQR.TrangThai`.

`SanQRService` **có sẵn guard** cho trường hợp current row ở `REVOKED` (từ
chối enable/regenerate với `INVALID_TRANSITION`) — guard này chưa có đường
nghiệp vụ nào kích hoạt ở QR-01B (xác nhận bằng TEST 17: set thẳng DB rồi gọi
`enable()`, xác nhận bị chặn đúng). Nếu QR-02 bổ sung một hành động
"archive/vô hiệu hoá vĩnh viễn QR của một sân" (ví dụ khi sân bị xoá), đó là
lúc current row cần chuyển `REVOKED` — guard đã sẵn sàng, không cần sửa thêm.

**Không cho:** `REVOKED → ACTIVE`, `REVOKED → DISABLED` (đã guard),
`DISABLED → DISABLED`/`ACTIVE → ACTIVE` qua `enable()`/`disable()` được coi
là no-op (trả thành công, không ghi Audit/không bump `UpdatedAt`, tránh đếm
click thừa vào lịch sử thay đổi thật).

---

## 5. Short code (bổ sung mới ở QR-01B)

Báo cáo QR-01 ban đầu chưa có short code — đã bổ sung.

- Định dạng: `VS-XXXXXX` (prefix cố định + 6 ký tự thân).
- Bảng ký tự: `ABCDEFGHJKMNPQRSTUVWXYZ23456789` (loại bỏ `0/O`, `1/I/L`) — 31
  ký tự, 31⁶ ≈ 887 triệu tổ hợp cho phần thân.
- Sinh bằng `SecureRandom` (`SanQRSecurityUtil.generateShortCode()`), không
  dùng `Math.random()`, không suy ra từ SanID/token.
- Unique toàn hệ thống, kiểm tra trong transaction đang mở trước khi persist,
  retry tối đa 20 lần nếu trùng (xác suất trùng cực thấp ở quy mô hiện tại).
- Resolve không phân biệt hoa/thường (`normalizeShortCode`).
- Regenerate luôn sinh short code mới cùng lúc với token mới; short code cũ
  vô hiệu ngay lập tức (tra qua `SanQRTokenHistory.shortCode`).
- `SanQRService.resolveActiveShortCode(String)` là entry point công khai
  tương đương `resolve(UUID)` nhưng nhận short code thay vì token.

---

## 6. Ownership — trust boundary

`SanQRService` (Service layer thuần) **không có quyền truy cập
`HttpSession`**. Mọi method nghiệp vụ nhận `managerCoSoId` và
`actorAccountId` như tham số `int`/`Integer` — đây là **input đã được tin
tưởng bởi caller**, KHÔNG phải giá trị mà Service tự xác thực được.

**Quy tắc bắt buộc cho mọi Servlet tương lai gọi vào Service này** (đã ghi rõ
trong Javadoc lớp `SanQRService`):

```java
// ĐÚNG — lấy từ session phía server
TaiKhoan manager = (TaiKhoan) session.getAttribute("user");
service.regenerate(sanId, manager.getCoSoId(), manager.getAccountId());

// SAI — không bao giờ được làm — tin giá trị client tự khai
int coSoId = Integer.parseInt(request.getParameter("coSoId"));
service.regenerate(sanId, coSoId, ...); // Manager A có thể tự xưng Manager B
```

Ở tầng Service, kiểm tra thật sự vẫn luôn là:

```java
San san = em.find(San.class, sanId, LockModeType.PESSIMISTIC_WRITE);
if (san.getCoSoID() != managerCoSoId) return Result.fail(ErrorCode.FORBIDDEN, ...);
```

— tức là **nếu** Servlet lỡ truyền sai `managerCoSoId` (do đọc từ request thay
vì session), Service vẫn sẽ so khớp đúng với `San.CoSoID` thật trong DB, nhưng
sẽ so khớp với giá trị SAI mà Servlet gửi lên — đây chính là lỗ hổng nếu
Servlet không tuân thủ. Service KHÔNG THỂ tự phát hiện việc này vì nó không
biết session. Trách nhiệm hoàn toàn thuộc về code gọi vào — đã document rõ,
chưa có Servlet nào tồn tại ở QR-01B để có thể vi phạm.

`TEST 08` xác nhận: gọi với `managerCoSoId` không khớp `San.CoSoID` thật luôn
trả `FORBIDDEN`, không có tác dụng phụ (token/trạng thái không đổi), không có
đường vòng nào bỏ qua kiểm tra này ở tầng Service.

---

## 7. Audit Log

`SanQRService` tự ghi Audit Log qua `AuditLogService.logSystem(...)` (không
qua `AuditLogService.log(req, ...)` vì Service layer không có
`HttpServletRequest` ở giai đoạn này — chưa có Servlet).

**Actions:** `CREATE_QR`, `ENABLE_QR`, `DISABLE_QR`, `REGENERATE_QR`.
**Entity type:** `SanQR`. **Entity ID:** `SanQRID`.

**Vấn đề đã phát hiện và sửa:** `AuditLogDAOImpl.save()` tự mở
`EntityManager`/transaction RIÊNG và commit ngay lập tức — nó **không** tham
gia transaction chính của `SanQRService`. Code ban đầu gọi `writeAudit()`
TRƯỚC `tx.commit()` của transaction chính — nếu transaction chính rollback
sau đó vì lỗi phát sinh, bản ghi audit "đã xảy ra" vẫn tồn tại dù hành động
QR thực tế KHÔNG xảy ra (audit nói dối). Đã sửa: **mọi `writeAudit()` được
gọi SAU khi `tx.commit()` của transaction chính thành công**, đảm bảo audit
chỉ ghi khi hành động chắc chắn đã xảy ra thật.

Chính sách lỗi audit nhất quán với toàn project: `AuditLogService` nuốt mọi
exception nội bộ (`catch (Exception e) { logger.error(...) }`), không bao giờ
làm hỏng luồng nghiệp vụ chính. Nếu ghi audit thất bại, request vẫn trả về
thành công cho Manager (hành động QR đã thực sự xảy ra), chỉ mất bản ghi audit
(đã log lỗi để điều tra sau).

**Không ghi vào Audit:** token đầy đủ, short code đầy đủ, session ID, cookie,
password, database credential. `TEST 20` xác nhận trực tiếp bằng query DB
thật: mọi `AuditLog.Details` của entity `SanQR` không chứa chuỗi token đầy đủ.

---

## 8. Resolve DTO

`SanQRResolveDTO` (`org.example.dto.qr`) — record thuần, immutable, không
setter, không tham chiếu entity JPA.

**Chỉ chứa:** `resultCode`, `message`, `tenCoSo`, `tenSan`, `tenMonTheThao`,
`available` (6 field).

**KHÔNG chứa:** `SanQRID`, `SanID`, `CoSoID`, token, short code, `CreatedBy`,
`UpdatedBy`, `RegenerateCount`, entity proxy nào.

`SanQRService.resolve()`/`resolveActiveShortCode()` trả `PublicResolveResult`
(outcome nội bộ + DTO công khai) — outcome dùng để log/debug phía server, DTO
là thứ DUY NHẤT an toàn để serialize ra response công khai (task sau).

`TEST 19` xác nhận bằng reflection: liệt kê toàn bộ field khai báo trên DTO,
đảm bảo không field nào có tên gợi ý lộ token/short code/ID nội bộ, và
`message` không chứa giá trị token thật.

---

## 9. Concurrency

Mọi transition (`getOrCreate`, `enable`, `disable`, `regenerate`) khoá
`San` bằng `LockModeType.PESSIMISTIC_WRITE` trước khi đọc/ghi `SanQR` liên
quan — pattern giống hệt `ServiceOrderManagerService`/`KhoDichVuManagerServlet`
đã có sẵn trong project.

**Kết quả test đồng thời trên DB thật** (không phải mock):

- **TEST 21** — 5 luồng `getOrCreate()` đồng thời trên 1 sân MỚI (chưa có QR):
  tất cả thành công, chỉ đúng 1 bản ghi `SanQR` được tạo.
- **TEST 22** — 5 luồng `regenerate()` đồng thời trên 1 sân: tất cả thành
  công tuần tự (PESSIMISTIC_WRITE serialize hoá), `regenerateCount` cộng dồn
  đúng đủ 5 (không mất lần nào), vẫn chỉ 1 bản ghi `SanQR`.
- **TEST 23** — 6 lệnh enable/disable xen kẽ đồng thời: không lệnh nào lỗi,
  trạng thái cuối cùng hợp lệ (không kẹt giá trị rác), không mất update.

---

## 10. Kết quả 24 test (chạy trên DB thật, không phải giả lập)

```
TEST 01: PASS (fixture sân test tạo thành công)
TEST 02: PASS (Manager đúng cơ sở tạo QR thành công)
TEST 03: PASS (token là UUID v4 hợp lệ)
TEST 04: PASS (token không chứa SanID theo cách trực tiếp)
TEST 05: PASS (short code hợp lệ, không chứa ký tự dễ nhầm/SanID)
TEST 06: PASS (short code trùng bị DB từ chối - kiểm tra bằng constraint thật)
TEST 07: PASS (tạo lần 2 không tạo duplicate, vẫn 1 bản ghi SanQR)
TEST 08: PASS (cơ sở sai bị FORBIDDEN, không có tác dụng phụ)
TEST 09: PASS (disable thành công)
TEST 10: PASS (token của QR đã disable trả DISABLED, không phải OK)
TEST 11: PASS (enable thành công, giữ nguyên token)
TEST 12: PASS (regenerate thành công)
TEST 13: PASS (token cũ sau regenerate -> REVOKED)
TEST 14: PASS (token mới resolve đúng sân)
TEST 15: PASS (short code cũ không còn hợp lệ sau regenerate)
TEST 16: PASS (short code mới resolve thành công, không phân biệt hoa/thường)
TEST 17: PASS (QR ở trạng thái REVOKED không thể enable lại)
TEST 18: PASS (token giả/null -> NOT_FOUND, không throw)
TEST 19: PASS (DTO không lộ field nội bộ nào)
TEST 20: PASS (AuditLog được tạo, không chứa token đầy đủ)
TEST 21: PASS (5 luồng getOrCreate đồng thời -> chỉ 1 QR được tạo)
TEST 22: PASS (5 luồng regenerate đồng thời -> trạng thái cuối nhất quán)
TEST 23: PASS (6 lệnh enable/disable đồng thời -> không mất update)
TEST 24: PASS (dữ liệu test dọn sạch hoàn toàn, verify lại bằng query)
```

**24/24 PASS**, chạy lặp lại 2 lần liên tiếp cho kết quả ổn định giống nhau.

### 10.1 Lỗi thật đã tìm thấy và sửa (chỉ phát hiện được nhờ chạy trên DB thật)

1. `UQ_SanQRTokenHistory_Token` không filtered → chặn mọi INSERT lịch sử thứ 2
   trở đi vì Token luôn NULL. Sửa: chuyển sang filtered index (mục 3.3).
2. `existsInHistory()` tra short code bằng nhầm cột `tokenHash` thay vì
   `shortCode` → `resolveActiveShortCode()` không bao giờ trả `REVOKED` cho
   short code cũ (luôn rơi vào `NOT_FOUND` sai). Sửa: tách đúng cột tra cứu
   cho từng loại (token dùng hash, short code dùng giá trị chuẩn hoá).
3. `writeAudit()` gọi trước `tx.commit()` → audit có thể "nói dối" nếu
   transaction chính rollback sau đó. Sửa: chuyển mọi lời gọi `writeAudit()`
   ra sau `tx.commit()` thành công.
4. Test `test06` không dọn `San` tạm thời khi nhánh throw (dòng dọn dẹp nằm
   sau câu lệnh gây exception trong cùng `try`, không bao giờ chạy tới). Sửa:
   chuyển vào `finally`.
5. `@AfterAll` an toàn cuối cùng chạy DELETE trên cùng `Connection` trong khi
   `ResultSet` của SELECT vẫn đang mở → có thể cắt ngang cursor giữa chừng.
   Sửa: thu thập toàn bộ ID trước, đóng ResultSet, rồi mới DELETE.

---

## 11. Build

| Bước | Kết quả |
|---|---|
| `mvn clean compile` | **PASS** |
| `mvn test-compile` | **PASS** |
| `mvn test` (toàn bộ 169 test trong project, không loại trừ gì) | **169 test, 168 PASS, 1 FAIL** — `ResetSessionStateTest.resetSession` (lỗi `Invalid column name 'TrangThai'`, script dev-scratch có sẵn từ commit `3bff78c`, thao tác trực tiếp `DatSanID=129` hard-code, **không liên quan QR**, không phải test do phiên này tạo/sửa) |
| `mvn package -DskipTests` | **PASS** |

**Không có loại trừ/exclusion nào được áp dụng trong lần chạy `mvn test` này**
— khác với các phiên trước, hai file từng bị nghi "lỗi có sẵn phải loại trừ"
(`YeuCauDichVuActionApiServlet.java`, `ServiceOrderManagerService.java`) hoá
ra đã được sửa đúng từ commit `fabc83a` (trước cả `f275065`) — giả định "phải
loại trừ 2 file" mà các phiên trước mang theo là **thông tin cũ, không còn
đúng**. Xác nhận lại bằng `mvn clean compile` không loại trừ gì, PASS sạch.

---

## 12. Để lại cho QR-02

- Trang Manager quản lý QR (danh sách sân, tạo/bật/tắt/regenerate qua UI).
- Sinh ảnh QR thật (QR code image generation) từ token/URL.
- In một mã / in hàng loạt.
- Icon quét QR phía Customer + camera scanner.
- Servlet public cho `resolve(token)`/`resolveActiveShortCode()` — **PHẢI**
  tuân thủ trust boundary ở mục 6 (lấy `CoSoID`/`AccountID` từ session, không
  bao giờ từ request parameter khi tạo/sửa QR của Manager).
- Form nhập short code thủ công phía Customer (rate-limit chống dò brute-force
  vì short code có entropy thấp hơn token nhiều — 887 triệu tổ hợp so với
  2^122 — cần giới hạn số lần thử/IP hoặc/session ở tầng UI+servlet, CHƯA có
  ở QR-01B).
- Cân nhắc dọn cột `SanQRTokenHistory.Token` (plaintext, đã nullable, không
  còn được ghi) bằng một migration riêng sau khi xác nhận không còn môi trường
  nào phụ thuộc đọc giá trị đó.
- Nếu cần nghiệp vụ "vô hiệu hoá QR vĩnh viễn" (ví dụ khi sân bị xoá mềm),
  đó là lúc dùng transition `ACTIVE/DISABLED → REVOKED` ở cấp `SanQR` — guard
  chặn `REVOKED → *` đã có sẵn, chỉ cần thêm hành động kích hoạt.
