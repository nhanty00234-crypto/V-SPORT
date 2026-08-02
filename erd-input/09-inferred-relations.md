# 09-inferred-relations.md
# V-SPORT / QuanLiSport — Inferred Relations
# Relations found in source code (Java DAO/Service/Servlet) but NOT formalized as DB FK constraints

**Data source:** Java files in `src/main/java/org/example/`
**Database not directly queried.** This file documents soft references, service-layer joins,
and object-graph navigation found in Java code that have no corresponding FK in migration SQL.

---

## 1. AuditLog — soft references (no FK)

**Source:** `src/main/java/org/example/model/AuditLog.java`,
`src/main/java/org/example/dao/AuditLogDAO.java`

| Field | Logical target | Note |
|---|---|---|
| `ActorAccountID` | `Accounts.AccountID` | No FK constraint — audit log must survive account deletion |
| `CoSoID` | `CoSo.CoSoID` | No FK — intentional, audit records must be immutable |
| `EntityID` | Multiple tables | Polymorphic reference via EntityType string |

**Reason not formalized:** Audit logs are immutable append-only records. Adding FK constraints
would prevent deletion of the referenced entity without first deleting audit history.

---

## 2. AdminTrash — soft references (no FK)

**Source:** `src/main/java/org/example/model/AdminTrash.java`

| Field | Logical target | Note |
|---|---|---|
| `EntityID` | Multiple tables | Polymorphic — EntityType string determines which table |
| `DeletedBy` | `Accounts.AccountID` | No FK |
| `RestoredBy` | `Accounts.AccountID` | No FK |

**Reason not formalized:** AdminTrash is a polymorphic trash bin. EntityType values observed in
code: `'San'`, `'LoaiSan'`, `'SanPham_DichVu'`, `'Accounts'`, etc.

---

## 3. ThongBao — logical link to source entity via MaBanGhi

**Source:** `src/main/java/org/example/model/ThongBao.java`,
`src/main/java/org/example/dao/ThongBaoDAO.java`

| Field | Logical target | Note |
|---|---|---|
| `MaBanGhi` | Multiple tables (polymorphic) | varchar ID of the entity the notification refers to |
| `LoaiThongBao` | Determines which table | Values: `'BOOKING'`, `'SOS'`, `'GHEPKEO'`, `'SERVICE_ORDER'`, `'REFUND'`, etc. |
| `DuongDan` | N/A | URL/path for deep-link navigation — not a DB FK |

---

## 4. YeuCauNghi — inferred from view SQL and Java model

**Source:** `sql/fix_view_yeuCauNghi.sql`, `src/main/java/org/example/model/YeuCauNghi.java`

| Column | Logical target | Note |
|---|---|---|
| `AccountID` | `Accounts.AccountID` | No FK found in migration — view confirms join pattern |
| `CoSoID` | `CoSo.CoSoID` | No FK found in migration |
| `XuLyBy` | `Accounts.AccountID` | Manager who processed the leave request |
| `DeletedBy` | `Accounts.AccountID` | No FK |

**Status:** Table DDL not found in any migration file. All relations inferred from view SQL
(`V_YeuCauNghi_ChiTiet`) and Java `@Column` annotations.

---

## 5. CaLamViec — shift assignment inferred relations

**Source:** `src/main/java/org/example/model/CaLamViec.java`

All columns in base V4 DDL have FKs declared. Additional soft relations found in service layer:

| Pattern | Description |
|---|---|
| `CaLamViec` ↔ `YeuCauNghi` | Service layer checks for approved leave requests before creating shifts (no DB-level FK) |
| `CaLamViec` ↔ `CaLamViecAudit` | CaLamViecAudit.CaLamViecID references CaLamViec — inferred, no FK migration found |
| `CaLamViec` ↔ `CaLamViecSwapRequest` | Swap requests reference two CaLamViecIDs — inferred, no FK migration found |

---

## 6. CaLamViecAudit — fully inferred (no migration SQL found)

**Source:** `src/main/java/org/example/model/CaLamViecAudit.java`

| Column | Inferred Type | Logical Target |
|---|---|---|
| `AuditID` | INT PK IDENTITY | — |
| `CaLamViecID` | INT | `CaLamViec.CaLamViecID` |
| `ActionType` | NVARCHAR | Values: `CREATE`, `UPDATE`, `DELETE` |
| `OldValue` | NVARCHAR(MAX) | JSON snapshot of old state |
| `NewValue` | NVARCHAR(MAX) | JSON snapshot of new state |
| `ChangedBy` | INT | `Accounts.AccountID` |
| `ChangedAt` | DATETIME2 | — |

---

## 7. CaLamViecAvailability — fully inferred (no migration SQL found)

**Source:** `src/main/java/org/example/model/CaLamViecAvailability.java`

| Column | Inferred Type | Logical Target |
|---|---|---|
| `AvailabilityID` | INT PK IDENTITY | — |
| `AccountID` | INT | `Accounts.AccountID` |
| `CoSoID` | INT | `CoSo.CoSoID` |
| `NgayDangKy` | DATE | — |
| `GioBatDau` | TIME | — |
| `GioKetThuc` | TIME | — |
| `TrangThai` | NVARCHAR | Values: `AVAILABLE`, `UNAVAILABLE` |
| `CreatedAt` | DATETIME2 | — |

