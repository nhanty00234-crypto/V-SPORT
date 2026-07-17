<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    V-SPORT customer bottom navigation. Visible at all viewport widths.
    5 items: Trang chu, Ban do, Ghep tran (raised center, white/green outline —
    only styled solid-active when the current route is /customer/ghep-keo),
    Noi bat, Tai khoan.
    Requires customer/common/vsport-theme.jsp for styling.

    Route /customer/noi-bat is built in Phase 4. Until then it shows a
    "Sap ra mat" toast instead of a 404.
    TODO(P4): point Noi bat at /customer/noi-bat.
--%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<nav class="vs-bottomnav" aria-label="Điều hướng chính">
    <a class="vs-bn-item" data-nav="home" href="${ctx}/index.jsp" aria-label="Trang chủ" title="Trang chủ">
        <span class="material-symbols-outlined vs-bn-ic" aria-hidden="true">home</span>
        <span>Trang chủ</span>
    </a>
    <a class="vs-bn-item" data-nav="map" href="${ctx}/customer/ban-do" aria-label="Bản đồ" title="Bản đồ">
        <span class="material-symbols-outlined vs-bn-ic" aria-hidden="true">map</span>
        <span>Bản đồ</span>
    </a>
    <a class="vs-bn-item vs-bn-center" data-nav="match" href="${ctx}/customer/ghep-keo" aria-label="Ghép trận" title="Ghép trận">
        <span class="vs-bn-fab"><span class="material-symbols-outlined vs-bn-ic" aria-hidden="true">sports_tennis</span></span>
        <span class="vs-bn-fablabel">Ghép trận</span>
    </a>
    <button type="button" class="vs-bn-item" data-nav="featured" data-soon="Nổi bật" aria-label="Nổi bật (sắp ra mắt)" title="Nổi bật (sắp ra mắt)">
        <span class="material-symbols-outlined vs-bn-ic" aria-hidden="true">local_fire_department</span>
        <span>Nổi bật</span>
    </button>
    <a class="vs-bn-item" data-nav="account" href="${ctx}/customer/tai-khoan" aria-label="Tài khoản" title="Tài khoản">
        <span class="material-symbols-outlined vs-bn-ic" aria-hidden="true">person</span>
        <span>Tài khoản</span>
    </a>
</nav>

<div id="vsToast" role="status" aria-live="polite" style="position:fixed;left:50%;bottom:calc(var(--vs-bottomnav-h) + 18px);transform:translateX(-50%) translateY(12px);z-index:1300;background:var(--vs-ink);color:#fff;padding:10px 16px;border-radius:9999px;font-size:13px;font-weight:600;opacity:0;visibility:hidden;transition:opacity .2s ease,transform .2s ease;box-shadow:0 6px 18px rgba(15,23,42,.25);"></div>

<script>
(function () {
    // Active state from current path.
    var path = window.location.pathname;
    var key = 'home';
    if (path.indexOf('/customer/ghep-keo') > -1 || path.indexOf('/customer/ghep-tran') > -1) key = 'match';
    else if (path.indexOf('/customer/ban-do') > -1) key = 'map';
    else if (path.indexOf('/customer/noi-bat') > -1) key = 'featured';
    else if (path.indexOf('/customer/tai-khoan') > -1) key = 'account';
    else if (path.indexOf('/index.jsp') > -1 || path === '/' || path.endsWith('/')) key = 'home';
    var active = document.querySelector('.vs-bottomnav [data-nav="' + key + '"]');
    if (active) {
        active.classList.add('is-active');
        active.setAttribute('aria-current', 'page');
    }

    // "Coming soon" toast for not-yet-built destinations.
    var toast = document.getElementById('vsToast');
    var toastTimer = null;
    function showToast(msg) {
        if (!toast) return;
        toast.textContent = msg;
        toast.style.opacity = '1';
        toast.style.visibility = 'visible';
        toast.style.transform = 'translateX(-50%) translateY(0)';
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () {
            toast.style.opacity = '0';
            toast.style.transform = 'translateX(-50%) translateY(12px)';
            setTimeout(function () { toast.style.visibility = 'hidden'; }, 220);
        }, 2000);
    }
    document.querySelectorAll('.vs-bottomnav [data-soon]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            showToast(btn.getAttribute('data-soon') + ' sắp ra mắt');
        });
    });
})();
</script>
