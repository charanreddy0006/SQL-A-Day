-- ================================================================
-- SQL-A-Day - DAY 70
-- Topic: Advanced SQL Query Optimization
-- Database: sql_query_optimization_lab
-- SQL Dialect: MySQL 8+
-- ================================================================

DROP DATABASE IF EXISTS sql_query_optimization_lab;
CREATE DATABASE sql_query_optimization_lab;
USE sql_query_optimization_lab;

-- ================================================================
-- 1. TABLE CREATION
-- ================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    customer_status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    registration_date DATETIME NOT NULL,
    INDEX idx_customers_city (city),
    INDEX idx_customers_state (state),
    INDEX idx_customers_status (customer_status),
    INDEX idx_customers_registration_date (registration_date)
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    category_status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    UNIQUE KEY uk_category_name (category_name)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    brand VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    product_status ENUM('Available', 'Out of Stock', 'Discontinued')
        NOT NULL DEFAULT 'Available',
    created_at DATETIME NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_products_category (category_id),
    INDEX idx_products_brand (brand),
    INDEX idx_products_price (price),
    INDEX idx_products_status (product_status),
    INDEX idx_products_category_price (category_id, price),
    INDEX idx_products_created_at (created_at)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_status ENUM(
        'Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'
    ) NOT NULL DEFAULT 'Pending',
    total_amount DECIMAL(12,2) NOT NULL,
    shipping_city VARCHAR(80) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_date (order_date),
    INDEX idx_orders_status (order_status),
    INDEX idx_orders_customer_date (customer_id, order_date),
    INDEX idx_orders_status_date (order_status, order_date)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id)
) ENGINE=InnoDB;

-- ================================================================
-- 2. SAMPLE DATA
-- ================================================================

INSERT INTO customers
(customer_name, email, city, state, customer_status, registration_date)
VALUES
('Arjun Reddy', 'arjun@example.com', 'Hyderabad', 'Telangana', 'Active', '2025-01-05 10:15:00'),
('Priya Sharma', 'priya@example.com', 'Bengaluru', 'Karnataka', 'Active', '2025-01-12 11:30:00'),
('Rahul Verma', 'rahul@example.com', 'Mumbai', 'Maharashtra', 'Active', '2025-02-01 09:20:00'),
('Sneha Rao', 'sneha@example.com', 'Chennai', 'Tamil Nadu', 'Active', '2025-02-18 15:45:00'),
('Kiran Kumar', 'kiran@example.com', 'Pune', 'Maharashtra', 'Inactive', '2025-03-03 13:00:00'),
('Ananya Singh', 'ananya@example.com', 'Delhi', 'Delhi', 'Active', '2025-03-20 17:10:00'),
('Vikram Das', 'vikram@example.com', 'Kolkata', 'West Bengal', 'Active', '2025-04-02 12:40:00'),
('Meera Nair', 'meera@example.com', 'Kochi', 'Kerala', 'Active', '2025-04-15 14:30:00'),
('Rohit Patel', 'rohit@example.com', 'Ahmedabad', 'Gujarat', 'Active', '2025-05-01 10:00:00'),
('Divya Reddy', 'divya@example.com', 'Warangal', 'Telangana', 'Active', '2025-05-22 16:20:00'),
('Nikhil Rao', 'nikhil@example.com', 'Hyderabad', 'Telangana', 'Active', '2025-06-10 11:25:00'),
('Keerthi Das', 'keerthi@example.com', 'Bengaluru', 'Karnataka', 'Active', '2025-06-18 09:50:00'),
('Manoj Gupta', 'manoj@example.com', 'Jaipur', 'Rajasthan', 'Inactive', '2025-07-05 18:00:00'),
('Asha Menon', 'asha@example.com', 'Kochi', 'Kerala', 'Active', '2025-07-20 13:15:00'),
('Varun Shah', 'varun@example.com', 'Mumbai', 'Maharashtra', 'Active', '2025-08-02 10:40:00');

INSERT INTO categories (category_name, category_status)
VALUES
('Laptop', 'Active'),
('Mobile', 'Active'),
('Monitor', 'Active'),
('Accessories', 'Active'),
('Audio', 'Active'),
('Tablet', 'Active');

