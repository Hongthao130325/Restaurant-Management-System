
package controller;

import dao.MenuDAO;
import model.MenuItem;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/menu")
public class MenuServlet extends HttpServlet {
    private MenuDAO menuDAO;
    
    @Override
    public void init() {
        menuDAO = new MenuDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<MenuItem> menuItems = menuDAO.getAllMenuItems();
        request.setAttribute("menuItems", menuItems);
        request.getRequestDispatcher("/views/customer/menu.jsp").forward(request, response);
    }
}