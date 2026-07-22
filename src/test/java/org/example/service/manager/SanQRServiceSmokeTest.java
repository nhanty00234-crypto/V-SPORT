package org.example.service.manager;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import org.example.dao.CheckInDAO;
import org.example.dto.qr.SanQRResolveDTO;
import org.example.model.CoSo;
import org.example.model.San;
import org.example.model.SanQR;
import org.example.model.SanQRTokenHistory;
import org.example.util.DBUtil;
import org.example.util.JPAUtil;
import org.example.util.SanQRSecurityUtil;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Smoke test 24 test case vòng đời SanQRService trên DB thật (QR-01B). Chạy
 * thủ công, cần DB QuanLiSport có ít nhất 2 cơ sở (để test ownership cross-
 * facility ở TEST 08) và chạy sql/migration_san_qr.sql +
 * sql/migration_san_qr_hardening.sql trước.
 *
 * TEST DATA: tạo MỘT San mới gắn vào CoSo thật đầu tiên tìm được (không sửa/
 * xoá CoSo, chỉ tạo San con trỏ tới nó) - tên sân có prefix "__QRTEST__" để dễ
 * nhận diện. Toàn bộ SanQR/SanQRTokenHistory/San test được dọn sạch ở
 * @AfterAll, có verify lại bằng query đếm dòng còn sót - không chỉ dựa vào
 * finally không kiểm tra lại.
 *
 * Test được đánh số thứ tự (MethodOrderer + @Order) vì đây là kịch bản vòng
 * đời tuần tự thật (tạo -> disable -> enable -> regenerate -> ...), không
 * phải các test độc lập ngẫu nhiên.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class SanQRServiceSmokeTest {

    private static final String TEST_PREFIX = "__QRTEST__";
    private static final SanQRService service = new SanQRService();

    // Trạng thái chia sẻ giữa các test theo thứ tự chạy (kịch bản vòng đời tuần tự).
    private static int testSanId;
    private static int testCoSoId;
    private static int wrongCoSoId; // cơ sở KHÁC để test ownership từ chối
    private static UUID firstToken;
    private static String firstShortCode;
    private static UUID secondToken;
    private static String secondShortCode;

    private static void createTestSan() throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            // Lấy 2 CoSoID thật khác nhau (không tạo CoSo mới - dùng dữ liệu có sẵn).
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT TOP 2 CoSoID FROM dbo.CoSo WHERE (IsDeleted = 0 OR IsDeleted IS NULL) ORDER BY CoSoID");
                 var rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Cần ít nhất 1 CoSo trong DB để chạy smoke test");
                testCoSoId = rs.getInt(1);
                wrongCoSoId = rs.next() ? rs.getInt(1) : testCoSoId + 999999; // fallback nếu DB chỉ có 1 cơ sở
            }
            // Lấy 1 LoaiSanID hợp lệ bất kỳ để insert San hợp lệ FK.
            int loaiSanId;
            try (PreparedStatement ps = conn.prepareStatement("SELECT TOP 1 LoaiSanID FROM dbo.LoaiSan");
                 var rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Cần ít nhất 1 LoaiSan trong DB để chạy smoke test");
                loaiSanId = rs.getInt(1);
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO dbo.San (TenSan, LoaiSanID, CoSoID, TrangThai) VALUES (?, ?, ?, N'Sẵn sàng')",
                    java.sql.Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, TEST_PREFIX + "Smoke_" + System.nanoTime());
                ps.setInt(2, loaiSanId);
                ps.setInt(3, testCoSoId);
                ps.executeUpdate();
                try (var keys = ps.getGeneratedKeys()) {
                    assertTrue(keys.next(), "Phải sinh được SanID cho sân test");
                    testSanId = keys.getInt(1);
                }
            }
        }
        System.out.println("=== TEST SAN đã tạo: SanID=" + testSanId + " CoSoID=" + testCoSoId
                + " (wrongCoSoId=" + wrongCoSoId + ") ===");
    }

    @Test
    @Order(1)
    void test01_createTestFixture() throws Exception {
        createTestSan();
        assertTrue(testSanId > 0);
        System.out.println("TEST 01: PASS (fixture sân test tạo thành công)");
    }

    @Test
    @Order(2)
    void test02_managerCreatesQrSuccessfully() {
        SanQRService.Result r = service.getOrCreate(testSanId, testCoSoId, null);
        assertTrue(r.success, "Manager đúng cơ sở phải tạo QR thành công: " + (r.errorMessage != null ? r.errorMessage : ""));
        assertNotNull(r.sanQR);
        assertEquals(SanQR.ACTIVE, r.sanQR.getTrangThai());
        firstToken = r.sanQR.getToken();
        firstShortCode = r.sanQR.getShortCode();
        System.out.println("TEST 02: PASS (QR tạo thành công, token=" + firstToken + ")");
    }

    @Test
    @Order(3)
    void test03_tokenIsValidUuidV4() {
        assertNotNull(firstToken);
        // UUID v4: 4 bit version nằm ở nibble thứ 13 của chuỗi hex (index 14 sau khi bỏ dấu -),
        // và 2 bit variant nằm ở nibble thứ 17 phải là 8/9/a/b (RFC 4122 variant 1).
        assertEquals(4, firstToken.version(), "Token phải là UUID version 4");
        assertEquals(2, firstToken.variant(), "Token phải đúng variant RFC 4122 (2)");
        System.out.println("TEST 03: PASS (token là UUID v4 hợp lệ, version=" + firstToken.version() + ")");
    }

    @Test
    @Order(4)
    void test04_tokenDoesNotContainSanIdDirectly() {
        String sanIdHex = Integer.toHexString(testSanId);
        String tokenNoDashes = firstToken.toString().replace("-", "");
        // Không đủ để chứng minh "không suy ra được", nhưng đủ để bắt lỗi rõ ràng
        // nếu ai đó lỡ implement kiểu new UUID(sanId, ...) hoặc nối chuỗi SanID vào token.
        assertFalse(tokenNoDashes.contains(sanIdHex) && sanIdHex.length() >= 3,
                "Token không được chứa SanID dưới dạng chuỗi con dễ nhận ra");
        System.out.println("TEST 04: PASS (token không chứa SanID theo cách trực tiếp)");
    }

    @Test
    @Order(5)
    void test05_shortCodeIsUniqueAndDoesNotContainSanId() {
        assertNotNull(firstShortCode);
        assertTrue(firstShortCode.startsWith("VS-"), "Short code phải theo định dạng VS-XXXXXX");
        String body = firstShortCode.substring(3);
        assertEquals(6, body.length());
        for (char c : body.toCharArray()) {
            assertFalse(c == '0' || c == 'O' || c == '1' || c == 'I' || c == 'L',
                    "Short code không được chứa ký tự dễ nhầm (0/O/1/I/L), nhưng có: " + c);
        }
        String sanIdStr = String.valueOf(testSanId);
        assertFalse(body.contains(sanIdStr) && sanIdStr.length() >= 2,
                "Short code không được chứa SanID");
        System.out.println("TEST 05: PASS (short code=" + firstShortCode + " hợp lệ, không chứa ký tự dễ nhầm/SanID)");
    }

    @Test
    @Order(6)
    void test06_shortCodeUniqueColumnEnforced() throws Exception {
        // Kiểm tra trực tiếp bằng DB constraint: cố insert một SanQR khác với ShortCode trùng.
        try (Connection conn = DBUtil.getConnection()) {
            boolean rejected = false;
            // Cần 1 SanID khác (chưa có QR) để không đụng UNIQUE SanID trước UNIQUE ShortCode.
            int otherSanId = createThrowawaySanForDuplicateTest(conn);
            try {
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO dbo.SanQR (SanID, Token, ShortCode) VALUES (?, NEWID(), ?)")) {
                    ps.setInt(1, otherSanId);
                    ps.setString(2, firstShortCode); // trùng short code đã cấp ở TEST 02
                    ps.executeUpdate();
                } catch (Exception e) {
                    rejected = true;
                }
            } finally {
                // PHẢI dọn dù INSERT thành công (không nên xảy ra) hay throw (trường hợp
                // mong đợi) - executeUpdate() ném exception nhảy thẳng qua bất kỳ dòng dọn
                // dẹp nào đặt SAU nó trong cùng try, nên phải đặt trong finally.
                cleanupThrowawaySan(conn, otherSanId);
            }
            assertTrue(rejected, "DB phải từ chối ShortCode trùng nhờ UQ_SanQR_ShortCode");
        }
        System.out.println("TEST 06: PASS (short code trùng bị DB từ chối)");
    }

    @Test
    @Order(7)
    void test07_secondCreateDoesNotDuplicate() throws Exception {
        SanQRService.Result r2 = service.getOrCreate(testSanId, testCoSoId, null);
        assertTrue(r2.success);
        assertEquals(firstToken, r2.sanQR.getToken(), "Gọi getOrCreate lần 2 không được sinh token mới (idempotent)");
        assertEquals(firstShortCode, r2.sanQR.getShortCode());
        assertEquals(1, countSanQRRowsForSan(testSanId), "Chỉ được có đúng 1 bản ghi SanQR cho 1 SanID");
        System.out.println("TEST 07: PASS (tạo lần 2 không tạo duplicate, vẫn 1 bản ghi SanQR)");
    }

    @Test
    @Order(8)
    void test08_managerWrongFacilityForbidden() {
        SanQRService.Result r = service.disable(testSanId, wrongCoSoId, null);
        assertFalse(r.success);
        assertEquals(SanQRService.ErrorCode.FORBIDDEN, r.errorCode);
        // Xác nhận KHÔNG có tác dụng phụ: token/trạng thái không đổi sau lần gọi bị từ chối.
        SanQRService.Result check = service.getOrCreate(testSanId, testCoSoId, null);
        assertEquals(SanQR.ACTIVE, check.sanQR.getTrangThai(), "Trạng thái không được đổi sau lệnh bị FORBIDDEN");
        assertEquals(firstToken, check.sanQR.getToken(), "Token không được đổi sau lệnh bị FORBIDDEN");
        System.out.println("TEST 08: PASS (cơ sở sai bị FORBIDDEN, không có tác dụng phụ)");
    }

    @Test
    @Order(9)
    void test09_disableSucceeds() {
        SanQRService.Result r = service.disable(testSanId, testCoSoId, null);
        assertTrue(r.success, r.errorMessage);
        assertEquals(SanQR.DISABLED, r.sanQR.getTrangThai());
        System.out.println("TEST 09: PASS (disable thành công)");
    }

    @Test
    @Order(10)
    void test10_disabledTokenDoesNotResolveOk() {
        SanQRService.PublicResolveResult r = service.resolve(firstToken);
        assertEquals(SanQRService.ResolveOutcome.DISABLED, r.outcome);
        assertFalse(r.dto.isAvailable());
        assertEquals("DISABLED", r.dto.getResultCode());
        System.out.println("TEST 10: PASS (token của QR đã disable trả DISABLED, không phải OK)");
    }

    @Test
    @Order(11)
    void test11_enableSucceeds() {
        SanQRService.Result r = service.enable(testSanId, testCoSoId, null);
        assertTrue(r.success, r.errorMessage);
        assertEquals(SanQR.ACTIVE, r.sanQR.getTrangThai());
        assertEquals(firstToken, r.sanQR.getToken(), "enable() không được đổi token");
        System.out.println("TEST 11: PASS (enable thành công, giữ nguyên token)");
    }

    @Test
    @Order(12)
    void test12_regenerateSucceeds() {
        SanQRService.Result r = service.regenerate(testSanId, testCoSoId, null);
        assertTrue(r.success, r.errorMessage);
        secondToken = r.sanQR.getToken();
        secondShortCode = r.sanQR.getShortCode();
        assertNotEquals(firstToken, secondToken, "Regenerate phải sinh token mới");
        assertNotEquals(firstShortCode, secondShortCode, "Regenerate phải sinh short code mới");
        assertEquals(SanQR.ACTIVE, r.sanQR.getTrangThai());
        assertEquals(1, r.sanQR.getRegenerateCount());
        System.out.println("TEST 12: PASS (regenerate thành công, token mới=" + secondToken + ")");
    }

    @Test
    @Order(13)
    void test13_oldTokenReturnsRevoked() {
        SanQRService.PublicResolveResult r = service.resolve(firstToken);
        assertEquals(SanQRService.ResolveOutcome.REVOKED, r.outcome);
        assertEquals("REVOKED", r.dto.getResultCode());
        System.out.println("TEST 13: PASS (token cũ sau regenerate -> REVOKED)");
    }

    @Test
    @Order(14)
    void test14_newTokenResolvesCorrectSan() {
        SanQRService.PublicResolveResult r = service.resolve(secondToken);
        assertEquals(SanQRService.ResolveOutcome.OK, r.outcome);
        assertTrue(r.dto.isAvailable());
        assertTrue(r.dto.getTenSan() != null && r.dto.getTenSan().startsWith(TEST_PREFIX));
        System.out.println("TEST 14: PASS (token mới resolve đúng sân: " + r.dto.getTenSan() + ")");
    }

    @Test
    @Order(15)
    void test15_oldShortCodeNoLongerValid() {
        SanQRService.PublicResolveResult r = service.resolveActiveShortCode(firstShortCode);
        assertEquals(SanQRService.ResolveOutcome.REVOKED, r.outcome,
                "Short code cũ sau regenerate phải bị từ chối REVOKED");
        System.out.println("TEST 15: PASS (short code cũ không còn hợp lệ sau regenerate)");
    }

    @Test
    @Order(16)
    void test16_newShortCodeResolvesSuccessfully() {
        SanQRService.PublicResolveResult r = service.resolveActiveShortCode(secondShortCode);
        assertEquals(SanQRService.ResolveOutcome.OK, r.outcome);
        assertTrue(r.dto.isAvailable());
        // Không phân biệt hoa/thường theo policy.
        SanQRService.PublicResolveResult rLower = service.resolveActiveShortCode(secondShortCode.toLowerCase());
        assertEquals(SanQRService.ResolveOutcome.OK, rLower.outcome, "Resolve short code không được phân biệt hoa/thường");
        System.out.println("TEST 16: PASS (short code mới resolve thành công, không phân biệt hoa/thường)");
    }

    @Test
    @Order(17)
    void test17_terminalRevokedCannotBeEnabled() throws Exception {
        // QR-01B chưa có nghiệp vụ đưa current row về REVOKED (đó là trạng thái
        // của history entry, không phải current SanQR - xem javadoc SanQRService).
        // Test này xác nhận guard tồn tại đúng bằng cách set thẳng DB rồi gọi enable(),
        // đảm bảo Service từ chối đúng nếu tương lai có đường nào đưa row về REVOKED.
        setSanQrStatusDirectly(testSanId, SanQR.REVOKED);
        SanQRService.Result r = service.enable(testSanId, testCoSoId, null);
        assertFalse(r.success);
        assertEquals(SanQRService.ErrorCode.INVALID_TRANSITION, r.errorCode);
        // Khôi phục lại ACTIVE để các test sau (nếu re-run cùng fixture) không bị ảnh hưởng.
        setSanQrStatusDirectly(testSanId, SanQR.ACTIVE);
        System.out.println("TEST 17: PASS (QR ở trạng thái REVOKED không thể enable lại)");
    }

    @Test
    @Order(18)
    void test18_fakeTokenReturnsNotFoundOrRevoked() {
        SanQRService.PublicResolveResult r = service.resolve(UUID.randomUUID());
        assertTrue(r.outcome == SanQRService.ResolveOutcome.NOT_FOUND,
                "Token ngẫu nhiên chưa từng cấp phải trả NOT_FOUND, không phải OK/REVOKED");
        assertFalse(r.dto.isAvailable());

        SanQRService.PublicResolveResult rNull = service.resolve(null);
        assertEquals(SanQRService.ResolveOutcome.NOT_FOUND, rNull.outcome, "Token null không được throw, phải NOT_FOUND");
        System.out.println("TEST 18: PASS (token giả/null -> NOT_FOUND, không throw)");
    }

    @Test
    @Order(19)
    void test19_resolveDtoDoesNotLeakInternalFields() throws Exception {
        SanQRService.PublicResolveResult r = service.resolve(secondToken);
        SanQRResolveDTO dto = r.dto;
        // Kiểm tra bằng reflection: liệt kê toàn bộ field khai báo trên DTO, xác nhận
        // KHÔNG có field nào tên gợi ý lộ nội bộ (id, token, code, coSo, san*Id, createdBy...).
        var fields = dto.getClass().getDeclaredFields();
        for (var f : fields) {
            String name = f.getName().toLowerCase();
            assertFalse(name.contains("token"), "DTO không được có field chứa 'token': " + f.getName());
            assertFalse(name.contains("shortcode") || name.equals("shortcode"), "DTO không được lộ short code: " + f.getName());
            assertFalse(name.contains("sanid") || name.contains("cosoid") || name.contains("sanqrid"),
                    "DTO không được lộ ID nội bộ: " + f.getName());
            assertFalse(name.contains("createdby") || name.contains("updatedby"),
                    "DTO không được lộ actor nội bộ: " + f.getName());
        }
        // toString() mặc định của record/class thường không phơi field private ra console
        // theo cách dễ đọc, nhưng ta xác nhận rõ hơn: message hiển thị không chứa token gốc.
        assertFalse(dto.getMessage() != null && dto.getMessage().contains(secondToken.toString()),
                "Message của DTO không được chứa token thật");
        System.out.println("TEST 19: PASS (DTO chỉ có " + fields.length + " field, không field nào lộ ID/token nội bộ)");
    }

    @Test
    @Order(20)
    void test20_auditCreatedWithoutFullToken() throws Exception {
        long countBefore;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT COUNT(*) FROM dbo.AuditLog WHERE EntityType = 'SanQR' AND CoSoID = ?")) {
            ps.setInt(1, testCoSoId);
            try (var rs = ps.executeQuery()) { rs.next(); countBefore = rs.getLong(1); }
        }
        assertTrue(countBefore > 0, "Phải có ít nhất 1 bản ghi AuditLog cho SanQR của cơ sở test "
                + "(được ghi bởi các hành động CREATE/DISABLE/ENABLE/REGENERATE ở các test trước)");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT TOP 20 Details FROM dbo.AuditLog WHERE EntityType = 'SanQR' AND CoSoID = ?")) {
            ps.setInt(1, testCoSoId);
            try (var rs = ps.executeQuery()) {
                while (rs.next()) {
                    String details = rs.getString(1);
                    if (details != null) {
                        assertFalse(details.contains(firstToken.toString()), "AuditLog.Details không được chứa token đầy đủ (token cũ)");
                        assertFalse(details.contains(secondToken.toString()), "AuditLog.Details không được chứa token đầy đủ (token mới)");
                    }
                }
            }
        }
        System.out.println("TEST 20: PASS (" + countBefore + " bản ghi AuditLog cho SanQR, không chứa token đầy đủ)");
    }

    @Test
    @Order(21)
    void test21_concurrentGetOrCreate_onlyOneQrCreated() throws Exception {
        // Sân MỚI riêng cho test concurrency create (không dùng lại testSanId đã có QR).
        int concurrentSanId;
        try (Connection conn = DBUtil.getConnection()) {
            concurrentSanId = createThrowawaySanForDuplicateTest(conn);
        }
        int threads = 5;
        Thread[] workers = new Thread[threads];
        SanQRService.Result[] results = new SanQRService.Result[threads];
        for (int i = 0; i < threads; i++) {
            final int idx = i;
            workers[i] = new Thread(() -> results[idx] = service.getOrCreate(concurrentSanId, testCoSoId, null));
        }
        for (Thread t : workers) t.start();
        for (Thread t : workers) t.join();

        for (SanQRService.Result r : results) {
            assertNotNull(r, "Mỗi thread phải trả kết quả, không treo/throw ra ngoài");
            assertTrue(r.success, "Mọi request getOrCreate đồng thời đều phải thành công (idempotent)");
        }
        assertEquals(1, countSanQRRowsForSan(concurrentSanId), "5 request tạo QR đồng thời chỉ được tạo đúng 1 bản ghi SanQR");

        try (Connection conn = DBUtil.getConnection()) {
            cleanupThrowawaySan(conn, concurrentSanId);
        }
        System.out.println("TEST 21: PASS (5 luồng getOrCreate đồng thời -> chỉ 1 QR được tạo)");
    }

    @Test
    @Order(22)
    void test22_concurrentRegenerate_noCorruptedState() throws Exception {
        int threads = 5;
        Thread[] workers = new Thread[threads];
        SanQRService.Result[] results = new SanQRService.Result[threads];
        int regenBefore = service.getOrCreate(testSanId, testCoSoId, null).sanQR.getRegenerateCount();
        for (int i = 0; i < threads; i++) {
            final int idx = i;
            workers[i] = new Thread(() -> results[idx] = service.regenerate(testSanId, testCoSoId, null));
        }
        for (Thread t : workers) t.start();
        for (Thread t : workers) t.join();

        for (SanQRService.Result r : results) {
            assertNotNull(r);
            assertTrue(r.success, "PESSIMISTIC_WRITE phải serialize hoá 5 regenerate đồng thời, tất cả đều thành công tuần tự");
        }
        SanQRService.Result finalState = service.getOrCreate(testSanId, testCoSoId, null);
        assertEquals(SanQR.ACTIVE, finalState.sanQR.getTrangThai());
        assertEquals(regenBefore + threads, finalState.sanQR.getRegenerateCount(),
                "regenerateCount phải cộng dồn đủ, không mất lần nào do race condition");
        assertEquals(1, countSanQRRowsForSan(testSanId), "Vẫn chỉ đúng 1 bản ghi SanQR sau nhiều lần regenerate đồng thời");
        System.out.println("TEST 22: PASS (5 regenerate đồng thời -> trạng thái cuối nhất quán, regenerateCount="
                + finalState.sanQR.getRegenerateCount() + ")");
    }

    @Test
    @Order(23)
    void test23_concurrentEnableDisable_noLostUpdate() throws Exception {
        int threads = 6;
        Thread[] workers = new Thread[threads];
        SanQRService.Result[] results = new SanQRService.Result[threads];
        AtomicInteger counter = new AtomicInteger();
        for (int i = 0; i < threads; i++) {
            final boolean enable = (i % 2 == 0);
            final int idx = i;
            workers[i] = new Thread(() -> {
                results[idx] = enable ? service.enable(testSanId, testCoSoId, null) : service.disable(testSanId, testCoSoId, null);
                counter.incrementAndGet();
            });
        }
        for (Thread t : workers) t.start();
        for (Thread t : workers) t.join();

        assertEquals(threads, counter.get(), "Tất cả thread phải hoàn tất, không có thread nào bị treo");
        for (SanQRService.Result r : results) {
            assertNotNull(r);
            assertTrue(r.success, "Enable/disable đồng thời không được lỗi (PESSIMISTIC_WRITE serialize hoá)");
        }
        // Trạng thái cuối cùng phải là ACTIVE hoặc DISABLED hợp lệ - không bị "kẹt" giá trị rác.
        SanQRService.Result finalState = service.getOrCreate(testSanId, testCoSoId, null);
        assertTrue(SanQR.ACTIVE.equals(finalState.sanQR.getTrangThai()) || SanQR.DISABLED.equals(finalState.sanQR.getTrangThai()));
        // Đưa về ACTIVE để dọn dẹp/kiểm tra sau nhất quán.
        service.enable(testSanId, testCoSoId, null);
        System.out.println("TEST 23: PASS (6 lệnh enable/disable đồng thời -> không mất update, trạng thái cuối hợp lệ)");
    }

    @Test
    @Order(24)
    void test24_cleanupTestData() throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            // Xoá theo đúng thứ tự FK: History -> SanQR -> San. AuditLog giữ lại
            // (chính sách project: AuditLog là hồ sơ vĩnh viễn, không xoá theo test -
            // các bản ghi audit của SanQR test sẽ trỏ tới EntityID không còn tồn tại,
            // giống hệt cách các module khác xử lý sau khi entity bị xoá thật).
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM dbo.SanQRTokenHistory WHERE SanID = ?")) {
                ps.setInt(1, testSanId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM dbo.SanQR WHERE SanID = ?")) {
                ps.setInt(1, testSanId);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM dbo.San WHERE SanID = ? AND TenSan LIKE ?")) {
                ps.setInt(1, testSanId);
                ps.setString(2, TEST_PREFIX + "%");
                int deleted = ps.executeUpdate();
                assertEquals(1, deleted, "Phải xoá đúng 1 sân test (an toàn: WHERE có cả SanID lẫn TenSan LIKE prefix test)");
            }

            // Verify lại - không chỉ tin finally, phải query xác nhận không còn dữ liệu test.
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.San WHERE SanID = ?")) {
                ps.setInt(1, testSanId);
                try (var rs = ps.executeQuery()) { rs.next(); assertEquals(0, rs.getInt(1), "San test phải bị xoá hoàn toàn"); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.SanQR WHERE SanID = ?")) {
                ps.setInt(1, testSanId);
                try (var rs = ps.executeQuery()) { rs.next(); assertEquals(0, rs.getInt(1), "SanQR test phải bị xoá hoàn toàn"); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.SanQRTokenHistory WHERE SanID = ?")) {
                ps.setInt(1, testSanId);
                try (var rs = ps.executeQuery()) { rs.next(); assertEquals(0, rs.getInt(1), "SanQRTokenHistory test phải bị xoá hoàn toàn"); }
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM dbo.San WHERE TenSan LIKE ?")) {
                ps.setString(1, TEST_PREFIX + "%");
                try (var rs = ps.executeQuery()) {
                    rs.next();
                    assertEquals(0, rs.getInt(1), "Không được còn sót bất kỳ sân test nào (prefix " + TEST_PREFIX + ")");
                }
            }
        }
        System.out.println("TEST 24: PASS (dữ liệu test đã dọn sạch hoàn toàn, verify lại bằng query xác nhận 0 dòng còn sót)");
        System.out.println();
        System.out.println("=== TẤT CẢ 24 TEST HOÀN TẤT ===");
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private static int createThrowawaySanForDuplicateTest(Connection conn) throws Exception {
        int loaiSanId;
        try (PreparedStatement ps = conn.prepareStatement("SELECT TOP 1 LoaiSanID FROM dbo.LoaiSan");
             var rs = ps.executeQuery()) {
            rs.next();
            loaiSanId = rs.getInt(1);
        }
        try (PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO dbo.San (TenSan, LoaiSanID, CoSoID, TrangThai) VALUES (?, ?, ?, N'Sẵn sàng')",
                java.sql.Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, TEST_PREFIX + "Aux_" + System.nanoTime());
            ps.setInt(2, loaiSanId);
            ps.setInt(3, testCoSoId);
            ps.executeUpdate();
            try (var keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getInt(1);
            }
        }
    }

    private static void cleanupThrowawaySan(Connection conn, int sanId) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM dbo.SanQRTokenHistory WHERE SanID = ?")) {
            ps.setInt(1, sanId); ps.executeUpdate();
        }
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM dbo.SanQR WHERE SanID = ?")) {
            ps.setInt(1, sanId); ps.executeUpdate();
        }
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM dbo.San WHERE SanID = ? AND TenSan LIKE ?")) {
            ps.setInt(1, sanId); ps.setString(2, TEST_PREFIX + "%"); ps.executeUpdate();
        }
    }

    private static long countSanQRRowsForSan(int sanId) throws Exception {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.SanQR WHERE SanID = ?")) {
            ps.setInt(1, sanId);
            try (var rs = ps.executeQuery()) { rs.next(); return rs.getLong(1); }
        }
    }

    private static void setSanQrStatusDirectly(int sanId, String status) throws Exception {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("UPDATE dbo.SanQR SET TrangThai = ? WHERE SanID = ?")) {
            ps.setString(1, status);
            ps.setInt(2, sanId);
            ps.executeUpdate();
        }
    }

    /**
     * Lưới an toàn cuối cùng: nếu một test giữa chừng fail bằng exception (không
     * chỉ assertion) khiến TEST 24 không kịp chạy, @AfterAll vẫn cố dọn theo
     * prefix tên sân - không để rác nằm lại DB chỉ vì 1 test fail bất thường.
     */
    @AfterAll
    static void ensureCleanupEvenOnFailure() throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            // Thu thập toàn bộ SanID TRƯỚC, đóng ResultSet lại rồi mới DELETE - không
            // được chạy DELETE trên cùng Connection trong khi ResultSet của SELECT vẫn
            // đang mở (MultipleActiveResultSets không bật cho SQL Server ở đây), nếu
            // không cursor SELECT có thể bị JDBC driver âm thầm cắt ngang giữa chừng,
            // khiến vòng lặp chỉ dọn được MỘT phần số bản ghi rác thay vì toàn bộ.
            java.util.List<Integer> leftoverIds = new java.util.ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT SanID FROM dbo.San WHERE TenSan LIKE ?")) {
                ps.setString(1, TEST_PREFIX + "%");
                try (var rs = ps.executeQuery()) {
                    while (rs.next()) {
                        leftoverIds.add(rs.getInt(1));
                    }
                }
            }
            for (int sanId : leftoverIds) {
                cleanupThrowawaySan(conn, sanId);
            }
        }
    }
}
