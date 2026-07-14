# Admin Trash Unification & Owner Approval Fix — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** (1) Đưa toàn bộ role Admin về DUY NHẤT một trang thùng rác `/admin/thung-rac` với giao diện lấy cảm hứng từ Manager Trash, xóa mọi UI thùng rác riêng lẻ trong các trang Admin. (2) Sửa luồng Owner Request để dữ liệu "Chờ duyệt"/"Từ chối" không rò rỉ vào trang Quản lý Cơ sở và Nhân sự, và việc duyệt/từ chối Owner chạy trong transaction nhất quán.

**Architecture:** Không tạo bảng/route thùng rác thứ hai. Giữ nguyên bảng `AdminTrash` (log/ledger) làm nguồn dữ liệu duy nhất cho `/admin/thung-rac`. Thêm một service mới `OwnerApprovalService` (JPA, một `EntityManager`/`EntityTransaction` duy nhất) làm lõi dùng chung cho cả hai entry-point duyệt/từ chối hiện có (`AdminOwnerServlet`, `QuanLyChiNhanhServlet`), để đảm bảo bất biến "Account mở khóa ⇔ CoSo Đang hoạt động". Lọc hiển thị pending/rejected bằng điều kiện `TrangThai` ở tầng DAO (JPQL), không đổi cấu trúc bảng.

**Tech Stack:** Java Servlet (Jakarta), JPA/Hibernate (`JPAUtil`), JDBC thuần cho `AdminTrash`/`AuditLog`, JSP + JSTL + TailwindCDN, không có test framework (không có `src/test`, không JUnit/Mockito trong `pom.xml`) — do đó bước "test" của mỗi task là `mvn clean compile` + kiểm tra thủ công qua HTTP/SQL, không phải unit test tự động.

## Global Constraints

- Không hard delete bất kỳ dữ liệu nào. Không thêm nút "Xóa vĩnh viễn" ở bất kỳ đâu trong role Admin.
- Không copy backend/quyền của Manager Trash sang Admin. Chỉ tham khảo phong cách UI (spacing, badge, table, empty state) của `src/main/webapp/manager/ThungRac.jsp`.
- Route thùng rác Admin chính thức duy nhất: `GET /admin/thung-rac` (đã có, không đổi).
- Không sửa PayOS, booking, check-in, hóa đơn, ca làm. Các thay đổi DAO `CoSo`/`TaiKhoan` chỉ thêm điều kiện lọc theo `TrangThai`/`IsDeleted`, không đổi logic đặt sân.
- Comment/Javadoc mới viết bằng tiếng Việt. Tên class/method/biến/package giữ tiếng Anh.
- Không commit, không push — chỉ sửa working tree.
- Field JPA xác nhận từ entity thật (không đoán): `CoSo.TrangThai`, `CoSo.AccountID_QuanLy`, `CoSo.isDeleted` (model dùng PascalCase cho hầu hết field, riêng `isDeleted`/`deletedAt`/`deletedBy` là camelCase); `TaiKhoan.accountId`, `TaiKhoan.roleId`, `TaiKhoan.isDeleted` (camelCase).
- Trước khi coi Task 1 là xong, chạy `SELECT TrangThai, COUNT(*) FROM CoSo GROUP BY TrangThai;` trên DB thật để xác nhận không có giá trị `TrangThai` nào khác bị lọc nhầm ngoài dự kiến (`Chờ duyệt`, `Từ chối`).

---

### Task 1: Loại "Chờ duyệt"/"Từ chối" khỏi truy vấn Quản lý Cơ sở

**Files:**
- Modify: `src/main/java/org/example/dao/impl/CoSoDAOImpl.java:20-28` (`getAllCoSo()`)

**Interfaces:**
- Consumes: không đổi chữ ký `List<CoSo> getAllCoSo()` — mọi caller hiện tại (`QuanLyChiNhanhServlet`, `AdminOwnerServlet` không dùng hàm này, `AdminDashboardServlet`, `QuanLyNguoiDungServlet`, `DatSanServlet`) không cần sửa.
- Produces: `getAllCoSo()` giờ chỉ trả về CoSo có `TrangThai` khác `Chờ duyệt` và `Từ chối`.

- [ ] **Step 1: Chạy truy vấn xác nhận giá trị TrangThai thật trong DB**

Chạy trên DB thật (SSMS hoặc `sqlcmd`):

```sql
SELECT TrangThai, COUNT(*) FROM CoSo GROUP BY TrangThai;
```

Ghi lại kết quả. Nếu có giá trị `TrangThai` khác ngoài `Chờ duyệt`, `Từ chối`, `Đang hoạt động`, `Hoạt động` — chúng vẫn được giữ hiển thị vì Step 2 dùng `NOT IN` (loại trừ), không dùng allow-list.

- [ ] **Step 2: Sửa `getAllCoSo()` để loại trừ Chờ duyệt/Từ chối**

Trong `src/main/java/org/example/dao/impl/CoSoDAOImpl.java`, thay:

```java
    @Override
    public List<CoSo> getAllCoSo() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM CoSo c WHERE c.isDeleted = false OR c.isDeleted IS NULL", CoSo.class).getResultList();
        } finally {
            em.close();
        }
    }
```

bằng:

```java
    @Override
    public List<CoSo> getAllCoSo() {
        // Loại trừ cơ sở đang "Chờ duyệt"/"Từ chối" vì đây là yêu cầu Owner
        // chưa được Admin duyệt, không phải cơ sở đang vận hành thật sự.
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM CoSo c WHERE (c.isDeleted = false OR c.isDeleted IS NULL) " +
                    "AND c.TrangThai NOT IN ('Chờ duyệt', 'Từ chối')", CoSo.class)
                .getResultList();
        } finally {
            em.close();
        }
    }
```

- [ ] **Step 3: Biên dịch**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`, không lỗi ở `CoSoDAOImpl.java`.

- [ ] **Step 4: Ghi chú tác động phụ (không phải lỗi)**

`getAllCoSo()` cũng được `DatSanServlet` (trang đặt sân khách hàng) và `AdminDashboardServlet` dùng — fix này khiến cơ sở "Chờ duyệt"/"Từ chối" cũng biến mất khỏi danh sách đặt sân công khai, đây là tác dụng phụ tích cực đúng nghiệp vụ, không phải thay đổi logic booking (không sửa file `DatSanServlet.java`).

---

### Task 2: Thêm truy vấn Nhân sự loại Owner chưa duyệt/bị từ chối

**Files:**
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java` (thêm method vào interface)
- Modify: `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java` (thêm implementation, sau `getAllAccounts()` dòng 44-54)
- Modify: `src/main/java/org/example/controller/admin/QuanLyNguoiDungServlet.java:63`

