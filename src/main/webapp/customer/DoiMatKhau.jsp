<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi Mật Khẩu - V-SPORT</title>
    <jsp:include page="/common/xtra-head.jsp" />
    <style>
        .acc-page-wrapper {
            background-color: var(--background);
            padding-bottom: 60px;
            animation: accFadeIn 0.25s ease-out;
        }
        @keyframes accFadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Hero Banner Header */
        .acc-hero {
            background: linear-gradient(135deg, #1b5e42 0%, #287A58 55%, #3aaa72 100%);
            color: #fff;
            padding: 36px 0 32px 0;
            margin-bottom: 32px;
            box-shadow: inset 0 -1px 0 rgba(255,255,255,0.08);
        }
        .acc-hero-inner {
            max-width: var(--container-width, 1320px);
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 24px;
        }
        .acc-user-profile {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .acc-avatar-circle {
            width: 76px;
            height: 76px;
            border-radius: 50%;
            background: var(--primary);
            color: var(--navy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            font-weight: 800;
            font-family: 'Outfit', sans-serif;
            box-shadow: 0 0 0 4px rgba(1, 226, 129, 0.25);
            flex-shrink: 0;
        }
        .acc-user-info {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .acc-user-name {
            font-size: 24px;
            font-weight: 800;
            color: #ffffff;
            font-family: 'Outfit', sans-serif;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .acc-user-meta {
            font-size: 13.5px;
            color: rgba(255, 255, 255, 0.75);
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }
        .acc-user-meta i { color: var(--primary); }
        .acc-rep-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 999px;
            background: rgba(1, 226, 129, 0.15);
            color: var(--primary);
            font-size: 12px;
            font-weight: 700;
            border: 1px solid rgba(1, 226, 129, 0.3);
        }

        .acc-hero-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .acc-hero-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
            border: none;
            cursor: pointer;
        }
        .acc-btn-primary {
            background: var(--primary);
            color: var(--navy);
            box-shadow: 0 4px 12px rgba(1, 226, 129, 0.25);
        }
        .acc-btn-primary:hover {
            background: var(--primary-hover);
            color: var(--navy);
            transform: translateY(-1px);
        }
        .acc-btn-glass {
            background: rgba(255, 255, 255, 0.1);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }

        /* Container Grid */
        .acc-main-container {
            max-width: var(--container-width, 1320px);
            margin: 0 auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 28px;
        }

        /* Sidebar Navigation */
        .acc-sidebar {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .acc-nav-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 10px;
            box-shadow: var(--shadow-small);
        }
        .acc-nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 600;
            color: var(--body-text);
            text-decoration: none;
            transition: all 0.2s ease;
            cursor: pointer;
            border: none;
            background: transparent;
            width: 100%;
            text-align: left;
            box-sizing: border-box;
        }
        .acc-nav-item i {
            font-size: 16px;
            width: 20px;
            text-align: center;
            color: var(--muted-text);
            transition: color 0.2s;
        }
        .acc-nav-item:hover {
            background: #f8fafc;
            color: var(--navy);
        }
        .acc-nav-item.active {
            background: rgba(1, 226, 129, 0.12);
            color: var(--navy);
            font-weight: 800;
        }
        .acc-nav-item.active i {
            color: #01c771;
        }
        .acc-nav-item.danger { color: #dc2626; }

        /* Main Content Card */
        .acc-content-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-small);
            max-width: 680px;
        }

        /* Page Header */
        .cp-header-row {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        .cp-header-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            background: rgba(1, 226, 129, 0.15);
            color: var(--navy);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .cp-header-title {
            font-size: 22px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            margin: 0 0 4px 0;
        }
        .cp-header-desc {
            font-size: 13.5px;
            color: var(--muted-text);
            margin: 0;
        }

        /* Form Fields */
        .cp-field {
            margin-bottom: 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .cp-label {
            font-size: 13.5px;
            font-weight: 700;
            color: var(--navy);
        }
        .cp-label .required { color: #dc2626; }

        .cp-input-wrap {
            position: relative;
            display: flex;
            align-items: center;
        }
        .cp-input {
            width: 100%;
            height: 46px;
            padding: 0 46px 0 14px;
            border: 1px solid var(--border);
            border-radius: 12px;
            font-size: 14px;
            background: #f8fafc;
            color: var(--navy);
            outline: none;
            transition: all 0.2s ease;
            box-sizing: border-box;
        }
        .cp-input:focus {
            border-color: #01c771;
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(1, 226, 129, 0.18);
        }

        .cp-eye-btn {
            position: absolute;
            right: 8px;
            width: 36px;
            height: 36px;
            border: none;
            background: transparent;
            color: var(--muted-text);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            transition: color 0.2s;
        }
        .cp-eye-btn:hover { color: var(--navy); }

        /* Security Note Box */
        .cp-sec-note {
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 14px 16px;
            font-size: 13px;
            color: var(--muted-text);
            line-height: 1.5;
            margin-top: 24px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
        }
        .cp-sec-note i {
            color: #01c771;
            font-size: 18px;
            margin-top: 2px;
            flex-shrink: 0;
        }

        /* Action Bar */
        .cp-action-bar {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 28px;
            padding-top: 20px;
            border-top: 1px solid var(--border);
        }
        .cp-btn-cancel {
            padding: 11px 22px;
            border-radius: 12px;
            border: 1px solid var(--border);
            background: #ffffff;
            color: var(--navy);
            font-size: 13.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .cp-btn-cancel:hover { background: #f8fafc; border-color: var(--navy); }
        .cp-btn-save {
            padding: 11px 28px;
            border-radius: 12px;
            border: none;
            background: var(--primary);
            color: var(--navy);
            font-size: 13.5px;
            font-weight: 800;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(1, 226, 129, 0.25);
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .cp-btn-save:hover { background: var(--primary-hover); transform: translateY(-1px); }
        .cp-btn-save:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

        .cp-alert {
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 600;
            margin-bottom: 20px;
            display: none;
        }
        .cp-alert.success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; display: block; }
        .cp-alert.danger { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; display: block; }

        @media (max-width: 768px) {
            .acc-main-container { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="password" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />

        <main class="acc-main-panel">
            <div class="acc-content-card">
                <!-- Header -->
                <div class="cp-header-row">
                    <div class="cp-header-icon"><i class="fas fa-lock"></i></div>
                    <div>
                        <h2 class="cp-header-title">Đổi mật khẩu</h2>
                        <p class="cp-header-desc">Sử dụng mật khẩu mạnh và không dùng lại mật khẩu ở dịch vụ khác.</p>
                    </div>
                </div>

                <div id="cpAlert" class="cp-alert" role="alert"></div>

                <form id="changePasswordForm">
                    <div class="cp-field">
                        <label class="cp-label">Mật khẩu hiện tại <span class="required">*</span></label>
                        <div class="cp-input-wrap">
                            <input type="password" id="currentPassword" name="currentPassword" class="cp-input" required autocomplete="current-password" placeholder="Nhập mật khẩu hiện tại" />
                            <button type="button" class="cp-eye-btn" onclick="togglePass('currentPassword', this)" aria-label="Hiện/ẩn mật khẩu">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="cp-field">
                        <label class="cp-label">Mật khẩu mới <span class="required">*</span></label>
                        <div class="cp-input-wrap">
                            <input type="password" id="newPassword" name="newPassword" class="cp-input" required autocomplete="new-password" placeholder="Tối thiểu 8 ký tự (chữ hoa, chữ thường, số, ký tự đặc biệt)" />
                            <button type="button" class="cp-eye-btn" onclick="togglePass('newPassword', this)" aria-label="Hiện/ẩn mật khẩu">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="cp-field">
                        <label class="cp-label">Xác nhận mật khẩu mới <span class="required">*</span></label>
                        <div class="cp-input-wrap">
                            <input type="password" id="confirmPassword" name="confirmPassword" class="cp-input" required autocomplete="new-password" placeholder="Nhập lại mật khẩu mới" />
                            <button type="button" class="cp-eye-btn" onclick="togglePass('confirmPassword', this)" aria-label="Hiện/ẩn mật khẩu">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="cp-sec-note">
                        <i class="fas fa-shield-alt"></i>
                        <div>
                            <strong>Lưu ý bảo mật:</strong> Mật khẩu của bạn được mã hóa 1 chiều bằng mã hóa BCrypt an toàn. Sau khi đổi mật khẩu thành công, bạn có thể dùng mật khẩu mới cho các lần đăng nhập tiếp theo.
                        </div>
                    </div>

                    <div class="cp-action-bar">
                        <a href="${ctx}/customer/tai-khoan" class="cp-btn-cancel">Hủy</a>
                        <button type="submit" id="cpSaveBtn" class="cp-btn-save">
                            <i class="fas fa-check-circle"></i> Cập nhật mật khẩu
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />

<script>
function togglePass(inputId, btn) {
    var input = document.getElementById(inputId);
    var icon = btn.querySelector('i');
    if (input.type === 'password') {
        input.type = 'text';
        icon.className = 'fas fa-eye-slash';
    } else {
        input.type = 'password';
        icon.className = 'fas fa-eye';
    }
}

document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
    e.preventDefault();
    var btn = document.getElementById('cpSaveBtn');
    var alertEl = document.getElementById('cpAlert');
    
    var curPass = document.getElementById('currentPassword').value.trim();
    var newPass = document.getElementById('newPassword').value.trim();
    var confPass = document.getElementById('confirmPassword').value.trim();

    if (!curPass || !newPass || !confPass) {
        alertEl.className = 'cp-alert danger';
        alertEl.textContent = 'Vui lòng điền đầy đủ các trường thông tin!';
        return;
    }
    if (newPass !== confPass) {
        alertEl.className = 'cp-alert danger';
        alertEl.textContent = 'Xác nhận mật khẩu mới không trùng khớp!';
        return;
    }

    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang cập nhật...';
    alertEl.className = 'cp-alert';
    alertEl.style.display = 'none';

    var params = new URLSearchParams();
    params.append('action', 'changePassword');
    params.append('currentPassword', curPass);
    params.append('newPassword', newPass);
    params.append('confirmPassword', confPass);

    fetch('${ctx}/account/update-profile', {
        method: 'POST',
        body: params,
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' }
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-check-circle"></i> Cập nhật mật khẩu';
        if (data.success) {
            alertEl.className = 'cp-alert success';
            alertEl.textContent = data.message || 'Đổi mật khẩu thành công!';
            document.getElementById('changePasswordForm').reset();
        } else {
            alertEl.className = 'cp-alert danger';
            alertEl.textContent = data.message || 'Mật khẩu hiện tại không đúng hoặc không đủ độ mạnh.';
        }
    })
    .catch(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-check-circle"></i> Cập nhật mật khẩu';
        alertEl.className = 'cp-alert danger';
        alertEl.textContent = 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.';
    });
});
</script>
</body>
</html>
