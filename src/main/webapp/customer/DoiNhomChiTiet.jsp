<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>${team.teamName} - Đội nhóm - V-SPORT</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
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
            margin-bottom: 24px;
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
        .dn-edit-btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 18px;
            border-radius: 12px;
            background: var(--primary);
            color: var(--navy);
            font-size: 13.5px;
            font-weight: 800;
            text-decoration: none;
            box-shadow: 0 4px 12px rgba(1, 226, 129, 0.25);
            transition: all 0.2s ease;
        }
        .dn-edit-btn:hover {
            background: var(--primary-hover);
            color: var(--navy);
            transform: translateY(-1px);
        }

        /* Detail Banner & Info */
        .dc-cover {
            height: 180px;
            border-radius: 16px;
            background: linear-gradient(135deg, #1b5e42, #287A58);
            background-size: cover;
            background-position: center;
            position: relative;
            margin-bottom: 20px;
        }
        .dc-header { padding: 0 8px; position: relative; margin-top: -46px; margin-bottom: 24px; }
        .dc-avatar { width: 84px; height: 84px; border-radius: 50%; border: 4px solid #fff; object-fit: cover; background: rgba(1, 226, 129, 0.15); box-shadow: 0 4px 14px rgba(0,0,0,.15); }
        .dc-name { font-size: 22px; font-weight: 800; color: var(--navy); margin: 12px 0 6px; font-family: 'Outfit', sans-serif; }
        .dc-meta { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; font-size: 13.5px; color: var(--muted-text); }
        .dc-badge { display: inline-flex; align-items: center; gap: 4px; padding: 4px 12px; border-radius: 9999px; font-size: 12px; font-weight: 700; background: rgba(1, 226, 129, 0.15); color: var(--navy); border: 1px solid rgba(1, 226, 129, 0.3); }
        .dc-desc { font-size: 14px; color: var(--body-text); line-height: 1.6; margin: 14px 0 0; background: #f8fafc; padding: 14px 18px; border-radius: 12px; border: 1px solid var(--border); }

        .dc-actions { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--border); }
        .dc-btn {
            padding: 10px 18px; border-radius: 10px; font-size: 13.5px; font-weight: 700; cursor: pointer; border: 1px solid var(--border);
            background: #fff; color: var(--navy); text-decoration: none; display: inline-flex; align-items: center; gap: 8px; transition: all 0.15s ease;
        }
        .dc-btn:hover { border-color: var(--navy); background: #f8fafc; }
        .dc-btn.primary { background: var(--primary); border-color: var(--primary); color: var(--navy); font-weight: 800; box-shadow: 0 4px 12px rgba(1, 226, 129, 0.2); }
        .dc-btn.primary:hover { background: var(--primary-hover); transform: translateY(-1px); }
        .dc-btn.danger { color: #dc2626; border-color: #fecaca; background: #fff5f5; }
        .dc-btn.danger:hover { background: #fee2e2; border-color: #dc2626; }
        .dc-btn:disabled { opacity: .55; cursor: not-allowed; transform: none; }

        .dc-section { margin-bottom: 28px; }
        .dc-section h2 { font-size: 16px; font-weight: 800; color: var(--navy); margin: 0 0 14px; display: flex; align-items: center; justify-content: space-between; font-family: 'Outfit', sans-serif; }
        .dc-section h2 .count { font-weight: 600; color: var(--muted-text); font-size: 13px; }

        .dc-member-row { display: flex; align-items: center; gap: 12px; padding: 12px 16px; border: 1px solid var(--border); border-radius: 12px; background: #fff; transition: background-color 0.15s ease; }
        .dc-member-row + .dc-member-row { margin-top: 8px; }
        .dc-member-row:hover { background: #f8fafc; }
        .dc-member-row img { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; background: rgba(1, 226, 129, 0.15); flex-shrink: 0; }
        .dc-member-info { flex: 1; min-width: 0; }
        .dc-member-name { font-size: 14px; font-weight: 700; color: var(--navy); }
        .dc-member-role { font-size: 12px; color: var(--muted-text); }
        .dc-member-actions { display: flex; gap: 8px; flex-shrink: 0; }
        .dc-mini-btn { padding: 6px 12px; border-radius: 8px; border: 1px solid var(--border); background: #fff; font-size: 12px; font-weight: 700; cursor: pointer; transition: all 0.15s ease; }
        .dc-mini-btn:hover { border-color: var(--navy); background: #f8fafc; }
        .dc-mini-btn.danger { color: #dc2626; border-color: #fecaca; }
        .dc-mini-btn.danger:hover { border-color: #dc2626; background: #fee2e2; }

        .dc-request-card { display: flex; align-items: center; gap: 12px; padding: 12px 16px; border: 1px solid var(--border); border-radius: 12px; background: #fff; }
        .dc-request-card + .dc-request-card { margin-top: 8px; }
        .dc-request-card img { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; background: rgba(1, 226, 129, 0.15); flex-shrink: 0; }

        .dc-match-panel { background: #f8fafc; border: 1px solid var(--border); border-radius: 14px; padding: 20px; display: none; margin-bottom: 18px; }
        .dc-match-panel.is-open { display: block; }
        .dc-match-panel .dt-field { margin-bottom: 14px; }
        .dc-match-panel label { display: block; font-size: 13px; font-weight: 700; color: var(--navy); margin-bottom: 6px; }
        .dc-match-panel select, .dc-match-panel textarea, .dc-match-panel input {
            width: 100%; padding: 10px 14px; border-radius: 10px; border: 1px solid var(--border); font-size: 13.5px; font-family: inherit; box-sizing: border-box; background: #fff;
        }
        .dc-match-card { border: 1px solid var(--border); border-radius: 12px; padding: 16px; background: #fff; }
        .dc-match-card + .dc-match-card { margin-top: 10px; }
        .dc-match-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }
        .dc-match-title { font-size: 14.5px; font-weight: 700; color: var(--navy); }
        .dc-match-sub { font-size: 12.5px; color: var(--muted-text); margin-top: 4px; }
        .dc-status-pill { font-size: 11.5px; font-weight: 700; padding: 4px 10px; border-radius: 9999px; white-space: nowrap; }
        .dc-status-pill.open { background: rgba(1, 226, 129, 0.15); color: var(--navy); border: 1px solid rgba(1, 226, 129, 0.3); }
        .dc-status-pill.full { background: #ecfdf5; color: #059669; }
        .dc-status-pill.cancelled { background: #fef2f2; color: #dc2626; }
        .dc-challenge-row { display: flex; align-items: center; gap: 10px; padding: 10px 0; border-top: 1px solid var(--border); margin-top: 10px; }
        .dc-challenge-row img { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; background: rgba(1, 226, 129, 0.15); }
        .dc-challenge-row .name { flex: 1; font-size: 13px; font-weight: 600; color: var(--navy); }

        .dc-empty-inline { font-size: 13px; color: var(--muted-text); padding: 12px 0; }

        /* Dialog & Toast */
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

        .dc-confirm-backdrop { position: fixed; inset: 0; z-index: 1100; background: rgba(7, 29, 56, 0.5); opacity: 0; visibility: hidden; transition: opacity .18s ease; backdrop-filter: blur(2px); }
        .dc-confirm-backdrop.is-open { opacity: 1; visibility: visible; }
        .dc-confirm { position: fixed; left: 50%; top: 50%; transform: translate(-50%,-50%); z-index: 1200; width: min(400px, calc(100vw - 40px)); background: #fff; border-radius: 16px; padding: 24px; text-align: center; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
        .dc-confirm p { font-size: 14px; color: var(--muted-text); margin: 8px 0 20px; }
        .dc-confirm .row { display: flex; gap: 12px; }
        .dc-confirm .row button { flex: 1; padding: 11px; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; border: 1px solid var(--border); background: #fff; color: var(--navy); }
        .dc-confirm .row button.confirm { background: #dc2626; border-color: #dc2626; color: #fff; }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="fallbackAvatar" value="${ctx}/assets/images/vsport-fallback.svg" />

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
                        <div class="dn-header-icon"><i class="fas fa-shield-alt"></i></div>
                        <div>
                            <h2 class="dn-header-title"><c:out value="${team.teamName}"/></h2>
                            <p class="dn-header-desc">Chi tiết thông tin đội nhóm và thành viên.</p>
                        </div>
                    </div>
                    <div style="display:flex; gap:10px; flex-wrap:wrap;">
                        <a class="dn-back-btn" href="${ctx}/customer/doi-nhom">
                            <i class="fas fa-arrow-left"></i> Quay lại Nhóm của tôi
                        </a>
                        <c:if test="${team.captain}">
                            <a class="dn-edit-btn" href="${ctx}/customer/doi-nhom/chinh-sua?id=${team.teamId}">
                                <i class="fas fa-edit"></i> Chỉnh sửa đội
                            </a>
                        </c:if>
                    </div>
                </div>

                <!-- Team Detail Banner & Header -->
                <div class="dc-cover" style="<c:if test='${not empty team.coverImagePath}'>background-image:url('${team.coverImagePath}');</c:if>"></div>
                <div class="dc-header">
                    <img class="dc-avatar" src="${not empty team.avatarPath ? team.avatarPath : fallbackAvatar}" alt="" onerror="this.onerror=null;this.src='${fallbackAvatar}';"/>
                    <p class="dc-name"><c:out value="${team.teamName}"/></p>
                    <div class="dc-meta">
                        <span class="dc-badge"><i class="fas fa-running"></i> <c:out value="${team.sportName}"/></span>
                        <c:if test="${not empty team.locationText}"><span>&middot; <i class="fas fa-map-marker-alt"></i> <c:out value="${team.locationText}"/></span></c:if>
                        <span>&middot; <i class="fas fa-user-friends"></i> ${team.memberCount}/${team.maxMembers} thành viên</span>
                        <span>&middot; Đội trưởng: <strong><c:out value="${team.captainName}"/></strong></span>
                    </div>
                    <c:if test="${not empty team.description}"><p class="dc-desc"><c:out value="${team.description}"/></p></c:if>
                </div>

                <!-- Action Buttons -->
                <div class="dc-actions" id="dcActions">
                    <c:choose>
                        <c:when test="${team.captain}">
                            <button type="button" class="dc-btn" id="dcInviteBtn"><i class="fas fa-user-plus"></i> Mời thành viên</button>
                            <button type="button" class="dc-btn primary" id="dcOpenMatchPanel"><i class="fas fa-swords"></i> Tạo kèo đội</button>
                            <button type="button" class="dc-btn danger" id="dcDisbandBtn"><i class="fas fa-trash-alt"></i> Giải tán đội</button>
                        </c:when>
                        <c:when test="${team.coCaptain}">
                            <button type="button" class="dc-btn" id="dcInviteBtn"><i class="fas fa-user-plus"></i> Mời thành viên</button>
                            <button type="button" class="dc-btn primary" id="dcOpenMatchPanel"><i class="fas fa-swords"></i> Tạo kèo đội</button>
                            <button type="button" class="dc-btn danger" id="dcLeaveBtn"><i class="fas fa-sign-out-alt"></i> Rời đội</button>
                        </c:when>
                        <c:when test="${not empty team.myRole}">
                            <button type="button" class="dc-btn danger" id="dcLeaveBtn"><i class="fas fa-sign-out-alt"></i> Rời đội</button>
                        </c:when>
                        <c:otherwise>
                            <button type="button" class="dc-btn primary" id="dcJoinBtn" data-team-id="${team.teamId}">
                                <i class="fas fa-paper-plane"></i> ${team.memberCount >= team.maxMembers ? 'Đã đủ người' : 'Xin tham gia'}
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Members List Section -->
                <div class="dc-section">
                    <h2>
                        <span>Danh sách thành viên</span>
                        <span class="count">${team.memberCount}/${team.maxMembers}</span>
                    </h2>
                    <c:forEach var="m" items="${team.members}">
                        <div class="dc-member-row" data-account-id="${m.accountId}">
                            <img src="${not empty m.avatarUrl ? m.avatarUrl : fallbackAvatar}" alt="" onerror="this.onerror=null;this.src='${fallbackAvatar}';"/>
                            <div class="dc-member-info">
                                <div class="dc-member-name"><c:out value="${m.fullName}"/></div>
                                <div class="dc-member-role">
                                    <c:choose><c:when test="${m.memberRole == 'CAPTAIN'}">Đội trưởng</c:when><c:when test="${m.memberRole == 'CO_CAPTAIN'}">Đội phó</c:when><c:otherwise>Thành viên</c:otherwise></c:choose>
                                </div>
                            </div>
                            <c:if test="${(team.captain || team.coCaptain) && m.memberRole != 'CAPTAIN'}">
                                <div class="dc-member-actions">
                                    <c:if test="${team.captain}">
                                        <button type="button" class="dc-mini-btn" data-transfer-captain="${m.accountId}">Chuyển đội trưởng</button>
                                    </c:if>
                                    <button type="button" class="dc-mini-btn danger" data-remove-member="${m.accountId}">Xóa</button>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>

                <!-- Join Requests Section -->
                <c:if test="${team.captain || team.coCaptain}">
                    <div class="dc-section">
                        <h2>
                            <span>Yêu cầu tham gia đang chờ</span>
                            <span class="count">${fn:length(joinRequests)}</span>
                        </h2>
                        <c:choose>
                            <c:when test="${empty joinRequests}"><p class="dc-empty-inline">Không có yêu cầu nào đang chờ.</p></c:when>
                            <c:otherwise>
                                <c:forEach var="jr" items="${joinRequests}">
                                    <div class="dc-request-card">
                                        <img src="${not empty jr.requesterAvatarUrl ? jr.requesterAvatarUrl : fallbackAvatar}" alt="" onerror="this.onerror=null;this.src='${fallbackAvatar}';"/>
                                        <div class="dc-member-info">
                                            <div class="dc-member-name"><c:out value="${jr.requesterName}"/></div>
                                            <c:if test="${not empty jr.message}"><div class="dc-member-role"><c:out value="${jr.message}"/></div></c:if>
                                        </div>
                                        <div class="dc-member-actions">
                                            <button type="button" class="dc-mini-btn" style="border-color:#059669;color:#059669;" data-approve-jr="${jr.joinRequestId}">Duyệt</button>
                                            <button type="button" class="dc-mini-btn danger" data-reject-jr="${jr.joinRequestId}">Từ chối</button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <!-- Match Panel Section -->
                <div class="dc-section" id="tao-keo">
                    <h2>Kèo đội</h2>

                    <c:if test="${team.captain || team.coCaptain}">
                        <div class="dc-match-panel" id="dcMatchPanel">
                            <div class="dt-field" style="margin-bottom: 14px;">
                                <label for="dcBookingSelect">Ca đặt sân của bạn</label>
                                <select id="dcBookingSelect"><option value="">Đang tải...</option></select>
                            </div>
                            <div class="dt-field" style="margin-bottom: 14px;">
                                <label for="dcTrinhDo">Trình độ mong muốn</label>
                                <select id="dcTrinhDo">
                                    <option value="">Không yêu cầu</option>
                                    <option value="Mới chơi">Mới chơi</option>
                                    <option value="Cơ bản">Cơ bản</option>
                                    <option value="Trung bình">Trung bình</option>
                                    <option value="Khá">Khá</option>
                                    <option value="Nâng cao">Nâng cao</option>
                                </select>
                            </div>
                            <div class="dt-field" style="margin-bottom: 14px;">
                                <label for="dcNote">Ghi chú</label>
                                <textarea id="dcNote" maxlength="240" rows="2" placeholder="Ghi chú cho đối thủ (tùy chọn)"></textarea>
                            </div>
                            <button type="button" class="dc-btn primary" id="dcSubmitMatch" style="width:100%;justify-content:center;">Tạo kèo</button>
                        </div>
                        <p id="dcMyMatchesEmpty" class="dc-empty-inline" style="display:none;">Đội bạn chưa tạo kèo nào.</p>
                        <div id="dcMyMatches"></div>
                    </c:if>

                    <h2 style="margin-top:22px;">Kèo đội đang mở (đội khác)</h2>
                    <p id="dcOpenMatchesEmpty" class="dc-empty-inline" style="display:none;">Hiện chưa có kèo đội nào đang mở.</p>
                    <div id="dcOpenMatches"></div>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- Invite member modal -->
<div class="dc-confirm-backdrop" id="dcInviteBackdrop"></div>
<div class="dc-confirm" id="dcInviteDialog" style="display:none;" role="dialog" aria-modal="true" aria-labelledby="dcInviteTitle">
    <p id="dcInviteTitle" style="font-weight:800;font-size:16px;margin:0 0 6px;color:var(--navy);font-family:'Outfit',sans-serif;">Mời thành viên</p>
    <div style="text-align:left; margin-top: 14px;">
        <label style="display:block;font-size:13px;font-weight:700;margin-bottom:6px;color:var(--navy);">Email người dùng</label>
        <input type="email" id="dcInviteUsername" class="dt-input" placeholder="nhap.email@example.com" style="width:100%;padding:10px 14px;border-radius:10px;border:1px solid var(--border);box-sizing:border-box;"/>
    </div>
    <div class="row" style="margin-top:20px;">
        <button type="button" id="dcInviteCancel">Hủy</button>
        <button type="button" id="dcInviteSend" class="confirm" style="background:var(--primary);border-color:var(--primary);color:var(--navy);font-weight:800;">Gửi lời mời</button>
    </div>
</div>

<!-- Generic confirm modal -->
<div class="dc-confirm-backdrop" id="dcConfirmBackdrop"></div>
<div class="dc-confirm" id="dcConfirmDialog" style="display:none;" role="dialog" aria-modal="true">
    <p id="dcConfirmTitle" style="font-weight:800;font-size:16px;margin:0;color:var(--navy);font-family:'Outfit',sans-serif;">Xác nhận</p>
    <p id="dcConfirmMsg">Bạn có chắc chắn?</p>
    <div class="row">
        <button type="button" id="dcConfirmCancel">Hủy</button>
        <button type="button" id="dcConfirmOk" class="confirm">Xác nhận</button>
    </div>
</div>

<div id="dcToast" class="dn-toast" role="status" aria-live="polite"></div>

<script>
(function () {
    'use strict';
    var CTX = "${ctx}";
    var FALLBACK_AVATAR = "${fallbackAvatar}";
    var TEAM_ID = ${team.teamId};
    var SPORT_ID = ${team.sportId};
    var IS_CAPTAIN = ${team.captain};
    var IS_CO_CAPTAIN = ${team.coCaptain};

    var toastTimer = null;
    function toast(msg, kind) {
        var el = document.getElementById('dcToast');
        el.className = 'dn-toast is-open' + (kind === 'danger' ? ' is-danger' : kind === 'success' ? ' is-success' : '');
        el.textContent = msg;
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { el.classList.remove('is-open'); }, 3200);
    }
    function esc(s) { return (s == null ? '' : String(s)).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); }
    function avatarSrc(p) { return p ? p : FALLBACK_AVATAR; }
    function post(url, params) {
        var form = new FormData();
        Object.keys(params).forEach(function (k) { form.append(k, params[k]); });
        return fetch(url, { method: 'POST', body: form, headers: { 'Accept': 'application/json' } }).then(function (r) { return r.json(); });
    }

    // ================= Generic confirm dialog =================
    var confirmBackdrop = document.getElementById('dcConfirmBackdrop');
    var confirmDialog = document.getElementById('dcConfirmDialog');
    var confirmAction = null;
    function openConfirm(title, msg, onConfirm) {
        document.getElementById('dcConfirmTitle').textContent = title;
        document.getElementById('dcConfirmMsg').textContent = msg;
        confirmAction = onConfirm;
        confirmBackdrop.classList.add('is-open'); confirmDialog.style.display = 'block';
    }
    function closeConfirm() { confirmBackdrop.classList.remove('is-open'); confirmDialog.style.display = 'none'; confirmAction = null; }
    document.getElementById('dcConfirmCancel').addEventListener('click', closeConfirm);
    confirmBackdrop.addEventListener('click', closeConfirm);
    document.getElementById('dcConfirmOk').addEventListener('click', function () { if (confirmAction) confirmAction(); closeConfirm(); });

    // ================= Join =================
    var joinBtn = document.getElementById('dcJoinBtn');
    if (joinBtn) {
        joinBtn.addEventListener('click', function () {
            if (joinBtn.disabled) return;
            joinBtn.disabled = true; joinBtn.textContent = 'Đang gửi...';
            post(CTX + '/customer/doi-nhom/xin-tham-gia', { teamId: TEAM_ID }).then(function (data) {
                toast(data.message, data.success ? 'success' : 'danger');
                if (data.success) joinBtn.textContent = 'Đã gửi yêu cầu'; else { joinBtn.disabled = false; joinBtn.textContent = 'Xin tham gia'; }
            }).catch(function () { toast('Không thể gửi yêu cầu.', 'danger'); joinBtn.disabled = false; joinBtn.textContent = 'Xin tham gia'; });
        });
    }

    // ================= Leave =================
    var leaveBtn = document.getElementById('dcLeaveBtn');
    if (leaveBtn) {
        leaveBtn.addEventListener('click', function () {
            openConfirm('Rời đội?', 'Bạn sẽ không còn là thành viên của đội này.', function () {
                post(CTX + '/customer/doi-nhom/roi-doi', { teamId: TEAM_ID }).then(function (data) {
                    toast(data.message, data.success ? 'success' : 'danger');
                    if (data.success) setTimeout(function () { window.location.href = CTX + '/customer/doi-nhom'; }, 500);
                });
            });
        });
    }

    // ================= Disband =================
    var disbandBtn = document.getElementById('dcDisbandBtn');
    if (disbandBtn) {
        disbandBtn.addEventListener('click', function () {
            openConfirm('Giải tán đội?', 'Hành động này không thể hoàn tác. Toàn bộ thành viên, lời mời và yêu cầu đang chờ sẽ bị đóng.', function () {
                post(CTX + '/customer/doi-nhom/giai-tan', { teamId: TEAM_ID }).then(function (data) {
                    toast(data.message, data.success ? 'success' : 'danger');
                    if (data.success) setTimeout(function () { window.location.href = CTX + '/customer/doi-nhom'; }, 500);
                });
            });
        });
    }

    // ================= Members: remove / transfer =================
    document.querySelectorAll('[data-remove-member]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var accountId = btn.getAttribute('data-remove-member');
            var row = btn.closest('.dc-member-row');
            var name = row.querySelector('.dc-member-name').textContent;
            openConfirm('Xóa thành viên?', 'Xóa "' + name + '" khỏi đội?', function () {
                post(CTX + '/customer/doi-nhom/xoa-thanh-vien', { teamId: TEAM_ID, accountId: accountId }).then(function (data) {
                    toast(data.message, data.success ? 'success' : 'danger');
                    if (data.success) row.remove();
                });
            });
        });
    });
    document.querySelectorAll('[data-transfer-captain]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var accountId = btn.getAttribute('data-transfer-captain');
            var row = btn.closest('.dc-member-row');
            var name = row.querySelector('.dc-member-name').textContent;
            openConfirm('Chuyển quyền đội trưởng?', 'Chuyển quyền đội trưởng cho "' + name + '"? Bạn sẽ trở thành thành viên thường.', function () {
                post(CTX + '/customer/doi-nhom/chuyen-quyen', { teamId: TEAM_ID, accountId: accountId }).then(function (data) {
                    toast(data.message, data.success ? 'success' : 'danger');
                    if (data.success) setTimeout(function () { window.location.reload(); }, 500);
                });
            });
        });
    });

    // ================= Join requests =================
    document.querySelectorAll('[data-approve-jr]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = btn.getAttribute('data-approve-jr');
            var card = btn.closest('.dc-request-card');
            card.querySelectorAll('button').forEach(function (b) { b.disabled = true; });
            post(CTX + '/customer/doi-nhom/duyet-tham-gia', { joinRequestId: id }).then(function (data) {
                toast(data.message, data.success ? 'success' : 'danger');
                if (data.success) setTimeout(function () { window.location.reload(); }, 500);
                else card.querySelectorAll('button').forEach(function (b) { b.disabled = false; });
            });
        });
    });
    document.querySelectorAll('[data-reject-jr]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = btn.getAttribute('data-reject-jr');
            var card = btn.closest('.dc-request-card');
            card.querySelectorAll('button').forEach(function (b) { b.disabled = true; });
            post(CTX + '/customer/doi-nhom/tu-choi-tham-gia', { joinRequestId: id }).then(function (data) {
                toast(data.message, data.success ? 'success' : 'danger');
                if (data.success) card.remove(); else card.querySelectorAll('button').forEach(function (b) { b.disabled = false; });
            });
        });
    });

    // ================= Invite member =================
    var inviteBtn = document.getElementById('dcInviteBtn');
    var inviteBackdrop = document.getElementById('dcInviteBackdrop');
    var inviteDialog = document.getElementById('dcInviteDialog');
    if (inviteBtn) {
        inviteBtn.addEventListener('click', function () {
            document.getElementById('dcInviteUsername').value = '';
            inviteBackdrop.classList.add('is-open'); inviteDialog.style.display = 'block';
        });
    }
    function closeInvite() { inviteBackdrop.classList.remove('is-open'); inviteDialog.style.display = 'none'; }
    document.getElementById('dcInviteCancel').addEventListener('click', closeInvite);
    inviteBackdrop.addEventListener('click', closeInvite);
    document.getElementById('dcInviteSend').addEventListener('click', function () {
        var username = document.getElementById('dcInviteUsername').value.trim();
        if (!username) { toast('Vui lòng nhập email.', 'danger'); return; }
        post(CTX + '/customer/doi-nhom/moi-thanh-vien', { teamId: TEAM_ID, email: username }).then(function (data) {
            toast(data.message, data.success ? 'success' : 'danger');
            if (data.success) closeInvite();
        });
    });

    // ================= Team match panel =================
    var matchPanel = document.getElementById('dcMatchPanel');
    var openMatchPanelBtn = document.getElementById('dcOpenMatchPanel');
    var bookingsLoaded = false;
    function loadBookings() {
        if (bookingsLoaded) return;
        bookingsLoaded = true;
        fetch(CTX + '/customer/api/team-matches/eligible-bookings', { headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                var sel = document.getElementById('dcBookingSelect');
                var bookings = (data && data.bookings) || [];
                if (!bookings.length) { sel.innerHTML = '<option value="">Bạn chưa có ca đặt sân phù hợp</option>'; return; }
                sel.innerHTML = bookings.map(function (b) {
                    return '<option value="' + b.datSanId + '" data-sport="' + (b.monTheThaoId || '') + '">' +
                        esc(b.tenCoSo) + ' - ' + esc(b.tenSan) + ' (' + b.ngayDat + ' ' + b.gioBatDau + '-' + b.gioKetThuc + ')</option>';
                }).join('');
            })
            .catch(function () { document.getElementById('dcBookingSelect').innerHTML = '<option value="">Không thể tải danh sách</option>'; });
    }
    if (openMatchPanelBtn) {
        openMatchPanelBtn.addEventListener('click', function () {
            matchPanel.classList.toggle('is-open');
            if (matchPanel.classList.contains('is-open')) loadBookings();
        });
    }
    if (window.location.hash === '#tao-keo' && matchPanel) { matchPanel.classList.add('is-open'); loadBookings(); }

    var submitMatchBtn = document.getElementById('dcSubmitMatch');
    if (submitMatchBtn) {
        submitMatchBtn.addEventListener('click', function () {
            var datSanId = document.getElementById('dcBookingSelect').value;
            if (!datSanId) { toast('Vui lòng chọn một ca đặt sân.', 'danger'); return; }
            submitMatchBtn.disabled = true; submitMatchBtn.textContent = 'Đang tạo...';
            post(CTX + '/customer/doi-nhom/tao-keo', {
                teamId: TEAM_ID, datSanId: datSanId, monTheThaoId: SPORT_ID,
                trinhDo: document.getElementById('dcTrinhDo').value, note: document.getElementById('dcNote').value
            }).then(function (data) {
                toast(data.message, data.success ? 'success' : 'danger');
                submitMatchBtn.disabled = false; submitMatchBtn.textContent = 'Tạo kèo';
                if (data.success) { matchPanel.classList.remove('is-open'); loadMyMatches(); }
            }).catch(function () { toast('Không thể tạo kèo.', 'danger'); submitMatchBtn.disabled = false; submitMatchBtn.textContent = 'Tạo kèo'; });
        });
    }

    function statusClass(s) {
        if (s === 'Đang mở') return 'open';
        if (s === 'Đã đủ người') return 'full';
        return 'cancelled';
    }

    function renderMatchCard(m, isMine) {
        var div = document.createElement('div');
        div.className = 'dc-match-card';
        var opponent = m.opponentTeamName ? ('Đối thủ: ' + esc(m.opponentTeamName)) : (m.pendingChallengeCount > 0 ? m.pendingChallengeCount + ' thách đấu đang chờ' : 'Chưa có đội thách đấu');
        div.innerHTML =
            '<div class="dc-match-top">' +
                '<div><div class="dc-match-title">' + esc(m.tenCoSo) + ' - ' + esc(m.tenSan) + '</div>' +
                '<div class="dc-match-sub">' + esc(m.ngayDat) + ' &middot; ' + esc(m.gioBatDau) + '-' + esc(m.gioKetThuc) + (m.tenMon ? ' &middot; ' + esc(m.tenMon) : '') + '</div>' +
                (!isMine ? '<div class="dc-match-sub">Đội: ' + esc(m.teamNameNguoiTao) + '</div>' : '') + '</div>' +
                '<span class="dc-status-pill ' + statusClass(m.trangThai) + '">' + esc(m.trangThai) + '</span>' +
            '</div>' +
            '<div class="dc-match-sub" style="margin-top:6px;">' + opponent + '</div>';

        if (isMine && (IS_CAPTAIN || IS_CO_CAPTAIN) && m.pendingChallengeCount > 0 && m.trangThai === 'Đang mở') {
            var challengesWrap = document.createElement('div');
            challengesWrap.className = 'dc-challenges';
            div.appendChild(challengesWrap);
            fetch(CTX + '/customer/api/team-matches/challenges?keoId=' + m.keoId, { headers: { 'Accept': 'application/json' } })
                .then(function (r) { return r.json(); })
                .then(function (challenges) {
                    (challenges || []).forEach(function (c) {
                        var row = document.createElement('div');
                        row.className = 'dc-challenge-row';
                        row.innerHTML = '<img src="' + esc(avatarSrc(c.challengerTeamAvatarPath)) + '" alt="" onerror="this.onerror=null;this.src=\'' + FALLBACK_AVATAR + '\';"/>' +
                            '<span class="name">' + esc(c.challengerTeamName) + '</span>' +
                            '<button type="button" class="dc-mini-btn" style="border-color:#059669;color:#059669;" data-accept-ch="' + c.chiTietKeoId + '" data-keo="' + m.keoId + '">Chấp nhận</button>' +
                            '<button type="button" class="dc-mini-btn danger" data-reject-ch="' + c.chiTietKeoId + '" data-keo="' + m.keoId + '">Từ chối</button>';
                        challengesWrap.appendChild(row);
                    });
                    challengesWrap.querySelectorAll('[data-accept-ch]').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            post(CTX + '/customer/doi-nhom/chap-nhan-thach-dau', { chiTietKeoId: btn.getAttribute('data-accept-ch'), keoId: btn.getAttribute('data-keo') })
                                .then(function (data) { toast(data.message, data.success ? 'success' : 'danger'); if (data.success) { loadMyMatches(); } });
                        });
                    });
                    challengesWrap.querySelectorAll('[data-reject-ch]').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            post(CTX + '/customer/doi-nhom/tu-choi-thach-dau', { chiTietKeoId: btn.getAttribute('data-reject-ch'), keoId: btn.getAttribute('data-keo') })
                                .then(function (data) { toast(data.message, data.success ? 'success' : 'danger'); if (data.success) { btn.closest('.dc-challenge-row').remove(); } });
                        });
                    });
                });
        }
        return div;
    }

    function loadMyMatches() {
        var wrap = document.getElementById('dcMyMatches');
        var empty = document.getElementById('dcMyMatchesEmpty');
        if (!wrap) return;
        fetch(CTX + '/customer/api/team-matches/mine?teamId=' + TEAM_ID, { headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (list) {
                wrap.innerHTML = '';
                if (!list || !list.length) { empty.style.display = 'block'; return; }
                empty.style.display = 'none';
                list.forEach(function (m) { wrap.appendChild(renderMatchCard(m, true)); });
            });
    }

    function loadOpenMatches() {
        var wrap = document.getElementById('dcOpenMatches');
        var empty = document.getElementById('dcOpenMatchesEmpty');
        fetch(CTX + '/customer/api/team-matches?sportId=' + SPORT_ID + '&excludeTeamId=' + TEAM_ID, { headers: { 'Accept': 'application/json' } })
            .then(function (r) { return r.json(); })
            .then(function (list) {
                wrap.innerHTML = '';
                if (!list || !list.length) { empty.style.display = 'block'; return; }
                empty.style.display = 'none';
                list.forEach(function (m) {
                    var card = renderMatchCard(m, false);
                    if (IS_CAPTAIN || IS_CO_CAPTAIN) {
                        var btn = document.createElement('button');
                        btn.type = 'button'; btn.className = 'dc-btn primary'; btn.style.marginTop = '8px'; btn.style.width = '100%'; btn.style.justifyContent = 'center';
                        btn.textContent = 'Thách đấu';
                        btn.addEventListener('click', function () {
                            btn.disabled = true; btn.textContent = 'Đang gửi...';
                            post(CTX + '/customer/doi-nhom/thach-dau', { keoId: m.keoId, challengerTeamId: TEAM_ID }).then(function (data) {
                                toast(data.message, data.success ? 'success' : 'danger');
                                if (!data.success) { btn.disabled = false; btn.textContent = 'Thách đấu'; }
                            });
                        });
                        card.appendChild(btn);
                    }
                    wrap.appendChild(card);
                });
            });
    }

    loadMyMatches();
    loadOpenMatches();
})();
</script>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
