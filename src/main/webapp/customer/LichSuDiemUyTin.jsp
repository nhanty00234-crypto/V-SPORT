<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điểm Uy Tín - V-SPORT</title>
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
        .acc-user-profile { display: flex; align-items: center; gap: 20px; }
        .acc-avatar-circle {
            width: 76px; height: 76px; border-radius: 50%;
            background: var(--primary); color: var(--navy);
            display: flex; align-items: center; justify-content: center;
            font-size: 32px; font-weight: 800; font-family: 'Outfit', sans-serif;
            box-shadow: 0 0 0 4px rgba(1, 226, 129, 0.25); flex-shrink: 0;
        }
        .acc-user-info { display: flex; flex-direction: column; gap: 6px; }
        .acc-user-name {
            font-size: 24px; font-weight: 800; color: #fff;
            font-family: 'Outfit', sans-serif; margin: 0;
            display: flex; align-items: center; gap: 12px;
        }
        .acc-user-meta {
            font-size: 13.5px; color: rgba(255,255,255,0.75);
            display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
        }
        .acc-user-meta i { color: var(--primary); }
        .acc-rep-chip {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 4px 12px; border-radius: 999px;
            background: rgba(1,226,129,0.15); color: var(--primary);
            font-size: 12px; font-weight: 700; border: 1px solid rgba(1,226,129,0.3);
        }
        .acc-hero-actions { display: flex; align-items: center; gap: 12px; flex-wrap: wrap; }
        .acc-hero-btn {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 10px 20px; border-radius: 12px; font-size: 13.5px;
            font-weight: 700; text-decoration: none; transition: all 0.2s ease; border: none; cursor: pointer;
        }
        .acc-btn-primary { background: var(--primary); color: var(--navy); box-shadow: 0 4px 12px rgba(1,226,129,0.25); }
        .acc-btn-primary:hover { background: var(--primary-hover); color: var(--navy); transform: translateY(-1px); }
        .acc-btn-glass { background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.15); }
        .acc-btn-glass:hover { background: rgba(255,255,255,0.2); color: #fff; }

        .acc-main-container {
            max-width: var(--container-width, 1320px);
            margin: 0 auto; padding: 0 20px;
            display: grid; grid-template-columns: 280px 1fr; gap: 28px;
        }
        .acc-sidebar { display: flex; flex-direction: column; gap: 16px; }
        .acc-nav-card {
            background: #fff; border: 1px solid var(--border);
            border-radius: 16px; padding: 10px; box-shadow: var(--shadow-small);
        }
        .acc-nav-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 16px; border-radius: 10px; font-size: 14px;
            font-weight: 600; color: var(--body-text); text-decoration: none;
            transition: all 0.2s ease; cursor: pointer; border: none;
            background: transparent; width: 100%; text-align: left; box-sizing: border-box;
        }
        .acc-nav-item i { font-size: 16px; width: 20px; text-align: center; color: var(--muted-text); transition: color 0.2s; }
        .acc-nav-item:hover { background: #f8fafc; color: var(--navy); }
        .acc-nav-item:hover i { color: var(--primary-hover); }
        .acc-nav-item.active { background: rgba(1,226,129,0.12); color: var(--navy); font-weight: 800; }
        .acc-nav-item.active i { color: #01c771; }
        .acc-nav-item.danger { color: #dc2626; }
        .acc-nav-item.danger:hover { background: #fff0f0; color: #b91c1c; }
        .acc-nav-item.danger i { color: #dc2626; }

        .acc-main-panel { min-width: 0; width: 100%; }
        .acc-content-card {
            background: #fff; border: 1px solid var(--border);
            border-radius: 20px; padding: 28px; box-shadow: var(--shadow-small);
            width: 100%; box-sizing: border-box; margin-bottom: 24px;
        }
        .acc-sec-title {
            font-size: 18px; font-weight: 800; color: var(--navy);
            font-family: 'Outfit', sans-serif; margin: 0 0 20px 0;
            display: flex; align-items: center; justify-content: space-between;
        }
        .breadcrumb {
            font-size: 13px; color: var(--muted-text); margin-bottom: 20px;
        }
        .breadcrumb a { color: var(--navy); }
        .breadcrumb a:hover { color: var(--primary); }

        /* Stats Grid */
        .rep-stats-grid {
            display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px;
        }
        .rep-stat-box {
            background: #f8fafc; border: 1px solid var(--border);
            border-radius: 14px; padding: 18px 16px;
            display: flex; align-items: flex-start; gap: 14px;
        }
        .rep-stat-icon {
            width: 44px; height: 44px; border-radius: 12px;
            background: rgba(1,226,129,0.12); color: var(--primary-hover);
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; flex-shrink: 0;
        }
        .rep-stat-num { font-size: 22px; font-weight: 800; color: var(--navy); font-family: 'Outfit', sans-serif; line-height: 1; margin-bottom: 4px; }
        .rep-stat-lbl { font-size: 12px; font-weight: 600; color: var(--muted-text); }

        /* Alert */
        .alert-box {
            padding: 16px 18px; background: #FBF3DB; border: 1px solid #f0dfa3;
            border-radius: 14px; color: #7a5a00; font-size: 14px;
            display: flex; gap: 12px; align-items: flex-start; margin-bottom: 20px;
        }
        .alert-box i { font-size: 18px; margin-top: 2px; color: #d99a1b; }

        /* Filter chips */
        .filter-row { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; margin-bottom: 20px; }
        .filter-chip {
            display: inline-flex; align-items: center; padding: 7px 16px;
            border-radius: 50px; font-size: 13px; font-weight: 600;
            color: var(--body-text); background: var(--background);
            border: 1px solid var(--border); white-space: nowrap; transition: var(--transition);
        }
        .filter-chip:hover { border-color: var(--primary); color: var(--navy); }
        .filter-chip.active { background: var(--navy); border-color: var(--navy); color: #fff; }

        /* Rep level badge */
        .rep-level-badge {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 14px; border-radius: 50px; font-size: 13px; font-weight: 700;
        }

        /* History list */
        .history-list { display: flex; flex-direction: column; gap: 10px; }
        .history-row {
            display: flex; justify-content: space-between; align-items: center;
            gap: 15px; padding: 16px 18px; background: #f8fafc;
            border: 1px solid var(--border); border-radius: 12px; flex-wrap: wrap;
        }
        .history-delta {
            display: inline-flex; align-items: center; gap: 4px;
            padding: 3px 10px; border-radius: 50px; font-size: 12px; font-weight: 800;
        }
        .history-delta.positive { background: #EDF3EC; color: #346538; }
        .history-delta.negative { background: #FDEBEC; color: #9F2F2D; }
        .history-delta.neutral { background: #e2e8f0; color: #475569; }
        .history-reason { font-size: 14px; font-weight: 600; color: var(--navy); margin-top: 4px; }
        .history-meta { font-size: 12.5px; color: var(--muted-text); margin-top: 4px; }
        .history-meta a { color: var(--primary-hover); font-weight: 600; }
        .history-score { font-size: 14px; font-weight: 700; color: var(--navy); white-space: nowrap; }
        .history-score .arrow { color: var(--muted-text); margin: 0 6px; }

        /* Calc list */
        .calc-list { list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 10px; }
        .calc-list li { display: flex; align-items: center; gap: 10px; font-size: 13.5px; color: var(--body-text); }
        .calc-list li b { color: var(--navy); }
        .calc-list i { width: 18px; text-align: center; }

        .empty-history {
            padding: 40px; text-align: center; background: var(--background);
            border-radius: 12px; border: 1px dashed var(--border);
        }

        @media (max-width: 1024px) {
            .acc-main-container { grid-template-columns: 1fr; }
            .rep-stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 640px) {
            .rep-stats-grid { grid-template-columns: 1fr; }
            .history-row { flex-direction: column; align-items: flex-start; }
            .history-score { align-self: flex-end; }
            .acc-user-profile { flex-direction: column; text-align: center; }
            .acc-user-name { justify-content: center; }
            .acc-user-meta { justify-content: center; }
            .acc-hero-inner { justify-content: center; text-align: center; }
        }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<div class="acc-page-wrapper">
    <jsp:include page="/customer/common/account-profile-banner.jsp" />

    <div class="acc-main-container">
        <c:set var="activePage" value="reputation" scope="request" />
        <jsp:include page="/customer/common/account-sidebar.jsp" />

        <main class="acc-main-panel">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a> /
                <a href="${pageContext.request.contextPath}/customer/tai-khoan">Tài khoản của tôi</a> /
                <span>Điểm uy tín</span>
            </div>

            <c:if test="${not canMatchmake}">
                <div class="alert-box">
                    <i class="fas fa-triangle-exclamation"></i>
                    <div>
                        <b>Tài khoản tạm thời bị hạn chế tính năng Ghép kèo.</b>
                        Điểm uy tín hiện tại là ${account.diemUyTin}/100, dưới ngưỡng tối thiểu 60 điểm. Hãy hoàn thành các ca đặt sân trực tiếp để tích lũy lại điểm.
                    </div>
                </div>
            </c:if>

            <!-- Stats -->
            <div class="rep-stats-grid">
                <div class="rep-stat-box">
                    <div class="rep-stat-icon"><i class="fas fa-star"></i></div>
                    <div>
                        <div class="rep-stat-num">${account.diemUyTin}/100</div>
                        <div class="rep-stat-lbl">Điểm hiện tại</div>
                    </div>
                </div>
                <div class="rep-stat-box">
                    <div class="rep-stat-icon" style="background:rgba(217,154,27,0.12);color:#956400;"><i class="fas fa-clock"></i></div>
                    <div>
                        <div class="rep-stat-num">${account.lateCancelCount}</div>
                        <div class="rep-stat-lbl">Số lần hủy gần giờ</div>
                    </div>
                </div>
                <div class="rep-stat-box">
                    <div class="rep-stat-icon" style="background:rgba(255,71,87,0.1);color:var(--danger);"><i class="fas fa-user-xmark"></i></div>
                    <div>
                        <div class="rep-stat-num">${account.noShowCount}</div>
                        <div class="rep-stat-lbl">Số lần không đến sân</div>
                    </div>
                </div>
            </div>

            <!-- History -->
            <div class="acc-content-card">
                <div class="acc-sec-title">
                    <span>Lịch sử thay đổi điểm</span>
                    <c:choose>
                        <c:when test="${account.diemUyTin >= 80}">
                            <span class="rep-level-badge" style="background:#EDF3EC;color:#346538;">${reputationLabel}</span>
                        </c:when>
                        <c:when test="${account.diemUyTin >= 60}">
                            <span class="rep-level-badge" style="background:#FBF3DB;color:#956400;">${reputationLabel}</span>
                        </c:when>
                        <c:when test="${account.diemUyTin >= 30}">
                            <span class="rep-level-badge" style="background:#FDECE3;color:#9a4a1a;">${reputationLabel}</span>
                        </c:when>
                        <c:otherwise>
                            <span class="rep-level-badge" style="background:#FDEBEC;color:#9F2F2D;">${reputationLabel}</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="filter-row">
                    <a href="?type=ALL" class="filter-chip ${actionFilter == 'ALL' ? 'active' : ''}">Tất cả</a>
                    <a href="?type=CANCEL_6_TO_24" class="filter-chip ${actionFilter == 'CANCEL_6_TO_24' ? 'active' : ''}">Hủy 6-24 giờ</a>
                    <a href="?type=LATE_CANCEL" class="filter-chip ${actionFilter == 'LATE_CANCEL' ? 'active' : ''}">Hủy dưới 6 giờ</a>
                    <a href="?type=NO_SHOW" class="filter-chip ${actionFilter == 'NO_SHOW' ? 'active' : ''}">Không đến</a>
                    <a href="?type=COMPLETED_BOOKING" class="filter-chip ${actionFilter == 'COMPLETED_BOOKING' ? 'active' : ''}">Hoàn thành</a>
                    <a href="?type=MANUAL_ADJUST" class="filter-chip ${actionFilter == 'MANUAL_ADJUST' ? 'active' : ''}">Điều chỉnh thủ công</a>
                </div>

                <div class="history-list">
                    <c:forEach var="item" items="${historyList}">
                        <div class="history-row">
                            <div>
                                <c:choose>
                                    <c:when test="${item.scoreDelta > 0}">
                                        <span class="history-delta positive"><i class="fas fa-plus"></i> ${item.scoreDelta} điểm</span>
                                    </c:when>
                                    <c:when test="${item.scoreDelta < 0}">
                                        <span class="history-delta negative"><i class="fas fa-minus"></i> ${item.scoreDelta * -1} điểm</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="history-delta neutral">0 điểm</span>
                                    </c:otherwise>
                                </c:choose>
                                <div class="history-reason">${fn:escapeXml(item.reason)}</div>
                                <div class="history-meta">
                                    <c:if test="${not empty item.datSanId}">
                                        <a href="${pageContext.request.contextPath}/customer/lich-su-dat-san#booking-${item.datSanId}">Mã đặt sân #${item.datSanId}</a>
                                        &middot;
                                    </c:if>
                                    ${fn:substring(item.createdAt, 8, 10)}/${fn:substring(item.createdAt, 5, 7)}/${fn:substring(item.createdAt, 0, 4)} ${fn:substring(item.createdAt, 11, 16)}
                                </div>
                            </div>
                            <div class="history-score">
                                ${item.scoreBefore}<span class="arrow">&rarr;</span>${item.scoreAfter}
                            </div>
                        </div>
                    </c:forEach>

                    <c:if test="${empty historyList}">
                        <div class="empty-history">
                            <i class="fas fa-clock-rotate-left" style="font-size:32px;color:var(--border);margin-bottom:10px;display:block;"></i>
                            <p style="color:var(--muted-text);font-weight:600;">Chưa có nhật ký biến động điểm uy tín nào.</p>
                        </div>
                    </c:if>
                </div>
            </div>

            <!-- How to calculate -->
            <div class="acc-content-card">
                <div class="acc-sec-title">Cách tính điểm uy tín</div>
                <ul class="calc-list">
                    <li><i class="fas fa-circle-check" style="color:#346538;"></i> Hủy sớm (từ 24 giờ trở lên trước giờ bắt đầu): <b>không bị trừ điểm</b>.</li>
                    <li><i class="fas fa-circle-minus" style="color:#956400;"></i> Hủy trong khoảng 6-24 giờ trước giờ bắt đầu: <b>-5 điểm</b>.</li>
                    <li><i class="fas fa-circle-minus" style="color:#9F2F2D;"></i> Hủy dưới 6 giờ trước giờ bắt đầu: <b>-10 điểm</b>.</li>
                    <li><i class="fas fa-circle-xmark" style="color:#9F2F2D;"></i> Không đến sân: <b>-20 điểm</b>.</li>
                    <li><i class="fas fa-circle-plus" style="color:#346538;"></i> Hoàn thành ca đặt sân: <b>+2 điểm</b>.</li>
                </ul>
            </div>
        </main>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
</body>
</html>
