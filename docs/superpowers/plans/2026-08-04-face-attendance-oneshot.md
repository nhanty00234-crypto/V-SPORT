# Điểm danh khuôn mặt một chạm — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cho phép đăng ký nhiều mẫu khuôn mặt mỗi nhân viên, thay ngưỡng nhận diện bằng thanh kéo có xem trước, và rút luồng điểm danh của nhân viên/bảo vệ xuống còn một nút không challenge.

**Architecture:** Logic so khớp descriptor được tách ra một lớp thuần `org.example.util.FaceDescriptorMatcher` — parse JSON descriptor (một mẫu cũ hoặc nhiều mẫu mới) và tính khoảng cách nhỏ nhất. Lớp này không chạm DB nên unit-test được bằng JUnit. Servlet và JavaScript đều gọi cùng một quy tắc: khoảng cách của một khuôn mặt tới một tài khoản là min trên các mẫu. Không đổi schema DB — cột `Accounts.FaceDescriptor` đổi từ `[128 số]` sang `[[128 số], …]`, đọc theo nhánh tương thích ngược.

**Tech Stack:** Java 17 servlet (Jakarta), Gson, JUnit 5 + Maven Surefire, JSP + Tailwind CDN, face-api.js (TinyFaceDetector) phía client, SQL Server.

## Global Constraints

- Không có migration DB. Không thêm/sửa cột. Cột `Accounts.FaceDescriptor` giữ nguyên kiểu `NVARCHAR(MAX)`.
- Dữ liệu descriptor cũ (mảng phẳng 128 số) phải tiếp tục hoạt động không cần thao tác thủ công.
- Giữ nguyên model nhận diện: `tinyFaceDetector` + `faceLandmark68TinyNet` + `faceRecognitionNet`. Không đổi sang SSD MobileNet.
- Ngưỡng nhận diện là một giá trị cho mỗi cơ sở, lưu ở `CoSoFaceConfig.ConfidenceMin`. Không có ngưỡng riêng theo từng nhân viên.
- Toàn bộ chuỗi hiển thị cho người dùng bằng tiếng Việt, giọng văn khớp code hiện có.
- `FaceLivenessPassed` ghi `false` cho mọi bản ghi tạo bởi luồng điểm danh mới.
- Server vẫn là nơi phán quyết cuối cùng; kiểm tra phía client chỉ phục vụ UX.
- Chạy test bằng `mvn -q test -Dtest=<TênTest>`. **Không** chạy toàn bộ `mvn test` — bộ test của repo có các lớp cần kết nối DB thật và luôn fail; đó là tình trạng có sẵn, không phải do thay đổi này.
- Commit sau mỗi task, message tiếng Việt theo dạng `feat(face): …` / `fix(face): …`, kèm dòng `Co-Authored-By: Claude <noreply@anthropic.com>`.

---

## File Structure

**Tạo mới:**
- `src/main/java/org/example/util/FaceDescriptorMatcher.java` — parse descriptor JSON (một hoặc nhiều mẫu) và tính khoảng cách nhỏ nhất. Thuần, không phụ thuộc servlet/DB.
- `src/test/java/org/example/util/FaceDescriptorMatcherTest.java` — unit test cho lớp trên.

**Sửa:**
- `src/main/java/org/example/controller/face/FaceCheckInServlet.java` — dùng matcher, ghi liveness `false`.
- `src/main/java/org/example/controller/face/FaceChallengeServlet.java` — trả `challenges: []` và `descriptors` (mảng nhiều mẫu).
- `src/main/java/org/example/controller/face/FaceEnrollServlet.java` — nhận mảng nhiều descriptor, chuẩn hoá về dạng lồng trước khi lưu.
- `src/main/webapp/assets/js/face-attendance.js` — bỏ challenge, thêm vòng bắt 3 frame liên tiếp + timeout 15s, min-distance trên nhiều mẫu.
- `src/main/webapp/assets/js/attendance-shared.js` — bỏ đồng hồ %, thêm nút Thử lại.
- `src/main/webapp/staff/CaLamViec.jsp`, `src/main/webapp/guard/DiemDanh.jsp` — gỡ khối hiển thị % khỏi modal, thêm nút Thử lại.
- `src/main/webapp/manager/FaceSettings.jsp` — slider ngưỡng + xem trước sống; modal đăng ký chụp nhiều mẫu.
- `src/main/webapp/manager/NhanSu.jsp` — chọn nhiều ảnh khi đăng ký.

---

### Task 1: Lớp so khớp descriptor nhiều mẫu

Đây là nền cho mọi task sau. Nó chứa toàn bộ quy tắc "một mẫu hay nhiều mẫu" ở đúng một chỗ, để servlet không phải tự đoán định dạng.

**Files:**
- Create: `src/main/java/org/example/util/FaceDescriptorMatcher.java`
- Test: `src/test/java/org/example/util/FaceDescriptorMatcherTest.java`

**Interfaces:**
- Consumes: Gson (`com.google.gson`), đã có trong pom.
- Produces:
  - `static double[][] parse(String json)` — trả mảng các mẫu; `null`/rỗng/JSON hỏng → mảng độ dài 0.
  - `static double distance(double[] a, double[] b)` — Euclidean, so tới độ dài nhỏ hơn.
  - `static double minDistance(double[][] samples, double[] incoming)` — nhỏ nhất trên các mẫu; không có mẫu → `Double.MAX_VALUE`.
  - `static String toStorageJson(double[][] samples)` — serialize dạng lồng để lưu DB.

- [ ] **Step 1: Viết test thất bại**

Tạo `src/test/java/org/example/util/FaceDescriptorMatcherTest.java`:

```java
package org.example.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class FaceDescriptorMatcherTest {

    /** Tạo descriptor 128 chiều với mọi phần tử bằng v. */
    private static double[] flat(double v) {
        double[] d = new double[128];
        java.util.Arrays.fill(d, v);
        return d;
    }

    private static String jsonOf(double... values) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < values.length; i++) {
            if (i > 0) sb.append(',');
            sb.append(values[i]);
        }
        return sb.append(']').toString();
    }

    @Test
    void parseDangCuMotMauPhangThanhMotMau() {
        String legacy = jsonOf(flat(0.1));
        double[][] samples = FaceDescriptorMatcher.parse(legacy);
        assertEquals(1, samples.length);
        assertEquals(128, samples[0].length);
        assertEquals(0.1, samples[0][0], 1e-9);
    }

    @Test
    void parseDangMoiNhieuMau() {
        String nested = "[" + jsonOf(flat(0.1)) + "," + jsonOf(flat(0.2)) + "]";
        double[][] samples = FaceDescriptorMatcher.parse(nested);
        assertEquals(2, samples.length);
        assertEquals(0.2, samples[1][0], 1e-9);
    }

    @Test
    void parseDauVaoHongTraVeRong() {
        assertEquals(0, FaceDescriptorMatcher.parse(null).length);
        assertEquals(0, FaceDescriptorMatcher.parse("").length);
        assertEquals(0, FaceDescriptorMatcher.parse("[]").length);
        assertEquals(0, FaceDescriptorMatcher.parse("khong-phai-json").length);
    }

    @Test
    void distanceTinhDungEuclidean() {
        double[] a = {0.0, 0.0, 0.0};
        double[] b = {3.0, 4.0, 0.0};
        assertEquals(5.0, FaceDescriptorMatcher.distance(a, b), 1e-9);
    }

    @Test
    void minDistanceLayMauGanNhat() {
        double[][] samples = { flat(0.0), flat(0.5) };
        double[] incoming = flat(0.5);
        assertEquals(0.0, FaceDescriptorMatcher.minDistance(samples, incoming), 1e-9);
    }

    @Test
    void minDistanceKhongCoMauTraVeMaxValue() {
        assertEquals(Double.MAX_VALUE,
                FaceDescriptorMatcher.minDistance(new double[0][], flat(0.1)), 0.0);
    }

    @Test
    void toStorageJsonLuonSinhDangLong() {
        String json = FaceDescriptorMatcher.toStorageJson(new double[][]{ {1.0, 2.0} });
        assertTrue(json.startsWith("[["), "Phải là mảng lồng, nhận được: " + json);
        // Đọc lại ra đúng một mẫu
        assertEquals(1, FaceDescriptorMatcher.parse(json).length);
    }
}
```

