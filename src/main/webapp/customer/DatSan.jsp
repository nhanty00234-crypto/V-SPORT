<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%
    // Trang này phải được servlet nạp dữ liệu trước khi render
    if (request.getAttribute("dsSan") == null) {
        response.sendRedirect(request.getContextPath() + "/customer/dat-san");
        return;
    }
%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>Đặt Sân - V-SPORT Elite Arena</title>
    <jsp:include page="/common/head.jsp" />
    <style>
        .filter-btn.active,
        .branch-filter-btn.active {
            background-color: #16a34a !important;
            color: white !important;
            border-color: #16a34a !important;
        }
        .filter-btn:not(.active):hover,
        .branch-filter-btn:not(.active):hover {
            background-color: #f8fafc !important;
        }
        .court-card {
            transition: all 0.2s ease-in-out;
        }
        .court-card:hover {
            box-shadow: 0 10px 25px rgba(0,0,0,0.05);
            transform: translateY(-2px);
            border-color: rgba(22, 163, 74, 0.2);
        }
        .form-input {
            width: 100%;
            padding: 0.75rem 1rem;
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            color: #1e293b;
            transition: all 0.2s ease;
            font-size: 0.9375rem;
        }
        .form-input:focus {
            border-color: #16a34a;
            box-shadow: 0 0 0 3px rgba(22, 163, 74, 0.1);
            outline: none;
            background-color: white;
        }
        .form-label {
            display: block;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            color: #64748b;
            margin-bottom: 0.5rem;
        }
    </style>
