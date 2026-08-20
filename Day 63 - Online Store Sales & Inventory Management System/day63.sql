-- Day 63 - Online Store Sales & Inventory Management System
-- SQL-A-Day | MySQL

DROP DATABASE IF EXISTS online_store;
CREATE DATABASE online_store;
USE online_store;

-- 1. TABLES

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(100),
    registration_date DATE NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    supplier VARCHAR(100),
    created_at DATE NOT NULL,
    CHECK (price > 0),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,
    last_restocked DATE,
    CHECK (stock_quantity >= 0),
    CHECK (reorder_level >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending','Processing','Shipped','Delivered','Cancelled') NOT NULL DEFAULT 'Pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    CHECK (quantity > 0),
    CHECK (unit_price > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Card','UPI','Net Banking','Cash on Delivery') NOT NULL,
    payment_status ENUM('Pending','Paid','Failed','Refunded') NOT NULL DEFAULT 'Pending',
    CHECK (amount > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- 2. SAMPLE DATA

INSERT INTO categories (category_name, description) VALUES
('Laptops','Laptop computers and accessories'),
('Smartphones','Mobile phones and accessories'),
('Audio','Headphones, earbuds and speakers'),
('Accessories','Computer and mobile accessories'),
('Smart Home','Smart home electronic products');

INSERT INTO customers
(customer_name,email,phone,city,registration_date) VALUES
('Rahul Sharma','rahul@example.com','9876543210','Mumbai','2025-01-10'),
('Priya Patel','priya@example.com','9876543211','Ahmedabad','2025-02-15'),
('Arjun Reddy','arjun@example.com','9876543212','Hyderabad','2025-03-20'),
('Sneha Rao','sneha@example.com','9876543213','Bengaluru','2025-04-12'),
('Vikram Singh','vikram@example.com','9876543214','Delhi','2025-05-05'),
('Ananya Gupta','ananya@example.com','9876543215','Pune','2025-05-25'),
('Karan Mehta','karan@example.com','9876543216','Surat','2025-06-18'),
('Neha Verma','neha@example.com','9876543217','Jaipur','2025-07-01'),
('Aditya Kumar','aditya@example.com','9876543218','Chennai','2025-07-15'),
('Meera Joshi','meera@example.com','9876543219','Rajkot','2025-08-10');

INSERT INTO products
(product_name,category_id,price,supplier,created_at) VALUES
('Lenovo IdeaPad Slim 5',1,65000,'Lenovo','2025-01-05'),
('Dell Inspiron 15',1,72000,'Dell','2025-01-08'),
('HP Pavilion 14',1,68000,'HP','2025-01-12'),
('iPhone 15',2,69999,'Apple','2025-01-20'),
('Samsung Galaxy S24',2,74999,'Samsung','2025-01-25'),
('OnePlus 13',2,64999,'OnePlus','2025-02-01'),
('Sony WH-1000XM5',3,29999,'Sony','2025-02-10'),
('Apple AirPods Pro',3,24999,'Apple','2025-02-15'),
('JBL Flip 6',3,9999,'JBL','2025-02-20'),
('Logitech MX Master 3S',4,8999,'Logitech','2025-03-01'),
('Apple Magic Keyboard',4,10999,'Apple','2025-03-05'),
('Samsung 27 Inch Monitor',4,18999,'Samsung','2025-03-10'),
('Amazon Echo Dot',5,5499,'Amazon','2025-03-15'),
('Google Nest Mini',5,4999,'Google','2025-03-20'),
('TP-Link Smart Plug',5,1299,'TP-Link','2025-03-25');

INSERT INTO inventory
(product_id,stock_quantity,reorder_level,last_restocked) VALUES
(1,25,5,'2025-08-01'),(2,18,5,'2025-08-02'),
(3,22,5,'2025-08-03'),(4,30,8,'2025-08-04'),
(5,20,8,'2025-08-05'),(6,35,8,'2025-08-06'),
(7,12,5,'2025-08-07'),(8,28,6,'2025-08-08'),
(9,40,10,'2025-08-09'),(10,15,5,'2025-08-10'),
(11,18,5,'2025-08-10'),(12,9,10,'2025-08-11'),
(13,25,8,'2025-08-12'),(14,30,8,'2025-08-13'),
(15,50,15,'2025-08-14');

INSERT INTO orders (customer_id,order_date,status) VALUES
(1,'2025-08-15 10:30:00','Delivered'),
(2,'2025-08-16 11:15:00','Delivered'),
(3,'2025-08-17 12:20:00','Shipped'),
(4,'2025-08-18 14:10:00','Processing'),
(5,'2025-08-19 09:45:00','Delivered'),
(6,'2025-08-20 16:30:00','Pending'),
(7,'2025-08-21 13:15:00','Delivered'),
(8,'2025-08-22 18:20:00','Shipped'),
(9,'2025-08-23 15:40:00','Processing'),
(10,'2025-08-24 10:10:00','Delivered'),
(1,'2025-08-25 11:00:00','Delivered'),
(3,'2025-08-26 17:25:00','Shipped'),
(5,'2025-08-27 12:30:00','Pending'),
(7,'2025-08-28 09:20:00','Delivered'),
(9,'2025-08-29 19:00:00','Processing');

INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES
(1,1,1,65000),(1,10,1,8999),
(2,4,1,69999),(2,8,1,24999),
(3,5,1,74999),(3,9,2,9999),
(4,2,1,72000),(4,11,1,10999),
(5,7,1,29999),(5,13,2,5499),
(6,6,1,64999),(6,15,3,1299),
(7,3,1,68000),(7,12,1,18999),
(8,8,2,24999),(8,14,1,4999),
(9,1,1,65000),(9,9,2,9999),
(10,4,1,69999),(10,10,1,8999),
(11,5,1,74999),(11,7,1,29999),
(12,6,2,64999),(12,15,2,1299),
(13,2,1,72000),(13,13,1,5499),
(14,3,1,68000),(14,8,1,24999),
(15,12,2,18999),(15,11,1,10999);

INSERT INTO payments
(order_id,payment_date,amount,payment_method,payment_status) VALUES
(1,'2025-08-15 10:35:00',73999,'UPI','Paid'),
(2,'2025-08-16 11:20:00',94998,'Card','Paid'),
(3,'2025-08-17 12:25:00',94997,'Net Banking','Paid'),
(4,'2025-08-18 14:15:00',82999,'Card','Paid'),
(5,'2025-08-19 09:50:00',40997,'UPI','Paid'),
(6,'2025-08-20 16:35:00',68896,'UPI','Pending'),
(7,'2025-08-21 13:20:00',86999,'Card','Paid'),
(8,'2025-08-22 18:25:00',54997,'Card','Paid'),
(9,'2025-08-23 15:45:00',84998,'Net Banking','Paid'),
(10,'2025-08-24 10:15:00',78998,'UPI','Paid'),
(11,'2025-08-25 11:05:00',104998,'Card','Paid'),
(12,'2025-08-26 17:30:00',132596,'Net Banking','Paid'),
(13,'2025-08-27 12:35:00',77499,'UPI','Pending'),
(14,'2025-08-28 09:25:00',92999,'Card','Paid'),
(15,'2025-08-29 19:05:00',48997,'UPI','Paid');

-- 3. BUSINESS ANALYTICS

SELECT SUM(quantity * unit_price) AS total_revenue
FROM order_items;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT AVG(order_total) AS average_order_value
FROM (
    SELECT order_id, SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_summary;

SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id,c.category_name
ORDER BY revenue DESC;

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC;

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_spent DESC;

SELECT
    p.product_name,
    i.stock_quantity,
    i.reorder_level
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_quantity <= i.reorder_level
ORDER BY i.stock_quantity;

SELECT
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status;

SELECT
    payment_method,
    COUNT(*) AS transactions,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_method
ORDER BY total_amount DESC;

SELECT
    product_name,
    price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 4. CTE

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id,p.product_name
)
SELECT *
FROM product_sales
ORDER BY revenue DESC;

-- 5. WINDOW FUNCTION

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id,p.product_name
)
SELECT
    product_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM product_revenue;

-- 6. VIEWS

CREATE VIEW sales_summary AS
SELECT
    DATE(o.order_date) AS order_date,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE(o.order_date);

CREATE VIEW product_performance AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id,p.product_name,c.category_name;

CREATE VIEW low_stock_report AS
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    i.stock_quantity,
    i.reorder_level
FROM products p
JOIN categories c ON p.category_id = c.category_id
JOIN inventory i ON p.product_id = i.product_id
WHERE i.stock_quantity <= i.reorder_level;

SELECT * FROM sales_summary ORDER BY order_date;
SELECT * FROM product_performance ORDER BY revenue DESC;
SELECT * FROM low_stock_report ORDER BY stock_quantity;

-- 7. INDEXES

CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_payments_status ON payments(payment_status);

-- 8. INVENTORY AUDIT AND TRIGGER

CREATE TABLE inventory_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    old_stock INT,
    new_stock INT,
    change_type VARCHAR(30),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER after_inventory_update
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF OLD.stock_quantity <> NEW.stock_quantity THEN
        INSERT INTO inventory_audit
        (product_id,old_stock,new_stock,change_type)
        VALUES
        (NEW.product_id,OLD.stock_quantity,NEW.stock_quantity,'STOCK_UPDATE');
    END IF;
END //

CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END //

DELIMITER ;

-- 9. STORED PROCEDURES

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(IN input_customer_id INT)
BEGIN
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = input_customer_id
    GROUP BY o.order_id,o.order_date,o.status
    ORDER BY o.order_date DESC;
END //

CREATE PROCEDURE GetLowStockProducts()
BEGIN
    SELECT
        p.product_id,
        p.product_name,
        i.stock_quantity,
        i.reorder_level
    FROM products p
    JOIN inventory i ON p.product_id = i.product_id
    WHERE i.stock_quantity <= i.reorder_level
    ORDER BY i.stock_quantity;
END //

DELIMITER ;

CALL GetCustomerOrders(1);
CALL GetLowStockProducts();

-- 10. TRANSACTION

START TRANSACTION;

INSERT INTO orders(customer_id,status)
VALUES (4,'Processing');

SET @transaction_order_id = LAST_INSERT_ID();

INSERT INTO order_items(order_id,product_id,quantity,unit_price)
VALUES (@transaction_order_id,10,1,8999);

COMMIT;

-- 11. FINAL DASHBOARD

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS customers_with_orders,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    AVG(oi.quantity * oi.unit_price) AS average_item_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC
LIMIT 5;

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

SELECT * FROM low_stock_report ORDER BY stock_quantity;

-- END OF DAY 63