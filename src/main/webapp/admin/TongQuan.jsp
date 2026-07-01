<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Tổng quan — V-SPORT Admin</title>
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200">
<style>
body{font-family:'Inter',sans-serif}
</style>
</head>
<body class="min-h-screen text-slate-900">

<jsp:include page="/admin/common/sidebar.jsp"/>

<!-- ── TOP BAR ── -->
<header class="fixed top-0 right-0 left-0 lg:left-[260px] bg-white/80 backdrop-blur-md border-b border-slate-200/80 z-10 flex items-center justify-between px-4 lg:px-8 xl:px-10" style="height:60px">
  <div class="flex items-center gap-3">
    <button data-sidebar-toggle class="lg:hidden p-2 rounded-xl hover:bg-slate-100 text-slate-500 transition-colors">
      <span class="material-symbols-outlined text-[20px]">menu</span>
    </button>
    <div class="flex items-center gap-2">
      <span class="material-symbols-outlined text-blue-500 text-[18px]" style="font-variation-settings:'FILL' 1">space_dashboard</span>
      <div>
        <h1 class="text-sm font-bold text-slate-900 leading-tight">Tổng quan hệ thống</h1>
        <p class="text-[11px] text-slate-400 leading-tight">Admin · V-Sport</p>
      </div>
    </div>
  </div>
  <div class="flex items-center gap-2">
    <div class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 bg-emerald-50 border border-emerald-100 rounded-xl">
      <span class="w-2 h-2 rounded-full bg-emerald-500 live-dot shrink-0"></span>
      <span class="text-xs font-semibold text-emerald-700">Hệ thống hoạt động</span>
    </div>
    <div class="w-px h-6 bg-slate-200 mx-1"></div>
    <jsp:include page="/admin/common/profile_dropdown.jsp"/>
  </div>
</header>

