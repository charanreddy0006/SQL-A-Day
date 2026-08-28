-- ================================================================
-- SQL-A-Day - DAY 71
-- Topic: Temporal Data, History Tracking, Auditing & SCD Type 2
-- Database: sql_temporal_history_lab
-- SQL Dialect: MySQL 8+
-- ================================================================

DROP DATABASE IF EXISTS sql_temporal_history_lab;
CREATE DATABASE sql_temporal_history_lab;
USE sql_temporal_history_lab;

-- ================================================================
-- 1. CURRENT CUSTOMER TABLE
-- ================================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    customer_status ENUM('Active', 'Inactive') NOT NULL DEFAULT 'Active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customers_email (email),
    INDEX idx_customers_city (city),
    INDEX idx_customers_status (customer_status)
) ENGINE=InnoDB;

-- ================================================================
-- 2. CUSTOMER HISTORY / SCD TYPE 2
-- ================================================================

CREATE TABLE customer_history (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    customer_status ENUM('Active', 'Inactive') NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NULL,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    change_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) NOT NULL DEFAULT 'system',
    INDEX idx_history_customer (customer_id),
    INDEX idx_history_current (customer_id, is_current),
    INDEX idx_history_period (customer_id, valid_from, valid_to),
    INDEX idx_history_valid_from (valid_from),
    INDEX idx_history_valid_to (valid_to)
) ENGINE=InnoDB;

-- ================================================================
-- 3. PRODUCTS AND PRICE HISTORY
-- ================================================================

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    product_status ENUM('Available', 'Out of Stock', 'Discontinued')
        NOT NULL DEFAULT 'Available',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE product_price_history (
    price_history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    old_price DECIMAL(12,2),
    new_price DECIMAL(12,2) NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NULL,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) NOT NULL DEFAULT 'system',
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_price_product (product_id),
    INDEX idx_price_period (product_id, valid_from, valid_to),
    INDEX idx_price_current (product_id, is_current)
) ENGINE=InnoDB;

-- ================================================================
-- 4. GENERIC AUDIT LOG
-- ================================================================

CREATE TABLE audit_log (
    audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    action_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(100) NOT NULL DEFAULT 'system',
    INDEX idx_audit_table_record (table_name, record_id),
    INDEX idx_audit_action (action_type),
    INDEX idx_audit_changed_at (changed_at)
) ENGINE=InnoDB;

-- ================================================================
-- 5. SAMPLE DATA
-- ================================================================

INSERT INTO customers
(customer_name, email, city, state, customer_status, created_at, updated_at)
VALUES
('Arjun Reddy', 'arjun@example.com', 'Hyderabad', 'Telangana', 'Active',
 '2025-01-05 10:00:00', '2025-01-05 10:00:00'),
('Priya Sharma', 'priya@example.com', 'Bengaluru', 'Karnataka', 'Active',
 '2025-01-10 11:00:00', '2025-01-10 11:00:00'),
('Rahul Verma', 'rahul@example.com', 'Mumbai', 'Maharashtra', 'Active',
 '2025-02-01 09:00:00', '2025-02-01 09:00:00'),
('Sneha Rao', 'sneha@example.com', 'Chennai', 'Tamil Nadu', 'Active',
 '2025-02-15 14:00:00', '2025-02-15 14:00:00'),
('Kiran Kumar', 'kiran@example.com', 'Pune', 'Maharashtra', 'Inactive',
 '2025-03-01 12:00:00', '2025-03-01 12:00:00');

INSERT INTO products
(product_name, category, price, product_status, created_at, updated_at)
VALUES
('Laptop Pro 14', 'Laptop', 85000, 'Available',
 '2025-01-01 10:00:00', '2025-01-01 10:00:00'),
('Smartphone X', 'Mobile', 55000, 'Available',
 '2025-01-05 10:00:00', '2025-01-05 10:00:00'),
('4K Monitor', 'Monitor', 28000, 'Available',
 '2025-01-10 10:00:00', '2025-01-10 10:00:00'),
('Mechanical Keyboard', 'Accessories', 4500, 'Available',
 '2025-01-15 10:00:00', '2025-01-15 10:00:00'),
('Noise Cancelling Headphones', 'Audio', 18000, 'Available',
 '2025-01-20 10:00:00', '2025-01-20 10:00:00');

INSERT INTO customer_history
(customer_id, customer_name, email, city, state, customer_status,
 valid_from, valid_to, is_current, change_type, changed_at, changed_by)
SELECT
    customer_id, customer_name, email, city, state, customer_status,
    created_at, NULL, TRUE, 'INSERT', created_at, 'system'
FROM customers;

