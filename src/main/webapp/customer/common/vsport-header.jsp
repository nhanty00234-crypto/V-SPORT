<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    boolean isLoggedIn = session.getAttribute("user") != null;
    org.example.model.TaiKhoan user = isLoggedIn ? (org.example.model.TaiKhoan) session.getAttribute("user") : null;
    String displayName = "Tài khoản";
    String rolePath = "/";
    int headerUnreadCount = 0;
    if (isLoggedIn) {
        displayName = (user.getFullName() != null && !user.getFullName().trim().isEmpty()) ? user.getFullName() : "Khách hàng";
        rolePath = org.example.util.RoleRedirectUtil.getHomePathByRoleId(user.getRoleId());
        if (user.getRoleId() == org.example.util.RoleRedirectUtil.ROLE_CUSTOMER) {
            try {
                org.example.service.NotificationService _nsSvc = new org.example.service.NotificationService();
                headerUnreadCount = _nsSvc.countUnread(user.getAccountId());
            } catch (Exception _e) {
                // không để lỗi notification làm gãy header
            }
        }
    }
    String ctxPath = request.getContextPath();
%>
<!-- V-SPORT New Theme Styles -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&family=Montserrat:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="<%= ctxPath %>/assets/css/vsport-customer.css?v=2">

<!-- Toast Notification Container -->
<div id="toast-container"></div>

