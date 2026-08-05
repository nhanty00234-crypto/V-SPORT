package org.example.util;

/**
 * HTML email templates with modern V-SPORT branding.
 * All templates use inline CSS for maximum email client compatibility (Gmail, Outlook, Apple Mail).
 */
public class EmailTemplates {

    // Brand colors
    private static final String NAVY   = "#0f172a";
    private static final String BLUE   = "#1d4ed8";
    private static final String GREEN  = "#047857";
    private static final String RED    = "#b91c1c";
    private static final String ORANGE = "#c2410c";

    // ── OTP đăng ký tài khoản ────────────────────────────────────────────────

    public static String otpDangKy(String fullName, String otp) {
        return build(
            "Mã xác thực đăng ký - V-SPORT",
            BLUE,
            "Mã xác thực",
            "Chỉ còn một bước nữa để hoàn tất xác thực email cho tài khoản <strong>V-SPORT</strong>.",
            otpBox(otp),
            "Mã xác thực này sẽ hết hạn sau <strong>10 phút</strong>.<br><br>"
            + "Để đảm bảo an toàn cho tài khoản, đừng chia sẻ mã này với bất kỳ ai."
            + " Nếu bạn không gửi yêu cầu này, hãy yên tâm bỏ qua email.",
            null,
            "info"
        );
    }

    // ── Mật khẩu mới khi quên mật khẩu (gửi trực tiếp, không qua OTP) ────────

    public static String matKhauMoiQuenMatKhau(String fullName, String newPassword, String loginUrl) {
        String pwBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0f9ff;border:1px solid #bae6fd;border-radius:12px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;text-align:center;'>"
            + "<div style='font-size:13px;color:#0369a1;margin-bottom:10px;'>Mật khẩu mới của bạn</div>"
            + "<strong style='font-family:Consolas,monospace;font-size:20px;letter-spacing:1px;color:#0f172a;background:#ffffff;border:1px solid #e0f2fe;padding:10px 18px;border-radius:8px;display:inline-block;'>"
            + esc(newPassword) + "</strong>"
            + "</td></tr></table>";
        String mainContent = pwBox + (loginUrl != null ? button("Đăng nhập ngay ➔", loginUrl) : "");

        return build(
            "Mật khẩu mới - V-SPORT",
            ORANGE,
            "Mật khẩu mới đã được cấp",
            "Hệ thống vừa nhận được yêu cầu đặt lại mật khẩu cho tài khoản <strong>V-SPORT</strong> của bạn."
            + " Một mật khẩu mới đã được tạo tự động, vui lòng dùng mật khẩu bên dưới để đăng nhập:",
            mainContent,
            "Vì lý do bảo mật, hãy <strong>đổi mật khẩu ngay</strong> sau khi đăng nhập.<br><br>"
            + "Nếu bạn <strong>không thực hiện</strong> yêu cầu này, vui lòng liên hệ ngay với đội ngũ hỗ trợ V-SPORT.",
            null,
            "warning"
        );
    }

    // ── Kích hoạt tài khoản nhân viên (gửi credentials) ──────────────────────

