-- ================================================================
-- SQL-A-Day - DAY 73
-- Topic: SQL Query Optimization & Execution Plans
-- Database: sql_optimization_lab
-- SQL Dialect: MySQL 8+
-- ================================================================

DROP DATABASE IF EXISTS sql_optimization_lab;
CREATE DATABASE sql_optimization_lab;
USE sql_optimization_lab;

-- ================================================================
-- 1. CUSTOMERS
-- ================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    customer_type ENUM('REGULAR', 'PREMIUM', 'VIP') NOT NULL DEFAULT 'REGULAR',
    signup_date DATE NOT NULL,
    INDEX idx_customers_city (city),
    INDEX idx_customers_type (customer_type)
) ENGINE=InnoDB;

-- ================================================================
-- 2. PRODUCTS
-- ================================================================

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(80) NOT NULL,
    brand VARCHAR(80) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    stock_quantity INT NOT NULL,
    INDEX idx_products_category (category),
    INDEX idx_products_brand (brand),
    INDEX idx_products_category_price (category, price)
) ENGINE=InnoDB;

-- ================================================================
-- 3. ORDERS
-- ================================================================

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    status ENUM('PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED') NOT NULL,
    total_amount DECIMAL(14,2) NOT NULL,
    shipping_city VARCHAR(80) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_date (order_date),
    INDEX idx_orders_status (status),
    INDEX idx_orders_customer_date (customer_id, order_date)
) ENGINE=InnoDB;

-- ================================================================
-- 4. ORDER ITEMS
-- ================================================================

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id),
    INDEX idx_order_items_product_order (product_id, order_id)
) ENGINE=InnoDB;

-- ================================================================
-- 5. SAMPLE CUSTOMERS
-- ================================================================

INSERT INTO customers
(customer_name, email, city, state, customer_type, signup_date)
VALUES
('Arjun Reddy', 'arjun@example.com', 'Hyderabad', 'Telangana', 'VIP', '2023-01-15'),
('Priya Nair', 'priya@example.com', 'Bengaluru', 'Karnataka', 'PREMIUM', '2023-02-20'),
('Rahul Sharma', 'rahul@example.com', 'Mumbai', 'Maharashtra', 'REGULAR', '2023-03-12'),
('Sneha Rao', 'sneha@example.com', 'Hyderabad', 'Telangana', 'PREMIUM', '2023-04-08'),
('Vikram Kumar', 'vikram@example.com', 'Chennai', 'Tamil Nadu', 'REGULAR', '2023-05-18'),
('Ananya Singh', 'ananya@example.com', 'Delhi', 'Delhi', 'VIP', '2023-06-25'),
('Kiran Patel', 'kiran@example.com', 'Ahmedabad', 'Gujarat', 'REGULAR', '2023-07-10'),
('Meera Das', 'meera@example.com', 'Kolkata', 'West Bengal', 'PREMIUM', '2023-08-14'),
('Rohit Verma', 'rohit@example.com', 'Pune', 'Maharashtra', 'REGULAR', '2023-09-21'),
('Divya Iyer', 'divya@example.com', 'Bengaluru', 'Karnataka', 'VIP', '2023-10-05');

-- ================================================================
-- 6. SAMPLE PRODUCTS
-- ================================================================

INSERT INTO products
(product_name, category, brand, price, stock_quantity)
VALUES
('Pro Laptop 14', 'Laptops', 'TechPro', 85000, 50),
('Gaming Laptop X', 'Laptops', 'GameMax', 125000, 25),
('Business Laptop B', 'Laptops', 'OfficeTech', 95000, 40),
('4K Monitor 27', 'Monitors', 'ViewMax', 32000, 70),
('Ultrawide Monitor 34', 'Monitors', 'ViewMax', 55000, 35),
('Mechanical Keyboard', 'Accessories', 'KeyMaster', 7500, 120),
('Wireless Mouse', 'Accessories', 'ClickPro', 2500, 200),
('Noise Cancelling Headphones', 'Audio', 'SoundMax', 18000, 80),
('USB-C Dock', 'Accessories', 'ConnectPro', 12000, 60),
('Tablet Pro', 'Tablets', 'TechPro', 60000, 45);

-- ================================================================
-- 7. SAMPLE ORDERS
-- ================================================================

