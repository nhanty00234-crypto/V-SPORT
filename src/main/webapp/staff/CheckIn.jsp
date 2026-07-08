<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <title>Quản lý Mở Sân / Check-in | V-SPORT</title>
    <jsp:include page="/staff/common/staff_head.jsp" />
    
    <style>
        body { font-family: 'Inter', sans-serif; }
        .card { 
            background: #fff; 
            border: 1px solid ${sessionScope.user.roleId == 2 ? '#e9d5ff' : '#ffedd5'}; 
            border-radius: 16px; 
            transition: box-shadow .2s, transform .2s; 
        }
        .card-hover:hover { 
            box-shadow: 0 8px 24px -8px ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.15)' : 'rgba(234, 88, 12, 0.12)'}; 
            transform: translateY(-2px); 
        }
        .badge { display: inline-flex; align-items: center; padding: 4px 10px; border-radius: 8px; font-size: 11px; font-weight: 600; }
        .badge-green { background: #dcfce7; color: #15803d; }
        .badge-amber { background: #fef3c7; color: #b45309; }
        .badge-red { background: #fee2e2; color: #b91c1c; }
        .badge-blue { background: #dbeafe; color: #1e40af; }
        .badge-orange { background: #ffedd5; color: #c2410c; }
        .badge-purple { background: #f3e8ff; color: #6d28d9; }
        .badge-gray { background: #f4f4f5; color: #52525b; }
        
        @keyframes pulse-dot {
            0%, 100% { box-shadow: 0 0 0 0 ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.4)' : 'rgba(234, 88, 12, 0.4)'}; }
            50% { box-shadow: 0 0 0 8px rgba(234, 88, 12, 0); }
        }
        .live-dot { animation: pulse-dot 1.6s ease-in-out infinite; }
        
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        main > section { animation: fadeUp .35s ease both; }
        .hero-gradient { 
            background: ${sessionScope.user.roleId == 2 
                ? 'linear-gradient(135deg, #faf5ff 0%, #f3e8ff 60%, #e9d5ff 100%)' 
                : 'linear-gradient(135deg, #fff7ed 0%, #ffedd5 60%, #ffedad 100%)'}; 
        }

        /* POS Product Catalog styles */
        .pos-tab {
            padding: 6px 14px;
            border-radius: 9999px;
            font-size: 11.5px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.15s ease;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #64748b;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            user-select: none;
        }
        .pos-tab:hover {
            border-color: #cbd5e1;
            color: #334155;
            background: #f8fafc;
        }
        .pos-tab.active {
            background: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
            color: #ffffff;
            border-color: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
        }
        
        .pos-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 14px;
            padding: 12px;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            cursor: pointer;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            user-select: none;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.02);
            min-height: 85px;
        }
        .pos-card:hover:not(.disabled) {
            border-color: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
            box-shadow: 0 6px 16px -4px ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.12)' : 'rgba(234, 88, 12, 0.1)'};
            transform: translateY(-1.5px);
        }
        .pos-card:active:not(.disabled) {
            transform: scale(0.97);
        }
        .pos-card.disabled {
            opacity: 0.55;
            cursor: not-allowed;
            background: #f8fafc;
            border-color: #cbd5e1;
            box-shadow: none;
        }

        /* 3-Column POS modal custom styling */
        .pos-grid-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.5rem;
        }
        @media (min-width: 1024px) {
            .pos-grid-container {
                grid-template-columns: 42fr 30fr 28fr;
            }
        }
        
        /* Stepper styles */
        .stepper-btn {
            width: 26px;
            height: 26px;
            border-radius: 8px;
            background: #f1f5f9;
            color: #475569;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.15s ease;
            user-select: none;
        }
        .stepper-btn:hover {
            background: #e2e8f0;
            color: #1e293b;
        }
        .stepper-btn:active {
            transform: scale(0.92);
        }
        
        /* Billing Mode Cards */
        .bill-mode-card {
            border: 2px solid #e2e8f0;
            background: #ffffff;
            border-radius: 14px;
            padding: 10px 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            align-items: flex-start;
            gap: 10px;
            position: relative;
            user-select: none;
        }
        .bill-mode-card:hover:not(.disabled) {
            border-color: #cbd5e1;
            background: #f8fafc;
        }
        .bill-mode-card.active {
            border-color: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
            background: ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.03)' : 'rgba(234, 88, 12, 0.02)'};
            box-shadow: 0 4px 12px ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.05)' : 'rgba(234, 88, 12, 0.04)'};
        }
        .bill-mode-card.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            background: #f8fafc;
            border-color: #cbd5e1;
        }
        
        /* Payment Method Cards */
        .pay-method-card {
            border: 2px solid #e2e8f0;
            background: #ffffff;
            border-radius: 12px;
            padding: 8px 10px;
            cursor: pointer;
            transition: all 0.2s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 6px;
            user-select: none;
            text-align: center;
            min-height: 70px;
        }
        .pay-method-card:hover {
            border-color: #cbd5e1;
            background: #f8fafc;
        }
        .pay-method-card.active {
            border-color: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
            background: ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.03)' : 'rgba(234, 88, 12, 0.02)'};
            color: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
            box-shadow: 0 4px 12px ${sessionScope.user.roleId == 2 ? 'rgba(124, 58, 237, 0.05)' : 'rgba(234, 88, 12, 0.04)'};
        }
        .pay-method-card.active .material-symbols-outlined {
            color: ${sessionScope.user.roleId == 2 ? '#7c3aed' : '#ea580c'};
        }
        
        /* Cart items styling */
        .cart-item {
            border-bottom: 1px solid #f1f5f9;
            padding: 10px 4px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            transition: background 0.15s ease;
        }
        .cart-item:hover {
            background: rgba(248, 250, 252, 0.5);
        }
    </style>
</head>
<body class="text-zinc-900 min-h-screen">

<!-- Khai báo các biến theme động dựa theo Role (Quản lý - Tím | Lễ tân - Cam) -->
<c:set var="isManager" value="${sessionScope.user.roleId == 2}" />
<c:set var="themeBg" value="${isManager ? 'bg-purple-600' : 'bg-orange-600'}" />
<c:set var="themeBgHover" value="${isManager ? 'hover:bg-purple-700' : 'hover:bg-orange-700'}" />
<c:set var="themeText" value="${isManager ? 'text-purple-650' : 'text-orange-650'}" />
<c:set var="themeTextDark" value="${isManager ? 'text-purple-950' : 'text-orange-950'}" />
<c:set var="themeTextMedium" value="${isManager ? 'text-purple-700' : 'text-orange-700'}" />
<c:set var="themeTextLight" value="${isManager ? 'text-purple-500' : 'text-orange-550'}" />
<c:set var="themeBorder" value="${isManager ? 'border-purple-100' : 'border-orange-100'}" />
<c:set var="themeBorderStrong" value="${isManager ? 'border-purple-200' : 'border-orange-200'}" />
<c:set var="themeBgLight" value="${isManager ? 'bg-purple-50/50' : 'bg-orange-50/50'}" />
<c:set var="themeBgLightStrong" value="${isManager ? 'bg-purple-100/50' : 'bg-orange-100/50'}" />
<c:set var="themeIcon" value="${isManager ? 'text-purple-600' : 'text-orange-650'}" />
<c:set var="badgeTheme" value="${isManager ? 'badge-purple' : 'badge-orange'}" />
<c:set var="focusRing" value="${isManager ? 'focus:border-purple-500' : 'focus:border-orange-500'}" />

<!-- Sidebar Navigation -->
<c:choose>
    <c:when test="${isManager}">
        <jsp:include page="/manager/common/sidebar.jsp" />
    </c:when>
    <c:otherwise>
        <jsp:include page="/staff/common/sidebar.jsp" />
    </c:otherwise>
</c:choose>

<!-- Header -->
<header class="h-[64px] fixed top-0 right-0 left-0 lg:left-[248px] bg-white/80 backdrop-blur-lg border-b ${themeBorder} z-20 flex items-center justify-between px-4 lg:px-6">
    <div class="flex items-center gap-3">
        <button id="mobileMenuBtn" class="lg:hidden p-2 rounded-lg ${isManager ? 'hover:bg-purple-50 text-purple-600' : 'hover:bg-orange-50 text-orange-650'}">
            <span class="material-symbols-outlined text-[20px]">menu</span>
        </button>
        <div>
            <h1 class="text-sm font-bold ${themeTextDark} tracking-tight">Hệ thống mở sân / Check-in</h1>
            <p class="text-xs ${themeTextLight} flex items-center gap-1.5">
                <span class="material-symbols-outlined text-[12px]">schedule</span>Chi nhánh cơ sở CS${sessionScope.user.coSoId}
            </p>
        </div>
    </div>
    <div class="flex items-center gap-1.5">
        <div class="text-xs font-semibold px-3 py-1 ${isManager ? 'bg-purple-50 text-purple-750' : 'bg-orange-50 text-orange-700'} rounded-lg">
            Vai trò: ${isManager ? "Quản lý" : "Lễ tân trực ca"}
        </div>
        <div class="w-px h-6 ${themeBorder} mx-1"></div>
        <jsp:include page="/manager/common/profile_dropdown.jsp" />
    </div>
</header>