**Interfaces:**
- Consumes: `CoSo.AccountID_QuanLy`, `CoSo.TrangThai`, `CoSo.isDeleted`, `TaiKhoan.roleId`, `TaiKhoan.accountId`, `TaiKhoan.isDeleted` (đã xác nhận ở Global Constraints).
- Produces: `List<TaiKhoan> getStaffDirectoryAccounts()` — dùng riêng cho trang Nhân sự, KHÔNG thay thế `getAllAccounts()` (vẫn giữ nguyên vì `AdminOwnerServlet`/`AdminDashboardServlet` cần thấy toàn bộ account kể cả Owner pending).

- [ ] **Step 1: Thêm khai báo method vào interface**

Trong `src/main/java/org/example/dao/TaiKhoanDAO.java`, thêm ngay sau dòng khai báo `List<TaiKhoan> getAllAccounts();` (dòng 25):

```java
    /**
     * Danh sách tài khoản dùng cho trang Nhân sự Admin: loại Owner (RoleID=2)
     * chưa có cơ sở nào được duyệt (chỉ có CoSo "Chờ duyệt" hoặc "Từ chối").
     */
    List<TaiKhoan> getStaffDirectoryAccounts();
```

- [ ] **Step 2: Thêm implementation**

Trong `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java`, thêm ngay sau method `getAllAccounts()` (sau dòng 54, trước `getDeletedAccounts()`):

```java
    @Override
    public List<TaiKhoan> getStaffDirectoryAccounts() {
        // Owner (RoleID=2) chỉ hiển thị trong Nhân sự nếu có ít nhất một CoSo
        // đã được duyệt (TrangThai khác "Chờ duyệt"/"Từ chối"); các role khác giữ nguyên.
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM TaiKhoan a WHERE (a.isDeleted = false OR a.isDeleted IS NULL) " +
                    "AND (a.roleId <> 2 OR EXISTS (" +
                    "  SELECT c FROM CoSo c WHERE c.AccountID_QuanLy = a.accountId " +
                    "  AND c.TrangThai NOT IN ('Chờ duyệt', 'Từ chối') " +
                    "  AND (c.isDeleted = false OR c.isDeleted IS NULL)" +
                    "))", TaiKhoan.class)
                .getResultList();
        } catch (Exception e) {
            logger.error("Lỗi lấy danh sách tài khoản Nhân sự: {}", e.getMessage(), e);
            return null;
        } finally {
            em.close();
        }
    }
```

- [ ] **Step 3: Dùng method mới trong trang Nhân sự**

Trong `src/main/java/org/example/controller/admin/QuanLyNguoiDungServlet.java:63`, đổi:

```java
        List<TaiKhoan> accounts = TaiKhoanDAO.getAllAccounts();
```

thành:

```java
        List<TaiKhoan> accounts = TaiKhoanDAO.getStaffDirectoryAccounts();
```

Không đổi dòng 64 (`getDeletedAccounts()`) và dòng 65 (`coSoDAO.getAllCoSo()` đã được lọc bởi Task 1, phù hợp vì dropdown chọn cơ sở trong trang Nhân sự chỉ nên hiện cơ sở đã hoạt động).

- [ ] **Step 4: Biên dịch**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`.

---

### Task 3: Tạo OwnerApprovalService (transaction duy nhất cho duyệt/từ chối)

**Files:**
- Create: `src/main/java/org/example/service/admin/OwnerApprovalService.java`

**Interfaces:**
- Consumes: `CoSo` (model), `TaiKhoan` (model), `JPAUtil.getEntityManager()`.
- Produces: `OwnerApprovalService.ApprovalResult approve(int coSoId, int adminId)` và `OwnerApprovalService.ApprovalResult reject(int coSoId)` — dùng ở Task 4, Task 5. `ApprovalResult` có field public `boolean success`, `String errorMessage`, `CoSo coSo`, `TaiKhoan account`.

- [ ] **Step 1: Viết service**

Tạo file `src/main/java/org/example/service/admin/OwnerApprovalService.java`:

```java
package org.example.service.admin;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.util.JPAUtil;

import java.time.LocalDateTime;

/**
 * Lõi nghiệp vụ duyệt/từ chối yêu cầu đăng ký Owner, chạy trong một
 * EntityTransaction duy nhất để đảm bảo CoSo và Account luôn đồng bộ:
 * không có tình trạng Account đã mở khóa nhưng CoSo vẫn "Chờ duyệt",
 * hoặc CoSo "Đang hoạt động" nhưng Account vẫn bị khóa.
 * Dùng chung cho cả AdminOwnerServlet và QuanLyChiNhanhServlet để
 * tránh hai luồng duyệt/từ chối lệch nhau.
 */
public class OwnerApprovalService {

    private static final Logger logger = LogManager.getLogger(OwnerApprovalService.class);

    public static class ApprovalResult {
        public final boolean success;
        public final String errorMessage;
        public final CoSo coSo;
        public final TaiKhoan account;

        private ApprovalResult(boolean success, String errorMessage, CoSo coSo, TaiKhoan account) {
            this.success = success;
            this.errorMessage = errorMessage;
            this.coSo = coSo;
            this.account = account;
        }

        static ApprovalResult ok(CoSo coSo, TaiKhoan account) {
            return new ApprovalResult(true, null, coSo, account);
        }

        static ApprovalResult fail(String message) {
            return new ApprovalResult(false, message, null, null);
        }
    }

