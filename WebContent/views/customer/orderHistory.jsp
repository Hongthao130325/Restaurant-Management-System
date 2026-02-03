<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử đơn hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .order-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            transition: all 0.3s;
        }
        .order-card:hover {
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
            margin-bottom: 15px;
        }
        .order-id-badge {
            font-size: 18px;
            font-weight: bold;
            color: #667eea;
        }
        .order-info-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 15px;
        }
        .info-item label {
            display: block;
            font-size: 12px;
            color: #999;
            margin-bottom: 5px;
        }
        .info-item value {
            font-weight: 600;
            color: #333;
        }
        @media (max-width: 768px) {
            .order-info-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../Common/header.jsp" %>
    
    <div class="container">
        <h1 class="page-title">📜 Lịch sử đơn hàng</h1>
        
        <c:choose>
            <c:when test="${empty orders}">
                <div style="text-align: center; padding: 80px 20px; background: white; border-radius: 15px;">
                    <div style="font-size: 80px; margin-bottom: 20px;">📦</div>
                    <h2>Chưa có đơn hàng nào</h2>
                    <p style="color: #666; margin: 20px 0;">Hãy đặt món ngay để trải nghiệm dịch vụ của chúng tôi!</p>
                    <a href="${pageContext.request.contextPath}/menu" class="btn btn-primary" 
                       style="display: inline-block; padding: 15px 40px; text-decoration: none;">
                        Xem thực đơn
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="order" items="${orders}">
                    <div class="order-card">
                        <div class="order-header">
                            <span class="order-id-badge">Đơn hàng #${order.orderId}</span>
                            <span class="badge badge-${order.orderStatus}">
                                <c:choose>
                                    <c:when test="${order.orderStatus == 'pending'}">⏳ Chờ xử lý</c:when>
                                    <c:when test="${order.orderStatus == 'confirmed'}">✓ Đã xác nhận</c:when>
                                    <c:when test="${order.orderStatus == 'preparing'}">👨‍🍳 Đang chuẩn bị</c:when>
                                    <c:when test="${order.orderStatus == 'delivering'}">🚚 Đang giao</c:when>
                                    <c:when test="${order.orderStatus == 'completed'}">✅ Hoàn thành</c:when>
                                    <c:otherwise>❌ Đã hủy</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        
                        <div class="order-info-grid">
                            <div class="info-item">
                                <label>Ngày đặt</label>
                                <value><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></value>
                            </div>
                            <div class="info-item">
                                <label>Tổng tiền</label>
                                <value style="color: #667eea; font-size: 18px;">
                                    <fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>đ
                                </value>
                            </div>
                            <div class="info-item">
                                <label>Thanh toán</label>
                                <value>
                                    <c:choose>
                                        <c:when test="${order.paymentMethod == 'cash'}">💵 Tiền mặt</c:when>
                                        <c:when test="${order.paymentMethod == 'card'}">💳 Thẻ</c:when>
                                        <c:otherwise>📱 Ví điện tử</c:otherwise>
                                    </c:choose>
                                </value>
                            </div>
                        </div>
                        
                        <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 15px; padding-top: 15px; border-top: 1px solid #f0f0f0;">
                            <a href="${pageContext.request.contextPath}/order?action=detail&id=${order.orderId}" 
                               class="btn btn-primary" style="text-decoration: none; padding: 10px 20px;">
                                Xem chi tiết
                            </a>
                            <c:if test="${order.orderStatus == 'pending'}">
    <button type="button"
        class="btn btn-danger"
        style="padding: 10px 20px;"
        data-order-id="${order.orderId}"
        onclick="openCancelModal(this)">
    Hủy đơn
</button>
</c:if>
                            <c:if test="${order.orderStatus == 'completed'}">
                                <button class="btn btn-success" style="padding: 10px 20px;">
                                    Đặt lại
                                </button>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
    
    
    <!-- ===== Cancel Modal ===== -->
<div id="cancelModal"
     style="display:none; position:fixed; inset:0; background:rgba(0,0,0,.45); z-index:9999;">
  <div style="background:#fff; width:420px; max-width:92vw; margin:10% auto; padding:20px; border-radius:12px;">
    <h3 style="margin:0 0 10px;">Hủy đơn hàng</h3>

    <input type="hidden" id="cancelOrderId">

    <label style="display:block; margin:8px 0 6px;">Lý do hủy</label>
    <textarea id="cancelReason" style="width:100%; height:90px; padding:10px;"
              placeholder="Nhập lý do hủy đơn..."></textarea>

    <div style="margin-top:12px; display:flex; gap:10px; justify-content:flex-end;">
      <button type="button" onclick="closeCancelModal()">Đóng</button>
      <button type="button" class="btn btn-danger" onclick="submitCancel()">Xác nhận hủy</button>
    </div>
  </div>
</div>
    
     <!-- ===== Cancel Order Script ===== -->
    <script>
     function openCancelModal(btn) {
    const orderId = btn.getAttribute("data-order-id");
    document.getElementById("cancelOrderId").value = orderId;
    document.getElementById("cancelReason").value = "";
    document.getElementById("cancelModal").style.display = "block";
  }

      function closeCancelModal() {
        document.getElementById("cancelModal").style.display = "none";
      }

      async function submitCancel() {
        const orderId = document.getElementById("cancelOrderId").value;
        const reason = document.getElementById("cancelReason").value.trim();

        if (!reason) {
          alert("Vui lòng nhập lý do hủy đơn.");
          return;
        }

        const form = new URLSearchParams();
        form.append("action", "cancel");
        form.append("orderId", orderId);
        form.append("reason", reason);

        const res = await fetch("${pageContext.request.contextPath}/order", {
          method: "POST",
          headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
          body: form.toString()
        });

        const data = await res.json();
        if (data.success) {
          alert("Đã hủy đơn thành công.");
          location.reload();
        } else {
          alert(data.message || "Không thể hủy đơn.");
        }
      }
    </script>
    
</body>
</html>