    public static String kichHoatNhanVien(String fullName, String username, String password, String otpCode) {
        String credBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0f9ff;border:1px solid #bae6fd;border-radius:12px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;'>"
            + "<div style='font-size:14px;color:#0369a1;font-weight:700;margin-bottom:12px;'>🔑 Thông tin đăng nhập tài khoản nhân viên:</div>"
            + "<div style='background:#ffffff;border:1px solid #e0f2fe;border-radius:8px;padding:12px 16px;margin-bottom:10px;'>"
            + "<span style='font-size:13px;color:#64748b;'>Tên đăng nhập: </span>"
            + "<strong style='font-family:Consolas,monospace;font-size:15px;color:#0f172a;background:#f1f5f9;padding:2px 8px;border-radius:4px;'>" + esc(username) + "</strong>"
            + "</div>"
            + "<div style='background:#ffffff;border:1px solid #e0f2fe;border-radius:8px;padding:12px 16px;'>"
            + "<span style='font-size:13px;color:#64748b;'>Mật khẩu tạm thời: </span>"
            + "<strong style='font-family:Consolas,monospace;font-size:15px;color:#0f172a;background:#f1f5f9;padding:2px 8px;border-radius:4px;'>" + esc(password) + "</strong>"
            + "</div>"
            + "</td></tr></table>";

        String otpSection = (otpCode != null && !otpCode.isBlank())
            ? "<p style='font-size:14px;color:#334155;margin:20px 0 8px 0;font-weight:600;'>Mã OTP xác thực kích hoạt:</p>" + otpBox(otpCode)
            : "";

        return build(
            "Kích hoạt tài khoản nhân viên - V-SPORT",
            NAVY,
            "Tài khoản làm việc đã sẵn sàng",
            "Tài khoản nhân viên hệ thống <strong>V-SPORT</strong> của bạn đã được khởi tạo bởi ban quản lý."
            + " Vui lòng sử dụng thông tin đăng nhập được cấp dưới đây:",
            credBox + otpSection,
            "<strong>Lưu ý quan trọng:</strong> Vì mục đích an toàn thông tin, vui lòng"
            + " <strong>đổi mật khẩu mới ngay lập tức</strong> sau khi đăng nhập lần đầu tiên.",
            null,
            "warning"
        );
    }

    // ── Xác thực thay đổi email ───────────────────────────────────────────────

    public static String otpDoiEmail(String fullName, String otp) {
        return build(
            "Xác thực thay đổi Email - V-SPORT",
            BLUE,
            "Xác thực email mới",
            "Bạn đã gửi yêu cầu thay đổi địa chỉ email liên kết với tài khoản <strong>V-SPORT</strong>."
            + " Nhập mã xác nhận bên dưới để hoàn tất thay đổi:",
            otpBox(otp),
            "Mã có hiệu lực trong <strong>5 phút</strong>.<br><br>"
            + "Nếu bạn không thực hiện thay đổi này, hãy liên hệ ngay với đội ngũ hỗ trợ V-SPORT.",
            null,
            "info"
        );
    }

    // ── OTP cấu hình PayOS ────────────────────────────────────────────────────

    public static String otpPayOSConfig(String fullName, String coSoName, String otp) {
        return build(
            "Xác thực cấu hình PayOS - V-SPORT",
            NAVY,
            "Xác thực cấu hình thanh toán",
            "Hệ thống ghi nhận thao tác cập nhật cấu hình cổng thanh toán PayOS cho cơ sở"
            + " <strong>\"" + esc(coSoName) + "\"</strong>. Vui lòng nhập mã xác thực để tiếp tục:",
            otpBox(otp),
            "Mã có hiệu lực trong <strong>5 phút</strong> và chỉ dùng được <strong>1 lần</strong>.<br><br>"
            + "Tuyệt đối không cung cấp mã này cho bất kỳ ai khác.",
            null,
            "warning"
        );
    }

    // ── Phê duyệt đối tác ────────────────────────────────────────────────────

    public static String pheQuyetDoiTac(String fullName, String email, String rawPassword, String loginUrl) {
        String btn = button("Đăng nhập Cổng Quản Lý ngay ➔", loginUrl != null ? loginUrl : "#");
        String pwDisplay = rawPassword != null && !rawPassword.isBlank() ? esc(rawPassword) : "(liên hệ quản trị viên)";
        return build(
            "Phê duyệt đối tác V-SPORT",
            GREEN,
            "Cơ sở đã được duyệt thành công!",
            "Ban quản trị <strong>V-SPORT</strong> xin thông báo: Đơn đăng ký tham gia mạng lưới cơ sở thể thao"
            + " đã được <strong>PHÊ DUYỆT THÀNH CÔNG</strong>.<br><br>"
            + "Thông tin đăng nhập quản lý cơ sở:<br>"
            + "• Email: <strong>" + esc(email) + "</strong><br>"
            + "• Mật khẩu: <strong style='font-family:Consolas,monospace;background:#f3f4f6;padding:2px 8px;border-radius:4px;'>" + pwDisplay + "</strong>",
            btn,
            "Hãy <strong>thay đổi mật khẩu ngay</strong> sau lần đăng nhập đầu tiên để bảo mật tài khoản.",
            null,
            "success"
        );
    }

