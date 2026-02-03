package dao;

import model.MenuItem;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MenuDAO extends BaseDAO {
    
    public List<MenuItem> getAllMenuItems() {
        List<MenuItem> items = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT m.*, c.category_name FROM menu_items m " +
                        "LEFT JOIN categories c ON m.category_id = c.category_id " +
                        "WHERE m.status = 'available' " +
                        "ORDER BY c.display_order, m.item_name";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                items.add(extractMenuItemFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return items;
    }
    
    public List<MenuItem> getAllMenuItemsForAdmin() {
        List<MenuItem> items = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT m.*, c.category_name FROM menu_items m " +
                        "LEFT JOIN categories c ON m.category_id = c.category_id " +
                        "ORDER BY m.item_id DESC";
            
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                items.add(extractMenuItemFromResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return items;
    }
    
    public MenuItem getMenuItemById(int itemId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT m.*, c.category_name FROM menu_items m " +
                        "LEFT JOIN categories c ON m.category_id = c.category_id " +
                        "WHERE m.item_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return extractMenuItemFromResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }
    
    public boolean addMenuItem(MenuItem item) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "INSERT INTO menu_items (item_name, category_id, description, price, image_url, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getItemName());
            ps.setInt(2, item.getCategoryId());
            ps.setString(3, item.getDescription());
            ps.setDouble(4, item.getPrice());
            ps.setString(5, item.getImageUrl());
            ps.setString(6, item.getStatus());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps);
        }
        return false;
    }
    
    public boolean updateMenuItem(MenuItem item) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "UPDATE menu_items SET item_name = ?, category_id = ?, description = ?, " +
                        "price = ?, image_url = ?, status = ? WHERE item_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getItemName());
            ps.setInt(2, item.getCategoryId());
            ps.setString(3, item.getDescription());
            ps.setDouble(4, item.getPrice());
            ps.setString(5, item.getImageUrl());
            ps.setString(6, item.getStatus());
            ps.setInt(7, item.getItemId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps);
        }
        return false;
    }
    
    public boolean deleteMenuItem(int itemId) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "DELETE FROM menu_items WHERE item_id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, itemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps);
        }
        return false;
    }
    
    private MenuItem extractMenuItemFromResultSet(ResultSet rs) throws SQLException {
        MenuItem item = new MenuItem();
        item.setItemId(rs.getInt("item_id"));
        item.setItemName(rs.getString("item_name"));
        item.setCategoryId(rs.getInt("category_id"));
        item.setCategoryName(rs.getString("category_name"));
        item.setDescription(rs.getString("description"));
        item.setPrice(rs.getDouble("price"));
        item.setImageUrl(rs.getString("image_url"));
        item.setStatus(rs.getString("status"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        return item;
    }
}
