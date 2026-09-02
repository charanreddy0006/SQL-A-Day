-- ============================================================
-- DAY 76 - SQL QUERY EXECUTION PLANS & PERFORMANCE ANALYSIS
-- ============================================================
-- Database : MySQL 8+
-- Topic    : EXPLAIN, EXPLAIN ANALYZE and Query Optimization
-- Project  : SQL Query Performance Lab
-- ============================================================


-- ============================================================
-- 1. CREATE DATABASE
-- ============================================================

DROP DATABASE IF EXISTS query_performance_lab;

CREATE DATABASE query_performance_lab;

USE query_performance_lab;


-- ============================================================
-- 2. CREATE CUSTOMERS TABLE
-- ============================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL,
    customer_status ENUM(
        'ACTIVE',
        'INACTIVE',
        'SUSPENDED'
    ) NOT NULL
);


-- ============================================================
-- 3. CREATE PRODUCTS TABLE
-- ============================================================

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);


-- ============================================================
-- 4. CREATE ORDERS TABLE
-- ============================================================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,

    customer_id INT NOT NULL,

    order_date DATETIME NOT NULL,

    order_status ENUM(
        'PENDING',
        'SHIPPED',
        'DELIVERED',
        'CANCELLED'
    ) NOT NULL,

    total_amount DECIMAL(12, 2) NOT NULL,

    shipping_city VARCHAR(80) NOT NULL,

    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- ============================================================
-- 5. CREATE ORDER ITEMS TABLE
-- ============================================================

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,

    order_id INT NOT NULL,

    product_id INT NOT NULL,

    quantity INT NOT NULL,

    unit_price DECIMAL(10, 2) NOT NULL,

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    CONSTRAINT fk_order_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);


-- ============================================================
-- 6. CREATE NUMBERS HELPER TABLE
-- ============================================================
-- This table is used to generate realistic test data.
-- We will create 50,000 rows.

CREATE TABLE numbers (
    n INT PRIMARY KEY
);


-- ============================================================
-- 7. GENERATE NUMBERS
-- ============================================================

SET SESSION cte_max_recursion_depth = 60000;

INSERT INTO numbers (n)

WITH RECURSIVE sequence_numbers AS (

    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM sequence_numbers
    WHERE n < 50000
)

SELECT n
FROM sequence_numbers;


-- ============================================================
-- 8. INSERT PRODUCTS
-- ============================================================

INSERT INTO products (
    product_id,
    product_name,
    category,
    unit_price
)
VALUES
(1, 'Laptop Pro 14', 'Electronics', 1299.00),
(2, 'Mechanical Keyboard', 'Electronics', 119.00),
(3, 'Wireless Mouse', 'Electronics', 49.00),
(4, 'Office Chair', 'Furniture', 349.00),
(5, 'Standing Desk', 'Furniture', 599.00),
(6, 'USB-C Hub', 'Accessories', 79.00),
(7, 'Monitor 27', 'Electronics', 429.00),
(8, 'Notebook Pack', 'Stationery', 18.00),
(9, 'Desk Lamp', 'Furniture', 65.00),
(10, 'Webcam HD', 'Electronics', 89.00);


-- ============================================================
-- 9. INSERT CUSTOMERS
-- ============================================================
-- 10,000 customers will be generated.

INSERT INTO customers (
    customer_id,
    customer_name,
    email,
    city,
    signup_date,
    customer_status
)

SELECT

    n,

    CONCAT(

        CASE MOD(n, 5)

            WHEN 0 THEN 'Arjun'

            WHEN 1 THEN 'Ravi'

            WHEN 2 THEN 'Priya'

            WHEN 3 THEN 'Sneha'

            ELSE 'Kiran'

        END,

        ' Customer ',

        n

    ),

    CONCAT(
        'customer',
        n,
        '@example.com'
    ),

    CASE MOD(n, 8)

        WHEN 0 THEN 'Hyderabad'

        WHEN 1 THEN 'Bengaluru'

        WHEN 2 THEN 'Chennai'

        WHEN 3 THEN 'Mumbai'

        WHEN 4 THEN 'Delhi'

        WHEN 5 THEN 'Pune'

        WHEN 6 THEN 'Kolkata'

        ELSE 'Vizag'

    END,

    DATE_ADD(
        '2022-01-01',
        INTERVAL MOD(n, 1500) DAY
    ),

    CASE MOD(n, 10)

        WHEN 0 THEN 'SUSPENDED'

        WHEN 1 THEN 'INACTIVE'

        ELSE 'ACTIVE'

    END

FROM numbers

WHERE n <= 10000;


-- ============================================================
-- 10. INSERT ORDERS
-- ============================================================
-- 50,000 orders will be generated.

INSERT INTO orders (
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount,
    shipping_city
)

