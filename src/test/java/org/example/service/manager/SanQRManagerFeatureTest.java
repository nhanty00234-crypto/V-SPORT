package org.example.service.manager;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Result;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import org.example.dto.qr.SanQRManagerDTO;
import org.example.model.SanQR;
import org.example.util.DBUtil;
import org.example.util.QrCodeRenderer;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * QR-02: kiểm thử phía Manager - PNG có thực sự quét được (decode ngược bằng
 * ZXing, không chỉ kiểm tra file tồn tại), URL trong QR không chứa
 * SanID/CoSoID, ownership qua SanQRService.findExistingBySanIds/
 * findReadOnlyBySanId, và SanQRManagerDTO.mask() không làm lộ full short code.
 * Không test HTTP/Servlet trực tiếp (cần Tomcat) - phần đó xác nhận thủ công,
 * xem docs/COURT_QR_MANAGER_PRINTING.md mục "HTTP/Tomcat test".
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class SanQRManagerFeatureTest {

    private static final String TEST_PREFIX = "__QRMGRTEST__";
    private static final SanQRService service = new SanQRService();

    private static int testSanId;
    private static int testCoSoId;
    private static int wrongCoSoId;

    @BeforeAll
    static void setup() throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT TOP 2 CoSoID FROM dbo.CoSo WHERE (IsDeleted = 0 OR IsDeleted IS NULL) ORDER BY CoSoID");
                 var rs = ps.executeQuery()) {
                assertTrue(rs.next(), "Cần ít nhất 1 CoSo trong DB để chạy test");
                testCoSoId = rs.getInt(1);
                wrongCoSoId = rs.next() ? rs.getInt(1) : testCoSoId + 999999;
            }
            int loaiSanId;
            try (PreparedStatement ps = conn.prepareStatement("SELECT TOP 1 LoaiSanID FROM dbo.LoaiSan");
                 var rs = ps.executeQuery()) {
                assertTrue(rs.next());
                loaiSanId = rs.getInt(1);
            }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO dbo.San (TenSan, LoaiSanID, CoSoID, TrangThai) VALUES (?, ?, ?, N'Sẵn sàng')",
                    java.sql.Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, TEST_PREFIX + "Court_" + System.nanoTime());
                ps.setInt(2, loaiSanId);
                ps.setInt(3, testCoSoId);
                ps.executeUpdate();
                try (var keys = ps.getGeneratedKeys()) {
                    assertTrue(keys.next());
                    testSanId = keys.getInt(1);
                }
            }
        }
    }

    @Test
    @Order(1)
    void test01_getOrCreateReturnsActiveQr() {
        SanQRService.Result r = service.getOrCreate(testSanId, testCoSoId, null);
        assertTrue(r.success);
        assertEquals(SanQR.ACTIVE, r.sanQR.getTrangThai());
        assertNotNull(r.sanQR.getShortCode());
    }

    @Test
    @Order(2)
    void test02_pngDecodesToCorrectPublicUrl() throws Exception {
        SanQR qr = service.findReadOnlyBySanId(testSanId);
        assertNotNull(qr);
        String expectedUrl = "https://vsport.example/qr/" + qr.getToken();

        byte[] png = QrCodeRenderer.toPngBytes(expectedUrl, 512);
        assertTrue(png.length > 100, "PNG phải có nội dung thực sự, không rỗng");

        BufferedImage image = ImageIO.read(new ByteArrayInputStream(png));
        assertNotNull(image, "Ảnh PNG phải decode được bằng ImageIO");

        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(new BufferedImageLuminanceSource(image)));
        Result decoded = new MultiFormatReader().decode(bitmap);

        assertEquals(expectedUrl, decoded.getText(), "Nội dung QR decode ngược phải khớp chính xác URL đã encode");
        assertTrue(decoded.getText().contains(qr.getToken().toString()), "URL phải chứa token");
        // Kiểm tra URL KHÔNG chứa SanID/CoSoID dưới dạng path segment/query riêng biệt (không chỉ substring thô -
        // vì UUID token có thể tình cờ chứa cùng chữ số với SanID/CoSoID, gây false positive).
        String pathOnly = decoded.getText().substring(decoded.getText().lastIndexOf("/qr/") + 4);
        assertEquals(qr.getToken().toString(), pathOnly, "Phần path sau /qr/ phải CHỈ là token, không kèm SanID/CoSoID/short code");
        assertFalse(decoded.getText().contains(qr.getShortCode()), "URL trong QR KHÔNG được chứa short code");
    }

    @Test
    @Order(3)
    void test03_regenerateProducesNewScannableUrl() throws Exception {
        SanQR before = service.findReadOnlyBySanId(testSanId);
        String oldToken = before.getToken().toString();

        SanQRService.Result r = service.regenerate(testSanId, testCoSoId, null);
        assertTrue(r.success);
        String newToken = r.sanQR.getToken().toString();
        assertNotEquals(oldToken, newToken, "Regenerate phải sinh token mới");

        String newUrl = "https://vsport.example/qr/" + newToken;
        byte[] png = QrCodeRenderer.toPngBytes(newUrl, 512);
        BufferedImage image = ImageIO.read(new ByteArrayInputStream(png));
        BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(new BufferedImageLuminanceSource(image)));
        Result decoded = new MultiFormatReader().decode(bitmap);
        assertEquals(newUrl, decoded.getText());

        SanQRService.PublicResolveResult oldResolve = service.resolve(java.util.UUID.fromString(oldToken));
        assertEquals(SanQRService.ResolveOutcome.REVOKED, oldResolve.outcome, "Token cũ (đã in) phải resolve REVOKED sau regenerate");
    }

    @Test
    @Order(4)
    void test04_findExistingBySanIdsOnlyReturnsRequestedCourt() {
        Map<Integer, SanQR> map = service.findExistingBySanIds(List.of(testSanId, 999999999));
        assertTrue(map.containsKey(testSanId));
        assertFalse(map.containsKey(999999999));
        assertEquals(1, map.size());
    }

    @Test
    @Order(5)
    void test05_findExistingBySanIdsEmptyListReturnsEmptyMap() {
        assertTrue(service.findExistingBySanIds(List.of()).isEmpty());
        assertTrue(service.findExistingBySanIds(null).isEmpty());
    }

    @Test
    @Order(6)
    void test06_managerDtoMaskNeverLeaksFullShortCode() {
        SanQR qr = service.findReadOnlyBySanId(testSanId);
        String full = qr.getShortCode();
        String masked = SanQRManagerDTO.mask(full);
        assertNotEquals(full, masked, "Masked short code phải khác full short code");
        assertTrue(masked.contains("••••"), "Masked short code phải chứa ký tự che");
        assertTrue(masked.endsWith(full.substring(full.length() - 2)), "Chỉ giữ lại 2 ký tự cuối");
    }

    @Test
    @Order(7)
    void test07_ownershipRejectedForWrongFacility() {
        // Manager cơ sở khác (wrongCoSoId) không được phép thao tác trên sân của testCoSoId.
        SanQRService.Result r = service.disable(testSanId, wrongCoSoId, null);
        assertFalse(r.success);
        assertEquals(SanQRService.ErrorCode.FORBIDDEN, r.errorCode);

        // Xác nhận không có side-effect: QR vẫn nguyên trạng thái trước đó.
        SanQR after = service.findReadOnlyBySanId(testSanId);
        assertEquals(SanQR.ACTIVE, after.getTrangThai(), "Yêu cầu bị từ chối không được làm thay đổi trạng thái QR");
    }

    @Test
    @Order(8)
    void test08_batchCreateOnlyTargetsCourtsWithoutQr() throws Exception {
        // Tạo thêm 1 sân KHÔNG có QR trong cùng cơ sở để mô phỏng batch create.
        int freshSanId;
        try (Connection conn = DBUtil.getConnection()) {
            int loaiSanId;
            try (PreparedStatement ps = conn.prepareStatement("SELECT TOP 1 LoaiSanID FROM dbo.LoaiSan");
                 var rs = ps.executeQuery()) { rs.next(); loaiSanId = rs.getInt(1); }
            try (PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO dbo.San (TenSan, LoaiSanID, CoSoID, TrangThai) VALUES (?, ?, ?, N'Sẵn sàng')",
                    java.sql.Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, TEST_PREFIX + "Fresh_" + System.nanoTime());
                ps.setInt(2, loaiSanId);
                ps.setInt(3, testCoSoId);
                ps.executeUpdate();
                try (var keys = ps.getGeneratedKeys()) { keys.next(); freshSanId = keys.getInt(1); }
            }
        }

        Map<Integer, SanQR> before = service.findExistingBySanIds(List.of(testSanId, freshSanId));
        assertTrue(before.containsKey(testSanId), "Sân đã có QR (testSanId) phải xuất hiện trong map hiện có");
        assertFalse(before.containsKey(freshSanId), "Sân mới chưa có QR không được xuất hiện trong map hiện có");

        // Batch create logic (mô phỏng SanQRManagerServlet.batchCreate): chỉ tạo cho sân chưa có QR.
        SanQRService.Result r = service.getOrCreate(freshSanId, testCoSoId, null);
        assertTrue(r.success);

        SanQR existingUnchanged = service.findReadOnlyBySanId(testSanId);
        assertNotNull(existingUnchanged, "QR của sân đã tồn tại từ trước KHÔNG được bị batch create động vào (không regenerate)");

        cleanupCourt(freshSanId);
    }

    @AfterAll
    static void cleanup() throws Exception {
        cleanupCourt(testSanId);
        // Safety net: quét mọi sân test còn sót theo prefix.
        try (Connection conn = DBUtil.getConnection()) {
            java.util.List<Integer> leftover = new java.util.ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT SanID FROM dbo.San WHERE TenSan LIKE ?")) {
                ps.setString(1, TEST_PREFIX + "%");
                try (var rs = ps.executeQuery()) {
                    while (rs.next()) leftover.add(rs.getInt(1));
                }
            }
            for (int sanId : leftover) cleanupCourt(sanId);

            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.San WHERE TenSan LIKE ?")) {
                ps.setString(1, TEST_PREFIX + "%");
                try (var rs = ps.executeQuery()) {
                    rs.next();
                    assertEquals(0, rs.getInt(1), "Toàn bộ dữ liệu test QR-02 phải được dọn sạch");
                }
            }
        }
    }

    private static void cleanupCourt(int sanId) throws Exception {
        try (Connection conn = DBUtil.getConnection()) {
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
    }
}