    /**
     * Duyệt yêu cầu: CoSo chuyển "Đang hoạt động", mở khóa Account liên kết,
     * đồng thời archive (soft-delete) các CoSo "Từ chối" cũ khác của cùng
     * account để tránh trùng lặp lịch sử đăng ký.
     */
    public ApprovalResult approve(int coSoId, int adminId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            CoSo coSo = em.find(CoSo.class, coSoId);
            if (coSo == null) {
                tx.rollback();
                return ApprovalResult.fail("Không tìm thấy cơ sở.");
            }
            if (!"Chờ duyệt".equals(coSo.getTrangThai())) {
                tx.rollback();
                return ApprovalResult.fail("Cơ sở này không ở trạng thái chờ duyệt.");
            }

            coSo.setTrangThai("Đang hoạt động");

            TaiKhoan account = null;
            if (coSo.getAccountID_QuanLy() != null) {
                account = em.find(TaiKhoan.class, coSo.getAccountID_QuanLy());
                if (account != null) {
                    account.setIsLocked(false);
                }
                em.createQuery(
                        "UPDATE CoSo c SET c.isDeleted = true, c.deletedAt = :now, c.deletedBy = :actor " +
                        "WHERE c.AccountID_QuanLy = :accId AND c.TrangThai = 'Từ chối' AND c.CoSoID <> :excludeId " +
                        "AND (c.isDeleted = false OR c.isDeleted IS NULL)")
                    .setParameter("now", LocalDateTime.now())
                    .setParameter("actor", adminId)
                    .setParameter("accId", coSo.getAccountID_QuanLy())
                    .setParameter("excludeId", coSoId)
                    .executeUpdate();
            }

            tx.commit();
            return ApprovalResult.ok(coSo, account);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi duyệt yêu cầu Owner coSoId={}: {}", coSoId, e.getMessage(), e);
            return ApprovalResult.fail("Lỗi hệ thống khi duyệt yêu cầu.");
        } finally {
            em.close();
        }
    }

    /**
     * Từ chối yêu cầu: CoSo chuyển "Từ chối", Account giữ nguyên trạng thái
     * khóa hiện tại (không tự mở, không tự khóa thêm).
     */
    public ApprovalResult reject(int coSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            CoSo coSo = em.find(CoSo.class, coSoId);
            if (coSo == null) {
                tx.rollback();
                return ApprovalResult.fail("Không tìm thấy cơ sở.");
            }
            if (!"Chờ duyệt".equals(coSo.getTrangThai())) {
                tx.rollback();
                return ApprovalResult.fail("Chỉ có thể từ chối cơ sở đang chờ duyệt.");
            }

            TaiKhoan account = coSo.getAccountID_QuanLy() != null
                    ? em.find(TaiKhoan.class, coSo.getAccountID_QuanLy())
                    : null;

            coSo.setTrangThai("Từ chối");

            tx.commit();
            return ApprovalResult.ok(coSo, account);
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            logger.error("Lỗi từ chối yêu cầu Owner coSoId={}: {}", coSoId, e.getMessage(), e);
            return ApprovalResult.fail("Lỗi hệ thống khi từ chối yêu cầu.");
        } finally {
            em.close();
        }
    }
}
```

- [ ] **Step 2: Biên dịch**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`.

---

### Task 4: Refactor AdminOwnerServlet dùng OwnerApprovalService, bỏ action "thu-hoi" độc lập

**Files:**
- Modify: `src/main/java/org/example/controller/admin/AdminOwnerServlet.java`

**Interfaces:**
- Consumes: `OwnerApprovalService.approve/reject` (Task 3).
- Produces: `loadPageData()` không còn set attribute `rejected` (dùng ở Task 7 để xóa tab tương ứng trong JSP).

- [ ] **Step 1: Thêm import và field service**

Thêm import sau dòng 18 (`import org.example.util.EmailUtil;`):

```java
import org.example.service.admin.OwnerApprovalService;
```

Thêm field sau dòng 32 (`private final AdminTrashDAO adminTrashDAO = new AdminTrashDAOImpl();`):

```java
    private final OwnerApprovalService ownerApprovalService = new OwnerApprovalService();
```

- [ ] **Step 2: Thay case "duyet" và "tu-choi", xóa case "thu-hoi"**

Thay toàn bộ khối từ dòng 67 (`switch (action) {`) đến hết case `"tu-choi"` (dòng 100, trước `case "thu-hoi":`) bằng:

```java
        switch (action) {
            case "duyet": {
                OwnerApprovalService.ApprovalResult result = ownerApprovalService.approve(coSoId, admin.getAccountId());
                if (result.success) {
                    syncCourts(coSoId, result.coSo.getLoaiHinhKinhDoanh(), result.coSo.getSoLuongSanDuKien());
                    if (result.account != null) {
                        sendApprovalEmail(result.account);
                    }
                    req.getSession().setAttribute("message",
                            "Đã duyệt cơ sở \"" + result.coSo.getTenCoSo() + "\" và kích hoạt tài khoản quản lý.");
                } else {
                    req.getSession().setAttribute("error", result.errorMessage);
                }
                break;
            }

            case "tu-choi": {
                String coSoName = coSo.getTenCoSo();
                OwnerApprovalService.ApprovalResult result = ownerApprovalService.reject(coSoId);
                if (result.success) {
                    adminTrashDAO.log("OwnerRequest", coSoId, coSoName, "CoSo", "Chờ duyệt",
                            admin.getAccountId(), null);
                    if (result.account != null) {
                        sendRejectionEmail(result.account, coSoName);
                    }
                    req.getSession().setAttribute("message", "Đã từ chối yêu cầu đăng ký cơ sở \"" + coSoName + "\".");
                    req.getSession().setAttribute("trashMessage", "Đã chuyển vào thùng rác.");
                    req.getSession().setAttribute("trashUrl", req.getContextPath() + "/admin/thung-rac");
                    req.getSession().setAttribute("trashCountdownSeconds", 10);
                } else {
                    req.getSession().setAttribute("error", result.errorMessage);
                }
                break;
            }
```

Giữ nguyên các `case "khoa":`, `case "mo-khoa":`, `default:` phía sau (dòng 112-136 hiện tại) — chỉ xóa hẳn khối `case "thu-hoi":` (dòng 102-110 hiện tại), vì việc "thu hồi từ chối" từ nay CHỈ thực hiện qua `/admin/thung-rac` (xem Task 6), không còn thao tác trực tiếp trên trang Quản lý Owner.

- [ ] **Step 3: Sửa helper `unlockAndNotify` thành `sendApprovalEmail` (chỉ gửi email, không update DB)**

Thay toàn bộ method `unlockAndNotify` (dòng 180-201) bằng:

```java
    private void sendApprovalEmail(TaiKhoan account) {
        final String email = account.getEmail();
        final String name = account.getFullName();
        new Thread(() -> {
            try {
                EmailUtil.sendEmail(email,
                    "Tài khoản đối tác V-SPORT đã được phê duyệt",
                    "Chào " + name + ",\n\n" +
                    "Cơ sở thể thao của bạn đã được quản trị viên phê duyệt thành công.\n" +
                    "Bạn có thể đăng nhập tại: http://localhost:8080/Backend_java\n" +
                    "  - Email: " + email + "\n" +
                    "  - Mật khẩu mặc định: 123456\n\n" +
                    "Vui lòng đổi mật khẩu sau khi đăng nhập lần đầu.\n\nTrân trọng,\nBan quản trị V-SPORT");
            } catch (Exception e) {
                logger.error("Lỗi gửi email phê duyệt tới {}", email, e);
            }
        }).start();
    }
```

- [ ] **Step 4: Sửa helper `notifyRejection` thành `sendRejectionEmail` (nhận sẵn TaiKhoan, không fetch lại)**

Thay method `notifyRejection` (dòng 253-270) bằng:

```java
    private void sendRejectionEmail(TaiKhoan account, String coSoName) {
        final String email = account.getEmail();
        final String name = account.getFullName();
        new Thread(() -> {
            try {
                EmailUtil.sendEmail(email,
                    "Yêu cầu đăng ký đối tác V-SPORT đã bị từ chối",
                    "Chào " + name + ",\n\n" +
                    "Chúng tôi rất tiếc phải thông báo rằng yêu cầu đăng ký cơ sở \"" + coSoName + "\" của bạn đã bị từ chối bởi ban quản trị.\n" +
                    "Bạn vẫn có thể đăng ký lại cơ sở mới với email này khi sẵn sàng.\n\n" +
                    "Trân trọng,\nBan quản trị V-SPORT");
            } catch (Exception e) {
                logger.error("Lỗi gửi email từ chối tới {}", email, e);
            }
        }).start();
    }
```

