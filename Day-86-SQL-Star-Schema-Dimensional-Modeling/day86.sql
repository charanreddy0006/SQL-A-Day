-- SQL-A-Day - Day 86
-- Topic: SQL Star Schema & Dimensional Modeling
-- MySQL 8+

DROP DATABASE IF EXISTS sql_star_schema_lab;
CREATE DATABASE sql_star_schema_lab;
USE sql_star_schema_lab;

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_number INT NOT NULL,
    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_number INT NOT NULL,
    year_number INT NOT NULL,
    week_number INT NOT NULL
);

CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    customer_segment VARCHAR(50)
);

CREATE TABLE dim_product (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_id VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(12,2) NOT NULL
);

CREATE TABLE dim_store (
    store_key INT AUTO_INCREMENT PRIMARY KEY,
    store_id VARCHAR(20) NOT NULL UNIQUE,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50)
);

-- Grain: one row = one product line in one sales order.
CREATE TABLE fact_sales (
    sales_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    date_key INT NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    store_key INT NOT NULL,
    order_id VARCHAR(30) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    sales_amount DECIMAL(14,2) NOT NULL,
    cost_amount DECIMAL(14,2) NOT NULL,
    profit_amount DECIMAL(14,2) NOT NULL,
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key),
    INDEX idx_fact_date(date_key),
    INDEX idx_fact_customer(customer_key),
    INDEX idx_fact_product(product_key),
    INDEX idx_fact_store(store_key),
    INDEX idx_fact_order(order_id)
);

INSERT INTO dim_date VALUES
(20260105,'2026-01-05',5,1,'January',1,2026,2),
(20260106,'2026-01-06',6,1,'January',1,2026,2),
(20260110,'2026-01-10',10,1,'January',1,2026,2),
(20260115,'2026-01-15',15,1,'January',1,2026,3),
(20260202,'2026-02-02',2,2,'February',1,2026,6),
(20260210,'2026-02-10',10,2,'February',1,2026,7),
(20260218,'2026-02-18',18,2,'February',1,2026,8),
(20260303,'2026-03-03',3,3,'March',1,2026,10),
(20260312,'2026-03-12',12,3,'March',1,2026,11),
(20260320,'2026-03-20',20,3,'March',1,2026,12);

INSERT INTO dim_customer
(customer_id,customer_name,city,state,customer_segment)
VALUES
('C001','Aarav Sharma','Rajkot','Gujarat','Premium'),
('C002','Diya Patel','Ahmedabad','Gujarat','Standard'),
('C003','Rohan Mehta','Vadodara','Gujarat','Premium'),
('C004','Anaya Shah','Surat','Gujarat','Standard'),
('C005','Kabir Joshi','Mumbai','Maharashtra','Enterprise'),
('C006','Ishita Rao','Pune','Maharashtra','Premium');

INSERT INTO dim_product
(product_id,product_name,category,subcategory,brand,unit_price)
VALUES
('P001','Laptop Pro 14','Electronics','Laptops','NovaTech',85000.00),
('P002','Wireless Mouse','Electronics','Accessories','ClickPro',1500.00),
('P003','Mechanical Keyboard','Electronics','Accessories','KeyMaster',4500.00),
('P004','Office Chair','Furniture','Chairs','ComfortX',12000.00),
('P005','Standing Desk','Furniture','Desks','WorkSpace',22000.00),
('P006','Monitor 27','Electronics','Monitors','ViewMax',28000.00),
('P007','USB-C Hub','Electronics','Accessories','ConnectX',3500.00),
('P008','Notebook Pack','Stationery','Notebooks','WriteWell',600.00);

INSERT INTO dim_store
(store_id,store_name,city,state,region)
VALUES
('S001','Rajkot Central','Rajkot','Gujarat','West'),
('S002','Ahmedabad Mall','Ahmedabad','Gujarat','West'),
('S003','Mumbai Tech Hub','Mumbai','Maharashtra','West'),
('S004','Pune Business Store','Pune','Maharashtra','West');

INSERT INTO fact_sales
(date_key,customer_key,product_key,store_key,order_id,quantity,unit_price,
 discount_amount,sales_amount,cost_amount,profit_amount)
VALUES
(20260105,1,1,1,'ORD1001',1,85000,5000,80000,65000,15000),
(20260105,1,2,1,'ORD1001',2,1500,0,3000,1800,1200),
(20260106,2,4,2,'ORD1002',1,12000,1000,11000,7500,3500),
(20260110,3,6,4,'ORD1003',2,28000,3000,53000,38000,15000),
(20260115,4,8,2,'ORD1004',5,600,0,3000,1800,1200),
(20260202,5,5,3,'ORD1005',2,22000,2000,42000,30000,12000),
(20260210,6,3,4,'ORD1006',1,4500,500,4000,2600,1400),
(20260210,6,7,4,'ORD1006',2,3500,0,7000,4200,2800),
(20260218,1,6,1,'ORD1007',1,28000,1000,27000,19000,8000),
(20260303,2,1,2,'ORD1008',1,85000,7000,78000,65000,13000),
(20260312,3,4,4,'ORD1009',2,12000,1000,23000,15000,8000),
(20260320,5,5,3,'ORD1010',1,22000,0,22000,15000,7000),
(20260320,6,2,4,'ORD1011',3,1500,0,4500,2700,1800),
(20260320,4,8,2,'ORD1012',10,600,500,5500,3600,1900);

