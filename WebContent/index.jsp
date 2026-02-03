<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (session.getAttribute("user") != null) {
        String roleName = (String) session.getAttribute("roleName");
        if ("admin".equals(roleName)) {
            response.sendRedirect(request.getContextPath() + "/admin");
        } else if ("employee".equals(roleName)) {
            response.sendRedirect(request.getContextPath() + "/employee");
        } else if ("customer".equals(roleName)) {
            response.sendRedirect(request.getContextPath() + "/menu");
        }
    } else {
        response.sendRedirect(request.getContextPath() + "/login");
    }
%>