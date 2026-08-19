-- ============================================================
-- E-Commerce Sales & Customer Analytics System
-- MySQL Project | Fresher / Intermediate Level
-- ============================================================

DROP DATABASE IF EXISTS ecommerce_analytics;
CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE,
    city VARCHAR(60),
    state VARCHAR(60),
    signup_date DATE NOT NULL
);

-- 2. CATEGORIES
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(80) UNIQUE NOT NULL
);

-- 3. PRODUCTS
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(120) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_qty INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 4. ORDERS
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status ENUM('Completed','Pending','Cancelled') DEFAULT 'Pending',
    payment_method ENUM('UPI','Card','Cash','Net Banking') NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 5. ORDER ITEMS
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ----------------------------
-- SAMPLE DATA
-- ----------------------------

INSERT INTO categories (category_name) VALUES
('Electronics'),
('Mobile Accessories'),
('Home Appliances'),
('Computer Accessories'),
('Audio');

INSERT INTO customers (customer_name,email,city,state,signup_date) VALUES
('Aarav Sharma','aarav@gmail.com','Pune','Maharashtra','2025-01-15'),
('Riya Patil','riya@gmail.com','Mumbai','Maharashtra','2025-02-10'),
('Karan Verma','karan@gmail.com','Nagpur','Maharashtra','2025-02-22'),
('Sneha Joshi','sneha@gmail.com','Nashik','Maharashtra','2025-03-05'),
('Rahul Khan','rahul@gmail.com','Aurangabad','Maharashtra','2025-03-18'),
('Priya Shah','priya@gmail.com','Ahmedabad','Gujarat','2025-04-02'),
('Aditya Mehta','aditya@gmail.com','Surat','Gujarat','2025-04-20'),
('Neha Singh','neha@gmail.com','Indore','Madhya Pradesh','2025-05-01'),
('Zaid Sheikh','zaid@gmail.com','Hyderabad','Telangana','2025-05-15'),
('Ananya Roy','ananya@gmail.com','Kolkata','West Bengal','2025-06-03');

INSERT INTO products (product_name,category_id,price,stock_qty) VALUES
('Wireless Mouse',4,799.00,80),
('Mechanical Keyboard',4,2499.00,45),
('USB-C Hub',4,1599.00,60),
('Bluetooth Speaker',5,1999.00,40),
('Wireless Earbuds',5,2999.00,55),
('Power Bank 20000mAh',2,1799.00,70),
('Phone Cover',2,499.00,120),
('Fast Charger 33W',2,899.00,90),
('Smart LED TV',3,24999.00,20),
('Air Fryer',3,5499.00,25),
('Smartphone',1,28999.00,30),
('Smart Watch',1,4999.00,50);

INSERT INTO orders (customer_id,order_date,status,payment_method) VALUES
(1,'2025-07-01','Completed','UPI'),
(2,'2025-07-03','Completed','Card'),
(3,'2025-07-05','Completed','UPI'),
(4,'2025-07-08','Cancelled','Card'),
(5,'2025-07-10','Completed','Cash'),
(6,'2025-07-14','Completed','Net Banking'),
(7,'2025-07-18','Pending','UPI'),
(8,'2025-07-20','Completed','Card'),
(9,'2025-07-25','Completed','UPI'),
(10,'2025-07-28','Completed','Card'),
(1,'2025-08-02','Completed','UPI'),
(3,'2025-08-04','Completed','Net Banking'),
(5,'2025-08-06','Pending','Card'),
(9,'2025-08-09','Completed','UPI'),
(2,'2025-08-12','Completed','Card');

