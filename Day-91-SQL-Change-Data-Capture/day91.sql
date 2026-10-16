-- Day 91: SQL Change Data Capture (CDC) & Incremental Loading
-- MySQL 8.0+ | Synthetic learning data
CREATE DATABASE IF NOT EXISTS sql_cdc_lab;
USE sql_cdc_lab;

DROP VIEW IF EXISTS vw_pending_changes;
DROP TRIGGER IF EXISTS trg_customer_ai;
DROP TRIGGER IF EXISTS trg_customer_au;
DROP TRIGGER IF EXISTS trg_customer_ad;
DROP TABLE IF EXISTS cdc_checkpoint;
DROP TABLE IF EXISTS customer_changes;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
 customer_id INT PRIMARY KEY,
 full_name VARCHAR(100) NOT NULL,
 email VARCHAR(150),
 city VARCHAR(80),
 status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
   ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE customer_changes (
 change_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 customer_id INT NOT NULL,
 operation_type ENUM('INSERT','UPDATE','DELETE') NOT NULL,
 changed_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
 old_name VARCHAR(100), new_name VARCHAR(100),
 old_email VARCHAR(150), new_email VARCHAR(150),
 old_city VARCHAR(80), new_city VARCHAR(80),
 old_status VARCHAR(20), new_status VARCHAR(20),
 processed BOOLEAN NOT NULL DEFAULT FALSE,
 INDEX idx_pending(processed,change_id),
 INDEX idx_customer(customer_id,change_id)
);
CREATE TABLE cdc_checkpoint (
 consumer_name VARCHAR(100) PRIMARY KEY,
 last_change_id BIGINT NOT NULL DEFAULT 0,
 updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
   ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO customers(customer_id,full_name,email,city,status) VALUES
(101,'Aarav Shah','aarav@example.com','Rajkot','ACTIVE'),
(102,'Diya Patel','diya@example.com','Ahmedabad','ACTIVE'),
(103,'Kabir Mehta','kabir@example.com','Surat','ACTIVE');
INSERT INTO cdc_checkpoint(consumer_name,last_change_id)
VALUES ('analytics_warehouse',0);

DELIMITER //
CREATE TRIGGER trg_customer_ai AFTER INSERT ON customers FOR EACH ROW
BEGIN
 INSERT INTO customer_changes(customer_id,operation_type,new_name,new_email,new_city,new_status)
 VALUES(NEW.customer_id,'INSERT',NEW.full_name,NEW.email,NEW.city,NEW.status);
END//
CREATE TRIGGER trg_customer_au AFTER UPDATE ON customers FOR EACH ROW
BEGIN
 INSERT INTO customer_changes(customer_id,operation_type,
 old_name,new_name,old_email,new_email,old_city,new_city,old_status,new_status)
 VALUES(NEW.customer_id,'UPDATE',
 OLD.full_name,NEW.full_name,OLD.email,NEW.email,OLD.city,NEW.city,OLD.status,NEW.status);
END//
CREATE TRIGGER trg_customer_ad AFTER DELETE ON customers FOR EACH ROW
BEGIN
 INSERT INTO customer_changes(customer_id,operation_type,old_name,old_email,old_city,old_status)
 VALUES(OLD.customer_id,'DELETE',OLD.full_name,OLD.email,OLD.city,OLD.status);
END//
DELIMITER ;

-- 1. Inspect initial rows and insert events.
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM customer_changes ORDER BY change_id;

-- 2. Generate example changes.
INSERT INTO customers VALUES
(104,'Meera Joshi','meera@example.com','Vadodara','ACTIVE',CURRENT_TIMESTAMP);
UPDATE customers SET city='Gandhinagar',email='diya.patel@example.com'
WHERE customer_id=102;
UPDATE customers SET status='INACTIVE' WHERE customer_id=103;
DELETE FROM customers WHERE customer_id=101;

-- 3. Inspect captured inserts, updates, and deletes.
SELECT change_id,customer_id,operation_type,changed_at,
       old_city,new_city,old_status,new_status,processed
FROM customer_changes ORDER BY change_id;

-- 4. Pending events view.
CREATE OR REPLACE VIEW vw_pending_changes AS
SELECT * FROM customer_changes WHERE processed=FALSE;
SELECT * FROM vw_pending_changes ORDER BY change_id;

-- 5. Incremental extraction by checkpoint and batch high-water mark.
-- Run these statements in the same session.
SELECT @last_id := last_change_id FROM cdc_checkpoint
WHERE consumer_name='analytics_warehouse';
SELECT @high_id := COALESCE(MAX(change_id),@last_id) FROM customer_changes;
SELECT * FROM customer_changes
WHERE change_id>@last_id AND change_id<=@high_id
ORDER BY change_id;

-- 6. Advance checkpoint ONLY after downstream processing succeeds.
-- UPDATE cdc_checkpoint SET last_change_id=@high_id
-- WHERE consumer_name='analytics_warehouse';

-- 7. Counts by operation type.
SELECT operation_type,COUNT(*) AS changes
FROM customer_changes GROUP BY operation_type;

-- 8. Latest event for each customer.
WITH ranked AS (
 SELECT c.*,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY change_id DESC) AS rn
 FROM customer_changes c
)
SELECT customer_id,operation_type,changed_at,new_name,new_email,new_city,new_status
FROM ranked WHERE rn=1 ORDER BY customer_id;

-- 9. Customers with multiple changes.
SELECT customer_id,COUNT(*) AS change_count,
       MIN(changed_at) AS first_change,MAX(changed_at) AS latest_change
FROM customer_changes GROUP BY customer_id HAVING COUNT(*)>1;

-- 10. Current-state snapshot reconstructed from latest events.
-- Latest DELETE events are excluded from the active snapshot.
WITH latest AS (
 SELECT c.*,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY change_id DESC) AS rn
 FROM customer_changes c
)
SELECT customer_id,new_name AS full_name,new_email AS email,
       new_city AS city,new_status AS status
FROM latest WHERE rn=1 AND operation_type<>'DELETE';

-- Practice:
-- A. Add a phone field to the source and change log.
-- B. Find events where city changed.
-- C. Explain why downstream systems need delete events/tombstones.
-- D. Design an idempotent consumer that can safely retry a batch.
-- E. Explain why a checkpoint must not advance before successful processing.

-- Optional cleanup:
-- DROP VIEW IF EXISTS vw_pending_changes;
-- DROP TRIGGER IF EXISTS trg_customer_ai;
-- DROP TRIGGER IF EXISTS trg_customer_au;
-- DROP TRIGGER IF EXISTS trg_customer_ad;
-- DROP TABLE IF EXISTS cdc_checkpoint;
-- DROP TABLE IF EXISTS customer_changes;
-- DROP TABLE IF EXISTS customers;
-- DROP DATABASE IF EXISTS sql_cdc_lab;
