# QR-03A — Luồng QR tại sân Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cho phép khách quét QR sân để gọi nhân viên / gọi món / yêu cầu dịch vụ, staff nhận và xử lý theo cơ sở, khách theo dõi trạng thái — không đụng QR domain, ServiceOrder (Task 6/7), thanh toán/hóa đơn/tồn kho hiện có.

**Architecture:** Bảng SQL mới `QRRequest` độc lập + `QRRequestService` (JPA, EntityManager theo pattern `SanQRService`) + 4 servlet customer-facing + 4 servlet staff-facing + 4 JSP mới + 1 chỉnh sửa nhỏ trong `CheckIn.jsp` (thumbnail QR + badge).

**Tech Stack:** Jakarta Servlet (`@WebServlet`, annotation-only, không sửa web.xml), JPA/Hibernate qua `JPAUtil.getEntityManager()`, Gson cho JSON API, JSTL trong JSP, SQL Server migration script `IF NOT EXISTS`.

## Global Constraints

- KHÔNG sửa: `SanQR*`, `SanQRService`, `SanQRManagerServlet/ImageServlet/PrintServlet`, `ServiceOrder*`, `YeuCauDichVu*`, `DichVu*` (Task 6/7), trang Quản lý Mã QR sân, logic booking/check-in hiện có, payment/invoice.
- Không tạo WebSocket, không QR check-in tự động, không QR mở sân/mở khóa, không thanh toán/trừ tồn kho/tạo hóa đơn từ luồng này.
- CoSoID cho mọi thao tác staff PHẢI lấy từ `session.getAttribute("user")` (`TaiKhoan.getCoSoId()`), không bao giờ tin request param — nguyên tắc chống IDOR đã áp dụng cho QR domain.
- Role IDs: Manager = 2, Staff/Receptionist = 4 (theo `CheckInServlet`).
- `SanQRResolveServlet` chỉ đọc (resolve), không tạo side-effect nào (không check-in, không tạo request).
- Mọi entity mới theo convention plain `int`/`Integer` FK column, không dùng `@ManyToOne` (đúng convention `SanQR`/`San`/`SanPham_DichVu`).
- Servlet mapping bằng `@WebServlet` annotation only, không sửa `web.xml`.

---

## File Structure

- Create: `sql/migration_qr_request.sql` — tạo bảng `QRRequest`.
- Create: `src/main/java/org/example/model/QRRequest.java` — entity.
- Create: `src/main/java/org/example/dao/QRRequestDAO.java` + `src/main/java/org/example/dao/impl/QRRequestDAOImpl.java`.
- Create: `src/main/java/org/example/service/QRRequestService.java` — business logic dùng chung customer/staff.
- Create: `src/main/java/org/example/dto/qr/QRRequestDTO.java` — DTO trả JSON (tránh serialize entity trực tiếp).
- Create: `src/main/java/org/example/controller/customer/SanQRResolveServlet.java` — `GET /qr/{shortCode}`.
- Create: `src/main/java/org/example/controller/customer/api/QRRequestApiServlet.java` — `POST /api/qr/yeu-cau`.
- Create: `src/main/java/org/example/controller/customer/api/QRRequestStatusApiServlet.java` — `GET /api/qr/yeu-cau`.
- Create: `src/main/java/org/example/controller/customer/api/SanPhamQRApiServlet.java` — `GET /api/qr/san-pham`.
- Create: `src/main/java/org/example/controller/staff/YeuCauQRServlet.java` — `GET /staff/yeu-cau-qr`.
- Create: `src/main/java/org/example/controller/staff/api/YeuCauQRApiServlet.java` — `GET /api/staff/yeu-cau-qr`.
- Create: `src/main/java/org/example/controller/staff/api/YeuCauQRActionApiServlet.java` — `POST /api/staff/yeu-cau-qr/{id}/action`.
- Create: `src/main/java/org/example/controller/staff/api/YeuCauQRCountApiServlet.java` — `GET /api/staff/yeu-cau-qr/count`.
- Create: `src/main/webapp/customer/QuetQR.jsp`.
- Create: `src/main/webapp/customer/TrangThaiYeuCau.jsp`.
- Create: `src/main/webapp/staff/YeuCauQR.jsp`.
- Modify: `src/main/webapp/staff/CheckIn.jsp` — thêm thumbnail QR trên card sân + badge số lượng yêu cầu mới.

---

### Task 1: DB migration + entity `QRRequest`

**Files:**
- Create: `sql/migration_qr_request.sql`
- Create: `src/main/java/org/example/model/QRRequest.java`

**Interfaces:**
- Produces: entity `QRRequest` với getters/setters: `getRequestId()/int`, `getSanId()/int`, `getCoSoId()/int`, `getGuestToken()/String`, `getCustomerId()/Integer`, `getRequestType()/String`, `getItemsJson()/String`, `getNote()/String`, `getStatus()/String`, `getCreatedAt()/LocalDateTime`, `getUpdatedAt()/LocalDateTime`, `getHandledByStaffId()/Integer`. Hằng số: `TYPE_CALL_STAFF`, `TYPE_ORDER_ITEM`, `TYPE_SERVICE_REQUEST`, `STATUS_NEW`, `STATUS_IN_PROGRESS`, `STATUS_DONE`, `STATUS_CANCELLED`.

- [ ] **Step 1: Viết migration SQL**

```sql
-- Migration: Bảng QRRequest cho luồng QR-03A (gọi nhân viên / gọi món / yêu cầu dịch vụ tại sân)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.

USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'QRRequest')
BEGIN
    CREATE TABLE QRRequest (
        RequestID       INT IDENTITY(1,1) PRIMARY KEY,
        SanID           INT NOT NULL,
        CoSoID          INT NOT NULL,
        GuestToken      VARCHAR(64) NOT NULL,
        CustomerID      INT NULL,
        RequestType     VARCHAR(20) NOT NULL,
        ItemsJson       NVARCHAR(MAX) NULL,
        Note            NVARCHAR(255) NULL,
        Status          VARCHAR(20) NOT NULL DEFAULT 'NEW',
        CreatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt       DATETIME2 NOT NULL DEFAULT GETDATE(),
        HandledByStaffID INT NULL,
        CONSTRAINT FK_QRRequest_San FOREIGN KEY (SanID) REFERENCES San(SanID),
        CONSTRAINT FK_QRRequest_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID),
        CONSTRAINT CK_QRRequest_Type CHECK (RequestType IN ('CALL_STAFF','ORDER_ITEM','SERVICE_REQUEST')),
        CONSTRAINT CK_QRRequest_Status CHECK (Status IN ('NEW','IN_PROGRESS','DONE','CANCELLED'))
    );
    CREATE INDEX IX_QRRequest_CoSo_Status ON QRRequest(CoSoID, Status);
    CREATE INDEX IX_QRRequest_GuestToken ON QRRequest(GuestToken);
    PRINT N'Đã tạo bảng QRRequest.';
END
ELSE
    PRINT N'Bảng QRRequest đã tồn tại, bỏ qua.';
GO
```

- [ ] **Step 2: Chạy migration trên DB dev, xác nhận bảng được tạo**

Run: `sqlcmd -S <server> -d QuanLiSport -i sql/migration_qr_request.sql`
Expected output includes: `Đã tạo bảng QRRequest.`

- [ ] **Step 3: Viết entity**

