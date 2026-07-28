<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="/common/xtra-head.jsp" />
<style>
.account-wrapper {
    padding: 60px 0;
    background-color: var(--background);
}
.account-container {
    display: flex;
    gap: 30px;
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}
.account-sidebar {
    width: 280px;
    flex-shrink: 0;
}
.account-main {
    flex: 1;
    min-width: 0;
}
.profile-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    padding: 25px;
    text-align: center;
    box-shadow: var(--shadow-small);
    margin-bottom: 20px;
}
.profile-avatar {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: var(--primary);
    color: var(--surface);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 32px;
    font-weight: 700;
    margin: 0 auto 15px;
}
.profile-name {
    font-size: 20px;
    font-weight: 700;
    color: var(--navy);
    margin-bottom: 5px;
}
.profile-email {
    font-size: 14px;
    color: var(--muted-text);
    margin-bottom: 15px;
}
.profile-rep {
    display: inline-block;
    padding: 5px 12px;
    background: rgba(1, 226, 129, 0.1);
    color: var(--primary-hover);
    border-radius: 50px;
    font-size: 13px;
    font-weight: 600;
    margin-bottom: 20px;
    text-decoration: none;
}
.profile-rep:hover { text-decoration: underline; }
.menu-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    box-shadow: var(--shadow-small);
    overflow: hidden;
}
.menu-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 15px 20px;
    color: var(--body-text);
    font-weight: 500;
    border-left: 3px solid transparent;
    transition: var(--transition);
}
.menu-item:hover {
    background: var(--background);
    color: var(--primary-hover);
}
.menu-item.active {
    background: rgba(1, 226, 129, 0.05);
    color: var(--primary-hover);
    border-left-color: var(--primary);
    font-weight: 600;
}
.menu-item i {
    font-size: 18px;
    width: 20px;
    text-align: center;
}
.menu-item.danger {
    color: var(--danger);
}
.menu-item.danger:hover {
    background: rgba(255, 71, 87, 0.05);
    color: var(--danger);
}
.breadcrumb {
    font-size: 14px;
    color: var(--muted-text);
    margin-bottom: 20px;
}
.breadcrumb a {
    color: var(--navy);
}
.breadcrumb a:hover {
    color: var(--primary);
}
.page-title {
    font-size: 32px;
    margin-bottom: 5px;
}
.page-desc {
    color: var(--muted-text);
    margin-bottom: 30px;
}
.stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 30px;
}
.stat-card {
    background: var(--surface);
    border-radius: var(--radius-medium);
    padding: 20px;
    box-shadow: var(--shadow-small);
    border: 1px solid var(--border);
    display: flex;
    align-items: flex-start;
    gap: 15px;
}
.stat-icon {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: rgba(1, 226, 129, 0.1);
    color: var(--primary-hover);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
}
.stat-info h3 {
    font-size: 24px;
    margin-bottom: 0;
    color: var(--navy);
}
.stat-info p {
    font-size: 13px;
    color: var(--muted-text);
    margin: 0;
}
.section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    gap: 10px;
    flex-wrap: wrap;
}
.section-header h2 {
    font-size: 22px;
}
.rep-level-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 5px 14px;
    border-radius: 50px;
    font-size: 13px;
    font-weight: 700;
}
.alert-box {
    margin-bottom: 20px;
    padding: 16px 18px;
    background: #FBF3DB;
    border: 1px solid #f0dfa3;
    border-radius: var(--radius-medium);
    color: #7a5a00;
    font-size: 14px;
    display: flex;
    gap: 12px;
    align-items: flex-start;
}
.alert-box i { font-size: 18px; margin-top: 2px; color: #d99a1b; }
.card-panel {
    background: var(--surface);
    border-radius: var(--radius-medium);
    box-shadow: var(--shadow-small);
    border: 1px solid var(--border);
    padding: 25px;
    margin-bottom: 30px;
}
.filter-row {
    display: flex;
    gap: 8px;
    overflow-x: auto;
    padding-bottom: 4px;
    margin-bottom: 20px;
}
.filter-chip {
    display: inline-flex;
    align-items: center;
    padding: 7px 16px;
    border-radius: 50px;
    font-size: 13px;
    font-weight: 600;
    color: var(--body-text);
    background: var(--background);
    border: 1px solid var(--border);
    white-space: nowrap;
    transition: var(--transition);
}
.filter-chip:hover { border-color: var(--primary); color: var(--navy); }
.filter-chip.active {
    background: var(--navy);
    border-color: var(--navy);
    color: #fff;
}
.history-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
}
.history-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    padding: 16px 18px;
    background: var(--background);
    border: 1px solid var(--border);
    border-radius: var(--radius-medium);
    flex-wrap: wrap;
}
.history-delta {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 10px;
    border-radius: 50px;
    font-size: 12px;
    font-weight: 800;
}
.history-delta.positive { background: #EDF3EC; color: #346538; }
.history-delta.negative { background: #FDEBEC; color: #9F2F2D; }
.history-delta.neutral { background: #e2e8f0; color: #475569; }
.history-reason {
    font-size: 14px;
    font-weight: 600;
    color: var(--navy);
    margin-top: 4px;
}
.history-meta {
    font-size: 12.5px;
    color: var(--muted-text);
    margin-top: 4px;
}
.history-meta a { color: var(--primary-hover); font-weight: 600; }
.history-score {
    font-size: 14px;
    font-weight: 700;
    color: var(--navy);
    white-space: nowrap;
}
.history-score .arrow { color: var(--muted-text); margin: 0 6px; }
.calc-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
}
.calc-list li {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 13.5px;
    color: var(--body-text);
}
.calc-list li b { color: var(--navy); }
.calc-list i { width: 18px; text-align: center; }
.empty-history {
    padding: 40px;
    text-align: center;
    background: var(--background);
    border-radius: var(--radius-medium);
    border: 1px dashed var(--border);
}

@media (max-width: 1024px) {
    .account-container { flex-direction: column; }
    .account-sidebar { width: 100%; }
    .stats-grid { grid-template-columns: repeat(2, 1fr); }
}
@media (max-width: 768px) {
    .account-wrapper { padding: 30px 0; }
    .account-container { padding: 0 min(20px, 5vw); gap: 20px; }
    .stats-grid { grid-template-columns: 1fr; }
    .page-title { font-size: 26px; }
    .history-row { flex-direction: column; align-items: flex-start; }
    .history-score { align-self: flex-end; }
}
@media (max-width: 430px) {
    .account-container { padding: 0 min(16px, 4vw); }
    .card-panel { padding: 18px; }
}
</style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<div class="account-wrapper">
    <div class="account-container">
        <!-- Sidebar -->
        <aside class="account-sidebar">
            <div class="profile-card">
                <div class="profile-avatar">
                    <c:choose>
                        <c:when test="${not empty account.fullName}">${fn:escapeXml(fn:substring(account.fullName, 0, 1).toUpperCase())}</c:when>
                        <c:otherwise>${fn:escapeXml(fn:substring(account.username, 0, 1).toUpperCase())}</c:otherwise>
                    </c:choose>
                </div>
                <div class="profile-name">${fn:escapeXml(not empty account.fullName ? account.fullName : account.username)}</div>
                <div class="profile-email">${not empty account.email ? fn:escapeXml(account.email) : 'Chưa cập nhật email'}</div>
                <c:if test="${not empty account.phoneNumber}">
                    <div class="profile-email" style="margin-top: -10px;">${fn:escapeXml(account.phoneNumber)}</div>
                </c:if>
                <a href="${pageContext.request.contextPath}/customer/lich-su-diem-uy-tin" class="profile-rep">
                    <i class="fas fa-star" style="margin-right: 5px;"></i> Uy tín: ${account.diemUyTin}/100
                </a>
                <div>
                    <a href="${pageContext.request.contextPath}/customer/ho-so" class="btn btn-outline" style="color: var(--navy); border-color: var(--border); width: 100%; margin-bottom: 10px;">Chỉnh sửa hồ sơ</a>
                </div>
            </div>

            <div class="menu-card">
                <a href="${pageContext.request.contextPath}/customer/tai-khoan" class="menu-item">
                    <i class="fas fa-home"></i> Tổng quan
                </a>
                <a href="${pageContext.request.contextPath}/customer/lich-su-diem-uy-tin" class="menu-item active">
                    <i class="fas fa-star"></i> Điểm uy tín
                </a>
                <a href="${pageContext.request.contextPath}/customer/ghep-keo?tab=cua-toi" class="menu-item">
                    <i class="fas fa-futbol"></i> Kèo của tôi
                </a>
                <a href="${pageContext.request.contextPath}/customer/dich-vu-cua-toi" class="menu-item">
                    <i class="fas fa-screwdriver-wrench"></i> Dịch vụ của tôi
                </a>
                <a href="${pageContext.request.contextPath}/customer/doi-nhom" class="menu-item">
                    <i class="fas fa-users"></i> Nhóm của tôi
                </a>
                <a href="${pageContext.request.contextPath}/customer/doi-mat-khau" class="menu-item">
                    <i class="fas fa-lock"></i> Đổi mật khẩu
                </a>
                <a href="${pageContext.request.contextPath}/logout" class="menu-item danger">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="account-main">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/">Trang chủ</a> /
                <a href="${pageContext.request.contextPath}/customer/tai-khoan">Tài khoản của tôi</a> /
                <span>Điểm uy tín</span>
            </div>

            <h1 class="page-title">Điểm uy tín của tôi</h1>
            <p class="page-desc">Theo dõi điểm hiện tại và lịch sử thay đổi do hủy gần giờ, không đến sân hoặc các điều chỉnh hợp lệ.</p>

            <c:if test="${not canMatchmake}">
                <div class="alert-box">
                    <i class="fas fa-triangle-exclamation"></i>
                    <div>
                        <b>Tài khoản tạm thời bị hạn chế tính năng Ghép kèo.</b>
                        Điểm uy tín hiện tại là ${account.diemUyTin}/100, dưới ngưỡng tối thiểu 60 điểm. Hãy hoàn thành các ca đặt sân trực tiếp để tích lũy lại điểm.
                    </div>
                </div>
            </c:if>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-star"></i></div>
                    <div class="stat-info">
                        <h3>${account.diemUyTin}/100</h3>
                        <p>Điểm hiện tại</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(217, 154, 27, 0.12); color: #956400;"><i class="fas fa-clock"></i></div>
                    <div class="stat-info">
                        <h3>${account.lateCancelCount}</h3>
                        <p>Số lần hủy gần giờ</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(255, 71, 87, 0.1); color: var(--danger);"><i class="fas fa-user-xmark"></i></div>
                    <div class="stat-info">
                        <h3>${account.noShowCount}</h3>
                        <p>Số lần không đến sân</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background: rgba(18, 45, 64, 0.1); color: var(--navy);"><i class="fas fa-shield-halved"></i></div>
                    <div class="stat-info">
                        <h3>60/100</h3>
                        <p>Tối thiểu để Ghép kèo</p>
                    </div>
                </div>
            </div>

            <div class="card-panel">
                <div class="section-header">
                    <h2>Lịch sử thay đổi điểm</h2>
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

            <div class="card-panel">
                <div class="section-header">
                    <h2>Cách tính điểm uy tín</h2>
                </div>
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

</body>
</html>
