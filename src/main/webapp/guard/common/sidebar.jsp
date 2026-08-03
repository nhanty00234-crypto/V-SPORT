<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Mobile overlay -->
<div id="sidebarOverlay" class="fixed inset-0 bg-black/40 z-20 hidden"></div>

<!-- ═══ GUARD SIDEBAR CSS ═══ -->
<style>
  /* ── Nav links ── */
  .nav-link {
    display: flex; align-items: center; gap: 10px;
    padding: 9px 12px; border-radius: 10px;
    color: #6b7280; font-size: 13.5px; font-weight: 500;
    text-decoration: none;
    transition: background-color .15s ease, color .15s ease, transform .15s ease;
    white-space: nowrap; position: relative; cursor: pointer;
  }
  .nav-link:hover { background: #fff1f2; color: #be123c; transform: translateX(2px); }
  .nav-link.active {
    background: #ffe4e6; color: #be123c; font-weight: 700;
  }
  .nav-link.is-navigating {
    background: linear-gradient(90deg, #fecdd3, #ffe4e6);
    color: #be123c;
  }
  .nav-link.active::before {
    content: ''; position: absolute; left: 0; top: 8px; bottom: 8px;
    width: 3px; background: #e11d48; border-radius: 0 3px 3px 0;
  }
  .nav-link .ti { transition: transform .2s cubic-bezier(.34,1.56,.64,1); }
  .nav-link:hover .ti { transform: scale(1.15); color: #be123c; }

  /* ── Accordion groups ── */
  .nav-group-header {
    display: flex; align-items: center; gap: 10px;
    padding: 9px 12px; border-radius: 10px;
    font-size: 13.5px; font-weight: 600; color: #6b7280;
    cursor: pointer; width: 100%; background: transparent;
    border: none; text-align: left;
    transition: background .15s, color .15s;
    user-select: none;
  }
  .nav-group-header:hover { background: #fff1f2; color: #be123c; }
  .nav-group-header.group-open { color: #be123c; background: #fff1f2; font-weight: 700; }
  .nav-group-header .group-arrow {
    margin-left: auto; font-size: 16px;
    transition: transform .22s cubic-bezier(.22,1,.36,1); opacity: .5;
  }
  .nav-group-header.group-open .group-arrow { transform: rotate(180deg); opacity: 1; }
  .nav-group-children {
    overflow: hidden; max-height: 0;
    transition: max-height .28s cubic-bezier(.22,1,.36,1), opacity .2s ease;
    opacity: 0;
  }
  .nav-group-children.group-open { max-height: 400px; opacity: 1; }
  .nav-group-children .nav-link { padding-left: 36px; font-size: 13px; }
  .nav-group-children .nav-link.active::before { left: 0; }
  .nav-group-wrap { margin-bottom: 2px; }

  /* ── Page motion ── */
  body.gd-motion main {
    opacity: 0; transform: translateY(5px) scale(.998); animation: none !important;
  }
  body.gd-motion.gd-page-ready main {
    opacity: 1; transform: none;
    transition: opacity .16s cubic-bezier(.22,1,.36,1), transform .16s cubic-bezier(.22,1,.36,1);
  }
  body.gd-page-exiting main {
    opacity: 0 !important; transform: translateY(-4px) scale(.997) !important;
    transition: opacity .1s ease, transform .1s ease !important;
  }
  .gd-transition-scrim {
    position: fixed; inset: 0; z-index: 60; pointer-events: none;
    background: linear-gradient(180deg, rgba(255,241,242,.5), rgba(254,205,211,.5));
    opacity: 0; transition: opacity .1s ease;
  }
  body.gd-page-exiting .gd-transition-scrim { opacity: 1; }

  @media (prefers-reduced-motion: reduce) {
    body.gd-motion main, body.gd-motion.gd-page-ready main, body.gd-page-exiting main {
      opacity:1!important; transform:none!important; transition:none!important;
    }
    .gd-transition-scrim { display:none!important; }
  }
</style>

<!-- ═══ SIDEBAR ═══ -->
<aside id="sidebar"
  class="w-[248px] h-screen fixed left-0 top-0 bg-white border-r border-rose-100 z-30 flex flex-col transition-transform duration-300 -translate-x-full lg:translate-x-0">

  <!-- Logo + tên nhân viên gộp 1 block -->
  <div class="px-5 py-4 border-b border-rose-50 flex items-center gap-3 shrink-0">
    <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-rose-500 to-red-700 flex items-center justify-center shrink-0 shadow-md shadow-rose-200">
      <i class="ti ti-shield-lock text-white text-[18px]"></i>
    </div>
    <div class="min-w-0">
      <p class="text-sm font-bold text-rose-900 leading-tight tracking-tight">V-SPORT</p>
      <p class="text-[10px] text-rose-500 font-semibold uppercase tracking-wider truncate">
        ${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}
        <span class="text-rose-300">·</span> CS${sessionScope.user.coSoId}
      </p>
    </div>
  </div>

  <!-- Navigation -->
  <nav class="flex-1 overflow-y-auto px-3 py-3 flex flex-col gap-0.5" id="sidebarNav">
    <%-- guardPage được set bởi servlet, dùng để xác định active state chính xác sau forward() --%>
    <c:set var="gp" value="${requestScope.guardPage}"/>
    <c:set var="grpCongViec" value="${gp == 'diem-danh' || gp == 'bao-cao-su-co' || gp == 'lich-su-su-co'}"/>

    <!-- Tổng quan -->
    <a href="${pageContext.request.contextPath}/guard/dashboard"
       class="nav-link ${gp == 'dashboard' ? 'active' : ''}">
      <i class="ti ti-layout-dashboard text-[19px]"></i>Tổng quan
    </a>

    <!-- Công việc -->
    <div class="nav-group-wrap">
      <button class="nav-group-header ${grpCongViec ? 'group-open' : ''}" onclick="toggleGroup(this)">
        <i class="ti ti-shield-check text-[19px] text-rose-500"></i>
        Công việc
        <i class="ti ti-chevron-down group-arrow"></i>
      </button>
      <div class="nav-group-children ${grpCongViec ? 'group-open' : ''}">
        <a href="${pageContext.request.contextPath}/guard/diem-danh"
           class="nav-link ${gp == 'diem-danh' ? 'active' : ''}">
          <i class="ti ti-id-badge text-[16px]"></i>Điểm danh ca
        </a>
        <a href="${pageContext.request.contextPath}/guard/bao-cao-su-co"
           class="nav-link ${gp == 'bao-cao-su-co' ? 'active' : ''}">
          <i class="ti ti-alert-triangle text-[16px]"></i>Báo cáo sự cố
        </a>
        <a href="${pageContext.request.contextPath}/guard/lich-su-su-co"
           class="nav-link ${gp == 'lich-su-su-co' ? 'active' : ''}">
          <i class="ti ti-history text-[16px]"></i>Lịch sử sự cố
        </a>
      </div>
    </div>

  </nav>

  <!-- Logout -->
  <div class="px-3 py-3 border-t border-rose-50 shrink-0">
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
    if (b !== btn) { b.classList.remove('group-open'); b.nextElementSibling.classList.remove('group-open'); }
  });
  if (isOpen) {
    btn.classList.remove('group-open'); btn.nextElementSibling.classList.remove('group-open');
  } else {
    btn.classList.add('group-open'); btn.nextElementSibling.classList.add('group-open');
  }
}
</script>

<script>
(function () {
  'use strict';

  /* ── Page motion ── */
  document.body.classList.add('gd-motion');

  function initPageMotion() {
    var scrim = document.createElement('div');
    scrim.className = 'gd-transition-scrim';
    document.body.appendChild(scrim);

    requestAnimationFrame(function () { document.body.classList.add('gd-page-ready'); });

    window.addEventListener('pageshow', function (e) {
      if (e.persisted) {
        document.body.classList.remove('gd-page-exiting');
        requestAnimationFrame(function () { document.body.classList.add('gd-page-ready'); });
      }
    });

    document.addEventListener('click', function (event) {
      var link = event.target.closest('a[href]');
      if (!link || event.defaultPrevented) return;
      if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0) return;
      if (link.target && link.target !== '_self') return;
      if (link.hasAttribute('download')) return;
      var href = link.getAttribute('href') || '';
      if (!href || href.charAt(0) === '#' || href.indexOf('javascript:') === 0) return;
      var url;
      try { url = new URL(href, window.location.href); } catch (e) { return; }
      if (url.origin !== window.location.origin) return;
      if (url.pathname === window.location.pathname && url.search === window.location.search && url.hash) return;
      if (url.href === window.location.href) return;

      var appPath = '${pageContext.request.contextPath}';
      var pn = url.pathname;
      var isGuardRoute = appPath
        ? (pn.indexOf(appPath + '/guard') === 0 || pn.indexOf(appPath + '/logout') === 0)
        : (pn.indexOf('/guard') === 0 || pn.indexOf('/logout') === 0);
      if (!isGuardRoute) return;

      event.preventDefault();
      link.classList.add('is-navigating');
      document.body.classList.add('gd-page-exiting');
      window.setTimeout(function () { window.location.href = url.href; }, 90);
    });
  }

  /* ── Mobile sidebar ── */
  function initSidebar() {
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    if (!sidebar) return;
    function open()  { sidebar.classList.remove('-translate-x-full'); if (overlay) overlay.classList.remove('hidden'); }
    function close() { sidebar.classList.add('-translate-x-full');    if (overlay) overlay.classList.add('hidden'); }
    document.querySelectorAll('[data-sidebar-toggle], #mobileMenuBtn, #sidebarToggle').forEach(function (btn) {
      btn.addEventListener('click', function () { sidebar.classList.contains('-translate-x-full') ? open() : close(); });
    });
    if (overlay) overlay.addEventListener('click', close);
    window.addEventListener('resize', function () { if (window.innerWidth >= 1024 && overlay) overlay.classList.add('hidden'); });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { initPageMotion(); initSidebar(); });
  } else {
    initPageMotion(); initSidebar();
  }
})();
</script>