```java
package org.example.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "QRRequest")
public class QRRequest {
    public static final String TYPE_CALL_STAFF = "CALL_STAFF";
    public static final String TYPE_ORDER_ITEM = "ORDER_ITEM";
    public static final String TYPE_SERVICE_REQUEST = "SERVICE_REQUEST";

    public static final String STATUS_NEW = "NEW";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_DONE = "DONE";
    public static final String STATUS_CANCELLED = "CANCELLED";

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RequestID")
    private int requestId;

    @Column(name = "SanID", nullable = false)
    private int sanId;

    @Column(name = "CoSoID", nullable = false)
    private int coSoId;

    @Column(name = "GuestToken", nullable = false, length = 64)
    private String guestToken;

    @Column(name = "CustomerID")
    private Integer customerId;

    @Column(name = "RequestType", nullable = false, length = 20)
    private String requestType;

    @Column(name = "ItemsJson", columnDefinition = "nvarchar(max)")
    private String itemsJson;

    @Column(name = "Note", length = 255)
    private String note;

    @Column(name = "Status", nullable = false, length = 20)
    private String status;

    @Column(name = "CreatedAt", nullable = false)
    private LocalDateTime createdAt;

    @Column(name = "UpdatedAt", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "HandledByStaffID")
    private Integer handledByStaffId;

    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
        if (status == null) status = STATUS_NEW;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    public int getSanId() { return sanId; }
    public void setSanId(int sanId) { this.sanId = sanId; }
    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
    public String getGuestToken() { return guestToken; }
    public void setGuestToken(String guestToken) { this.guestToken = guestToken; }
    public Integer getCustomerId() { return customerId; }
    public void setCustomerId(Integer customerId) { this.customerId = customerId; }
    public String getRequestType() { return requestType; }
    public void setRequestType(String requestType) { this.requestType = requestType; }
    public String getItemsJson() { return itemsJson; }
    public void setItemsJson(String itemsJson) { this.itemsJson = itemsJson; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    public Integer getHandledByStaffId() { return handledByStaffId; }
    public void setHandledByStaffId(Integer handledByStaffId) { this.handledByStaffId = handledByStaffId; }
}
```

- [ ] **Step 4: Compile check**

Run: `mvn -q -pl . compile` (hoặc `mvn compile` nếu không multi-module)
Expected: BUILD SUCCESS, không lỗi ở `QRRequest.java`.

- [ ] **Step 5: Commit**

```bash
git add sql/migration_qr_request.sql src/main/java/org/example/model/QRRequest.java
git commit -m "feat(qr03a): add QRRequest table and entity"
```

---

### Task 2: DAO + Service `QRRequestService`

**Files:**
- Create: `src/main/java/org/example/dao/QRRequestDAO.java`
- Create: `src/main/java/org/example/dao/impl/QRRequestDAOImpl.java`
- Create: `src/main/java/org/example/service/QRRequestService.java`
- Create: `src/main/java/org/example/dto/qr/QRRequestDTO.java`

**Interfaces:**
- Consumes: `QRRequest` entity (Task 1), `JPAUtil.getEntityManager()`.
- Produces: `QRRequestService` public methods used by later tasks:
  - `Result createRequest(int sanId, String guestToken, Integer customerId, String requestType, String itemsJson, String note)` — validates QR ACTIVE, `San` tồn tại/chưa xoá, ghi `CoSoID` từ `San`.
  - `List<QRRequestDTO> listByGuestToken(String guestToken, int sanId)`
  - `List<QRRequestDTO> listByCoSoAndStatus(int coSoId, String status)` (status null = tất cả)
  - `Result updateStatus(int requestId, int staffCoSoId, Integer staffAccountId, String newStatus)` — kiểm tra `req.getCoSoId() == staffCoSoId`, kiểm tra transition hợp lệ (NEW→IN_PROGRESS→DONE, hoặc bất kỳ trạng thái chưa DONE→CANCELLED).
  - `long countNewByCoSo(int coSoId)`
  - Inner class `Result` giống pattern `SanQRService.Result` với `ok`, `fail(ErrorCode, message)`, field `success`, `message`, `data`.
  - Enum `ErrorCode { NOT_FOUND, FORBIDDEN, INVALID_TRANSITION, SYSTEM }`

- [ ] **Step 1: Viết DTO**

```java
package org.example.dto.qr;

import java.time.LocalDateTime;

public final class QRRequestDTO {
    private final int requestId;
    private final int sanId;
    private final String tenSan;
    private final String requestType;
    private final String itemsJson;
    private final String note;
    private final String status;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;

    public QRRequestDTO(int requestId, int sanId, String tenSan, String requestType,
                         String itemsJson, String note, String status,
                         LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.requestId = requestId;
        this.sanId = sanId;
        this.tenSan = tenSan;
        this.requestType = requestType;
        this.itemsJson = itemsJson;
        this.note = note;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getRequestId() { return requestId; }
    public int getSanId() { return sanId; }
    public String getTenSan() { return tenSan; }
    public String getRequestType() { return requestType; }
    public String getItemsJson() { return itemsJson; }
    public String getNote() { return note; }
    public String getStatus() { return status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
```

- [ ] **Step 2: Viết DAO interface + impl**

```java
package org.example.dao;

import org.example.model.QRRequest;
import java.util.List;

public interface QRRequestDAO {
    QRRequest save(QRRequest request);
    QRRequest findById(int requestId);
    List<QRRequest> findByGuestTokenAndSan(String guestToken, int sanId);
    List<QRRequest> findByCoSoAndStatus(int coSoId, String status);
    long countByCoSoAndStatus(int coSoId, String status);
}
```

```java
package org.example.dao.impl;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import org.example.dao.QRRequestDAO;
import org.example.model.QRRequest;
import org.example.util.JPAUtil;

import java.util.List;

public class QRRequestDAOImpl implements QRRequestDAO {

    @Override
    public QRRequest save(QRRequest request) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            em.getTransaction().begin();
            if (request.getRequestId() == 0) {
                em.persist(request);
            } else {
                request = em.merge(request);
            }
            em.getTransaction().commit();
            return request;
        } catch (RuntimeException e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    @Override
    public QRRequest findById(int requestId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(QRRequest.class, requestId);
        } finally {
            em.close();
        }
    }

    @Override
    public List<QRRequest> findByGuestTokenAndSan(String guestToken, int sanId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<QRRequest> q = em.createQuery(
                "SELECT r FROM QRRequest r WHERE r.guestToken = :guestToken AND r.sanId = :sanId ORDER BY r.createdAt DESC",
                QRRequest.class);
            q.setParameter("guestToken", guestToken);
            q.setParameter("sanId", sanId);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public List<QRRequest> findByCoSoAndStatus(int coSoId, String status) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            String jpql = "SELECT r FROM QRRequest r WHERE r.coSoId = :coSoId"
                + (status != null ? " AND r.status = :status" : "")
                + " ORDER BY r.createdAt DESC";
            TypedQuery<QRRequest> q = em.createQuery(jpql, QRRequest.class);
            q.setParameter("coSoId", coSoId);
            if (status != null) q.setParameter("status", status);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    @Override
    public long countByCoSoAndStatus(int coSoId, String status) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<Long> q = em.createQuery(
                "SELECT COUNT(r) FROM QRRequest r WHERE r.coSoId = :coSoId AND r.status = :status",
                Long.class);
            q.setParameter("coSoId", coSoId);
            q.setParameter("status", status);
            return q.getSingleResult();
        } finally {
            em.close();
        }
    }
}
```