INSERT INTO product_price_history
(product_id, old_price, new_price, valid_from, valid_to,
 is_current, changed_at, changed_by)
SELECT
    product_id, NULL, price, created_at, NULL, TRUE, created_at, 'system'
FROM products;

-- ================================================================
-- 6. CURRENT DATA
-- ================================================================

SELECT * FROM customers;
SELECT * FROM products;

-- ================================================================
-- 7. CUSTOMER HISTORY - CHANGE 1
-- ================================================================

SET @change_time_1 = '2025-04-10 10:00:00';

UPDATE customer_history
SET valid_to = @change_time_1,
    is_current = FALSE
WHERE customer_id = 1
AND is_current = TRUE;

UPDATE customers
SET city = 'Bengaluru',
    state = 'Karnataka',
    updated_at = @change_time_1
WHERE customer_id = 1;

INSERT INTO customer_history
(customer_id, customer_name, email, city, state, customer_status,
 valid_from, valid_to, is_current, change_type, changed_at, changed_by)
SELECT
    customer_id, customer_name, email, city, state, customer_status,
    @change_time_1, NULL, TRUE, 'UPDATE', @change_time_1, 'admin_user'
FROM customers
WHERE customer_id = 1;

-- ================================================================
-- 8. CUSTOMER HISTORY - CHANGE 2
-- ================================================================

SET @change_time_2 = '2025-07-15 14:30:00';

UPDATE customer_history
SET valid_to = @change_time_2,
    is_current = FALSE
WHERE customer_id = 1
AND is_current = TRUE;

UPDATE customers
SET city = 'Hyderabad',
    state = 'Telangana',
    updated_at = @change_time_2
WHERE customer_id = 1;

INSERT INTO customer_history
(customer_id, customer_name, email, city, state, customer_status,
 valid_from, valid_to, is_current, change_type, changed_at, changed_by)
SELECT
    customer_id, customer_name, email, city, state, customer_status,
    @change_time_2, NULL, TRUE, 'UPDATE', @change_time_2, 'admin_user'
FROM customers
WHERE customer_id = 1;

-- ================================================================
-- 9. COMPLETE CUSTOMER HISTORY
-- ================================================================

SELECT
    history_id,
    customer_id,
    customer_name,
    city,
    state,
    valid_from,
    valid_to,
    is_current,
    change_type,
    changed_at,
    changed_by
FROM customer_history
WHERE customer_id = 1
ORDER BY valid_from;

-- ================================================================
-- 10. CURRENT VERSION
-- ================================================================

SELECT
    customer_id,
    customer_name,
    city,
    state,
    customer_status,
    valid_from,
    is_current
FROM customer_history
WHERE is_current = TRUE
ORDER BY customer_id;

-- ================================================================
-- 11. POINT-IN-TIME QUERY
-- ================================================================

SELECT
    customer_id,
    customer_name,
    city,
    state,
    valid_from,
    valid_to
FROM customer_history
WHERE customer_id = 1
AND valid_from <= '2025-05-01 00:00:00'
AND (valid_to IS NULL OR valid_to > '2025-05-01 00:00:00');

-- ================================================================
-- 12. SECOND POINT-IN-TIME QUERY
-- ================================================================

SELECT
    customer_id,
    customer_name,
    city,
    state,
    valid_from,
    valid_to
FROM customer_history
WHERE customer_id = 1
AND valid_from <= '2025-08-01 00:00:00'
AND (valid_to IS NULL OR valid_to > '2025-08-01 00:00:00');

-- ================================================================
-- 13. PRODUCT PRICE CHANGE 1
-- ================================================================

SET @price_change_1 = '2025-05-01 09:00:00';

UPDATE product_price_history
SET valid_to = @price_change_1,
    is_current = FALSE
WHERE product_id = 1
AND is_current = TRUE;

UPDATE products
SET price = 92000,
    updated_at = @price_change_1
WHERE product_id = 1;

INSERT INTO product_price_history
(product_id, old_price, new_price, valid_from, valid_to,
 is_current, changed_at, changed_by)
VALUES
(1, 85000, 92000, @price_change_1, NULL, TRUE,
 @price_change_1, 'pricing_admin');

-- ================================================================
-- 14. PRODUCT PRICE CHANGE 2
-- ================================================================

SET @price_change_2 = '2025-08-01 09:00:00';

UPDATE product_price_history
SET valid_to = @price_change_2,
    is_current = FALSE
WHERE product_id = 1
AND is_current = TRUE;

UPDATE products
SET price = 88000,
    updated_at = @price_change_2
WHERE product_id = 1;

INSERT INTO product_price_history
(product_id, old_price, new_price, valid_from, valid_to,
 is_current, changed_at, changed_by)
