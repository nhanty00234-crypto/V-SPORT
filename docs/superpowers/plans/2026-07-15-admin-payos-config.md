# Admin PayOS Per-CoSo Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let Admin (RoleID=1) view, add, and update PayOS credentials (Client ID / API Key / Checksum Key) per Cơ Sở from the existing Admin "Quản lý Cơ Sở" screen, without ever exposing full secrets to the browser or logs.

**Architecture:** Extend the existing `QuanLyChiNhanhServlet`/`QuanLyChiNhanh.jsp` module with a new focused servlet (`PayOSConfigAdminServlet`) at `/admin/chi-nhanh/payos`, a new service (`PayOSConfigurationService`) with pure, unit-testable merge/validate/mask logic, and a new raw-JDBC DAO (`PayOSConfigDAO`) that reads/writes only the three `PayOS_*` columns on `dbo.CoSo` — kept deliberately separate from the JPA `CoSo` entity so secret columns are never pulled into a widely-shared, potentially-logged object. `FilterQuyenAdmin` (already protecting `/admin/*`) gets a narrow JSON-403 special case for this one route. No changes to Manager/Staff payment flow.

**Tech Stack:** Java 17, Jakarta Servlet, JSP/JSTL, Gson (already a dependency, used elsewhere for JSON — e.g. `HoaDonDetailServlet`), raw JDBC via `DBUtil` (already used by `CoSoNganHangDAOImpl`, `FacilityTrashService`), JUnit 5 (already configured, see `CourtPricingServiceTest`).

## Global Constraints

- Admin-only (RoleID=1). Enforced server-side in `FilterQuyenAdmin`, not just hidden in the UI.
- Never return full secret values to the frontend. GET/POST responses only ever contain masked values + booleans.
- Never log secret values (Client ID/API Key/Checksum Key) — only CoSoID, admin AccountID, action, fields-changed, success/failure.
- Never accept a masked/placeholder value back as a real credential (reject anything containing `•`, all-asterisk strings, or the literal "Đã cấu hình").
- Blank submitted field = keep existing value. Non-blank = replace. After merge, all three fields must be non-blank or the update is rejected.
- Do not use `CoSoNganHang` table/DAO for PayOS. Do not touch `CheckoutService`, `InvoiceView`, `InvoiceViewService`, `CheckInServlet`, `HoaDonPrint.jsp`, or the bank-transfer files currently uncommitted in git status — those are unrelated in-flight work.
- All AJAX responses are `application/json;charset=UTF-8`, real HTTP status codes (400/403/404/500), never `sendError` HTML, never a redirect for a fetch call.
- No DB migration is executed by the assistant (no live DB access from this sandbox) — the SQL script is idempotent (`IF NOT EXISTS`) and delivered for the user to run once, exactly like `sql/migration_bank_transfer.sql`.
- Visual language must match the existing Admin Portal exactly (Tailwind CDN + Tabler icons, `rounded-xl`/`rounded-2xl`, zinc/blue palette, `badge-*` classes, zinc-900 for the committing "Save" action, blue-600 reserved for "add new"). No gradients beyond the existing card top-border accent, no glassmorphism, no card-in-card, one primary action per modal footer.

---

### Task 1: SQL migration for PayOS columns (defensive, idempotent)

**Files:**
- Create: `sql/migration_payos_config.sql`

- [ ] **Step 1: Write the migration script**

```sql
-- Migration: Cấu hình PayOS riêng theo từng Cơ Sở (Admin quản lý qua giao diện)
-- Chạy một lần trên DB thực. Script có kiểm tra IF NOT EXISTS nên an toàn khi chạy lại.
-- Nếu 3 cột này đã được thêm thủ công trước đó, script sẽ bỏ qua (không ghi đè).

USE QuanLiSport;
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'CoSo') AND name = N'PayOS_ClientID')
BEGIN
    ALTER TABLE CoSo ADD PayOS_ClientID NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột PayOS_ClientID vào CoSo.';
END
ELSE
    PRINT N'Cột PayOS_ClientID đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'CoSo') AND name = N'PayOS_ApiKey')
BEGIN
    ALTER TABLE CoSo ADD PayOS_ApiKey NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột PayOS_ApiKey vào CoSo.';
END
ELSE
    PRINT N'Cột PayOS_ApiKey đã tồn tại, bỏ qua.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'CoSo') AND name = N'PayOS_ChecksumKey')
BEGIN
    ALTER TABLE CoSo ADD PayOS_ChecksumKey NVARCHAR(500) NULL;
    PRINT N'Đã thêm cột PayOS_ChecksumKey vào CoSo.';
END
ELSE
    PRINT N'Cột PayOS_ChecksumKey đã tồn tại, bỏ qua.';
GO
```

