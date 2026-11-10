-- SQL-A-Day | Day 97: MySQL UUIDs and Binary UUID Storage
-- Requires MySQL 8.0+. Run in a practice environment.

CREATE DATABASE IF NOT EXISTS sql_uuid_lab;
USE sql_uuid_lab;

-- 1. Generate UUID values (MySQL UUID() produces a time-based UUIDv1).
SELECT UUID() AS generated_uuid;

-- 2. Readable UUID storage: CHAR(36)
DROP TABLE IF EXISTS customers_char;
CREATE TABLE customers_char (
    customer_id CHAR(36) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

INSERT INTO customers_char (customer_id, customer_name, email)
VALUES
(UUID(), 'Aarav Shah', 'aarav@example.com'),
(UUID(), 'Diya Patel', 'diya@example.com'),
(UUID(), 'Kabir Mehta', 'kabir@example.com');

SELECT * FROM customers_char;

-- 3. Compact UUID storage: BINARY(16)
DROP TABLE IF EXISTS customers_binary;
CREATE TABLE customers_binary (
    customer_id BINARY(16) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

-- UUID() generates UUIDv1; swap_flag=1 is intended for UUIDv1 layout.
INSERT INTO customers_binary (customer_id, customer_name, email)
VALUES
(UUID_TO_BIN(UUID(), 1), 'Aarav Shah', 'aarav@example.com'),
(UUID_TO_BIN(UUID(), 1), 'Diya Patel', 'diya@example.com'),
(UUID_TO_BIN(UUID(), 1), 'Kabir Mehta', 'kabir@example.com');

-- Decode using the SAME swap flag used during encoding.
SELECT BIN_TO_UUID(customer_id, 1) AS customer_uuid,
       customer_name, email
FROM customers_binary;

-- 4. Round-trip conversion
SET @uuid_text = '6ccd780c-baba-1026-9564-5b8c656024db';
SET @uuid_binary = UUID_TO_BIN(@uuid_text, 1);
SELECT @uuid_text AS original_uuid,
       HEX(@uuid_binary) AS binary_hex,
       BIN_TO_UUID(@uuid_binary, 1) AS converted_back;

-- 5. Lookup using a UUID string supplied by an application
SELECT customer_name, email
FROM customers_binary
WHERE customer_id = UUID_TO_BIN(
    (SELECT customer_id FROM customers_char
     WHERE email = 'aarav@example.com'), 1
);
-- The example above is intentionally not executable as written because the
-- subquery returns UUID text from a different generated row. Use the pattern:
-- WHERE customer_id = UUID_TO_BIN('known-uuid-string', 1);

-- 6. UUID primary and foreign keys
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS app_users;

CREATE TABLE app_users (
    user_id BINARY(16) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE orders (
    order_id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    order_total DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orders_users FOREIGN KEY (user_id)
        REFERENCES app_users(user_id)
);

INSERT INTO app_users (user_id, full_name, email)
VALUES
(UUID_TO_BIN(UUID(), 1), 'Mira Rao', 'mira@example.com'),
(UUID_TO_BIN(UUID(), 1), 'Arjun Nair', 'arjun@example.com');

INSERT INTO orders (order_id, user_id, order_total, order_status)
SELECT UUID_TO_BIN(UUID(), 1), user_id, 2499.00, 'PAID'
FROM app_users WHERE email = 'mira@example.com';

INSERT INTO orders (order_id, user_id, order_total, order_status)
SELECT UUID_TO_BIN(UUID(), 1), user_id, 799.00, 'PENDING'
FROM app_users WHERE email = 'arjun@example.com';

SELECT BIN_TO_UUID(o.order_id, 1) AS order_uuid,
       u.full_name, o.order_total, o.order_status
FROM orders o
JOIN app_users u ON u.user_id = o.user_id;

-- 7. Compare column storage
SELECT OCTET_LENGTH(customer_id) AS uuid_text_bytes
FROM customers_char LIMIT 1;

SELECT OCTET_LENGTH(customer_id) AS uuid_binary_bytes
FROM customers_binary LIMIT 1;

-- 8. UUIDv4 caution:
-- For UUIDv4 values generated externally, do not blindly use swap_flag=1.
-- Use UUID_TO_BIN(uuid_v4_text) and BIN_TO_UUID(binary_uuid) with default 0.
-- Always use matching flags for encoding and decoding.

-- 9. Practice:
-- a) Create products with BINARY(16) primary key.
-- b) Insert three rows using UUID_TO_BIN(UUID(), 1).
-- c) Display IDs with BIN_TO_UUID(product_id, 1).
-- d) Create product_reviews with a BINARY(16) foreign key.
-- e) Compare CHAR(36) and BINARY(16) using OCTET_LENGTH().

-- Optional cleanup:
-- DROP DATABASE sql_uuid_lab;
