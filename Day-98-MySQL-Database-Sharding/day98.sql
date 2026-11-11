-- SQL-A-Day | Day 98: MySQL Database Sharding
-- MySQL 8.0+
-- NOTE: This is a SINGLE-SERVER simulation using multiple tables.
-- True sharding distributes data across independent database instances.

CREATE DATABASE IF NOT EXISTS sql_sharding_lab;
USE sql_sharding_lab;

-- 1. Two simulated customer shards
DROP TABLE IF EXISTS customers_shard_0;
DROP TABLE IF EXISTS customers_shard_1;
CREATE TABLE customers_shard_0 (
    customer_id BIGINT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL
);
CREATE TABLE customers_shard_1 LIKE customers_shard_0;

-- 2. Corresponding order shards
DROP TABLE IF EXISTS orders_shard_0;
DROP TABLE IF EXISTS orders_shard_1;
CREATE TABLE orders_shard_0 (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_total DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_orders_customer (customer_id)
);
CREATE TABLE orders_shard_1 LIKE orders_shard_0;

-- 3. Deterministic routing rule: customer_id MOD 2
-- Even IDs -> shard 0; odd IDs -> shard 1.
SELECT customer_id, MOD(customer_id, 2) AS shard_number
FROM (
    SELECT 1001 AS customer_id UNION ALL SELECT 1002
    UNION ALL SELECT 1003 UNION ALL SELECT 1004
) AS ids;

-- 4. Insert customers into their assigned shard
INSERT INTO customers_shard_1 VALUES
(1001, 'Aarav Shah', 'aarav@example.com', 'Hyderabad'),
(1003, 'Diya Patel', 'diya@example.com', 'Rajkot'),
(1005, 'Kabir Mehta', 'kabir@example.com', 'Pune');

INSERT INTO customers_shard_0 VALUES
(1002, 'Mira Rao', 'mira@example.com', 'Hyderabad'),
(1004, 'Arjun Nair', 'arjun@example.com', 'Bengaluru'),
(1006, 'Ishita Das', 'ishita@example.com', 'Mumbai');

-- 5. Insert orders into the same shard as their customer
INSERT INTO orders_shard_1
(order_id, customer_id, order_total, order_status) VALUES
(5001, 1001, 2499.00, 'PAID'),
(5003, 1003, 799.00, 'PENDING'),
(5005, 1005, 1599.00, 'SHIPPED');

INSERT INTO orders_shard_0
(order_id, customer_id, order_total, order_status) VALUES
(5002, 1002, 499.00, 'PAID'),
(5004, 1004, 3299.00, 'PAID'),
(5006, 1006, 999.00, 'CANCELLED');

-- 6. Point lookup: customer 1003 is odd, so it belongs to shard 1
SELECT * FROM customers_shard_1 WHERE customer_id = 1003;

-- 7. Global customer view using UNION ALL
SELECT customer_id, customer_name, email, city, 'shard_0' AS shard_name
FROM customers_shard_0
UNION ALL
SELECT customer_id, customer_name, email, city, 'shard_1'
FROM customers_shard_1
ORDER BY customer_id;

-- 8. Global order report
SELECT order_id, customer_id, order_total, order_status, 'shard_0' AS shard_name
FROM orders_shard_0
UNION ALL
SELECT order_id, customer_id, order_total, order_status, 'shard_1'
FROM orders_shard_1
ORDER BY order_id;

-- 9. Join within each shard, then combine the results
SELECT c.customer_id, c.customer_name, o.order_id, o.order_total,
       o.order_status, 'shard_0' AS shard_name
FROM customers_shard_0 c
JOIN orders_shard_0 o ON o.customer_id = c.customer_id
UNION ALL
SELECT c.customer_id, c.customer_name, o.order_id, o.order_total,
       o.order_status, 'shard_1'
FROM customers_shard_1 c
JOIN orders_shard_1 o ON o.customer_id = c.customer_id
ORDER BY customer_id;

-- 10. Global aggregation across shards
SELECT COUNT(*) AS total_orders,
       SUM(order_total) AS total_revenue,
       AVG(order_total) AS average_order_value
FROM (
    SELECT order_id, order_total FROM orders_shard_0
    UNION ALL
    SELECT order_id, order_total FROM orders_shard_1
) all_orders;

-- 11. Revenue by status across shards
SELECT order_status, COUNT(*) AS order_count, SUM(order_total) AS revenue
FROM (
    SELECT order_status, order_total FROM orders_shard_0
    UNION ALL
    SELECT order_status, order_total FROM orders_shard_1
) all_orders
GROUP BY order_status
ORDER BY revenue DESC;

-- 12. Validate routing: both queries should return zero rows
SELECT customer_id FROM customers_shard_0
WHERE MOD(customer_id, 2) <> 0;

SELECT customer_id FROM customers_shard_1
WHERE MOD(customer_id, 2) <> 1;

-- 13. Detect duplicate customer IDs across shards
SELECT customer_id, COUNT(*) AS copies
FROM (
    SELECT customer_id FROM customers_shard_0
    UNION ALL
    SELECT customer_id FROM customers_shard_1
) all_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 14. Compare shard row counts
SELECT 'shard_0' AS shard_name, COUNT(*) AS customer_count
FROM customers_shard_0
UNION ALL
SELECT 'shard_1', COUNT(*) FROM customers_shard_1;

-- Practice:
-- A. Add a third shard and choose a routing strategy.
-- B. Find customers with no orders across both shards.
-- C. Group global customers by city.
-- D. Explain why changing MOD(id, 2) to MOD(id, 3) remaps many rows.
-- E. Explain why cross-shard joins are harder across separate servers.

-- Optional cleanup:
-- DROP DATABASE sql_sharding_lab;
