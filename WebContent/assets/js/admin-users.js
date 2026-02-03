// admin-users.js

const contextPath = document.querySelector('script[src*="admin-users.js"]')
    ?.src.split('/assets')[0] || '';

function openAddUserModal() {
    openModal('addUserModal');
}

function addUser(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    formData.append('action', 'addUser');
    
    fetch(contextPath + '/admin', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(data.message, 'success');
            closeModal('addUserModal');
            setTimeout(() => location.reload(), 1000);
        } else {
            showNotification(data.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Có lỗi xảy ra!', 'error');
    });
    
    return false;
}

function editUser(userId) {
    // Implement edit functionality
    showNotification('Chức năng đang phát triển', 'info');
}

function toggleUserStatus(userId, currentStatus) {
    const newStatus = currentStatus === 'active' ? 'locked' : 'active';
    const message = newStatus === 'locked' ? 'khóa' : 'mở khóa';
    
    if (!confirm(`Bạn có chắc muốn ${message} người dùng này?`)) {
        return;
    }
    
    const formData = new FormData();
    formData.append('action', 'toggleUserStatus');
    formData.append('userId', userId);
    formData.append('status', newStatus);
    
    fetch(contextPath + '/admin', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(data.message, 'success');
            setTimeout(() => location.reload(), 1000);
        } else {
            showNotification(data.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Có lỗi xảy ra!', 'error');
    });
}

function deleteUser(userId) {
    if (!confirm('Bạn có chắc muốn xóa người dùng này? Hành động này không thể hoàn tác!')) {
        return;
    }
    
    const formData = new FormData();
    formData.append('action', 'deleteUser');
    formData.append('userId', userId);
    
    fetch(contextPath + '/admin', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(data.message, 'success');
            setTimeout(() => location.reload(), 1000);
        } else {
            showNotification(data.message, 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        showNotification('Có lỗi xảy ra!', 'error');
    });
}