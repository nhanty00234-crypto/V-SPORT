# Soft Delete + Thùng Rác Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Chuyển mọi chức năng xóa sang xóa mềm (`IsDeleted/DeletedAt/DeletedBy`), thêm trang thùng rác Manager `/manager/thung-rac` với khôi phục + xóa vĩnh viễn, và job tự dọn sau 30 ngày.

**Architecture:** Thêm 3 cột soft-delete vào 8 bảng (Accounts đã có `isDeleted`). Mỗi DAO có `softDelete/restore/hardDelete/findDeletedByCoSo`. `ThungRacService` gom item đã xóa của một cơ sở thành `TrashItem` DTO cho servlet/JSP. `TrashCleanupListener` chạy `ScheduledExecutorService` 24h/lần để hard-delete bản ghi quá 30 ngày.

**Tech Stack:** Java 17 Servlet/JSP (Jakarta), JPA (JPAUtil) + JDBC (DBUtil) hỗn hợp, SQL Server, Tailwind CSS, Log4j2.

**Spec:** `docs/superpowers/specs/2026-07-02-soft-delete-trash-design.md`

## Global Constraints

- KHÔNG có test framework trong project — mỗi task kết thúc bằng `mvn -q compile` phải PASS và bước kiểm thử thủ công ghi rõ.
- SoftHold giữ nguyên xóa cứng — không đụng vào `SoftHoldDAOImpl`.
- "Tạm đóng" của San trở về là trạng thái nghiệp vụ thuần túy; xóa San dùng `IsDeleted`.
- Mọi thao tác thùng rác của Manager phải xác thực item thuộc `coSoId` của manager.
- Commit sau mỗi task, message tiếng Anh dạng `feat:`/`refactor:`.
- Encoding file Java/JSP: UTF-8. JSP theo style Tailwind + Material Symbols purple hiện có.
- Retention: 30 ngày, hằng số `Constants.TRASH_RETENTION_DAYS = 30`.

---

### Task 1: SQL migration script

**Files:**
- Create: `sql/migration_soft_delete.sql`

**Interfaces:**
- Produces: các cột `IsDeleted BIT NOT NULL DEFAULT 0`, `DeletedAt DATETIME NULL`, `DeletedBy INT NULL` trên các bảng `San, LoaiSan, SanPham_DichVu, CaLamViec, ThongBao, YeuCauNghi, LichDatSan, CoSo`; cột `DeletedAt, DeletedBy` trên `Accounts`.

- [ ] **Step 1: Viết script migration idempotent**

```sql
-- migration_soft_delete.sql
-- Chạy tay trên SQL Server. Idempotent: chạy lại không lỗi.

DECLARE @tables TABLE (TableName SYSNAME);
INSERT INTO @tables VALUES ('San'),('LoaiSan'),('SanPham_DichVu'),('CaLamViec'),
                           ('ThongBao'),('YeuCauNghi'),('LichDatSan'),('CoSo');

DECLARE @t SYSNAME, @sql NVARCHAR(MAX);
DECLARE cur CURSOR FOR SELECT TableName FROM @tables;
OPEN cur;
FETCH NEXT FROM cur INTO @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF COL_LENGTH(@t, 'IsDeleted') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@t) + N' ADD IsDeleted BIT NOT NULL DEFAULT 0';
        EXEC sp_executesql @sql;
    END
    IF COL_LENGTH(@t, 'DeletedAt') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@t) + N' ADD DeletedAt DATETIME NULL';
        EXEC sp_executesql @sql;
    END
    IF COL_LENGTH(@t, 'DeletedBy') IS NULL
    BEGIN
        SET @sql = N'ALTER TABLE ' + QUOTENAME(@t) + N' ADD DeletedBy INT NULL';
        EXEC sp_executesql @sql;
    END
    FETCH NEXT FROM cur INTO @t;
END
CLOSE cur; DEALLOCATE cur;

-- Accounts đã có isDeleted, chỉ bổ sung 2 cột:
IF COL_LENGTH('Accounts', 'DeletedAt') IS NULL
    ALTER TABLE Accounts ADD DeletedAt DATETIME NULL;
IF COL_LENGTH('Accounts', 'DeletedBy') IS NULL
    ALTER TABLE Accounts ADD DeletedBy INT NULL;

-- Dữ liệu cũ: San từng "xóa mềm" bằng trạng thái Tạm đóng — KHÔNG tự chuyển
-- sang IsDeleted=1 vì Tạm đóng cũng là trạng thái nghiệp vụ hợp lệ. Giữ nguyên.
PRINT 'Migration soft-delete hoàn tất.';
```

