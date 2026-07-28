<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cập Nhật Hồ Sơ - V-SPORT</title>
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
            background: linear-gradient(135deg, var(--navy-dark) 0%, var(--navy) 60%, #163e5c 100%);
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
        .acc-user-meta i {
            color: var(--primary);
        }
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
        .acc-nav-item.danger {
            color: #dc2626;
        }

        /* Main Content Card */
        .acc-content-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-small);
        }

        /* Page Header */
        .pf-header-row {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-bottom: 24px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        .pf-header-icon {
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
        .pf-header-title {
            font-size: 22px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            margin: 0 0 4px 0;
        }
        .pf-header-desc {
            font-size: 13.5px;
            color: var(--muted-text);
            margin: 0;
        }

        /* Form Styling */
        .pf-group-title {
            font-size: 15px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            margin: 24px 0 16px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .pf-group-title:first-of-type { margin-top: 0; }
        .pf-group-title i { color: #01c771; }

        .pf-form-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 18px;
            margin-bottom: 16px;
        }
        .pf-field-full { grid-column: 1 / -1; }

        .pf-field {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .pf-label {
            font-size: 13px;
            font-weight: 700;
            color: var(--navy);
        }
        .pf-label .required { color: #dc2626; margin-left: 2px; }

        .pf-input, .pf-select, .pf-textarea {
            width: 100%;
            height: 46px;
            padding: 0 14px;
            border: 1px solid var(--border);
            border-radius: 12px;
            font-size: 14px;
            background: #f8fafc;
            color: var(--navy);
            outline: none;
            transition: all 0.2s ease;
            box-sizing: border-box;
            font-family: inherit;
        }
        .pf-textarea {
            height: auto;
            padding: 12px 14px;
            resize: vertical;
        }
        .pf-input:focus, .pf-select:focus, .pf-textarea:focus {
            border-color: #01c771;
            background: #ffffff;
            box-shadow: 0 0 0 3px rgba(1, 226, 129, 0.18);
        }
        .pf-input:disabled {
            background: #e2e8f0;
            color: #64748b;
            cursor: not-allowed;
        }
        .pf-badge-verified {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 11px;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 999px;
            background: #dcfce7;
            color: #15803d;
            margin-left: 6px;
        }

        /* Action Bar */
        .pf-action-bar {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 12px;
            margin-top: 32px;
            padding-top: 20px;
            border-top: 1px solid var(--border);
        }
        .pf-btn-cancel {
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
        .pf-btn-cancel:hover { background: #f8fafc; border-color: var(--navy); }
        .pf-btn-save {
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
        .pf-btn-save:hover { background: var(--primary-hover); transform: translateY(-1px); }
        .pf-btn-save:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }

        .pf-alert {
            padding: 12px 16px;
            border-radius: 12px;
            font-size: 13.5px;
            font-weight: 600;
            margin-bottom: 20px;
            display: none;
        }
        .pf-alert.success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; display: block; }
        .pf-alert.danger { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; display: block; }

        @media (max-width: 768px) {
            .acc-main-container { grid-template-columns: 1fr; }
            .pf-form-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="profile" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />

        <main class="acc-main-panel">
            <div class="acc-content-card">
                <!-- Header -->
                <div class="pf-header-row">
                    <div class="pf-header-icon"><i class="fas fa-user-cog"></i></div>
                    <div>
                        <h2 class="pf-header-title">Cập nhật hồ sơ</h2>
                        <p class="pf-header-desc">Cập nhật thông tin cá nhân và sở thích thể thao của bạn.</p>
                    </div>
                </div>

                <div id="pfAlert" class="pf-alert" role="alert"></div>

                <form id="profileForm">
                    <!-- Group 1: Thông tin cá nhân -->
                    <div class="pf-group-title"><i class="fas fa-user"></i> Thông tin cá nhân</div>
                    <div class="pf-form-grid">
                        <div class="pf-field">
                            <label class="pf-label">Họ và tên <span class="required">*</span></label>
                            <input type="text" id="pfFullName" name="fullName" class="pf-input" required value="${fn:escapeXml(account.fullName)}" placeholder="Nhập họ và tên đầy đủ" />
                        </div>
                        <div class="pf-field">
                            <label class="pf-label">Email <span class="pf-badge-verified"><i class="fas fa-check-circle"></i> Đã xác minh</span></label>
                            <input type="email" class="pf-input" value="${fn:escapeXml(account.email)}" disabled title="Email không thể thay đổi trực tiếp" />
                        </div>
                        <div class="pf-field">
                            <label class="pf-label">Số điện thoại</label>
                            <input type="text" id="pfPhone" name="phone" class="pf-input" value="${fn:escapeXml(account.phoneNumber)}" placeholder="Nhập số điện thoại liên hệ" />
                    </div>

                    <!-- Group 2: Sở thích thể thao -->
                    <div class="pf-group-title"><i class="fas fa-running"></i> Sở thích thể thao</div>
                    <div class="pf-form-grid">
                        <div class="pf-field">
                            <label class="pf-label">Môn thể thao yêu thích</label>
                            <select id="pfSportId" class="pf-select">
                                <option value="">Chọn môn thể thao</option>
                                <c:forEach var="mon" items="${dsMon}">
                                    <option value="${mon.monTheThaoID}" ${profileExtra.favoriteSportId == mon.monTheThaoID ? 'selected' : ''}>${mon.tenMon}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="pf-field">
                            <label class="pf-label">Trình độ chơi</label>
                            <select id="pfLevel" class="pf-select">
                                <option value="">Chọn trình độ</option>
                                <option value="Mới chơi" ${profileExtra.levelSkill eq 'Mới chơi' ? 'selected' : ''}>Mới chơi</option>
                                <option value="Cơ bản" ${profileExtra.levelSkill eq 'Cơ bản' ? 'selected' : ''}>Cơ bản</option>
                                <option value="Trung bình" ${profileExtra.levelSkill eq 'Trung bình' ? 'selected' : ''}>Trung bình</option>
                                <option value="Khá" ${profileExtra.levelSkill eq 'Khá' ? 'selected' : ''}>Khá</option>
                                <option value="Nâng cao" ${profileExtra.levelSkill eq 'Nâng cao' ? 'selected' : ''}>Nâng cao</option>
                            </select>
                        </div>
                        <div class="pf-field">
                            <label class="pf-label">Tần suất chơi</label>
                            <select id="pfFrequency" class="pf-select">
                                <option value="">Chọn tần suất</option>
                                <option value="1 lần/tuần" ${profileExtra.frequency eq '1 lần/tuần' ? 'selected' : ''}>1 lần/tuần</option>
                                <option value="2-3 lần/tuần" ${profileExtra.frequency eq '2-3 lần/tuần' ? 'selected' : ''}>2-3 lần/tuần</option>
                                <option value="4+ lần/tuần" ${profileExtra.frequency eq '4+ lần/tuần' ? 'selected' : ''}>4+ lần/tuần</option>
                                <option value="Không cố định" ${profileExtra.frequency eq 'Không cố định' ? 'selected' : ''}>Không cố định</option>
                            </select>
                        </div>
                        <div class="pf-field">
                            <label class="pf-label">Khu vực hay chơi</label>
                            <input type="text" id="pfLocation" class="pf-input" value="${fn:escapeXml(profileExtra.favoriteLocation)}" placeholder="Ví dụ: Quận 1, Bình Thạnh..." />
                        </div>
                    </div>

                    <!-- Group 3: Thông tin bổ sung -->
                    <div class="pf-group-title"><i class="fas fa-heartbeat"></i> Thông tin bổ sung</div>
                    <div class="pf-form-grid">
                        <div class="pf-field">
                            <label class="pf-label">Chiều cao (cm)</label>
                            <input type="number" id="pfHeight" class="pf-input" min="50" max="260" value="${profileExtra.heightCm}" placeholder="175" />
                        </div>
                        <div class="pf-field">
                            <label class="pf-label">Cân nặng (kg)</label>
                            <input type="number" id="pfWeight" class="pf-input" min="20" max="300" value="${profileExtra.weightKg}" placeholder="68" />
                        </div>
                        <div class="pf-field pf-field-full">
                            <label class="pf-label">Giới thiệu ngắn</label>
                            <textarea id="pfNote" class="pf-textarea" rows="3" placeholder="Chia sẻ đôi chút về phong cách thi đấu hoặc kinh nghiệm thể thao của bạn...">${fn:escapeXml(profileExtra.personalNote)}</textarea>
                        </div>
                    </div>

                    <!-- Action Bar -->
                    <div class="pf-action-bar">
                        <a href="${ctx}/customer/tai-khoan" class="pf-btn-cancel">Hủy thay đổi</a>
                        <button type="submit" id="pfSaveBtn" class="pf-btn-save">
                            <i class="fas fa-save"></i> Lưu thay đổi
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />

<script>
document.getElementById('profileForm').addEventListener('submit', function(e) {
    e.preventDefault();
    var btn = document.getElementById('pfSaveBtn');
    var alertEl = document.getElementById('pfAlert');
    btn.disabled = true;
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';
    alertEl.className = 'pf-alert';
    alertEl.style.display = 'none';

    var p1 = new FormData();
    p1.append('fullName', document.getElementById('pfFullName').value);
    p1.append('phone', document.getElementById('pfPhone').value);

    var p2 = new URLSearchParams();
    var sportVal = document.getElementById('pfSportId').value;
    if (sportVal) p2.append('sportId', sportVal);
    var levelVal = document.getElementById('pfLevel').value;
    if (levelVal) p2.append('level', levelVal);
    var freqVal = document.getElementById('pfFrequency').value;
    if (freqVal) p2.append('frequency', freqVal);
    var locVal = document.getElementById('pfLocation').value;
    if (locVal) p2.append('location', locVal);

    var p3 = new URLSearchParams();
    var hVal = document.getElementById('pfHeight').value;
    if (hVal) p3.append('heightCm', hVal);
    var wVal = document.getElementById('pfWeight').value;
    if (wVal) p3.append('weightKg', wVal);

    var p4 = new URLSearchParams();
    var noteVal = document.getElementById('pfNote').value;
    if (noteVal) p4.append('noteText', noteVal);

    Promise.all([
        fetch('${ctx}/account/update-profile', { method: 'POST', body: p1 }),
        fetch('${ctx}/customer/ho-so/cap-nhat-ca-nhan-hoa', { method: 'POST', body: p2, headers: {'Content-Type': 'application/x-www-form-urlencoded'} }),
        fetch('${ctx}/customer/ho-so/cap-nhat-the-chat', { method: 'POST', body: p3, headers: {'Content-Type': 'application/x-www-form-urlencoded'} }),
        fetch('${ctx}/customer/ho-so/cap-nhat-ghi-chu', { method: 'POST', body: p4, headers: {'Content-Type': 'application/x-www-form-urlencoded'} })
    ]).then(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
        alertEl.className = 'pf-alert success';
        alertEl.textContent = 'Hồ sơ cá nhân đã được cập nhật thành công!';
        window.scrollTo({ top: 0, behavior: 'smooth' });
        setTimeout(function() { location.reload(); }, 1200);
    }).catch(function() {
        btn.disabled = false;
        btn.innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
        alertEl.className = 'pf-alert danger';
        alertEl.textContent = 'Không thể lưu thay đổi. Vui lòng kiểm tra lại thông tin.';
    });
});
</script>
</body>
</html>
