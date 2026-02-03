<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Gọi món - Nhân viên</title>
  <style>
    .box{max-width:900px;margin:40px auto;padding:24px;border:1px solid #eee;border-radius:12px;background:#fff}
    .btn{padding:10px 14px;border:0;border-radius:8px;background:#5b6dff;color:#fff;cursor:pointer}
    select{padding:10px;border-radius:8px;border:1px solid #ddd;width:260px}
  </style>
</head>
<body>
<%@ include file="../Common/header.jsp" %>

<div class="box">
  <h2>🍽️ Gọi món (Dine-in)</h2>
  <p>Chọn bàn để bắt đầu gọi món.</p>

  <form action="${pageContext.request.contextPath}/staff/dinein/menu" method="get">
    <label>Chọn bàn:</label>

    <select name="tableId" required>
      <option value="">-- chọn bàn --</option>

      <c:forEach var="t" items="${tables}">
        <option value="${t.tableId}">
          ${t.tableNumber} (Sức chứa: ${t.capacity})
        </option>
      </c:forEach>
    </select>

    <input type="hidden" name="mode" value="DINEIN"/>
    <button class="btn" type="submit">Bắt đầu gọi món</button>
  </form>

  <c:if test="${empty tables}">
    <p style="margin-top:12px;color:#e53e3e;font-weight:600;">
      Không có bàn trống (available) để gọi món.
    </p>
  </c:if>
</div>
</body>
</html>
