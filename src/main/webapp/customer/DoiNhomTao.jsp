<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${editMode}">Chỉnh Sửa Đội - V-SPORT</c:when><c:otherwise>Tạo Đội Mới - V-SPORT</c:otherwise></c:choose></title>
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
        .acc-btn-glass:hover {
            background: rgba(255, 255, 255, 0.2);
            color: #ffffff;
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
        @media (max-width: 768px) {
            .acc-main-container { grid-template-columns: 1fr; }
        }

        /* Main Content Card */
        .acc-content-card {
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 28px;
            box-shadow: var(--shadow-small);
        }

        /* Page Header inside Card */
        .dn-header-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 28px;
            padding-bottom: 20px;
            border-bottom: 1px solid var(--border);
        }
        .dn-header-title-wrap {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .dn-header-icon {
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
        .dn-header-title {
            font-size: 22px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Outfit', sans-serif;
            margin: 0 0 4px 0;
        }
        .dn-header-desc {
            font-size: 13.5px;
            color: var(--muted-text);
            margin: 0;
        }
        .dn-back-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            border-radius: 12px;
            background: #f8fafc;
            color: var(--navy);
            font-size: 13.5px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
            border: 1px solid var(--border);
        }
        .dn-back-btn:hover {
            background: #f1f5f9;
            border-color: #cbd5e1;
            transform: translateY(-1px);
        }

        /* Avatar Picker Section */
        .dt-avatar-section {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 20px;
            background: #f8fafc;
            border: 1px solid var(--border);
            border-radius: 16px;
            margin-bottom: 24px;
        }
        .dt-avatar-btn {
            position: relative;
            width: 84px;
            height: 84px;
            border-radius: 50%;
            border: 3px solid var(--primary);
            background: rgba(1, 226, 129, 0.12);
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: visible;
            padding: 0;
            flex-shrink: 0;
            box-shadow: 0 4px 12px rgba(1, 226, 129, 0.2);
            transition: transform 0.2s ease;
        }
        .dt-avatar-btn:hover {
            transform: scale(1.03);
        }
        .dt-avatar-btn img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
            display: none;
        }
        .dt-avatar-btn.has-image img { display: block; }
        .dt-avatar-btn.has-image svg.dt-avatar-placeholder { display: none; }
        .dt-avatar-placeholder { width: 34px; height: 34px; color: var(--navy); }
        .dt-avatar-cam {
            position: absolute;
            right: -2px;
            bottom: -2px;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: var(--navy);
            color: var(--primary);
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #ffffff;
            font-size: 12px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.15);
        }
        .dt-avatar-text-h {
            font-size: 15px;
            font-weight: 700;
            color: var(--navy);
            margin: 0 0 4px 0;
        }
        .dt-avatar-text-p {
            font-size: 13px;
            color: var(--muted-text);
            margin: 0;
        }

        /* Form Fields */
        .dt-form-grid {
            display: flex;
            flex-direction: column;
            gap: 22px;
        }
        .dt-field {
            display: flex;
            flex-direction: column;
        }
        .dt-label {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 14px;
            font-weight: 700;
            color: var(--navy);
            margin-bottom: 8px;
        }
        .dt-label .req { color: #dc2626; margin-left: 4px; }
        .dt-counter { font-size: 12px; font-weight: 600; color: var(--muted-text); }
        .dt-input, .dt-select, .dt-textarea {
            width: 100%;
            padding: 12px 16px;
            border-radius: 12px;
            border: 1px solid var(--border);
            font-size: 14px;
            color: var(--navy);
            background: #ffffff;
            font-family: inherit;
            transition: all 0.2s ease;
            box-sizing: border-box;
        }
        .dt-input:focus, .dt-select:focus, .dt-textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(1, 226, 129, 0.25);
            outline: none;
        }
        .dt-textarea { resize: vertical; min-height: 90px; line-height: 1.5; }
        .dt-help { font-size: 12.5px; color: var(--muted-text); margin-top: 6px; }
        .dt-error { font-size: 12.5px; color: #dc2626; margin-top: 6px; display: none; font-weight: 600; }
        .dt-error.is-visible { display: block; }
        .dt-field.has-error .dt-input, .dt-field.has-error .dt-select, .dt-field.has-error .dt-textarea {
            border-color: #dc2626;
            background-color: #fff5f5;
        }

        /* Cover Upload */
        .dt-cover-upload {
            border: 2px dashed var(--border);
            border-radius: 14px;
            background: #f8fafc;
            height: 140px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 8px;
            cursor: pointer;
            color: var(--muted-text);
            text-align: center;
            position: relative;
            overflow: hidden;
            transition: all 0.2s ease;
        }
        .dt-cover-upload:hover {
            border-color: var(--primary);
            background: rgba(1, 226, 129, 0.04);
        }
        .dt-cover-upload i.dt-cover-icon { font-size: 28px; color: var(--navy); opacity: 0.6; }
        .dt-cover-upload span { font-size: 13.5px; font-weight: 600; color: var(--navy); }
        .dt-cover-upload img { position: absolute; inset: 0; width: 100%; height: 100%; object-fit: cover; display: none; }
        .dt-cover-upload.has-image img { display: block; }
        .dt-cover-upload.has-image i.dt-cover-icon, .dt-cover-upload.has-image span.dt-cover-hint { display: none; }

        .dt-cover-actions { display: none; gap: 10px; margin-top: 10px; }
        .dt-cover-actions.is-visible { display: flex; }
        .dt-cover-actions button {
            flex: 1;
            padding: 9px 14px;
            border-radius: 10px;
            border: 1px solid var(--border);
            background: #ffffff;
            font-size: 13px;
            font-weight: 700;
            color: var(--navy);
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .dt-cover-actions button:hover {
            background: #f8fafc;
            border-color: var(--navy);
        }

        /* Form Actions */
        .dt-actions-row {
            display: flex;
            align-items: center;
            gap: 14px;
            margin-top: 28px;
            padding-top: 20px;
            border-top: 1px solid var(--border);
        }
        .dt-submit {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 12px 28px;
            border-radius: 12px;
            border: none;
            background: var(--primary);
            color: var(--navy);
            font-size: 15px;
            font-weight: 800;
            font-family: 'Outfit', sans-serif;
            cursor: pointer;
            box-shadow: 0 4px 14px rgba(1, 226, 129, 0.25);
            transition: all 0.2s ease;
        }
        .dt-submit:hover {
            background: var(--primary-hover);
            transform: translateY(-1px);
            box-shadow: 0 6px 18px rgba(1, 226, 129, 0.35);
        }
        .dt-submit:disabled { opacity: .65; cursor: not-allowed; transform: none; }
        .dt-cancel {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 12px 22px;
            border-radius: 12px;
            border: 1px solid var(--border);
            background: #ffffff;
            color: var(--navy);
            font-size: 14px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .dt-cancel:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
        }

        .dt-spinner {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            border: 2px solid rgba(7, 29, 56, 0.2);
            border-top-color: var(--navy);
            animation: dtspin .8s linear infinite;
            display: none;
        }
        .dt-submit.is-loading .dt-spinner { display: inline-block; }
        @keyframes dtspin { to { transform: rotate(360deg); } }

        /* Toast */
        .dn-toast {
            position: fixed; left: 50%; bottom: 30px;
            transform: translateX(-50%) translateY(12px); z-index: 1300;
            background: var(--navy); color: #fff; padding: 10px 20px; border-radius: 999px;
            font-size: 13.5px; font-weight: 700; opacity: 0; visibility: hidden;
            transition: opacity .2s ease, transform .2s ease; box-shadow: 0 8px 22px rgba(0,0,0,.2);
            max-width: 88vw; text-align: center;
        }
        .dn-toast.is-open { opacity: 1; visibility: visible; transform: translateX(-50%) translateY(0); }
        .dn-toast.is-danger { background: #dc2626; }
        .dn-toast.is-success { background: #059669; }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="teams" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />

        <main class="acc-main-panel">
            <div class="acc-content-card">
                <!-- Header Section -->
                <div class="dn-header-row">
                    <div class="dn-header-title-wrap">
                        <div class="dn-header-icon"><i class="fas fa-users-cog"></i></div>
                        <div>
                            <h2 class="dn-header-title">
                                <c:choose><c:when test="${editMode}">Chỉnh sửa đội nhóm</c:when><c:otherwise>Tạo đội nhóm mới</c:otherwise></c:choose>
                            </h2>
                            <p class="dn-header-desc">
                                <c:choose><c:when test="${editMode}">Cập nhật thông tin chi tiết và hình ảnh cho đội nhóm của bạn.</c:when><c:otherwise>Điền đầy đủ thông tin bên dưới để khởi tạo đội nhóm thể thao mới.</c:otherwise></c:choose>
                            </p>
                        </div>
                    </div>
                    <a class="dn-back-btn" href="${ctx}/customer/doi-nhom">
                        <i class="fas fa-arrow-left"></i> Quay lại Nhóm của tôi
                    </a>
                </div>

                <form id="dtForm" novalidate>
                    <c:if test="${editMode}"><input type="hidden" name="teamId" value="${team.teamId}"/></c:if>

                    <!-- Avatar Picker -->
                    <div class="dt-avatar-section">
                        <button type="button" class="dt-avatar-btn<c:if test="${editMode && not empty team.avatarPath}"> has-image</c:if>" id="dtAvatarBtn" aria-label="Chọn ảnh đại diện đội">
                            <svg class="dt-avatar-placeholder" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect width="18" height="18" x="3" y="3" rx="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/></svg>
                            <img id="dtAvatarPreview" src="<c:if test="${editMode}">${team.avatarPath}</c:if>" alt=""/>
                            <span class="dt-avatar-cam" aria-hidden="true">
                                <i class="fas fa-camera"></i>
                            </span>
                        </button>
                        <input type="file" id="dtAvatarFile" name="avatarFile" accept="image/jpeg,image/png,image/webp,image/gif" hidden/>
                        <div>
                            <h3 class="dt-avatar-text-h">Logo / Ảnh đại diện đội</h3>
                            <p class="dt-avatar-text-p">Nhấp vào icon để tải lên logo đội (Định dạng JPG, PNG, WEBP. Tối đa 5MB).</p>
                        </div>
                    </div>

                    <!-- Form Input Fields -->
                    <div class="dt-form-grid">
                        <div class="dt-field" id="fTeamName">
                            <label class="dt-label" for="dtTeamName">
                                <span>Tên đội <span class="req">*</span></span>
                                <span class="dt-counter" id="dtTeamNameCounter">0/50</span>
                            </label>
                            <input class="dt-input" type="text" id="dtTeamName" name="teamName" maxlength="50" placeholder="Nhập tên đội nhóm của bạn..." value="${editMode ? team.teamName : ''}" required/>
                            <p class="dt-error" id="eTeamName">Tên đội phải có từ 3 đến 50 ký tự.</p>
                        </div>

                        <div class="dt-field">
                            <label class="dt-label">Hình ảnh bìa trước</label>
                            <div class="dt-cover-upload<c:if test="${editMode && not empty team.coverImagePath}"> has-image</c:if>" id="dtCoverUpload">
                                <i class="fas fa-image dt-cover-icon"></i>
                                <span class="dt-cover-hint">Nhấn để chọn ảnh bìa từ thư viện</span>
                                <img id="dtCoverPreview" src="<c:if test="${editMode}">${team.coverImagePath}</c:if>" alt=""/>
                            </div>
                            <input type="file" id="dtCoverFile" name="coverFile" accept="image/jpeg,image/png,image/webp,image/gif" hidden/>
                            <div class="dt-cover-actions<c:if test="${editMode && not empty team.coverImagePath}"> is-visible</c:if>" id="dtCoverActions">
                                <button type="button" id="dtCoverChange"><i class="fas fa-sync-alt"></i> Thay ảnh</button>
                                <button type="button" id="dtCoverRemove"><i class="fas fa-trash-alt"></i> Xóa ảnh</button>
                            </div>
                        </div>

                        <div class="dt-field" id="fLocation">
                            <label class="dt-label" for="dtLocation">Khu vực hoạt động</label>
                            <input class="dt-input" type="text" id="dtLocation" name="locationText" maxlength="255" placeholder="Ví dụ: Quận 1, TP. Hồ Chí Minh hoặc tên sân thường thi đấu" value="${editMode ? team.locationText : ''}"/>
                        </div>

                        <div class="dt-field">
                            <label class="dt-label" for="dtDescription">
                                <span>Mô tả đội</span>
                                <span class="dt-counter" id="dtDescCounter">0/225</span>
                            </label>
                            <textarea class="dt-textarea" id="dtDescription" name="description" maxlength="225" placeholder="Giới thiệu ngắn gọn về tiêu chí hoạt động, trình độ đội..."><c:if test="${editMode}">${team.description}</c:if></textarea>
                        </div>

                        <div class="dt-field" id="fSport">
                            <label class="dt-label" for="dtSport">Loại thể thao <span class="req">*</span></label>
                            <select class="dt-select" id="dtSport" name="sportId" required>
                                <option value="" disabled ${editMode ? '' : 'selected'}>-- Chọn loại thể thao --</option>
                                <c:forEach var="mon" items="${dsMon}">
                                    <option value="${mon.monTheThaoID}" <c:if test="${editMode && team.sportId == mon.monTheThaoID}">selected</c:if>>${mon.tenMon}</option>
                                </c:forEach>
                            </select>
                            <p class="dt-error" id="eSport">Vui lòng chọn loại thể thao.</p>
                        </div>

                        <div class="dt-field" id="fMaxMembers">
                            <label class="dt-label" for="dtMaxMembers">Số thành viên tối đa <span class="req">*</span></label>
                            <input class="dt-input" type="number" id="dtMaxMembers" name="maxMembers" min="2" max="30" step="1"
                                   placeholder="Nhập số lượng thành viên (2 - 30)" value="${editMode ? team.maxMembers : ''}" required/>
                            <p class="dt-help"><i class="fas fa-info-circle"></i> Số lượng thành viên tối đa được phép từ 2 đến 30 người.</p>
                            <p class="dt-error" id="eMaxMembers">Số thành viên tối đa phải nằm trong khoảng từ 2 đến 30.</p>
                        </div>
                    </div>

                    <!-- Form Actions -->
                    <div class="dt-actions-row">
                        <button type="submit" class="dt-submit" id="dtSubmit">
                            <span class="dt-spinner" aria-hidden="true"></span>
                            <span id="dtSubmitLabel">
                                <c:choose><c:when test="${editMode}"><i class="fas fa-save"></i> Lưu thay đổi</c:when><c:otherwise><i class="fas fa-plus-circle"></i> Tạo đội ngay</c:otherwise></c:choose>
                            </span>
                        </button>
                        <a href="${ctx}/customer/doi-nhom" class="dt-cancel">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<div id="dtToast" class="dn-toast" role="status" aria-live="polite"></div>

<script>
(function () {
    'use strict';
    var CTX = "${ctx}";
    var EDIT_MODE = ${editMode ? 'true' : 'false'};
    var TEAM_ID = EDIT_MODE ? ${editMode ? team.teamId : 0} : null;

    var toastTimer = null;
    function toast(msg, kind) {
        var el = document.getElementById('dtToast');
        el.className = 'dn-toast is-open' + (kind === 'danger' ? ' is-danger' : kind === 'success' ? ' is-success' : '');
        el.textContent = msg;
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { el.classList.remove('is-open'); }, 3200);
    }

    // ================= Counters =================
    function bindCounter(inputId, counterId, max) {
        var el = document.getElementById(inputId);
        var counter = document.getElementById(counterId);
        if (!el || !counter) return;
        function update() { counter.textContent = el.value.length + '/' + max; }
        el.addEventListener('input', update);
        update();
    }
    bindCounter('dtTeamName', 'dtTeamNameCounter', 50);
    bindCounter('dtDescription', 'dtDescCounter', 225);

    // ================= Avatar =================
    var avatarBtn = document.getElementById('dtAvatarBtn');
    var avatarFile = document.getElementById('dtAvatarFile');
    var avatarPreview = document.getElementById('dtAvatarPreview');
    if (avatarBtn && avatarFile) {
        avatarBtn.addEventListener('click', function () { avatarFile.click(); });
        avatarFile.addEventListener('change', function () {
            var f = avatarFile.files[0];
            if (!f) return;
            if (f.size > 5 * 1024 * 1024) { toast('Ảnh đại diện tối đa 5MB.', 'danger'); avatarFile.value = ''; return; }
            avatarPreview.src = URL.createObjectURL(f);
            avatarBtn.classList.add('has-image');
        });
    }

    // ================= Cover =================
    var coverUpload = document.getElementById('dtCoverUpload');
    var coverFile = document.getElementById('dtCoverFile');
    var coverPreview = document.getElementById('dtCoverPreview');
    var coverActions = document.getElementById('dtCoverActions');
    function openCoverPicker() { if (coverFile) coverFile.click(); }
    if (coverUpload) coverUpload.addEventListener('click', openCoverPicker);
    var btnChange = document.getElementById('dtCoverChange');
    if (btnChange) {
        btnChange.addEventListener('click', function (e) { e.stopPropagation(); openCoverPicker(); });
    }
    var btnRemove = document.getElementById('dtCoverRemove');
    if (btnRemove) {
        btnRemove.addEventListener('click', function (e) {
            e.stopPropagation();
            if (coverFile) coverFile.value = '';
            if (coverPreview) coverPreview.src = '';
            if (coverUpload) coverUpload.classList.remove('has-image');
            if (coverActions) coverActions.classList.remove('is-visible');
        });
    }
    if (coverFile) {
        coverFile.addEventListener('change', function () {
            var f = coverFile.files[0];
            if (!f) return;
            if (f.size > 8 * 1024 * 1024) { toast('Ảnh bìa tối đa 8MB.', 'danger'); coverFile.value = ''; return; }
            if (coverPreview) coverPreview.src = URL.createObjectURL(f);
            if (coverUpload) coverUpload.classList.add('has-image');
            if (coverActions) coverActions.classList.add('is-visible');
        });
    }

    // ================= Validation =================
    function setError(fieldId, errorId, show) {
        var f = document.getElementById(fieldId);
        var e = document.getElementById(errorId);
        if (f) f.classList.toggle('has-error', show);
        if (e) e.classList.toggle('is-visible', show);
    }
    function validate() {
        var ok = true;
        var nameEl = document.getElementById('dtTeamName');
        var name = nameEl ? nameEl.value.trim() : '';
        if (name.length < 3 || name.length > 50) { setError('fTeamName', 'eTeamName', true); ok = false; } else setError('fTeamName', 'eTeamName', false);

        var sportEl = document.getElementById('dtSport');
        var sport = sportEl ? sportEl.value : '';
        if (!sport) { setError('fSport', 'eSport', true); ok = false; } else setError('fSport', 'eSport', false);

        var maxEl = document.getElementById('dtMaxMembers');
        var max = maxEl ? parseInt(maxEl.value, 10) : 0;
        if (!max || max < 2 || max > 30) { setError('fMaxMembers', 'eMaxMembers', true); ok = false; } else setError('fMaxMembers', 'eMaxMembers', false);

        return ok;
    }

    // ================= Submit =================
    var form = document.getElementById('dtForm');
    var submitBtn = document.getElementById('dtSubmit');
    var submitLabel = document.getElementById('dtSubmitLabel');
    var submitting = false;

    if (form) {
        form.addEventListener('submit', function (e) {
            e.preventDefault();
            if (submitting) return;
            if (!validate()) { toast('Vui lòng kiểm tra lại các trường bắt buộc.', 'danger'); return; }

            submitting = true;
            if (submitBtn) {
                submitBtn.disabled = true;
                submitBtn.classList.add('is-loading');
            }
            if (submitLabel) {
                submitLabel.innerHTML = '<i class="fas fa-spinner fa-spin"></i> ' + (EDIT_MODE ? 'Đang lưu...' : 'Đang tạo đội...');
            }

            var formData = new FormData(form);
            var url = CTX + (EDIT_MODE ? '/customer/doi-nhom/chinh-sua' : '/customer/doi-nhom/tao');

            fetch(url, { method: 'POST', body: formData, headers: { 'Accept': 'application/json' } })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    if (data.success) {
                        toast(data.message || 'Thành công.', 'success');
                        var targetId = data.teamId || TEAM_ID;
                        setTimeout(function () {
                            if (targetId) {
                                window.location.href = CTX + '/customer/doi-nhom/chi-tiet?id=' + targetId;
                            } else {
                                window.location.href = CTX + '/customer/doi-nhom';
                            }
                        }, 500);
                    } else {
                        toast(data.message || 'Có lỗi xảy ra.', 'danger');
                        submitting = false;
                        if (submitBtn) {
                            submitBtn.disabled = false;
                            submitBtn.classList.remove('is-loading');
                        }
                        if (submitLabel) {
                            submitLabel.innerHTML = EDIT_MODE ? '<i class="fas fa-save"></i> Lưu thay đổi' : '<i class="fas fa-plus-circle"></i> Tạo đội ngay';
                        }
                    }
                })
                .catch(function () {
                    toast('Không thể kết nối máy chủ. Vui lòng thử lại.', 'danger');
                    submitting = false;
                    if (submitBtn) {
                        submitBtn.disabled = false;
                        submitBtn.classList.remove('is-loading');
                    }
                    if (submitLabel) {
                        submitLabel.innerHTML = EDIT_MODE ? '<i class="fas fa-save"></i> Lưu thay đổi' : '<i class="fas fa-plus-circle"></i> Tạo đội ngay';
                    }
                });
        });
    }
})();
</script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
