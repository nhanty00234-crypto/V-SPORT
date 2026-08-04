# 00 — Thông tin bộ xuất ERD V-SPORT

| Mục | Giá trị |
|---|---|
| Thời gian xuất | 2026-08-04 10:15 (+07:00) |
| Branch hiện tại | `main` |
| Commit hiện tại | `ec7f577d48a468d97d352ea996cb97f7188cd8a8` — *docs(face): kế hoạch triển khai điểm danh một chạm* |
| Tên database | `QuanLiSport` (Microsoft SQL Server) |
| Có kết nối được DB thật khi xuất? | **KHÔNG** |
| Snapshot DB thật gần nhất được dùng | `docs/erd/schema-full.json` — dump `INFORMATION_SCHEMA` + `sys.*` ngày **2026-08-02** |

## Vì sao không kết nối được database

`src/main/java/org/example/util/DBUtil.java` bắt buộc lấy cấu hình từ biến môi trường
`DB_URL`, `DB_USERNAME`, `DB_PASSWORD` (hoặc system property `db.url` / `db.username` /
`db.password`). Trong môi trường xuất này:

- Không có biến môi trường `DB_URL` / `DB_USERNAME` / `DB_PASSWORD`.
- `src/main/resources/META-INF/persistence.xml` để trống các thuộc tính JDBC.
- Máy không có client SQL Server (`sqlcmd`, `pyodbc`, `pymssql` đều không có).

Do đó **không có câu lệnh nào được chạy lên database thật** — kể cả `SELECT`.
Không có INSERT/UPDATE/DELETE/DROP/ALTER nào được thực hiện.

## Nguồn dữ liệu đã sử dụng (theo thứ tự ưu tiên)

1. **`docs/erd/schema-full.json`** — *nguồn chính (SourceOfTruth = `LIVE_DB_SNAPSHOT_2026-08-02`)*.
   Đây là bản dump metadata thật của database `QuanLiSport` (53 bảng, 627 cột, 103 FK,
   65 index, 52 PK). Được sinh tự động ngày 2026-08-02 theo `docs/erd/README.md`.
   Mọi thông tin trong bộ xuất mà snapshot này có đều được lấy từ đây, kể cả khi
   migration SQL hoặc tài liệu cũ nói khác.
2. **Các file migration SQL trong repo** — dùng để bổ sung những gì snapshot không có
   (IDENTITY, CHECK, tên constraint DEFAULT) và những bảng/cột được thêm *sau* ngày
   snapshot. Mọi mục thuộc loại này mang `SourceOfTruth = MIGRATION_SQL` hoặc
   `MIGRATION_SQL_NOT_IN_SNAPSHOT` và có ghi chú "chưa xác minh trên DB thật".
3. **Source code Java** (`model/`, `dao/`, `service/`, `controller/`) — dùng để xác định
   quan hệ suy luận, tình trạng sử dụng của bảng và ánh xạ bảng ↔ class.

Thư mục `erd-input/` (bộ xuất cũ ngày 2026-08-03) **không** được dùng làm nguồn dữ liệu
vì có sai sót đã kiểm chứng (xem `19-schema-conflicts-and-orphans.md`, mục "Sai sót của
bộ xuất cũ").

## Danh sách thư mục / file đã quét

- `docs/erd/schema-full.json`, `docs/erd/schema-summary.json`, `docs/erd/README.md`
- `sql/*.sql` — 61 file. Trong đó 36 file `migration_*` / `create_*` được phân tích DDL;
  các file `verify_*`, `rollback_*`, `diagnose_*`, `repair_*`, `fix_*`, `seed_*` chỉ được
  đọc tham khảo, không dùng để sinh schema.
- `src/main/resources/migration_face_attendance.sql`
- `Tài nguyên/QuanLiSport_V4.sql` (schema gốc V4). Các file
  `QuanLiSport_Master_V3.sql`, `QuanLiSport_Master_AI_V1/V2.sql` là phiên bản cũ hơn,
  đã bị V4 thay thế nên không dùng để sinh schema.
- `src/main/java/org/example/{model,dao,service,controller}/**`
- `src/main/resources/META-INF/persistence.xml` (không có mapping entity — dự án chủ yếu
  dùng JDBC thủ công, chỉ vài chỗ dùng JPA với entity `TaiKhoan`).
- `.worktrees/` và `.claude/worktrees/` bị **loại trừ** (bản sao cũ của repo).

## Giới hạn và dữ liệu chưa thể xác minh

1. **Snapshot trễ 2 ngày.** Snapshot chụp 2026-08-02; commit gần nhất là 2026-08-04.
   15 bảng và 24 cột chỉ tồn tại trong migration SQL, chưa biết đã chạy trên DB thật hay
   chưa. Tất cả đều được đánh dấu rõ trong CSV.
2. **ON DELETE / ON UPDATE**: snapshot không dump `sys.foreign_keys.delete_referential_action`.
   Trong `04-foreign-keys.csv` ghi `NO ACTION` — đây là **mặc định của SQL Server**, không
   phải giá trị đọc được từ DB. Cần kết nối DB thật để xác nhận, đặc biệt nếu có CASCADE.
3. **Tên constraint của DEFAULT**: snapshot chỉ có biểu thức `COLUMN_DEFAULT`, không có tên
   constraint. `08-default-constraints.csv` ghi `(tên constraint không có trong snapshot)`
   cho các cột thuộc DB thật.
4. **CHECK constraint**: snapshot không dump `sys.check_constraints`. Toàn bộ
   `07-check-constraints.csv` lấy từ migration SQL → có thể thiếu hoặc thừa so với DB thật.
5. **IDENTITY**: snapshot không có cờ identity. Giá trị trong `02-columns.csv` suy ra từ
   DDL migration; cột nào không tìm được DDL thì để trống chứ không đoán.
6. **`EstimatedRowCount`**: không có (`N/A (không kết nối được DB)`).
7. **INCLUDE columns / filtered index**: snapshot chỉ có danh sách cột khóa, nên
   `IncludedColumns` và `FilterDefinition` của index thuộc DB thật để trống.
8. **`sql/migration_guard_module.sql` viết bằng cú pháp MySQL** (`AUTO_INCREMENT`, `ENUM`,
   `TEXT`, `ADD COLUMN IF NOT EXISTS`, `INDEX` inline) nên **không chạy được trên SQL Server**.
   Bảng `SuCo` được giữ nguyên kiểu dữ liệu gốc trong bộ xuất, không tự dịch sang kiểu
   SQL Server. Xem `19-schema-conflicts-and-orphans.md`.

## Bảo mật

Bộ xuất này **không chứa**: mật khẩu, chuỗi kết nối, PayOS client/api/checksum key, mật khẩu
email, token, dữ liệu cá nhân hay bất kỳ câu `INSERT` dữ liệu thật nào. Địa chỉ máy chủ DB
xuất hiện trong `docs/erd/README.md` (file có sẵn trong repo) **không** được sao chép vào đây.
