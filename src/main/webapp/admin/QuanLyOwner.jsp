<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Quản lý Owner – V-SPORT Admin</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200"/>
  <style>body{font-family:'Inter',sans-serif}</style>
</head>
<body class="min-h-screen text-slate-900">

<jsp:include page="common/sidebar.jsp"/>

<!-- ── TOP BAR ── -->
<header class="fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-md border-b border-slate-200/80 z-10 flex items-center px-4 lg:px-8 xl:px-10 gap-3"
        style="height:60px">
  <button data-sidebar-toggle class="lg:hidden p-2 rounded-xl hover:bg-slate-100 text-slate-500 transition-colors">
    <span class="material-symbols-outlined text-[20px]">menu</span>
  </button>
  <span class="material-symbols-outlined text-blue-500 text-[18px]" style="font-variation-settings:'FILL' 1">manage_accounts</span>
  <div>
    <h1 class="text-sm font-bold text-slate-900 leading-tight">Quản lý Owner / Đối tác</h1>
    <p class="text-[11px] text-slate-400 leading-tight">Admin · V-Sport</p>
  </div>
</header>

<!-- ── MAIN ── -->
<main class="lg:ml-[260px] pt-[60px] px-4 lg:px-8 xl:px-10 pb-10 min-h-screen">

  <!-- Flash messages -->
  <c:if test="${not empty sessionScope.message}">
    <div class="reveal mt-4 flex items-center gap-3 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-2xl px-4 py-3.5 text-sm">
      <span class="material-symbols-outlined text-emerald-500 text-[20px]" style="font-variation-settings:'FILL' 1">check_circle</span>
      <span><c:out value="${sessionScope.message}"/></span>
    </div>
    <c:remove var="message" scope="session"/>
  </c:if>
  <c:if test="${not empty sessionScope.error}">
    <div class="reveal mt-4 flex items-center gap-3 bg-red-50 border border-red-200 text-red-800 rounded-2xl px-4 py-3.5 text-sm">
      <span class="material-symbols-outlined text-red-500 text-[20px]" style="font-variation-settings:'FILL' 1">error</span>
      <span><c:out value="${sessionScope.error}"/></span>
    </div>
    <c:remove var="error" scope="session"/>
  </c:if>

  <!-- Page header -->
  <div class="reveal mt-5 mb-5">
    <h2 class="text-xl font-black text-slate-900">Đơn đăng ký đối tác</h2>
    <p class="text-sm text-slate-500 mt-1">Duyệt hoặc từ chối các cơ sở đăng ký qua kênh owner. Quản lý trạng thái tài khoản.</p>
  </div>

  <!-- Count cards -->
  <div class="reveal grid grid-cols-3 gap-3 mb-6">
    <div class="adm-card p-4 flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-amber-50 flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-amber-500 text-[20px]" style="font-variation-settings:'FILL' 1">schedule</span>
      </div>
      <div>
        <p class="text-2xl font-black text-slate-900">${pending.size()}</p>
        <p class="text-[11px] text-slate-500 font-medium">Chờ duyệt</p>
      </div>
    </div>
    <div class="adm-card p-4 flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-emerald-50 flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-emerald-500 text-[20px]" style="font-variation-settings:'FILL' 1">check_circle</span>
      </div>
      <div>
        <p class="text-2xl font-black text-slate-900">${approved.size()}</p>
        <p class="text-[11px] text-slate-500 font-medium">Đang hoạt động</p>
      </div>
    </div>
    <div class="adm-card p-4 flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-red-50 flex items-center justify-center shrink-0">
        <span class="material-symbols-outlined text-red-400 text-[20px]" style="font-variation-settings:'FILL' 1">cancel</span>
      </div>
      <div>
        <p class="text-2xl font-black text-slate-900">${rejected.size()}</p>
        <p class="text-[11px] text-slate-500 font-medium">Từ chối</p>
      </div>
    </div>
  </div>

  <!-- Tab bar -->
  <div class="reveal flex items-center gap-2 mb-5">
    <button class="tab-pill active" id="tabPending"   onclick="switchTab('pending', this)">
      <span class="material-symbols-outlined text-[15px]">schedule</span>
      Chờ duyệt
      <c:if test="${pending.size() > 0}">
        <span class="ml-0.5 bg-amber-100 text-amber-700 rounded-full px-2 py-0 text-[11px] font-bold">${pending.size()}</span>
      </c:if>
    </button>
    <button class="tab-pill" id="tabApproved" onclick="switchTab('approved', this)">
      <span class="material-symbols-outlined text-[15px]">check_circle</span>
      Đang hoạt động
      <c:if test="${approved.size() > 0}">
        <span class="ml-0.5 bg-emerald-100 text-emerald-700 rounded-full px-2 py-0 text-[11px] font-bold">${approved.size()}</span>
      </c:if>
    </button>
    <button class="tab-pill" id="tabRejected" onclick="switchTab('rejected', this)">
      <span class="material-symbols-outlined text-[15px]">cancel</span>
      Từ chối
      <c:if test="${rejected.size() > 0}">
        <span class="ml-0.5 bg-red-100 text-red-600 rounded-full px-2 py-0 text-[11px] font-bold">${rejected.size()}</span>
      </c:if>
    </button>
  </div>

  <!-- ══ TAB: Chờ duyệt ══ -->
  <div id="tab-pending">
    <c:choose>
      <c:when test="${empty pending}">
        <div class="reveal adm-card p-14 text-center">
          <span class="material-symbols-outlined text-slate-200 text-[56px]">inbox</span>
          <p class="text-slate-400 mt-3 font-medium text-sm">Không có đơn đăng ký nào đang chờ duyệt</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="flex flex-col gap-3">
          <c:forEach var="row" items="${pending}" varStatus="st">
            <c:set var="cs"  value="${row.coSo}"/>
            <c:set var="mgr" value="${row.manager}"/>
            <div class="reveal d${st.index > 5 ? 5 : st.index} adm-card border-l-4 border-l-amber-400 p-5
                        hover:shadow-md transition-shadow duration-200">
              <div class="flex flex-col md:flex-row md:items-start gap-4">

                <!-- Icon -->
                <div class="w-11 h-11 rounded-2xl bg-amber-50 border border-amber-100
                            flex items-center justify-center shrink-0">
                  <span class="material-symbols-outlined text-amber-500 text-[22px]" style="font-variation-settings:'FILL' 1">store</span>
                </div>

                <!-- Info -->
                <div class="flex-1 min-w-0">
                  <div class="flex flex-wrap items-center gap-2 mb-2">
                    <span class="font-bold text-slate-900 text-[15px]"><c:out value="${cs.tenCoSo}"/></span>
                    <span class="badge badge-amber">Chờ duyệt</span>
                  </div>
                  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-6 gap-y-1.5 text-[13px] text-slate-500">
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">person</span>
                      <c:out value="${mgr.fullName}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">mail</span>
                      <c:out value="${mgr.email}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">call</span>
                      <c:out value="${cs.soDienThoai}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">location_on</span>
                      <c:out value="${cs.diaChi}"/>
                    </span>
                    <c:if test="${not empty cs.loaiHinhKinhDoanh}">
                      <span class="flex items-center gap-1.5 truncate">
                        <span class="material-symbols-outlined text-[14px] text-slate-400">sports</span>
                        <c:out value="${cs.loaiHinhKinhDoanh}"/>
                      </span>
                    </c:if>
                    <c:if test="${cs.soLuongSanDuKien > 0}">
                      <span class="flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[14px] text-slate-400">grid_view</span>
                        Dự kiến <strong class="text-slate-700 ml-0.5">${cs.soLuongSanDuKien} sân</strong>
                      </span>
                    </c:if>
                  </div>
                </div>

                <!-- Actions -->
                <div class="flex items-center gap-2 shrink-0 flex-wrap">
                  <a href="?action=duyet&id=${cs.coSoID}"
                     onclick="return confirm('Duyệt cơ sở \'${cs.tenCoSo}\' và kích hoạt tài khoản quản lý?')"
                     class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-emerald-600 text-white
                            text-sm font-semibold hover:bg-emerald-700 active:scale-95 transition-all shadow-sm shadow-emerald-200">
                    <span class="material-symbols-outlined text-[16px]">check_circle</span>Duyệt
                  </a>
                  <a href="?action=tu-choi&id=${cs.coSoID}"
                     onclick="return confirm('Từ chối đăng ký cơ sở \'${cs.tenCoSo}\'?')"
                     class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-white border border-slate-200
                            text-slate-600 text-sm font-semibold hover:bg-red-50 hover:border-red-200 hover:text-red-600
                            active:scale-95 transition-all">
                    <span class="material-symbols-outlined text-[16px]">cancel</span>Từ chối
                  </a>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- ══ TAB: Đang hoạt động ══ -->
  <div id="tab-approved" class="hidden">
    <c:choose>
      <c:when test="${empty approved}">
        <div class="reveal adm-card p-14 text-center">
          <span class="material-symbols-outlined text-slate-200 text-[56px]">domain_disabled</span>
          <p class="text-slate-400 mt-3 font-medium text-sm">Chưa có cơ sở đối tác nào đang hoạt động</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="flex flex-col gap-3">
          <c:forEach var="row" items="${approved}" varStatus="st">
            <c:set var="cs"  value="${row.coSo}"/>
            <c:set var="mgr" value="${row.manager}"/>
            <div class="reveal d${st.index > 5 ? 5 : st.index} adm-card border-l-4 border-l-emerald-400 p-5
                        hover:shadow-md transition-shadow duration-200">
              <div class="flex flex-col md:flex-row md:items-start gap-4">
                <div class="w-11 h-11 rounded-2xl bg-emerald-50 border border-emerald-100
                            flex items-center justify-center shrink-0">
                  <span class="material-symbols-outlined text-emerald-500 text-[22px]" style="font-variation-settings:'FILL' 1">store</span>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex flex-wrap items-center gap-2 mb-2">
                    <span class="font-bold text-slate-900 text-[15px]"><c:out value="${cs.tenCoSo}"/></span>
                    <span class="badge badge-green">Đang hoạt động</span>
                    <c:if test="${mgr.isLocked}">
                      <span class="badge badge-red">Tài khoản bị khóa</span>
                    </c:if>
                  </div>
                  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-6 gap-y-1.5 text-[13px] text-slate-500">
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">person</span>
                      <c:out value="${mgr.fullName}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">mail</span>
                      <c:out value="${mgr.email}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">call</span>
                      <c:out value="${cs.soDienThoai}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">location_on</span>
                      <c:out value="${cs.diaChi}"/>
                    </span>
                    <c:if test="${not empty cs.loaiHinhKinhDoanh}">
                      <span class="flex items-center gap-1.5 truncate">
                        <span class="material-symbols-outlined text-[14px] text-slate-400">sports</span>
                        <c:out value="${cs.loaiHinhKinhDoanh}"/>
                      </span>
                    </c:if>
                    <c:if test="${cs.soLuongSanDuKien > 0}">
                      <span class="flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[14px] text-slate-400">grid_view</span>
                        <strong class="text-slate-700">${cs.soLuongSanDuKien} sân</strong>
                      </span>
                    </c:if>
                  </div>
                </div>
                <div class="shrink-0">
                  <c:choose>
                    <c:when test="${mgr.isLocked}">
                      <a href="?action=mo-khoa&id=${cs.coSoID}"
                         onclick="return confirm('Mở khóa tài khoản owner \'${mgr.fullName}\'?')"
                         class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-blue-600 text-white
                                text-sm font-semibold hover:bg-blue-700 active:scale-95 transition-all shadow-sm shadow-blue-200">
                        <span class="material-symbols-outlined text-[16px]">lock_open</span>Mở khóa
                      </a>
                    </c:when>
                    <c:otherwise>
                      <a href="?action=khoa&id=${cs.coSoID}"
                         onclick="return confirm('Khóa tài khoản owner \'${mgr.fullName}\'? Owner sẽ không thể đăng nhập.')"
                         class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-white border border-slate-200
                                text-slate-600 text-sm font-semibold hover:bg-amber-50 hover:border-amber-200 hover:text-amber-700
                                active:scale-95 transition-all">
                        <span class="material-symbols-outlined text-[16px]">lock</span>Khóa tài khoản
                      </a>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- ══ TAB: Từ chối ══ -->
  <div id="tab-rejected" class="hidden">
    <c:choose>
      <c:when test="${empty rejected}">
        <div class="reveal adm-card p-14 text-center">
          <span class="material-symbols-outlined text-slate-200 text-[56px]">do_not_disturb_on</span>
          <p class="text-slate-400 mt-3 font-medium text-sm">Không có đơn đăng ký nào bị từ chối</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="flex flex-col gap-3">
          <c:forEach var="row" items="${rejected}" varStatus="st">
            <c:set var="cs"  value="${row.coSo}"/>
            <c:set var="mgr" value="${row.manager}"/>
            <div class="reveal d${st.index > 5 ? 5 : st.index} adm-card border-l-4 border-l-red-400 p-5
                        hover:shadow-md transition-shadow duration-200">
              <div class="flex flex-col md:flex-row md:items-start gap-4">
                <div class="w-11 h-11 rounded-2xl bg-red-50 border border-red-100
                            flex items-center justify-center shrink-0">
                  <span class="material-symbols-outlined text-red-400 text-[22px]" style="font-variation-settings:'FILL' 1">store</span>
                </div>
                <div class="flex-1 min-w-0">
                  <div class="flex flex-wrap items-center gap-2 mb-2">
                    <span class="font-bold text-slate-900 text-[15px]"><c:out value="${cs.tenCoSo}"/></span>
                    <span class="badge badge-red">Từ chối</span>
                  </div>
                  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-6 gap-y-1.5 text-[13px] text-slate-500">
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">person</span>
                      <c:out value="${mgr.fullName}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">mail</span>
                      <c:out value="${mgr.email}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">call</span>
                      <c:out value="${cs.soDienThoai}"/>
                    </span>
                    <span class="flex items-center gap-1.5 truncate">
                      <span class="material-symbols-outlined text-[14px] text-slate-400">location_on</span>
                      <c:out value="${cs.diaChi}"/>
                    </span>
                    <c:if test="${not empty cs.loaiHinhKinhDoanh}">
                      <span class="flex items-center gap-1.5 truncate">
                        <span class="material-symbols-outlined text-[14px] text-slate-400">sports</span>
                        <c:out value="${cs.loaiHinhKinhDoanh}"/>
                      </span>
                    </c:if>
                  </div>
                </div>
                <div class="shrink-0">
                  <a href="?action=duyet&id=${cs.coSoID}"
                     onclick="return confirm('Duyệt lại cơ sở \'${cs.tenCoSo}\' và kích hoạt tài khoản?')"
                     class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-emerald-600 text-white
                            text-sm font-semibold hover:bg-emerald-700 active:scale-95 transition-all shadow-sm shadow-emerald-200">
                    <span class="material-symbols-outlined text-[16px]">refresh</span>Duyệt lại
                  </a>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

</main>

<script>
function switchTab(name, btn) {
  ['pending','approved','rejected'].forEach(function(t) {
    document.getElementById('tab-' + t).classList.add('hidden');
  });
  document.getElementById('tab-' + name).classList.remove('hidden');
  document.querySelectorAll('.tab-pill').forEach(function(b) { b.classList.remove('active'); });
  btn.classList.add('active');
  // re-trigger reveal for newly shown cards
  var newEls = document.querySelectorAll('#tab-' + name + ' .reveal:not(.visible)');
  newEls.forEach(function(el, i) {
    setTimeout(function() { el.classList.add('visible'); }, i * 60);
  });
}
</script>
</body>
</html>
