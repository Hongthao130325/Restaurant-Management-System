# Restaurant Management System

## Description
Restaurant Management System is a web-based application developed using **Java Servlet, JSP, and JDBC**, deployed on **Apache Tomcat**.  
The system is designed for small restaurants to manage daily operations such as menu management, order processing, and user access control.

The project follows the **MVC (Model - View - Controller)** architecture to separate business logic, data access, and presentation layers, making the system easier to maintain and extend.

---

## Technologies Used
- Java Servlet & JSP
- JDBC (MySQL)
- Apache Tomcat
- HTML, CSS, JavaScript
- MVC Design Pattern

---

## Project Structure
- `controller/` – Servlet controllers handling requests
- `dao/` – Data Access Objects for database operations
- `model/` – Entity classes
- `filter/` – Authentication and role filters
- `util/` – Database and utility classes
- `views/` – JSP pages for UI
- `assets/` – CSS, JavaScript, and images

---


## Features

### Authentication & Authorization
- User login and registration
- Role-based access control (Admin, Employee, Customer)

### Admin Functions
- Manage menu items (add, update, delete)
- Manage user accounts
- View orders and sales reports

### Employee Functions
- View customer orders
- Call and process in-store orders

### Customer Functions
- Browse menu
- Add items to cart
- Place orders online
- View order history

---

## How to Run
1. Import the project into Eclipse (Dynamic Web Project)
2. Configure Apache Tomcat server
3. Set up MySQL database and update database connection in `DBConnection.java`
4. Run the project on Tomcat
5. Access the system via browser

---

## Notes
This project is suitable for academic purposes and small-scale restaurant management.
