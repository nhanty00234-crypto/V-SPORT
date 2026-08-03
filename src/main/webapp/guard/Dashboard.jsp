<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <title>GUARD Dashboard | V-SPORT</title>
  <jsp:include page="/guard/common/guard_head.jsp"/>
</head>
<body>

<jsp:include page="/guard/common/sidebar.jsp"/>
<jsp:include page="/guard/common/header.jsp">
  <jsp:param name="pageTitle" value="Tổng quan"/>
  <jsp:param name="pageSubtitle" value="Cơ sở CS${sessionScope.user.coSoId} — Hôm nay"/>
</jsp:include>

<main class="lg:ml-[248px] mt-[60px] p-4 lg:p-6 flex flex-col gap-5">

  <!-- Hero Banner -->
  <section class="gd-hero rounded-2xl border border-rose-200 overflow-hidden relative">
    <div class="absolute -top-10 -right-10 w-56 h-56 bg-rose-400/10 rounded-full blur-3xl pointer-events-none"></div>
    <div class="relative p-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
      <div class="flex items-center gap-4">
        <div class="w-14 h-14 rounded-2xl bg-gradient-to-br from-rose-500 to-red-700 flex items-center justify-center shadow-lg">
          <span class="material-symbols-outlined text-[28px] text-white" style="font-variation-settings:'FILL' 1">shield_person</span>
        </div>
        <div>
          <p class="text-[10px] font-bold uppercase tracking-widest text-rose-600 mb-0.5">GUARD PORTAL</p>
          <h2 class="text-xl font-black text-rose-950">Chào, ${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}!</h2>
          <div class="flex items-center gap-2 mt-1 text-xs text-rose-600 flex-wrap">
            <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px]">storefront</span>Cơ sở CS${sessionScope.user.coSoId}</span>
            <span class="text-rose-200">·</span>
            <span class="flex items-center gap-1 font-semibold"><span class="w-1.5 h-1.5 rounded-full bg-rose-500 inline-block live-dot"></span>Đang trực</span>
          </div>
        </div>
      </div>
      <div class="flex gap-3 flex-wrap">
        <a href="${pageContext.request.contextPath}/guard/bao-cao-su-co"
           class="inline-flex items-center gap-2 bg-rose-600 hover:bg-rose-700 text-white font-bold text-sm px-5 py-2.5 rounded-xl shadow transition">
          <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">report</span>Báo sự cố
        </a>
        <a href="${pageContext.request.contextPath}/guard/diem-danh"
           class="inline-flex items-center gap-2 bg-white border-2 border-rose-200 text-rose-700 hover:border-rose-400 font-bold text-sm px-5 py-2.5 rounded-xl transition">
          <span class="material-symbols-outlined text-[18px]" style="font-variation-settings:'FILL' 1">badge</span>Điểm danh
        </a>
      </div>
    </div>
  </section>

  <!-- KPI Row -->
  <section class="grid grid-cols-1 sm:grid-cols-3 gap-4 stagger">

    <!-- Ca hôm nay -->
    <div class="gd-card p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-rose-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-rose-600" style="font-variation-settings:'FILL' 1">work_history</span>
        </div>
        <c:choose>
          <c:when test="${caHomNay == null}"><span class="badge badge-gray">Không có ca</span></c:when>
          <c:when test="${caHomNay.trangThai == 'CheckedIn'}"><span class="badge badge-green">Đang trực</span></c:when>
          <c:when test="${caHomNay.trangThai == 'CheckedOut'}"><span class="badge badge-blue">Đã xong</span></c:when>
          <c:otherwise><span class="badge badge-amber">Chưa vào ca</span></c:otherwise>
        </c:choose>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Ca làm hôm nay</p>
      <c:choose>
        <c:when test="${caHomNay != null}">
          <p class="text-xl font-black text-rose-950">${caHomNay.tenCa != null ? caHomNay.tenCa : 'Ca làm việc'}</p>
          <p class="text-xs text-zinc-500 mt-1">${caHomNay.gioBatDau} – ${caHomNay.gioKetThuc}</p>
        </c:when>
        <c:otherwise>
          <p class="text-xl font-black text-zinc-400">—</p>
          <p class="text-xs text-zinc-400 mt-1">Chưa được phân ca</p>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- Điểm danh -->
    <div class="gd-card p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-rose-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-rose-600" style="font-variation-settings:'FILL' 1">how_to_reg</span>
        </div>
        <c:choose>
          <c:when test="${caHomNay != null && caHomNay.gioVaoThuc != null && caHomNay.gioRaThuc == null}">
            <span class="badge badge-green">Đã vào ca</span>
          </c:when>
          <c:when test="${caHomNay != null && caHomNay.gioRaThuc != null}">
            <span class="badge badge-blue">Hoàn thành</span>
          </c:when>
          <c:otherwise><span class="badge badge-gray">Chưa điểm danh</span></c:otherwise>
        </c:choose>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Điểm danh hôm nay</p>
      <c:choose>
        <c:when test="${caHomNay != null && caHomNay.gioVaoThuc != null}">
          <p class="text-xl font-black text-rose-950">${caHomNay.gioVaoThuc}</p>
          <p class="text-xs text-zinc-500 mt-1">Vào ca lúc ${caHomNay.gioVaoThuc}</p>
        </c:when>
        <c:otherwise>
          <p class="text-xl font-black text-zinc-400">—</p>
          <p class="text-xs text-zinc-400 mt-1">Chưa bấm vào ca</p>
        </c:otherwise>
      </c:choose>
    </div>

    <!-- Sự cố hôm nay -->
    <div class="gd-card p-5">
      <div class="flex items-start justify-between mb-3">
        <div class="w-11 h-11 rounded-xl bg-rose-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-rose-600" style="font-variation-settings:'FILL' 1">warning</span>
        </div>
        <c:choose>
          <c:when test="${suCoHomNay > 0}"><span class="badge badge-red">${suCoHomNay} sự cố</span></c:when>
          <c:otherwise><span class="badge badge-green">Bình thường</span></c:otherwise>
        </c:choose>
      </div>
      <p class="text-xs text-zinc-500 font-medium mb-1">Sự cố hôm nay</p>
      <p class="text-3xl font-black text-rose-950">${suCoHomNay}</p>
      <p class="text-xs text-zinc-500 mt-1">Báo cáo của bạn</p>
    </div>
  </section>

  <!-- Quick Actions -->
  <section>
    <h3 class="text-sm font-bold text-rose-900 mb-3">Thao tác nhanh</h3>
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
      <a href="${pageContext.request.contextPath}/guard/diem-danh"
         class="gd-card p-5 flex items-center gap-4 hover:border-rose-400 cursor-pointer group">
        <div class="w-12 h-12 rounded-xl bg-rose-100 flex items-center justify-center group-hover:bg-rose-200 transition">
          <span class="material-symbols-outlined text-[24px] text-rose-700" style="font-variation-settings:'FILL' 1">badge</span>
        </div>
        <div>
          <p class="font-bold text-rose-900">Điểm danh ca làm việc</p>
          <p class="text-xs text-zinc-500 mt-0.5">Vào ca / Kết thúc ca — xem lịch sử 7 ngày</p>
        </div>
        <span class="material-symbols-outlined text-rose-300 ml-auto">chevron_right</span>
      </a>

      <a href="${pageContext.request.contextPath}/guard/bao-cao-su-co"
         class="gd-card p-5 flex items-center gap-4 hover:border-rose-400 cursor-pointer group">
        <div class="w-12 h-12 rounded-xl bg-rose-100 flex items-center justify-center group-hover:bg-rose-200 transition">
          <span class="material-symbols-outlined text-[24px] text-rose-700" style="font-variation-settings:'FILL' 1">report</span>
        </div>
        <div>
          <p class="font-bold text-rose-900">Báo cáo sự cố</p>
          <p class="text-xs text-zinc-500 mt-0.5">Phân loại, mức độ, mô tả, đính kèm ảnh</p>
        </div>
        <span class="material-symbols-outlined text-rose-300 ml-auto">chevron_right</span>
      </a>

      <a href="${pageContext.request.contextPath}/guard/lich-su-su-co"
         class="gd-card p-5 flex items-center gap-4 hover:border-rose-400 cursor-pointer group">
        <div class="w-12 h-12 rounded-xl bg-rose-100 flex items-center justify-center group-hover:bg-rose-200 transition">
          <span class="material-symbols-outlined text-[24px] text-rose-700" style="font-variation-settings:'FILL' 1">history</span>
        </div>
        <div>
          <p class="font-bold text-rose-900">Lịch sử sự cố</p>
          <p class="text-xs text-zinc-500 mt-0.5">Xem trạng thái xử lý từ manager</p>
        </div>
        <span class="material-symbols-outlined text-rose-300 ml-auto">chevron_right</span>
      </a>

      <div class="gd-card p-5 flex items-center gap-4 opacity-60 cursor-not-allowed">
        <div class="w-12 h-12 rounded-xl bg-zinc-100 flex items-center justify-center">
          <span class="material-symbols-outlined text-[24px] text-zinc-400" style="font-variation-settings:'FILL' 1">qr_code_scanner</span>
        </div>
        <div>
          <p class="font-bold text-zinc-500">Quét QR cơ sở</p>
          <p class="text-xs text-zinc-400 mt-0.5">Sắp ra mắt</p>
        </div>
        <span class="badge badge-gray ml-auto text-[10px]">Soon</span>
      </div>
    </div>
  </section>

</main>
</body>
</html>
