# Face Attendance Anti-Spoofing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Thêm điểm danh khuôn mặt với active liveness detection (chống ảnh tĩnh, video, ảnh in) cho role GUARD (5) và STAFF/LE_TAN (4), cấu hình bật/tắt per-branch.

**Architecture:** Browser dùng face-api.js để thực hiện liveness challenge ngẫu nhiên (blink/turn_left/turn_right/smile), extract 128-float descriptor, gửi lên Java server. Server validate challenge token (TTL 3 phút, 1-time-use), tính Euclidean distance vs descriptor đã enroll, ghi audit đầy đủ (timestamp + ảnh + confidence + liveness result). Không cần server Python hay cloud API — hoàn toàn self-hosted.

**Tech Stack:** Java Servlet (Jakarta EE 6), JSP + JSTL, Tailwind CSS CDN, face-api.js 0.22.2 CDN, SQL Server (mssql-jdbc), Gson 2.10.1.

## Global Constraints

- Role constants: `ROLE_BAO_VE = 5`, `ROLE_LE_TAN = 4`, `ROLE_MANAGER = 2` (từ `Constants.java`)
- Upload path pattern: `getServletContext().getRealPath("/uploads/X")` với fallback `new File(System.getProperty("user.home"), "v-sport/uploads/X")`
- Session user object: `(TaiKhoan) session.getAttribute("user")`, lấy `user.getAccountId()`, `user.getRoleId()`, `user.getCoSoId()`
- JSON response: dùng `Gson` (`new Gson().toJson(map)`), set `resp.setContentType("application/json;charset=UTF-8")`
- CSRF: guard_head.jsp và staff head tự inject `_csrf` vào form POST — servlet đọc `req.getParameter("_csrf")`
- face-api.js CDN: `https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js`
- Face descriptor threshold: `0.6` (Euclidean distance — tiêu chuẩn face-api.js)
- Challenge TTL: 180 giây

---

## File Map

### Tạo mới
| File | Mục đích |
|------|----------|
| `src/main/webapp/assets/face-models/` | Thư mục chứa face-api.js model weights |
| `src/main/java/org/example/model/FaceChallengeToken.java` | Model cho challenge token |
| `src/main/java/org/example/model/CoSoFaceConfig.java` | Model cấu hình face per-branch |
| `src/main/java/org/example/dao/FaceChallengeTokenDAO.java` | Interface DAO |
| `src/main/java/org/example/dao/CoSoFaceConfigDAO.java` | Interface DAO |
| `src/main/java/org/example/dao/impl/FaceChallengeTokenDAOImpl.java` | Impl |
| `src/main/java/org/example/dao/impl/CoSoFaceConfigDAOImpl.java` | Impl |
| `src/main/java/org/example/controller/face/FaceChallengeServlet.java` | GET /face/challenge |
| `src/main/java/org/example/controller/face/FaceEnrollServlet.java` | POST /face/enroll |
| `src/main/java/org/example/controller/face/FaceCheckInServlet.java` | POST /face/checkin |
| `src/main/java/org/example/controller/face/FaceCheckOutServlet.java` | POST /face/checkout |
| `src/main/java/org/example/controller/manager/FaceSettingsServlet.java` | GET/POST /manager/face-settings |
| `src/main/webapp/assets/js/face-attendance.js` | Client JS orchestration |
| `src/main/webapp/guard/FaceEnroll.jsp` | Self-enroll UI cho guard |
| `src/main/webapp/staff/FaceEnroll.jsp` | Self-enroll UI cho staff |
| `src/main/webapp/manager/FaceSettings.jsp` | Trang cài đặt face per-branch |

### Sửa đổi
| File | Thay đổi |
|------|---------|
| `src/main/java/org/example/model/TaiKhoan.java` | Thêm 3 field face |
| `src/main/java/org/example/model/CaLamViec.java` | Thêm 4 field face audit |
| `src/main/java/org/example/dao/TaiKhoanDAO.java` | Thêm 2 method face |
| `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java` | Impl 2 method face |
| `src/main/java/org/example/dao/CaLamViecDAO.java` | Thêm method faceCheckIn/faceCheckOut |
| `src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java` | Impl faceCheckIn/faceCheckOut |
| `src/main/webapp/guard/DiemDanh.jsp` | Thêm face modal + nút |
| `src/main/webapp/staff/CaLamViec.jsp` | Thêm face checkin/checkout modal |
| `src/main/webapp/manager/NhanSu.jsp` | Thêm upload ảnh khuôn mặt + xem trạng thái |
| `src/main/webapp/guard/common/sidebar.jsp` | Thêm link "Đăng ký khuôn mặt" |
| `src/main/webapp/staff/common/header.jsp` | Thêm link "Đăng ký khuôn mặt" |

---

## Task 1: Database Migration

**Files:**
- Create: `src/main/resources/migration_face_attendance.sql`

**Interfaces:**
- Produces: bảng `CoSoFaceConfig`, `FaceChallengeToken`; các cột mới trong `TaiKhoan`, `CaLamViec`

- [ ] **Step 1: Tạo file SQL migration**

```sql
-- migration_face_attendance.sql
-- Bước 1: Thêm cột face vào TaiKhoan
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('TaiKhoan') AND name='FaceDescriptor')
    ALTER TABLE TaiKhoan ADD FaceDescriptor NVARCHAR(MAX) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('TaiKhoan') AND name='FaceImagePath')
    ALTER TABLE TaiKhoan ADD FaceImagePath NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('TaiKhoan') AND name='FaceEnrolledAt')
    ALTER TABLE TaiKhoan ADD FaceEnrolledAt DATETIME NULL;

-- Bước 2: Thêm cột face audit vào CaLamViec
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceVerified')
    ALTER TABLE CaLamViec ADD FaceVerified BIT NOT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceCheckInImage')
    ALTER TABLE CaLamViec ADD FaceCheckInImage NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceConfidence')
    ALTER TABLE CaLamViec ADD FaceConfidence FLOAT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceLivenessPassed')
    ALTER TABLE CaLamViec ADD FaceLivenessPassed BIT NOT NULL DEFAULT 0;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceCheckOutImage')
    ALTER TABLE CaLamViec ADD FaceCheckOutImage NVARCHAR(500) NULL;
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=OBJECT_ID('CaLamViec') AND name='FaceCheckOutConfidence')
    ALTER TABLE CaLamViec ADD FaceCheckOutConfidence FLOAT NULL;

-- Bước 3: Tạo bảng CoSoFaceConfig
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type='U' AND name='CoSoFaceConfig')
CREATE TABLE CoSoFaceConfig (
    CoSoID        INT PRIMARY KEY,
    FaceRequired  BIT NOT NULL DEFAULT 0,
    ConfidenceMin FLOAT NOT NULL DEFAULT 0.6,
    UpdatedAt     DATETIME NULL,
    CONSTRAINT FK_FaceConfig_CoSo FOREIGN KEY (CoSoID) REFERENCES CoSo(CoSoID)
);

-- Bước 4: Tạo bảng FaceChallengeToken
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE type='U' AND name='FaceChallengeToken')
CREATE TABLE FaceChallengeToken (
    TokenID    VARCHAR(64)   PRIMARY KEY,
    AccountID  INT           NOT NULL,
    CaLamViecID INT          NOT NULL,
    Action     VARCHAR(10)   NOT NULL DEFAULT 'checkin',  -- 'checkin' hoặc 'checkout'
    Challenges NVARCHAR(200) NOT NULL,   -- JSON: ["blink","turn_left"]
    CreatedAt  DATETIME      NOT NULL DEFAULT GETDATE(),
    ExpiresAt  DATETIME      NOT NULL,
    UsedAt     DATETIME      NULL,
    CONSTRAINT FK_FaceToken_TaiKhoan FOREIGN KEY (AccountID) REFERENCES TaiKhoan(AccountID)
);
```

- [ ] **Step 2: Chạy migration trên SQL Server**

Mở SQL Server Management Studio hoặc dùng sqlcmd:
```bash
sqlcmd -S localhost -d VsportDB -U sa -P yourpassword -i src/main/resources/migration_face_attendance.sql
```
Kiểm tra: `SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='TaiKhoan' AND COLUMN_NAME LIKE 'Face%'` → phải trả về 3 dòng.

- [ ] **Step 3: Commit**
```bash
git add src/main/resources/migration_face_attendance.sql
git commit -m "feat(face): DB migration - thêm cột face và bảng config/token"
```

---

## Task 2: Download face-api.js Models

**Files:**
- Create: `src/main/webapp/assets/face-models/` (thư mục chứa 3 model)

**Interfaces:**
- Produces: URL `/assets/face-models/tiny_face_detector_model-weights_manifest.json` và các shard, landmark, recognition models

- [ ] **Step 1: Tạo thư mục và download models**

```bash
mkdir -p src/main/webapp/assets/face-models

# Tiny Face Detector (detect khuôn mặt, nhẹ ~190KB)
BASE=https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights
cd src/main/webapp/assets/face-models

curl -O $BASE/tiny_face_detector_model-weights_manifest.json
curl -O $BASE/tiny_face_detector_model-shard1

# Face Landmark 68 tiny (detect 68 điểm cho liveness, ~80KB)
curl -O $BASE/face_landmark_68_tiny_model-weights_manifest.json
curl -O $BASE/face_landmark_68_tiny_model-shard1

# Face Recognition (extract 128-float descriptor, ~6.2MB)
curl -O $BASE/face_recognition_model-weights_manifest.json
curl -O $BASE/face_recognition_model-shard1
curl -O $BASE/face_recognition_model-shard2

cd -
```

- [ ] **Step 2: Kiểm tra files tồn tại**
```bash
ls -lh src/main/webapp/assets/face-models/
# Phải thấy 8 files tổng ~6.5MB
```

- [ ] **Step 3: Commit**
```bash
git add src/main/webapp/assets/face-models/
git commit -m "feat(face): thêm face-api.js model weights (tiny detector + landmarks + recognition)"
```

---

## Task 3: Model Classes + DAO Layer

**Files:**
- Create: `src/main/java/org/example/model/FaceChallengeToken.java`
- Create: `src/main/java/org/example/model/CoSoFaceConfig.java`
- Modify: `src/main/java/org/example/model/TaiKhoan.java`
- Modify: `src/main/java/org/example/model/CaLamViec.java`
- Create: `src/main/java/org/example/dao/FaceChallengeTokenDAO.java`
- Create: `src/main/java/org/example/dao/CoSoFaceConfigDAO.java`
- Create: `src/main/java/org/example/dao/impl/FaceChallengeTokenDAOImpl.java`
- Create: `src/main/java/org/example/dao/impl/CoSoFaceConfigDAOImpl.java`
- Modify: `src/main/java/org/example/dao/TaiKhoanDAO.java`
- Modify: `src/main/java/org/example/dao/impl/TaiKhoanDAOImpl.java`
- Modify: `src/main/java/org/example/dao/CaLamViecDAO.java`
- Modify: `src/main/java/org/example/dao/impl/CaLamViecDAOImpl.java`