    /** @deprecated Dùng {@link #pheQuyetDoiTac(String, String, String, String)} */
    @Deprecated
    public static String pheQuyetDoiTac(String fullName, String email, String loginUrl) {
        return pheQuyetDoiTac(fullName, email, null, loginUrl);
    }

    // ── Từ chối đối tác ──────────────────────────────────────────────────────

    public static String tuChoiDoiTac(String fullName, String coSoName) {
        return build(
            "Thông báo kết quả đăng ký - V-SPORT",
            RED,
            "Thông tin đăng ký cần được cập nhật",
            "Cảm ơn bạn đã quan tâm đến việc hợp tác cùng <strong>V-SPORT</strong>."
            + " Sau khi xem xét hồ sơ đăng ký cơ sở <strong>\"" + esc(coSoName) + "\"</strong>,"
            + " ban quản trị rất tiếc chưa thể chấp thuận đơn đăng ký ở thời điểm này.<br><br>"
            + "Bạn có thể kiểm tra lại thông tin hồ sơ và gửi lại đơn đăng ký mới trên hệ thống.",
            null,
            "Nếu bạn cần thêm thông tin hoặc giải đáp chi tiết, xin vui lòng liên hệ qua bộ phận CSKH của V-SPORT.",
            null,
            "info"
        );
    }

    // ── Chào mừng tài khoản mới (customer) ───────────────────────────────────

    public static String chaoMungDangKy(String fullName) {
        return build(
            "Chào mừng đến với V-SPORT!",
            BLUE,
            "Tài khoản đã được kích hoạt!",
            "Chúc mừng bạn đã gia nhập cộng đồng thể thao <strong>V-SPORT</strong>!"
            + " Tài khoản của bạn hiện đã sẵn sàng để trải nghiệm dịch vụ đặt sân trực tuyến nhanh chóng, tiện lợi.",
            featureList(),
            "Hãy sẵn sàng ra sân và tận hưởng những giờ phút luyện tập thể thao sôi động nhất!",
            null,
            "success"
        );
    }

    // ── Xác nhận đặt sân ─────────────────────────────────────────────────────

    public static String xacNhanDatSan(String fullName, String tenSan, String ngayGio, String diaChi, String soTien) {
        String infoBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;'>"
            + "<div style='font-size:14px;color:#15803d;font-weight:700;margin-bottom:12px;'>📋 Chi tiết lịch đặt sân:</div>"
            + infoRow("🏟️", "Tên sân", tenSan)
            + infoRow("📅", "Khung giờ", ngayGio)
            + infoRow("📍", "Địa điểm", diaChi)
            + (soTien != null ? infoRow("💰", "Tổng thanh toán", "<strong style='color:" + GREEN + ";font-size:16px;'>" + esc(soTien) + "</strong>") : "")
            + "</td></tr></table>";

        return build(
            "Xác nhận đặt sân thành công - V-SPORT",
            GREEN,
            "Đặt sân thành công!",
            "Yêu cầu đặt sân thể thao của bạn đã được ghi nhận và xác nhận thành công trên hệ thống <strong>V-SPORT</strong>:",
            infoBox,
            "Vui lòng có mặt đúng giờ trước 10–15 phút. Khi tới sân, bạn chỉ cần đọc tên hoặc giơ thông tin email này cho nhân viên.",
            null,
            "success"
        );
    }

    // ── Hủy đặt sân ──────────────────────────────────────────────────────────

    public static String huyDatSan(String fullName, String tenSan, String ngayGio) {
        String infoBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#fef2f2;border:1px solid #fecaca;border-radius:12px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;'>"
            + "<div style='font-size:14px;color:#dc2626;font-weight:700;margin-bottom:12px;'>🚫 Thông tin lịch đặt đã hủy:</div>"
            + infoRow("🏟️", "Tên sân", tenSan)
            + infoRow("📅", "Khung giờ", ngayGio)
            + "</td></tr></table>";

        return build(
            "Thông báo hủy lịch đặt sân - V-SPORT",
            RED,
            "Lịch đặt sân đã được hủy",
            "Hệ thống <strong>V-SPORT</strong> xác nhận lịch đặt sân dưới đây của bạn đã được hủy thành công:",
            infoBox,
            "Nếu bạn có nhu cầu đặt lại sân hoặc cần hỗ trợ về hoàn tiền (nếu có), vui lòng truy cập trang cá nhân hoặc liên hệ bộ phận hỗ trợ.",
            null,
            "info"
        );
    }

