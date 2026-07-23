<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<title>${pageTitle}</title>
<jsp:include page="/manager/common/manager_head.jsp" />
</head>
<body class="text-zinc-900 min-h-screen">

<jsp:include page="/manager/common/sidebar.jsp" />

<c:set var="headerTitle" value="Tổng quan Vận hành" scope="page" />
<c:set var="headerSubtitle" value="Chi nhánh cơ sở CS${sessionScope.user.coSoId}" scope="page" />
<c:set var="headerIcon" value="schedule" scope="page" />
<jsp:include page="/manager/common/header.jsp" />

<main class="lg:ml-[248px] mt-[64px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Welcome banner -->
  <section class="mgr-banner-shimmer rounded-2xl border border-purple-200 overflow-hidden relative">
    <div class="absolute -top-12 -right-12 w-64 h-64 bg-purple-300/20 rounded-full blur-3xl pointer-events-none"></div>
    <div class="absolute -bottom-12 -left-12 w-48 h-48 bg-indigo-300/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="relative p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
      <div class="flex items-center gap-4">
        <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=7c3aed&color=fff&bold=true" class="w-14 h-14 rounded-2xl object-cover shadow-md ring-4 ring-white" alt="Avatar">
        <div>
          <p class="text-[10px] font-bold uppercase tracking-widest text-purple-700 mb-1">CỔNG THÔNG TIN QUẢN LÝ</p>
          <h2 class="text-xl font-black text-purple-950 tracking-tight">Chào mừng trở lại, ${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}!</h2>
          <div class="flex items-center gap-3 mt-1.5 text-xs text-purple-600 flex-wrap">
            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px]">storefront</span>Cơ sở CS${sessionScope.user.coSoId}</span>
            <span class="text-purple-200">·</span>
            <span class="flex items-center gap-1 text-purple-700 font-semibold"><span class="w-1.5 h-1.5 rounded-full bg-purple-500 inline-block live-dot"></span>Hệ thống sẵn sàng</span>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- Tab Navigation -->
  <div class="flex items-center gap-1 bg-purple-50/60 rounded-xl p-1 border border-purple-100 w-fit">
    <button onclick="switchTab('overview')" id="tab-overview"
      class="tab-btn px-5 py-2 text-sm font-semibold rounded-lg transition-all flex items-center gap-2 active-tab">
      <span class="material-symbols-outlined text-[16px]">dashboard</span>Tổng quan
    </button>
    <button onclick="switchTab('revenue')" id="tab-revenue"
      class="tab-btn px-5 py-2 text-sm font-semibold rounded-lg transition-all flex items-center gap-2">
      <span class="material-symbols-outlined text-[16px]">bar_chart</span>Doanh thu
    </button>
    <button onclick="switchTab('reviews')" id="tab-reviews"
      class="tab-btn px-5 py-2 text-sm font-semibold rounded-lg transition-all flex items-center gap-2">
      <span class="material-symbols-outlined text-[16px]">star</span>Đánh giá
      <c:if test="${dashboardData.totalDanhGia > 0}">
        <span class="bg-purple-600 text-white text-[10px] font-bold px-1.5 py-0.5 rounded-full">${dashboardData.totalDanhGia}</span>
      </c:if>
    </button>
  </div>

  <!-- ===== TAB: TỔNG QUAN ===== -->
  <div id="panel-overview">

    <!-- KPI row -->
    <section class="grid grid-cols-2 lg:grid-cols-4 gap-4 stagger mb-5">
      <div class="card mgr-kpi-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center mgr-kpi-icon"><span class="material-symbols-outlined text-[20px] text-purple-700" style="font-variation-settings:'FILL' 1">event</span></div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">trending_up</span>Hôm nay</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Lịch đặt hôm nay</p>
        <p class="text-3xl font-black text-purple-950 tracking-tight" data-mgr-count="${dashboardData.bookingsTodayCount}">${dashboardData.bookingsTodayCount}</p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
          <p class="text-[11px] text-zinc-500">Chi nhánh CS${sessionScope.user.coSoId}</p>
          <svg width="50" height="20" viewBox="0 0 50 20" class="text-purple-500"><polyline fill="none" stroke="currentColor" stroke-width="1.5" points="0,15 8,12 16,14 24,8 32,10 40,5 50,8"/><polyline fill="rgba(139,92,246,.1)" stroke="none" points="0,15 8,12 16,14 24,8 32,10 40,5 50,8 50,20 0,20"/></svg>
        </div>
      </div>
      <div class="card mgr-kpi-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-indigo-50 flex items-center justify-center mgr-kpi-icon"><span class="material-symbols-outlined text-[20px] text-indigo-700" style="font-variation-settings:'FILL' 1">payments</span></div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md"><span class="material-symbols-outlined text-[12px]">trending_up</span>Đã thu</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu hôm nay</p>
        <p class="text-3xl font-black text-purple-950 tracking-tight">
          <fmt:formatNumber value="${dashboardData.revenueToday}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
        </p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
          <p class="text-[11px] text-zinc-500">Tổng doanh thu cơ sở</p>
          <p class="text-[11px] font-bold text-zinc-700"><fmt:formatNumber value="${dashboardData.totalRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
        </div>
      </div>
      <div class="card mgr-kpi-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-fuchsia-50 flex items-center justify-center mgr-kpi-icon"><span class="material-symbols-outlined text-[20px] text-fuchsia-700" style="font-variation-settings:'FILL' 1">stadium</span></div>
          <span class="badge badge-purple">Khả dụng</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Sân hoạt động</p>
        <p class="text-3xl font-black text-purple-950 tracking-tight" data-mgr-count="${dashboardData.activeFields}">${dashboardData.activeFields}<span class="text-lg text-zinc-400">/${dashboardData.totalFields}</span></p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
          <p class="text-[11px] text-zinc-500">Tình trạng sẵn sàng</p>
          <div class="flex gap-0.5"><span class="w-1 h-3 rounded-sm bg-purple-400"></span><span class="w-1 h-3 rounded-sm bg-purple-400"></span><span class="w-1 h-3 rounded-sm bg-purple-400"></span><span class="w-1 h-3 rounded-sm bg-purple-400"></span></div>
        </div>
      </div>
      <div class="card mgr-kpi-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-violet-50 flex items-center justify-center mgr-kpi-icon"><span class="material-symbols-outlined text-[20px] text-violet-700" style="font-variation-settings:'FILL' 1">groups</span></div>
          <span class="badge badge-purple">Nhân sự</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Nhân sự cơ sở</p>
        <p class="text-3xl font-black text-purple-950 tracking-tight" data-mgr-count="${dashboardData.totalStaff}">${dashboardData.totalStaff}</p>
        <div class="flex items-center justify-between mt-3 pt-3 border-t border-purple-50">
          <p class="text-[11px] text-zinc-500">Hoạt động tại CS${sessionScope.user.coSoId}</p>
          <span class="w-2.5 h-2.5 rounded-full bg-green-500 inline-block live-dot"></span>
        </div>
      </div>
    </section>

    <section class="grid grid-cols-1 xl:grid-cols-3 gap-5">
      <div class="xl:col-span-2 flex flex-col gap-5">
        <!-- Today Bookings List -->
        <div class="card overflow-hidden">
          <div class="flex items-center justify-between px-5 py-4 border-b border-purple-50">
            <div>
              <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">event_available</span>Lịch đặt sân hôm nay</h3>
              <p class="text-[11px] text-purple-500 mt-0.5">Danh sách lịch hoạt động trong ngày của chi nhánh</p>
            </div>
            <a href="${pageContext.request.contextPath}/manager/quan-ly-san" class="text-[11px] font-semibold text-purple-700 hover:underline">Chi tiết sân →</a>
          </div>
          <div class="divide-y divide-purple-50 row-stagger">
            <c:if test="${empty dashboardData.todayBookingsList}">
              <div class="p-6 text-center text-zinc-400 text-sm">Chưa có lượt đặt sân nào được đăng ký hôm nay.</div>
            </c:if>
            <c:forEach items="${dashboardData.todayBookingsList}" var="lich">
              <div class="flex items-center gap-3 px-5 py-3.5 hover:bg-purple-50/20 transition-colors">
                <div class="w-10 h-10 rounded-full bg-purple-50 text-purple-750 flex items-center justify-center font-bold text-sm shrink-0">
                  ${lich.account != null ? lich.account.username.substring(0,1).toUpperCase() : "K"}
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex items-center gap-2">
                    <p class="text-sm font-semibold text-zinc-800 truncate">
                      ${lich.account != null ? (lich.account.fullName != null && lich.account.fullName.length() > 0 ? lich.account.fullName : lich.account.username) : "Khách vãng lai"}
                    </p>
                    <span class="badge badge-purple">${lich.nguonDatSan}</span>
                  </div>
                  <div class="flex items-center gap-2 text-[11px] text-zinc-500 mt-0.5">
                    <span class="flex items-center gap-0.5 text-purple-700 font-medium">
                      <span class="material-symbols-outlined text-[12px]">stadium</span>
                      ${lich.san != null ? lich.san.tenSan : "Sân thi đấu"}
                    </span>
                    <span>·</span>
                    <span class="flex items-center gap-0.5">
                      <span class="material-symbols-outlined text-[12px]">schedule</span>
                      ${lich.gioBatDau} – ${lich.gioKetThuc}
                    </span>
                  </div>
                </div>
                <div class="text-right shrink-0">
                  <p class="text-sm font-bold text-zinc-900">
                    <fmt:formatNumber value="${lich.tongTienDuKien}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                  </p>
                  <span class="badge <c:choose><c:when test="${lich.trangThai == 'Đã thanh toán' || lich.trangThai == 'Success'}">badge-green</c:when><c:when test="${lich.trangThai == 'Chờ thanh toán' || lich.trangThai == 'Pending'}">badge-amber</c:when><c:otherwise>badge-red</c:otherwise></c:choose> mt-1">
                    ${lich.trangThai}
                  </span>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>

      <div class="flex flex-col gap-5">
        <!-- Recent Invoices -->
        <div class="card overflow-hidden">
          <div class="flex items-center justify-between px-5 py-4 border-b border-purple-50">
            <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">receipt_long</span>Hóa đơn gần đây</h3>
            <span class="badge badge-purple">Mới nhất</span>
          </div>
          <div class="divide-y divide-purple-50 row-stagger">
            <c:if test="${empty dashboardData.recentInvoices}">
              <div class="p-6 text-center text-zinc-400 text-sm">Chưa lập hóa đơn nào gần đây.</div>
            </c:if>
            <c:forEach items="${dashboardData.recentInvoices}" var="hd">
              <div class="p-4 hover:bg-purple-50/20 transition-colors flex items-center justify-between gap-3">
                <div>
                  <p class="text-xs font-bold text-zinc-800">Mã hóa đơn: HD${hd.hoaDonId}</p>
                  <p class="text-[10px] text-zinc-500 mt-0.5"><fmt:formatDate value="${hd.ngayLap}" pattern="dd/MM/yyyy HH:mm"/></p>
                  <p class="text-[10px] text-purple-600 font-semibold mt-1">${hd.khachHang != null ? hd.khachHang.fullName : "Khách vãng lai"}</p>
                </div>
                <div class="text-right">
                  <p class="text-xs font-bold text-zinc-900"><fmt:formatNumber value="${hd.tongThanhToan}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                  <span class="badge <c:choose><c:when test="${hd.trangThaiThanhToan == 'Đã thanh toán'}">badge-green</c:when><c:when test="${hd.trangThaiThanhToan == 'Chờ thanh toán'}">badge-amber</c:when><c:otherwise>badge-red</c:otherwise></c:choose> mt-1">
                    ${hd.trangThaiThanhToan}
                  </span>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>

        <!-- Warnings -->
        <div class="card overflow-hidden">
          <div class="px-5 py-4 border-b border-purple-50">
            <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">warning</span>Cảnh báo & Nhắc việc</h3>
          </div>
          <div class="p-4 flex flex-col gap-3">
            <div class="flex items-start gap-3 p-3 rounded-lg bg-amber-50 border border-amber-200/50">
              <span class="material-symbols-outlined text-[18px] text-amber-600 shrink-0 mt-0.5">date_range</span>
              <div class="flex-1 min-w-0">
                <p class="text-xs font-semibold text-zinc-900">Có yêu cầu nghỉ phép đang chờ duyệt</p>
                <p class="text-[10px] text-zinc-500 mt-0.5">Nhân viên gửi yêu cầu xin nghỉ phép.</p>
                <a href="${pageContext.request.contextPath}/manager/yeu-cau-nghi" class="text-[10px] text-amber-700 font-bold hover:underline mt-1 inline-block">Duyệt yêu cầu →</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>

  <!-- ===== TAB: DOANH THU ===== -->
  <div id="panel-revenue" class="hidden flex flex-col gap-5">

    <!-- Revenue KPI row -->
    <section class="grid grid-cols-2 lg:grid-cols-4 gap-4">
      <div class="card card-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-indigo-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-indigo-700" style="font-variation-settings:'FILL' 1">payments</span></div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-green-600 bg-green-50 px-2 py-0.5 rounded-md">Hôm nay</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu hôm nay</p>
        <p class="text-2xl font-black text-purple-950 tracking-tight"><fmt:formatNumber value="${dashboardData.revenueToday}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
      </div>
      <div class="card card-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-purple-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-purple-700" style="font-variation-settings:'FILL' 1">calendar_month</span></div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-md">Tháng này</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu tháng này</p>
        <p class="text-2xl font-black text-purple-950 tracking-tight"><fmt:formatNumber value="${dashboardData.revenueThisMonth}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
      </div>
      <div class="card card-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-zinc-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-zinc-500" style="font-variation-settings:'FILL' 1">history</span></div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold text-zinc-500 bg-zinc-50 px-2 py-0.5 rounded-md">Tháng trước</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">Doanh thu tháng trước</p>
        <p class="text-2xl font-black text-purple-950 tracking-tight"><fmt:formatNumber value="${dashboardData.revenueLastMonth}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
      </div>
      <div class="card card-hover p-5">
        <div class="flex items-start justify-between mb-3">
          <div class="w-11 h-11 rounded-xl bg-green-50 flex items-center justify-center"><span class="material-symbols-outlined text-[20px] text-green-600" style="font-variation-settings:'FILL' 1">trending_up</span></div>
          <span class="flex items-center gap-0.5 text-[11px] font-bold
            <c:choose><c:when test="${dashboardData.revenueGrowth != null && dashboardData.revenueGrowth >= 0}">text-green-600 bg-green-50</c:when><c:otherwise>text-red-600 bg-red-50</c:otherwise></c:choose>
            px-2 py-0.5 rounded-md">Tăng trưởng</span>
        </div>
        <p class="text-xs text-zinc-500 font-medium mb-1">So tháng trước</p>
        <c:choose>
          <c:when test="${dashboardData.revenueGrowth != null}">
            <p class="text-2xl font-black tracking-tight <c:choose><c:when test="${dashboardData.revenueGrowth >= 0}">text-green-600</c:when><c:otherwise>text-red-500</c:otherwise></c:choose>">
              <c:if test="${dashboardData.revenueGrowth >= 0}">+</c:if>${dashboardData.revenueGrowth}%
            </p>
          </c:when>
          <c:otherwise><p class="text-2xl font-black text-zinc-400">—</p></c:otherwise>
        </c:choose>
      </div>
    </section>

    <section class="grid grid-cols-1 xl:grid-cols-3 gap-5">
      <!-- Monthly Revenue Chart -->
      <div class="xl:col-span-2 card p-5">
        <div class="mb-5">
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">bar_chart</span>Doanh thu 6 tháng gần nhất</h3>
          <p class="text-[11px] text-purple-500 mt-0.5">Tổng doanh thu đã thu theo từng tháng</p>
        </div>
        <c:set var="revenueByMonth" value="${dashboardData.revenueByMonth}" />
        <c:if test="${not empty revenueByMonth}">
          <%-- Find max value for bar scaling --%>
          <c:set var="maxRev" value="0" />
          <c:forEach items="${revenueByMonth}" var="entry">
            <c:if test="${entry.value > maxRev}"><c:set var="maxRev" value="${entry.value}" /></c:if>
          </c:forEach>
          <div class="flex items-end justify-between gap-3 h-44 px-1">
            <c:forEach items="${revenueByMonth}" var="entry">
              <c:set var="pct" value="${maxRev > 0 ? (entry.value / maxRev * 100) : 5}" />
              <div class="flex-1 flex flex-col items-center gap-1.5 group">
                <span class="text-[9px] font-bold text-zinc-400 group-hover:text-purple-700 whitespace-nowrap">
                  <fmt:formatNumber value="${entry.value / 1000000}" maxFractionDigits="1"/>M
                </span>
                <div class="w-full rounded-t-md cursor-pointer transition-all group-hover:opacity-80"
                  style="height:${pct < 5 ? 5 : pct}%; background: linear-gradient(to top, #7c3aed, #818cf8)"></div>
                <span class="text-[9px] font-semibold text-zinc-500">${entry.key}</span>
              </div>
            </c:forEach>
          </div>
        </c:if>
        <c:if test="${empty revenueByMonth}">
          <div class="h-44 flex items-center justify-center text-zinc-400 text-sm">Chưa có dữ liệu doanh thu.</div>
        </c:if>
      </div>

      <!-- Revenue by Court -->
      <div class="card overflow-hidden">
        <div class="px-5 py-4 border-b border-purple-50">
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">stadium</span>Doanh thu theo sân</h3>
          <p class="text-[11px] text-purple-500 mt-0.5">Tháng hiện tại</p>
        </div>
        <div class="divide-y divide-purple-50 row-stagger">
          <c:if test="${empty dashboardData.revenueBySan}">
            <div class="p-6 text-center text-zinc-400 text-sm">Chưa có dữ liệu tháng này.</div>
          </c:if>
          <%-- Find max for progress bars --%>
          <c:set var="maxSanRev" value="0" />
          <c:forEach items="${dashboardData.revenueBySan}" var="row">
            <c:if test="${row[1] > maxSanRev}"><c:set var="maxSanRev" value="${row[1]}" /></c:if>
          </c:forEach>
          <c:forEach items="${dashboardData.revenueBySan}" var="row" varStatus="st">
            <div class="px-5 py-3 hover:bg-purple-50/20 transition-colors">
              <div class="flex items-center justify-between mb-1.5">
                <p class="text-xs font-semibold text-zinc-800 truncate flex-1">${row[0]}</p>
                <p class="text-xs font-bold text-purple-700 shrink-0 ml-2">
                  <fmt:formatNumber value="${row[1]}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </p>
              </div>
              <div class="w-full bg-purple-50 rounded-full h-1.5">
                <div class="h-1.5 rounded-full bg-gradient-to-r from-purple-500 to-indigo-400"
                  style="width: ${maxSanRev > 0 ? (row[1] / maxSanRev * 100) : 0}%"></div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </section>
  </div>

  <!-- ===== TAB: ĐÁNH GIÁ ===== -->
  <div id="panel-reviews" class="hidden flex flex-col gap-5">

    <!-- Review KPI row -->
    <section class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="card card-hover p-5 flex items-center gap-4">
        <div class="w-14 h-14 rounded-2xl bg-amber-50 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[28px] text-amber-500" style="font-variation-settings:'FILL' 1">star</span>
        </div>
        <div>
          <p class="text-xs text-zinc-500 font-medium mb-0.5">Sao trung bình</p>
          <c:choose>
            <c:when test="${dashboardData.avgSoSao != null}">
              <p class="text-3xl font-black text-purple-950">${dashboardData.avgSoSao}<span class="text-base text-zinc-400">/5</span></p>
            </c:when>
            <c:otherwise><p class="text-3xl font-black text-zinc-400">—</p></c:otherwise>
          </c:choose>
        </div>
      </div>
      <div class="card card-hover p-5 flex items-center gap-4">
        <div class="w-14 h-14 rounded-2xl bg-purple-50 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[28px] text-purple-600" style="font-variation-settings:'FILL' 1">rate_review</span>
        </div>
        <div>
          <p class="text-xs text-zinc-500 font-medium mb-0.5">Tổng đánh giá</p>
          <p class="text-3xl font-black text-purple-950">${dashboardData.totalDanhGia}</p>
        </div>
      </div>
      <div class="card card-hover p-5 flex items-center gap-4">
        <div class="w-14 h-14 rounded-2xl bg-red-50 flex items-center justify-center shrink-0">
          <span class="material-symbols-outlined text-[28px] text-red-500" style="font-variation-settings:'FILL' 1">sentiment_dissatisfied</span>
        </div>
        <div>
          <p class="text-xs text-zinc-500 font-medium mb-0.5">Đánh giá tiêu cực</p>
          <c:set var="badCount" value="0" />
          <c:forEach items="${dashboardData.danhGiaList}" var="dg">
            <c:if test="${dg.soSao <= 2}"><c:set var="badCount" value="${badCount + 1}" /></c:if>
          </c:forEach>
          <p class="text-3xl font-black <c:choose><c:when test="${badCount > 0}">text-red-500</c:when><c:otherwise>text-zinc-400</c:otherwise></c:choose>">${badCount}</p>
        </div>
      </div>
    </section>

    <!-- Review List -->
    <div class="card overflow-hidden">
      <div class="px-5 py-4 border-b border-purple-50 flex items-center justify-between">
        <div>
          <h3 class="text-sm font-bold text-purple-950 flex items-center gap-2"><span class="material-symbols-outlined text-[18px] text-purple-700">reviews</span>Đánh giá gần đây</h3>
          <p class="text-[11px] text-purple-500 mt-0.5">20 đánh giá mới nhất từ khách hàng</p>
        </div>
        <div class="flex items-center gap-2">
          <button onclick="filterReviews('all')" id="filter-all" class="review-filter px-3 py-1 text-[11px] font-semibold rounded-md bg-purple-600 text-white">Tất cả</button>
          <button onclick="filterReviews('bad')" id="filter-bad" class="review-filter px-3 py-1 text-[11px] font-semibold rounded-md bg-white text-zinc-600 border border-zinc-200 hover:bg-red-50">1-2 sao</button>
        </div>
      </div>
      <div id="review-list" class="divide-y divide-purple-50 row-stagger">
        <c:if test="${empty dashboardData.danhGiaList}">
          <div class="p-8 text-center text-zinc-400 text-sm">
            <span class="material-symbols-outlined text-[40px] text-zinc-300 block mb-2">rate_review</span>
            Chưa có đánh giá nào từ khách hàng.
          </div>
        </c:if>
        <c:forEach items="${dashboardData.danhGiaList}" var="dg">
          <div class="review-row px-5 py-4 hover:bg-purple-50/20 transition-colors ${dg.soSao <= 2 ? 'bad-review' : ''}" data-stars="${dg.soSao}">
            <div class="flex items-start gap-3">
              <div class="w-9 h-9 rounded-full bg-purple-50 flex items-center justify-center font-bold text-sm text-purple-700 shrink-0">
                ${dg.accountIdNguoiDanhGia}
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between gap-2 flex-wrap">
                  <div class="flex items-center gap-2">
                    <span class="text-xs font-bold text-zinc-800">Khách #${dg.accountIdNguoiDanhGia}</span>
                    <c:if test="${dg.soSao <= 2}">
                      <span class="badge badge-red text-[10px]">Tiêu cực</span>
                    </c:if>
                  </div>
                  <span class="text-[10px] text-zinc-400">
                    <c:if test="${dg.ngayDanhGia != null}">
                      ${fn:substring(dg.ngayDanhGia.toString(), 0, 16)}
                    </c:if>
                  </span>
                </div>
                <!-- Stars -->
                <div class="flex items-center gap-0.5 my-1">
                  <c:forEach begin="1" end="5" var="s">
                    <span class="material-symbols-outlined text-[14px] ${s <= dg.soSao ? 'text-amber-400' : 'text-zinc-200'}"
                      style="font-variation-settings:'FILL' 1">star</span>
                  </c:forEach>
                  <span class="text-[10px] text-zinc-500 ml-1">${dg.soSao}/5</span>
                </div>
                <c:if test="${not empty dg.binhLuan}">
                  <p class="text-xs text-zinc-600 leading-relaxed">${dg.binhLuan}</p>
                </c:if>
                <c:if test="${empty dg.binhLuan}">
                  <p class="text-xs text-zinc-400 italic">Không có bình luận.</p>
                </c:if>
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>
  </div>

