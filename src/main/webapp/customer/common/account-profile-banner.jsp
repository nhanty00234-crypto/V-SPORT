<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<c:set var="accUser" value="${not empty account ? account : sessionScope.user}"/>
<div class="acc-hero">
    <div class="acc-hero-inner">
        <div class="acc-user-profile">
            <div class="acc-avatar-circle">
                <c:choose>
                    <c:when test="${not empty accUser.fullName}">${fn:escapeXml(fn:substring(accUser.fullName, 0, 1).toUpperCase())}</c:when>
                    <c:otherwise>${fn:escapeXml(fn:substring(not empty accUser.username ? accUser.username : 'V', 0, 1).toUpperCase())}</c:otherwise>
                </c:choose>
            </div>
            <div class="acc-user-info">
                <h1 class="acc-user-name">
                    ${fn:escapeXml(not empty accUser.fullName ? accUser.fullName : accUser.username)}
                    <span class="acc-rep-chip"><i class="fas fa-shield-alt"></i> Uy tín: ${accUser.diemUyTin != null ? accUser.diemUyTin : 80}/100</span>
                </h1>
                <div class="acc-user-meta">
                    <span><i class="fas fa-envelope"></i> ${not empty accUser.email ? fn:escapeXml(accUser.email) : 'Chưa cập nhật email'}</span>
                    <c:if test="${not empty accUser.phoneNumber}">
                        <span><i class="fas fa-phone"></i> ${fn:escapeXml(accUser.phoneNumber)}</span>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="acc-hero-actions">
            <a href="${pageContext.request.contextPath}/customer/ho-so" class="acc-hero-btn acc-btn-glass">
                <i class="fas fa-user-edit"></i> Chỉnh sửa hồ sơ
            </a>
            <a href="${pageContext.request.contextPath}/customer/dat-san" class="acc-hero-btn acc-btn-primary">
                <i class="fas fa-calendar-plus"></i> Đặt sân ngay
            </a>
        </div>
    </div>
</div>
