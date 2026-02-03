package dao;

import model.Table;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TableDAO extends BaseDAO {

    public List<Table> getAvailableTables() {
        List<Table> list = new ArrayList<>();
        String sql = "SELECT table_id, table_number, capacity, status " +
                     "FROM `tables` WHERE status = 'available' ORDER BY table_id";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Table t = new Table();
                t.setTableId(rs.getInt("table_id"));
                t.setTableNumber(rs.getString("table_number"));
                t.setCapacity(rs.getInt("capacity"));
                t.setStatus(rs.getString("status"));
                list.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // Nếu bạn muốn show tất cả bàn (kể cả occupied)
    public List<Table> getAllTables() {
        List<Table> list = new ArrayList<>();
        String sql = "SELECT table_id, table_number, capacity, status FROM `tables` ORDER BY table_id";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Table t = new Table();
                t.setTableId(rs.getInt("table_id"));
                t.setTableNumber(rs.getString("table_number"));
                t.setCapacity(rs.getInt("capacity"));
                t.setStatus(rs.getString("status"));
                list.add(t);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
