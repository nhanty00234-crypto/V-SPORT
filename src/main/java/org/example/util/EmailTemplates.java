package org.example.util;

/**
 * HTML email templates with V-SPORT branding.
 * All templates use inline CSS for maximum email client compatibility.
 */
public class EmailTemplates {

    // Brand colors
    private static final String NAVY   = "#1e3a8a";
    private static final String BLUE   = "#2563eb";
    private static final String GREEN  = "#16a34a";
    private static final String RED    = "#dc2626";
    private static final String ORANGE = "#ea580c";

    // ── OTP đăng ký tài khoản ────────────────────────────────────────────────

    public static String otpDangKy(String fullName, String otp) {
        return build(
            "🎉 Xác thực đăng ký tài khoản",
            BLUE,
            "Chào mừng bạn đến với V-SPORT!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Cảm ơn bạn đã đăng ký tài khoản V-SPORT. Vui lòng nhập mã xác thực bên dưới để hoàn tất đăng ký:",
            otpBox(otp),
            "Mã có hiệu lực trong <strong>10 phút</strong> và chỉ dùng được <strong>một lần</strong>.<br>"
            + "Không chia sẻ mã này với bất kỳ ai.",
            null,
            "info"
        );
    }

    // ── OTP quên mật khẩu ────────────────────────────────────────────────────

    public static String otpQuenMatKhau(String fullName, String otp) {
        return build(
            "🔐 Đặt lại mật khẩu",
            ORANGE,
            "Yêu cầu đặt lại mật khẩu",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản V-SPORT của bạn. Nhập mã xác thực bên dưới để tiếp tục:",
            otpBox(otp),
            "Mã có hiệu lực trong <strong>10 phút</strong> và chỉ dùng được <strong>một lần</strong>.<br>"
            + "Nếu bạn <strong>không</strong> yêu cầu đặt lại mật khẩu, hãy bỏ qua email này — tài khoản của bạn vẫn an toàn.",
            null,
            "warning"
        );
    }

    // ── Kích hoạt tài khoản nhân viên (gửi credentials) ──────────────────────

    public static String kichHoatNhanVien(String fullName, String username, String password, String otpCode) {
        String credBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0f9ff;border:1px solid #bae6fd;border-radius:8px;padding:0;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:Arial,sans-serif;'>"
            + "<p style='margin:0 0 12px 0;font-size:14px;color:#0369a1;font-weight:600;'>Thông tin đăng nhập của bạn:</p>"
            + "<p style='margin:0 0 8px 0;font-size:15px;color:#1e293b;'>👤 Tên đăng nhập: <strong style='font-family:monospace;background:#e0f2fe;padding:2px 6px;border-radius:4px;'>" + esc(username) + "</strong></p>"
            + "<p style='margin:0;font-size:15px;color:#1e293b;'>🔑 Mật khẩu tạm: <strong style='font-family:monospace;background:#e0f2fe;padding:2px 6px;border-radius:4px;'>" + esc(password) + "</strong></p>"
            + "</td></tr></table>";

        String otpSection = (otpCode != null && !otpCode.isBlank())
            ? "<p style='font-size:15px;color:#374151;margin:16px 0 8px 0;'>Và mã OTP kích hoạt tài khoản:</p>" + otpBox(otpCode)
            : "";

        return build(
            "✅ Kích hoạt tài khoản V-SPORT",
            NAVY,
            "Tài khoản của bạn đã được tạo",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Tài khoản nhân viên V-SPORT của bạn đã được tạo bởi Quản lý. Vui lòng sử dụng thông tin bên dưới để đăng nhập:",
            credBox + otpSection,
            "⚠️ Vui lòng <strong>đổi mật khẩu ngay</strong> sau lần đăng nhập đầu tiên để bảo mật tài khoản.",
            null,
            "warning"
        );
    }

    // ── Xác thực thay đổi email ───────────────────────────────────────────────

    public static String otpDoiEmail(String fullName, String otp) {
        return build(
            "📧 Xác thực thay đổi email",
            BLUE,
            "Xác thực địa chỉ email mới",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Bạn vừa yêu cầu thay đổi địa chỉ email cho tài khoản V-SPORT. Nhập mã xác thực bên dưới để xác nhận:",
            otpBox(otp),
            "Mã có hiệu lực trong <strong>5 phút</strong>.<br>"
            + "Nếu bạn không thực hiện thao tác này, vui lòng bỏ qua email này.",
            null,
            "info"
        );
    }