INSERT INTO products
(product_name, category_id, brand, price, stock_quantity, product_status, created_at)
VALUES
('Laptop Pro 14', 1, 'TechPro', 85000, 25, 'Available', '2025-01-10 10:00:00'),
('Laptop Air 13', 1, 'TechPro', 72000, 35, 'Available', '2025-01-20 10:00:00'),
('Gaming Laptop X', 1, 'GameMax', 125000, 12, 'Available', '2025-02-05 10:00:00'),
('Business Laptop B', 1, 'OfficeTech', 65000, 28, 'Available', '2025-02-15 10:00:00'),
('Smartphone X', 2, 'MobileMax', 55000, 50, 'Available', '2025-03-01 10:00:00'),
('Smartphone Lite', 2, 'MobileMax', 22000, 90, 'Available', '2025-03-10 10:00:00'),
('Smartphone Pro', 2, 'TechPro', 78000, 18, 'Available', '2025-03-20 10:00:00'),
('4K Monitor', 3, 'ViewMax', 28000, 40, 'Available', '2025-04-01 10:00:00'),
('Office Monitor', 3, 'ViewMax', 15000, 60, 'Available', '2025-04-10 10:00:00'),
('Ultrawide Monitor', 3, 'ScreenPro', 45000, 20, 'Available', '2025-04-20 10:00:00'),
('Mechanical Keyboard', 4, 'KeyMaster', 4500, 80, 'Available', '2025-05-01 10:00:00'),
('Wireless Mouse', 4, 'ClickPro', 1500, 150, 'Available', '2025-05-05 10:00:00'),
('USB-C Hub', 4, 'ConnectX', 3500, 100, 'Available', '2025-05-15 10:00:00'),
('Gaming Headset', 5, 'GameMax', 8000, 45, 'Available', '2025-06-01 10:00:00'),
('Noise Cancelling Headphones', 5, 'SoundPro', 18000, 35, 'Available', '2025-06-10 10:00:00'),
('Bluetooth Speaker', 5, 'SoundPro', 6500, 55, 'Available', '2025-06-20 10:00:00'),
('Tablet 11', 6, 'TechPro', 32000, 20, 'Available', '2025-07-01 10:00:00'),
('Tablet Pro', 6, 'TechPro', 52000, 15, 'Available', '2025-07-15 10:00:00');

INSERT INTO orders
(customer_id, order_date, order_status, total_amount, shipping_city)
VALUES
(1, '2025-08-01 10:30:00', 'Delivered', 90000, 'Hyderabad'),
(2, '2025-08-05 12:00:00', 'Shipped', 4500, 'Bengaluru'),
(3, '2025-08-09 14:20:00', 'Delivered', 28000, 'Mumbai'),
(4, '2025-08-12 09:15:00', 'Confirmed', 72000, 'Chennai'),
(6, '2025-08-15 16:10:00', 'Delivered', 18000, 'Delhi'),
(7, '2025-08-18 11:00:00', 'Pending', 125000, 'Kolkata'),
(8, '2025-08-20 13:45:00', 'Delivered', 6500, 'Kochi'),
(9, '2025-08-22 17:30:00', 'Confirmed', 55000, 'Ahmedabad'),
(10, '2025-08-24 15:00:00', 'Delivered', 32000, 'Warangal'),
(1, '2025-08-25 10:00:00', 'Pending', 15000, 'Hyderabad'),
(11, '2025-08-26 11:20:00', 'Delivered', 125000, 'Hyderabad'),
(12, '2025-08-27 12:10:00', 'Shipped', 22000, 'Bengaluru'),
(14, '2025-08-28 13:30:00', 'Delivered', 45000, 'Kochi'),
(15, '2025-08-29 14:40:00', 'Confirmed', 78000, 'Mumbai'),
(2, '2025-08-30 16:00:00', 'Delivered', 18000, 'Bengaluru');

INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 85000),
(1, 12, 2, 1500),
(2, 11, 1, 4500),
(3, 8, 1, 28000),
(4, 2, 1, 72000),
(5, 15, 1, 18000),
(6, 3, 1, 125000),
(7, 16, 1, 6500),
(8, 5, 1, 55000),
(9, 17, 1, 32000),
(10, 9, 1, 15000),
(11, 3, 1, 125000),
(12, 6, 1, 22000),
(13, 10, 1, 45000),
(14, 7, 1, 78000),
(15, 15, 1, 18000);

-- ================================================================
-- 3. BASIC QUERY PLAN ANALYSIS
-- ================================================================

EXPLAIN
SELECT *
FROM products
WHERE category_id = 1
AND price > 70000;

EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
WHERE category_id = 1
AND price > 70000;

-- ================================================================
-- 4. WHERE VS HAVING
-- ================================================================

SELECT
    customer_id,
    SUM(total_amount) AS total_spent
FROM orders
WHERE order_status = 'Delivered'
GROUP BY customer_id
HAVING SUM(total_amount) > 50000;

-- ================================================================
-- 5. JOIN OPTIMIZATION
-- ================================================================

EXPLAIN
SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered';

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Delivered'
AND o.order_date >= '2025-08-01';

-- ================================================================
-- 6. SUBQUERY VS JOIN
-- ================================================================

SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > 50000
);

SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.total_amount > 50000;

EXPLAIN
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    WHERE total_amount > 50000
);

EXPLAIN
SELECT DISTINCT
    c.customer_id,
    c.customer_name
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.total_amount > 50000;

-- ================================================================
-- 7. EXISTS VS IN
-- ================================================================

SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
    AND o.order_status = 'Delivered'
);

SELECT
    c.customer_id,
    c.customer_name
FROM customers AS c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders AS o
    WHERE o.order_status = 'Delivered'
);

