<%-- header.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<header class="site-header">
    <div class="container">
        <div class="header-content">
            <a href="${pageContext.request.contextPath}/" class="logo">
                <h1>🍽️ BTQ</h1>
            </a>
            
            <nav class="main-nav">
                <c:if test="${sessionScope.user != null}">
                    <c:choose>
                        <c:when test="${sessionScope.user.roleName == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/admin">Dashboard</a>
                            <a href="${pageContext.request.contextPath}/admin?action=users">Người dùng</a>
                            <a href="${pageContext.request.contextPath}/admin?action=menu">Thực đơn</a>
                            <a href="${pageContext.request.contextPath}/admin?action=orders">Đơn hàng</a>
                            <a href="${pageContext.request.contextPath}/admin?action=reports">Báo cáo</a>
                        </c:when>
                        <c:when test="${sessionScope.user.roleName == 'EMPLOYEE'}">
                            <a href="${pageContext.request.contextPath}/employee">Đơn hàng</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/menu">Thực đơn</a>
                            <a href="${pageContext.request.contextPath}/cart?action=view">
                                Giỏ hàng 
<span id="cartCount" class="badge">
    <c:choose>
        <c:when test="${not empty sessionScope.cartSize}">
            ${sessionScope.cartSize}
        </c:when>
        <c:otherwise>0</c:otherwise>
    </c:choose>
</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/order?action=history">Đơn hàng của tôi</a>
                        </c:otherwise>
                    </c:choose>
                    
                    <div class="user-menu">
                        <span>Xin chào, ${sessionScope.user.fullName}</span>
                        <a href="${pageContext.request.contextPath}/logout" class="btn btn-sm btn-danger">Đăng xuất</a>
                    </div>
                </c:if>
                
                <c:if test="${sessionScope.user == null}">
                    <a href="${pageContext.request.contextPath}/views/auth/login.jsp">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/views/auth/register.jsp">Đăng ký</a>
                </c:if>
            </nav>
        </div>
    </div>
</header>