- [ ] **Step 3: Viết `QRRequestService`**

```java
package org.example.service;

import org.example.dao.QRRequestDAO;
import org.example.dao.impl.QRRequestDAOImpl;
import org.example.dto.qr.QRRequestDTO;
import org.example.model.QRRequest;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.service.manager.SanQRService;
import org.example.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.util.List;
import java.util.stream.Collectors;

public class QRRequestService {

    public enum ErrorCode { NOT_FOUND, FORBIDDEN, INVALID_TRANSITION, SYSTEM }

    public static class Result {
        public final boolean success;
        public final ErrorCode errorCode;
        public final String message;
        public final QRRequestDTO data;

        private Result(boolean success, ErrorCode errorCode, String message, QRRequestDTO data) {
            this.success = success; this.errorCode = errorCode; this.message = message; this.data = data;
        }

        public static Result ok(QRRequestDTO data) { return new Result(true, null, null, data); }
        public static Result fail(ErrorCode code, String message) { return new Result(false, code, message, null); }
    }

    private final QRRequestDAO dao = new QRRequestDAOImpl();
    private final SanQRService sanQRService = new SanQRService();

    public Result createRequest(int sanId, String guestToken, Integer customerId,
                                 String requestType, String itemsJson, String note) {
        if (guestToken == null || guestToken.isBlank()) {
            return Result.fail(ErrorCode.FORBIDDEN, "Thiếu định danh phiên.");
        }
        EntityManager em = JPAUtil.getEntityManager();
        San san;
        try {
            san = em.find(San.class, sanId);
        } finally {
            em.close();
        }
        if (san == null || Boolean.TRUE.equals(san.getIsDeleted())) {
            return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy sân.");
        }
        SanQR sanQR = sanQRService.findReadOnlyBySanId(sanId);
        if (sanQR == null || !sanQR.isActive()) {
            return Result.fail(ErrorCode.FORBIDDEN, "Mã QR của sân này không còn hiệu lực.");
        }

        QRRequest request = new QRRequest();
        request.setSanId(sanId);
        request.setCoSoId(san.getCoSoID());
        request.setGuestToken(guestToken);
        request.setCustomerId(customerId);
        request.setRequestType(requestType);
        request.setItemsJson(itemsJson);
        request.setNote(note);
        request.setStatus(QRRequest.STATUS_NEW);
        QRRequest saved = dao.save(request);
        return Result.ok(toDTO(saved, san.getTenSan()));
    }

    public List<QRRequestDTO> listByGuestToken(String guestToken, int sanId) {
        EntityManager em = JPAUtil.getEntityManager();
        String tenSan;
        try {
            San san = em.find(San.class, sanId);
            tenSan = san != null ? san.getTenSan() : "";
        } finally {
            em.close();
        }
        return dao.findByGuestTokenAndSan(guestToken, sanId).stream()
            .map(r -> toDTO(r, tenSan))
            .collect(Collectors.toList());
    }

    public List<QRRequestDTO> listByCoSoAndStatus(int coSoId, String status) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return dao.findByCoSoAndStatus(coSoId, status).stream()
                .map(r -> {
                    San san = em.find(San.class, r.getSanId());
                    return toDTO(r, san != null ? san.getTenSan() : "");
                })
                .collect(Collectors.toList());
        } finally {
            em.close();
        }
    }

    public Result updateStatus(int requestId, int staffCoSoId, Integer staffAccountId, String newStatus) {
        QRRequest req = dao.findById(requestId);
        if (req == null) {
            return Result.fail(ErrorCode.NOT_FOUND, "Không tìm thấy yêu cầu.");
        }
        if (req.getCoSoId() != staffCoSoId) {
            return Result.fail(ErrorCode.FORBIDDEN, "Yêu cầu không thuộc cơ sở của bạn.");
        }
        if (!isValidTransition(req.getStatus(), newStatus)) {
            return Result.fail(ErrorCode.INVALID_TRANSITION,
                "Không thể chuyển từ " + req.getStatus() + " sang " + newStatus + ".");
        }
        req.setStatus(newStatus);
        req.setHandledByStaffId(staffAccountId);
        QRRequest saved = dao.save(req);
        EntityManager em = JPAUtil.getEntityManager();
        String tenSan;
        try {
            San san = em.find(San.class, saved.getSanId());
            tenSan = san != null ? san.getTenSan() : "";
        } finally {
            em.close();
        }
        return Result.ok(toDTO(saved, tenSan));
    }

    public long countNewByCoSo(int coSoId) {
        return dao.countByCoSoAndStatus(coSoId, QRRequest.STATUS_NEW);
    }

    private boolean isValidTransition(String from, String to) {
        if (QRRequest.STATUS_CANCELLED.equals(to)) {
            return !QRRequest.STATUS_DONE.equals(from) && !QRRequest.STATUS_CANCELLED.equals(from);
        }
        if (QRRequest.STATUS_NEW.equals(from) && QRRequest.STATUS_IN_PROGRESS.equals(to)) return true;
        if (QRRequest.STATUS_IN_PROGRESS.equals(from) && QRRequest.STATUS_DONE.equals(to)) return true;
        return false;
    }

    private QRRequestDTO toDTO(QRRequest r, String tenSan) {
        return new QRRequestDTO(r.getRequestId(), r.getSanId(), tenSan, r.getRequestType(),
            r.getItemsJson(), r.getNote(), r.getStatus(), r.getCreatedAt(), r.getUpdatedAt());
    }
}
```

> Lưu ý cho engineer thực hiện: kiểm tra chữ ký thật của `SanQRService.findReadOnlyBySanId(int)` (đọc file `org.example.service.manager.SanQRService`) — nếu tên phương thức khác, dùng đúng tên có sẵn để lấy `SanQR` theo `sanId` mà không cần lock. Nếu không có sẵn phương thức read-only theo `sanId`, thêm một phương thức nhỏ đọc-only vào `SanQRService` (không sửa logic hiện có, chỉ thêm method mới) hoặc query trực tiếp qua `EntityManager` trong `QRRequestService` bằng JPQL `SELECT q FROM SanQR q WHERE q.sanId = :sanId`.

- [ ] **Step 4: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/dao/QRRequestDAO.java \
        src/main/java/org/example/dao/impl/QRRequestDAOImpl.java \
        src/main/java/org/example/service/QRRequestService.java \
        src/main/java/org/example/dto/qr/QRRequestDTO.java
git commit -m "feat(qr03a): add QRRequestService with create/list/updateStatus/count"
```

---

### Task 3: Customer resolve servlet + trang quét QR

**Files:**
- Create: `src/main/java/org/example/controller/customer/SanQRResolveServlet.java`
- Create: `src/main/webapp/customer/QuetQR.jsp`
- Create: `src/main/java/org/example/controller/customer/api/SanPhamQRApiServlet.java`

**Interfaces:**
- Consumes: `SanQRService` (đã có, dùng `resolveActiveShortCode(String)` trả `PublicResolveResult` với `outcome` + `dto` là `SanQRResolveDTO`), `SanPhamDichVuDAO.findByCoSo(int)`.
- Produces: request attribute `sanId`, `resolveDto` truyền vào JSP; endpoint JSON `/api/qr/san-pham?sanId=` trả `[{sanPhamId, tenSanPham, donGia}]`.

- [ ] **Step 1: Viết `SanQRResolveServlet`**

```java
package org.example.controller.customer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.service.manager.SanQRService;

