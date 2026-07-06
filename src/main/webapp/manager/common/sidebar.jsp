<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Tabler Icons – custom icon set for V-SPORT --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css"/>
<!-- Mobile sidebar overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-black/40 z-20 hidden"></div>

    <!-- Sidebar Manager -->
    <aside id="sidebar"
      class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-purple-100 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">
      <div class="px-5 py-4 border-b border-purple-50 flex items-center gap-3">
        <div
          class="w-9 h-9 rounded-xl bg-gradient-to-br from-purple-600 to-indigo-800 flex items-center justify-center shrink-0 shadow-md shadow-purple-200">
          <i class="ti ti-ball-tennis text-white text-[18px]"></i>
        </div>
        <div>
          <p class="text-sm font-bold text-purple-900 leading-tight tracking-tight">V-SPORT</p>
          <p class="text-[10px] text-purple-500 font-semibold uppercase tracking-wider">Manager Portal</p>
        </div>
      </div>

      <nav class="flex-1 overflow-y-auto px-3 py-4 flex flex-col gap-1">
        <c:set var="uri" value="${pageContext.request.requestURI}" />
        
        <!-- Tổng quan -->
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mb-1.5">Tổng quan</p>
        <a href="${pageContext.request.contextPath}/manager/dashboard"
          class="nav-link ${uri.contains('/manager/dashboard') || uri.contains('/Dashboard.jsp') ? 'active' : ''}">
          <i class="ti ti-layout-dashboard text-[19px]"></i>Tổng quan
        </a>

        <!-- Vận hành sân bãi -->
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mt-4 mb-1.5">Vận hành sân bãi</p>
        <a href="${pageContext.request.contextPath}/manager/quan-ly-san"
          class="nav-link ${uri.contains('/manager/quan-ly-san') || uri.contains('/QuanLySan.jsp') ? 'active' : ''}">
          <i class="ti ti-building-stadium text-[19px]"></i>Quản lý sân
        </a>
        <a href="${pageContext.request.contextPath}/staff/checkin"
          class="nav-link ${uri.contains('/staff/checkin') || uri.contains('/CheckIn.jsp') ? 'active' : ''}">
          <i class="ti ti-door-enter text-[19px]"></i>Mở sân / Check-in
        </a>
        <a href="${pageContext.request.contextPath}/manager/dat-san"
          class="nav-link ${uri.contains('/manager/dat-san') || uri.contains('/QuanLyDatSan.jsp') ? 'active' : ''}">
          <i class="ti ti-calendar-check text-[19px]"></i>Duyệt đặt sân
        </a>

        <!-- Kinh doanh & Dịch vụ -->
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mt-4 mb-1.5">Kinh doanh &amp; Dịch vụ</p>
        <a href="${pageContext.request.contextPath}/manager/kho-dich-vu"
          class="nav-link ${uri.contains('/manager/kho-dich-vu') || uri.contains('/KhoDichVu.jsp') ? 'active' : ''}">
          <i class="ti ti-package text-[19px]"></i>Kho &amp; Dịch Vụ
        </a>

        <!-- Nhân sự -->
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mt-4 mb-1.5">Quản lý nhân sự</p>
        <a href="${pageContext.request.contextPath}/manager/nhan-su"
          class="nav-link ${uri.contains('/manager/nhan-su') || uri.contains('/NhanSu.jsp') ? 'active' : ''}">
          <i class="ti ti-users-group text-[19px]"></i>Nhân sự
        </a>
        <a href="${pageContext.request.contextPath}/manager/ca-lam"
          class="nav-link ${uri.contains('/manager/ca-lam') || uri.contains('/CaLamViec.jsp') ? 'active' : ''}">
          <i class="ti ti-calendar-time text-[19px]"></i>Lịch làm việc
        </a>

        <!-- Khách hàng -->
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mt-4 mb-1.5">Khách hàng</p>
        <a href="${pageContext.request.contextPath}/manager/khach-hang"
          class="nav-link ${uri.contains('/manager/khach-hang') || uri.contains('/KhachHang.jsp') ? 'active' : ''}">
          <i class="ti ti-user text-[19px]"></i>Quản lý khách hàng
        </a>

        <!-- Hệ thống -->
        <p class="text-[10px] font-bold uppercase tracking-widest text-purple-400 px-3 mt-4 mb-1.5">Hệ thống</p>
        <a href="${pageContext.request.contextPath}/manager/thung-rac"
          class="nav-link ${uri.contains('/manager/thung-rac') || uri.contains('/ThungRac.jsp') ? 'active' : ''}">
          <i class="ti ti-trash text-[19px]"></i>Thùng rác
        </a>
        <a href="${pageContext.request.contextPath}/manager/audit-log"
          class="nav-link ${uri.contains('/manager/audit-log') ? 'active' : ''}">
          <i class="ti ti-history text-[19px]"></i>Nhật Ký Thao Tác
        </a>
      </nav>

      <div class="px-3 py-3 border-t border-purple-50">
        <a href="${pageContext.request.contextPath}/logout"
          class="nav-link text-red-500 hover:bg-red-50 text-xs font-semibold">
          <i class="ti ti-logout text-[16px] text-red-500"></i>Đăng xuất
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
<script>
(function() {
  function initSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    if (!sidebar || !overlay) return;
    new MutationObserver(function() {
      if (window.innerWidth < 1024) {
        overlay.classList.toggle('hidden', sidebar.classList.contains('-translate-x-full'));
      }
    }).observe(sidebar, { attributes: true, attributeFilter: ['class'] });
    overlay.addEventListener('click', function() { sidebar.classList.add('-translate-x-full'); });
    sidebar.querySelectorAll('a').forEach(function(a) {
      a.addEventListener('click', function() {
        if (window.innerWidth < 1024) sidebar.classList.add('-translate-x-full');
      });
    });
    window.addEventListener('resize', function() {
      if (window.innerWidth >= 1024) overlay.classList.add('hidden');
    });
  }
  function init24hTime() {
    document.querySelectorAll('input[type="time"]').forEach(function(inp) {
      var val   = inp.value || '00:00';
      var parts = val.split(':');
      var initH = parseInt(parts[0] || 0, 10);
      var initM = parseInt(parts[1] || 0, 10);
      var steps = [0, 15, 30, 45];
      var closestM = steps.reduce(function(a, b) { return Math.abs(b - initM) < Math.abs(a - initM) ? b : a; });

      var wrap = document.createElement('div');
      wrap.style.cssText = 'display:flex;align-items:center;gap:4px;width:100%;';

      var selStyle = 'flex:1;min-width:0;height:' + (inp.offsetHeight || 38) + 'px;'
                   + 'padding:4px 8px;border:' + getComputedStyle(inp).border + ';'
                   + 'border-radius:' + getComputedStyle(inp).borderRadius + ';'
                   + 'font-size:' + getComputedStyle(inp).fontSize + ';'
                   + 'background:#fff;cursor:pointer;';

      var hSel = document.createElement('select');
      hSel.style.cssText = selStyle;
      hSel.setAttribute('aria-label', 'Giờ');
      for (var h = 0; h <= 23; h++) {
        var o = document.createElement('option');
        o.value = String(h).padStart(2, '0');
        o.textContent = String(h).padStart(2, '0') + 'h';
        if (h === initH) o.selected = true;
        hSel.appendChild(o);
      }

      var mSel = document.createElement('select');
      mSel.style.cssText = selStyle;
      mSel.setAttribute('aria-label', 'Phút');
      steps.forEach(function(m) {
        var o = document.createElement('option');
        o.value = String(m).padStart(2, '0');
        o.textContent = String(m).padStart(2, '0');
        if (m === closestM) o.selected = true;
        mSel.appendChild(o);
      });

      function sync() {
        inp.value = hSel.value + ':' + mSel.value + ':00';
        inp.dispatchEvent(new Event('change', { bubbles: true }));
        inp.dispatchEvent(new Event('input',  { bubbles: true }));
      }
      hSel.addEventListener('change', sync);
      mSel.addEventListener('change', sync);

      wrap.appendChild(hSel);
      wrap.appendChild(mSel);
      inp.style.display = 'none';
      inp.parentNode.insertBefore(wrap, inp.nextSibling);
      sync();
    });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function() { initSidebar(); init24hTime(); });
  else { initSidebar(); init24hTime(); }
})();
</script>