</main>

<style>
  .active-tab { background: white; color: #4c1d95; box-shadow: 0 1px 3px rgba(0,0,0,.08); }
  .tab-btn:not(.active-tab) { color: #7c3aed; }
  .tab-btn:not(.active-tab):hover { background: white/60; }
</style>

<script>
  document.getElementById('mobileMenuBtn')?.addEventListener('click', () => {
    document.getElementById('sidebar').classList.toggle('-translate-x-full');
  });

  function switchTab(name) {
    ['overview','revenue','reviews'].forEach(t => {
      document.getElementById('panel-' + t).classList.toggle('hidden', t !== name);
      const btn = document.getElementById('tab-' + t);
      btn.classList.toggle('active-tab', t === name);
    });
  }

  function filterReviews(type) {
    document.querySelectorAll('.review-row').forEach(row => {
      row.classList.toggle('hidden', type === 'bad' && row.dataset.stars > 2);
    });
    document.getElementById('filter-all').className = 'review-filter px-3 py-1 text-[11px] font-semibold rounded-md ' +
      (type === 'all' ? 'bg-purple-600 text-white' : 'bg-white text-zinc-600 border border-zinc-200 hover:bg-red-50');
    document.getElementById('filter-bad').className = 'review-filter px-3 py-1 text-[11px] font-semibold rounded-md ' +
      (type === 'bad' ? 'bg-red-500 text-white' : 'bg-white text-zinc-600 border border-zinc-200 hover:bg-red-50');
  }
</script>
</body>
</html>