- [ ] **Step 2: Chạy test để xác nhận nó fail**

```bash
mvn -q test -Dtest=FaceDescriptorMatcherTest
```

Kỳ vọng: FAIL khi biên dịch — `cannot find symbol: class FaceDescriptorMatcher`.

- [ ] **Step 3: Viết implementation tối thiểu**

Tạo `src/main/java/org/example/util/FaceDescriptorMatcher.java`:

```java
package org.example.util;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;

/**
 * So khớp khuôn mặt với nhiều mẫu đã đăng ký.
 *
 * Cột Accounts.FaceDescriptor có hai định dạng cùng tồn tại:
 *   - cũ:  [0.1, 0.2, ...]              (đúng một mẫu 128 chiều)
 *   - mới: [[0.1, ...], [0.3, ...]]     (nhiều mẫu)
 * parse() nhận cả hai nên bản ghi cũ không cần migration.
 */
public final class FaceDescriptorMatcher {

    private static final Gson GSON = new Gson();
    private static final double[][] EMPTY = new double[0][];

    private FaceDescriptorMatcher() {}

    /** Đọc descriptor đã lưu thành danh sách mẫu. Dữ liệu hỏng trả mảng rỗng. */
    public static double[][] parse(String json) {
        if (json == null || json.trim().isEmpty()) return EMPTY;
        try {
            JsonArray outer = GSON.fromJson(json, JsonArray.class);
            if (outer == null || outer.size() == 0) return EMPTY;

            JsonElement first = outer.get(0);
            if (first.isJsonPrimitive()) {
                // Định dạng cũ: một mẫu phẳng
                return new double[][]{ GSON.fromJson(outer, double[].class) };
            }

            double[][] samples = new double[outer.size()][];
            for (int i = 0; i < outer.size(); i++) {
                samples[i] = GSON.fromJson(outer.get(i), double[].class);
            }
            return samples;
        } catch (Exception e) {
            return EMPTY;
        }
    }

    /** Khoảng cách Euclidean, so tới độ dài nhỏ hơn của hai vector. */
    public static double distance(double[] a, double[] b) {
        if (a == null || b == null) return Double.MAX_VALUE;
        double sum = 0;
        int len = Math.min(a.length, b.length);
        for (int i = 0; i < len; i++) {
            double diff = a[i] - b[i];
            sum += diff * diff;
        }
        return Math.sqrt(sum);
    }

    /** Khoảng cách tới mẫu gần nhất. Không có mẫu nào → Double.MAX_VALUE. */
    public static double minDistance(double[][] samples, double[] incoming) {
        if (samples == null || samples.length == 0) return Double.MAX_VALUE;
        double best = Double.MAX_VALUE;
        for (double[] sample : samples) {
            double d = distance(sample, incoming);
            if (d < best) best = d;
        }
        return best;
    }

    /** Serialize về dạng lồng để lưu DB — luôn ghi định dạng mới. */
    public static String toStorageJson(double[][] samples) {
        return GSON.toJson(samples == null ? EMPTY : samples);
    }
}
```

- [ ] **Step 4: Chạy test để xác nhận pass**

```bash
mvn -q test -Dtest=FaceDescriptorMatcherTest
```

Kỳ vọng: PASS, 7 test.

- [ ] **Step 5: Commit**

```bash
git add src/main/java/org/example/util/FaceDescriptorMatcher.java src/test/java/org/example/util/FaceDescriptorMatcherTest.java
git commit -m "feat(face): lớp so khớp descriptor nhiều mẫu

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 2: Server dùng min-distance và bỏ liveness

Đổi hai servlet sang dùng matcher của Task 1. Sau task này server đã chấp nhận nhiều mẫu, dù giao diện đăng ký chưa tạo được chúng.

**Files:**
- Modify: `src/main/java/org/example/controller/face/FaceCheckInServlet.java:131-137`, `:168`
- Modify: `src/main/java/org/example/controller/face/FaceChallengeServlet.java:73-76`, `:100-110`
- Test: `src/test/java/org/example/util/FaceDescriptorMatcherTest.java` (đã có, dùng lại làm hồi quy)

**Interfaces:**
- Consumes: `FaceDescriptorMatcher.parse`, `.minDistance` từ Task 1.
- Produces: JSON của `/face/challenge` đổi hình dạng — khóa `descriptors` (mảng các mảng, thay cho `descriptor` số ít) và `challenges` luôn là `[]`. Task 4 dựa vào hai khóa này.

- [ ] **Step 1: Sửa FaceCheckInServlet sang min-distance**

Trong `FaceCheckInServlet.java`, thêm import:

```java
import org.example.util.FaceDescriptorMatcher;
```

Thay khối tại dòng 131-137:

```java
        double[] storedDesc   = gson.fromJson(faceData.getFaceDescriptor(), double[].class);
        double[] incomingDesc = new double[128];
        for (int i = 0; i < Math.min(128, descArr.size()); i++) {
            incomingDesc[i] = descArr.get(i).getAsDouble();
        }

        double distance = euclideanDistance(storedDesc, incomingDesc);
```

bằng:

```java
        // Nhiều mẫu: lấy khoảng cách tới mẫu gần nhất. parse() nhận cả định dạng cũ một mẫu.
        double[][] storedSamples = FaceDescriptorMatcher.parse(faceData.getFaceDescriptor());
        if (storedSamples.length == 0) {
            resp.getWriter().write("{\"success\":false,\"error\":\"Dữ liệu khuôn mặt đã lưu bị lỗi. Liên hệ quản lý đăng ký lại.\"}");
            return;
        }

        double[] incomingDesc = new double[128];
        for (int i = 0; i < Math.min(128, descArr.size()); i++) {
            incomingDesc[i] = descArr.get(i).getAsDouble();
        }

        double distance = FaceDescriptorMatcher.minDistance(storedSamples, incomingDesc);
```

- [ ] **Step 2: Ghi liveness false**

Trong cùng file, dòng 168, đổi:

```java
            ok = caLamViecDAO.faceCheckIn(caId, imagePath, confidence, true);
```

thành:

```java
            // Luồng một chạm không còn challenge tư thế; hậu kiểm dựa vào ảnh snapshot.
            ok = caLamViecDAO.faceCheckIn(caId, imagePath, confidence, false);
```

- [ ] **Step 3: Gỡ helper không còn dùng**

Xoá phương thức `euclideanDistance` (dòng 185-193) khỏi `FaceCheckInServlet.java` — matcher đã thay thế. Nếu trình biên dịch báo còn chỗ gọi khác, giữ lại và bỏ qua bước này.

- [ ] **Step 4: FaceChallengeServlet trả challenges rỗng và nhiều descriptor**

Trong `FaceChallengeServlet.java`, thêm import:

```java
import org.example.util.FaceDescriptorMatcher;
```

Thay khối chọn challenge (dòng 73-76):

```java
        // Random 2 trong 4 challenges, shuffle thứ tự
        List<String> pool = new ArrayList<>(Arrays.asList(ALL_CHALLENGES));
        Collections.shuffle(pool);
        List<String> chosen = pool.subList(0, 2);
```

bằng:

```java
        // Không còn challenge tư thế: luồng điểm danh chỉ bắt khuôn mặt rồi gửi.
        // Token vẫn được cấp để chống phát lại (replay) ở /face/checkin.
        List<String> chosen = Collections.emptyList();
