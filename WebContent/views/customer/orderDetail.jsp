<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn hàng #${order.orderId}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .order-detail-container {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
            margin-top: 30px;
        }
        .detail-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
        }
        .status-timeline {
            display: flex;
            justify-content: space-between;
            margin: 30px 0;
            position: relative;
        }
        .status-step {
            text-align: center;
            flex: 1;
            position: relative;
        }
        .status-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-size: 24px;
            position: relative;
            z-index: 2;
        }
        .status-step.active .status-icon {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .status-step.completed .status-icon {
            background: #28a745;
            color: white;
        }
        @media (max-width: 768px) {
            .order-detail-container {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../Common/header.jsp" %>
    
    <div class="container">
        <h1 class="page-title">Chi tiết đơn hàng #${order.orderId}</h1>
        
        <div class="order-detail-container">
            <!-- Order Details -->
            <div class="detail-card">
                <h2 style="margin-bottom: 20px;">📦 Thông tin đơn hàng</h2>
                
                <!-- Status Timeline -->
                <div class="status-timeline">
                    <div class="status-step ${order.orderStatus == 'pending' || order.orderStatus == 'confirmed' || order.orderStatus == 'preparing' || order.orderStatus == 'delivering' || order.orderStatus == 'completed' ? 'completed' : ''}">
                        <div class="status-icon">📝</div>
                        <div style="font-size: 12px;">Đã đặt</div>
                    </div>
                    <div class="status-step ${order.orderStatus == 'confirmed' || order.orderStatus == 'preparing' || order.orderStatus == 'delivering' || order.orderStatus == 'completed' ? 'completed' : order.orderStatus == 'confirmed' ? 'active' : ''}">
                        <div class="status-icon">✓</div>
                        <div style="font-size: 12px;">Xác nhận</div>
                    </div>
                    <div class="status-step ${order.orderStatus == 'preparing' || order.orderStatus == 'delivering' || order.orderStatus == 'completed' ? 'completed' : order.orderStatus == 'preparing' ? 'active' : ''}">
                        <div class="status-icon">👨‍🍳</div>
                        <div style="font-size: 12px;">Chuẩn bị</div>
                    </div>
                    <div class="status-step ${order.orderStatus == 'delivering' || order.orderStatus == 'completed' ? 'completed' : order.orderStatus == 'delivering' ? 'active' : ''}">
                        <div class="status-icon">🚚</div>
                        <div style="font-size: 12px;">Giao hàng</div>
                    </div>
                    <div class="status-step ${order.orderStatus == 'completed' ? 'completed' : ''}">
                        <div class="status-icon">✅</div>
                        <div style="font-size: 12px;">Hoàn thành</div>
                    </div>
                </div>
                
                <h3 style="margin: 30px 0 15px;">Món đã đặt</h3>
                <c:forEach var="detail" items="${order.orderDetails}">
                    <div style="display: flex; justify-content: space-between; padding: 15px 0; border-bottom: 1px solid #f0f0f0;">
                        <div>
                            <strong>${detail.itemName}</strong>
                            <div style="color: #999; font-size: 14px;">
                                <fmt:formatNumber value="${detail.unitPrice}" pattern="#,###"/>đ x ${detail.quantity}
                            </div>
                            <c:if test="${not empty detail.itemNote}">
                                <div style="color: #666; font-size: 13px; margin-top: 5px;">
                                    📝 ${detail.itemNote}
                                </div>
                            </c:if>
                        </div>
                        <div style="font-weight: bold;">
                            <fmt:formatNumber value="${detail.subTotal}" pattern="#,###"/>đ
                        </div>
                    </div>
                </c:forEach>
            </div>
            
            <!-- Order Summary -->
            <div>
                <div class="detail-card">
                    <h3 style="margin-bottom: 20px;">📋 Tóm tắt</h3>
                    <div style="margin-bottom: 10px;">
                        <small style="color: #999;">Trạng thái</small>
                        <div>
                            <span class="badge badge-${order.orderStatus}">
                                <c:choose>
                                    <c:when test="${order.orderStatus == 'pending'}">Chờ xử lý</c:when>
                                    <c:when test="${order.orderStatus == 'confirmed'}">Đã xác nhận</c:when>
                                    <c:when test="${order.orderStatus == 'preparing'}">Đang chuẩn bị</c:when>
                                    <c:when test="${order.orderStatus == 'delivering'}">Đang giao</c:when>
                                    <c:when test="${order.orderStatus == 'completed'}">Hoàn thành</c:when>
                                    <c:otherwise>Đã hủy</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>
                    
                    <div style="margin: 20px 0; padding: 20px 0; border-top: 1px solid #f0f0f0; border-bottom: 1px solid #f0f0f0;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                            <span>Tạm tính:</span>
                            <span><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>đ</span>
                        </div>
                        <div style="display: flex; justify-content: space-between;">
                            <span>Phí giao hàng:</span>
                            <span style="color: #28a745;">Miễn phí</span>
                        </div>
                    </div>
                    
                    <div style="display: flex; justify-content: space-between; font-size: 20px; font-weight: bold;">
                        <span>Tổng cộng:</span>
                        <span style="color: #667eea;">
                            <fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>đ
                        </span>
                    </div>
                </div>
                
                <div class="detail-card" style="margin-top: 20px;">
    <h3 style="margin-bottom: 15px;">📍 Thông tin nhận hàng</h3>
    <p><strong>${order.customerName}</strong></p>
    <p>📞 ${order.customerPhone}</p>
    <p>🏠 Địa chỉ tài khoản: ${order.customerAddress}</p>

    <c:if test="${not empty order.deliveryAddress}">
        <p>🚚 Địa chỉ giao hàng: ${order.deliveryAddress}</p>
    </c:if>
    
    <c:if test="${not empty order.customerNote}">
        <div style="margin-top: 15px; padding: 15px; background: #f8f9ff; border-radius: 10px;">
            <small style="color: #999;">Ghi chú:</small>
            <p style="margin: 5px 0 0; color: #666;">${order.customerNote}</p>
        </div>
    </c:if>
</div>

                
                <a href="${pageContext.request.contextPath}/order?action=history" 
                   class="btn btn-secondary btn-block" 
                   style="margin-top: 20px; text-decoration: none; display: block; text-align: center; padding: 12px;">
                   ← Quay lại lịch sử
                </a>
            </div>
        </div>
    </div>
</body>
</html>