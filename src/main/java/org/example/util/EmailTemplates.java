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
            "🎉 Mã xác thực đăng ký - V-SPORT",
            BLUE,
            "Chào mừng bạn đến với V-SPORT!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Cảm ơn bạn đã lựa chọn V-SPORT! Để hoàn tất quá trình tạo tài khoản, vui lòng sử dụng mã xác thực OTP 6 chữ số dưới đây:",
            otpBox(otp),
            "⏱️ Mã xác thực này có hiệu lực trong <strong>10 phút</strong> và chỉ sử dụng được <strong>1 lần</strong>.<br>"
            + "🔒 Vì lý do an toàn, xin vui lòng không chia sẻ mã này với bất kỳ ai.",
            null,
            "info"
        );
    }

    // ── OTP quên mật khẩu ────────────────────────────────────────────────────

    public static String otpQuenMatKhau(String fullName, String otp) {
        return build(
            "🔐 Đặt lại mật khẩu - V-SPORT",
            ORANGE,
            "Yêu cầu đặt lại mật khẩu",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Hệ thống vừa nhận được yêu cầu đặt lại mật khẩu cho tài khoản V-SPORT của bạn. Vui lòng nhập mã xác thực OTP bên dưới để tiến hành khôi phục mật khẩu:",
            otpBox(otp),
            "⏱️ Mã OTP có hiệu lực trong <strong>10 phút</strong>.<br>"
            + "🛡️ Nếu bạn <strong>không thực hiện</strong> yêu cầu này, vui lòng bỏ qua email — tài khoản của bạn luôn được an toàn tuyệt đối.",
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
            "✅ Kích hoạt tài khoản nhân viên - V-SPORT",
            NAVY,
            "Tài khoản làm việc đã sẵn sàng",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Tài khoản nhân viên hệ thống V-SPORT của bạn đã được khởi tạo bởi ban quản lý. Vui lòng sử dụng thông tin đăng nhập được cấp dưới đây:",
            credBox + otpSection,
            "⚠️ <strong>Lưu ý quan trọng:</strong> Vì mục đích an toàn thông tin, vui lòng <strong>đổi mật khẩu mới ngay lập tức</strong> sau khi đăng nhập lần đầu tiên.",
            null,
            "warning"
        );
    }

    // ── Xác thực thay đổi email ───────────────────────────────────────────────

    public static String otpDoiEmail(String fullName, String otp) {
        return build(
            "📧 Xác thực thay đổi Email - V-SPORT",
            BLUE,
            "Xác thực địa chỉ email mới",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Bạn đã gửi yêu cầu thay đổi địa chỉ email liên kết với tài khoản V-SPORT. Nhập mã OTP xác nhận bên dưới để hoàn tất thay đổi:",
            otpBox(otp),
            "⏱️ Mã có hiệu lực trong <strong>5 phút</strong>.<br>"
            + "Nếu bạn không thực hiện thay đổi này, hãy liên hệ ngay với đỗi ngũ hỗ trợ V-SPORT.",
            null,
            "info"
        );
    }

    // ── OTP cấu hình PayOS ────────────────────────────────────────────────────

    public static String otpPayOSConfig(String fullName, String coSoName, String otp) {
        return build(
            "⚡ Xác thực cấu hình PayOS - V-SPORT",
            NAVY,
            "Xác thực cập nhật cấu hình thanh toán",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Hệ thống ghi nhận thao tác cập nhật cấu hình cổng thanh toán PayOS cho cơ sở <strong>\"" + esc(coSoName) + "\"</strong>. Vui lòng nhập mã OTP xác thực:",
            otpBox(otp),
            "⏱️ Mã có hiệu lực trong <strong>5 phút</strong> và chỉ dùng được <strong>1 lần</strong>.<br>"
            + "🚨 Tuyệt đối không cung cấp mã OTP này cho bất kỳ ai khác.",
            null,
            "warning"
        );
    }

    // ── Phê duyệt đối tác ────────────────────────────────────────────────────

    public static String pheQuyetDoiTac(String fullName, String email, String rawPassword, String loginUrl) {
        String btn = button("Đăng nhập Cổng Quản Lý ngay ➔", loginUrl != null ? loginUrl : "#");
        String pwDisplay = rawPassword != null && !rawPassword.isBlank() ? esc(rawPassword) : "(liên hệ quản trị viên)";
        return build(
            "🎊 Phê duyệt đối tác V-SPORT",
            GREEN,
            "Cơ sở của bạn đã được duyệt thành công!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Ban quản trị V-SPORT xin thông báo: Đơn đăng ký tham gia mạng lưới cơ sở thể thao <strong>\"" + esc(fullName) + "\"</strong> đã được <strong style='color:" + GREEN + ";'>PHÊ DUYỆT THÀNH CÔNG</strong>.<br><br>"
            + "Bạn có thể sử dụng thông tin sau để đăng nhập quản lý cơ sở:<br>"
            + "• Email đăng nhập: <strong>" + esc(email) + "</strong><br>"
            + "• Mật khẩu: <strong style='font-family:Consolas,monospace;font-size:15px;color:#0f172a;background:#f1f5f9;padding:2px 10px;border-radius:4px;letter-spacing:1px;'>" + pwDisplay + "</strong>",
            btn,
            "⚠️ Hãy <strong>thay đổi mật khẩu ngay</strong> sau lần đăng nhập đầu tiên để bảo mật tài khoản của bạn.",
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
            "📋 Thông báo kết quả đăng ký - V-SPORT",
            RED,
            "Thông tin đăng ký cần được cập nhật",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Cảm ơn bạn đã quan tâm đến việc hợp tác cùng V-SPORT. Sau khi xem xét hồ sơ đăng ký cơ sở <strong>\"" + esc(coSoName) + "\"</strong>, ban quản trị rất tiếc chưa thể chấp thuận đơn đăng ký ở thời điểm này.<br><br>"
            + "Bạn có thể kiểm tra lại thông tin hồ sơ và thực hiện gửi lại đơn đăng ký mới trên hệ thống.",
            null,
            "Nếu bạn cần thêm thông tin hoặc giải đáp chi tiết, xin vui lòng phản hồi hoặc liên hệ qua bộ phận CSKH của V-SPORT.",
            null,
            "info"
        );
    }

    // ── Chào mừng tài khoản mới (customer) ───────────────────────────────────

    public static String chaoMungDangKy(String fullName) {
        return build(
            "🏆 Chào mừng đến với V-SPORT!",
            BLUE,
            "Tài khoản của bạn đã kích hoạt!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Chúc mừng bạn đã gia nhập cộng đồng thể thao V-SPORT! Tài khoản của bạn hiện đã sẵn sàng để trải nghiệm dịch vụ đặt sân trực tuyến nhanh chóng, tiện lợi.",
            featureList(),
            "Hãy sẵn sàng ra sân và tận hưởng những giờ phút luyện tập thể thao sôi động nhất! ⚽🏸🏀",
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
            "✅ Xác nhận đặt sân thành công - V-SPORT",
            GREEN,
            "Xác nhận đặt sân thành công!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Yêu cầu đặt sân thể thao của bạn đã được ghi nhận và xác nhận thành công trên hệ thống V-SPORT:",
            infoBox,
            "📌 Vui lòng có mặt đúng giờ trước 10-15 phút. Khi tới sân, bạn chỉ cần đọc tên hoặc giơ thông tin email này cho nhân viên.",
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
            "❌ Thông báo hủy lịch đặt sân - V-SPORT",
            RED,
            "Lịch đặt sân đã được hủy thành công",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Hệ thống xác nhận lịch đặt sân dưới đây của bạn đã được hủy thành công:",
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
            "💳 Xác nhận thanh toán thành công - V-SPORT",
            GREEN,
            "Thanh toán giao dịch hoàn tất!",
            "Xin chào <strong>" + esc(fullName) + "</strong>,<br><br>"
            + "Chúng tôi đã nhận được khoản thanh toán trực tuyến qua cổng PayOS cho dịch vụ của bạn. Dưới đây là chi tiết biên nhận:",
            infoBox,
            "Cảm ơn bạn đã tin dùng V-SPORT. Hẹn gặp lại bạn trên sân tập! 🏃✨",
            null,
            "success"
        );
    }

    // ── Helpers & Formatting ──────────────────────────────────────────────────

    /**
     * Renders 6 distinct boxes for each digit of the OTP code for high-end visual appearance.
     */
    private static String otpBox(String otp) {
        if (otp == null) otp = "------";
        String cleanOtp = otp.trim();
        
        StringBuilder boxesHtml = new StringBuilder();
        boxesHtml.append("<table cellpadding='0' cellspacing='0' border='0' align='center' style='margin:28px auto;'><tr>");
        
        for (int i = 0; i < cleanOtp.length(); i++) {
            char digit = cleanOtp.charAt(i);
            boxesHtml.append("<td style='padding:0 5px;'>")
                     .append("<div style='width:42px;height:52px;line-height:50px;background:#f8fafc;border:2px solid #3b82f6;border-radius:10px;font-family:Consolas,\"Courier New\",Courier,monospace;font-size:26px;font-weight:800;color:#1d4ed8;text-align:center;box-shadow:0 3px 8px rgba(37,99,235,0.12);'>")
                     .append(digit)
                     .append("</div></td>");
        }
        
        boxesHtml.append("</tr></table>");
        return boxesHtml.toString();
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
        String noteBg, noteColor, noteBorder, noteIcon;
        switch (noteType != null ? noteType : "info") {
            case "success":
                noteBg = "#f0fdf4"; noteColor = "#15803d"; noteBorder = "#bbf7d0"; noteIcon = "✅"; break;
            case "warning":
                noteBg = "#fffbeb"; noteColor = "#b45309"; noteBorder = "#fde68a"; noteIcon = "⚠️"; break;
            case "danger":
                noteBg = "#fef2f2"; noteColor = "#b91c1c"; noteBorder = "#fecaca"; noteIcon = "🚨"; break;
            default:
                noteBg = "#eff6ff"; noteColor = "#1d4ed8"; noteBorder = "#bfdbfe"; noteIcon = "💡";
        }

        return "<!DOCTYPE html><html lang='vi'><head>"
            + "<meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1.0'>"
            + "<title>" + esc(browserTitle) + "</title></head>"
            + "<body style='margin:0;padding:0;background-color:#f1f5f9;font-family:system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",Roboto,Helvetica,Arial,sans-serif;-webkit-font-smoothing:antialiased;'>"
            + "<table width='100%' cellpadding='0' cellspacing='0' style='background-color:#f1f5f9;padding:40px 12px;'>"
            + "<tr><td align='center'>"

            // Outer Card Container
            + "<table width='600' cellpadding='0' cellspacing='0' style='max-width:600px;width:100%;background:#ffffff;"
            + "border-radius:20px;overflow:hidden;box-shadow:0 10px 30px rgba(0,0,0,0.06);border:1px solid #e2e8f0;'>"

            // Header section with dark gradient backdrop
            + "<tr><td style='background:#0f172a;background:linear-gradient(135deg,#0f172a 0%,#1e3a8a 50%,#2563eb 100%);padding:36px 40px;text-align:center;'>"
            + "<div style='display:inline-block;padding:6px 18px;background:rgba(255,255,255,0.12);border:1px solid rgba(255,255,255,0.22);border-radius:999px;color:#ffffff;font-size:12px;font-weight:800;letter-spacing:3px;margin-bottom:8px;box-shadow:0 2px 8px rgba(0,0,0,0.15);'>"
            + "⚡ V-SPORT"
            + "</div>"
            + "<div style='font-size:11px;color:rgba(255,255,255,0.75);letter-spacing:1.5px;font-weight:600;text-transform:uppercase;margin-top:2px;'>"
            + "Hệ Thống Đặt Sân Thể Thao Thông Minh"
            + "</div>"
            + "</td></tr>"

            // Multi-color accent border
            + "<tr><td style='height:4px;background:#2563eb;background:linear-gradient(90deg,#2563eb 0%,#06b6d4 50%,#f97316 100%);'></td></tr>"

            // Card Body Content
            + "<tr><td style='padding:40px 36px;'>"
            + "<h2 style='margin:0 0 16px 0;font-size:22px;font-weight:800;color:#0f172a;letter-spacing:-0.4px;line-height:1.3;'>" + headline + "</h2>"
            + "<p style='margin:0 0 20px 0;font-size:15px;color:#475569;line-height:1.7;'>" + intro + "</p>"
            + (mainContent != null ? mainContent : "")
            + (note != null
                ? "<table width='100%' cellpadding='0' cellspacing='0' style='background:" + noteBg + ";border:1px solid " + noteBorder + ";border-left:4px solid " + noteColor + ";border-radius:10px;margin-top:24px;'>"
                  + "<tr><td style='padding:14px 16px;font-size:13.5px;color:" + noteColor + ";line-height:1.65;'>"
                  + "<span style='margin-right:6px;'>" + noteIcon + "</span>" + note
                  + "</td></tr></table>"
                : "")
            + "</td></tr>"

            // Modern Footer section
            + "<tr><td style='background:#f8fafc;padding:28px 36px;text-align:center;border-top:1px solid #f1f5f9;'>"
            + "<div style='font-size:13px;font-weight:800;color:#1e3a8a;letter-spacing:1.5px;margin-bottom:6px;'>V-SPORT PLATFORM</div>"
            + "<div style='font-size:12px;color:#94a3b8;line-height:1.6;max-width:440px;margin:0 auto;'>"
            + "Email này được gửi tự động từ hệ thống V-SPORT. Vui lòng không phản hồi trực tiếp email này.<br>"
            + "Nếu bạn cần trợ giúp, xin vui lòng truy cập trung tâm hỗ trợ của chúng tôi."
            + (footer != null ? "<br><span style='color:#64748b;font-weight:500;'>" + footer + "</span>" : "")
            + "</div>"
            + "<div style='margin-top:16px;padding-top:14px;border-top:1px solid #e2e8f0;font-size:11px;color:#cbd5e1;'>"
            + "© " + java.time.Year.now().getValue() + " V-SPORT. Tất cả quyền được bảo lưu."
            + "</div>"
            + "</td></tr>"

            + "</table></td></tr></table></body></html>";
    }
}
