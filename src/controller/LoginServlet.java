package controller;

import dao.UserDAO;
import model.User;
import util.SessionUtils;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        if (SessionUtils.isLoggedIn(request)) {
            User user = SessionUtils.getCurrentUser(request);
            response.sendRedirect(request.getContextPath() + SessionUtils.getRoleRedirectUrl(user));
            return;
        }
        request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        User user = userDAO.login(username, password);
        
        if (user != null) {
            SessionUtils.setUserSession(request, user);
            response.sendRedirect(request.getContextPath() + SessionUtils.getRoleRedirectUrl(user));
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("/views/auth/login.jsp").forward(request, response);
        }
    }
}