<!-- Main Content Area -->
<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-6">

    <!-- 1. THÔNG BÁO HỆ THỐNG / THÔNG BÁO LỖI -->
    <c:if test="${not empty successMsg}">
        <section class="bg-green-50 border border-green-200 text-green-800 p-4 rounded-xl flex items-center gap-3 shadow-sm">
            <span class="material-symbols-outlined text-green-600 text-[24px]">check_circle</span>
            <div>
                <p class="font-bold text-sm">Thành công</p>
                <p class="text-xs">${successMsg}</p>
            </div>
        </section>
    </c:if>

    <c:if test="${not empty errorMsg and empty paymentRequired}">
        <section class="bg-red-50 border border-red-200 text-red-800 p-4 rounded-xl flex items-center gap-3 shadow-sm">
            <span class="material-symbols-outlined text-red-600 text-[24px]">error</span>
            <div>
                <p class="font-bold text-sm">Lỗi xử lý nghiệp vụ</p>
                <p class="text-xs">${errorMsg}</p>
            </div>
        </section>
    </c:if>

    <!-- HỘP THOẠI CẢNH BÁO THANH TOÁN (Payment Lock Alert) -->
    <c:if test="${paymentRequired}">
        <section class="bg-amber-50 border-2 border-amber-300 text-amber-950 p-5 rounded-2xl flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-md">
            <div class="flex items-start gap-3.5">
                <div class="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center text-amber-700 shrink-0 shadow-inner">
                    <span class="material-symbols-outlined text-[28px]" style="font-variation-settings: 'FILL' 1">lock</span>
                </div>
                <div class="hidden">
                    <h3 class="font-black text-base text-amber-950 tracking-tight flex items-center gap-1.5">
                        CẢNH BÁO THU TIỀN MẶT <span class="badge badge-red uppercase">Payment Lock</span>
                    </h3>
                    <p class="text-xs text-amber-900 mt-1 leading-relaxed">
                        ${errorMsg}<br>
                        <strong>Yêu cầu:</strong> Lễ tân vui lòng thu tiền mặt của khách tại quầy trước khi kích hoạt trạng thái mở sân.
                    </p>
                </div>
            </div>
            <div class="flex gap-2 shrink-0 self-end md:self-center">
                <form action="${pageContext.request.contextPath}/staff/checkin" method="post">
                    <input type="hidden" name="action" value="checkInPreBooked">
                    <input type="hidden" name="datSanId" value="${datSanIdPending}">
                    <input type="hidden" name="daThuTienMat" value="true">
                    <button type="submit" class="bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 shadow-sm active:scale-95 transition-all">
                        <span class="material-symbols-outlined text-[16px]">payments</span>
                        Đã thu tiền mặt & Mở sân
                    </button>
                </form>
                <a href="${pageContext.request.contextPath}/staff/checkin" class="bg-zinc-200 hover:bg-zinc-300 text-zinc-800 font-bold text-xs px-4 py-2.5 rounded-xl flex items-center gap-1.5 transition-all">
                    Hủy bỏ
                </a>
            </div>
        </section>
    </c:if>

    <c:set var="availCount" value="0" />
    <c:set var="useCount" value="0" />
    <c:set var="maintCount" value="0" />
    <c:set var="closeCount" value="0" />
    <c:forEach var="s" items="${danhSachSan}">
        <c:choose>
            <c:when test="${s.trangThai == 'Sẵn sàng'}"><c:set var="availCount" value="${availCount + 1}" /></c:when>
            <c:when test="${s.trangThai == 'Đang sử dụng'}"><c:set var="useCount" value="${useCount + 1}" /></c:when>
            <c:when test="${s.trangThai == 'Bảo trì'}"><c:set var="maintCount" value="${maintCount + 1}" /></c:when>
            <c:otherwise><c:set var="closeCount" value="${closeCount + 1}" /></c:otherwise>
        </c:choose>
    </c:forEach>

    <!-- Welcome & Facility Status Bar -->
    <section class="hero-gradient rounded-2xl border ${themeBorderStrong} p-5 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 relative overflow-hidden">
        <div class="absolute -top-12 -right-12 w-64 h-64 ${isManager ? 'bg-purple-300/10' : 'bg-orange-300/10'} rounded-full blur-3xl pointer-events-none"></div>
        <div>
            <span class="text-[10px] font-extrabold uppercase tracking-widest ${themeTextMedium} block mb-0.5">BẢNG ĐIỀU KHIỂN CHI NHÁNH CƠ SỞ</span>
            <h2 class="text-xl font-black ${themeTextDark} tracking-tight">Kích hoạt & Giám sát sân bãi thời gian thực</h2>
            <p class="text-xs ${themeTextMedium} mt-1">Đảm bảo việc mở sân chính xác và xử lý tranh chấp đặt sân online.</p>
        </div>
    </section>

    <!-- Dashboard Stats Grid -->
    <section class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3">
        <div class="card p-3.5 flex flex-col items-center justify-center bg-white border border-zinc-200 shadow-sm text-center">
            <span class="text-[9px] text-zinc-550 font-bold block uppercase tracking-wider">Tổng số sân</span>
            <span id="stat-total" class="text-lg font-black text-zinc-800 mt-1">${danhSachSan.size()}</span>
        </div>
        <div class="card p-3.5 flex flex-col items-center justify-center bg-white border border-green-200 shadow-sm text-center">
            <span class="text-[9px] text-zinc-550 font-bold block uppercase tracking-wider">Sẵn sàng</span>
            <span id="stat-available" class="text-lg font-black text-green-600 mt-1">${availCount}</span>
        </div>
        <div class="card p-3.5 flex flex-col items-center justify-center bg-white border ${themeBorder} shadow-sm text-center">
            <span class="text-[9px] text-zinc-550 font-bold block uppercase tracking-wider">Đang sử dụng</span>
            <span id="stat-in-use" class="text-lg font-black ${themeText} mt-1">${useCount}</span>
        </div>
        <div class="card p-3.5 flex flex-col items-center justify-center bg-white border border-amber-200 shadow-sm text-center">
            <span class="text-[9px] text-zinc-550 font-bold block uppercase tracking-wider">Bảo trì</span>
            <span id="stat-maintenance" class="text-lg font-black text-amber-600 mt-1">${maintCount}</span>
        </div>
        <div class="card p-3.5 flex flex-col items-center justify-center bg-white border border-red-200 shadow-sm text-center">
            <span class="text-[9px] text-zinc-550 font-bold block uppercase tracking-wider">Tạm đóng</span>
            <span id="stat-closed" class="text-lg font-black text-red-650 mt-1">${closeCount}</span>
        </div>
        <div class="card p-3.5 flex flex-col items-center justify-center bg-white border border-zinc-200 shadow-sm text-center">
            <span class="text-[9px] text-zinc-550 font-bold block uppercase tracking-wider">Lịch hôm nay</span>
            <span id="stat-today" class="text-lg font-black ${themeTextMedium} mt-1">${danhSachLich.size()}</span>
        </div>
    </section>

    <!-- 2. HÌNH ẢNH TRẠNG THÁI SÂN BÃI THỰC TẾ (Real-time Field Status Grid) -->
    <section id="field-status-grid" class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        <c:choose>
            <c:when test="${danhSachSan.size() == 0}">
                <div class="col-span-full py-12 flex flex-col items-center justify-center text-center bg-white rounded-2xl border border-zinc-150 p-6">
                    <span class="material-symbols-outlined text-[48px] text-zinc-300 mb-2">sports_soccer</span>
                    <p class="font-extrabold text-zinc-800 text-sm">Chưa có sân nào trong cơ sở này</p>
                    <p class="text-xs text-zinc-500 mt-1">Hãy tạo sân ở mục Quản lý sân trước.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="san" items="${danhSachSan}">
                    <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 cursor-pointer card-hover hover:border-zinc-300
                         ${san.trangThai == 'Đang sử dụng' ? (isManager ? 'border-purple-300 shadow-md' : 'border-orange-300 shadow-md') : ''}
                         ${san.trangThai == 'Bảo trì' ? 'border-amber-200 bg-amber-50/20' : ''}
                         ${san.trangThai == 'Tạm đóng' ? 'border-red-200 bg-red-50/20' : ''}"
                         data-sanid="${san.sanID}"
                         data-tensan="${san.tenSan}"
                         data-loaisan="${san.tenLoaiSan}"
                         data-trangthai="${san.trangThai}"
                         data-mota="${san.moTa}"
                         data-giakhongden="${san.giaKhongDen}"
                         data-giacoden="${san.giaCoDen}"
                         data-giobatdaulenden="${san.gioBatDauLenDen}"
                         data-giokethuclenden="${san.gioKetThucLenDen}"
                         data-datsanidactive="${san.datSanIdActive}"
                         data-giobatdauactive="${san.gioBatDauActive}"
                         data-giokethucactive="${san.gioKetThucActive}"
                         data-ghichuactive="${san.ghiChuActive}"
                         onclick="onCardClick(event, this)">
                        
                        <div class="w-full flex flex-col items-center">
                            <c:choose>
                                <c:when test="${san.trangThai == 'Đang sử dụng'}">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full ${isManager ? 'bg-purple-500' : 'bg-orange-500'} live-dot"></span>
                                    <div class="w-12 h-12 rounded-2xl ${isManager ? 'bg-purple-50' : 'bg-orange-50'} flex items-center justify-center ${themeIcon} mb-2 shadow-inner">
                                        <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-800">${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">${san.tenLoaiSan}</p>
                                    <span class="badge ${badgeTheme} mt-2 uppercase text-[10px]">Đang sử dụng</span>
                                    <p class="text-[10px] text-zinc-500 mt-1 flex items-center justify-center gap-1">
                                        <span class="material-symbols-outlined text-[12px]">schedule</span>
                                        <span class="card-timer font-bold text-zinc-700" 
                                              data-start="${san.gioBatDauActive}" 
                                              data-end="${san.gioKetThucActive}" 
                                              data-note="${san.ghiChuActive}">Bắt đầu: ${san.gioBatDauActive}</span>
                                    </p>
                                    
                                    <c:if test="${san.ghiChuActive != null && san.ghiChuActive.contains('Không cố định') && !san.ghiChuActive.contains('Đã chốt giờ thực tế')}">
                                        <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="w-full mt-2" onsubmit="return confirm('Bạn có chắc chắn muốn dừng chơi và chốt giờ thực tế cho ca này?');">
                                            <input type="hidden" name="action" value="stopOpenSession">
                                            <input type="hidden" name="datSanId" value="${san.datSanIdActive}">
                                            <button type="submit" class="w-full bg-red-550 hover:bg-red-700 text-white font-extrabold text-[10px] py-2 rounded-xl shadow-sm hover:shadow transition-all active:scale-95 flex items-center justify-center gap-1">
                                                <span class="material-symbols-outlined text-[12px]">stop_circle</span>
                                                Dừng chơi & Tính tiền
                                            </button>
                                        </form>
                                    </c:if>
                                    <button type="button" onclick="openStaffInvoiceModal(${san.datSanIdActive})" class="w-full mt-3 ${themeBg} ${themeBgHover} text-white font-extrabold text-[10px] py-2 rounded-xl shadow-sm hover:shadow transition-all active:scale-95">
                                        Dịch vụ & Thanh toán
                                    </button>
                                </c:when>
                                <c:when test="${san.trangThai == 'Sẵn sàng'}">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-green-500"></span>
                                    <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center text-green-600 mb-2">
                                        <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-800">${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">${san.tenLoaiSan}</p>
                                    <span class="badge badge-green mt-2 uppercase text-[10px]">Sẵn sàng</span>
                                    
                                    <button type="button" onclick="toggleCardCollapse(event, ${san.sanID})" class="w-full mt-3 ${themeBg} ${themeBgHover} text-white font-extrabold text-[10px] py-2 rounded-xl shadow-sm hover:shadow transition-all active:scale-95">
                                        Mở sân
                                    </button>

                                    <!-- Collapsible walk-in form inline -->
                                    <div id="collapse-walkin-${san.sanID}" class="hidden w-full mt-3 pt-3 border-t border-zinc-150 text-left space-y-3" onclick="event.stopPropagation()">
                                        <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="space-y-3">
                                            <input type="hidden" name="action" value="checkInWalkIn">
                                            <input type="hidden" name="sanId" value="${san.sanID}">
                                            <input type="hidden" id="card-walkin-duration-${san.sanID}" name="duration" value="120">
                                            
                                            <!-- Prebooked list if any -->
                                            <div id="card-prebooked-section-${san.sanID}" class="hidden space-y-1">
                                                <label class="block text-[9px] font-black ${themeText} uppercase tracking-wider">Khách đặt trước hôm nay:</label>
                                                <div id="card-prebooked-list-${san.sanID}" class="space-y-1"></div>
                                            </div>

                                            <div class="space-y-1">
                                                <label class="block text-[9px] font-black text-zinc-500 uppercase tracking-wider">Kiểu giờ chơi:</label>
                                                <div class="grid grid-cols-2 gap-1">
                                                    <label id="card-mode-fixed-label-${san.sanID}" class="border ${themeBorderStrong} ${themeBgLight} rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold ${themeTextMedium} transition-all text-center">
                                                        <input type="radio" class="sr-only" name="playMode" value="FIXED" checked onchange="setCardPlayMode(${san.sanID}, 'FIXED')">
                                                        Cố định
                                                    </label>
                                                    <label id="card-mode-open-label-${san.sanID}" class="border border-zinc-150 rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold text-zinc-700 hover:border-zinc-300 transition-all text-center">
                                                        <input type="radio" class="sr-only" name="playMode" value="OPEN" onchange="setCardPlayMode(${san.sanID}, 'OPEN')">
                                                        Không cố định
                                                    </label>
                                                </div>
                                            </div>

                                            <div id="card-fixed-panel-${san.sanID}" class="space-y-1">
                                                <label class="block text-[9px] font-black text-zinc-500 uppercase tracking-wider">Mốc giờ chơi:</label>
                                                <div class="grid grid-cols-3 gap-1 mb-1">
                                                    <button type="button" data-card-duration-btn="${san.sanID}-60" onclick="setCardDuration(${san.sanID}, 60)" class="card-duration-btn-${san.sanID} py-1 rounded border border-zinc-200 text-[8px] font-extrabold text-zinc-700 hover:bg-zinc-50">60p</button>
                                                    <button type="button" data-card-duration-btn="${san.sanID}-120" onclick="setCardDuration(${san.sanID}, 120)" class="card-duration-btn-${san.sanID} py-1 rounded border ${themeBorderStrong} ${themeBgLight} text-[8px] font-extrabold ${themeTextMedium}">2h</button>
                                                    <button type="button" data-card-duration-btn="${san.sanID}-180" onclick="setCardDuration(${san.sanID}, 180)" class="card-duration-btn-${san.sanID} py-1 rounded border border-zinc-200 text-[8px] font-extrabold text-zinc-700 hover:bg-zinc-50">3h</button>
                                                </div>
                                                <select name="duration_select" onchange="setCardSelectDuration(${san.sanID}, this.value)" class="w-full text-[9px] p-1 border border-zinc-200 rounded bg-white focus:outline-none">
                                                    <option value="60">60 phút (1 giờ)</option>
                                                    <option value="90">90 phút (1.5 giờ)</option>
                                                    <option value="120" selected>120 phút (2 giờ)</option>
                                                    <option value="150">150 phút (2.5 giờ)</option>
                                                    <option value="180">180 phút (3 giờ)</option>
                                                </select>
                                            </div>

                                            <div id="card-open-note-${san.sanID}" class="hidden p-1.5 rounded border ${themeBorder} ${themeBgLight} text-[8px] ${themeTextMedium} font-semibold leading-tight">
                                                Tính tiền thực tế khi trả sân.
                                            </div>

                                            <div class="space-y-1">
                                                <label class="block text-[9px] font-black text-zinc-500 uppercase tracking-wider">Đơn giá (VND/h):</label>
                                                <input type="number" id="card-rate-${san.sanID}" name="donGia" step="10000" class="w-full text-[10px] p-1 border border-zinc-150 rounded bg-zinc-50 cursor-not-allowed focus:outline-none" required readonly oninput="calculateCardPrice(${san.sanID})">
                                                <span id="card-rate-type-${san.sanID}" class="text-[8px] text-zinc-450 block italic"></span>
                                            </div>

                                            <div class="p-1.5 bg-zinc-50 rounded border border-zinc-150 flex items-center justify-between text-[9px]">
                                                <span class="text-zinc-550 font-bold">Tạm tính:</span>
                                                <span id="card-subtotal-val-${san.sanID}" class="font-extrabold text-[10px] ${themeTextMedium}">0đ</span>
                                            </div>

                                            <button type="submit" class="w-full ${themeBg} ${themeBgHover} text-white font-extrabold text-[9px] py-1.5 rounded-lg shadow-sm hover:shadow active:scale-95 transition-all flex items-center justify-center gap-1">
                                                <span class="material-symbols-outlined text-[10px]">play_circle</span>
                                                Mở sân ngay
                                            </button>
                                        </form>
                                    </div>
                                </c:when>
                                <c:when test="${san.trangThai == 'Bảo trì'}">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-amber-500"></span>
                                    <div class="w-12 h-12 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-600 mb-2">
                                        <span class="material-symbols-outlined text-[24px]">build</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-850 opacity-60">${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">${san.tenLoaiSan}</p>
                                    <span class="badge badge-amber mt-2 uppercase text-[10px]">Bảo trì</span>
                                    
                                    <button type="button" onclick="openCourtDetailDrawer(${san.sanID})" class="w-full mt-3 bg-zinc-150 text-zinc-600 hover:bg-zinc-200 transition-colors font-extrabold text-[10px] py-2 rounded-xl">
                                        Chi tiết
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-red-500"></span>
                                    <div class="w-12 h-12 rounded-2xl bg-red-50 flex items-center justify-center text-red-650 mb-2">
                                        <span class="material-symbols-outlined text-[24px]">block</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-850 opacity-60">${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">${san.tenLoaiSan}</p>
                                    <span class="badge badge-red mt-2 uppercase text-[10px]">Tạm đóng</span>
                                    
                                    <button type="button" onclick="openCourtDetailDrawer(${san.sanID})" class="w-full mt-3 bg-zinc-150 text-zinc-600 hover:bg-zinc-200 transition-colors font-extrabold text-[10px] py-2 rounded-xl">
                                        Chi tiết
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>

    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- 4. DANH SÁCH LỊCH ĐẶT SÂN TRONG NGÀY (Today's Bookings Schedule Dashboard) -->
        <section class="card p-5 xl:col-span-3 border ${themeBorder} overflow-hidden flex flex-col justify-between">
            <div>
                <!-- Header with Tabs -->
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between border-b ${themeBorder} pb-4 mb-5 gap-4">
                    <h3 class="text-base font-black ${themeTextDark} tracking-tight flex items-center gap-2">
                        <span class="material-symbols-outlined ${themeIcon}">calendar_today</span>
                        Vận Hành & Check-in Hôm Nay
                    </h3>
                    
                    <div class="flex bg-zinc-100 p-1 rounded-xl text-xs font-bold gap-1 self-start lg:self-auto shadow-inner">
                        <button type="button" id="tab-btn-playing" onclick="switchBookingTab('playing')" class="flex items-center gap-2 px-4 py-2 rounded-lg transition-all text-zinc-555 hover:text-zinc-800">
                            <span class="material-symbols-outlined text-[16px]">sports_soccer</span>
                            Đang chơi
                            <span id="badge-count-playing" class="bg-emerald-500 text-white px-2 py-0.5 rounded-full text-[10px] font-extrabold">0</span>
                        </button>
                        <button type="button" id="tab-btn-waiting" onclick="switchBookingTab('waiting')" class="flex items-center gap-2 px-4 py-2 rounded-lg transition-all text-zinc-555 hover:text-zinc-800">
                            <span class="material-symbols-outlined text-[16px]">schedule</span>
                            Chờ check-in
                            <span id="badge-count-waiting" class="bg-amber-500 text-white px-2 py-0.5 rounded-full text-[10px] font-extrabold">0</span>
                        </button>
                        <button type="button" id="tab-btn-completed" onclick="switchBookingTab('completed')" class="flex items-center gap-2 px-4 py-2 rounded-lg transition-all text-zinc-500 hover:text-zinc-700">
                            <span class="material-symbols-outlined text-[16px]">check_circle</span>
                            Đã xong hôm nay
                            <span id="badge-count-completed" class="bg-zinc-400 text-white px-2 py-0.5 rounded-full text-[10px] font-extrabold">0</span>
                        </button>
                    </div>
                </div>

                <!-- Search Input -->
                <div class="mb-5 relative">
                    <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                        <span class="material-symbols-outlined text-zinc-450 text-[18px]">search</span>
                    </div>
                    <input type="text" id="booking-search-input" oninput="onBookingSearch(this.value)" placeholder="Tìm kiếm nhanh ca chơi theo tên khách, số điện thoại hoặc sân..." class="w-full text-xs pl-10 pr-4 py-2.5 border border-zinc-200 focus:border-zinc-400 rounded-xl bg-white focus:outline-none transition-all placeholder-zinc-400 text-zinc-800">
                </div>

                <!-- Tab Contents -->
                <!-- Tab 1: Playing -->
                <div id="tab-content-playing" class="tab-pane hidden">
                    <div id="list-playing" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <!-- Filled by JS -->
                    </div>
                </div>

                <!-- Tab 2: Waiting -->
                <div id="tab-content-waiting" class="tab-pane hidden">
                    <div id="list-waiting" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <!-- Filled by JS -->
                    </div>
                </div>

                <!-- Tab 3: Completed -->
                <div id="tab-content-completed" class="tab-pane hidden">
                    <div id="list-completed" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <!-- Filled by JS -->
                    </div>
                </div>
            </div>

            <!-- Helpful tips -->
            <div class="mt-6 p-3 bg-zinc-50 border border-zinc-200 rounded-xl text-[10px] text-zinc-550 flex items-center gap-2">
                <span class="material-symbols-outlined text-zinc-400 text-[16px]">info</span>
                <span>Mẹo: Staff có thể nhấn vào biểu tượng <span class="material-symbols-outlined text-[12px] inline-block align-middle text-[#630ed4]">content_copy</span> để copy nhanh số điện thoại của khách hàng, hoặc click số điện thoại để gọi.</span>
            </div>
        </section>
    </div>

</main>

<script>
    let drawerTimerInterval = null;
    const isManager = ${isManager};
    const themeBg = '${themeBg}';
    const themeBgHover = '${themeBgHover}';
    const themeText = '${themeText}';
    const themeTextMedium = '${themeTextMedium}';
    const themeBorder = '${themeBorder}';
    const themeBorderStrong = '${themeBorderStrong}';
    const themeBgLight = '${themeBgLight}';
    const themeIcon = '${themeIcon}';
    const badgeTheme = '${badgeTheme}';
    const focusRing = '${focusRing}';
    let localDanhSachLich = [
        <c:forEach var="b" items="${danhSachLich}" varStatus="status">
            {
                datSanId: ${b.datSanId},
                sanId: ${b.sanId},
                tenSan: `${b.tenSan}`,
                tenKhachHang: `${b.tenKhachHang}`,
                soDienThoai: `${b.soDienThoai != null ? b.soDienThoai : ''}`,
                tenLoaiSan: `${b.tenLoaiSan != null ? b.tenLoaiSan : ''}`,
                gioBatDau: "${b.gioBatDau != null ? b.gioBatDau.toString().substring(0,5) : '00:00'}",
                gioKetThuc: "${b.gioKetThuc != null ? b.gioKetThuc.toString().substring(0,5) : '00:00'}",
                tongTien: ${b.tongTien != null ? b.tongTien : 0},
                trangThai: "${b.trangThai}",
                ghiChu: `${b.ghiChu != null ? b.ghiChu : ''}`,
                trangThaiThanhToan: "${b.trangThaiThanhToan}",
                nguonDatSan: "${b.nguonDatSan}"
            }<c:if test="${not status.last}">,</c:if>
        </c:forEach>
    ];

    let activeBookingTab = null;
    let bookingSearchQuery = "";

    function onBookingSearch(val) {
        bookingSearchQuery = val.trim().toLowerCase();
        renderBookings();
    }

    function switchBookingTab(tabName) {
        activeBookingTab = tabName;
        
        // Hide all tab panes
        document.querySelectorAll('.tab-pane').forEach(el => el.classList.add('hidden'));
        
        // Remove active styling from all tab buttons
        document.querySelectorAll('[id^="tab-btn-"]').forEach(btn => {
            btn.className = "flex items-center gap-2 px-4 py-2 rounded-lg transition-all text-zinc-550 hover:text-zinc-800";
        });
        
        // Show current tab pane
        const activePane = document.getElementById(`tab-content-${tabName}`);
        if (activePane) activePane.classList.remove('hidden');
        
        // Set active styling on current button
        const activeBtn = document.getElementById(`tab-btn-${tabName}`);
        if (activeBtn) {
            if (tabName === 'playing') {
                activeBtn.className = `flex items-center gap-2 px-4 py-2 rounded-lg transition-all bg-emerald-500 text-white shadow-md`;
            } else if (tabName === 'waiting') {
                activeBtn.className = `flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${themeBg} text-white shadow-md`;
            } else {
                activeBtn.className = `flex items-center gap-2 px-4 py-2 rounded-lg transition-all bg-zinc-650 text-white shadow-md`;
            }
        }
    }

    function copyToClipboard(text, btnEl) {
        if (!navigator.clipboard) {
            const textarea = document.createElement('textarea');
            textarea.value = text;
            textarea.style.position = 'fixed';
            document.body.appendChild(textarea);
            textarea.select();
            try {
                document.execCommand('copy');
                const icon = btnEl.querySelector('.material-symbols-outlined');
                if (icon) {
                    icon.textContent = 'check';
                    icon.classList.remove('text-zinc-450');
                    icon.classList.add('text-green-600');
                    setTimeout(() => {
                        icon.textContent = 'content_copy';
                        icon.classList.remove('text-green-600');
                        icon.classList.add('text-zinc-450');
                    }, 1500);
                }
            } catch (err) {
                console.error('Fallback copy failed', err);
            }
            document.body.removeChild(textarea);
            return;
        }
        navigator.clipboard.writeText(text).then(() => {
            const icon = btnEl.querySelector('.material-symbols-outlined');
            if (icon) {
                icon.textContent = 'check';
                icon.classList.remove('text-zinc-450');
                icon.classList.add('text-green-600');
                setTimeout(() => {
                    icon.textContent = 'content_copy';
                    icon.classList.remove('text-green-600');
                    icon.classList.add('text-zinc-450');
                }, 1500);
            }
        }).catch(err => {
            console.error('Failed to copy: ', err);
        });
    }

    function renderBookings() {
        const playingContainer = document.getElementById('list-playing');
        const waitingContainer = document.getElementById('list-waiting');
        const completedContainer = document.getElementById('list-completed');
        
        if (!playingContainer || !waitingContainer || !completedContainer) return;
        
        playingContainer.innerHTML = '';
        waitingContainer.innerHTML = '';
        completedContainer.innerHTML = '';
        
        // Filter by search query if any
        let list = localDanhSachLich || [];
        if (bookingSearchQuery) {
            list = list.filter(b => 
                (b.tenKhachHang && b.tenKhachHang.toLowerCase().includes(bookingSearchQuery)) ||
                (b.soDienThoai && b.soDienThoai.toLowerCase().includes(bookingSearchQuery)) ||
                (b.tenSan && b.tenSan.toLowerCase().includes(bookingSearchQuery))
            );
        }
        
        let countPlaying = 0;
        let countWaiting = 0;
        let countCompleted = 0;
        
        list.forEach(b => {
            const batDau = b.gioBatDau;
            const ketThuc = b.gioKetThuc;
            const formattedTongTien = formatCurrency(b.tongTien);
            const statusBadgeClass = b.trangThaiThanhToan === 'Đã thanh toán' ? 'badge-green' : 'badge-amber';
            const nguonBadgeClass = b.nguonDatSan === 'Walk-in' ? 'badge-gray' : 'badge-blue';
            
            // Determine booking status badge theme
            let statusTheme = 'badge-gray';
            if (b.trangThai === 'Đang sử dụng' || b.trangThai === 'Đang chơi') {
                statusTheme = 'badge-green';
            } else if (b.trangThai === 'Đã xác nhận') {
                statusTheme = 'badge-green';
            } else if (b.trangThai === 'Chờ xác nhận') {
                statusTheme = 'badge-amber';
            }
            
            const hasPhone = b.soDienThoai && b.soDienThoai.trim().length > 0;
            const phoneActionHtml = hasPhone ? `
                <div class="flex items-center gap-1 font-mono">
                    <a href="tel:\${b.soDienThoai}" class="hover:underline text-[#630ed4] font-bold">\${b.soDienThoai}</a>
                    <button type="button" onclick="copyToClipboard('\${b.soDienThoai}', this)" class="text-zinc-450 hover:text-[#630ed4] transition-colors p-0.5" title="Copy số điện thoại">
                        <span class="material-symbols-outlined text-[13px]">content_copy</span>
                    </button>
                </div>
            ` : '<span class="text-zinc-400">Không có SĐT</span>';

            const noteTooltipHtml = b.ghiChu ? `
                <div class="mt-2 pt-2 border-t border-zinc-100 flex items-start gap-1 text-[10px] text-zinc-555 italic" title="\${b.ghiChu}">
                    <span class="material-symbols-outlined text-[12px] text-zinc-400 shrink-0 mt-0.5">speaker_notes</span>
                    <span class="truncate max-w-full">\${b.ghiChu}</span>
                </div>
            ` : '';
            
            if (b.trangThai === 'Đang sử dụng' || b.trangThai === 'Đang chơi') {
                countPlaying++;
                playingContainer.insertAdjacentHTML('beforeend', `
                    <div class="border border-emerald-250 hover:border-emerald-350 bg-emerald-50/10 rounded-2xl p-4 flex flex-col justify-between shadow-sm transition-all duration-200 relative overflow-hidden group">
                        <div>
                            <div class="flex justify-between items-start mb-3">
                                <div>
                                    <div class="flex items-center gap-1.5 flex-wrap">
                                        <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse"></span>
                                        <h4 class="font-extrabold text-sm text-zinc-800">\${b.tenSan}</h4>
                                        <span class="text-[9px] font-semibold text-emerald-700 px-1.5 py-0.5 bg-emerald-50 rounded">\${b.tenLoaiSan || 'Sân bóng'}</span>
                                    </div>
                                    <div class="text-xs font-black text-zinc-650 mt-1 font-mono flex items-center gap-1">
                                        <span class="material-symbols-outlined text-[14px] text-zinc-450">schedule</span>
                                        \${batDau} - \${ketThuc}
                                    </div>
                                </div>
                                <div class="flex flex-col items-end gap-1 shrink-0">
                                    <span class="badge \${nguonBadgeClass} text-[8px] uppercase tracking-wider">\${b.nguonDatSan}</span>
                                    <span class="badge badge-green text-[8px] uppercase font-bold tracking-tight">ĐANG CHƠI</span>
                                </div>
                            </div>
                            
                            <div class="bg-white rounded-xl p-3 space-y-1.5 border border-zinc-150 text-xs mb-4">
                                <div class="flex items-center justify-between text-zinc-700 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Khách hàng:</span>
                                    <span class="font-extrabold text-zinc-900 flex items-center gap-1 truncate font-sans" title="\${b.tenKhachHang}">
                                        <span class="material-symbols-outlined text-[13px] text-zinc-400">person</span>
                                        \${b.tenKhachHang}
                                    </span>
                                </div>
                                <div class="flex items-center justify-between text-zinc-700 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Liên hệ:</span>
                                    \${phoneActionHtml}
                                </div>
                                <div class="flex items-center justify-between text-zinc-700 pt-1 border-t border-zinc-100 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Thanh toán:</span>
                                    <span class="badge \${statusBadgeClass} text-[9px]">\${b.trangThaiThanhToan}</span>
                                </div>
                            </div>
                            
                            <div class="flex items-center justify-between p-2.5 rounded-xl bg-emerald-50 border border-emerald-100 text-emerald-800 text-xs mb-4">
                                <span class="font-semibold flex items-center gap-1">
                                    <span class="material-symbols-outlined text-[14px]">play_circle</span>
                                    Thời gian:
                                </span>
                                <span class="font-black text-xs animate-pulse card-timer" data-start="\${b.gioBatDau}" data-end="\${b.gioKetThuc}" data-note="\${b.ghiChu}">-</span>
                            </div>
                            
                            \${noteTooltipHtml}
                        </div>
                        
                        <div class="mt-4 flex gap-2">
                            <button type="button" onclick="openStaffInvoiceModal(\${b.datSanId})" class="w-full \${themeBg} \${themeBgHover} text-white font-extrabold text-[11px] py-2.5 rounded-xl shadow-sm hover:shadow transition-all active:scale-95 flex items-center justify-center gap-1.5">
                                <span class="material-symbols-outlined text-[16px]">receipt_long</span>
                                Dịch vụ &amp; Thanh toán
                            </button>
                        </div>
                    </div>
                `);
            } else if (b.trangThai === 'Đã xác nhận' || b.trangThai === 'Chờ xác nhận') {
                countWaiting++;
                
                let checkinBtnText = "Mở sân";
                let checkinAction = "checkInPreBooked";
                
                waitingContainer.insertAdjacentHTML('beforeend', `
                    <div class="border border-zinc-200 hover:border-zinc-350 bg-white rounded-2xl p-4 flex flex-col justify-between shadow-sm transition-all duration-200 relative overflow-hidden group">
                        <div>
                            <div class="flex justify-between items-start mb-3">
                                <div>
                                    <div class="flex items-center gap-1.5 flex-wrap">
                                        <span class="w-2.5 h-2.5 rounded-full bg-amber-500 animate-pulse"></span>
                                        <h4 class="font-extrabold text-sm text-zinc-800">\${b.tenSan}</h4>
                                        <span class="text-[9px] font-semibold text-zinc-500 px-1.5 py-0.5 bg-zinc-100 rounded">\${b.tenLoaiSan || 'Sân bóng'}</span>
                                    </div>
                                    <div class="text-xs font-black text-zinc-650 mt-1 font-mono flex items-center gap-1">
                                        <span class="material-symbols-outlined text-[14px] text-zinc-450">schedule</span>
                                        \${batDau} - \${ketThuc}
                                    </div>
                                </div>
                                <div class="flex flex-col items-end gap-1 shrink-0">
                                    <span class="badge \${nguonBadgeClass} text-[8px] uppercase tracking-wider">\${b.nguonDatSan}</span>
                                    <span class="badge \${statusTheme} text-[8px] uppercase font-bold tracking-tight">\${b.trangThai === 'Chờ xác nhận' ? 'Chờ duyệt' : b.trangThai}</span>
                                </div>
                            </div>
                            
                            <div class="bg-zinc-50 rounded-xl p-3 space-y-1.5 border border-zinc-150 text-xs mb-4">
                                <div class="flex items-center justify-between text-zinc-700 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Khách hàng:</span>
                                    <span class="font-extrabold text-zinc-900 flex items-center gap-1 truncate font-sans" title="\${b.tenKhachHang}">
                                        <span class="material-symbols-outlined text-[13px] text-zinc-400">person</span>
                                        \${b.tenKhachHang}
                                    </span>
                                </div>
                                <div class="flex items-center justify-between text-zinc-700 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Liên hệ:</span>
                                    \${phoneActionHtml}
                                </div>
                                <div class="flex items-center justify-between text-zinc-700 pt-1 border-t border-zinc-100 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Thanh toán:</span>
                                    <span class="badge \${statusBadgeClass} text-[9px]">\${b.trangThaiThanhToan}</span>
                                </div>
                            </div>
                            
                            \${noteTooltipHtml}
                        </div>
                        
                        <div class="mt-4 flex gap-2">
                            <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="flex-1">
                                <input type="hidden" name="action" value="\${checkinAction}">
                                <input type="hidden" name="datSanId" value="\${b.datSanId}">
                                <input type="hidden" name="daThuTienMat" value="false">
                                <button type="submit" class="w-full \${themeBg} \${themeBgHover} text-white font-extrabold text-[11px] py-2.5 rounded-xl shadow-sm hover:shadow transition-all active:scale-95 flex items-center justify-center gap-1">
                                    <span class="material-symbols-outlined text-[14px]">power_settings_new</span>
                                    \${checkinBtnText}
                                </button>
                            </form>
                            <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="flex-none" onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch đặt này do khách bùng không?');">
                                <input type="hidden" name="action" value="cancelNoShow">
                                <input type="hidden" name="datSanId" value="\${b.datSanId}">
                                <button type="submit" class="bg-rose-50 hover:bg-rose-100 text-rose-600 font-extrabold text-[11px] px-3.5 py-2.5 rounded-xl transition-all active:scale-95 flex items-center justify-center" title="Hủy ca do khách không đến">
                                    <span class="material-symbols-outlined text-[16px]">cancel</span>
                                </button>
                            </form>
                        </div>
                    </div>
                `);
            } else {
                countCompleted++;
                completedContainer.insertAdjacentHTML('beforeend', `
                    <div class="border border-zinc-200 bg-zinc-50 opacity-80 hover:opacity-100 rounded-2xl p-4 flex flex-col justify-between shadow-sm transition-all duration-200 relative overflow-hidden group">
                        <div>
                            <div class="flex justify-between items-start mb-3">
                                <div>
                                    <div class="flex items-center gap-1.5 flex-wrap">
                                        <span class="w-2.5 h-2.5 rounded-full bg-zinc-400"></span>
                                        <h4 class="font-bold text-sm text-zinc-700">\${b.tenSan}</h4>
                                        <span class="text-[9px] font-semibold text-zinc-500 px-1.5 py-0.5 bg-zinc-100 rounded">\${b.tenLoaiSan || 'Sân bóng'}</span>
                                    </div>
                                    <div class="text-xs font-medium text-zinc-500 mt-1 font-mono flex items-center gap-1">
                                        <span class="material-symbols-outlined text-[14px] text-zinc-400">schedule</span>
                                        \${batDau} - \${ketThuc}
                                    </div>
                                </div>
                                <div class="flex flex-col items-end gap-1 shrink-0">
                                    <span class="badge \${nguonBadgeClass} text-[8px] uppercase tracking-wider">\${b.nguonDatSan}</span>
                                    <span class="badge badge-gray text-[8px] uppercase font-bold tracking-tight">\${b.trangThai}</span>
                                </div>
                            </div>
                            
                            <div class="bg-white rounded-xl p-3 space-y-1.5 border border-zinc-150 text-xs mb-4">
                                <div class="flex items-center justify-between text-zinc-700 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Khách hàng:</span>
                                    <span class="font-bold text-zinc-800 flex items-center gap-1 truncate font-sans" title="\${b.tenKhachHang}">
                                        <span class="material-symbols-outlined text-[13px] text-zinc-400">person</span>
                                        \${b.tenKhachHang}
                                    </span>
                                </div>
                                <div class="flex items-center justify-between text-zinc-700 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Liên hệ:</span>
                                    <span class="font-medium text-zinc-700 font-mono">\${b.soDienThoai || '---'}</span>
                                </div>
                                <div class="flex items-center justify-between text-zinc-700 pt-1 border-t border-zinc-100 gap-2">
                                    <span class="text-zinc-400 font-medium shrink-0">Tổng tiền sân:</span>
                                    <span class="font-extrabold text-zinc-900">\${formattedTongTien}</span>
                                </div>
                            </div>
                            
                            \${noteTooltipHtml}
                        </div>
                        
                        <div class="flex items-center justify-between p-2 rounded-xl bg-zinc-100 border border-zinc-200 text-zinc-600 text-[10px]">
                            <span class="font-medium">Trạng thái HĐ:</span>
                            <span class="font-bold uppercase \${b.trangThaiThanhToan === 'Đã thanh toán' ? 'text-emerald-700' : 'text-amber-700'}">\${b.trangThaiThanhToan}</span>
                        </div>
                    </div>
                `);
            }
        });
        
        // Show empty states if counters are 0
        if (countPlaying === 0) {
            playingContainer.innerHTML = `
                <div class="col-span-full py-12 text-center text-xs text-zinc-450 italic bg-zinc-50 rounded-2xl border border-dashed border-zinc-200 flex flex-col items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[32px] text-zinc-300">sports_soccer</span>
                    Hiện chưa có ca chơi nào đang hoạt động.
                </div>
            `;
        }
        if (countWaiting === 0) {
            waitingContainer.innerHTML = `
                <div class="col-span-full py-12 text-center text-xs text-zinc-450 italic bg-zinc-50 rounded-2xl border border-dashed border-zinc-200 flex flex-col items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[32px] text-zinc-300">schedule</span>
                    Không có lịch chờ check-in nào trong ngày hôm nay.
                </div>
            `;
        }
        if (countCompleted === 0) {
            completedContainer.innerHTML = `
                <div class="col-span-full py-12 text-center text-xs text-zinc-450 italic bg-zinc-50 rounded-2xl border border-dashed border-zinc-200 flex flex-col items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[32px] text-zinc-300">check_circle</span>
                    Chưa ghi nhận ca chơi hoàn thành nào hôm nay.
                </div>
            `;
        }
        
        // Update badge counts on tabs
        document.getElementById('badge-count-playing').textContent = countPlaying;
        document.getElementById('badge-count-waiting').textContent = countWaiting;
        document.getElementById('badge-count-completed').textContent = countCompleted;
        
        // Auto-select active tab on initial render
        if (activeBookingTab === null) {
            const hasPlaying = localDanhSachLich.some(b => b.trangThai === 'Đang sử dụng' || b.trangThai === 'Đang chơi');
            switchBookingTab(hasPlaying ? 'playing' : 'waiting');
        } else {
            switchBookingTab(activeBookingTab);
        }
    }

    // Convert time string "HH:MM" or "HH:MM:SS" to a Date object today
    function parseTimeToDate(timeStr) {
        if (!timeStr) return null;
        const parts = timeStr.split(':');
        if (parts.length < 2) return null;
        const d = new Date();
        d.setHours(parseInt(parts[0], 10), parseInt(parts[1], 10), 0, 0);
        return d;
    }

    // Get correct start and end Date objects, handling potential overnight wrap-around
    function getTimerDates(startStr, endStr) {
        const startDate = parseTimeToDate(startStr);
        let endDate = parseTimeToDate(endStr);
        if (startDate && endDate && endDate < startDate) {
            // End time is on the next day
            endDate.setDate(endDate.getDate() + 1);
        }
        return { startDate, endDate };
    }

    // Format millisecond duration into HH:MM:SS
    function formatDuration(ms) {
        const totalSecs = Math.max(0, Math.floor(ms / 1000));
        const hrs = Math.floor(totalSecs / 3600);
        const mins = Math.floor((totalSecs % 3600) / 60);
        const secs = totalSecs % 60;
        
        const pad = (num) => String(num).padStart(2, '0');
        return pad(hrs) + ':' + pad(mins) + ':' + pad(secs);
    }

    // Update all card timers in the court grid
    function updateAllCardTimers() {
        const timers = document.querySelectorAll('.card-timer');
        const now = new Date();
        
        timers.forEach(timer => {
            const startStr = timer.getAttribute('data-start');
            const endStr = timer.getAttribute('data-end');
            const noteStr = timer.getAttribute('data-note') || '';
            if (!startStr) return;
            
            const isOpenMode = noteStr.includes('Không cố định');
            const { startDate, endDate } = getTimerDates(startStr, endStr);
            
            if (isOpenMode) {
                // Count up timer
                if (startDate) {
                    let elapsedMs = now - startDate;
                    if (elapsedMs < 0) elapsedMs += 24 * 60 * 60 * 1000;
                    timer.textContent = "Đã chơi: " + formatDuration(elapsedMs);
                    timer.className = "card-timer font-black text-emerald-650 animate-pulse";
                }
            } else {
                // Countdown timer
                if (startDate && endDate) {
                    if (now < startDate) {
                        timer.textContent = "Chờ bắt đầu";
                        timer.className = "card-timer font-bold text-zinc-500";
                    } else if (now >= endDate) {
                        timer.textContent = "Hết giờ chơi";
                        timer.className = "card-timer font-black text-rose-600 animate-bounce";
                    } else {
                        const remainingMs = endDate - now;
                        timer.textContent = "Còn lại: " + formatDuration(remainingMs);
                        
                        // Change style dynamically based on remaining time
                        const remainingMins = remainingMs / 60000;
                        if (remainingMins <= 15) {
                            timer.className = "card-timer font-black text-rose-600 animate-pulse";
                        } else {
                            timer.className = "card-timer font-bold " + themeText;
                        }
                    }
                }
            }
        });
    }

    // Start timer loop for the side drawer
    function startDrawerTimerLoop(startDate, endDate, isOpenMode, ratePerHour, baseCourtPrice) {
        if (drawerTimerInterval) {
            clearInterval(drawerTimerInterval);
        }
        
        const timerValEl = document.getElementById('drawer-active-timer-val');
        const timerRowEl = document.getElementById('drawer-active-timer-row');
        const timerLabelEl = document.getElementById('drawer-active-timer-label');
        const totalPriceEl = document.getElementById('drawer-active-total-price');
        
        function update() {
            const now = new Date();
            if (isOpenMode) {
                // Count-up mode
                if (startDate) {
                    let elapsedMs = now - startDate;
                    if (elapsedMs < 0) elapsedMs += 24 * 60 * 60 * 1000;
                    
                    if (timerValEl) timerValEl.textContent = formatDuration(elapsedMs);
                    if (timerLabelEl) timerLabelEl.textContent = "Đang đếm tới:";
                    
                    // Styling
                    if (timerRowEl) {
                        timerRowEl.className = "flex justify-between p-2.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800";
                    }
                    if (timerValEl) {
                        timerValEl.className = "font-black text-sm text-emerald-700 animate-pulse";
                    }
                    
                    // Real-time calculation of accrued price
                    const elapsedHours = (elapsedMs / 1000) / 3600.0;
                    const accruedPrice = elapsedHours * ratePerHour;
                    if (totalPriceEl) totalPriceEl.textContent = formatCurrency(accruedPrice);
                }
            } else {
                // Countdown mode
                if (startDate && endDate) {
                    if (now < startDate) {
                        if (timerValEl) timerValEl.textContent = "Chờ bắt đầu";
                        if (timerLabelEl) timerLabelEl.textContent = "Trạng thái:";
                        if (timerRowEl) timerRowEl.className = "flex justify-between p-2.5 rounded-xl bg-zinc-50 border border-zinc-200 text-zinc-800";
                        if (timerValEl) timerValEl.className = "font-bold text-sm text-zinc-650";
                        if (totalPriceEl) totalPriceEl.textContent = formatCurrency(baseCourtPrice);
                    } else if (now >= endDate) {
                        if (timerValEl) timerValEl.textContent = "Hết giờ chơi";
                        if (timerLabelEl) timerLabelEl.textContent = "Thời gian:";
                        if (timerRowEl) timerRowEl.className = "flex justify-between p-2.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 animate-pulse";
                        if (timerValEl) timerValEl.className = "font-black text-sm text-rose-700";
                        if (totalPriceEl) totalPriceEl.textContent = formatCurrency(baseCourtPrice);
                    } else {
                        const remainingMs = endDate - now;
                        if (timerValEl) timerValEl.textContent = formatDuration(remainingMs);
                        if (timerLabelEl) timerLabelEl.textContent = "Đếm ngược:";
                        
                        const remainingMins = remainingMs / 60000;
                        if (remainingMins <= 15) {
                            if (timerRowEl) timerRowEl.className = "flex justify-between p-2.5 rounded-xl bg-rose-50 border border-rose-200 text-rose-800 animate-pulse";
                            if (timerValEl) timerValEl.className = "font-black text-sm text-rose-700";
                        } else {
                            if (timerRowEl) timerRowEl.className = `flex justify-between p-2.5 rounded-xl ${themeBgLight} border ${themeBorderStrong} ${themeTextMedium}`;
                            if (timerValEl) timerValEl.className = `font-black text-sm ${themeTextMedium}`;
                        }
                        if (totalPriceEl) totalPriceEl.textContent = formatCurrency(baseCourtPrice);
                    }
                }
            }
        }
        
        update();
        drawerTimerInterval = setInterval(update, 1000);
    }
    
    // Auto start grid timers and render bookings
    document.addEventListener("DOMContentLoaded", () => {
        renderBookings();
        updateAllCardTimers();
        setInterval(updateAllCardTimers, 1000);
    });

    // Responsive Mobile Menu handler
    const mobileMenuBtn = document.getElementById('mobileMenuBtn');
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', () => {
            const sidebar = document.querySelector('aside');
            if (sidebar) {
                sidebar.classList.toggle('-translate-x-full');
            }
        });
    }

    async function pollUpdates() {
        try {
            const response = await fetch('${pageContext.request.contextPath}/staff/checkin?ajax=true');
            if (!response.ok) return;
            const data = await response.json();
            
            if (data.danhSachLich) {
                localDanhSachLich = data.danhSachLich;
            }
            
            // Update dynamic stats counters
            if (data.danhSachSan) {
                let total = data.danhSachSan.length;
                let avail = 0, inUse = 0, maint = 0, closed = 0;
                data.danhSachSan.forEach(s => {
                    if (s.trangThai === 'Sẵn sàng') avail++;
                    else if (s.trangThai === 'Đang sử dụng') inUse++;
                    else if (s.trangThai === 'Bảo trì') maint++;
                    else closed++;
                });
                if(document.getElementById('stat-total')) document.getElementById('stat-total').textContent = total;
                if(document.getElementById('stat-available')) document.getElementById('stat-available').textContent = avail;
                if(document.getElementById('stat-in-use')) document.getElementById('stat-in-use').textContent = inUse;
                if(document.getElementById('stat-maintenance')) document.getElementById('stat-maintenance').textContent = maint;
                if(document.getElementById('stat-closed')) document.getElementById('stat-closed').textContent = closed;
            }
            if (data.danhSachLich && document.getElementById('stat-today')) {
                document.getElementById('stat-today').textContent = data.danhSachLich.length;
            }
            
            // 1. Cập nhật Real-time Field Status Grid
            const fieldGrid = document.getElementById('field-status-grid');
            if (fieldGrid && data.danhSachSan) {
                let htmlGrid = '';
                data.danhSachSan.forEach(san => {
                    const tenLoaiSan = san.tenLoaiSan || '';
                    const gioBatDauLenDenStr = san.gioBatDauLenDen || '';
                    const gioKetThucLenDenStr = san.gioKetThucLenDen || '';
                    
                    if (san.trangThai === 'Đang sử dụng') {
                        let stopButtonHtml = '';
                        if (san.ghiChuActive && san.ghiChuActive.includes('Không cố định') && !san.ghiChuActive.includes('Đã chốt giờ thực tế')) {
                            stopButtonHtml = `
                                <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="w-full mt-2" onsubmit="return confirm('Bạn có chắc chắn muốn dừng chơi và chốt giờ thực tế cho ca này?');">
                                    <input type="hidden" name="action" value="stopOpenSession">
                                    <input type="hidden" name="datSanId" value="\${san.datSanIdActive}">
                                    <button type="submit" class="w-full bg-red-550 hover:bg-red-700 text-white font-extrabold text-[10px] py-2 rounded-xl shadow-sm hover:shadow transition-all active:scale-95 flex items-center justify-center gap-1">
                                        <span class="material-symbols-outlined text-[12px]">stop_circle</span>
                                        Dừng chơi & Tính tiền
                                    </button>
                                </form>
                            `;
                        }
                        htmlGrid += `
                            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 cursor-pointer card-hover hover:border-zinc-300 border-${isManager ? 'purple-300' : 'orange-300'} shadow-md"
                                 data-sanid="\${san.sanID}"
                                 data-tensan="\${san.tenSan}"
                                 data-loaisan="\${tenLoaiSan}"
                                 data-trangthai="\${san.trangThai}"
                                 data-mota="\${san.moTa || ''}"
                                 data-giakhongden="\${san.giaKhongDen}"
                                 data-giacoden="\${san.giaCoDen}"
                                 data-giobatdaulenden="\${gioBatDauLenDenStr}"
                                 data-giokethuclenden="\${gioKetThucLenDenStr}"
                                 data-datsanidactive="\${san.datSanIdActive}"
                                 data-giobatdauactive="\${san.gioBatDauActive}"
                                 data-giokethucactive="\${san.gioKetThucActive || ''}"
                                 data-ghichuactive="\${san.ghiChuActive || ''}"
                                 onclick="onCardClick(event, this)">
                                <div class="w-full flex flex-col items-center">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full ${isManager ? 'bg-purple-500' : 'bg-orange-500'} live-dot"></span>
                                    <div class="w-12 h-12 rounded-2xl ${isManager ? 'bg-purple-50' : 'bg-orange-50'} flex items-center justify-center ${themeIcon} mb-2 shadow-inner">
                                        <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-800">\${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">\${tenLoaiSan}</p>
                                    <span class="badge ${badgeTheme} mt-2 uppercase text-[10px]">Đang sử dụng</span>
                                    <p class="text-[10px] text-zinc-500 mt-1 flex items-center justify-center gap-1">
                                        <span class="material-symbols-outlined text-[12px]">schedule</span>
                                        <span class="card-timer font-bold text-zinc-700" 
                                              data-start="\${san.gioBatDauActive || ''}" 
                                              data-end="\${san.gioKetThucActive || ''}" 
                                              data-note="\${san.ghiChuActive || ''}">Bắt đầu: \${san.gioBatDauActive || ''}</span>
                                    </p>
                                    
                                    \${stopButtonHtml}
                                    <button type="button" onclick="openStaffInvoiceModal(\${san.datSanIdActive})" class="w-full mt-3 \${themeBg} \${themeBgHover} text-white font-extrabold text-[10px] py-2 rounded-xl shadow-sm hover:shadow transition-all active:scale-95">
                                        Dịch vụ & Thanh toán
                                    </button>
                                </div>
                            </div>
                        `;
                    } else if (san.trangThai === 'Sẵn sàng') {
                        htmlGrid += `
                            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 cursor-pointer card-hover hover:border-zinc-300"
                                 data-sanid="\${san.sanID}"
                                 data-tensan="\${san.tenSan}"
                                 data-loaisan="\${tenLoaiSan}"
                                 data-trangthai="\${san.trangThai}"
                                 data-mota="\${san.moTa || ''}"
                                 data-giakhongden="\${san.giaKhongDen}"
                                 data-giacoden="\${san.giaCoDen}"
                                 data-giobatdaulenden="\${gioBatDauLenDenStr}"
                                 data-giokethuclenden="\${gioKetThucLenDenStr}"
                                 data-datsanidactive="\${san.datSanIdActive}"
                                 data-giobatdauactive="\${san.gioBatDauActive}"
                                 onclick="onCardClick(event, this)">
                                <div class="w-full flex flex-col items-center">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-green-500"></span>
                                    <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center text-green-600 mb-2">
                                        <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-800">\${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">\${tenLoaiSan}</p>
                                    <span class="badge badge-green mt-2 uppercase text-[10px]">Sẵn sàng</span>
                                    
                                    <button type="button" onclick="toggleCardCollapse(event, \${san.sanID})" class="w-full mt-3 ${themeBg} ${themeBgHover} text-white font-extrabold text-[10px] py-2 rounded-xl shadow-sm hover:shadow transition-all active:scale-95">
                                        Mở sân
                                    </button>

                                    <!-- Collapsible walk-in form inline -->
                                    <div id="collapse-walkin-\${san.sanID}" class="hidden w-full mt-3 pt-3 border-t border-zinc-150 text-left space-y-3" onclick="event.stopPropagation()">
                                        <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="space-y-3">
                                            <input type="hidden" name="action" value="checkInWalkIn">
                                            <input type="hidden" name="sanId" value="\${san.sanID}">
                                            <input type="hidden" id="card-walkin-duration-\${san.sanID}" name="duration" value="120">
                                            
                                            <!-- Prebooked list if any -->
                                            <div id="card-prebooked-section-\${san.sanID}" class="hidden space-y-1">
                                                <label class="block text-[9px] font-black \${themeText} uppercase tracking-wider">Khách đặt trước hôm nay:</label>
                                                <div id="card-prebooked-list-\${san.sanID}" class="space-y-1"></div>
                                            </div>

                                            <div class="space-y-1">
                                                <label class="block text-[9px] font-black text-zinc-500 uppercase tracking-wider">Kiểu giờ chơi:</label>
                                                <div class="grid grid-cols-2 gap-1">
                                                    <label id="card-mode-fixed-label-\${san.sanID}" class="border \${themeBorderStrong} \${themeBgLight} rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold \${themeTextMedium} transition-all text-center">
                                                        <input type="radio" class="sr-only" name="playMode" value="FIXED" checked onchange="setCardPlayMode(\${san.sanID}, 'FIXED')">
                                                        Cố định
                                                    </label>
                                                    <label id="card-mode-open-label-\${san.sanID}" class="border border-zinc-150 rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold text-zinc-700 hover:border-zinc-300 transition-all text-center">
                                                        <input type="radio" class="sr-only" name="playMode" value="OPEN" onchange="setCardPlayMode(\${san.sanID}, 'OPEN')">
                                                        Không cố định
                                                    </label>
                                                </div>
                                            </div>

                                            <div id="card-fixed-panel-\${san.sanID}" class="space-y-1">
                                                <label class="block text-[9px] font-black text-zinc-500 uppercase tracking-wider">Mốc giờ chơi:</label>
                                                <div class="grid grid-cols-3 gap-1 mb-1">
                                                    <button type="button" data-card-duration-btn="\${san.sanID}-60" onclick="setCardDuration(\${san.sanID}, 60)" class="card-duration-btn-\${san.sanID} py-1 rounded border border-zinc-200 text-[8px] font-extrabold text-zinc-700 hover:bg-zinc-50">60p</button>
                                                    <button type="button" data-card-duration-btn="\${san.sanID}-120" onclick="setCardDuration(\${san.sanID}, 120)" class="card-duration-btn-\${san.sanID} py-1 rounded border \${themeBorderStrong} \${themeBgLight} text-[8px] font-extrabold \${themeTextMedium}">2h</button>
                                                    <button type="button" data-card-duration-btn="\${san.sanID}-180" onclick="setCardDuration(\${san.sanID}, 180)" class="card-duration-btn-\${san.sanID} py-1 rounded border border-zinc-200 text-[8px] font-extrabold text-zinc-700 hover:bg-zinc-50">3h</button>
                                                </div>
                                                <select name="duration_select" onchange="setCardSelectDuration(\${san.sanID}, this.value)" class="w-full text-[9px] p-1 border border-zinc-200 rounded bg-white focus:outline-none">
                                                    <option value="60">60 phút (1 giờ)</option>
                                                    <option value="90">90 phút (1.5 giờ)</option>
                                                    <option value="120" selected>120 phút (2 giờ)</option>
                                                    <option value="150">150 phút (2.5 giờ)</option>
                                                    <option value="180">180 phút (3 giờ)</option>
                                                </select>
                                            </div>

                                            <div id="card-open-note-\${san.sanID}" class="hidden p-1.5 rounded border \${themeBorder} \${themeBgLight} text-[8px] \${themeTextMedium} font-semibold leading-tight">
                                                Tính tiền thực tế khi trả sân.
                                            </div>

                                            <div class="space-y-1">
                                                <label class="block text-[9px] font-black text-zinc-500 uppercase tracking-wider">Đơn giá (VND/h):</label>
                                                <input type="number" id="card-rate-\${san.sanID}" name="donGia" step="10000" class="w-full text-[10px] p-1 border border-zinc-150 rounded bg-zinc-50 cursor-not-allowed focus:outline-none" required readonly oninput="calculateCardPrice(\${san.sanID})">
                                                <span id="card-rate-type-\${san.sanID}" class="text-[8px] text-zinc-450 block italic"></span>
                                            </div>

                                            <div class="p-1.5 bg-zinc-50 rounded border border-zinc-150 flex items-center justify-between text-[9px]">
                                                <span class="text-zinc-550 font-bold">Tạm tính:</span>
                                                <span id="card-subtotal-val-\${san.sanID}" class="font-extrabold text-[10px] ${themeTextMedium}">0đ</span>
                                            </div>

                                            <button type="submit" class="w-full \${themeBg} \${themeBgHover} text-white font-extrabold text-[9px] py-1.5 rounded-lg shadow-sm hover:shadow active:scale-95 transition-all flex items-center justify-center gap-1">
                                                <span class="material-symbols-outlined text-[10px]">play_circle</span>
                                                Mở sân ngay
                                            </button>
                                        </form>
                                    </div>
                        `;
                    } else if (san.trangThai === 'Bảo trì') {
                        htmlGrid += `
                            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 border-amber-200 bg-amber-50/20 cursor-pointer card-hover hover:border-zinc-300"
                                 data-sanid="\${san.sanID}"
                                 data-tensan="\${san.tenSan}"
                                 data-loaisan="\${tenLoaiSan}"
                                 data-trangthai="\${san.trangThai}"
                                 data-mota="\${san.moTa || ''}"
                                 data-giakhongden="\${san.giaKhongDen}"
                                 data-giacoden="\${san.giaCoDen}"
                                 data-giobatdaulenden="\${gioBatDauLenDenStr}"
                                 data-giokethuclenden="\${gioKetThucLenDenStr}"
                                 data-datsanidactive="\${san.datSanIdActive}"
                                 data-giobatdauactive="\${san.gioBatDauActive}"
                                 onclick="onCardClick(event, this)">
                                <div class="w-full flex flex-col items-center">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-amber-500"></span>
                                    <div class="w-12 h-12 rounded-2xl bg-amber-50 flex items-center justify-center text-amber-600 mb-2">
                                        <span class="material-symbols-outlined text-[24px]">build</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-850 opacity-60">\${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">\${tenLoaiSan}</p>
                                    <span class="badge badge-amber mt-2 uppercase text-[10px]">Bảo trì</span>
                                    
                                    <button type="button" onclick="openCourtDetailDrawer(\${san.sanID})" class="w-full mt-3 bg-zinc-150 text-zinc-600 hover:bg-zinc-200 transition-colors font-extrabold text-[10px] py-2 rounded-xl">
                                        Chi tiết
                                    </button>
                                </div>
                            </div>
                        `;
                    } else {
                        htmlGrid += `
                            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 border-red-200 bg-red-50/20 cursor-pointer card-hover hover:border-zinc-300"
                                 data-sanid="\${san.sanID}"
                                 data-tensan="\${san.tenSan}"
                                 data-loaisan="\${tenLoaiSan}"
                                 data-trangthai="\${san.trangThai}"
                                 data-mota="\${san.moTa || ''}"
                                 data-giakhongden="\${san.giaKhongDen}"
                                 data-giacoden="\${san.giaCoDen}"
                                 data-giobatdaulenden="\${gioBatDauLenDenStr}"
                                 data-giokethuclenden="\${gioKetThucLenDenStr}"
                                 data-datsanidactive="\${san.datSanIdActive}"
                                 data-giobatdauactive="\${san.gioBatDauActive}"
                                 onclick="onCardClick(event, this)">
                                <div class="w-full flex flex-col items-center">
                                    <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-red-500"></span>
                                    <div class="w-12 h-12 rounded-2xl bg-red-50 flex items-center justify-center text-red-655 mb-2">
                                        <span class="material-symbols-outlined text-[24px]">block</span>
                                    </div>
                                    <h4 class="font-bold text-sm text-zinc-850 opacity-60">\${san.tenSan}</h4>
                                    <p class="text-[10px] text-zinc-500 font-medium">\${tenLoaiSan}</p>
                                    <span class="badge badge-red mt-2 uppercase text-[10px]">Tạm đóng</span>
                                    
                                    <button type="button" onclick="openCourtDetailDrawer(\${san.sanID})" class="w-full mt-3 bg-zinc-150 text-zinc-600 hover:bg-zinc-200 transition-colors font-extrabold text-[10px] py-2 rounded-xl">
                                        Chi tiết
                                    </button>
                                </div>
                            </div>
                        `;
                    }
                });
                fieldGrid.innerHTML = htmlGrid;
            }
            

            // 3. Cập nhật Today's Bookings Layout
            if (data.danhSachLich) {
                renderBookings();
            }
            
            // Refresh grid card timers immediately
            updateAllCardTimers();

            // Refresh Open Side Drawer details if open
            if (activeDrawerSanId !== null) {
                openCourtDetailDrawer(activeDrawerSanId);
            }
        } catch (err) {
            console.error('Lỗi khi cập nhật trạng thái sân tự động:', err);
        }
    }

    // Chạy cập nhật ngay khi tải trang và thiết lập chu kỳ 30 giây
    setInterval(pollUpdates, 30000);