- [ ] **Step 5: Bỏ danh sách "rejected" khỏi trang Quản lý Owner chính**

Trong `loadPageData()`, thay:

```java
        List<Map<String, Object>> pending  = new ArrayList<>();
        List<Map<String, Object>> approved = new ArrayList<>();
        List<Map<String, Object>> rejected = new ArrayList<>();
```

bằng:

```java
        List<Map<String, Object>> pending  = new ArrayList<>();
        List<Map<String, Object>> approved = new ArrayList<>();
```

Và thay:

```java
            switch (cs.getTrangThai()) {
                case "Chờ duyệt": pending.add(row); break;
                case "Đang hoạt động": approved.add(row); break;
                case "Từ chối": rejected.add(row); break;
            }
        }

        req.setAttribute("pending",  pending);
        req.setAttribute("approved", approved);
        req.setAttribute("rejected", rejected);
```

bằng:

```java
            switch (cs.getTrangThai()) {
                case "Chờ duyệt": pending.add(row); break;
                case "Đang hoạt động": approved.add(row); break;
                // "Từ chối" không hiển thị ở trang Quản lý Owner nữa —
                // chỉ xuất hiện tại /admin/thung-rac (xem AdminTrashServlet).
                default: break;
            }
        }

        req.setAttribute("pending",  pending);
        req.setAttribute("approved", approved);
```

- [ ] **Step 6: Biên dịch**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`. Nếu lỗi "cannot find symbol: rejected" ở JSP forward — bỏ qua ở bước này (JSP sửa ở Task 7, JSP không được `mvn compile` kiểm tra).

---

### Task 5: Hợp nhất luồng duyệt/từ chối trùng lặp trong QuanLyChiNhanhServlet

**Bối cảnh:** `QuanLyChiNhanhServlet.java:48-104` có action `duyet`/`khong-duyet` riêng, độc lập với `AdminOwnerServlet`, có thể gọi từ `/admin/chi-nhanh?action=duyet&id=X` hoặc từ nút trên `NhanSu.jsp` (`from=nhan-su`). Bản này **không ghi AdminTrash khi từ chối** — vi phạm yêu cầu "từ chối phải vào thùng rác". Task này hợp nhất cả hai action để dùng chung `OwnerApprovalService`.

**Files:**
- Modify: `src/main/java/org/example/controller/admin/QuanLyChiNhanhServlet.java`

**Interfaces:**
- Consumes: `OwnerApprovalService.approve/reject` (Task 3), `AdminTrashDAO.log` (đã có field `adminTrashDAO` dòng 40).

- [ ] **Step 1: Thêm import và field service**

Thêm import sau dòng 19 (`import org.example.util.EmailUtil;`):

```java
import org.example.service.admin.OwnerApprovalService;
```

Thêm field sau dòng 40 (`private final AdminTrashDAO adminTrashDAO = new AdminTrashDAOImpl();`):

```java
    private final OwnerApprovalService ownerApprovalService = new OwnerApprovalService();
```

- [ ] **Step 2: Thay khối `if ("duyet".equals(action))`**

Thay toàn bộ khối (dòng 48-86 hiện tại, từ `if ("duyet".equals(action)) {` đến trước `} else if ("khong-duyet".equals(action)) {`) bằng:

```java
            if ("duyet".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                TaiKhoan admin = (TaiKhoan) req.getSession().getAttribute("user");
                OwnerApprovalService.ApprovalResult result = ownerApprovalService.approve(id, admin.getAccountId());
                if (result.success) {
                    Map<String, Integer> sportCounts = buildSportCounts(
                            result.coSo.getLoaiHinhKinhDoanh(), result.coSo.getSoLuongSanDuKien());
                    syncCourtsForBranch(id, sportCounts);
                    if (result.account != null) {
                        sendApprovalEmail(result.account);
                    }
                    req.getSession().setAttribute("message", "Duyệt cơ sở thành công và tài khoản quản lý đã được kích hoạt!");
                } else {
                    req.getSession().setAttribute("error", result.errorMessage);
                }
                String from = req.getParameter("from");
                if ("nhan-su".equals(from)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/chi-nhanh");
                }
                return;
            } else if ("khong-duyet".equals(action)) {
```

- [ ] **Step 3: Thay khối `else if ("khong-duyet".equals(action))`**

Thay nội dung bên trong (dòng 88-103 hiện tại) bằng:

```java
                int id = Integer.parseInt(req.getParameter("id"));
                TaiKhoan admin = (TaiKhoan) req.getSession().getAttribute("user");
                CoSo chiNhanhBeforeReject = chiNhanhDAO.getCoSoById(id);
                String coSoName = chiNhanhBeforeReject != null ? chiNhanhBeforeReject.getTenCoSo() : null;
                OwnerApprovalService.ApprovalResult result = ownerApprovalService.reject(id);
                if (result.success) {
                    adminTrashDAO.log("OwnerRequest", id, coSoName, "CoSo", "Chờ duyệt",
                            admin.getAccountId(), null);
                    req.getSession().setAttribute("message", "Đã từ chối duyệt cơ sở.");
                    req.getSession().setAttribute("trashMessage", "Đã chuyển vào thùng rác.");
                    req.getSession().setAttribute("trashUrl", req.getContextPath() + "/admin/thung-rac");
                    req.getSession().setAttribute("trashCountdownSeconds", 10);
                } else {
                    req.getSession().setAttribute("error", result.errorMessage);
                }
                String from = req.getParameter("from");
                if ("nhan-su".equals(from)) {
                    resp.sendRedirect(req.getContextPath() + "/admin/nhan-su");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/chi-nhanh");
                }
                return;
            }
```

- [ ] **Step 4: Thêm helper `buildSportCounts` và `sendApprovalEmail`, xóa `unlockManagerAccount` cũ**

Xóa toàn bộ method `unlockManagerAccount` (dòng 418-445 hiện tại — không còn được gọi vì `OwnerApprovalService.approve` đã tự mở khóa account trong transaction).

Thêm hai helper mới ở cuối class (trước dấu `}` đóng class):

```java
    private Map<String, Integer> buildSportCounts(String loaiHinh, int total) {
        Map<String, Integer> sportCounts = new HashMap<>();
        if (loaiHinh != null && !loaiHinh.trim().isEmpty() && total > 0) {
            String[] sports = loaiHinh.split(",");
            for (int i = 0; i < sports.length; i++) {
                sports[i] = sports[i].trim();
            }
            int base = total / sports.length;
            int remainder = total % sports.length;
            for (int i = 0; i < sports.length; i++) {
                sportCounts.put(sports[i], base + (i < remainder ? 1 : 0));
            }
        }
        return sportCounts;
    }

    private void sendApprovalEmail(TaiKhoan account) {
        new Thread(() -> {
            try {
                EmailUtil.sendEmail(
                    account.getEmail(),
                    "Tài khoản đối tác V-SPORT đã được phê duyệt",
                    "Chào " + account.getFullName() + ",\n\n" +
                    "Cơ sở thể thao của bạn đã được quản trị viên phê duyệt thành công.\n" +
                    "Bạn hiện có thể đăng nhập vào hệ thống quản lý V-SPORT bằng tài khoản sau:\n" +
                    "- Tên đăng nhập (Email): " + account.getEmail() + "\n" +
                    "- Mật khẩu mặc định: 123456\n\n" +
                    "Vui lòng đổi mật khẩu sau khi đăng nhập lần đầu tiên để bảo mật tài khoản.\n\n" +
                    "Trân trọng,\nBan quản trị V-SPORT"
                );
            } catch (Exception e) {
                logger.error("Lỗi gửi email phê duyệt đến {}", account.getEmail(), e);
            }
        }).start();
    }
