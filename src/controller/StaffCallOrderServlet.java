package controller;

import dao.TableDAO;
import model.Table;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/staff/call-order")
public class StaffCallOrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        TableDAO tableDAO = new TableDAO();
        List<Table> tables = tableDAO.getAvailableTables(); // hoặc getAllTables()

        request.setAttribute("tables", tables);
        request.getRequestDispatcher("/views/staff/call_order.jsp").forward(request, response);
    }
}
