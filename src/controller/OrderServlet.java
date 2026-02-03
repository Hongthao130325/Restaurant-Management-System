package controller;

import dao.OrderDAO;
import model.*;
import util.SessionUtils;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {
    private OrderDAO orderDAO;
    
    @Override
    public void init() {
        orderDAO = new OrderDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("checkout".equals(action)) {
            showCheckout(request, response);
        } else if ("history".equals(action)) {
            showOrderHistory(request, response);
        } else if ("detail".equals(action)) {
            showOrderDetail(request, response);
        } else {
            showOrderHistory(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("place".equals(action)) {
            placeOrder(request, response);
        } else if ("cancel".equals(action)) {
            cancelOrder(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }
    
    private void showCheckout(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Map<Integer, Map<String, Object>> cart = 
            (Map<Integer, Map<String, Object>>) session.getAttribute("cart");
        
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu");
            return;
        }
        
        double total = 0;
        for (Map<String, Object> cartItem : cart.values()) {
            MenuItem item = (MenuItem) cartItem.get("item");
            int quantity = (int) cartItem.get("quantity");
            total += item.getPrice() * quantity;
        }
        
        request.setAttribute("total", total);
        request.getRequestDispatcher("/views/customer/checkout.jsp").forward(request, response);
    }
    
    private void placeOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = SessionUtils.getCurrentUser(request);
        Map<Integer, Map<String, Object>> cart =
                (Map<Integer, Map<String, Object>>) session.getAttribute("cart");

        // Không có giỏ -> quay về menu
        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/menu");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String paymentMethod   = request.getParameter("paymentMethod");
        String customerNote    = request.getParameter("customerNote");
        String deliveryAddress = request.getParameter("deliveryAddress");

        // ✅ BẮT BUỘC ĐỊA CHỈ GIAO HÀNG
        if (deliveryAddress == null || deliveryAddress.trim().isEmpty()) {
            request.setAttribute("errorDelivery", "Vui lòng nhập địa chỉ giao hàng.");
            // giữ lại ghi chú nếu có
            request.setAttribute("customerNote", customerNote);
            showCheckout(request, response);   // forward lại trang checkout
            return;
        }
        deliveryAddress = deliveryAddress.trim();

        Order order = new Order();
        order.setCustomerId(user.getUserId());
        order.setOrderType("online");
        order.setPaymentMethod(paymentMethod);
        order.setCustomerNote(customerNote);
        order.setDeliveryAddress(deliveryAddress);   // ✅ lưu vào object

        double total = 0;
        List<OrderDetail> details = new ArrayList<>();

        for (Map<String, Object> cartItem : cart.values()) {
            MenuItem item     = (MenuItem) cartItem.get("item");
            int      quantity = (int) cartItem.get("quantity");
            String   note     = (String) cartItem.get("note");

            OrderDetail detail = new OrderDetail();
            detail.setItemId(item.getItemId());
            detail.setQuantity(quantity);
            detail.setUnitPrice(item.getPrice());
            detail.setItemNote(note);
            details.add(detail);

            total += item.getPrice() * quantity;
        }

        order.setTotalAmount(total);
        order.setOrderDetails(details);

        int orderId = orderDAO.createOrder(order);
        System.out.println("DEBUG orderId = " + orderId); // để xem trong console

        if (orderId > 0) {
            // clear cart
            session.removeAttribute("cart");
            session.setAttribute("cartSize", 0);

            request.setAttribute("success", true);
            request.setAttribute("orderId", orderId);
            request.getRequestDispatcher("/views/customer/orderSuccess.jsp")
                   .forward(request, response);
        } else {
            request.setAttribute("error", "Đặt hàng thất bại! Vui lòng thử lại.");
            showCheckout(request, response);
        }
    }


    
    private void showOrderHistory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        User user = SessionUtils.getCurrentUser(request);
        List<Order> orders = orderDAO.getOrdersByCustomer(user.getUserId());
        request.setAttribute("orders", orders);
        request.getRequestDispatcher("/views/customer/orderHistory.jsp").forward(request, response);
    }
    
    private void showOrderDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int orderId = Integer.parseInt(request.getParameter("id"));
        Order order = orderDAO.getOrderById(orderId);
        
        User user = SessionUtils.getCurrentUser(request);
        if (order != null && order.getCustomerId() == user.getUserId()) {
            request.setAttribute("order", order);
            request.getRequestDispatcher("/views/customer/orderDetail.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/order?action=history");
        }
    }
    
    private void cancelOrder(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // lấy user hiện tại (khách hàng)
        User u = SessionUtils.getCurrentUser(request);
        if (u == null) {
            response.getWriter().write("{\"success\":false,\"message\":\"Bạn chưa đăng nhập\"}");
            return;
        }

        String orderIdStr = request.getParameter("orderId");
        String reason = request.getParameter("reason");

        if (orderIdStr == null || orderIdStr.isBlank() || reason == null || reason.isBlank()) {
            response.getWriter().write("{\"success\":false,\"message\":\"Vui lòng nhập lý do hủy\"}");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            response.getWriter().write("{\"success\":false,\"message\":\"orderId không hợp lệ\"}");
            return;
        }

        boolean ok = orderDAO.cancelOrderByCustomer(orderId, u.getUserId(), reason.trim());

        if (ok) {
            response.getWriter().write("{\"success\":true}");
        } else {
            response.getWriter().write("{\"success\":false,\"message\":\"Không thể hủy đơn vì đơn đã được xác nhận hoặc không hợp lệ\"}");
        }
    }
}