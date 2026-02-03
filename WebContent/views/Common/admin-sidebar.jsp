<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="admin-sidebar">
    <div class="sidebar-header">
        <h2>🍽️ Admin Panel</h2>
    </div>
    
    <nav class="sidebar-nav">

        <!-- Users -->
        <a href="${pageContext.request.contextPath}/admin?action=users"
           class="<c:if test='${param.action eq "users"}'>active</c:if>">
            👥 Quản lý người dùng
        </a>

        <!-- Menu -->
        <a href="${pageContext.request.contextPath}/admin?action=menu"
           class="<c:if test='${param.action eq "menu"}'>active</c:if>">
            🍜 Quản lý menu
        </a>

        <!-- Orders -->
        <a href="${pageContext.request.contextPath}/admin?action=orders"
           class="<c:if test='${param.action eq "orders"}'>active</c:if>">
            📦 Quản lý đơn hàng
        </a>

        <!-- Reports -->
        <a href="${pageContext.request.contextPath}/admin?action=reports"
           class="<c:if test='${param.action eq "reports"}'>active</c:if>">
            📈 Báo cáo thống kê
        </a>
    </nav>
    
    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-danger btn-block">Đăng xuất</a>
    </div>
</div>