INSERT INTO orders
(customer_id, order_date, status, total_amount, shipping_city)
VALUES
(1, '2025-01-05 10:30:00', 'DELIVERED', 85000, 'Hyderabad'),
(2, '2025-01-08 12:15:00', 'SHIPPED', 32000, 'Bengaluru'),
(3, '2025-01-12 15:40:00', 'PAID', 7500, 'Mumbai'),
(4, '2025-01-18 09:25:00', 'DELIVERED', 125000, 'Hyderabad'),
(5, '2025-02-03 14:10:00', 'CANCELLED', 18000, 'Chennai'),
(6, '2025-02-15 11:45:00', 'DELIVERED', 95000, 'Delhi'),
(7, '2025-02-22 16:20:00', 'SHIPPED', 2500, 'Ahmedabad'),
(8, '2025-03-01 13:05:00', 'DELIVERED', 55000, 'Kolkata'),
(9, '2025-03-10 17:35:00', 'PAID', 12000, 'Pune'),
(10, '2025-03-15 10:05:00', 'DELIVERED', 60000, 'Bengaluru'),
(1, '2025-04-02 11:20:00', 'DELIVERED', 32000, 'Hyderabad'),
(2, '2025-04-09 15:15:00', 'SHIPPED', 18000, 'Bengaluru'),
(3, '2025-04-16 12:40:00', 'DELIVERED', 7500, 'Mumbai'),
(4, '2025-05-03 09:55:00', 'DELIVERED', 85000, 'Hyderabad'),
(5, '2025-05-12 14:30:00', 'PAID', 2500, 'Chennai'),
(6, '2025-05-20 16:45:00', 'DELIVERED', 125000, 'Delhi'),
(7, '2025-06-04 10:15:00', 'SHIPPED', 12000, 'Ahmedabad'),
(8, '2025-06-18 13:50:00', 'DELIVERED', 32000, 'Kolkata'),
(9, '2025-07-02 17:10:00', 'PAID', 95000, 'Pune'),
(10, '2025-07-15 11:35:00', 'DELIVERED', 55000, 'Bengaluru');

-- ================================================================
-- 8. SAMPLE ORDER ITEMS
-- ================================================================

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 85000),
(2, 4, 1, 32000),
(3, 6, 1, 7500),
(4, 2, 1, 125000),
(5, 8, 1, 18000),
(6, 3, 1, 95000),
(7, 7, 1, 2500),
(8, 5, 1, 55000),
(9, 9, 1, 12000),
(10, 10, 1, 60000),
(11, 4, 1, 32000),
(12, 8, 1, 18000),
(13, 6, 1, 7500),
(14, 1, 1, 85000),
(15, 7, 1, 2500),
(16, 2, 1, 125000),
(17, 9, 1, 12000),
(18, 4, 1, 32000),
(19, 3, 1, 95000),
(20, 5, 1, 55000);

-- ================================================================
-- 9. BASELINE QUERY
-- ================================================================

SELECT customer_id, customer_name, city, customer_type
FROM customers
WHERE city = 'Hyderabad';

-- ================================================================
-- 10. EXPLAIN FILTER QUERY
-- ================================================================

EXPLAIN
SELECT *
FROM customers
WHERE city = 'Hyderabad';

-- ================================================================
-- 11. EXPLAIN CUSTOMER ORDER QUERY
-- ================================================================

EXPLAIN
SELECT order_id, order_date, total_amount, status
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- ================================================================
-- 12. EXPLAIN DATE RANGE QUERY
-- ================================================================

EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE order_date >= '2025-01-01'
  AND order_date < '2025-04-01';

-- ================================================================
-- 13. EXPLAIN TWO-TABLE JOIN
-- ================================================================

EXPLAIN
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount
FROM orders AS o
INNER JOIN customers AS c
    ON c.customer_id = o.customer_id
WHERE c.city = 'Hyderabad';

-- ================================================================
-- 14. EXPLAIN MULTI-TABLE JOIN
-- ================================================================

EXPLAIN
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders AS o
INNER JOIN customers AS c
    ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi
    ON oi.order_id = o.order_id
INNER JOIN products AS p
    ON p.product_id = oi.product_id
WHERE c.city = 'Hyderabad'
  AND p.category = 'Laptops';

-- ================================================================
-- 15. SARGABLE DATE FILTER
-- ================================================================

EXPLAIN
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_date >= '2025-04-01'
  AND order_date < '2025-05-01';

-- ================================================================
-- 16. NON-SARGABLE DATE FILTER
-- ================================================================

EXPLAIN
SELECT order_id, order_date, total_amount
FROM orders
WHERE DATE(order_date) = '2025-04-01';

-- ================================================================
-- 17. SELECT * VS REQUIRED COLUMNS
-- ================================================================

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1;

EXPLAIN
SELECT order_id, order_date, total_amount
FROM orders
WHERE customer_id = 1;

-- ================================================================
-- 18. EXISTS VS IN
-- ================================================================

EXPLAIN
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders AS o
    WHERE o.status = 'DELIVERED'
);

EXPLAIN
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'DELIVERED'
);

-- ================================================================
-- 19. UNION VS UNION ALL
-- ================================================================

EXPLAIN
SELECT city
FROM customers
WHERE customer_type = 'VIP'
UNION
SELECT city
FROM customers
WHERE customer_type = 'PREMIUM';

EXPLAIN
SELECT city
FROM customers
WHERE customer_type = 'VIP'
UNION ALL
SELECT city
FROM customers
WHERE customer_type = 'PREMIUM';