- [ ] **Step 2: Người dùng chạy script trên DB** — báo user chạy `sql/migration_soft_delete.sql` trong SSMS trước khi test runtime. (Code các task sau vẫn compile được mà không cần DB.)

- [ ] **Step 3: Commit**

```bash
git add sql/migration_soft_delete.sql
git commit -m "feat: add soft-delete migration script"
```

---

### Task 2: Hằng số + model fields

**Files:**
- Modify: `src/main/java/org/example/util/Constants.java` (thêm hằng số)
- Modify: `src/main/java/org/example/model/San.java`, `LoaiSan.java`, `SanPham_DichVu.java`, `CaLamViec.java`, `ThongBao.java`, `YeuCauNghi.java`, `Lichdatsan.java`, `CoSo.java`, `TaiKhoan.java`

**Interfaces:**
- Produces: `Constants.TRASH_RETENTION_DAYS` (int, = 30); trên mỗi model: `boolean isDeleted` + `LocalDateTime deletedAt` + `Integer deletedBy` với getter/setter chuẩn (`isDeleted()/setDeleted(boolean)`, `getDeletedAt()/setDeletedAt(...)`, `getDeletedBy()/setDeletedBy(...)`).

- [ ] **Step 1: Thêm hằng số vào Constants.java**

```java
// Trash / soft delete
public static final int TRASH_RETENTION_DAYS = 30;
```

- [ ] **Step 2: Thêm field vào từng model JPA** (San, LoaiSan, SanPham_DichVu, CoSo, TaiKhoan, CaLamViec... — với model JPA dùng annotation; TaiKhoan đã có `isDeleted` thì chỉ thêm 2 field mới):

```java
@Column(name = "IsDeleted")
private boolean isDeleted;

@Column(name = "DeletedAt")
private LocalDateTime deletedAt;

@Column(name = "DeletedBy")
private Integer deletedBy;

public boolean isDeleted() { return isDeleted; }
public void setDeleted(boolean deleted) { isDeleted = deleted; }
public LocalDateTime getDeletedAt() { return deletedAt; }
public void setDeletedAt(LocalDateTime deletedAt) { this.deletedAt = deletedAt; }
public Integer getDeletedBy() { return deletedBy; }
public void setDeletedBy(Integer deletedBy) { this.deletedBy = deletedBy; }
```

Với model không phải JPA entity (POJO dùng bởi DAO JDBC như ThongBao, YeuCauNghi, Lichdatsan, CaLamViec nếu là POJO): thêm field + getter/setter y hệt nhưng KHÔNG có `@Column`. Kiểm tra từng file trước khi sửa: nếu class có `@Entity` thì thêm `@Column`, nếu không thì bỏ. Import `java.time.LocalDateTime` khi cần.

Lưu ý TaiKhoan: nếu field sẵn có tên `deleted` với `@Column(name="isDeleted")` thì GIỮ NGUYÊN field đó, chỉ thêm `deletedAt`, `deletedBy`.

- [ ] **Step 3: Compile**

