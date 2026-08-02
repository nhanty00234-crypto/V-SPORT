<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<style>
    .acc-stats-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-bottom: 28px;
    }
    .acc-stat-box {
        background: #f8fafc;
        border: 1px solid var(--border, #DCE5EF);
        border-radius: 14px;
        padding: 18px 20px;
        display: flex;
        align-items: center;
        gap: 16px;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    .acc-stat-box:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }
    .acc-stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        flex-shrink: 0;
    }
    .acc-stat-num {
        font-size: 24px;
        font-weight: 800;
        color: var(--navy, #0B2E59);
        font-family: 'Outfit', sans-serif;
        line-height: 1;
        margin-bottom: 4px;
    }
    .acc-stat-lbl {
        font-size: 12.5px;
        font-weight: 600;
        color: var(--muted-text, #64748b);
    }

    .acc-sec-title {
        font-size: 18px;
        font-weight: 800;
        color: var(--navy, #0B2E59);
        font-family: 'Outfit', sans-serif;
        margin: 0 0 16px 0;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    .acc-booking-card {
        background: #fff;
        border: 1px solid var(--border, #DCE5EF);
        border-radius: 16px;
        padding: 20px 24px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        transition: border-color 0.2s, box-shadow 0.2s;
    }
    .acc-booking-card:hover {
        border-color: #cbd5e1;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }

    .acc-shortcuts-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 16px;
        margin-top: 12px;
    }
    .acc-shortcut-item {
        background: #f8fafc;
        border: 1px solid var(--border, #DCE5EF);
        border-radius: 14px;
        padding: 20px 16px;
        text-align: center;
        text-decoration: none;
        color: var(--navy, #0B2E59);
        transition: all 0.2s ease;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
    }
    .acc-shortcut-item:hover {
        background: #ffffff;
        border-color: var(--primary, #01c771);
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    }
    .acc-shortcut-icon {
        width: 44px;
        height: 44px;
        border-radius: 12px;
        background: rgba(1, 226, 129, 0.12);
        color: var(--navy, #0B2E59);
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
    }
    .acc-shortcut-lbl {
        font-size: 13.5px;
        font-weight: 700;
    }

    @media (max-width: 1024px) {
        .acc-stats-grid { grid-template-columns: repeat(2, 1fr); }
        .acc-shortcuts-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 640px) {
        .acc-stats-grid { grid-template-columns: 1fr; }
        .acc-shortcuts-grid { grid-template-columns: repeat(2, 1fr); }
        .acc-booking-card { flex-direction: column; align-items: flex-start; }
    }
</style>

<div class="acc-stats-grid">
    <div class="acc-stat-box">
        <div class="acc-stat-icon" style="background: rgba(1, 226, 129, 0.15); color: var(--navy, #0B2E59);">
            <i class="fas fa-calendar-check"></i>
        </div>
        <div>
            <div class="acc-stat-num">${upcomingCount}</div>
            <div class="acc-stat-lbl">Lịch sắp tới</div>
        </div>
    </div>
    <div class="acc-stat-box">
        <div class="acc-stat-icon" style="background: rgba(18, 45, 64, 0.1); color: var(--navy, #0B2E59);">
            <i class="fas fa-history"></i>
        </div>
        <div>
            <div class="acc-stat-num">${totalBookings}</div>
            <div class="acc-stat-lbl">Tổng số lần đặt</div>
        </div>
    </div>
    <div class="acc-stat-box">
        <div class="acc-stat-icon" style="background: rgba(16, 185, 129, 0.1); color: #059669;">
            <i class="fas fa-check-circle"></i>
        </div>
        <div>
            <div class="acc-stat-num">${completedCount}</div>
            <div class="acc-stat-lbl">Đã hoàn thành</div>
        </div>
    </div>
    <a href="${pageContext.request.contextPath}/customer/lich-su-diem-uy-tin" class="acc-stat-box" style="text-decoration: none;">
        <div class="acc-stat-icon" style="background: rgba(245, 158, 11, 0.12); color: #d97706;">
            <i class="fas fa-star"></i>
        </div>
        <div>
            <div class="acc-stat-num">${account.diemUyTin}/100</div>
            <div class="acc-stat-lbl">Điểm uy tín</div>
        </div>
    </a>
</div>

<div class="acc-sec-title">
    <span><i class="fas fa-calendar-alt" style="color: #01c771; margin-right: 8px;"></i> Lịch đặt sân gần nhất</span>
    <a href="${pageContext.request.contextPath}/customer/gio-hang" style="font-size: 13.5px; font-weight: 700; color: var(--navy, #0B2E59); text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
        Xem tất cả <i class="fas fa-arrow-right" style="font-size: 12px;"></i>
    </a>
</div>

<div style="margin-bottom: 28px;">
    <c:choose>
        <c:when test="${not empty upcomingBookings}">
            <c:forEach var="lich" items="${upcomingBookings}">
                <div class="acc-booking-card">
                    <div>
                        <div style="font-size: 17px; font-weight: 800; color: var(--navy, #0B2E59); font-family: 'Outfit', sans-serif; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 6px;">
                            <c:choose>
                                <c:when test="${not empty upcomingSanNames[lich.sanId]}">${fn:escapeXml(upcomingSanNames[lich.sanId])}</c:when>
                                <c:otherwise>Sân #${lich.sanId}</c:otherwise>
                            </c:choose>
                            <c:choose>
                                <c:when test="${lich.trangThai == 'Chờ xác nhận'}"><span style="display:inline-block; padding:3px 10px; border-radius:999px; font-size:11.5px; font-weight:700; background:#FFF7DA; color:#8a6116; border:1px solid #fef08a;">Chờ duyệt</span></c:when>
                                <c:when test="${lich.trangThai == 'Chờ thanh toán'}"><span style="display:inline-block; padding:3px 10px; border-radius:999px; font-size:11.5px; font-weight:700; background:#ffe6cf; color:#8a4b12; border:1px solid #fed7aa;">Chờ thanh toán</span></c:when>
                                <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt' || lich.trangThai == 'Đã thanh toán'}"><span style="display:inline-block; padding:3px 10px; border-radius:999px; font-size:11.5px; font-weight:700; background:#dcfce7; color:#15803d; border:1px solid #bbf7d0;">Đã duyệt</span></c:when>
                                <c:when test="${lich.trangThai == 'Đang sử dụng'}"><span style="display:inline-block; padding:3px 10px; border-radius:999px; font-size:11.5px; font-weight:700; background:#f3e8ff; color:#6b21a8; border:1px solid #e9d5ff;">Đang đá</span></c:when>
                                <c:otherwise><span style="display:inline-block; padding:3px 10px; border-radius:999px; font-size:11.5px; font-weight:700; background:#f1f5f9; color:#475569; border:1px solid #cbd5e1;">${fn:escapeXml(lich.trangThai)}</span></c:otherwise>
                            </c:choose>
                        </div>
                        <div style="font-size: 13.5px; color: #475569; display: flex; align-items: center; gap: 14px; flex-wrap: wrap; font-weight: 500;">
                            <c:if test="${not empty upcomingCoSoNames[lich.sanId]}">
                                <span><i class="fas fa-map-marker-alt" style="color: #01c771; margin-right: 4px;"></i> ${fn:escapeXml(upcomingCoSoNames[lich.sanId])}</span>
                            </c:if>
                            <span><i class="far fa-calendar-alt" style="color: #01c771; margin-right: 4px;"></i> ${lich.ngayDat}</span>
                            <span><i class="far fa-clock" style="color: #01c771; margin-right: 4px;"></i> ${lich.gioBatDau} - ${lich.gioKetThuc} &bull; Mã: #${lich.datSanId}</span>
                        </div>
                    </div>
                    <div>
                        <a href="${pageContext.request.contextPath}/customer/gio-hang" style="background: #f1f5f9; color: var(--navy, #0B2E59); border: 1px solid var(--border, #DCE5EF); padding: 8px 18px; border-radius: 10px; font-weight: 700; font-size: 13px; text-decoration: none; display: inline-block;">
                            Xem chi tiết
                        </a>
                    </div>
                </div>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <div style="padding: 40px 20px; text-align: center; background: #f8fafc; border-radius: 16px; border: 1px solid var(--border, #DCE5EF);">
                <div style="font-size: 40px; color: #cbd5e1; margin-bottom: 12px;"><i class="fas fa-calendar-times"></i></div>
                <h3 style="margin: 0 0 6px 0; font-size: 18px; color: var(--navy, #0B2E59); font-weight: 800;">Chưa có lịch đặt nào</h3>
                <p style="color: #64748b; margin: 0 0 20px 0; font-size: 14px;">Bạn hiện không có lịch đặt sân sắp tới.</p>
                <a href="${pageContext.request.contextPath}/customer/dat-san" style="padding: 10px 24px; border-radius: 50px; background: #01c771; color: var(--navy, #0B2E59); font-weight: 800; text-decoration: none; display: inline-block;">Đặt sân ngay</a>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<div class="acc-sec-title">
    <span><i class="fas fa-bolt" style="color: #01c771; margin-right: 8px;"></i> Truy cập nhanh</span>
</div>
<div class="acc-shortcuts-grid">
    <a href="${pageContext.request.contextPath}/customer/dat-san" class="acc-shortcut-item">
        <div class="acc-shortcut-icon"><i class="fas fa-plus-circle"></i></div>
        <div class="acc-shortcut-lbl">Đặt sân mới</div>
    </a>
    <a href="${pageContext.request.contextPath}/customer/ban-do" class="acc-shortcut-item">
        <div class="acc-shortcut-icon"><i class="fas fa-map-marked-alt"></i></div>
        <div class="acc-shortcut-lbl">Tìm sân gần nhất</div>
    </a>
    <a href="${pageContext.request.contextPath}/customer/ghep-keo?tab=tao-keo" class="acc-shortcut-item">
        <div class="acc-shortcut-icon"><i class="fas fa-users"></i></div>
        <div class="acc-shortcut-lbl">Tạo kèo giao lưu</div>
    </a>
    <a href="${pageContext.request.contextPath}/customer/ghep-keo?tab=kham-pha" class="acc-shortcut-item">
        <div class="acc-shortcut-icon"><i class="fas fa-search"></i></div>
        <div class="acc-shortcut-lbl">Tìm người chơi</div>
    </a>
</div>