**Interfaces:**
- Produces:
  - `FaceChallengeToken`: fields tokenId, accountId, caLamViecId, action, challenges, createdAt, expiresAt, usedAt
  - `CoSoFaceConfig`: fields coSoId, faceRequired, confidenceMin, updatedAt
  - `TaiKhoan`: thêm faceDescriptor (String JSON), faceImagePath, faceEnrolledAt
  - `CaLamViec`: thêm faceVerified, faceCheckInImage, faceConfidence, faceLivenessPassed, faceCheckOutImage, faceCheckOutConfidence
  - `FaceChallengeTokenDAO.insert(token)`, `.findById(tokenId)`, `.markUsed(tokenId)`, `.deleteExpired()`
  - `CoSoFaceConfigDAO.findByCoSo(coSoId)`, `.upsert(config)`
  - `TaiKhoanDAO.updateFaceData(accountId, descriptorJson, imagePath)`, `.getFaceData(accountId)` trả về `TaiKhoan` (chỉ face fields)
  - `CaLamViecDAO.faceCheckIn(caId, imagePath, confidence, livenessPassed)`, `.faceCheckOut(caId, imagePath, confidence)`

- [ ] **Step 1: Tạo FaceChallengeToken.java**

```java
// src/main/java/org/example/model/FaceChallengeToken.java
package org.example.model;

import java.time.LocalDateTime;

public class FaceChallengeToken {
    private String tokenId;
    private int accountId;
    private int caLamViecId;
    private String action; // "checkin" hoặc "checkout"
    private String challenges; // JSON string: ["blink","turn_left"]
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private LocalDateTime usedAt;

    public String getTokenId() { return tokenId; }
    public void setTokenId(String tokenId) { this.tokenId = tokenId; }
    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
    public int getCaLamViecId() { return caLamViecId; }
    public void setCaLamViecId(int caLamViecId) { this.caLamViecId = caLamViecId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public String getChallenges() { return challenges; }
    public void setChallenges(String challenges) { this.challenges = challenges; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getExpiresAt() { return expiresAt; }
    public void setExpiresAt(LocalDateTime expiresAt) { this.expiresAt = expiresAt; }
    public LocalDateTime getUsedAt() { return usedAt; }
    public void setUsedAt(LocalDateTime usedAt) { this.usedAt = usedAt; }

    public boolean isExpired() {
        return expiresAt != null && LocalDateTime.now().isAfter(expiresAt);
    }
    public boolean isUsed() {
        return usedAt != null;
    }
}
```

- [ ] **Step 2: Tạo CoSoFaceConfig.java**

```java
// src/main/java/org/example/model/CoSoFaceConfig.java
package org.example.model;

import java.time.LocalDateTime;

public class CoSoFaceConfig {
    private int coSoId;
    private boolean faceRequired;
    private double confidenceMin; // 0.0 - 1.0, default 0.6
    private LocalDateTime updatedAt;

    public int getCoSoId() { return coSoId; }
    public void setCoSoId(int coSoId) { this.coSoId = coSoId; }
    public boolean isFaceRequired() { return faceRequired; }
    public void setFaceRequired(boolean faceRequired) { this.faceRequired = faceRequired; }
    public double getConfidenceMin() { return confidenceMin; }
    public void setConfidenceMin(double confidenceMin) { this.confidenceMin = confidenceMin; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
```

- [ ] **Step 3: Thêm face fields vào TaiKhoan.java**

Mở `src/main/java/org/example/model/TaiKhoan.java`, thêm sau các field hiện có:

```java
// Thêm vào phần fields
private String faceDescriptor;  // JSON array 128 floats
private String faceImagePath;
private java.time.LocalDateTime faceEnrolledAt;

// Thêm getters/setters
public String getFaceDescriptor() { return faceDescriptor; }
public void setFaceDescriptor(String faceDescriptor) { this.faceDescriptor = faceDescriptor; }
public String getFaceImagePath() { return faceImagePath; }
public void setFaceImagePath(String faceImagePath) { this.faceImagePath = faceImagePath; }
public java.time.LocalDateTime getFaceEnrolledAt() { return faceEnrolledAt; }
public void setFaceEnrolledAt(java.time.LocalDateTime faceEnrolledAt) { this.faceEnrolledAt = faceEnrolledAt; }
public boolean isFaceEnrolled() { return faceDescriptor != null && !faceDescriptor.isEmpty(); }
```

- [ ] **Step 4: Thêm face fields vào CaLamViec.java**

Mở `src/main/java/org/example/model/CaLamViec.java`, thêm sau các field hiện có:

```java
// Fields
private boolean faceVerified;
private String faceCheckInImage;
private Double faceConfidence;
private boolean faceLivenessPassed;
private String faceCheckOutImage;
private Double faceCheckOutConfidence;

// Getters/Setters
public boolean isFaceVerified() { return faceVerified; }
public void setFaceVerified(boolean faceVerified) { this.faceVerified = faceVerified; }
public String getFaceCheckInImage() { return faceCheckInImage; }
public void setFaceCheckInImage(String faceCheckInImage) { this.faceCheckInImage = faceCheckInImage; }
public Double getFaceConfidence() { return faceConfidence; }
public void setFaceConfidence(Double faceConfidence) { this.faceConfidence = faceConfidence; }
public boolean isFaceLivenessPassed() { return faceLivenessPassed; }
public void setFaceLivenessPassed(boolean faceLivenessPassed) { this.faceLivenessPassed = faceLivenessPassed; }
public String getFaceCheckOutImage() { return faceCheckOutImage; }
public void setFaceCheckOutImage(String faceCheckOutImage) { this.faceCheckOutImage = faceCheckOutImage; }
public Double getFaceCheckOutConfidence() { return faceCheckOutConfidence; }
public void setFaceCheckOutConfidence(Double faceCheckOutConfidence) { this.faceCheckOutConfidence = faceCheckOutConfidence; }
```

- [ ] **Step 5: Tạo FaceChallengeTokenDAO interface**

```java
// src/main/java/org/example/dao/FaceChallengeTokenDAO.java
package org.example.dao;

import org.example.model.FaceChallengeToken;

public interface FaceChallengeTokenDAO {
    void insert(FaceChallengeToken token);
    FaceChallengeToken findById(String tokenId);
    void markUsed(String tokenId);
    void deleteExpired();
}
```

- [ ] **Step 6: Tạo CoSoFaceConfigDAO interface**

```java
// src/main/java/org/example/dao/CoSoFaceConfigDAO.java
package org.example.dao;

import org.example.model.CoSoFaceConfig;

public interface CoSoFaceConfigDAO {
    CoSoFaceConfig findByCoSo(int coSoId);
    void upsert(CoSoFaceConfig config);
}
```

- [ ] **Step 7: Tạo FaceChallengeTokenDAOImpl.java**

```java
// src/main/java/org/example/dao/impl/FaceChallengeTokenDAOImpl.java
package org.example.dao.impl;

import org.example.dao.FaceChallengeTokenDAO;
import org.example.model.FaceChallengeToken;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;

public class FaceChallengeTokenDAOImpl implements FaceChallengeTokenDAO {

    @Override
    public void insert(FaceChallengeToken token) {
        String sql = "INSERT INTO FaceChallengeToken (TokenID, AccountID, CaLamViecID, Action, Challenges, CreatedAt, ExpiresAt) VALUES (?,?,?,?,?,?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, token.getTokenId());
            ps.setInt(2, token.getAccountId());
            ps.setInt(3, token.getCaLamViecId());
            ps.setString(4, token.getAction());
            ps.setString(5, token.getChallenges());
            ps.setTimestamp(6, Timestamp.valueOf(token.getCreatedAt()));
            ps.setTimestamp(7, Timestamp.valueOf(token.getExpiresAt()));
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("insert FaceChallengeToken failed", e);
        }
    }

    @Override
    public FaceChallengeToken findById(String tokenId) {
        String sql = "SELECT * FROM FaceChallengeToken WHERE TokenID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("findById FaceChallengeToken failed", e);
        }
        return null;
    }

    @Override
    public void markUsed(String tokenId) {
        String sql = "UPDATE FaceChallengeToken SET UsedAt=GETDATE() WHERE TokenID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tokenId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("markUsed FaceChallengeToken failed", e);
        }
    }

    @Override
    public void deleteExpired() {
        String sql = "DELETE FROM FaceChallengeToken WHERE ExpiresAt < GETDATE()";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("deleteExpired FaceChallengeToken failed", e);
        }
    }

    private FaceChallengeToken map(ResultSet rs) throws SQLException {
        FaceChallengeToken t = new FaceChallengeToken();
        t.setTokenId(rs.getString("TokenID"));
        t.setAccountId(rs.getInt("AccountID"));
        t.setCaLamViecId(rs.getInt("CaLamViecID"));
        t.setAction(rs.getString("Action"));
        t.setChallenges(rs.getString("Challenges"));
        Timestamp created = rs.getTimestamp("CreatedAt");
        if (created != null) t.setCreatedAt(created.toLocalDateTime());
        Timestamp expires = rs.getTimestamp("ExpiresAt");
        if (expires != null) t.setExpiresAt(expires.toLocalDateTime());
        Timestamp used = rs.getTimestamp("UsedAt");
        if (used != null) t.setUsedAt(used.toLocalDateTime());
        return t;
    }
}
```

- [ ] **Step 8: Tạo CoSoFaceConfigDAOImpl.java**

```java
// src/main/java/org/example/dao/impl/CoSoFaceConfigDAOImpl.java
package org.example.dao.impl;

import org.example.dao.CoSoFaceConfigDAO;
import org.example.model.CoSoFaceConfig;
import org.example.util.DBUtil;

import java.sql.*;
import java.time.LocalDateTime;

public class CoSoFaceConfigDAOImpl implements CoSoFaceConfigDAO {

    @Override
    public CoSoFaceConfig findByCoSo(int coSoId) {
        String sql = "SELECT * FROM CoSoFaceConfig WHERE CoSoID=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, coSoId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CoSoFaceConfig cfg = new CoSoFaceConfig();
                    cfg.setCoSoId(rs.getInt("CoSoID"));
                    cfg.setFaceRequired(rs.getBoolean("FaceRequired"));
                    cfg.setConfidenceMin(rs.getDouble("ConfidenceMin"));
                    Timestamp ts = rs.getTimestamp("UpdatedAt");
                    if (ts != null) cfg.setUpdatedAt(ts.toLocalDateTime());
                    return cfg;
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("findByCoSo CoSoFaceConfig failed", e);
        }
        // Trả về config mặc định nếu chưa cài đặt
        CoSoFaceConfig def = new CoSoFaceConfig();
        def.setCoSoId(coSoId);
        def.setFaceRequired(false);
        def.setConfidenceMin(0.6);
        return def;
    }

    @Override
    public void upsert(CoSoFaceConfig config) {
        String sql = "MERGE CoSoFaceConfig AS target " +
                "USING (VALUES (?,?,?,GETDATE())) AS source (CoSoID, FaceRequired, ConfidenceMin, UpdatedAt) " +
                "ON target.CoSoID = source.CoSoID " +
                "WHEN MATCHED THEN UPDATE SET FaceRequired=source.FaceRequired, ConfidenceMin=source.ConfidenceMin, UpdatedAt=source.UpdatedAt " +
                "WHEN NOT MATCHED THEN INSERT (CoSoID, FaceRequired, ConfidenceMin, UpdatedAt) VALUES (source.CoSoID, source.FaceRequired, source.ConfidenceMin, source.UpdatedAt);";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, config.getCoSoId());
            ps.setBoolean(2, config.isFaceRequired());
            ps.setDouble(3, config.getConfidenceMin());
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("upsert CoSoFaceConfig failed", e);
        }
    }
}
```