VALUES
(1, 92000, 88000, @price_change_2, NULL, TRUE,
 @price_change_2, 'pricing_admin');

-- ================================================================
-- 15. PRICE HISTORY
-- ================================================================

SELECT
    price_history_id,
    product_id,
    old_price,
    new_price,
    valid_from,
    valid_to,
    is_current,
    changed_by
FROM product_price_history
WHERE product_id = 1
ORDER BY valid_from;

-- ================================================================
-- 16. HISTORICAL PRICE QUERY
-- ================================================================

SELECT
    product_id,
    old_price,
    new_price,
    valid_from,
    valid_to
FROM product_price_history
WHERE product_id = 1
AND valid_from <= '2025-06-01 00:00:00'
AND (valid_to IS NULL OR valid_to > '2025-06-01 00:00:00');

-- ================================================================
-- 17. CURRENT PRODUCT PRICES
-- ================================================================

SELECT
    p.product_id,
    p.product_name,
    p.price AS current_price,
    h.valid_from
FROM products AS p
JOIN product_price_history AS h
    ON h.product_id = p.product_id
   AND h.is_current = TRUE
ORDER BY p.product_id;

-- ================================================================
-- 18. PRICE CHANGE REPORT
-- ================================================================

SELECT
    p.product_name,
    h.old_price,
    h.new_price,
    ROUND(((h.new_price - h.old_price) / h.old_price) * 100, 2)
        AS percentage_change,
    h.changed_at,
    h.changed_by
FROM product_price_history AS h
JOIN products AS p
    ON p.product_id = h.product_id
WHERE h.old_price IS NOT NULL
ORDER BY h.changed_at;

-- ================================================================
-- 19. AUDIT LOG
-- ================================================================

INSERT INTO audit_log
(table_name, record_id, action_type, old_values, new_values,
 changed_at, changed_by)
VALUES
(
    'customers',
    1,
    'UPDATE',
    JSON_OBJECT('city', 'Mumbai', 'state', 'Maharashtra'),
    JSON_OBJECT('city', 'Bengaluru', 'state', 'Karnataka'),
    '2025-04-10 10:00:00',
    'admin_user'
);

INSERT INTO audit_log
(table_name, record_id, action_type, old_values, new_values,
 changed_at, changed_by)
VALUES
(
    'products',
    1,
    'UPDATE',
    JSON_OBJECT('price', 85000),
    JSON_OBJECT('price', 92000),
    '2025-05-01 09:00:00',
    'pricing_admin'
);

SELECT
    audit_id,
    table_name,
    record_id,
    action_type,
    old_values,
    new_values,
    changed_at,
    changed_by
FROM audit_log
ORDER BY changed_at;

-- ================================================================
-- 20. READ JSON AUDIT VALUES
-- ================================================================

SELECT
    audit_id,
    table_name,
    record_id,
    action_type,
    JSON_UNQUOTE(JSON_EXTRACT(old_values, '$.price')) AS old_price,
    JSON_UNQUOTE(JSON_EXTRACT(new_values, '$.price')) AS new_price,
    changed_by
FROM audit_log
WHERE table_name = 'products';

-- ================================================================
-- 21. HISTORY VERSION NUMBER
-- ================================================================

SELECT
    customer_id,
    customer_name,
    city,
    state,
    valid_from,
    valid_to,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY valid_from
    ) AS version_number
FROM customer_history
ORDER BY customer_id, valid_from;

-- ================================================================
-- 22. LAG() FOR PREVIOUS VALUE
-- ================================================================

SELECT
    customer_id,
    city,
    state,
    valid_from,
    LAG(city) OVER (
        PARTITION BY customer_id
        ORDER BY valid_from
    ) AS previous_city,
    LAG(state) OVER (
        PARTITION BY customer_id
        ORDER BY valid_from
    ) AS previous_state
FROM customer_history
ORDER BY customer_id, valid_from;

-- ================================================================
-- 23. DETECT LOCATION CHANGES
-- ================================================================

WITH history_with_previous AS (
    SELECT
        customer_id,
        city,
        state,
        valid_from,
        LAG(city) OVER (
            PARTITION BY customer_id
            ORDER BY valid_from
        ) AS previous_city,
        LAG(state) OVER (
            PARTITION BY customer_id
            ORDER BY valid_from
        ) AS previous_state
    FROM customer_history
)
SELECT
    customer_id,
    previous_city,
    city AS new_city,
    previous_state,
    state AS new_state,
    valid_from AS changed_at
FROM history_with_previous
WHERE previous_city IS NOT NULL
AND (
    previous_city <> city
    OR previous_state <> state
)
ORDER BY customer_id, changed_at;

-- ================================================================
-- 24. SCD TYPE 1 EXAMPLE
-- ================================================================