```

Thay khối trả descriptor (dòng 107-109):

```java
        if (faceData != null && faceData.getFaceDescriptor() != null) {
            result.put("descriptor", gson.fromJson(faceData.getFaceDescriptor(), double[].class));
        }
```

bằng:

```java
        if (faceData != null && faceData.getFaceDescriptor() != null) {
            double[][] samples = FaceDescriptorMatcher.parse(faceData.getFaceDescriptor());
            if (samples.length > 0) result.put("descriptors", samples);
        }
```

Trường `ALL_CHALLENGES` không còn được dùng — xoá dòng 28.

- [ ] **Step 5: Biên dịch**

```bash
mvn -q -DskipTests compile
```

Kỳ vọng: BUILD SUCCESS, không lỗi biên dịch.

- [ ] **Step 6: Chạy lại test của matcher**

```bash
mvn -q test -Dtest=FaceDescriptorMatcherTest
```

Kỳ vọng: PASS.

- [ ] **Step 7: Commit**

```bash
git add src/main/java/org/example/controller/face/FaceCheckInServlet.java src/main/java/org/example/controller/face/FaceChallengeServlet.java
git commit -m "feat(face): server so khớp nhiều mẫu, bỏ challenge tư thế

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 3: Enroll servlet nhận nhiều mẫu

Không có bước này thì giao diện ở Task 5/6 không có chỗ để gửi nhiều mẫu.

**Files:**
- Modify: `src/main/java/org/example/controller/face/FaceEnrollServlet.java:78-115`, `:46-52`

**Interfaces:**
- Consumes: `FaceDescriptorMatcher.parse`, `.toStorageJson` từ Task 1.
- Produces: `/face/enroll` POST nhận thêm khoá JSON `descriptors` (mảng các mảng 128 số) và field multipart `descriptors`; vẫn nhận `descriptor` số ít của client cũ. `/face/enroll` GET trả thêm `sampleCount` (số nguyên) và `descriptors` (mảng các mảng 128 số, vắng mặt nếu chưa đăng ký). Task 6, 7 và 8 dùng các khoá này.

- [ ] **Step 1: Thêm helper chuẩn hoá vào FaceEnrollServlet**

Thêm import:

```java
import org.example.util.FaceDescriptorMatcher;
```

Thêm phương thức vào phần `// --- helpers ---` của `FaceEnrollServlet.java`:

```java
    /**
     * Chuẩn hoá payload descriptor về JSON dạng lồng để lưu.
     * Nhận cả `descriptors` (nhiều mẫu, client mới) và `descriptor` (một mẫu, client cũ).
     * Trả null nếu không có mẫu hợp lệ nào.
     */
    private String normalizeDescriptors(String rawJson) {
        double[][] samples = FaceDescriptorMatcher.parse(rawJson);
        java.util.List<double[]> valid = new java.util.ArrayList<>();
        for (double[] s : samples) {
            if (s != null && s.length >= 128) valid.add(s);
        }
        if (valid.isEmpty()) return null;
        return FaceDescriptorMatcher.toStorageJson(valid.toArray(new double[0][]));
    }
```

- [ ] **Step 2: Nhánh JSON nhận nhiều mẫu**

Thay khối nhánh JSON (dòng 86-97):

```java
            if (body == null || !body.has("descriptor")) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (cần 128 số)\"}");
                return;
            }
            JsonArray arr = body.get("descriptor").getAsJsonArray();
            if (arr == null || arr.size() < 128) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (cần 128 số)\"}");
                return;
            }
            descriptorJson = arr.toString();
            String photo = body.has("photo") ? body.get("photo").getAsString() : null;
            imagePath = savePhotoBase64(photo, targetId);
```

bằng:

```java
            JsonArray arr = null;
            if (body != null && body.has("descriptors")) {
                arr = body.get("descriptors").getAsJsonArray();
            } else if (body != null && body.has("descriptor")) {
                // Client cũ gửi một mẫu phẳng — bọc lại thành danh sách một phần tử
                JsonArray single = body.get("descriptor").getAsJsonArray();
                arr = new JsonArray();
                arr.add(single);
            }

            descriptorJson = arr == null ? null : normalizeDescriptors(arr.toString());
            if (descriptorJson == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (mỗi mẫu cần 128 số)\"}");
                return;
            }

            String photo = body.has("photo") ? body.get("photo").getAsString() : null;
            imagePath = savePhotoBase64(photo, targetId);
```

- [ ] **Step 3: Nhánh multipart nhận nhiều mẫu**

Thay khối nhánh multipart (dòng 101-106):

```java
            String descField = req.getParameter("descriptor");
            if (descField == null || descField.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu descriptor\"}");
                return;
            }
            descriptorJson = descField;
```

bằng:

```java
            String descField = req.getParameter("descriptors");
            if (descField == null || descField.isEmpty()) descField = req.getParameter("descriptor");
            if (descField == null || descField.isEmpty()) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Thiếu descriptor\"}");
                return;
            }
            descriptorJson = normalizeDescriptors(descField);
            if (descriptorJson == null) {
                resp.getWriter().write("{\"success\":false,\"error\":\"Descriptor không hợp lệ (mỗi mẫu cần 128 số)\"}");
                return;
            }
```

- [ ] **Step 4: GET trả về số mẫu và các mẫu**

Trong `doGet`, sau dòng `result.put("enrolled", ...)`, thêm:

```java
        double[][] samples = faceData == null
                ? new double[0][]
                : FaceDescriptorMatcher.parse(faceData.getFaceDescriptor());
        result.put("sampleCount", samples.length);
        // Manager cần các mẫu để xem trước ngưỡng ở trang cài đặt.
        // Endpoint này vốn đã giới hạn cho manager cùng cơ sở.
        if (samples.length > 0) result.put("descriptors", samples);
```

- [ ] **Step 5: Biên dịch**

```bash
mvn -q -DskipTests compile
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 6: Commit**

```bash
git add src/main/java/org/example/controller/face/FaceEnrollServlet.java
git commit -m "feat(face): enroll nhận nhiều mẫu khuôn mặt

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 4: Luồng điểm danh một chạm phía client

Đây là task người dùng cảm nhận trực tiếp: bấm nút, ~1-2 giây, xong.

**Files:**
- Modify: `src/main/webapp/assets/js/face-attendance.js` (viết lại phần lớn)

**Interfaces:**
- Consumes: `/face/challenge` trả `descriptors` và `challenges: []` (Task 2).
- Produces: `FaceAttendance.init(opts)` giữ nguyên tên và trả `Promise<boolean>`; `FaceAttendance.start()`, `.stop()` giữ nguyên. Bỏ hỗ trợ `opts.matchEl` / `opts.matchBarEl` / `opts.matchHintEl` — truyền vào cũng bị bỏ qua. Thêm `opts.onTimeout` (hàm không tham số, gọi khi quá 15 giây). Task 5 dựa vào các điểm này.

- [ ] **Step 1: Thay hằng số và biến trạng thái**

Ở đầu `face-attendance.js`, thay toàn bộ khối hằng số + biến (dòng 4-24) bằng:

```javascript
    const DETECTION_INTERVAL_MS = 100;  // 10fps
    const REQUIRED_STREAK = 3;          // số frame liên tiếp đạt ngưỡng mới chấp nhận
    const TIMEOUT_MS = 15000;           // quá thời gian này thì dừng và mời thử lại

    let _opts = {};
    let _stream = null;
    let _intervalId = null;
    let _timeoutId = null;
    let _token = null;
    let _capturedDescriptor = null;
    let _capturedSnapshot = null;
    let _modelsLoaded = false;
    let _enrolledSamples = [];       // các mẫu đã đăng ký, để chấm tại chỗ
    let _threshold = 0.6;            // khoảng cách Euclidean tối đa được duyệt
    let _streak = 0;                 // số frame liên tiếp đang đạt
    let _bestDistance = Infinity;    // frame tốt nhất trong chuỗi hiện tại
    let _bestDetection = null;
```

