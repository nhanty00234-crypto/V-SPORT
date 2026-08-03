<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Tabler Icons --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/dist/tabler-icons.min.css"/>

<!-- Mobile sidebar overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-black/40 z-20 hidden"></div>

<!-- ═══ STAFF SHARED CSS ═══ -->
<style id="staff-shared-css">

  /* ── Nav links ── */
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
    transition: background-color .15s ease, color .15s ease, transform .15s ease, box-shadow .15s ease;
    white-space: nowrap;
    position: relative;
    cursor: pointer;
  }
  .nav-link:hover { background: #fff7ed; color: #c2410c; transform: translateX(2px); }
  .nav-link.active {
    background: #ffedd5;
    color: #c2410c;
    font-weight: 600;
  }
  .nav-link.is-navigating {
    background: linear-gradient(90deg, #fed7aa, #ffedd5);
    color: #c2410c;
    box-shadow: inset 0 0 0 1px rgba(234,88,12,.1);
  }
  .nav-link.active::before {
    content: '';
    position: absolute;
    left: 0;
    top: 8px;
    bottom: 8px;
    width: 3px;
    background: #ea580c;
    border-radius: 0 3px 3px 0;
  }

  /* ── Scroll reveal ── */
  .reveal       { opacity:0; transform:translateY(14px);   transition:opacity .42s cubic-bezier(.22,1,.36,1),transform .42s cubic-bezier(.22,1,.36,1); }
  .reveal-left  { opacity:0; transform:translateX(-14px);  transition:opacity .42s cubic-bezier(.22,1,.36,1),transform .42s cubic-bezier(.22,1,.36,1); }
  .reveal-scale { opacity:0; transform:scale(.98);         transition:opacity .38s cubic-bezier(.22,1,.36,1),transform .38s cubic-bezier(.22,1,.36,1); }
  .reveal.visible, .reveal-left.visible, .reveal-scale.visible { opacity:1; transform:none; }
  .d0{transition-delay:0ms}   .d1{transition-delay:45ms}  .d2{transition-delay:90ms}
  .d3{transition-delay:135ms} .d4{transition-delay:180ms} .d5{transition-delay:225ms}

  /* ── Page enter/exit motion ── */
  body.stf-motion main {
    opacity: 0;
    transform: translateY(5px) scale(.998);
    animation: none !important;
  }
  body.stf-motion.stf-page-ready main {
    opacity: 1;
    transform: translateY(0) scale(1);
    transition: opacity .16s cubic-bezier(.22,1,.36,1),
                transform .16s cubic-bezier(.22,1,.36,1);
  }
  body.stf-page-exiting main {
    opacity: 0 !important;
    transform: translateY(-4px) scale(.997) !important;
    transition: opacity .1s ease, transform .1s ease !important;
  }

  /* ── Transition scrim overlay ── */
  .stf-transition-scrim {
    position: fixed;
    inset: 0;
    z-index: 60;
    pointer-events: none;
    background: linear-gradient(180deg, rgba(255,247,237,.5), rgba(254,237,213,.62));
    opacity: 0;
    transition: opacity .1s ease;
  }
  body.stf-page-exiting .stf-transition-scrim {
    opacity: 1;
  }
  .stf-transition-scrim::after {
    content: '';
    position: absolute;
    left: 248px; right: 0; top: 64px;
    height: 2px;
    background: linear-gradient(90deg, transparent, #ea580c, #fb923c, transparent);
    transform: scaleX(0);
    transform-origin: left;
  }
  body.stf-page-exiting .stf-transition-scrim::after {
    animation: stfRouteLine .22s cubic-bezier(.22,1,.36,1) forwards;
  }
  @keyframes stfRouteLine { to { transform: scaleX(1); } }

  @media (max-width: 1023px) { .stf-transition-scrim::after { left: 0; } }
  @media (prefers-reduced-motion: reduce) {
    body.stf-motion main,
    body.stf-motion.stf-page-ready main,
    body.stf-page-exiting main { opacity:1!important; transform:none!important; filter:none!important; transition:none!important; }
    .stf-transition-scrim { display: none !important; }
  }

  .nav-link .material-symbols-outlined,
  .nav-link .ti { transition: transform .2s cubic-bezier(.34,1.56,.64,1); }
  .nav-link:hover .material-symbols-outlined,
  .nav-link:hover .ti { transform: scale(1.15); color: #ea580c; }
</style>

<!-- ═══ SIDEBAR ACCORDION CSS ═══ -->
<style>
  .nav-group-header {
    display: flex; align-items: center; gap: 10px;
    padding: 9px 12px; border-radius: 10px;
    font-size: 13.5px; font-weight: 600; color: #6b7280;
    cursor: pointer; width: 100%; background: transparent;
    border: none; text-align: left;
    transition: background .15s, color .15s;
    user-select: none;
  }
  .nav-group-header:hover { background: #fff7ed; color: #c2410c; }
  .nav-group-header.group-open { color: #c2410c; background: #fff7ed; font-weight: 700; }
  .nav-group-header .group-arrow {
    margin-left: auto; font-size: 16px; transition: transform .22s cubic-bezier(.22,1,.36,1);
    opacity: .5;
  }
  .nav-group-header.group-open .group-arrow { transform: rotate(180deg); opacity: 1; }
  .nav-group-children {
    overflow: hidden;
    max-height: 0;
    transition: max-height .28s cubic-bezier(.22,1,.36,1), opacity .2s ease;
    opacity: 0;
  }
  .nav-group-children.group-open {
    max-height: 400px;
    opacity: 1;
  }
  .nav-group-children .nav-link {
    padding-left: 38px;
    font-size: 13px;
  }
  .nav-group-children .nav-link.active::before { left: 0; }
  .nav-group-wrap { margin-bottom: 2px; }
</style>

<!-- ═══ SIDEBAR ═══ -->
<aside id="sidebar"
  class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-orange-100 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">

  <div class="px-5 py-4 border-b border-orange-50 flex items-center gap-3 shrink-0">
    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center shrink-0 shadow-md shadow-orange-200">
      <i class="ti ti-ball-tennis text-white text-[18px]"></i>
    </div>
    <div>
      <p class="text-sm font-bold text-orange-900 leading-tight tracking-tight">V-SPORT</p>
      <p class="text-[10px] text-orange-550 font-semibold uppercase tracking-wider">Staff Portal</p>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="flex-1 overflow-y-auto px-3 py-3 flex flex-col gap-0.5" id="sidebarNav">
    <c:set var="uri" value="${pageContext.request.requestURI}" />

    <%-- Tính active group để auto-open --%>
    <c:set var="grpVanHanh"  value="${uri.contains('/staff/checkin') || uri.contains('/CheckIn.jsp') || uri.contains('/staff/dat-san') || uri.contains('/QuanLyDatSan.jsp') || uri.contains('/staff/yeu-cau-qr') || uri.contains('/YeuCauQR.jsp')}" />
    <c:set var="grpTaiChinh" value="${uri.contains('/staff/hoan-tien') || uri.contains('/staff/HoanTien.jsp')}" />
    <c:set var="grpCaNhan"   value="${uri.contains('/staff/ca-lam') || uri.contains('/CaLamViec.jsp') || uri.contains('/yeu-cau-nghi') || uri.contains('/yeuCauNghi_')}" />

    <!-- ── Tổng quan (không có group) ── -->
    <a href="${pageContext.request.contextPath}/staff/dashboard"
      class="nav-link ${uri.contains('/staff/dashboard') || uri.contains('/Dashboard.jsp') ? 'active' : ''}">
      <i class="ti ti-layout-dashboard text-[19px]"></i>Tổng quan
    </a>

    <!-- ── Vận hành sân bãi ── -->
    <div class="nav-group-wrap">
      <button class="nav-group-header ${grpVanHanh ? 'group-open' : ''}" onclick="toggleGroup(this)">
        <i class="ti ti-building-stadium text-[19px] text-orange-500"></i>
        Vận hành sân bãi
        <i class="ti ti-chevron-down group-arrow"></i>
      </button>
      <div class="nav-group-children ${grpVanHanh ? 'group-open' : ''}">
        <a href="${pageContext.request.contextPath}/staff/checkin"
          class="nav-link ${uri.contains('/staff/checkin') || uri.contains('/CheckIn.jsp') ? 'active' : ''}">
          <i class="ti ti-door-enter text-[16px]"></i>Mở sân / Check-in
        </a>
        <a href="${pageContext.request.contextPath}/staff/dat-san"
          class="nav-link ${uri.contains('/staff/dat-san') || uri.contains('/QuanLyDatSan.jsp') ? 'active' : ''}">
          <i class="ti ti-calendar-check text-[16px]"></i>Duyệt đặt sân
        </a>
        <a href="${pageContext.request.contextPath}/staff/yeu-cau-qr"
          class="nav-link ${uri.contains('/staff/yeu-cau-qr') || uri.contains('/YeuCauQR.jsp') ? 'active' : ''}">
          <i class="ti ti-qrcode text-[16px]"></i>Yêu cầu từ QR
        </a>
      </div>
    </div>

    <!-- ── Tài chính ── -->
    <div class="nav-group-wrap">
      <button class="nav-group-header ${grpTaiChinh ? 'group-open' : ''}" onclick="toggleGroup(this)">
        <i class="ti ti-cash text-[19px] text-orange-500"></i>
        Tài chính
        <i class="ti ti-chevron-down group-arrow"></i>
      </button>
      <div class="nav-group-children ${grpTaiChinh ? 'group-open' : ''}">
        <a href="${pageContext.request.contextPath}/staff/hoan-tien"
          class="nav-link ${uri.contains('/staff/hoan-tien') || uri.contains('/staff/HoanTien.jsp') ? 'active' : ''}">
          <i class="ti ti-receipt-refund text-[16px]"></i>Yêu cầu hoàn tiền
        </a>
      </div>
    </div>

    <!-- ── Cá nhân ── -->
    <div class="nav-group-wrap">
      <button class="nav-group-header ${grpCaNhan ? 'group-open' : ''}" onclick="toggleGroup(this)">
        <i class="ti ti-user text-[19px] text-orange-500"></i>
        Cá nhân
        <i class="ti ti-chevron-down group-arrow"></i>
      </button>
      <div class="nav-group-children ${grpCaNhan ? 'group-open' : ''}">
        <a href="${pageContext.request.contextPath}/staff/ca-lam"
          class="nav-link ${uri.contains('/staff/ca-lam') || uri.contains('/CaLamViec.jsp') ? 'active' : ''}">
          <i class="ti ti-calendar-week text-[16px]"></i>Lịch làm của tôi
        </a>
        <a href="${pageContext.request.contextPath}/staff/yeu-cau-nghi"
          class="nav-link ${uri.contains('/yeu-cau-nghi') || uri.contains('/yeuCauNghi_') ? 'active' : ''}">
          <i class="ti ti-clipboard-list text-[16px]"></i>Đăng ký nghỉ phép
        </a>
      </div>
    </div>

    <!-- ── Đăng ký khuôn mặt ── -->
    <a href="${pageContext.request.contextPath}/staff/enroll-face"
      class="nav-link ${uri.contains('/staff/enroll-face') || uri.contains('/FaceEnroll.jsp') ? 'active' : ''}">
      <i class="ti ti-face-id text-[19px]"></i>Đăng ký khuôn mặt
    </a>

  </nav>

  <!-- Logout -->
  <div class="px-3 py-3 border-t border-orange-50 shrink-0">
    <a href="${pageContext.request.contextPath}/logout"
      class="nav-link text-red-500 hover:bg-red-50 hover:text-red-600 text-xs font-semibold">
      <i class="ti ti-logout text-[16px] text-red-500"></i>Đăng xuất
    </a>
  </div>
</aside>

<script>
function toggleGroup(btn) {
  var isOpen = btn.classList.contains('group-open');
  document.querySelectorAll('.nav-group-header.group-open').forEach(function(b) {
    if (b !== btn) {
      b.classList.remove('group-open');
      var ch = b.nextElementSibling;
      if (ch) ch.classList.remove('group-open');
    }
  });
  if (isOpen) {
    btn.classList.remove('group-open');
    btn.nextElementSibling.classList.remove('group-open');
  } else {
    btn.classList.add('group-open');
    btn.nextElementSibling.classList.add('group-open');
  }
}
</script>

<!-- ═══ SIDEBAR JS ═══ -->
<script>
(function () {
  'use strict';

  /* ── 1. Page motion (enter / exit) ── */
  document.body.classList.add('stf-motion');

  function initPageMotion() {
    var scrim = document.createElement('div');
    scrim.className = 'stf-transition-scrim';
    document.body.appendChild(scrim);

    /* enter: reveal main on next frame */
    requestAnimationFrame(function () {
      document.body.classList.add('stf-page-ready');
    });

    /* bfcache restore */
    window.addEventListener('pageshow', function (e) {
      if (e.persisted) {
        document.body.classList.remove('stf-page-exiting');
        requestAnimationFrame(function () {
          document.body.classList.add('stf-page-ready');
        });
      }
    });

    /* intercept clicks → exit animation → navigate */
    document.addEventListener('click', function (event) {
      var link = event.target.closest('a[href]');
      if (!link || event.defaultPrevented) return;
      if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0) return;
      if (link.target && link.target !== '_self') return;
      if (link.hasAttribute('download')) return;

      var href = link.getAttribute('href') || '';
      if (!href || href.charAt(0) === '#' ||
          href.indexOf('javascript:') === 0 ||
          href.indexOf('mailto:') === 0 ||
          href.indexOf('tel:') === 0) return;

      var url;
      try { url = new URL(href, window.location.href); } catch (e) { return; }
      if (url.origin !== window.location.origin) return;
      if (url.pathname === window.location.pathname &&
          url.search === window.location.search &&
          url.hash) return;
      if (url.href === window.location.href) return;

      /* only intercept staff / logout routes */
      var appPath = '${pageContext.request.contextPath}';
      var pathname = url.pathname;
      var isStaffRoute = appPath
        ? (pathname.indexOf(appPath + '/staff')  === 0 ||
           pathname.indexOf(appPath + '/logout') === 0)
        : (pathname.indexOf('/staff')  === 0 ||
           pathname.indexOf('/logout') === 0);
      if (!isStaffRoute) return;

      event.preventDefault();
      link.classList.add('is-navigating');
      document.body.classList.add('stf-page-exiting');
      window.setTimeout(function () {
        window.location.href = url.href;
      }, 90);
    });
  }

  /* ── 2. Sidebar open/close (mobile) ── */
  function initSidebar() {
    var sidebar  = document.getElementById('sidebar');
    var overlay  = document.getElementById('sidebarOverlay');
    if (!sidebar) return;

    function open()  { sidebar.classList.remove('-translate-x-full'); if (overlay) overlay.classList.remove('hidden'); }
    function close() { sidebar.classList.add('-translate-x-full');    if (overlay) overlay.classList.add('hidden'); }

    document.querySelectorAll('[data-sidebar-toggle], #mobileMenuBtn, #sidebarToggle').forEach(function (btn) {
      btn.addEventListener('click', function () {
        sidebar.classList.contains('-translate-x-full') ? open() : close();
      });
    });

    if (overlay) overlay.addEventListener('click', close);
    window.addEventListener('resize', function () {
      if (window.innerWidth >= 1024) { if (overlay) overlay.classList.add('hidden'); }
    });
  }

  /* ── 3. Scroll reveal ── */
  function initReveal() {
    var els = document.querySelectorAll('.reveal, .reveal-left, .reveal-scale, .reveal-on-scroll');
    if (!els.length) return;
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) {
          e.target.classList.add('visible');
          e.target.classList.add('revealed');
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.06, rootMargin: '0px 0px -8px 0px' });
    els.forEach(function (el) { io.observe(el); });
  }

  /* ── Boot ── */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () {
      initPageMotion();
      initSidebar();
      initReveal();
    });
  } else {
    initPageMotion();
    initSidebar();
    initReveal();
  }
})();
</script>
