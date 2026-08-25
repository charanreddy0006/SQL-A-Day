-- ============================================================
-- SQL-A-Day - Day 68
-- Topic: SQL Transaction Isolation Levels & Concurrency
-- Database: concurrency_lab
-- SQL Dialect: MySQL 8+
-- Storage Engine: InnoDB
-- ============================================================
-- IMPORTANT:
-- Concurrency demonstrations marked SESSION A / SESSION B
-- require two separate MySQL connections.
-- ============================================================

DROP DATABASE IF EXISTS concurrency_lab;
CREATE DATABASE concurrency_lab;
USE concurrency_lab;

-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE bank_accounts (
    account_id INT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_holder VARCHAR(100) NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    account_status ENUM('Active','Frozen','Closed') NOT NULL DEFAULT 'Active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (balance >= 0)
) ENGINE=InnoDB;

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    product_status ENUM('Available','Out of Stock','Discontinued') NOT NULL DEFAULT 'Available',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CHECK (stock_quantity >= 0),
    CHECK (unit_price >= 0)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    order_status ENUM('Pending','Confirmed','Cancelled') NOT NULL DEFAULT 'Pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES inventory(product_id),
    CHECK (quantity > 0),
    CHECK (total_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE concurrency_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    operation_name VARCHAR(100) NOT NULL,
    session_name VARCHAR(50) NOT NULL,
    description VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 2. SAMPLE DATA
-- ============================================================

INSERT INTO bank_accounts
(account_id, account_number, account_holder, balance, account_status)
VALUES
(1,'BANK10001','Arjun Mehta',50000.00,'Active'),
(2,'BANK10002','Priya Sharma',30000.00,'Active'),
(3,'BANK10003','Rahul Verma',75000.00,'Active'),
(4,'BANK10004','Sneha Reddy',45000.00,'Active');

INSERT INTO inventory
(product_id,product_name,stock_quantity,unit_price,product_status)
VALUES
(101,'Laptop',20,65000.00,'Available'),
(102,'Mechanical Keyboard',50,4500.00,'Available'),
(103,'Wireless Mouse',100,1500.00,'Available'),
(104,'Monitor',15,18000.00,'Available'),
(105,'USB-C Hub',0,3000.00,'Out of Stock');

SELECT * FROM bank_accounts;
SELECT * FROM inventory;

-- ============================================================
-- 3. CHECK ISOLATION LEVEL
-- ============================================================

SELECT @@transaction_isolation AS session_isolation_level;
SELECT @@global.transaction_isolation AS global_isolation_level;

-- Common isolation levels:
-- READ UNCOMMITTED
-- READ COMMITTED
-- REPEATABLE READ
-- SERIALIZABLE

-- ============================================================
-- 4. DIRTY READ / READ UNCOMMITTED
-- ============================================================
-- SESSION A:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- START TRANSACTION;
-- UPDATE bank_accounts SET balance = balance - 5000 WHERE account_id = 1;
-- Keep transaction open.
--
-- SESSION B:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM bank_accounts WHERE account_id = 1;
--
-- SESSION A:
-- ROLLBACK;
--
-- SESSION B may have read the uncommitted value before it was rolled back.
-- SESSION B:
-- COMMIT;
-- ============================================================

-- ============================================================
-- 5. READ COMMITTED / NON-REPEATABLE READ
-- ============================================================
-- SESSION A:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM bank_accounts WHERE account_id = 2;
--
-- SESSION B:
-- START TRANSACTION;
-- UPDATE bank_accounts SET balance = balance + 5000 WHERE account_id = 2;
-- COMMIT;
--
-- SESSION A:
-- SELECT balance FROM bank_accounts WHERE account_id = 2;
-- COMMIT;
--
-- The second read can see the newly committed value.
-- ============================================================

-- ============================================================
-- 6. REPEATABLE READ
-- ============================================================
-- MySQL InnoDB commonly uses REPEATABLE READ as its default.
--
-- SESSION A:
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT balance FROM bank_accounts WHERE account_id = 3;
--
-- SESSION B:
-- UPDATE bank_accounts SET balance = balance + 2000 WHERE account_id = 3;
-- COMMIT;
--
-- SESSION A:
-- SELECT balance FROM bank_accounts WHERE account_id = 3;
-- COMMIT;
--
-- Ordinary consistent reads in Session A use its transaction snapshot.
-- ============================================================

-- ============================================================
-- 7. PHANTOM READ CONCEPT
-- ============================================================
-- SESSION A:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT COUNT(*) FROM inventory WHERE stock_quantity > 10;
--
-- SESSION B:
-- INSERT INTO inventory(product_id,product_name,stock_quantity,unit_price)
-- VALUES(106,'Webcam',30,5000.00);
-- COMMIT;
--
-- SESSION A:
-- SELECT COUNT(*) FROM inventory WHERE stock_quantity > 10;
-- COMMIT;
--
-- A repeated range query may observe a different set of matching rows.
-- ============================================================

-- ============================================================
-- 8. SERIALIZABLE
-- ============================================================
-- SESSION A:
-- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- START TRANSACTION;
-- SELECT * FROM inventory WHERE stock_quantity > 10;
-- Keep transaction open.
--
-- SESSION B:
-- SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- START TRANSACTION;
-- INSERT INTO inventory(product_id,product_name,stock_quantity,unit_price)
-- VALUES(107,'Camera',25,25000.00);
--
-- Session B may wait because of the stronger concurrency control.
-- SESSION A: COMMIT;
-- SESSION B: COMMIT;
-- ============================================================

-- ============================================================
-- 9. LOST UPDATE CONCEPT
-- ============================================================
-- Initial stock = 20.
-- A reads 20. B reads 20.
-- A calculates 19. B calculates 18.
-- A writes 19. B writes 18.
-- One logical update can be lost.
-- Prefer an atomic UPDATE for simple counters.
-- ============================================================

START TRANSACTION;

UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;

INSERT INTO concurrency_log(operation_name,session_name,description)
VALUES('Atomic Stock Decrease','Session-A','Conditional atomic stock decrement');

COMMIT;

SELECT * FROM inventory WHERE product_id = 101;

-- ============================================================
-- 10. ROW LOCKING WITH FOR UPDATE
-- ============================================================

START TRANSACTION;

SELECT account_id,account_number,account_holder,balance
FROM bank_accounts
WHERE account_id = 1
FOR UPDATE;

UPDATE bank_accounts
SET balance = balance - 1000
WHERE account_id = 1
  AND balance >= 1000;

COMMIT;

-- ============================================================
-- 11. TWO-SESSION FOR UPDATE TEST
-- ============================================================
-- SESSION A:
-- START TRANSACTION;
-- SELECT balance FROM bank_accounts WHERE account_id = 2 FOR UPDATE;
-- Keep transaction open.
--
-- SESSION B:
-- START TRANSACTION;
-- UPDATE bank_accounts SET balance = balance + 1000 WHERE account_id = 2;
--
-- Session B may wait for Session A's lock.
--
-- SESSION A:
-- COMMIT;
--
-- SESSION B can continue, subject to the transaction state/configuration.
-- ============================================================

-- ============================================================
-- 12. INVENTORY RESERVATION
-- ============================================================

START TRANSACTION;

SELECT product_id,product_name,stock_quantity,unit_price
FROM inventory
WHERE product_id = 102
FOR UPDATE;

UPDATE inventory
SET stock_quantity = stock_quantity - 2,
    product_status = CASE
        WHEN stock_quantity - 2 = 0 THEN 'Out of Stock'
        ELSE 'Available'
    END
WHERE product_id = 102
  AND stock_quantity >= 2;

INSERT INTO orders(product_id,customer_name,quantity,total_amount,order_status)
SELECT product_id,'Demo Customer',2,unit_price * 2,'Confirmed'
FROM inventory
WHERE product_id = 102
  AND stock_quantity >= 0;

COMMIT;

SELECT * FROM inventory WHERE product_id = 102;
SELECT * FROM orders ORDER BY order_id DESC LIMIT 1;

-- ============================================================
-- 13. EXPLICIT ISOLATION LEVEL TESTS
-- ============================================================

SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;
START TRANSACTION;
SELECT account_id,account_holder,balance FROM bank_accounts ORDER BY account_id;
COMMIT;

SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation;
START TRANSACTION;
SELECT account_id,account_holder,balance FROM bank_accounts ORDER BY account_id;
COMMIT;

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT @@transaction_isolation;
START TRANSACTION;
SELECT account_id,account_holder,balance FROM bank_accounts ORDER BY account_id;
COMMIT;

-- Restore common InnoDB default for this session.
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- ============================================================
-- 14. DEADLOCK CONCEPT
-- ============================================================
-- SESSION A:
-- START TRANSACTION;
-- SELECT * FROM bank_accounts WHERE account_id = 1 FOR UPDATE;
-- SELECT * FROM bank_accounts WHERE account_id = 2 FOR UPDATE;
--
-- SESSION B:
-- START TRANSACTION;
-- SELECT * FROM bank_accounts WHERE account_id = 2 FOR UPDATE;
-- SELECT * FROM bank_accounts WHERE account_id = 1 FOR UPDATE;
--
-- This opposite lock order can create a circular wait.
-- InnoDB normally detects the deadlock and rolls back one victim.
-- Do this only as a controlled experiment.
-- ============================================================

-- ============================================================
-- 15. DEADLOCK PREVENTION: CONSISTENT LOCK ORDER
-- ============================================================

START TRANSACTION;

SELECT account_id,balance
FROM bank_accounts
WHERE account_id IN (1,2)
ORDER BY account_id
FOR UPDATE;

UPDATE bank_accounts
SET balance = balance - 2000
WHERE account_id = 1
  AND balance >= 2000;

UPDATE bank_accounts
SET balance = balance + 2000
WHERE account_id = 2;

INSERT INTO concurrency_log(operation_name,session_name,description)
VALUES('Ordered Account Transfer','Session-A','Locked account rows in ascending ID order');

COMMIT;

SELECT * FROM bank_accounts WHERE account_id IN (1,2) ORDER BY account_id;

-- ============================================================
-- 16. REPEATABLE READ SNAPSHOT DEMO
-- ============================================================
-- SESSION A:
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- SELECT account_id,balance FROM bank_accounts WHERE account_id = 1;
--
-- SESSION B:
-- START TRANSACTION;
-- UPDATE bank_accounts SET balance = balance + 500 WHERE account_id = 1;
-- COMMIT;
--
-- SESSION A:
-- SELECT account_id,balance FROM bank_accounts WHERE account_id = 1;
-- COMMIT;
--
-- Compare the two values to understand consistent reads.
-- ============================================================

-- ============================================================
-- 17. USEFUL LOCK / TRANSACTION INSPECTION
-- ============================================================
-- Depending on MySQL version and privileges, these can help inspect locks:
--
-- SELECT * FROM performance_schema.data_locks;
-- SELECT * FROM performance_schema.data_lock_waits;
-- SELECT * FROM information_schema.innodb_trx;
-- ============================================================

-- ============================================================
-- 18. FINAL REPORTS
-- ============================================================

SELECT account_id,account_number,account_holder,balance,account_status
FROM bank_accounts ORDER BY account_id;

SELECT product_id,product_name,stock_quantity,unit_price,product_status
FROM inventory ORDER BY product_id;

SELECT order_id,product_id,customer_name,quantity,total_amount,order_status,created_at
FROM orders ORDER BY order_id;

SELECT log_id,operation_name,session_name,description,created_at
FROM concurrency_log ORDER BY log_id;

SELECT @@transaction_isolation AS final_session_isolation_level;

-- ============================================================
-- END OF DAY 68
-- ============================================================