- [ ] **Step 9: Thêm 2 method vào TaiKhoanDAO interface**

```java
// Thêm vào TaiKhoanDAO.java
void updateFaceData(int accountId, String descriptorJson, String imagePath);
TaiKhoan getFaceData(int accountId); // chỉ load accountId, faceDescriptor, faceImagePath, faceEnrolledAt
```

- [ ] **Step 10: Implement trong TaiKhoanDAOImpl.java**

```java
@Override
public void updateFaceData(int accountId, String descriptorJson, String imagePath) {
    String sql = "UPDATE TaiKhoan SET FaceDescriptor=?, FaceImagePath=?, FaceEnrolledAt=GETDATE() WHERE AccountID=?";
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, descriptorJson);
        ps.setString(2, imagePath);
        ps.setInt(3, accountId);
        ps.executeUpdate();
    } catch (SQLException e) {
        throw new RuntimeException("updateFaceData failed", e);
    }
}

@Override
public TaiKhoan getFaceData(int accountId) {
    String sql = "SELECT AccountID, FaceDescriptor, FaceImagePath, FaceEnrolledAt FROM TaiKhoan WHERE AccountID=?";
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, accountId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                TaiKhoan tk = new TaiKhoan();
                tk.setAccountId(rs.getInt("AccountID"));
                tk.setFaceDescriptor(rs.getString("FaceDescriptor"));
                tk.setFaceImagePath(rs.getString("FaceImagePath"));
                Timestamp ts = rs.getTimestamp("FaceEnrolledAt");
                if (ts != null) tk.setFaceEnrolledAt(ts.toLocalDateTime());
                return tk;
            }
        }
    } catch (SQLException e) {
        throw new RuntimeException("getFaceData failed", e);
    }
    return null;
}
```

- [ ] **Step 11: Thêm method vào CaLamViecDAO interface**

```java
// Thêm vào CaLamViecDAO.java
boolean faceCheckIn(int caLamViecId, String imagePath, double confidence, boolean livenessPassed);
boolean faceCheckOut(int caLamViecId, String imagePath, double confidence);
```

- [ ] **Step 12: Implement trong CaLamViecDAOImpl.java**

```java
@Override
public boolean faceCheckIn(int caLamViecId, String imagePath, double confidence, boolean livenessPassed) {
    String sql = "UPDATE CaLamViec SET GioVaoThuc=GETDATE(), TrangThai='CheckedIn', " +
                 "FaceVerified=1, FaceCheckInImage=?, FaceConfidence=?, FaceLivenessPassed=? " +
                 "WHERE CaLamViecID=? AND GioVaoThuc IS NULL";
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, imagePath);
        ps.setDouble(2, confidence);
        ps.setBoolean(3, livenessPassed);
        ps.setInt(4, caLamViecId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        logger.error("faceCheckIn failed", e);
        return false;
    }
}

@Override
public boolean faceCheckOut(int caLamViecId, String imagePath, double confidence) {
    String sql = "UPDATE CaLamViec SET GioRaThuc=GETDATE(), TrangThai='CheckedOut', " +
                 "FaceCheckOutImage=?, FaceCheckOutConfidence=? " +
                 "WHERE CaLamViecID=? AND GioVaoThuc IS NOT NULL AND GioRaThuc IS NULL";
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, imagePath);
        ps.setDouble(2, confidence);
        ps.setInt(3, caLamViecId);
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        logger.error("faceCheckOut failed", e);
        return false;
    }
}
```

- [ ] **Step 13: Update mapResultSetToCaLamViec trong CaLamViecDAOImpl để đọc face fields**

Tìm method `mapResultSetToCaLamViec` trong `CaLamViecDAOImpl.java`, thêm vào cuối trước `return ca;`:

```java
// Thêm vào mapResultSetToCaLamViec, wrap trong try-catch vì cột mới có thể chưa có trên DB cũ
try {
    ca.setFaceVerified(rs.getBoolean("FaceVerified"));
    ca.setFaceCheckInImage(rs.getString("FaceCheckInImage"));
    double conf = rs.getDouble("FaceConfidence");
    if (!rs.wasNull()) ca.setFaceConfidence(conf);
    ca.setFaceLivenessPassed(rs.getBoolean("FaceLivenessPassed"));
    ca.setFaceCheckOutImage(rs.getString("FaceCheckOutImage"));
    double confOut = rs.getDouble("FaceCheckOutConfidence");
    if (!rs.wasNull()) ca.setFaceCheckOutConfidence(confOut);
} catch (SQLException ignored) { /* cột chưa tồn tại trên DB cũ */ }
```

- [ ] **Step 14: Commit**
```bash
git add src/main/java/org/example/model/ src/main/java/org/example/dao/
git commit -m "feat(face): thêm model classes + DAO layer cho face attendance"
```

---

## Task 4: FaceChallengeServlet

**Files:**
- Create: `src/main/java/org/example/controller/face/FaceChallengeServlet.java`

**Interfaces:**
- Consumes: session `user.getAccountId()`, request param `caLamViecId`, `action` (checkin/checkout)
- Produces: `GET /face/challenge?caLamViecId=X&action=checkin` → JSON `{token, challenges: ["blink","turn_left"], ttlSeconds: 180}`

- [ ] **Step 1: Tạo FaceChallengeServlet.java**

```java
// src/main/java/org/example/controller/face/FaceChallengeServlet.java
package org.example.controller.face;

import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.FaceChallengeTokenDAO;
import org.example.dao.impl.FaceChallengeTokenDAOImpl;
import org.example.model.FaceChallengeToken;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet("/face/challenge")
public class FaceChallengeServlet extends HttpServlet {

    private static final String[] ALL_CHALLENGES = {"blink", "turn_left", "turn_right", "smile"};
    private static final int TTL_SECONDS = 180;
    private final FaceChallengeTokenDAO tokenDAO = new FaceChallengeTokenDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        TaiKhoan user = getUser(req);
        if (user == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        String caIdStr = req.getParameter("caLamViecId");
        String action = req.getParameter("action");
        if (caIdStr == null || action == null) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"Thiếu caLamViecId hoặc action\"}");
            return;
        }

        int caId;
        try { caId = Integer.parseInt(caIdStr); } catch (NumberFormatException e) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"caLamViecId không hợp lệ\"}");
            return;
        }

        // Random 2 trong 4 challenges, shuffle thứ tự
        List<String> pool = new ArrayList<>(Arrays.asList(ALL_CHALLENGES));
        Collections.shuffle(pool);
        List<String> chosen = pool.subList(0, 2);

        FaceChallengeToken token = new FaceChallengeToken();
        token.setTokenId(UUID.randomUUID().toString());
        token.setAccountId(user.getAccountId());
        token.setCaLamViecId(caId);
        token.setAction(action);
        token.setChallenges(gson.toJson(chosen));
        token.setCreatedAt(LocalDateTime.now());
        token.setExpiresAt(LocalDateTime.now().plusSeconds(TTL_SECONDS));

        tokenDAO.insert(token);
        // Xóa token cũ hết hạn (cleanup không quan trọng)
        try { tokenDAO.deleteExpired(); } catch (Exception ignored) {}

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("token", token.getTokenId());
        result.put("challenges", chosen);
        result.put("ttlSeconds", TTL_SECONDS);
        resp.getWriter().write(gson.toJson(result));
    }

    private TaiKhoan getUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) return null;
        int role = user.getRoleId();
        if (role != Constants.ROLE_BAO_VE && role != Constants.ROLE_LE_TAN && role != Constants.ROLE_MANAGER) return null;
        return user;
    }
}
```

- [ ] **Step 2: Test thủ công**

Đăng nhập bằng tài khoản bảo vệ hoặc staff, dùng browser DevTools:
```javascript
fetch('/Backend_java/face/challenge?caLamViecId=1&action=checkin')
  .then(r => r.json()).then(console.log)
// Kỳ vọng: {token: "uuid...", challenges: ["blink", "turn_left"], ttlSeconds: 180}
```

- [ ] **Step 3: Commit**
```bash
git add src/main/java/org/example/controller/face/FaceChallengeServlet.java
git commit -m "feat(face): FaceChallengeServlet - sinh challenge token ngẫu nhiên"
```

---

## Task 5: face-attendance.js (Client Orchestration)

**Files:**
- Create: `src/main/webapp/assets/js/face-attendance.js`

**Interfaces:**
- Consumes: `window.FaceAttendance.init(options)` được gọi từ DiemDanh.jsp và CaLamViec.jsp
- Produces: `window.FaceAttendance` object với methods:
  - `init({videoEl, overlayEl, statusEl, contextPath, caLamViecId, action, onSuccess, onError})`
  - `start()` — bắt đầu camera + challenge flow
  - `stop()` — dừng camera

- [ ] **Step 1: Tạo face-attendance.js**