<style>
    :root {
        --primary-blue: #2563eb;
    }
    
    .new-header {
        background-color: #ffffff;
        padding: 12px 0;
        position: sticky;
        top: 0;
        z-index: 1000;
        box-shadow: 0 1px 10px rgba(0,0,0,0.05);
        font-family: 'Poppins', sans-serif;
    }

    .new-header .container {
        max-width: 1440px;
        width: 100%;
        margin: 0 auto;
        padding: 0 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .new-header .logo a {
        display: flex;
        align-items: center;
        gap: 10px;
        text-decoration: none;
        color: #111;
    }

    .new-header .logo-icon {
        background-color: var(--primary-blue);
        color: white;
        width: 32px;
        height: 32px;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 16px;
    }

    .new-header .logo-text {
        font-size: 20px;
        font-weight: 700;
    }

    .new-header .main-menu ul {
        display: flex;
        gap: 24px;
        list-style: none;
        margin: 0;
        padding: 0;
    }

    .new-header .main-menu a {
        color: #4b5563;
        text-decoration: none;
        font-weight: 500;
        font-size: 14px;
        text-transform: none !important;
        transition: color 0.2s;
    }

    .new-header .main-menu a:hover {
        color: var(--primary-blue);
    }
    
    .new-header .header-left {
        display: flex;
        align-items: center;
        gap: 40px;
    }

    .new-header .nav-actions {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .new-header .location {
        display: flex;
        align-items: center;
        gap: 6px;
        color: #4b5563;
        font-size: 14px;
        font-weight: 500;
    }

    .new-header .location i {
        color: var(--primary-blue);
    }

    .new-header .action-icon {
        color: #4b5563;
        font-size: 18px;
        text-decoration: none;
        transition: color 0.2s;
        display: flex;
        align-items: center;
    }

    .new-header .action-icon:hover {
        color: var(--primary-blue);
    }

    .new-header .notification-icon {
        position: relative;
        color: #4b5563;
        font-size: 18px;
        cursor: pointer;
        transition: color 0.2s;
        display: flex;
        align-items: center;
    }

    .new-header .notification-icon:hover {
        color: var(--primary-blue);
    }

    .new-header .notification-dot {
        position: absolute;
        top: -4px;
        right: -6px;
        z-index: 10;
        min-width: 18px;
        height: 18px;
        padding: 0 4px;
        background-color: #ef4444;
        color: #fff;
        border-radius: 9px;
        font-size: 11px;
        font-weight: 700;
        line-height: 18px;
        text-align: center;
        border: 2px solid #fff;
        display: none;
    }

    /* Notification dropdown */
    #vsNotifWrap { position: relative; }
    #vsNotifWrap .notification-icon { background: none; border: none; padding: 0; }
    #vsNotifDropdown {
        position: absolute;
        top: calc(100% + 10px);
        right: -10px;
        width: 360px;
        max-width: min(360px, calc(100vw - 24px));
        max-height: calc(100vh - 100px);
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 8px 30px rgba(0,0,0,0.15);
        z-index: 2000;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    #vsNotifDropdown.hidden, #vsNotifDropdown[hidden] { display: none !important; }
    .vsnd-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 14px 16px 10px;
        border-bottom: 1px solid #f3f4f6;
        flex-shrink: 0;
        background: #fff;
    }
    .vsnd-header h4 { margin: 0; font-size: 15px; font-weight: 600; color: #111; }
    .vsnd-read-all {
        font-size: 12px; color: #2563eb; cursor: pointer; font-weight: 500;
        background: none; border: none; padding: 0;
    }
    .vsnd-read-all:hover { text-decoration: underline; }
    #vsNotifList { max-height: 380px; overflow-y: auto; flex: 1; list-style: none; margin: 0; padding: 0; }
    .vsnd-item {
        display: flex; gap: 10px; padding: 12px 16px;
        border-bottom: 1px solid #f9fafb; cursor: pointer;
        text-decoration: none; color: inherit;
    }
    .vsnd-item:hover { background: #f9fafb; }
    .vsnd-item.unread { background: #eff6ff; }
    .vsnd-item.unread:hover { background: #dbeafe; }
    .vsnd-icon {
        width: 38px; height: 38px; border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
        font-size: 16px; flex-shrink: 0;
    }
    .vsnd-icon.dat-san { background: #dcfce7; color: #16a34a; }
    .vsnd-icon.thanh-toan { background: #fef9c3; color: #ca8a04; }
    .vsnd-icon.hoan-tien { background: #fee2e2; color: #dc2626; }
    .vsnd-icon.default { background: #f3f4f6; color: #6b7280; }
    .vsnd-body { flex: 1; min-width: 0; }
    .vsnd-title {
        font-size: 13px; font-weight: 600; color: #111;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
        margin-bottom: 2px;
    }
    .vsnd-text { font-size: 12px; color: #6b7280; line-height: 1.4;
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
    .vsnd-time { font-size: 11px; color: #9ca3af; margin-top: 3px; }
    .vsnd-empty { padding: 30px 16px; text-align: center; color: #9ca3af; font-size: 13px; }
    .vsnd-footer {
        text-align: center; padding: 10px;
        border-top: 1px solid #f3f4f6;
        flex-shrink: 0;
        background: #fafafa;
    }
    .vsnd-footer a {
        font-size: 13px; color: #2563eb; font-weight: 500; text-decoration: none;
    }
    .vsnd-footer a:hover { text-decoration: underline; }

    .new-header .user-profile {
        display: flex;
        align-items: center;
        gap: 8px;
        cursor: pointer;
        text-decoration: none;
    }

    .new-header .user-profile img {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        object-fit: cover;
    }

    .new-header .user-profile span {
        font-weight: 600;
        font-size: 14px;
        color: #111827;
    }

    .new-header .btn-primary {
        background-color: var(--primary-blue);
        color: white;
        padding: 8px 16px;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 500;
        font-size: 14px;
        border: none;
        transition: background-color 0.2s;
    }

    .new-header .btn-primary:hover {
        background-color: #1d4ed8;
        color: white;
    }
</style>

<!-- Main Navbar -->
<header class="new-header">
    <div class="container">
        <div class="header-left">
            <div class="logo">
                <a href="<%= ctxPath %>/">
                    <div class="logo-icon">S</div>
                    <span class="logo-text">Sânzy</span>
                </a>
            </div>
            
            <nav class="main-menu">
                <ul>
                    <li><a href="<%= ctxPath %>/">Khám phá</a></li>
                    <li><a href="<%= ctxPath %>/customer/tim-kiem">Tìm sân</a></li>
                    <li><a href="<%= ctxPath %>/customer/ghep-keo">Gắn bạn</a></li>
                    <li><a href="#">Cộng đồng</a></li>
                    <li><a href="#">Ưu đãi</a></li>
                </ul>
            </nav>
        </div>
        
        <div class="nav-actions">
            <div class="location">
                <i class="fa-solid fa-location-dot"></i> Hà Nội
            </div>
            
            <a href="#" class="action-icon"><i class="fa-regular fa-heart"></i></a>
            
            <% if (isLoggedIn && user.getRoleId() == org.example.util.RoleRedirectUtil.ROLE_CUSTOMER) { %>
            <div id="vsNotifWrap" style="position:relative;overflow:visible;">
                <button class="notification-icon" id="vsNotifBtn" aria-label="Thông báo" aria-expanded="false" style="overflow:visible;">
                    <i class="fa-regular fa-bell"></i>
                </button>
                <span class="notification-dot" id="vsNotifBadge"></span>
                <div id="vsNotifDropdown" class="hidden">
                    <div class="vsnd-header">
                        <h4>Thông báo</h4>
                        <button class="vsnd-read-all" id="vsNotifReadAll">Đọc tất cả</button>
                    </div>
                    <ul id="vsNotifList"><li class="vsnd-empty">Đang tải...</li></ul>
                    <div class="vsnd-footer">
                        <a href="<%= ctxPath %>/customer/thong-bao">Xem tất cả thông báo</a>
                    </div>
                </div>
            </div>
            <% } else { %>
            <div class="notification-icon">
                <i class="fa-regular fa-bell"></i>
            </div>
            <% } %>
            
            <% if (isLoggedIn) { %>
                <a href="<%= ctxPath %><%= rolePath %>" class="user-profile">
                    <img src="<%= ctxPath %>/assets/images/default-avatar.png" alt="Avatar" onerror="this.src='https://ui-avatars.com/api/?name=<%= displayName %>&background=random'">
                    <span><%= displayName %></span>
                    <i class="fa-solid fa-chevron-down" style="font-size: 10px; color: #6b7280;"></i>
                </a>
            <% } else { %>
                <div class="user-profile" onclick="toggleAuthDropdown('login')">
                    <img src="https://ui-avatars.com/api/?name=Hiền&background=f3f4f6&color=333" alt="Avatar">
                    <span>Hiền</span>
                    <i class="fa-solid fa-chevron-down" style="font-size: 10px; color: #6b7280;"></i>
                </div>
                <div class="auth-dropdown-wrapper" id="authDropdownWrapper" style="display:none;">
                    <jsp:include page="/auth/AuthDropdown.jsp" />
                </div>
            <% } %>
            
            <a href="<%= ctxPath %>/customer/dat-san" class="btn-primary">Đặt sân</a>
        </div>
    </div>
</header>
<% if (isLoggedIn && user.getRoleId() == org.example.util.RoleRedirectUtil.ROLE_CUSTOMER) { %>
<script>
(function() {
    var ctx = '<%= ctxPath %>';
    var btn = document.getElementById('vsNotifBtn');
    var dropdown = document.getElementById('vsNotifDropdown');
    var badge = document.getElementById('vsNotifBadge');
    var list = document.getElementById('vsNotifList');
    var readAllBtn = document.getElementById('vsNotifReadAll');
    if (!btn) return;

    var isOpen = false;
    var cached = null;

    function loaiIcon(loai) {
        if (!loai) return '<i class="fa-solid fa-bell"></i>';
        loai = loai.toUpperCase();
        if (loai.indexOf('DAT_SAN') !== -1 || loai.indexOf('BOOKING') !== -1 || loai.indexOf('GIU_CHO') !== -1)
            return '<i class="fa-solid fa-calendar-check"></i>';
        if (loai.indexOf('THANH_TOAN') !== -1 || loai.indexOf('PAYMENT') !== -1)
            return '<i class="fa-solid fa-receipt"></i>';
        if (loai.indexOf('HOAN_TIEN') !== -1 || loai.indexOf('REFUND') !== -1)
            return '<i class="fa-solid fa-rotate-left"></i>';
        return '<i class="fa-solid fa-bell"></i>';
    }
    function loaiClass(loai) {
        if (!loai) return 'default';
        loai = loai.toUpperCase();
        if (loai.indexOf('DAT_SAN') !== -1 || loai.indexOf('BOOKING') !== -1 || loai.indexOf('GIU_CHO') !== -1) return 'dat-san';
        if (loai.indexOf('THANH_TOAN') !== -1 || loai.indexOf('PAYMENT') !== -1) return 'thanh-toan';
        if (loai.indexOf('HOAN_TIEN') !== -1 || loai.indexOf('REFUND') !== -1) return 'hoan-tien';
        return 'default';
    }
    function relTime(ms) {
        if (!ms) return '';
        var diff = Math.floor((Date.now() - ms) / 1000);
        if (diff < 60) return 'Vừa xong';
        if (diff < 3600) return Math.floor(diff / 60) + ' phút trước';
        if (diff < 86400) return Math.floor(diff / 3600) + ' giờ trước';
        return Math.floor(diff / 86400) + ' ngày trước';
    }

    function updateBadge(count) {
        if (count > 0) {
            badge.textContent = count > 99 ? '99+' : count;
            badge.style.display = 'block';
        } else {
            badge.style.display = 'none';
        }
    }

    function renderList(data) {
        list.innerHTML = '';
        if (!data || !data.items || data.items.length === 0) {
            list.innerHTML = '<li class="vsnd-empty">Chưa có thông báo nào</li>';
            return;
        }
        data.items.forEach(function(n) {
            var li = document.createElement('li');
            li.className = 'vsnd-item' + (!n.daDoc ? ' unread' : '');
            var href = n.duongDan ? (ctx + n.duongDan) : (ctx + '/customer/thong-bao');
            li.innerHTML =
                '<a href="' + href + '" class="vsnd-item' + (!n.daDoc ? ' unread' : '') + '" style="display:flex;gap:10px;text-decoration:none;color:inherit;width:100%;">'
                + '<div class="vsnd-icon ' + loaiClass(n.loai) + '">' + loaiIcon(n.loai) + '</div>'
                + '<div class="vsnd-body">'
                + '<div class="vsnd-title">' + (n.tieuDe || '') + '</div>'
                + '<div class="vsnd-text">' + (n.noiDung || '') + '</div>'
                + '<div class="vsnd-time">' + relTime(n.thoiGian) + '</div>'
                + '</div></a>';
            // đánh dấu đã đọc khi click
            li.querySelector('a').addEventListener('click', function() {
                markRead(n.id);
            });
            list.appendChild(li);
        });
    }

    function fetchNotifs() {
        fetch(ctx + '/customer/thong-bao?format=json&limit=8', { credentials: 'same-origin' })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                cached = data;
                updateBadge(data.unread);
                if (isOpen) renderList(data);
            })
            .catch(function() {});
    }

    function openDropdown() {
        isOpen = true;
        dropdown.classList.remove('hidden');
        btn.setAttribute('aria-expanded', 'true');
        if (cached) renderList(cached);
        else list.innerHTML = '<li class="vsnd-empty">Đang tải...</li>';
        fetchNotifs();
    }
    function closeDropdown() {
        isOpen = false;
        dropdown.classList.add('hidden');
        btn.setAttribute('aria-expanded', 'false');
    }

    function markRead(id) {
        var fd = new FormData();
        fd.append('action', 'markRead');
        fd.append('id', id);
        fetch(ctx + '/customer/thong-bao', { method: 'POST', body: fd, credentials: 'same-origin', redirect: 'manual' })
            .then(function() { fetchNotifs(); })
            .catch(function() {});
    }

    btn.addEventListener('click', function(e) {
        e.stopPropagation();
        if (isOpen) closeDropdown(); else openDropdown();
    });
    document.addEventListener('click', function(e) {
        var wrap = document.getElementById('vsNotifWrap');
        if (isOpen && wrap && !wrap.contains(e.target)) closeDropdown();
    });
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isOpen) closeDropdown();
    });

    if (readAllBtn) {
        readAllBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            var fd = new FormData();
            fd.append('action', 'markAllRead');
            fetch(ctx + '/customer/thong-bao', { method: 'POST', body: fd, credentials: 'same-origin', redirect: 'manual' })
                .then(function() { fetchNotifs(); })
                .catch(function() {});
        });
    }

    // Fetch ngay khi load + poll mỗi 30s
    fetchNotifs();
    setInterval(fetchNotifs, 30000);
})();
</script>
<% } %>
