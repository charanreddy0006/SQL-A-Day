-- ============================================================
-- Day 95: MySQL Performance Schema — Runtime Diagnostics
-- MySQL 8.0+
-- Project: sql_performance_schema_lab
-- ============================================================
-- Performance Schema exposes runtime instrumentation about server
-- activity. It helps investigate statements, waits, sessions and
-- resource usage. It is different from EXPLAIN: EXPLAIN describes
-- a query plan; Performance Schema records runtime observations.
--
-- Run in a development environment. Some instruments/consumers may
-- be disabled by server configuration or require privileges.

CREATE DATABASE IF NOT EXISTS sql_performance_schema_lab;
USE sql_performance_schema_lab;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(60) NOT NULL
);

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

INSERT INTO customers VALUES
(1,'Aarav Shah','Rajkot'),(2,'Diya Patel','Ahmedabad'),
(3,'Kabir Mehta','Surat'),(4,'Anaya Desai','Vadodara'),
(5,'Ishaan Joshi','Rajkot');

INSERT INTO orders VALUES
(5001,1,'2026-09-01','COMPLETED',1599.00),
(5002,2,'2026-09-02','PENDING',2499.00),
(5003,3,'2026-09-03','COMPLETED',799.00),
(5004,1,'2026-09-04','CANCELLED',499.00),
(5005,4,'2026-09-05','COMPLETED',3499.00),
(5006,5,'2026-09-06','PENDING',1299.00);

INSERT INTO order_items VALUES
(1,5001,'Keyboard',1,999.00),(2,5001,'Mouse',1,600.00),
(3,5002,'Monitor',1,2499.00),(4,5003,'USB Hub',1,799.00),
(5,5004,'Mouse Pad',1,499.00),(6,5005,'SSD',1,3499.00),
(7,5006,'Headset',1,1299.00);

-- ------------------------------------------------------------
-- 1. Confirm Performance Schema availability
-- ------------------------------------------------------------
SHOW VARIABLES LIKE 'performance_schema';

-- Performance Schema is a system database, not the lab database.
SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.tables
WHERE TABLE_SCHEMA = 'performance_schema'
ORDER BY TABLE_NAME
LIMIT 30;

-- ------------------------------------------------------------
-- 2. Inspect enabled instruments and consumers
-- ------------------------------------------------------------
SELECT NAME, ENABLED, TIMED
FROM performance_schema.setup_instruments
WHERE NAME LIKE 'statement/%'
ORDER BY NAME
LIMIT 30;

SELECT NAME, ENABLED
FROM performance_schema.setup_consumers
ORDER BY NAME;

-- Optional: enable statement history consumers for this session/server.
-- Requires suitable privileges; settings may be reset by server policy.
-- UPDATE performance_schema.setup_consumers
-- SET ENABLED = 'YES'
-- WHERE NAME IN ('events_statements_current',
--                'events_statements_history',
--                'events_statements_history_long');

-- ------------------------------------------------------------
-- 3. Generate a few statements to create observable activity
-- ------------------------------------------------------------
SELECT status, COUNT(*) AS order_count, SUM(total_amount) AS order_value
FROM sql_performance_schema_lab.orders
GROUP BY status;

SELECT c.city, COUNT(o.order_id) AS orders_count
FROM sql_performance_schema_lab.customers c
LEFT JOIN sql_performance_schema_lab.orders o
  ON o.customer_id = c.customer_id
GROUP BY c.city;

SELECT o.order_id, c.customer_name, oi.product_name,
       oi.quantity, oi.unit_price
FROM sql_performance_schema_lab.orders o
JOIN sql_performance_schema_lab.customers c
  ON c.customer_id = o.customer_id
JOIN sql_performance_schema_lab.order_items oi
  ON oi.order_id = o.order_id
WHERE o.status = 'COMPLETED';

-- ------------------------------------------------------------
-- 4. Recent statement events (if statement history is enabled)
-- SQL_TEXT can be NULL for statements that are not retained.
-- ------------------------------------------------------------
SELECT
    EVENT_ID,
    EVENT_NAME,
    SQL_TEXT,
    TIMER_WAIT / 1000000000000 AS elapsed_seconds,
    ROWS_EXAMINED,
    ROWS_SENT,
    MYSQL_ERRNO
FROM performance_schema.events_statements_history
ORDER BY EVENT_ID DESC
LIMIT 20;

