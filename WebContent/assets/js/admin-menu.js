const scriptTag = document.querySelector('script[src*="admin-menu.js"]');
const contextPath = scriptTag ? scriptTag.src.split('/assets')[0] : '';


function openAddMenuItemModal() {
    openModal('addMenuItemModal');
}

function addMenuItem(event) {
    event.preventDefault();
    
    const form = event.target;
    const formData = new FormData(form);
    formData.append('action', 'addMenuItem');
    
    fetch(contextPath + '/admin', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showNotification(data.message, 'success');
            closeModal('addMenuItemModal');
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

function editMenuItem(itemId) {
    showNotification('Chức năng đang phát triển', 'info');
}

function deleteMenuItem(itemId) {
    if (!confirm('Bạn có chắc muốn xóa món ăn này?')) {
        return;
    }
    
    const formData = new FormData();
    formData.append('action', 'deleteMenuItem');
    formData.append('itemId', itemId);
    
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