-- ================================================================
-- 20. COMPOSITE INDEX
-- ================================================================

CREATE INDEX idx_orders_status_date
ON orders(status, order_date);

EXPLAIN
SELECT order_id, order_date, total_amount
FROM orders
WHERE status = 'DELIVERED'
  AND order_date >= '2025-01-01'
  AND order_date < '2025-08-01';

-- ================================================================
-- 21. COMPOSITE INDEX WITH CUSTOMER + DATE
-- ================================================================

EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE customer_id = 1
  AND order_date >= '2025-01-01'
  AND order_date < '2025-08-01';

-- ================================================================
-- 22. COVERING-STYLE INDEX
-- ================================================================

CREATE INDEX idx_orders_customer_cover
ON orders(customer_id, order_date, status, total_amount);

EXPLAIN
SELECT order_id, order_date, status, total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- ================================================================
-- 23. GROUP BY
-- ================================================================

EXPLAIN
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY customer_id;

-- ================================================================
-- 24. FILTER BEFORE AGGREGATION
-- ================================================================

EXPLAIN
SELECT
    customer_id,
    COUNT(*) AS delivered_orders,
    SUM(total_amount) AS delivered_revenue
FROM orders
WHERE status = 'DELIVERED'
GROUP BY customer_id;

-- ================================================================
-- 25. ORDER BY + LIMIT
-- ================================================================

EXPLAIN
SELECT order_id, customer_id, order_date, total_amount
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC
LIMIT 5;

-- ================================================================
-- 26. TOP PRODUCTS
-- ================================================================

EXPLAIN
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items AS oi
INNER JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- ================================================================
-- 27. PRODUCT FILTER WITH COMPOSITE INDEX
-- ================================================================

EXPLAIN
SELECT product_id, product_name, category, price
FROM products
WHERE category = 'Laptops'
  AND price BETWEEN 80000 AND 130000
ORDER BY price DESC;

-- ================================================================
-- 28. CORRELATED SUBQUERY
-- ================================================================

EXPLAIN
SELECT c.customer_id, c.customer_name
FROM customers AS c
WHERE (
    SELECT COUNT(*)
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
) >= 2;

-- ================================================================
-- 29. JOIN + GROUP BY ALTERNATIVE
-- ================================================================

EXPLAIN
SELECT c.customer_id, c.customer_name
FROM customers AS c
INNER JOIN orders AS o
    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(*) >= 2;

-- ================================================================
-- 30. EXPLAIN ANALYZE
--    Requires MySQL 8.0.18+
-- ================================================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount
FROM orders AS o
INNER JOIN customers AS c
    ON c.customer_id = o.customer_id
WHERE o.customer_id = 1
ORDER BY o.order_date DESC;

-- ================================================================
-- 31. EXPLAIN ANALYZE WITH AGGREGATION
-- ================================================================

EXPLAIN ANALYZE
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue
FROM orders
WHERE status = 'DELIVERED'
GROUP BY customer_id;

-- ================================================================
-- 32. FUNCTION ON INDEXED COLUMN
-- ================================================================

EXPLAIN
SELECT order_id, order_date, total_amount
FROM orders
WHERE YEAR(order_date) = 2025;

-- ================================================================
-- 33. REWRITTEN RANGE VERSION
-- ================================================================

EXPLAIN
SELECT order_id, order_date, total_amount
FROM orders
WHERE order_date >= '2025-01-01'
  AND order_date < '2026-01-01';

-- ================================================================
-- 34. INSPECT INDEXES
-- ================================================================

SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('customers', 'products', 'orders', 'order_items')
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ================================================================
-- 35. INSPECT TABLE AND INDEX SIZE
-- ================================================================

SELECT
    TABLE_NAME,
    TABLE_ROWS,
    ROUND(DATA_LENGTH / 1024, 2) AS data_kb,
    ROUND(INDEX_LENGTH / 1024, 2) AS index_kb
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = DATABASE()
ORDER BY DATA_LENGTH DESC;

-- ================================================================
-- 36. FINAL PRODUCTION-STYLE REPORT QUERY
-- ================================================================

EXPLAIN ANALYZE
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS delivered_orders,
    SUM(o.total_amount) AS total_revenue
FROM customers AS c
INNER JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.status = 'DELIVERED'
  AND o.order_date >= '2025-01-01'
  AND o.order_date < '2026-01-01'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC;

-- ================================================================
-- 37. FINAL RESULT QUERY
-- ================================================================

SELECT
    c.customer_name,
    c.customer_type,
    COUNT(o.order_id) AS delivered_orders,
    COALESCE(SUM(o.total_amount), 0) AS delivered_revenue
FROM customers AS c
LEFT JOIN orders AS o
    ON o.customer_id = c.customer_id
   AND o.status = 'DELIVERED'
GROUP BY c.customer_id, c.customer_name, c.customer_type
ORDER BY delivered_revenue DESC;

-- ================================================================
-- END OF DAY 73
-- ================================================================
