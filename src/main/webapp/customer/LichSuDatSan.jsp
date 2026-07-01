<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="vi" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch Sử Đặt Sân - V-SPORT Elite Arena</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <jsp:include page="/common/head.jsp" />
    <style>
        /* Ghi đè triệt để màu nền ấm (beige) và màu chữ mặc định từ head.jsp */
        body { 
            font-family: 'Inter', system-ui, -apple-system, sans-serif !important;
            background-color: #f8fafc !important; /* Force slate-50 background */
            color: #0f172a !important; /* Force slate-900 text */
        }
        .premium-card {
            background: #ffffff;
            border: 1px solid #f1f5f9;
            border-radius: 24px;
            box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.03), 0 8px 10px -6px rgba(15, 23, 42, 0.03);
        }
    </style>
</head>
<body class="min-h-screen flex flex-col antialiased">

    <!-- Header Navigation -->
    <jsp:include page="/common/header.jsp" />

    <!-- Main Content Area -->
    <main class="flex-grow pt-[120px] pb-24">
        <div class="max-w-[1500px] mx-auto px-4 sm:px-6 lg:px-8">
            
            <!-- 1. Green Hero Banner matching DatSan.jsp -->
            <div class="mb-10 bg-gradient-to-r from-green-600 via-emerald-600 to-teal-600 rounded-3xl p-8 sm:p-12 text-white shadow-xl relative overflow-hidden animate-fade-in-up">
                <!-- Decorative background elements -->
                <div class="absolute -right-10 -bottom-10 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                <div class="absolute -left-10 -top-10 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                
                <div class="relative z-10 max-w-2xl">
                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/20 text-xs font-semibold uppercase tracking-wider mb-4 backdrop-blur-md">
                        <i class="fa-solid fa-clock-rotate-left"></i> Hoạt động của bạn
                    </span>
                    <h1 class="text-3xl sm:text-5xl font-extrabold tracking-tight mb-3">Lịch Sử Đặt Sân</h1>
                    <p class="text-white/80 text-sm sm:text-base leading-relaxed">
                        Theo dõi danh sách ca chơi, quản lý các yêu cầu đặt sân trực tuyến và kiểm tra trạng thái duyệt lịch của bạn.
                    </p>
                </div>
            </div>

            <!-- Success Alert Message -->
            <c:if test="${not empty sessionScope.message}">
                <div class="mb-6 p-4 bg-emerald-50 border border-emerald-100 rounded-2xl text-emerald-800 text-xs font-bold flex items-center gap-3 shadow-sm max-w-xl animate-fade-in-up">
                    <span class="material-symbols-outlined text-emerald-600 text-[20px]">check_circle</span>
                    <span>${sessionScope.message}</span>
                    <% session.removeAttribute("message"); %>
                </div>
            </c:if>

            <!-- 2. Responsive 2-Column Dashboard Layout -->
            <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
                
                <!-- Sidebar: User Stats & Quick Links (1 Column) -->
                <div class="lg:col-span-1 space-y-6">
                    <div class="premium-card p-6 flex flex-col items-center text-center">
                        <!-- User Initial Avatar -->
                        <div class="w-16 h-16 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center font-extrabold text-2xl shadow-inner mb-4">
                            <c:choose>
                                <c:when test="${not empty user.fullName}">
                                    ${fn:substring(user.fullName, 0, 1).toUpperCase()}
                                </c:when>
                                <c:otherwise>
                                    ${fn:substring(user.username, 0, 1).toUpperCase()}
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <h3 class="font-extrabold text-slate-800 text-base leading-tight">${user.fullName}</h3>
                        <p class="text-slate-450 text-xs mt-1 font-medium">${user.email}</p>
                        
                        <div class="w-full border-t border-slate-100 my-5"></div>
                        
                        <!-- Simple stats -->
                        <div class="w-full grid grid-cols-2 gap-4">
                            <div class="text-center bg-slate-50 rounded-xl p-3 border border-slate-100">
                                <span class="text-[10px] text-slate-400 font-bold block uppercase tracking-wide">Đặt Sân</span>
                                <span class="text-lg font-black text-emerald-600 mt-1 block">${dsLich.size()}</span>
                            </div>
                            <div class="text-center bg-slate-50 rounded-xl p-3 border border-slate-100">
                                <span class="text-[10px] text-slate-400 font-bold block uppercase tracking-wide">Điểm Uy Tín</span>
                                <span class="text-lg font-black text-slate-700 mt-1 block">${user.diemUyTin != null ? user.diemUyTin : 100}</span>
                            </div>
                        </div>
                        
                        <a href="${pageContext.request.contextPath}/customer/dat-san" class="w-full mt-6 bg-emerald-600 hover:bg-emerald-700 text-white font-extrabold text-xs py-3 rounded-xl flex items-center justify-center gap-1.5 transition-all shadow-sm shadow-emerald-600/10 active:scale-95 duration-200">
                            <span class="material-symbols-outlined text-[16px]">add_circle</span>
                            Đặt sân mới ngay
                        </a>
                    </div>
                </div>

                <!-- Main Content: History Table Card (3 Columns) -->
                <div class="lg:col-span-3">
                    <div class="premium-card p-6 overflow-hidden">
                        <div class="flex justify-between items-center mb-6">
                            <h2 class="text-base font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
                                <span class="material-symbols-outlined text-emerald-600 text-[20px]">calendar_month</span>
                                Danh sách đơn đặt sân hôm nay & trước đó
                            </h2>
                        </div>
                        
                        <div class="overflow-x-auto rounded-2xl border border-slate-100">
                            <table class="w-full text-left text-xs border-collapse">
                                <thead>
                                    <tr class="bg-slate-50/70 border-b border-slate-100 text-slate-500 font-bold">
                                        <th class="p-4">Sân & Địa điểm</th>
                                        <th class="p-4 text-center">Thời gian thi đấu</th>
                                        <th class="p-4 text-right">Chi phí</th>
                                        <th class="p-4 text-center">Trạng thái</th>
                                        <th class="p-4 text-center">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-slate-100 bg-white">
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

                                        <tr class="hover:bg-slate-50/30 transition-colors">
                                            <td class="p-4">
                                                <div class="flex flex-col gap-0.5">
                                                    <span class="font-extrabold text-sm text-slate-900">${tenSanHienThi}</span>
                                                    <span class="text-[10px] text-slate-450 font-bold flex items-center gap-1">
                                                        <c:if test="${not empty branchHienThi}">
                                                            <span class="material-symbols-outlined text-[12px] text-slate-400">location_on</span>
                                                            ${branchHienThi} &middot;
                                                        </c:if>
                                                        Mã: #${lich.datSanId}
                                                    </span>
                                                </div>
                                            </td>
                                            <td class="p-4 text-center">
                                                <div class="flex flex-col gap-0.5">
                                                    <span class="font-bold text-slate-700">${lich.ngayDat}</span>
                                                    <span class="text-xs text-emerald-600 font-extrabold font-mono">${lich.gioBatDau.toString().substring(0,5)} — ${lich.gioKetThuc.toString().substring(0,5)}</span>
                                                </div>
                                            </td>
                                            <td class="p-4 text-right font-extrabold text-slate-900 text-sm">
                                                <fmt:formatNumber value="${lich.tongTienDuKien}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                            </td>
                                            <td class="p-4 text-center">
                                                <c:choose>
                                                    <c:when test="${lich.trangThai == 'Chờ xác nhận'}">
                                                        <span class="bg-amber-50 text-amber-700 border border-amber-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Chờ duyệt</span>
                                                    </c:when>
                                                    <c:when test="${lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đã đặt'}">
                                                        <span class="bg-green-50 text-green-700 border border-green-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đã duyệt</span>
                                                    </c:when>
                                                    <c:when test="${lich.trangThai == 'Đang sử dụng'}">
                                                        <span class="bg-purple-50 text-purple-700 border border-purple-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đang đá</span>
                                                    </c:when>
                                                    <c:when test="${lich.trangThai == 'Đã hủy'}">
                                                        <span class="bg-red-50 text-red-700 border border-red-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="bg-slate-100 text-slate-500 border border-slate-200 px-2.5 py-1 rounded-lg text-[10px] font-bold inline-block">${lich.trangThai}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="p-4 text-center">
                                                <div class="flex items-center justify-center gap-1.5">
                                                    <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận'}">
                                                        <form action="${pageContext.request.contextPath}/customer/huy-dat-san" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu đặt sân này?');" class="inline-block">
                                                            <input type="hidden" name="id" value="${lich.datSanId}">
                                                            <button type="submit" class="px-3 py-1.5 rounded-lg border border-red-200 text-red-500 font-bold hover:bg-red-50 hover:border-red-300 transition-all active:scale-95 text-[10px]">
                                                                Hủy
                                                            </button>
                                                        </form>
                                                    </c:if>
                                                    <c:if test="${lich.trangThai == 'Chờ xác nhận' || lich.trangThai == 'Đã xác nhận' || lich.trangThai == 'Đang sử dụng'}">
                                                        <button type="button" onclick="openCustomerServiceModal(${lich.datSanId})" class="px-3 py-1.5 rounded-lg border border-emerald-200 bg-emerald-50 text-emerald-600 font-bold hover:bg-emerald-100 transition-all active:scale-95 text-[10px]">
                                                            Dịch vụ
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${lich.trangThai == 'Đã hủy'}">
                                                        <span class="text-slate-400 text-[10px] line-through">Không khả dụng</span>
                                                    </c:if>
                                                    <c:if test="${lich.trangThai == 'Đã hoàn thành'}">
                                                        <span class="text-green-600 text-[10px] font-bold">Hoàn thành</span>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty dsLich}">
                                        <tr>
                                            <td colspan="5" class="p-16 text-center">
                                                <span class="material-symbols-outlined text-[40px] text-slate-200 block mb-4">event_busy</span>
                                                <p class="text-slate-400 text-[11px] font-extrabold uppercase tracking-widest">Chưa có dữ liệu lịch sử đặt sân</p>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </main>

    <!-- Footer -->
    <jsp:include page="/common/footer.jsp" />

    <script>
        // Active link highlight
        const navHistory = document.getElementById('nav-history');
        if (navHistory) {
            navHistory.classList.add('active');
        }
    </script>

    <!-- CUSTOMER SERVICE BOOKING MODAL -->
    <div id="customerServiceModal" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[60] hidden flex items-center justify-center opacity-0 transition-opacity duration-300 overflow-y-auto py-10 px-4">
        <div class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl overflow-hidden transform scale-95 transition-all duration-300 relative my-auto">
            <div class="bg-gradient-to-r from-emerald-600 to-teal-600 px-6 py-4 flex items-center justify-between text-white">
                <h3 class="font-bold text-lg flex items-center gap-2">
                    <span class="material-symbols-outlined">coffee</span> Đặt thêm Dịch vụ / Nước uống
                </h3>
                <button onclick="closeCustomerServiceModal()" class="text-white/80 hover:text-white transition-colors p-1">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            
            <div class="p-6 md:p-8 max-h-[70vh] overflow-y-auto">
                <form id="customer-service-form" action="${pageContext.request.contextPath}/customer/dat-dich-vu" method="post" class="space-y-6">
                    <input type="hidden" name="datSanId" id="customer-service-datsan-id">
                    
                    <div id="customer-service-loading" class="text-center py-10 text-slate-500">
                        <span class="material-symbols-outlined animate-spin text-[32px] text-emerald-600 mb-2">sync</span>
                        <p class="text-sm font-medium">Đang tải danh sách dịch vụ...</p>
                    </div>
                    
                    <div id="customer-service-container" class="hidden space-y-4">
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4" id="customer-products-grid">
                            <!-- Populated dynamically via JS -->
                        </div>
                    </div>
                    
                    <div class="pt-6 border-t border-slate-100 flex justify-between items-center">
                        <div>
                            <span class="text-xs font-bold text-slate-400 uppercase block">Tổng tiền dịch vụ thêm</span>
                            <span class="text-xl font-bold text-emerald-600" id="customer-service-total">0 đ</span>
                        </div>
                        <div class="flex gap-3">
                            <button type="button" onclick="closeCustomerServiceModal()" class="px-6 py-3 rounded-xl font-bold text-slate-600 bg-slate-100 hover:bg-slate-200 transition-colors">
                                Hủy
                            </button>
                            <button type="submit" class="px-8 py-3 rounded-xl font-bold text-white bg-emerald-600 hover:bg-emerald-700 transition-all shadow-md hover:shadow-emerald-600/20 active:scale-95 duration-200">
                                Xác nhận đặt
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        let customerProducts = [];
        let customerOrdered = [];

        function openCustomerServiceModal(datSanId) {
            document.getElementById("customer-service-datsan-id").value = datSanId;
            
            const modal = document.getElementById("customerServiceModal");
            const loading = document.getElementById("customer-service-loading");
            const container = document.getElementById("customer-service-container");
            const grid = document.getElementById("customer-products-grid");
            
            modal.classList.remove("hidden");
            modal.classList.add("flex");
            loading.classList.remove("hidden");
            container.classList.add("hidden");
            
            setTimeout(() => {
                modal.classList.remove("opacity-0");
                modal.querySelector(".bg-white").classList.remove("scale-95");
            }, 10);

            // Fetch data
            fetch(`${pageContext.request.contextPath}/customer/dat-dich-vu?datSanId=${datSanId}`)
                .then(res => res.json())
                .then(data => {
                    customerProducts = data.products || [];
                    customerOrdered = data.ordered || [];
                    
                    loading.classList.add("hidden");
                    container.classList.remove("hidden");
                    
                    grid.innerHTML = "";
                    if (customerProducts.length === 0) {
                        grid.innerHTML = `<div class="col-span-2 text-center text-slate-400 py-8 italic">Cơ sở này hiện không có sản phẩm/dịch vụ nào đang kinh doanh.</div>`;
                        return;
                    }

                    customerProducts.forEach(prod => {
                        const ord = customerOrdered.find(o => o.SanPhamID === prod.SanPhamID);
                        const qty = ord ? ord.SoLuong : 0;
                        
                        const itemHtml = `
                            <div class="p-4 bg-slate-50 border border-slate-100 rounded-2xl flex items-center justify-between shadow-sm">
                                <div class="flex-grow min-w-0 pr-4">
                                    <h4 class="font-bold text-slate-800 text-sm truncate">${prod.TenSanPham}</h4>
                                    <p class="text-xs text-slate-500 mt-0.5">${prod.DonGia.toLocaleString('vi-VN')} đ / ${prod.DonViTinh || 'cái'}</p>
                                    <p class="text-[10px] text-slate-400 italic mt-0.5 truncate">${prod.MoTa || 'Sản phẩm phục vụ tại sân'}</p>
                                    <p class="text-[10px] text-slate-500 font-semibold mt-1">Còn lại: ${prod.SoLuongTon} ${prod.DonViTinh || 'cái'}</p>
                                </div>
                                <div class="flex items-center gap-2 shrink-0">
                                    <input type="hidden" name="productId" value="${prod.SanPhamID}">
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, -1)" class="w-8 h-8 rounded-lg bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold flex items-center justify-center transition-colors select-none">-</button>
                                    <input type="number" name="quantity" id="cust-qty-${prod.SanPhamID}" value="${qty}" min="0" max="${prod.SoLuongTon}" class="w-12 text-center bg-white border border-slate-200 rounded-lg py-1 text-sm font-bold" readonly>
                                    <button type="button" onclick="adjustCustomerQty(${prod.SanPhamID}, 1)" class="w-8 h-8 rounded-lg bg-slate-200 hover:bg-slate-300 text-slate-700 font-bold flex items-center justify-center transition-colors select-none">+</button>
                                </div>
                            </div>
                        `;
                        grid.insertAdjacentHTML("beforeend", itemHtml);
                    });
                    
                    recalculateCustomerTotal();
                })
                .catch(err => {
                    grid.innerHTML = `<div class="col-span-2 text-center text-red-500 py-8 italic">Có lỗi xảy ra khi tải dữ liệu: ${err.message}</div>`;
                    loading.classList.add("hidden");
                    container.classList.remove("hidden");
                });
        }

        function adjustCustomerQty(spId, delta) {
            const input = document.getElementById(`cust-qty-${spId}`);
            if (!input) return;
            
            const prod = customerProducts.find(p => p.SanPhamID === spId);
            if (!prod) return;
            
            let val = parseInt(input.value) || 0;
            val += delta;
            
            if (val < 0) val = 0;
            if (val > prod.SoLuongTon) {
                alert(`Không thể chọn vượt quá số lượng tồn kho (${prod.SoLuongTon})`);
                val = prod.SoLuongTon;
            }
            
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
            const modal = document.getElementById("customerServiceModal");
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