Run: `mvn -q compile` — Expected: BUILD SUCCESS

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/model src/main/java/org/example/util/Constants.java
git commit -m "feat: add soft-delete fields to models and retention constant"
```

---

### Task 3: DAO JPA — San, LoaiSan, SanPham_DichVu (soft delete + restore + hardDelete + findDeleted)

**Files:**
- Modify: `src/main/java/org/example/dao/SanDAO.java`, `LoaiSanDAO.java`, `SanPhamDichVuDAO.java` (interface)
- Modify: `src/main/java/org/example/dao/impl/SanDAOImpl.java`, `LoaiSanDAOImpl.java`, `SanPhamDichVuDAOImpl.java`

**Interfaces:**
- Produces (trên cả 3 DAO, thay `LoaiSan` bằng entity tương ứng):
  - `boolean softDelete(int id, int actorId)`
  - `boolean restore(int id)`
  - `boolean hardDelete(int id)`
  - `List<LoaiSan> findDeletedByCoSo(int coSoId)`
  - `List<LoaiSan> findDeletedOlderThan(int days)` (cho cleanup job)
- Consumes: model fields từ Task 2.

- [ ] **Step 1: Thêm method vào interface** (ví dụ LoaiSanDAO; SanDAO/SanPhamDichVuDAO tương tự với entity của chúng):

```java
boolean softDelete(int id, int actorId);
boolean restore(int id);
boolean hardDelete(int id);
List<LoaiSan> findDeletedByCoSo(int coSoId);
List<LoaiSan> findDeletedOlderThan(int days);
```

- [ ] **Step 2: Implement trong LoaiSanDAOImpl** (pattern chung cho cả 3 impl JPA — đổi entity class/tên field id tương ứng; method `delete(int)` cũ đổi body thành hard delete và giữ tên `hardDelete`, cập nhật caller ở task sau):

```java
@Override
public boolean softDelete(int id, int actorId) {
    EntityManager em = JPAUtil.getEntityManager();
    EntityTransaction trans = em.getTransaction();
    try {
        trans.begin();
        LoaiSan ls = em.find(LoaiSan.class, id);
        if (ls == null || ls.isDeleted()) { trans.rollback(); return false; }
        ls.setDeleted(true);
        ls.setDeletedAt(java.time.LocalDateTime.now());
        ls.setDeletedBy(actorId);
        em.merge(ls);
        trans.commit();
        return true;
    } catch (Exception e) {
        logger.error("Lỗi soft delete LoaiSan ID {}: {}", id, e.getMessage(), e);
        if (trans.isActive()) trans.rollback();
        return false;
    } finally {
        em.close();
    }
}

@Override
public boolean restore(int id) {
    EntityManager em = JPAUtil.getEntityManager();
    EntityTransaction trans = em.getTransaction();
    try {
        trans.begin();
        LoaiSan ls = em.find(LoaiSan.class, id);
        if (ls == null || !ls.isDeleted()) { trans.rollback(); return false; }
        ls.setDeleted(false);
        ls.setDeletedAt(null);
        ls.setDeletedBy(null);
        em.merge(ls);
        trans.commit();
        return true;
    } catch (Exception e) {
        logger.error("Lỗi restore LoaiSan ID {}: {}", id, e.getMessage(), e);
        if (trans.isActive()) trans.rollback();
        return false;
    } finally {
        em.close();
    }
}

@Override
public boolean hardDelete(int id) {
    // giữ nguyên body của delete(int) cũ (em.remove)
}

@Override
public List<LoaiSan> findDeletedByCoSo(int coSoId) {
    EntityManager em = JPAUtil.getEntityManager();
    try {
        return em.createQuery(
                "SELECT l FROM LoaiSan l WHERE l.coSoID = :coSoId AND l.isDeleted = true", LoaiSan.class)
                .setParameter("coSoId", coSoId)
                .getResultList();
    } finally {
        em.close();
    }
}

