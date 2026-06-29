<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!-- Sidebar Staff -->
<aside id="sidebar" class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-orange-100 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">
  <div class="px-5 py-4 border-b border-orange-50 flex items-center gap-3">
    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center shrink-0 shadow-md shadow-orange-200">
      <span class="material-symbols-outlined text-white text-[18px]">sports_tennis</span>
    </div>
    <div>
      <p class="text-sm font-bold text-orange-900 leading-tight tracking-tight">V-SPORT</p>
      <p class="text-[10px] text-orange-550 font-semibold uppercase tracking-wider">Staff Portal</p>
    </div>
  </div>
  
  <nav class="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-1">
    <c:set var="uri" value="${pageContext.request.requestURI}" />
    <p class="text-[10px] font-bold uppercase tracking-widest text-orange-400 px-3 mb-1.5">Công việc</p>
    <a href="${pageContext.request.contextPath}/staff/dashboard" class="nav-link ${uri.contains('/staff/dashboard') || uri.contains('/Dashboard.jsp') ? 'active' : ''}">
      <span class="material-symbols-outlined text-[19px]">space_dashboard</span>Tổng quan
    </a>
    <a href="${pageContext.request.contextPath}/staff/ca-lam" class="nav-link ${uri.contains('/ca-lam') || uri.contains('/CaLamViec.jsp') ? 'active' : ''}">
      <span class="material-symbols-outlined text-[19px]">schedule</span>Lịch làm việc
    </a>
    <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi" class="nav-link ${uri.contains('/yeu-cau-nghi') || uri.contains('/yeuCauNghi_') ? 'active' : ''}">
      <span class="material-symbols-outlined text-[19px]">assignment</span>Đăng ký nghỉ phép
    </a>
  </nav>
  
  <div class="px-3 py-3 border-t border-orange-50">
    <a href="${pageContext.request.contextPath}/logout" class="nav-link text-red-500 hover:bg-red-50 text-xs font-semibold">
      <span class="material-symbols-outlined text-[16px] text-red-500">logout</span>Đăng xuất
    </a>
  </div>
</aside>

<style>
  .nav-link { 
    display:flex;
    align-items:center;
    gap:11px;
    padding:10px 14px;
    border-radius:10px;
    color:#6b7280;
    font-size:14px;
    font-weight:500;
    text-decoration:none;
    transition:all .15s;
    white-space:nowrap;
    position:relative; 
  }
  .nav-link:hover { 
    background:#fff7ed;
    color:#c2410c; 
  }
  .nav-link.active { 
    background:#ffedd5;
    color:#c2410c;
    font-weight:600; 
  }
  .nav-link.active::before { 
    content:''; 
    position:absolute; 
    left:0; 
    top:8px; 
    bottom:8px; 
    width:3px; 
    background:#ea580c; 
    border-radius:0 3px 3px 0; 
  }
</style>
