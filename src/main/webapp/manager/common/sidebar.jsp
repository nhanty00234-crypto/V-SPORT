<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!-- Sidebar Manager -->
    <aside id="sidebar"
      class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-purple-100 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">
      <div class="px-5 py-4 border-b border-purple-50 flex items-center gap-3">
        <div
          class="w-9 h-9 rounded-xl bg-gradient-to-br from-purple-600 to-indigo-800 flex items-center justify-center shrink-0 shadow-md shadow-purple-200">
          <span class="material-symbols-outlined text-white text-[18px]">sports_tennis</span>
        </div>
        <div>
          <p class="text-sm font-bold text-purple-900 leading-tight tracking-tight">V-SPORT</p>
          <p class="text-[10px] text-purple-500 font-semibold uppercase tracking-wider">Manager Portal</p>
        </div>
      </div>

      <nav class="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-1">
        <c:set var="uri" value="${pageContext.request.requestURI}" />
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mb-1.5">Vận hành cơ sở</p>
        <a href="${pageContext.request.contextPath}/manager/dashboard"
          class="nav-link ${uri.contains('/manager/dashboard') || uri.contains('/Dashboard.jsp') ? 'active' : ''}">
          <span class="material-symbols-outlined text-[19px]">space_dashboard</span>Tổng quan
        </a>
        <a href="${pageContext.request.contextPath}/manager/quan-ly-san"
          class="nav-link ${uri.contains('/manager/quan-ly-san') || uri.contains('/QuanLySan.jsp') ? 'active' : ''}">
          <span class="material-symbols-outlined text-[19px]">stadium</span>Quản lý sân
        </a>
        <a href="${pageContext.request.contextPath}/manager/kho-dich-vu"
          class="nav-link ${uri.contains('/manager/kho-dich-vu') || uri.contains('/KhoDichVu.jsp') ? 'active' : ''}">
          <span class="material-symbols-outlined text-[19px]">inventory_2</span>Kho & Dịch Vụ
        </a>
        <a href="${pageContext.request.contextPath}/staff/checkin"
          class="nav-link ${uri.contains('/staff/checkin') || uri.contains('/CheckIn.jsp') ? 'active' : ''}">
          <span class="material-symbols-outlined text-[19px]">power_settings_new</span>Mở sân / Check-in
        </a>

        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mt-5 mb-1.5">Nhân sự & Khách hàng
        </p>
        <a href="${pageContext.request.contextPath}/manager/nhan-su"
          class="nav-link ${uri.contains('/manager/nhan-su') || uri.contains('/NhanSu.jsp') ? 'active' : ''}">
          <span class="material-symbols-outlined text-[19px]">groups</span>Nhân sự
        </a>
        <a href="${pageContext.request.contextPath}/manager/khach-hang"
          class="nav-link ${uri.contains('/manager/khach-hang') || uri.contains('/KhachHang.jsp') ? 'active' : ''}">
          <span class="material-symbols-outlined text-[19px]">face</span>Quản lý khách hàng
        </a>
      </nav>

      <div class="px-3 py-3 border-t border-purple-50">
        <a href="${pageContext.request.contextPath}/logout"
          class="nav-link text-red-500 hover:bg-red-50 text-xs font-semibold">
          <span class="material-symbols-outlined text-[16px] text-red-500">logout</span>Đăng xuất
        </a>
      </div>
    </aside>

    <style>
      .nav-link {
        display: flex;
        align-items: center;
        gap: 11px;
        padding: 10px 14px;
        border-radius: 10px;
        color: #6b7280;
        font-size: 14px;
        font-weight: 500;
        text-decoration: none;
        transition: all .15s;
        white-space: nowrap;
        position: relative;
      }

      .nav-link:hover {
        background: #f5f3ff;
        color: #6d28d9;
      }

      .nav-link.active {
        background: #ede9fe;
        color: #6d28d9;
        font-weight: 600;
      }

      .nav-link.active::before {
        content: '';
        position: absolute;
        left: 0;
        top: 8px;
        bottom: 8px;
        width: 3px;
        background: #7c3aed;
        border-radius: 0 3px 3px 0;
      }
    </style>