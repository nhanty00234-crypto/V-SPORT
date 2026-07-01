<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <title>${san.tenSan} - V-SPORT</title>
    <jsp:include page="/common/head.jsp" />
    <style>
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .material-symbols-outlined.filled {
            font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        .hide-scroll::-webkit-scrollbar { display: none; }
        .hide-scroll { -ms-overflow-style: none; scrollbar-width: none; }
    </style>
</head>
<body class="bg-[#f7f9fb] text-[#191c1e] font-sans antialiased min-h-screen flex flex-col">

    <jsp:include page="/common/header.jsp" />

    <main class="flex-grow pt-[80px] pb-16">
        <div class="w-full max-w-7xl mx-auto px-4 md:px-12 py-10">

            <!-- Breadcrumbs -->
            <div class="flex items-center gap-2 text-[#3d4a3d] text-xs font-semibold mb-10">
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="hover:text-[#006e2f] transition-colors">Tìm Sân</a>
                <span class="material-symbols-outlined text-[16px]">chevron_right</span>
                <a href="${pageContext.request.contextPath}/customer/dat-san" class="hover:text-[#006e2f] transition-colors">Danh sách sân</a>
                <span class="material-symbols-outlined text-[16px]">chevron_right</span>
                <span class="text-[#191c1e] font-bold">${san.tenSan}</span>
            </div>

            <!-- Hero Gallery Bento -->
            <section class="grid grid-cols-1 md:grid-cols-4 md:grid-rows-2 gap-2 md:gap-3 h-[340px] md:h-[480px] mb-16 rounded-xl overflow-hidden">
                <!-- Main large image (col-span-3, row-span-2) -->
                <div class="md:col-span-3 md:row-span-2 relative group cursor-pointer">
                    <img src="${not empty san.hinhAnh ? san.hinhAnh : 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?q=80&w=1400'}"
                         alt="${san.tenSan}"
                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105">
                    <div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                    <!-- Status badge -->
                    <div class="absolute top-4 left-4">
                        <span class="px-3 py-1.5 rounded-full text-xs font-extrabold uppercase tracking-wider shadow backdrop-blur-md flex items-center gap-1.5
                              ${san.trangThai == 'Sẵn sàng' ? 'bg-green-600/90 text-white' : 'bg-amber-500/90 text-white'}">
                            <span class="w-1.5 h-1.5 rounded-full bg-white animate-pulse"></span>
                            ${san.trangThai == 'Sẵn sàng' ? 'Trống sân' : 'Đang dùng'}
                        </span>
                    </div>
                    <button class="absolute bottom-4 right-4 bg-white/90 backdrop-blur-sm px-4 py-2 rounded-full text-xs font-semibold flex items-center gap-1.5 hover:bg-white transition-colors shadow-sm text-[#191c1e]">
                        <span class="material-symbols-outlined text-[16px]">photo_library</span>
                        Xem tất cả ảnh
                    </button>
                </div>
                <!-- Thumbnail 1 -->
                <div class="hidden md:block relative overflow-hidden group cursor-pointer">
                    <img src="${not empty san.hinhAnh ? san.hinhAnh : 'https://images.unsplash.com/photo-1544698310-74ea9d1c8258?q=80&w=600'}"
                         alt="${san.tenSan} - ảnh 2"
                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 brightness-90">
                    <div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                </div>
                <!-- Thumbnail 2 -->
                <div class="hidden md:block relative overflow-hidden group cursor-pointer">
                    <img src="https://images.unsplash.com/photo-1528972042015-f4b8a57c5c3c?q=80&w=600"
                         alt="${san.tenSan} - ảnh 3"
                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 brightness-90">
                    <div class="absolute inset-0 bg-black/10 group-hover:bg-transparent transition-colors"></div>
                </div>
            </section>

            <!-- Main Content: Left + Right -->
            <div class="flex flex-col lg:flex-row gap-16">

                <!-- LEFT COLUMN: Details (2/3) -->
                <div class="w-full lg:w-2/3 flex flex-col gap-10">

                    <!-- Header Info -->
                    <div>
                        <div class="flex justify-between items-start mb-3">
                            <h1 class="text-2xl md:text-3xl font-bold text-[#191c1e] leading-tight">${san.tenSan}</h1>
                        </div>
                        <div class="flex flex-wrap items-center gap-x-4 gap-y-2 text-[#3d4a3d] text-sm font-medium mb-4">
                            <div class="flex items-center gap-1">
                                <span class="material-symbols-outlined text-[18px] text-[#006e2f] filled">star</span>
                                <span class="text-[#6d7b6c]">${coSo.tenCoSo}</span>
                            </div>
                            <span class="text-[#bccbb9]">•</span>
                            <div class="flex items-center gap-1">
                                <span class="material-symbols-outlined text-[18px]">location_on</span>
                                <span>${coSo.diaChi}</span>
                            </div>
                        </div>
                        <!-- Sport / Type tags -->
                        <div class="flex flex-wrap gap-2">
                            <span class="px-3 py-1 bg-[#006e2f]/10 text-[#004b1e] rounded font-semibold text-xs">${tenMon}</span>
                            <span class="px-3 py-1 bg-[#006e2f]/10 text-[#004b1e] rounded font-semibold text-xs">${loai.tenLoai}</span>
                            <span class="px-3 py-1 bg-[#006e2f]/10 text-[#004b1e] rounded font-semibold text-xs">
                                ${coSo.gioMoCua != null ? coSo.gioMoCua : '06:00'} – ${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}
                            </span>
                            <span class="px-3 py-1 bg-[#006e2f]/10 text-[#004b1e] rounded font-semibold text-xs">${totalSimilarCourts} sân tương tự</span>
                        </div>
                    </div>

                    <hr class="border-[#e6e8ea]">

                    <!-- Description -->
                    <div>
                        <h2 class="text-xl font-semibold text-[#191c1e] mb-3">Giới thiệu sân</h2>
                        <p class="text-base text-[#3d4a3d] leading-relaxed">
                            ${not empty san.moTa ? san.moTa : 'Hệ thống sân đấu tiêu chuẩn với mặt sân cao cấp, hệ thống thoát nước tối ưu đảm bảo sân luôn khô ráo và bám tốt. Sân được trang bị hệ thống chiếu sáng LED chuyên nghiệp phục vụ thi đấu vào ban đêm. Thích hợp cho cả tập luyện phong trào và tổ chức các giải đấu quy mô vừa.'}
                        </p>
                    </div>

                    <hr class="border-[#e6e8ea]">

                    <!-- Amenities -->
                    <div>
                        <h2 class="text-xl font-semibold text-[#191c1e] mb-6">Tiện ích</h2>
                        <div class="grid grid-cols-2 md:grid-cols-3 gap-y-6 gap-x-4">
                            <div class="flex items-center gap-3 text-[#3d4a3d]">
                                <span class="material-symbols-outlined text-[24px] text-[#006e2f]">wifi</span>
                                <span class="text-base">Wifi miễn phí</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3d4a3d]">
                                <span class="material-symbols-outlined text-[24px] text-[#006e2f]">local_parking</span>
                                <span class="text-base">Bãi đỗ xe</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3d4a3d]">
                                <span class="material-symbols-outlined text-[24px] text-[#006e2f]">lightbulb</span>
                                <span class="text-base">Đèn chiếu sáng</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3d4a3d]">
                                <span class="material-symbols-outlined text-[24px] text-[#006e2f]">shower</span>
                                <span class="text-base">Phòng tắm</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3d4a3d]">
                                <span class="material-symbols-outlined text-[24px] text-[#006e2f]">local_drink</span>
                                <span class="text-base">Nước uống</span>
                            </div>
                            <div class="flex items-center gap-3 text-[#3d4a3d]">
                                <span class="material-symbols-outlined text-[24px] text-[#006e2f]">security</span>
                                <span class="text-base">Bảo vệ 24/7</span>
                            </div>
                        </div>
                    </div>

                    <hr class="border-[#e6e8ea]">

                    <!-- Location / Map -->
                    <div>
                        <h2 class="text-xl font-semibold text-[#191c1e] mb-2">Vị trí</h2>
                        <p class="text-base text-[#3d4a3d] mb-4 flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-[18px] text-[#006e2f]">location_on</span>
                            ${coSo.diaChi}
                        </p>
                        <div class="w-full h-56 bg-[#eceef0] rounded-xl overflow-hidden border border-[#e0e3e5] shadow-sm">
                            <iframe
                                src="https://maps.google.com/maps?q=${fn:replace(coSo.diaChi, ' ', '+')}&output=embed&z=15"
                                class="w-full h-full border-0"
                                allowfullscreen=""
                                loading="lazy"
                                referrerpolicy="no-referrer-when-downgrade"
                                title="Bản đồ ${coSo.tenCoSo}">
                            </iframe>
                        </div>
                    </div>

                </div>

                <!-- RIGHT COLUMN: Booking Widget (1/3) -->
                <div class="w-full lg:w-1/3">
                    <div class="sticky top-24 bg-white rounded-xl shadow-[0_4px_12px_rgba(0,0,0,0.08)] border border-[#e0e3e5] p-6 flex flex-col gap-5">

                        <!-- Price Header -->
                        <div class="flex justify-between items-end">
                            <div>
                                <span class="text-2xl font-bold text-[#191c1e]"><fmt:formatNumber value="${loai.giaKhongDen}" pattern="#,##0"/> đ</span>
                                <span class="text-sm text-[#6d7b6c]">/giờ</span>
                            </div>
                            <span class="text-xs font-semibold px-2.5 py-1 rounded-full
                                  ${san.trangThai == 'Sẵn sàng' ? 'bg-green-100 text-green-700' : 'bg-amber-100 text-amber-700'}">
                                ${san.trangThai == 'Sẵn sàng' ? 'Còn trống' : 'Đang dùng'}
                            </span>
                        </div>

                        <!-- Alert messages -->
                        <c:if test="${not empty sessionScope.error}">
                            <div class="p-3.5 bg-red-50 border border-red-200 text-red-600 text-xs rounded-lg flex items-start gap-2">
                                <span class="material-symbols-outlined text-[16px] shrink-0 mt-0.5">error</span>
                                <span>${sessionScope.error}</span>
                            </div>
                            <% session.removeAttribute("error"); %>
                        </c:if>
                        <c:if test="${not empty sessionScope.message}">
                            <div class="p-3.5 bg-green-50 border border-green-200 text-green-700 text-xs rounded-lg flex items-start gap-2">
                                <span class="material-symbols-outlined text-[16px] shrink-0 mt-0.5">check_circle</span>
                                <span>${sessionScope.message}</span>
                            </div>
                            <% session.removeAttribute("message"); %>
                        </c:if>

                        <form id="quick-booking-form" action="${pageContext.request.contextPath}/customer/dat-san" method="post" class="flex flex-col gap-5">
                            <input type="hidden" name="sanId" value="${san.sanID}">
                            <input type="hidden" name="gioBatDau" id="gioBatDau">
                            <input type="hidden" name="gioKetThuc" id="gioKetThuc">

                            <!-- Date Picker -->
                            <div class="flex flex-col gap-1.5">
                                <label for="ngayDat" class="text-sm font-semibold text-[#191c1e]">Chọn ngày</label>
                                <div class="flex items-center border border-[#bccbb9] rounded-lg px-3 py-2.5 bg-[#f7f9fb] hover:border-[#006e2f] focus-within:border-[#006e2f] focus-within:ring-2 focus-within:ring-[#006e2f]/20 transition-all">
                                    <input type="date" name="ngayDat" id="ngayDat" required
                                           class="bg-transparent border-none p-0 w-full text-sm text-[#191c1e] outline-none"
                                           onchange="onDateChange()">
                                </div>
                            </div>

                            <!-- Time Slots Grid -->
                            <div class="flex flex-col gap-2">
                                <div class="flex justify-between items-center">
                                    <label class="text-sm font-semibold text-[#191c1e]">Chọn khung giờ</label>
                                    <span class="text-xs text-[#006e2f] font-medium">
                                        ${coSo.gioMoCua != null ? coSo.gioMoCua : '06:00'} – ${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}
                                    </span>
                                </div>
                                <div id="time-grid" class="grid grid-cols-3 gap-1.5 max-h-[200px] overflow-y-auto hide-scroll">
                                    <!-- Dynamic chips rendered by JS -->
                                </div>
                                <div id="time-summary" class="hidden text-xs font-semibold text-[#006e2f] bg-green-50 border border-green-200 rounded-lg px-3 py-2">
                                </div>
                                <div id="overlap-warning" class="hidden bg-red-50 border border-red-200 text-red-600 p-3 rounded-lg text-xs flex gap-2 items-start">
                                    <span class="material-symbols-outlined text-[15px] mt-0.5 shrink-0">warning</span>
                                    <span id="overlap-warning-text">Trùng lịch đặt sân!</span>
                                </div>
                            </div>

                            <!-- Notes -->
                            <div class="flex flex-col gap-1.5">
                                <label for="ghiChu" class="text-sm font-semibold text-[#191c1e]">Ghi chú</label>
                                <textarea name="ghiChu" id="ghiChu" rows="2"
                                          class="border border-[#bccbb9] rounded-lg px-3 py-2.5 text-sm bg-[#f7f9fb] text-[#191c1e] placeholder-[#6d7b6c] resize-none outline-none hover:border-[#006e2f] focus:border-[#006e2f] focus:ring-2 focus:ring-[#006e2f]/20 transition-all"
                                          placeholder="Thuê bóng, mượn áo tập..."></textarea>
                            </div>

                            <!-- Payment Method -->
                            <div class="grid grid-cols-2 gap-2">
                                <label class="pay-opt border-2 border-[#006e2f] bg-green-50/30 rounded-lg p-2.5 flex items-center justify-center cursor-pointer font-semibold text-xs text-[#006e2f] active:scale-95 transition-all" id="lbl-opt-sau">
                                    <input type="radio" name="paymentMethod" value="sau" checked class="hidden" onchange="changePayMethod('sau')">
                                    Trả tại quầy
                                </label>
                                <label class="pay-opt border-2 border-[#e0e3e5] rounded-lg p-2.5 flex items-center justify-center cursor-pointer font-semibold text-xs text-[#6d7b6c] hover:border-[#bccbb9] active:scale-95 transition-all" id="lbl-opt-payos">
                                    <input type="radio" name="paymentMethod" value="payos" class="hidden" onchange="changePayMethod('payos')">
                                    PayOS Online
                                </label>
                            </div>

                            <hr class="border-[#e6e8ea]">

                            <!-- Price Breakdown -->
                            <div id="price-breakdown" class="hidden flex-col gap-2">
                                <div class="flex justify-between text-sm text-[#6d7b6c]">
                                    <span id="price-line-desc"></span>
                                    <span id="price-line-amount"></span>
                                </div>
                                <div class="flex justify-between font-bold text-base text-[#191c1e] pt-2 border-t border-[#e6e8ea] mt-1">
                                    <span>Tổng cộng</span>
                                    <span id="price-total" class="text-[#006e2f]"></span>
                                </div>
                            </div>

                            <!-- Submit / Login CTA -->
                            <c:choose>
                                <c:when test="${sessionScope.user != null}">
                                    <button type="submit" id="btn-submit-booking" disabled
                                            class="w-full bg-[#006e2f] text-white font-semibold text-base py-4 rounded-lg hover:bg-[#005321] active:scale-[0.98] transition-all shadow-sm flex items-center justify-center gap-2 disabled:opacity-40 disabled:cursor-not-allowed">
                                        Đặt Sân Ngay
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/dangnhap"
                                       class="w-full bg-[#006e2f] text-white font-semibold text-base py-4 rounded-lg hover:bg-[#005321] active:scale-[0.98] transition-all shadow-sm flex items-center justify-center gap-2 text-center">
                                        Đăng Nhập Để Đặt Sân
                                        <span class="material-symbols-outlined text-[18px]">login</span>
                                    </a>
                                </c:otherwise>
                            </c:choose>

                            <p class="text-center text-xs text-[#6d7b6c]">Chưa tính phí cho đến khi đặt thành công</p>
                        </form>
                    </div>
                </div>

            </div><!-- end main content -->

        </div><!-- end container -->

        <!-- OTHER COURTS SECTION -->
        <div class="w-full max-w-7xl mx-auto px-4 md:px-12 mt-16">
            <div class="bg-white p-8 rounded-xl border border-[#e0e3e5] shadow-sm">
                <h2 class="text-xl font-bold text-[#191c1e] mb-6 flex items-center gap-2">
                    <span class="material-symbols-outlined text-[24px] text-[#006e2f]">sports_tennis</span>
                    Các sân đấu khác dành cho bạn
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-5">
                    <c:forEach var="os" items="${otherSans}" varStatus="loop">
                        <c:if test="${loop.index < 4}">
                            <c:set var="osCoSoName" value="Cơ Sở" />
                            <c:forEach var="cs" items="${dsCoSo}">
                                <c:if test="${cs.coSoID == os.coSoID}">
                                    <c:set var="osCoSoName" value="${cs.tenCoSo}" />
                                </c:if>
                            </c:forEach>
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
                            <c:set var="osSportName" value="Khác" />
                            <c:forEach var="m" items="${dsMon}">
                                <c:if test="${m.monTheThaoID == osSportId}">
                                    <c:set var="osSportName" value="${m.tenMon}" />
                                </c:if>
                            </c:forEach>

                            <div class="bg-[#f7f9fb] border border-[#e0e3e5] rounded-xl overflow-hidden flex flex-col transition-all duration-300 hover:shadow-md hover:-translate-y-1">
                                <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${os.sanID}" class="block group hover:no-underline">
                                    <div class="relative h-[130px] overflow-hidden bg-[#eceef0]">
                                        <img src="${not empty os.hinhAnh ? os.hinhAnh : 'https://images.unsplash.com/photo-1544698310-74ea9d1c8258?q=80&w=600'}"
                                             alt="${os.tenSan}"
                                             class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105">
                                        <span class="absolute top-2 right-2 px-2 py-0.5 rounded bg-black/60 text-white text-[9px] font-bold uppercase tracking-wider backdrop-blur-sm">${osSportName}</span>
                                    </div>
                                    <div class="p-4 space-y-1.5">
                                        <h4 class="font-bold text-[#191c1e] text-sm truncate group-hover:text-[#006e2f] transition-colors">${os.tenSan}</h4>
                                        <p class="text-xs text-[#6d7b6c] flex items-center gap-1">
                                            <span class="material-symbols-outlined text-[13px]">location_on</span>
                                            ${osCoSoName}
                                        </p>
                                        <p class="text-[11px] text-[#6d7b6c] italic truncate">${osTypeName}</p>
                                    </div>
                                </a>
                                <div class="px-4 pb-4 pt-0 flex items-center justify-between border-t border-[#e6e8ea] mt-auto">
                                    <span class="text-sm font-bold text-[#006e2f]"><fmt:formatNumber value="${osPrice}" pattern="#,##0"/> đ<span class="text-[10px] font-normal text-[#6d7b6c]">/h</span></span>
                                    <a href="${pageContext.request.contextPath}/customer/chi-tiet-san?id=${os.sanID}"
                                       class="px-3 py-1.5 bg-[#006e2f] text-white rounded-lg text-[11px] font-semibold hover:bg-[#005321] hover:no-underline transition-all">
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
        const branchOpenTime = "${coSo.gioMoCua != null ? coSo.gioMoCua : '06:00'}";
        const branchCloseTime = "${coSo.gioDongCua != null ? coSo.gioDongCua : '23:00'}";
        const pricePerHour = parseFloat("${loai.giaKhongDen != null ? loai.giaKhongDen : 0}");

        let selectedStartMin = null;
        let selectedEndMin = null;

        const activeBookings = [
            <c:forEach var="b" items="${activeBookings}">
                <c:if test="${b.sanId == san.sanID && b.trangThai != 'Đã hủy'}">
                    { id: ${b.datSanId}, date: "${b.ngayDat}", start: "${b.gioBatDau}", end: "${b.gioKetThuc}", status: "${b.trangThai}" },
                </c:if>
            </c:forEach>
        ];

        const today = new Date();
        const todayStr = today.getFullYear() + "-" + String(today.getMonth() + 1).padStart(2, "0") + "-" + String(today.getDate()).padStart(2, "0");
        document.getElementById("ngayDat").min = todayStr;
        document.getElementById("ngayDat").value = todayStr;

        function changePayMethod(method) {
            const activeClass = "pay-opt border-2 border-[#006e2f] bg-green-50/30 rounded-lg p-2.5 flex items-center justify-center cursor-pointer font-semibold text-xs text-[#006e2f] active:scale-95 transition-all";
            const inactiveClass = "pay-opt border-2 border-[#e0e3e5] rounded-lg p-2.5 flex items-center justify-center cursor-pointer font-semibold text-xs text-[#6d7b6c] hover:border-[#bccbb9] active:scale-95 transition-all";
            document.getElementById("lbl-opt-sau").className = method === 'sau' ? activeClass : inactiveClass;
            document.getElementById("lbl-opt-payos").className = method === 'payos' ? activeClass : inactiveClass;
        }

        function timeToMinutes(t) {
            const p = t.split(":");
            return parseInt(p[0], 10) * 60 + parseInt(p[1], 10);
        }

        function minToStr(m) {
            return String(Math.floor(m / 60)).padStart(2, "0") + ":" + String(m % 60).padStart(2, "0");
        }

        function formatDuration(mins) {
            const h = Math.floor(mins / 60), m = mins % 60;
            return (h > 0 ? h + " tiếng " : "") + (m > 0 ? m + " phút" : "");
        }

        function onDateChange() {
            selectedStartMin = null;
            selectedEndMin = null;
            document.getElementById("gioBatDau").value = "";
            document.getElementById("gioKetThuc").value = "";
            renderTimeGrid();
            updatePriceBreakdown();
        }

        function findNextBlockedMin(startMin, closeMin, conflicts) {
            let limit = closeMin;
            conflicts.forEach(b => {
                const bs = timeToMinutes(b.start);
                if (bs > startMin && bs < limit) limit = bs;
            });
            return limit;
        }

        function renderTimeGrid() {
            const openMin = timeToMinutes(branchOpenTime);
            const closeMin = timeToMinutes(branchCloseTime);
            const dateVal = document.getElementById("ngayDat").value;
            const grid = document.getElementById("time-grid");
            const summary = document.getElementById("time-summary");
            grid.innerHTML = "";

            const conflicts = activeBookings.filter(b => b.date === dateVal);
            let nowMin = -1;
            if (dateVal === todayStr) {
                const n = new Date();
                nowMin = n.getHours() * 60 + n.getMinutes();
            }

            let rangeLimit = null;
            if (selectedStartMin !== null && selectedEndMin === null) {
                rangeLimit = findNextBlockedMin(selectedStartMin, closeMin, conflicts);
            }

            for (let m = openMin; m <= closeMin - 30; m += 30) {
                const isPast = m <= nowMin;
                const isBooked = conflicts.some(b => m >= timeToMinutes(b.start) && m < timeToMinutes(b.end));
                const isStart = m === selectedStartMin;
                const isEnd = m === selectedEndMin;
                const isInRange = selectedStartMin !== null && selectedEndMin !== null && m > selectedStartMin && m < selectedEndMin;
                const isExtendable = selectedStartMin !== null && selectedEndMin === null && m > selectedStartMin && rangeLimit !== null && m <= rangeLimit;

                const chip = document.createElement("button");
                chip.type = "button";
                chip.textContent = minToStr(m);

                let cls = "py-2 rounded-lg text-xs font-semibold border transition-colors text-center ";
                if (isPast) {
                    chip.disabled = true;
                    cls += "bg-[#f2f4f6] text-[#bccbb9] border-[#e0e3e5] cursor-not-allowed";
                } else if (isBooked) {
                    chip.disabled = true;
                    cls += "bg-red-50 text-red-300 border-red-200 cursor-not-allowed line-through";
                } else if (isStart || isEnd) {
                    cls += "border-2 border-[#006e2f] bg-[#006e2f] text-white shadow-sm";
                } else if (isInRange) {
                    cls += "border-[#006e2f]/40 bg-[#006e2f]/10 text-[#006e2f]";
                } else if (isExtendable) {
                    cls += "border-[#bccbb9] text-[#006e2f] hover:border-[#006e2f] hover:bg-green-50 cursor-pointer";
                } else {
                    cls += "border-[#bccbb9] text-[#3d4a3d] hover:border-[#006e2f] hover:text-[#006e2f] hover:bg-green-50 cursor-pointer";
                }
                chip.className = cls;
                if (!chip.disabled) chip.addEventListener("click", () => onChipClick(m));
                grid.appendChild(chip);
            }

            if (selectedStartMin !== null && selectedEndMin !== null) {
                summary.textContent = "Đã chọn: " + minToStr(selectedStartMin) + " – " + minToStr(selectedEndMin) + " (" + formatDuration(selectedEndMin - selectedStartMin) + ")";
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

            document.getElementById("gioBatDau").value = selectedStartMin !== null ? minToStr(selectedStartMin) : "";
            document.getElementById("gioKetThuc").value = selectedEndMin !== null ? minToStr(selectedEndMin) : "";

            renderTimeGrid();
            updatePriceBreakdown();
            checkSchedule();
        }

        function updatePriceBreakdown() {
            const breakdown = document.getElementById("price-breakdown");
            if (selectedStartMin === null || selectedEndMin === null || !pricePerHour) {
                breakdown.classList.add("hidden");
                breakdown.classList.remove("flex");
                return;
            }
            const hours = (selectedEndMin - selectedStartMin) / 60;
            const total = Math.round(pricePerHour * hours);
            document.getElementById("price-line-desc").textContent =
                pricePerHour.toLocaleString("vi-VN") + " đ × " + (hours % 1 === 0 ? hours : hours.toFixed(1)) + " giờ";
            document.getElementById("price-line-amount").textContent = total.toLocaleString("vi-VN") + " đ";
            document.getElementById("price-total").textContent = total.toLocaleString("vi-VN") + " đ";
            breakdown.classList.remove("hidden");
            breakdown.classList.add("flex");
        }

        function checkSchedule() {
            const dateVal = document.getElementById("ngayDat").value;
            const startVal = document.getElementById("gioBatDau").value;
            const endVal = document.getElementById("gioKetThuc").value;
            const btnSubmit = document.getElementById("btn-submit-booking");
            const warningBox = document.getElementById("overlap-warning");

            if (!startVal || !endVal) {
                if (btnSubmit) btnSubmit.disabled = true;
                warningBox.classList.add("hidden");
                return;
            }

            const startMin = timeToMinutes(startVal);
            const endMin = timeToMinutes(endVal);
            if (endMin <= startMin) { if (btnSubmit) btnSubmit.disabled = true; return; }

            const conflicts = activeBookings.filter(b => b.date === dateVal);
            const hasOverlap = conflicts.some(b => {
                const bs = timeToMinutes(b.start), be = timeToMinutes(b.end);
                return startMin < be && endMin > bs;
            });

            if (hasOverlap) {
                warningBox.classList.remove("hidden");
                if (btnSubmit) btnSubmit.disabled = true;
            } else {
                warningBox.classList.add("hidden");
                if (btnSubmit) btnSubmit.disabled = false;
            }
        }

        // Init
        renderTimeGrid();
    </script>
</body>
</html>