-- Long history consumer may provide a larger retained window.
SELECT
    THREAD_ID,
    EVENT_ID,
    SQL_TEXT,
    ROUND(TIMER_WAIT / 1000000000000, 6) AS elapsed_seconds,
    ROWS_EXAMINED,
    ROWS_SENT
FROM performance_schema.events_statements_history_long
WHERE SQL_TEXT IS NOT NULL
ORDER BY TIMER_START DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 5. Statement digest summary: aggregate similar SQL statements
-- ------------------------------------------------------------
SELECT
    SCHEMA_NAME,
    DIGEST_TEXT,
    COUNT_STAR AS execution_count,
    ROUND(SUM_TIMER_WAIT / 1000000000000, 4) AS total_seconds,
    ROUND(AVG_TIMER_WAIT / 1000000000000, 6) AS average_seconds,
    SUM_ROWS_EXAMINED AS rows_examined,
    SUM_ROWS_SENT AS rows_sent
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 15;

-- ------------------------------------------------------------
-- 6. Find statements examining many rows
-- ------------------------------------------------------------
SELECT
    SCHEMA_NAME,
    DIGEST_TEXT,
    COUNT_STAR,
    SUM_ROWS_EXAMINED,
    SUM_ROWS_SENT,
    ROUND(AVG_TIMER_WAIT / 1000000000000, 6) AS avg_seconds
FROM performance_schema.events_statements_summary_by_digest
WHERE DIGEST_TEXT IS NOT NULL
ORDER BY SUM_ROWS_EXAMINED DESC
LIMIT 15;

-- ------------------------------------------------------------
-- 7. Table I/O summary: reads, inserts, updates and deletes
-- ------------------------------------------------------------
SELECT
    OBJECT_SCHEMA,
    OBJECT_NAME,
    COUNT_READ,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE,
    SUM_TIMER_READ / 1000000000000 AS read_seconds
FROM performance_schema.table_io_waits_summary_by_table
WHERE OBJECT_SCHEMA = 'sql_performance_schema_lab'
ORDER BY COUNT_READ + COUNT_INSERT + COUNT_UPDATE + COUNT_DELETE DESC;

-- ------------------------------------------------------------
-- 8. File I/O summary (server-wide; inspect carefully)
-- ------------------------------------------------------------
SELECT
    FILE_NAME,
    COUNT_READ,
    SUM_NUMBER_OF_BYTES_READ,
    COUNT_WRITE,
    SUM_NUMBER_OF_BYTES_WRITE
FROM performance_schema.file_summary_by_instance
ORDER BY SUM_TIMER_WAIT DESC
LIMIT 15;

-- ------------------------------------------------------------
-- 9. Current connection/session information
-- ------------------------------------------------------------
SELECT
    THREAD_ID,
    PROCESSLIST_ID,
    PROCESSLIST_USER,
    PROCESSLIST_HOST,
    PROCESSLIST_DB,
    PROCESSLIST_COMMAND,
    PROCESSLIST_TIME,
    PROCESSLIST_STATE
FROM performance_schema.threads
WHERE TYPE = 'FOREGROUND'
ORDER BY PROCESSLIST_TIME DESC;

-- ------------------------------------------------------------
-- 10. Lock wait diagnostics (rows appear only when waits exist)
-- ------------------------------------------------------------
SELECT
    REQUESTING_ENGINE_TRANSACTION_ID,
    BLOCKING_ENGINE_TRANSACTION_ID,
    REQUESTING_THREAD_ID,
    BLOCKING_THREAD_ID,
    OBJECT_SCHEMA,
    OBJECT_NAME,
    LOCK_TYPE,
    LOCK_MODE
FROM performance_schema.data_lock_waits;

-- ------------------------------------------------------------
-- 11. Reset selected summary counters for a controlled experiment
-- TRUNCATE on Performance Schema summary tables resets statistics;
-- it does not delete application data. Requires appropriate privileges.
-- Uncomment only when you understand the impact on shared diagnostics.
-- ------------------------------------------------------------
-- TRUNCATE TABLE performance_schema.events_statements_summary_by_digest;
-- TRUNCATE TABLE performance_schema.table_io_waits_summary_by_table;

-- Practice:
-- A. Run a SELECT with a selective WHERE clause and inspect its digest.
-- B. Compare rows examined and rows sent for two query variants.
-- C. Identify the lab table with the highest read count.
-- D. Find the digest with the highest average execution time.
-- E. Explain why an empty history table does not prove no statements ran.
