<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%
    Object roleIdObj = session.getAttribute("roleId");
    Object fullNameObj = session.getAttribute("fullName");
    Object emailObj = session.getAttribute("email");

    int roleId = -1;
    if (roleIdObj instanceof Number) {
        roleId = ((Number) roleIdObj).intValue();
    } else if (roleIdObj instanceof String) {
        try { roleId = Integer.parseInt((String) roleIdObj); } catch (NumberFormatException ignored) {}
    }

    String fullName = fullNameObj != null ? fullNameObj.toString() : "";
    String email = emailObj != null ? emailObj.toString() : "";
    boolean isLoggedIn = roleId != -1 || session.getAttribute("user") != null;
    String displayName = !fullName.trim().isEmpty() ? fullName : (!email.trim().isEmpty() ? email : "Tài khoản");
    String ctxPath = request.getContextPath();
%>
<!-- V-SPORT New Theme Styles -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800;900&family=Montserrat:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link rel="stylesheet" href="<%= ctxPath %>/assets/css/vsport-customer.css">

<!-- Toast Notification Container -->
<div id="toast-container"></div>

<!-- Top Contact Bar -->
<div class="top-bar">
    <div class="container">
        <div class="top-bar-left">
            <span><i class="fa-solid fa-phone"></i> Hỗ trợ: 1900 1234</span>
            <span class="divider">|</span>
            <span><i class="fa-solid fa-envelope"></i> contact@v-sport.vn</span>
        </div>
        <div class="top-bar-right">
            <a href="#">Tải Ứng Dụng</a>
            <span class="divider">|</span>
            <a href="#">Trở thành đối tác</a>
            <span class="divider">|</span>
            <% if (isLoggedIn) { %>
                <a href="<%= ctxPath %>/customer/tai-khoan">Xin chào, <%= fn:escapeXml(displayName) %></a>
                <span class="divider">|</span>
                <a href="<%= ctxPath %>/logout">Đăng xuất</a>
            <% } else { %>
                <a href="<%= ctxPath %>/dangnhap">Đăng nhập</a>
            <% } %>
        </div>
    </div>
</div>

<!-- Main Navbar -->
<header class="navbar">
    <div class="container">
        <div class="logo">
            <a href="<%= ctxPath %>/">
                V<span class="logo-icon"><i class="fa-solid fa-bolt text-red" style="margin: 0 5px;"></i></span>SPORT
            </a>
        </div>
        <nav class="main-menu">
            <ul>
                <li class="<%= request.getRequestURI().endsWith("/index.jsp") || request.getRequestURI().equals(ctxPath + "/") ? "active" : "" %>"><a href="<%= ctxPath %>/">TRANG CHỦ</a></li>
                <li class="<%= request.getRequestURI().contains("/dat-san") ? "active" : "" %>"><a href="<%= ctxPath %>/customer/dat-san">TÌM SÂN</a></li>
                <li class="<%= request.getRequestURI().contains("/ghep-keo") || request.getRequestURI().contains("/doi-nhom") ? "active" : "" %>"><a href="<%= ctxPath %>/customer/ghep-keo">GHÉP TRẬN</a></li>
                <li class="<%= request.getRequestURI().contains("/tai-khoan") || request.getRequestURI().contains("/ho-so") || request.getRequestURI().contains("/lich-su") ? "active" : "" %>"><a href="<%= ctxPath %>/customer/tai-khoan">TÀI KHOẢN</a></li>
                <li><a href="#">BẢNG GIÁ</a></li>
                <li><a href="#">LIÊN HỆ</a></li>
            </ul>
        </nav>
        <div class="nav-actions">
            <a href="<%= ctxPath %>/customer/dat-san" class="action-icon"><i class="fa-solid fa-magnifying-glass"></i></a>
            <a href="<%= ctxPath %>/customer/lich-su-dat-san" class="action-icon cart-icon">
                <i class="fa-solid fa-calendar-check"></i>
            </a>
            <a href="#" class="action-icon menu-icon"><i class="fa-solid fa-bars"></i></a>
        </div>
    </div>
</header>