```

- [ ] **Step 5: Biên dịch**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`. Nếu compiler báo `TaiKhoanDAO`/`TaiKhoanDAOImpl` import không dùng nữa (vì `unlockManagerAccount` bị xóa) — xóa luôn import `org.example.dao.TaiKhoanDAO` và `org.example.dao.impl.TaiKhoanDAOImpl` ở đầu file nếu không còn chỗ nào khác dùng.

---

### Task 6: Thêm guard chống trùng lặp khi thu hồi OwnerRequest từ thùng rác

**Files:**
- Modify: `src/main/java/org/example/controller/admin/AdminTrashServlet.java:126-131` (case `"OwnerRequest"` trong `restoreSource`)

**Interfaces:**
- Consumes: `coSoDAO.getCoSoById`, cần thêm truy vấn kiểm tra CoSo khác cùng account đang active/pending.

- [ ] **Step 1: Thêm method kiểm tra trùng lặp vào CoSoDAO**

Trong `src/main/java/org/example/dao/CoSoDAO.java`, thêm khai báo:

```java
    /**
     * Kiểm tra account đã có cơ sở khác đang "Chờ duyệt" hoặc "Đang hoạt động"
     * hay chưa (dùng khi thu hồi một OwnerRequest bị từ chối từ thùng rác,
     * tránh tạo ra hai yêu cầu/​cơ sở cùng hoạt động cho một account).
     */
    boolean hasActiveOrPendingCoSo(int accountId, int excludeCoSoId);
```

Trong `src/main/java/org/example/dao/impl/CoSoDAOImpl.java`, thêm implementation sau `archiveRejectedForAccount` (sau dòng 374):

```java
    @Override
    public boolean hasActiveOrPendingCoSo(int accountId, int excludeCoSoId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long count = em.createQuery(
                    "SELECT COUNT(c) FROM CoSo c WHERE c.AccountID_QuanLy = :accId AND c.CoSoID <> :excludeId " +
                    "AND (c.isDeleted = false OR c.isDeleted IS NULL) " +
                    "AND c.TrangThai IN ('Chờ duyệt', 'Đang hoạt động')", Long.class)
                .setParameter("accId", accountId)
                .setParameter("excludeId", excludeCoSoId)
                .getSingleResult();
            return count != null && count > 0;
        } finally {
            em.close();
        }
    }
```

- [ ] **Step 2: Dùng guard này trong `AdminTrashServlet.restoreSource`**

Trong `src/main/java/org/example/controller/admin/AdminTrashServlet.java`, thay case `"OwnerRequest"` (dòng 126-131) bằng:

```java
                case "OwnerRequest": {
                    CoSo coSo = coSoDAO.getCoSoById(item.getEntityId());
                    if (coSo == null) return false;
                    if (coSo.getAccountID_QuanLy() != null &&
                            coSoDAO.hasActiveOrPendingCoSo(coSo.getAccountID_QuanLy(), coSo.getCoSoID())) {
                        logger.warn("Không thể thu hồi OwnerRequest CoSoID={}: account đã có cơ sở khác đang hoạt động/chờ duyệt", coSo.getCoSoID());
                        return false;
                    }
                    coSo.setTrangThai(item.getOldStatus() != null ? item.getOldStatus() : "Chờ duyệt");
                    return coSoDAO.updateCoSo(coSo);
                }
```

- [ ] **Step 3: Biên dịch**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`.

---

### Task 7: Bỏ tab "Từ chối" khỏi trang Quản lý Owner

**Bối cảnh:** Sau Task 4, `rejected` không còn là attribute JSP nữa; và theo yêu cầu, request bị từ chối chỉ hiển thị ở `/admin/thung-rac`, không còn tab riêng với nút "Thu hồi" tại chỗ (nút đó gọi action `thu-hoi` đã bị xóa ở Task 4).

**Files:**
- Modify: `src/main/webapp/admin/QuanLyOwner.jsp`

**Interfaces:**
- Consumes: không còn dùng biến JSTL `rejected`.

- [ ] **Step 1: Xóa stat card "Từ chối"**

Xóa khối (dòng 135-143 hiện tại):

```html
    <div class="bg-white border border-zinc-200/80 rounded-2xl p-4 flex items-center gap-4 hover:shadow-sm transition-all">
      <div class="w-12 h-12 rounded-xl bg-red-50 text-red-500 border border-red-100 flex items-center justify-center shrink-0">
        <i class="ti ti-circle-x text-2xl"></i>
      </div>
      <div>
        <p class="text-2xl font-black text-zinc-900">${rejected.size()}</p>
        <p class="text-xs text-zinc-400 font-semibold tracking-wide uppercase">Từ chối</p>
      </div>
    </div>
```

- [ ] **Step 2: Xóa nút tab "Từ chối", thêm link sang thùng rác**

Xóa khối nút (dòng 162-168 hiện tại):

```html
    <button class="tab-pill" id="tabRejected" onclick="switchTab('rejected', this)">
      <i class="ti ti-circle-x text-sm"></i>
      Từ chối
      <c:if test="${rejected.size() > 0}">
        <span class="ml-1 bg-red-100 text-red-600 rounded-md px-2 py-0.5 text-[10px] font-bold">${rejected.size()}</span>
      </c:if>
    </button>
