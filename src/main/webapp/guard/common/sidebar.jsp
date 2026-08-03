<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String currentUri = request.getRequestURI();
%>

<div id="gdSidebarOverlay" onclick="document.getElementById('gdSidebar').classList.add('-translate-x-full'); this.style.display='none';"></div>

<aside id="gdSidebar" class="fixed top-0 left-0 h-full w-[248px] bg-white border-r border-rose-100 z-30 flex flex-col transition-transform duration-200 -translate-x-full lg:translate-x-0">
  <!-- Logo -->
  <div class="flex items-center gap-3 px-5 py-4 border-b border-rose-100">
    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-rose-500 to-red-700 flex items-center justify-center shadow">
      <span class="material-symbols-outlined text-[18px] text-white" style="font-variation-settings:'FILL' 1">shield_person</span>
    </div>
    <div>
      <p class="text-[10px] font-bold uppercase tracking-widest text-rose-500">V-SPORT</p>
      <p class="text-sm font-black text-rose-900 tracking-tight">GUARD Portal</p>
    </div>
  </div>

  <!-- User info -->
  <div class="px-4 py-3 border-b border-rose-50">
    <div class="flex items-center gap-3">
      <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}&background=e11d48&color=fff&bold=true"
           class="w-9 h-9 rounded-xl object-cover shadow" alt="Avatar">
      <div class="min-w-0">
        <p class="text-xs font-bold text-rose-900 truncate">${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}</p>
        <p class="text-[10px] text-rose-500 font-semibold flex items-center gap-1">
          <span class="w-1.5 h-1.5 rounded-full bg-rose-500 inline-block live-dot"></span>Bảo vệ — CS${sessionScope.user.coSoId}
        </p>
      </div>
    </div>
  </div>

  <!-- Nav -->
  <nav class="flex-1 overflow-y-auto px-3 py-3 flex flex-col gap-1">
    <p class="text-[10px] font-bold uppercase tracking-widest text-rose-400 px-3 mb-1 mt-1">Tổng quan</p>
    <a href="${pageContext.request.contextPath}/guard/dashboard"
       class="gd-nav <%= currentUri.contains("/guard/dashboard") ? "active" : "" %>">
      <span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">dashboard</span>
      Tổng quan
    </a>

    <p class="text-[10px] font-bold uppercase tracking-widest text-rose-400 px-3 mb-1 mt-3">Công việc</p>
    <a href="${pageContext.request.contextPath}/guard/diem-danh"
       class="gd-nav <%= currentUri.contains("/guard/diem-danh") ? "active" : "" %>">
      <span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">badge</span>
      Điểm danh ca
    </a>
    <a href="${pageContext.request.contextPath}/guard/bao-cao-su-co"
       class="gd-nav <%= currentUri.contains("/guard/bao-cao-su-co") ? "active" : "" %>">
      <span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">report</span>
      Báo cáo sự cố
    </a>
    <a href="${pageContext.request.contextPath}/guard/lich-su-su-co"
       class="gd-nav <%= currentUri.contains("/guard/lich-su-su-co") ? "active" : "" %>">
      <span class="material-symbols-outlined text-[19px]" style="font-variation-settings:'FILL' 1">history</span>
      Lịch sử sự cố
    </a>
  </nav>

  <!-- Logout -->
  <div class="px-3 py-4 border-t border-rose-50">
    <a href="${pageContext.request.contextPath}/dangxuat"
       class="gd-nav text-red-600 hover:bg-red-50 hover:text-red-700">
      <span class="material-symbols-outlined text-[19px]">logout</span>
      Đăng xuất
    </a>
  </div>
</aside>