-- Basic inspection
SELECT * FROM dim_date;
SELECT * FROM dim_customer;
SELECT * FROM dim_product;
SELECT * FROM dim_store;
SELECT * FROM fact_sales;

-- Total sales, cost and profit
SELECT SUM(sales_amount) total_sales,
       SUM(cost_amount) total_cost,
       SUM(profit_amount) total_profit
FROM fact_sales;

-- Sales by product
SELECT p.product_name,p.category,
       SUM(f.quantity) units_sold,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit
FROM fact_sales f
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY p.product_key,p.product_name,p.category
ORDER BY total_sales DESC;

-- Sales by customer
SELECT c.customer_name,c.customer_segment,c.city,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit
FROM fact_sales f
JOIN dim_customer c ON f.customer_key=c.customer_key
GROUP BY c.customer_key,c.customer_name,c.customer_segment,c.city
ORDER BY total_sales DESC;

-- Sales by store
SELECT s.store_name,s.city,s.region,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit
FROM fact_sales f
JOIN dim_store s ON f.store_key=s.store_key
GROUP BY s.store_key,s.store_name,s.city,s.region
ORDER BY total_sales DESC;

-- Monthly sales
SELECT d.year_number,d.month_number,d.month_name,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit
FROM fact_sales f
JOIN dim_date d ON f.date_key=d.date_key
GROUP BY d.year_number,d.month_number,d.month_name
ORDER BY d.year_number,d.month_number;

-- Sales by category
SELECT p.category,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit,
       SUM(f.quantity) units_sold
FROM fact_sales f
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY p.category
ORDER BY total_sales DESC;

-- Sales by customer segment
SELECT c.customer_segment,
       COUNT(DISTINCT c.customer_key) customers,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit
FROM fact_sales f
JOIN dim_customer c ON f.customer_key=c.customer_key
GROUP BY c.customer_segment
ORDER BY total_sales DESC;

-- Sales by region
SELECT s.region,
       SUM(f.sales_amount) total_sales,
       SUM(f.profit_amount) total_profit
FROM fact_sales f
JOIN dim_store s ON f.store_key=s.store_key
GROUP BY s.region;

-- Top 5 products
SELECT p.product_name,SUM(f.sales_amount) revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY p.product_key,p.product_name
ORDER BY revenue DESC LIMIT 5;

-- Top 5 customers
SELECT c.customer_name,SUM(f.sales_amount) revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_key=c.customer_key
GROUP BY c.customer_key,c.customer_name
ORDER BY revenue DESC LIMIT 5;

-- Month + category
SELECT d.month_name,p.category,SUM(f.sales_amount) revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key=d.date_key
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY d.month_number,d.month_name,p.category
ORDER BY d.month_number,revenue DESC;

-- Store + product
SELECT s.store_name,p.product_name,
       SUM(f.quantity) units_sold,SUM(f.sales_amount) revenue
FROM fact_sales f
JOIN dim_store s ON f.store_key=s.store_key
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY s.store_key,s.store_name,p.product_key,p.product_name
ORDER BY s.store_name,revenue DESC;

-- Profit margin
SELECT p.category,
       SUM(f.sales_amount) revenue,
       SUM(f.profit_amount) profit,
       ROUND(SUM(f.profit_amount)/NULLIF(SUM(f.sales_amount),0)*100,2)
       profit_margin_percent
FROM fact_sales f
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY p.category
ORDER BY profit_margin_percent DESC;

-- Average order value
SELECT ROUND(SUM(order_total)/COUNT(*),2) average_order_value
FROM (
    SELECT order_id,SUM(sales_amount) order_total
    FROM fact_sales GROUP BY order_id
) x;

-- Order-level summary
SELECT f.order_id,d.full_date,c.customer_name,s.store_name,
       SUM(f.sales_amount) order_value,
       SUM(f.profit_amount) order_profit
FROM fact_sales f
JOIN dim_date d ON f.date_key=d.date_key
JOIN dim_customer c ON f.customer_key=c.customer_key
JOIN dim_store s ON f.store_key=s.store_key
GROUP BY f.order_id,d.full_date,c.customer_name,s.store_name
ORDER BY d.full_date,f.order_id;

-- Drill-down: year -> month -> category
SELECT d.year_number,d.month_name,p.category,
       SUM(f.sales_amount) revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key=d.date_key
JOIN dim_product p ON f.product_key=p.product_key
GROUP BY d.year_number,d.month_number,d.month_name,p.category
ORDER BY d.year_number,d.month_number,p.category;

-- Grain check
SELECT COUNT(*) fact_rows,
       COUNT(DISTINCT order_id) orders,
       SUM(quantity) total_units
FROM fact_sales;

-- PRACTICE QUESTIONS
-- Q1. Find total revenue by state.
-- Q2. Find the best-selling product by quantity.
-- Q3. Find monthly profit.
-- Q4. Find the top customer in each segment.
-- Q5. Find the highest-revenue category in each month.
-- Q6. Find stores whose revenue is above average store revenue.
-- Q7. Calculate revenue per customer.
-- Q8. Find the most profitable product.
-- Q9. Find each customer's first purchase date.
-- Q10. Find each customer's total number of orders.
-- Q11. Find products that were never sold.
-- Q12. Find the percentage contribution of each category to total revenue.
-- Q13. Find the month with the highest revenue.
-- Q14. Compare revenue and profit by region.
-- Q15. Build a report by year, month, region, category, revenue and profit.