    // ── OTP cấu hình PayOS ────────────────────────────────────────────────────

    public static String otpPayOSConfig(String fullName, String coSoName, String otp) {
        return build(
            "🔧 Xác thực cấu hình PayOS",
            NAVY,
            "Xác thực cập nhật PayOS",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Yêu cầu cập nhật cấu hình PayOS cho cơ sở <strong>\"" + esc(coSoName) + "\"</strong> đã được gửi. Nhập mã xác thực bên dưới để tiếp tục:",
            otpBox(otp),
            "Mã có hiệu lực trong <strong>5 phút</strong> và chỉ dùng được <strong>một lần</strong>.<br>"
            + "Không chia sẻ mã này với bất kỳ ai, kể cả nhân viên V-SPORT.<br>"
            + "Nếu bạn không yêu cầu thao tác này, vui lòng kiểm tra lại tài khoản quản trị của bạn.",
            null,
            "warning"
        );
    }

    // ── Phê duyệt đối tác ────────────────────────────────────────────────────

    public static String pheQuyetDoiTac(String fullName, String email, String loginUrl) {
        String btn = button("Đăng nhập ngay", loginUrl != null ? loginUrl : "#");
        return build(
            "🎊 Đối tác V-SPORT được phê duyệt",
            GREEN,
            "Cơ sở của bạn đã được phê duyệt!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Chúng tôi vui mừng thông báo cơ sở thể thao của bạn đã được <strong style='color:" + GREEN + ";'>phê duyệt thành công</strong> bởi ban quản trị V-SPORT.<br><br>"
            + "Bạn có thể đăng nhập ngay với email: <strong>" + esc(email) + "</strong> và mật khẩu mặc định <strong>123456</strong>.",
            btn,
            "⚠️ Vui lòng <strong>đổi mật khẩu ngay</strong> sau lần đăng nhập đầu tiên để bảo mật tài khoản.",
            null,
            "success"
        );
    }

    // ── Từ chối đối tác ──────────────────────────────────────────────────────

    public static String tuChoiDoiTac(String fullName, String coSoName) {
        return build(
            "📋 Kết quả xét duyệt đối tác V-SPORT",
            RED,
            "Yêu cầu đăng ký chưa được phê duyệt",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Chúng tôi rất tiếc phải thông báo rằng yêu cầu đăng ký cơ sở <strong>\"" + esc(coSoName) + "\"</strong> của bạn hiện chưa được phê duyệt bởi ban quản trị.<br><br>"
            + "Bạn vẫn có thể đăng ký lại cơ sở mới khi sẵn sàng.",
            null,
            "Nếu bạn có thắc mắc, vui lòng liên hệ đội hỗ trợ V-SPORT để được giải đáp.",
            null,
            "info"
        );
    }

    // ── Chào mừng tài khoản mới (customer) ───────────────────────────────────

    public static String chaoMungDangKy(String fullName) {
        return build(
            "🏆 Chào mừng đến với V-SPORT!",
            BLUE,
            "Tài khoản đã được kích hoạt thành công!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Tài khoản V-SPORT của bạn đã được xác thực và kích hoạt thành công. Bạn có thể bắt đầu đặt sân, khám phá các cơ sở thể thao gần bạn và tận hưởng trải nghiệm tuyệt vời!",
            featureList(),
            "Cảm ơn bạn đã tin tưởng lựa chọn V-SPORT. Chúc bạn có những buổi tập luyện thật vui!",
            null,
            "success"
        );
    }

    // ── Xác nhận đặt sân ─────────────────────────────────────────────────────