import java.io.IOException;

@WebServlet({"/qr/*"})
public class SanQRResolveServlet extends HttpServlet {

    private final SanQRService sanQRService = new SanQRService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        String shortCode = pathInfo != null ? pathInfo.replace("/", "") : null;
        if (shortCode == null || shortCode.isBlank()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        SanQRService.PublicResolveResult result = sanQRService.resolveActiveShortCode(shortCode);
        SanQRResolveDTO dto = result.dto;
        req.setAttribute("resolveDto", dto);
        req.setAttribute("shortCode", shortCode);
        req.setAttribute("sanIdParam", req.getParameter("sanId"));
        req.getRequestDispatcher("/customer/QuetQR.jsp").forward(req, resp);
    }
}
```

> Lưu ý: `SanQRResolveDTO` (xem file có sẵn) không chứa `sanId`. Trang JSP cần `sanId` để gọi API tạo request/lấy sản phẩm. Kiểm tra `SanQRService.resolveActiveShortCode` — nếu `PublicResolveResult`/`SanQRResolveDTO` không lộ `sanId`, thêm field `sanId` (Integer, có thể null khi lỗi) vào `SanQRResolveDTO` bằng cách thêm factory method mới `okWithSanId(...)` mà KHÔNG xoá/sửa các factory method cũ (`ok`, `notFound`, `revoked`, `disabled`, `facilityInactive` phải giữ nguyên chữ ký để không phá code hiện có), và cập nhật lời gọi `ok(...)` bên trong `SanQRService` tại chỗ resolve OK để truyền thêm `sanId`.

- [ ] **Step 2: Viết `QuetQR.jsp`**

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quét mã sân - V-SPORT</title>
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background:#f4f4f5; margin:0; padding:16px; }
        .card { background:#fff; border-radius:16px; padding:20px; box-shadow:0 1px 3px rgba(0,0,0,.08); margin-bottom:12px; }
        h1 { font-size:18px; margin:0 0 4px; }
        .sub { color:#71717a; font-size:13px; margin:0 0 16px; }
        .action-btn { display:flex; align-items:center; gap:12px; width:100%; padding:16px; border:none; border-radius:14px;
                      background:#7C3AED; color:#fff; font-weight:700; font-size:15px; margin-bottom:12px; cursor:pointer; }
        .action-btn:active { transform: scale(.98); }
        .error-box { color:#b91c1c; background:#fef2f2; border-radius:12px; padding:16px; }
    </style>
</head>
<body>
<c:choose>
    <c:when test="${resolveDto.resultCode == 'OK'}">
        <div class="card">
            <h1>${resolveDto.tenSan}</h1>
            <p class="sub">${resolveDto.tenCoSo}</p>
        </div>
        <button class="action-btn" onclick="location.href='TrangThaiYeuCau.jsp?shortCode=${shortCode}&type=call'">📢 Gọi nhân viên</button>
        <button class="action-btn" onclick="location.href='TrangThaiYeuCau.jsp?shortCode=${shortCode}&type=order'">🍔 Gọi món</button>
        <button class="action-btn" onclick="location.href='TrangThaiYeuCau.jsp?shortCode=${shortCode}&type=service'">🛠️ Yêu cầu dịch vụ</button>
    </c:when>
    <c:otherwise>
        <div class="error-box">${resolveDto.message}</div>
    </c:otherwise>
</c:choose>
</body>
</html>
```

> Ghi chú thiết kế: bước 2 này dựng khung điều hướng tối thiểu (redirect sang trang theo dõi kèm `type`), phần form nhập món/ghi chú và gọi API tạo request thực tế được hoàn thiện ở Task 5 khi viết `TrangThaiYeuCau.jsp` (trang đó xử lý cả tạo request lẫn theo dõi, tránh trùng lặp 2 trang).

- [ ] **Step 3: Viết `SanPhamQRApiServlet`**

```java
package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dao.SanPhamDichVuDAO;
import org.example.dao.impl.SanPhamDichVuDAOImpl;
import org.example.model.San;
import org.example.model.SanPham_DichVu;
import org.example.util.JPAUtil;
import jakarta.persistence.EntityManager;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/api/qr/san-pham")
public class SanPhamQRApiServlet extends HttpServlet {

    private final SanPhamDichVuDAO sanPhamDao = new SanPhamDichVuDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        int sanId;
        try {
            sanId = Integer.parseInt(req.getParameter("sanId"));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Thiếu sanId.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        EntityManager em = JPAUtil.getEntityManager();
        San san;
        try {
            san = em.find(San.class, sanId);
        } finally {
            em.close();
        }
        if (san == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            out.put("success", false);
            out.put("message", "Không tìm thấy sân.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        List<SanPham_DichVu> items = sanPhamDao.findByCoSo(san.getCoSoID());
        List<Map<String, Object>> data = items.stream()
            .filter(p -> !"Ngừng bán".equalsIgnoreCase(p.getTrangThai()))
            .map(p -> {
                Map<String, Object> m = new HashMap<>();
                m.put("sanPhamId", p.getSanPhamID());
                m.put("tenSanPham", p.getTenSanPham());
                m.put("donGia", p.getDonGia());
                return m;
            })
            .collect(Collectors.toList());
        out.put("success", true);
        out.put("data", data);
        resp.getWriter().write(gson.toJson(out));
    }
}
```

> Lưu ý: kiểm tra chữ ký thật của getters trên `SanPham_DichVu` (`getSanPhamID()`, `getTenSanPham()`, `getDonGia()`, `getTrangThai()`) và giá trị thực tế dùng cho "ngừng bán" trong `TrangThai` trước khi hardcode chuỗi so sánh — nếu khác, dùng đúng giá trị hiện có trong DB/enum.

- [ ] **Step 4: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/controller/customer/SanQRResolveServlet.java \
        src/main/webapp/customer/QuetQR.jsp \
        src/main/java/org/example/controller/customer/api/SanPhamQRApiServlet.java
git commit -m "feat(qr03a): add customer QR resolve page and product listing API"
```

---

### Task 4: API tạo yêu cầu (`POST /api/qr/yeu-cau`)

**Files:**
- Create: `src/main/java/org/example/controller/customer/api/QRRequestApiServlet.java`

**Interfaces:**
- Consumes: `QRRequestService.createRequest(...)` (Task 2).
- Produces: `POST /api/qr/yeu-cau` nhận form params `sanId, guestToken, requestType, note, itemsJson` (itemsJson optional, JSON string do client build sẵn), trả `{success, message, data:{requestId,status,...}}`.

- [ ] **Step 1: Viết servlet**

```java
package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/qr/yeu-cau")
public class QRRequestApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        try {
            int sanId = Integer.parseInt(req.getParameter("sanId"));
            String guestToken = req.getParameter("guestToken");
            String requestType = req.getParameter("requestType");
            String note = req.getParameter("note");
            String itemsJson = req.getParameter("itemsJson");

