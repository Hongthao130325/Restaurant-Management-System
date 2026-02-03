<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý đơn hàng - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        .filter-buttons{display:flex;gap:10px;margin-bottom:20px}
        .filter-btn{padding:10px 20px;border:2px solid #3498db;background:#fff;color:#3498db;border-radius:5px;cursor:pointer}
        .filter-btn.active{background:#3498db;color:#fff}
        .quick-actions{display:flex;gap:6px}
    </style>
</head>

<body>
<div class="admin-layout">
    <%@ include file="../Common/admin-sidebar.jsp" %>

    <div class="admin-content">
        <h1>📋 Quản lý đơn hàng</h1>

        <!-- FILTER -->
        <div class="filter-buttons">
            <%-- <button class="filter-btn ${empty statusFilter ? 'active' : ''}"
                    onclick="filterOrders('')">📋 Tất cả</button> --%>
            <button class="filter-btn active" data-status="all">Tất cả</button>
            <button class="filter-btn ${statusFilter=='pending'?'active':''}"
                    onclick="filterOrders('pending')">⏳ Chờ xử lý</button>
            <button class="filter-btn ${statusFilter=='confirmed'?'active':''}"
                    onclick="filterOrders('confirmed')">✅ Đã xác nhận</button>
            <button class="filter-btn ${statusFilter=='preparing'?'active':''}"
                    onclick="filterOrders('preparing')">👨‍🍳 Đang chuẩn bị</button>
            <button class="filter-btn ${statusFilter=='delivering'?'active':''}"
                    onclick="filterOrders('delivering')">🚚 Đang giao</button>
            <button class="filter-btn ${statusFilter=='completed'?'active':''}"
                    onclick="filterOrders('completed')">✔️ Hoàn thành</button>
            <button class="filter-btn ${statusFilter=='cancelled'?'active':''}"
                    onclick="filterOrders('cancelled')">❌ Đã hủy</button>
        </div>

        <!-- TABLE -->
        <div class="table-container">
            <table class="data-table">
                <thead>
                <tr>
                    <th width="80">Mã ĐH</th>
                    <th width="160">Khách hàng</th>
                    <th width="150">Thời gian</th>
                    <th width="130">Tổng tiền</th>
                    <th width="150">Trạng thái</th>
                    <th width="200">Hành động</th>
                </tr>
                </thead>
                <tbody>

                <fmt:setLocale value="vi_VN"/>

                <c:forEach var="order" items="${orders}">
                    <tr>
                        <td align="center"><strong>#${order.orderId}</strong></td>

                        <td>
                            <strong>${order.customerName}</strong><br>
                            <small>${order.customerPhone}</small>
                        </td>

                        <td>
                            <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </td>

                        <td>
                            <strong style="color:#e74c3c">
                                <fmt:formatNumber value="${order.totalAmount}" groupingUsed="true"/> đ
                            </strong>
                        </td>

                        <td align="center">
                            <c:choose>
                            	<c:when test="${order.orderStatus=='null'}">
                                    <span class="badge" style="background:#f39c12">Tất cả</span>
                                </c:when>
                                <c:when test="${order.orderStatus=='pending'}">
                                    <span class="badge" style="background:#f39c12">⏳ Chờ xử lý</span>
                                </c:when>
                                <c:when test="${order.orderStatus=='confirmed'}">
                                    <span class="badge" style="background:#3498db">✅ Đã xác nhận</span>
                                </c:when>
                                <c:when test="${order.orderStatus=='preparing'}">
                                    <span class="badge" style="background:#9b59b6">👨‍🍳 Đang chuẩn bị</span>
                                </c:when>
                                <c:when test="${order.orderStatus=='delivering'}">
                                    <span class="badge" style="background:#16a085">🚚 Đang giao</span>
                                </c:when>
                                <c:when test="${order.orderStatus=='completed'}">
                                    <span class="badge badge-success">✔️ Hoàn thành</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-danger">❌ Đã hủy</span>
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <div class="quick-actions">
                                <button class="btn btn-sm btn-info"
                                        onclick="viewOrder(${order.orderId})">👁️</button>

                                <c:if test="${order.orderStatus!='completed' && order.orderStatus!='cancelled'}">
                                    <button class="btn btn-sm btn-warning"
                                            onclick="openStatus(${order.orderId})">✏️</button>
                                </c:if>
                            </div>
                        </td>
                    </tr>
                </c:forEach>

                <c:if test="${empty orders}">
                    <tr>
                        <td colspan="6" align="center" style="padding:30px">
                            📭 Không có đơn hàng
                        </td>
                    </tr>
                </c:if>

                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
const contextPath = '${pageContext.request.contextPath}';

function filterOrders(status){
	
    location.href = contextPath + '/admin?action=orders'
        + (status ? '&status=' + status : '');
}

function viewOrder(id){
    location.href = contextPath + '/admin?action=orderDetail&id=' + id;
}

function openStatus(id){
    const status = prompt("Nhập trạng thái mới (pending, confirmed, preparing, delivering, completed, cancelled)");
    if(!status) return;

    const params = new URLSearchParams();
    params.append("action","updateOrderStatus");
    params.append("orderId",id);
    params.append("status",status);

    fetch(contextPath + "/admin",{
        method:"POST",
        headers:{"Content-Type":"application/x-www-form-urlencoded"},
        body:params.toString()
    })
    .then(r=>r.json())
    .then(d=>{
        if(d.success) location.reload();
        else alert(d.message);
    });
}
</script>

</body>
</html>