    public static String xacNhanDatSan(String fullName, String tenSan, String ngayGio, String diaChi, String soTien) {
        String infoBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:Arial,sans-serif;'>"
            + "<p style='margin:0 0 12px 0;font-size:14px;color:#15803d;font-weight:600;'>Chi tiết đặt sân:</p>"
            + infoRow("🏟️", "Sân", tenSan)
            + infoRow("📅", "Thời gian", ngayGio)
            + infoRow("📍", "Địa chỉ", diaChi)
            + (soTien != null ? infoRow("💰", "Tổng tiền", "<strong style='color:" + GREEN + ";'>" + esc(soTien) + "</strong>") : "")
            + "</td></tr></table>";

        return build(
            "✅ Xác nhận đặt sân thành công",
            GREEN,
            "Đặt sân thành công!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Yêu cầu đặt sân của bạn đã được xác nhận. Dưới đây là thông tin chi tiết:",
            infoBox,
            "Vui lòng có mặt đúng giờ. Nếu cần hủy hoặc thay đổi, hãy liên hệ trực tiếp với cơ sở.",
            null,
            "success"
        );
    }

    // ── Hủy đặt sân ──────────────────────────────────────────────────────────

    public static String huyDatSan(String fullName, String tenSan, String ngayGio) {
        String infoBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#fef2f2;border:1px solid #fecaca;border-radius:8px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:Arial,sans-serif;'>"
            + "<p style='margin:0 0 12px 0;font-size:14px;color:#dc2626;font-weight:600;'>Thông tin đặt sân đã hủy:</p>"
            + infoRow("🏟️", "Sân", tenSan)
            + infoRow("📅", "Thời gian", ngayGio)
            + "</td></tr></table>";

        return build(
            "❌ Thông báo hủy đặt sân",
            RED,
            "Đặt sân đã được hủy",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Đặt sân dưới đây của bạn đã được hủy thành công:",
            infoBox,
            "Nếu bạn không yêu cầu hủy hoặc cần hỗ trợ, vui lòng liên hệ đội hỗ trợ V-SPORT.",
            null,
            "info"
        );
    }

    // ── Xác nhận thanh toán ───────────────────────────────────────────────────

