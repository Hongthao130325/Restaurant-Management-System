package controller;

import dao.MenuDAO;
import model.MenuItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/staff/dinein/menu")
public class StaffDineInMenuServlet extends HttpServlet {

    private MenuDAO menuDAO;

    @Override
    public void init() {
        menuDAO = new MenuDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tableId = request.getParameter("tableId");
        if (tableId == null || tableId.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/staff/call-order");
            return;
        }

        // Load menu giống customer
        List<MenuItem> menuItems = menuDAO.getAllMenuItems();
        request.setAttribute("menuItems", menuItems);

        // Đánh dấu dine-in
        request.setAttribute("mode", "DINEIN");
        request.setAttribute("tableId", tableId);

        // Dùng lại UI menu customer
        request.getRequestDispatcher("/views/customer/menu.jsp").forward(request, response);
    }
}