```javascript
// src/main/webapp/assets/js/face-attendance.js
'use strict';

window.FaceAttendance = (function () {
    const MODEL_URL = '/Backend_java/assets/face-models';
    const EAR_THRESHOLD = 0.25;   // Eye Aspect Ratio để detect chớp mắt
    const BLINK_FRAMES = 2;        // Số frame liên tiếp EAR < threshold = chớp mắt
    const TURN_RATIO = 0.20;       // Nose dịch > 20% face width = quay đầu
    const TURN_FRAMES = 3;
    const SMILE_MOUTH_RATIO = 0.45; // mouth_width / face_width để detect cười
    const DETECTION_INTERVAL_MS = 100; // 10fps

    let _opts = {};
    let _stream = null;
    let _intervalId = null;
    let _token = null;
    let _challenges = [];
    let _currentChallengeIdx = 0;
    let _challengePassedFrames = 0;
    let _capturedDescriptor = null;
    let _capturedSnapshot = null;
    let _modelsLoaded = false;

    // ── Utilities ──────────────────────────────────────────────────────────────

    function dist(p1, p2) {
        return Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2));
    }

    function eyeAspectRatio(eyePts) {
        // eyePts: 6 điểm [p0..p5], p0=góc trái, p3=góc phải
        const vertical1 = dist(eyePts[1], eyePts[5]);
        const vertical2 = dist(eyePts[2], eyePts[4]);
        const horizontal = dist(eyePts[0], eyePts[3]);
        return (vertical1 + vertical2) / (2.0 * horizontal);
    }

    function setStatus(msg, type) {
        // type: 'info' | 'success' | 'error' | 'challenge'
        if (!_opts.statusEl) return;
        const colors = {
            info: 'text-zinc-500',
            success: 'text-green-600 font-bold',
            error: 'text-red-600 font-bold',
            challenge: 'text-rose-700 font-bold text-lg'
        };
        _opts.statusEl.className = colors[type] || 'text-zinc-500';
        _opts.statusEl.textContent = msg;
    }

    const CHALLENGE_LABELS = {
        blink: '👁 CHỚP MẮT',
        turn_left: '← QUAY ĐẦU TRÁI',
        turn_right: 'QUAY ĐẦU PHẢI →',
        smile: '😊 MỈM CƯỜI'
    };

    // ── Challenge detection ────────────────────────────────────────────────────

    function detectChallenge(challenge, landmarks, box) {
        const leftEye = landmarks.getLeftEye();
        const rightEye = landmarks.getRightEye();
        const nose = landmarks.getNose();
        const mouth = landmarks.getMouth();

        switch (challenge) {
            case 'blink': {
                const earLeft = eyeAspectRatio(leftEye);
                const earRight = eyeAspectRatio(rightEye);
                return (earLeft + earRight) / 2 < EAR_THRESHOLD;
            }
            case 'turn_left': {
                const noseTip = nose[3]; // điểm 30 trong 68-landmark
                const faceCenter = { x: box.x + box.width / 2, y: box.y + box.height / 2 };
                const shift = (faceCenter.x - noseTip.x) / box.width;
                return shift > TURN_RATIO;
            }
            case 'turn_right': {
                const noseTip = nose[3];
                const faceCenter = { x: box.x + box.width / 2, y: box.y + box.height / 2 };
                const shift = (noseTip.x - faceCenter.x) / box.width;
                return shift > TURN_RATIO;
            }
            case 'smile': {
                const mouthLeft = mouth[0];
                const mouthRight = mouth[6];
                const mouthWidth = dist(mouthLeft, mouthRight);
                return mouthWidth / box.width > SMILE_MOUTH_RATIO;
            }
            default:
                return false;
        }
    }

    // ── Main detection loop ────────────────────────────────────────────────────

    async function detectionLoop() {
        const video = _opts.videoEl;
        const detection = await faceapi
            .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
            .withFaceLandmarks(true)  // true = tiny landmark model
            .withFaceDescriptor();

        if (!detection) {
            setStatus('Không tìm thấy khuôn mặt. Hãy nhìn thẳng vào camera.', 'info');
            _challengePassedFrames = 0;
            return;
        }

        const box = detection.detection.box;
        const landmarks = detection.landmarks;
        const currentChallenge = _challenges[_currentChallengeIdx];
        const passed = detectChallenge(currentChallenge, landmarks, box);

        if (passed) {
            _challengePassedFrames++;
            const required = currentChallenge === 'blink' ? BLINK_FRAMES : TURN_FRAMES;
            if (_challengePassedFrames >= required) {
                _challengePassedFrames = 0;
                _currentChallengeIdx++;

                if (_currentChallengeIdx >= _challenges.length) {
                    // Tất cả challenge passed — capture descriptor + snapshot
                    clearInterval(_intervalId);
                    _capturedDescriptor = Array.from(detection.descriptor);
                    _capturedSnapshot = captureSnapshot(video);
                    setStatus('✓ Xác minh thành công! Đang gửi...', 'success');
                    await submitToServer();
                } else {
                    setStatus(CHALLENGE_LABELS[_challenges[_currentChallengeIdx]], 'challenge');
                }
            }
        } else {
            _challengePassedFrames = 0;
            setStatus(CHALLENGE_LABELS[currentChallenge], 'challenge');
        }
    }

    function captureSnapshot(video) {
        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        // Nén xuống JPEG quality 0.7 để tiết kiệm bandwidth
        return canvas.toDataURL('image/jpeg', 0.7);
    }

    // ── Server submission ──────────────────────────────────────────────────────

    async function submitToServer() {
        const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
        const body = {
            token: _token,
            caLamViecId: _opts.caLamViecId,
            action: _opts.action,
            descriptor: _capturedDescriptor,
            snapshot: _capturedSnapshot,
            _csrf: csrfToken
        };

        try {
            const res = await fetch(_opts.contextPath + '/face/checkin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
                body: JSON.stringify(body)
            });
            const data = await res.json();
            if (data.success) {
                stopCamera();
                if (_opts.onSuccess) _opts.onSuccess(data);
            } else {
                setStatus('Lỗi: ' + (data.error || 'Nhận diện thất bại'), 'error');
                if (_opts.onError) _opts.onError(data.error);
            }
        } catch (e) {
            setStatus('Lỗi kết nối. Thử lại.', 'error');
            if (_opts.onError) _opts.onError(e.message);
        }
    }

    // ── Public API ─────────────────────────────────────────────────────────────

    async function init(opts) {
        _opts = opts;

        if (!_modelsLoaded) {
            setStatus('Đang tải model nhận diện...', 'info');
            await Promise.all([
                faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
                faceapi.nets.faceLandmark68TinyNet.loadFromUri(MODEL_URL),
                faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
            ]);
            _modelsLoaded = true;
        }

        // Lấy challenge từ server
        setStatus('Đang chuẩn bị...', 'info');
        const res = await fetch(
            `${opts.contextPath}/face/challenge?caLamViecId=${opts.caLamViecId}&action=${opts.action}`
        );
        const data = await res.json();
        _token = data.token;
        _challenges = data.challenges;
        _currentChallengeIdx = 0;
        _challengePassedFrames = 0;
    }

    async function start() {
        // Bật camera
        _stream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480, facingMode: 'user' } });
        _opts.videoEl.srcObject = _stream;
        await new Promise(resolve => { _opts.videoEl.onloadedmetadata = resolve; });
        await _opts.videoEl.play();

        setStatus(CHALLENGE_LABELS[_challenges[0]], 'challenge');
        _intervalId = setInterval(detectionLoop, DETECTION_INTERVAL_MS);
    }

    function stopCamera() {
        if (_intervalId) { clearInterval(_intervalId); _intervalId = null; }
        if (_stream) { _stream.getTracks().forEach(t => t.stop()); _stream = null; }
    }

    return { init, start, stop: stopCamera };
})();
```

- [ ] **Step 2: Commit**
```bash
git add src/main/webapp/assets/js/face-attendance.js
git commit -m "feat(face): face-attendance.js - liveness challenge orchestration client-side"
```

---

## Task 6: FaceCheckInServlet (Backend Validate + Record)

**Files:**
- Create: `src/main/java/org/example/controller/face/FaceCheckInServlet.java`

**Interfaces:**
- Consumes: `POST /face/checkin` JSON body `{token, caLamViecId, action, descriptor[], snapshot}`
- Produces: JSON `{success: true, confidence: 87.3}` hoặc `{success: false, error: "..."}`

- [ ] **Step 1: Tạo FaceCheckInServlet.java**

```java
// src/main/java/org/example/controller/face/FaceCheckInServlet.java
package org.example.controller.face;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.CaLamViecDAO;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.FaceChallengeTokenDAO;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.*;
import org.example.model.*;
import org.example.util.Constants;

import java.io.*;
import java.util.*;

@WebServlet("/face/checkin")
public class FaceCheckInServlet extends HttpServlet {

    private static final double MATCH_THRESHOLD = 0.6;
    private final FaceChallengeTokenDAO tokenDAO = new FaceChallengeTokenDAOImpl();
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final CaLamViecDAO caLamViecDAO = new CaLamViecDAOImpl();
    private final CoSoFaceConfigDAO configDAO = new CoSoFaceConfigDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");

        TaiKhoan user = getUser(req);
        if (user == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"success\":false,\"error\":\"Chưa đăng nhập\"}");
            return;
        }

        // Parse JSON body
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
        }
        JsonObject body;
        try { body = gson.fromJson(sb.toString(), JsonObject.class); }
        catch (Exception e) {
            resp.setStatus(400);
            resp.getWriter().write("{\"success\":false,\"error\":\"Body JSON không hợp lệ\"}");
            return;
        }

        String tokenId = body.get("token") == null ? null : body.get("token").getAsString();
        int caId = body.get("caLamViecId") == null ? 0 : body.get("caLamViecId").getAsInt();
        String action = body.get("action") == null ? "checkin" : body.get("action").getAsString();
        JsonArray descriptorArr = body.get("descriptor") == null ? null : body.get("descriptor").getAsJsonArray();
        String snapshot = body.get("snapshot") == null ? null : body.get("snapshot").getAsString();

        if (tokenId == null || caId == 0 || descriptorArr == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu dữ liệu bắt buộc\"}");
            return;
        }

        // Validate token
        FaceChallengeToken token = tokenDAO.findById(tokenId);
        if (token == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token không tồn tại\"}");
            return;
        }
        if (token.isExpired()) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token đã hết hạn. Vui lòng thử lại.\"}");
            return;
        }
        if (token.isUsed()) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token đã được sử dụng\"}");
            return;
        }
        if (token.getAccountId() != user.getAccountId()) {
            resp.setStatus(403);
            resp.getWriter().write("{\"success\":false,\"error\":\"Token không thuộc về bạn\"}");
            return;
        }
        if (token.getCaLamViecId() != caId) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Token không khớp ca làm việc\"}");
            return;
        }

        // Load stored descriptor
        TaiKhoan faceData = taiKhoanDAO.getFaceData(user.getAccountId());
        if (faceData == null || faceData.getFaceDescriptor() == null) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Bạn chưa đăng ký khuôn mặt. Liên hệ quản lý.\"}");
            return;
        }

        // Parse stored descriptor
        double[] storedDesc = gson.fromJson(faceData.getFaceDescriptor(), double[].class);

        // Parse incoming descriptor
        double[] incomingDesc = new double[128];
        for (int i = 0; i < Math.min(128, descriptorArr.size()); i++) {
            incomingDesc[i] = descriptorArr.get(i).getAsDouble();
        }

        // Euclidean distance
        double distance = euclideanDistance(storedDesc, incomingDesc);

        // Load config để lấy ngưỡng của chi nhánh
        double threshold = MATCH_THRESHOLD;
        if (user.getCoSoId() != null) {
            CoSoFaceConfig cfg = configDAO.findByCoSo(user.getCoSoId());
            threshold = cfg.getConfidenceMin(); // đây là threshold distance
        }

        if (distance > threshold) {
            double confidence = Math.max(0, (1 - distance / MATCH_THRESHOLD) * 100);
            resp.getWriter().write(String.format(
                "{\"success\":false,\"error\":\"Khuôn mặt không khớp (%.1f%%%). Vui lòng thử lại.\",\"confidence\":%.1f}",
                confidence, confidence));
            return;
        }

        double confidence = Math.max(0, Math.min(100, (1 - distance / MATCH_THRESHOLD) * 100));

        // Mark token used (chống replay)
        tokenDAO.markUsed(tokenId);

        // Lưu snapshot
        String imagePath = saveSnapshot(snapshot, user.getAccountId(), caId, action);

        // Ghi vào DB
        boolean ok;
        if ("checkin".equals(action)) {
            ok = caLamViecDAO.faceCheckIn(caId, imagePath, confidence, true);
        } else {
            ok = caLamViecDAO.faceCheckOut(caId, imagePath, confidence);
        }

        if (!ok) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Không thể cập nhật ca làm việc. Ca có thể đã được điểm danh.\"}");
            return;
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("confidence", Math.round(confidence * 10.0) / 10.0);
        result.put("action", action);
        resp.getWriter().write(gson.toJson(result));
    }

    private double euclideanDistance(double[] a, double[] b) {
        double sum = 0;
        for (int i = 0; i < Math.min(a.length, b.length); i++) {
            double diff = a[i] - b[i];
            sum += diff * diff;
        }
        return Math.sqrt(sum);
    }

    private String saveSnapshot(String base64DataUrl, int accountId, int caId, String action) {
        if (base64DataUrl == null || !base64DataUrl.startsWith("data:image")) return null;
        try {
            String base64 = base64DataUrl.substring(base64DataUrl.indexOf(',') + 1);
            byte[] bytes = java.util.Base64.getDecoder().decode(base64);
            String dir = getServletContext().getRealPath("/uploads/face-checkin");
            if (dir == null) {
                dir = new java.io.File(System.getProperty("user.home"), "v-sport/uploads/face-checkin").getAbsolutePath();
            }
            new java.io.File(dir).mkdirs();
            String filename = accountId + "_ca" + caId + "_" + action + "_" + System.currentTimeMillis() + ".jpg";
            java.nio.file.Files.write(java.nio.file.Paths.get(dir, filename), bytes);
            return "/uploads/face-checkin/" + filename;
        } catch (Exception e) {
            return null;
        }
    }

    private TaiKhoan getUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) return null;
        int role = user.getRoleId();
        if (role != Constants.ROLE_BAO_VE && role != Constants.ROLE_LE_TAN) return null;
        return user;
    }
}
```

