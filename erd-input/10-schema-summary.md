# 10-schema-summary.md
# V-SPORT / QuanLiSport — Schema Summary
# Generated: 2026-08-02

---

## ⚠️ DATA SOURCE NOTICE

**Không kết nối được database thực tế.**

Database credentials (`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`) are stored in environment
variables and are not committed to the repository. No live DB query was executed.

**Dữ liệu được trích xuất từ:**
1. `Tài nguyên/QuanLiSport_V4.sql` — base schema with 27 original tables
2. ~35 migration SQL files in `sql/` directory (all scanned)
3. Java model files in `src/main/java/org/example/model/` (for 6 tables with no DDL found)

All row counts show **N/A** (no live query run).

---

## TOTALS

| Metric | Count |
|---|---|
| Total tables | 58 |
| Tables from V4 base schema | 27 |
| Tables added by migrations | 25 |
| Tables inferred from Java model only | 6 |
| Total foreign key relationships | ~105 |
| Unique constraints | 14 |
| Check constraints | 29 |
| Named indexes (non-PK) | 14 |
| Views | 1 (`V_YeuCauNghi_ChiTiet`) |

---

## TABLE LIST BY MODULE

### Core / Auth
| Table | Notes |
|---|---|
| Roles | 27+ rows expected (from seeded roles) |
| Accounts | Central user table; all roles; soft-delete partial |
| AuditLog | Append-only; no FK to Accounts by design |

### Facility Management
| Table | Notes |
|---|---|
| CoSo | Facilities/venues; circular FK with Accounts |
| CoSoNganHang | 1-1 with CoSo; bank account for transfer payments |
| CoSoCapability | Feature flags per facility (PayOS, QR, etc.) |
| AdminTrash | Polymorphic soft-delete trash bin |

### Court Management
| Table | Notes |
|---|---|
| MonTheThao | Sport types |
| LoaiSan | Court types with pricing tiers |
| San | Individual courts |
| SanQR | QR code per court (1-1 with San) |
| SanQRTokenHistory | QR token rotation log |
| QRRequest | Customer requests via QR scan |

### Booking
| Table | Notes |
|---|---|
| LichDatSan | Central booking table; 20+ columns after migrations |
| LichDatSan_DichVu | Pre-ordered products for a booking |
| BookingExtension | Time extension records for active bookings |
| CourtChargeSegment | Per-segment billing (lighting on/off splits) |
| SoftHold | Temporary slot lock during online checkout (DDL inferred) |

### Payments
| Table | Notes |
|---|---|
| HoaDon | Invoices; self-referencing via ParentHoaDonID |
| ChiTietHoaDon | Line items per invoice |
| PayOSPaymentAttempt | PayOS payment link/QR tracking |
| NhomChiaTien | Group bill split session |
| NhomChiaTienChiTiet | Per-person share in group bill split |
| ChiaHoaDon | **DEPRECATED** — replaced by NhomChiaTien |
| MaQR | QR codes for ChiaHoaDon (deprecated) |
| HoanTien | Refund requests and status |

### Products & Services
| Table | Notes |
|---|---|
| DanhMucSanPham | Product categories |
| SanPham_DichVu | Products and services sold on-site |
| SportService | Sport-specific services (stringing, coaching, etc.) |
| RacketStringingConfig | Config for racket stringing service (1-1 with SportService) |
| ServiceMaterial | Materials inventory for sport services |
| ServiceOrder | Customer sport service orders |
| RacketStringingOrderDetail | Detail for stringing orders (1-1 with ServiceOrder) |
| ServiceOrderStatusHistory | Status change log for ServiceOrder (DDL inferred) |

### Promotions
| Table | Notes |
|---|---|
| KhuyenMai | Discount codes / promotions |
| KhuyenMaiHinhAnh | Promotion banner images |
| LichSuKhuyenMai | Promotion usage history; FK anomaly (see below) |

### Matchmaking
| Table | Notes |
|---|---|
| GhepKeo | Match-finding requests |
| ChiTietGhepKeo | Participants in a match |
| MonTheThaoYeuThich | N-N: user favorite sports |

### Team Management
| Table | Notes |
|---|---|
| Teams | Sports teams |
| TeamMembers | Team membership |
| TeamInvitations | Team invitations from captains |
| TeamJoinRequests | Join requests from non-members |

### Notifications & Chat
| Table | Notes |
|---|---|
| ThongBao | In-app push notifications |
| NhatKyChat | Chatbot conversation history |

### SOS / Emergency Recruitment
| Table | Notes |
|---|---|
| YeuCauSOS | Emergency player recruitment posts |
| NhatKySOSGui | SOS notification delivery log |

### Staff Management
| Table | Notes |
|---|---|
| CaLamViec | Staff work shifts |
| CaLamViecAudit | Shift change audit log (DDL inferred) |
| CaLamViecAvailability | Staff availability registration (DDL inferred) |
| CaLamViecSwapRequest | Shift swap requests (DDL inferred) |
| YeuCauNghi | Staff leave requests (DDL inferred from view + Java) |

### ELO / Reputation
| Table | Notes |
|---|---|
| LichSuELO | ELO score change history |
| CustomerReputationHistory | Reputation score change history |