@Override
public List<LoaiSan> findDeletedOlderThan(int days) {
    EntityManager em = JPAUtil.getEntityManager();
    try {
        return em.createQuery(
                "SELECT l FROM LoaiSan l WHERE l.isDeleted = true AND l.deletedAt < :cutoff", LoaiSan.class)
                .setParameter("cutoff", java.time.LocalDateTime.now().minusDays(days))
                .getResultList();
    } finally {
        em.close();
    }
}
```

`SanDAOImpl` chưa có delete — thêm đủ 5 method. `SanPhamDichVuDAOImpl.delete()` cũ (em.remove) đổi tên thành `hardDelete`.

- [ ] **Step 3: Lọc query đang hoạt động trong 3 impl này** — thêm điều kiện vào các SELECT:
  - `SanDAOImpl.getAllSan()` → `SELECT s FROM San s WHERE s.isDeleted = false`
  - `SanDAOImpl.getSansByCoSo` → thêm `AND s.isDeleted = false`
  - `SanDAOImpl.countSanByTrangThai`, `countSansByLoaiSanId` → thêm `AND s.isDeleted = false`
  - `LoaiSanDAOImpl.getAllLoaiSan`, `getLoaiSansByCoSo` → thêm `l.isDeleted = false`
  - Các SELECT trong `SanPhamDichVuDAOImpl` → tương tự

- [ ] **Step 4: Compile** — `mvn -q compile`, Expected: BUILD SUCCESS (nếu có caller gọi `delete(` cũ bị lỗi compile → đổi caller sang `hardDelete(` tạm, task 6 sửa hành vi thật)

- [ ] **Step 5: Commit** — `git commit -m "feat: soft delete support in San/LoaiSan/SanPham DAOs"`

---

### Task 4: DAO JDBC — ThongBao, YeuCauNghi, LichDatSan, CaLamViec (soft delete)

**Files:**
- Modify: `src/main/java/org/example/dao/ThongBaoDAO.java` + `impl/ThongBaoDAOImpl.java`
- Modify: `src/main/java/org/example/dao/YeuCauNghiDAO.java` + `impl/YeuCauNghiDAOImpl.java`
- Modify: `src/main/java/org/example/dao/LichDatSanDAO.java` + `impl/LichDatSanDAOImpl.java`
- Modify: `src/main/java/org/example/dao/CaLamViecDAO.java` + `impl/CaLamViecDAOImpl.java`

**Interfaces:**
- Produces trên mỗi DAO: `boolean softDelete(int id, int actorId)`, `boolean restore(int id)`, `boolean hardDelete(int id)`, `List<X> findDeletedByCoSo(int coSoId)`, `List<Integer> findDeletedIdsOlderThan(int days)`.

- [ ] **Step 1: Pattern JDBC soft delete** (ví dụ ThongBao — các bảng khác thay tên bảng/cột id: `YeuCauNghi.YeuCauNghiID`, `LichDatSan.DatSanID`, `CaLamViec.CaLamViecID`):

```java
@Override
public boolean softDelete(int thongBaoId, int actorId) {
    String sql = "UPDATE ThongBao SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ? " +
                 "WHERE ThongBaoID = ? AND IsDeleted = 0";
    try (Connection conn = org.example.util.DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, actorId);
        ps.setInt(2, thongBaoId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        logger.error("Lỗi soft delete thông báo ID {}: {}", thongBaoId, e.getMessage(), e);
        return false;
    }
}

@Override
public boolean restore(int thongBaoId) {
    String sql = "UPDATE ThongBao SET IsDeleted = 0, DeletedAt = NULL, DeletedBy = NULL " +
                 "WHERE ThongBaoID = ? AND IsDeleted = 1";
    // cùng khung try-with-resources như trên
}

@Override
public boolean hardDelete(int thongBaoId) {
    String sql = "DELETE FROM ThongBao WHERE ThongBaoID = ?";
    // = body của delete() cũ; delete() cũ xóa đi, caller đổi sang softDelete
}
```

- [ ] **Step 2: findDeletedByCoSo — scope theo cơ sở qua join:**

```java
-- ThongBao (qua Accounts):
SELECT t.* FROM ThongBao t JOIN Accounts a ON t.AccountID = a.AccountID
WHERE a.CoSoID = ? AND t.IsDeleted = 1 ORDER BY t.DeletedAt DESC

-- YeuCauNghi (qua Accounts): tương tự join AccountID
-- LichDatSan (qua San):
SELECT b.* FROM LichDatSan b JOIN San s ON b.SanID = s.SanID
WHERE s.CoSoID = ? AND b.IsDeleted = 1 ORDER BY b.DeletedAt DESC
-- CaLamViec: nếu bảng có cột CoSoID thì WHERE CoSoID = ? trực tiếp,
-- nếu không thì join Accounts như ThongBao. Kiểm tra model CaLamViec trước khi viết.
```

Map ResultSet bằng hàm map sẵn có của từng DAO (vd `mapResultSetToThongBao`), nhớ set thêm 3 field mới nếu hàm map đọc `SELECT *`.

- [ ] **Step 3: findDeletedIdsOlderThan:**

```sql
SELECT ThongBaoID FROM ThongBao
WHERE IsDeleted = 1 AND DeletedAt < DATEADD(day, -?, GETDATE())
```

- [ ] **Step 4: Lọc mọi SELECT đang hoạt động trong 4 impl** — grep từng file tìm `"SELECT` và thêm `AND IsDeleted = 0` (hoặc `WHERE IsDeleted = 0` nếu chưa có WHERE). Chú ý query đếm/thống kê cũng phải lọc.

- [ ] **Step 5: Compile + commit** — `mvn -q compile` PASS rồi `git commit -m "feat: soft delete support in ThongBao/YeuCauNghi/LichDatSan/CaLamViec DAOs"`

---

### Task 5: DAO — CoSo + TaiKhoan

**Files:**
- Modify: `src/main/java/org/example/dao/CoSoDAO.java` + `impl/CoSoDAOImpl.java`
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java` + `impl/TaiKhoanDAOImpl.java`

**Interfaces:**
- Produces: `CoSoDAO.softDelete(int id, int actorId)`, `CoSoDAO.restore(int id)`, `CoSoDAO.hardDeleteCascade(int id)` (= cascade 16 bước cũ, đổi tên từ delete cũ), `CoSoDAO.findDeletedOlderThan(int days)`.
- TaiKhoan: `softDeleteAccount/restoreAccount/permanentDeleteAccount` giữ nguyên tên, sửa SQL để set/clear `DeletedAt, DeletedBy`; thêm `findDeletedByCoSo(int coSoId)` và `findDeletedIdsOlderThan(int days)`.

- [ ] **Step 1: CoSo — softDelete/restore là UPDATE 1 dòng** (KHÔNG cascade):

```java
@Override
public boolean softDelete(int coSoId, int actorId) {
    String sql = "UPDATE CoSo SET IsDeleted = 1, DeletedAt = GETDATE(), DeletedBy = ? " +
                 "WHERE CoSoID = ? AND IsDeleted = 0";
    // JDBC try-with-resources như pattern Task 4
}
```

Method delete cascade cũ đổi tên `hardDeleteCascade(int id)`, giữ nguyên 16 bước. Caller admin đổi sang `softDelete`.

- [ ] **Step 2: TaiKhoan — cập nhật SQL hiện có:**

```sql
-- softDeleteAccount: UPDATE Accounts SET isDeleted = 1, isLocked = 1, DeletedAt = GETDATE(), DeletedBy = ? WHERE AccountID = ?
-- (thêm tham số actorId vào chữ ký: softDeleteAccount(int id, int actorId); caller cũ truyền id người thao tác từ session)
-- restoreAccount: UPDATE Accounts SET isDeleted = 0, isLocked = 0, DeletedAt = NULL, DeletedBy = NULL WHERE AccountID = ?
```

`findDeletedByCoSo`: `SELECT * FROM Accounts WHERE CoSoID = ? AND isDeleted = 1`.

- [ ] **Step 3: Lọc SELECT trong CoSoDAOImpl** (`WHERE IsDeleted = 0`) và xác nhận các SELECT trong TaiKhoanDAOImpl đã lọc `isDeleted = 0` (đa số đã có vì cơ chế cũ — chỉ bổ sung nơi thiếu).

- [ ] **Step 4: Compile + commit** — `git commit -m "feat: soft delete for CoSo and unified account soft delete metadata"`

---

### Task 6: Service + Servlet — chuyển mọi handler xóa sang softDelete

**Files:**
- Modify: `src/main/java/org/example/service/manager/SanService.java` (deleteSan → set isDeleted thay vì trạng thái Tạm đóng; deleteLoaiSan → softDelete; thêm restore/hardDelete tương ứng có check branch)
- Modify: `src/main/java/org/example/service/manager/CaLamService.java` (deleteShift → softDelete, giữ validation + audit + notification)
- Modify: `src/main/java/org/example/service/manager/NhanSuService.java` (deleteStaff truyền actorId)
- Modify: `src/main/java/org/example/controller/QuanLySanManagerServlet.java` (handleDeleteSan/handleDeleteLoaiSan message mới; truyền actorId = manager.getAccountId())
- Modify: `src/main/java/org/example/controller/manager/QuanLySanManagerServlet.java` (Manager: soft-delete San — admin `QuanLySanServlet` đã bị xóa; chỉ còn `/manager/quan-ly-san`)
- Modify: `src/main/java/org/example/controller/QuanLyCaLamManagerServlet.java`
- Modify: `src/main/java/org/example/controller/manager/KhoDichVuManagerServlet.java` (bỏ nhánh conditional hard delete — luôn softDelete)
- Modify: `src/main/java/org/example/controller/QuanLyNguoiDungServlet.java`, `controller/manager/NhanSuManagerServlet.java` (truyền actorId)
- Modify: servlet admin quản lý cơ sở (tìm bằng `Grep "hardDeleteCascade\|CoSoDAO" src/main/java/org/example/controller`) → chuyển sang `coSoDAO.softDelete`, thêm action `restoreCoSo`.

**Interfaces:**
- Consumes: DAO methods Task 3-5.
- Produces: `SanService.deleteSan(int sanId, int coSoId, int actorId)` (đổi chữ ký, cập nhật caller), `SanService.deleteLoaiSan(int loaiSanId, int coSoId, int actorId)`, `SanService.restoreSan(int sanId, int coSoId)` với rule chặn: nếu `loaiSanDAO.getLoaiSanById(san.getLoaiSanID()).isDeleted()` → throw `IllegalStateException("Hãy khôi phục loại sân trước khi khôi phục sân này.")`.

- [ ] **Step 1: SanService.deleteSan** — bỏ set trạng thái Tạm đóng:

```java
public void deleteSan(int sanId, int coSoId, int actorId) {
    San san = sanDAO.getSanById(sanId);
    BranchSecurityUtils.validateSanBelongsToCoSo(san, coSoId); // giữ check branch hiện có
    sanDAO.softDelete(sanId, actorId);
}
```

`deleteLoaiSan`: GIỮ guard "còn sân đang dùng loại này thì chặn" (`countSansByLoaiSanId > 0` — giờ count đã lọc isDeleted=0 nên sân trong thùng rác không chặn nữa), sau đó `loaiSanDAO.softDelete(loaiSanId, actorId)`.

- [ ] **Step 2: Cập nhật từng servlet** — mỗi handler delete truyền `((TaiKhoan) session.getAttribute("user")).getAccountId()` làm actorId, message đổi thành dạng `"Đã chuyển vào thùng rác. Có thể khôi phục trong 30 ngày."`. KhoDichVu: xóa nhánh `existsInInvoices` phân biệt hard/soft — luôn `softDelete`.

- [ ] **Step 3: Grep xác nhận không còn đường xóa cứng từ UI:**

Run: `grep -rn "hardDelete\|\.delete(" src/main/java/org/example/controller` — Expected: các match chỉ là `permanentDelete` action (nút xóa vĩnh viễn) hoặc code không phải delete entity.

- [ ] **Step 4: Compile + commit** — `git commit -m "refactor: route all delete handlers through soft delete"`

---

### Task 7: Quét query toàn cục — ẩn bản ghi đã xóa khỏi mọi màn hình

**Files:**
- Modify: mọi DAO/Service còn lại có SELECT trên 9 bảng trên (ngoài các file đã sửa ở Task 3-5): `HoaDonDAOImpl`, `DatSanDAOImpl`, `CustomerBranchDAOImpl`, `CoSoDAOImpl`, các service booking/trang chủ khách hàng...

- [ ] **Step 1: Grep tìm mọi query đụng 9 bảng:**

Run (Git Bash):
```bash
grep -rln -e "FROM San\b" -e "FROM LoaiSan" -e "FROM SanPham_DichVu" -e "FROM CaLamViec\b" \
  -e "FROM ThongBao" -e "FROM YeuCauNghi" -e "FROM LichDatSan" -e "FROM CoSo\b" -e "FROM Accounts" \
  src/main/java | sort -u
```

- [ ] **Step 2: Với từng file, từng query:** thêm `AND <alias>.IsDeleted = 0` (SQL) hoặc `AND x.isDeleted = false` (JPQL). Quy tắc: chỉ lọc bảng chính của nghiệp vụ hiển thị; JOIN lịch sử (vd hóa đơn join San để lấy tên sân) KHÔNG lọc bảng join — hóa đơn cũ vẫn phải hiện tên sân đã xóa.

- [ ] **Step 3: Kiểm thử thủ công:** đăng nhập customer → trang đặt sân không hiện sân đã xóa; manager → các trang danh sách không hiện item đã xóa.

- [ ] **Step 4: Compile + commit** — `git commit -m "refactor: filter soft-deleted records from all active queries"`

---

### Task 8: ThungRacService + TrashItem DTO

**Files:**
- Create: `src/main/java/org/example/service/manager/ThungRacService.java`

**Interfaces:**
- Produces:

```java
public class ThungRacService {
    public static class TrashItem {
        private String entityType;   // "san","loaiSan","sanPham","caLam","thongBao","yeuCauNghi","booking","nhanSu"
        private String entityLabel;  // "Sân", "Loại sân", ...
        private int id;
        private String name;         // tên hiển thị
        private LocalDateTime deletedAt;
        private Integer deletedBy;
        private String deletedByName; // resolve qua TaiKhoanDAO, null-safe
        private long daysLeft;        // TRASH_RETENTION_DAYS - số ngày đã trôi, floor 0
        // getters/setters đầy đủ
    }
    public List<TrashItem> getTrashByCoSo(int coSoId);
    public void restore(String entityType, int id, int coSoId);      // switch theo type, verify branch, áp rule chặn San
    public void permanentDelete(String entityType, int id, int coSoId);
}
```

- [ ] **Step 1: Implement getTrashByCoSo** — gọi lần lượt `findDeletedByCoSo` của 8 DAO, map sang TrashItem (name: San→tenSan, LoaiSan→tenLoai, SanPham→tenSP, CaLam→"Ca " + ngày + tên NV, ThongBao→tieuDe, YeuCauNghi→"Đơn nghỉ " + ngày, Booking→"Booking #" + id + tên sân, NhanSu→hoTen), sort theo deletedAt giảm dần. `daysLeft = Math.max(0, TRASH_RETENTION_DAYS - ChronoUnit.DAYS.between(deletedAt, LocalDateTime.now()))`.

- [ ] **Step 2: Implement restore** — switch entityType; mỗi nhánh: load bản ghi, verify thuộc coSoId (throw `IllegalArgumentException("Không có quyền thao tác item này.")` nếu sai), nhánh `"san"` kiểm tra LoaiSan cha chưa xóa, rồi gọi `restore` của DAO. `"nhanSu"` gọi `taiKhoanDAO.restoreAccount`.

- [ ] **Step 3: Implement permanentDelete** — verify branch như trên rồi gọi `hardDelete` của DAO tương ứng.

- [ ] **Step 4: Compile + commit** — `git commit -m "feat: ThungRacService aggregating per-branch trash"`

---

### Task 9: ThungRacManagerServlet + JSP thùng rác + sidebar

**Files:**
- Create: `src/main/java/org/example/controller/ThungRacManagerServlet.java`
- Create: `src/main/webapp/manager/ThungRac.jsp`
- Modify: file sidebar manager (tìm bằng `grep -rln "quan-ly-san" src/main/webapp/manager` — thêm link vào cùng chỗ các trang khác; nếu mỗi JSP tự chứa sidebar thì thêm vào tất cả JSP manager)

**Interfaces:**
- Consumes: `ThungRacService` (Task 8).
- Produces: route `/manager/thung-rac` (GET danh sách + POST `action=restore|permanentDelete`, params `entityType`, `id`).

- [ ] **Step 1: Servlet** — copy khung auth/branch của `QuanLySanManagerServlet` (check ROLE_MANAGER + coSoId):

```java
@WebServlet("/manager/thung-rac")
public class ThungRacManagerServlet extends HttpServlet {
    private final ThungRacService thungRacService = new ThungRacService();

    // doGet: setAttribute("trashItems", thungRacService.getTrashByCoSo(coSoId));
    //        forward /manager/ThungRac.jsp
    // doPost: action=restore → thungRacService.restore(type, id, coSoId); message "Đã khôi phục thành công!"
    //         action=permanentDelete → thungRacService.permanentDelete(...); message "Đã xóa vĩnh viễn."
    //         catch IllegalArgumentException/IllegalStateException → session "error"
    //         redirect về /manager/thung-rac
}
```

- [ ] **Step 2: JSP** — theo layout/style purple của `QuanLySan.jsp`: header "Thùng rác", tab filter theo entityType (client-side JS lọc bảng), ô search theo name, bảng cột: Loại (badge màu theo type) / Tên / Người xóa / Ngày xóa / Còn lại ("còn N ngày" — đỏ nếu ≤ 5) / Hành động (form POST nút Khôi phục màu emerald icon `restore_from_trash`, nút Xóa vĩnh viễn màu đỏ icon `delete_forever` có `onclick="return confirm('Xóa vĩnh viễn? Hành động này không thể hoàn tác!')"`). Empty state icon `recycling` + "Thùng rác trống". Render message/error session như các trang manager khác.

- [ ] **Step 3: Sidebar** — thêm mục:

```html
<a href="${pageContext.request.contextPath}/manager/thung-rac" class="...same classes as siblings...">
    <span class="material-symbols-outlined">delete</span> Thùng rác
</a>
```

- [ ] **Step 4: Kiểm thử thủ công** — rebuild + deploy: xóa 1 sân, 1 loại sân, 1 sản phẩm → vào thùng rác thấy đủ 3 item; khôi phục sân khi loại sân cha còn trong rác → thấy lỗi chặn; khôi phục loại sân rồi sân → OK; xóa vĩnh viễn 1 item → mất khỏi DB.

- [ ] **Step 5: Commit** — `git commit -m "feat: manager trash page with restore and permanent delete"`

---

### Task 10: TrashCleanupListener — tự dọn sau 30 ngày

**Files:**
- Create: `src/main/java/org/example/listener/TrashCleanupListener.java`

**Interfaces:**
- Consumes: `findDeletedOlderThan`/`findDeletedIdsOlderThan` + `hardDelete` của các DAO; `CoSoDAO.hardDeleteCascade`.

- [ ] **Step 1: Implement listener**

```java
package org.example.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.util.Constants;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class TrashCleanupListener implements ServletContextListener {

    private static final Logger logger = LogManager.getLogger(TrashCleanupListener.class);
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "trash-cleanup");
            t.setDaemon(true);
            return t;
        });
        scheduler.scheduleAtFixedRate(this::cleanup, 1, 24, TimeUnit.HOURS);
        logger.info("TrashCleanupListener started, retention {} days", Constants.TRASH_RETENTION_DAYS);
    }

    private void cleanup() {
        try {
            int days = Constants.TRASH_RETENTION_DAYS;
            // Thứ tự con → cha để tôn trọng FK:
            // 1. LichDatSan  2. ThongBao  3. YeuCauNghi  4. CaLamViec
            // 5. San  6. LoaiSan  7. SanPham_DichVu  8. Accounts  9. CoSo (cascade)
            // mỗi bước: dao.findDeleted...OlderThan(days) → loop hardDelete, log số lượng
        } catch (Exception e) {
            logger.error("Trash cleanup failed: {}", e.getMessage(), e);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) scheduler.shutdownNow();
    }
}
```

Điền phần thân `cleanup()` với 9 bước gọi DAO như comment; CoSo quá hạn gọi `hardDeleteCascade`.

- [ ] **Step 2: Kiểm thử thủ công** — tạm đổi `TRASH_RETENTION_DAYS` chạy với `DATEADD(minute, ...)`? Không — thay vào đó UPDATE tay `DeletedAt = DATEADD(day, -31, GETDATE())` cho 1 bản ghi test trong SSMS, restart Tomcat, đợi lần chạy đầu (delay 1h → để test nhanh, tạm đổi `scheduleAtFixedRate(this::cleanup, 1, 24, TimeUnit.HOURS)` initial delay thành `TimeUnit.MINUTES` trong lúc test rồi trả lại). Xác nhận bản ghi bị xóa cứng.

- [ ] **Step 3: Compile + commit** — `git commit -m "feat: scheduled trash cleanup after 30-day retention"`

---

### Task 11: Phía Admin — khôi phục CoSo + đồng bộ trang người dùng

**Files:**
- Modify: servlet + JSP admin quản lý cơ sở (tìm: `grep -rln "CoSo" src/main/java/org/example/controller | grep -iv manager`) — thêm filter "Đã xóa" + nút Khôi phục (POST `action=restoreCoSo` → `coSoDAO.restore(id)`)
- Modify: `QuanLyNguoiDungServlet` — đảm bảo softDelete truyền actorId (đã làm Task 6), JSP admin users thêm cột ngày xóa nếu đang có view "đã xóa"

- [ ] **Step 1: Trang cơ sở admin** — thêm toggle/filter hiển thị cơ sở `IsDeleted = 1` (DAO thêm `findDeleted()` toàn cục cho admin), mỗi dòng đã xóa có nút "Khôi phục" (emerald) và "Xóa vĩnh viễn" (đỏ, confirm dialog, gọi `hardDeleteCascade`).

- [ ] **Step 2: Kiểm thử thủ công** — admin xóa 1 cơ sở test → biến mất khỏi danh sách chính, KHÔNG mất dữ liệu con trong DB; khôi phục → mọi thứ trở lại; manager của cơ sở bị xóa không đăng nhập thao tác được dữ liệu (các query lọc CoSo).

- [ ] **Step 3: Compile + commit** — `git commit -m "feat: admin restore for soft-deleted branches"`

---

### Task 12: Kiểm thử tổng + hoàn tất

- [ ] **Step 1: Chạy checklist kiểm thử của spec:**
  1. Mỗi entity: xóa → mất khỏi danh sách chính, hiện trong thùng rác → khôi phục → trở lại.
  2. Chặn khôi phục San khi LoaiSan cha trong rác.
  3. Xóa vĩnh viễn xóa thật khỏi DB.
  4. Manager cơ sở A không thấy item cơ sở B (thử sửa param POST bằng id của cơ sở khác → nhận lỗi quyền).
  5. Cleanup job xóa bản ghi quá 30 ngày (test bằng UPDATE DeletedAt lùi 31 ngày).
- [ ] **Step 2: Fix mọi lỗi phát sinh, compile PASS.**
- [ ] **Step 3: Commit cuối** — `git commit -m "feat: complete soft-delete trash system"`