            if (!isValidType(requestType)) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", "Loại yêu cầu không hợp lệ.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }

            QRRequestService.Result result = service.createRequest(sanId, guestToken, null, requestType, itemsJson, note);
            if (!result.success) {
                resp.setStatus(statusFor(result.errorCode));
                out.put("success", false);
                out.put("message", result.message);
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            out.put("success", true);
            out.put("data", result.data);
            resp.getWriter().write(gson.toJson(out));
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Dữ liệu không hợp lệ.");
            resp.getWriter().write(gson.toJson(out));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.put("success", false);
            out.put("message", "Đã xảy ra lỗi hệ thống.");
            resp.getWriter().write(gson.toJson(out));
        }
    }

    private boolean isValidType(String type) {
        return "CALL_STAFF".equals(type) || "ORDER_ITEM".equals(type) || "SERVICE_REQUEST".equals(type);
    }

    private int statusFor(QRRequestService.ErrorCode code) {
        if (code == null) return HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        switch (code) {
            case NOT_FOUND: return HttpServletResponse.SC_NOT_FOUND;
            case FORBIDDEN: return HttpServletResponse.SC_FORBIDDEN;
            default: return HttpServletResponse.SC_INTERNAL_SERVER_ERROR;
        }
    }
}
```

- [ ] **Step 2: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 3: Thủ công kiểm tra bằng curl (server phải đang chạy)**

Run: `curl -s -X POST "http://localhost:8080/Backend_java/api/qr/yeu-cau" -d "sanId=1&guestToken=test-token-1&requestType=CALL_STAFF&note=test"`
Expected: JSON `{"success":true,"data":{...,"status":"NEW",...}}` (hoặc `{"success":false,...}` với message rõ ràng nếu sân/QR không hợp lệ trong DB dev — không phải lỗi 500).

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/controller/customer/api/QRRequestApiServlet.java
git commit -m "feat(qr03a): add API to create QR request from customer"
```

---

### Task 5: API + trang theo dõi trạng thái (tạo request UI + polling)

**Files:**
- Create: `src/main/java/org/example/controller/customer/api/QRRequestStatusApiServlet.java`
- Modify: `src/main/webapp/customer/TrangThaiYeuCau.jsp` (tạo mới, đã tham chiếu ở Task 3)

**Interfaces:**
- Consumes: `QRRequestService.listByGuestToken(String, int)` (Task 2), `QRRequestApiServlet` (Task 4), `SanPhamQRApiServlet` (Task 3).
- Produces: `GET /api/qr/yeu-cau?guestToken=&sanId=` trả `{success, data:[{requestId,requestType,itemsJson,note,status,createdAt,updatedAt}]}`.

- [ ] **Step 1: Viết `QRRequestStatusApiServlet`**

```java
package org.example.controller.customer.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.dto.qr.QRRequestDTO;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/qr/yeu-cau-status")
public class QRRequestStatusApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        try {
            String guestToken = req.getParameter("guestToken");
            int sanId = Integer.parseInt(req.getParameter("sanId"));
            if (guestToken == null || guestToken.isBlank()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", "Thiếu guestToken.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            List<QRRequestDTO> data = service.listByGuestToken(guestToken, sanId);
            out.put("success", true);
            out.put("data", data);
            resp.getWriter().write(gson.toJson(out));
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Dữ liệu không hợp lệ.");
            resp.getWriter().write(gson.toJson(out));
        }
    }
}
```

> Ghi chú: path là `/api/qr/yeu-cau-status` (khác `POST /api/qr/yeu-cau` ở Task 4) để tránh trùng URL pattern GET/POST trên cùng servlet path — Jakarta cho phép cùng path khác method trên cùng class, nhưng ở đây ta dùng 2 class riêng (`QRRequestApiServlet` cho POST tạo, `QRRequestStatusApiServlet` cho GET liệt kê) nên bắt buộc path khác nhau.