### Parking
| Table | Notes |
|---|---|
| TheGiuXe | Parking spaces |
| LichXeRaVao | Vehicle entry/exit log |

---

## ANOMALIES DETECTED

### ANOMALY 1: TaiKhoan FK reference bug
**Files:** `sql/migration_promotional_codes.sql`, `sql/migration_refund_workflows.sql`
**Detail:** `LichSuKhuyenMai` and `HoanTien` migration scripts reference `TaiKhoan(AccountID)`
instead of `Accounts(AccountID)`. `TaiKhoan` is not defined in any scanned SQL file.
**Impact:** These FK constraints would fail to apply on a clean V4+ install.
**Likely cause:** Pre-V4 schema used `TaiKhoan` as the user table name.
**Recommended fix:** Change `REFERENCES TaiKhoan(AccountID)` → `REFERENCES Accounts(AccountID)`
in both migration files.

### ANOMALY 2: ChiaHoaDon is dead code
**File:** `sql/migration_group_bill_split.sql` (comment in file)
**Detail:** `ChiaHoaDon` and `MaQR` were V4 original tables for bill splitting.
They have been replaced by `NhomChiaTien` + `NhomChiaTienChiTiet` in a later migration.
The tables still exist in DB schema but should not receive new data.

### ANOMALY 3: 6 tables with DDL inferred from Java model only
The following tables have Java `@Entity` model classes but no `CREATE TABLE` DDL was found
in any scanned migration file:
- `YeuCauNghi` — confirmed via `fix_view_yeuCauNghi.sql` column references
- `ServiceOrderStatusHistory` — confirmed via `ServiceOrderStatusHistory.java`
- `CaLamViecAudit` — confirmed via `CaLamViecAudit.java`
- `CaLamViecAvailability` — confirmed via `CaLamViecAvailability.java`
- `CaLamViecSwapRequest` — confirmed via `CaLamViecSwapRequest.java`
- `SoftHold` — confirmed via `SoftHold.java`

These tables are included in all output files marked as "DDL inferred from Java model."
Their actual column definitions in the live database may differ from the Java model inference.

### ANOMALY 4: Circular FK between CoSo and Accounts
`CoSo.AccountID_QuanLy → Accounts.AccountID` and `Accounts.CoSoID → CoSo.CoSoID`
form a circular reference. Application code must manage insert order carefully.

---

## SECURITY NOTES

The following columns in `CoSo` store **sensitive API credentials**:
- `CoSo.PayOS_ClientID` — PayOS client identifier
- `CoSo.PayOS_ApiKey` — PayOS API key
- `CoSo.PayOS_ChecksumKey` — PayOS HMAC checksum key

**These column names are listed in schema output files for structural documentation only.**
**No actual credential values appear anywhere in this erd-input/ directory.**
**The credentials are stored encrypted in the database and loaded at runtime via environment variables.**

Additionally:
- `Accounts.Password` — bcrypt hashed passwords are stored in DB; no values in output files
- `Accounts.GoogleID`, `FacebookID`, `ZaloID`, `MessengerID` — OAuth IDs; structural only
- `Accounts.SoTaiKhoan`, `MaNganHang` — bank account info; structural only

---

## KEY DESIGN PATTERNS

| Pattern | Tables |
|---|---|
| Soft delete (IsDeleted + DeletedAt + DeletedBy) | San, LoaiSan, SanPham_DichVu, CaLamViec, ThongBao, LichDatSan, CoSo, Teams, SportService, ServiceMaterial, YeuCauNghi |
| 1-1 enforced via UNIQUE constraint | SanQR↔San, RacketStringingConfig↔SportService, RacketStringingOrderDetail↔ServiceOrder, CoSoNganHang↔CoSo |
| Polymorphic reference (EntityType+EntityID) | AuditLog, AdminTrash, ThongBao |
| PayOS online payment integration | PayOSPaymentAttempt, LichDatSan (PayOS columns), CoSo (PayOS keys) |
| ELO skill rating | LichSuELO, Accounts.DiemTrinhDo |
| Reputation scoring | CustomerReputationHistory, Accounts.DiemUyTin |
| Audit trail | AuditLog, CaLamViecAudit, ServiceOrderStatusHistory |
| Status machine | LichDatSan.TrangThai (8+ states), ServiceOrder.Status (8 states), HoanTien.TrangThai |

---

## FILES IN THIS erd-input/ DIRECTORY

| File | Description |
|---|---|
| `01-tables.csv` | All 58 tables with description |
| `02-columns.csv` | All columns with full type/constraint/FK info |
| `03-primary-keys.csv` | All primary keys including composite PKs |
| `04-foreign-keys.csv` | ~105 FK relationships with ON DELETE/UPDATE |
| `05-unique-constraints.csv` | 14 unique constraints and unique indexes |
| `06-indexes.csv` | All clustered + nonclustered indexes |
| `07-check-constraints.csv` | 29 check constraints |
| `08-full-schema.sql` | Complete DDL reconstructed from all source files |
| `09-inferred-relations.md` | Relations in source code not formalized as DB FKs |
| `10-schema-summary.md` | This file |
| `11-source-model-mapping.csv` | DB table → Java Model/DAO/Service/Servlet mapping |