- [ ] **Step 2: Gỡ các hàm liveness và thay bằng min-distance**

Xoá các hàm `eyeAspectRatio`, `detectChallenge`, hằng `CHALLENGE_LABELS`, và hàm `updateMatch`. Xoá hàm `dist` nếu không còn chỗ gọi.

Thêm hàm min-distance ngay sau `euclidean`:

```javascript
    /** Khoảng cách tới mẫu đã đăng ký gần nhất. Không có mẫu → Infinity. */
    function minDistance(descriptor) {
        let best = Infinity;
        for (let i = 0; i < _enrolledSamples.length; i++) {
            const d = euclidean(_enrolledSamples[i], descriptor);
            if (d < best) best = d;
        }
        return best;
    }
```

- [ ] **Step 3: Viết lại vòng detect**

Thay toàn bộ `detectionLoop` bằng:

```javascript
    async function detectionLoop() {
        const video = _opts.videoEl;
        const detection = await faceapi
            .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
            .withFaceLandmarks(true)  // true = tiny landmark model
            .withFaceDescriptor();

        if (!detection) {
            _streak = 0;
            _bestDistance = Infinity;
            _bestDetection = null;
            setStatus('Đưa khuôn mặt vào giữa khung hình', 'info');
            return;
        }

        const distance = minDistance(detection.descriptor);

        if (distance > _threshold) {
            _streak = 0;
            _bestDistance = Infinity;
            _bestDetection = null;
            setStatus('Đang nhận diện...', 'info');
            return;
        }

        // Frame đạt: giữ frame khớp nhất trong chuỗi để gửi lên server
        _streak++;
        if (distance < _bestDistance) {
            _bestDistance = distance;
            _bestDetection = detection;
        }
        setStatus('Đang nhận diện...', 'info');

        if (_streak >= REQUIRED_STREAK) {
            stopLoop();
            _capturedDescriptor = Array.from(_bestDetection.descriptor);
            _capturedSnapshot = captureSnapshot(video);
            setStatus('Đang gửi...', 'info');
            await submitToServer();
        }
    }

    /** Dừng vòng detect và bộ đếm timeout, nhưng giữ camera đang mở. */
    function stopLoop() {
        if (_intervalId) { clearInterval(_intervalId); _intervalId = null; }
        if (_timeoutId) { clearTimeout(_timeoutId); _timeoutId = null; }
    }

    function onTimeout() {
        stopLoop();
        stopCamera();
        setStatus('Chưa nhận ra bạn. Hãy đứng nơi đủ sáng, bỏ khẩu trang và thử lại.', 'error');
        if (_opts.onTimeout) _opts.onTimeout();
    }
```

- [ ] **Step 4: Cập nhật init và start**

Trong `init`, thay khối lấy dữ liệu từ server (dòng 251-264 của bản gốc) bằng:

```javascript
        _token = data.token;
        _enrolledSamples = data.descriptors || [];
        if (typeof data.threshold === 'number') _threshold = data.threshold;

        if (!_enrolledSamples.length) {
            setStatus('Bạn chưa được đăng ký khuôn mặt. Liên hệ quản lý để đăng ký.', 'error');
            if (_opts.onError) _opts.onError('Chưa đăng ký khuôn mặt');
            return false;
        }
        return true;
```

Thay `start` bằng:

```javascript
    async function start() {
        _streak = 0;
        _bestDistance = Infinity;
        _bestDetection = null;

        _stream = await navigator.mediaDevices.getUserMedia({
            video: { width: 640, height: 480, facingMode: 'user' }
        });
        _opts.videoEl.srcObject = _stream;
        await new Promise(function (resolve) { _opts.videoEl.onloadedmetadata = resolve; });
        await _opts.videoEl.play();

        setStatus('Đang nhận diện...', 'info');
        _intervalId = setInterval(detectionLoop, DETECTION_INTERVAL_MS);
        _timeoutId = setTimeout(onTimeout, TIMEOUT_MS);
    }
```

Thay `stopCamera` bằng:

```javascript
    function stopCamera() {
        stopLoop();
        if (_stream) { _stream.getTracks().forEach(function (t) { t.stop(); }); _stream = null; }
    }
```

- [ ] **Step 5: Kiểm tra cú pháp JavaScript**

```bash
node --check src/main/webapp/assets/js/face-attendance.js
```

Kỳ vọng: không in ra gì (cú pháp hợp lệ).

- [ ] **Step 6: Xác nhận không còn tham chiếu challenge**

```bash
grep -n "challenge\|CHALLENGE\|matchEl\|matchBarEl\|matchHintEl\|_requiredPercent\|_maxDistance\|toPercent" src/main/webapp/assets/js/face-attendance.js
```

Kỳ vọng: chỉ còn dòng gọi `/face/challenge` trong `init` (đường dẫn endpoint giữ nguyên). Nếu còn dòng khác, xoá nốt.

- [ ] **Step 7: Commit**

```bash
git add src/main/webapp/assets/js/face-attendance.js
git commit -m "feat(face): điểm danh một chạm, bỏ challenge tư thế phía client

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 5: Modal điểm danh gọn lại, thêm nút Thử lại

**Files:**
- Modify: `src/main/webapp/assets/js/attendance-shared.js:81-134`
- Modify: `src/main/webapp/staff/CaLamViec.jsp:335-357`
- Modify: `src/main/webapp/guard/DiemDanh.jsp:168-192`

**Interfaces:**
- Consumes: `FaceAttendance.init/start/stop` và `opts.onTimeout` từ Task 4.
- Produces: `Attendance.retry()` — hàm không tham số, gọi lại phiên điểm danh hiện tại; JSP gắn vào nút Thử lại.

- [ ] **Step 1: Gỡ khối % khỏi modal của nhân viên**

Trong `src/main/webapp/staff/CaLamViec.jsp`, xoá toàn bộ khối từ `<%-- Mức độ khớp khuôn mặt theo thời gian thực --%>` tới thẻ `</div>` đóng khối đó (khối chứa `faceMatch`, `faceMatchBar`, `faceMatchHint`).

Ngay trước nút Hủy, thêm nút Thử lại:

```html
    <button type="button" id="faceRetryBtn" onclick="Attendance.retry()"
            class="w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl text-sm transition hidden">
      Thử lại
    </button>
```

- [ ] **Step 2: Gỡ khối % khỏi modal của bảo vệ**

Trong `src/main/webapp/guard/DiemDanh.jsp`, xoá khối `<div class="w-full">` chứa `faceMatch`, `faceMatchBar`, `faceMatchHint`.

Ngay trước nút Hủy, thêm:

```html
    <button type="button" id="faceRetryBtn" onclick="Attendance.retry()"
            class="w-full bg-rose-500 hover:bg-rose-600 text-white font-bold py-3 rounded-xl text-sm transition hidden">
      Thử lại
    </button>
```

- [ ] **Step 3: Cập nhật attendance-shared.js**

Thay `resetGauge` (dòng 81-87) bằng:

```javascript
  function resetGauge() {
    if (el('faceProgress')) el('faceProgress').style.width = '0%';
    if (el('faceRetryBtn')) el('faceRetryBtn').classList.add('hidden');
  }

  function showRetry() {
    if (el('faceRetryBtn')) el('faceRetryBtn').classList.remove('hidden');
  }
```

Thêm biến nhớ phiên hiện tại ngay trên `openModal`:

```javascript
  var _lastAction = null;
  var _lastCaId = null;
```

Trong `start(action, caId)`, ngay sau `resetGauge();` thêm:

```javascript
    _lastAction = action;
    _lastCaId = caId;
```

Trong đối tượng truyền cho `FaceAttendance.init`, xoá ba dòng `matchEl` / `matchBarEl` / `matchHintEl`, và thêm sau `onError`:

```javascript
      onTimeout: function () {
        showRetry();
      }