</head>
<body class="bg-[#f4f6f8] text-[#1e293b] min-h-screen flex flex-col antialiased">

    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[120px] pb-24">
        <div class="max-w-[1280px] mx-auto px-4 sm:px-6">
            
            <!-- Page Header -->
            <div class="mb-8 flex flex-col sm:flex-row justify-between items-start sm:items-end gap-4 animate-fade-in-up">
                <div>
                    <h1 class="text-3xl sm:text-4xl font-bold text-[#1e293b] tracking-tight">Tìm và Đặt sân</h1>
                    <p class="mt-2 text-sm text-slate-500">Hệ thống sân bãi hiện đại, cập nhật lịch theo thời gian thực.</p>
                </div>
                <!-- Optional: Search bar or Sorting could go here -->
            </div>

            <!-- Alert Messages -->
            <c:if test="${not empty sessionScope.error}">
                <div class="mb-6 p-4 bg-red-50 border border-red-100 rounded-xl text-red-600 text-sm flex items-start gap-3 shadow-sm animate-fade-in-up">
                    <span class="material-symbols-outlined text-[20px] shrink-0">error</span>
                    <div>
                        <span class="font-bold block">Đặt sân không thành công</span>
                        <span class="text-red-600/80 leading-normal block mt-0.5">${sessionScope.error}</span>
                    </div>
                    <% session.removeAttribute("error"); %>
                </div>
            </c:if>

            <c:if test="${not empty sessionScope.message}">
                <div class="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl text-green-700 text-sm flex items-start gap-3 shadow-sm animate-fade-in-up">
                    <span class="material-symbols-outlined text-[20px] shrink-0">check_circle</span>
                    <div>
                        <span class="font-bold block">Thành công</span>
                        <span class="text-green-700/80 leading-normal block mt-0.5">${sessionScope.message}</span>
                    </div>
                    <% session.removeAttribute("message"); %>
                </div>
            </c:if>

            <!-- Main Layout Grid (Sidebar + List) -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-8 items-start">
                
                <!-- LEFT SIDEBAR: Filters -->
                <div class="lg:col-span-1 space-y-6 lg:sticky lg:top-[120px] animate-fade-in-up">
                    
                    <!-- Sport Type Filter -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800">Môn thể thao</h3>
                        </div>
                        <div class="p-3 flex flex-col gap-1">
                            <button type="button" onclick="filterSport(0)" id="btn-sport-0" class="filter-btn active w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                <span class="material-symbols-outlined text-[20px]">apps</span>
                                Tất cả
                            </button>
                            <c:forEach var="mon" items="${dsMon}">
                                <button type="button" onclick="filterSport(${mon.monTheThaoID})" id="btn-sport-${mon.monTheThaoID}" class="filter-btn w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-slate-600 text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                    <span class="material-symbols-outlined text-[20px]">
                                        <c:choose>
                                            <c:when test="${mon.tenMon == 'Bóng đá'}">sports_soccer</c:when>
                                            <c:when test="${mon.tenMon == 'Cầu lông'}">sports_tennis</c:when>
                                            <c:when test="${mon.tenMon == 'Pickleball'}">sports_tennis</c:when>
                                            <c:when test="${mon.tenMon == 'Tennis'}">sports_tennis</c:when>
                                            <c:otherwise>sports_volleyball</c:otherwise>
                                        </c:choose>
                                    </span>
                                    ${mon.tenMon}
                                </button>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Branch Filter -->
                    <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                        <div class="px-5 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                            <h3 class="font-bold text-slate-800">Chọn Cơ Sở</h3>
                        </div>
                        <div class="p-3 flex flex-col gap-1">
                            <button type="button" onclick="filterBranch(0)" id="btn-branch-0" class="branch-filter-btn active w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                <span class="material-symbols-outlined text-[20px]">map</span>
                                Tất cả Cơ Sở
                            </button>
                            <c:forEach var="cs" items="${dsCoSo}">
                                <button type="button" onclick="filterBranch(${cs.coSoID})" id="btn-branch-${cs.coSoID}" class="branch-filter-btn w-full px-4 py-2.5 rounded-xl text-[14px] font-medium text-slate-600 text-left flex items-center gap-3 transition-colors hover:bg-slate-50">
                                    <span class="material-symbols-outlined text-[20px] shrink-0">location_on</span>
                                    <span class="flex flex-col min-w-0">
                                        <span class="truncate">${cs.tenCoSo}</span>
                                        <span class="text-[11px] text-slate-400 font-normal">${cs.gioMoCua != null ? cs.gioMoCua : '06:00'} - ${cs.gioDongCua != null ? cs.gioDongCua : '23:00'}</span>
                                    </span>
                                </button>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <!-- RIGHT MAIN CONTENT: Court List -->
                <div class="lg:col-span-3 space-y-4 animate-fade-in-up" style="animation-delay: 0.1s">
                    <div class="flex flex-wrap justify-between items-center gap-2 px-1 mb-2">
                        <span class="text-sm text-slate-500 font-medium">Tìm thấy <strong id="court-count" class="text-slate-800">0</strong> sân</span>
                        <span id="court-status-summary" class="text-xs text-slate-500 font-medium"></span>
                    </div>
                    
                    <div id="courts-container" class="flex flex-col gap-5">
                        <!-- Dynamically loaded via JS -->
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- BOOKING & CHECKOUT MODAL FLOW -->
    <!-- OVERLAY -->
    <div id="bookingModalOverlay" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        
        <!-- STEP 1: BOOKING FORM PANEL -->
        <div id="bookingFormPanel" class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            
            <div class="bg-green-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <span class="material-symbols-outlined">event_available</span> Đăng ký đặt sân
                </h3>
                <button onclick="closeBookingModal()" class="text-white/80 hover:text-white transition-colors p-1">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>

            <div class="p-6 md:p-8">
                <!-- Selected Court Info -->
                <div class="flex items-start gap-4 p-4 bg-slate-50 rounded-2xl border border-slate-100 mb-6">
                    <div>
                        <h4 id="modal-court-name" class="font-bold text-slate-800 text-lg">Tên sân</h4>
                        <p id="modal-court-branch" class="text-sm text-slate-500 flex items-center gap-1 mt-1">
                            <span class="material-symbols-outlined text-[16px]">location_on</span> Cơ sở
                        </p>
                        <p id="modal-court-type" class="text-xs font-semibold text-green-600 mt-2 bg-green-50 px-2 py-1 rounded-md inline-block">Loại sân</p>
                        <p id="modal-court-status" class="text-xs font-bold mt-2 inline-flex items-center gap-1.5 px-2 py-1 rounded-md"></p>
                    </div>
                </div>

                <form id="booking-form" action="${pageContext.request.contextPath}/customer/dat-san" method="post" class="space-y-5">
                    <input type="hidden" name="sanId" id="input-san-id" required>
                    <input type="hidden" name="paymentMethod" id="input-payment-method" value="sau">

                    <div id="branch-hours-info" class="flex items-center gap-2 text-sm text-slate-600 bg-blue-50 border border-blue-100 rounded-xl px-4 py-3">
                        <span class="material-symbols-outlined text-[18px] text-blue-600 shrink-0">schedule</span>
                        <span>Giờ hoạt động: <strong id="modal-branch-hours" class="text-slate-800">--:-- - --:--</strong></span>
                    </div>

                    <div class="space-y-1.5">
                        <label for="ngayDat" class="form-label">Ngày thi đấu <span class="text-red-500">*</span></label>
                        <input type="date" name="ngayDat" id="ngayDat" required class="form-input" onchange="onBookingDateChange()">
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div class="space-y-1.5">
                            <label for="gioBatDau" class="form-label">Giờ bắt đầu <span class="text-red-500">*</span></label>
                            <input type="time" name="gioBatDau" id="gioBatDau" required class="form-input" onchange="checkScheduleAndPrice()">
                        </div>
                        <div class="space-y-1.5">
                            <label for="gioKetThuc" class="form-label">Giờ kết thúc <span class="text-red-500">*</span></label>
                            <input type="time" name="gioKetThuc" id="gioKetThuc" required class="form-input" onchange="checkScheduleAndPrice()">
                        </div>
                    </div>

                    <!-- Timetable Preview Block -->
                    <div id="timetable-block" class="hidden mt-2">
                        <label class="form-label text-amber-600">Lịch đã có người đặt trong ngày</label>
                        <div id="timeline-slots" class="flex flex-wrap gap-2 mt-2">
                            <!-- Slots go here -->
                        </div>
                    </div>
                    
                    <div id="overlap-warning" class="bg-red-50 border border-red-200 text-red-600 p-3 rounded-xl text-sm hidden flex gap-2 items-start mt-2 shadow-sm">
                        <span class="material-symbols-outlined text-[18px] mt-0.5">warning</span>
                        <span id="overlap-warning-text">Trùng lịch!</span>
                    </div>

                    <div class="space-y-1.5">
                        <label for="ghiChu" class="form-label">Ghi chú yêu cầu</label>
                        <textarea name="ghiChu" id="ghiChu" rows="2" class="form-input resize-none" placeholder="Thuê bóng, mượn áo tập..."></textarea>
                    </div>

                    <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
                        <button type="button" onclick="closeBookingModal()" class="px-6 py-3 rounded-xl font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
                            Hủy
                        </button>
                        
                        <c:choose>
                            <c:when test="${sessionScope.user != null}">
                                <button type="button" id="next-checkout-btn" onclick="goToCheckout()" disabled
                                        class="px-8 py-3 rounded-xl font-bold text-white bg-green-600 hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2">
                                    Tiếp tục thanh toán <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                                </button>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/dangnhap"
                                   class="px-8 py-3 rounded-xl font-bold text-white bg-blue-600 hover:bg-blue-700 transition-colors flex items-center gap-2">
                                    Đăng nhập để đặt sân <span class="material-symbols-outlined text-[18px]">login</span>
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </div>
        </div>

        <!-- STEP 2: CHECKOUT PAYMENT PANEL -->
        <div id="checkoutPanel" class="bg-white w-full max-w-md rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 hidden relative my-auto">
            <div class="px-6 py-4 flex items-center gap-3 border-b border-slate-100">
                <button onclick="backToBookingForm()" class="p-1.5 text-slate-400 hover:text-slate-800 bg-slate-50 hover:bg-slate-100 rounded-full transition-colors flex items-center justify-center">
                    <span class="material-symbols-outlined text-[20px]">arrow_back</span>
                </button>
                <h3 class="font-bold text-slate-800 text-lg">Thanh toán đặt sân</h3>
            </div>

            <div class="p-6">
                <!-- Summary -->
                <div class="bg-slate-50 rounded-2xl p-4 border border-slate-100 mb-6 space-y-2 text-sm">
                    <div class="flex justify-between text-slate-600">
                        <span>Thời gian chơi</span>
                        <span id="summary-duration" class="font-bold text-slate-800">-</span>
                    </div>
                    <div class="flex justify-between text-slate-600">
                        <span>Đơn giá</span>
                        <span id="summary-rate" class="font-bold text-slate-800">-</span>
                    </div>
                    <div id="summary-lights-row" class="flex justify-between text-amber-600 hidden">
                        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[16px]">wb_twilight</span> Phụ thu đèn tối</span>
                        <span class="font-bold">Có áp dụng</span>
                    </div>
                    <div class="pt-3 mt-1 border-t border-slate-200 flex justify-between items-end">
                        <span class="text-xs font-bold uppercase text-slate-500">Tổng cộng</span>
                        <span id="summary-total" class="text-2xl font-bold text-green-600">-</span>
                    </div>
                </div>

                <!-- Pay Later Panel -->
                <div id="sauPanel" class="bg-slate-50 border border-slate-200 rounded-2xl p-6 text-center flex flex-col items-center justify-center gap-3">
                    <div class="w-12 h-12 bg-white text-slate-600 rounded-full flex items-center justify-center shadow-sm"><span class="material-symbols-outlined text-[24px]">schedule</span></div>
                    <div>
                        <p class="text-sm font-bold text-slate-800">Chờ duyệt yêu cầu</p>
                        <p class="text-xs text-slate-500 mt-2 leading-relaxed">Admin sẽ duyệt yêu cầu của bạn. Vui lòng thanh toán tại quầy khi đến sân.</p>
                    </div>
                </div>

                <button onclick="confirmBooking()" class="w-full mt-6 bg-green-600 hover:bg-green-700 text-white font-bold h-12 rounded-xl text-[14px] transition-colors shadow-md shadow-green-600/20 flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">verified</span> Hoàn tất đặt sân
                </button>
            </div>
        </div>
    </div>

    <jsp:include page="/common/footer.jsp" />

    <!-- JavaScript Bridges and UI Handling -->
    <script>
        // Set min date of picker to today
        const dateInput = document.getElementById('ngayDat');
        const todayStr = new Date().toISOString().split('T')[0];
        dateInput.min = todayStr;
        dateInput.value = todayStr;

        // 1. Data bridge from Java context
        const DEFAULT_OPEN_TIME = "06:00";
        const DEFAULT_CLOSE_TIME = "23:00";

        const branches = {
            <c:forEach var="cs" items="${dsCoSo}" varStatus="status">
                "${cs.coSoID}": {
                    id: ${cs.coSoID},
                    name: `${fn:replace(fn:escapeXml(cs.tenCoSo), '`', '\\`')}`,
                    address: `${fn:replace(fn:escapeXml(cs.diaChi), '`', '\\`')}`,
                    openTime: "${cs.gioMoCua != null ? cs.gioMoCua : '06:00:00'}",
                    closeTime: "${cs.gioDongCua != null ? cs.gioDongCua : '23:00:00'}"
                }${not status.last ? ',' : ''}
            </c:forEach>
        };

        const sports = {
            <c:forEach var="m" items="${dsMon}" varStatus="status">
                "${m.monTheThaoID}": `${fn:replace(fn:escapeXml(m.tenMon), '`', '\\`')} `.trim()${not status.last ? ',' : ''}
            </c:forEach>
        };

        const courtTypes = {
            <c:forEach var="l" items="${dsLoai}" varStatus="status">
                "${l.loaiSanID}": {
                    id: ${l.loaiSanID},
                    sportId: ${l.monTheThaoID},
                    name: `${fn:replace(fn:escapeXml(l.tenLoai), '`', '\\`')} `.trim(),
                    priceDay: ${l.giaKhongDen},
                    priceNight: ${l.giaCoDen},
                    lightTime: `${l.gioBatDauLenDen}`, // HH:mm:ss format
                    branchId: ${l.coSoID != null ? l.coSoID : 'null'}
                }${not status.last ? ',' : ''}
            </c:forEach>
        };

        const courts = [
            <c:forEach var="s" items="${dsSan}" varStatus="status">
                {
                    id: ${s.sanID},
                    name: `${fn:replace(fn:escapeXml(s.tenSan), '`', '\\`')} `.trim(),
                    typeId: ${s.loaiSanID},
                    branchId: ${s.coSoID},
                    status: `${fn:replace(fn:escapeXml(s.trangThai), '`', '\\`')} `.trim(),
                    desc: `${fn:replace(fn:escapeXml(s.moTa), '`', '\\`')} `.trim(),
                    image: `${fn:replace(fn:escapeXml(s.hinhAnh != null ? s.hinhAnh : ''), '`', '\\`')} `.trim()
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];

        const activeBookings = [
            <c:forEach var="b" items="${activeBookings}" varStatus="status">
                {
                    id: ${b.datSanId},
                    sanId: ${b.sanId != null ? b.sanId : 'null'},
                    date: `${b.ngayDat}`,
                    start: `${b.gioBatDau}`,
                    end: `${b.gioKetThuc}`,
                    status: `${fn:escapeXml(b.trangThai)} `.trim()
                }${not status.last ? ',' : ''}
            </c:forEach>
        ];

        // 2. State management
        let selectedBranchId = 0;
        let selectedSportId = 0;
        let selectedCourtId = null;
        let currentTotalCost = 0;

        // Parse query parameters
        const urlParams = new URLSearchParams(window.location.search);
        const paramSportId = parseInt(urlParams.get('sportId')) || 0;
        const paramBranchId = parseInt(urlParams.get('branchId')) || 0;
        const paramDate = urlParams.get('date');

        if (paramBranchId) selectedBranchId = paramBranchId;
        if (paramSportId) selectedSportId = paramSportId;
        if (paramDate) dateInput.value = paramDate;

        // 3. Render Courts in Horizontal List
        function getCourtStatusInfo(status) {
            const s = (status || '').trim();
            if (s === 'Sẵn sàng') {
                return { label: 'Trống sân', bookable: true, badgeClass: 'bg-emerald-50 text-emerald-700 border border-emerald-200', dotClass: 'bg-emerald-500' };
            }
            if (s === 'Đang dùng') {
                return { label: 'Đang dùng', bookable: false, badgeClass: 'bg-amber-50 text-amber-700 border border-amber-200', dotClass: 'bg-amber-500 animate-pulse' };
            }
            if (s === 'Bảo trì' || s === 'Đang bảo trì' || s === 'Tạm đóng') {
                return { label: s, bookable: false, badgeClass: 'bg-red-50 text-red-700 border border-red-200', dotClass: 'bg-red-500' };
            }
            return { label: s || 'Không rõ', bookable: false, badgeClass: 'bg-slate-50 text-slate-600 border border-slate-200', dotClass: 'bg-slate-400' };
        }

        function buildStatusBadge(statusInfo) {
            return '<span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-lg text-[10px] font-bold uppercase tracking-wider ' + statusInfo.badgeClass + '">' +
                '<span class="w-1.5 h-1.5 rounded-full shrink-0 ' + statusInfo.dotClass + '"></span>' +
                statusInfo.label + '</span>';
        }

        function renderCourts() {
            const container = document.getElementById("courts-container");
            container.innerHTML = "";

            // Filter courts array
            const filteredCourts = courts.filter(c => {
                const matchBranch = (selectedBranchId === 0 || c.branchId === selectedBranchId);
                const type = courtTypes[c.typeId];
                const matchSport = (selectedSportId === 0 || (type && type.sportId === selectedSportId));
                return matchBranch && matchSport;
            });

            document.getElementById("court-count").textContent = filteredCourts.length;

            const availableCount = filteredCourts.filter(c => c.status === 'Sẵn sàng').length;
            const inUseCount = filteredCourts.filter(c => c.status === 'Đang dùng').length;
            const otherCount = filteredCourts.length - availableCount - inUseCount;
            const summaryParts = [];
            if (availableCount > 0) summaryParts.push('<span class="text-emerald-600">' + availableCount + ' trống</span>');
            if (inUseCount > 0) summaryParts.push('<span class="text-amber-600">' + inUseCount + ' đang dùng</span>');
            if (otherCount > 0) summaryParts.push('<span class="text-red-500">' + otherCount + ' không khả dụng</span>');
            document.getElementById("court-status-summary").innerHTML = summaryParts.join(' · ');

            if (filteredCourts.length === 0) {
                container.innerHTML = `
                    <div class="bg-white rounded-3xl p-12 text-center border border-slate-200">
                        <span class="material-symbols-outlined text-[64px] text-slate-200 block mb-4">search_off</span>
                        <p class="text-base text-slate-500 font-medium">Không tìm thấy sân đấu phù hợp với bộ lọc.</p>
                        <button onclick="filterBranch(0); filterSport(0);" class="mt-4 text-green-600 font-bold hover:underline">Xóa bộ lọc</button>
                    </div>
                `;
                return;
            }

            filteredCourts.forEach(c => {
                const type = courtTypes[c.typeId] || { name: "Chưa phân loại", priceDay: 100000, priceNight: 100000 };
                const branch = branches[c.branchId] || { name: "Cơ Sở chung", address: "", openTime: DEFAULT_OPEN_TIME, closeTime: DEFAULT_CLOSE_TIME };
                const sportName = sports[type.sportId] || "Thể thao";
                const statusInfo = getCourtStatusInfo(c.status);
                const statusBadge = buildStatusBadge(statusInfo);
                const priceText = type.priceDay.toLocaleString('vi-VN') + 'đ';
                const bookBtnLabel = statusInfo.bookable ? 'Đặt sân' : statusInfo.label;

                const cardHtml = `
                    <div class="court-card bg-white rounded-2xl border border-slate-200 overflow-hidden \${statusInfo.bookable ? '' : 'opacity-90'}">
                        <div class="p-5 flex flex-col flex-grow justify-between gap-4">
                            <div>
                                <div class="flex flex-wrap items-center gap-2 mb-2">
                                    <span class="px-2.5 py-1 rounded-lg bg-green-50 text-green-700 text-[10px] font-bold uppercase tracking-wider">\${sportName}</span>
                                    \${statusBadge}
                                </div>
                                <div class="flex justify-between items-start gap-2">
                                    <h3 class="text-xl font-bold text-slate-800 leading-tight">\${c.name}</h3>
                                </div>
                                <p class="text-[13px] text-slate-500 mt-1 flex items-center gap-1">
                                    <span class="material-symbols-outlined text-[15px]">location_on</span>
                                    \${branch.name} <span class="text-slate-300 mx-1">•</span> \${type.name}
                                </p>
                                <p class="text-[12px] text-slate-400 mt-1 flex items-center gap-1">
                                    <span class="material-symbols-outlined text-[14px]">schedule</span>
                                    \${normalizeTime(branch.openTime)} - \${normalizeTime(branch.closeTime)}
                                </p>
                                <p class="text-[13.5px] text-slate-600 mt-3 line-clamp-2">\${c.desc || 'Sân tiêu chuẩn chất lượng cao.'}</p>
                            </div>
                            
                            <div class="flex items-end justify-between border-t border-slate-100 pt-4 mt-auto">
                                <div>
                                    <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider block mb-0.5">Giá thuê từ</span>
                                    <span class="text-[18px] font-bold text-green-600">\${priceText}<span class="text-sm font-normal text-slate-500">/h</span></span>
                                </div>
                                <button type="button" 
                                    onclick="\${statusInfo.bookable ? 'openBookingModal(' + c.id + ')' : ''}" 
                                    \${statusInfo.bookable ? '' : 'disabled'}
                                    class="px-6 py-2.5 bg-green-600 text-white rounded-xl text-sm font-bold transition-all hover:bg-green-700 hover:shadow-lg hover:shadow-green-600/30 disabled:bg-slate-300 disabled:text-slate-500 disabled:shadow-none flex items-center gap-2">
                                    <span class="material-symbols-outlined text-[18px]">\${statusInfo.bookable ? 'calendar_add_on' : 'block'}</span>
                                    \${bookBtnLabel}
                                </button>
                            </div>
                        </div>
                    </div>
                `;
                container.insertAdjacentHTML("beforeend", cardHtml);
            });
        }

        // 4. Filters Interaction
        function filterBranch(branchId) {
            selectedBranchId = branchId;
            document.querySelectorAll(".branch-filter-btn").forEach(btn => {
                btn.classList.remove("active");
                btn.style.backgroundColor = '';
                btn.style.color = '';
            });
            const activeBtn = document.getElementById(`btn-branch-${branchId}`);
            if (activeBtn) {
                activeBtn.classList.add("active");
                activeBtn.style.backgroundColor = '#16a34a';
                activeBtn.style.color = '#ffffff';
            }
            renderCourts();
        }

        function filterSport(sportId) {
            selectedSportId = sportId;
            document.querySelectorAll(".filter-btn").forEach(btn => {
                btn.classList.remove("active");
                btn.style.backgroundColor = '';
                btn.style.color = '';
            });
            const activeBtn = document.getElementById(`btn-sport-${sportId}`);
            if (activeBtn) {
                activeBtn.classList.add("active");
                activeBtn.style.backgroundColor = '#16a34a';
                activeBtn.style.color = '#ffffff';
            }
            renderCourts();
        }

        // 5. Booking Flow & Modal
        function openBookingModal(courtId) {
            selectedCourtId = courtId;
            document.getElementById("input-san-id").value = courtId;
            
            const court = courts.find(c => c.id === courtId);
            if (!court) return;

            const type = courtTypes[court.typeId];
            const branch = branches[court.branchId];

            // Setup Modal Header
            document.getElementById("modal-court-name").textContent = court.name;
            document.getElementById("modal-court-branch").innerHTML = `<span class="material-symbols-outlined text-[16px]">location_on</span> \${branch.name}`;
            document.getElementById("modal-court-type").textContent = type.name;

            const statusInfo = getCourtStatusInfo(court.status);
            const modalStatusEl = document.getElementById("modal-court-status");
            modalStatusEl.className = 'text-xs font-bold mt-2 inline-flex items-center gap-1.5 px-2 py-1 rounded-md ' + statusInfo.badgeClass;
            modalStatusEl.innerHTML = '<span class="w-1.5 h-1.5 rounded-full ' + statusInfo.dotClass + '"></span>' + statusInfo.label;

            // Reset inputs & apply giờ mở/đóng cửa theo cơ sở
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").value = "";
            applyBranchTimeConstraints(court.branchId);
            document.getElementById("timetable-block").classList.add("hidden");
            document.getElementById("overlap-warning").classList.add("hidden");
            const btnNext = document.getElementById("next-checkout-btn");
            if (btnNext) btnNext.disabled = true;

            // Show Overlay & Form Panel
            const overlay = document.getElementById("bookingModalOverlay");
            const formPanel = document.getElementById("bookingFormPanel");
            const checkoutPanel = document.getElementById("checkoutPanel");

            overlay.classList.remove("hidden");
            checkoutPanel.classList.add("hidden");
            formPanel.classList.remove("hidden");

            // Trigger animation
            setTimeout(() => {
                overlay.classList.remove("opacity-0");
                formPanel.classList.remove("scale-95");
            }, 10);
            
            checkScheduleAndPrice();
        }

        function closeBookingModal() {
            const overlay = document.getElementById("bookingModalOverlay");
            const panels = document.querySelectorAll("#bookingFormPanel, #checkoutPanel");
            
            overlay.classList.add("opacity-0");
            panels.forEach(p => p.classList.add("scale-95"));

            setTimeout(() => {
                overlay.classList.add("hidden");
            }, 300);
        }

        function checkScheduleAndPrice() {
            const courtId = selectedCourtId;
            const dateVal = document.getElementById("ngayDat").value;
            const startVal = document.getElementById("gioBatDau").value;
            const endVal = document.getElementById("gioKetThuc").value;

            if (!courtId || !dateVal) return;

            const btnNext = document.getElementById("next-checkout-btn");
            const timetableBlock = document.getElementById("timetable-block");
            const timelineSlots = document.getElementById("timeline-slots");
            const warningBox = document.getElementById("overlap-warning");
            const warningText = document.getElementById("overlap-warning-text");

            // Show conflicts for selected date
            const conflicts = activeBookings.filter(b => b.sanId === courtId && b.date === dateVal && b.status !== "Đã hủy");
            
            if (conflicts.length > 0) {
                timetableBlock.classList.remove("hidden");
                timelineSlots.innerHTML = "";
                conflicts.forEach(b => {
                    const formatTime = (timeStr) => timeStr.substring(0, 5);
                    const slotHtml = `
                        <div class="px-3 py-1.5 bg-amber-50 text-amber-700 border border-amber-200 rounded-lg text-xs font-bold shadow-sm">
                            \${formatTime(b.start)} - \${formatTime(b.end)}
                        </div>
                    `;
                    timelineSlots.insertAdjacentHTML("beforeend", slotHtml);
                });
            } else {
                timetableBlock.classList.add("hidden");
            }

            if (!startVal || !endVal) {
                if (btnNext) btnNext.disabled = true;
                warningBox.classList.add("hidden");
                return;
            }

            const court = courts.find(c => c.id === courtId);
            const branchHours = getBranchHours(court ? court.branchId : null);
            const startMin = timeToMinutes(startVal);
            const endMin = timeToMinutes(endVal);
            const openMin = timeToMinutes(branchHours.openTime);
            const closeMin = timeToMinutes(branchHours.closeTime);

            // Logic validations
            if (endMin <= startMin) {
                warningText.textContent = "Giờ kết thúc phải sau giờ bắt đầu.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            if (startMin < openMin) {
                warningText.textContent = branchHours.name + " mở cửa lúc " + branchHours.openTime + ". Giờ bắt đầu quá sớm.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            if (endMin > closeMin) {
                warningText.textContent = branchHours.name + " đóng cửa lúc " + branchHours.closeTime + ". Giờ kết thúc vượt quá giờ hoạt động.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            if (dateVal === todayStr) {
                const now = new Date();
                const nowMin = now.getHours() * 60 + now.getMinutes();
                if (startMin < nowMin) {
                    warningText.textContent = "Không thể đặt sân cho giờ đã qua trong ngày hôm nay.";
                    warningBox.classList.remove("hidden");
                    if (btnNext) btnNext.disabled = true;
                    return;
                }
            }

            let isOverlapping = false;
            conflicts.forEach(b => {
                const bStart = timeToMinutes(b.start);
                const bEnd = timeToMinutes(b.end);
                if (!(endMin <= bStart || startMin >= bEnd)) {
                    isOverlapping = true;
                }
            });

            if (isOverlapping) {
                warningText.textContent = "Khung giờ bạn chọn đã bị trùng lịch với đơn đặt khác.";
                warningBox.classList.remove("hidden");
                if (btnNext) btnNext.disabled = true;
                return;
            }

            warningBox.classList.add("hidden");
            if (btnNext) btnNext.disabled = false;

            // Calculate cost silently to prepare for checkout
            const type = courtTypes[court.typeId];
            if (type) {
                const lightMin = timeToMinutes(type.lightTime);
                let hourlyRate = type.priceDay;
                let applyLights = false;

                if (startMin >= lightMin) {
                    hourlyRate = type.priceNight;
                    applyLights = type.priceNight !== type.priceDay;
                }

                const durationHours = (endMin - startMin) / 60.0;
                currentTotalCost = Math.round(durationHours * hourlyRate);

                // Populate Checkout Panel data
                document.getElementById("summary-duration").textContent = `\${durationHours.toFixed(1)} giờ (\${formatDurationText(endMin - startMin)})`;
                document.getElementById("summary-rate").textContent = `\${hourlyRate.toLocaleString('vi-VN')} đ/giờ`;
                
                const lightsRow = document.getElementById("summary-lights-row");
                if (applyLights) {
                    lightsRow.classList.remove("hidden");
                } else {
                    lightsRow.classList.add("hidden");
                }

                document.getElementById("summary-total").textContent = `\${currentTotalCost.toLocaleString('vi-VN')} đ`;
            }
        }

        function goToCheckout() {
            const form = document.getElementById('booking-form');
            if (!form.reportValidity()) return;

            const formPanel = document.getElementById("bookingFormPanel");
            const checkoutPanel = document.getElementById("checkoutPanel");

            formPanel.classList.add("scale-95", "opacity-0");
            setTimeout(() => {
                formPanel.classList.add("hidden");
                formPanel.classList.remove("opacity-0"); // Reset for later
                
                checkoutPanel.classList.remove("hidden");
                // slight delay for rendering
                setTimeout(() => {
                    checkoutPanel.classList.remove("scale-95");
                }, 10);
            }, 200);
        }

        function backToBookingForm() {
            const formPanel = document.getElementById("bookingFormPanel");
            const checkoutPanel = document.getElementById("checkoutPanel");

            checkoutPanel.classList.add("scale-95", "opacity-0");
            setTimeout(() => {
                checkoutPanel.classList.add("hidden");
                checkoutPanel.classList.remove("opacity-0");
                
                formPanel.classList.remove("hidden");
                setTimeout(() => {
                    formPanel.classList.remove("scale-95");
                }, 10);
            }, 200);
        }

        function confirmBooking() {
            document.getElementById('booking-form').submit();
        }

        function normalizeTime(timeStr) {
            if (!timeStr) return DEFAULT_OPEN_TIME;
            return timeStr.substring(0, 5);
        }

        function getBranchHours(branchId) {
            const branch = branches[branchId];
            return {
                openTime: normalizeTime(branch?.openTime || DEFAULT_OPEN_TIME),
                closeTime: normalizeTime(branch?.closeTime || DEFAULT_CLOSE_TIME),
                name: branch?.name || "Cơ Sở"
            };
        }

        function getCurrentTimeStr() {
            const now = new Date();
            return String(now.getHours()).padStart(2, "0") + ":" + String(now.getMinutes()).padStart(2, "0");
        }

        function applyBranchTimeConstraints(branchId) {
            const { openTime, closeTime } = getBranchHours(branchId);
            const startInput = document.getElementById("gioBatDau");
            const endInput = document.getElementById("gioKetThuc");
            const hoursLabel = document.getElementById("modal-branch-hours");

            startInput.min = openTime;
            startInput.max = closeTime;
            endInput.min = openTime;
            endInput.max = closeTime;

            if (hoursLabel) {
                hoursLabel.textContent = openTime + " - " + closeTime;
            }

            const dateVal = document.getElementById("ngayDat").value;
            if (dateVal === todayStr && timeToMinutes(getCurrentTimeStr()) > timeToMinutes(openTime)) {
                startInput.min = getCurrentTimeStr();
            }
        }

        function onBookingDateChange() {
            const court = courts.find(c => c.id === selectedCourtId);
            if (court) {
                applyBranchTimeConstraints(court.branchId);
            }
            checkScheduleAndPrice();
        }

        function timeToMinutes(timeStr) {
            const parts = timeStr.split(":");
            return parseInt(parts[0], 10) * 60 + parseInt(parts[1], 10);
        }

        function formatDurationText(totalMinutes) {
            const h = Math.floor(totalMinutes / 60);
            const m = totalMinutes % 60;
            let res = "";
            if (h > 0) res += h + ' tiếng ';
            if (m > 0) res += m + ' phút';
            return res.trim();
        }

        // Init - Debug logging
        console.log('[DatSan] courts loaded from server:', courts.length, courts);
        console.log('[DatSan] courtTypes:', courtTypes);
        console.log('[DatSan] branches:', branches);
        console.log('[DatSan] sports:', sports);
        
        // Render courts first, then apply filters
        renderCourts();
        filterBranch(selectedBranchId);
        filterSport(selectedSportId);
    </script>
</body>
</html>
