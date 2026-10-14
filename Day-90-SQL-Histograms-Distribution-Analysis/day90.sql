-- Day 90: SQL Histograms & Distribution Analysis
-- MySQL 8.0+ | Synthetic learning dataset
CREATE DATABASE IF NOT EXISTS sql_distribution_lab;
USE sql_distribution_lab;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
 customer_id INT PRIMARY KEY, customer_name VARCHAR(80), city VARCHAR(50), signup_date DATE
);
CREATE TABLE products (
 product_id INT PRIMARY KEY, product_name VARCHAR(80), category VARCHAR(40), list_price DECIMAL(10,2)
);
CREATE TABLE sales (
 sale_id INT PRIMARY KEY, customer_id INT, product_id INT, sale_date DATE,
 quantity INT, unit_price DECIMAL(10,2), discount_pct DECIMAL(5,2),
 FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
 FOREIGN KEY(product_id) REFERENCES products(product_id)
);
INSERT INTO customers VALUES
(1,'Aarav Shah','Rajkot','2026-01-05'),(2,'Diya Patel','Ahmedabad','2026-01-12'),
(3,'Kabir Mehta','Surat','2026-02-03'),(4,'Anaya Joshi','Vadodara','2026-02-15'),
(5,'Ishaan Desai','Rajkot','2026-03-01'),(6,'Meera Rao','Surat','2026-03-18'),
(7,'Rohan Shah','Junagadh','2026-04-02'),(8,'Ira Trivedi','Ahmedabad','2026-04-22');
INSERT INTO products VALUES
(101,'USB Cable','Accessories',199),(102,'Wireless Mouse','Accessories',799),
(103,'Mechanical Keyboard','Accessories',2499),(104,'Laptop Stand','Accessories',1299),
(105,'Budget Headphones','Audio',999),(106,'Studio Headphones','Audio',5999),
(107,'Bluetooth Speaker','Audio',3499),(108,'Office Monitor','Displays',12999),
(109,'Gaming Monitor','Displays',27999),(110,'Premium Laptop','Computers',89999);
INSERT INTO sales VALUES
(1,1,101,'2026-01-10',2,199,0),(2,2,102,'2026-01-15',1,799,5),
(3,1,105,'2026-01-21',1,999,0),(4,3,103,'2026-02-04',1,2499,10),
(5,4,101,'2026-02-10',4,199,0),(6,5,106,'2026-02-20',1,5999,10),
(7,6,104,'2026-03-02',2,1299,5),(8,2,107,'2026-03-11',1,3499,0),
(9,7,102,'2026-03-19',3,799,0),(10,8,108,'2026-04-01',1,12999,5),
(11,5,105,'2026-04-12',2,999,0),(12,4,109,'2026-04-23',1,27999,10),
(13,1,103,'2026-05-05',2,2499,5),(14,3,101,'2026-05-15',5,199,0),
(15,5,107,'2026-05-28',1,3499,5),(16,6,106,'2026-06-02',1,5999,0),
(17,7,104,'2026-06-10',3,1299,10),(18,8,108,'2026-06-15',1,12999,0),
(19,2,102,'2026-06-21',2,799,5),(20,1,110,'2026-06-29',1,89999,0);

-- 1. Profile values before choosing bucket boundaries.
SELECT COUNT(*) AS product_count, MIN(list_price) AS min_price,
       MAX(list_price) AS max_price, AVG(list_price) AS avg_price
FROM products;

-- 2. Business-friendly price bands.
SELECT CASE WHEN list_price < 1000 THEN 'Under 1K'
            WHEN list_price < 5000 THEN '1K-4,999'
            WHEN list_price < 15000 THEN '5K-14,999'
            ELSE '15K and above' END AS price_band,
       COUNT(*) AS product_count, ROUND(AVG(list_price),2) AS avg_price
FROM products
GROUP BY price_band
ORDER BY MIN(list_price);