- [ ] **Step 2: Commit**
```bash
git add src/main/java/org/example/controller/face/FaceCheckInServlet.java
git commit -m "feat(face): FaceCheckInServlet - validate token + Euclidean match + ghi audit"
```

---

## Task 7: FaceEnrollServlet

**Files:**
- Create: `src/main/java/org/example/controller/face/FaceEnrollServlet.java`

**Interfaces:**
- Consumes:
  - `GET /face/enroll` → trả về trạng thái enroll của user hiện tại (JSON)
  - `POST /face/enroll` JSON body `{descriptor[], photo}` hoặc multipart form (manager upload)
  - `POST /face/enroll?targetAccountId=X` — manager enroll cho nhân viên khác
- Produces: `{success: true, enrolledAt: "..."}` hoặc `{success: false, error: "..."}`

- [ ] **Step 1: Tạo FaceEnrollServlet.java**

```java
// src/main/java/org/example/controller/face/FaceEnrollServlet.java
package org.example.controller.face;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.*;
import java.nio.file.*;
import java.util.*;

@WebServlet("/face/enroll")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5MB
public class FaceEnrollServlet extends HttpServlet {

    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        TaiKhoan user = getAuthorizedUser(req);
        if (user == null) { resp.setStatus(401); resp.getWriter().write("{\"error\":\"Unauthorized\"}"); return; }

        int targetId = resolveTargetId(req, user);
        TaiKhoan faceData = taiKhoanDAO.getFaceData(targetId);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("enrolled", faceData != null && faceData.getFaceDescriptor() != null);
        result.put("imagePath", faceData != null ? faceData.getFaceImagePath() : null);
        result.put("enrolledAt", faceData != null && faceData.getFaceEnrolledAt() != null
                ? faceData.getFaceEnrolledAt().toString() : null);
        resp.getWriter().write(gson.toJson(result));
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        TaiKhoan user = getAuthorizedUser(req);
        if (user == null) { resp.setStatus(401); resp.getWriter().write("{\"error\":\"Unauthorized\"}"); return; }

        int targetId = resolveTargetId(req, user);

        String contentType = req.getContentType();
        String descriptorJson = null;
        String imagePath = null;

        if (contentType != null && contentType.startsWith("application/json")) {
            // Self-enroll: descriptor + snapshot từ face-api.js
            StringBuilder sb = new StringBuilder();
            try (BufferedReader r = req.getReader()) {
                String line;
                while ((line = r.readLine()) != null) sb.append(line);
            }
            JsonObject body = gson.fromJson(sb.toString(), JsonObject.class);
            JsonArray arr = body.get("descriptor") == null ? null : body.get("descriptor").getAsJsonArray();
            if (arr == null || arr.size() < 128) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (cần 128 số)\"}");
                return;
            }
            descriptorJson = arr.toString();
            String photo = body.get("photo") == null ? null : body.get("photo").getAsString();
            imagePath = savePhotoBase64(photo, targetId);

        } else if (contentType != null && contentType.startsWith("multipart/form-data")) {
            // Manager upload file ảnh — descriptor sẽ do client extract rồi gửi kèm field
            String descField = req.getParameter("descriptor");
            if (descField == null || descField.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu descriptor\"}");
                return;
            }
            descriptorJson = descField;
            Part filePart = req.getPart("photo");
            if (filePart != null && filePart.getSize() > 0) {
                imagePath = savePhotoStream(filePart.getInputStream(), targetId);
            }
        } else {
            resp.getWriter().write("{\"success\":false,\"error\":\"Content-Type không hỗ trợ\"}");
            return;
        }

        taiKhoanDAO.updateFaceData(targetId, descriptorJson, imagePath);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("enrolledAt", java.time.LocalDateTime.now().toString());
        resp.getWriter().write(gson.toJson(result));
    }

    private int resolveTargetId(HttpServletRequest req, TaiKhoan user) {
        String targetParam = req.getParameter("targetAccountId");
        if (targetParam != null && user.getRoleId() == Constants.ROLE_MANAGER) {
            try { return Integer.parseInt(targetParam); } catch (NumberFormatException ignored) {}
        }
        return user.getAccountId();
    }

    private String savePhotoBase64(String base64DataUrl, int accountId) {
        if (base64DataUrl == null || !base64DataUrl.startsWith("data:image")) return null;
        try {
            byte[] bytes = Base64.getDecoder().decode(base64DataUrl.substring(base64DataUrl.indexOf(',') + 1));
            return saveBytes(bytes, accountId);
        } catch (Exception e) { return null; }
    }

    private String savePhotoStream(InputStream stream, int accountId) throws IOException {
        return saveBytes(stream.readAllBytes(), accountId);
    }

    private String saveBytes(byte[] bytes, int accountId) throws IOException {
        String dir = getServletContext().getRealPath("/uploads/face-photos");
        if (dir == null) dir = new File(System.getProperty("user.home"), "v-sport/uploads/face-photos").getAbsolutePath();
        new File(dir).mkdirs();
        String filename = "face_" + accountId + "_" + System.currentTimeMillis() + ".jpg";
        Files.write(Paths.get(dir, filename), bytes);
        return "/uploads/face-photos/" + filename;
    }

    private TaiKhoan getAuthorizedUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        TaiKhoan user = (TaiKhoan) session.getAttribute("user");
        if (user == null) return null;
        int role = user.getRoleId();
        if (role == Constants.ROLE_BAO_VE || role == Constants.ROLE_LE_TAN || role == Constants.ROLE_MANAGER) return user;
        return null;
    }
}
```

- [ ] **Step 2: Commit**
```bash
git add src/main/java/org/example/controller/face/FaceEnrollServlet.java
git commit -m "feat(face): FaceEnrollServlet - self-enroll + manager upload"
```

---

## Task 8: FaceSettingsServlet

**Files:**
- Create: `src/main/java/org/example/controller/manager/FaceSettingsServlet.java`
- Create: `src/main/webapp/manager/FaceSettings.jsp`

**Interfaces:**
- Consumes: `GET /manager/face-settings` → render JSP với config, `POST /manager/face-settings` → upsert config
- Produces: redirect về GET với flash message sau khi lưu

- [ ] **Step 1: Tạo FaceSettingsServlet.java**

```java
// src/main/java/org/example/controller/manager/FaceSettingsServlet.java
package org.example.controller.manager;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
import org.example.model.CoSoFaceConfig;
import org.example.model.TaiKhoan;
import org.example.util.Constants;

import java.io.IOException;

@WebServlet("/manager/face-settings")
public class FaceSettingsServlet extends HttpServlet {

    private final CoSoFaceConfigDAO configDAO = new CoSoFaceConfigDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;

        CoSoFaceConfig config = configDAO.findByCoSo(manager.getCoSoId());
        req.setAttribute("faceConfig", config);
        req.getRequestDispatcher("/manager/FaceSettings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        TaiKhoan manager = getManager(req, resp);
        if (manager == null) return;

        boolean faceRequired = "on".equals(req.getParameter("faceRequired")) || "true".equals(req.getParameter("faceRequired"));
        double confidenceMin = 0.6;
        try { confidenceMin = Double.parseDouble(req.getParameter("confidenceMin")); } catch (Exception ignored) {}
        confidenceMin = Math.max(0.4, Math.min(0.9, confidenceMin));

        CoSoFaceConfig config = new CoSoFaceConfig();
        config.setCoSoId(manager.getCoSoId());
        config.setFaceRequired(faceRequired);
        config.setConfidenceMin(confidenceMin);
        configDAO.upsert(config);

        req.getSession().setAttribute("flashSuccess", "Đã lưu cài đặt điểm danh khuôn mặt.");
        resp.sendRedirect(req.getContextPath() + "/manager/face-settings");
    }

    private TaiKhoan getManager(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_MANAGER || user.getCoSoId() == null) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap");
            return null;
        }
        return user;
    }
}
```

- [ ] **Step 2: Tạo FaceSettings.jsp**

