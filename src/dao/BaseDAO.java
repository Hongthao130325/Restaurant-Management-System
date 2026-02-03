package dao;

import util.DBConnection;
import java.sql.*;

public class BaseDAO {
    
    protected Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }
    
    protected void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        if (ps != null) {
            try { ps.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    protected void closeResources(Connection conn, PreparedStatement ps) {
        closeResources(conn, ps, null);
    }
}