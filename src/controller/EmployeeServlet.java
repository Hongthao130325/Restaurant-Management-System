package controller;

import dao.OrderDAO;
import model.Order;
import model.User;
import util.SessionUtils;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/employee")
public class EmployeeServlet extends HttpServlet {
    private OrderDAO orderDAO;
    
    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }
    
    @Override

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("detail".equals(action)) {
            showOrderDetail(request, response);
        } else {
            showOrders(request, response);
        }
    } 
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        
        if ("updateStatus".equals(action)) {
            updateOrderStatus(request, response);
        }
    }
    
    private void showOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

    	String status = request.getParameter("status");
    	if (status != null) {
    	    status = status.trim().toLowerCase(); 
    	}
    	 System.out.println("STATUS RECEIVED = [" + status + "]");

        User staff = SessionUtils.getCurrentUser(request);
        int staffId = staff.getUserId();

        List<Order> orders;

        if (status == null || status.isEmpty()) {
            // 📋 TẤT CẢ = lịch sử (completed + cancelled)
            orders = orderDAO.getHistoryOrdersForStaff(staffId);
        }
        else if ("pending".equals(status)) {
            orders = orderDAO.getPendingOrders();
        }
        else {
            orders = orderDAO.getOrdersByStatusAndStaff(status, staffId);
        }


        request.setAttribute("orders", orders);
        request.setAttribute("statusFilter", status);
        request.getRequestDispatcher("/views/employee/orders.jsp").forward(request, response);
    }
    
    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("id"));
        Order order = orderDAO.getOrderById(orderId);
        
        if (order != null) {
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/employee/orderDetail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/employee");
        }
    }
    
    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String orderIdStr = request.getParameter("orderId");
        String status = request.getParameter("status");

        // check thiếu param
        if (orderIdStr == null || orderIdStr.trim().isEmpty() ||
            status == null || status.trim().isEmpty()) {

            response.getWriter().write("{\"success\":false,\"message\":\"Thiếu orderId hoặc status\"}");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"orderId không hợp lệ\"}");
            return;
        }

        User staff = SessionUtils.getCurrentUser(request);
        Integer staffId = (staff != null) ? staff.getUserId() : null;

        boolean ok = orderDAO.updateOrderStatus(orderId, status, staffId);

        if (ok) {
            response.getWriter().write("{\"success\":true}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Cập nhật thất bại\"}");
        }
    }
}
