<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    org.example.model.TaiKhoan user = (org.example.model.TaiKhoan) session.getAttribute("user");
    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo — V-SPORT</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Poppins', system-ui, sans-serif;
            background: #f9fafb;
            color: #111827;
            min-height: 100vh;
        }
        .page-wrapper {
            max-width: 720px;
            margin: 0 auto;
            padding: 32px 20px 64px;
        }
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }
        .page-header h1 {
            font-size: 22px;
            font-weight: 700;
            color: #111827;
        }
        .badge-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #2563eb;
            color: #fff;
            font-size: 12px;
            font-weight: 600;
            border-radius: 999px;
            min-width: 22px;
            height: 22px;
            padding: 0 6px;
            margin-left: 8px;
        }
        .btn-mark-all {
            font-size: 13px;
            font-weight: 500;
            color: #2563eb;
            background: none;
            border: none;
            cursor: pointer;
            padding: 6px 12px;
            border-radius: 8px;
            transition: background 0.15s;
        }
        .btn-mark-all:hover { background: #eff6ff; }
        .notif-list {
            display: flex;
            flex-direction: column;
            gap: 1px;
            background: #EAEAEA;
            border: 1px solid #EAEAEA;
            border-radius: 12px;
            overflow: hidden;
        }
        .notif-item {
            display: flex;
            gap: 14px;
            align-items: flex-start;
            padding: 16px 20px;
            background: #fff;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            transition: background 0.12s;
            position: relative;
        }
        .notif-item:hover { background: #f9fafb; }
        .notif-item.unread { background: #eff6ff; }
        .notif-item.unread:hover { background: #dbeafe; }
        .notif-icon {
            flex-shrink: 0;
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 17px;
        }
        .notif-icon.booking   { background: #dbeafe; color: #2563eb; }
        .notif-icon.payment   { background: #d1fae5; color: #059669; }
        .notif-icon.refund    { background: #fef3c7; color: #d97706; }
        .notif-icon.default   { background: #f3f4f6; color: #6b7280; }
        .notif-body { flex: 1; min-width: 0; }
        .notif-title {
            font-size: 14px;
            font-weight: 600;
            color: #111827;
            line-height: 1.4;
            margin-bottom: 3px;
        }
        .notif-item.unread .notif-title { color: #1e3a8a; }
        .notif-content {
            font-size: 13px;
            color: #6b7280;
            line-height: 1.5;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .notif-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 5px;
        }
        .notif-time {
            font-size: 11px;
            color: #9ca3af;
        }
        .unread-dot {
            width: 7px;
            height: 7px;
            background: #2563eb;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 64px 20px;
            gap: 12px;
            color: #9ca3af;
            text-align: center;
        }
        .empty-state i { font-size: 40px; color: #d1d5db; }
        .empty-state p { font-size: 14px; }
        .pagination {
            display: flex;
            gap: 8px;
            justify-content: center;
            margin-top: 24px;
        }
        .pagination a {
            padding: 8px 16px;
            border: 1px solid #EAEAEA;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            text-decoration: none;
            background: #fff;
            transition: all 0.12s;
        }
        .pagination a:hover { background: #f3f4f6; border-color: #d1d5db; }
        .pagination a.disabled {
            color: #d1d5db;
            pointer-events: none;
        }
        .settings-link {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            color: #6b7280;
            text-decoration: none;
            margin-top: 20px;
            justify-content: center;
        }
        .settings-link:hover { color: #2563eb; }
    </style>
</head>
<body>
<%-- Header --%>
<jsp:include page="/customer/common/vsport-header.jsp" />

<div class="page-wrapper">
    <div class="page-header">
        <h1>
            Thông báo
            <c:if test="${unreadCount > 0}">
                <span class="badge-count">${unreadCount}</span>
            </c:if>
        </h1>
        <c:if test="${unreadCount > 0}">
            <form method="post" action="<%= ctxPath %>/customer/thong-bao" style="margin:0">
                <input type="hidden" name="action" value="markAllRead">
                <button type="submit" class="btn-mark-all">Đánh dấu tất cả đã đọc</button>
            </form>
        </c:if>
    </div>

    <c:choose>
        <c:when test="${empty notifications}">
            <div class="empty-state">
                <i class="fa-regular fa-bell-slash"></i>
                <p>Bạn chưa có thông báo nào.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="notif-list">
                <c:forEach var="n" items="${notifications}">
                    <c:set var="iconClass" value="default" />
                    <c:set var="iconFA" value="fa-regular fa-bell" />
                    <c:if test="${fn:contains(n.loaiThongBao, 'DAT_SAN') || fn:contains(n.loaiThongBao, 'BOOKING') || fn:contains(n.loaiThongBao, 'GIU_CHO')}">
                        <c:set var="iconClass" value="booking" />
                        <c:set var="iconFA" value="fa-regular fa-calendar-check" />
                    </c:if>
                    <c:if test="${fn:contains(n.loaiThongBao, 'THANH_TOAN') || fn:contains(n.loaiThongBao, 'PAYMENT')}">
                        <c:set var="iconClass" value="payment" />
                        <c:set var="iconFA" value="fa-solid fa-check-circle" />
                    </c:if>
                    <c:if test="${fn:contains(n.loaiThongBao, 'HOAN_TIEN') || fn:contains(n.loaiThongBao, 'REFUND')}">
                        <c:set var="iconClass" value="refund" />
                        <c:set var="iconFA" value="fa-solid fa-rotate-left" />
                    </c:if>

                    <%-- Wrap trong form POST để markRead trước khi redirect --%>
                    <c:choose>
                        <c:when test="${not empty n.duongDan}">
                            <form method="post" action="<%= ctxPath %>/customer/thong-bao" style="display:contents">
                                <input type="hidden" name="action" value="markRead">
                                <input type="hidden" name="id" value="${n.thongBaoId}">
                                <button type="submit" class="notif-item ${n.daDoc ? '' : 'unread'}" style="width:100%;text-align:left;border:none;font-family:inherit;">
                                    <div class="notif-icon ${iconClass}"><i class="${iconFA}"></i></div>
                                    <div class="notif-body">
                                        <div class="notif-title"><c:out value="${n.tieuDe}"/></div>
                                        <div class="notif-content"><c:out value="${n.noiDung}"/></div>
                                        <div class="notif-meta">
                                            <span class="notif-time">${n.thoiGianGui}</span>
                                            <c:if test="${!n.daDoc}"><span class="unread-dot"></span></c:if>
                                        </div>
                                    </div>
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form method="post" action="<%= ctxPath %>/customer/thong-bao" style="display:contents">
                                <input type="hidden" name="action" value="markRead">
                                <input type="hidden" name="id" value="${n.thongBaoId}">
                                <button type="submit" class="notif-item ${n.daDoc ? '' : 'unread'}" style="width:100%;text-align:left;border:none;font-family:inherit;cursor:default;">
                                    <div class="notif-icon ${iconClass}"><i class="${iconFA}"></i></div>
                                    <div class="notif-body">
                                        <div class="notif-title"><c:out value="${n.tieuDe}"/></div>
                                        <div class="notif-content"><c:out value="${n.noiDung}"/></div>
                                        <div class="notif-meta">
                                            <span class="notif-time">${n.thoiGianGui}</span>
                                            <c:if test="${!n.daDoc}"><span class="unread-dot"></span></c:if>
                                        </div>
                                    </div>
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="<%= ctxPath %>/customer/thong-bao?page=${currentPage - 1}">&larr; Trước</a>
                        </c:when>
                        <c:otherwise>
                            <a class="disabled">&larr; Trước</a>
                        </c:otherwise>
                    </c:choose>

                    <span style="font-size:13px;font-weight:600;color:#6b7280;display:inline-flex;align-items:center;padding:0 8px;">
                        Trang ${currentPage} / ${totalPages}
                    </span>

                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="<%= ctxPath %>/customer/thong-bao?page=${currentPage + 1}">Tiếp &rarr;</a>
                        </c:when>
                        <c:otherwise>
                            <a class="disabled">Tiếp &rarr;</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </c:otherwise>
    </c:choose>

    <a href="<%= ctxPath %>/customer/notification-settings" class="settings-link">
        <i class="fa-solid fa-sliders"></i> Cài đặt thông báo
    </a>
</div>
<jsp:include page="/common/footer.jsp" />
</body>
</html>