</script>

<!-- STAFF INVOICE & SERVICE MODAL -->
<div id="staffInvoiceModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 p-2 sm:p-4">
    <div class="bg-white w-full max-w-[1400px] rounded-lg sm:rounded-xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative flex flex-col" style="max-height: 96vh;">

        <!-- Header -->
        <header class="bg-[#f8f9ff] border-b border-[#ccc3d8] flex justify-between items-center px-4 lg:px-8 py-3 lg:py-4 shrink-0">
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-lg bg-[#e5eeff] flex items-center justify-center ${isManager ? 'text-purple-700' : 'text-orange-600'}">
                    <span class="material-symbols-outlined">receipt_long</span>
                </div>
                <div>
                    <h1 class="text-xl font-bold text-[#0b1c30]">Thanh toán &amp; Quản lý Dịch vụ</h1>
                    <p class="text-xs text-[#5d5d67]">Chọn dịch vụ · Xác nhận thanh toán · In hóa đơn</p>
                </div>
            </div>
            <button onclick="closeStaffInvoiceModal()" class="w-10 h-10 flex items-center justify-center rounded-full hover:bg-[#dce9ff] transition-colors text-[#5d5d67]">
                <span class="material-symbols-outlined">close</span>
            </button>
        </header>

        <!-- Flex body: loading + content -->
        <div class="flex-1 min-h-0 overflow-hidden flex flex-col">

            <!-- Loading state -->
            <div id="staff-invoice-loading" class="flex-1 flex flex-col items-center justify-center text-zinc-500">
                <span class="material-symbols-outlined animate-spin text-[32px] ${themeIcon} mb-2">sync</span>
                <p class="text-sm font-medium">Đang tải chi tiết hóa đơn...</p>
            </div>

            <!-- Main 3-column content -->
            <div id="staff-invoice-content" class="hidden flex-1 min-h-0 bg-[#f8f9ff] p-3 lg:p-6 gap-3 lg:gap-6 animate-fadeUp flex flex-col lg:flex-row overflow-y-auto lg:overflow-hidden">

                <!-- Section 1: Dịch vụ đi kèm / Nước uống -->
                <section class="flex-none lg:flex-1 min-w-0 bg-white rounded-xl border border-[#ccc3d8] p-4 lg:p-6 flex flex-col lg:min-h-0">
                    <div class="mb-4 shrink-0">
                        <div class="flex items-center gap-2 mb-1">
                            <span class="material-symbols-outlined text-[#5d5d67] text-sm">shopping_cart</span>
                            <h2 class="text-base font-bold uppercase text-[#0b1c30]">DỊCH VỤ ĐI KÈM / NƯỚC UỐNG</h2>
                        </div>
                        <p class="text-sm text-[#5d5d67]">Chọn sản phẩm từ kho dịch vụ để thêm vào hóa đơn.</p>
                    </div>
                    <!-- Category Filter Tabs -->
                    <div class="flex flex-wrap gap-2 mb-4 shrink-0">
                        <button type="button" onclick="filterStaffCatalog('all', this)" class="pos-tab active"><span class="material-symbols-outlined text-[15px]">apps</span> Tất cả</button>
                        <button type="button" onclick="filterStaffCatalog('drinks', this)" class="pos-tab"><span class="material-symbols-outlined text-[15px]">local_cafe</span> Đồ uống</button>
                        <button type="button" onclick="filterStaffCatalog('rentals', this)" class="pos-tab"><span class="material-symbols-outlined text-[15px]">sports_tennis</span> Thuê dụng cụ</button>
                        <button type="button" onclick="filterStaffCatalog('others', this)" class="pos-tab"><span class="material-symbols-outlined text-[15px]">more_horiz</span> Khác</button>
                    </div>
                    <!-- Search Bar -->
                    <div class="relative mb-4 shrink-0">
                        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <span class="material-symbols-outlined text-[#7b7487] text-[20px]">search</span>
                        </div>
                        <input type="text" id="staff-catalog-search" oninput="searchStaffCatalog(this.value)" placeholder="Tìm nhanh dịch vụ, nước uống..." class="w-full text-sm pl-10 pr-4 py-3 rounded-lg border border-[#ccc3d8] bg-white focus:outline-none focus:border-[#630ed4] focus:ring-1 focus:ring-[#630ed4] transition-all text-[#0b1c30] placeholder-[#5d5d67]">
                    </div>
                    <!-- Product Grid -->
                    <div id="staff-product-catalog" class="max-h-[240px] lg:max-h-none lg:flex-1 overflow-y-auto grid grid-cols-2 auto-rows-max gap-3 pr-1 lg:min-h-0 content-start">
                        <!-- Populated dynamically via JS -->
                    </div>
                    <!-- Hidden inputs for backward compatibility -->
                    <select id="staff-product-select" class="hidden"></select>
                    <input type="number" id="staff-product-qty" class="hidden" value="1">
                    <button type="button" id="staff-add-service-btn" class="hidden"></button>
                </section>

                <!-- Section 2: Sản phẩm đã chọn -->
                <section class="flex-none lg:flex-1 min-w-0 bg-white rounded-xl border border-[#ccc3d8] p-4 lg:p-6 flex flex-col lg:min-h-0">
                    <div class="flex justify-between items-center border-b border-[#ccc3d8] pb-4 mb-4 shrink-0">
                        <div class="flex items-center gap-2">
                            <span class="material-symbols-outlined text-[#5d5d67] text-sm">shopping_bag</span>
                            <h2 class="text-sm font-bold uppercase text-[#0b1c30]">SẢN PHẨM ĐÃ CHỌN</h2>
                        </div>
                        <div class="flex items-center gap-3">
                            <span class="text-[10px] text-[#5d5d67] font-medium uppercase">DANH SÁCH GIỎ HÀNG</span>
                            <span class="text-xs font-semibold text-[#0b1c30]" id="staff-cart-item-count">0 mặt hàng</span>
                        </div>
                    </div>
                    <!-- Cart items list -->
                    <div id="staff-cart-list" class="max-h-[200px] lg:max-h-none lg:flex-1 overflow-y-auto pr-1 space-y-1 lg:min-h-0">
                        <!-- Populated dynamically via JS -->
                    </div>
                    <!-- Cart subtotal -->
                    <div class="mt-4 pt-4 border-t border-[#ccc3d8] flex justify-between items-center shrink-0">
                        <span class="text-[10px] text-[#5d5d67] font-medium uppercase">TỔNG TIỀN DỊCH VỤ:</span>
                        <span class="text-base font-bold text-[#0b1c30]" id="staff-cart-subtotal">0 đ</span>
                    </div>
                </section>

                <!-- Section 3: Right Sidebar -->
                <section class="w-full lg:w-[340px] lg:shrink-0 flex flex-col gap-4 lg:overflow-y-auto lg:min-h-0 pr-1">

                    <!-- Court Info Card -->
                    <div class="bg-white rounded-xl border border-[#ccc3d8] p-5 shrink-0">
                        <div class="flex items-start gap-4 mb-4">
                            <div class="w-10 h-10 rounded-full bg-[#e5eeff] flex items-center justify-center text-[#5d5d67] shrink-0">
                                <span class="material-symbols-outlined">sports_soccer</span>
                            </div>
                            <div>
                                <p class="text-xs ${isManager ? 'text-purple-700' : 'text-orange-600'} uppercase font-medium mb-1">THÔNG TIN CA ĐẤU</p>
                                <h3 class="text-base font-bold text-[#0b1c30]" id="staff-invoice-court-name">Tên sân</h3>
                                <p class="text-sm text-[#5d5d67]" id="staff-invoice-time-slot">00:00 - 00:00 (01/01/2026)</p>
                            </div>
                        </div>
                        <div class="flex justify-between items-center pt-4 border-t border-[#ccc3d8]">
                            <span class="text-xs text-[#5d5d67] uppercase font-medium">TRẠNG THÁI:</span>
                            <span class="badge badge-amber" id="staff-invoice-payment-status">Chưa thanh toán</span>
                        </div>
                    </div>

                    <!-- Price Details Card -->
                    <div class="bg-white rounded-xl border border-[#ccc3d8] p-5 shrink-0">
                        <div class="flex items-center gap-2 mb-4">
                            <span class="material-symbols-outlined text-[#5d5d67] text-[18px]">schedule</span>
                            <h4 class="text-xs text-[#5d5d67] uppercase font-medium">CHI TIẾT TIỀN SÂN</h4>
                        </div>
                        <div class="space-y-3 text-sm">
                            <div class="flex justify-between">
                                <span class="text-[#5d5d67]">Đơn giá sân:</span>
                                <span class="font-semibold text-[#0b1c30]" id="staff-detail-court-rate">0 đ/giờ</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-[#5d5d67]">Giờ bắt đầu:</span>
                                <span class="font-semibold text-[#0b1c30]" id="staff-detail-start-time">00:00</span>
                            </div>
                            <div class="flex justify-between">
                                <span class="text-[#5d5d67]">Giờ kết thúc:</span>
                                <span class="font-semibold text-[#0b1c30]" id="staff-detail-end-time">00:00</span>
                            </div>
                            <div id="staff-detail-early-container" class="flex justify-between text-amber-700 hidden">
                                <span>Phụ thu nhận sớm:</span>
                                <span class="font-bold" id="staff-detail-early-surcharge">0 đ</span>
                            </div>
                            <div id="staff-detail-late-container" class="flex justify-between text-red-600 hidden">
                                <span>Phụ thu quá giờ (<span id="staff-detail-late-minutes">0</span> phút):</span>
                                <span class="font-bold" id="staff-detail-late-surcharge">0 đ</span>
                            </div>
                        </div>
                    </div>

                    <!-- Bill Types -->
                    <div id="bill-mode-section" class="shrink-0">
                        <h4 class="text-xs text-[#0b1c30] uppercase font-semibold mb-3">LOẠI BILL DỊCH VỤ</h4>
                        <div class="space-y-2">
                            <div id="lbl-billmode-main" class="bill-mode-card active" onclick="setBillMode('MAIN')">
                                <input type="radio" name="billModeRadio" value="MAIN" checked class="hidden">
                                <span class="material-symbols-outlined text-[18px] text-[#5d5d67] shrink-0 mt-0.5">merge</span>
                                <div class="min-w-0 flex-1">
                                    <p class="font-semibold text-[#0b1c30] text-sm">Cộng vào hóa đơn sân</p>
                                    <p class="text-xs text-[#5d5d67] mt-0.5 leading-tight">Dùng khi khách thanh toán chung tiền sân và dịch vụ.</p>
                                </div>
                            </div>
                            <div id="lbl-billmode-split" class="bill-mode-card" onclick="setBillMode('SPLIT')">
                                <input type="radio" name="billModeRadio" value="SPLIT" class="hidden">
                                <span class="material-symbols-outlined text-[18px] text-[#5d5d67] shrink-0 mt-0.5">call_split</span>
                                <div class="min-w-0 flex-1">
                                    <p class="font-semibold text-[#0b1c30] text-sm">Tách bill dịch vụ</p>
                                    <p class="text-xs text-[#5d5d67] mt-0.5 leading-tight">Dùng khi khách muốn trả riêng phần dịch vụ.</p>
                                </div>
                            </div>
                        </div>
                        <div id="split-paynow-section" class="hidden flex items-center gap-2 bg-amber-50 border border-amber-200 rounded-xl px-3 py-2 mt-2">
                            <input type="checkbox" id="split-pay-now-cb" class="${isManager ? 'accent-purple-600' : 'accent-orange-600'}">
                            <label for="split-pay-now-cb" class="text-xs font-bold text-amber-800 cursor-pointer">Thanh toán bill tách ngay bây giờ</label>
                        </div>
                    </div>

                    <!-- Split bills list -->
                    <div id="split-bills-section" class="hidden shrink-0">
                        <h4 class="text-xs text-[#0b1c30] uppercase font-semibold mb-2 flex items-center gap-1">
                            <span class="material-symbols-outlined text-[15px] text-amber-600">receipt</span>
                            Hóa đơn tách dịch vụ
                        </h4>
                        <div id="split-bills-list" class="space-y-2"></div>
                    </div>

                    <!-- Payment Methods -->
                    <div class="shrink-0">
                        <h4 class="text-xs text-[#0b1c30] uppercase font-semibold mb-3">PHƯƠNG THỨC THANH TOÁN</h4>
                        <div class="grid grid-cols-2 gap-3">
                            <div class="pay-method-card active" id="lbl-pay-cash" onclick="changeStaffPayMethod('Tiền mặt')">
                                <input type="radio" name="staffPaymentMethod" value="Tiền mặt" checked class="hidden">
                                <span class="material-symbols-outlined text-[22px]">payments</span>
                                <span class="font-semibold text-sm">Tiền mặt</span>
                            </div>
                            <div class="pay-method-card" id="lbl-pay-transfer" onclick="changeStaffPayMethod('Chuyển khoản')">
                                <input type="radio" name="staffPaymentMethod" value="Chuyển khoản" class="hidden">
                                <span class="material-symbols-outlined text-[22px]">qr_code_2</span>
                                <span class="font-semibold text-sm">Chuyển khoản</span>
                            </div>
                        </div>
                    </div>

                    <!-- Summary Total -->
                    <div class="bg-[#dce9ff] rounded-xl p-5 shrink-0">
                        <div class="space-y-2 mb-4">
                            <div class="flex justify-between text-sm">
                                <span class="text-[#5d5d67]">Tiền sân:</span>
                                <span class="font-semibold text-[#0b1c30]" id="staff-summary-court-price" data-val="0">0 đ</span>
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-[#5d5d67]">Tiền dịch vụ:</span>
                                <span class="font-semibold text-[#0b1c30]" id="staff-summary-services-price">0 đ</span>
                            </div>
                        </div>
                        <div class="flex justify-between items-center pt-4 border-t border-[#ccc3d8]">
                            <span class="text-xs text-[#5d5d67] uppercase font-medium">TỔNG THANH TOÁN</span>
                            <span class="text-2xl font-bold ${themeTextMedium}" id="staff-summary-total">0 đ</span>
                        </div>
                    </div>

                    <!-- Hidden forms -->
                    <form id="staff-save-services-form" action="${pageContext.request.contextPath}/staff/checkin" method="post" onsubmit="return prepareAddServicesSubmit()">
                        <input type="hidden" name="action" value="addServices">
                        <input type="hidden" name="datSanId" id="staff-save-datsan-id">
                        <input type="hidden" name="billMode" id="staff-save-billmode" value="MAIN">
                        <input type="hidden" name="payNow" id="staff-save-paynow" value="false">
                        <input type="hidden" name="phuongThucThanhToan" id="staff-save-paymethod" value="Tiền mặt">
                        <div id="staff-save-hidden-inputs" class="hidden"></div>
                    </form>
                    <form id="staff-payment-form" action="${pageContext.request.contextPath}/staff/checkin" method="post" onsubmit="return confirmPaymentSubmit()">
                        <input type="hidden" name="action" value="processPayment">
                        <input type="hidden" name="datSanId" id="staff-pay-datsan-id">
                        <input type="hidden" name="phuongThucThanhToan" id="staff-pay-method-input" value="Tiền mặt">
                    </form>

                </section>
            </div><!-- End of staff-invoice-content -->

        </div><!-- End of flex body -->

        <!-- Footer -->
        <footer class="bg-[#f8f9ff] border-t border-[#ccc3d8] flex flex-wrap justify-between items-center gap-2 px-4 lg:px-8 py-3 lg:py-4 shrink-0">
            <button type="button" onclick="closeStaffInvoiceModal()" class="bg-[#e3e1ed] text-[#64636d] rounded-lg px-5 py-2 text-sm font-semibold hover:brightness-95 transition-all active:scale-95">
                Đóng
            </button>
            <div class="flex flex-wrap gap-2">
                <button form="staff-save-services-form" type="submit" class="bg-white border ${themeBorderStrong} ${themeTextMedium} rounded-lg px-6 py-2.5 text-sm font-semibold ${isManager ? 'hover:bg-purple-50' : 'hover:bg-orange-50'} transition-all active:scale-95">
                    Lưu dịch vụ
                </button>
                <button form="staff-payment-form" type="submit" class="${themeBg} ${themeBgHover} text-white rounded-lg px-6 py-2.5 text-sm font-semibold flex items-center gap-2 transition-all active:scale-95">
                    <span class="material-symbols-outlined text-sm">print</span>
                    Thanh toán &amp; In hóa đơn
                </button>
            </div>
        </footer>

    </div><!-- End of modal inner container -->
</div><!-- End of staffInvoiceModal -->

<!-- Court Detail Side Drawer -->
<div id="drawerOverlay" class="fixed inset-0 bg-black/40 backdrop-blur-sm z-40 hidden opacity-0 transition-opacity duration-300" onclick="closeCourtDetailDrawer()"></div>
<div id="courtDetailDrawer" class="fixed inset-y-0 right-0 w-full sm:w-[450px] bg-white border-l border-zinc-200 shadow-2xl z-50 transform translate-x-full transition-transform duration-300 ease-in-out flex flex-col hidden">
    <!-- Header -->
    <div class="p-5 border-b border-zinc-100 flex items-center justify-between">
        <div>
            <h3 id="drawer-court-name" class="text-base font-extrabold text-zinc-900 tracking-tight">Tên sân</h3>
            <div class="flex items-center gap-1.5 mt-1">
                <span id="drawer-court-type" class="text-[10px] text-zinc-550 font-bold uppercase">Loại sân</span>
                <span class="text-zinc-300">•</span>
                <span id="drawer-court-status-badge" class="badge">Sẵn sàng</span>
            </div>
        </div>
        <button type="button" onclick="closeCourtDetailDrawer()" class="p-2 rounded-xl text-zinc-400 hover:bg-zinc-50 hover:text-zinc-650 transition-colors">
            <span class="material-symbols-outlined text-[20px]">close</span>
        </button>
    </div>
    
    <!-- Content (Scrollable) -->
    <div class="flex-1 overflow-y-auto p-5 space-y-6">
        <!-- Court Specifications -->
        <div class="bg-zinc-50 rounded-2xl p-4 border border-zinc-150 space-y-3">
            <h4 class="text-[11px] font-bold text-zinc-450 uppercase tracking-wider">Thông số chi tiết</h4>
            <div class="grid grid-cols-2 gap-4 text-xs">
                <div>
                    <span class="text-zinc-550 block">Mã sân (SanID):</span>
                    <span id="drawer-court-id" class="font-extrabold text-zinc-800">-</span>
                </div>
                <div>
                    <span class="text-zinc-550 block">Cơ sở chi nhánh:</span>
                    <span id="drawer-court-coso" class="font-extrabold text-zinc-800">-</span>
                </div>
                <div>
                    <span class="text-zinc-550 block">Giá không đèn:</span>
                    <span id="drawer-price-nolite" class="font-extrabold text-zinc-800">-</span>
                </div>
                <div>
                    <span class="text-zinc-550 block">Giá có đèn:</span>
                    <span id="drawer-price-lite" class="font-extrabold text-zinc-800">-</span>
                </div>
                <div class="col-span-2">
                    <span class="text-zinc-550 block">Khung giờ bật đèn:</span>
                    <span id="drawer-light-time" class="font-extrabold text-zinc-800">-</span>
                </div>
            </div>
            <div id="drawer-desc-container" class="mt-2 pt-2 border-t border-zinc-100 hidden">
                <span class="text-zinc-550 block text-xs">Mô tả:</span>
                <p id="drawer-court-desc" class="text-xs text-zinc-650 mt-1 italic"></p>
            </div>
        </div>
        
        <!-- Action Sections -->
        
        <!-- Section D: Danh sách đặt lịch hôm nay (Khách đặt trước) -->
        <div id="drawer-action-prebooked" class="hidden space-y-4">
            <div class="flex items-center gap-2 text-zinc-850 font-extrabold text-sm border-b pb-2">
                <span class="material-symbols-outlined ${themeText}">calendar_today</span>
                <span>Khách đã đặt trước & thành công</span>
            </div>
            <div id="drawer-prebooked-list" class="space-y-3">
                <!-- Will be dynamically populated via JS -->
            </div>
        </div>

        <!-- Section A: Sẵn sàng -> Mở sân nhanh -->
        <div id="drawer-action-walkin" class="hidden space-y-4">
            <div class="flex items-center gap-2 text-zinc-850 font-extrabold text-sm">
                <span class="material-symbols-outlined text-green-600">bolt</span>
                <span>Mở sân nhanh cho Khách vãng lai</span>
            </div>
            <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="space-y-4">
                <input type="hidden" name="action" value="checkInWalkIn">
                <input type="hidden" id="drawer-walkin-san-id" name="sanId">
                <input type="hidden" id="drawer-walkin-duration" name="duration" value="120">
                
                <div class="space-y-2">
                    <label class="block text-[11px] font-bold text-zinc-500">Kiểu giờ chơi:</label>
                    <div class="grid grid-cols-2 gap-2">
                        <label id="drawer-mode-fixed-label" class="border-2 ${themeBorderStrong} ${themeBgLight} rounded-xl p-3 cursor-pointer text-xs font-bold ${themeTextMedium} transition-all text-center">
                            <input type="radio" class="sr-only" name="playMode" value="FIXED" checked onchange="setDrawerPlayMode('FIXED')">
                            Giờ cố định
                        </label>
                        <label id="drawer-mode-open-label" class="border-2 border-zinc-150 rounded-xl p-3 cursor-pointer text-xs font-bold text-zinc-700 hover:border-zinc-300 transition-all text-center">
                            <input type="radio" class="sr-only" name="playMode" value="OPEN" onchange="setDrawerPlayMode('OPEN')">
                            Không cố định
                        </label>
                    </div>
                    <div id="drawer-fixed-duration-panel" class="space-y-2 mt-2">
                        <label class="block text-[11px] font-bold text-zinc-500">Mốc thời gian chơi:</label>
                        <div class="grid grid-cols-5 gap-1.5">
                            <button type="button" data-duration-btn="60" onclick="setDrawerDuration(60)" class="drawer-duration-btn py-2 px-1 rounded-lg border border-zinc-200 text-[10px] font-bold text-zinc-700 hover:bg-zinc-50">60p</button>
                            <button type="button" data-duration-btn="90" onclick="setDrawerDuration(90)" class="drawer-duration-btn py-2 px-1 rounded-lg border border-zinc-200 text-[10px] font-bold text-zinc-700 hover:bg-zinc-50">90p</button>
                            <button type="button" data-duration-btn="120" onclick="setDrawerDuration(120)" class="drawer-duration-btn py-2 px-1 rounded-lg border ${themeBorderStrong} ${themeBgLight} text-[10px] font-bold ${themeTextMedium}">120p</button>
                            <button type="button" data-duration-btn="150" onclick="setDrawerDuration(150)" class="drawer-duration-btn py-2 px-1 rounded-lg border border-zinc-200 text-[10px] font-bold text-zinc-700 hover:bg-zinc-50">150p</button>
                            <button type="button" data-duration-btn="180" onclick="setDrawerDuration(180)" class="drawer-duration-btn py-2 px-1 rounded-lg border border-zinc-200 text-[10px] font-bold text-zinc-700 hover:bg-zinc-50">180p</button>
                        </div>
                        <div class="mt-2">
                            <label class="block text-[11px] font-bold text-zinc-500 mb-1">Tự chọn số giờ chơi:</label>
                            <input type="number" id="drawer-custom-hours" min="0.5" max="12" step="0.5" placeholder="VD: 1.5"
                                   oninput="setDrawerCustomDuration()"
                                   class="w-full text-xs p-2.5 border border-zinc-200 rounded-xl bg-zinc-50 focus:outline-none ${focusRing} focus:bg-white">
                        </div>
                    </div>
                    
                    <div id="drawer-open-duration-note" class="hidden p-3 rounded-xl border ${themeBorder} ${themeBgLight} text-[11px] ${themeTextMedium} font-semibold mt-2">
                        Phiên không cố định sẽ hiển thị đồng hồ đếm tới trong màn hình chi tiết sân.
                    </div>
                </div>

                <div>
                    <label class="block text-[11px] font-bold text-zinc-500 mb-1">Đơn giá tự áp dụng (VND / giờ):</label>
                    <input type="number" id="drawer-walkin-rate" name="donGia" step="10000" class="w-full text-xs p-2.5 border border-zinc-150 rounded-xl bg-zinc-100 cursor-not-allowed focus:outline-none" required readonly oninput="calculateDrawerPrice()">
                    <span id="drawer-walkin-rate-type" class="text-[10px] text-zinc-500 mt-1 block">Áp dụng: Giá không đèn</span>
                </div>
                
                <div class="p-3 bg-zinc-50 rounded-xl border border-zinc-150 flex items-center justify-between text-xs">
                    <span class="text-zinc-550">Tạm tính tiền sân:</span>
                    <span id="drawer-walkin-total" class="font-extrabold text-sm ${themeTextMedium}">0 đ</span>
                </div>
                
                <button type="submit" class="w-full ${themeBg} ${themeBgHover} text-white font-extrabold text-xs py-3 rounded-xl shadow hover:shadow-md transition-all active:scale-95 flex items-center justify-center gap-1.5">
                    <span class="material-symbols-outlined text-[16px]">play_circle</span>
                    Mở sân ngay
                </button>
            </form>
        </div>
        
        <!-- Section B: Đang sử dụng -> Phiên chơi hiện tại -->
        <div id="drawer-action-active" class="hidden space-y-4">
            <div class="flex items-center gap-2 text-zinc-850 font-extrabold text-sm">
                <span class="material-symbols-outlined ${themeText}">sports_tennis</span>
                <span>Phiên chơi hiện tại</span>
            </div>
            
            <div class="space-y-3 ${themeBgLight} border ${themeBorder} rounded-2xl p-4 text-xs">
                <div class="flex justify-between">
                    <span class="text-zinc-550">Mã đơn đặt (DatSanID):</span>
                    <span id="drawer-active-id" class="font-bold text-zinc-800">-</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-zinc-550">Giờ bắt đầu:</span>
                    <span id="drawer-active-start" class="font-bold text-zinc-800">-</span>
                </div>
                <div class="flex justify-between">
                    <span class="text-zinc-550">Kiểu giờ chơi:</span>
                    <span id="drawer-active-mode" class="font-bold text-zinc-800">-</span>
                </div>
                <!-- Dynamic Timer display row -->
                <div class="flex justify-between p-2.5 rounded-xl bg-white border ${themeBorder}" id="drawer-active-timer-row">
                    <span class="text-zinc-600 font-semibold" id="drawer-active-timer-label">Thời gian:</span>
                    <span id="drawer-active-timer-val" class="font-black text-sm text-zinc-800">-</span>
                </div>
                <div class="flex justify-between pt-2 border-t ${themeBorder} text-sm font-extrabold">
                    <span class="text-zinc-700">Tổng tiền sân tạm tính:</span>
                    <span id="drawer-active-total-price" class="${themeTextMedium}">0 đ</span>
                </div>
            </div>

            <!-- Stop Session Form (only for OPEN mode) -->
            <form id="drawer-stop-session-form" action="${pageContext.request.contextPath}/staff/checkin" method="post" class="hidden">
                <input type="hidden" name="action" value="stopOpenSession">
                <input type="hidden" id="drawer-stop-datsan-id" name="datSanId">
                <button type="submit" class="w-full bg-rose-600 hover:bg-rose-700 text-white font-black text-xs py-3 rounded-xl shadow-lg hover:shadow-rose-600/20 active:scale-95 transition-all flex items-center justify-center gap-1.5 animate-pulse">
                    <span class="material-symbols-outlined text-[18px]">stop_circle</span>
                    Dừng chơi & Tính tiền
                </button>
            </form>
            
            <button type="button" id="drawer-btn-invoice" class="w-full ${themeBg} ${themeBgHover} text-white font-extrabold text-xs py-3 rounded-xl shadow hover:shadow-md transition-all active:scale-95 flex items-center justify-center gap-1.5">
                <span class="material-symbols-outlined text-[18px]">payments</span>
                Dịch vụ & Thanh toán
            </button>
        </div>
        
        <!-- Section C: Bảo trì / Tạm đóng -> Không thể mở -->
        <div id="drawer-action-disabled" class="hidden bg-red-50/40 border border-red-100 text-red-900 rounded-xl p-4 text-xs flex items-center gap-2">
            <span class="material-symbols-outlined text-red-600 text-[18px]">warning</span>
            <span>Sân hiện đang bảo trì hoặc tạm đóng, không thể mở cho khách chơi.</span>
        </div>
    </div>
</div>

<script>
    function formatCurrency(val) {
        if (val === undefined || val === null || isNaN(val)) return '0 đ';
        return Math.round(Number(val)).toLocaleString('vi-VN') + ' đ';
    }

    let staffProducts = [];
    let staffOrdered = [];
    let currentStaffDatSanId = -1;

    let currentStaffCatalogCat = "all";
    let currentStaffCatalogSearch = "";

    function filterStaffCatalog(cat, button) {
        document.querySelectorAll(".pos-tab").forEach(btn => btn.classList.remove("active"));
        button.classList.add("active");
        currentStaffCatalogCat = cat;
        renderStaffProductCatalog(cat, currentStaffCatalogSearch);
    }

    function searchStaffCatalog(val) {
        currentStaffCatalogSearch = val.trim().toLowerCase();
        renderStaffProductCatalog(currentStaffCatalogCat, currentStaffCatalogSearch);
    }

    function getProductCategory(prod) {
        if (!prod || !prod.TenSanPham) return "others";
        const name = prod.TenSanPham.toLowerCase();
        if (name.includes("nước") || name.includes("coca") || name.includes("sting") || name.includes("revive") || name.includes("trà") || name.includes("aquafina") || name.includes("lon") || name.includes("chai") || name.includes("h2o")) {
            return "drinks";
        }
        if (name.includes("thuê") || name.includes("vợt") || name.includes("bóng") || name.includes("giày") || name.includes("áo") || name.includes("bib") || name.includes("vớ") || name.includes("phục vụ")) {
            return "rentals";
        }
        return "others";
    }

    function renderStaffProductCatalog(filterCat = 'all', keyword = '') {
        const container = document.getElementById("staff-product-catalog");
        if (!container) return;
        container.innerHTML = "";

        let filtered = staffProducts || [];

        // 1. Filter by category tab
        if (filterCat !== 'all') {
            filtered = filtered.filter(p => getProductCategory(p) === filterCat);
        }

        // 2. Filter by search input keyword
        if (keyword) {
            filtered = filtered.filter(p => p.TenSanPham && p.TenSanPham.toLowerCase().includes(keyword));
        }

        if (filtered.length === 0) {
            container.innerHTML = `<div class="col-span-full py-12 text-center text-xs text-zinc-400 italic">Không tìm thấy sản phẩm nào.</div>`;
            return;
        }

        filtered.forEach(prod => {
            const isOutOfStock = prod.SoLuongTon <= 0;
            const cardClass = isOutOfStock ? "pos-card disabled" : "pos-card";
            const stockText = isOutOfStock 
                ? `<span class="px-2 py-0.5 rounded-md bg-red-50 text-red-650 font-bold text-[9px] uppercase tracking-wide">Hết hàng</span>` 
                : `<span class="text-[10px] text-zinc-500 font-semibold">Kho: <strong class="text-zinc-700 font-bold">\${prod.SoLuongTon}</strong></span>`;
            
            const cat = getProductCategory(prod);
            const icon = cat === 'drinks' ? 'local_cafe' : cat === 'rentals' ? 'sports_tennis' : 'grid_view';
            const iconBg = cat === 'drinks' ? 'bg-blue-50 text-blue-600' : cat === 'rentals' ? 'bg-orange-50 text-orange-600' : 'bg-slate-100 text-slate-600';

            const cardHtml = `
                <div class="\${cardClass}" onclick="if(!this.classList.contains('disabled')) quickAddProduct(\${prod.SanPhamID}, 1)">
                    <div class="flex items-start gap-2">
                        <div class="w-8 h-8 rounded-lg \${iconBg} flex items-center justify-center shrink-0">
                            <span class="material-symbols-outlined text-[16px]">\${icon}</span>
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="font-bold text-zinc-800 text-[12px] truncate leading-tight" title="\${prod.TenSanPham}">\${prod.TenSanPham}</p>
                            <p class="text-[10px] text-zinc-400 mt-0.5 capitalize">\${prod.DonViTinh || 'cái'}</p>
                        </div>
                    </div>
                    <div class="flex items-center justify-between mt-3 pt-1 border-t border-zinc-50">
                        <span class="font-black text-[12.5px] text-zinc-900">\${formatCurrency(prod.DonGia)}</span>
                        \${stockText}
                    </div>
                </div>
            `;
            container.insertAdjacentHTML("beforeend", cardHtml);
        });
    }

    function quickAddProduct(spId, qty) {
        const prod = staffProducts.find(p => p.SanPhamID === spId);
        if (!prod) return;

        if (prod.SoLuongTon <= 0) {
            alert("Sản phẩm này đã hết hàng!");
            return;
        }

        const existing = staffOrdered.find(o => o.SanPhamID === spId);
        if (existing) {
            const newQty = existing.SoLuong + qty;
            if (newQty > prod.SoLuongTon) {
                alert(`Không thể chọn vượt quá số lượng tồn kho (\${prod.SoLuongTon})`);
                return;
            }
            existing.SoLuong = newQty;
            existing.ThanhTien = newQty * existing.DonGiaTaiThoiDiemBan;
        } else {
            staffOrdered.push({
                SanPhamID: spId,
                SoLuong: qty,
                DonGiaTaiThoiDiemBan: prod.DonGia,
                ThanhTien: qty * prod.DonGia
            });
        }
        renderStaffOrderedTable();
    }

    function openStaffInvoiceModal(datSanId) {
        currentStaffDatSanId = datSanId;
        document.getElementById("staff-save-datsan-id").value = datSanId;
        document.getElementById("staff-pay-datsan-id").value = datSanId;
        
        const modal = document.getElementById("staffInvoiceModal");
        const loading = document.getElementById("staff-invoice-loading");
        const content = document.getElementById("staff-invoice-content");
        
        modal.classList.remove("hidden");
        modal.classList.add("flex");
        loading.classList.remove("hidden");
        content.classList.add("hidden");
        
        setTimeout(() => {
            modal.classList.remove("opacity-0");
            modal.querySelector(".bg-white").classList.remove("scale-95");
        }, 10);
 
        // Fetch invoice detail
        fetch('${pageContext.request.contextPath}/staff/checkin?action=getInvoiceDetails&datSanId=' + datSanId)
            .then(res => {
                if (!res.ok) {
                    return res.text().then(text => {
                        try {
                            const errData = JSON.parse(text);
                            throw new Error(errData.error || 'Lỗi server: ' + res.status);
                        } catch (parseErr) {
                            if (parseErr.message && parseErr.message.startsWith('Lỗi server')) throw parseErr;
                            throw new Error('Lỗi server (' + res.status + '). Vui lòng tải lại trang.');
                        }
                    });
                }
                return res.json();
            })
            .then(data => {
                staffProducts = data.products || [];
                staffOrdered = data.ordered || [];
                
                document.getElementById("staff-invoice-court-name").textContent = data.tenSan;
                document.getElementById("staff-invoice-time-slot").textContent = data.gioBatDau + ' - ' + data.gioKetThuc + ' (' + data.ngayDat + ')';
                
                const statusBadge = document.getElementById("staff-invoice-payment-status");
                statusBadge.textContent = data.trangThaiThanhToan;
                if (data.trangThaiThanhToan === 'Đã thanh toán') {
                    statusBadge.className = "badge badge-green";
                } else {
                    statusBadge.className = "badge badge-amber";
                }

                // Handle split bill state
                currentMainBillPaid = !!data.mainBillPaid;
                const lblMain = document.getElementById('lbl-billmode-main');
                if (currentMainBillPaid) {
                    // Main already paid → disable MAIN mode, force SPLIT
                    lblMain.className = 'bill-mode-card disabled pointer-events-none opacity-50';
                    lblMain.onclick = null;
                    setBillMode('SPLIT');
                } else {
                    lblMain.className = 'bill-mode-card';
                    lblMain.onclick = () => setBillMode('MAIN');
                    setBillMode('MAIN');
                }
                renderSplitBillsList(data.splitBills || []);
 
                // Populate court details
                document.getElementById("staff-detail-court-rate").textContent = formatCurrency(data.donGiaGio) + "/giờ";
                document.getElementById("staff-detail-start-time").textContent = data.gioBatDau;
                document.getElementById("staff-detail-end-time").textContent = data.gioKetThuc;

                const earlyContainer = document.getElementById("staff-detail-early-container");
                if (data.phuThuNhanSom > 0) {
                    earlyContainer.classList.remove("hidden");
                    document.getElementById("staff-detail-early-surcharge").textContent = formatCurrency(data.phuThuNhanSom);
                } else {
                    earlyContainer.classList.add("hidden");
                }

                const lateContainer = document.getElementById("staff-detail-late-container");
                if (data.minutesOver > 10) {
                    lateContainer.classList.remove("hidden");
                    document.getElementById("staff-detail-late-minutes").textContent = data.minutesOver;
                    document.getElementById("staff-detail-late-surcharge").textContent = formatCurrency(data.phuThuQuaGio);
                } else {
                    lateContainer.classList.add("hidden");
                }

                // Populate court price summary
                const summaryCourtPriceEl = document.getElementById("staff-summary-court-price");
                summaryCourtPriceEl.textContent = formatCurrency(data.tongTienSan);
                summaryCourtPriceEl.setAttribute("data-val", data.tongTienSan);
 
                // Reset search lookup and filter tab states
                const searchInput = document.getElementById("staff-catalog-search");
                if (searchInput) searchInput.value = "";
                currentStaffCatalogSearch = "";
                
                document.querySelectorAll(".pos-tab").forEach(btn => btn.classList.remove("active"));
                const defaultTab = document.querySelector(".pos-tab[onclick*='all']");
                if (defaultTab) defaultTab.classList.add("active");
                currentStaffCatalogCat = "all";

                // Render catalog grid
                renderStaffProductCatalog("all", "");

                // Populate products select (for legacy bindings)
                const select = document.getElementById("staff-product-select");
                if (select) {
                    select.innerHTML = '<option value="">-- Chọn sản phẩm thêm --</option>';
                    staffProducts.forEach(prod => {
                        const statusText = prod.SoLuongTon <= 0 ? ' - HẾT HÀNG' : ` - Kho: \${prod.SoLuongTon}`;
                        select.insertAdjacentHTML("beforeend", `<option value="\${prod.SanPhamID}">\${prod.TenSanPham} (\${formatCurrency(prod.DonGia)} / \${prod.DonViTinh || 'cái'}\${statusText})</option>`);
                    });
                }
 
                renderStaffOrderedTable();
                
                loading.classList.add("hidden");
                content.classList.remove("hidden");
            })
            .catch(err => {
                alert('Lỗi khi tải chi tiết hóa đơn: ' + err.message);
                closeStaffInvoiceModal();
            });
    }

    function renderStaffOrderedTable() {
        const cartList = document.getElementById("staff-cart-list");
        if (!cartList) return;
        cartList.innerHTML = "";
        
        let totalItems = 0;
        
        if (staffOrdered.length === 0) {
            cartList.innerHTML = `
                <div class="flex flex-col items-center justify-center text-center py-14 px-4 border-2 border-dashed border-slate-100 rounded-2xl h-full min-h-[300px]">
                    <div class="w-10 h-10 rounded-full bg-slate-50 flex items-center justify-center text-slate-400 mb-2.5">
                        <span class="material-symbols-outlined text-[20px]">shopping_cart</span>
                    </div>
                    <p class="text-xs font-bold text-slate-700">Chưa có dịch vụ nào được thêm</p>
                    <p class="text-[10px] text-slate-400 mt-1 max-w-[200px]">Chọn sản phẩm từ danh sách bên trái để bắt đầu.</p>
                </div>
            `;
        } else {
            staffOrdered.forEach(item => {
                const prod = staffProducts.find(p => p.SanPhamID === item.SanPhamID);
                const prodName = prod ? prod.TenSanPham : ('Sản phẩm #' + item.SanPhamID);
                const unit = prod ? (prod.DonViTinh || 'cái') : 'cái';
                const formattedPrice = item.DonGiaTaiThoiDiemBan.toLocaleString('vi-VN');
                const formattedTotal = item.ThanhTien.toLocaleString('vi-VN');
                
                totalItems += item.SoLuong;
                
                cartList.insertAdjacentHTML("beforeend", `
                    <div class="cart-item">
                        <div class="min-w-0 flex-grow">
                            <p class="font-bold text-slate-800 text-xs truncate" title="\${prodName}">\${prodName}</p>
                            <p class="text-[9px] text-slate-400 mt-0.5 capitalize">\${unit} • \${formattedPrice} đ</p>
                        </div>
                        
                        <!-- Stepper count -->
                        <div class="flex items-center gap-1 shrink-0">
                            <button type="button" onclick="adjustStaffItemQty(\${item.SanPhamID}, -1)" class="stepper-btn">-</button>
                            <span class="font-bold text-xs w-6 text-center text-slate-800">\${item.SoLuong}</span>
                            <button type="button" onclick="adjustStaffItemQty(\${item.SanPhamID}, 1)" class="stepper-btn">+</button>
                        </div>
                        
                        <!-- Line total price & Delete -->
                        <div class="flex items-center gap-2 shrink-0">
                            <span class="font-extrabold text-xs text-slate-800 text-right min-w-[70px]">\${formattedTotal} đ</span>
                            <button type="button" onclick="removeStaffItem(\${item.SanPhamID})" class="p-1 rounded text-red-500 hover:bg-red-50 hover:text-red-650 transition-colors flex items-center justify-center">
                                <span class="material-symbols-outlined text-[16px]">close</span>
                            </button>
                        </div>
                    </div>
                `);
            });
        }

        // Update item count badge in Column 2
        const countText = staffOrdered.length === 1 ? '1 mặt hàng' : `\${staffOrdered.length} mặt hàng`;
        const countEl = document.getElementById("staff-cart-item-count");
        if (countEl) countEl.textContent = countText;

        recalculateStaffTotals();
    }

    function adjustStaffItemQty(spId, delta) {
        const prod = staffProducts.find(p => p.SanPhamID === spId);
        if (!prod) return;
        
        const item = staffOrdered.find(o => o.SanPhamID === spId);
        if (!item) return;

        let newQty = item.SoLuong + delta;
        if (newQty <= 0) {
            removeStaffItem(spId);
            return;
        }

        if (newQty > prod.SoLuongTon) {
            alert(`Không thể chọn vượt quá số lượng tồn kho (\${prod.SoLuongTon})`);
            newQty = prod.SoLuongTon;
        }

        item.SoLuong = newQty;
        item.ThanhTien = newQty * item.DonGiaTaiThoiDiemBan;
        renderStaffOrderedTable();
    }

    function removeStaffItem(spId) {
        staffOrdered = staffOrdered.filter(o => o.SanPhamID !== spId);
        renderStaffOrderedTable();
    }

    function addServiceToInvoiceList() {
        const select = document.getElementById("staff-product-select");
        const qtyInput = document.getElementById("staff-product-qty");
        
        const spId = parseInt(select.value);
        const qty = parseInt(qtyInput.value) || 1;
        
        if (!spId) {
            alert("Vui lòng chọn sản phẩm.");
            return;
        }

        const prod = staffProducts.find(p => p.SanPhamID === spId);
        if (!prod) return;

        if (qty > prod.SoLuongTon) {
            alert(`Sản phẩm này chỉ còn tồn kho: \${prod.SoLuongTon}`);
            return;
        }

        // Check if already ordered
        const existing = staffOrdered.find(o => o.SanPhamID === spId);
        if (existing) {
            const newQty = existing.SoLuong + qty;
            if (newQty > prod.SoLuongTon) {
                alert(`Không thể thêm vì tổng số lượng vượt quá tồn kho (\${prod.SoLuongTon})`);
                return;
            }
            existing.SoLuong = newQty;
            existing.ThanhTien = newQty * existing.DonGiaTaiThoiDiemBan;
        } else {
            staffOrdered.push({
                SanPhamID: spId,
                SoLuong: qty,
                DonGiaTaiThoiDiemBan: prod.DonGia,
                ThanhTien: qty * prod.DonGia
            });
        }

        select.value = "";
        qtyInput.value = "1";
        renderStaffOrderedTable();
    }

    function recalculateStaffTotals() {
        let serviceTotal = 0;
        staffOrdered.forEach(item => {
            serviceTotal += item.ThanhTien;
        });

        const summaryCourtPriceEl = document.getElementById("staff-summary-court-price");
        const courtPriceVal = parseFloat(summaryCourtPriceEl.getAttribute("data-val")) || 0;
        
        const totalVal = courtPriceVal + serviceTotal;
        
        const cartSubtotalEl = document.getElementById("staff-cart-subtotal");
        if (cartSubtotalEl) cartSubtotalEl.textContent = serviceTotal.toLocaleString('vi-VN') + " đ";
        
        document.getElementById("staff-summary-services-price").textContent = serviceTotal.toLocaleString('vi-VN') + " đ";
        document.getElementById("staff-summary-total").textContent = totalVal.toLocaleString('vi-VN') + " đ";

        // Update hidden inputs for saving
        const hiddenContainer = document.getElementById("staff-save-hidden-inputs");
        if (hiddenContainer) {
            hiddenContainer.innerHTML = "";
            staffOrdered.forEach(item => {
                hiddenContainer.insertAdjacentHTML("beforeend", `<input type="hidden" name="productId" value="\${item.SanPhamID}">`);
                hiddenContainer.insertAdjacentHTML("beforeend", `<input type="hidden" name="quantity" value="\${item.SoLuong}">`);
            });
        }
    }

    function changeStaffPayMethod(method) {
        document.getElementById("staff-pay-method-input").value = method;
        document.getElementById("staff-save-paymethod").value = method;
        
        const lblCash = document.getElementById("lbl-pay-cash");
        const lblTransfer = document.getElementById("lbl-pay-transfer");
        
        if (lblCash && lblTransfer) {
            if (method === 'Tiền mặt') {
                lblCash.classList.add("active");
                lblTransfer.classList.remove("active");
            } else {
                lblTransfer.classList.add("active");
                lblCash.classList.remove("active");
            }
        }
    }

    function confirmPaymentSubmit() {
        // Kiểm tra split bills chưa thanh toán (cảnh báo phía client, server sẽ chặn cứng)
        const splitSection = document.getElementById('split-bills-section');
        if (splitSection && !splitSection.classList.contains('hidden')) {
            const unpaidBtns = splitSection.querySelectorAll('button[onclick^="paySplitBill"]');
            if (unpaidBtns.length > 0) {
                return confirm(`⚠️ Có \${unpaidBtns.length} hóa đơn tách dịch vụ CHƯA thanh toán!\nNếu tiếp tục, hệ thống sẽ từ chối yêu cầu kết thúc ca chơi.\n\nBạn vẫn muốn thử?`);
            }
        }
        return confirm("Xác nhận khách đã thanh toán đơn này? Sân bóng sẽ được giải phóng về trạng thái Sẵn sàng.");
    }

    function closeStaffInvoiceModal() {
        const modal = document.getElementById("staffInvoiceModal");
        modal.classList.add("opacity-0");
        modal.querySelector(".bg-white").classList.add("scale-95");
        setTimeout(() => {
            modal.classList.add("hidden");
            modal.classList.remove("flex");
        }, 300);
    }


    function toggleCardCollapse(event, sanId) {
        if (event) {
            event.stopPropagation();
        }
        const collapseEl = document.getElementById(`collapse-walkin-\${sanId}`);
        if (!collapseEl) return;
        
        const isCurrentlyHidden = collapseEl.classList.contains('hidden');
        
        // Hide all other collapsible sections first
        document.querySelectorAll('[id^="collapse-walkin-"]').forEach(el => {
            el.classList.add('hidden');
        });
        
        if (isCurrentlyHidden) {
            collapseEl.classList.remove('hidden');
            
            // Set prices and render prebooked
            const cardEl = document.querySelector(`.card[data-sanid="\${sanId}"]`);
            if (cardEl) {
                const giaKhongDen = parseFloat(cardEl.getAttribute('data-giakhongden')) || 0;
                const giaCoDen = parseFloat(cardEl.getAttribute('data-giacoden')) || 0;
                const gioBatDauLenDen = cardEl.getAttribute('data-giobatdaulenden') || '';
                const gioKetThucLenDen = cardEl.getAttribute('data-giokethuclenden') || '';
                
                const now = new Date();
                const currentTimeStr = now.toTimeString().split(' ')[0];
                let rate = giaKhongDen;
                let isLite = false;
                
                if (gioBatDauLenDen && gioKetThucLenDen) {
                    if (currentTimeStr >= gioBatDauLenDen && currentTimeStr <= gioKetThucLenDen) {
                        rate = giaCoDen;
                        isLite = true;
                    }
                }
                
                const rateInput = document.getElementById(`card-rate-\${sanId}`);
                if (rateInput) {
                    rateInput.value = rate;
                    rateInput.setAttribute('data-base', rate);
                    rateInput.setAttribute('data-giakhongden', giaKhongDen);
                    rateInput.setAttribute('data-giacoden', giaCoDen);
                    rateInput.setAttribute('data-giobatdaulenden', gioBatDauLenDen);
                    rateInput.setAttribute('data-giokethuclenden', gioKetThucLenDen);
                }
                
                const rateTypeSpan = document.getElementById(`card-rate-type-\${sanId}`);
                if (rateTypeSpan) {
                    rateTypeSpan.textContent = `Áp dụng: \${isLite ? 'Giá có đèn' : 'Giá không đèn'}`;
                }
                
                // Initialize default playMode to FIXED and duration to 120
                setCardPlayMode(sanId, 'FIXED');
                setCardDuration(sanId, 120);
                
                // Render today's bookings for this court
                renderCardPrebookedBookings(sanId);
            }
        }
    }

    function setCardPlayMode(sanId, mode) {
        const lblFixed = document.getElementById(`card-mode-fixed-label-\${sanId}`);
        const lblOpen = document.getElementById(`card-mode-open-label-\${sanId}`);
        const fixedPanel = document.getElementById(`card-fixed-panel-\${sanId}`);
        const openNote = document.getElementById(`card-open-note-\${sanId}`);
        const durationInput = document.getElementById(`card-walkin-duration-\${sanId}`);
        
        if (mode === 'FIXED') {
            if (lblFixed) lblFixed.className = `border ${themeBorderStrong} ${themeBgLight} rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold ${themeTextMedium} transition-all text-center`;
            if (lblOpen) lblOpen.className = "border border-zinc-150 rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold text-zinc-700 hover:border-zinc-300 transition-all text-center";
            if (fixedPanel) fixedPanel.classList.remove('hidden');
            if (openNote) openNote.classList.add('hidden');
            
            // Revert duration input to the active button's value
            let activeFixedBtn = document.querySelector(`.card-duration-btn-\${sanId}.\${themeBorderStrong}`);
            if (activeFixedBtn) {
                const dur = parseInt(activeFixedBtn.getAttribute('data-card-duration-btn').split('-')[1]) || 120;
                if (durationInput) durationInput.value = dur;
            } else {
                if (durationInput) durationInput.value = 120;
            }
        } else {
            if (lblFixed) lblFixed.className = "border border-zinc-150 rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold text-zinc-700 hover:border-zinc-300 transition-all text-center";
            if (lblOpen) lblOpen.className = `border ${themeBorderStrong} ${themeBgLight} rounded-lg py-1 px-1 cursor-pointer text-[9px] font-extrabold ${themeTextMedium} transition-all text-center`;
            if (fixedPanel) fixedPanel.classList.add('hidden');
            if (openNote) {
                openNote.classList.remove('hidden');
                const rateEl = document.getElementById("card-rate-${sanId}");
                const rateVal = rateEl ? parseFloat(rateEl.value) || 0 : 0;
                openNote.innerHTML = `Đơn giá áp dụng: <strong>\${formatCurrency(rateVal)}/giờ</strong><br><span style="opacity:.75">Tính tiền thực tế khi trả sân.</span>`;
            }
            
            // Set 120 default for conflict checks in open mode
            if (durationInput) durationInput.value = 120;
        }
        calculateCardPrice(sanId);
    }

    function setCardDuration(sanId, mins) {
        const durationInput = document.getElementById(`card-walkin-duration-\${sanId}`);
        if (durationInput) {
            durationInput.value = mins;
        }
        
        // Highlight active button
        const buttons = document.querySelectorAll(`.card-duration-btn-\${sanId}`);
        buttons.forEach(btn => {
            const btnDur = parseInt(btn.getAttribute('data-card-duration-btn').split('-')[1]);
            if (btnDur === mins) {
                btn.className = `card-duration-btn-\${sanId} py-1 rounded border \${themeBorderStrong} \${themeBgLight} text-[8px] font-extrabold \${themeTextMedium}`;
            } else {
                btn.className = `card-duration-btn-\${sanId} py-1 rounded border border-zinc-200 text-[8px] font-extrabold text-zinc-700 hover:bg-zinc-50`;
            }
        });
        
        // Update select value if matching
        const select = document.querySelector(`#collapse-walkin-\${sanId} select[name="duration_select"]`);
        if (select) {
            select.value = mins;
        }
        
        calculateCardPrice(sanId);
    }

    function setCardSelectDuration(sanId, mins) {
        const durationInput = document.getElementById(`card-walkin-duration-\${sanId}`);
        if (durationInput) {
            durationInput.value = mins;
        }
        
        // Highlight corresponding button (or clear highlights if not found)
        const buttons = document.querySelectorAll(`.card-duration-btn-\${sanId}`);
        buttons.forEach(btn => {
            const btnDur = parseInt(btn.getAttribute('data-card-duration-btn').split('-')[1]);
            if (btnDur === parseInt(mins)) {
                btn.className = `card-duration-btn-\${sanId} py-1 rounded border \${themeBorderStrong} \${themeBgLight} text-[8px] font-extrabold \${themeTextMedium}`;
            } else {
                btn.className = `card-duration-btn-\${sanId} py-1 rounded border border-zinc-200 text-[8px] font-extrabold text-zinc-700 hover:bg-zinc-50`;
            }
        });
        
        calculateCardPrice(sanId);
    }

    function calculateCardPrice(sanId) {
        const durationInput = document.getElementById(`card-walkin-duration-\${sanId}`);
        const rateInput = document.getElementById(`card-rate-\${sanId}`);
        const totalSpan = document.getElementById(`card-subtotal-val-\${sanId}`);
        if (!durationInput || !rateInput || !totalSpan) return;
        
        const openRadio = document.querySelector(`#collapse-walkin-\${sanId} input[name="playMode"][value="OPEN"]`);
        const isOpen = openRadio && openRadio.checked;
        if (isOpen) {
            totalSpan.textContent = "Thực tế";
            const overrideContainer = document.getElementById(`card-override-container-\${sanId}`);
            if (overrideContainer) overrideContainer.classList.add('hidden');
            return;
        }

        const duration = parseInt(durationInput.value) || 0;
        const rate = parseFloat(rateInput.value) || 0;
        const total = (duration / 60.0) * rate;
        
        totalSpan.textContent = formatCurrency(total);
        
        const base = parseFloat(rateInput.getAttribute('data-base')) || 0;
        const overrideContainer = document.getElementById(`card-override-container-\${sanId}`);
        const reasonText = document.getElementById(`card-override-reason-\${sanId}`);
        if (overrideContainer && reasonText) {
            if (rate !== base) {
                overrideContainer.classList.remove('hidden');
                reasonText.setAttribute('required', 'required');
            } else {
                overrideContainer.classList.add('hidden');
                reasonText.removeAttribute('required');
            }
        }
    }

    function renderCardPrebookedBookings(sanId) {
        const prebookedSection = document.getElementById(`card-prebooked-section-\${sanId}`);
        const prebookedList = document.getElementById(`card-prebooked-list-\${sanId}`);
        if (!prebookedSection || !prebookedList) return;

        const courtBookings = localDanhSachLich.filter(b => b.sanId === sanId && (b.trangThai === 'Đã xác nhận' || b.trangThai === 'Chờ xác nhận'));
        if (courtBookings.length === 0) {
            prebookedSection.classList.add('hidden');
            prebookedList.innerHTML = '';
        } else {
            prebookedSection.classList.remove('hidden');
            prebookedList.innerHTML = '';
            courtBookings.forEach(b => {
                const statusBadgeClass = b.trangThaiThanhToan === 'Đã thanh toán' ? 'badge-green' : 'badge-amber';
                prebookedList.insertAdjacentHTML('beforeend', `
                    <div class="p-1.5 \${themeBgLight} border \${themeBorder} rounded flex flex-col gap-0.5 text-[9px] mb-1">
                        <div class="flex justify-between items-center font-bold">
                            <span class="text-zinc-800 truncate max-w-[80px]">\${b.tenKhachHang}</span>
                            <span class="text-[7px] px-1 py-0.5 rounded font-mono \${statusBadgeClass}">\${b.trangThaiThanhToan}</span>
                        </div>
                        <div class="text-[8px] text-zinc-500 font-mono flex justify-between items-center">
                            <span>\${b.gioBatDau} - \${b.gioKetThuc}</span>
                            <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="inline-block">
                                <input type="hidden" name="action" value="checkInPreBooked">
                                <input type="hidden" name="datSanId" value="\${b.datSanId}">
                                <input type="hidden" name="daThuTienMat" value="false">
                                <button type="submit" class="\${themeBg} \${themeBgHover} text-white font-extrabold text-[8px] px-1 py-0.5 rounded transition-all active:scale-95">
                                    Mở
                                </button>
                            </form>
                        </div>
                    </div>
                `);
            });
        }
    }

    // --- Side Drawer Functions ---
    let activeDrawerSanId = null;

    function getLocalTimeString(timeVal) {
        if (!timeVal) return '';
        if (typeof timeVal === 'string') return timeVal;
        if (typeof timeVal === 'object' && timeVal.hour !== undefined) {
            const h = String(timeVal.hour).padStart(2, '0');
            const m = String(timeVal.minute).padStart(2, '0');
            return `\${h}:\${m}:00`;
        }
        return '';
    }

    function onCardClick(event, cardEl) {
        if (event.target.closest('button') || event.target.closest('form')) return;
        const trangThai = cardEl.getAttribute('data-trangthai');
        const sanId = parseInt(cardEl.getAttribute('data-sanid'));
        if (trangThai === 'Sẵn sàng') {
            toggleCardCollapse(event, sanId);
        } else {
            openCourtDetailDrawer(sanId);
        }
    }

    function openCourtDetailDrawer(sanId) {
        activeDrawerSanId = sanId;
        
        const cardEl = document.querySelector('.card[data-sanid="' + sanId + '"]');
        if (!cardEl) return;
        
        const tenSan = cardEl.getAttribute('data-tensan');
        const tenLoaiSan = cardEl.getAttribute('data-loaisan');
        const trangThai = cardEl.getAttribute('data-trangthai');
        const moTa = cardEl.getAttribute('data-mota') || '';
        const giaKhongDen = parseFloat(cardEl.getAttribute('data-giakhongden')) || 0;
        const giaCoDen = parseFloat(cardEl.getAttribute('data-giacoden')) || 0;
        const gioBatDauLenDen = cardEl.getAttribute('data-giobatdaulenden') || '';
        const gioKetThucLenDen = cardEl.getAttribute('data-giokethuclenden') || '';
        const datSanIdActive = cardEl.getAttribute('data-datsanidactive');
        const gioBatDauActive = cardEl.getAttribute('data-giobatdauactive');
        
        // Update Drawer elements
        document.getElementById('drawer-court-name').textContent = tenSan;
        document.getElementById('drawer-court-type').textContent = tenLoaiSan;
        document.getElementById('drawer-court-id').textContent = sanId;
        document.getElementById('drawer-court-coso').textContent = 'CS' + '${sessionScope.user.coSoId}';
        document.getElementById('drawer-price-nolite').textContent = formatCurrency(giaKhongDen);
        document.getElementById('drawer-price-lite').textContent = formatCurrency(giaCoDen);
        document.getElementById('drawer-light-time').textContent = gioBatDauLenDen && gioKetThucLenDen ? (gioBatDauLenDen.substring(0,5) + ' - ' + gioKetThucLenDen.substring(0,5)) : 'Không có cấu hình';
        
        const descContainer = document.getElementById('drawer-desc-container');
        if (moTa && moTa !== 'null') {
            descContainer.classList.remove('hidden');
            document.getElementById('drawer-court-desc').textContent = moTa;
        } else {
            descContainer.classList.add('hidden');
        }
        
        // Set Status Badge
        const statusBadge = document.getElementById('drawer-court-status-badge');
        statusBadge.textContent = trangThai;
        if (trangThai === 'Sẵn sàng') {
            statusBadge.className = 'badge badge-green';
        } else if (trangThai === 'Đang sử dụng') {
            statusBadge.className = 'badge ' + '${badgeTheme}';
        } else if (trangThai === 'Bảo trì') {
            statusBadge.className = 'badge badge-amber';
        } else {
            statusBadge.className = 'badge badge-red';
        }
        
        // Hide all action blocks first
        document.getElementById('drawer-action-walkin').classList.add('hidden');
        document.getElementById('drawer-action-active').classList.add('hidden');
        document.getElementById('drawer-action-disabled').classList.add('hidden');
        const prebookedSection = document.getElementById('drawer-action-prebooked');
        if (prebookedSection) prebookedSection.classList.add('hidden');
        
        if (trangThai === 'Sẵn sàng') {
            document.getElementById('drawer-action-walkin').classList.remove('hidden');
            document.getElementById('drawer-walkin-san-id').value = sanId;
            
            // Reset playMode selection to FIXED and duration to 120
            const fixedRadio = document.querySelector('#courtDetailDrawer input[name="playMode"][value="FIXED"]');
            if (fixedRadio) {
                fixedRadio.checked = true;
            }
            setDrawerPlayMode('FIXED');
            setDrawerDuration(120);

            // Filter bookings for this court today
            const courtBookings = localDanhSachLich.filter(b => b.sanId === sanId && (b.trangThai === 'Đã xác nhận' || b.trangThai === 'Chờ xác nhận'));
            const prebookedList = document.getElementById('drawer-prebooked-list');
            if (prebookedSection && prebookedList) {
                prebookedSection.classList.remove('hidden');
                prebookedList.innerHTML = '';
                if (courtBookings.length === 0) {
                    prebookedList.innerHTML = `
                        <div class="py-4 text-center text-zinc-400 text-xs italic bg-zinc-50 rounded-xl border border-dashed border-zinc-200">
                            Không có lịch đặt trước cho sân này hôm nay.
                        </div>
                    `;
                } else {
                    courtBookings.forEach(b => {
                        const statusBadgeClass = b.trangThaiThanhToan === 'Đã thanh toán' ? 'badge-green' : 'badge-amber';
                        prebookedList.insertAdjacentHTML('beforeend', `
                            <div class="p-3.5 \${themeBgLight} border \${themeBorder} rounded-2xl flex flex-col gap-2 hover:bg-\${isManager ? 'purple' : 'orange'}-100/30 transition-all">
                                <div class="flex justify-between items-start">
                                    <div>
                                        <div class="font-black text-xs text-zinc-800 flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[14px] \${themeIcon}">person</span>
                                            \${b.tenKhachHang}
                                        </div>
                                        <div class="text-[10px] text-zinc-500 mt-1 flex items-center gap-1 font-mono">
                                            <span class="material-symbols-outlined text-[12px] text-zinc-400">schedule</span>
                                            \${b.gioBatDau} - \${b.gioKetThuc}
                                        </div>
                                    </div>
                                    <span class="badge \${statusBadgeClass} text-[9px] font-bold tracking-tight uppercase">\${b.trangThaiThanhToan}</span>
                                </div>
                                <div class="flex justify-between items-center pt-2 border-t \${themeBorder}">
                                    <span class="text-[10px] text-zinc-550 font-semibold uppercase tracking-wider bg-zinc-150 px-2 py-0.5 rounded">Nguồn: \${b.nguonDatSan}</span>
                                    <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="inline-block">
                                        <input type="hidden" name="action" value="checkInPreBooked">
                                        <input type="hidden" name="datSanId" value="\${b.datSanId}">
                                        <input type="hidden" name="daThuTienMat" value="false">
                                        <button type="submit" class="\${themeBg} \${themeBgHover} text-white font-extrabold text-[10px] px-3.5 py-1.5 rounded-xl shadow-sm hover:shadow transition-all active:scale-95 flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[12px]">power_settings_new</span>
                                            Mở sân ngay
                                        </button>
                                    </form>
                                </div>
                            </div>
                        `);
                    });
                }
            }
            
            // Set base rates
            const now = new Date();
            const currentTimeStr = now.toTimeString().split(' ')[0];
            let rate = giaKhongDen;
            let isLite = false;
            
            if (gioBatDauLenDen && gioKetThucLenDen) {
                if (currentTimeStr >= gioBatDauLenDen && currentTimeStr <= gioKetThucLenDen) {
                    rate = giaCoDen;
                    isLite = true;
                }
            }
            
            const rateInput = document.getElementById('drawer-walkin-rate');
            rateInput.value = rate;
            rateInput.setAttribute('data-base', rate);
            rateInput.setAttribute('data-giakhongden', giaKhongDen);
            rateInput.setAttribute('data-giacoden', giaCoDen);
            rateInput.setAttribute('data-giobatdaulenden', gioBatDauLenDen);
            rateInput.setAttribute('data-giokethuclenden', gioKetThucLenDen);
            
            const rateTypeSpan = document.getElementById('drawer-walkin-rate-type');
            rateTypeSpan.textContent = `Áp dụng: \${isLite ? 'Giá có đèn' : 'Giá không đèn'}`;
            
            calculateDrawerPrice();
            
            // Auto focus duration
            setTimeout(() => {
                document.getElementById('drawer-walkin-duration').focus();
            }, 100);
            
        } else if (trangThai === 'Đang sử dụng') {
            document.getElementById('drawer-action-active').classList.remove('hidden');
            document.getElementById('drawer-active-id').textContent = datSanIdActive || '-';
            document.getElementById('drawer-active-start').textContent = gioBatDauActive || '-';
            
            // Set datSanId on the stop session form
            document.getElementById('drawer-stop-datsan-id').value = datSanIdActive || '';
            
            // Determine playing mode
            const gioKetThucActive = cardEl.getAttribute('data-giokethucactive') || '';
            const ghiChuActive = cardEl.getAttribute('data-ghichuactive') || '';
            const isOpenMode = ghiChuActive.includes('Không cố định');
            
            // Display playing mode
            const activeModeEl = document.getElementById('drawer-active-mode');
            if (activeModeEl) {
                activeModeEl.textContent = isOpenMode ? 'Giờ không cố định' : 'Giờ cố định';
            }
            
            // Show/Hide Stop Session button depending on mode
            const stopFormEl = document.getElementById('drawer-stop-session-form');
            if (stopFormEl) {
                if (isOpenMode) {
                    stopFormEl.classList.remove('hidden');
                } else {
                    stopFormEl.classList.add('hidden');
                }
            }

            // Calculate start and end dates
            const { startDate, endDate } = getTimerDates(gioBatDauActive, gioKetThucActive);

            // Determine active hourly rate based on whether current time is in light time
            const now = new Date();
            const currentTimeStr = now.toTimeString().split(' ')[0];
            let rate = giaKhongDen;
            if (gioBatDauLenDen && gioKetThucLenDen) {
                if (currentTimeStr >= gioBatDauLenDen && currentTimeStr <= gioKetThucLenDen) {
                    rate = giaCoDen;
                }
            }

            // Estimate baseCourtPrice for fixed mode
            let baseCourtPrice = 0;
            if (!isOpenMode && startDate && endDate) {
                const plannedMins = Math.max(0, Math.floor((endDate - startDate) / 60000));
                baseCourtPrice = (plannedMins / 60.0) * rate;
            }

            // Start the drawer timer loop
            startDrawerTimerLoop(startDate, endDate, isOpenMode, rate, baseCourtPrice);
            
            const payBtn = document.getElementById('drawer-btn-invoice');
            payBtn.onclick = () => {
                if (datSanIdActive && datSanIdActive !== 'null') {
                    openStaffInvoiceModal(parseInt(datSanIdActive));
                } else {
                    alert("Không tìm thấy phiên chơi đang hoạt động của sân này.");
                }
            };
            
        } else {
            document.getElementById('drawer-action-disabled').classList.remove('hidden');
        }
        
        // Open drawer
        const drawer = document.getElementById('courtDetailDrawer');
        const overlay = document.getElementById('drawerOverlay');
        drawer.classList.remove('hidden');
        overlay.classList.remove('hidden');
        setTimeout(() => {
            drawer.classList.remove('translate-x-full');
            overlay.classList.remove('opacity-0');
        }, 10);
    }

    function setDrawerPlayMode(mode) {
        const lblFixed = document.getElementById('drawer-mode-fixed-label');
        const lblOpen = document.getElementById('drawer-mode-open-label');
        const fixedPanel = document.getElementById('drawer-fixed-duration-panel');
        const openNote = document.getElementById('drawer-open-duration-note');
        const durationInput = document.getElementById('drawer-walkin-duration');
        const customHoursInput = document.getElementById('drawer-custom-hours');
        
        if (mode === 'FIXED') {
            if (lblFixed) lblFixed.className = `border-2 ${themeBorderStrong} ${themeBgLight} rounded-xl p-3 cursor-pointer text-xs font-bold ${themeTextMedium} transition-all text-center`;
            if (lblOpen) lblOpen.className = "border-2 border-zinc-150 rounded-xl p-3 cursor-pointer text-xs font-bold text-zinc-700 hover:border-zinc-300 transition-all text-center";
            if (fixedPanel) fixedPanel.classList.remove('hidden');
            if (openNote) openNote.classList.add('hidden');
            
            // Revert duration input to the active button's value
            let activeFixedBtn = document.querySelector(`.drawer-duration-btn.\${themeBorderStrong}`);
            if (activeFixedBtn) {
                const dur = parseInt(activeFixedBtn.getAttribute('data-duration-btn')) || 120;
                if (durationInput) durationInput.value = dur;
            } else {
                if (durationInput) durationInput.value = 120;
            }
            if (customHoursInput) customHoursInput.value = '';
        } else {
            if (lblFixed) lblFixed.className = "border-2 border-zinc-150 rounded-xl p-3 cursor-pointer text-xs font-bold text-zinc-700 hover:border-zinc-300 transition-all text-center";
            if (lblOpen) lblOpen.className = `border-2 ${themeBorderStrong} ${themeBgLight} rounded-xl p-3 cursor-pointer text-xs font-bold ${themeTextMedium} transition-all text-center`;
            if (fixedPanel) fixedPanel.classList.add('hidden');
            if (openNote) openNote.classList.remove('hidden');
            
            // For open mode, we set duration input to 120 minutes by default (which represents the initial conflict checking window, 2 hours)
            if (durationInput) durationInput.value = 120;
        }
        calculateDrawerPrice();
    }
 
    function setDrawerDuration(mins) {
        const durationInput = document.getElementById('drawer-walkin-duration');
        if (durationInput) {
            durationInput.value = mins;
        }
        
        // Highlight active button
        const buttons = document.querySelectorAll('.drawer-duration-btn');
        buttons.forEach(btn => {
            const btnDur = parseInt(btn.getAttribute('data-duration-btn'));
            if (btnDur === mins) {
                btn.className = `drawer-duration-btn py-2 px-1 rounded-lg border \${themeBorderStrong} \${themeBgLight} text-[10px] font-bold \${themeTextMedium}`;
            } else {
                btn.className = "drawer-duration-btn py-2 px-1 rounded-lg border border-zinc-200 text-[10px] font-bold text-zinc-700 hover:bg-zinc-50";
            }
        });
        
        // Clear custom input
        const customHoursInput = document.getElementById('drawer-custom-hours');
        if (customHoursInput) {
            customHoursInput.value = '';
        }
        
        calculateDrawerPrice();
    }
 
    function setDrawerCustomDuration() {
        const customHoursInput = document.getElementById('drawer-custom-hours');
        const durationInput = document.getElementById('drawer-walkin-duration');
        if (!customHoursInput || !durationInput) return;
        
        const hours = parseFloat(customHoursInput.value);
        if (!isNaN(hours) && hours > 0) {
            const mins = Math.round(hours * 60);
            durationInput.value = mins;
            
            // De-select all fixed buttons
            const buttons = document.querySelectorAll('.drawer-duration-btn');
            buttons.forEach(btn => {
                btn.className = "drawer-duration-btn py-2 px-1 rounded-lg border border-zinc-200 text-[10px] font-bold text-zinc-700 hover:bg-zinc-50";
            });
        }
        calculateDrawerPrice();
    }
 
    function calculateDrawerPrice() {
        const durationSelect = document.getElementById('drawer-walkin-duration');
        const rateInput = document.getElementById('drawer-walkin-rate');
        const totalSpan = document.getElementById('drawer-walkin-total');
        if (!durationSelect || !rateInput || !totalSpan) return;
        
        const openRadio = document.querySelector('#courtDetailDrawer input[name="playMode"][value="OPEN"]');
        const isOpen = openRadio && openRadio.checked;
        if (isOpen) {
            totalSpan.textContent = "Tính theo thời gian thực tế";
            const overrideContainer = document.getElementById('drawer-walkin-override-container');
            if (overrideContainer) overrideContainer.classList.add('hidden');
            return;
        }
 
        const duration = parseInt(durationSelect.value) || 0;
        const rate = parseFloat(rateInput.value) || 0;
        const total = (duration / 60.0) * rate;
        
        totalSpan.textContent = formatCurrency(total);
        
        const base = parseFloat(rateInput.getAttribute('data-base')) || 0;
        const overrideContainer = document.getElementById('drawer-walkin-override-container');
        const reasonText = document.getElementById('drawer-walkin-override-reason');
        if (overrideContainer && reasonText) {
            if (rate !== base) {
                overrideContainer.classList.remove('hidden');
                reasonText.setAttribute('required', 'required');
            } else {
                overrideContainer.classList.add('hidden');
                reasonText.removeAttribute('required');
            }
        }
    }

    function closeCourtDetailDrawer() {
        if (drawerTimerInterval) {
            clearInterval(drawerTimerInterval);
            drawerTimerInterval = null;
        }
        activeDrawerSanId = null;
        const drawer = document.getElementById('courtDetailDrawer');
        const overlay = document.getElementById('drawerOverlay');
        
        drawer.classList.add('translate-x-full');
        overlay.classList.add('opacity-0');
        setTimeout(() => {
            drawer.classList.add('hidden');
            overlay.classList.add('hidden');
        }, 300);
    }

    // --- Split Bill ---
    let currentBillMode = 'MAIN';
    let currentMainBillPaid = false;

    function setBillMode(mode) {
        currentBillMode = mode;
        document.getElementById('staff-save-billmode').value = mode;

        const lblMain = document.getElementById('lbl-billmode-main');
        const lblSplit = document.getElementById('lbl-billmode-split');
        const payNowSection = document.getElementById('split-paynow-section');

        if (mode === 'MAIN') {
            if (currentMainBillPaid) {
                lblMain.className = 'bill-mode-card disabled pointer-events-none opacity-50';
            } else {
                lblMain.className = 'bill-mode-card active';
            }
            lblSplit.className = 'bill-mode-card';
            payNowSection.classList.add('hidden');
        } else {
            lblSplit.className = 'bill-mode-card active';
            if (currentMainBillPaid) {
                lblMain.className = 'bill-mode-card disabled pointer-events-none opacity-50';
            } else {
                lblMain.className = 'bill-mode-card';
            }
            payNowSection.classList.remove('hidden');
        }
    }

    function renderSplitBillsList(splitBills) {
        const section = document.getElementById('split-bills-section');
        const list = document.getElementById('split-bills-list');
        if (!splitBills || splitBills.length === 0) {
            section.classList.add('hidden');
            return;
        }
        section.classList.remove('hidden');
        list.innerHTML = '';
        splitBills.forEach(sb => {
            const isPaid = sb.trangThai === 'Đã thanh toán';
            const formattedTotal = formatCurrency(sb.tongThanhToan);
            const payBtnHtml = !isPaid ? (
                '<button type="button" onclick="paySplitBill(' + sb.hoaDonId + ')" ' +
                'class="px-3 py-1.5 rounded-lg bg-green-600 hover:bg-green-700 text-white font-bold text-[10px] active:scale-95 transition-all">' +
                'Thanh toán' +
                '</button>'
            ) : '';
            list.insertAdjacentHTML('beforeend', `
                <div class="p-3 rounded-xl border \${isPaid ? 'border-green-200 bg-green-50' : 'border-amber-200 bg-amber-50'} text-xs flex items-center justify-between gap-2">
                    <div>
                        <span class="font-bold text-zinc-800">HĐ Tách #\${sb.hoaDonId}</span>
                        <span class="text-zinc-500 ml-2">\${sb.ngayLap}</span>
                        <span class="ml-2 \${isPaid ? 'text-green-700' : 'text-amber-700'} font-bold">\${isPaid ? '✓ Đã TT' : '⏳ Chưa TT'}</span>
                        <span class="ml-2 font-extrabold text-zinc-800">\${formattedTotal}</span>
                    </div>
                    \${payBtnHtml}
                </div>
            `);
        });
    }

    function paySplitBill(hoaDonId) {
        if (!confirm('Xác nhận thanh toán hóa đơn tách #' + hoaDonId + '?')) return;
        const form = document.createElement('form');
        form.method = 'post';
        form.action = '${pageContext.request.contextPath}/staff/checkin';
        form.innerHTML = '<input type="hidden" name="action" value="payInvoice">' +
            '<input type="hidden" name="hoaDonId" value="' + hoaDonId + '">' +
            '<input type="hidden" name="phuongThucThanhToan" value="Tiền mặt">';
        document.body.appendChild(form);
        form.submit();
    }

    function prepareAddServicesSubmit() {
        if (staffOrdered.length === 0) {
            alert('Vui lòng chọn ít nhất một sản phẩm.');
            return false;
        }
        const mode = currentBillMode;
        document.getElementById('staff-save-billmode').value = mode;

        if (mode === 'MAIN' && currentMainBillPaid) {
            if (!confirm('Hóa đơn sân đã được thanh toán. Bạn có muốn tạo hóa đơn tách thay thế không?')) {
                return false;
            }
            document.getElementById('staff-save-billmode').value = 'SPLIT';
        }

        if (mode === 'SPLIT' || (mode === 'MAIN' && currentMainBillPaid)) {
            const payNow = document.getElementById('split-pay-now-cb').checked;
            document.getElementById('staff-save-paynow').value = payNow ? 'true' : 'false';
            document.getElementById('staff-save-paymethod').value =
                document.getElementById('staff-pay-method-input').value || 'Tiền mặt';
        }
        return true;
    }

    // Initialize subtotal and event listener for product stock check
    document.addEventListener("DOMContentLoaded", () => {
        updateWalkinSubtotal();
        
        const prodSelect = document.getElementById("staff-product-select");
        const addBtn = document.getElementById("staff-add-service-btn");
        if (prodSelect) {
            prodSelect.addEventListener("change", function() {
                const selectedOption = this.options[this.selectedIndex];
                if (!selectedOption || !selectedOption.value) {
                    if (addBtn) {
                        addBtn.removeAttribute("disabled");
                        addBtn.textContent = "Thêm";
                    }
                    return;
                }
                
                const spId = parseInt(selectedOption.value);
                const prod = staffProducts.find(p => p.SanPhamID === spId);
                if (prod && prod.SoLuongTon <= 0) {
                    if (addBtn) {
                        addBtn.setAttribute("disabled", "disabled");
                        addBtn.textContent = "Hết hàng";
                    }
                } else {
                    if (addBtn) {
                        addBtn.removeAttribute("disabled");
                        addBtn.textContent = "Thêm";
                    }
                }
            });
        }
    });
</script>

<c:if test="${not empty autoOpenInvoiceDatSanId}">
    <script>
        document.addEventListener("DOMContentLoaded", () => {
            setTimeout(() => {
                openStaffInvoiceModal(${autoOpenInvoiceDatSanId});
            }, 600);
        });
    </script>
</c:if>

</body>
</html>
