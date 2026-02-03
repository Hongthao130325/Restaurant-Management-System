<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Menu - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <style>
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 20px;
        }
        .menu-card {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .menu-card-image {
            width: 100%;
            height: 200px;
            background: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
        }
        .menu-card-body {
            padding: 20px;
        }
        .menu-card-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .menu-card-category {
            color: #999;
            font-size: 12px;
            margin-bottom: 10px;
        }
        .menu-card-desc {
            color: #666;
            font-size: 14px;
            margin-bottom: 15px;
        }
        .menu-card-price {
            font-size: 20px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 15px;
        }
        .menu-card-actions {
            display: flex;
            gap: 10px;
        }
        .menu-card-actions button,
        .menu-card-actions form {
            flex: 1;
        }
    </style>
</head>
<body>
    <div class="admin-layout">
        <%@ include file="../Common/admin-sidebar.jsp" %>
        
        <div class="admin-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
                <h1 class="page-title" style="margin: 0;">Quản lý Menu</h1>
                <button class="btn btn-primary" onclick="showAddForm()">+ Thêm món mới</button>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${param.success eq 'add'}">
                <div class="alert alert-success">Thêm món ăn thành công!</div>
            </c:if>
            <c:if test="${param.success eq 'update'}">
                <div class="alert alert-success">Cập nhật món ăn thành công!</div>
            </c:if>
            <c:if test="${param.success eq 'delete'}">
                <div class="alert alert-success">Xóa món ăn thành công!</div>
            </c:if>
            <c:if test="${param.error ne null}">
                <div class="alert alert-error">${param.error}</div>
            </c:if>
            
            <!-- Add/Edit Form (Hidden by default) -->
            <div id="menuForm" style="display: none; background: white; padding: 30px; border-radius: 10px; margin-bottom: 30px;">
                <h3 id="formTitle">Thêm món ăn mới</h3>
                <form action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" id="formAction" value="addMenuItem">
                    <input type="hidden" name="itemId" id="itemId">
                    
                    <div class="form-group">
                        <label>Tên món *</label>
                        <input type="text" name="itemName" id="itemName" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Danh mục *</label>
                        <select name="categoryId" id="categoryId" required>
                            <option value="1">Món chính</option>
                            <option value="2">Món phụ</option>
                            <option value="3">Đồ uống</option>
                            <option value="4">Tráng miệng</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Mô tả</label>
                        <textarea name="description" id="description" rows="3"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Giá *</label>
                        <input type="number" name="price" id="price" step="1000" min="0" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Tên file ảnh</label>
                        <input type="text" name="imageUrl" id="imageUrl" placeholder="vd: pho-bo.jpg">
                    </div>
                    
                    <div class="form-group">
                        <label>Trạng thái</label>
                        <select name="status" id="status">
                            <option value="available">Có sẵn</option>
                            <option value="unavailable">Hết hàng</option>
                        </select>
                    </div>
                    
                    <div style="display: flex; gap: 10px; margin-top: 20px;">
                        <button type="submit" class="btn btn-primary">Lưu</button>
                        <button type="button" class="btn btn-secondary" onclick="hideForm()">Hủy</button>
                    </div>
                </form>
            </div>
            
            <!-- Menu Grid -->
            <div class="menu-grid">
                <c:forEach var="item" items="${menuItems}">
                    <div class="menu-card">
                        <div class="menu-card-image">
                            🍜
                        </div>
                        <div class="menu-card-body">
                            <div class="menu-card-title">${item.itemName}</div>
                            <div class="menu-card-category">${item.categoryName}</div>
                            <div class="menu-card-desc">${item.description}</div>
                            <div class="menu-card-price">
                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                            </div>
                            <div style="margin-bottom: 15px;">
                                <span class="badge ${item.status == 'available' ? 'badge-completed' : 'badge-cancelled'}">
                                    ${item.status == 'available' ? 'Có sẵn' : 'Hết hàng'}
                                </span>
                            </div>
                            <div class="menu-card-actions">
                                <button class="btn btn-primary" style="padding: 8px; font-size: 12px;"
                                        onclick="editItem(${item.itemId}, '${item.itemName}', ${item.categoryId}, '${item.description}', ${item.price}, '${item.imageUrl}', '${item.status}')">
                                    Sửa
                                </button>
                                <form action="${pageContext.request.contextPath}/admin" method="post" 
                                      onsubmit="return confirm('Bạn có chắc muốn xóa món này?');">
                                    <input type="hidden" name="action" value="deleteMenuItem">
                                    <input type="hidden" name="itemId" value="${item.itemId}">
                                    <button type="submit" class="btn btn-danger" style="padding: 8px; font-size: 12px; width: 100%;">
                                        Xóa
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
    
    <script>
        function showAddForm() {
            document.getElementById('menuForm').style.display = 'block';
            document.getElementById('formTitle').textContent = 'Thêm món ăn mới';
            document.getElementById('formAction').value = 'addMenuItem';
            document.getElementById('itemId').value = '';
            document.getElementById('itemName').value = '';
            document.getElementById('categoryId').value = '1';
            document.getElementById('description').value = '';
            document.getElementById('price').value = '';
            document.getElementById('imageUrl').value = '';
            document.getElementById('status').value = 'available';
            
            // Scroll to top
            window.scrollTo({ top: 0, behavior: 'smooth' });
        }
        
        function editItem(itemId, itemName, categoryId, description, price, imageUrl, status) {
            document.getElementById('menuForm').style.display = 'block';
            document.getElementById('formTitle').textContent = 'Sửa món ăn';
            document.getElementById('formAction').value = 'updateMenuItem';
            document.getElementById('itemId').value = itemId;
            document.getElementById('itemName').value = itemName;
            document.getElementById('categoryId').value = categoryId;
            document.getElementById('description').value = description || '';
            document.getElementById('price').value = price;
            document.getElementById('imageUrl').value = imageUrl || '';
            document.getElementById('status').value = status;
            
            // Scroll to form
            document.getElementById('menuForm').scrollIntoView({ behavior: 'smooth' });
        }
        
        function hideForm() {
            document.getElementById('menuForm').style.display = 'none';
        }
    </script>
</body>
</html>