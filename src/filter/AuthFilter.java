package filter;

import util.SessionUtils;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {
    
    private static final String[] PUBLIC_URLS = {
        "/login", "/register", "/assets", "/views/auth"
    };
    
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
        
        // Kiểm tra nếu là public resource
        boolean isPublic = isPublicResource(path);
        
        // Kiểm tra đăng nhập
        boolean isLoggedIn = SessionUtils.isLoggedIn(httpRequest);
        
        if (isPublic || isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(contextPath + "/login");
        }
    }
    
    private boolean isPublicResource(String path) {
        if (path.equals("/") || path.isEmpty()) {
            return true;
        }
        
        for (String publicUrl : PUBLIC_URLS) {
            if (path.startsWith(publicUrl)) {
                return true;
            }
        }
        
        // Static resources
        if (path.endsWith(".css") || path.endsWith(".js") || 
            path.endsWith(".jpg") || path.endsWith(".png") || 
            path.endsWith(".gif") || path.endsWith(".ico")) {
            return true;
        }
        
        return false;
    }
    
    @Override
    public void destroy() {}
}