```

Cũng trong `onError`, thêm `showRetry();` ở cuối hàm để lỗi server cũng có đường thử lại.

Thêm hàm `retry` ngay sau `start`:

```javascript
  /** Chạy lại phiên điểm danh hiện tại sau khi hết giờ hoặc lỗi. */
  function retry() {
    if (_lastAction === null || _lastCaId === null) return;
    start(_lastAction, _lastCaId);
  }
```

Thêm `retry: retry,` vào đối tượng `return { ... }` ở cuối module.

- [ ] **Step 4: Kiểm tra cú pháp**

```bash
node --check src/main/webapp/assets/js/attendance-shared.js
```

Kỳ vọng: không in ra gì.

- [ ] **Step 5: Xác nhận JSP không còn tham chiếu mồ côi**

```bash
grep -rn "faceMatch" src/main/webapp/staff/CaLamViec.jsp src/main/webapp/guard/DiemDanh.jsp src/main/webapp/assets/js/
```

Kỳ vọng: không có kết quả nào.

- [ ] **Step 6: Commit**

```bash
git add src/main/webapp/assets/js/attendance-shared.js src/main/webapp/staff/CaLamViec.jsp src/main/webapp/guard/DiemDanh.jsp
git commit -m "feat(face): modal điểm danh gọn lại, thêm nút thử lại

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 6: Đăng ký nhiều mẫu ở modal FaceSettings

**Files:**
- Modify: `src/main/webapp/manager/FaceSettings.jsp:475-505` (phần thân modal và nút), `:553-708` (phần script)

**Interfaces:**
- Consumes: `/face/enroll` POST JSON khoá `descriptors` (Task 3).
- Produces: không có gì cho task sau.

- [ ] **Step 1: Thay khối "Chất lượng khuôn mặt" bằng dải mẫu**

Trong `FaceSettings.jsp`, thay khối `<%-- Chất lượng khuôn mặt theo thời gian thực --%>` (dòng 475-487) bằng:

```html
      <%-- Các mẫu đã chụp --%>
      <div>
        <div class="flex items-baseline justify-between mb-1.5">
          <span class="text-xs font-semibold text-zinc-500">Mẫu đã chụp</span>
          <span id="fsSampleCount" class="text-violet-600 font-black text-sm">0 / 3</span>
        </div>
        <div id="fsSampleStrip" class="flex gap-2"></div>
        <p class="text-[11px] text-zinc-400 mt-1.5">
          Chụp 3 mẫu ở góc và ánh sáng khác nhau để nhận diện ổn định hơn. Tối thiểu 1 mẫu.
        </p>
      </div>
```

- [ ] **Step 2: Thêm nút Chụp mẫu**

Thay khối nút (dòng 494-503) bằng:

```html
    <div class="px-5 pb-5 flex gap-2 shrink-0">
      <button type="button" id="fsBtnStart" onclick="fsStartCamera()"
              class="flex-1 h-11 rounded-xl bg-violet-600 hover:bg-violet-700 text-white font-bold text-sm transition flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[18px]">videocam</span>Mở camera
      </button>
      <button type="button" id="fsBtnCapture" onclick="fsCaptureSample()" disabled
              class="flex-1 h-11 rounded-xl bg-amber-500 hover:bg-amber-600 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-bold text-sm transition flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[18px]">photo_camera</span>Chụp mẫu
      </button>
      <button type="button" id="fsBtnSave" onclick="fsSaveEnroll()" disabled
              class="flex-1 h-11 rounded-xl bg-emerald-600 hover:bg-emerald-700 disabled:bg-zinc-200 disabled:text-zinc-400 text-white font-bold text-sm transition flex items-center justify-center gap-2">
        <span class="material-symbols-outlined text-[18px]">save</span>Lưu
      </button>
    </div>
```

- [ ] **Step 3: Thay state và các hàm quality trong script**

Trong khối `<script>`, thay khai báo state (dòng 553-560) bằng:

```javascript
  var FS_RECOMMENDED_SAMPLES = 3;
  var FS_MIN_DETECT_SCORE = 0.7;   // điểm tin cậy tối thiểu của bộ phát hiện để chụp
  var FS_DUP_DISTANCE = 0.2;       // gần hơn mức này coi như trùng mẫu cũ
  var FS_DIFF_DISTANCE = 0.6;      // xa hơn mức này có thể là người khác

  var _fsTargetId = null;
  var _fsStream = null;
  var _fsLoopId = null;
  var _fsModelsLoaded = false;
  var _fsSamples = [];      // [{descriptor: [...], snapshot: dataUrl}]
  var _fsLiveDetection = null;  // detection của frame mới nhất, dùng khi bấm Chụp mẫu
```

Xoá dòng `document.getElementById('fsRequired').textContent = FS_REQUIRED;` và xoá hàm `fsSetQuality`.

Thêm hàm quản lý dải mẫu:

```javascript
  function fsEuclidean(a, b) {
    var sum = 0;
    for (var i = 0; i < Math.min(a.length, b.length); i++) {
      var d = a[i] - b[i];
      sum += d * d;
    }
    return Math.sqrt(sum);
  }

  function fsRenderSamples() {
    var strip = document.getElementById('fsSampleStrip');
    strip.innerHTML = '';
    _fsSamples.forEach(function (s, idx) {
      var wrap = document.createElement('div');
      wrap.className = 'relative w-14 h-14 rounded-lg overflow-hidden bg-zinc-100 shrink-0';
      var img = document.createElement('img');
      img.src = s.snapshot;
      img.className = 'w-full h-full object-cover scale-x-[-1]';
      img.alt = 'Mẫu ' + (idx + 1);
      var del = document.createElement('button');
      del.type = 'button';
      del.className = 'absolute top-0 right-0 bg-black/60 text-white text-[10px] leading-none px-1 py-0.5';
      del.textContent = '×';
      del.onclick = function () { _fsSamples.splice(idx, 1); fsRenderSamples(); };
      wrap.appendChild(img);
      wrap.appendChild(del);
      strip.appendChild(wrap);
    });
    document.getElementById('fsSampleCount').textContent =
      _fsSamples.length + ' / ' + FS_RECOMMENDED_SAMPLES;
    document.getElementById('fsBtnSave').disabled = _fsSamples.length === 0;
  }
```

- [ ] **Step 4: Viết lại vòng detect và thêm chụp mẫu**

Thay `fsDetectLoop` bằng:

```javascript
  async function fsDetectLoop() {
    var video = document.getElementById('fsVideo');
    var det = await faceapi
      .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
      .withFaceLandmarks(true)
      .withFaceDescriptor();

    if (!det || det.detection.score < FS_MIN_DETECT_SCORE) {
      _fsLiveDetection = null;
      document.getElementById('fsBtnCapture').disabled = true;
      fsStatus('Chưa thấy khuôn mặt rõ — đưa mặt vào giữa khung, đủ sáng', 'text-zinc-500');
      return;
    }

    _fsLiveDetection = det;
    document.getElementById('fsBtnCapture').disabled = false;
    fsStatus('Đã sẵn sàng — nhấn "Chụp mẫu"', 'text-green-600 font-semibold');
  }

  /** Chụp frame hiện tại thành một mẫu, kèm cảnh báo trùng lặp / khác người. */
  function fsCaptureSample() {
    if (!_fsLiveDetection) return;
    var descriptor = Array.from(_fsLiveDetection.descriptor);
    var video = document.getElementById('fsVideo');

    var warning = '';
    if (_fsSamples.length > 0) {
      var best = Infinity;
      _fsSamples.forEach(function (s) {
        var d = fsEuclidean(s.descriptor, descriptor);
        if (d < best) best = d;
      });
      if (best < FS_DUP_DISTANCE) {
        warning = ' Mẫu gần trùng mẫu đã có, hãy chụp ở góc hoặc ánh sáng khác.';
      } else if (best > FS_DIFF_DISTANCE) {
        warning = ' Ảnh này có thể không phải cùng một người.';
      }
    }

    _fsSamples.push({ descriptor: descriptor, snapshot: fsCapture(video) });
    fsRenderSamples();
    fsStatus('✓ Đã thêm mẫu ' + _fsSamples.length + '.' + warning,
             warning ? 'text-amber-600 font-semibold' : 'text-green-600 font-bold');
  }
```