```jsp
<%-- src/main/webapp/manager/FaceSettings.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Cài đặt điểm danh khuôn mặt | Manager V-SPORT</title>
  <jsp:include page="/manager/common/head.jsp"/>
</head>
<body>
<jsp:include page="/manager/common/sidebar.jsp"/>
<jsp:include page="/manager/common/header.jsp">
  <jsp:param name="pageTitle" value="Điểm danh khuôn mặt"/>
  <jsp:param name="pageSubtitle" value="Cài đặt cho chi nhánh của bạn"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 max-w-xl">

  <c:if test="${not empty sessionScope.flashSuccess}">
    <div class="mb-4 p-3 bg-green-50 border border-green-200 text-green-700 rounded-xl text-sm">
      ${sessionScope.flashSuccess}
    </div>
    <c:remove var="flashSuccess" scope="session"/>
  </c:if>

  <div class="bg-white rounded-2xl shadow-sm border border-zinc-100 p-6">
    <h2 class="text-lg font-black text-zinc-800 mb-5">Cài đặt điểm danh khuôn mặt</h2>
    <form method="post" action="${pageContext.request.contextPath}/manager/face-settings" class="flex flex-col gap-5">

      <div class="flex items-center justify-between p-4 bg-zinc-50 rounded-xl">
        <div>
          <p class="font-bold text-zinc-700">Bắt buộc điểm danh bằng khuôn mặt</p>
          <p class="text-sm text-zinc-400">Nhân viên phải qua face scan mới được vào/ra ca</p>
        </div>
        <label class="relative inline-flex items-center cursor-pointer">
          <input type="checkbox" name="faceRequired" class="sr-only peer"
                 ${faceConfig.faceRequired ? 'checked' : ''}>
          <div class="w-11 h-6 bg-zinc-200 peer-focus:ring-2 peer-focus:ring-rose-300 rounded-full peer
                      peer-checked:bg-rose-500 after:content-[''] after:absolute after:top-0.5 after:left-[2px]
                      after:bg-white after:rounded-full after:h-5 after:w-5 after:transition-all
                      peer-checked:after:translate-x-full"></div>
        </label>
      </div>

      <div>
        <label class="block text-sm font-semibold text-zinc-600 mb-1">
          Ngưỡng Euclidean distance tối đa (thấp hơn = nghiêm ngặt hơn)
        </label>
        <select name="confidenceMin" class="w-full border border-zinc-200 rounded-xl px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-rose-300">
          <option value="0.4" ${faceConfig.confidenceMin == 0.4 ? 'selected' : ''}>0.4 — Rất nghiêm ngặt (~95% giống)</option>
          <option value="0.5" ${faceConfig.confidenceMin == 0.5 ? 'selected' : ''}>0.5 — Nghiêm ngặt (~88% giống)</option>
          <option value="0.6" ${faceConfig.confidenceMin == 0.6 ? 'selected' : ''}>0.6 — Mặc định (~80% giống)</option>
          <option value="0.7" ${faceConfig.confidenceMin == 0.7 ? 'selected' : ''}>0.7 — Thoải mái hơn (~70% giống)</option>
        </select>
        <p class="text-xs text-zinc-400 mt-1">Khuyến nghị 0.6 — phù hợp hầu hết điều kiện ánh sáng bình thường</p>
      </div>

      <button type="submit"
              class="bg-rose-600 hover:bg-rose-700 text-white font-bold py-3 rounded-xl transition text-sm">
        Lưu cài đặt
      </button>
    </form>
  </div>
</main>
</body>
</html>
```

- [ ] **Step 3: Commit**
```bash
git add src/main/java/org/example/controller/manager/FaceSettingsServlet.java src/main/webapp/manager/FaceSettings.jsp
git commit -m "feat(face): FaceSettingsServlet + FaceSettings.jsp - cài đặt per-branch"
```

---

## Task 9: FaceEnroll.jsp cho Guard và Staff

**Files:**
- Create: `src/main/webapp/guard/FaceEnroll.jsp`
- Create: `src/main/webapp/staff/FaceEnroll.jsp`
- Create: `src/main/java/org/example/controller/guard/GuardFaceEnrollPageServlet.java`
- Create: `src/main/java/org/example/controller/staff/StaffFaceEnrollPageServlet.java`

**Interfaces:**
- Consumes: session user, GET /guard/enroll-face và /staff/enroll-face
- Produces: trang self-enroll với camera capture, gọi POST /face/enroll

- [ ] **Step 1: Tạo GuardFaceEnrollPageServlet.java**

```java
// src/main/java/org/example/controller/guard/GuardFaceEnrollPageServlet.java
package org.example.controller.guard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import java.io.IOException;

@WebServlet("/guard/enroll-face")
public class GuardFaceEnrollPageServlet extends HttpServlet {
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_BAO_VE) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap"); return;
        }
        TaiKhoan faceData = taiKhoanDAO.getFaceData(user.getAccountId());
        req.setAttribute("faceData", faceData);
        req.getRequestDispatcher("/guard/FaceEnroll.jsp").forward(req, resp);
    }
}
```

- [ ] **Step 2: Tạo StaffFaceEnrollPageServlet.java** (tương tự, thay ROLE_BAO_VE bằng ROLE_LE_TAN, URL /staff/enroll-face, JSP /staff/FaceEnroll.jsp)

```java
// src/main/java/org/example/controller/staff/StaffFaceEnrollPageServlet.java
package org.example.controller.staff;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.example.dao.TaiKhoanDAO;
import org.example.dao.impl.TaiKhoanDAOImpl;
import org.example.model.TaiKhoan;
import org.example.util.Constants;
import java.io.IOException;

@WebServlet("/staff/enroll-face")
public class StaffFaceEnrollPageServlet extends HttpServlet {
    private final TaiKhoanDAO taiKhoanDAO = new TaiKhoanDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        TaiKhoan user = session != null ? (TaiKhoan) session.getAttribute("user") : null;
        if (user == null || user.getRoleId() != Constants.ROLE_LE_TAN) {
            resp.sendRedirect(req.getContextPath() + "/dangnhap"); return;
        }
        TaiKhoan faceData = taiKhoanDAO.getFaceData(user.getAccountId());
        req.setAttribute("faceData", faceData);
        req.getRequestDispatcher("/staff/FaceEnroll.jsp").forward(req, resp);
    }
}
```

- [ ] **Step 3: Tạo guard/FaceEnroll.jsp**

```jsp
<%-- src/main/webapp/guard/FaceEnroll.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>Đăng ký khuôn mặt | GUARD V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
  <script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
</head>
<body>
<jsp:include page="/guard/common/sidebar.jsp"/>
<jsp:include page="/guard/common/header.jsp">
  <jsp:param name="pageTitle" value="Đăng ký khuôn mặt"/>
  <jsp:param name="pageSubtitle" value="Dùng cho điểm danh sinh trắc học"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 max-w-lg">

  <!-- Trạng thái hiện tại -->
  <c:choose>
    <c:when test="${faceData != null && faceData.faceEnrolled}">
      <div class="gd-card p-5 mb-5 flex items-center gap-4">
        <div class="w-12 h-12 rounded-2xl bg-green-100 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px] text-green-600" style="font-variation-settings:'FILL' 1">face</span>
        </div>
        <div>
          <p class="font-bold text-green-700">Đã đăng ký khuôn mặt</p>
          <p class="text-xs text-zinc-400">Cập nhật lần cuối: ${faceData.faceEnrolledAt}</p>
        </div>
      </div>
    </c:when>
    <c:otherwise>
      <div class="gd-card p-5 mb-5 flex items-center gap-4 border-amber-200 bg-amber-50">
        <span class="material-symbols-outlined text-[28px] text-amber-500" style="font-variation-settings:'FILL' 1">warning</span>
        <p class="text-sm text-amber-700 font-semibold">Bạn chưa đăng ký khuôn mặt. Hãy hoàn thành để điểm danh.</p>
      </div>
    </c:otherwise>
  </c:choose>

  <!-- Camera section -->
  <div class="gd-card p-6 flex flex-col items-center gap-4">
    <div class="relative w-full max-w-xs aspect-square bg-zinc-900 rounded-2xl overflow-hidden">
      <video id="enrollVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
      <canvas id="enrollCanvas" class="absolute inset-0 w-full h-full scale-x-[-1]" style="display:none"></canvas>
    </div>

    <p id="enrollStatus" class="text-zinc-500 text-sm text-center min-h-[2rem]">Nhấn "Bắt đầu" để mở camera</p>

    <div id="enrollPreview" class="hidden w-32 h-32 rounded-2xl overflow-hidden border-4 border-green-400">
      <img id="enrollPreviewImg" class="w-full h-full object-cover" alt="Preview khuôn mặt"/>
    </div>

    <div class="flex gap-3 w-full">
      <button id="btnStart" onclick="startEnroll()"
              class="flex-1 bg-rose-600 hover:bg-rose-700 text-white font-bold py-3 rounded-xl text-sm transition">
        📷 Bắt đầu
      </button>
      <button id="btnSave" onclick="saveEnroll()" disabled
              class="flex-1 bg-green-600 hover:bg-green-700 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-bold py-3 rounded-xl text-sm transition">
        ✓ Lưu khuôn mặt
      </button>
    </div>
  </div>
</main>

<script src="${pageContext.request.contextPath}/assets/js/face-enroll.js"></script>
<script>
  const CONTEXT_PATH = '${pageContext.request.contextPath}';
  const MODEL_URL = CONTEXT_PATH + '/assets/face-models';
</script>
</body>
</html>
```

- [ ] **Step 4: Tạo staff/FaceEnroll.jsp** — Sao chép guard/FaceEnroll.jsp, thay:
  - `<jsp:include page="/guard/common/guard_head.jsp"/>` → `<jsp:include page="/staff/common/head.jsp"/>`
  - `<jsp:include page="/guard/common/sidebar.jsp"/>` → `<jsp:include page="/staff/common/sidebar.jsp"/>`
  - `<jsp:include page="/guard/common/header.jsp">` → `<jsp:include page="/staff/common/header.jsp">`

- [ ] **Step 5: Tạo face-enroll.js (script riêng cho enrollment)**

```javascript
// src/main/webapp/assets/js/face-enroll.js
'use strict';
let _enrollStream = null;
let _enrollDescriptor = null;
let _enrollSnapshot = null;
let _modelsLoaded = false;

async function startEnroll() {
    const statusEl = document.getElementById('enrollStatus');
    const video = document.getElementById('enrollVideo');
    statusEl.textContent = 'Đang tải model nhận diện...';

    if (!_modelsLoaded) {
        await Promise.all([
            faceapi.nets.tinyFaceDetector.loadFromUri(MODEL_URL),
            faceapi.nets.faceLandmark68TinyNet.loadFromUri(MODEL_URL),
            faceapi.nets.faceRecognitionNet.loadFromUri(MODEL_URL)
        ]);
        _modelsLoaded = true;
    }

    _enrollStream = await navigator.mediaDevices.getUserMedia({ video: { width: 640, height: 480, facingMode: 'user' } });
    video.srcObject = _enrollStream;
    await new Promise(r => { video.onloadedmetadata = r; });
    await video.play();

    statusEl.textContent = 'Nhìn thẳng vào camera và giữ yên...';

    // Capture sau 2s (đủ thời gian ổn định)
    setTimeout(async () => {
        statusEl.textContent = 'Đang phân tích khuôn mặt...';
        const detection = await faceapi
            .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
            .withFaceLandmarks(true)
            .withFaceDescriptor();

        if (!detection) {
            statusEl.textContent = 'Không tìm thấy khuôn mặt. Thử lại với ánh sáng tốt hơn.';
            return;
        }

        _enrollDescriptor = Array.from(detection.descriptor);

        // Capture snapshot
        const canvas = document.getElementById('enrollCanvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        canvas.getContext('2d').drawImage(video, 0, 0);
        _enrollSnapshot = canvas.toDataURL('image/jpeg', 0.8);

        // Preview
        document.getElementById('enrollPreviewImg').src = _enrollSnapshot;
        document.getElementById('enrollPreview').classList.remove('hidden');

        statusEl.textContent = '✓ Đã nhận diện khuôn mặt. Nhấn "Lưu khuôn mặt" để xác nhận.';
        statusEl.className = 'text-green-600 font-bold text-sm text-center';
        document.getElementById('btnSave').disabled = false;

        // Dừng camera
        if (_enrollStream) { _enrollStream.getTracks().forEach(t => t.stop()); _enrollStream = null; }
    }, 2000);
}

async function saveEnroll() {
    if (!_enrollDescriptor) return;
    const statusEl = document.getElementById('enrollStatus');
    statusEl.textContent = 'Đang lưu...';

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
    const res = await fetch(CONTEXT_PATH + '/face/enroll', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ descriptor: _enrollDescriptor, photo: _enrollSnapshot, _csrf: csrfToken })
    });
    const data = await res.json();
    if (data.success) {
        statusEl.textContent = '✓ Đăng ký khuôn mặt thành công!';
        statusEl.className = 'text-green-600 font-bold text-sm text-center';
        document.getElementById('btnSave').disabled = true;
    } else {
        statusEl.textContent = 'Lỗi: ' + (data.error || 'Không thể lưu');
        statusEl.className = 'text-red-600 font-bold text-sm text-center';
    }
}
```

