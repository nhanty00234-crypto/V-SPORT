package org.example.service.manager;

import org.example.model.SanQR;
import org.example.util.DBUtil;
import org.junit.jupiter.api.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Smoke test vòng đời SanQRService trên DB thật (QR-01). Chạy thủ công, cần DB
 * QuanLiSport có ít nhất 1 sân chưa xóa mềm - tự dò TOP 1 San thay vì hard-code
 * SanID để không phụ thuộc dữ liệu seed cụ thể của máy chạy.
 *
 * Yêu cầu chạy sql/migration_san_qr.sql trước (xem RunSanQRMigrationTest).
 *
 * Không dùng @BeforeAll/@AfterAll dọn DB tự động - đây là smoke test thủ công
 * theo đúng convention các *Test.java khác trong project (VerifyCoSoConfigTest,
 * FindActiveCheckinsTest), người chạy tự xem log để xác nhận kết quả.
 */
class SanQRServiceSmokeTest {

    private final SanQRService service = new SanQRService();

    private static class TestSan {
        int sanId;
        int coSoId;
    }

    private TestSan findAnySan() throws Exception {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT TOP 1 SanID, CoSoID FROM dbo.San WHERE (IsDeleted = 0 OR IsDeleted IS NULL) ORDER BY SanID");
             ResultSet rs = ps.executeQuery()) {
            assertTrue(rs.next(), "Cần ít nhất 1 sân chưa xóa mềm trong DB để chạy smoke test này");
            TestSan t = new TestSan();
            t.sanId = rs.getInt("SanID");
            t.coSoId = rs.getInt("CoSoID");
            return t;
        }
    }

    @Test
    void fullLifecycle_createEnableDisableRegenerateResolve() throws Exception {
        TestSan san = findAnySan();
        System.out.println("=== SMOKE TEST SanQRService trên SanID=" + san.sanId + " (CoSoID=" + san.coSoId + ") ===");

        // 1. getOrCreate - idempotent
        SanQRService.Result r1 = service.getOrCreate(san.sanId, san.coSoId, null);
        assertTrue(r1.success, "getOrCreate lần 1 phải thành công: " + r1.errorMessage);
        UUID firstToken = r1.sanQR.getToken();
        assertNotNull(firstToken);
        assertEquals(SanQR.ACTIVE, r1.sanQR.getTrangThai());
        System.out.println("OK: getOrCreate lần 1 -> token=" + firstToken);

        SanQRService.Result r1b = service.getOrCreate(san.sanId, san.coSoId, null);
        assertTrue(r1b.success);
        assertEquals(firstToken, r1b.sanQR.getToken(), "getOrCreate gọi lại không được tạo token mới (idempotent)");
        System.out.println("OK: getOrCreate lần 2 idempotent, cùng token");

        // 2. Ownership: cơ sở khác không được thao tác
        SanQRService.Result rForbidden = service.disable(san.sanId, san.coSoId + 999999, null);
        assertFalse(rForbidden.success);
        assertEquals(SanQRService.ErrorCode.FORBIDDEN, rForbidden.errorCode);
        System.out.println("OK: coSoId sai bị từ chối FORBIDDEN");

        // 3. resolve khi đang ACTIVE -> OK
        SanQRService.ResolveResult resolveActive = service.resolve(firstToken);
        assertEquals(SanQRService.ResolveOutcome.OK, resolveActive.outcome);
        assertNotNull(resolveActive.san);
        assertEquals(san.sanId, resolveActive.san.getSanID());
        System.out.println("OK: resolve token ACTIVE -> OK, đúng SanID");

        // 4. disable -> resolve phải trả DISABLED, không phải NOT_FOUND
        SanQRService.Result rDisable = service.disable(san.sanId, san.coSoId, null);
        assertTrue(rDisable.success, rDisable.errorMessage);
        assertEquals(SanQR.DISABLED, rDisable.sanQR.getTrangThai());
        SanQRService.ResolveResult resolveDisabled = service.resolve(firstToken);
        assertEquals(SanQRService.ResolveOutcome.DISABLED, resolveDisabled.outcome);
        System.out.println("OK: disable() -> resolve trả DISABLED (không lộ nhầm NOT_FOUND)");

        // 5. enable -> resolve lại OK, token không đổi
        SanQRService.Result rEnable = service.enable(san.sanId, san.coSoId, null);
        assertTrue(rEnable.success, rEnable.errorMessage);
        assertEquals(SanQR.ACTIVE, rEnable.sanQR.getTrangThai());
        assertEquals(firstToken, rEnable.sanQR.getToken(), "enable() không được đổi token");
        System.out.println("OK: enable() khôi phục ACTIVE, giữ nguyên token");

        // 6. regenerate -> token mới, token cũ bị REVOKED khi resolve
        SanQRService.Result rRegen = service.regenerate(san.sanId, san.coSoId, null);
        assertTrue(rRegen.success, rRegen.errorMessage);
        UUID secondToken = rRegen.sanQR.getToken();
        assertNotEquals(firstToken, secondToken, "regenerate phải sinh token mới");
        assertEquals(SanQR.ACTIVE, rRegen.sanQR.getTrangThai());
        assertEquals(1, rRegen.sanQR.getRegenerateCount());
        System.out.println("OK: regenerate -> token mới=" + secondToken + ", regenerateCount=1");

        SanQRService.ResolveResult resolveOldToken = service.resolve(firstToken);
        assertEquals(SanQRService.ResolveOutcome.REVOKED, resolveOldToken.outcome,
                "Token cũ sau regenerate phải bị từ chối REVOKED, không phải NOT_FOUND im lặng");
        System.out.println("OK: quét lại token CŨ sau regenerate -> REVOKED (đúng, không phải NOT_FOUND mơ hồ)");

        SanQRService.ResolveResult resolveNewToken = service.resolve(secondToken);
        assertEquals(SanQRService.ResolveOutcome.OK, resolveNewToken.outcome);
        System.out.println("OK: quét token MỚI -> OK");

        // 7. resolve token ngẫu nhiên không tồn tại -> NOT_FOUND, không throw
        SanQRService.ResolveResult resolveRandom = service.resolve(UUID.randomUUID());
        assertEquals(SanQRService.ResolveOutcome.NOT_FOUND, resolveRandom.outcome);
        System.out.println("OK: token ngẫu nhiên không tồn tại -> NOT_FOUND");

        // 8. resolve token null -> NOT_FOUND, không NPE
        SanQRService.ResolveResult resolveNull = service.resolve(null);
        assertEquals(SanQRService.ResolveOutcome.NOT_FOUND, resolveNull.outcome);
        System.out.println("OK: token null -> NOT_FOUND, không throw");

        System.out.println("=== SMOKE TEST HOÀN TẤT - lưu ý: đã để lại QR ACTIVE token=" + secondToken
                + " trên SanID=" + san.sanId + ", chạy lại getOrCreate lần sau vẫn idempotent ===");
    }

    @Test
    void concurrentRegenerate_onlyResultsInOneFinalActiveToken() throws Exception {
        TestSan san = findAnySan();
        service.getOrCreate(san.sanId, san.coSoId, null); // đảm bảo đã có QR trước khi test concurrency

        int threads = 5;
        Thread[] workers = new Thread[threads];
        SanQRService.Result[] results = new SanQRService.Result[threads];
        for (int i = 0; i < threads; i++) {
            final int idx = i;
            workers[i] = new Thread(() -> results[idx] = service.regenerate(san.sanId, san.coSoId, null));
        }
        for (Thread t : workers) t.start();
        for (Thread t : workers) t.join();

        long successCount = 0;
        for (SanQRService.Result r : results) {
            assertNotNull(r, "Mỗi thread phải trả về kết quả, không được bị treo/throw ra ngoài");
            if (r.success) successCount++;
        }
        // PESSIMISTIC_WRITE khiến 5 request serialize thay vì chạy song song - tất cả
        // ĐỀU phải thành công tuần tự (không request nào bị lỗi do đụng độ), nhưng kết
        // quả cuối cùng trong DB chỉ có ĐÚNG 1 token active tại một thời điểm.
        assertEquals(threads, successCount, "Mọi request regenerate tuần tự đều phải thành công nhờ khóa PESSIMISTIC_WRITE");

        SanQRService.Result finalState = service.getOrCreate(san.sanId, san.coSoId, null);
        assertTrue(finalState.success);
        assertEquals(SanQR.ACTIVE, finalState.sanQR.getTrangThai());
        assertEquals(threads, finalState.sanQR.getRegenerateCount(),
                "regenerateCount phải cộng dồn đúng đủ " + threads + " lần, không mất lần nào do race condition");
        System.out.println("OK: " + threads + " regenerate đồng thời -> tất cả thành công tuần tự, "
                + "trạng thái cuối cùng nhất quán (regenerateCount=" + finalState.sanQR.getRegenerateCount() + ")");
    }
}