- [ ] **Step 5: Cập nhật mở/đóng modal và lưu**

Trong `fsOpenEnroll`, thay hai dòng `_fsDescriptor = null; _fsSnapshot = null;` bằng `_fsSamples = [];` và thay `fsSetQuality(null);` bằng `fsRenderSamples();`. Thêm `document.getElementById('fsBtnCapture').disabled = true;`.

Trong `fsStartCamera`, thay `_fsDescriptor = null;` bằng `_fsLiveDetection = null;`, và bỏ dòng `document.getElementById('fsBtnSave').disabled = true;` (nút Lưu giờ do `fsRenderSamples` điều khiển).

Thay `fsSaveEnroll` bằng:

```javascript
  async function fsSaveEnroll() {
    if (!_fsSamples.length || !_fsTargetId) return;
    document.getElementById('fsBtnSave').disabled = true;
    fsStatus('Đang lưu...', 'text-zinc-500');

    var csrf = document.querySelector('meta[name="csrf-token"]');
    try {
      var res = await fetch(FS_CTX + '/face/enroll?targetAccountId=' + _fsTargetId, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          descriptors: _fsSamples.map(function (s) { return s.descriptor; }),
          photo: _fsSamples[0].snapshot,
          _csrf: csrf ? csrf.content : ''
        })
      });
      var data = await res.json();
      if (data.success) {
        fsStatus('✓ Đã lưu ' + _fsSamples.length + ' mẫu! Đang tải lại...', 'text-green-600 font-bold');
        setTimeout(function () { location.reload(); }, 900);
      } else {
        fsStatus('Lỗi: ' + (data.error || 'Không thể lưu'), 'text-red-600 font-bold');
        document.getElementById('fsBtnSave').disabled = false;
      }
    } catch (e) {
      fsStatus('Lỗi kết nối: ' + e.message, 'text-red-600 font-bold');
      document.getElementById('fsBtnSave').disabled = false;
    }
  }
```

- [ ] **Step 6: Xác nhận không còn tham chiếu mồ côi**

```bash
grep -n "fsSetQuality\|fsQuality\|fsRequired\|_fsDescriptor\|_fsSnapshot\|FS_REQUIRED" src/main/webapp/manager/FaceSettings.jsp
```

Kỳ vọng: chỉ còn `FS_REQUIRED` nếu Task 7 chưa chạy (nó dùng trong khối slider) — mọi tên khác phải biến mất. Nếu `fsQuality`/`fsSetQuality` còn, xoá nốt.

- [ ] **Step 7: Commit**

```bash
git add src/main/webapp/manager/FaceSettings.jsp
git commit -m "feat(face): manager chụp nhiều mẫu khuôn mặt khi đăng ký

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 7: Thanh kéo ngưỡng có xem trước sống

**Files:**
- Modify: `src/main/webapp/manager/FaceSettings.jsp:419-444` (khối ngưỡng), phần script cuối file

**Interfaces:**
- Consumes: `/face/enroll` GET trả `descriptors` (Task 3); hàm `fsEuclidean(a, b)` đã định nghĩa trong khối script ở Task 6 — **Task 6 phải làm trước Task 7**.
- Produces: không có gì cho task sau.

- [ ] **Step 1: Thay 4 radio bằng slider**

Trong `FaceSettings.jsp`, thay khối `<div>` chứa "Ngưỡng nhận diện" (dòng 419-444) bằng:

```html
        <div>
          <p class="text-sm font-bold text-violet-950 mb-1">Ngưỡng nhận diện</p>
          <p class="text-xs text-zinc-400 mb-3">Khoảng cách Euclidean tối đa giữa khuôn mặt quét và mẫu đã đăng ký — số càng nhỏ càng nghiêm ngặt.</p>

          <div class="flex items-center gap-3">
            <span class="text-[11px] font-semibold text-zinc-400 shrink-0">Chặt</span>
            <input type="range" id="fsThresholdRange" name="confidenceMin"
                   min="0.35" max="0.75" step="0.01" value="${faceConfig.confidenceMin}"
                   class="flex-1 accent-violet-600">
            <span class="text-[11px] font-semibold text-zinc-400 shrink-0">Dễ</span>
            <span id="fsThresholdValue" class="w-12 text-right text-sm font-black text-violet-700 shrink-0">0.60</span>
          </div>
          <p id="fsThresholdLabel" class="text-xs text-zinc-500 mt-2 font-semibold">Cân bằng</p>

          <div class="mt-4 p-3 bg-violet-50/60 border border-violet-100 rounded-xl">
            <p class="text-xs font-bold text-violet-950 mb-2">Xem trước bằng camera</p>
            <div class="flex gap-3">
              <div class="relative w-32 h-32 bg-zinc-900 rounded-lg overflow-hidden shrink-0">
                <video id="fsPvVideo" class="w-full h-full object-cover scale-x-[-1]" autoplay muted playsinline></video>
              </div>
              <div class="flex-1 min-w-0">
                <select id="fsPvStaff" class="w-full text-xs border border-violet-100 rounded-lg px-2 py-1.5 mb-2">
                  <option value="">— Chọn nhân viên đã đăng ký —</option>
                </select>
                <button type="button" id="fsPvBtn" onclick="fsPvToggle()"
                        class="text-xs bg-violet-600 hover:bg-violet-700 text-white font-semibold px-3 py-1.5 rounded-lg transition">
                  Bật camera
                </button>
                <p id="fsPvResult" class="text-xs mt-2 font-semibold text-zinc-400">Chưa chạy</p>
              </div>
            </div>
          </div>
        </div>
```

- [ ] **Step 2: Thêm danh sách nhân viên vào select**

Trong khối `<script>`, ngay dưới các biến `FS_*`, thêm:

```javascript
  /* Nhân sự đã đăng ký khuôn mặt, để xem trước ngưỡng.
     `daDangKy` là request attribute do FaceSettingsServlet đặt (dòng 63),
     cũng chính là list đang render bảng ở tab "Nhân sự" (dòng 170). */
  var FS_ENROLLED = [
    <c:forEach var="nv" items="${daDangKy}" varStatus="st">
      { id: ${nv.accountId}, name: '<c:out value="${nv.fullName}"/>' }<c:if test="${!st.last}">,</c:if>
    </c:forEach>
  ];