- [ ] **Step 6: Commit**
```bash
git add src/main/webapp/guard/FaceEnroll.jsp src/main/webapp/staff/FaceEnroll.jsp \
        src/main/webapp/assets/js/face-enroll.js \
        src/main/java/org/example/controller/guard/GuardFaceEnrollPageServlet.java \
        src/main/java/org/example/controller/staff/StaffFaceEnrollPageServlet.java
git commit -m "feat(face): FaceEnroll pages + self-enroll JS cho guard và staff"
```

---

## Task 10: Cập nhật DiemDanh.jsp (Guard)

**Files:**
- Modify: `src/main/webapp/guard/DiemDanh.jsp`
- Modify: `src/main/java/org/example/controller/guard/GuardDiemDanhServlet.java`

**Interfaces:**
- Consumes: `faceConfig` (CoSoFaceConfig) từ servlet, `caHomNay.faceVerified`, `caHomNay.faceConfidence`
- Produces: UI với face modal overlay thay/bên cạnh nút "VÀO CA"

- [ ] **Step 1: Cập nhật GuardDiemDanhServlet để load faceConfig**

Thêm vào doGet trong `GuardDiemDanhServlet.java` sau khi load `caHomNay`:

```java
// Thêm import ở đầu file
import org.example.dao.CoSoFaceConfigDAO;
import org.example.dao.impl.CoSoFaceConfigDAOImpl;
import org.example.model.CoSoFaceConfig;

// Thêm field
private final CoSoFaceConfigDAO faceConfigDAO = new CoSoFaceConfigDAOImpl();

// Thêm vào doGet trước req.setAttribute("caHomNay", ...)
CoSoFaceConfig faceConfig = user.getCoSoId() != null
    ? faceConfigDAO.findByCoSo(user.getCoSoId())
    : new CoSoFaceConfig();
req.setAttribute("faceConfig", faceConfig);
```

- [ ] **Step 2: Cập nhật DiemDanh.jsp — thay block "Action buttons"**

Tìm block `<!-- Action buttons -->` trong DiemDanh.jsp (khoảng dòng 57-104), thay toàn bộ phần `<div class="flex gap-3">...</div>` bằng:

```jsp
<!-- Action buttons -->
<div class="flex gap-3">
  <c:choose>
    <%-- Chưa vào ca --%>
    <c:when test="${caHomNay.gioVaoThuc == null}">
      <%-- Face check-in button (ưu tiên) --%>
      <button type="button" id="btnFaceCheckIn"
              onclick="openFaceModal('checkin', ${caHomNay.caLamViecId})"
              class="inline-flex items-center gap-2 bg-rose-600 hover:bg-rose-700 text-white font-bold text-sm px-6 py-3 rounded-xl shadow-lg shadow-rose-200 transition">
        <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">face</span>
        ĐIỂM DANH KHUÔN MẶT
      </button>
      <%-- Fallback thủ công nếu faceRequired=false --%>
      <c:if test="${!faceConfig.faceRequired}">
        <form method="post" action="${pageContext.request.contextPath}/guard/diem-danh"
              onsubmit="return confirm('Xác nhận VÀO CA thủ công lúc ' + new Date().toLocaleTimeString('vi-VN') + '?')">
          <input type="hidden" name="action" value="checkin">
          <input type="hidden" name="caLamViecId" value="${caHomNay.caLamViecId}">
          <button type="submit"
                  class="inline-flex items-center gap-2 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold text-sm px-4 py-3 rounded-xl transition">
            <span class="material-symbols-outlined text-[16px]">login</span>
            Thủ công
          </button>
        </form>
      </c:if>
    </c:when>
    <%-- Đã vào ca, chưa ra --%>
    <c:when test="${caHomNay.gioVaoThuc != null && caHomNay.gioRaThuc == null}">
      <div class="text-right">
        <p class="text-xs text-green-600 font-semibold mb-1 flex items-center gap-1">
          <span class="w-1.5 h-1.5 rounded-full bg-green-500 inline-block live-dot"></span>
          Đang trong ca — vào lúc ${caHomNay.gioVaoThuc}
          <c:if test="${caHomNay.faceVerified}">
            <span class="ml-1 text-[10px] bg-green-100 text-green-700 px-1.5 py-0.5 rounded-full">
              👁 <fmt:formatNumber value="${caHomNay.faceConfidence}" maxFractionDigits="0"/>%
            </span>
          </c:if>
        </p>
        <button type="button" onclick="openFaceModal('checkout', ${caHomNay.caLamViecId})"
                class="inline-flex items-center gap-2 bg-zinc-700 hover:bg-zinc-800 text-white font-bold text-sm px-6 py-3 rounded-xl transition">
          <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">face</span>
          KẾT THÚC CA
        </button>
        <c:if test="${!faceConfig.faceRequired}">
          <form method="post" action="${pageContext.request.contextPath}/guard/diem-danh" class="inline ml-2"
                onsubmit="return confirm('Kết thúc ca thủ công?')">
            <input type="hidden" name="action" value="checkout">
            <input type="hidden" name="caLamViecId" value="${caHomNay.caLamViecId}">
            <button type="submit" class="text-xs text-zinc-400 hover:text-zinc-600 underline">Thủ công</button>
          </form>
        </c:if>
      </div>
    </c:when>
    <%-- Đã hoàn thành --%>
    <c:otherwise>
      <div class="text-right">
        <span class="badge badge-blue text-sm px-4 py-2">
          <span class="material-symbols-outlined text-[16px] mr-1" style="font-variation-settings:'FILL' 1">check_circle</span>
          Ca hoàn thành
        </span>
        <p class="text-xs text-zinc-400 mt-2">
          Vào: ${caHomNay.gioVaoThuc} — Ra: ${caHomNay.gioRaThuc}
          <c:if test="${caHomNay.faceVerified}">
            | 👁 <fmt:formatNumber value="${caHomNay.faceConfidence}" maxFractionDigits="0"/>%
          </c:if>
        </p>
      </div>
    </c:otherwise>
  </c:choose>
</div>
```

- [ ] **Step 3: Thêm Face Modal và script vào DiemDanh.jsp trước `</body>`**

```jsp
<%-- Thêm ở head (sau guard_head.jsp include) --%>
<script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>

<%-- Thêm trước </body> --%>
<!-- Face Attendance Modal -->
<div id="faceModal" class="fixed inset-0 bg-black/70 z-50 flex items-center justify-center hidden">
  <div class="bg-white rounded-3xl shadow-2xl p-6 w-full max-w-sm mx-4 flex flex-col items-center gap-4">
    <h3 class="font-black text-rose-900 text-lg" id="faceModalTitle">Điểm danh khuôn mặt</h3>

    <div class="relative w-full aspect-square bg-zinc-900 rounded-2xl overflow-hidden">
      <video id="faceVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
    </div>

    <p id="faceStatus" class="text-zinc-600 text-sm text-center font-medium min-h-[2.5rem]">
      Đang khởi động camera...
    </p>

    <div class="w-full bg-zinc-100 rounded-full h-2">
      <div id="faceProgress" class="bg-rose-500 h-2 rounded-full transition-all duration-300" style="width:0%"></div>
    </div>

    <button onclick="closeFaceModal()"
            class="w-full bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold py-3 rounded-xl text-sm transition">
      Hủy
    </button>
  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/face-attendance.js"></script>
<script>
const CONTEXT_PATH = '${pageContext.request.contextPath}';
let _currentCaId = null;
let _currentAction = null;

function openFaceModal(action, caId) {
  _currentCaId = caId;
  _currentAction = action;
  document.getElementById('faceModal').classList.remove('hidden');
  document.getElementById('faceModalTitle').textContent =
    action === 'checkin' ? 'Điểm danh VÀO CA' : 'Điểm danh KẾT THÚC CA';
  startFaceAttendance(action, caId);
}

function closeFaceModal() {
  FaceAttendance.stop();
  document.getElementById('faceModal').classList.add('hidden');
}

async function startFaceAttendance(action, caId) {
  const statusEl = document.getElementById('faceStatus');
  const progressEl = document.getElementById('faceProgress');

  await FaceAttendance.init({
    videoEl: document.getElementById('faceVideo'),
    statusEl: statusEl,
    contextPath: CONTEXT_PATH,
    caLamViecId: caId,
    action: action,
    onSuccess: function(data) {
      progressEl.style.width = '100%';
      statusEl.textContent = '✓ Thành công! Độ khớp: ' + data.confidence.toFixed(1) + '%';
      statusEl.className = 'text-green-600 font-bold text-sm text-center';
      setTimeout(() => { closeFaceModal(); location.reload(); }, 1500);
    },
    onError: function(msg) {
      statusEl.textContent = '✗ ' + (msg || 'Lỗi nhận diện');
      statusEl.className = 'text-red-600 font-bold text-sm text-center';
    }
  });

  await FaceAttendance.start();
}
</script>
```

- [ ] **Step 4: Thêm `<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>` vào đầu DiemDanh.jsp** (để dùng `<fmt:formatNumber>`)

- [ ] **Step 5: Commit**
```bash
git add src/main/webapp/guard/DiemDanh.jsp \
        src/main/java/org/example/controller/guard/GuardDiemDanhServlet.java
git commit -m "feat(face): tích hợp face modal vào trang điểm danh bảo vệ"
```

---

## Task 11: Cập nhật Staff CaLamViec.jsp

**Files:**
- Modify: `src/main/webapp/staff/CaLamViec.jsp`