- [ ] **Step 2: No execution here** — this sandbox has no live DB connection (`DB_URL`/`DB_USERNAME` are unset; the real SQL Server only exists on the user's Windows machine). Flag to the user in the final report: run this script once via SSMS/sqlcmd before testing, same as `migration_bank_transfer.sql` was run.

---

### Task 2: DTOs — `PayOSConfigState`, `PayOSCredentials`, `PayOSConfigurationStatus`, `PayOSConfigurationUpdateResult`

**Files:**
- Create: `src/main/java/org/example/dto/payment/PayOSConfigState.java`
- Create: `src/main/java/org/example/dto/payment/PayOSCredentials.java`
- Create: `src/main/java/org/example/dto/payment/PayOSConfigurationStatus.java`
- Create: `src/main/java/org/example/dto/payment/PayOSConfigurationUpdateResult.java`

**Interfaces:**
- Produces: `PayOSConfigState` enum (`NOT_CONFIGURED`, `PARTIAL`, `CONFIGURED`) with `fromRawValues(String,String,String)`.
- Produces: `PayOSCredentials(String clientId, String apiKey, String checksumKey)` — raw, internal-only, `toString()` redacted.
- Produces: `PayOSConfigurationStatus` — masked/boolean view safe to return to the frontend.
- Produces: `PayOSConfigurationUpdateResult` — `.ok(status, fieldsChanged)` / `.fail(httpStatus, message)`.

- [ ] **Step 1: Create `PayOSConfigState.java`**

```java
package org.example.dto.payment;

public enum PayOSConfigState {
    NOT_CONFIGURED,
    PARTIAL,
    CONFIGURED;

    public static PayOSConfigState fromRawValues(String clientId, String apiKey, String checksumKey) {
        int filled = 0;
        if (isFilled(clientId)) filled++;
        if (isFilled(apiKey)) filled++;
        if (isFilled(checksumKey)) filled++;
        if (filled == 0) return NOT_CONFIGURED;
        if (filled == 3) return CONFIGURED;
        return PARTIAL;
    }

    private static boolean isFilled(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
```

- [ ] **Step 2: Create `PayOSCredentials.java`**

```java
package org.example.dto.payment;

/**
 * DTO nội bộ chứa khóa PayOS thô của một Cơ Sở.
 * KHÔNG serialize ra JSON, KHÔNG log, KHÔNG trả về frontend.
 * getCredentialsForPayment() (PayOSConfigurationService) là nơi duy nhất
 * được phép đọc giá trị thật — chỉ dùng nội bộ tầng thanh toán backend.
 */
public final class PayOSCredentials {
    private final String clientId;
    private final String apiKey;
    private final String checksumKey;

    public PayOSCredentials(String clientId, String apiKey, String checksumKey) {
        this.clientId = clientId;
        this.apiKey = apiKey;
        this.checksumKey = checksumKey;
    }

    public String getClientId() { return clientId; }
    public String getApiKey() { return apiKey; }
    public String getChecksumKey() { return checksumKey; }

    public boolean isClientIdConfigured() { return isFilled(clientId); }
    public boolean isApiKeyConfigured() { return isFilled(apiKey); }
    public boolean isChecksumKeyConfigured() { return isFilled(checksumKey); }

    public PayOSConfigState toState() {
        return PayOSConfigState.fromRawValues(clientId, apiKey, checksumKey);
    }

    private static boolean isFilled(String value) {
        return value != null && !value.trim().isEmpty();
    }

    /** Không bao giờ in giá trị thật — chặn rò rỉ nếu vô tình bị log hoặc nối chuỗi. */
    @Override
    public String toString() {
        return "PayOSCredentials[REDACTED]";
    }
}
```

- [ ] **Step 3: Create `PayOSConfigurationStatus.java`**

```java
package org.example.dto.payment;

public final class PayOSConfigurationStatus {
    private final int coSoId;
    private final String coSoName;
    private final PayOSConfigState state;
    private final boolean clientIdConfigured;
    private final boolean apiKeyConfigured;
    private final boolean checksumKeyConfigured;
    private final String clientIdMasked;
    private final String apiKeyMasked;
    private final String checksumKeyMasked;
    private final String lastUpdatedAt;

    public PayOSConfigurationStatus(int coSoId, String coSoName, PayOSConfigState state,
                                     boolean clientIdConfigured, boolean apiKeyConfigured, boolean checksumKeyConfigured,
                                     String clientIdMasked, String apiKeyMasked, String checksumKeyMasked,
                                     String lastUpdatedAt) {
        this.coSoId = coSoId;
        this.coSoName = coSoName;
        this.state = state;
        this.clientIdConfigured = clientIdConfigured;
        this.apiKeyConfigured = apiKeyConfigured;
        this.checksumKeyConfigured = checksumKeyConfigured;
        this.clientIdMasked = clientIdMasked;
        this.apiKeyMasked = apiKeyMasked;
        this.checksumKeyMasked = checksumKeyMasked;
        this.lastUpdatedAt = lastUpdatedAt;
    }

    public int getCoSoId() { return coSoId; }
    public String getCoSoName() { return coSoName; }
    public PayOSConfigState getState() { return state; }
    public boolean isClientIdConfigured() { return clientIdConfigured; }
    public boolean isApiKeyConfigured() { return apiKeyConfigured; }
    public boolean isChecksumKeyConfigured() { return checksumKeyConfigured; }
    public String getClientIdMasked() { return clientIdMasked; }
    public String getApiKeyMasked() { return apiKeyMasked; }
    public String getChecksumKeyMasked() { return checksumKeyMasked; }
    public String getLastUpdatedAt() { return lastUpdatedAt; }
}
```

- [ ] **Step 4: Create `PayOSConfigurationUpdateResult.java`**

```java
package org.example.dto.payment;

import java.util.Collections;
import java.util.List;

public final class PayOSConfigurationUpdateResult {
    private final boolean success;
    private final int httpStatus;
    private final String message;
    private final PayOSConfigurationStatus status;
    private final List<String> fieldsChanged;

    private PayOSConfigurationUpdateResult(boolean success, int httpStatus, String message,
                                            PayOSConfigurationStatus status, List<String> fieldsChanged) {
        this.success = success;
        this.httpStatus = httpStatus;
        this.message = message;
        this.status = status;
        this.fieldsChanged = fieldsChanged;
    }

    public static PayOSConfigurationUpdateResult ok(PayOSConfigurationStatus status, List<String> fieldsChanged) {
        return new PayOSConfigurationUpdateResult(true, 200, "Đã cập nhật cấu hình PayOS.", status, fieldsChanged);
    }

    public static PayOSConfigurationUpdateResult fail(int httpStatus, String message) {
        return new PayOSConfigurationUpdateResult(false, httpStatus, message, null, Collections.emptyList());
    }

    public boolean isSuccess() { return success; }
    public int getHttpStatus() { return httpStatus; }
    public String getMessage() { return message; }
    public PayOSConfigurationStatus getStatus() { return status; }
    public List<String> getFieldsChanged() { return fieldsChanged; }
}
```

- [ ] **Step 5: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS (no other files reference these yet, so this just validates syntax).

---

### Task 3: `SecretMaskUtil` + unit test (TDD)

**Files:**
- Create: `src/main/java/org/example/util/SecretMaskUtil.java`
- Test: `src/test/java/org/example/util/SecretMaskUtilTest.java`

**Interfaces:**
- Produces: `SecretMaskUtil.mask(String value): String` — null/empty→null, len<=8→`"••••"`, len>8→first4+`"••••"`+last4.

- [ ] **Step 1: Write the failing test**

```java
package org.example.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class SecretMaskUtilTest {

    @Test
    void nullValue_returnsNull() {
        assertNull(SecretMaskUtil.mask(null));
    }

    @Test
    void emptyValue_returnsNull() {
        assertNull(SecretMaskUtil.mask(""));
    }

    @Test
    void shortValue_returnsFourDots() {
        assertEquals("••••", SecretMaskUtil.mask("abcd1234"));
    }

    @Test
    void longValue_masksMiddle() {
        assertEquals("abcd••••7890", SecretMaskUtil.mask("abcdef1234567890"));
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `mvn -q -Dtest=SecretMaskUtilTest test`
Expected: FAIL — compile error, `SecretMaskUtil` does not exist.

- [ ] **Step 3: Write the implementation**

```java
package org.example.util;

public final class SecretMaskUtil {
    private SecretMaskUtil() {}

    public static String mask(String value) {
        if (value == null || value.isEmpty()) return null;
        if (value.length() <= 8) return "••••";
        return value.substring(0, 4) + "••••" + value.substring(value.length() - 4);
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `mvn -q -Dtest=SecretMaskUtilTest test`
Expected: PASS, 4/4 tests green.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/SecretMaskUtil.java src/test/java/org/example/util/SecretMaskUtilTest.java
git commit -m "feat: add SecretMaskUtil for PayOS secret masking"
```

---

### Task 4: `PayOSConfigDAO` + `PayOSConfigDAOImpl` (raw JDBC)

**Files:**
- Create: `src/main/java/org/example/dao/PayOSConfigDAO.java`
- Create: `src/main/java/org/example/dao/impl/PayOSConfigDAOImpl.java`

**Interfaces:**
- Consumes: `PayOSCredentials` (Task 2), `PayOSConfigState` (Task 2), `DBUtil.getConnection()` (existing).
- Produces: `findPayOSConfigurationStatusByCoSoId(int)`, `updatePayOSConfiguration(int,String,String,String): boolean`, `getPayOSCredentialsForInternalUse(int)`, `findStatusForAllCoSo(): Map<Integer,PayOSConfigState>` — used by Task 8 (list page) and Task 6 (service).

- [ ] **Step 1: Create the interface**

```java
package org.example.dao;

import org.example.dto.payment.PayOSConfigState;
import org.example.dto.payment.PayOSCredentials;

import java.util.Map;

public interface PayOSConfigDAO {

    /** Đọc giá trị PayOS thô của một CoSo — null nếu CoSoID không tồn tại trong bảng CoSo. */
    PayOSCredentials findPayOSConfigurationStatusByCoSoId(int coSoId);

    /** Ghi 3 giá trị PayOS đã merge/validate (service layer chịu trách nhiệm merge). Trả về true nếu đúng 1 dòng bị ảnh hưởng. */
    boolean updatePayOSConfiguration(int coSoId, String clientId, String apiKey, String checksumKey);

    /** Chỉ dùng nội bộ cho tầng thanh toán backend — không expose qua servlet/API. */
    PayOSCredentials getPayOSCredentialsForInternalUse(int coSoId);

    /** Trạng thái PayOS cho toàn bộ CoSo chưa xóa mềm — dùng cho badge ở trang danh sách, tránh N+1 query. */
    Map<Integer, PayOSConfigState> findStatusForAllCoSo();
}
```

- [ ] **Step 2: Create the implementation**

```java
package org.example.dao.impl;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dao.PayOSConfigDAO;
import org.example.dto.payment.PayOSConfigState;
import org.example.dto.payment.PayOSCredentials;
import org.example.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class PayOSConfigDAOImpl implements PayOSConfigDAO {

    private static final Logger logger = LogManager.getLogger(PayOSConfigDAOImpl.class);

    private static final String SELECT_SQL =
            "SELECT PayOS_ClientID, PayOS_ApiKey, PayOS_ChecksumKey FROM CoSo WHERE CoSoID = ?";

    @Override
    public PayOSCredentials findPayOSConfigurationStatusByCoSoId(int coSoId) {
        return queryRawCredentials(coSoId);
    }

    @Override
    public PayOSCredentials getPayOSCredentialsForInternalUse(int coSoId) {
        return queryRawCredentials(coSoId);
    }

    private PayOSCredentials queryRawCredentials(int coSoId) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(SELECT_SQL)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new PayOSCredentials(
                        rs.getString("PayOS_ClientID"),
                        rs.getString("PayOS_ApiKey"),
                        rs.getString("PayOS_ChecksumKey"));
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi đọc cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            throw new IllegalStateException("Không thể đọc cấu hình PayOS.", e);
        }
    }

    @Override
    public boolean updatePayOSConfiguration(int coSoId, String clientId, String apiKey, String checksumKey) {
        String sql = "UPDATE CoSo SET PayOS_ClientID = ?, PayOS_ApiKey = ?, PayOS_ChecksumKey = ? WHERE CoSoID = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, clientId);
                ps.setString(2, apiKey);
                ps.setString(3, checksumKey);
                ps.setInt(4, coSoId);
                int affected = ps.executeUpdate();
                if (affected == 1) {
                    conn.commit();
                    return true;
                }
                conn.rollback();
                return false;
            } catch (SQLException e) {
                conn.rollback();
                logger.error("Lỗi khi cập nhật cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
                throw new IllegalStateException("Không thể cập nhật cấu hình PayOS.", e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            logger.error("Lỗi kết nối khi cập nhật cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            throw new IllegalStateException("Không thể cập nhật cấu hình PayOS.", e);
        }
    }

    @Override
    public Map<Integer, PayOSConfigState> findStatusForAllCoSo() {
        String sql = "SELECT CoSoID, PayOS_ClientID, PayOS_ApiKey, PayOS_ChecksumKey FROM CoSo " +
                "WHERE IsDeleted = 0 OR IsDeleted IS NULL";
        Map<Integer, PayOSConfigState> result = new HashMap<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int coSoId = rs.getInt("CoSoID");
                PayOSConfigState state = PayOSConfigState.fromRawValues(
                        rs.getString("PayOS_ClientID"),
                        rs.getString("PayOS_ApiKey"),
                        rs.getString("PayOS_ChecksumKey"));
                result.put(coSoId, state);
            }
        } catch (SQLException e) {
            logger.error("Lỗi khi tải trạng thái PayOS cho danh sách cơ sở: {}", e.getMessage());
        }
        return result;
    }
}
```

- [ ] **Step 3: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/dao/PayOSConfigDAO.java src/main/java/org/example/dao/impl/PayOSConfigDAOImpl.java
git commit -m "feat: add PayOSConfigDAO for per-CoSo PayOS credential storage"
```

---

### Task 5: `AuditLogService.ENTITY_PAYOS_CONFIG` constant

**Files:**
- Modify: `src/main/java/org/example/service/AuditLogService.java:51` (next to `ENTITY_CO_SO`)

- [ ] **Step 1: Add the constant**

```java
    public static final String ENTITY_CO_SO      = "CoSo";
    public static final String ENTITY_PAYOS_CONFIG = "PayOSConfig";
```

- [ ] **Step 2: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

---

### Task 6: `PayOSConfigurationService` with pure merge/validate logic + unit tests (TDD)

**Files:**
- Create: `src/main/java/org/example/service/PayOSConfigurationService.java`
- Test: `src/test/java/org/example/service/PayOSConfigurationServiceTest.java`

**Interfaces:**
- Consumes: `CoSoDAO`/`CoSoDAOImpl` (existing, `getCoSoById(int): CoSo`, `CoSo.isDeleted(): boolean`, `CoSo.getTenCoSo()`), `PayOSConfigDAO` (Task 4), `AuditLogDAO`/`AuditLogDAOImpl` (existing, `findWithFilters(...)`), `AuditLogService.log(req, actor, overrideCoSoId, action, entityType, entityId, entityName, details)` (existing overload), `SecretMaskUtil.mask` (Task 3).
- Produces: `getStatus(int): PayOSConfigurationStatus` (throws `PayOSConfigurationException` on not-found/invalid id), `updateConfiguration(int,String,String,String,HttpServletRequest,TaiKhoan): PayOSConfigurationUpdateResult`, `getCredentialsForPayment(int): PayOSCredentials` (nullable, internal-only — not called by any servlet in this task), package-private static `mergeAndValidate(PayOSCredentials,String,String,String): MergeOutcome` — the pure, unit-tested core.

- [ ] **Step 1: Write the failing tests for the pure merge/validate logic**

```java
package org.example.service;

import org.example.dto.payment.PayOSCredentials;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PayOSConfigurationServiceTest {

    private static final PayOSCredentials NOT_CONFIGURED = new PayOSCredentials(null, null, null);
    private static final PayOSCredentials FULLY_CONFIGURED =
            new PayOSCredentials("old-client", "old-api-key", "old-checksum");

    @Test
    void firstTimeConfig_missingField_isRejected() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(NOT_CONFIGURED, "new-client", "", "");
        assertFalse(outcome.valid);
        assertEquals("API Key không được để trống.", outcome.errorMessage);
    }

    @Test
    void firstTimeConfig_allThreeProvided_succeeds() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(NOT_CONFIGURED, "client-1", "api-1", "checksum-1");
        assertTrue(outcome.valid);
        assertEquals("client-1", outcome.finalClientId);
        assertEquals(List.of("CLIENT_ID", "API_KEY", "CHECKSUM_KEY"), outcome.fieldsChanged);
    }

    @Test
    void allFieldsBlank_keepsOldValues_noChange() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "", "", "");
        assertTrue(outcome.valid);
        assertEquals("old-client", outcome.finalClientId);
        assertEquals("old-api-key", outcome.finalApiKey);
        assertEquals("old-checksum", outcome.finalChecksumKey);
        assertTrue(outcome.fieldsChanged.isEmpty());
    }

    @Test
    void onlyApiKeyProvided_keepsOtherTwo() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "", "new-api-key", "");
        assertTrue(outcome.valid);
        assertEquals("old-client", outcome.finalClientId);
        assertEquals("new-api-key", outcome.finalApiKey);
        assertEquals("old-checksum", outcome.finalChecksumKey);
        assertEquals(List.of("API_KEY"), outcome.fieldsChanged);
    }

    @Test
    void maskedValueSubmitted_isRejected() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "abcd••••7890", "", "");
        assertFalse(outcome.valid);
    }

    @Test
    void controlCharacterSubmitted_isRejected() {
        PayOSConfigurationService.MergeOutcome outcome =
                PayOSConfigurationService.mergeAndValidate(FULLY_CONFIGURED, "line1\nline2", "", "");
        assertFalse(outcome.valid);
    }
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `mvn -q -Dtest=PayOSConfigurationServiceTest test`
Expected: FAIL — compile error, `PayOSConfigurationService` does not exist.

- [ ] **Step 3: Write the implementation**

```java
package org.example.service;

import jakarta.servlet.http.HttpServletRequest;
import org.example.dao.AuditLogDAO;
import org.example.dao.CoSoDAO;
import org.example.dao.PayOSConfigDAO;
import org.example.dao.impl.AuditLogDAOImpl;
import org.example.dao.impl.CoSoDAOImpl;
import org.example.dao.impl.PayOSConfigDAOImpl;
import org.example.dto.payment.PayOSConfigState;
import org.example.dto.payment.PayOSConfigurationStatus;
import org.example.dto.payment.PayOSConfigurationUpdateResult;
import org.example.dto.payment.PayOSCredentials;
import org.example.model.AuditLog;
import org.example.model.CoSo;
import org.example.model.TaiKhoan;
import org.example.util.SecretMaskUtil;

import java.util.ArrayList;
import java.util.List;

/**
 * Nghiệp vụ cấu hình PayOS riêng theo từng Cơ Sở (màn hình Admin).
 * getCredentialsForPayment() là điểm duy nhất trả khóa PayOS thô — chỉ được
 * gọi từ tầng thanh toán backend trong tương lai, KHÔNG được expose qua
 * servlet/API trong nhiệm vụ này.
 */
public class PayOSConfigurationService {

    public static final class PayOSConfigurationException extends RuntimeException {
        private final int httpStatus;

        public PayOSConfigurationException(int httpStatus, String message) {
            super(message);
            this.httpStatus = httpStatus;
        }

        public int getHttpStatus() { return httpStatus; }
    }

    private final CoSoDAO coSoDAO;
    private final PayOSConfigDAO payOSConfigDAO;
    private final AuditLogDAO auditLogDAO;

    public PayOSConfigurationService() {
        this(new CoSoDAOImpl(), new PayOSConfigDAOImpl(), new AuditLogDAOImpl());
    }

    PayOSConfigurationService(CoSoDAO coSoDAO, PayOSConfigDAO payOSConfigDAO, AuditLogDAO auditLogDAO) {
        this.coSoDAO = coSoDAO;
        this.payOSConfigDAO = payOSConfigDAO;
        this.auditLogDAO = auditLogDAO;
    }

    public PayOSConfigurationStatus getStatus(int coSoId) {
        CoSo coSo = loadActiveCoSoOrThrow(coSoId);
        PayOSCredentials raw = payOSConfigDAO.findPayOSConfigurationStatusByCoSoId(coSoId);
        if (raw == null) raw = new PayOSCredentials(null, null, null);
        return buildStatus(coSo, raw);
    }

    public PayOSConfigurationUpdateResult updateConfiguration(int coSoId, String newClientId, String newApiKey,
                                                                String newChecksumKey, HttpServletRequest req,
                                                                TaiKhoan admin) {
        CoSo coSo;
        try {
            coSo = loadActiveCoSoOrThrow(coSoId);
        } catch (PayOSConfigurationException e) {
            return PayOSConfigurationUpdateResult.fail(e.getHttpStatus(), e.getMessage());
        }

        PayOSCredentials current = payOSConfigDAO.findPayOSConfigurationStatusByCoSoId(coSoId);
        if (current == null) current = new PayOSCredentials(null, null, null);
        boolean wasConfiguredBefore = current.toState() != PayOSConfigState.NOT_CONFIGURED;

        MergeOutcome merged = mergeAndValidate(current, newClientId, newApiKey, newChecksumKey);
        if (!merged.valid) {
            return PayOSConfigurationUpdateResult.fail(400, merged.errorMessage);
        }
        if (merged.fieldsChanged.isEmpty()) {
            return PayOSConfigurationUpdateResult.ok(buildStatus(coSo, current), merged.fieldsChanged);
        }

        boolean updated = payOSConfigDAO.updatePayOSConfiguration(
                coSoId, merged.finalClientId, merged.finalApiKey, merged.finalChecksumKey);
        if (!updated) {
            return PayOSConfigurationUpdateResult.fail(500, "Không thể cập nhật cấu hình PayOS. Vui lòng thử lại.");
        }

        String action = wasConfiguredBefore ? AuditLogService.ACTION_UPDATE : AuditLogService.ACTION_CREATE;
        String details = "Admin cập nhật cấu hình PayOS cho cơ sở #" + coSoId +
                ". Fields changed: " + String.join(", ", merged.fieldsChanged) + ".";
        AuditLogService.log(req, admin, coSoId, action, AuditLogService.ENTITY_PAYOS_CONFIG,
                String.valueOf(coSoId), coSo.getTenCoSo(), details);

        PayOSCredentials finalRaw = new PayOSCredentials(merged.finalClientId, merged.finalApiKey, merged.finalChecksumKey);
        return PayOSConfigurationUpdateResult.ok(buildStatus(coSo, finalRaw), merged.fieldsChanged);
    }

    /** Chỉ dùng nội bộ tầng thanh toán backend. KHÔNG gọi từ servlet/API. */
    public PayOSCredentials getCredentialsForPayment(int coSoId) {
        CoSo coSo = coSoDAO.getCoSoById(coSoId);
        if (coSo == null || coSo.isDeleted()) return null;
        PayOSCredentials raw = payOSConfigDAO.getPayOSCredentialsForInternalUse(coSoId);
        if (raw == null || raw.toState() != PayOSConfigState.CONFIGURED) return null;
        return raw;
    }

    private CoSo loadActiveCoSoOrThrow(int coSoId) {
        if (coSoId <= 0) {
            throw new PayOSConfigurationException(400, "CoSoID không hợp lệ.");
        }
        CoSo coSo = coSoDAO.getCoSoById(coSoId);
        if (coSo == null || coSo.isDeleted()) {
            throw new PayOSConfigurationException(404, "Không tìm thấy cơ sở.");
        }
        return coSo;
    }

    private PayOSConfigurationStatus buildStatus(CoSo coSo, PayOSCredentials raw) {
        return new PayOSConfigurationStatus(
                coSo.getCoSoID(),
                coSo.getTenCoSo(),
                raw.toState(),
                raw.isClientIdConfigured(),
                raw.isApiKeyConfigured(),
                raw.isChecksumKeyConfigured(),
                SecretMaskUtil.mask(raw.getClientId()),
                SecretMaskUtil.mask(raw.getApiKey()),
                SecretMaskUtil.mask(raw.getChecksumKey()),
                fetchLastUpdatedAt(coSo.getCoSoID()));
    }

    private String fetchLastUpdatedAt(int coSoId) {
        try {
            List<AuditLog> logs = auditLogDAO.findWithFilters(
                    coSoId, AuditLogService.ENTITY_PAYOS_CONFIG, null, null, null, 1, 1);
            if (logs.isEmpty() || logs.get(0).getCreatedAt() == null) return null;
            return logs.get(0).getCreatedAt().toString();
        } catch (Exception e) {
            return null;
        }
    }

    // ═══ Pure merge/validate logic — unit-testable without a database ═══

    static final class MergeOutcome {
        final boolean valid;
        final String errorMessage;
        final String finalClientId;
        final String finalApiKey;
        final String finalChecksumKey;
        final List<String> fieldsChanged;

        private MergeOutcome(boolean valid, String errorMessage, String finalClientId, String finalApiKey,
                              String finalChecksumKey, List<String> fieldsChanged) {
            this.valid = valid;
            this.errorMessage = errorMessage;
            this.finalClientId = finalClientId;
            this.finalApiKey = finalApiKey;
            this.finalChecksumKey = finalChecksumKey;
            this.fieldsChanged = fieldsChanged;
        }

        static MergeOutcome invalid(String message) {
            return new MergeOutcome(false, message, null, null, null, List.of());
        }

        static MergeOutcome of(String clientId, String apiKey, String checksumKey, List<String> fieldsChanged) {
            return new MergeOutcome(true, null, clientId, apiKey, checksumKey, fieldsChanged);
        }
    }

    static MergeOutcome mergeAndValidate(PayOSCredentials current, String rawNewClientId,
                                          String rawNewApiKey, String rawNewChecksumKey) {
        String clientCheck = validateSubmittedField(rawNewClientId, "Client ID");
        if (clientCheck != null) return MergeOutcome.invalid(clientCheck);
        String apiCheck = validateSubmittedField(rawNewApiKey, "API Key");
        if (apiCheck != null) return MergeOutcome.invalid(apiCheck);
        String checksumCheck = validateSubmittedField(rawNewChecksumKey, "Checksum Key");
        if (checksumCheck != null) return MergeOutcome.invalid(checksumCheck);

        List<String> fieldsChanged = new ArrayList<>();
        String finalClientId = resolveField(current.getClientId(), rawNewClientId, "CLIENT_ID", fieldsChanged);
        String finalApiKey = resolveField(current.getApiKey(), rawNewApiKey, "API_KEY", fieldsChanged);
        String finalChecksumKey = resolveField(current.getChecksumKey(), rawNewChecksumKey, "CHECKSUM_KEY", fieldsChanged);

        if (isBlank(finalClientId)) return MergeOutcome.invalid("Client ID không được để trống.");
        if (isBlank(finalApiKey)) return MergeOutcome.invalid("API Key không được để trống.");
        if (isBlank(finalChecksumKey)) return MergeOutcome.invalid("Checksum Key không được để trống.");

        return MergeOutcome.of(finalClientId, finalApiKey, finalChecksumKey, fieldsChanged);
    }

    private static String resolveField(String currentValue, String rawNewValue, String fieldTag, List<String> fieldsChanged) {
        if (isBlank(rawNewValue)) {
            return currentValue;
        }
        String trimmed = rawNewValue.trim();
        if (!trimmed.equals(currentValue)) {
            fieldsChanged.add(fieldTag);
        }
        return trimmed;
    }

    /** null nếu hợp lệ (kể cả rỗng — rỗng nghĩa là giữ nguyên giá trị cũ); thông báo lỗi nếu không hợp lệ. */
    private static String validateSubmittedField(String rawValue, String fieldLabel) {
        if (isBlank(rawValue)) return null;
        String trimmed = rawValue.trim();
        if (trimmed.length() > 500) return fieldLabel + " quá dài.";
        if (containsControlChar(trimmed)) return fieldLabel + " chứa ký tự không hợp lệ.";
        if (looksLikePlaceholder(trimmed)) return fieldLabel + " không hợp lệ.";
        return null;
    }

    private static boolean containsControlChar(String value) {
        for (int i = 0; i < value.length(); i++) {
            if (Character.isISOControl(value.charAt(i))) return true;
        }
        return false;
    }

    private static boolean looksLikePlaceholder(String value) {
        if (value.contains("•")) return true;
        if (value.chars().allMatch(c -> c == '*')) return true;
        return value.equalsIgnoreCase("Đã cấu hình");
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `mvn -q -Dtest=PayOSConfigurationServiceTest test`
Expected: PASS, 6/6 tests green.

- [ ] **Step 5: Compile the full project**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 6: Commit**

```bash
git add src/main/java/org/example/service/AuditLogService.java \
        src/main/java/org/example/service/PayOSConfigurationService.java \
        src/test/java/org/example/service/PayOSConfigurationServiceTest.java
git commit -m "feat: add PayOSConfigurationService with pure merge/validate logic"
```

---

### Task 7: `FilterQuyenAdmin` JSON-403 for the PayOS API route

**Files:**
- Modify: `src/main/java/org/example/filter/FilterQuyenAdmin.java`

**Interfaces:**
- Consumes: nothing new.
- Produces: JSON `{"success":false,"message":"..."}` with HTTP 403 for unauthenticated or non-Admin requests to any path containing `/chi-nhanh/payos`. All other `/admin/*` paths keep existing `sendError`/redirect behavior — zero behavior change for the rest of the Admin Portal.

- [ ] **Step 1: Replace the filter body**

```java
package org.example.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.example.model.TaiKhoan;
import java.io.IOException;

/**
 * Filter đặc quyền cho Admin để bảo vệ các route /admin/*
 */
@WebFilter("/admin/*")
public class FilterQuyenAdmin implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean loggedIn = (session != null && session.getAttribute("user") != null);
        String path = httpRequest.getServletPath();
        boolean isJsonApiRoute = path.contains("/chi-nhanh/payos");

        if (loggedIn) {
            TaiKhoan user = (TaiKhoan) session.getAttribute("user");
            if (path.contains("/quan-ly-san") || path.contains("/QuanLySan.jsp")) {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Quản trị viên không có quyền quản lý sân (Chức năng này dành riêng cho Quản lý cơ sở).");
                return;
            }
            // Chỉ Role 1 (Admin) mới được vào vùng này
            if (user.getRoleId() == 1) {
                chain.doFilter(request, response);
            } else if (isJsonApiRoute) {
                writeForbiddenJson(httpResponse);
            } else {
                httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền Admin để truy cập chức năng này.");
            }
        } else if (isJsonApiRoute) {
            writeForbiddenJson(httpResponse);
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/dangnhap?admin=true");
        }
    }

    private void writeForbiddenJson(HttpServletResponse resp) throws IOException {
        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"success\":false,\"message\":\"Bạn không có quyền thực hiện thao tác này.\"}");
    }

    @Override
    public void destroy() {}
}
```

- [ ] **Step 2: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/filter/FilterQuyenAdmin.java
git commit -m "feat: return JSON 403 for unauthorized PayOS config API access"
```

---

### Task 8: `PayOSConfigAdminServlet` (GET/POST `/admin/chi-nhanh/payos`)

**Files:**
- Create: `src/main/java/org/example/controller/admin/PayOSConfigAdminServlet.java`

**Interfaces:**
- Consumes: `PayOSConfigurationService` (Task 6), Gson `JsonObject` (existing dependency, pattern from `HoaDonDetailServlet`/`FacilityTrashService`).
- Produces: `GET ?coSoId=N` → `{"success":true,"configuration":{...}}` or `{"success":false,"message":"..."}` with matching HTTP status. `POST` with `coSoId`, `clientId`, `apiKey`, `checksumKey` form params → same envelope shape, `message` set to the save confirmation on success.

- [ ] **Step 1: Create the servlet**

```java
package org.example.controller.admin;

import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.example.dto.payment.PayOSConfigurationStatus;
import org.example.dto.payment.PayOSConfigurationUpdateResult;
import org.example.model.TaiKhoan;
import org.example.service.PayOSConfigurationService;

import java.io.IOException;

@WebServlet(urlPatterns = { "/admin/chi-nhanh/payos" })
public class PayOSConfigAdminServlet extends HttpServlet {

    private static final Logger logger = LogManager.getLogger(PayOSConfigAdminServlet.class);
    private final PayOSConfigurationService payOSConfigurationService = new PayOSConfigurationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        if (coSoId == null) {
            writeJson(resp, 400, errorJson("CoSoID không hợp lệ."));
            return;
        }

        try {
            PayOSConfigurationStatus status = payOSConfigurationService.getStatus(coSoId);
            JsonObject body = new JsonObject();
            body.addProperty("success", true);
            body.add("configuration", toJson(status));
            writeJson(resp, 200, body);
        } catch (PayOSConfigurationService.PayOSConfigurationException e) {
            writeJson(resp, e.getHttpStatus(), errorJson(e.getMessage()));
        } catch (Exception e) {
            logger.error("Lỗi khi tải cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            writeJson(resp, 500, errorJson("Lỗi hệ thống khi tải cấu hình PayOS."));
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan admin = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (admin == null) {
            writeJson(resp, 403, errorJson("Bạn không có quyền thực hiện thao tác này."));
            return;
        }

        Integer coSoId = parseCoSoId(req.getParameter("coSoId"));
        if (coSoId == null) {
            writeJson(resp, 400, errorJson("CoSoID không hợp lệ."));
            return;
        }

        String clientId = req.getParameter("clientId");
        String apiKey = req.getParameter("apiKey");
        String checksumKey = req.getParameter("checksumKey");

        try {
            PayOSConfigurationUpdateResult result = payOSConfigurationService.updateConfiguration(
                    coSoId, clientId, apiKey, checksumKey, req, admin);

            if (!result.isSuccess()) {
                writeJson(resp, result.getHttpStatus(), errorJson(result.getMessage()));
                return;
            }

            JsonObject body = new JsonObject();
            body.addProperty("success", true);
            body.addProperty("message", result.getMessage());
            body.add("configuration", toJson(result.getStatus()));
            writeJson(resp, 200, body);
        } catch (Exception e) {
            logger.error("Lỗi khi cập nhật cấu hình PayOS cho CoSoID {}: {}", coSoId, e.getMessage());
            writeJson(resp, 500, errorJson("Lỗi hệ thống khi cập nhật cấu hình PayOS."));
        }
    }

    private JsonObject toJson(PayOSConfigurationStatus status) {
        JsonObject json = new JsonObject();
        json.addProperty("coSoId", status.getCoSoId());
        json.addProperty("coSoName", status.getCoSoName());
        json.addProperty("status", status.getState().name());
        json.addProperty("clientIdConfigured", status.isClientIdConfigured());
        json.addProperty("apiKeyConfigured", status.isApiKeyConfigured());
        json.addProperty("checksumKeyConfigured", status.isChecksumKeyConfigured());
        json.addProperty("clientIdMasked", status.getClientIdMasked());
        json.addProperty("apiKeyMasked", status.getApiKeyMasked());
        json.addProperty("checksumKeyMasked", status.getChecksumKeyMasked());
        json.addProperty("lastUpdatedAt", status.getLastUpdatedAt());
        return json;
    }

    private JsonObject errorJson(String message) {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("message", message);
        return json;
    }

    private void writeJson(HttpServletResponse resp, int httpStatus, JsonObject body) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setStatus(httpStatus);
        resp.getWriter().write(body.toString());
    }

    private Integer parseCoSoId(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        try {
            int value = Integer.parseInt(raw.trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
```

- [ ] **Step 2: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 3: Commit**

```bash
git add src/main/java/org/example/controller/admin/PayOSConfigAdminServlet.java
git commit -m "feat: add admin GET/POST endpoint for per-CoSo PayOS configuration"
```

---

### Task 9: Wire the status map into `QuanLyChiNhanhServlet`

**Files:**
- Modify: `src/main/java/org/example/controller/admin/QuanLyChiNhanhServlet.java`

**Interfaces:**
- Consumes: `PayOSConfigDAO.findStatusForAllCoSo()` (Task 4).
- Produces: request attribute `payosStatusMap` (`Map<Integer,PayOSConfigState>`) available to `QuanLyChiNhanh.jsp` (Task 10).

- [ ] **Step 1: Add imports and field** (near existing `chiNhanhDAO` field, line ~40)

```java
import org.example.dao.PayOSConfigDAO;
import org.example.dao.impl.PayOSConfigDAOImpl;
import org.example.dto.payment.PayOSConfigState;
import java.util.Map;
```

```java
    private final PayOSConfigDAO payOSConfigDAO = new PayOSConfigDAOImpl();
```

- [ ] **Step 2: Set the request attribute in the list branch** (`/admin/chi-nhanh` GET, around line 98)

Change:
```java
            List<CoSo> dsChiNhanh = chiNhanhDAO.getAllCoSo();
            req.setAttribute("dsChiNhanh", dsChiNhanh);
            req.getRequestDispatcher("/admin/QuanLyChiNhanh.jsp").forward(req, resp);
```
to:
```java
            List<CoSo> dsChiNhanh = chiNhanhDAO.getAllCoSo();
            Map<Integer, PayOSConfigState> payosStatusMap = payOSConfigDAO.findStatusForAllCoSo();
            req.setAttribute("dsChiNhanh", dsChiNhanh);
            req.setAttribute("payosStatusMap", payosStatusMap);
            req.getRequestDispatcher("/admin/QuanLyChiNhanh.jsp").forward(req, resp);
```

- [ ] **Step 3: Compile check**

Run: `mvn -q compile`
Expected: BUILD SUCCESS.

- [ ] **Step 4: Commit**

```bash
git add src/main/java/org/example/controller/admin/QuanLyChiNhanhServlet.java
git commit -m "feat: expose PayOS status map to the CoSo list JSP"
```

---

### Task 10: `QuanLyChiNhanh.jsp` — badge, "Cấu hình" button, modal, JS

**Files:**
- Modify: `src/main/webapp/admin/QuanLyChiNhanh.jsp`

- [ ] **Step 1: Add `.badge-gray` next to the existing badge classes** (in the `<style>` block, near `.badge-amber` at line 18)

```css
  .badge-gray   { background:#f4f4f5;color:#52525b; }
```

- [ ] **Step 2: Add the PayOS status row to each card**, inserted right before the existing `<!-- Action buttons -->` comment (around line 205), inside the `<c:forEach var="cn" ...>` loop:

```jsp
        <!-- PayOS status row -->
        <div class="flex items-center justify-between pt-1">
          <div class="flex items-center gap-1.5 text-xs">
            <i class="ti ti-credit-card text-sm text-zinc-400"></i>
            <span class="text-zinc-500">PayOS:</span>
            <c:choose>
              <c:when test="${payosStatusMap[cn.coSoID] == 'CONFIGURED'}">
                <span id="payosBadge${cn.coSoID}" class="badge badge-green">Đã cấu hình</span>
              </c:when>
              <c:when test="${payosStatusMap[cn.coSoID] == 'PARTIAL'}">
                <span id="payosBadge${cn.coSoID}" class="badge badge-amber">Thiếu thông tin</span>
              </c:when>
              <c:otherwise>
                <span id="payosBadge${cn.coSoID}" class="badge badge-gray">Chưa cấu hình</span>
              </c:otherwise>
            </c:choose>
          </div>
          <button type="button" onclick="openPayOSModal(${cn.coSoID}, '${cn.tenCoSo}')"
                  class="flex items-center gap-1 px-2.5 py-1 rounded-lg text-[11px] font-semibold text-zinc-600 bg-zinc-50 hover:bg-zinc-100 border border-zinc-200 transition-all">
            <i class="ti ti-settings text-xs"></i>Cấu hình
          </button>
        </div>
```

- [ ] **Step 3: Add the config modal markup**, right after the existing `<!-- ═══ Modal Sửa Cơ Sở ═══ -->` block closes (after the `</div>` that closes `id="modalSua"`, before `<!-- Custom Geolocation Modal -->`):

```jsp
<!-- ═══ Modal Cấu hình PayOS ═══ -->
<div id="modalPayOS" class="hidden fixed inset-0 z-[95] flex items-center justify-center p-4">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-sm" onclick="closePayOSModal()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[480px] flex flex-col">

    <div class="flex items-center justify-between px-6 py-4 border-b border-zinc-100 shrink-0">
      <div>
        <h3 class="text-base font-bold text-zinc-900">Cấu hình PayOS</h3>
        <p class="text-xs text-zinc-500 mt-0.5" id="payosModalSubtitle"></p>
      </div>
      <button type="button" id="payosCloseBtn" onclick="closePayOSModal()" class="p-1.5 rounded-lg hover:bg-zinc-100 text-zinc-400">
        <i class="ti ti-x text-lg"></i>
      </button>
    </div>

    <!-- LOADING state -->
    <div id="payosLoading" class="p-6 flex flex-col gap-3">
      <div class="h-10 rounded-xl bg-zinc-100 animate-pulse"></div>
      <div class="h-10 rounded-xl bg-zinc-100 animate-pulse"></div>
      <div class="h-10 rounded-xl bg-zinc-100 animate-pulse"></div>
    </div>

    <!-- EDITING / SAVING / ERROR states -->
    <form id="payosForm" class="hidden p-6 flex flex-col gap-4" onsubmit="return submitPayOSConfig(event)">
      <div id="payosFormError" class="hidden px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600 font-medium"></div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Client ID</label>
        <div class="relative">
          <input type="password" id="payosClientId" autocomplete="new-password"
                 class="payos-input h-10 w-full pl-3 pr-10 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
          <button type="button" onclick="togglePayOSVisibility('payosClientId')" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600">
            <i class="ti ti-eye text-base"></i>
          </button>
        </div>
        <p class="text-[11px] text-zinc-400" id="payosClientIdHint"></p>
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">API Key</label>
        <div class="relative">
          <input type="password" id="payosApiKey" autocomplete="new-password"
                 class="payos-input h-10 w-full pl-3 pr-10 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
          <button type="button" onclick="togglePayOSVisibility('payosApiKey')" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600">
            <i class="ti ti-eye text-base"></i>
          </button>
        </div>
        <p class="text-[11px] text-zinc-400" id="payosApiKeyHint"></p>
      </div>

      <div class="flex flex-col gap-1.5">
        <label class="text-xs font-semibold text-zinc-700">Checksum Key</label>
        <div class="relative">
          <input type="password" id="payosChecksumKey" autocomplete="new-password"
                 class="payos-input h-10 w-full pl-3 pr-10 rounded-xl border border-zinc-200 text-sm focus:border-blue-400 focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all font-medium">
          <button type="button" onclick="togglePayOSVisibility('payosChecksumKey')" class="absolute right-2.5 top-1/2 -translate-y-1/2 text-zinc-400 hover:text-zinc-600">
            <i class="ti ti-eye text-base"></i>
          </button>
        </div>
        <p class="text-[11px] text-zinc-400" id="payosChecksumKeyHint"></p>
      </div>

      <div class="flex justify-end gap-3 pt-2 border-t border-zinc-50">
        <button type="button" onclick="closePayOSModal()" id="payosCancelBtn" class="h-10 px-5 rounded-xl border border-zinc-200 text-sm font-bold text-zinc-600 hover:bg-zinc-50 transition-all">Hủy</button>
        <button type="submit" id="payosSaveBtn" class="h-10 px-6 rounded-xl bg-zinc-900 text-white text-sm font-bold hover:bg-zinc-800 transition-all shadow-lg shadow-zinc-900/10 flex items-center gap-2">
          <i class="ti ti-device-floppy text-sm"></i>Lưu cấu hình
        </button>
      </div>
    </form>

  </div>
</div>

<!-- Toast -->
<div id="payosToast" class="hidden fixed bottom-6 right-6 z-[110] px-4 py-3 rounded-xl bg-zinc-900 text-white text-sm font-semibold shadow-xl flex items-center gap-2">
  <i class="ti ti-circle-check text-emerald-400"></i>
  <span id="payosToastMsg"></span>
</div>
```

- [ ] **Step 4: Add the JS block**, appended at the end of the existing `<script>` block (right before `</script>`, after `finalValidateEdit()`):

```javascript
  // ═══════════ PAYOS CONFIG MODAL ═══════════
  let payosCurrentCoSoId = null;
  let payosSaving = false;

  function openPayOSModal(coSoId, coSoName) {
    payosCurrentCoSoId = coSoId;
    document.getElementById('payosModalSubtitle').textContent = coSoName + ' · Cơ sở #' + coSoId;
    document.getElementById('payosForm').classList.add('hidden');
    document.getElementById('payosLoading').classList.remove('hidden');
    document.getElementById('payosFormError').classList.add('hidden');
    ['payosClientId', 'payosApiKey', 'payosChecksumKey'].forEach(id => {
      const el = document.getElementById(id);
      el.value = '';
      el.type = 'password';
    });
    document.getElementById('modalPayOS').classList.remove('hidden');

    fetch('${pageContext.request.contextPath}/admin/chi-nhanh/payos?coSoId=' + coSoId)
      .then(r => r.json())
      .then(data => {
        document.getElementById('payosLoading').classList.add('hidden');
        document.getElementById('payosForm').classList.remove('hidden');
        if (!data.success) {
          showPayOSFormError(data.message || 'Không thể tải cấu hình PayOS.');
          return;
        }
        const cfg = data.configuration;
        setPayOSFieldHint('payosClientIdHint', cfg.clientIdConfigured, cfg.clientIdMasked);
        setPayOSFieldHint('payosApiKeyHint', cfg.apiKeyConfigured, cfg.apiKeyMasked);
        setPayOSFieldHint('payosChecksumKeyHint', cfg.checksumKeyConfigured, cfg.checksumKeyMasked);
        document.getElementById('payosClientId').placeholder = cfg.clientIdConfigured ? 'Đã cấu hình — để trống nếu không thay đổi' : 'Nhập Client ID';
        document.getElementById('payosApiKey').placeholder = cfg.apiKeyConfigured ? 'Đã cấu hình — để trống nếu không thay đổi' : 'Nhập API Key';
        document.getElementById('payosChecksumKey').placeholder = cfg.checksumKeyConfigured ? 'Đã cấu hình — để trống nếu không thay đổi' : 'Nhập Checksum Key';
      })
      .catch(() => {
        document.getElementById('payosLoading').classList.add('hidden');
        document.getElementById('payosForm').classList.remove('hidden');
        showPayOSFormError('Lỗi kết nối. Vui lòng thử lại.');
      });
  }

  function setPayOSFieldHint(hintId, configured, masked) {
    document.getElementById(hintId).textContent = configured ? ('Hiện tại: ' + masked) : 'Chưa cấu hình';
  }

  function togglePayOSVisibility(inputId) {
    const el = document.getElementById(inputId);
    el.type = el.type === 'password' ? 'text' : 'password';
  }

  function showPayOSFormError(msg) {
    const el = document.getElementById('payosFormError');
    el.textContent = msg;
    el.classList.remove('hidden');
  }

  function closePayOSModal() {
    if (payosSaving) return;
    document.getElementById('modalPayOS').classList.add('hidden');
    payosCurrentCoSoId = null;
  }

  function setPayOSFormDisabled(disabled) {
    document.getElementById('payosCancelBtn').disabled = disabled;
    document.getElementById('payosCloseBtn').disabled = disabled;
    document.querySelectorAll('.payos-input').forEach(i => i.disabled = disabled);
  }

  function submitPayOSConfig(event) {
    event.preventDefault();
    if (payosSaving) return false;
    payosSaving = true;

    document.getElementById('payosFormError').classList.add('hidden');
    const btn = document.getElementById('payosSaveBtn');
    const originalHtml = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<span class="animate-spin inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full"></span> Đang lưu...';
    setPayOSFormDisabled(true);

    const body = new URLSearchParams();
    body.set('coSoId', payosCurrentCoSoId);
    body.set('clientId', document.getElementById('payosClientId').value);
    body.set('apiKey', document.getElementById('payosApiKey').value);
    body.set('checksumKey', document.getElementById('payosChecksumKey').value);

    fetch('${pageContext.request.contextPath}/admin/chi-nhanh/payos', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: body.toString()
    })
      .then(r => r.json())
      .then(data => {
        payosSaving = false;
        btn.disabled = false;
        btn.innerHTML = originalHtml;
        setPayOSFormDisabled(false);

        if (!data.success) {
          showPayOSFormError(data.message || 'Không thể lưu cấu hình PayOS.');
          return;
        }
        updatePayOSBadge(payosCurrentCoSoId, data.configuration.status);
        showPayOSToast(data.message || 'Đã cập nhật cấu hình PayOS.');
        closePayOSModal();
      })
      .catch(() => {
        payosSaving = false;
        btn.disabled = false;
        btn.innerHTML = originalHtml;
        setPayOSFormDisabled(false);
        showPayOSFormError('Lỗi kết nối. Vui lòng thử lại.');
      });

    return false;
  }

  function updatePayOSBadge(coSoId, status) {
    const badge = document.getElementById('payosBadge' + coSoId);
    if (!badge) return;
    const cls = status === 'CONFIGURED' ? 'badge-green' : status === 'PARTIAL' ? 'badge-amber' : 'badge-gray';
    const label = status === 'CONFIGURED' ? 'Đã cấu hình' : status === 'PARTIAL' ? 'Thiếu thông tin' : 'Chưa cấu hình';
    badge.className = 'badge ' + cls;
    badge.textContent = label;
  }

  let payosToastTimer = null;
  function showPayOSToast(msg) {
    const toast = document.getElementById('payosToast');
    document.getElementById('payosToastMsg').textContent = msg;
    toast.classList.remove('hidden');
    clearTimeout(payosToastTimer);
    payosToastTimer = setTimeout(() => toast.classList.add('hidden'), 3000);
  }
```

- [ ] **Step 5: Static JS syntax check**

The JS lives inside JSP with EL expressions (`${pageContext.request.contextPath}`), so `node --check` cannot run directly against the `.jsp` file. Extract the `<script>` body to a scratch `.js` file with `${pageContext.request.contextPath}` replaced by an empty string literal, then run:

Run: `node --check /tmp/claude-1000/-home-nhan-Downloads-V-SPORT/*/scratchpad/payos-jsp-check.js`
Expected: no output (syntax OK).

- [ ] **Step 6: Commit**

```bash
git add src/main/webapp/admin/QuanLyChiNhanh.jsp
git commit -m "feat: add PayOS configuration modal to the Admin CoSo list"
```

---

### Task 11: Full build, static verification, and report

**Files:** none (verification only)

- [ ] **Step 1: Full compile + test + package**

Run: `mvn -q -DskipTests=false clean package`
Expected: BUILD SUCCESS, all unit tests green (`SecretMaskUtilTest`, `PayOSConfigurationServiceTest`, plus the pre-existing `CourtPricingServiceTest`), WAR produced under `target/`.

- [ ] **Step 2: Trace every one of the 15 spec test cases against the code** (manual code-reading verification — no live DB/Tomcat/browser available in this sandbox) and record which are proven by unit test vs. proven by code inspection vs. require the user's own manual pass with `.\start_server.bat` on their Windows machine.

- [ ] **Step 3: Report to the user** per the structure in the task prompt (module extended, routes, service/DAO, secret-safety mechanism, merge rule, masking, authZ, audit log, files touched, per-test result, build result, next steps for Manager/Staff PayOS integration) — explicitly flagging that DB/browser-level tests (1, 3, 4, 8–15 in their live-server form) need the user to run `.\start_server.bat` and the SQL migration first, since this sandbox has no Windows/Tomcat/MSSQL access.