---

## 8. CaLamViecSwapRequest — fully inferred (no migration SQL found)

**Source:** `src/main/java/org/example/model/CaLamViecSwapRequest.java`

| Column | Inferred Type | Logical Target |
|---|---|---|
| `SwapRequestID` | INT PK IDENTITY | — |
| `CaLamViecID_Requester` | INT | `CaLamViec.CaLamViecID` |
| `CaLamViecID_Target` | INT | `CaLamViec.CaLamViecID` |
| `RequesterAccountID` | INT | `Accounts.AccountID` |
| `TargetAccountID` | INT | `Accounts.AccountID` |
| `TrangThai` | NVARCHAR | Values: `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED` |
| `GhiChu` | NVARCHAR | — |
| `CreatedAt` | DATETIME2 | — |
| `ReviewedAt` | DATETIME2 | — |
| `ReviewedBy` | INT | `Accounts.AccountID` |

---

## 9. SoftHold — fully inferred (no migration SQL found)

**Source:** `src/main/java/org/example/model/SoftHold.java`

Used to temporarily lock a court slot during online booking checkout flow before payment completes.

| Column | Inferred Type | Logical Target |
|---|---|---|
| `HoldID` | INT PK IDENTITY | — |
| `SanID` | INT | `San.SanID` |
| `NgayDat` | DATE | — |
| `GioBatDau` | TIME | — |
| `GioKetThuc` | TIME | — |
| `AccountID` | INT | `Accounts.AccountID` |
| `HoldToken` | VARCHAR | Unique token for the hold session |
| `ExpiresAt` | DATETIME2 | Hold expiry (typically 10-15 minutes) |
| `Status` | NVARCHAR | Values: `ACTIVE`, `RELEASED`, `CONVERTED` |
| `CreatedAt` | DATETIME2 | — |

**Relation to LichDatSan:** When the booking is confirmed, `SoftHold.Status` → `CONVERTED`
and a new `LichDatSan` row is created. No FK connects them in DB.

---

## 10. LichSuKhuyenMai — ANOMALY: FK references `TaiKhoan` not `Accounts`

**Source:** `sql/migration_promotional_codes.sql`

```sql
-- Original SQL (anomaly):
CONSTRAINT FK_LichSuKM_Account FOREIGN KEY (AccountID) REFERENCES TaiKhoan(AccountID)
```

`TaiKhoan` is not defined in V4 base schema or any migration file. It may be:
- An old table name from a pre-V4 schema (before rename to `Accounts`)
- A SQL synonym pointing to `Accounts`
- A bug in the migration script

**Impact:** The FK as written in the migration file would fail to apply to a clean DB that has
only the V4 schema. The `AccountID` column logically references `Accounts.AccountID`.

**Same anomaly in:** `sql/migration_refund_workflows.sql` (references `TaiKhoan`)

---

## 11. NhatKyChat — missing FK to booking context

**Source:** `src/main/java/org/example/model/NhatKyChat.java`,
`src/main/java/org/example/dao/NhatKyChatDAO.java`

The service layer stores `DatSanID` in `NhatKyChat.TrangThaiBot` JSON payload (inferred from
DAO code) when the chatbot is helping with a booking. No separate FK column exists in the table.

---

## 12. GhepKeo ↔ LichDatSan — booking optional

**Source:** `src/main/java/org/example/servlet/*GhepKeoServlet.java`

FK `FK_GhepKeo_LichDatSan` exists, but `DatSanID` is nullable. Service code checks:
- If `DatSanID IS NULL`: open/public match-finding (no court booked yet)
- If `DatSanID IS NOT NULL`: match attached to specific booking

This is a legitimate optional FK, not an anomaly.

---

## 13. CoSo ↔ Accounts — circular FK handled via deferred constraint add

**Source:** `Tài nguyên/QuanLiSport_V4.sql`

`CoSo.AccountID_QuanLy` → `Accounts.AccountID` and
`Accounts.CoSoID` → `CoSo.CoSoID` form a circular reference.
Both FKs are declared in DDL; the script adds `FK_CoSo_AccountQuanLy` after `Accounts`
is created. Application code must insert with NULL then UPDATE one side.

---

## 14. HoaDon — self-referencing via ParentHoaDonID

**Source:** `sql/migration_hoadon_loai.sql`

`HoaDon.ParentHoaDonID → HoaDon.HoaDonID` is a self-join declared as FK.
Used for: `MAIN` invoice ↔ `SUPPLEMENT` invoice (e.g., booking extension adds extra charge).

---

## 15. Teams ↔ GhepKeo — team-based matchmaking

**Source:** `sql/migration_team_management.sql`

`GhepKeo.TeamIDNguoiTao` → `Teams.TeamID` (nullable FK, added in migration)
`ChiTietGhepKeo.TeamIDNguoiThamGia` → `Teams.TeamID` (nullable FK, added in migration)

Both FKs are formalized in migration SQL. Listed here because the match-team relationship
is also enforced at the service layer: only CAPTAIN or CO_CAPTAIN can initiate team match.

---

*End of inferred-relations file.*
*Last updated from source scan: 2026-08-02*