**Interfaces:**
- Consumes: faceConfig từ servlet xử lý staff ca lam (cần update servlet tương tự Task 10 Step 1)
- Produces: face modal tương tự guard, áp dụng cho nút checkin/checkout của staff

- [ ] **Step 1: Tìm servlet load CaLamViec.jsp của staff và thêm faceConfig**

```bash
grep -r "CaLamViec.jsp" /home/nhan/Downloads/V-SPORT/src/main/java --include="*.java" -l
```

Mở servlet đó, thêm pattern tương tự Task 10 Step 1 (import + field + load faceConfig + setAttribute).

- [ ] **Step 2: Tìm nút checkin/checkout trong staff/CaLamViec.jsp**

```bash
grep -n "checkin\|checkout\|VÀO CA\|KẾT THÚC" src/main/webapp/staff/CaLamViec.jsp | head -20
```

Thêm nút "ĐIỂM DANH KHUÔN MẶT" và modal tương tự Task 10 Steps 2-3, chỉ thay URL action từ `/guard/diem-danh` thành URL của staff checkin servlet.

- [ ] **Step 3: Thêm face-api.js CDN script và face-attendance.js vào staff/CaLamViec.jsp**

```jsp
<script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/face-attendance.js"></script>
```

- [ ] **Step 4: Commit**
```bash
git add src/main/webapp/staff/CaLamViec.jsp
git commit -m "feat(face): tích hợp face modal vào trang ca làm việc staff"
```

---

## Task 12: Manager Upload Ảnh Khuôn Mặt Nhân Viên

**Files:**
- Modify: `src/main/webapp/manager/NhanSu.jsp`

**Interfaces:**
- Consumes: `POST /face/enroll?targetAccountId=X` với multipart form (photo + descriptor)
- Produces: Upload UI trong modal nhân viên, hiển thị trạng thái đã enroll hay chưa

- [ ] **Step 1: Thêm section face trong modal nhân viên của NhanSu.jsp**

Tìm modal chi tiết nhân viên trong `NhanSu.jsp` (grep cho `modal` hoặc `chi tiết nhân viên`), thêm tab hoặc section:

```jsp
<%-- Thêm vào modal chi tiết nhân viên --%>
<div class="border-t border-zinc-100 pt-4 mt-4">
  <h4 class="font-bold text-zinc-700 text-sm mb-3 flex items-center gap-2">
    <span class="material-symbols-outlined text-[18px] text-rose-500" style="font-variation-settings:'FILL' 1">face</span>
    Khuôn mặt điểm danh
  </h4>
  <div id="managerFaceStatus" class="text-sm text-zinc-400 mb-3">Đang tải...</div>
  <div class="flex gap-3 items-start">
    <div id="managerFacePreview" class="w-20 h-20 rounded-xl bg-zinc-100 overflow-hidden hidden">
      <img id="managerFaceImg" class="w-full h-full object-cover" alt="Face photo"/>
    </div>
    <div class="flex-1">
      <p class="text-xs text-zinc-400 mb-2">Upload ảnh chân dung rõ mặt (JPG/PNG, tối đa 5MB)</p>
      <div class="flex gap-2">
        <input type="file" id="managerFaceFile" accept="image/jpeg,image/png" class="hidden"
               onchange="previewManagerFace(event)"/>
        <button type="button" onclick="document.getElementById('managerFaceFile').click()"
                class="text-xs bg-zinc-100 hover:bg-zinc-200 text-zinc-700 font-semibold px-3 py-2 rounded-lg transition">
          Chọn ảnh
        </button>
        <button type="button" id="btnManagerSaveFace" onclick="saveManagerFace()" disabled
                class="text-xs bg-rose-600 hover:bg-rose-700 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-semibold px-3 py-2 rounded-lg transition">
          Lưu khuôn mặt
        </button>
      </div>
      <p id="managerFaceUploadStatus" class="text-xs mt-2 min-h-[1rem]"></p>
    </div>
  </div>
</div>
```

- [ ] **Step 2: Thêm script xử lý manager face upload vào NhanSu.jsp**

```javascript
let _managerTargetId = null;
let _managerFaceDescriptor = null;
let _managerFacePhoto = null;
let _managerModelsLoaded = false;
const FACE_MODEL_URL = contextPath + '/assets/face-models';

async function loadManagerFaceStatus(accountId) {
  _managerTargetId = accountId;
  const res = await fetch(contextPath + '/face/enroll?targetAccountId=' + accountId);
  const data = await res.json();
  const statusEl = document.getElementById('managerFaceStatus');
  const previewEl = document.getElementById('managerFacePreview');
  const imgEl = document.getElementById('managerFaceImg');
  if (data.enrolled) {
    statusEl.innerHTML = '<span class="text-green-600 font-semibold">✓ Đã đăng ký khuôn mặt</span> — ' + (data.enrolledAt || '');
    if (data.imagePath) {
      imgEl.src = contextPath + data.imagePath;
      previewEl.classList.remove('hidden');
    }
  } else {
    statusEl.textContent = 'Chưa đăng ký khuôn mặt';
  }
}

async function previewManagerFace(event) {
  const file = event.target.files[0];
  if (!file) return;
  const statusEl = document.getElementById('managerFaceUploadStatus');
  statusEl.textContent = 'Đang phân tích khuôn mặt...';

  if (!_managerModelsLoaded) {
    await Promise.all([
      faceapi.nets.tinyFaceDetector.loadFromUri(FACE_MODEL_URL),
      faceapi.nets.faceLandmark68TinyNet.loadFromUri(FACE_MODEL_URL),
      faceapi.nets.faceRecognitionNet.loadFromUri(FACE_MODEL_URL)
    ]);
    _managerModelsLoaded = true;
  }

  const img = await faceapi.bufferToImage(file);
  const detection = await faceapi.detectSingleFace(img, new faceapi.TinyFaceDetectorOptions())
    .withFaceLandmarks(true).withFaceDescriptor();

  if (!detection) {
    statusEl.textContent = '✗ Không tìm thấy khuôn mặt trong ảnh. Chọn ảnh khác.';
    statusEl.className = 'text-xs mt-2 text-red-600';
    return;
  }

  _managerFaceDescriptor = JSON.stringify(Array.from(detection.descriptor));
  _managerFacePhoto = null; // sẽ upload file gốc

  statusEl.textContent = '✓ Nhận diện thành công. Nhấn "Lưu khuôn mặt".';
  statusEl.className = 'text-xs mt-2 text-green-600 font-semibold';
  document.getElementById('btnManagerSaveFace').disabled = false;

  // Preview
  document.getElementById('managerFaceImg').src = URL.createObjectURL(file);
  document.getElementById('managerFacePreview').classList.remove('hidden');
}

async function saveManagerFace() {
  if (!_managerFaceDescriptor || !_managerTargetId) return;
  const statusEl = document.getElementById('managerFaceUploadStatus');
  statusEl.textContent = 'Đang lưu...';

  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content || '';
  const file = document.getElementById('managerFaceFile').files[0];
  const formData = new FormData();
  formData.append('descriptor', _managerFaceDescriptor);
  if (file) formData.append('photo', file);
  formData.append('_csrf', csrfToken);

  const res = await fetch(contextPath + '/face/enroll?targetAccountId=' + _managerTargetId, {
    method: 'POST', body: formData
  });
  const data = await res.json();
  if (data.success) {
    statusEl.textContent = '✓ Đã lưu khuôn mặt thành công!';
    statusEl.className = 'text-xs mt-2 text-green-600 font-bold';
    document.getElementById('btnManagerSaveFace').disabled = true;
  } else {
    statusEl.textContent = '✗ Lỗi: ' + (data.error || 'Không thể lưu');
    statusEl.className = 'text-xs mt-2 text-red-600';
  }
}
```

Khi mở modal nhân viên, gọi `loadManagerFaceStatus(accountId)`.

- [ ] **Step 3: Thêm face-api.js CDN vào head của NhanSu.jsp nếu chưa có**
```jsp
<script src="https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js"></script>
```

- [ ] **Step 4: Commit**
```bash
git add src/main/webapp/manager/NhanSu.jsp
git commit -m "feat(face): manager upload ảnh khuôn mặt cho nhân viên"
```

---

## Task 13: Navigation Links + Sidebar

**Files:**
- Modify: `src/main/webapp/guard/common/sidebar.jsp`
- Modify: `src/main/webapp/staff/common/header.jsp` (hoặc sidebar)
- Modify: `src/main/webapp/manager/common/sidebar.jsp` (nếu có)

- [ ] **Step 1: Thêm link "Đăng ký khuôn mặt" vào guard sidebar**

Mở `src/main/webapp/guard/common/sidebar.jsp`, tìm phần menu "Công việc", thêm sau "Điểm danh ca":

```jsp
<a href="${pageContext.request.contextPath}/guard/enroll-face"
   class="sidebar-link flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium
          ${pageContext.request.servletPath == '/guard/enroll-face' ? 'bg-rose-50 text-rose-700 font-bold' : 'text-zinc-600 hover:bg-zinc-50'}">
  <span class="material-symbols-outlined text-[20px]" style="font-variation-settings:'FILL' 1">face</span>
  Đăng ký khuôn mặt
</a>
```

- [ ] **Step 2: Thêm link tương tự vào staff navigation**

Mở `src/main/webapp/staff/common/header.jsp` (hoặc sidebar), thêm link `/staff/enroll-face`.

- [ ] **Step 3: Thêm link "Cài đặt khuôn mặt" vào manager sidebar**

Thêm vào mục "Nhân sự" của manager sidebar:
```jsp
<a href="${pageContext.request.contextPath}/manager/face-settings"
   class="...">
  <span class="material-symbols-outlined ...">face</span>
  Cài đặt điểm danh mặt
</a>
```

- [ ] **Step 4: Commit**
```bash
git add src/main/webapp/guard/common/sidebar.jsp \
        src/main/webapp/staff/common/header.jsp
git commit -m "feat(face): thêm navigation links cho face enrollment và face settings"
```

---

## Kiểm tra tổng thể sau khi hoàn thành

- [ ] Guard đăng ký khuôn mặt tại `/guard/enroll-face` → camera bật, detect face, lưu thành công
- [ ] Guard vào `/guard/diem-danh` → nhấn "ĐIỂM DANH KHUÔN MẶT" → modal mở, thực hiện 2 challenge → server trả về confidence > 60% → ca chuyển sang CheckedIn
- [ ] Guard kết thúc ca bằng face checkout → ca chuyển sang CheckedOut
- [ ] Nếu `faceRequired=false`: nút "Thủ công" vẫn hoạt động bình thường
- [ ] Manager bật `faceRequired=true` tại `/manager/face-settings` → nút thủ công biến mất
- [ ] Manager upload ảnh cho nhân viên tại NhanSu.jsp → descriptor được lưu, guard điểm danh khớp
- [ ] Replay attack: gửi lại cùng token → server trả `Token đã được sử dụng`
- [ ] Ảnh tĩnh: challenge blink fail → không thể pass
