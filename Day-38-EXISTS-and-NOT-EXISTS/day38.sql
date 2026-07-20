-- Day 38 : EXISTS and NOT EXISTS

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Customers Table
--------------------------------------------------

CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

INSERT INTO customers VALUES
(1,'John'),
(2,'Emma'),
(3,'David'),
(4,'Sophia'),
(5,'James');

--------------------------------------------------
-- Orders Table
--------------------------------------------------

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(10,2)
);

INSERT INTO orders VALUES
(101,1,1500),
(102,1,2500),
(103,3,1800),
(104,4,3200);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM customers;
SELECT * FROM orders;

--------------------------------------------------
-- Example 1 : EXISTS
--------------------------------------------------

SELECT customer_name
FROM customers c
WHERE EXISTS
(
    SELECT 1
    FROM orders o
    WHERE c.customer_id = o.customer_id
);

--------------------------------------------------
-- Example 2 : NOT EXISTS
--------------------------------------------------

SELECT customer_name
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders o
    WHERE c.customer_id = o.customer_id
);

--------------------------------------------------
-- Example 3 : Customers with Orders > 2000
--------------------------------------------------

SELECT customer_name
FROM customers c
WHERE EXISTS
(
    SELECT 1
    FROM orders o
    WHERE c.customer_id = o.customer_id
      AND amount > 2000
);

--------------------------------------------------
-- Example 4 : Customers Without Large Orders
--------------------------------------------------

SELECT customer_name
FROM customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM orders o
    WHERE c.customer_id = o.customer_id
      AND amount > 3000
);