<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo Thống kê - Admin</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <style>
        .filter-section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .filter-row {
            display: flex;
            gap: 20px;
            align-items: flex-end;
            flex-wrap: wrap;
        }
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        .filter-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        .filter-group select,
        .filter-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .filter-buttons {
            display: flex;
            gap: 10px;
        }
        .report-section {
            background: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .report-title {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 20px;
            color: #333;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            color: white;
            padding: 25px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .stat-value {
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            background: #f8f9fa;
            border-radius: 10px;
            color: #666;
        }
        .date-range-info {
            background: #e3f2fd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border-left: 4px solid #2196f3;
        }
    </style>
</head>
<body>
    <div class="admin-layout">
        <%@ include file="../Common/admin-sidebar.jsp" %>
        
        <div class="admin-content">
            <h1 class="page-title">Báo cáo Thống kê</h1>
            
            <!-- Filter Section -->
            <div class="filter-section">
                <h3 style="margin-bottom: 20px; color: #333;">📅 Lọc dữ liệu</h3>
                <form id="filterForm" method="get" action="${pageContext.request.contextPath}/admin">
                    <input type="hidden" name="action" value="reports">
                    
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="filterType">Loại lọc</label>
                            <select id="filterType" name="filterType" onchange="toggleFilterType()">
                                <option value="year" ${empty dateRangeMode ? 'selected' : ''}>Theo năm</option>
                                <option value="dateRange" ${dateRangeMode ? 'selected' : ''}>Khoảng thời gian</option>
                            </select>
                        </div>
                        
                        <!-- Năm -->
                        <div class="filter-group" id="yearFilter" style="${dateRangeMode ? 'display: none;' : ''}">
                            <label for="year">Chọn năm</label>
                            <select id="year" name="year">
                                <c:forEach var="y" items="${availableYears}">
                                    <option value="${y}" ${selectedYear == y ? 'selected' : ''}>Năm ${y}</option>
                                </c:forEach>
                            </select>
                        </div>
                        
                        <!-- Khoảng thời gian -->
                        <div class="filter-group" id="dateRangeFilter" style="${dateRangeMode ? '' : 'display: none;'}">
                            <label for="startDate">Từ ngày</label>
                            <input type="date" id="startDate" name="startDate" 
                                   value="${startDate}" required>
                        </div>
                        
                        <div class="filter-group" id="endDateFilter" style="${dateRangeMode ? '' : 'display: none;'}">
                            <label for="endDate">Đến ngày</label>
                            <input type="date" id="endDate" name="endDate" 
                                   value="${endDate}" required>
                        </div>
                        
                        <div class="filter-buttons">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-search"></i> Xem báo cáo
                            </button>
                            <button type="button" class="btn btn-secondary" onclick="resetFilter()">
                                <i class="fas fa-redo"></i> Reset
                            </button>
                        </div>
                    </div>
                </form>
            </div>
            
            <!-- Date Range Info -->
            <c:if test="${dateRangeMode}">
                <div class="date-range-info">
                    <strong><i class="fas fa-calendar-alt"></i> Khoảng thời gian:</strong>
                    Từ <strong>${startDate}</strong> đến <strong>${endDate}</strong>
                </div>
            </c:if>
            
            <!-- Summary Stats -->
            <div class="stats-grid">
                <div class="stat-card" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <div class="stat-value">
                        <c:set var="totalRevenue" value="0"/>
                        <c:forEach var="month" items="${monthlyRevenue}">
                            <c:set var="totalRevenue" value="${totalRevenue + month.revenue}"/>
                        </c:forEach>
                        <fmt:formatNumber value="${totalRevenue}" pattern="#,###"/>đ
                    </div>
                    <div class="stat-label">
                        <c:choose>
                            <c:when test="${dateRangeMode}">Tổng doanh thu</c:when>
                            <c:otherwise>Tổng doanh thu năm ${selectedYear}</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="stat-card" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                    <div class="stat-value">
                        <c:set var="totalOrders" value="0"/>
                        <c:forEach var="month" items="${monthlyRevenue}">
                            <c:set var="totalOrders" value="${totalOrders + month.orderCount}"/>
                        </c:forEach>
                        ${totalOrders}
                    </div>
                    <div class="stat-label">
                        <c:choose>
                            <c:when test="${dateRangeMode}">Tổng đơn hàng</c:when>
                            <c:otherwise>Tổng đơn hàng năm ${selectedYear}</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div class="stat-card" style="background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);">
                    <div class="stat-value">
                        <c:choose>
                            <c:when test="${totalOrders > 0}">
                                <fmt:formatNumber value="${totalRevenue / totalOrders}" pattern="#,###"/>đ
                            </c:when>
                            <c:otherwise>0đ</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="stat-label">Giá trị đơn hàng trung bình</div>
                </div>
            </div>
            
            <!-- Monthly Revenue Chart -->
            <div class="report-section">
                <div class="report-title">
                    📊 
                    <c:choose>
                        <c:when test="${dateRangeMode}">Doanh thu theo ngày</c:when>
                        <c:otherwise>Doanh thu theo tháng (Năm ${selectedYear})</c:otherwise>
                    </c:choose>
                </div>
                
                <c:choose>
                    <c:when test="${empty monthlyRevenue}">
                        <div class="no-data">
                            <i class="fas fa-chart-line" style="font-size: 48px; color: #ccc; margin-bottom: 20px;"></i>
                            <p style="font-size: 18px; color: #666;">Không có dữ liệu doanh thu</p>
                            <p style="color: #999;">Hãy chọn khoảng thời gian khác hoặc đảm bảo đã có đơn hàng hoàn thành</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <c:choose>
                                            <c:when test="${dateRangeMode}">
                                                <th>Ngày</th>
                                            </c:when>
                                            <c:otherwise>
                                                <th>Tháng</th>
                                            </c:otherwise>
                                        </c:choose>
                                        <th>Số đơn hàng</th>
                                        <th>Doanh thu</th>
                                        <th>Doanh thu trung bình/đơn</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="data" items="${monthlyRevenue}">
                                        <tr>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${dateRangeMode}">
                                                        <fmt:formatDate value="${data.date}" pattern="dd/MM/yyyy"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <strong>Tháng ${data.month}</strong>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${data.orderCount} đơn</td>
                                            <td>
                                                <strong style="color: #667eea;">
                                                    <fmt:formatNumber value="${data.revenue}" pattern="#,###"/>đ
                                                </strong>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${data.orderCount > 0}">
                                                        <fmt:formatNumber value="${data.revenue / data.orderCount}" pattern="#,###"/>đ
                                                    </c:when>
                                                    <c:otherwise>0đ</c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr style="background: #f8f9fa; font-weight: bold;">
                                        <td>TỔNG</td>
                                        <td>${totalOrders} đơn</td>
                                        <td style="color: #667eea;">
                                            <fmt:formatNumber value="${totalRevenue}" pattern="#,###"/>đ
                                        </td>
                                        <td>-</td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        
                        <!-- Simple Bar Chart -->
                        <div style="margin-top: 30px;">
                            <h4 style="margin-bottom: 20px;">Biểu đồ doanh thu</h4>
                            <c:forEach var="data" items="${monthlyRevenue}">
                                <div style="margin-bottom: 15px;">
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                                        <span>
                                            <c:choose>
                                                <c:when test="${dateRangeMode}">
                                                    <fmt:formatDate value="${data.date}" pattern="dd/MM"/>
                                                </c:when>
                                                <c:otherwise>
                                                    <strong>Tháng ${data.month}</strong>
                                                </c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span>
                                            <fmt:formatNumber value="${data.revenue}" pattern="#,###"/>đ
                                            <small style="color: #666; margin-left: 10px;">(${data.orderCount} đơn)</small>
                                        </span>
                                    </div>
                                    <div style="background: #e0e0e0; height: 30px; border-radius: 5px; overflow: hidden;">
                                        <div style="background: linear-gradient(90deg, #667eea 0%, #764ba2 100%); 
                                                    height: 100%; 
                                                    width: ${data.revenue / totalRevenue * 100}%;
                                                    display: flex;
                                                    align-items: center;
                                                    padding: 0 10px;
                                                    color: white;
                                                    font-weight: bold;
                                                    font-size: 12px;">
                                            ${data.orderCount} đơn
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
         
            
            <!-- Export Button -->
            <div style="text-align: center; margin-top: 30px;">
                <button class="btn btn-success" onclick="exportReport()">
                    <i class="fas fa-file-export"></i> Xuất báo cáo PDF
                </button>
                <button class="btn btn-info" onclick="printReport()" style="margin-left: 10px;">
                    <i class="fas fa-print"></i> In báo cáo
                </button>
            </div>
        </div>
    </div>
    
    <script src="${pageContext.request.contextPath}/assets/js/script.js"></script>
    <script>
        function toggleFilterType() {
            const filterType = document.getElementById('filterType').value;
            const yearFilter = document.getElementById('yearFilter');
            const dateRangeFilter = document.getElementById('dateRangeFilter');
            const endDateFilter = document.getElementById('endDateFilter');
            
            if (filterType === 'year') {
                yearFilter.style.display = 'block';
                dateRangeFilter.style.display = 'none';
                endDateFilter.style.display = 'none';
                document.getElementById('startDate').required = false;
                document.getElementById('endDate').required = false;
            } else {
                yearFilter.style.display = 'none';
                dateRangeFilter.style.display = 'block';
                endDateFilter.style.display = 'block';
                document.getElementById('startDate').required = true;
                document.getElementById('endDate').required = true;
            }
        }
        
        function resetFilter() {
            const currentYear = new Date().getFullYear();
            document.getElementById('filterType').value = 'year';
            document.getElementById('year').value = currentYear;
            document.getElementById('startDate').value = '';
            document.getElementById('endDate').value = '';
            toggleFilterType();
            document.getElementById('filterForm').submit();
        }
        
        // Set default dates for date range (last 30 days)
        window.onload = function() {
            const today = new Date();
            const thirtyDaysAgo = new Date();
            thirtyDaysAgo.setDate(today.getDate() - 30);
            
            // Format dates as YYYY-MM-DD
            const formatDate = (date) => {
                return date.toISOString().split('T')[0];
            };
            
            if (!document.getElementById('startDate').value) {
                document.getElementById('startDate').value = formatDate(thirtyDaysAgo);
            }
            if (!document.getElementById('endDate').value) {
                document.getElementById('endDate').value = formatDate(today);
            }
        };
        
        function exportReport() {
            alert('Chức năng xuất PDF đang được phát triển!');
        }
        
        function printReport() {
            window.print();
        }
    </script>
</body>
</html>