<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực đơn - Nhà hàng</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">

    <style>
        .menu-filters {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 10px 20px;
            border: 2px solid #667eea;
            background: white;
            color: #667eea;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }

        .filter-btn:hover,
        .filter-btn.active {
            background: #667eea;
            color: white;
        }

        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
        }

        .menu-item-card {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .menu-item-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
        }

        .menu-item-image {
            width: 100%;
            height: 220px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 80px;
            position: relative;
        }

        .menu-item-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #ff4757;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }

        .menu-item-info {
            padding: 20px;
        }

        .menu-item-category {
            color: #999;
            font-size: 12px;
            text-transform: uppercase;
            margin-bottom: 5px;
            font-weight: 600;
        }

        .menu-item-name {
            font-size: 20px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }

        .menu-item-desc {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 15px;
            height: 40px;
            overflow: hidden;
        }

        .menu-item-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .menu-item-price {
            font-size: 24px;
            font-weight: bold;
            color: #667eea;
        }

        .add-to-cart-section {
            display: flex;
            gap: 10px;
        }

        .quantity-selector {
            display: flex;
            align-items: center;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
        }

        .qty-btn {
            width: 35px;
            height: 35px;
            border: none;
            background: #f5f5f5;
            cursor: pointer;
            font-size: 18px;
            font-weight: bold;
            transition: background 0.3s;
        }

        .qty-btn:hover {
            background: #e0e0e0;
        }

        .qty-input {
            width: 50px;
            border: none;
            text-align: center;
            font-weight: bold;
            font-size: 16px;
        }

        .btn-add-cart {
            flex: 1;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-add-cart:hover {
            transform: scale(1.05);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        /* Alert ở giữa phía trên */
        .alert.alert-success {
            position: fixed;
            top: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #48bb78;
            color: #fff;
            padding: 12px 22px;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
            font-weight: 600;
            z-index: 9999;
        }
    </style>
</head>

<body>
<%@ include file="../Common/header.jsp" %>

<div class="container">
    <h1 class="page-title">🍽️ Thực đơn của chúng tôi</h1>

    <!-- Category Filters -->
    <div class="menu-filters">
        <button class="filter-btn active" onclick="filterCategory('all')">Tất cả</button>
        <button class="filter-btn" onclick="filterCategory('1')">🍜 Món chính</button>
        <button class="filter-btn" onclick="filterCategory('2')">🥗 Món phụ</button>
        <button class="filter-btn" onclick="filterCategory('3')">🥤 Đồ uống</button>
        <button class="filter-btn" onclick="filterCategory('4')">🍰 Tráng miệng</button>
    </div>

    <!-- Success Message -->
    <c:if test="${param.added eq 'true'}">
        <div class="alert alert-success" style="animation: slideIn 0.5s;">
            ✓ Đã thêm món vào giỏ hàng!
        </div>
    </c:if>

    <!-- Menu Grid -->
    <div class="menu-grid">
        <c:forEach var="item" items="${menuItems}">
            <div class="menu-item-card" data-category="${item.categoryId}">
                <div class="menu-item-image">
                    🍜
                    <c:if test="${item.price < 30000}">
                        <span class="menu-item-badge">Giá tốt</span>
                    </c:if>
                </div>

                <div class="menu-item-info">
                    <div class="menu-item-category">${item.categoryName}</div>
                    <h3 class="menu-item-name">${item.itemName}</h3>
                    <p class="menu-item-desc">${item.description}</p>

                    <div class="menu-item-footer">
                        <div class="menu-item-price">
                            <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}/cart" method="post" class="add-to-cart-form">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="itemId" value="${item.itemId}">

                        <div class="add-to-cart-section">
                            <div class="quantity-selector">
                                <button type="button" class="qty-btn" onclick="decreaseQty(this)">-</button>
                                <input type="number"
                                       name="quantity"
                                       value="1"
                                       min="1"
                                       max="99"
                                       class="qty-input"
                                       readonly>
                                <button type="button" class="qty-btn" onclick="increaseQty(this)">+</button>
                            </div>

                            <button type="submit" class="btn-add-cart">
                                🛒 Thêm vào giỏ
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </c:forEach>
    </div>

    <c:if test="${empty menuItems}">
        <div style="text-align: center; padding: 60px; background: white; border-radius: 15px;">
            <p style="font-size: 18px; color: #666;">Chưa có món ăn nào trong thực đơn</p>
        </div>
    </c:if>
</div>

<script>
    function increaseQty(btn) {
        const input = btn.parentElement.querySelector('.qty-input');
        const currentValue = parseInt(input.value);
        if (currentValue < 99) {
            input.value = currentValue + 1;
        }
    }

    function decreaseQty(btn) {
        const input = btn.parentElement.querySelector('.qty-input');
        const currentValue = parseInt(input.value);
        if (currentValue > 1) {
            input.value = currentValue - 1;
        }
    }

    function filterCategory(categoryId) {
        const cards = document.querySelectorAll('.menu-item-card');
        const buttons = document.querySelectorAll('.filter-btn');

        // Update active button
        buttons.forEach(btn => btn.classList.remove('active'));
        event.target.classList.add('active');

        // Filter cards
        cards.forEach(card => {
            if (categoryId === 'all' || card.dataset.category === categoryId) {
                card.style.display = 'block';
            } else {
                card.style.display = 'none';
            }
        });
    }

    // Auto hide success message
    setTimeout(() => {
        const alert = document.querySelector('.alert-success');
        if (alert) {
            alert.style.animation = 'slideOut 0.5s';
            setTimeout(() => alert.remove(), 500);
        }
    }, 3000);
</script>

<style>
    @keyframes slideIn {
        from {
            transform: translateY(-100%);
            opacity: 0;
        }
        to {
            transform: translateY(0);
            opacity: 1;
        }
    }

    @keyframes slideOut {
        from {
            transform: translateY(0);
            opacity: 1;
        }
        to {
            transform: translateY(-100%);
            opacity: 0;
        }
    }
</style>

</body>
</html>