```

- [ ] **Step 3: Thêm script cho slider và xem trước**

Thêm vào cuối khối `<script>`:

```javascript
  /* ═══════════ Thanh kéo ngưỡng + xem trước ═══════════ */
  var _pvStream = null;
  var _pvLoopId = null;
  var _pvSamples = [];   // mẫu của nhân viên đang chọn

  function fsThresholdLabel(v) {
    if (v <= 0.45) return 'Chặt — ít chấp nhận sai, nhân viên có thể phải quét lại';
    if (v <= 0.62) return 'Cân bằng — khuyến nghị cho hầu hết điều kiện ánh sáng';
    return 'Dễ — nhận nhanh hơn nhưng rủi ro nhận nhầm cao hơn';
  }

  function fsOnThresholdChange() {
    var v = parseFloat(document.getElementById('fsThresholdRange').value);
    document.getElementById('fsThresholdValue').textContent = v.toFixed(2);
    document.getElementById('fsThresholdLabel').textContent = fsThresholdLabel(v);
  }

  document.getElementById('fsThresholdRange').addEventListener('input', fsOnThresholdChange);
  fsOnThresholdChange();

  (function fsFillPvStaff() {
    var sel = document.getElementById('fsPvStaff');
    FS_ENROLLED.forEach(function (nv) {
      var o = document.createElement('option');
      o.value = nv.id;
      o.textContent = nv.name;
      sel.appendChild(o);
    });
  })();

  async function fsPvToggle() {
    if (_pvStream) { fsPvStop(); return; }

    var accountId = document.getElementById('fsPvStaff').value;
    if (!accountId) {
      document.getElementById('fsPvResult').textContent = 'Hãy chọn một nhân viên trước';
      document.getElementById('fsPvResult').className = 'text-xs mt-2 font-semibold text-amber-600';
      return;
    }

    // Mẫu đã đăng ký của nhân viên này
    var res = await fetch(FS_CTX + '/face/enroll?targetAccountId=' + accountId);
    var data = await res.json();
    if (!data.enrolled) {
      document.getElementById('fsPvResult').textContent = 'Nhân viên này chưa đăng ký khuôn mặt';
      document.getElementById('fsPvResult').className = 'text-xs mt-2 font-semibold text-amber-600';
      return;
    }

    if (!_fsModelsLoaded) {
      await Promise.all([
        faceapi.nets.tinyFaceDetector.loadFromUri(FS_MODEL_URL),
        faceapi.nets.faceLandmark68TinyNet.loadFromUri(FS_MODEL_URL),
        faceapi.nets.faceRecognitionNet.loadFromUri(FS_MODEL_URL)
      ]);
      _fsModelsLoaded = true;
    }

    // Các mẫu đã đăng ký, lấy thẳng từ endpoint enroll (Task 3 trả khoá `descriptors`)
    _pvSamples = data.descriptors || [];
    if (!_pvSamples.length) {
      document.getElementById('fsPvResult').textContent = 'Không đọc được mẫu của nhân viên này';
      document.getElementById('fsPvResult').className = 'text-xs mt-2 font-semibold text-red-600';
      return;
    }

    var video = document.getElementById('fsPvVideo');
    _pvStream = await navigator.mediaDevices.getUserMedia({ video: { width: 320, height: 320, facingMode: 'user' } });
    video.srcObject = _pvStream;
    await new Promise(function (r) { video.onloadedmetadata = r; });
    await video.play();

    document.getElementById('fsPvBtn').textContent = 'Tắt camera';
    _pvLoopId = setInterval(fsPvLoop, 200);
  }

  function fsPvStop() {
    if (_pvLoopId) { clearInterval(_pvLoopId); _pvLoopId = null; }
    if (_pvStream) { _pvStream.getTracks().forEach(function (t) { t.stop(); }); _pvStream = null; }
    document.getElementById('fsPvBtn').textContent = 'Bật camera';
    document.getElementById('fsPvResult').textContent = 'Chưa chạy';
    document.getElementById('fsPvResult').className = 'text-xs mt-2 font-semibold text-zinc-400';
  }

  async function fsPvLoop() {
    var video = document.getElementById('fsPvVideo');
    var det = await faceapi
      .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions({ inputSize: 320 }))
      .withFaceLandmarks(true)
      .withFaceDescriptor();

    var out = document.getElementById('fsPvResult');
    if (!det) {
      out.textContent = 'Không thấy khuôn mặt';
      out.className = 'text-xs mt-2 font-semibold text-zinc-400';
      return;
    }

    var incoming = Array.from(det.descriptor);
    var best = Infinity;
    _pvSamples.forEach(function (s) {
      var d = fsEuclidean(s, incoming);
      if (d < best) best = d;
    });

    var threshold = parseFloat(document.getElementById('fsThresholdRange').value);
    var ok = best <= threshold;
    out.textContent = (ok ? '✓ ĐẠT' : '✗ KHÔNG ĐẠT') + ' — khoảng cách ' + best.toFixed(2)
                    + ' / ngưỡng ' + threshold.toFixed(2);
    out.className = 'text-xs mt-2 font-semibold ' + (ok ? 'text-green-600' : 'text-amber-600');
  }

  // Tắt camera xem trước khi rời tab để không giữ webcam
  document.querySelectorAll('.fs-tab').forEach(function (t) {
    t.addEventListener('click', function () { if (_pvStream) fsPvStop(); });
  });
```

- [ ] **Step 4: Xoá hằng FS_REQUIRED không còn dùng**

```bash
grep -n "FS_REQUIRED" src/main/webapp/manager/FaceSettings.jsp
```

Xoá dòng khai báo `var FS_REQUIRED = ...` và mọi chỗ gọi còn lại. `FS_THRESHOLD` và `FS_MAX_DISTANCE` cũng xoá nếu không còn chỗ dùng.

- [ ] **Step 5: Nới khoảng kẹp trong servlet cho khớp slider**

`FaceSettingsServlet.java:84` đang kẹp giá trị về `[0.4, 0.9]`, nên đầu dưới `0.35` của slider sẽ bị nâng lên `0.4` khi lưu. Đổi dòng:

```java
        confidenceMin = Math.max(0.4, Math.min(0.9, confidenceMin));
```

thành:

```java
        confidenceMin = Math.max(0.35, Math.min(0.75, confidenceMin));
```

Sau đó biên dịch:

```bash
mvn -q -DskipTests compile
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 6: Commit**

```bash
git add src/main/webapp/manager/FaceSettings.jsp src/main/java/org/example/controller/manager/FaceSettingsServlet.java
git commit -m "feat(face): thanh kéo ngưỡng nhận diện kèm xem trước camera

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 8: Đăng ký nhiều ảnh ở NhanSu.jsp

Trang nhân sự vẫn dùng luồng upload file. Cho chọn nhiều ảnh để nó ngang khả năng với modal ở FaceSettings.

**Files:**
- Modify: `src/main/webapp/manager/NhanSu.jsp:351-354`, `:523-608`

**Interfaces:**
- Consumes: `/face/enroll` POST multipart field `descriptors` (Task 3).
- Produces: không có gì cho task sau.

- [ ] **Step 1: Cho input nhận nhiều file**

Trong `NhanSu.jsp`, thay dòng 351-354:

```html
            <p class="text-xs text-zinc-400 mb-2">Upload ảnh chân dung rõ mặt (JPG/PNG, tối đa 5MB)</p>
            <div class="flex gap-2">
              <input type="file" id="managerFaceFile" accept="image/jpeg,image/png" class="hidden"
                     onchange="previewManagerFace(event)"/>
```

bằng:

```html
            <p class="text-xs text-zinc-400 mb-2">Chọn 3 ảnh chân dung ở góc/ánh sáng khác nhau (JPG/PNG, mỗi ảnh tối đa 5MB)</p>
            <div class="flex gap-2">
              <input type="file" id="managerFaceFile" accept="image/jpeg,image/png" multiple class="hidden"
                     onchange="previewManagerFace(event)"/>
