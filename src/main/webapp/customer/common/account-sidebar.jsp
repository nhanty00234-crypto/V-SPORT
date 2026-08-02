<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<aside class="acc-sidebar">
    <div class="acc-nav-card">
        <a href="${ctx}/customer/tai-khoan" class="acc-nav-item ${activePage eq 'overview' ? 'active' : ''}">
            <i class="fas fa-chart-pie"></i> Tổng quan tài khoản
        </a>
        <a href="${ctx}/customer/doi-nhom" class="acc-nav-item ${activePage eq 'teams' ? 'active' : ''}">
            <i class="fas fa-users"></i> Nhóm của tôi
        </a>
        <a href="${ctx}/customer/ho-so" class="acc-nav-item ${activePage eq 'profile' ? 'active' : ''}">
            <i class="fas fa-user-cog"></i> Cập nhật hồ sơ
        </a>
        <a href="${ctx}/customer/lich-su-diem-uy-tin" class="acc-nav-item ${activePage eq 'reputation' ? 'active' : ''}">
            <i class="fas fa-star"></i> Điểm uy tín
        </a>
        <a href="${ctx}/customer/doi-mat-khau" class="acc-nav-item ${activePage eq 'password' ? 'active' : ''}">
            <i class="fas fa-lock"></i> Đổi mật khẩu
        </a>
        <a href="${ctx}/logout" class="acc-nav-item danger">
            <i class="fas fa-sign-out-alt"></i> Đăng xuất
        </a>
    </div>
</aside>