- [ ] **Step 2: Viết `TrangThaiYeuCau.jsp`**

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Yêu cầu của bạn - V-SPORT</title>
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background:#f4f4f5; margin:0; padding:16px; }
        .card { background:#fff; border-radius:16px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.08); margin-bottom:12px; }
        .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; text-transform:uppercase; }
        .badge-new { background:#dbeafe; color:#1d4ed8; }
        .badge-progress { background:#fef3c7; color:#b45309; }
        .badge-done { background:#dcfce7; color:#15803d; }
        .badge-cancel { background:#fee2e2; color:#b91c1c; }
        textarea, input[type=text] { width:100%; box-sizing:border-box; border:1px solid #e4e4e7; border-radius:10px; padding:10px; font-size:14px; }
        .item-row { display:flex; align-items:center; justify-content:space-between; padding:8px 0; border-bottom:1px solid #f4f4f5; }
        .qty-btn { width:28px; height:28px; border-radius:8px; border:1px solid #e4e4e7; background:#fff; font-size:16px; cursor:pointer; }
        .submit-btn { width:100%; padding:14px; border:none; border-radius:12px; background:#7C3AED; color:#fff; font-weight:700; margin-top:12px; cursor:pointer; }
        .back-link { display:inline-block; margin-bottom:12px; color:#71717a; font-size:13px; text-decoration:none; }
    </style>
</head>
<body>
<a class="back-link" href="QuetQR.jsp?shortCode=${param.shortCode}">&larr; Quay lại</a>

<div id="composer" class="card" style="display:none;">
    <div id="composer-call" style="display:none;">
        <p>Bạn cần nhân viên hỗ trợ gì?</p>
        <textarea id="callNote" placeholder="Ghi chú (tuỳ chọn)"></textarea>
        <button class="submit-btn" onclick="submitCallStaff()">Gửi yêu cầu gọi nhân viên</button>
    </div>
    <div id="composer-order" style="display:none;">
        <p>Chọn món/sản phẩm:</p>
        <div id="productList"></div>
        <button class="submit-btn" onclick="submitOrder()">Gửi yêu cầu gọi món</button>
    </div>
    <div id="composer-service" style="display:none;">
        <p>Mô tả dịch vụ bạn cần:</p>
        <textarea id="serviceNote" placeholder="Ví dụ: cần thêm lưới, đổi bóng..."></textarea>
        <button class="submit-btn" onclick="submitService()">Gửi yêu cầu dịch vụ</button>
    </div>
</div>

<h3 style="font-size:14px;color:#71717a;">Yêu cầu của bạn</h3>
<div id="requestList"></div>

<script>
const CONTEXT = "${pageContext.request.contextPath}";
const SAN_ID = ${empty resolveDto.sanId ? param.sanId : resolveDto.sanId};
const SHORT_CODE = "${param.shortCode}";
const TYPE = "${param.type}";

function getGuestToken() {
    let t = localStorage.getItem('vsport_guest_token');
    if (!t) {
        t = 'guest-' + Date.now() + '-' + Math.random().toString(36).slice(2, 10);
        localStorage.setItem('vsport_guest_token', t);
    }
    return t;
}
const GUEST_TOKEN = getGuestToken();

if (TYPE === 'call') { document.getElementById('composer').style.display='block'; document.getElementById('composer-call').style.display='block'; }
if (TYPE === 'order') {
    document.getElementById('composer').style.display='block';
    document.getElementById('composer-order').style.display='block';
    loadProducts();
}
if (TYPE === 'service') { document.getElementById('composer').style.display='block'; document.getElementById('composer-service').style.display='block'; }

function loadProducts() {
    fetch(`${CONTEXT}/api/qr/san-pham?sanId=${SAN_ID}`)
        .then(r => r.json())
        .then(res => {
            if (!res.success) return;
            const list = document.getElementById('productList');
            list.innerHTML = res.data.map(p => `
                <div class="item-row" data-id="${p.sanPhamId}" data-name="${p.tenSanPham}">
                    <span>${p.tenSanPham} - ${p.donGia.toLocaleString('vi-VN')}đ</span>
                    <span>
                        <button class="qty-btn" onclick="changeQty(${p.sanPhamId}, -1)">-</button>
                        <span id="qty-${p.sanPhamId}" style="margin:0 8px;">0</span>
                        <button class="qty-btn" onclick="changeQty(${p.sanPhamId}, 1)">+</button>
                    </span>
                </div>`).join('');
        });
}

const cart = {};
function changeQty(id, delta) {
    cart[id] = Math.max(0, (cart[id] || 0) + delta);
    document.getElementById('qty-' + id).textContent = cart[id];
}

function submitCallStaff() {
    const note = document.getElementById('callNote').value;
    createRequest('CALL_STAFF', note, null);
}

function submitOrder() {
    const items = Object.keys(cart).filter(id => cart[id] > 0).map(id => {
        const row = document.querySelector(`.item-row[data-id="${id}"]`);
        return { sanPhamId: Number(id), tenSanPham: row.dataset.name, soLuong: cart[id] };
    });
    if (items.length === 0) { alert('Vui lòng chọn ít nhất 1 món.'); return; }
    createRequest('ORDER_ITEM', null, JSON.stringify(items));
}

function submitService() {
    const note = document.getElementById('serviceNote').value;
    if (!note.trim()) { alert('Vui lòng mô tả yêu cầu.'); return; }
    createRequest('SERVICE_REQUEST', note, null);
}

function createRequest(requestType, note, itemsJson) {
    const body = new URLSearchParams();
    body.set('sanId', SAN_ID);
    body.set('guestToken', GUEST_TOKEN);
    body.set('requestType', requestType);
    if (note) body.set('note', note);
    if (itemsJson) body.set('itemsJson', itemsJson);
    fetch(`${CONTEXT}/api/qr/yeu-cau`, { method: 'POST', body })
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                document.getElementById('composer').style.display = 'none';
                loadRequests();
            } else {
                alert(res.message || 'Không thể gửi yêu cầu.');
            }
        });
}

function statusLabel(status) {
    switch (status) {
        case 'NEW': return ['badge-new', 'Mới gửi'];
        case 'IN_PROGRESS': return ['badge-progress', 'Đang xử lý'];
        case 'DONE': return ['badge-done', 'Hoàn thành'];
        case 'CANCELLED': return ['badge-cancel', 'Đã huỷ'];
        default: return ['badge-new', status];
    }
}

function typeLabel(type) {
    if (type === 'CALL_STAFF') return 'Gọi nhân viên';
    if (type === 'ORDER_ITEM') return 'Gọi món';
    return 'Yêu cầu dịch vụ';
}

function loadRequests() {
    fetch(`${CONTEXT}/api/qr/yeu-cau-status?guestToken=${GUEST_TOKEN}&sanId=${SAN_ID}`)
        .then(r => r.json())
        .then(res => {
            if (!res.success) return;
            const list = document.getElementById('requestList');
            if (res.data.length === 0) {
                list.innerHTML = '<div class="card">Bạn chưa gửi yêu cầu nào.</div>';
                return;
            }
            list.innerHTML = res.data.map(r => {
                const [cls, label] = statusLabel(r.status);
                return `<div class="card">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <strong>${typeLabel(r.requestType)}</strong>
                        <span class="badge ${cls}">${label}</span>
                    </div>
                    ${r.note ? `<p style="color:#71717a;font-size:13px;">${r.note}</p>` : ''}
                </div>`;
            }).join('');
        });
}

loadRequests();
setInterval(loadRequests, 5000);
</script>
</body>
</html>
```

- [ ] **Step 3: Compile check + manual smoke test**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

Manual: mở `http://localhost:8080/Backend_java/qr/<shortCode-thật-trong-DB>`, bấm "Gọi nhân viên", xác nhận request được tạo và trang tự cập nhật badge sau khi staff đổi trạng thái (kiểm chứng đầy đủ ở Task 6).

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/controller/customer/api/QRRequestStatusApiServlet.java \
        src/main/webapp/customer/TrangThaiYeuCau.jsp
git commit -m "feat(qr03a): add customer request composer and status tracking page"
```

---

### Task 6: Trang staff xử lý yêu cầu QR

**Files:**
- Create: `src/main/java/org/example/controller/staff/YeuCauQRServlet.java`
- Create: `src/main/java/org/example/controller/staff/api/YeuCauQRApiServlet.java`
- Create: `src/main/java/org/example/controller/staff/api/YeuCauQRActionApiServlet.java`
- Create: `src/main/java/org/example/controller/staff/api/YeuCauQRCountApiServlet.java`
- Create: `src/main/webapp/staff/YeuCauQR.jsp`

**Interfaces:**
- Consumes: `QRRequestService.listByCoSoAndStatus`, `updateStatus`, `countNewByCoSo` (Task 2).
- Produces: trang `/staff/yeu-cau-qr` với tabs, `GET /api/staff/yeu-cau-qr?status=`, `POST /api/staff/yeu-cau-qr/{id}/action`, `GET /api/staff/yeu-cau-qr/count` trả `{success,data:{count:N}}` — dùng ở Task 7.

- [ ] **Step 1: Viết `YeuCauQRServlet` (render trang)**

```java
package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;

import java.io.IOException;

@WebServlet("/staff/yeu-cau-qr")
public class YeuCauQRServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        req.getRequestDispatcher("/staff/YeuCauQR.jsp").forward(req, resp);
    }
}
```

- [ ] **Step 2: Viết `YeuCauQRApiServlet`**

```java
package org.example.controller.staff.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.dto.qr.QRRequestDTO;
import org.example.model.TaiKhoan;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/api/staff/yeu-cau-qr")
public class YeuCauQRApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            out.put("message", "Bạn không có quyền truy cập chức năng này.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        String status = req.getParameter("status");
        if (status != null && status.isBlank()) status = null;
        List<QRRequestDTO> data = service.listByCoSoAndStatus(user.getCoSoId(), status);
        out.put("success", true);
        out.put("data", data);
        resp.getWriter().write(gson.toJson(out));
    }
}
```

- [ ] **Step 3: Viết `YeuCauQRActionApiServlet`**

```java
package org.example.controller.staff.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.QRRequest;
import org.example.model.TaiKhoan;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/staff/yeu-cau-qr/action")
public class YeuCauQRActionApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            out.put("message", "Bạn không có quyền truy cập chức năng này.");
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        try {
            int requestId = Integer.parseInt(req.getParameter("requestId"));
            String action = req.getParameter("action");
            String newStatus = mapAction(action);
            if (newStatus == null) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", "Hành động không hợp lệ.");
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            QRRequestService.Result result = service.updateStatus(requestId, user.getCoSoId(), user.getTaiKhoanId(), newStatus);
            if (!result.success) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.put("success", false);
                out.put("message", result.message);
                resp.getWriter().write(gson.toJson(out));
                return;
            }
            out.put("success", true);
            out.put("data", result.data);
            resp.getWriter().write(gson.toJson(out));
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.put("success", false);
            out.put("message", "Dữ liệu không hợp lệ.");
            resp.getWriter().write(gson.toJson(out));
        }
    }

    private String mapAction(String action) {
        if ("start".equals(action)) return QRRequest.STATUS_IN_PROGRESS;
        if ("complete".equals(action)) return QRRequest.STATUS_DONE;
        if ("cancel".equals(action)) return QRRequest.STATUS_CANCELLED;
        return null;
    }
}
```

> Lưu ý: kiểm tra tên getter thật cho ID tài khoản trên `TaiKhoan` (`getTaiKhoanId()` là giả định — có thể là `getAccountId()`/`getId()`; đọc file `org.example.model.TaiKhoan` và dùng đúng tên).

- [ ] **Step 4: Viết `YeuCauQRCountApiServlet`**

```java
package org.example.controller.staff.api;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import org.example.service.QRRequestService;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/staff/yeu-cau-qr/count")
public class YeuCauQRCountApiServlet extends HttpServlet {