<!-- ── MAIN ── -->
<main class="lg:ml-[260px] pt-[60px] px-4 lg:px-8 xl:px-10 pb-10 flex flex-col gap-5 min-h-screen">

  <!-- HERO BANNER -->
  <section class="reveal mt-5 rounded-2xl overflow-hidden relative"
           style="background:linear-gradient(135deg,#1e3a8a 0%,#2563eb 60%,#3b82f6 100%)">
    <!-- decorative pattern -->
    <div class="absolute inset-0 opacity-[.07]"
         style="background-image:radial-gradient(circle,#fff 1px,transparent 1px);background-size:28px 28px"></div>
    <div class="absolute top-0 right-0 w-72 h-full opacity-10"
         style="background:radial-gradient(ellipse at right,#fff 0%,transparent 70%)"></div>

    <div class="relative px-6 py-6 sm:py-7 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-5">
      <div class="flex items-center gap-4">
        <div class="w-14 h-14 rounded-2xl bg-white/20 backdrop-blur-sm flex items-center justify-center
                    text-white text-2xl font-black shadow-xl border border-white/20">
          <c:choose>
            <c:when test="${sessionScope.user.fullName != null && sessionScope.user.fullName.length() > 0}">
              ${sessionScope.user.fullName.substring(0,1).toUpperCase()}
            </c:when>
            <c:otherwise>
              ${sessionScope.user.username.substring(0,1).toUpperCase()}
            </c:otherwise>
          </c:choose>
        </div>
        <div>
          <p class="text-blue-200 text-[11px] font-semibold uppercase tracking-widest mb-1">Quản trị viên hệ thống</p>
          <h2 class="text-white text-xl sm:text-2xl font-black leading-tight">
            Xin chào,&nbsp;<c:out value="${sessionScope.user.fullName != null && sessionScope.user.fullName.length() > 0 ? sessionScope.user.fullName : sessionScope.user.username}"/>!
          </h2>
          <p class="text-blue-200/80 text-xs mt-1">Bạn đang quản lý toàn bộ hệ thống V-Sport.</p>
        </div>
      </div>
      <div class="flex flex-wrap gap-2">
        <a href="${pageContext.request.contextPath}/admin/chi-nhanh"
           class="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/15 hover:bg-white/25 border border-white/20
                  text-white text-sm font-semibold transition-all backdrop-blur-sm">
          <span class="material-symbols-outlined text-[16px]">add_business</span>Thêm cơ sở
        </a>
        <a href="${pageContext.request.contextPath}/admin/nhan-su"
           class="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white text-blue-700 text-sm font-bold
                  hover:bg-blue-50 transition-all shadow-lg shadow-blue-900/20">
          <span class="material-symbols-outlined text-[16px]">person_add</span>Thêm nhân sự
        </a>
      </div>
    </div>
  </section>

  <!-- KPI GRID -->
  <section class="grid grid-cols-2 xl:grid-cols-4 gap-3 sm:gap-4">

    <div class="reveal d0 adm-card adm-card-hover p-4 sm:p-5">
      <div class="flex items-start justify-between mb-4">
        <div class="w-11 h-11 rounded-2xl bg-blue-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-blue-600" style="font-variation-settings:'FILL' 1">location_city</span>
        </div>
        <span class="badge badge-green">${activeBranches} HĐ</span>
      </div>
      <p class="text-xs text-slate-500 font-medium">Tổng cơ sở</p>
      <p class="text-3xl font-black text-slate-900 mt-0.5 num-anim">${totalBranches}</p>
      <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between">
        <p class="text-[11px] text-slate-400">${totalBranches - activeBranches} không hoạt động</p>
        <a href="${pageContext.request.contextPath}/admin/chi-nhanh"
           class="text-[11px] font-semibold text-blue-600 hover:underline flex items-center gap-0.5">
          Xem <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
        </a>
      </div>
    </div>

    <div class="reveal d1 adm-card adm-card-hover p-4 sm:p-5">
      <div class="flex items-start justify-between mb-4">
        <div class="w-11 h-11 rounded-2xl bg-violet-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-violet-600" style="font-variation-settings:'FILL' 1">manage_accounts</span>
        </div>
        <span class="badge badge-purple">${totalOwners} owner</span>
      </div>
      <p class="text-xs text-slate-500 font-medium">Tổng tài khoản</p>
      <p class="text-3xl font-black text-slate-900 mt-0.5 num-anim">${totalAccounts}</p>
      <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between">
        <p class="text-[11px] text-slate-400">${totalManagers} quản lý</p>
        <a href="${pageContext.request.contextPath}/admin/nhan-su"
           class="text-[11px] font-semibold text-blue-600 hover:underline flex items-center gap-0.5">
          Xem <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
        </a>
      </div>
    </div>

    <div class="reveal d2 adm-card adm-card-hover p-4 sm:p-5">
      <div class="flex items-start justify-between mb-4">
        <div class="w-11 h-11 rounded-2xl bg-amber-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-amber-600" style="font-variation-settings:'FILL' 1">badge</span>
        </div>
        <span class="badge badge-amber">Nhân viên</span>
      </div>
      <p class="text-xs text-slate-500 font-medium">Lễ tân / Bảo vệ</p>
      <p class="text-3xl font-black text-slate-900 mt-0.5 num-anim">${totalStaff}</p>
      <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between">
        <p class="text-[11px] text-slate-400">Trên toàn hệ thống</p>
        <a href="${pageContext.request.contextPath}/admin/nhan-su"
           class="text-[11px] font-semibold text-blue-600 hover:underline flex items-center gap-0.5">
          Xem <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
        </a>
      </div>
    </div>

    <div class="reveal d3 adm-card adm-card-hover p-4 sm:p-5">
      <div class="flex items-start justify-between mb-4">
        <div class="w-11 h-11 rounded-2xl bg-emerald-50 flex items-center justify-center">
          <span class="material-symbols-outlined text-[22px] text-emerald-600" style="font-variation-settings:'FILL' 1">groups</span>
        </div>
        <span class="badge badge-green">Khách hàng</span>
      </div>
      <p class="text-xs text-slate-500 font-medium">Người dùng đã đăng ký</p>
      <p class="text-3xl font-black text-slate-900 mt-0.5 num-anim">${totalCustomers}</p>
      <div class="mt-3 pt-3 border-t border-slate-100 flex items-center justify-between">
        <p class="text-[11px] text-slate-400">Toàn hệ thống</p>
        <a href="${pageContext.request.contextPath}/admin/nhan-su"
           class="text-[11px] font-semibold text-blue-600 hover:underline flex items-center gap-0.5">
          Xem <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
        </a>
      </div>
    </div>
  </section>

  <!-- MAIN GRID -->
  <section class="grid grid-cols-1 xl:grid-cols-5 gap-4 sm:gap-5">

    <!-- Danh sách cơ sở -->
    <div class="reveal reveal-left xl:col-span-3 adm-card">
      <div class="flex items-center justify-between px-5 py-4 border-b border-slate-100">
        <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
          <span class="material-symbols-outlined text-[17px] text-blue-600" style="font-variation-settings:'FILL' 1">location_on</span>
          Danh sách cơ sở
        </h3>
        <a href="${pageContext.request.contextPath}/admin/chi-nhanh"
           class="text-[11px] font-semibold text-blue-600 hover:underline flex items-center gap-0.5">
          Xem tất cả <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
        </a>
      </div>
      <c:if test="${empty allBranches}">
        <div class="p-10 text-center text-slate-400 text-sm">Chưa có cơ sở nào.</div>
      </c:if>
      <div class="divide-y divide-slate-50">
        <c:forEach items="${allBranches}" var="cs" end="6">
          <div class="flex items-center gap-3 px-5 py-3.5 hover:bg-slate-50/60 transition-colors">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center
                        shrink-0 text-white font-black text-sm shadow-md shadow-blue-200">
              ${cs.tenCoSo.substring(0,1).toUpperCase()}
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm font-semibold text-slate-900 truncate">${cs.tenCoSo}</p>
              <p class="text-[11px] text-slate-400 truncate mt-0.5">${cs.diaChi}</p>
            </div>
            <c:choose>
              <c:when test="${cs.trangThai == 'Đang hoạt động'}">
                <span class="shrink-0 badge badge-green">Hoạt động</span>
              </c:when>
              <c:when test="${cs.trangThai == 'Chờ duyệt'}">
                <span class="shrink-0 badge badge-amber">Chờ duyệt</span>
              </c:when>
              <c:otherwise>
                <span class="shrink-0 badge badge-zinc">${cs.trangThai}</span>
              </c:otherwise>
            </c:choose>
          </div>
        </c:forEach>
      </div>
    </div>

    <!-- Right column -->
    <div class="xl:col-span-2 flex flex-col gap-4 sm:gap-5">

      <!-- Phân bổ vai trò -->
      <div class="reveal d1 adm-card p-5">
        <h3 class="text-sm font-bold text-slate-900 mb-4 flex items-center gap-2">
          <span class="material-symbols-outlined text-[17px] text-violet-500" style="font-variation-settings:'FILL' 1">donut_large</span>
          Phân bổ vai trò
        </h3>
        <div class="flex flex-col gap-3.5">
          <c:set var="tot" value="${totalAccounts > 0 ? totalAccounts : 1}"/>

          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-[14px] text-blue-600">storefront</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center justify-between mb-1.5">
                <span class="text-xs font-medium text-slate-700">Chủ cơ sở</span>
                <span class="text-xs font-bold text-slate-900">${totalOwners}</span>
              </div>
              <div class="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-blue-500 rounded-full transition-all duration-700"
                     style="width:${totalOwners * 100 / tot}%"></div>
              </div>
            </div>
          </div>

          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-lg bg-violet-50 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-[14px] text-violet-600">admin_panel_settings</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center justify-between mb-1.5">
                <span class="text-xs font-medium text-slate-700">Quản lý</span>
                <span class="text-xs font-bold text-slate-900">${totalManagers}</span>
              </div>
              <div class="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-violet-500 rounded-full transition-all duration-700"
                     style="width:${totalManagers * 100 / tot}%"></div>
              </div>
            </div>
          </div>

          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-lg bg-amber-50 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-[14px] text-amber-600">badge</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center justify-between mb-1.5">
                <span class="text-xs font-medium text-slate-700">Nhân viên</span>
                <span class="text-xs font-bold text-slate-900">${totalStaff}</span>
              </div>
              <div class="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-amber-500 rounded-full transition-all duration-700"
                     style="width:${totalStaff * 100 / tot}%"></div>
              </div>
            </div>
          </div>

          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-lg bg-emerald-50 flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-[14px] text-emerald-600">groups</span>
            </div>
            <div class="flex-1">
              <div class="flex items-center justify-between mb-1.5">
                <span class="text-xs font-medium text-slate-700">Khách hàng</span>
                <span class="text-xs font-bold text-slate-900">${totalCustomers}</span>
              </div>
              <div class="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <div class="h-full bg-emerald-500 rounded-full transition-all duration-700"
                     style="width:${totalCustomers * 100 / tot}%"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tài khoản mới nhất -->
      <div class="reveal d2 adm-card flex-1">
        <div class="flex items-center justify-between px-5 py-4 border-b border-slate-100">
          <h3 class="text-sm font-bold text-slate-900 flex items-center gap-2">
            <span class="material-symbols-outlined text-[17px] text-emerald-500" style="font-variation-settings:'FILL' 1">person_add</span>
            Tài khoản mới nhất
          </h3>
          <a href="${pageContext.request.contextPath}/admin/nhan-su"
             class="text-[11px] font-semibold text-blue-600 hover:underline flex items-center gap-0.5">
            Xem tất <span class="material-symbols-outlined text-[13px]">arrow_forward</span>
          </a>
        </div>
        <c:if test="${empty recentAccounts}">
          <div class="p-6 text-center text-slate-400 text-sm">Chưa có tài khoản.</div>
        </c:if>
        <div class="divide-y divide-slate-50">
          <c:forEach items="${recentAccounts}" var="acc">
            <div class="flex items-center gap-3 px-5 py-3 hover:bg-slate-50/60 transition-colors">
              <div class="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center
                          text-slate-700 font-bold text-xs shrink-0 border border-slate-200">
                <c:choose>
                  <c:when test="${acc.fullName != null && acc.fullName.length() > 0}">${acc.fullName.substring(0,1).toUpperCase()}</c:when>
                  <c:otherwise>${acc.username.substring(0,1).toUpperCase()}</c:otherwise>
                </c:choose>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-xs font-semibold text-slate-900 truncate leading-tight">
                  <c:out value="${acc.fullName != null && acc.fullName.length() > 0 ? acc.fullName : acc.username}"/>
                </p>
                <p class="text-[10px] text-slate-400 truncate"><c:out value="${acc.username}"/></p>
              </div>
              <c:choose>
                <c:when test="${acc.roleId == 1}"><span class="badge badge-red text-[10px]">Admin</span></c:when>
                <c:when test="${acc.roleId == 2}"><span class="badge badge-purple text-[10px]">QL</span></c:when>
                <c:when test="${acc.roleId == 3}"><span class="badge badge-green text-[10px]">KH</span></c:when>
                <c:when test="${acc.roleId == 4}"><span class="badge badge-amber text-[10px]">LT</span></c:when>
                <c:when test="${acc.roleId == 5}"><span class="badge badge-zinc text-[10px]">BV</span></c:when>
                <c:when test="${acc.roleId == 6}"><span class="badge badge-blue text-[10px]">Owner</span></c:when>
              </c:choose>
            </div>
          </c:forEach>
        </div>
      </div>

    </div>
  </section>

  <!-- QUICK ACCESS -->
  <section class="grid grid-cols-1 sm:grid-cols-3 gap-3 sm:gap-4">
    <a href="${pageContext.request.contextPath}/admin/chi-nhanh"
       class="reveal d0 adm-card adm-card-hover flex items-center gap-4 p-5 group">
      <div class="w-12 h-12 rounded-2xl bg-blue-600 flex items-center justify-center
                  shadow-lg shadow-blue-200 group-hover:scale-110 transition-transform shrink-0">
        <span class="material-symbols-outlined text-white text-[22px]" style="font-variation-settings:'FILL' 1">location_on</span>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-bold text-slate-900">Quản lý Cơ Sở</p>
        <p class="text-xs text-slate-400 mt-0.5">${totalBranches} cơ sở · Thêm, sửa, xóa</p>
      </div>
      <span class="material-symbols-outlined text-slate-300 group-hover:text-blue-500 transition-colors text-[20px]">arrow_forward</span>
    </a>

    <a href="${pageContext.request.contextPath}/admin/nhan-su"
       class="reveal d1 adm-card adm-card-hover flex items-center gap-4 p-5 group">
      <div class="w-12 h-12 rounded-2xl bg-violet-600 flex items-center justify-center
                  shadow-lg shadow-violet-200 group-hover:scale-110 transition-transform shrink-0">
        <span class="material-symbols-outlined text-white text-[22px]" style="font-variation-settings:'FILL' 1">groups</span>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-bold text-slate-900">Quản lý Nhân Sự</p>
        <p class="text-xs text-slate-400 mt-0.5">${totalAccounts} tài khoản · Phân quyền</p>
      </div>
      <span class="material-symbols-outlined text-slate-300 group-hover:text-violet-500 transition-colors text-[20px]">arrow_forward</span>
    </a>

    <a href="${pageContext.request.contextPath}/admin/quan-ly-owner"
       class="reveal d2 adm-card adm-card-hover flex items-center gap-4 p-5 group">
      <div class="w-12 h-12 rounded-2xl bg-emerald-600 flex items-center justify-center
                  shadow-lg shadow-emerald-200 group-hover:scale-110 transition-transform shrink-0">
        <span class="material-symbols-outlined text-white text-[22px]" style="font-variation-settings:'FILL' 1">manage_accounts</span>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-bold text-slate-900">Quản lý Owner</p>
        <p class="text-xs text-slate-400 mt-0.5">Duyệt đăng ký · Khóa tài khoản</p>
      </div>
      <span class="material-symbols-outlined text-slate-300 group-hover:text-emerald-500 transition-colors text-[20px]">arrow_forward</span>
    </a>
  </section>

</main>
</body>
</html>