UPDATE customers
SET city = 'Chennai',
    state = 'Tamil Nadu'
WHERE customer_id = 2;

SELECT
    customer_id,
    customer_name,
    city,
    state
FROM customers
WHERE customer_id = 2;

-- Restore the value for the remaining demonstration.
UPDATE customers
SET city = 'Bengaluru',
    state = 'Karnataka'
WHERE customer_id = 2;

-- ================================================================
-- 25. SCD TYPE 2 EXAMPLE
-- ================================================================

SET @scd2_change = '2025-06-01 10:00:00';

UPDATE customer_history
SET valid_to = @scd2_change,
    is_current = FALSE
WHERE customer_id = 2
AND is_current = TRUE;

UPDATE customers
SET city = 'Hyderabad',
    state = 'Telangana',
    updated_at = @scd2_change
WHERE customer_id = 2;

INSERT INTO customer_history
(customer_id, customer_name, email, city, state, customer_status,
 valid_from, valid_to, is_current, change_type, changed_at, changed_by)
SELECT
    customer_id, customer_name, email, city, state, customer_status,
    @scd2_change, NULL, TRUE, 'UPDATE', @scd2_change, 'admin_user'
FROM customers
WHERE customer_id = 2;

SELECT
    customer_id,
    customer_name,
    city,
    state,
    valid_from,
    valid_to,
    is_current
FROM customer_history
WHERE customer_id = 2
ORDER BY valid_from;

-- ================================================================
-- 26. POINT-IN-TIME REPORT FOR ALL CUSTOMERS
-- ================================================================

WITH requested_time AS (
    SELECT '2025-05-15 12:00:00' AS as_of_time
)
SELECT
    h.customer_id,
    h.customer_name,
    h.city,
    h.state,
    h.customer_status,
    h.valid_from,
    h.valid_to
FROM customer_history AS h
CROSS JOIN requested_time AS r
WHERE h.valid_from <= r.as_of_time
AND (h.valid_to IS NULL OR h.valid_to > r.as_of_time)
ORDER BY h.customer_id;

-- ================================================================
-- 27. CURRENT VS HISTORICAL DATA
-- ================================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.city AS current_city,
    h.city AS historical_city,
    h.valid_from,
    h.valid_to
FROM customers AS c
JOIN customer_history AS h
    ON h.customer_id = c.customer_id
WHERE h.is_current = FALSE
ORDER BY c.customer_id, h.valid_from;

-- ================================================================
-- 28. HISTORY COUNT
-- ================================================================

SELECT
    customer_id,
    COUNT(*) AS number_of_versions,
    MIN(valid_from) AS first_version,
    MAX(valid_from) AS latest_version
FROM customer_history
GROUP BY customer_id
ORDER BY number_of_versions DESC;

-- ================================================================
-- 29. DATA QUALITY CHECKS
-- ================================================================

SELECT *
FROM customer_history
WHERE is_current = TRUE
AND valid_to IS NOT NULL;

SELECT *
FROM customer_history
WHERE is_current = FALSE
AND valid_to IS NULL;

-- ================================================================
-- 30. OVERLAPPING PERIOD CHECK
-- ================================================================

SELECT
    h1.customer_id,
    h1.history_id AS first_history_id,
    h2.history_id AS second_history_id,
    h1.valid_from AS first_valid_from,
    h1.valid_to AS first_valid_to,
    h2.valid_from AS second_valid_from,
    h2.valid_to AS second_valid_to
FROM customer_history AS h1
JOIN customer_history AS h2
    ON h1.customer_id = h2.customer_id
   AND h1.history_id < h2.history_id
   AND h1.valid_from <
       COALESCE(h2.valid_to, '9999-12-31 23:59:59')
   AND h2.valid_from <
       COALESCE(h1.valid_to, '9999-12-31 23:59:59');

-- ================================================================
-- 31. FINAL AUDIT SUMMARY
-- ================================================================

SELECT
    action_type,
    COUNT(*) AS action_count
FROM audit_log
GROUP BY action_type
ORDER BY action_count DESC;

SELECT
    table_name,
    COUNT(*) AS audit_count
FROM audit_log
GROUP BY table_name
ORDER BY audit_count DESC;

-- ================================================================
-- 32. VALIDATION
-- ================================================================

SELECT COUNT(*) AS customer_count FROM customers;
SELECT COUNT(*) AS customer_history_count FROM customer_history;
SELECT COUNT(*) AS product_count FROM products;
SELECT COUNT(*) AS price_history_count FROM product_price_history;
SELECT COUNT(*) AS audit_count FROM audit_log;

-- ================================================================
-- END OF DAY 71
-- ================================================================