-- ================================================================
-- 8. CTE OPTIMIZATION PATTERN
-- ================================================================

WITH delivered_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        total_amount
    FROM orders
    WHERE order_status = 'Delivered'
),
customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS revenue
    FROM delivered_orders
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    cr.revenue
FROM customer_revenue AS cr
JOIN customers AS c
    ON c.customer_id = cr.customer_id
ORDER BY cr.revenue DESC;

-- ================================================================
-- 9. SARGABLE DATE FILTERING
-- ================================================================

EXPLAIN
SELECT *
FROM orders
WHERE DATE(order_date) = '2025-08-20';

EXPLAIN
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_date >= '2025-08-20 00:00:00'
AND order_date < '2025-08-21 00:00:00';

-- ================================================================
-- 10. LIKE PATTERNS
-- ================================================================

EXPLAIN
SELECT product_id, product_name
FROM products
WHERE product_name LIKE 'Laptop%';

EXPLAIN
SELECT product_id, product_name
FROM products
WHERE product_name LIKE '%Laptop%';

-- ================================================================
-- 11. UNION VS UNION ALL
-- ================================================================

EXPLAIN
SELECT city
FROM customers
WHERE state = 'Telangana'
UNION
SELECT city
FROM customers
WHERE state = 'Karnataka';

EXPLAIN
SELECT city
FROM customers
WHERE state = 'Telangana'
UNION ALL
SELECT city
FROM customers
WHERE state = 'Karnataka';

-- ================================================================
-- 12. ORDER BY AND LIMIT
-- ================================================================

EXPLAIN
SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY price DESC
LIMIT 5;

SELECT
    product_id,
    product_name,
    price
FROM products
ORDER BY price DESC
LIMIT 5;

-- ================================================================
-- 13. AGGREGATION
-- ================================================================

EXPLAIN
SELECT
    category_id,
    COUNT(*) AS product_count,
    AVG(price) AS average_price,
    MAX(price) AS maximum_price
FROM products
GROUP BY category_id;

SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count,
    AVG(p.price) AS average_price,
    MAX(p.price) AS maximum_price
FROM categories AS c
LEFT JOIN products AS p
    ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY average_price DESC;

-- ================================================================
-- 14. TOP CUSTOMERS
-- ================================================================

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_spent
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- ================================================================
-- 15. TOP PRODUCTS BY REVENUE
-- ================================================================

SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
JOIN orders AS o
    ON o.order_id = oi.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 5;

-- ================================================================
-- 16. COMPOSITE INDEX FOR QUERY PATTERN
-- ================================================================

CREATE INDEX idx_orders_status_customer_date
ON orders(order_status, customer_id, order_date);

EXPLAIN
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'Delivered'
AND customer_id = 1
ORDER BY order_date DESC;

-- ================================================================
-- 17. EXPLAIN FORMAT TREE
-- ================================================================

EXPLAIN FORMAT=TREE
SELECT
    o.order_id,
    c.customer_name,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
AND o.total_amount > 20000;

-- ================================================================
-- 18. EXPLAIN ANALYZE
-- ================================================================

EXPLAIN ANALYZE
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.total_amount
FROM orders AS o
WHERE o.order_status = 'Delivered'
AND o.order_date >= '2025-08-01';

-- ================================================================
-- 19. INFORMATION_SCHEMA INDEX INSPECTION
-- ================================================================

SELECT
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    SEQ_IN_INDEX,
    NON_UNIQUE,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'sql_query_optimization_lab'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ================================================================
-- 20. TABLE STATISTICS
-- ================================================================

SELECT
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sql_query_optimization_lab'
ORDER BY TABLE_NAME;

-- ================================================================
-- 21. WINDOW FUNCTION
-- ================================================================

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS total_revenue
    FROM orders
    WHERE order_status <> 'Cancelled'
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank;

-- ================================================================
-- 22. LATEST ORDER PER CUSTOMER
-- ================================================================

WITH ranked_orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rn
    FROM orders
)
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM ranked_orders
WHERE rn = 1;

-- ================================================================
-- 23. FINAL BUSINESS REPORT
-- ================================================================

SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) AS products,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
FROM categories AS c
LEFT JOIN products AS p
    ON p.category_id = c.category_id
LEFT JOIN order_items AS oi
    ON oi.product_id = p.product_id
LEFT JOIN orders AS o
    ON o.order_id = oi.order_id
    AND o.order_status <> 'Cancelled'
GROUP BY c.category_id, c.category_name
ORDER BY revenue DESC;

-- ================================================================
-- 24. VALIDATION
-- ================================================================

SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS category_count FROM categories;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS order_count FROM orders;
SELECT COUNT(*) AS order_item_count FROM order_items;

SELECT SUM(total_amount) AS total_order_value
FROM orders;

SELECT SUM(quantity) AS total_units
FROM order_items;

-- ================================================================
-- END OF DAY 70
-- ================================================================