<!-- Reusable Custom Delete Confirmation Modal -->
<div id="customConfirmModal" class="fixed inset-0 z-[100] flex items-center justify-center p-4 hidden">
  <div class="absolute inset-0 bg-black/40 backdrop-blur-xs transition-opacity duration-300" onclick="closeCustomConfirm()"></div>
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-[400px] p-6 text-center transform scale-95 transition-all duration-300 border border-purple-100">
    <div class="w-14 h-14 rounded-full bg-purple-50 text-purple-600 flex items-center justify-center mx-auto mb-4">
      <i class="ti ti-trash text-[28px] text-purple-600"></i>
    </div>
    <h3 class="text-base font-bold text-purple-955 mb-2">Xác nhận xóa</h3>
    <p class="text-xs text-purple-650/80 mb-6 leading-relaxed px-2" id="customConfirmMessage">Bạn có chắc chắn muốn xóa mục này?</p>
    <div class="flex gap-3 justify-center">
      <button onclick="closeCustomConfirm()" class="flex-1 py-2 bg-zinc-100 hover:bg-zinc-200 text-zinc-700 rounded-xl text-xs font-semibold transition-all">
        Hủy bỏ
      </button>
      <button id="customConfirmSubmitBtn" class="flex-1 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-xs font-semibold transition-all shadow-md shadow-purple-200">
        Xác nhận xóa
      </button>
    </div>
  </div>
