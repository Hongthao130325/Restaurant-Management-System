<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng - Nhà hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .cart-container {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
            margin-top: 30px;
        }
        .cart-items {
            background: white;
            border-radius: 15px;
            padding: 30px;
        }
        .cart-item {
            display: flex;
            gap: 20px;
            padding: 20px;
            border-bottom: 1px solid #f0f0f0;
            align-items: center;
        }
        .cart-item:last-child {
            border-bottom: none;
        }
        .cart-item-image {
            width: 100px;
            height: 100px;
            border-radius: 10px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            flex-shrink: 0;
        }
        .cart-item-info {
            flex: 1;
        }
        .cart-item-name {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .cart-item-price {
            color: #667eea;
            font-weight: 600;
            margin-bottom: 10px;
        }
        .cart-item-note {
            color: #999;
            font-size: 13px;
        }
        .cart-item-actions {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 10px;
        }
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .qty-btn-cart {
            width: 30px;
            height: 30px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
        }
        .qty-btn-cart:hover {
            background: #f5f5f5;
        }
        .cart-item-total {
            font-size: 20px;
            font-weight: bold;
            color: #333;
        }
        .btn-remove {
            color: #ff4757;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 14px;
            text-decoration: underline;
        }
        .cart-summary {
            background: white;
            border-radius: 15px;
            padding: 30px;
            height: fit-content;
            position: sticky;
            top: 100px;
        }
        .summary-title {
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            font-size: 16px;
        }
        .summary-total {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #f0f0f0;
            font-size: 24px;
            font-weight: bold;
        }
        .total-amount {
            color: #667eea;
        }
        .empty-cart {
            text-align: center;
            padding: 80px 20px;
            background: white;
            border-radius: 15px;
        }
        .empty-cart-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        @media (max-width: 768px) {
            .cart-container {
                grid-template-columns: 1fr;
            }
            .cart-item {
                flex-direction: column;
                align-items: flex-start;
            }
            .cart-item-actions {
                width: 100%;
                flex-direction: row;
                justify-content: space-between;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../Common/header.jsp" %>
    
    <div class="container">
        <h1 class="page-title">🛒 Giỏ hàng của bạn</h1>
        
        <c:choose>
            <c:when test="${empty sessionScope.cart}">
                <div class="empty-cart">
                    <div class="empty-cart-icon">🛒</div>
                    <h2>Giỏ hàng trống</h2>
                    <p style="color: #666; margin: 20px 0;">Bạn chưa có món ăn nào trong giỏ hàng</p>
                    <a href="${pageContext.request.contextPath}/menu" class="btn btn-primary" style="display: inline-block; padding: 15px 40px; text-decoration: none;">
                        Xem thực đơn
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="cart-container">
                    <!-- Cart Items -->
                    <div class="cart-items">
                        <h2 style="margin-bottom: 20px;">Món đã chọn</h2>
                        
                        <c:set var="total" value="0"/>
                        <c:forEach var="entry" items="${sessionScope.cart}">
                            <c:set var="cartItem" value="${entry.value}"/>
                            <c:set var="item" value="${cartItem.item}"/>
                            <c:set var="quantity" value="${cartItem.quantity}"/>
                            <c:set var="subtotal" value="${item.price * quantity}"/>
                            <c:set var="total" value="${total + subtotal}"/>
                            
                            <div class="cart-item">
                                <div class="cart-item-image">🍜</div>
                                <div class="cart-item-info">
                                    <div class="cart-item-name">${item.itemName}</div>
                                    <div class="cart-item-price">
                                        <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                    </div>
                                    <c:if test="${not empty cartItem.note}">
                                        <div class="cart-item-note">Ghi chú: ${cartItem.note}</div>
                                    </c:if>
                                </div>
                                <div class="cart-item-actions">
                                    <div class="quantity-control">
                                        <form action="${pageContext.request.contextPath}/cart" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="itemId" value="${item.itemId}">
                                            <input type="hidden" name="quantity" value="${quantity - 1}">
                                            <button type="submit" class="qty-btn-cart" ${quantity <= 1 ? 'disabled' : ''}>-</button>
                                        </form>
                                        
                                        <span style="font-weight: bold; min-width: 30px; text-align: center;">${quantity}</span>
                                        
                                        <form action="${pageContext.request.contextPath}/cart" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="update">
                                            <input type="hidden" name="itemId" value="${item.itemId}">
                                            <input type="hidden" name="quantity" value="${quantity + 1}">
                                            <button type="submit" class="qty-btn-cart">+</button>
                                        </form>
                                    </div>
                                    
                                    <div class="cart-item-total">
                                        <fmt:formatNumber value="${subtotal}" pattern="#,###"/>đ
                                    </div>
                                    
                                    <form action="${pageContext.request.contextPath}/cart" method="post" 
                                          onsubmit="return confirm('Bạn có chắc muốn xóa món này?');">
                                        <input type="hidden" name="action" value="remove">
                                        <input type="hidden" name="itemId" value="${item.itemId}">
                                        <button type="submit" class="btn-remove">Xóa</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <!-- Cart Summary -->
                    <div class="cart-summary">
                        <div class="summary-title">Tóm tắt đơn hàng</div>
                        
                        <div class="summary-row">
                            <span>Tạm tính:</span>
                            <span><fmt:formatNumber value="${total}" pattern="#,###"/>đ</span>
                        </div>
                        
                        <div class="summary-row">
                            <span>Phí giao hàng:</span>
                            <span style="color: #28a745; font-weight: 600;">Miễn phí</span>
                        </div>
                        
                        <div class="summary-total">
                            <span>Tổng cộng:</span>
                            <span class="total-amount">
                                <fmt:formatNumber value="${total}" pattern="#,###"/>đ
                            </span>
                        </div>
                        
                        <a href="${pageContext.request.contextPath}/order?action=checkout" 
                           class="btn btn-primary btn-block" 
                           style="margin-top: 20px; padding: 15px; font-size: 16px; text-decoration: none; display: block; text-align: center;">
                            Tiến hành đặt hàng
                        </a>
                        
                        <a href="${pageContext.request.contextPath}/menu" 
                           class="btn btn-secondary btn-block" 
                           style="margin-top: 10px; padding: 12px; text-decoration: none; display: block; text-align: center;">
                            ← Tiếp tục mua hàng
                        </a>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</body>
</html>