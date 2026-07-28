<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Giỏ hàng & Lịch sử đặt sân - V-SPORT</title>
    <jsp:include page="/common/xtra-head.jsp" />
    <style>
        .cart-hero {
            background: linear-gradient(135deg, var(--navy-dark) 0%, var(--navy) 60%, #163e5c 100%);
            color: #fff;
            padding: 32px 0 28px 0;
            margin-bottom: 32px;
            box-shadow: inset 0 -1px 0 rgba(255,255,255,0.08);
        }
        .cart-hero-inner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }
        .cart-hero-title {
            font-size: 26px;
            font-weight: 800;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #ffffff;
            font-family: 'Poppins', sans-serif;
        }
        .cart-hero-title i {
            color: var(--primary);
            font-size: 24px;
        }
        .cart-hero-breadcrumbs {
            font-size: 13px;
            color: rgba(255,255,255,0.65);
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 8px;
        }
        .cart-hero-breadcrumbs a {
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: color 0.2s;
        }
        .cart-hero-breadcrumbs a:hover {
            color: var(--primary);
        }
        .cart-tabs {
            display: flex;
            align-items: center;
            gap: 0;
            background: none;
            padding: 0;
            border-radius: 0;
            border: none;
            flex-wrap: nowrap;
            white-space: nowrap;
        }
        .cart-tab-btn {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            padding: 6px 4px;
            font-size: 13px;
            font-weight: 700;
            color: rgba(255, 255, 255, 0.4);
            text-decoration: none;
            cursor: pointer;
            border: none;
            background: transparent;
            transition: color 0.2s;
            white-space: nowrap;
        }
        .cart-tab-btn + .cart-tab-btn::before {
            content: '';
            display: inline-block;
            width: 1px;
            height: 14px;
            background: rgba(255,255,255,0.2);
            margin-right: 12px;
        }
        .cart-tab-btn:first-child { margin-right: 12px; }
        .cart-tab-btn.active {
            background: none;
            color: #ffffff;
            box-shadow: none;
        }
        .cart-tab-btn:hover:not(.active) {
            color: rgba(255, 255, 255, 0.7);
            background: transparent;
        }
        .cart-tab-count {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 2px 7px;
            border-radius: 99px;
            font-size: 10px;
            font-weight: 800;
        }
        .cart-tab-btn.active .cart-tab-count {
            background: rgba(255,255,255,0.18);
            color: #fff;
        }
        .cart-tab-btn:not(.active) .cart-tab-count {
            background: rgba(255,255,255,0.1);
            color: rgba(255,255,255,0.5);
        }
        
        .cart-main-wrapper {
            max-width: var(--container-width);
            margin: 0 auto 60px auto;
            padding: 0 20px;
        }

        .tab-panel {
            animation: tabFadeIn 0.2s ease-out;
        }

        @keyframes tabFadeIn {
            from { opacity: 0; transform: translateY(4px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .cart-items-list {
            max-width: 1000px;
            margin: 0 auto;
        }

        /* Filter Controls */
        .history-controls {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
            margin-bottom: 24px;
        }
        .history-filters {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .hs-filter-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 18px;
            border-radius: 50px;
            font-size: 13px;
            font-weight: 700;
            color: var(--body-text);
            background: #fff;
            border: 1px solid var(--border);
            cursor: pointer;
            transition: all 0.2s;
        }
        .hs-filter-chip:hover {
            border-color: var(--navy);
            color: var(--navy);
        }
        .hs-filter-chip.is-active {
            background: var(--navy);
            border-color: var(--navy);
            color: #fff;
        }
        .history-search {
            position: relative;
            min-width: 260px;
        }
        .history-search input {
            width: 100%;
            padding: 9px 16px 9px 36px;
            border-radius: 50px;
            border: 1px solid var(--border);
            font-size: 13px;
            outline: none;
            background: #fff;
            transition: border-color 0.2s;
        }
        .history-search input:focus {
            border-color: var(--primary);
        }
        .history-search i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--muted-text);
            font-size: 13px;
        }

        .cart-item {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow-small);
            transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s;
        }
        .cart-item:hover {
            border-color: #cbd5e1;
            box-shadow: var(--shadow-medium);
        }
        .cart-item-info {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .cart-item-title {
            font-size: 19px;
            font-weight: 800;
            color: var(--navy);
            font-family: 'Poppins', sans-serif;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .cart-item-detail {
            font-size: 14px;
            color: var(--body-text);
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 500;
        }
        .cart-item-detail i {
            color: var(--primary);
            width: 16px;
        }
        .cart-item-price {
            font-size: 22px;
            font-weight: 800;
            color: #059669;
            font-family: 'Poppins', sans-serif;
        }
        .cart-item-status {
            display: inline-flex;
            align-items: center;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 12px;
            font-weight: 700;
        }
        .status-pending { background: #FFF7DA; color: #8a6116; border: 1px solid #fef08a; }
        .status-payment { background: #ffe6cf; color: #8a4b12; border: 1px solid #fed7aa; }
        .status-success { background: #dcfce7; color: #15803d; border: 1px solid #bbf7d0; }
        .status-active { background: #f3e8ff; color: #6b21a8; border: 1px solid #e9d5ff; }
        .status-completed { background: #e0f2fe; color: #0369a1; border: 1px solid #bae6fd; }
        .status-cancel { background: #fee2e2; color: #b91c1c; border: 1px solid #fecaca; }

        .cart-actions {
            display: flex;
            flex-direction: column;
            gap: 10px;
            align-items: flex-end;
        }
        .btn-cart-action {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 18px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 13px;
            text-decoration: none;
            cursor: pointer;
            border: none;
            transition: all 0.2s ease;
        }
        .btn-pay {
            background: var(--primary);
            color: var(--navy);
            box-shadow: 0 3px 10px rgba(1, 226, 129, 0.25);
        }
        .btn-pay:hover {
            background: var(--primary-hover);
            color: var(--navy);
        }
        .btn-cancel {
            background: #fff0f0;
            color: #dc2626;
            border: 1px solid #fecaca;
        }
        .btn-cancel:hover {
            background: #fee2e2;
            color: #b91c1c;
        }
        .btn-service {
            background: #f8fafc;
            color: #334155;
            border: 1px solid #cbd5e1;
        }
        .btn-service:hover {
            background: #f1f5f9;
            color: #0f172a;
        }
        .btn-match {
            background: #fffbeb;
            color: #b45309;
            border: 1px solid #fde68a;
        }
        .btn-match:hover {
            background: #fef3c7;
            color: #92400e;
        }

        .empty-cart {
            text-align: center;
            padding: 70px 24px;
            background: #fff;
            border-radius: 20px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-small);
        }
        .empty-cart-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #f1f5f9;
            color: #94a3b8;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            margin-bottom: 20px;
        }
        .empty-cart h3 {
            font-size: 22px;
            font-weight: 800;
            color: var(--navy);
            margin-bottom: 10px;
        }
        .empty-cart p {
            color: var(--muted-text);
            margin-bottom: 24px;
            font-size: 15px;
        }
        .highlight-target-booking {
            outline: 3px solid #10b981 !important;
            box-shadow: 0 0 25px rgba(16, 185, 129, 0.5) !important;
            transform: scale(1.02);
            transition: all 0.3s ease;
        }
    </style>
</head>
<body>

<jsp:include page="/common/header-xtra.jsp" />

<!-- Hero Banner Header -->
<div class="cart-hero">
    <div class="container">
        <div class="cart-hero-breadcrumbs">
            <a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Trang chủ</a>
            <i class="fas fa-chevron-right" style="font-size: 10px;"></i>
            <span id="breadcrumb-title">Giỏ hàng & Lịch sử đặt sân</span>
        </div>
        <div class="cart-hero-inner">
            <h1 class="cart-hero-title" id="page-hero-title">
                <i class="fas fa-shopping-basket"></i>
                Giỏ hàng & Lịch sử đặt sân
            </h1>
            <div class="cart-tabs">
                <button type="button" id="tab-btn-cart" class="cart-tab-btn active" onclick="switchBookingTab('cart')">
                    <i class="fas fa-shopping-cart"></i> Giỏ hàng (Chờ thanh toán)
                    <span class="cart-tab-count">${fn:length(cartItems)}</span>
                </button>
                <button type="button" id="tab-btn-history" class="cart-tab-btn" onclick="switchBookingTab('history')">
                    <i class="fas fa-history"></i> Lịch sử đặt sân
                    <span class="cart-tab-count">${fn:length(dsLich)}</span>
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Main Content Area -->
<div class="cart-main-wrapper">
    <c:if test="${not empty sessionScope.error}">
        <div style="background: #ffe5e6; color: #e3000f; padding: 15px 20px; border-radius: 12px; margin-bottom: 24px; font-weight: 600; border: 1px solid #fecaca;" class="cart-items-list">
            <i class="fas fa-exclamation-circle" style="margin-right: 8px;"></i> ${fn:escapeXml(sessionScope.error)}
        </div>
        <% session.removeAttribute("error"); %>
    </c:if>
    <c:if test="${not empty sessionScope.message}">
        <div style="background: #E5F7EF; color: #16A36A; padding: 15px 20px; border-radius: 12px; margin-bottom: 24px; font-weight: 600; border: 1px solid #a7f3d0;" class="cart-items-list">
            <i class="fas fa-check-circle" style="margin-right: 8px;"></i> ${fn:escapeXml(sessionScope.message)}
        </div>
        <% session.removeAttribute("message"); %>
    </c:if>

    <div class="cart-items-list">
        <!-- ================= TAB 1: GIỎ HÀNG (CHỜ THANH TOÁN) ================= -->
        <div id="panel-cart" class="tab-panel">
            <c:choose>
                <c:when test="${empty cartItems}">
                    <div class="empty-cart">
                        <div class="empty-cart-icon">
                            <i class="fas fa-shopping-basket"></i>
                        </div>
                        <h3>Giỏ hàng trống</h3>
                        <p>Bạn chưa có sân nào đang chờ thanh toán hoặc xác nhận. Hãy tìm sân ngay để đặt lịch!</p>
                        <div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
                            <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn btn-primary" style="padding: 12px 28px; border-radius: 50px;">
                                <i class="fas fa-calendar-plus" style="margin-right: 8px;"></i> Đặt sân ngay
                            </a>
                            <button type="button" onclick="switchBookingTab('history')" class="btn" style="background: #f1f5f9; color: var(--navy); padding: 12px 24px; border-radius: 50px; border: none; font-weight: 700; cursor: pointer;">
                                <i class="fas fa-history" style="margin-right: 8px;"></i> Xem lịch sử đặt sân
                            </button>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${cartItems}">
                        <c:set var="tenSan" value="Sân không xác định" />
                        <c:set var="tenCoSo" value="Cơ sở không xác định" />
                        <c:forEach var="s" items="${dsSan}">
                            <c:if test="${s.sanID == item.sanId}">
                                <c:set var="tenSan" value="${s.tenSan}" />
                                <c:forEach var="c" items="${dsCoSo}">
                                    <c:if test="${c.coSoID == s.coSoID}">
                                        <c:set var="tenCoSo" value="${c.tenCoSo}" />
                                    </c:if>
                                </c:forEach>
                            </c:if>
                        </c:forEach>

                        <div class="cart-item" id="booking-item-${item.datSanId}" data-datsan-id="${item.datSanId}">
                            <div class="cart-item-info">
                                <div class="cart-item-title">
                                    ${fn:escapeXml(tenSan)} - ${fn:escapeXml(tenCoSo)}
                                    <c:choose>
                                        <c:when test="${item.trangThai == 'Chờ thanh toán'}">
                                            <span class="cart-item-status status-payment"><i class="fas fa-qrcode" style="margin-right:5px;"></i> Chờ thanh toán</span>
                                        </c:when>
                                        <c:when test="${item.trangThai == 'Chờ xác nhận'}">
                                            <span class="cart-item-status status-pending"><i class="fas fa-hourglass-half" style="margin-right:5px;"></i> Chờ duyệt</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="cart-item-status status-pending">${fn:escapeXml(item.trangThai)}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="cart-item-detail">
                                    <i class="far fa-calendar-alt"></i> Ngày đặt: ${item.ngayDat}
                                </div>
                                <div class="cart-item-detail">
                                    <i class="far fa-clock"></i> Khung giờ: ${fn:substring(item.gioBatDau, 0, 5)} - ${fn:substring(item.gioKetThuc, 0, 5)} &bull; Mã: #${item.datSanId}
                                </div>
                            </div>
                            <div class="cart-actions">
                                <div class="cart-item-price"><fmt:formatNumber value="${item.tongTienDuKien}" pattern="#,##0"/> đ</div>
                                <div style="display: flex; gap: 8px; flex-wrap: wrap; justify-content: flex-end;">
                                    <c:if test="${item.trangThai == 'Chờ thanh toán'}">
                                        <a href="${pageContext.request.contextPath}/customer/thanh-toan-qr?datSanId=${item.datSanId}" class="btn-cart-action btn-pay">
                                            <i class="fas fa-credit-card"></i> Thanh toán
                                        </a>
                                    </c:if>
                                    <button type="button" onclick="openCancelBookingModal(${item.datSanId}, '${item.ngayDat}', '${item.gioBatDau}')" class="btn-cart-action btn-cancel">
                                        <i class="fas fa-times"></i> Hủy sân
                                    </button>
                                    <c:if test="${item.trangThai == 'Chờ xác nhận' || item.trangThai == 'Đã xác nhận'}">
                                        <button type="button" onclick="openCustomerServiceModal(${item.datSanId})" class="btn-cart-action btn-service">
                                            <i class="fas fa-concierge-bell"></i> Dịch vụ
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ================= TAB 2: LỊCH SỬ ĐẶT SÂN ================= -->
        <div id="panel-history" class="tab-panel" style="display: none;">
            <div class="history-controls">
                <div class="history-filters" id="historyStatusChips">
                    <button type="button" class="hs-filter-chip is-active" data-status-filter="all"><i class="fas fa-list-ul"></i> Tất cả</button>
                    <button type="button" class="hs-filter-chip" data-status-filter="upcoming"><i class="fas fa-calendar-check"></i> Sắp tới</button>
                    <button type="button" class="hs-filter-chip" data-status-filter="completed"><i class="fas fa-check-double"></i> Đã hoàn thành</button>
                    <button type="button" class="hs-filter-chip" data-status-filter="cancelled"><i class="fas fa-ban"></i> Đã hủy / Không đến</button>
                </div>
                <div class="history-search">
                    <i class="fas fa-search"></i>
                    <input type="search" id="historySearchInput" placeholder="Tìm tên sân, mã đơn..." autocomplete="off">
                </div>
            </div>

            <div id="historyTableBody">
                <c:forEach var="lich" items="${dsLich}">
                    <c:set var="tenSanHienThi" value="Sân #${lich.sanId}" />
                    <c:set var="branchHienThi" value="" />
                    <c:forEach var="s" items="${dsSan}">
                        <c:if test="${s.sanID == lich.sanId}">
                            <c:set var="tenSanHienThi" value="${s.tenSan}" />
                            <c:forEach var="cs" items="${dsCoSo}">
                                <c:if test="${cs.coSoID == s.coSoID}">
                                    <c:set var="branchHienThi" value="${cs.tenCoSo}" />
                                </c:if>
                            </c:forEach>
                        </c:if>
                    </c:forEach>

                    <c:set var="hsStatusGroup" value="other" />
                    <c:if test="${lich.trangThai == 'Chờ thanh toán' || lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt' || lich.trangThai == 'Đang sử dụng'}"><c:set var="hsStatusGroup" value="upcoming" /></c:if>
                    <c:if test="${lich.trangThai == 'Đã hoàn thành'}"><c:set var="hsStatusGroup" value="completed" /></c:if>
                    <c:if test="${lich.trangThai == 'Đã hủy' || lich.trangThai == 'Không đến'}"><c:set var="hsStatusGroup" value="cancelled" /></c:if>

                    <div class="cart-item history-row" id="booking-item-${lich.datSanId}" data-datsan-id="${lich.datSanId}" data-status-group="${hsStatusGroup}">
                        <div class="cart-item-info">
                            <div class="cart-item-title">
                                ${fn:escapeXml(tenSanHienThi)}
                                <c:if test="${not empty branchHienThi}"> - ${fn:escapeXml(branchHienThi)}</c:if>
                                
                                <c:choose>
                                    <c:when test="${lich.trangThai == 'Chờ thanh toán'}">
                                        <span class="cart-item-status status-payment"><i class="fas fa-qrcode" style="margin-right:5px;"></i> Chờ thanh toán</span>
                                    </c:when>
                                    <c:when test="${lich.trangThai == 'Chờ xác nhận'}">
                                        <span class="cart-item-status status-pending"><i class="fas fa-hourglass-half" style="margin-right:5px;"></i> Chờ duyệt</span>
                                    </c:when>
                                    <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt'}">
                                        <span class="cart-item-status status-success"><i class="fas fa-check-circle" style="margin-right:5px;"></i> Đã duyệt</span>
                                    </c:when>
                                    <c:when test="${lich.trangThai == 'Đang sử dụng'}">
                                        <span class="cart-item-status status-active"><i class="fas fa-running" style="margin-right:5px;"></i> Đang đá</span>
                                    </c:when>
                                    <c:when test="${lich.trangThai == 'Đã hoàn thành'}">
                                        <span class="cart-item-status status-completed"><i class="fas fa-flag-checkered" style="margin-right:5px;"></i> Hoàn thành</span>
                                    </c:when>
                                    <c:when test="${lich.trangThai == 'Đã hủy'}">
                                        <span class="cart-item-status status-cancel"><i class="fas fa-times-circle" style="margin-right:5px;"></i> Đã hủy</span>
                                    </c:when>
                                    <c:when test="${lich.trangThai == 'Không đến'}">
                                        <span class="cart-item-status status-cancel"><i class="fas fa-user-slash" style="margin-right:5px;"></i> Không đến</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="cart-item-status status-pending">${lich.trangThai}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="cart-item-detail">
                                <i class="far fa-calendar-alt"></i> Ngày đặt: ${lich.ngayDat}
                            </div>
                            <div class="cart-item-detail">
                                <i class="far fa-clock"></i> Khung giờ: ${lich.gioBatDau.toString().substring(0,5)} - ${lich.gioKetThuc.toString().substring(0,5)} &bull; Mã: #${lich.datSanId}
                            </div>

                            <c:if test="${(lich.trangThai == 'Đã hủy' || lich.trangThai == 'Không đến') && not empty lich.ghiChu}">
                                <div class="cart-item-detail" style="color: #64748b; font-size: 13px;">
                                    <i class="fas fa-info-circle"></i> Lý do: ${fn:escapeXml(lich.ghiChu)}
                                </div>
                            </c:if>
                        </div>

                        <div class="cart-actions">
                            <div class="cart-item-price"><fmt:formatNumber value="${lich.tongTienDuKien}" pattern="#,##0"/> đ</div>

                            <c:if test="${lich.trangThai == 'Chờ thanh toán'}">
                                <div style="display: flex; gap: 8px;">
                                    <a href="${pageContext.request.contextPath}/customer/thanh-toan-qr?datSanId=${lich.datSanId}" class="btn-cart-action btn-pay">
                                        <i class="fas fa-credit-card"></i> Thanh toán
                                    </a>
                                    <a href="${pageContext.request.contextPath}/customer/payos-cancel?datSanId=${lich.datSanId}" onclick="return confirm('Hủy đơn thanh toán này? Khung giờ sẽ được giải phóng.');" class="btn-cart-action btn-cancel">
                                        <i class="fas fa-times"></i> Hủy
                                    </a>
                                </div>
                            </c:if>

                            <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đang sử dụng'}">
                                <div style="display: flex; gap: 8px; flex-wrap: wrap; justify-content: flex-end;">
                                    <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận'}">
                                        <button type="button" onclick="openCancelBookingModal(${lich.datSanId}, '${lich.ngayDat}', '${lich.gioBatDau}')" class="btn-cart-action btn-cancel">
                                            <i class="fas fa-times"></i> Hủy sân
                                        </button>
                                    </c:if>
                                    <button type="button" onclick="openCustomerServiceModal(${lich.datSanId})" class="btn-cart-action btn-service">
                                        <i class="fas fa-concierge-bell"></i> Dịch vụ
                                    </button>
                                    <c:if test="${lich.trangThai == 'Đã xác nhận'}">
                                        <button type="button" onclick="openUrgentOpponentModal()" class="btn-cart-action btn-match">
                                            <i class="fas fa-user-plus"></i> Tìm đối
                                        </button>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty dsLich}">
                    <div class="empty-cart">
                        <div class="empty-cart-icon">
                            <i class="fas fa-history"></i>
                        </div>
                        <h3>Chưa có lịch sử đặt sân</h3>
                        <p>Bạn chưa có lịch sử đặt sân nào. Hãy tìm sân ngay để trải nghiệm!</p>
                        <a href="${pageContext.request.contextPath}/customer/dat-san" class="btn btn-primary" style="padding: 12px 28px; border-radius: 50px;">
                            <i class="fas fa-calendar-plus" style="margin-right: 8px;"></i> Đặt sân ngay
                        </a>
                    </div>
                </c:if>
            </div>

            <div id="historyPagination" style="display: none; padding-top: 16px; margin-top: 12px; border-top: 1px solid var(--border); align-items: center; justify-content: space-between; font-size: 13px; color: var(--muted-text);">
                <span id="historyPaginationInfo">Hiển thị...</span>
                <div id="historyPaginationBtns" style="display: flex; gap: 4px;"></div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />

<!-- CUSTOMER SERVICE BOOKING MODAL -->
<div id="customerServiceModal" style="position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 2000; display: none; align-items: center; justify-content: center; padding: 20px;">
    <div style="background: #fff; width: 100%; max-width: 600px; border-radius: 20px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); overflow: hidden;">
        <div style="background: linear-gradient(135deg, var(--navy-dark), var(--navy)); padding: 16px 24px; display: flex; align-items: center; justify-content: space-between; color: #fff;">
            <h3 style="font-size: 16px; font-weight: 800; margin: 0; font-family: 'Poppins', sans-serif;"><i class="fas fa-concierge-bell" style="color: var(--primary); margin-right: 8px;"></i> Đặt thêm dịch vụ / Nước uống</h3>
            <button onclick="closeCustomerServiceModal()" style="background: none; border: none; color: rgba(255,255,255,0.8); cursor: pointer; font-size: 18px;"><i class="fas fa-times"></i></button>
        </div>

        <div style="padding: 24px; max-height: 70vh; overflow-y: auto;">
            <form id="customer-service-form" action="${pageContext.request.contextPath}/customer/dat-dich-vu" method="post">
                <input type="hidden" name="datSanId" id="customer-service-datsan-id">

                <div id="customer-service-loading" style="text-align: center; padding: 30px 0; color: var(--muted-text);">
                    <i class="fas fa-spinner fa-spin" style="font-size: 28px; color: var(--primary); margin-bottom: 8px;"></i>
                    <p style="margin: 0; font-size: 14px;">Đang tải danh sách dịch vụ...</p>
                </div>

                <div id="customer-service-container" style="display: none;">
                    <div id="customer-products-grid" style="display: grid; grid-template-columns: 1fr; gap: 12px;"></div>
                </div>

                <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between;">
                    <div>
                        <span style="font-size: 11px; font-weight: 700; color: var(--muted-text); text-transform: uppercase; display: block;">Tổng tiền thêm</span>
                        <span id="customer-service-total" style="font-size: 20px; font-weight: 800; color: #059669; font-family: 'Poppins', sans-serif;">0 đ</span>
                    </div>
                    <div style="display: flex; gap: 10px;">
                        <button type="button" onclick="closeCustomerServiceModal()" style="padding: 10px 20px; border-radius: 8px; font-weight: 700; background: #f1f5f9; border: none; color: #475569; cursor: pointer;">Hủy</button>
                        <button type="submit" class="btn btn-primary" style="padding: 10px 24px; border-radius: 8px; font-weight: 700;">Xác nhận đặt</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- CANCEL BOOKING MODAL -->
<div id="cancelBookingModal" style="position: fixed; inset: 0; background: rgba(15, 23, 42, 0.6); backdrop-filter: blur(4px); z-index: 2000; display: none; align-items: center; justify-content: center; padding: 20px;">
    <div style="background: #fff; width: 100%; max-width: 440px; border-radius: 20px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1); overflow: hidden;">
        <div style="background: #dc2626; padding: 16px 24px; display: flex; align-items: center; justify-content: space-between; color: #fff;">
            <h3 style="font-size: 16px; font-weight: 800; margin: 0; font-family: 'Poppins', sans-serif;"><i class="fas fa-exclamation-triangle" style="margin-right: 8px;"></i> Xác nhận hủy đặt sân</h3>
            <button onclick="closeCancelBookingModal()" style="background: none; border: none; color: rgba(255,255,255,0.8); cursor: pointer; font-size: 18px;"><i class="fas fa-times"></i></button>
        </div>
        <form id="cancelBookingForm" action="${pageContext.request.contextPath}/customer/huy-dat-san" method="post">
            <input type="hidden" name="id" id="cancelBookingDatSanId" value="">
            <div style="padding: 24px;">
                <p style="margin-top: 0; margin-bottom: 12px; font-size: 14px; color: var(--body-text);">Bạn có chắc chắn muốn hủy đơn đặt sân này không?</p>
                <div id="cancelBookingLateWarning" style="display: none; background: #fffbeb; border: 1px solid #fde68a; padding: 12px; border-radius: 10px; font-size: 12px; color: #b45309; margin-bottom: 12px;">
                    <i class="fas fa-exclamation-circle"></i> Hủy sát giờ (dưới 6 tiếng) có thể làm giảm điểm uy tín của bạn.
                </div>
                <div>
                    <label style="display: block; font-size: 12px; font-weight: 700; color: var(--muted-text); margin-bottom: 6px;">Lý do hủy (không bắt buộc)</label>
                    <textarea name="reason" rows="2" maxlength="255" placeholder="Nhập lý do bận việc..." style="width: 100%; padding: 10px; border-radius: 8px; border: 1px solid var(--border); font-size: 13px; outline: none; box-sizing: border-box;"></textarea>
                </div>
            </div>
            <div style="padding: 16px 24px; background: #f8fafc; border-top: 1px solid var(--border); display: flex; justify-content: flex-end; gap: 10px;">
                <button type="button" onclick="closeCancelBookingModal()" style="padding: 10px 20px; border-radius: 8px; font-weight: 700; background: #e2e8f0; border: none; color: #475569; cursor: pointer;">Đóng</button>
                <button type="submit" style="padding: 10px 24px; border-radius: 8px; font-weight: 700; background: #dc2626; border: none; color: #fff; cursor: pointer;">Xác nhận hủy</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/customer/common/urgent-opponent-modal.jsp" />

<script>
    // 0ms Instant Client-Side Tab Switching
    function switchBookingTab(tab) {
        const isCart = tab === 'cart';
        const tabBtnCart = document.getElementById('tab-btn-cart');
        const tabBtnHistory = document.getElementById('tab-btn-history');
        const panelCart = document.getElementById('panel-cart');
        const panelHistory = document.getElementById('panel-history');
        const breadcrumbTitle = document.getElementById('breadcrumb-title');
        const pageHeroTitle = document.getElementById('page-hero-title');

        if (isCart) {
            tabBtnCart.classList.add('active');
            tabBtnHistory.classList.remove('active');
            panelHistory.style.display = 'none';
            panelCart.style.display = 'block';
            if (breadcrumbTitle) breadcrumbTitle.textContent = 'Giỏ hàng & Lịch sử đặt sân';
            if (pageHeroTitle) pageHeroTitle.innerHTML = '<i class="fas fa-shopping-basket"></i> Giỏ hàng & Lịch sử đặt sân';
            if (window.location.pathname.includes('lich-su-dat-san')) {
                history.pushState(null, '', '${pageContext.request.contextPath}/customer/gio-hang');
            }
        } else {
            tabBtnHistory.classList.add('active');
            tabBtnCart.classList.remove('active');
            panelCart.style.display = 'none';
            panelHistory.style.display = 'block';
            if (breadcrumbTitle) breadcrumbTitle.textContent = 'Giỏ hàng & Lịch sử đặt sân';
            if (pageHeroTitle) pageHeroTitle.innerHTML = '<i class="fas fa-history"></i> Giỏ hàng & Lịch sử đặt sân';
            if (window.location.pathname.includes('gio-hang')) {
                history.pushState(null, '', '${pageContext.request.contextPath}/customer/lich-su-dat-san');
            }
        }
    }

    // Auto-detect initial tab from URL
    document.addEventListener('DOMContentLoaded', () => {
        const path = window.location.pathname;
        if (path.includes('lich-su-dat-san')) {
            switchBookingTab('history');
        } else {
            switchBookingTab('cart');
        }

        // History tab search, filtering, pagination
        const tableBody = document.getElementById('historyTableBody');
        const pagPanel = document.getElementById('historyPagination');
        const searchInput = document.getElementById('historySearchInput');
        const statusChips = document.querySelectorAll('#historyStatusChips [data-status-filter]');
        if (!tableBody || !pagPanel) return;

        const rows = Array.from(tableBody.querySelectorAll('.history-row'));
        if (rows.length === 0) return;

        const pageSize = 5;
        let currentPage = 1;
        let activeStatus = 'all';

        function applyFilters(resetPage = true) {
            if (resetPage) currentPage = 1;
            const searchValue = searchInput ? searchInput.value.toLowerCase().trim() : '';
            const matchedRows = [];

            rows.forEach(row => {
                const text = row.innerText.toLowerCase();
                const statusOk = activeStatus === 'all' || row.getAttribute('data-status-group') === activeStatus;
                if (statusOk && text.includes(searchValue)) {
                    matchedRows.push(row);
                } else {
                    row.style.display = 'none';
                }
            });

            const totalPages = Math.ceil(matchedRows.length / pageSize);
            const start = (currentPage - 1) * pageSize;
            const end = start + pageSize;

            matchedRows.forEach((row, index) => {
                if (index >= start && index < end) {
                    row.style.display = 'flex';
                } else {
                    row.style.display = 'none';
                }
            });

            if (matchedRows.length === 0 || totalPages <= 1) {
                pagPanel.style.display = 'none';
            } else {
                pagPanel.style.display = 'flex';
            }

            const actualEnd = Math.min(end, matchedRows.length);
            const infoSpan = document.getElementById('historyPaginationInfo');
            if (infoSpan) {
                if (matchedRows.length > 0) {
                    infoSpan.innerText = `Hiển thị ${start + 1}-${actualEnd} trong ${matchedRows.length} đơn đặt sân`;
                } else {
                    infoSpan.innerText = `Không tìm thấy đơn đặt sân nào`;
                }
            }

            renderButtons(totalPages);
        }

        function renderButtons(totalPages) {
            const btnContainer = document.getElementById('historyPaginationBtns');
            if (!btnContainer) return;
            btnContainer.innerHTML = '';
            if (totalPages <= 1) return;

            const prevBtn = document.createElement('button');
            prevBtn.type = 'button';
            prevBtn.style.cssText = 'padding: 6px 12px; border-radius: 6px; border: 1px solid var(--border); background: #fff; cursor: pointer;';
            prevBtn.disabled = currentPage === 1;
            prevBtn.innerHTML = '<i class="fas fa-chevron-left"></i>';
            prevBtn.onclick = () => { currentPage--; applyFilters(false); };
            btnContainer.appendChild(prevBtn);

            for (let i = 1; i <= totalPages; i++) {
                const btn = document.createElement('button');
                btn.type = 'button';
                btn.innerText = i;
                if (i === currentPage) {
                    btn.style.cssText = 'padding: 6px 12px; border-radius: 6px; background: var(--navy); color: #fff; border: none; font-weight: 700;';
                } else {
                    btn.style.cssText = 'padding: 6px 12px; border-radius: 6px; border: 1px solid var(--border); background: #fff; cursor: pointer;';
                }
                btn.onclick = () => { currentPage = i; applyFilters(false); };
                btnContainer.appendChild(btn);
            }

            const nextBtn = document.createElement('button');
            nextBtn.type = 'button';
            nextBtn.style.cssText = 'padding: 6px 12px; border-radius: 6px; border: 1px solid var(--border); background: #fff; cursor: pointer;';
            nextBtn.disabled = currentPage === totalPages;
            nextBtn.innerHTML = '<i class="fas fa-chevron-right"></i>';
            nextBtn.onclick = () => { currentPage++; applyFilters(false); };
            btnContainer.appendChild(nextBtn);
        }

        if (searchInput) {
            searchInput.addEventListener('input', () => applyFilters(true));
        }

        statusChips.forEach(chip => {
            chip.addEventListener('click', () => {
                statusChips.forEach(c => c.classList.remove('is-active'));
                chip.classList.add('is-active');
                activeStatus = chip.getAttribute('data-status-filter');
                applyFilters(true);
            });
        });

        applyFilters(true);

        // Tự động chuyển tab, cuộn trang & highlight đúng đơn đặt sân khi từ thông báo nhấp qua
        const urlParams = new URLSearchParams(window.location.search);
        const highlightId = urlParams.get('highlightDatSanId');
        if (highlightId) {
            const targetInCart = document.querySelector('#panel-cart #booking-item-' + highlightId);
            if (targetInCart) {
                switchBookingTab('cart');
            } else {
                switchBookingTab('history');
            }

            const targetRow = document.getElementById('booking-item-' + highlightId);
            if (targetRow) {
                const matchIndex = rows.indexOf(targetRow);
                if (matchIndex !== -1) {
                    currentPage = Math.floor(matchIndex / pageSize) + 1;
                    applyFilters(false);
                }
                setTimeout(() => {
                    targetRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    targetRow.classList.add('highlight-target-booking');
                    setTimeout(() => {
                        targetRow.classList.remove('highlight-target-booking');
                    }, 4000);
                }, 350);
            }
        }
    });

    window.addEventListener('popstate', () => {
        const path = window.location.pathname;
        if (path.includes('lich-su-dat-san')) {
            switchBookingTab('history');
        } else {
            switchBookingTab('cart');
        }
    });

    let customerProducts = [];
    let customerOrdered = [];

    function openCustomerServiceModal(datSanId) {
        document.getElementById("customer-service-datsan-id").value = datSanId;
        const modal = document.getElementById("customerServiceModal");
        const loading = document.getElementById("customer-service-loading");
        const container = document.getElementById("customer-service-container");
        const grid = document.getElementById("customer-products-grid");

        modal.style.display = "flex";
        loading.style.display = "block";
        container.style.display = "none";

        fetch(`${pageContext.request.contextPath}/customer/dat-dich-vu?datSanId=${datSanId}`)
            .then(res => res.json())
            .then(data => {
                customerProducts = data.products || [];
                customerOrdered = data.ordered || [];
                loading.style.display = "none";
                container.style.display = "block";
                grid.innerHTML = "";

                if (customerProducts.length === 0) {
                    grid.innerHTML = `<div style="text-align: center; color: var(--muted-text); padding: 20px 0; font-style: italic;">Cơ sở này hiện chưa có dịch vụ nào kinh doanh.</div>`;
                    return;
                }

                customerProducts.forEach(prod => {
                    const ord = customerOrdered.find(o => o.SanPhamID === prod.SanPhamID);
                    const qty = ord ? ord.SoLuong : 0;

                    const itemHtml = `
                        <div style="padding: 12px; background: #f8fafc; border: 1px solid var(--border); border-radius: 12px; display: flex; align-items: center; justify-content: space-between;">
                            <div>
                                <strong style="font-size: 14px; color: var(--navy); display: block;">${prod.TenSanPham}</strong>
                                <span style="font-size: 12px; color: var(--muted-text);">${prod.DonGia.toLocaleString('vi-VN')} đ / ${prod.DonViTinh || 'cái'}</span>
                            </div>
                            <div style="display: flex; align-items: center; gap: 6px;">
                                <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, -1)" style="width: 28px; height: 28px; border-radius: 6px; border: 1px solid var(--border); background: #fff; cursor: pointer; font-weight: 700;">-</button>
                                <input type="number" name="quantity" id="cust-qty-${prod.SanPhamID}" value="${qty}" min="0" max="${prod.SoLuongTon}" style="width: 36px; text-align: center; border: 1px solid var(--border); border-radius: 6px; font-weight: 700; padding: 2px 0;" readonly>
                                <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, 1)" style="width: 28px; height: 28px; border-radius: 6px; border: 1px solid var(--border); background: #fff; cursor: pointer; font-weight: 700;">+</button>
                            </div>
                        </div>
                    `;
                    grid.insertAdjacentHTML("beforeend", itemHtml);
                });
                recalculateCustomerTotal();
            })
            .catch(err => {
                grid.innerHTML = `<div style="text-align: center; color: #dc2626; padding: 20px 0;">Có lỗi xảy ra: ${err.message}</div>`;
                loading.style.display = "none";
                container.style.display = "block";
            });
    }

    function adjustCustomerQty(spId, delta) {
        const input = document.getElementById(`cust-qty-${spId}`);
        if (!input) return;
        const prod = customerProducts.find(p => p.SanPhamID === spId);
        if (!prod) return;
        let val = (parseInt(input.value) || 0) + delta;
        if (val < 0) val = 0;
        if (val > prod.SoLuongTon) val = prod.SoLuongTon;
        input.value = val;
        recalculateCustomerTotal();
    }

    function recalculateCustomerTotal() {
        let total = 0;
        customerProducts.forEach(prod => {
            const input = document.getElementById(`cust-qty-${prod.SanPhamID}`);
            const qty = input ? (parseInt(input.value) || 0) : 0;
            total += qty * prod.DonGia;
        });
        document.getElementById("customer-service-total").textContent = total.toLocaleString('vi-VN') + " đ";
    }

    function closeCustomerServiceModal() {
        document.getElementById("customerServiceModal").style.display = "none";
    }

    function openCancelBookingModal(datSanId, ngayDatStr, gioBatDauStr) {
        document.getElementById("cancelBookingDatSanId").value = datSanId;
        var warningEl = document.getElementById("cancelBookingLateWarning");
        try {
            var bookingStart = new Date(ngayDatStr + "T" + gioBatDauStr);
            var hoursUntilStart = (bookingStart.getTime() - Date.now()) / (1000 * 60 * 60);
            warningEl.style.display = (hoursUntilStart <= 6) ? "block" : "none";
        } catch (e) {
            warningEl.style.display = "none";
        }
        document.getElementById("cancelBookingModal").style.display = "flex";
    }

    function closeCancelBookingModal() {
        document.getElementById("cancelBookingModal").style.display = "none";
    }
</script>
</body>
</html>