```

- [ ] **Step 2: Thay state một mẫu bằng danh sách mẫu**

Thay dòng 523-527:

```javascript
let _managerTargetId = null;
let _managerFaceDescriptor = null;
let _managerFacePhoto = null;
let _managerModelsLoaded = false;
```

bằng:

```javascript
let _managerTargetId = null;
let _managerFaceDescriptors = [];   // mảng các descriptor 128 chiều
let _managerModelsLoaded = false;
```

- [ ] **Step 3: Viết lại previewManagerFace cho nhiều ảnh**

Thay toàn bộ hàm `previewManagerFace` bằng:

```javascript
async function previewManagerFace(event) {
  const files = Array.from(event.target.files || []);
  if (!files.length) return;
  const statusEl = document.getElementById('managerFaceUploadStatus');
  statusEl.textContent = 'Đang phân tích ' + files.length + ' ảnh...';
  statusEl.className = 'text-xs mt-2 text-zinc-500';

  if (!_managerModelsLoaded) {
    await Promise.all([
      faceapi.nets.tinyFaceDetector.loadFromUri(FACE_MODEL_URL),
      faceapi.nets.faceLandmark68TinyNet.loadFromUri(FACE_MODEL_URL),
      faceapi.nets.faceRecognitionNet.loadFromUri(FACE_MODEL_URL)
    ]);
    _managerModelsLoaded = true;
  }

  _managerFaceDescriptors = [];
  let skipped = 0;
  for (const file of files) {
    const img = await faceapi.bufferToImage(file);
    const detection = await faceapi.detectSingleFace(img, new faceapi.TinyFaceDetectorOptions())
      .withFaceLandmarks(true).withFaceDescriptor();
    if (detection) {
      _managerFaceDescriptors.push(Array.from(detection.descriptor));
    } else {
      skipped++;
    }
  }

  if (!_managerFaceDescriptors.length) {
    statusEl.textContent = '✗ Không tìm thấy khuôn mặt trong ảnh nào. Chọn ảnh khác.';
    statusEl.className = 'text-xs mt-2 text-red-600';
    document.getElementById('btnManagerSaveFace').disabled = true;
    return;
  }

  statusEl.textContent = '✓ Nhận diện được ' + _managerFaceDescriptors.length + ' mẫu'
    + (skipped ? ' (bỏ qua ' + skipped + ' ảnh không thấy mặt)' : '')
    + '. Nhấn "Lưu khuôn mặt".';
  statusEl.className = 'text-xs mt-2 text-green-600 font-semibold';
  document.getElementById('btnManagerSaveFace').disabled = false;

  document.getElementById('managerFaceImg').src = URL.createObjectURL(files[0]);
  document.getElementById('managerFacePreview').classList.remove('hidden');
}
```

- [ ] **Step 4: Gửi mảng descriptors khi lưu**

Trong `saveManagerFace`, thay hai dòng đầu và phần dựng form:

```javascript
  if (!_managerFaceDescriptor || !_managerTargetId) return;
```

thành:

```javascript
  if (!_managerFaceDescriptors.length || !_managerTargetId) return;
```

và thay:

```javascript
  const file = document.getElementById('managerFaceFile').files[0];
  const formData = new FormData();
  formData.append('descriptor', _managerFaceDescriptor);
  if (file) formData.append('photo', file);
```

thành:

```javascript
  const file = document.getElementById('managerFaceFile').files[0];
  const formData = new FormData();
  formData.append('descriptors', JSON.stringify(_managerFaceDescriptors));
  if (file) formData.append('photo', file);
```

Trong nhánh thành công, đổi thông báo thành:

```javascript
    statusEl.textContent = '✓ Đã lưu ' + _managerFaceDescriptors.length + ' mẫu khuôn mặt!';
```

- [ ] **Step 5: Hiển thị số mẫu ở trạng thái**

Trong `loadManagerFaceStatus`, thay dòng gán `statusEl.innerHTML` trong nhánh `data.enrolled` bằng:

```javascript
    statusEl.innerHTML = '<span class="text-green-600 font-semibold">✓ Đã đăng ký '
      + (data.sampleCount || 1) + ' mẫu khuôn mặt</span> — ' + (data.enrolledAt || '');
```

- [ ] **Step 6: Xác nhận không còn tham chiếu mồ côi**

```bash
grep -n "_managerFaceDescriptor\b\|_managerFacePhoto" src/main/webapp/manager/NhanSu.jsp
```

Kỳ vọng: không có kết quả.

- [ ] **Step 7: Commit**

```bash
git add src/main/webapp/manager/NhanSu.jsp
git commit -m "feat(face): đăng ký nhiều ảnh khuôn mặt ở trang nhân sự

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

### Task 9: Kiểm thử thủ công đầu-cuối

Không có test tự động nào chạm được camera hay DB thật, nên đây là bước kiểm chứng thật sự. Thực hiện đủ danh sách trước khi coi là xong.

**Files:**
- Test: kiểm thử thủ công qua trình duyệt, không sửa file. Nếu phát hiện lỗi, sửa tại chỗ rồi commit riêng.

**Interfaces:**
- Consumes: toàn bộ Task 1-8.
- Produces: không.

- [ ] **Step 1: Biên dịch và đóng gói**

```bash
mvn -q -DskipTests package
```

Kỳ vọng: BUILD SUCCESS.

- [ ] **Step 2: Chạy unit test của matcher**

```bash
mvn -q test -Dtest=FaceDescriptorMatcherTest
```

Kỳ vọng: PASS. Không chạy toàn bộ `mvn test` — xem Global Constraints.

- [ ] **Step 3: Deploy và kiểm tương thích ngược**

Deploy lên Tomcat, đăng nhập bằng tài khoản nhân viên **đã có descriptor định dạng cũ** (đăng ký trước thay đổi này). Mở `/staff/ca-lam`, bấm **Điểm danh**.

Kỳ vọng: camera mở, trong 1-3 giây trạng thái chuyển "Đang nhận diện..." → điểm danh thành công. Không có bất kỳ yêu cầu quay đầu/chớp mắt nào.

- [ ] **Step 4: Kiểm đăng ký nhiều mẫu**

Đăng nhập manager, mở `/manager/face-settings`, tab Nhân sự, bấm đăng ký khuôn mặt cho một nhân viên. Chụp 3 mẫu ở ba góc khác nhau. Lưu.

Kỳ vọng: dải mẫu hiện 3 ảnh nhỏ, đếm "3 / 3", lưu báo "Đã lưu 3 mẫu". Chụp lại đúng một tư thế hai lần phải hiện cảnh báo "Mẫu gần trùng mẫu đã có".

- [ ] **Step 5: Kiểm cải thiện nhận diện**

Đăng nhập lại bằng nhân viên vừa đăng ký 3 mẫu, điểm danh ở điều kiện ánh sáng khác lúc đăng ký.

Kỳ vọng: nhận ra nhanh hơn rõ rệt so với Step 3. Ghi lại số lần thất bại nếu có.

- [ ] **Step 6: Kiểm thanh kéo có tác dụng**

Ở `/manager/face-settings` tab Cài đặt: kéo slider, xác nhận số và nhãn (Chặt/Cân bằng/Dễ) đổi theo. Chọn một nhân viên, bật camera xem trước, đưa mặt vào và kéo slider qua lại.

Kỳ vọng: dòng kết quả nhảy giữa "✓ ĐẠT" và "✗ KHÔNG ĐẠT" khi ngưỡng vượt qua khoảng cách đo được. Lưu ngưỡng `0.35`, sau đó thử điểm danh — phải bị từ chối. Đặt lại `0.60`.

- [ ] **Step 7: Kiểm timeout và nút Thử lại**

Điểm danh rồi che camera 15 giây.

Kỳ vọng: xuất hiện thông báo "Chưa nhận ra bạn. Hãy đứng nơi đủ sáng, bỏ khẩu trang và thử lại." kèm nút **Thử lại**. Bấm Thử lại thì camera mở lại và vòng nhận diện chạy tiếp.

- [ ] **Step 8: Kiểm luồng bảo vệ**

Lặp lại Step 3 và Step 7 với tài khoản bảo vệ ở `/guard/diem-danh`.

Kỳ vọng: hành vi giống hệt luồng nhân viên.

- [ ] **Step 9: Kiểm log hậu kiểm**

Ở `/manager/face-settings` tab log, xem các lần điểm danh vừa thực hiện.

Kỳ vọng: mỗi dòng có ảnh snapshot bấm xem được và giá trị confidence. Đây là lớp chống gian lận thay cho challenge.

- [ ] **Step 10: Commit sửa lỗi nếu có**

Nếu Step 3-9 phát hiện lỗi, sửa và commit:

```bash
git add -A
git commit -m "fix(face): sửa lỗi phát hiện khi kiểm thử đầu-cuối

Co-Authored-By: Claude <noreply@anthropic.com>"
```

Nếu mọi bước đều đạt, không cần commit thêm.
