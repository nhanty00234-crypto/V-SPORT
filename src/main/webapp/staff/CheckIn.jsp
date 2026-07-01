<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Mở Sân / Check-in | V-SPORT</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts & Material Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
    
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
    </style>
</head>
<body class="bg-zinc-50 text-zinc-900 min-h-screen">

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
            Role: ${isManager ? "Quản lý" : "Lễ tân trực ca"}
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
                <div>
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

    <!-- Welcome & Facility Status Bar -->
    <section class="hero-gradient rounded-2xl border ${themeBorderStrong} p-5 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 relative overflow-hidden">
        <div class="absolute -top-12 -right-12 w-64 h-64 ${isManager ? 'bg-purple-300/10' : 'bg-orange-300/10'} rounded-full blur-3xl pointer-events-none"></div>
        <div>
            <span class="text-[10px] font-extrabold uppercase tracking-widest ${themeTextMedium} block mb-0.5">BẢNG ĐIỀU KHIỂN CHI NHÁNH CƠ SỞ</span>
            <h2 class="text-xl font-black ${themeTextDark} tracking-tight">Kích hoạt & Giám sát sân bãi thời gian thực</h2>
            <p class="text-xs ${themeTextMedium} mt-1">Đảm bảo việc mở sân chính xác và xử lý tranh chấp đặt sân online.</p>
        </div>
        <div class="flex items-center gap-4 bg-white/60 backdrop-blur-md border ${themeBorder} p-3 rounded-xl shadow-sm">
            <div class="text-center px-3 border-r ${themeBorder}">
                <span class="text-[10px] text-zinc-500 font-bold block">TỔNG SỐ SÂN</span>
                <span class="text-lg font-black ${themeTextMedium}">${danhSachSan.size()}</span>
            </div>
            <div class="text-center px-3">
                <span class="text-[10px] text-zinc-500 font-bold block">LỊCH HÔM NAY</span>
                <span class="text-lg font-black ${themeTextMedium}">${danhSachLich.size()}</span>
            </div>
        </div>
    </section>

    <!-- 2. HÌNH ẢNH TRẠNG THÁI SÂN BÃI THỰC TẾ (Real-time Field Status Grid) -->
    <section id="field-status-grid" class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        <c:forEach var="san" items="${danhSachSan}">
            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 <c:if test="${san.trangThai == 'Đang sử dụng'}">border-${isManager ? 'purple-300' : 'orange-300'} shadow-md</c:if>">
                <c:choose>
                    <c:when test="${san.trangThai == 'Đang sử dụng'}">
                        <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full ${isManager ? 'bg-purple-500' : 'bg-orange-500'} live-dot"></span>
                        <div class="w-12 h-12 rounded-2xl ${isManager ? 'bg-purple-50' : 'bg-orange-50'} flex items-center justify-center ${themeIcon} mb-3 shadow-inner">
                            <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                        </div>
                        <h4 class="font-bold text-sm text-zinc-800">${san.tenSan}</h4>
                        <span class="badge ${badgeTheme} mt-2.5 uppercase text-[10px]">Đang sử dụng</span>
                    </c:when>
                    <c:otherwise>
                        <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-green-500"></span>
                        <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center text-green-600 mb-3">
                            <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                        </div>
                        <h4 class="font-bold text-sm text-zinc-800">${san.tenSan}</h4>
                        <span class="badge badge-green mt-2.5 uppercase text-[10px]">Sẵn sàng</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </section>

    <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
        <!-- 3. MỞ SÂN KHÁCH VÃNG LAI (Walk-in Booking Form) -->
        <section class="card p-5 xl:col-span-1 border ${themeBorder} flex flex-col justify-between">
            <div>
                <h3 class="text-base font-black ${themeTextDark} tracking-tight flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined ${themeIcon}">person_add</span>
                    Mở Sân Khách Vãng Lai
                </h3>
                <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="flex flex-col gap-4">
                    <input type="hidden" name="action" value="checkInWalkIn">
                    
                    <div>
                        <label class="block text-xs font-bold text-zinc-650 mb-1.5">Chọn sân mở trống:</label>
                        <select id="walkin-san-select" name="sanId" class="w-full text-xs p-2.5 border border-zinc-200 rounded-xl bg-zinc-50 focus:outline-none ${focusRing} focus:bg-white" required>
                            <option value="">-- Chọn Sân Trống --</option>
                            <c:forEach var="san" items="${danhSachSan}">
                                <c:if test="${san.trangThai == 'Sẵn sàng'}">
                                    <option value="${san.sanID}">${san.tenSan}</option>
                                </c:if>
                            </c:forEach>
                        </select>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-zinc-650 mb-1.5">Thời gian chơi (phút):</label>
                        <select name="duration" class="w-full text-xs p-2.5 border border-zinc-200 rounded-xl bg-zinc-50 focus:outline-none ${focusRing} focus:bg-white" required>
                            <option value="60">60 phút (1 giờ)</option>
                            <option value="90">90 phút (1.5 giờ)</option>
                            <option value="120" selected>120 phút (2 giờ)</option>
                            <option value="150">150 phút (2.5 giờ)</option>
                            <option value="180">180 phút (3 giờ)</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-zinc-650 mb-1.5">Đơn giá sân (VND / giờ):</label>
                        <input type="number" name="donGia" value="200000" step="10000" class="w-full text-xs p-2.5 border border-zinc-200 rounded-xl bg-zinc-50 focus:outline-none ${focusRing} focus:bg-white" required>
                    </div>

                    <button type="submit" class="w-full mt-2 ${themeBg} ${themeBgHover} text-white font-extrabold text-xs py-3 rounded-xl flex items-center justify-center gap-2 shadow-sm transition-all active:scale-95">
                        <span class="material-symbols-outlined text-[16px]">power_settings_new</span>
                        Mở sân vãng lai ngay
                    </button>
                </form>
            </div>
            <div class="mt-5 p-3.5 ${themeBgLight} border ${themeBorder} rounded-xl text-[11px] ${themeTextDark}">
                <strong class="flex items-center gap-1.5 mb-1"><span class="material-symbols-outlined text-[14px]">info</span> Lưu ý kẹt lịch đặt:</strong>
                Hệ thống tự động kiểm tra xem trong khoảng thời gian chơi vãng lai đã chọn có lịch đặt trước online/offline của khách hàng khác hay không trước khi cấp phép mở sân.
            </div>
        </section>

        <!-- 4. DANH SÁCH LỊCH ĐẶT SÂN TRONG NGÀY (Today's Bookings Schedule) -->
        <section class="card p-5 xl:col-span-2 border ${themeBorder} overflow-hidden flex flex-col justify-between">
            <div>
                <h3 class="text-base font-black ${themeTextDark} tracking-tight flex items-center gap-2 mb-4">
                    <span class="material-symbols-outlined ${themeIcon}">calendar_today</span>
                    Lịch Đặt Sân Hôm Nay & Check-in
                </h3>
                <div class="overflow-x-auto rounded-xl border ${themeBorder}">
                    <table class="w-full text-left text-xs border-collapse">
                        <thead>
                            <tr class="${themeBgLight} border-b ${themeBorder} ${themeTextDark} font-bold">
                                <th class="p-3">Sân</th>
                                <th class="p-3">Khách hàng</th>
                                <th class="p-3 text-center">Khung giờ</th>
                                <th class="p-3 text-right">Tổng tiền</th>
                                <th class="p-3 text-center">Nguồn đặt</th>
                                <th class="p-3 text-center">Trạng thái</th>
                                <th class="p-3 text-center">Thanh toán</th>
                                <th class="p-3 text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody id="booking-table-body">
                            <c:choose>
                                <c:when test="${empty danhSachLich}">
                                    <tr>
                                        <td colspan="8" class="p-8 text-center text-zinc-450 italic">Không có lịch đặt sân nào trong ngày hôm nay.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="booking" items="${danhSachLich}">
                                        <tr class="border-b ${themeBorder} hover:bg-${isManager ? 'purple' : 'orange'}-50/10 transition-all">
                                            <td class="p-3 font-semibold text-zinc-800">${booking.tenSan}</td>
                                            <td class="p-3 text-zinc-700">
                                                <div>${booking.tenKhachHang}</div>
                                                <div class="text-[10px] text-zinc-500 italic max-w-[150px] truncate" title="${booking.ghiChu}">${booking.ghiChu}</div>
                                            </td>
                                            <td class="p-3 text-center text-zinc-600 font-mono">
                                                ${booking.gioBatDau.toString().substring(0,5)} - ${booking.gioKetThuc.toString().substring(0,5)}
                                            </td>
                                            <td class="p-3 text-right font-bold ${themeTextDark}">
                                                <fmt:formatNumber value="${booking.tongTien}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </td>
                                            <td class="p-3 text-center">
                                                <span class="badge ${booking.nguonDatSan == 'Walk-in' ? 'badge-gray' : 'badge-blue'}">
                                                    ${booking.nguonDatSan}
                                                </span>
                                            </td>
                                            <td class="p-3 text-center">
                                                <c:choose>
                                                    <c:when test="${booking.trangThai == 'Đang sử dụng'}">
                                                        <span class="badge ${badgeTheme} uppercase">Đang đá</span>
                                                    </c:when>
                                                    <c:when test="${booking.trangThai == 'Đã xác nhận'}">
                                                        <span class="badge badge-green">Đã xác nhận</span>
                                                    </c:when>
                                                    <c:when test="${booking.trangThai == 'Chờ xác nhận'}">
                                                        <span class="badge badge-amber">Chờ duyệt</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-gray">${booking.trangThai}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="p-3 text-center">
                                                <span class="badge ${booking.trangThaiThanhToan == 'Đã thanh toán' ? 'badge-green' : 'badge-amber'}">
                                                    ${booking.trangThaiThanhToan}
                                                </span>
                                            </td>
                                            <td class="p-3 text-center">
                                                <c:if test="${booking.trangThai == 'Đã xác nhận' or booking.trangThai == 'Chờ xác nhận'}">
                                                    <div class="flex items-center justify-center gap-1.5">
                                                        <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="inline-block">
                                                            <input type="hidden" name="action" value="checkInPreBooked">
                                                            <input type="hidden" name="datSanId" value="${booking.datSanId}">
                                                            <input type="hidden" name="daThuTienMat" value="false">
                                                            <button type="submit" class="${themeBg} ${themeBgHover} text-white font-extrabold text-[10px] px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all active:scale-95">
                                                                Mở sân
                                                            </button>
                                                        </form>
                                                        <form action="${pageContext.request.contextPath}/staff/checkin" method="post" class="inline-block" onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch đặt này do khách bùng không?');">
                                                            <input type="hidden" name="action" value="cancelNoShow">
                                                            <input type="hidden" name="datSanId" value="${booking.datSanId}">
                                                            <button type="submit" class="bg-red-550 hover:bg-red-700 text-white font-extrabold text-[10px] px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all active:scale-95">
                                                                Hủy ca
                                                            </button>
                                                        </form>
                                                    </div>
                                                </c:if>
                                                <c:if test="${booking.trangThai == 'Đang sử dụng'}">
                                                    <button type="button" onclick="openStaffInvoiceModal(${booking.datSanId})" class="bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold text-[10px] px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all active:scale-95">
                                                        Dịch vụ & Thanh toán
                                                    </button>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="mt-4 p-3 bg-zinc-50 border border-zinc-200 rounded-xl text-[10px] text-zinc-550 flex items-center gap-2">
                <span class="material-symbols-outlined text-zinc-400">help</span>
                <span>Thao tác có thể bấm nút <strong>"Mở sân"</strong> để check-in. Hệ thống sẽ tự động đối chiếu thời gian đến sớm phụ thu hoặc đến trễ và kiểm tra tiền cọc trước khi kích hoạt.</span>
            </div>
        </section>
    </div>

</main>

<script>
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

    // Cấu hình cập nhật dữ liệu tự động (Polling mỗi 30 giây)
    const contextPath = '${pageContext.request.contextPath}';
    const isManager = ${isManager};
    const themeBg = '${themeBg}';
    const themeBgHover = '${themeBgHover}';
    const themeIcon = '${themeIcon}';
    const badgeTheme = '${badgeTheme}';
    const themeBorder = '${themeBorder}';
    
    function formatCurrency(value) {
        return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value).replace(/₫/g, 'đ');
    }

    async function pollUpdates() {
        try {
            const response = await fetch(`${contextPath}/staff/checkin?ajax=true`);
            if (!response.ok) return;
            const data = await response.json();
            
            // 1. Cập nhật Real-time Field Status Grid
            const fieldGrid = document.getElementById('field-status-grid');
            if (fieldGrid && data.danhSachSan) {
                let htmlGrid = '';
                data.danhSachSan.forEach(san => {
                    if (san.trangThai === 'Đang sử dụng') {
                        htmlGrid += `
                            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200 border-${isManager ? 'purple-300' : 'orange-300'} shadow-md">
                                <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full \${isManager ? 'bg-purple-500' : 'bg-orange-500'} live-dot"></span>
                                <div class="w-12 h-12 rounded-2xl \${isManager ? 'bg-purple-50' : 'bg-orange-50'} flex items-center justify-center \${themeIcon} mb-3 shadow-inner">
                                    <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                                </div>
                                <h4 class="font-bold text-sm text-zinc-800">\${san.tenSan}</h4>
                                <span class="badge \${badgeTheme} mt-2.5 uppercase text-[10px]">Đang sử dụng</span>
                            </div>
                        `;
                    } else {
                        htmlGrid += `
                            <div class="card p-4 flex flex-col items-center justify-between text-center relative overflow-hidden transition-all duration-200">
                                <span class="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-green-500"></span>
                                <div class="w-12 h-12 rounded-2xl bg-green-50 flex items-center justify-center text-green-600 mb-3">
                                    <span class="material-symbols-outlined text-[24px]">sports_soccer</span>
                                </div>
                                <h4 class="font-bold text-sm text-zinc-800">\${san.tenSan}</h4>
                                <span class="badge badge-green mt-2.5 uppercase text-[10px]">Sẵn sàng</span>
                            </div>
                        `;
                    }
                });
                fieldGrid.innerHTML = htmlGrid;
            }
            
            // 2. Cập nhật dropdown chọn sân ở form Walk-in
            const walkinSelect = document.getElementById('walkin-san-select');
            if (walkinSelect && data.danhSachSan) {
                const currentSelected = walkinSelect.value;
                let htmlSelect = '<option value="">-- Chọn Sân Trống --</option>';
                data.danhSachSan.forEach(san => {
                    if (san.trangThai === 'Sẵn sàng') {
                        htmlSelect += `<option value="\${san.sanID}" \${currentSelected == san.sanID ? 'selected' : ''}>\${san.tenSan}</option>`;
                    }
                });
                walkinSelect.innerHTML = htmlSelect;
            }

            // 3. Cập nhật Today's Bookings Table
            const tableBody = document.getElementById('booking-table-body');
            if (tableBody && data.danhSachLich) {
                if (data.danhSachLich.length === 0) {
                    tableBody.innerHTML = `
                        <tr>
                            <td colspan="8" class="p-8 text-center text-zinc-450 italic">Không có lịch đặt sân nào trong ngày hôm nay.</td>
                        </tr>
                    `;
                } else {
                    let htmlTable = '';
                    data.danhSachLich.forEach(booking => {
                        let statusBadge = '';
                        if (booking.trangThai === 'Đang sử dụng') {
                            statusBadge = `<span class="badge \${badgeTheme} uppercase">Đang đá</span>`;
                        } else if (booking.trangThai === 'Đã xác nhận') {
                            statusBadge = `<span class="badge badge-green">Đã xác nhận</span>`;
                        } else if (booking.trangThai === 'Chờ xác nhận') {
                            statusBadge = `<span class="badge badge-amber">Chờ duyệt</span>`;
                        } else {
                            statusBadge = `<span class="badge badge-gray">\${booking.trangThai}</span>`;
                        }
                        
                        let paymentBadge = `<span class="badge \${booking.trangThaiThanhToan === 'Đã thanh toán' ? 'badge-green' : 'badge-amber'}>\${booking.trangThaiThanhToan}</span>`;
                        
                        let actionButtons = '';
                        if (booking.trangThai === 'Đã xác nhận' || booking.trangThai === 'Chờ xác nhận') {
                            actionButtons = `
                                <div class="flex items-center justify-center gap-1.5">
                                    <form action="\${contextPath}/staff/checkin" method="post" class="inline-block">
                                        <input type="hidden" name="action" value="checkInPreBooked">
                                        <input type="hidden" name="datSanId" value="\${booking.datSanId}">
                                        <input type="hidden" name="daThuTienMat" value="false">
                                        <button type="submit" class="\${themeBg} \${themeBgHover} text-white font-extrabold text-[10px] px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all active:scale-95">
                                            Mở sân
                                        </button>
                                    </form>
                                    <form action="\${contextPath}/staff/checkin" method="post" class="inline-block" onsubmit="return confirm('Bạn có chắc chắn muốn hủy lịch đặt này do khách bùng không?');">
                                        <input type="hidden" name="action" value="cancelNoShow">
                                        <input type="hidden" name="datSanId" value="\${booking.datSanId}">
                                        <button type="submit" class="bg-red-550 hover:bg-red-700 text-white font-extrabold text-[10px] px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all active:scale-95">
                                            Hủy ca
                                        </button>
                                    </form>
                                </div>
                            `;
                        } else if (booking.trangThai === 'Đang sử dụng') {
                            actionButtons = `
                                <button type="button" onclick="openStaffInvoiceModal(\${booking.datSanId})" class="bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold text-[10px] px-3 py-1.5 rounded-lg shadow-sm hover:shadow transition-all active:scale-95">
                                    Dịch vụ & Thanh toán
                                </button>
                            `;
                        }

                        htmlTable += `
                            <tr class="border-b \${themeBorder} hover:bg-\${isManager ? 'purple' : 'orange'}-50/10 transition-all">
                                <td class="p-3 font-semibold text-zinc-800">\${booking.tenSan}</td>
                                <td class="p-3 text-zinc-700">
                                    <div>\${booking.tenKhachHang}</div>
                                    <div class="text-[10px] text-zinc-500 italic max-w-[150px] truncate" title="\${booking.ghiChu}">\${booking.ghiChu}</div>
                                </td>
                                <td class="p-3 text-center text-zinc-600 font-mono">
                                    \${booking.gioBatDau.substring(0, 5)} - \${booking.gioKetThuc.substring(0, 5)}
                                </td>
                                <td class="p-3 text-right font-bold text-zinc-800">
                                    \${formatCurrency(booking.tongTien)}
                                </td>
                                <td class="p-3 text-center">
                                    <span class="badge \${booking.nguonDatSan === 'Walk-in' ? 'badge-gray' : 'badge-blue'}">
                                        \${booking.nguonDatSan}
                                    </span>
                                </td>
                                <td class="p-3 text-center">\${statusBadge}</td>
                                <td class="p-3 text-center">\${paymentBadge}</td>
                                <td class="p-3 text-center">\${actionButtons}</td>
                            </tr>
                        `;
                    });
                    tableBody.innerHTML = htmlTable;
                }
            }
        } catch (err) {
            console.error('Lỗi khi cập nhật trạng thái sân tự động:', err);
        }
    }

    // Chạy cập nhật ngay khi tải trang và thiết lập chu kỳ 30 giây
    setInterval(pollUpdates, 30000);
