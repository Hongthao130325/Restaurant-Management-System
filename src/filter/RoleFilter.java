package filter;

import model.User;
import util.SessionUtils;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter({"/admin", "/employee", "/menu", "/cart", "/order"})
public class RoleFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) 
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String uri = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = uri.substring(contextPath.length());
        
        User user = SessionUtils.getCurrentUser(httpRequest);
        
        if (user == null) {
            httpResponse.sendRedirect(contextPath + "/login");
            return;
        }
        
        boolean hasAccess = checkAccess(path, user.getRoleName());
        
        if (hasAccess) {
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(contextPath + "/login?error=access_denied");
        }
    }
    
    private boolean checkAccess(String path, String roleName) {
        if (roleName == null) return false;
        roleName = roleName.toLowerCase();

        if (path.startsWith("/admin")) {
            return "admin".equals(roleName);
        } else if (path.startsWith("/employee")) {
            return "employee".equals(roleName) || "admin".equals(roleName);
        } else if (path.startsWith("/menu") || path.startsWith("/cart") || path.startsWith("/order")) {
            return "customer".equals(roleName);
        }
        return false;
    }
    
    @Override
    public void destroy() {}
}