    private final QRRequestService service = new QRRequestService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");
        Map<String, Object> out = new HashMap<>();
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || (user.getRoleId() != 2 && user.getRoleId() != 4)) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            out.put("success", false);
            resp.getWriter().write(gson.toJson(out));
            return;
        }
        long count = service.countNewByCoSo(user.getCoSoId());
        Map<String, Object> data = new HashMap<>();
        data.put("count", count);
        out.put("success", true);
        out.put("data", data);
        resp.getWriter().write(gson.toJson(out));
    }
}
```

- [ ] **Step 5: Viết `YeuCauQR.jsp`**

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Yêu cầu từ QR sân - V-SPORT</title>
    <style>
        body { font-family: 'Be Vietnam Pro', system-ui, sans-serif; background:#f4f4f5; margin:0; padding:24px; }
        .tabs { display:flex; gap:8px; margin-bottom:16px; }
        .tab-btn { padding:8px 16px; border-radius:10px; border:1px solid #e4e4e7; background:#fff; cursor:pointer; font-weight:600; font-size:13px; }
        .tab-btn.active { background:#7C3AED; color:#fff; border-color:#7C3AED; }
        .card { background:#fff; border-radius:14px; padding:16px; box-shadow:0 1px 3px rgba(0,0,0,.06); margin-bottom:10px; }
        .badge { display:inline-block; padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; text-transform:uppercase; }
        .badge-new { background:#dbeafe; color:#1d4ed8; }
        .badge-progress { background:#fef3c7; color:#b45309; }
        .action-btn { padding:8px 14px; border:none; border-radius:8px; font-weight:700; font-size:12px; cursor:pointer; color:#fff; }
        .btn-start { background:#7C3AED; }
        .btn-complete { background:#16a34a; }
        .btn-cancel { background:#dc2626; }
    </style>
</head>
<body>
<h2>Yêu cầu từ QR sân</h2>
<div class="tabs">
    <button class="tab-btn active" data-status="NEW" onclick="switchTab('NEW', this)">Mới</button>
    <button class="tab-btn" data-status="IN_PROGRESS" onclick="switchTab('IN_PROGRESS', this)">Đang xử lý</button>
    <button class="tab-btn" data-status="DONE" onclick="switchTab('DONE', this)">Hoàn thành</button>
    <button class="tab-btn" data-status="CANCELLED" onclick="switchTab('CANCELLED', this)">Đã huỷ</button>
</div>
<div id="list"></div>

<script>
const CONTEXT = "${pageContext.request.contextPath}";
let currentStatus = 'NEW';

function switchTab(status, btn) {
    currentStatus = status;
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    loadList();
}

function typeLabel(type) {
    if (type === 'CALL_STAFF') return 'Gọi nhân viên';
    if (type === 'ORDER_ITEM') return 'Gọi món';
    return 'Yêu cầu dịch vụ';
}

function actionButtons(r) {
    if (r.status === 'NEW') {
        return `<button class="action-btn btn-start" onclick="doAction(${r.requestId},'start')">Bắt đầu xử lý</button>
                <button class="action-btn btn-cancel" onclick="doAction(${r.requestId},'cancel')">Huỷ</button>`;
    }
    if (r.status === 'IN_PROGRESS') {
        return `<button class="action-btn btn-complete" onclick="doAction(${r.requestId},'complete')">Hoàn thành</button>
                <button class="action-btn btn-cancel" onclick="doAction(${r.requestId},'cancel')">Huỷ</button>`;
    }
    return '';
}

function loadList() {
    fetch(`${CONTEXT}/api/staff/yeu-cau-qr?status=${currentStatus}`)
        .then(r => r.json())
        .then(res => {
            const list = document.getElementById('list');
            if (!res.success) { list.innerHTML = '<div class="card">Không thể tải dữ liệu.</div>'; return; }
            if (res.data.length === 0) { list.innerHTML = '<div class="card">Không có yêu cầu nào.</div>'; return; }
            list.innerHTML = res.data.map(r => `
                <div class="card">
                    <div style="display:flex;justify-content:space-between;align-items:center;">
                        <div>
                            <strong>${r.tenSan}</strong> — ${typeLabel(r.requestType)}
                            ${r.note ? `<p style="color:#71717a;font-size:13px;margin:4px 0 0;">${r.note}</p>` : ''}
                            ${r.itemsJson ? `<p style="color:#71717a;font-size:13px;margin:4px 0 0;">${r.itemsJson}</p>` : ''}
                        </div>
                        <div>${actionButtons(r)}</div>
                    </div>
                </div>`).join('');
        });
}

function doAction(requestId, action) {
    const body = new URLSearchParams();
    body.set('requestId', requestId);
    body.set('action', action);
    fetch(`${CONTEXT}/api/staff/yeu-cau-qr/action`, { method: 'POST', body })
        .then(r => r.json())
        .then(res => {
            if (!res.success) { alert(res.message || 'Không thể xử lý.'); return; }
            loadList();
        });
}

loadList();
setInterval(loadList, 10000);
</script>
</body>
</html>
```

- [ ] **Step 6: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 7: Thủ công kiểm tra luồng end-to-end**

1. Đăng nhập staff/manager, mở `http://localhost:8080/Backend_java/staff/yeu-cau-qr`, xác nhận tab "Mới" hiển thị request tạo ở Task 4/5.
2. Bấm "Bắt đầu xử lý" → xác nhận request biến mất khỏi tab Mới, xuất hiện ở tab "Đang xử lý".
3. Bấm "Hoàn thành" → xuất hiện ở tab "Hoàn thành".
4. Mở lại trang theo dõi của khách (Task 5) → xác nhận badge trạng thái tự cập nhật thành "Hoàn thành" trong vòng 5s (không cần reload).

- [ ] **Step 8: Commit**

```bash
git add src/main/java/org/example/controller/staff/YeuCauQRServlet.java \
        src/main/java/org/example/controller/staff/api/YeuCauQRApiServlet.java \
        src/main/java/org/example/controller/staff/api/YeuCauQRActionApiServlet.java \
        src/main/java/org/example/controller/staff/api/YeuCauQRCountApiServlet.java \
        src/main/webapp/staff/YeuCauQR.jsp
git commit -m "feat(qr03a): add staff page to process QR requests"
```

---

### Task 7: Tích hợp vào `CheckIn.jsp` — thumbnail QR + badge yêu cầu mới

**Files:**
- Modify: `src/main/webapp/staff/CheckIn.jsp`

**Interfaces:**
- Consumes: `YeuCauQRCountApiServlet` (`GET /api/staff/yeu-cau-qr/count`, Task 6), `SanQRImageServlet` (đã có, Manager-only — cần kiểm tra guard role trước khi dùng ở trang Staff).

- [ ] **Step 1: Kiểm tra guard role của `SanQRImageServlet`**

