/*
===============================================================================
SQL-A-Day | DAY 100 — FINAL DAY
Topic: End-to-End SQL Capstone — Retail Sales Analytics
Database: MySQL 8.0+

PURPOSE
Apply SQL skills in a single practical analytics project:
schema design, constraints, joins, aggregation, subqueries, CTEs, window
functions, date analysis, data quality checks, and business reporting.

This is a learning project, not a production-ready commerce database.
The script recreates its own practice database and sample tables.
===============================================================================
*/

CREATE DATABASE IF NOT EXISTS sql_day100_capstone;
USE sql_day100_capstone;

-- Rebuild the lab safely for repeatable practice.
DROP VIEW IF EXISTS vw_monthly_sales;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- ---------------------------------------------------------------------------
-- 1. DATABASE DESIGN
-- ---------------------------------------------------------------------------

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    signup_date DATE NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(60) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_product_price CHECK (unit_price >= 0),
    CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    CONSTRAINT chk_order_status
      CHECK (order_status IN ('PLACED','PAID','SHIPPED','DELIVERED','CANCELLED')),
    CONSTRAINT fk_orders_customer
      FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price_at_sale DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_sale_price CHECK (unit_price_at_sale >= 0),
    CONSTRAINT fk_items_order
      FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product
      FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------------------------------------------------------------------------
-- 2. INSERT SAMPLE DATA
-- ---------------------------------------------------------------------------

INSERT INTO customers VALUES
(1,'Aarav Shah','Rajkot','Gujarat','2025-01-10','aarav@example.com'),
(2,'Diya Patel','Ahmedabad','Gujarat','2025-02-14','diya@example.com'),
(3,'Kabir Mehta','Surat','Gujarat','2025-03-02','kabir@example.com'),
(4,'Mira Rao','Hyderabad','Telangana','2025-04-19','mira@example.com'),
(5,'Ishaan Reddy','Hyderabad','Telangana','2025-05-22','ishaan@example.com'),
(6,'Anaya Iyer','Chennai','Tamil Nadu','2025-06-11','anaya@example.com'),
(7,'Vivaan Das','Pune','Maharashtra','2025-07-07','vivaan@example.com'),
(8,'Sara Khan','Mumbai','Maharashtra','2025-08-18','sara@example.com');

INSERT INTO products VALUES
(101,'Wireless Mouse','Accessories',799.00,120),
(102,'Mechanical Keyboard','Accessories',2499.00,65),
(103,'USB-C Hub','Accessories',1799.00,80),
(104,'Laptop Stand','Accessories',1299.00,45),
(105,'27-inch Monitor','Monitors',15999.00,25),
(106,'Portable SSD 1TB','Storage',6499.00,40),
(107,'Webcam HD','Accessories',2199.00,55),
(108,'Noise Cancelling Headphones','Audio',8999.00,30);

INSERT INTO orders VALUES
(1001,1,'2025-09-03','DELIVERED'),
(1002,2,'2025-09-08','DELIVERED'),
(1003,1,'2025-10-12','DELIVERED'),
(1004,3,'2025-10-21','CANCELLED'),
(1005,4,'2025-11-02','DELIVERED'),
(1006,5,'2025-11-16','SHIPPED'),
(1007,6,'2025-12-04','DELIVERED'),
(1008,2,'2025-12-19','DELIVERED'),
(1009,7,'2026-01-05','DELIVERED'),
(1010,8,'2026-01-22','PAID'),
(1011,4,'2026-02-09','DELIVERED'),
(1012,5,'2026-02-25','CANCELLED'),
(1013,1,'2026-03-07','DELIVERED'),
(1014,3,'2026-03-18','DELIVERED'),
(1015,6,'2026-03-28','PLACED'),
(1016,8,'2026-04-03','DELIVERED'),
(1017,7,'2026-04-17','DELIVERED'),
(1018,2,'2026-04-26','DELIVERED');

INSERT INTO order_items VALUES
(1,1001,101,2,799.00),
(2,1001,104,1,1299.00),
(3,1002,102,1,2499.00),
(4,1002,103,1,1799.00),
(5,1003,105,1,15999.00),
(6,1003,101,1,799.00),
(7,1004,108,1,8999.00),
(8,1005,106,1,6499.00),
(9,1005,107,1,2199.00),
(10,1006,102,1,2499.00),
(11,1006,104,2,1299.00),
(12,1007,108,1,8999.00),
(13,1007,103,2,1799.00),
(14,1008,101,3,799.00),
(15,1008,107,1,2199.00),
(16,1009,105,1,15999.00),
(17,1010,106,1,6499.00),
(18,1011,102,1,2499.00),
(19,1011,103,1,1799.00),
(20,1012,108,1,8999.00),
(21,1013,105,1,15999.00),
(22,1013,104,1,1299.00),
(23,1014,101,2,799.00),
(24,1014,102,1,2499.00),
(25,1015,107,1,2199.00),
(26,1016,108,1,8999.00),
(27,1016,103,1,1799.00),
(28,1017,106,1,6499.00),
(29,1017,104,1,1299.00),
(30,1018,102,1,2499.00),
(31,1018,101,2,799.00);

-- ---------------------------------------------------------------------------
-- 3. DATA QUALITY CHECKS
-- ---------------------------------------------------------------------------

