package dao;

import model.Order;
import model.OrderDetail;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDAO extends BaseDAO {
    
	public int createOrder(Order order) {
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;

	    try {
	        conn = getConnection();
	        conn.setAutoCommit(false);

	        String sql = "INSERT INTO orders (" +
	                "customer_id, table_id, order_type, order_status, " +
	                "payment_method, payment_status, total_amount, " +
	                "customer_note, delivery_address" +
	                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

	        ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

	        ps.setInt(1, order.getCustomerId());

	        if (order.getTableId() > 0) {
	            ps.setInt(2, order.getTableId());
	        } else {
	            ps.setNull(2, Types.INTEGER);
	        }

	        ps.setString(3, order.getOrderType());
	        ps.setString(4, "pending");
	        ps.setString(5, order.getPaymentMethod());
	        ps.setString(6, "unpaid");
	        ps.setDouble(7, order.getTotalAmount());
	        ps.setString(8, order.getCustomerNote());
	        ps.setString(9, order.getDeliveryAddress());   // 👈

	        int affectedRows = ps.executeUpdate();

	        if (affectedRows > 0) {
	            rs = ps.getGeneratedKeys();
	            if (rs.next()) {
	                int orderId = rs.getInt(1);

	                for (OrderDetail detail : order.getOrderDetails()) {
	                    if (!addOrderDetail(conn, orderId, detail)) {
	                        conn.rollback();
	                        return -1;
	                    }
	                }

	                conn.commit();
	                return orderId;
	            }
	        }

	        conn.rollback();
	    } catch (SQLException e) {
	        e.printStackTrace(); // xem lỗi trong Console
	        try {
	            if (conn != null) conn.rollback();
	        } catch (SQLException ex) {
	            ex.printStackTrace();
	        }
	    } finally {
	        try {
	            if (conn != null) conn.setAutoCommit(true);
	        } catch (SQLException e) {
	            e.printStackTrace();
	        }
	        closeResources(conn, ps, rs);
	    }
	    return -1;
	}



	private boolean addOrderDetail(Connection conn, int orderId, OrderDetail detail) {
	    PreparedStatement ps = null;
	    try {
	        String sql = "INSERT INTO order_details " +
	                     "(order_id, item_id, quantity, unit_price, item_note) " +
	                     "VALUES (?, ?, ?, ?, ?)";

	        ps = conn.prepareStatement(sql);
	        ps.setInt(1, orderId);
	        ps.setInt(2, detail.getItemId());
	        ps.setInt(3, detail.getQuantity());
	        ps.setDouble(4, detail.getUnitPrice());
	        ps.setString(5, detail.getItemNote());

	        return ps.executeUpdate() > 0;
	    } catch (SQLException e) {
	        e.printStackTrace();
	    } finally {
	        if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
	    }
	    return false;
	}


    
    public Order getOrderById(int orderId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT o.*, " +
                        "u1.full_name as customer_name, u1.phone as customer_phone, " +
                        "u1.address as customer_address, u1.email as customer_email, " +
                        "u2.full_name as staff_name, t.table_number " +
                        "FROM orders o " +
                        "LEFT JOIN users u1 ON o.customer_id = u1.user_id " +
                        "LEFT JOIN users u2 ON o.staff_id = u2.user_id " +
                        "LEFT JOIN tables t ON o.table_id = t.table_id " +
                        "WHERE o.order_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                Order order = extractOrderFromResultSet(rs);
                order.setOrderDetails(getOrderDetails(orderId));
                return order;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }
    
    public List<OrderDetail> getOrderDetails(int orderId) {
        List<OrderDetail> details = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT od.*, m.item_name, m.image_url FROM order_details od " +
                        "JOIN menu_items m ON od.item_id = m.item_id " +
                        "WHERE od.order_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                OrderDetail detail = new OrderDetail();
                detail.setDetailId(rs.getInt("detail_id"));
                detail.setOrderId(rs.getInt("order_id"));
                detail.setItemId(rs.getInt("item_id"));
                detail.setItemName(rs.getString("item_name"));
                detail.setItemImage(rs.getString("image_url"));
                detail.setQuantity(rs.getInt("quantity"));
                detail.setUnitPrice(rs.getDouble("unit_price"));
                detail.setItemNote(rs.getString("item_note"));
                details.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return details;
    }
    
    public List<Order> getOrdersByCustomer(int customerId) {
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql =
                "SELECT o.*, " +
                "       u1.full_name AS customer_name, " +
                "       u1.phone      AS customer_phone, " +
                "       u1.address    AS customer_address, " +
                "       u1.email      AS customer_email, " +
                "       u2.full_name  AS staff_name, " +
                "       t.table_number " +
                "FROM orders o " +
                "JOIN users u1 ON o.customer_id = u1.user_id " +
                "LEFT JOIN users  u2 ON o.staff_id = u2.user_id " +
                "LEFT JOIN tables t  ON o.table_id = t.table_id " +
                "WHERE o.customer_id = ? " +
                "ORDER BY o.created_at DESC";

            ps = conn.prepareStatement(sql);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();

            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return orders;
    }

    
    public List<Order> getAllOrders() {
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT o.*, " +
                        "u1.full_name as customer_name, u1.phone as customer_phone, " +
                        "u1.address as customer_address, u1.email as customer_email, " +
                        "u2.full_name as staff_name " +
                        "FROM orders o " +
                        "LEFT JOIN users u1 ON o.customer_id = u1.user_id " +
                        "LEFT JOIN users u2 ON o.staff_id = u2.user_id " +
                        "ORDER BY o.created_at DESC";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return orders;
    }
    
    public List<Order> getOrdersByStatus(String status) {
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql =
                "SELECT o.*, " +
                "       u1.full_name AS customer_name, " +
                "       u1.phone      AS customer_phone, " +
                "       u1.address    AS customer_address, " +
                "       u1.email      AS customer_email, " +
                "       u2.full_name  AS staff_name, " +
                "       t.table_number " +
                "FROM orders o " +
                "JOIN users u1 ON o.customer_id = u1.user_id " +
                "LEFT JOIN users  u2 ON o.staff_id = u2.user_id " +
                "LEFT JOIN tables t  ON o.table_id = t.table_id " +
                "WHERE o.order_status = ? " +
                "ORDER BY o.created_at DESC";

            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            rs = ps.executeQuery();

            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return orders;
    }

    
    public boolean updateOrderStatus(int orderId, String status, Integer staffId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "UPDATE orders SET order_status = ?, staff_id = ? WHERE order_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            if (staffId != null) {
                ps.setInt(2, staffId);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setInt(3, orderId);
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps);
        }
        return false;
    }
    
    private Order extractOrderFromResultSet(ResultSet rs) throws SQLException {
        Order order = new Order();
        order.setOrderId(rs.getInt("order_id"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setCustomerPhone(rs.getString("customer_phone"));
        order.setCustomerAddress(rs.getString("customer_address"));
        order.setCustomerEmail(rs.getString("customer_email"));
        order.setStaffId(rs.getInt("staff_id"));
        order.setStaffName(rs.getString("staff_name"));
        order.setTableId(rs.getInt("table_id"));
        order.setTableNumber(rs.getString("table_number"));
        order.setOrderType(rs.getString("order_type"));
        order.setOrderStatus(rs.getString("order_status"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setPaymentStatus(rs.getString("payment_status"));
        order.setTotalAmount(rs.getDouble("total_amount"));
        order.setCustomerNote(rs.getString("customer_note"));
        order.setStaffNote(rs.getString("staff_note"));
        order.setCreatedAt(rs.getTimestamp("created_at"));
        order.setUpdatedAt(rs.getTimestamp("updated_at"));
    
        order.setDeliveryAddress(rs.getString("delivery_address"));


        return order;
    }
    public List<Order> getOrdersHistoryByStaff(int staffId) {
        List<Order> orders = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            String sql =
                "SELECT o.*, " +
                "       u1.full_name AS customer_name, " +
                "       u1.phone      AS customer_phone, " +
                "       u1.address    AS customer_address, " +
                "       u1.email      AS customer_email, " +
                "       u2.full_name  AS staff_name, " +
                "       t.table_number " +
                "FROM orders o " +
                "JOIN users u1 ON o.customer_id = u1.user_id " +
                "LEFT JOIN users u2 ON o.staff_id = u2.user_id " +
                "LEFT JOIN tables t ON o.table_id = t.table_id " +
                "WHERE o.staff_id = ? " +
                "  AND o.order_status IN ('completed','cancelled') " +
                "ORDER BY o.updated_at DESC, o.created_at DESC";

            ps = conn.prepareStatement(sql);
            ps.setInt(1, staffId);
            rs = ps.executeQuery();

            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }

        return orders;
    }

    public List<Order> getOrdersByStatusAndStaff(String status, int staffId) {
        List<Order> orders = new ArrayList<>();

        String sql =
            "SELECT o.*, " +
            "u1.full_name AS customer_name, u1.phone AS customer_phone, " +
            "u1.address AS customer_address, u1.email AS customer_email, " +
            "u2.full_name AS staff_name, t.table_number " +
            "FROM orders o " +
            "JOIN users u1 ON o.customer_id = u1.user_id " +
            "LEFT JOIN users u2 ON o.staff_id = u2.user_id " +
            "LEFT JOIN tables t ON o.table_id = t.table_id " +
            "WHERE o.order_status = ? AND o.staff_id = ? " +
            "ORDER BY o.updated_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);   
            ps.setInt(2, staffId);    

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    public List<Order> getPendingOrders() {
        List<Order> orders = new ArrayList<>();
        String sql =
        	    "SELECT o.*, " +
        	    "u1.full_name AS customer_name, " +
        	    "u1.phone AS customer_phone, " +
        	    "u1.address AS customer_address, " +
        	    "u1.email AS customer_email, " +
        	    "u2.full_name AS staff_name, " +
        	    "t.table_number " +
        	    "FROM orders o " +
        	    "JOIN users u1 ON o.customer_id = u1.user_id " +
        	    "LEFT JOIN users u2 ON o.staff_id = u2.user_id " +
        	    "LEFT JOIN tables t ON o.table_id = t.table_id " +
        	    "WHERE o.order_status = 'pending' " +
        	    "AND (o.staff_id IS NULL OR o.staff_id = 0) " +
        	    "ORDER BY o.created_at DESC";


        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) orders.add(extractOrderFromResultSet(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
    public boolean cancelOrderByCustomer(int orderId, int customerId, String reason) {
        String sql =
            "UPDATE orders " +
            "SET order_status = 'cancelled', cancel_reason = ?, updated_at = NOW() " +
            "WHERE order_id = ? AND customer_id = ? AND order_status = 'pending'";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, reason);
            ps.setInt(2, orderId);
            ps.setInt(3, customerId);

            return ps.executeUpdate() > 0; // chỉ true nếu đúng pending và đúng chủ đơn
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<Order> getHistoryOrdersForStaff(int staffId) {
        List<Order> orders = new ArrayList<>();

        String sql =
            "SELECT o.*, " +
            "u1.full_name AS customer_name, u1.phone AS customer_phone, " +
            "u1.address AS customer_address, u1.email AS customer_email, " +
            "u2.full_name AS staff_name, t.table_number " +
            "FROM orders o " +
            "JOIN users u1 ON o.customer_id = u1.user_id " +
            "LEFT JOIN users u2 ON o.staff_id = u2.user_id " +
            "LEFT JOIN tables t ON o.table_id = t.table_id " +
            "WHERE (o.order_status = 'completed' AND o.staff_id = ?) " +
            "   OR (o.order_status = 'cancelled' AND (o.staff_id = ? OR o.staff_id IS NULL OR o.staff_id = 0)) " +
            "ORDER BY o.updated_at DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, staffId);
            ps.setInt(2, staffId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) orders.add(extractOrderFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }
}