Đọc lại `src/main/java/org/example/controller/manager/SanQRImageServlet.java`: nếu servlet chỉ cho phép `Constants.ROLE_MANAGER`, Staff (role 4) sẽ bị 403 khi load ảnh. Nếu đúng vậy, sửa điều kiện role trong `SanQRImageServlet` để cho phép cả Manager và Staff cùng cơ sở xem preview (KHÔNG đổi endpoint, KHÔNG đổi logic tạo/regenerate/print — chỉ nới điều kiện xem ảnh preview). Nếu servlet đã cho phép cả hai role, bỏ qua bước sửa.

```java
// Trong doGet của SanQRImageServlet, thay điều kiện chỉ-Manager bằng:
if (manager == null || (manager.getRoleId() != Constants.ROLE_MANAGER && manager.getRoleId() != Constants.ROLE_STAFF) || manager.getCoSoId() == null) {
    response.sendError(HttpServletResponse.SC_FORBIDDEN);
    return;
}
```

> Xác nhận tên hằng số `Constants.ROLE_STAFF` có tồn tại (trước đó thấy `CheckInServlet` so sánh trực tiếp `roleId != 4`) — nếu chưa có hằng số này trong `Constants`, dùng `4` trực tiếp để nhất quán với `CheckInServlet`, không tự thêm hằng số mới ngoài phạm vi task.

- [ ] **Step 2: Thêm thumbnail QR vào card sân "Sẵn sàng" (dòng ~526-539 theo khảo sát)**

Tìm khối:
```jsp
<c:when test="${san.trangThai == 'Sẵn sàng'}">
    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-green-500"></span>
```
Thay bằng (thêm ảnh QR nhỏ, giữ nguyên phần còn lại của khối):
```jsp
<c:when test="${san.trangThai == 'Sẵn sàng'}">
    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-green-500"></span>
    <img src="${pageContext.request.contextPath}/manager/ma-qr-san-anh?sanId=${san.sanID}&mode=preview"
         alt="QR sân" class="absolute top-2.5 left-2.5 w-10 h-10 rounded-lg border border-zinc-200 cursor-pointer"
         onclick="window.open(this.src, '_blank')" />
```

Áp dụng tương tự cho card "Đang sử dụng" nếu cùng cấu trúc `absolute top-2.5 right-2.5` (kiểm tra thực tế trong file, chỉ thêm ở các trạng thái sân còn hoạt động: Sẵn sàng, Đang sử dụng — không thêm ở Bảo trì/Tạm đóng vì QR không còn ý nghĩa dùng ngay).

- [ ] **Step 3: Thêm badge "Yêu cầu mới" vào khu vực counters (gần dòng ~589-607)**

Tìm khối chứa `badge-count-waiting` (hoặc tương tự) và thêm 1 nút mới cạnh đó:
```jsp
<button type="button" onclick="location.href='${pageContext.request.contextPath}/staff/yeu-cau-qr'"
        class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-purple-50 text-purple-700 text-xs font-bold">
    <span class="material-symbols-outlined text-[16px]">qr_code_scanner</span>
    Yêu cầu QR
    <span id="badge-count-qr-request" class="badge-count">0</span>
</button>
```

- [ ] **Step 4: Thêm JS polling cho badge (đặt cạnh `setInterval(pollUpdates, 30000)` ở dòng ~1611)**

```javascript
function pollQRRequestCount() {
    fetch(`${CONTEXT_PATH}/api/staff/yeu-cau-qr/count`)
        .then(r => r.json())
        .then(res => {
            if (res.success) {
                const el = document.getElementById('badge-count-qr-request');
                if (el) el.textContent = res.data.count;
            }
        });
}
pollQRRequestCount();
setInterval(pollQRRequestCount, 10000);
```

> Lưu ý: kiểm tra tên biến JS đang giữ context path trong file (`CONTEXT_PATH` là giả định theo convention phổ biến trong dự án) — nếu file dùng biến khác (vd `contextPath`, hoặc literal `${pageContext.request.contextPath}` chèn trực tiếp mỗi lần), dùng đúng biến/khai báo sẵn có trong `CheckIn.jsp` thay vì đặt tên mới.

- [ ] **Step 5: Compile/deploy check**

Run: `mvn -q compile` rồi deploy lại ứng dụng lên server dev.
Expected: trang `/staff/checkin` tải bình thường, không lỗi JS console, thumbnail QR hiển thị đúng ảnh của từng sân.

- [ ] **Step 6: Kiểm tra thủ công toàn luồng chấp nhận**

1. Lấy `shortCode` thật của 1 sân (từ trang Quản lý Mã QR sân) → mở `http://localhost:8080/Backend_java/qr/<shortCode>` trên điện thoại/trình duyệt khác.
2. Bấm "Gọi nhân viên" → gửi.
3. Vào `/staff/checkin`, xác nhận badge "Yêu cầu QR" tăng lên 1 trong vòng 10s.
4. Bấm badge → sang `/staff/yeu-cau-qr`, thấy yêu cầu ở tab Mới → Bắt đầu xử lý → Hoàn thành.
5. Quay lại tab điện thoại (trang theo dõi) → xác nhận trạng thái tự cập nhật thành "Hoàn thành" trong vòng 5s.
6. Lặp lại với "Gọi món" (chọn ít nhất 1 sản phẩm) và "Yêu cầu dịch vụ" (nhập ghi chú) để xác nhận cả 3 loại đều chạy đúng.

- [ ] **Step 7: Commit**

```bash
git add src/main/webapp/staff/CheckIn.jsp src/main/java/org/example/controller/manager/SanQRImageServlet.java
git commit -m "feat(qr03a): add QR thumbnail and new-request badge to staff check-in page"
```

---

## Self-Review Notes

- **Spec coverage:** Task 1-2 = data model; Task 3-5 = customer resolve/gọi món/gọi nhân viên/dịch vụ/theo dõi trạng thái; Task 6 = staff tiếp nhận/xử lý; Task 7 = thumbnail QR trong card + badge/shortcut ở check-in. Tất cả 5 mục trong "Mục tiêu của task" đều có task tương ứng. Điều kiện dừng (luồng end-to-end) được xác minh thủ công ở Task 7 Step 6.
- **Không đụng nền tảng QR/ServiceOrder hiện có:** duy nhất 1 thay đổi tối thiểu, có điều kiện, vào `SanQRImageServlet` (chỉ nới role guard cho ảnh preview, Task 7 Step 1) — mọi thứ khác trong QR domain và toàn bộ `ServiceOrder`/Task 6/7 giữ nguyên.
- **Type consistency:** `QRRequestDTO`, `QRRequestService.Result/ErrorCode`, hằng số `QRRequest.TYPE_*`/`STATUS_*` dùng nhất quán xuyên suốt Task 2, 4, 5, 6.
- **Rủi ro cần engineer xác minh khi thực thi** (đã đánh dấu "Lưu ý" trong từng task): chữ ký thật của `SanQRService.resolveActiveShortCode`/`findReadOnlyBySanId`, field `sanId` trên `SanQRResolveDTO`, getter ID trên `TaiKhoan`, tên hằng số role trong `Constants`, tên biến context-path JS trong `CheckIn.jsp` — vì các chi tiết này phụ thuộc mã nguồn đọc thời điểm brainstorm, engineer cần đọc lại file thật trước khi paste nguyên văn nếu có sai khác.