    public static String xacNhanThanhToan(String fullName, String tenSan, String ngayGio, String soTien, String maGiaoDich) {
        String infoBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:8px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:Arial,sans-serif;'>"
            + "<p style='margin:0 0 12px 0;font-size:14px;color:#15803d;font-weight:600;'>Chi tiết giao dịch:</p>"
            + infoRow("🏟️", "Sân", tenSan)
            + infoRow("📅", "Thời gian", ngayGio)
            + infoRow("💰", "Số tiền", "<strong style='color:" + GREEN + ";'>" + esc(soTien) + "</strong>")
            + (maGiaoDich != null ? infoRow("🧾", "Mã giao dịch", "<code style='background:#e0f2fe;padding:2px 6px;border-radius:4px;font-size:13px;'>" + esc(maGiaoDich) + "</code>") : "")
            + "</td></tr></table>";

        return build(
            "💳 Xác nhận thanh toán thành công",
            GREEN,
            "Thanh toán thành công!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Chúng tôi đã nhận được thanh toán của bạn qua PayOS. Đây là thông tin giao dịch:",
            infoBox,
            "Cảm ơn bạn đã sử dụng dịch vụ V-SPORT. Hẹn gặp lại bạn trên sân! 🏃",
            null,
            "success"
        );
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static String otpBox(String otp) {
        return "<div style='text-align:center;margin:28px 0;'>"
            + "<div style='display:inline-block;background:#1e3a8a;color:#ffffff;font-size:36px;font-weight:700;"
            + "font-family:monospace,Courier New;letter-spacing:12px;padding:18px 36px;"
            + "border-radius:12px;box-shadow:0 4px 16px rgba(30,58,138,0.25);'>"
            + esc(otp)
            + "</div></div>";
    }

    private static String button(String label, String url) {
        return "<div style='text-align:center;margin:28px 0;'>"
            + "<a href='" + url + "' style='display:inline-block;background:#2563eb;color:#ffffff;"
            + "font-family:Arial,sans-serif;font-size:16px;font-weight:600;text-decoration:none;"
            + "padding:14px 36px;border-radius:8px;box-shadow:0 4px 12px rgba(37,99,235,0.3);'>"
            + label
            + "</a></div>";
    }

    private static String featureList() {
        return "<table width='100%' cellpadding='0' cellspacing='0' style='margin:20px 0;'>"
            + "<tr>"
            + featureCard("🏟️", "Đặt sân online", "Đặt sân thể thao dễ dàng, nhanh chóng")
            + featureCard("💳", "Thanh toán tiện lợi", "Thanh toán qua PayOS an toàn & nhanh gọn")
            + featureCard("👥", "Ghép kèo", "Tìm đối thủ & kết nối cộng đồng thể thao")
            + "</tr></table>";
    }

    private static String featureCard(String icon, String title, String desc) {
        return "<td style='width:33%;padding:8px;vertical-align:top;'>"
            + "<div style='background:#f8fafc;border-radius:8px;padding:16px;text-align:center;font-family:Arial,sans-serif;'>"
            + "<div style='font-size:28px;margin-bottom:8px;'>" + icon + "</div>"
            + "<div style='font-size:13px;font-weight:600;color:#1e293b;margin-bottom:4px;'>" + title + "</div>"
            + "<div style='font-size:12px;color:#64748b;'>" + desc + "</div>"
            + "</div></td>";
    }

    private static String infoRow(String icon, String label, String value) {
        return "<p style='margin:0 0 8px 0;font-size:14px;color:#1e293b;font-family:Arial,sans-serif;'>"
            + icon + " <span style='color:#6b7280;'>" + label + ":</span> " + value + "</p>";
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    private static String build(String browserTitle, String accentColor, String headline,
                                 String intro, String mainContent, String note,
                                 String footer, String noteType) {
        String noteBg, noteColor, noteBorder;
        switch (noteType != null ? noteType : "info") {
            case "success":
                noteBg = "#f0fdf4"; noteColor = "#15803d"; noteBorder = "#bbf7d0"; break;
            case "warning":
                noteBg = "#fffbeb"; noteColor = "#92400e"; noteBorder = "#fde68a"; break;
            default:
                noteBg = "#eff6ff"; noteColor = "#1d4ed8"; noteBorder = "#bfdbfe";
        }

        return "<!DOCTYPE html><html lang='vi'><head>"
            + "<meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1.0'>"
            + "<title>" + esc(browserTitle) + "</title></head>"
            + "<body style='margin:0;padding:0;background:#f1f5f9;font-family:Arial,Helvetica,sans-serif;'>"
            + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f1f5f9;padding:32px 0;'>"
            + "<tr><td align='center'>"

            // Card
            + "<table width='600' cellpadding='0' cellspacing='0' style='max-width:600px;width:100%;background:#ffffff;"
            + "border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);'>"

            // Header
            + "<tr><td style='background:" + accentColor + ";padding:32px 40px;text-align:center;'>"
            + "<div style='font-size:28px;font-weight:800;color:#ffffff;letter-spacing:2px;'>V-SPORT</div>"
            + "<div style='font-size:12px;color:rgba(255,255,255,0.75);margin-top:4px;letter-spacing:1px;'>HỆ THỐNG ĐẶT SÂN THỂ THAO</div>"
            + "</td></tr>"

            // Accent bar
            + "<tr><td style='height:4px;background:linear-gradient(90deg,#2563eb,#7c3aed,#db2777);'></td></tr>"

            // Body
            + "<tr><td style='padding:40px;'>"
            + "<h2 style='margin:0 0 20px 0;font-size:22px;font-weight:700;color:#1e293b;'>" + headline + "</h2>"
            + "<p style='margin:0 0 20px 0;font-size:15px;color:#374151;line-height:1.7;'>" + intro + "</p>"
            + (mainContent != null ? mainContent : "")
            + (note != null
                ? "<div style='background:" + noteBg + ";border-left:4px solid " + noteColor + ";border-radius:0 8px 8px 0;"
                  + "padding:14px 18px;margin-top:24px;font-size:14px;color:" + noteColor + ";line-height:1.6;'>"
                  + note + "</div>"
                : "")
            + "</td></tr>"

            // Footer
            + "<tr><td style='background:#f8fafc;padding:24px 40px;text-align:center;border-top:1px solid #e2e8f0;'>"
            + "<p style='margin:0 0 6px 0;font-size:13px;font-weight:700;color:#1e3a8a;letter-spacing:1px;'>V-SPORT</p>"
            + "<p style='margin:0;font-size:12px;color:#94a3b8;line-height:1.6;'>"
            + "Email này được gửi tự động từ hệ thống V-SPORT.<br>"
            + "Vui lòng không trả lời email này."
            + (footer != null ? "<br>" + footer : "")
            + "</p></td></tr>"

            + "</table></td></tr></table></body></html>";
    }
}
