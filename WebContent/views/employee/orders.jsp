<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý đơn hàng - Nhân viên</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        .employee-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px}
        .stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:15px;margin-bottom:20px}
        .stat-box{background:#fff;padding:20px;border-radius:8px;text-align:center;box-shadow:0 2px 5px rgba(0,0,0,.1)}
        .stat-number{font-size:2rem;font-weight:bold;color:#3498db}
        .stat-label{color:#7f8c8d;margin-top:5px}
        .filter-buttons{display:flex;gap:10px;margin-bottom:20px}
        .filter-btn{padding:10px 20px;border:2px solid #3498db;background:#fff;color:#3498db;border-radius:5px;cursor:pointer}
        .filter-btn.active{background:#3498db;color:#fff}
        .quick-actions{display:flex;gap:6px;flex-wrap:wrap}
    </style>
</head>

<body>
<jsp:include page="../Common/header.jsp"/>

<div class="container" style="margin-top:20px">

    <!-- HEADER -->
    <div class="employee-header">
        <h1>📋 Quản lý đơn hàng</h1>
        <button class="btn btn-primary" onclick="location.reload()">🔄 Làm mới</button>
    </div>

    

    <!-- FILTER -->
    <div class="filter-buttons">
        <button class="filter-btn ${empty currentStatus ? 'active' : ''}"
                onclick="filterOrders('')">📋 Tất cả</button>

        <button class="filter-btn ${currentStatus == 'pending' ? 'active' : ''}"
                onclick="filterOrders('pending')">⏳ Chờ xử lý</button>

        <button class="filter-btn ${currentStatus == 'confirmed' ? 'active' : ''}"
                onclick="filterOrders('confirmed')">✅ Đã xác nhận</button>

        <button class="filter-btn ${currentStatus == 'preparing' ? 'active' : ''}"
                onclick="filterOrders('preparing')">👨‍🍳 Đang chuẩn bị</button>

        <button class="filter-btn ${currentStatus == 'delivering' ? 'active' : ''}"
                onclick="filterOrders('delivering')">🚚 Đang giao</button>
    </div>

    <!-- TABLE -->
    <div style="background:#fff;padding:20px;border-radius:8px;box-shadow:0 2px 8px rgba(0,0,0,.1)">
        <table class="data-table">
            <thead>
            <tr>
                <th width="80">Mã ĐH</th>
                <th width="150">Khách hàng</th>
                <th width="150">Thời gian</th>
                <th width="130">Tổng tiền</th>
                <th width="150">Trạng thái</th>
                <th width="260">Hành động</th>
            </tr>
            </thead>
            <tbody>

            <fmt:setLocale value="vi_VN"/>

            <c:forEach var="order" items="${orders}">
    <tr>
        <td align="center"><strong>#${order.orderId}</strong></td>

        <td>${order.customerName}</td>

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
                <c:when test="${order.orderStatus == 'pending'}">
                    <span class="badge" style="background:#f39c12">⏳ Chờ xử lý</span>
                </c:when>
                <c:when test="${order.orderStatus == 'confirmed'}">
                    <span class="badge" style="background:#3498db">✅ Đã xác nhận</span>
                </c:when>
                <c:when test="${order.orderStatus == 'preparing'}">
                    <span class="badge" style="background:#9b59b6">👨‍🍳 Đang chuẩn bị</span>
                </c:when>
                <c:when test="${order.orderStatus == 'delivering'}">
                    <span class="badge" style="background:#16a085">🚚 Đang giao</span>
                </c:when>
                <c:when test="${order.orderStatus == 'completed'}">
                    <span class="badge badge-success">✔️ Hoàn thành</span>
                </c:when>
                <c:otherwise>
                    <span class="badge badge-danger">❌ Đã hủy</span>
                </c:otherwise>
            </c:choose>
        </td>

        <td>
  <c:choose>

    <c:when test="${order.orderStatus == 'pending'}">
      <div class="quick-actions">
        <button class="btn btn-sm btn-info" onclick="viewOrder(${order.orderId})">👁️</button>
        <button class="btn btn-sm btn-success" onclick="confirmOrder(${order.orderId})">✅</button>
      </div>
    </c:when>

    <c:when test="${order.orderStatus == 'confirmed'}">
      <div class="quick-actions">
        <button class="btn btn-sm btn-info" onclick="viewOrder(${order.orderId})">👁️</button>
        <button class="btn btn-sm btn-primary" onclick="startPreparing(${order.orderId})">👨‍🍳</button>
      </div>
    </c:when>

    <c:when test="${order.orderStatus == 'preparing'}">
      <div class="quick-actions">
        <button class="btn btn-sm btn-info" onclick="viewOrder(${order.orderId})">👁️</button>
        <button class="btn btn-sm btn-primary" onclick="startDelivering(${order.orderId})">🚚</button>
      </div>
    </c:when>

    <c:when test="${order.orderStatus == 'delivering'}">
      <div class="quick-actions">
        <button class="btn btn-sm btn-info" onclick="viewOrder(${order.orderId})">👁️</button>
        <button class="btn btn-sm btn-success" onclick="completeOrder(${order.orderId})">✔️</button>
      </div>
    </c:when>

    <c:otherwise>
      <!-- completed hoặc cancelled => để trống đúng yêu cầu -->
      &nbsp;
    </c:otherwise>

  </c:choose>
</td>

    </tr>
</c:forEach>


            <c:if test="${empty orders}">
                <tr>
                    <td colspan="6" align="center" style="padding:30px">📭 Không có đơn hàng</td>
                </tr>
            </c:if>

            </tbody>
        </table>
    </div>
</div>

<jsp:include page="../Common/footer.jsp"/>

<script>
    const contextPath = '${pageContext.request.contextPath}';

    function filterOrders(status){
        location.href = status
            ? contextPath + '/employee?status=' + status
            : contextPath + '/employee';
    }
    
function viewOrder(id){
    location.href = contextPath + '/employee?action=detail&id=' + id;
}


   function updateStatus(id, status){
    const params = new URLSearchParams();
    params.append("action", "updateStatus");
    params.append("orderId", id);
    params.append("status", status);

    fetch(contextPath + "/employee", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        },
        body: params.toString()
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) location.reload();
        else alert(data.message || "Lỗi cập nhật trạng thái");
    })
    .catch(err => {
        console.error(err);
        alert("Server không trả JSON (mở Console để xem).");
    });
}

function confirmOrder(id){ updateStatus(id, "confirmed"); }
function startPreparing(id){ updateStatus(id, "preparing"); }
function startDelivering(id){ updateStatus(id, "delivering"); }
function completeOrder(id){ updateStatus(id, "completed"); }

</script>

</body>
</html>