```

Thay bằng một link tĩnh (không phải tab) trỏ sang thùng rác chung, đặt ngay sau nút "Đang hoạt động":

```html
    <a href="${pageContext.request.contextPath}/admin/thung-rac?loai=OwnerRequest"
       class="ml-auto flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold text-zinc-500 hover:text-zinc-700 hover:bg-zinc-100 transition-all">
      <i class="ti ti-trash text-sm"></i>Yêu cầu đã từ chối (thùng rác)
    </a>
```

- [ ] **Step 3: Xóa toàn bộ khối nội dung tab "Từ chối"**

Xóa toàn bộ khối từ comment `<!-- ══ TAB: Từ chối ══ -->` đến `</div>` đóng tương ứng (dòng 350-421 hiện tại, ngay trước `</main>`):

```html
  <!-- ══ TAB: Từ chối ══ -->
  <div id="tab-rejected" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5 hidden">
    ... (toàn bộ nội dung) ...
  </div>
```

- [ ] **Step 4: Sửa mảng tab trong JavaScript**

Tìm dòng (khoảng dòng 438 sau khi xóa các khối trên, số dòng sẽ dịch lên — tìm theo nội dung):

```javascript
    ['pending','approved','rejected'].forEach(function(t) {
```

Thay bằng:

```javascript
    ['pending','approved'].forEach(function(t) {
```

- [ ] **Step 5: Kiểm tra thủ công**

Mở `/admin/quan-ly-owner` trên trình duyệt (sau khi build & deploy ở Task 10), xác nhận: chỉ còn 2 tab "Chờ duyệt" / "Đang hoạt động", có link "Yêu cầu đã từ chối (thùng rác)" trỏ đúng `/admin/thung-rac?loai=OwnerRequest`, không còn lỗi JS console do thiếu phần tử `tab-rejected`.

---

### Task 8: Đồng bộ giao diện ThungRacAdmin.jsp theo phong cách Manager Trash

**Bối cảnh:** `ThungRacAdmin.jsp` hiện đã đúng cấu trúc nghiệp vụ (chỉ có nút "Thu hồi", không có "Xóa vĩnh viễn", đã filter theo entityType/restored/scope) — chỉ cần chỉnh phong cách (card padding, badge, tên cột, mô tả, modal xác nhận) để gần với card/table/badge/empty-state của Manager Trash mà KHÔNG copy tab-theo-loại hay theme tím của Manager (Admin giữ 1 bảng phẳng vì dữ liệu đa loại — đúng yêu cầu cột đề xuất trong spec).

**Files:**
- Modify: `src/main/webapp/admin/ThungRacAdmin.jsp`

**Interfaces:**
- Consumes: `AdminTrash` field: `entityType`, `displayName`, `sourceTable`, `oldStatus`, `deletedByName`, `deletedAt`, `restored`, `trashId` (không đổi, JSP chỉ đổi trình bày).

- [ ] **Step 1: Cập nhật tiêu đề/mô tả đúng nguyên văn spec**

Thay dòng 34-35:

```html
      <h1 class="text-lg font-bold text-slate-900">Thùng rác Admin</h1>
      <p class="text-sm text-slate-500 mt-1">Các dữ liệu bạn đã xóa sẽ được lưu tại đây để có thể thu hồi.</p>
```

bằng:

```html
      <h1 class="text-lg font-bold text-slate-900">Thùng rác Admin</h1>
      <p class="text-sm text-slate-500 mt-1">Các dữ liệu đã xóa được lưu tại đây để có thể thu hồi.</p>
```

- [ ] **Step 2: Đổi nhãn cột đúng theo spec, nâng cấp style card giống Manager (bo góc lớn hơn, đậm hơn)**

Thay khối `<div class="adm-card overflow-x-auto">` … `<thead>` (dòng 57-69) bằng:

```html
    <div class="bg-white border border-slate-200/80 rounded-2xl overflow-x-auto shadow-xs">
      <table class="w-full text-sm">
        <thead>
          <tr class="text-left text-[11px] uppercase tracking-wide text-slate-400 border-b border-slate-100">
            <th class="px-4 py-3">Loại dữ liệu</th>
            <th class="px-4 py-3">Tên dữ liệu</th>
            <th class="px-4 py-3">Nguồn</th>
            <th class="px-4 py-3">Trạng thái trước khi xóa</th>
            <th class="px-4 py-3">Người thao tác</th>
            <th class="px-4 py-3">Ngày xóa</th>
            <th class="px-4 py-3">Trạng thái thu hồi</th>
            <th class="px-4 py-3 text-right">Hành động</th>
          </tr>
        </thead>
```

- [ ] **Step 3: Empty state đồng bộ icon với Manager Trash**

Thay dòng 107-109:

```html
          <c:if test="${empty items}">
            <tr><td colspan="8" class="px-4 py-10 text-center text-slate-400 text-sm">Thùng rác trống.</td></tr>
          </c:if>
```

bằng:

```html
          <c:if test="${empty items}">
            <tr>
              <td colspan="8" class="py-16 text-center text-slate-400">
                <i class="ti ti-trash-off text-4xl block mb-2 opacity-40"></i>
                <span class="text-sm font-medium">Thùng rác trống.</span>
              </td>
            </tr>
          </c:if>
```

- [ ] **Step 4: Thay `confirm()` gốc bằng modal xác nhận Thu hồi có style riêng (không copy modal của Manager)**

Thay khối nút "Thu hồi" (dòng 92-104):

```html
              <td class="px-4 py-3 text-right">
                <c:if test="${!it.restored}">
                  <form method="post" action="${pageContext.request.contextPath}/admin/thung-rac"
                        onsubmit="return confirm('Bạn có chắc muốn thu hồi mục này?');">
                    <input type="hidden" name="action" value="restore"/>
                    <input type="hidden" name="id" value="${it.trashId}"/>
                    <button type="submit"
                            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-600 text-white text-xs font-semibold hover:bg-blue-700">
                      <i class="ti ti-arrow-back-up"></i> Thu hồi
                    </button>
                  </form>
                </c:if>
              </td>
```

bằng:

```html
              <td class="px-4 py-3 text-right">
                <c:if test="${!it.restored}">
                  <button type="button"
                          onclick="openRestoreModal(${it.trashId}, '${fn:escapeXml(it.displayName)}')"
                          class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-blue-600 text-white text-xs font-semibold hover:bg-blue-700">
                    <i class="ti ti-arrow-back-up"></i> Thu hồi
                  </button>
                </c:if>
              </td>
```

Thêm taglib `fn` ở đầu file, ngay dưới dòng 2 (`<%@ taglib prefix="c" ... %>`):

```jsp
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
```

- [ ] **Step 5: Thêm modal + form ẩn + script, trước `</body>`**

Thay dòng 113-114 (`  </main>\n</div>`) bằng:

```html
  </main>
</div>

<!-- Modal xác nhận Thu hồi -->
<div id="restoreModal" class="hidden fixed inset-0 z-[90] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closeRestoreModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-xl w-full max-w-sm p-6">
    <h3 class="text-base font-bold text-slate-900 mb-1">Thu hồi mục này?</h3>
    <p class="text-sm text-slate-500 mb-5" id="restoreModalText"></p>
    <div class="flex justify-end gap-2">
      <button type="button" onclick="closeRestoreModal()"
              class="h-10 px-4 rounded-xl border border-slate-200 text-sm font-bold text-slate-600 hover:bg-slate-50">Hủy</button>
      <button type="button" onclick="submitRestore()"
              class="h-10 px-4 rounded-xl bg-blue-600 text-white text-sm font-bold hover:bg-blue-700">Thu hồi</button>
    </div>
  </div>
</div>

<form id="restoreForm" method="post" action="${pageContext.request.contextPath}/admin/thung-rac" class="hidden">
  <input type="hidden" name="action" value="restore"/>
  <input type="hidden" name="id" id="restoreTrashId"/>
</form>

<script>
  function openRestoreModal(trashId, displayName) {
    document.getElementById('restoreTrashId').value = trashId;
    document.getElementById('restoreModalText').textContent = 'Đưa "' + displayName + '" trở lại trạng thái trước khi xóa.';
    document.getElementById('restoreModal').classList.remove('hidden');
  }
  function closeRestoreModal() {
    document.getElementById('restoreModal').classList.add('hidden');
  }
  function submitRestore() {
    document.getElementById('restoreForm').submit();
  }
</script>
```

- [ ] **Step 6: Kiểm tra thủ công**

Sau khi deploy (Task 10), mở `/admin/thung-rac`, bấm "Thu hồi" trên một dòng chưa thu hồi → modal hiện ra đúng tên dữ liệu → bấm "Thu hồi" trong modal → dữ liệu được restore, không còn nút "Xóa vĩnh viễn"/"Dọn sạch" nào trên trang.

---

### Task 9: Xóa tab/section thùng rác riêng trong NhanSu.jsp

**Bối cảnh:** `NhanSu.jsp` có tab "Thùng rác" + `#sectionThungRac` + `#trashGrid` render client-side, chỉ có nút "Khôi phục" (không có Xóa vĩnh viễn). Backend `QuanLyNguoiDungServlet` khi soft-delete ĐÃ ghi vào `AdminTrash` và set session toast trỏ `/admin/thung-rac` (dòng 363-386, không cần sửa). Task này chỉ xóa phần UI nhúng, giữ nguyên toàn bộ backend.

**Files:**
- Modify: `src/main/webapp/admin/NhanSu.jsp`

**Interfaces:**
- Không đổi backend/servlet.

- [ ] **Step 1: Xóa tab button "Thùng rác"**

Tìm và xóa khối chứa (khoảng dòng 55-58 hiện tại):

```html
      <button id="tabThungRac" onclick="switchTab('thungrac')" class="flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-medium text-zinc-500 hover:text-zinc-700 transition-all">
        ...
        <span id="trashCountBadge" class="hidden text-xs bg-red-100 text-red-600 px-1.5 py-0.5 rounded font-bold">0</span>
      </button>
```

Thay bằng một link tĩnh trỏ sang thùng rác chung, giữ cùng style với các nút tab khác nhưng không phải là tab (không toggle nội dung tại chỗ):

```html
      <a href="${pageContext.request.contextPath}/admin/thung-rac?loai=Account"
         class="ml-auto flex items-center gap-1.5 px-4 py-1.5 rounded-lg text-sm font-medium text-zinc-500 hover:text-zinc-700 transition-all">
        <i class="ti ti-trash text-sm"></i>Thùng rác
      </a>
```

(Đọc trước 10 dòng quanh dòng 51-58 trong file thật để xác nhận đúng ngữ cảnh nút "Nhân sự" liền trước, vì icon/markup chính xác của nút gốc chưa được trích ở khảo sát — dùng cùng cấu trúc class với nút "Nhân sự" hiện có, chỉ đổi icon/label/href.)

- [ ] **Step 2: Xóa toàn bộ section `#sectionThungRac`**

Xóa khối (khoảng dòng 96-106 hiện tại):

```html
  <div id="sectionThungRac" class="hidden w-full flex flex-col gap-4">
    ...
    <div id="trashGrid" class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4"></div>
    ...
  </div>
```

- [ ] **Step 3: Xóa JS liên quan — `renderTrash`, nhánh "thungrac" trong `switchTab`, `trashCountBadge`**

Xóa toàn bộ hàm `renderTrash()` (khoảng dòng 545-620 hiện tại, đến hết `}` đóng hàm bao gồm cả `renderPaginationControls('sectionThungRac', 'trashPagination', ...)`).

Trong hàm `switchTab(tab)` (khoảng dòng 622-639), xóa nhánh xử lý `trashSection`/`tabThungRac` (dòng 624, 626, 634, 639) — giữ lại logic chuyển tab "Nhân sự" duy nhất còn lại (nếu sau khi xóa `switchTab` không còn ý nghĩa vì chỉ còn 1 tab, có thể xóa lời gọi `switchTab` không dùng nữa — nhưng KHÔNG xóa nếu file còn dùng cho các tab khác ngoài Nhân sự/Thùng rác; đọc toàn bộ hàm trước khi xóa để tránh xóa nhầm tab khác).

Xóa các lời gọi `renderTrash()` còn sót lại (dòng 958, 971, 1033 hiện tại — đây là trong các callback sau khi xóa/khôi phục tài khoản, các dòng này gọi `renderTrash()` để refresh lưới thùng rác tại chỗ; xóa lời gọi đó, KHÔNG xóa phần logic soft-delete/toast xung quanh).

Cũng xóa dòng cập nhật badge (dòng 959: `const badge = document.getElementById('trashCountBadge');` và các dòng set text/hiện badge liền kề).

- [ ] **Step 4: Kiểm tra thủ công**

Sau deploy (Task 10): mở `/admin/nhan-su`, xác nhận không còn tab/khu vực "Thùng rác" tại chỗ; xóa (soft-delete) một tài khoản nhân viên → toast "Đã chuyển vào thùng rác." với nút "Đi tới thùng rác" hiện ra (từ `admin_toast.jsp`, không đổi) → bấm vào → tới đúng `/admin/thung-rac`, tài khoản vừa xóa xuất hiện ở đó với nút "Thu hồi".

---

### Task 10: Build tổng thể và kiểm thử thủ công theo toàn bộ spec

**Files:** không sửa file, chỉ verify.

- [ ] **Step 1: Build**

Run: `mvn -q -f /home/nhan/Downloads/V-SPORT/pom.xml clean compile`
Expected: `BUILD SUCCESS`, không có lỗi ở bất kỳ file nào sửa trong Task 1-9.

- [ ] **Step 2: Deploy & kiểm thử HTTP** (cần Tomcat + SQL Server thật của người thực thi — không chạy được trong sandbox này)

Deploy WAR lên Tomcat theo cách hiện có của dự án, sau đó kiểm tra:

```
GET /Backend_java/admin/thung-rac        → 200, không 404/500
GET /Backend_java/admin/quan-ly-owner    → 200, chỉ 2 tab Chờ duyệt/Đang hoạt động
GET /Backend_java/admin/chi-nhanh        → 200, không có cơ sở "Chờ duyệt"/"Từ chối"
GET /Backend_java/admin/nhan-su          → 200, không có Owner chưa duyệt/bị từ chối
```

- [ ] **Step 3: Test case Owner Request theo spec Bước 16**

Chạy SQL kiểm tra trước và sau mỗi case:

```sql
SELECT c.CoSoID, c.TenCoSo, c.TrangThai, c.IsDeleted, c.AccountID_QuanLy,
       a.Email, a.IsLocked, a.RoleID
FROM CoSo c LEFT JOIN Accounts a ON a.AccountID = c.AccountID_QuanLy
ORDER BY c.CoSoID DESC;
```

CASE 1 (đăng ký mới): CoSo `Chờ duyệt`, Account `IsLocked=1`, chỉ hiện ở Quản lý Owner (tab Chờ duyệt), KHÔNG hiện ở `/admin/chi-nhanh`, KHÔNG hiện ở `/admin/nhan-su`.

CASE 2 (duyệt qua `/admin/quan-ly-owner?action=duyet&id=X`): CoSo → `Đang hoạt động`, Account → `IsLocked=0`, xuất hiện ở `/admin/chi-nhanh` và `/admin/nhan-su`.

CASE 2b (duyệt qua `/admin/chi-nhanh?action=duyet&id=X`): kết quả giống hệt CASE 2 (xác nhận hai entry-point đã hợp nhất — Task 5).

CASE 3 (từ chối, cả hai entry-point `/admin/quan-ly-owner?action=tu-choi` và `/admin/chi-nhanh?action=khong-duyet`): CoSo → `Từ chối`, KHÔNG hard delete, biến khỏi Quản lý Owner, có dòng mới trong `AdminTrash` với `EntityType='OwnerRequest'`, hiện ở `/admin/thung-rac`.

CASE 4 (thu hồi từ `/admin/thung-rac`): CoSo → `Chờ duyệt`, quay lại tab Chờ duyệt của Quản lý Owner, Account vẫn `IsLocked=1`, KHÔNG hiện ở Cơ sở/Nhân sự.

CASE 5 (thu hồi rồi duyệt): duyệt thành công bình thường, chỉ sau đó mới hiện ở Cơ sở/Nhân sự.

CASE 6 (guard trùng lặp — Task 6): tạo 2 request cùng account (đăng ký lại sau khi bị từ chối), từ chối request đầu (vào trash), duyệt request thứ hai (account có CoSo `Đang hoạt động`) → thử thu hồi request đầu từ thùng rác → phải bị từ chối với thông báo lỗi (không tạo ra 2 CoSo active/pending cho cùng 1 account).

- [ ] **Step 4: Test thùng rác chung theo spec Bước 17**

- Rà toàn bộ trang Admin: không còn tab/section/nút thùng rác riêng nào ngoài `/admin/thung-rac` (đặc biệt NhanSu.jsp sau Task 9).
- Sidebar Admin chỉ có 1 mục "Thùng rác" (đã xác nhận sẵn có, không đổi).
- Không có nút "Xóa vĩnh viễn" ở bất kỳ trang Admin nào (đã xác nhận Admin chưa từng có — chỉ Manager có, không đụng tới).
- Mở `/manager/thung-rac` bằng tài khoản Manager, xác nhận trang này KHÔNG bị ảnh hưởng (không file nào trong `src/main/webapp/manager/` hoặc `ThungRacManagerServlet.java` bị sửa ở plan này).

- [ ] **Step 5: git diff review**

Run: `git -C /home/nhan/Downloads/V-SPORT diff --stat` và `git -C /home/nhan/Downloads/V-SPORT diff --name-status`

Expected: chỉ các file liệt kê trong Task 1-9 (`CoSoDAOImpl.java`, `CoSoDAO.java`, `TaiKhoanDAO.java`, `TaiKhoanDAOImpl.java`, `OwnerApprovalService.java` [mới], `AdminOwnerServlet.java`, `QuanLyChiNhanhServlet.java`, `AdminTrashServlet.java`, `QuanLyOwner.jsp`, `ThungRacAdmin.jsp`, `NhanSu.jsp`). KHÔNG có file liên quan PayOS/booking/check-in/hóa đơn/ca làm, KHÔNG có file trong `src/main/webapp/manager/`. `.env.example` (thay đổi có sẵn từ trước, không liên quan) không được commit trong task này.

- [ ] **Step 6: KHÔNG commit, KHÔNG push** — dừng lại ở working tree, để người dùng tự review và commit.

---

## Self-Review

**Spec coverage:**
- Mục A (thùng rác Admin đồng nhất) → Task 8 (restyle), Task 9 (xóa UI riêng NhanSu), Task 10 Step 4 (verify sidebar/không permanent-delete/Manager Trash không bị ảnh hưởng).
- Mục B (Owner Request) → Task 1 (lọc Cơ sở), Task 2 (lọc Nhân sự), Task 3-4-5 (transaction duyệt/từ chối hợp nhất), Task 6 (guard thu hồi), Task 7 (bỏ tab Từ chối), Task 10 Step 3 (5 test case + case guard).
- Toast 10 giây (Bước 15): không cần sửa — `admin_toast.jsp` và các session attribute `trashMessage/trashUrl/trashCountdownSeconds` đã tồn tại và được giữ nguyên ở mọi điểm ghi AdminTrash (Task 4, 5, đã có sẵn ở QuanLyChiNhanhServlet.xoa và QuanLyNguoiDungServlet).
- Không hard delete / không nút vĩnh viễn: xác nhận Admin chưa từng có (khảo sát), không task nào thêm vào.

**Placeholder scan:** không còn "TBD"/"tương tự Task N" — mọi step có code hoặc lệnh cụ thể. Task 9 Step 1 có một ghi chú "đọc trước 10 dòng" vì khảo sát ban đầu không trích đủ markup gốc của nút "Nhân sự" liền kề — đây là hướng dẫn xác minh tại chỗ, không phải placeholder cho logic nghiệp vụ.

**Type consistency:** `OwnerApprovalService.ApprovalResult` dùng nhất quán field `success/errorMessage/coSo/account` giữa Task 3 (định nghĩa), Task 4, Task 5 (sử dụng). `hasActiveOrPendingCoSo(int accountId, int excludeCoSoId)` khớp giữa khai báo interface (Task 6 Step 1) và lời gọi (Task 6 Step 2).
