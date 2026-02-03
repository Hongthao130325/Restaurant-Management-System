<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán - Nhà hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .checkout-container {
            display: grid;
            grid-template-columns: 1fr 400px;
            gap: 30px;
            margin-top: 30px;
        }
        .checkout-form {
            background: white;
            border-radius: 15px;
            padding: 40px;
        }
        .section-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
        }
        .payment-methods {
            display: grid;
            gap: 15px;
            margin-bottom: 20px;
        }
        .payment-method {
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            padding: 15px;
            cursor: pointer;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .payment-method:hover {
            border-color: #667eea;
            background: #f8f9ff;
        }
        .payment-method input[type="radio"] {
            width: 20px;
            height: 20px;
        }
        .payment-method.selected {
            border-color: #667eea;
            background: #f8f9ff;
        }
        .payment-icon {
            font-size: 30px;
        }
        .payment-info h4 {
            margin: 0 0 5px 0;
            font-size: 16px;
        }
        .payment-info p {
            margin: 0;
            font-size: 13px;
            color: #666;
        }
        .order-summary-checkout {
            background: white;
            border-radius: 15px;
            padding: 30px;
            height: fit-content;
            position: sticky;
            top: 100px;
        }
        .order-item-mini {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .order-item-mini:last-child {
            border-bottom: none;
        }
        @media (max-width: 768px) {
            .checkout-container {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../Common/header.jsp" %>
    
    <div class="container">
        <h1 class="page-title">💳 Thanh toán đơn hàng</h1>
        
        <div class="checkout-container">
            <!-- Checkout Form -->
            <div class="checkout-form">
    <form action="${pageContext.request.contextPath}/order" method="post">
        <input type="hidden" name="action" value="place">

        <!-- Delivery Information -->
        <div class="section-title">📍 Thông tin giao hàng</div>

        <div class="form-group">
            <label>Họ tên *</label>
            <input type="text"
                   value="${sessionScope.user.fullName}"
                   readonly
                   style="background: #f5f5f5;">
        </div>

        <div class="form-group">
            <label>Số điện thoại *</label>
            <input type="text"
                   value="${sessionScope.user.phone}"
                   readonly
                   style="background: #f5f5f5;">
        </div>

        <div class="form-group">
            <label>Địa chỉ giao hàng *</label>

            <!-- 👇 QUAN TRỌNG: name="deliveryAddress" -->
            <input type="text"
                   name="deliveryAddress"
                   placeholder="Nhập địa chỉ giao hàng"
                   value="${param.deliveryAddress != null ? param.deliveryAddress : sessionScope.user.address}"
                   required>

            <small style="color: #999;">
                Bạn có thể cập nhật thông tin trong phần
                <a href="#" style="color: #667eea;">Tài khoản</a>
            </small>

            <!-- Hiện lỗi nếu thiếu địa chỉ -->
            <c:if test="${not empty errorDelivery}">
                <div style="color:#e74c3c;font-size:13px;margin-top:5px;">
                    ${errorDelivery}
                </div>
            </c:if>
        </div>

        <!-- Payment Method -->
        <div class="section-title" style="margin-top: 30px;">💰 Phương thức thanh toán</div>

        <div class="payment-methods">
            <label class="payment-method selected">
                <input type="radio" name="paymentMethod" value="cash" checked>
                <span class="payment-icon">💵</span>
                <div class="payment-info">
                    <h4>Tiền mặt</h4>
                    <p>Thanh toán khi nhận hàng (COD)</p>
                </div>
            </label>

            <label class="payment-method">
                <input type="radio" name="paymentMethod" value="card">
                <span class="payment-icon">💳</span>
                <div class="payment-info">
                    <h4>Thẻ ngân hàng</h4>
                    <p>Visa, Mastercard, JCB</p>
                </div>
            </label>

            <label class="payment-method">
                <input type="radio" name="paymentMethod" value="e-wallet">
                <span class="payment-icon">📱</span>
                <div class="payment-info">
                    <h4>Ví điện tử</h4>
                    <p>MoMo, ZaloPay, VNPay</p>
                </div>
            </label>
        </div>

        <!-- Note -->
        <div class="form-group" style="margin-top: 20px;">
            <label>Ghi chú đơn hàng</label>
            <textarea name="customerNote" rows="4"
                      placeholder="Ví dụ: Giao trước 12h, không gọi chuông...">${param.customerNote}</textarea>
        </div>

        <!-- Submit Button -->
        <button type="submit" class="btn btn-primary btn-block"
                style="margin-top: 30px; padding: 15px; font-size: 18px; font-weight: bold;">
            🛒 Đặt hàng
        </button>
    </form>
</div>

            
            <!-- Order Summary -->
            <div class="order-summary-checkout">
                <div class="section-title">📝 Đơn hàng của bạn</div>
                
                <c:set var="total" value="0"/>
                <c:forEach var="entry" items="${sessionScope.cart}">
                    <c:set var="cartItem" value="${entry.value}"/>
                    <c:set var="item" value="${cartItem.item}"/>
                    <c:set var="quantity" value="${cartItem.quantity}"/>
                    <c:set var="subtotal" value="${item.price * quantity}"/>
                    <c:set var="total" value="${total + subtotal}"/>
                    
                    <div class="order-item-mini">
                        <div>
                            <strong>${item.itemName}</strong>
                            <div style="color: #999; font-size: 13px;">x${quantity}</div>
                        </div>
                        <div style="font-weight: 600;">
                            <fmt:formatNumber value="${subtotal}" pattern="#,###"/>đ
                        </div>
                    </div>
                </c:forEach>
                
                <div style="margin: 20px 0; padding: 20px 0; border-top: 2px solid #f0f0f0; border-bottom: 2px solid #f0f0f0;">
                    <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                        <span>Tạm tính:</span>
                        <span><fmt:formatNumber value="${total}" pattern="#,###"/>đ</span>
                    </div>
                    <div style="display: flex; justify-content: space-between;">
                        <span>Phí giao hàng:</span>
                        <span style="color: #28a745; font-weight: 600;">Miễn phí</span>
                    </div>
                </div>
                
                <div style="display: flex; justify-content: space-between; font-size: 20px; font-weight: bold;">
                    <span>Tổng cộng:</span>
                    <span style="color: #667eea;">
                        <fmt:formatNumber value="${total}" pattern="#,###"/>đ
                    </span>
                </div>
                
                <div style="margin-top: 20px; padding: 15px; background: #f8f9ff; border-radius: 10px; border-left: 4px solid #667eea;">
                    <small style="color: #666;">
                        ✓ Miễn phí giao hàng cho đơn trên 50,000đ<br>
                        ✓ Giao hàng trong vòng 30-45 phút<br>
                        ✓ Hỗ trợ 24/7
                    </small>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Payment method selection
        document.querySelectorAll('.payment-method').forEach(method => {
            method.addEventListener('click', function() {
                document.querySelectorAll('.payment-method').forEach(m => m.classList.remove('selected'));
                this.classList.add('selected');
                this.querySelector('input[type="radio"]').checked = true;
            });
        });
    </script>
</body>
</html>