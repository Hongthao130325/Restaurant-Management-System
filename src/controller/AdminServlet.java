package controller;

import dao.*;
import model.*;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.sql.Date;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    private UserDAO userDAO;
    private MenuDAO menuDAO;
    private OrderDAO orderDAO;
    private ReportDAO reportDAO;
    private Gson gson;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
        menuDAO = new MenuDAO();
        orderDAO = new OrderDAO();
        reportDAO = new ReportDAO();
        gson = new Gson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        String action = request.getParameter("action");
        
        // Xử lý getOrderDetail cho AJAX request
        if ("getOrderDetail".equals(action)) {
            getOrderDetailAjax(request, response);
            return;
        }
        
        if (action == null || "reports".equals(action)) {
            showReports(request, response);
        } else if ("users".equals(action)) {
            showUsers(request, response);
        } else if ("menu".equals(action)) {
            showMenu(request, response);
        } else if ("orders".equals(action)) {
            showOrders(request, response);
        
        } else {
            showReports(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String action = request.getParameter("action");
        System.out.println("AdminServlet - Action: " + action);
        
        try {
            if ("addUser".equals(action)) {
                addUser(request, response);
            } else if ("updateUser".equals(action)) {
                updateUser(request, response);
            } else if ("deleteUser".equals(action)) {
                deleteUser(request, response);
            } else if ("toggleUserStatus".equals(action)) {
                toggleUserStatus(request, response);
            } else if ("addMenuItem".equals(action)) {
                addMenuItem(request, response);
            } else if ("updateMenuItem".equals(action)) {
                updateMenuItem(request, response);
            } else if ("deleteMenuItem".equals(action)) {
                deleteMenuItem(request, response);
            } else if ("updateOrderStatus".equals(action)) {
                updateOrderStatusAjax(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?error=" + e.getMessage());
        }
    }
        
    private void showUsers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/views/admin/manageUsers.jsp").forward(request, response);
    }
    
    private void addUser(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            
            if (userDAO.usernameExists(username)) {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&error=Username exists");
                return;
            }
            
            if (userDAO.emailExists(email)) {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&error=Email exists");
                return;
            }
            
            User user = new User(username, password, fullName, email, roleId);
            user.setPhone(phone);
            user.setAddress(address);
            
            boolean success = userDAO.register(user);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&success=add");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=users&error=" + e.getMessage());
        }
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            
            User user = new User();
            user.setUserId(userId);
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhone(phone);
            user.setAddress(address);
            user.setRoleId(roleId);
            
            boolean success = userDAO.updateUser(user);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&success=update");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=users&error=" + e.getMessage());
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean success = userDAO.deleteUser(userId);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=users&error=" + e.getMessage());
        }
    }
    
    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String status = request.getParameter("status");
            
            boolean success = userDAO.updateUserStatus(userId, status);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&success=status");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=users&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=users&error=" + e.getMessage());
        }
    }
    
    private void showMenu(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<MenuItem> menuItems = menuDAO.getAllMenuItemsForAdmin();
        request.setAttribute("menuItems", menuItems);
        request.getRequestDispatcher("/views/admin/manageMenu.jsp").forward(request, response);
    }
    
    private void addMenuItem(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            String itemName = request.getParameter("itemName");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String description = request.getParameter("description");
            double price = Double.parseDouble(request.getParameter("price"));
            String imageUrl = request.getParameter("imageUrl");
            String status = request.getParameter("status");
            
            MenuItem item = new MenuItem(itemName, categoryId, description, price);
            item.setImageUrl(imageUrl != null && !imageUrl.isEmpty() ? imageUrl : "default.jpg");
            item.setStatus(status);
            
            boolean success = menuDAO.addMenuItem(item);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=menu&success=add");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=menu&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=menu&error=" + e.getMessage());
        }
    }
    
    private void updateMenuItem(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            String itemName = request.getParameter("itemName");
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            String description = request.getParameter("description");
            double price = Double.parseDouble(request.getParameter("price"));
            String imageUrl = request.getParameter("imageUrl");
            String status = request.getParameter("status");
            
            MenuItem item = new MenuItem(itemName, categoryId, description, price);
            item.setItemId(itemId);
            item.setImageUrl(imageUrl != null && !imageUrl.isEmpty() ? imageUrl : "default.jpg");
            item.setStatus(status);
            
            boolean success = menuDAO.updateMenuItem(item);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=menu&success=update");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=menu&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=menu&error=" + e.getMessage());
        }
    }
    
    private void deleteMenuItem(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            boolean success = menuDAO.deleteMenuItem(itemId);
            
            if (success) {
                response.sendRedirect(request.getContextPath() + "/admin?action=menu&success=delete");
            } else {
                response.sendRedirect(request.getContextPath() + "/admin?action=menu&error=Failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin?action=menu&error=" + e.getMessage());
        }
    }
    
    private void showOrders(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String statusFilter = request.getParameter("status");
        List<Order> orders;
        
        if (statusFilter != null && !statusFilter.isEmpty()) {
            orders = orderDAO.getOrdersByStatus(statusFilter);
        } else {
            orders = orderDAO.getAllOrders();
        }
        
        request.setAttribute("orders", orders);
        request.setAttribute("statusFilter", statusFilter);
        request.getRequestDispatcher("/views/admin/manageOrders.jsp").forward(request, response);
    }
    
    private void getOrderDetailAjax(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        
        try {
            String orderIdParam = request.getParameter("orderId");
            if (orderIdParam == null) {
                orderIdParam = request.getParameter("id");
            }
            
            int orderId = Integer.parseInt(orderIdParam);
            Order order = orderDAO.getOrderById(orderId);
            
            Map<String, Object> result = new HashMap<>();
            
            if (order != null) {
                Map<String, Object> orderData = new HashMap<>();
                orderData.put("orderId", order.getOrderId());
                orderData.put("customerName", order.getCustomerName());
                orderData.put("customerPhone", order.getCustomerPhone());
                orderData.put("orderDate", order.getCreatedAt() != null ? order.getCreatedAt().toString() : "");
                orderData.put("paymentMethod", order.getPaymentMethod());
                orderData.put("status", order.getOrderStatus());
                orderData.put("deliveryAddress", order.getDeliveryAddress());
                orderData.put("note", order.getCustomerNote());
                orderData.put("totalAmount", order.getTotalAmount());
                orderData.put("orderType", order.getOrderType());
                orderData.put("paymentStatus", order.getPaymentStatus());
                
                List<Map<String, Object>> details = new ArrayList<>();
                if (order.getOrderDetails() != null) {
                    for (OrderDetail detail : order.getOrderDetails()) {
                        Map<String, Object> detailMap = new HashMap<>();
                        detailMap.put("itemName", detail.getItemName());
                        detailMap.put("quantity", detail.getQuantity());
                        detailMap.put("unitPrice", detail.getUnitPrice());
                        detailMap.put("note", detail.getItemNote());
                        details.add(detailMap);
                    }
                }
                orderData.put("orderDetails", details);
                
                result.put("success", true);
                result.put("order", orderData);
            } else {
                result.put("success", false);
                result.put("message", "Order not found");
            }
            
            response.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }
    
    private void updateOrderStatusAjax(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json; charset=UTF-8");
        
        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");
            
            System.out.println("Updating order " + orderId + " to status: " + status);
            
            boolean success = orderDAO.updateOrderStatus(orderId, status, null);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", success);
            result.put("message", success ? "Update successful!" : "Update failed");
            
            response.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Error: " + e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }
    
	private void showReports(HttpServletRequest request, HttpServletResponse response) 
	        throws ServletException, IOException {
	    System.out.println("DEBUG: Loading reports...");
	    
	    int currentYear = Calendar.getInstance().get(Calendar.YEAR);
	    
	    String yearParam = request.getParameter("year");
	    int selectedYear = currentYear;
	    if (yearParam != null && !yearParam.isEmpty()) {
	        try {
	            selectedYear = Integer.parseInt(yearParam);
	        } catch (NumberFormatException e) {
	            selectedYear = currentYear;
	        }
	    }
	    
	    String startDateStr = request.getParameter("startDate");
	    String endDateStr = request.getParameter("endDate");
	    
	    List<Map<String, Object>> monthlyRevenue;
	    
	    if (startDateStr != null && !startDateStr.isEmpty() && 
	        endDateStr != null && !endDateStr.isEmpty()) {
	        try {
	            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
	            
	            // SỬA LẠI: Chuyển từ java.util.Date sang java.sql.Date
	            java.util.Date utilStartDate = sdf.parse(startDateStr);
	            java.util.Date utilEndDate = sdf.parse(endDateStr);
	            
	            java.sql.Date startDate = new java.sql.Date(utilStartDate.getTime());
	            java.sql.Date endDate = new java.sql.Date(utilEndDate.getTime());
	            
	            System.out.println("DEBUG: Getting data from " + startDate + " to " + endDate);
	            
	            monthlyRevenue = reportDAO.getRevenueByDateRange(startDate, endDate);
	            
	            request.setAttribute("startDate", startDateStr);
	            request.setAttribute("endDate", endDateStr);
	            request.setAttribute("dateRangeMode", true);
	            
	        } catch (Exception e) {
	            e.printStackTrace();
	            System.err.println("ERROR parsing dates: " + e.getMessage());
	            monthlyRevenue = reportDAO.getRevenueByMonth(selectedYear);
	            request.setAttribute("dateRangeMode", false);
	        }
		    } else {
		        System.out.println("DEBUG: Getting data for year " + selectedYear);
		        monthlyRevenue = reportDAO.getRevenueByMonth(selectedYear);
		        request.setAttribute("dateRangeMode", false);
		    }
		    
		    List<Integer> availableYears = reportDAO.getAvailableYears();
		    if (availableYears.isEmpty()) {
		        availableYears = Arrays.asList(currentYear - 1, currentYear, currentYear + 1);
		    }
		    
		    System.out.println("DEBUG: Monthly revenue count = " + monthlyRevenue.size());
		    
		    request.setAttribute("monthlyRevenue", monthlyRevenue);
		    request.setAttribute("currentYear", currentYear);
		    request.setAttribute("selectedYear", selectedYear);
		    request.setAttribute("availableYears", availableYears);
		    
		    request.getRequestDispatcher("/views/admin/report.jsp").forward(request, response);
	}
}