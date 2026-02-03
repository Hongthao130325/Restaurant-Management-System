package util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import model.User;

public class SessionUtils {
    
    public static User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute("user");
        }
        return null;
    }
    
    public static boolean isLoggedIn(HttpServletRequest request) {
        return getCurrentUser(request) != null;
    }
    
    public static boolean isAdmin(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && "admin".equals(user.getRoleName());
    }
    
    public static boolean isEmployee(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && "employee".equals(user.getRoleName());
    }
    
    public static boolean isCustomer(HttpServletRequest request) {
        User user = getCurrentUser(request);
        return user != null && "customer".equals(user.getRoleName());
    }
    
    public static void setUserSession(HttpServletRequest request, User user) {
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("username", user.getUsername());
        session.setAttribute("roleName", user.getRoleName());
        session.setAttribute("roleId", user.getRoleId());
        session.setAttribute("fullName", user.getFullName());
    }
    
    public static void removeUserSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }
    }
    
    public static String getRoleRedirectUrl(User user) {
        if (user == null) return "/login";
        
        switch (user.getRoleName()) {
            case "admin":
                return "/admin";
            case "employee":
                return "/employee";
            case "customer":
                return "/menu";
            default:
                return "/login";
        }
    }
}