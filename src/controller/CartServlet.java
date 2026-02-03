package controller;

import dao.MenuDAO;
import model.MenuItem;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private MenuDAO menuDAO;
    private Gson gson;

    @Override
    public void init() {
        menuDAO = new MenuDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/customer/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            addToCart(request, response);
        } else if ("update".equals(action)) {
            updateCart(request, response);
        } else if ("remove".equals(action)) {
            removeFromCart(request, response);
        }
    }

    private void addToCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            String note = request.getParameter("note");

            MenuItem item = menuDAO.getMenuItemById(itemId);

            Map<String, Object> result = new HashMap<>();

            if (item != null) {
                HttpSession session = request.getSession();

                @SuppressWarnings("unchecked")
                Map<Integer, Map<String, Object>> cart =
                        (Map<Integer, Map<String, Object>>) session.getAttribute("cart");

                if (cart == null) {
                    cart = new HashMap<>();
                }

                if (cart.containsKey(itemId)) {
                    Map<String, Object> cartItem = cart.get(itemId);
                    int currentQty = (int) cartItem.get("quantity");
                    cartItem.put("quantity", currentQty + quantity);
                } else {
                    Map<String, Object> cartItem = new HashMap<>();
                    cartItem.put("item", item);
                    cartItem.put("quantity", quantity);
                    cartItem.put("note", note != null ? note : "");
                    cart.put(itemId, cartItem);
                }

                session.setAttribute("cart", cart);
                session.setAttribute("cartSize", cart.size());

                result.put("success", true);
                result.put("message", "Đã thêm vào giỏ hàng!");
                result.put("cartSize", cart.size());
            } else {
                result.put("success", false);
                result.put("message", "Món ăn không tồn tại!");
            }
            
            response.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "Có lỗi xảy ra: " + e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }

    private void updateCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            HttpSession session = request.getSession();

            @SuppressWarnings("unchecked")
            Map<Integer, Map<String, Object>> cart =
                    (Map<Integer, Map<String, Object>>) session.getAttribute("cart");

            Map<String, Object> result = new HashMap<>();

            if (cart != null && cart.containsKey(itemId)) {
                if (quantity > 0) {
                    cart.get(itemId).put("quantity", quantity);
                } else {
                    cart.remove(itemId);
                }

                session.setAttribute("cart", cart);
                session.setAttribute("cartSize", cart.size());

                result.put("success", true);
                result.put("cartSize", cart.size());
            } else {
                result.put("success", false);
                result.put("message", "Món không tồn tại trong giỏ hàng");
            }
            
            response.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }

    private void removeFromCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));

            HttpSession session = request.getSession();

            @SuppressWarnings("unchecked")
            Map<Integer, Map<String, Object>> cart =
                    (Map<Integer, Map<String, Object>>) session.getAttribute("cart");

            Map<String, Object> result = new HashMap<>();

            if (cart != null) {
                cart.remove(itemId);
                session.setAttribute("cart", cart);
                session.setAttribute("cartSize", cart.size());

                result.put("success", true);
                result.put("cartSize", cart.size());
            } else {
                result.put("success", false);
                result.put("message", "Giỏ hàng trống");
            }
            
            response.getWriter().write(gson.toJson(result));
        } catch (Exception e) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", e.getMessage());
            response.getWriter().write(gson.toJson(result));
        }
    }
}