-- SQL-A-Day Day 69
-- Topic: SQL Indexes & Query Performance
-- MySQL 8+ / InnoDB

DROP DATABASE IF EXISTS index_performance_lab;
CREATE DATABASE index_performance_lab;
USE index_performance_lab;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    state VARCHAR(80) NOT NULL,
    customer_status ENUM('Active','Inactive') NOT NULL DEFAULT 'Active',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category VARCHAR(80) NOT NULL,
    brand VARCHAR(80) NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    product_status ENUM('Available','Out of Stock','Discontinued') NOT NULL DEFAULT 'Available',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (price >= 0),
    CHECK (stock_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending','Confirmed','Shipped','Delivered','Cancelled') NOT NULL DEFAULT 'Pending',
    total_amount DECIMAL(12,2) NOT NULL,
    shipping_city VARCHAR(80) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CHECK (total_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    CHECK (quantity > 0),
    CHECK (unit_price >= 0)
) ENGINE=InnoDB;

INSERT INTO customers (customer_name,email,city,state,customer_status) VALUES
('Arjun Reddy','arjun@example.com','Hyderabad','Telangana','Active'),
('Priya Sharma','priya@example.com','Bengaluru','Karnataka','Active'),
('Rahul Verma','rahul@example.com','Mumbai','Maharashtra','Active'),
('Sneha Rao','sneha@example.com','Chennai','Tamil Nadu','Active'),
('Kiran Kumar','kiran@example.com','Pune','Maharashtra','Inactive'),
('Ananya Singh','ananya@example.com','Delhi','Delhi','Active'),
('Vikram Das','vikram@example.com','Kolkata','West Bengal','Active'),
('Meera Nair','meera@example.com','Kochi','Kerala','Active'),
('Rohit Patel','rohit@example.com','Ahmedabad','Gujarat','Active'),
('Divya Reddy','divya@example.com','Warangal','Telangana','Active');

INSERT INTO products (product_name,category,brand,price,stock_quantity,product_status) VALUES
('Laptop Pro 14','Laptop','TechPro',85000,25,'Available'),
('Laptop Air 13','Laptop','TechPro',72000,30,'Available'),
('Gaming Laptop X','Laptop','GameMax',125000,12,'Available'),
('Mechanical Keyboard','Accessories','KeyMaster',4500,80,'Available'),
('Wireless Mouse','Accessories','ClickPro',1500,150,'Available'),
('4K Monitor','Monitor','ViewMax',28000,40,'Available'),
('Office Monitor','Monitor','ViewMax',15000,60,'Available'),
('USB-C Hub','Accessories','ConnectX',3500,100,'Available'),
('Webcam HD','Accessories','VisionPro',5500,75,'Available'),
('Gaming Headset','Audio','GameMax',8000,45,'Available'),
('Bluetooth Speaker','Audio','SoundPro',6500,55,'Available'),
('Noise Cancelling Headphones','Audio','SoundPro',18000,35,'Available'),
('Tablet 11','Tablet','TechPro',32000,20,'Available'),
('Smartphone X','Smartphone','MobileMax',55000,50,'Available'),
('Smartphone Lite','Smartphone','MobileMax',22000,90,'Available');

INSERT INTO orders (customer_id,order_date,order_status,total_amount,shipping_city) VALUES
(1,'2026-01-10 10:30:00','Delivered',90000,'Hyderabad'),
(2,'2026-01-15 12:00:00','Shipped',4500,'Bengaluru'),
(3,'2026-02-02 14:20:00','Delivered',28000,'Mumbai'),
(4,'2026-02-12 09:15:00','Confirmed',72000,'Chennai'),
(6,'2026-02-20 16:10:00','Delivered',18000,'Delhi'),
(7,'2026-03-01 11:00:00','Pending',125000,'Kolkata'),
(8,'2026-03-05 13:45:00','Delivered',6500,'Kochi'),
(9,'2026-03-10 17:30:00','Confirmed',55000,'Ahmedabad'),
(10,'2026-03-18 15:00:00','Delivered',32000,'Warangal'),
(1,'2026-03-20 10:00:00','Pending',15000,'Hyderabad');

INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES
(1,1,1,85000),(1,5,2,1500),(2,4,1,4500),(3,6,1,28000),
(4,2,1,72000),(5,12,1,18000),(6,3,1,125000),(7,11,1,6500),
(8,14,1,55000),(9,13,1,32000),(10,7,1,15000);

-- Baseline execution plans
EXPLAIN SELECT * FROM customers WHERE city = 'Hyderabad';

-- Single-column indexes
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_customers_status ON customers(customer_status);
CREATE UNIQUE INDEX ux_customers_email ON customers(email);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_product_name ON products(product_name);
CREATE INDEX idx_orders_order_date ON orders(order_date);

-- Composite indexes
CREATE INDEX idx_products_category_price ON products(category,price);
CREATE INDEX idx_products_category_price_name ON products(category,price,product_name);
CREATE INDEX idx_orders_status_date ON orders(order_status,order_date);
CREATE INDEX idx_orders_customer_date ON orders(customer_id,order_date);

-- Foreign-key / JOIN indexes
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Covering-index example
CREATE INDEX idx_products_covering_category_name_price
ON products(category,product_name,price);

-- Date index
CREATE INDEX idx_customers_created_at ON customers(created_at);

-- Query-plan demonstrations
EXPLAIN SELECT * FROM products WHERE category='Laptop';
EXPLAIN SELECT * FROM products WHERE category='Laptop' AND price>70000;
EXPLAIN SELECT * FROM products WHERE price>70000;
EXPLAIN SELECT product_name,price FROM products WHERE category='Audio' ORDER BY price;
EXPLAIN SELECT order_id,customer_id,order_date,total_amount
FROM orders WHERE order_status='Delivered' AND order_date>='2026-02-01'
ORDER BY order_date;
EXPLAIN SELECT order_id,order_date,total_amount
FROM orders WHERE customer_id=1 ORDER BY order_date DESC;

-- EXPLAIN TREE
EXPLAIN FORMAT=TREE
SELECT product_name,category,price
FROM products
WHERE category='Laptop' AND price>70000;

-- EXPLAIN ANALYZE executes the query; use it when actual runtime
-- information is required.
EXPLAIN ANALYZE
SELECT product_id,product_name,category,price
FROM products
WHERE category='Laptop' AND price>70000;

-- Selectivity / cardinality exploration
SELECT customer_status,COUNT(*) AS total
FROM customers GROUP BY customer_status;

SELECT city,COUNT(*) AS total
FROM customers GROUP BY city ORDER BY total DESC;

SELECT category,COUNT(*) AS total
FROM products GROUP BY category ORDER BY total DESC;

SELECT COUNT(*) AS total_customers,
       COUNT(DISTINCT email) AS unique_emails,
       COUNT(DISTINCT customer_status) AS status_values,
       COUNT(DISTINCT city) AS city_values
FROM customers;

-- Function vs range predicate
EXPLAIN SELECT * FROM customers
WHERE DATE(created_at)='2026-01-01';

EXPLAIN SELECT * FROM customers
WHERE created_at>='2026-01-01 00:00:00'
AND created_at<'2026-01-02 00:00:00';

-- LIKE index behavior
EXPLAIN SELECT product_id,product_name
FROM products WHERE product_name LIKE 'Laptop%';

EXPLAIN SELECT product_id,product_name
FROM products WHERE product_name LIKE '%Laptop%';

-- JOIN
EXPLAIN
SELECT o.order_id,c.customer_name,o.order_date,o.total_amount
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
WHERE c.city='Hyderabad';

-- Aggregation
EXPLAIN
SELECT p.category,
       COUNT(*) AS items_sold,
       SUM(oi.quantity*oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id=p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Index inventory
SHOW INDEX FROM customers;
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;

SELECT TABLE_NAME,INDEX_NAME,COLUMN_NAME,SEQ_IN_INDEX,
       NON_UNIQUE,CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA='index_performance_lab'
ORDER BY TABLE_NAME,INDEX_NAME,SEQ_IN_INDEX;

-- Final reports
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders,SUM(total_amount) AS total_order_value
FROM orders;
SELECT COUNT(*) AS total_order_items,SUM(quantity) AS total_units
FROM order_items;

-- Index removal syntax (kept commented for safe learning):
-- DROP INDEX idx_customers_status ON customers;