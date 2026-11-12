-- SQL-A-Day | Day 99: MySQL Schema Evolution & Zero-Downtime Migrations
-- MySQL 8.0+ | Learning simulation, not a guarantee of zero downtime.
-- Run in a practice database. CONTRACT section is destructive and optional.

CREATE DATABASE IF NOT EXISTS sql_schema_migration_lab;
USE sql_schema_migration_lab;

-- 1. Initial legacy schema
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id BIGINT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE orders (
  order_id BIGINT PRIMARY KEY,
  customer_id BIGINT NOT NULL,
  order_amount DECIMAL(10,2) NOT NULL,
  order_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_orders_customer(customer_id),
  CONSTRAINT fk_orders_customer FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id)
) ENGINE=InnoDB;

INSERT INTO customers(customer_id, full_name, email) VALUES
(1,'Aarav Shah','aarav@example.com'),
(2,'Diya Patel','diya@example.com'),
(3,'Kabir Mehta','kabir@example.com');

INSERT INTO orders(order_id, customer_id, order_amount, order_status) VALUES
(101,1,2499.00,'PAID'),(102,2,799.00,'PENDING'),
(103,1,1599.00,'SHIPPED'),(104,3,499.00,'PAID');

-- 2. EXPAND: add new nullable columns; retain old columns for compatibility.
ALTER TABLE customers
  ADD COLUMN first_name VARCHAR(60) NULL,
  ADD COLUMN last_name VARCHAR(60) NULL;

ALTER TABLE orders
  ADD COLUMN total_amount DECIMAL(10,2) NULL;

-- 3. BACKFILL: populate the new representation.
-- This one-shot update is fine for this tiny lab. Large tables should be
-- processed in bounded, restartable batches with monitoring.
UPDATE customers
SET first_name = SUBSTRING_INDEX(full_name, ' ', 1),
    last_name = CASE WHEN LOCATE(' ', full_name) > 0
      THEN SUBSTRING(full_name, LOCATE(' ', full_name) + 1)
      ELSE '' END
WHERE first_name IS NULL OR last_name IS NULL;

UPDATE orders
SET total_amount = order_amount
WHERE total_amount IS NULL;

-- 4. VALIDATE: expected counts are zero.
SELECT COUNT(*) AS customers_missing_new_name
FROM customers WHERE first_name IS NULL OR last_name IS NULL;

SELECT COUNT(*) AS orders_missing_new_amount
FROM orders WHERE total_amount IS NULL;

SELECT COUNT(*) AS amount_mismatches
FROM orders WHERE total_amount <> order_amount;

-- 5. COMPATIBILITY / DUAL-WRITE example during rolling deployment.
-- Old application instances may still need legacy columns. Keep both
-- representations synchronized until all old versions are retired.
INSERT INTO customers
  (customer_id, full_name, email, first_name, last_name)
VALUES (4,'Mira Rao','mira@example.com','Mira','Rao');

INSERT INTO orders
  (order_id, customer_id, order_amount, total_amount, order_status)
VALUES (105,4,1299.00,1299.00,'PAID');

SELECT customer_id, full_name, first_name, last_name
FROM customers ORDER BY customer_id;

-- 6. SWITCH READS: new application code reads the new columns.
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name, email
FROM customers;

SELECT order_id, customer_id, total_amount, order_status
FROM orders;

-- 7. OPTIONAL CONTRACT: DO NOT RUN until old application versions,
-- reports, ETL jobs and integrations no longer use the legacy columns.
-- Also confirm validation, backup/recovery, monitoring and rollback window.
-- ALTER TABLE customers DROP COLUMN full_name;
-- ALTER TABLE orders DROP COLUMN order_amount;

-- After checking no NULL values and confirming app writes, constraints
-- could be tightened in a later migration:
-- ALTER TABLE customers
--   MODIFY first_name VARCHAR(60) NOT NULL,
--   MODIFY last_name VARCHAR(60) NOT NULL;
-- ALTER TABLE orders MODIFY total_amount DECIMAL(10,2) NOT NULL;

-- 8. Simple migration history example
CREATE TABLE IF NOT EXISTS schema_migrations (
  version VARCHAR(50) PRIMARY KEY,
  description VARCHAR(255) NOT NULL,
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO schema_migrations(version, description) VALUES
('099_expand','Added new customer name and order amount columns'),
('099_backfill','Backfilled and validated new columns')
ON DUPLICATE KEY UPDATE description = VALUES(description);

SELECT * FROM schema_migrations ORDER BY applied_at;

-- 9. Operational inspection
SHOW CREATE TABLE customers;
SHOW CREATE TABLE orders;
SHOW FULL PROCESSLIST;

-- MySQL metadata locks can delay DDL. Check active transactions and lock
-- waits before production changes. DDL algorithm/lock support is operation-
-- and version-dependent; never assume every ALTER is instant or nonblocking.

-- Practice:
-- A. Add phone_number using an expand step.
-- B. Backfill it and write validation queries.
-- C. Demonstrate dual writes for old/new fields.
-- D. Design a safe contract step.
-- E. Explain why huge one-shot UPDATEs can be risky.

-- Optional cleanup:
-- DROP DATABASE sql_schema_migration_lab;