</script>

<!-- STAFF INVOICE & SERVICE MODAL -->
<div id="staffInvoiceModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
    <div class="bg-white w-full max-w-3xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
        
        <div class="bg-gradient-to-r from-indigo-700 to-purple-800 px-6 py-4 flex items-center justify-between text-white">
            <h3 class="font-bold text-lg flex items-center gap-2">
                <span class="material-symbols-outlined">receipt_long</span> Thanh toán & Quản lý Dịch vụ
            </h3>
            <button onclick="closeStaffInvoiceModal()" class="text-white/80 hover:text-white transition-colors p-1">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        
        <div class="p-6 md:p-8 max-h-[75vh] overflow-y-auto">
            <div id="staff-invoice-loading" class="text-center py-12 text-zinc-500">
                <span class="material-symbols-outlined animate-spin text-[32px] text-indigo-600 mb-2">sync</span>
                <p class="text-sm font-medium">Đang tải chi tiết hóa đơn...</p>
            </div>
            
            <div id="staff-invoice-content" class="hidden space-y-6">
                <!-- General details -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-4 bg-zinc-50 rounded-2xl border border-zinc-100 text-xs">
                    <div>
                        <p class="text-zinc-500 font-semibold uppercase">Thông tin ca đấu</p>
                        <h4 class="font-bold text-zinc-800 text-sm mt-1" id="staff-invoice-court-name">Tên sân</h4>
                        <p class="text-zinc-600 mt-0.5" id="staff-invoice-time-slot">00:00 - 00:00 (01/01/2026)</p>
                    </div>
                    <div>
                        <p class="text-zinc-500 font-semibold uppercase">Trạng thái thanh toán</p>
                        <span class="badge badge-amber mt-1.5" id="staff-invoice-payment-status">Chưa thanh toán</span>
                    </div>
                </div>
                
                <!-- Services management -->
                <div>
                    <h4 class="font-extrabold text-zinc-800 text-xs uppercase tracking-wider mb-3">Dịch vụ đi kèm / Nước uống</h4>
                    
                    <!-- Add service inline form -->
                    <div class="flex gap-2 mb-4 items-end bg-zinc-50 p-3 rounded-xl border border-zinc-100">
                        <div class="flex-grow">
                            <label class="block text-[10px] font-bold text-zinc-500 uppercase mb-1">Chọn sản phẩm</label>
                            <select id="staff-product-select" class="w-full text-xs p-2 bg-white border border-zinc-200 rounded-lg focus:outline-none focus:border-indigo-600">
                                <!-- Populated dynamically -->
                            </select>
                        </div>
                        <div class="w-20">
                            <label class="block text-[10px] font-bold text-zinc-500 uppercase mb-1">Số lượng</label>
                            <input type="number" id="staff-product-qty" value="1" min="1" class="w-full text-xs p-2 bg-white border border-zinc-200 rounded-lg text-center font-bold focus:outline-none focus:border-indigo-600">
                        </div>
                        <button type="button" onclick="addServiceToInvoiceList()" class="bg-indigo-600 hover:bg-indigo-700 text-white font-extrabold text-xs px-4 py-2 rounded-lg transition-all active:scale-95 h-[34px] flex items-center justify-center">
                            Thêm
                        </button>
                    </div>
                    
                    <!-- Invoice detail table -->
                    <div class="border border-zinc-100 rounded-xl overflow-hidden">
                        <table class="w-full text-left text-xs border-collapse">
                            <thead>
                                <tr class="bg-zinc-50 border-b border-zinc-100 text-zinc-500 font-bold">
                                    <th class="p-3">Tên sản phẩm</th>
                                    <th class="p-3 text-center">Đơn giá</th>
                                    <th class="p-3 text-center">Số lượng</th>
                                    <th class="p-3 text-right">Thành tiền</th>
                                    <th class="p-3 text-center">Xóa</th>
                                </tr>
                            </thead>
                            <tbody id="staff-invoice-details-body">
                                <!-- Populated dynamically -->
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Pricing summary & payment method -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-zinc-100">
                    <div class="space-y-3">
                        <h4 class="font-extrabold text-zinc-800 text-xs uppercase tracking-wider">Phương thức thanh toán</h4>
                        <div class="grid grid-cols-2 gap-2">
                            <label class="border-2 border-indigo-600 bg-indigo-50/10 rounded-xl p-3 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-indigo-700 hover:bg-indigo-50/20 active:scale-95 transition-all" id="lbl-pay-cash">
                                <input type="radio" name="staffPaymentMethod" value="Tiền mặt" checked class="hidden" onchange="changeStaffPayMethod('Tiền mặt')">
                                <span class="material-symbols-outlined text-[18px]">payments</span> Tiền mặt
                            </label>
                            <label class="border-2 border-zinc-150 rounded-xl p-3 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-zinc-700 hover:border-zinc-300 active:scale-95 transition-all" id="lbl-pay-transfer">
                                <input type="radio" name="staffPaymentMethod" value="Chuyển khoản" class="hidden" onchange="changeStaffPayMethod('Chuyển khoản')">
                                <span class="material-symbols-outlined text-[18px]">qr_code_2</span> Chuyển khoản
                            </label>
                        </div>
                    </div>
                    <div class="bg-zinc-50 border border-zinc-100 p-4 rounded-2xl space-y-2 text-xs">
                        <div class="flex justify-between text-zinc-650">
                            <span>Tiền sân:</span>
                            <span class="font-bold text-zinc-800" id="staff-summary-court-price" data-val="0">0 đ</span>
                        </div>
                        <div class="flex justify-between text-zinc-650">
                            <span>Tiền dịch vụ:</span>
                            <span class="font-bold text-zinc-800" id="staff-summary-services-price">0 đ</span>
                        </div>
                        <div class="pt-2.5 mt-1 border-t border-zinc-200 flex justify-between items-end">
                            <span class="font-extrabold text-zinc-800 uppercase text-[10px]">Tổng thanh toán:</span>
                            <span class="text-lg font-black text-indigo-600" id="staff-summary-total">0 đ</span>
                        </div>
                    </div>
                </div>
                
                <!-- Actions -->
                <div class="pt-4 flex justify-between gap-3">
                    <div class="flex gap-2">
                        <form id="staff-save-services-form" action="${pageContext.request.contextPath}/staff/checkin" method="post">
                            <input type="hidden" name="action" value="addServices">
                            <input type="hidden" name="datSanId" id="staff-save-datsan-id">
                            <div id="staff-save-hidden-inputs" class="hidden"></div>
                            <button type="submit" class="px-6 py-3 rounded-xl font-bold text-indigo-700 bg-indigo-50 border border-indigo-200 hover:bg-indigo-100 transition-colors text-xs active:scale-95">
                                Lưu thay đổi dịch vụ
                            </button>
                        </form>
                    </div>
                    <div class="flex gap-2">
                        <button type="button" onclick="closeStaffInvoiceModal()" class="px-6 py-3 rounded-xl font-bold text-zinc-600 bg-zinc-100 hover:bg-zinc-200 text-xs active:scale-95 transition-colors">
                            Đóng
                        </button>
                        <form id="staff-payment-form" action="${pageContext.request.contextPath}/staff/checkin" method="post" onsubmit="return confirmPaymentSubmit()">
                            <input type="hidden" name="action" value="processPayment">
                            <input type="hidden" name="datSanId" id="staff-pay-datsan-id">
                            <input type="hidden" name="phuongThucThanhToan" id="staff-pay-method-input" value="Tiền mặt">
                            <button type="submit" class="px-8 py-3 rounded-xl font-extrabold text-white bg-indigo-600 hover:bg-indigo-700 transition-all shadow-md hover:shadow-indigo-600/20 text-xs active:scale-95 duration-200 flex items-center gap-1.5">
                                <span class="material-symbols-outlined text-[16px]">print</span>
                                Thanh toán & Xuất hóa đơn (Bill)
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    let staffProducts = [];
    let staffOrdered = [];
    let currentStaffDatSanId = -1;

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
        fetch(`${pageContext.request.contextPath}/staff/checkin?action=getInvoiceDetails&datSanId=${datSanId}`)
            .then(res => res.json())
            .then(data => {
                staffProducts = data.products || [];
                staffOrdered = data.ordered || [];
                
                document.getElementById("staff-invoice-court-name").textContent = data.tenSan;
                document.getElementById("staff-invoice-time-slot").textContent = `${data.gioBatDau} - ${data.gioKetThuc} (${data.ngayDat})`;
                
                const statusBadge = document.getElementById("staff-invoice-payment-status");
                statusBadge.textContent = data.trangThaiThanhToan;
                if (data.trangThaiThanhToan === 'Đã thanh toán') {
                    statusBadge.className = "badge badge-green mt-1.5";
                } else {
                    statusBadge.className = "badge badge-amber mt-1.5";
                }

                // Populate court price
                const summaryCourtPriceEl = document.getElementById("staff-summary-court-price");
                summaryCourtPriceEl.textContent = data.tongTienSan.toLocaleString('vi-VN') + " đ";
                summaryCourtPriceEl.setAttribute("data-val", data.tongTienSan);

                // Populate products select
                const select = document.getElementById("staff-product-select");
                select.innerHTML = '<option value="">-- Chọn sản phẩm thêm --</option>';
                staffProducts.forEach(prod => {
                    select.insertAdjacentHTML("beforeend", `<option value="${prod.SanPhamID}">${prod.TenSanPham} (${prod.DonGia.toLocaleString('vi-VN')} đ / ${prod.DonViTinh || 'cái'} - Kho: ${prod.SoLuongTon})</option>`);
                });

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
        const tbody = document.getElementById("staff-invoice-details-body");
        tbody.innerHTML = "";
        
        if (staffOrdered.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" class="p-4 text-center text-zinc-400 italic">Chưa có dịch vụ nào được thêm.</td></tr>`;
        } else {
            staffOrdered.forEach(item => {
                const prod = staffProducts.find(p => p.SanPhamID === item.SanPhamID);
                const prodName = prod ? prod.TenSanPham : `Sản phẩm #${item.SanPhamID}`;
                const unit = prod ? (prod.DonViTinh || 'cái') : 'cái';
                
                tbody.insertAdjacentHTML("beforeend", `
                    <tr class="border-b border-zinc-100 hover:bg-zinc-50/50">
                        <td class="p-3 font-semibold text-zinc-850">${prodName}</td>
                        <td class="p-3 text-center text-zinc-600">${item.DonGiaTaiThoiDiemBan.toLocaleString('vi-VN')} đ</td>
                        <td class="p-3 text-center">
                            <div class="flex items-center justify-center gap-1.5">
                                <button type="button" onclick="adjustStaffItemQty(${item.SanPhamID}, -1)" class="w-6 h-6 rounded bg-zinc-200 hover:bg-zinc-300 text-zinc-700 font-bold flex items-center justify-center select-none">-</button>
                                <span class="font-bold text-sm w-8 text-center">${item.SoLuong}</span>
                                <button type="button" onclick="adjustStaffItemQty(${item.SanPhamID}, 1)" class="w-6 h-6 rounded bg-zinc-200 hover:bg-zinc-300 text-zinc-700 font-bold flex items-center justify-center select-none">+</button>
                            </div>
                        </td>
                        <td class="p-3 text-right font-bold text-zinc-800">${item.ThanhTien.toLocaleString('vi-VN')} đ</td>
                        <td class="p-3 text-center">
                            <button type="button" onclick="removeStaffItem(${item.SanPhamID})" class="p-1 rounded text-red-500 hover:bg-red-50 flex items-center justify-center mx-auto transition-colors">
                                <span class="material-symbols-outlined text-[18px]">delete</span>
                            </button>
                        </td>
                    </tr>
                `);
            });
        }

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
            alert(`Không thể chọn vượt quá số lượng tồn kho (${prod.SoLuongTon})`);
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
            alert(`Sản phẩm này chỉ còn tồn kho: ${prod.SoLuongTon}`);
            return;
        }

        // Check if already ordered
        const existing = staffOrdered.find(o => o.SanPhamID === spId);
        if (existing) {
            const newQty = existing.SoLuong + qty;
            if (newQty > prod.SoLuongTon) {
                alert(`Không thể thêm vì tổng số lượng vượt quá tồn kho (${prod.SoLuongTon})`);
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
        
        document.getElementById("staff-summary-services-price").textContent = serviceTotal.toLocaleString('vi-VN') + " đ";
        document.getElementById("staff-summary-total").textContent = totalVal.toLocaleString('vi-VN') + " đ";

        // Update hidden inputs for saving
        const hiddenContainer = document.getElementById("staff-save-hidden-inputs");
        hiddenContainer.innerHTML = "";
        staffOrdered.forEach(item => {
            hiddenContainer.insertAdjacentHTML("beforeend", `<input type="hidden" name="productId" value="${item.SanPhamID}">`);
            hiddenContainer.insertAdjacentHTML("beforeend", `<input type="hidden" name="quantity" value="${item.SoLuong}">`);
        });
    }

    function changeStaffPayMethod(method) {
        document.getElementById("staff-pay-method-input").value = method;
        
        const lblCash = document.getElementById("lbl-pay-cash");
        const lblTransfer = document.getElementById("lbl-pay-transfer");
        
        if (method === 'Tiền mặt') {
            lblCash.className = "border-2 border-indigo-600 bg-indigo-50/10 rounded-xl p-3 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-indigo-700 hover:bg-indigo-50/20 active:scale-95 transition-all";
            lblTransfer.className = "border-2 border-zinc-150 rounded-xl p-3 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-zinc-700 hover:border-zinc-300 active:scale-95 transition-all";
        } else {
            lblTransfer.className = "border-2 border-indigo-600 bg-indigo-50/10 rounded-xl p-3 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-indigo-700 hover:bg-indigo-50/20 active:scale-95 transition-all";
            lblCash.className = "border-2 border-zinc-150 rounded-xl p-3 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-zinc-700 hover:border-zinc-300 active:scale-95 transition-all";
        }
    }

    function confirmPaymentSubmit() {
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
</script>
</body>
</html>
