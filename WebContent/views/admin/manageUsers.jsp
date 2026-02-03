<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý người dùng - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <div class="admin-layout">
        <%@ include file="../Common/admin-sidebar.jsp" %>
        
        <div class="admin-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
                <h1 class="page-title" style="margin: 0;">Quản lý người dùng</h1>
                <button class="btn btn-primary" onclick="showAddForm()">+ Thêm người dùng</button>
            </div>
            
            <!-- Success/Error Messages -->
            <c:if test="${param.success eq 'add'}">
                <div class="alert alert-success">Thêm người dùng thành công!</div>
            </c:if>
            <c:if test="${param.success eq 'update'}">
                <div class="alert alert-success">Cập nhật người dùng thành công!</div>
            </c:if>
            <c:if test="${param.success eq 'delete'}">
                <div class="alert alert-success">Xóa người dùng thành công!</div>
            </c:if>
            <c:if test="${param.success eq 'status'}">
                <div class="alert alert-success">Cập nhật trạng thái thành công!</div>
            </c:if>
            <c:if test="${param.error ne null}">
                <div class="alert alert-error">${param.error}</div>
            </c:if>
            
            <!-- Add/Edit Form (Hidden by default) -->
            <div id="userForm" style="display: none; background: white; padding: 30px; border-radius: 10px; margin-bottom: 30px;">
                <h3 id="formTitle">Thêm người dùng mới</h3>
                <form action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" id="formAction" value="addUser">
                    <input type="hidden" name="userId" id="userId">
                    
                    <div class="form-group">
                        <label>Tên đăng nhập *</label>
                        <input type="text" name="username" id="username" required>
                    </div>
                    
                    <div class="form-group" id="passwordGroup">
                        <label>Mật khẩu *</label>
                        <input type="password" name="password" id="password">
                    </div>
                    
                    <div class="form-group">
                        <label>Họ tên *</label>
                        <input type="text" name="fullName" id="fullName" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Email *</label>
                        <input type="email" name="email" id="email" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Số điện thoại</label>
                        <input type="tel" name="phone" id="phone">
                    </div>
                    
                    <div class="form-group">
                        <label>Địa chỉ</label>
                        <textarea name="address" id="address" rows="2"></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label>Vai trò *</label>
                        <select name="roleId" id="roleId" required>
                            <option value="1">Admin</option>
                            <option value="2">Nhân viên</option>
                            <option value="3" selected>Khách hàng</option>
                        </select>
                    </div>
                    
                    <div style="display: flex; gap: 10px; margin-top: 20px;">
                        <button type="submit" class="btn btn-primary">Lưu</button>
                        <button type="button" class="btn btn-secondary" onclick="hideForm()">Hủy</button>
                    </div>
                </form>
            </div>
            
            <!-- Users Table -->
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên đăng nhập</th>
                            <th>Họ tên</th>
                            <th>Email</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="user" items="${users}">
                            <tr>
                                <td>${user.userId}</td>
                                <td><strong>${user.username}</strong></td>
                                <td>${user.fullName}</td>
                                <td>${user.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.roleName == 'admin'}">
                                            <span class="badge badge-completed">Admin</span>
                                        </c:when>
                                        <c:when test="${user.roleName == 'employee'}">
                                            <span class="badge badge-confirmed">Nhân viên</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-pending">Khách hàng</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${user.status == 'active'}">
                                            <span class="badge badge-completed">Hoạt động</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-cancelled">Khóa</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <button class="btn btn-primary" style="padding: 5px 10px; font-size: 12px;" 
                                            onclick="editUser(${user.userId}, '${user.username}', '${user.fullName}', '${user.email}', '${user.phone}', '${user.address}', ${user.roleId})">
                                        Sửa
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display: inline;">
                                        <input type="hidden" name="action" value="toggleUserStatus">
                                        <input type="hidden" name="userId" value="${user.userId}">
                                        <input type="hidden" name="status" value="${user.status == 'active' ? 'locked' : 'active'}">
                                        <button type="submit" class="btn btn-warning" style="padding: 5px 10px; font-size: 12px;">
                                            ${user.status == 'active' ? 'Khóa' : 'Mở khóa'}
                                        </button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/admin" method="post" style="display: inline;" 
                                          onsubmit="return confirm('Bạn có chắc muốn xóa người dùng này?');">
                                        <input type="hidden" name="action" value="deleteUser">
                                        <input type="hidden" name="userId" value="${user.userId}">
                                        <button type="submit" class="btn btn-danger" style="padding: 5px 10px; font-size: 12px;">
                                            Xóa
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>
        function showAddForm() {
            document.getElementById('userForm').style.display = 'block';
            document.getElementById('formTitle').textContent = 'Thêm người dùng mới';
            document.getElementById('formAction').value = 'addUser';
            document.getElementById('userId').value = '';
            document.getElementById('username').value = '';
            document.getElementById('username').readOnly = false;
            document.getElementById('password').value = '';
            document.getElementById('password').required = true;
            document.getElementById('passwordGroup').style.display = 'block';
            document.getElementById('fullName').value = '';
            document.getElementById('email').value = '';
            document.getElementById('phone').value = '';
            document.getElementById('address').value = '';
            document.getElementById('roleId').value = '3';
        }
        
        function editUser(userId, username, fullName, email, phone, address, roleId) {
            document.getElementById('userForm').style.display = 'block';
            document.getElementById('formTitle').textContent = 'Sửa thông tin người dùng';
            document.getElementById('formAction').value = 'updateUser';
            document.getElementById('userId').value = userId;
            document.getElementById('username').value = username;
            document.getElementById('username').readOnly = true;
            document.getElementById('password').required = false;
            document.getElementById('passwordGroup').style.display = 'none';
            document.getElementById('fullName').value = fullName;
            document.getElementById('email').value = email;
            document.getElementById('phone').value = phone || '';
            document.getElementById('address').value = address || '';
            document.getElementById('roleId').value = roleId;
            
            // Scroll to form
            document.getElementById('userForm').scrollIntoView({ behavior: 'smooth' });
        }
        
        function hideForm() {
            document.getElementById('userForm').style.display = 'none';
        }
    </script>
</body>
</html>