-- 3. Fixed-width histogram: bucket width = 10,000.
SELECT FLOOR(list_price / 10000) AS bucket_number,
       CONCAT(FLOOR(list_price / 10000)*10000, ' - ',
              FLOOR(list_price / 10000)*10000+9999.99) AS price_range,
       COUNT(*) AS products_in_bucket
FROM products
GROUP BY FLOOR(list_price / 10000)
ORDER BY bucket_number;

-- 4. Distribution of net sale values.
WITH sale_values AS (
 SELECT sale_id, quantity*unit_price*(1-discount_pct/100) AS net_value
 FROM sales
)
SELECT CASE WHEN net_value < 1000 THEN 'Small (<1K)'
            WHEN net_value < 5000 THEN 'Medium (1K-4,999)'
            WHEN net_value < 20000 THEN 'Large (5K-19,999)'
            ELSE 'Very large (20K+)' END AS sale_band,
       COUNT(*) AS sale_count, ROUND(AVG(net_value),2) AS avg_value
FROM sale_values GROUP BY sale_band ORDER BY MIN(net_value);

-- 5. Purchase-frequency distribution; LEFT JOIN includes zero-purchase customers.
WITH customer_orders AS (
 SELECT c.customer_id, COUNT(s.sale_id) AS purchase_count
 FROM customers c LEFT JOIN sales s ON s.customer_id=c.customer_id
 GROUP BY c.customer_id
)
SELECT purchase_count, COUNT(*) AS customers
FROM customer_orders GROUP BY purchase_count ORDER BY purchase_count;

-- 6. Category-level distribution summary.
SELECT category, COUNT(*) AS product_count, MIN(list_price) AS min_price,
       MAX(list_price) AS max_price, ROUND(AVG(list_price),2) AS avg_price
FROM products GROUP BY category ORDER BY product_count DESC;

-- 7. Quartile-like groups using NTILE(4).
WITH ranked AS (
 SELECT product_id, product_name, list_price,
        NTILE(4) OVER(ORDER BY list_price) AS price_quartile
 FROM products
)
SELECT price_quartile, MIN(list_price) AS group_min,
       MAX(list_price) AS group_max, COUNT(*) AS products
FROM ranked GROUP BY price_quartile ORDER BY price_quartile;

-- 8. Display each product's quartile assignment.
SELECT product_id, product_name, list_price,
       NTILE(4) OVER(ORDER BY list_price) AS price_quartile
FROM products ORDER BY list_price;

-- 9. Simple IQR outlier screening using approximate quartile group boundaries.
WITH bucketed AS (
 SELECT list_price, NTILE(4) OVER(ORDER BY list_price) AS q
 FROM products
),
bounds AS (
 SELECT MAX(CASE WHEN q=1 THEN list_price END) AS q1_boundary,
        MIN(CASE WHEN q=4 THEN list_price END) AS q3_boundary
 FROM bucketed
)
SELECT p.product_id, p.product_name, p.list_price,
       b.q1_boundary, b.q3_boundary,
       b.q3_boundary-b.q1_boundary AS iqr
FROM products p CROSS JOIN bounds b
WHERE p.list_price < b.q1_boundary-1.5*(b.q3_boundary-b.q1_boundary)
   OR p.list_price > b.q3_boundary+1.5*(b.q3_boundary-b.q1_boundary);

-- 10. Monthly sales distribution.
SELECT DATE_FORMAT(sale_date,'%Y-%m') AS sales_month,
       COUNT(*) AS sale_count,
       SUM(quantity*unit_price*(1-discount_pct/100)) AS net_revenue
FROM sales GROUP BY DATE_FORMAT(sale_date,'%Y-%m') ORDER BY sales_month;

-- Practice:
-- A. Create quantity buckets for sales.
-- B. Create a histogram of customer signup months.
-- C. Compare price bands across product categories.
-- D. Explain how bucket width changes a histogram.
-- E. Explain why NTILE(4) is not always the same as a statistical percentile.

-- Optional cleanup:
-- DROP TABLE IF EXISTS sales;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS customers;
-- DROP DATABASE IF EXISTS sql_distribution_lab;