</div>

<script>
  let customConfirmCallback = null;

  function showCustomConfirm(message, callback) {
      document.getElementById('customConfirmMessage').textContent = message;
      customConfirmCallback = callback;
      const modal = document.getElementById('customConfirmModal');
      modal.classList.remove('hidden');
      const box = modal.querySelector('.relative');
      setTimeout(() => {
          box.classList.remove('scale-95');
          box.classList.add('scale-100');
      }, 10);
  }

  function closeCustomConfirm() {
      const modal = document.getElementById('customConfirmModal');
      if (!modal) return;
      const box = modal.querySelector('.relative');
      box.classList.remove('scale-100');
      box.classList.add('scale-95');
      setTimeout(() => {
          modal.classList.add('hidden');
      }, 150);
  }

  function showToast(message, type = 'success') {
      let container = document.getElementById('global-toast-container');
      if (!container) {
          container = document.createElement('div');
          container.id = 'global-toast-container';
          container.className = 'fixed bottom-5 right-5 z-[200] flex flex-col gap-2 max-w-sm w-full';
          document.body.appendChild(container);
      }
      
      const toast = document.createElement('div');
      toast.className = 'p-4 rounded-xl shadow-lg border text-xs font-semibold flex items-center gap-3 transition-all duration-300 transform translate-y-2 opacity-0';
      
      let bg = 'bg-white border-purple-100 text-purple-900';
      let icon = 'info';
      let iconColor = 'text-purple-600';
      
      if (type === 'success') {
          bg = 'bg-purple-50 border-purple-150 text-purple-900';
          icon = 'check_circle';
          iconColor = 'text-purple-600';
      } else if (type === 'error') {
          bg = 'bg-red-50 border-red-150 text-red-900';
          icon = 'error';
          iconColor = 'text-red-600';
      }
      
      toast.className += ' ' + bg;
      
      toast.innerHTML = `
          <span class="material-symbols-outlined ` + iconColor + ` text-[20px] shrink-0">` + icon + `</span>
          <div class="flex-1">` + message + `</div>
      `;
      
      container.appendChild(toast);
      
      setTimeout(() => {
          toast.classList.remove('translate-y-2', 'opacity-0');
      }, 10);
      
      setTimeout(() => {
          toast.classList.add('translate-y-2', 'opacity-0');
          setTimeout(() => {
              toast.remove();
          }, 300);
      }, 4000);
  }

  document.addEventListener('DOMContentLoaded', () => {
      const submitBtn = document.getElementById('customConfirmSubmitBtn');
      if (submitBtn) {
          submitBtn.addEventListener('click', () => {
              if (customConfirmCallback) {
                  customConfirmCallback();
              }
              closeCustomConfirm();
          });
      }
  });
</script>