-- Day 82 - SQL Table Partitioning
-- MySQL 8.x

DROP DATABASE IF EXISTS sql_partitioning_lab;
CREATE DATABASE sql_partitioning_lab;
USE sql_partitioning_lab;

-- ============================================================
-- 1. RANGE PARTITIONING
-- ============================================================

CREATE TABLE sales_range (
    sale_id BIGINT NOT NULL,
    sale_date DATE NOT NULL,
    customer_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (sale_id, sale_date)
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

INSERT INTO sales_range VALUES
(1, '2024-02-10', 101, 1200.00),
(2, '2024-08-15', 102, 850.00),
(3, '2025-01-20', 103, 2200.00),
(4, '2025-11-05', 104, 1750.00),
(5, '2026-03-12', 105, 3200.00),
(6, '2026-08-21', 106, 4100.00);

SELECT * FROM sales_range;

SELECT
    TABLE_NAME, PARTITION_NAME, PARTITION_METHOD,
    PARTITION_EXPRESSION, TABLE_ROWS
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'sales_range';

-- Partition pruning example
SELECT *
FROM sales_range
WHERE sale_date >= '2026-01-01'
  AND sale_date < '2027-01-01';

EXPLAIN
SELECT *
FROM sales_range
WHERE sale_date >= '2026-01-01'
  AND sale_date < '2027-01-01';

-- ============================================================
-- 2. RANGE COLUMNS
-- ============================================================

CREATE TABLE orders_by_date (
    order_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    customer_id INT NOT NULL,
    order_total DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (order_id, order_date)
)
PARTITION BY RANGE COLUMNS (order_date) (
    PARTITION p_before_2025 VALUES LESS THAN ('2025-01-01'),
    PARTITION p2025 VALUES LESS THAN ('2026-01-01'),
    PARTITION p2026 VALUES LESS THAN ('2027-01-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

INSERT INTO orders_by_date VALUES
(101, '2024-12-20', 1, 500.00),
(102, '2025-03-15', 2, 1250.00),
(103, '2025-09-21', 3, 760.00),
(104, '2026-02-10', 4, 2100.00),
(105, '2026-09-18', 5, 3400.00);

SELECT * FROM orders_by_date;

-- ============================================================
-- 3. LIST COLUMNS PARTITIONING
-- ============================================================

CREATE TABLE customers_by_region (
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    region_code VARCHAR(10) NOT NULL,
    total_spend DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (customer_id, region_code)
)
PARTITION BY LIST COLUMNS (region_code) (
    PARTITION p_north VALUES IN ('NORTH'),
    PARTITION p_south VALUES IN ('SOUTH'),
    PARTITION p_east VALUES IN ('EAST'),
    PARTITION p_west VALUES IN ('WEST'),
    PARTITION p_other VALUES IN ('CENTRAL', 'NORTHEAST')
);

INSERT INTO customers_by_region VALUES
(1, 'Aarav', 'NORTH', 12000.00),
(2, 'Diya', 'SOUTH', 18500.00),
(3, 'Rohan', 'EAST', 9200.00),
(4, 'Meera', 'WEST', 15000.00),
(5, 'Kabir', 'SOUTH', 21000.00),
(6, 'Anaya', 'CENTRAL', 7000.00);

SELECT * FROM customers_by_region;

-- ============================================================
-- 4. HASH PARTITIONING
-- ============================================================

CREATE TABLE events_hash (
    event_id BIGINT NOT NULL,
    user_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_time DATETIME NOT NULL,
    PRIMARY KEY (event_id, user_id)
)
PARTITION BY HASH (user_id)
PARTITIONS 4;

INSERT INTO events_hash VALUES
(1, 101, 'login', '2026-09-01 09:00:00'),
(2, 102, 'purchase', '2026-09-01 09:15:00'),
(3, 103, 'logout', '2026-09-01 10:00:00'),
(4, 104, 'login', '2026-09-01 10:30:00'),
(5, 105, 'purchase', '2026-09-01 11:00:00'),
(6, 106, 'login', '2026-09-01 11:30:00'),
(7, 107, 'purchase', '2026-09-01 12:00:00');

SELECT * FROM events_hash;

-- ============================================================
-- 5. KEY PARTITIONING
-- ============================================================

CREATE TABLE users_key (
    user_id BIGINT NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (user_id)
)
PARTITION BY KEY (user_id)
PARTITIONS 4;

INSERT INTO users_key VALUES
(1001, 'User A', '2026-01-01 10:00:00'),
(1002, 'User B', '2026-01-02 10:00:00'),
(1003, 'User C', '2026-01-03 10:00:00'),
(1004, 'User D', '2026-01-04 10:00:00'),
(1005, 'User E', '2026-01-05 10:00:00');

SELECT * FROM users_key;

-- ============================================================
-- 6. PARTITION METADATA
-- ============================================================

SELECT
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_METHOD,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE()
  AND PARTITION_NAME IS NOT NULL
ORDER BY TABLE_NAME, PARTITION_ORDINAL_POSITION;

-- ============================================================
-- 7. QUERY A SPECIFIC PARTITION
-- ============================================================

SELECT *
FROM sales_range PARTITION (p2026);

-- ============================================================
-- 8. AGGREGATION
-- ============================================================

SELECT
    YEAR(sale_date) AS sale_year,
    COUNT(*) AS total_sales,
    SUM(amount) AS total_revenue
FROM sales_range
GROUP BY YEAR(sale_date)
ORDER BY sale_year;

-- ============================================================
-- 9. MONTHLY RANGE COLUMNS + REORGANIZE
-- ============================================================

CREATE TABLE monthly_sales (
    sale_id BIGINT NOT NULL,
    sale_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (sale_id, sale_date)
)
PARTITION BY RANGE COLUMNS (sale_date) (
    PARTITION p2026_01 VALUES LESS THAN ('2026-02-01'),
    PARTITION p2026_02 VALUES LESS THAN ('2026-03-01'),
    PARTITION p2026_03 VALUES LESS THAN ('2026-04-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

INSERT INTO monthly_sales VALUES
(1, '2026-01-15', 1000.00),
(2, '2026-02-20', 1500.00),
(3, '2026-03-25', 1800.00),
(4, '2026-09-01', 2200.00);

ALTER TABLE monthly_sales
REORGANIZE PARTITION p_future INTO (
    PARTITION p2026_09 VALUES LESS THAN ('2026-10-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);

SELECT
    PARTITION_NAME,
    PARTITION_DESCRIPTION
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'monthly_sales'
ORDER BY PARTITION_ORDINAL_POSITION;

-- Destructive examples -- intentionally commented:
-- ALTER TABLE monthly_sales TRUNCATE PARTITION p2026_01;
-- ALTER TABLE monthly_sales DROP PARTITION p2026_01;

-- ============================================================
-- 10. PRACTICE
-- ============================================================

-- 1. Create a table partitioned by year from 2023 to 2027.
-- 2. Create monthly RANGE COLUMNS partitions for one year.
-- 3. Find total revenue for 2026.
-- 4. Query only the 2025 partition.
-- 5. Create a LIST COLUMNS table for product categories.
-- 6. Create a HASH-partitioned table with 8 partitions.
-- 7. Inspect information_schema.PARTITIONS.
-- 8. Add a future partition to a date-partitioned table.
-- 9. Explain partition pruning.
-- 10. Compare RANGE, LIST, HASH and KEY partitioning.

-- ============================================================
-- End of Day 82
-- ============================================================
