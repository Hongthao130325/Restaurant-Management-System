// admin-orders.js - Quản lý đơn hàng

console.log("=== admin-orders.js loaded ===");

// Lấy context path
function getContextPath() {
    const path = window.location.pathname;
    const parts = path.split('/');
    return '/' + parts[1];
}

const CONTEXT = getContextPath();

// Xem chi tiết đơn hàng
function viewOrderDetail(orderId) {
    console.log("Viewing order:", orderId);
    
    const url = CONTEXT + '/admin?action=getOrderDetail&orderId=' + orderId;
    
    fetch(url)
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                displayOrderDetail(data.order);
            } else {
                alert('Không thể tải thông tin đơn hàng!');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Có lỗi xảy ra: ' + error.message);
        });
}

// Hiển thị chi tiết đơn hàng
function displayOrderDetail(order) {
    document.getElementById('detailOrderId').textContent = order.orderId;
    document.getElementById('detailCustomer').textContent = order.customerName;
    document.getElementById('detailDate').textContent = formatDate(order.orderDate);
    document.getElementById('detailPayment').textContent = formatPaymentMethod(order.paymentMethod);
    document.getElementById('detailStatus').innerHTML = formatStatus(order.status);
    document.getElementById('detailAddress').textContent = order.deliveryAddress || 'Không có';
    document.getElementById('detailNote').textContent = order.note || 'Không có ghi chú';
    document.getElementById('detailTotal').textContent = formatCurrency(order.totalAmount);
    
    // Hiển thị danh sách món
    const itemsHtml = order.orderDetails.map(item => `
        <tr>
            <td>${item.itemName}</td>
            <td>${item.quantity}</td>
            <td>${formatCurrency(item.unitPrice)}</td>
            <td><strong>${formatCurrency(item.quantity * item.unitPrice)}</strong></td>
            <td>${item.note || '-'}</td>
        </tr>
    `).join('');
    
    document.getElementById('detailItems').innerHTML = itemsHtml;
    
    // Hiển thị các nút cập nhật trạng thái
    displayStatusActions(order.orderId, order.status);
    
    // Mở modal
    document.getElementById('orderDetailModal').style.display = 'block';
}

// Hiển thị các nút cập nhật trạng thái
function displayStatusActions(orderId, currentStatus) {
    const actionsDiv = document.getElementById('statusActions');
    
    if (currentStatus === 'completed' || currentStatus === 'cancelled') {
        actionsDiv.innerHTML = '<p style="color: #7f8c8d;">Đơn hàng đã hoàn tất, không thể thay đổi trạng thái.</p>';
        return;
    }
    
    const statusFlow = {
        'pending': { next: 'confirmed', label: '✅ Xác nhận đơn', color: '#27ae60' },
        'confirmed': { next: 'preparing', label: '👨‍🍳 Bắt đầu chuẩn bị', color: '#9b59b6' },
        'preparing': { next: 'delivering', label: '🚚 Bắt đầu giao hàng', color: '#3498db' },
        'delivering': { next: 'completed', label: '✔️ Hoàn thành', color: '#27ae60' }
    };
    
    const action = statusFlow[currentStatus];
    
    if (action) {
        actionsDiv.innerHTML = `
            <button class="btn btn-primary" style="background-color: ${action.color};" 
                    onclick="quickUpdateStatus(${orderId}, '${action.next}')">
                ${action.label}
            </button>
            <button class="btn btn-warning" onclick="updateOrderStatus(${orderId})">
                🔄 Chọn trạng thái khác
            </button>
            <button class="btn btn-danger" onclick="quickUpdateStatus(${orderId}, 'cancelled')">
                ❌ Hủy đơn
            </button>
        `;
    } else {
        actionsDiv.innerHTML = `
            <button class="btn btn-warning" onclick="updateOrderStatus(${orderId})">
                🔄 Cập nhật trạng thái
            </button>
        `;
    }
}

// Cập nhật trạng thái nhanh
function quickUpdateStatus(orderId, newStatus) {
    const confirmMsg = newStatus === 'cancelled' 
        ? 'Bạn có chắc muốn HỦY đơn hàng này?' 
        : 'Xác nhận thay đổi trạng thái đơn hàng?';
    
    if (!confirm(confirmMsg)) return;
    
    performStatusUpdate(orderId, newStatus);
}

// Mở modal cập nhật trạng thái
function updateOrderStatus(orderId) {
    document.getElementById('updateOrderId').textContent = orderId;
    document.getElementById('orderIdToUpdate').value = orderId;
    document.getElementById('orderDetailModal').style.display = 'none';
    document.getElementById('updateStatusModal').style.display = 'block';
}

// Thực hiện cập nhật trạng thái
function performStatusUpdate(orderId, newStatus) {
    const url = CONTEXT + '/admin';
    const data = `action=updateOrderStatus&orderId=${orderId}&status=${newStatus}`;
    
    console.log('Updating order:', orderId, 'to status:', newStatus);
    
    fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: data
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            alert('✅ ' + result.message);
            location.reload();
        } else {
            alert('❌ ' + result.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Có lỗi xảy ra: ' + error.message);
    });
}

// Đóng modal chi tiết
function closeOrderDetail() {
    document.getElementById('orderDetailModal').style.display = 'none';
}

// Đóng modal cập nhật
function closeUpdateStatus() {
    document.getElementById('updateStatusModal').style.display = 'none';
}

// Xử lý form cập nhật trạng thái
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('updateStatusForm');
    if (form) {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const orderId = document.getElementById('orderIdToUpdate').value;
            const newStatus = document.getElementById('newStatus').value;
            
            performStatusUpdate(orderId, newStatus);
        });
    }
});

// Helper functions
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
}

function formatPaymentMethod(method) {
    const methods = {
        'cash': '💵 Tiền mặt',
        'momo': '📱 MoMo',
        'banking': '🏦 Chuyển khoản'
    };
    return methods[method] || method;
}

function formatStatus(status) {
    const statuses = {
        'pending': '<span class="badge" style="background-color: #f39c12;">⏳ Chờ xử lý</span>',
        'confirmed': '<span class="badge" style="background-color: #3498db;">✅ Đã xác nhận</span>',
        'preparing': '<span class="badge" style="background-color: #9b59b6;">👨‍🍳 Đang chuẩn bị</span>',
        'delivering': '<span class="badge" style="background-color: #3498db;">🚚 Đang giao</span>',
        'completed': '<span class="badge badge-success">✔️ Hoàn thành</span>',
        'cancelled': '<span class="badge badge-danger">❌ Đã hủy</span>'
    };
    return statuses[status] || status;
}

console.log("=== admin-orders.js ready ===");