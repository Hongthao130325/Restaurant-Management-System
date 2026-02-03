<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt hàng thành công</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .success-container {
            max-width: 600px;
            margin: 80px auto;
            text-align: center;
            background: white;
            padding: 60px 40px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        }
        .success-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 50px;
            margin: 0 auto 30px;
            animation: scaleIn 0.5s ease-out;
        }
        @keyframes scaleIn {
            from { transform: scale(0); }
            to { transform: scale(1); }
        }
        .success-title {
            font-size: 32px;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
        }
        .order-id {
            font-size: 20px;
            color: #667eea;
            font-weight: bold;
            margin: 20px 0;
            padding: 15px;
            background: #f8f9ff;
            border-radius: 10px;
        }
        .success-actions {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>
    <%@ include file="../Common/header.jsp" %>
    
    <div class="container">
        <div class="success-container">
            <div class="success-icon">✓</div>
            <h1 class="success-title">Đặt hàng thành công!</h1>
            <p style="color: #666; font-size: 16px; line-height: 1.6;">
                Cảm ơn bạn đã đặt hàng. Đơn hàng của bạn đã được ghi nhận và đang được xử lý.
            </p>
            <div class="order-id">
                Mã đơn hàng: #${orderId}
            </div>
            <p style="color: #666; margin-top: 20px;">
                Chúng tôi sẽ gọi điện xác nhận và giao hàng trong thời gian sớm nhất.
            </p>
            <div class="success-actions">
                <a href="${pageContext.request.contextPath}/order?action=detail&id=${orderId}" 
                   class="btn btn-primary" style="text-decoration: none; padding: 15px 30px;">
                    Xem chi tiết đơn hàng
                </a>
                <a href="${pageContext.request.contextPath}/menu" 
                   class="btn btn-secondary" style="text-decoration: none; padding: 15px 30px;">
                    Tiếp tục mua hàng
                </a>
            </div>
        </div>
    </div>
</body>
</html>
