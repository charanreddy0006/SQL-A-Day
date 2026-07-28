-- Day 46 : Database Denormalization

CREATE DATABASE ecommerce_db;

USE ecommerce_db;

--------------------------------------------------
-- Normalized Tables
--------------------------------------------------

CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

CREATE TABLE products(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id)
);

INSERT INTO customers VALUES
(1,'John'),
(2,'Emma');

INSERT INTO products VALUES
(101,'Laptop',800.00),
(102,'Mouse',20.00);

INSERT INTO orders VALUES
(1001,1,101),
(1002,2,102);

--------------------------------------------------
-- Retrieve Data Using JOIN
--------------------------------------------------

SELECT
o.order_id,
c.customer_name,
p.product_name,
p.price
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
JOIN products p
ON o.product_id = p.product_id;

--------------------------------------------------
-- Denormalized Table
--------------------------------------------------

CREATE TABLE order_summary(
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO order_summary VALUES
(1001,'John','Laptop',800.00),
(1002,'Emma','Mouse',20.00);

--------------------------------------------------
-- Retrieve Data Without JOIN
--------------------------------------------------

SELECT *
FROM order_summary;