-- Check duplicate customer emails (should return no rows due to UNIQUE).
SELECT email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

-- Check for orders with no matching customer (should return no rows
-- because of the foreign key).
SELECT o.order_id
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Check order items with invalid quantities/prices.
SELECT *
FROM order_items
WHERE quantity <= 0 OR unit_price_at_sale < 0;

-- ---------------------------------------------------------------------------
-- 4. CORE BUSINESS METRICS
-- ---------------------------------------------------------------------------

-- Total order count and status breakdown.
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Revenue from completed orders only.
-- Revenue is calculated from the price captured at sale time.
SELECT
    SUM(oi.quantity * oi.unit_price_at_sale) AS delivered_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'DELIVERED';

-- Revenue and order count by customer.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(oi.quantity * oi.unit_price_at_sale) AS customer_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_revenue DESC;

-- Product performance.
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price_at_sale) AS product_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY p.product_id, p.product_name
ORDER BY product_revenue DESC;

-- Category performance.
SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price_at_sale) AS category_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY p.category
ORDER BY category_revenue DESC;

-- ---------------------------------------------------------------------------
-- 5. DATE-BASED ANALYSIS
-- ---------------------------------------------------------------------------

-- Monthly revenue.
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(oi.quantity * oi.unit_price_at_sale) AS monthly_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- ---------------------------------------------------------------------------
-- 6. SUBQUERIES AND CTEs
-- ---------------------------------------------------------------------------

-- Customers whose delivered revenue is greater than the average
-- delivered revenue per customer.
WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(oi.quantity * oi.unit_price_at_sale) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.order_status = 'DELIVERED'
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_revenue
WHERE revenue > (SELECT AVG(revenue) FROM customer_revenue)
ORDER BY revenue DESC;

-- ---------------------------------------------------------------------------
-- 7. WINDOW FUNCTIONS
-- ---------------------------------------------------------------------------

-- Rank products by delivered revenue within each category.
WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(oi.quantity * oi.unit_price_at_sale) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'DELIVERED'
    GROUP BY p.product_id, p.product_name, p.category
)
SELECT
    product_name,
    category,
    revenue,
    DENSE_RANK() OVER (
        PARTITION BY category ORDER BY revenue DESC
    ) AS category_rank
FROM product_revenue
ORDER BY category, category_rank;

-- ---------------------------------------------------------------------------
-- 8. CUSTOMER SEGMENTATION
-- ---------------------------------------------------------------------------

WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(DISTINCT o.order_id) AS delivered_orders,
        COALESCE(SUM(oi.quantity * oi.unit_price_at_sale), 0) AS revenue
    FROM customers c
    LEFT JOIN orders o
      ON o.customer_id = c.customer_id
     AND o.order_status = 'DELIVERED'
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    delivered_orders,
    revenue,
    CASE
      WHEN revenue >= 15000 THEN 'HIGH VALUE'
      WHEN revenue >= 5000 THEN 'MEDIUM VALUE'
      WHEN revenue > 0 THEN 'LOW VALUE'
      ELSE 'NO DELIVERED PURCHASE'
    END AS customer_segment
FROM customer_metrics
ORDER BY revenue DESC;

-- ---------------------------------------------------------------------------
-- 9. VIEW FOR REUSABLE MONTHLY REPORTING
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id) AS delivered_orders,
    SUM(oi.quantity * oi.unit_price_at_sale) AS monthly_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m');

SELECT * FROM vw_monthly_sales ORDER BY sales_month;

-- ---------------------------------------------------------------------------
-- 10. FINAL EXECUTIVE SUMMARY QUERIES
-- ---------------------------------------------------------------------------

-- Overall KPIs.
SELECT
    (SELECT COUNT(*) FROM customers) AS total_customers,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'DELIVERED')
      AS delivered_orders,
    (SELECT COUNT(*) FROM orders WHERE order_status = 'CANCELLED')
      AS cancelled_orders,
    (SELECT SUM(oi.quantity * oi.unit_price_at_sale)
       FROM orders o
       JOIN order_items oi ON oi.order_id = o.order_id
       WHERE o.order_status = 'DELIVERED') AS delivered_revenue;

-- Top 5 customers by delivered revenue.
SELECT
    c.customer_name,
    SUM(oi.quantity * oi.unit_price_at_sale) AS revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY c.customer_id, c.customer_name
ORDER BY revenue DESC
LIMIT 5;

-- Top 5 products by delivered units sold.
SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON o.order_id = oi.order_id
WHERE o.order_status = 'DELIVERED'
GROUP BY p.product_id, p.product_name
ORDER BY units_sold DESC
LIMIT 5;

-- ---------------------------------------------------------------------------
-- 11. FINAL PROJECT CHALLENGES
-- ---------------------------------------------------------------------------

-- Challenge 1: Find customers who have never placed an order.
-- Challenge 2: Find products that have never appeared in a delivered order.
-- Challenge 3: Calculate average delivered order value.
-- Challenge 4: Find each customer's first delivered order date.
-- Challenge 5: Calculate month-over-month revenue change.
-- Challenge 6: Find the highest-revenue product in each category.
-- Challenge 7: Compare order counts by city.
-- Challenge 8: Identify customers with more than one delivered order.

-- END OF DAY 100 — SQL-A-DAY FINAL CAPSTONE