SELECT

    n,

    MOD(n - 1, 10000) + 1,

    DATE_ADD(
        '2025-01-01 08:00:00',
        INTERVAL MOD(n * 37, 525600) MINUTE
    ),

    CASE MOD(n, 20)

        WHEN 0 THEN 'CANCELLED'

        WHEN 1 THEN 'PENDING'

        WHEN 2 THEN 'SHIPPED'

        ELSE 'DELIVERED'

    END,

    CAST(
        20
        + MOD(n * 83, 4980)
        + (MOD(n, 100) / 100)
        AS DECIMAL(12, 2)
    ),

    CASE MOD(n, 8)

        WHEN 0 THEN 'Hyderabad'

        WHEN 1 THEN 'Bengaluru'

        WHEN 2 THEN 'Chennai'

        WHEN 3 THEN 'Mumbai'

        WHEN 4 THEN 'Delhi'

        WHEN 5 THEN 'Pune'

        WHEN 6 THEN 'Kolkata'

        ELSE 'Vizag'

    END

FROM numbers;


-- ============================================================
-- 11. INSERT ORDER ITEMS
-- ============================================================

INSERT INTO order_items (
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price
)

SELECT

    n,

    MOD(n - 1, 50000) + 1,

    MOD(n - 1, 10) + 1,

    MOD(n, 5) + 1,

    CASE MOD(n - 1, 10)

        WHEN 0 THEN 1299.00

        WHEN 1 THEN 119.00

        WHEN 2 THEN 49.00

        WHEN 3 THEN 349.00

        WHEN 4 THEN 599.00

        WHEN 5 THEN 79.00

        WHEN 6 THEN 429.00

        WHEN 7 THEN 18.00

        WHEN 8 THEN 65.00

        ELSE 89.00

    END

FROM numbers;


-- ============================================================
-- 12. VERIFY DATA
-- ============================================================

SELECT COUNT(*) AS total_customers
FROM customers;


SELECT COUNT(*) AS total_products
FROM products;


SELECT COUNT(*) AS total_orders
FROM orders;


SELECT COUNT(*) AS total_order_items
FROM order_items;


-- ============================================================
-- 13. BASIC EXPLAIN
-- ============================================================
-- EXPLAIN shows the execution plan chosen/planned by MySQL.

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5000;


-- Another example

EXPLAIN
SELECT *
FROM orders
WHERE shipping_city = 'Hyderabad';


-- ============================================================
-- 14. UNDERSTANDING FULL TABLE SCAN
-- ============================================================
-- At this stage, shipping_city has no dedicated index.
-- MySQL may need to inspect many/all rows.

EXPLAIN
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE shipping_city = 'Hyderabad';


-- ============================================================
-- 15. NON-SARGABLE DATE FILTER
-- ============================================================
-- Applying DATE() to the indexed column can make efficient
-- B-tree index usage more difficult.

EXPLAIN
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE DATE(order_date) = '2025-06-15';


-- ============================================================
-- 16. SARGABLE DATE FILTER
-- ============================================================
-- A range condition is generally more index-friendly.

EXPLAIN
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE order_date >= '2025-06-15 00:00:00'
  AND order_date < '2025-06-16 00:00:00';


-- ============================================================
-- 17. CREATE INDEXES
-- ============================================================

CREATE INDEX idx_orders_customer
ON orders(customer_id);


CREATE INDEX idx_orders_date
ON orders(order_date);


CREATE INDEX idx_orders_city
ON orders(shipping_city);


CREATE INDEX idx_orders_status_date
ON orders(
    order_status,
    order_date
);


CREATE INDEX idx_orders_customer_date_amount
ON orders(
    customer_id,
    order_date,
    total_amount
);


CREATE INDEX idx_customers_name
ON customers(customer_name);


CREATE INDEX idx_customers_city_status
ON customers(
    city,
    customer_status
);


-- ============================================================
-- 18. UPDATE OPTIMIZER STATISTICS
-- ============================================================

ANALYZE TABLE customers;

ANALYZE TABLE orders;

ANALYZE TABLE order_items;

ANALYZE TABLE products;


-- ============================================================
-- 19. EXPLAIN AFTER INDEXING
-- ============================================================

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 5000;


-- Composite-index query

EXPLAIN
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 5000
  AND order_date >= '2025-06-01'
  AND order_date < '2025-07-01';


-- ============================================================
-- 20. EXPLAIN ORDER STATUS + DATE
-- ============================================================

EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'DELIVERED'
  AND order_date >= '2025-06-01'
ORDER BY order_date DESC
LIMIT 20;


-- ============================================================
-- 21. EXPLAIN ANALYZE
-- ============================================================
-- EXPLAIN ANALYZE actually executes the SELECT and provides
-- actual execution information.

EXPLAIN ANALYZE
SELECT
    order_id,
    customer_id,
    total_amount
FROM orders
WHERE customer_id = 5000;


-- ============================================================
-- 22. EXPLAIN ANALYZE WITH DATE RANGE
-- ============================================================

EXPLAIN ANALYZE
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 5000
  AND order_date >= '2025-06-01'
  AND order_date < '2025-07-01';


-- ============================================================
-- 23. SARGABILITY EXPERIMENT - YEAR()
-- ============================================================

EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE YEAR(order_date) = 2025;


-- Better range-based version

EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE order_date >= '2025-01-01'
  AND order_date < '2026-01-01';


-- ============================================================
-- 24. LIKE PREFIX SEARCH
-- ============================================================

EXPLAIN
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_name LIKE 'Arjun%';


-- ============================================================
-- 25. LIKE LEADING WILDCARD
-- ============================================================
-- A leading wildcard generally prevents efficient use of a
-- normal B-tree index for this type of substring search.

EXPLAIN
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_name LIKE '%Customer 99%';


-- ============================================================
-- 26. COMPOSITE INDEX
-- ============================================================
-- Index:
-- customer_id -> order_date -> total_amount

EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 2500
  AND order_date >= '2025-04-01'
  AND order_date < '2025-05-01';


-- ============================================================
-- 27. QUERY USING ONLY SECOND COLUMN
-- ============================================================
-- The composite index above starts with customer_id.
-- This query filters only on order_date.

EXPLAIN
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE order_date >= '2025-04-01'
  AND order_date < '2025-05-01';


-- ============================================================
-- 28. JOIN EXECUTION PLAN
-- ============================================================

EXPLAIN
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE c.city = 'Hyderabad'
  AND o.order_status = 'DELIVERED';


-- ============================================================
-- 29. JOIN WITH EXPLAIN ANALYZE
-- ============================================================

EXPLAIN ANALYZE
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.total_amount
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE c.city = 'Hyderabad'
  AND o.order_status = 'DELIVERED';


-- ============================================================
-- 30. AGGREGATION EXECUTION PLAN
-- ============================================================

EXPLAIN
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;


-- ============================================================
-- 31. AGGREGATION WITH EXPLAIN ANALYZE
-- ============================================================

EXPLAIN ANALYZE
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_id;


-- ============================================================
-- 32. ORDER BY + LIMIT
-- ============================================================

EXPLAIN
SELECT
    order_id,
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'DELIVERED'
ORDER BY order_date DESC
LIMIT 20;


-- ============================================================
-- 33. COVERING INDEX CONCEPT
-- ============================================================
-- Required columns are present in:
--
-- customer_id
-- order_date
-- total_amount
--
-- MySQL may be able to satisfy the query from the index
-- without additional base-table lookups.

EXPLAIN
SELECT
    customer_id,
    order_date,
    total_amount
FROM orders
WHERE customer_id = 7500
  AND order_date >= '2025-08-01'
  AND order_date < '2025-09-01';


-- ============================================================
-- 34. FORCE INDEX
-- ============================================================
-- FORCE INDEX is used here only for experimentation.

EXPLAIN
SELECT
    order_id,
    customer_id,
    order_date
FROM orders FORCE INDEX (
    idx_orders_customer_date_amount
)
WHERE customer_id = 5000
  AND order_date >= '2025-01-01'
  AND order_date < '2026-01-01';


-- ============================================================
-- 35. SHOW INDEX INFORMATION
-- ============================================================

SHOW INDEX FROM orders;


SHOW INDEX FROM customers;


-- ============================================================
-- 36. REFRESH STATISTICS
-- ============================================================

ANALYZE TABLE orders;


-- ============================================================
-- 37. PRACTICE QUERY 1
-- ============================================================
-- Find orders shipped to Mumbai.

EXPLAIN
SELECT
    order_id,
    total_amount
FROM orders
WHERE shipping_city = 'Mumbai';


-- ============================================================
-- 38. PRACTICE QUERY 2
-- ============================================================
-- Find active customers in Pune.

EXPLAIN
SELECT
    customer_id,
    customer_name
FROM customers
WHERE city = 'Pune'
  AND customer_status = 'ACTIVE';


-- ============================================================
-- 39. PRACTICE QUERY 3
-- ============================================================
-- Compare DATE() against a range.

EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE DATE(order_date) = '2025-12-10';


EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE order_date >= '2025-12-10'
  AND order_date < '2025-12-11';


-- ============================================================
-- 40. PRACTICE QUERY 4
-- ============================================================

EXPLAIN ANALYZE
SELECT
    order_id,
    order_date,
    total_amount
FROM orders
WHERE order_status = 'DELIVERED'
ORDER BY order_date DESC
LIMIT 50;


-- ============================================================
-- 41. PRACTICE QUERY 5
-- ============================================================

EXPLAIN
SELECT
    c.customer_name,
    COUNT(o.order_id) AS orders_count
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE c.city = 'Chennai'
GROUP BY
    c.customer_id,
    c.customer_name;


-- ============================================================
-- 42. FINAL DATA CHECK
-- ============================================================

SELECT
    'customers' AS table_name,
    COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT
    'products',
    COUNT(*)
FROM products

UNION ALL

SELECT
    'orders',
    COUNT(*)
FROM orders

UNION ALL

SELECT
    'order_items',
    COUNT(*)
FROM order_items;


-- ============================================================
-- END OF DAY 76
-- ============================================================