INSERT INTO order_items (order_id,product_id,quantity,unit_price,discount) VALUES
(1,1,2,799,5),
(1,8,1,899,0),
(2,5,1,2999,10),
(2,7,2,499,0),
(3,2,1,2499,5),
(3,3,1,1599,0),
(4,11,1,28999,8),
(5,10,1,5499,5),
(5,7,2,499,0),
(6,9,1,24999,10),
(7,12,1,4999,0),
(8,4,2,1999,5),
(8,6,1,1799,0),
(9,11,1,28999,7),
(9,8,2,899,0),
(10,5,2,2999,5),
(10,1,1,799,0),
(11,12,1,4999,10),
(11,3,2,1599,0),
(12,10,1,5499,0),
(12,2,1,2499,5),
(13,6,2,1799,0),
(14,11,1,28999,8),
(14,5,1,2999,0),
(15,9,1,24999,5);

-- ============================================================
-- BUSINESS QUERIES
-- ============================================================

-- Q1. Total revenue from completed orders
SELECT ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed';

-- Q2. Revenue by category
SELECT c.category_name,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY c.category_id, c.category_name
ORDER BY revenue DESC;

-- Q3. Top 5 products by revenue
SELECT p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- Q4. Top customers by spending
SELECT c.customer_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- Q5. Monthly revenue
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY month;

-- Q6. Customers who spent above average customer spending
SELECT customer_name, total_spent
FROM (
    SELECT c.customer_id,
           c.customer_name,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
) AS customer_sales
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT c2.customer_id,
               SUM(oi2.quantity * oi2.unit_price * (1 - oi2.discount/100)) AS total_spent
        FROM customers c2
        JOIN orders o2 ON c2.customer_id = o2.customer_id
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        WHERE o2.status = 'Completed'
        GROUP BY c2.customer_id
    ) AS avg_sales
);

-- Q7. Products that have never been ordered
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- Q8. Order value / average order value
SELECT ROUND(SUM(order_total),2) AS total_completed_sales,
       ROUND(AVG(order_total),2) AS average_order_value
FROM (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY o.order_id
) AS order_values;

-- Q9. Order status summary
SELECT status, COUNT(*) AS order_count
FROM orders
GROUP BY status;

-- Q10. Payment method performance
SELECT payment_method,
       COUNT(*) AS completed_orders,
       ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY payment_method
ORDER BY revenue DESC;


-- VIEW: completed order details
CREATE OR REPLACE VIEW completed_order_details AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_name,
    c.city,
    p.product_name,
    cat.category_name,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    ROUND(oi.quantity * oi.unit_price * (1 - oi.discount/100),2) AS line_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
WHERE o.status = 'Completed';

-- Use the view
SELECT * FROM completed_order_details;

-- CTE: customer revenue ranking
WITH customer_revenue AS (
    SELECT c.customer_id,
           c.customer_name,
           ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_name,
       revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;

-- WINDOW FUNCTION: product sales ranking within category
SELECT
    cat.category_name,
    p.product_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS revenue,
    DENSE_RANK() OVER (
        PARTITION BY cat.category_id
        ORDER BY SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) DESC
    ) AS category_rank
FROM categories cat
JOIN products p ON cat.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.status = 'Completed'
GROUP BY cat.category_id, cat.category_name, p.product_id, p.product_name
ORDER BY cat.category_name, category_rank;

-- CASE: customer segmentation
SELECT
    c.customer_name,
    ROUND(SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)),2) AS total_spent,
    CASE
        WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) >= 25000 THEN 'Platinum'
        WHEN SUM(oi.quantity * oi.unit_price * (1 - oi.discount/100)) >= 10000 THEN 'Gold'
        ELSE 'Silver'
    END AS customer_segment
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- Stored Procedure: get customer purchase history
DELIMITER //
CREATE PROCEDURE GetCustomerPurchaseHistory(IN p_customer_id INT)
BEGIN
    SELECT
        c.customer_name,
        o.order_id,
        o.order_date,
        o.status,
        p.product_name,
        oi.quantity,
        ROUND(oi.quantity * oi.unit_price * (1 - oi.discount/100),2) AS line_total
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE c.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END //
DELIMITER ;

-- Example:
CALL GetCustomerPurchaseHistory(1);

-- ============================================================
-- PROJECT COMPLETE
-- ============================================================
