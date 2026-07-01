<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>${san.tenSan} - Chi Tiết Sân V-SPORT</title>
    <jsp:include page="/common/head.jsp" />
    <style>
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
        .amenity-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 42px;
            height: 42px;
            border-radius: 12px;
            background-color: #f1f5f9;
            color: #64748b;
            transition: all 0.2s ease;
        }
        .amenity-card:hover .amenity-icon {
            background-color: #dcfce7;
            color: #16a34a;
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="bg-[#f4f6f8] text-[#1e293b] min-h-screen flex flex-col antialiased">

    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[120px] pb-24">
        <div class="w-full px-4 sm:px-6 lg:px-10 xl:px-16 animate-fade-in-up">
            
            <!-- Breadcrumbs -->
            <nav class="flex mb-8 text-xs font-semibold text-slate-500 gap-2 items-center">
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="hover:text-green-600 transition-colors">Tìm Sân</a>
                <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                <span class="text-slate-400">Chi tiết sân</span>
                <span class="material-symbols-outlined text-[14px]">chevron_right</span>
                <span class="text-green-600 font-bold">${san.tenSan}</span>
            </nav>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8 items-start">
                
                <!-- LEFT COLUMN: Court Details (2/3 width) -->
                <div class="lg:col-span-2 space-y-6">
                    
                    <!-- Main Gallery / Banner -->
                    <div class="relative rounded-3xl overflow-hidden shadow-md aspect-[16/9] bg-slate-200 group">
                        <img src="${not empty san.hinhAnh ? san.hinhAnh : 'https://images.unsplash.com/photo-1544698310-74ea9d1c8258?q=80&w=1200'}" 
                             alt="${san.tenSan}" 
                             class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105">
                        
                        <!-- Status Badge overlay -->
                        <div class="absolute top-4 left-4">
                            <span class="px-3.5 py-1.5 rounded-full text-xs font-extrabold uppercase tracking-wider shadow-md backdrop-blur-md flex items-center gap-1.5 
                                  ${san.trangThai == 'Sẵn sàng' ? 'bg-green-500/90 text-white' : 'bg-amber-500/90 text-white'}">
                                <span class="w-1.5 h-1.5 rounded-full bg-white animate-pulse"></span>
                                ${san.trangThai == 'Sẵn sàng' ? 'Trống sân' : 'Đang dùng'}
                            </span>
                        </div>
                        
                        <!-- Sport Category overlay -->
                        <div class="absolute top-4 right-4">
                            <span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider bg-black/60 text-white backdrop-blur-sm">
                                ${tenMon}
                            </span>
                        </div>
                    </div>

                    <!-- Court Title & Branch -->
                    <div class="bg-white p-6 sm:p-8 rounded-3xl border border-slate-200/80 shadow-sm space-y-4">
                        <div class="flex flex-wrap items-start justify-between gap-4 border-b border-slate-100 pb-5">
                            <div>
                                <h1 class="text-2xl sm:text-3xl font-black text-slate-800 tracking-tight">${san.tenSan}</h1>
                                <p class="text-sm text-slate-500 flex items-center gap-1.5 mt-2 font-medium">
                                    <span class="material-symbols-outlined text-[18px] text-green-600">location_on</span>
                                    Cơ sở: <strong class="text-slate-700">${coSo.tenCoSo}</strong>
                                </p>
                                <p class="text-xs text-slate-400 mt-1 italic pl-6">${coSo.diaChi}</p>
                            </div>
                            <div class="text-right">
                                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block mb-0.5">Giá thuê chỉ từ</span>
                                <span class="text-2xl font-black text-green-600"><fmt:formatNumber value="${loai.giaKhongDen}" pattern="#,##0"/> đ<span class="text-xs font-normal text-slate-500">/h</span></span>
                            </div>
                        </div>

                        <!-- Highlights info -->
                        <div class="grid grid-cols-2 sm:grid-cols-3 gap-4 pt-2">
                            <div class="p-3.5 bg-slate-50 rounded-2xl border border-slate-100/50">
                                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block mb-0.5">Loại hình sân</span>
                                <span class="text-xs font-bold text-slate-800">${loai.tenLoai}</span>
                            </div>
                            <div class="p-3.5 bg-slate-50 rounded-2xl border border-slate-100/50">
                                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block mb-0.5">Giờ hoạt động</span>
                                <span class="text-xs font-bold text-slate-800">${coSo.gioMoCua != null ? coSo.gioMoCua : '06:00'} - ${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}</span>
                            </div>
                            <div class="p-3.5 bg-slate-50 rounded-2xl border border-slate-100/50 col-span-2 sm:col-span-1">
                                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider block mb-0.5">Sân tương tự</span>
                                <span class="text-xs font-bold text-slate-800">${totalSimilarCourts} sân tại chi nhánh</span>
                            </div>
                        </div>
                    </div>

                    <!-- Amenities Services -->
                    <div class="bg-white p-6 sm:p-8 rounded-3xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-sm font-black text-slate-800 uppercase tracking-wider mb-5 flex items-center gap-2">
                            <span class="material-symbols-outlined text-[20px] text-green-600">sports_soccer</span>
                            Tiện ích sân đấu
                        </h3>
                        <div class="grid grid-cols-2 sm:grid-cols-5 gap-4">
                            <div class="amenity-card flex flex-col items-center text-center p-3 rounded-2xl border border-slate-100 transition-all hover:bg-slate-50">
                                <div class="amenity-icon mb-2">
                                    <span class="material-symbols-outlined text-[22px]">wifi</span>
                                </div>
                                <span class="text-xs font-bold text-slate-700">Wifi miễn phí</span>
                            </div>
                            <div class="amenity-card flex flex-col items-center text-center p-3 rounded-2xl border border-slate-100 transition-all hover:bg-slate-50">
                                <div class="amenity-icon mb-2">
                                    <span class="material-symbols-outlined text-[22px]">local_parking</span>
                                </div>
                                <span class="text-xs font-bold text-slate-700">Bãi đỗ xe</span>
                            </div>
                            <div class="amenity-card flex flex-col items-center text-center p-3 rounded-2xl border border-slate-100 transition-all hover:bg-slate-50">
                                <div class="amenity-icon mb-2">
                                    <span class="material-symbols-outlined text-[22px]">local_drink</span>
                                </div>
                                <span class="text-xs font-bold text-slate-700">Nước mát</span>
                            </div>
                            <div class="amenity-card flex flex-col items-center text-center p-3 rounded-2xl border border-slate-100 transition-all hover:bg-slate-50">
                                <div class="amenity-icon mb-2">
                                    <span class="material-symbols-outlined text-[22px]">lightbulb</span>
                                </div>
                                <span class="text-xs font-bold text-slate-700">Đèn đêm</span>
                            </div>
                            <div class="amenity-card flex flex-col items-center text-center p-3 rounded-2xl border border-slate-100 transition-all hover:bg-slate-50">
                                <div class="amenity-icon mb-2">
                                    <span class="material-symbols-outlined text-[22px]">shower</span>
                                </div>
                                <span class="text-xs font-bold text-slate-700">Phòng tắm</span>
                            </div>
                        </div>
                    </div>

                    <!-- Description Block -->
                    <div class="bg-white p-6 sm:p-8 rounded-3xl border border-slate-200/80 shadow-sm">
                        <h3 class="text-sm font-black text-slate-800 uppercase tracking-wider mb-4 flex items-center gap-2">
                            <span class="material-symbols-outlined text-[20px] text-green-600">description</span>
                            Mô tả chi tiết
                        </h3>
                        <p class="text-sm text-slate-600 leading-relaxed">
                            ${not empty san.moTa ? san.moTa : 'Hệ thống sân đấu tiêu chuẩn quốc tế với lớp cỏ/sàn cao cấp, hệ thống thoát nước tối ưu đảm bảo sân luôn khô ráo và bám tốt. Sân được trang bị hệ thống chiếu sáng LED chuyên nghiệp phục vụ thi đấu vào ban đêm không lo bóng mờ. Thích hợp cho cả tập luyện phong trào và tổ chức các giải đấu quy mô vừa.'}
                        </p>
                    </div>

                </div>

                <!-- RIGHT COLUMN: Booking Form Widget (1/3 width) -->
                <div class="lg:col-span-1 space-y-6 lg:sticky lg:top-[120px]">
                    
                    <!-- Quick booking card -->
                    <div class="bg-white p-6 rounded-3xl border border-slate-200/80 shadow-md">
                        <h3 class="text-sm font-black text-slate-800 uppercase tracking-wider mb-5 flex items-center gap-2 border-b border-slate-100 pb-3">
                            <span class="material-symbols-outlined text-[20px] text-green-600">calendar_month</span>
                            Đặt Sân Nhanh
                        </h3>

                        <!-- Alert messages -->
                        <c:if test="${not empty sessionScope.error}">
                            <div class="mb-4 p-3.5 bg-red-50 border border-red-100 text-red-600 text-xs rounded-xl flex items-start gap-2 shadow-inner">
                                <span class="material-symbols-outlined text-[18px] shrink-0">error</span>
                                <span>${sessionScope.error}</span>
                            </div>
                            <% session.removeAttribute("error"); %>
                        </c:if>
                        
                        <form id="quick-booking-form" action="${pageContext.request.contextPath}/customer/dat-san" method="post" class="space-y-5">
                            <input type="hidden" name="sanId" value="${san.sanID}">
                            <input type="hidden" name="gioBatDau" id="gioBatDau">
                            <input type="hidden" name="gioKetThuc" id="gioKetThuc">

                            <!-- GROUP 1: Thời gian -->
                            <div class="bg-slate-50/60 border border-slate-100 rounded-2xl p-4 space-y-3">
                                <span class="text-[11px] font-black text-green-700 uppercase tracking-wider">1. Chọn thời gian</span>

                                <div class="space-y-1.5">
                                    <label for="ngayDat" class="form-label">Ngày thi đấu <span class="text-red-500">*</span></label>
                                    <input type="date" name="ngayDat" id="ngayDat" required class="form-input" onchange="onDateChange()">
                                </div>

                                <div class="space-y-1.5">
                                    <label class="form-label">Chọn khung giờ <span class="text-red-500">*</span></label>
                                    <div id="time-grid" class="flex flex-wrap gap-1.5 max-h-[220px] overflow-y-auto pr-1">
                                        <!-- Dynamic chips -->
                                    </div>
                                    <div id="time-summary" class="hidden text-xs font-bold text-green-700 bg-green-50 border border-green-100 rounded-lg px-3 py-2 mt-1">
                                        <!-- Dynamic -->
                                    </div>
                                </div>

                                <div id="overlap-warning" class="bg-red-50 border border-red-100 text-red-600 p-3 rounded-xl text-xs hidden flex gap-2 items-start shadow-sm">
                                    <span class="material-symbols-outlined text-[16px] mt-0.5">warning</span>
                                    <span id="overlap-warning-text">Trùng lịch!</span>
                                </div>
                            </div>

                            <!-- GROUP 2: Ghi chú -->
                            <div class="bg-slate-50/60 border border-slate-100 rounded-2xl p-4 space-y-1.5">
                                <span class="text-[11px] font-black text-green-700 uppercase tracking-wider">2. Ghi chú yêu cầu</span>
                                <textarea name="ghiChu" id="ghiChu" rows="2" class="form-input resize-none" placeholder="Thuê bóng, mượn áo tập..."></textarea>
                            </div>

                            <!-- GROUP 3: Thanh toán & Xác nhận -->
                            <div class="border-t-2 border-slate-100 pt-4 space-y-3">
                                <span class="text-[11px] font-black text-green-700 uppercase tracking-wider">3. Thanh toán &amp; Xác nhận</span>

                                <div class="grid grid-cols-2 gap-2">
                                    <label class="border-2 border-green-600 bg-green-50/10 rounded-xl p-2.5 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-green-700 active:scale-95 transition-all" id="lbl-opt-sau">
                                        <input type="radio" name="paymentMethod" value="sau" checked class="hidden" onchange="changePayMethod('sau')">
                                        Trả sau tại quầy
                                    </label>
                                    <label class="border-2 border-slate-100 rounded-xl p-2.5 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-slate-600 hover:border-slate-300 active:scale-95 transition-all" id="lbl-opt-payos">
                                        <input type="radio" name="paymentMethod" value="payos" class="hidden" onchange="changePayMethod('payos')">
                                        PayOS Online
                                    </label>
                                </div>

                                <div id="estimated-price-row" class="hidden items-center justify-between bg-green-50 border border-green-100 rounded-xl px-4 py-2.5">
                                    <span class="text-xs font-bold text-slate-600">Tạm tính</span>
                                    <span id="estimated-price-value" class="text-base font-black text-green-700"></span>
                                </div>

                                <c:choose>
                                    <c:when test="${sessionScope.user != null}">
                                        <button type="submit" id="btn-submit-booking" disabled
                                                class="w-full py-3.5 rounded-xl font-bold text-white bg-green-600 hover:bg-green-700 transition-all shadow-md hover:shadow-green-600/20 active:scale-95 duration-250 flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed">
                                            Đặt Sân Đấu Ngay
                                            <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/dangnhap"
                                           class="w-full py-3.5 rounded-xl font-bold text-white bg-green-600 hover:bg-green-700 transition-all text-center flex items-center justify-center gap-2 active:scale-95">
                                            Đăng Nhập Để Đặt Sân
                                            <span class="material-symbols-outlined text-[18px]">login</span>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </form>
                    </div>

                </div>

            </div>

            <!-- OTHER COURTS SECTION -->
            <div class="mt-16 bg-white p-8 rounded-3xl border border-slate-200/80 shadow-sm space-y-6">
                <h2 class="text-xl font-black text-slate-800 tracking-tight flex items-center gap-2">
                    <span class="material-symbols-outlined text-[24px] text-green-600">sports_tennis</span>
                    Các sân đấu khác dành cho bạn
                </h2>
                
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <c:forEach var="os" items="${otherSans}" varStatus="loop">
                        <c:if test="${loop.index < 4}">
                            <!-- Find facility name -->
                            <c:set var="osCoSoName" value="Cơ Sở" />
                            <c:forEach var="cs" items="${dsCoSo}">
                                <c:if test="${cs.coSoID == os.coSoID}">
                                    <c:set var="osCoSoName" value="${cs.tenCoSo}" />
                                </c:if>
                            </c:forEach>
                            
                            <!-- Find LoaiSan name and price -->
                            <c:set var="osTypeName" value="Chưa phân loại" />
                            <c:set var="osPrice" value="0" />
                            <c:set var="osSportId" value="0" />
                            <c:forEach var="ls" items="${dsLoaiSan}">
                                <c:if test="${ls.loaiSanID == os.loaiSanID}">
                                    <c:set var="osTypeName" value="${ls.tenLoai}" />
                                    <c:set var="osPrice" value="${ls.giaKhongDen}" />
                                    <c:set var="osSportId" value="${ls.monTheThaoID}" />
                                </c:if>
                            </c:forEach>
                            
                            <!-- Find Sport Name -->
                            <c:set var="osSportName" value="Khác" />
                            <c:forEach var="m" items="${dsMon}">
                                <c:if test="${m.monTheThaoID == osSportId}">
                                    <c:set var="osSportName" value="${m.tenMon}" />
                                </c:if>
                            </c:forEach>

                            <!-- Render card -->
                            <div class="bg-slate-50 border border-slate-100 rounded-2xl overflow-hidden flex flex-col justify-between transition-all duration-300 hover:shadow-md hover:-translate-y-1">
                                <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${os.sanID}" class="block group hover:no-underline">
                                    <div class="relative h-[130px] w-full overflow-hidden bg-slate-200">
                                        <img src="${not empty os.hinhAnh ? os.hinhAnh : 'https://images.unsplash.com/photo-1544698310-74ea9d1c8258?q=80&w=600'}" 
                                             alt="${os.tenSan}" 
                                             class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105">
                                        <span class="absolute top-2 right-2 px-2 py-0.5 rounded bg-black/60 text-white text-[9px] font-bold uppercase tracking-wider backdrop-blur-sm">
                                            ${osSportName}
                                        </span>
                                    </div>
                                    <div class="p-4 space-y-2">
                                        <h4 class="font-bold text-slate-800 text-sm truncate group-hover:text-green-600 transition-colors">${os.tenSan}</h4>
                                        <p class="text-xs text-slate-500 flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[14px] text-slate-400">location_on</span>
                                            ${osCoSoName}
                                        </p>
                                        <p class="text-[11px] text-slate-450 italic truncate">${osTypeName}</p>
                                    </div>
                                </a>
                                <div class="p-4 pt-0 flex items-center justify-between border-t border-slate-100/50 mt-auto bg-white/50">
                                    <span class="text-xs font-black text-green-600"><fmt:formatNumber value="${osPrice}" pattern="#,##0"/> đ<span class="text-[10px] font-normal text-slate-400">/h</span></span>
                                    <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${os.sanID}" 
                                       class="px-3 py-1 bg-green-600 text-white rounded-lg text-[10px] font-bold hover:bg-green-700 hover:no-underline transition-all">
                                        Xem sân
                                    </a>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </div>

        </div>
    </main>

    <jsp:include page="/common/footer.jsp" />

    <script>
        const courtId = parseInt("${san.sanID}");
        const branchOpenTime = "${coSo.gioMoCua != null ? coSo.gioMoCua : '06:00'}";
        const branchCloseTime = "${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}";
        const pricePerHour = parseFloat("${loai.giaKhongDen != null ? loai.giaKhongDen : 0}");

        let selectedStartMin = null;
        let selectedEndMin = null;
        
        // Active bookings of this court
        const activeBookings = [
            <c:forEach var="b" items="${activeBookings}">
                <c:if test="${b.sanId == san.sanID && b.trangThai != 'Đã hủy'}">
                    {
                        id: ${b.datSanId},
                        date: "${b.ngayDat}",
                        start: "${b.gioBatDau}",
                        end: "${b.gioKetThuc}",
                        status: "${b.trangThai}"
                    },
                </c:if>
            </c:forEach>
        ];

        // Format dates
        const today = new Date();
        const todayStr = today.getFullYear() + "-" + String(today.getMonth() + 1).padStart(2, "0") + "-" + String(today.getDate()).padStart(2, "0");
        document.getElementById("ngayDat").min = todayStr;
        document.getElementById("ngayDat").value = todayStr;

        function changePayMethod(method) {
            const lblSau = document.getElementById("lbl-opt-sau");
            const lblPayOS = document.getElementById("lbl-opt-payos");
            if (method === 'sau') {
                lblSau.className = "border-2 border-green-600 bg-green-50/10 rounded-xl p-2.5 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-green-700 active:scale-95 transition-all";
                lblPayOS.className = "border-2 border-slate-100 rounded-xl p-2.5 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-slate-600 hover:border-slate-300 active:scale-95 transition-all";
            } else {
                lblPayOS.className = "border-2 border-green-600 bg-green-50/10 rounded-xl p-2.5 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-green-700 active:scale-95 transition-all";
                lblSau.className = "border-2 border-slate-100 rounded-xl p-2.5 flex items-center justify-center gap-1.5 cursor-pointer font-bold text-xs text-slate-600 hover:border-slate-300 active:scale-95 transition-all";
            }
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

        function onDateChange() {
            applyTimeConstraints();
            checkSchedule();
        }

        function getSlotStatus(m, conflicts, currentTotalMin) {
            const isPast = m <= currentTotalMin;
            const isBooked = conflicts.some(b => {
                const startB = timeToMinutes(b.start);
                const endB = timeToMinutes(b.end);
                return m >= startB && m < endB;
            });
            if (isPast) return "past";
            if (isBooked) return "booked";
            return "available";
        }

        function findNextBlockedMin(startMin, closeMin, conflicts, currentTotalMin) {
            let limit = closeMin;
            conflicts.forEach(b => {
                const bStartMin = timeToMinutes(b.start);
                if (bStartMin > startMin && bStartMin < limit) {
                    limit = bStartMin;
                }
            });
            return limit;
        }

        function applyTimeConstraints() {
            selectedStartMin = null;
            selectedEndMin = null;
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").value = "";
            renderTimeGrid();
            updateEstimatedPrice();
        }

        function renderTimeGrid() {
            const openMin = timeToMinutes(branchOpenTime);
            const closeMin = timeToMinutes(branchCloseTime);
            const dateVal = document.getElementById("ngayDat").value;
            const grid = document.getElementById("time-grid");
            const summary = document.getElementById("time-summary");
            grid.innerHTML = "";

            const conflicts = activeBookings.filter(b => b.date === dateVal);

            let currentTotalMin = -1;
            if (dateVal === todayStr) {
                const now = new Date();
                currentTotalMin = now.getHours() * 60 + now.getMinutes();
            }

            let rangeLimit = null;
            if (selectedStartMin !== null && selectedEndMin === null) {
                rangeLimit = findNextBlockedMin(selectedStartMin, closeMin, conflicts, currentTotalMin);
            }

            for (let m = openMin; m <= closeMin - 30; m += 30) {
                const hour = Math.floor(m / 60);
                const min = m % 60;
                const timeStr = String(hour).padStart(2, "0") + ":" + String(min).padStart(2, "0");
                const status = getSlotStatus(m, conflicts, currentTotalMin);

                const chip = document.createElement("button");
                chip.type = "button";
                chip.textContent = timeStr;

                const isSelectedStart = (m === selectedStartMin);
                const isSelectedEnd = (m === selectedEndMin);
                const isInRange = (selectedStartMin !== null && selectedEndMin !== null && m > selectedStartMin && m < selectedEndMin);
                const isExtendable = (selectedStartMin !== null && selectedEndMin === null && m > selectedStartMin && rangeLimit !== null && m <= rangeLimit);

                let cls = "px-2.5 py-1.5 rounded-lg text-[11px] font-bold border transition-all ";
                if (status === "past") {
                    chip.disabled = true;
                    cls += "bg-slate-100 text-slate-300 border-slate-100 cursor-not-allowed";
                } else if (status === "booked") {
                    chip.disabled = true;
                    cls += "bg-red-50 text-red-300 border-red-100 cursor-not-allowed line-through";
                } else if (isSelectedStart || isSelectedEnd) {
                    cls += "bg-green-600 text-white border-green-600 shadow-sm";
                } else if (isInRange) {
                    cls += "bg-green-50 text-green-700 border-green-200";
                } else if (isExtendable) {
                    cls += "bg-white text-green-700 border-green-300 hover:bg-green-50 cursor-pointer";
                } else {
                    cls += "bg-white text-slate-600 border-slate-200 hover:border-green-300 hover:bg-green-50 cursor-pointer";
                }
                chip.className = cls;

                if (!chip.disabled) {
                    chip.addEventListener("click", () => onChipClick(m));
                }
                grid.appendChild(chip);
            }

            if (selectedStartMin !== null && selectedEndMin !== null) {
                const startStr = String(Math.floor(selectedStartMin / 60)).padStart(2, "0") + ":" + String(selectedStartMin % 60).padStart(2, "0");
                const endStr = String(Math.floor(selectedEndMin / 60)).padStart(2, "0") + ":" + String(selectedEndMin % 60).padStart(2, "0");
                const durationText = formatDurationText(selectedEndMin - selectedStartMin);
                summary.textContent = `Bạn chọn: ${startStr} - ${endStr} (${durationText})`;
                summary.classList.remove("hidden");
            } else {
                summary.classList.add("hidden");
            }
        }

        function onChipClick(m) {
            if (selectedStartMin === null) {
                selectedStartMin = m;
            } else if (selectedEndMin === null) {
                if (m === selectedStartMin) {
                    selectedStartMin = null;
                } else if (m > selectedStartMin) {
                    selectedEndMin = m;
                } else {
                    selectedStartMin = m;
                }
            } else {
                selectedStartMin = m;
                selectedEndMin = null;
            }

            const startStr = selectedStartMin !== null
                ? String(Math.floor(selectedStartMin / 60)).padStart(2, "0") + ":" + String(selectedStartMin % 60).padStart(2, "0")
                : "";
            const endStr = selectedEndMin !== null
                ? String(Math.floor(selectedEndMin / 60)).padStart(2, "0") + ":" + String(selectedEndMin % 60).padStart(2, "0")
                : "";
            document.getElementById("gioBatDau").value = startStr;
            document.getElementById("gioKetThuc").value = endStr;

            renderTimeGrid();
            updateEstimatedPrice();
            checkSchedule();
        }

        function updateEstimatedPrice() {
            const row = document.getElementById("estimated-price-row");
            const valueEl = document.getElementById("estimated-price-value");
            if (selectedStartMin === null || selectedEndMin === null || !pricePerHour) {
                row.classList.add("hidden");
                row.classList.remove("flex");
                return;
            }
            const hours = (selectedEndMin - selectedStartMin) / 60;
            const total = Math.round(pricePerHour * hours);
            valueEl.textContent = total.toLocaleString("vi-VN") + " đ";
            row.classList.remove("hidden");
            row.classList.add("flex");
        }

        function checkSchedule() {
            const dateVal = document.getElementById("ngayDat").value;
            const startVal = document.getElementById("gioBatDau").value;
            const endVal = document.getElementById("gioKetThuc").value;

            const btnSubmit = document.getElementById("btn-submit-booking");
            const warningBox = document.getElementById("overlap-warning");

            const conflicts = activeBookings.filter(b => b.date === dateVal);

            if (!startVal || !endVal) {
                if (btnSubmit) btnSubmit.disabled = true;
                warningBox.classList.add("hidden");
                return;
            }

            const startMin = timeToMinutes(startVal);
            const endMin = timeToMinutes(endVal);

            // Validations
            if (endMin <= startMin) {
                if (btnSubmit) btnSubmit.disabled = true;
                return;
            }

            const hasOverlap = conflicts.some(b => {
                const bStart = timeToMinutes(b.start);
                const bEnd = timeToMinutes(b.end);
                return (startMin < bEnd && endMin > bStart);
            });

            if (hasOverlap) {
                warningBox.classList.remove("hidden");
                if (btnSubmit) btnSubmit.disabled = true;
            } else {
                warningBox.classList.add("hidden");
                if (btnSubmit) btnSubmit.disabled = false;
            }
        }

        // Initialize constraints on load
        applyTimeConstraints();
    </script>
</body>
</html>