    // ── Xác nhận thanh toán ───────────────────────────────────────────────────

    public static String xacNhanThanhToan(String fullName, String tenSan, String ngayGio, String soTien, String maGiaoDich) {
        String infoBox = "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;margin:20px 0;'>"
            + "<tr><td style='padding:20px;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;'>"
            + "<div style='font-size:14px;color:#15803d;font-weight:700;margin-bottom:12px;'>💳 Biên nhận giao dịch thanh toán:</div>"
            + infoRow("🏟️", "Tên sân", tenSan)
            + infoRow("📅", "Khung giờ", ngayGio)
            + infoRow("💰", "Số tiền đã trả", "<strong style='color:" + GREEN + ";font-size:16px;'>" + esc(soTien) + "</strong>")
            + (maGiaoDich != null ? infoRow("🧾", "Mã giao dịch PayOS", "<code style='background:#e2e8f0;padding:2px 8px;border-radius:4px;font-size:13px;font-weight:600;color:#1e293b;'>" + esc(maGiaoDich) + "</code>") : "")
            + "</td></tr></table>";

        return build(
            "Xác nhận thanh toán thành công - V-SPORT",
            GREEN,
            "Thanh toán hoàn tất!",
            "Chúng tôi đã nhận được khoản thanh toán trực tuyến qua cổng PayOS cho dịch vụ của bạn."
            + " Dưới đây là chi tiết biên nhận:",
            infoBox,
            "Cảm ơn bạn đã tin dùng V-SPORT. Hẹn gặp lại bạn trên sân tập!",
            null,
            "success"
        );
    }

    // ── Helpers & Formatting ──────────────────────────────────────────────────

    /**
     * Renders OTP as spaced digits inside a single rounded gray box (Casso-style).
     */
    private static String otpBox(String otp) {
        if (otp == null) otp = "------";
        String cleanOtp = otp.trim();

        StringBuilder spaced = new StringBuilder();
        for (int i = 0; i < cleanOtp.length(); i++) {
            if (i > 0) spaced.append("  ");
            spaced.append(cleanOtp.charAt(i));
        }

        return "<table cellpadding='0' cellspacing='0' border='0' align='center' style='margin:24px auto;width:100%;max-width:480px;'>"
            + "<tr><td align='center'>"
            + "<div style='background:#f3f4f6;border-radius:12px;padding:24px 32px;display:inline-block;'>"
            + "<span style='font-family:Consolas,\"Courier New\",Courier,monospace;font-size:36px;font-weight:700;letter-spacing:10px;color:#111827;'>"
            + esc(spaced.toString())
            + "</span>"
            + "</div>"
            + "</td></tr></table>";
    }

    private static String button(String label, String url) {
        return "<table cellpadding='0' cellspacing='0' border='0' align='center' style='margin:28px auto;'><tr><td align='center'>"
            + "<a href='" + url + "' style='display:inline-block;background:linear-gradient(135deg,#1d4ed8 0%,#2563eb 100%);color:#ffffff;"
            + "font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;font-size:15px;font-weight:700;text-decoration:none;"
            + "padding:14px 34px;border-radius:10px;box-shadow:0 6px 20px rgba(37,99,235,0.35);letter-spacing:0.3px;'>"
            + label
            + "</a></td></tr></table>";
    }

    private static String featureList() {
        return "<table width='100%' cellpadding='0' cellspacing='0' style='margin:24px 0;'>"
            + "<tr>"
            + featureCard("🏟️", "Đặt Sân Trực Tuyến", "Tìm kiếm & giữ sân thể thao mong muốn cực dễ")
            + featureCard("💳", "PayOS Tiện Lợi", "Thanh toán QR Code an toàn & xác nhận tự động")
            + featureCard("👥", "Ghép Kèo Đấu", "Tìm đối thủ & mở rộng giao lưu thể thao")
            + "</tr></table>";
    }

