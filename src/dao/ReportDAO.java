package dao;

import java.sql.*;
import java.util.*;
import java.sql.Date;

public class ReportDAO extends BaseDAO {
    
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            System.out.println("DEBUG: Getting dashboard stats...");
            
            // Today orders
            ps = conn.prepareStatement("SELECT COUNT(*) as count FROM orders WHERE DATE(created_at) = CURDATE()");
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                stats.put("todayOrders", count);
                System.out.println("DEBUG: Today orders = " + count);
            }
            closeStatementAndResultSet(ps, rs);
            
            // Today revenue
            ps = conn.prepareStatement(
                "SELECT COALESCE(SUM(total_amount), 0) as revenue " +
                "FROM orders " +
                "WHERE order_status = 'completed' AND DATE(created_at) = CURDATE()"
            );
            rs = ps.executeQuery();
            if (rs.next()) {
                double revenue = rs.getDouble("revenue");
                stats.put("todayRevenue", revenue);
                System.out.println("DEBUG: Today revenue = " + revenue);
            }
            closeStatementAndResultSet(ps, rs);
            
            // Total customers
            ps = conn.prepareStatement("SELECT COUNT(*) as count FROM users WHERE role_id = 2");
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                stats.put("totalCustomers", count);
                System.out.println("DEBUG: Total customers = " + count);
            }
            closeStatementAndResultSet(ps, rs);
            
            // Pending orders
            ps = conn.prepareStatement("SELECT COUNT(*) as count FROM orders WHERE order_status = 'pending'");
            rs = ps.executeQuery();
            if (rs.next()) {
                int count = rs.getInt("count");
                stats.put("pendingOrders", count);
                System.out.println("DEBUG: Pending orders = " + count);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("ERROR in getDashboardStats: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        
        // Default values
        if (!stats.containsKey("todayOrders")) stats.put("todayOrders", 0);
        if (!stats.containsKey("todayRevenue")) stats.put("todayRevenue", 0.0);
        if (!stats.containsKey("totalCustomers")) stats.put("totalCustomers", 0);
        if (!stats.containsKey("pendingOrders")) stats.put("pendingOrders", 0);
        
        System.out.println("DEBUG: Final stats = " + stats);
        return stats;
    }
    
    public List<Map<String, Object>> getRevenueByDateRange(Date startDate, Date endDate) {
        List<Map<String, Object>> results = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            System.out.println("DEBUG: Getting revenue from " + startDate + " to " + endDate);
            
            String sql = "SELECT DATE(created_at) as order_date, " +
                        "COUNT(*) as order_count, " +
                        "COALESCE(SUM(total_amount), 0) as revenue " +
                        "FROM orders " +
                        "WHERE order_status = 'completed' " +
                        "AND DATE(created_at) BETWEEN ? AND ? " +
                        "GROUP BY DATE(created_at) ORDER BY order_date";
            
            ps = conn.prepareStatement(sql);
            ps.setDate(1, new java.sql.Date(startDate.getTime()));
            ps.setDate(2, new java.sql.Date(endDate.getTime()));
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("date", rs.getDate("order_date"));
                row.put("orderCount", rs.getInt("order_count"));
                row.put("revenue", rs.getDouble("revenue"));
                results.add(row);
            }
            
            System.out.println("DEBUG: Found " + results.size() + " days with data");
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("ERROR in getRevenueByDateRange: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        
        return results;
    }
    
    
    public List<Integer> getAvailableYears() {
        List<Integer> years = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT DISTINCT YEAR(created_at) as year FROM orders ORDER BY year DESC";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                years.add(rs.getInt("year"));
            }
            
            if (years.isEmpty()) {
                int currentYear = Calendar.getInstance().get(Calendar.YEAR);
                years.add(currentYear);
                years.add(currentYear - 1);
            }
            
            System.out.println("DEBUG: Available years = " + years);
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        
        return years;
    }
    
    public List<Map<String, Object>> getRevenueByMonth(int year) {
        List<Map<String, Object>> results = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            System.out.println("DEBUG: Getting revenue for year " + year);
            
            String sql = "SELECT MONTH(created_at) as month, " +
                        "COUNT(*) as order_count, " +
                        "COALESCE(SUM(total_amount), 0) as revenue " +
                        "FROM orders " +
                        "WHERE order_status = 'completed' AND YEAR(created_at) = ? " +
                        "GROUP BY MONTH(created_at) ORDER BY month";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, year);
            rs = ps.executeQuery();
            
            Map<Integer, Map<String, Object>> monthMap = new HashMap<>();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                int month = rs.getInt("month");
                row.put("month", month);
                row.put("orderCount", rs.getInt("order_count"));
                row.put("revenue", rs.getDouble("revenue"));
                monthMap.put(month, row);
            }
            
            // Fill all 12 months
            for (int i = 1; i <= 12; i++) {
                if (monthMap.containsKey(i)) {
                    results.add(monthMap.get(i));
                } else {
                    Map<String, Object> row = new HashMap<>();
                    row.put("month", i);
                    row.put("orderCount", 0);
                    row.put("revenue", 0.0);
                    results.add(row);
                }
            }
            
            System.out.println("DEBUG: Loaded 12 months data");
            
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("ERROR in getRevenueByMonth: " + e.getMessage());
        } finally {
            closeResources(conn, ps, rs);
        }
        
        return results;
    }
    
    
    private void closeStatementAndResultSet(PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
}