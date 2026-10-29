-- ============================================================
-- Day 96: MySQL Role-Based Access Control (RBAC)
-- MySQL 8.0+
-- Project: sql_rbac_lab
-- ============================================================
-- Goal: understand users, roles, privileges, GRANT, REVOKE,
-- default roles, and least-privilege access.
--
-- IMPORTANT:
-- This script creates database objects and roles in your MySQL
-- instance. Role creation/granting requires suitable privileges.
-- The CREATE USER examples are commented out intentionally.
-- Run only in a local development instance.

CREATE DATABASE IF NOT EXISTS sql_rbac_lab;
USE sql_rbac_lab;

DROP VIEW IF EXISTS vw_public_product_catalog;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(60) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1,'Aarav Shah','aarav@example.test','Rajkot'),
(2,'Diya Patel','diya@example.test','Ahmedabad'),
(3,'Kabir Mehta','kabir@example.test','Surat');

INSERT INTO products VALUES
(101,'Mechanical Keyboard','Accessories',2499.00,25),
(102,'Wireless Mouse','Accessories',899.00,50),
(103,'27-inch Monitor','Displays',14999.00,12),
(104,'USB-C Hub','Accessories',1799.00,30);

INSERT INTO orders VALUES
(5001,1,'2026-10-01','COMPLETED',3398.00),
(5002,2,'2026-10-02','PENDING',14999.00),
(5003,3,'2026-10-03','COMPLETED',1799.00);

CREATE VIEW vw_public_product_catalog AS
SELECT product_id, product_name, category, unit_price
FROM products;

-- ------------------------------------------------------------
-- 1. Inspect database-level and object-level privileges
-- ------------------------------------------------------------
SHOW PRIVILEGES;

-- See grants for the account currently connected.
-- This does not show every other account's grants.
SHOW GRANTS;

-- ------------------------------------------------------------
-- 2. Create roles
-- A role is a named collection of privileges.
-- Names are scoped as MySQL accounts: 'role_name'@'host'.
-- ------------------------------------------------------------
CREATE ROLE IF NOT EXISTS
    'rbac_readonly'@'%',
    'rbac_sales'@'%',
    'rbac_inventory'@'%';

-- ------------------------------------------------------------
-- 3. Grant minimum required privileges to each role
-- ------------------------------------------------------------

-- Read-only analyst: read selected business tables and the view.
GRANT SELECT ON sql_rbac_lab.customers
    TO 'rbac_readonly'@'%';
GRANT SELECT ON sql_rbac_lab.orders
    TO 'rbac_readonly'@'%';
GRANT SELECT ON sql_rbac_lab.vw_public_product_catalog
    TO 'rbac_readonly'@'%';

-- Sales role: read customers/catalog and create/read orders.
GRANT SELECT ON sql_rbac_lab.customers
    TO 'rbac_sales'@'%';
GRANT SELECT ON sql_rbac_lab.vw_public_product_catalog
    TO 'rbac_sales'@'%';
GRANT SELECT, INSERT, UPDATE ON sql_rbac_lab.orders
    TO 'rbac_sales'@'%';

-- Inventory role: read and update product inventory.
GRANT SELECT ON sql_rbac_lab.products
    TO 'rbac_inventory'@'%';
GRANT UPDATE (stock_quantity) ON sql_rbac_lab.products
    TO 'rbac_inventory'@'%';

-- ------------------------------------------------------------
-- 4. Inspect privileges granted to roles
-- ------------------------------------------------------------
SHOW GRANTS FOR 'rbac_readonly'@'%';
SHOW GRANTS FOR 'rbac_sales'@'%';
SHOW GRANTS FOR 'rbac_inventory'@'%';

-- ------------------------------------------------------------
-- 5. Create example users (OPTIONAL)
-- Replace the placeholder passwords with strong unique secrets.
-- Do not commit real passwords to GitHub or store them in scripts.
-- Run only if you have CREATE USER privilege and need test accounts.
-- ------------------------------------------------------------
-- CREATE USER 'analyst_demo'@'localhost'
--   IDENTIFIED BY 'REPLACE_WITH_A_STRONG_SECRET';
-- CREATE USER 'sales_demo'@'localhost'
--   IDENTIFIED BY 'REPLACE_WITH_A_STRONG_SECRET';
-- CREATE USER 'inventory_demo'@'localhost'
--   IDENTIFIED BY 'REPLACE_WITH_A_STRONG_SECRET';

-- ------------------------------------------------------------
-- 6. Assign roles to users (run after creating the optional users)
-- ------------------------------------------------------------
-- GRANT 'rbac_readonly'@'%' TO 'analyst_demo'@'localhost';
-- GRANT 'rbac_sales'@'%' TO 'sales_demo'@'localhost';
-- GRANT 'rbac_inventory'@'%' TO 'inventory_demo'@'localhost';

-- Set a role as the default role for a user.
-- SET DEFAULT ROLE 'rbac_readonly'@'%' TO 'analyst_demo'@'localhost';
-- SET DEFAULT ROLE 'rbac_sales'@'%' TO 'sales_demo'@'localhost';
-- SET DEFAULT ROLE 'rbac_inventory'@'%' TO 'inventory_demo'@'localhost';

-- ------------------------------------------------------------
-- 7. Inspect a user's grants and role assignment (optional users)
-- ------------------------------------------------------------
-- SHOW GRANTS FOR 'analyst_demo'@'localhost';
-- SHOW GRANTS FOR 'sales_demo'@'localhost';
-- SHOW GRANTS FOR 'inventory_demo'@'localhost';

-- ------------------------------------------------------------
-- 8. Revoke a privilege from a role
-- Example: remove UPDATE on orders from the sales role.
-- ------------------------------------------------------------
-- REVOKE UPDATE ON sql_rbac_lab.orders
--   FROM 'rbac_sales'@'%';

-- ------------------------------------------------------------
-- 9. Revoke a role from a user (optional users)
-- ------------------------------------------------------------
-- REVOKE 'rbac_inventory'@'%'
--   FROM 'inventory_demo'@'localhost';

-- ------------------------------------------------------------
-- 10. Demonstrate a column-level privilege
-- Inventory can update stock_quantity, but not product_name or price.
-- The role grant is above. Test after connecting as an assigned user.
-- ------------------------------------------------------------
-- Allowed by the role:
-- UPDATE sql_rbac_lab.products
-- SET stock_quantity = stock_quantity - 1
-- WHERE product_id = 101;
--
-- Should be denied if the user has only rbac_inventory:
-- UPDATE sql_rbac_lab.products
-- SET unit_price = 2599.00
-- WHERE product_id = 101;

-- ------------------------------------------------------------
-- 11. Role cleanup (optional)
-- Uncomment only when you want to remove the lab roles.
-- First revoke role assignments from users, if you created any.
-- ------------------------------------------------------------
-- DROP ROLE 'rbac_readonly'@'%';
-- DROP ROLE 'rbac_sales'@'%';
-- DROP ROLE 'rbac_inventory'@'%';

-- ------------------------------------------------------------
-- Practice prompts
-- ------------------------------------------------------------
-- A. Create a role that can SELECT products but cannot see customers.
-- B. Create a reporting role with SELECT access to the product view only.
-- C. Give a support role SELECT on customers and UPDATE on no other table.
-- D. Explain the difference between GRANTing a role and SET DEFAULT ROLE.
-- E. Design roles for analyst, sales, inventory, and database administrator.
-- F. Explain why application users should not receive ALL PRIVILEGES.