    private static String featureCard(String icon, String title, String desc) {
        return "<td style='width:33.33%;padding:6px;vertical-align:top;'>"
            + "<div style='background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:16px 10px;text-align:center;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;height:100%;'>"
            + "<div style='font-size:26px;margin-bottom:8px;'>" + icon + "</div>"
            + "<div style='font-size:13px;font-weight:700;color:#0f172a;margin-bottom:4px;'>" + title + "</div>"
            + "<div style='font-size:11px;color:#64748b;line-height:1.4;'>" + desc + "</div>"
            + "</div></td>";
    }

    private static String infoRow(String icon, String label, String value) {
        return "<div style='margin-bottom:10px;font-size:14px;color:#334155;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,sans-serif;'>"
            + "<span style='margin-right:8px;font-size:16px;'>" + icon + "</span>"
            + "<span style='color:#64748b;min-width:110px;display:inline-block;'>" + label + ":</span> "
            + "<span style='color:#0f172a;font-weight:600;'>" + value + "</span>"
            + "</div>";
    }

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    private static String build(String browserTitle, String accentColor, String headline,
                                 String intro, String mainContent, String note,
                                 String footer, String noteType) {
        String headerColor = accentColor != null ? accentColor : "#1d4ed8";

        String noteHtml = "";
        if (note != null) {
            noteHtml = "<p style='margin:20px 0 0 0;font-size:13.5px;color:#374151;line-height:1.7;'>"
                + note + "</p>";
        }

        return "<!DOCTYPE html><html lang='vi'><head>"
            + "<meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1.0'>"
            + "<title>" + esc(browserTitle) + "</title></head>"
            + "<body style='margin:0;padding:0;background-color:#f3f4f6;"
            + "font-family:-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif;'>"
            + "<table width='100%' cellpadding='0' cellspacing='0' style='background-color:#f3f4f6;padding:40px 16px;'>"
            + "<tr><td align='center'>"

            // Card
            + "<table width='560' cellpadding='0' cellspacing='0' "
            + "style='max-width:560px;width:100%;background:#ffffff;border-radius:8px;"
            + "overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);'>"

            // Header — solid color, title only
            + "<tr><td style='background:" + headerColor + ";padding:22px 32px;'>"
            + "<p style='margin:0;font-size:18px;font-weight:700;color:#ffffff;letter-spacing:0.2px;'>"
            + "V-SPORT &mdash; " + headline
            + "</p>"
            + "</td></tr>"

            // Body
            + "<tr><td style='padding:32px 32px 24px 32px;'>"
            + "<p style='margin:0 0 16px 0;font-size:15px;color:#111827;'>Xin ch&#224;o,</p>"
            + "<p style='margin:0 0 8px 0;font-size:15px;color:#374151;line-height:1.7;'>" + intro + "</p>"
            + (mainContent != null ? mainContent : "")
            + noteHtml
            + "</td></tr>"

            // Footer
            + "<tr><td style='padding:18px 32px 24px 32px;border-top:1px solid #e5e7eb;'>"
            + "<p style='margin:0;font-size:12px;color:#9ca3af;line-height:1.6;font-style:italic;'>"
            + "&#272;&#226;y l&#224; email &#273;&#432;&#7907;c g&#7917;i t&#7921; &#273;&#7897;ng t&#7915; h&#7879; th&#7889;ng V-SPORT."
            + " Vui l&#242;ng kh&#244;ng ph&#7843;n h&#7891;i tr&#7921;c ti&#7871;p email n&#224;y."
            + (footer != null ? "<br>" + footer : "")
            + "<br>N&#7871;u b&#7841;n c&#7847;n tr&#7907; gi&#250;p, xin vui l&#242;ng li&#234;n h&#7879; "
            + "<a href='mailto:support@vsport.vn' style='color:#6b7280;'>support@vsport.vn</a>."
            + "</p>"
            + "</td></tr>"

            + "</table></td></tr></table></body></html>";
    }
}
