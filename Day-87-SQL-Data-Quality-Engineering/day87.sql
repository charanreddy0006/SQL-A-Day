-- ============================================================
-- SQL-A-Day - Day 87
-- Topic: SQL Data Quality Engineering & Automated Validation
-- Database: MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS sql_data_quality_lab;
CREATE DATABASE sql_data_quality_lab;
USE sql_data_quality_lab;

-- ============================================================
-- 1. SOURCE TABLES
-- ============================================================

CREATE TABLE customers (
    customer_id INT,
    customer_code VARCHAR(20),
    customer_name VARCHAR(100),
    email VARCHAR(150),
    phone VARCHAR(20),
    city VARCHAR(100),
    customer_status VARCHAR(20),
    signup_date DATE,
    last_updated DATETIME
);

CREATE TABLE products (
    product_id INT,
    product_code VARCHAR(20),
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(12,2),
    product_status VARCHAR(20),
    last_updated DATETIME
);

CREATE TABLE orders (
    order_id INT,
    order_number VARCHAR(30),
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    unit_price DECIMAL(12,2),
    order_status VARCHAR(20),
    last_updated DATETIME
);

-- ============================================================
-- 2. TEST DATA
-- Some rows intentionally contain quality problems.
-- ============================================================

INSERT INTO customers VALUES
(101,'C101','Aarav Sharma','aarav@example.com','9876543210','Rajkot','ACTIVE','2026-01-10','2026-03-20 10:00:00'),
(102,'C102','Diya Patel','diya@example.com','9876543211','Ahmedabad','ACTIVE','2026-01-12','2026-03-20 10:30:00'),
(103,'C103','Rohan Mehta','rohan@example.com','9876543212','Vadodara','ACTIVE','2026-01-15','2026-03-20 11:00:00'),
(104,'C104','Anaya Shah','anaya@example.com','9876543213','Surat','INACTIVE','2026-01-18','2026-03-20 11:30:00'),
(105,'C105','Kabir Joshi',NULL,'9876543214','Mumbai','ACTIVE','2026-02-02','2026-03-20 12:00:00'),
(106,'C103','Duplicate Customer','duplicate@example.com','9876543299','Pune','ACTIVE','2026-02-10','2026-03-20 12:30:00'),
(107,'C107','Ishita Rao','ishita-email.com','9876543220','Pune','ACTIVE','2026-02-15','2026-03-20 13:00:00'),
(108,'C108','Neel Joshi','neel@example.com','9876543221','Nashik','UNKNOWN','2026-02-20','2026-03-20 13:30:00'),
(109,'C109','Meera Desai','meera@example.com','9876543222','Mumbai','ACTIVE','2027-01-01','2026-03-20 14:00:00'),
(110,'C110','Vikram Singh','vikram@example.com','9876543223',NULL,'ACTIVE','2026-02-25','2026-03-20 14:30:00');

INSERT INTO products VALUES
(201,'P201','Laptop Pro 14','Electronics',85000.00,'ACTIVE','2026-03-20 09:00:00'),
(202,'P202','Wireless Mouse','Electronics',1500.00,'ACTIVE','2026-03-20 09:10:00'),
(203,'P203','Office Chair','Furniture',12000.00,'ACTIVE','2026-03-20 09:20:00'),
(204,'P204','Standing Desk','Furniture',22000.00,'ACTIVE','2026-03-20 09:30:00'),
(205,'P205','Monitor 27','Electronics',28000.00,'ACTIVE','2026-03-20 09:40:00'),
(206,'P206','USB-C Hub','Electronics',3500.00,'ACTIVE','2026-03-20 09:50:00'),
(207,'P207','Broken Price Product','Electronics',-500.00,'ACTIVE','2026-03-20 10:00:00'),
(208,'P208','Unknown Product','Electronics',2500.00,'DISCONTINUED_NOW','2026-03-20 10:10:00'),
(209,'P206','Duplicate Hub','Electronics',3600.00,'ACTIVE','2026-03-20 10:20:00');

INSERT INTO orders VALUES
(1001,'ORD1001',101,201,'2026-03-01',1,85000.00,'COMPLETED','2026-03-20 10:00:00'),
(1002,'ORD1002',102,202,'2026-03-02',2,1500.00,'COMPLETED','2026-03-20 10:05:00'),
(1003,'ORD1003',103,203,'2026-03-03',1,12000.00,'COMPLETED','2026-03-20 10:10:00'),
(1004,'ORD1004',104,204,'2026-03-04',1,22000.00,'CANCELLED','2026-03-20 10:15:00'),
(1005,'ORD1005',999,205,'2026-03-05',1,28000.00,'COMPLETED','2026-03-20 10:20:00'),
(1006,'ORD1006',105,999,'2026-03-06',1,1000.00,'COMPLETED','2026-03-20 10:25:00'),
(1007,'ORD1007',101,206,'2026-03-07',0,3500.00,'COMPLETED','2026-03-20 10:30:00'),
(1008,'ORD1008',102,202,'2026-03-08',-2,1500.00,'COMPLETED','2026-03-20 10:35:00'),
(1009,'ORD1009',103,203,'2026-03-09',1,12000.00,'UNKNOWN','2026-03-20 10:40:00'),
(1010,'ORD1010',104,204,'2027-02-01',1,22000.00,'COMPLETED','2026-03-20 10:45:00'),
(1011,'ORD1011',105,205,'2026-03-10',1,5000.00,'COMPLETED','2026-03-20 10:50:00'),
(1012,'ORD1001',106,201,'2026-03-11',1,85000.00,'COMPLETED','2026-03-20 10:55:00');

-- ============================================================
-- 3. DATA PROFILING
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders;

SELECT COUNT(*) AS rows,
       COUNT(customer_id) AS non_null_ids,
       COUNT(DISTINCT customer_code) AS unique_codes
FROM customers;

SELECT COUNT(*) AS rows,
       COUNT(DISTINCT product_code) AS unique_codes
FROM products;

SELECT COUNT(*) AS rows,
       COUNT(DISTINCT order_number) AS unique_order_numbers
FROM orders;

-- ============================================================
-- 4. COMPLETENESS
-- ============================================================

SELECT * FROM customers
WHERE email IS NULL OR TRIM(email)='';

SELECT * FROM customers
WHERE city IS NULL OR TRIM(city)='';

SELECT * FROM products
WHERE product_name IS NULL
   OR category IS NULL
   OR unit_price IS NULL;

SELECT * FROM orders
WHERE order_number IS NULL
   OR customer_id IS NULL
   OR product_id IS NULL
   OR order_date IS NULL;

-- ============================================================
-- 5. DUPLICATES / UNIQUENESS
-- ============================================================

SELECT customer_code, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_code
HAVING COUNT(*) > 1;

SELECT product_code, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_code
HAVING COUNT(*) > 1;

SELECT order_number, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_number
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 6. PRIMARY-KEY STYLE CHECKS
-- ============================================================

SELECT * FROM customers WHERE customer_id IS NULL;

SELECT customer_id, COUNT(*) AS row_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT * FROM products WHERE product_id IS NULL;

SELECT product_id, COUNT(*) AS row_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT * FROM orders WHERE order_id IS NULL;

SELECT order_id, COUNT(*) AS row_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- ============================================================
-- 7. FORMAT VALIDATION
-- ============================================================

SELECT *
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

SELECT *
FROM customers
WHERE phone IS NULL
   OR phone NOT REGEXP '^[0-9]{10}$';

-- ============================================================
-- 8. DOMAIN VALIDATION
-- ============================================================

SELECT *
FROM customers
WHERE customer_status NOT IN ('ACTIVE','INACTIVE')
   OR customer_status IS NULL;

SELECT *
FROM products
WHERE product_status NOT IN ('ACTIVE','INACTIVE')
   OR product_status IS NULL;

SELECT *
FROM orders
WHERE order_status NOT IN ('COMPLETED','PENDING','CANCELLED')
   OR order_status IS NULL;

-- ============================================================
-- 9. NUMERIC VALIDATION
-- ============================================================

SELECT * FROM products
WHERE unit_price IS NULL OR unit_price <= 0;

SELECT * FROM orders
WHERE quantity IS NULL OR quantity <= 0;

SELECT * FROM orders
WHERE unit_price IS NULL OR unit_price <= 0;

-- ============================================================
-- 10. DATE VALIDATION
-- ============================================================

SELECT * FROM customers
WHERE signup_date IS NULL OR signup_date > CURRENT_DATE;

SELECT * FROM orders
WHERE order_date IS NULL OR order_date > CURRENT_DATE;

SELECT * FROM customers
WHERE last_updated > CURRENT_TIMESTAMP;

-- ============================================================
-- 11. REFERENTIAL INTEGRITY
-- ============================================================

SELECT o.order_id,o.order_number,o.customer_id
FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL;

SELECT o.order_id,o.order_number,o.product_id
FROM orders o
LEFT JOIN products p ON o.product_id=p.product_id
WHERE p.product_id IS NULL;

-- ============================================================
-- 12. CROSS-TABLE CONSISTENCY
-- ============================================================

SELECT
    o.order_id,
    o.order_number,
    o.product_id,
    o.unit_price AS order_price,
    p.unit_price AS product_price
FROM orders o
JOIN products p ON o.product_id=p.product_id
WHERE ABS(o.unit_price-p.unit_price) > 0.01;

-- ============================================================
-- 13. BUSINESS RULES
-- ============================================================

SELECT *
FROM orders
WHERE order_status='COMPLETED'
  AND (quantity <= 0 OR unit_price <= 0);

SELECT *
FROM customers
WHERE customer_status='ACTIVE'
  AND (email IS NULL OR TRIM(email)='');

SELECT *
FROM products
WHERE product_status='ACTIVE'
  AND unit_price <= 0;

-- ============================================================
-- 14. DATA FRESHNESS
-- ============================================================

SELECT
    'customers' AS table_name,
    MAX(last_updated) AS latest_update,
    TIMESTAMPDIFF(HOUR,MAX(last_updated),CURRENT_TIMESTAMP)
        AS hours_since_update
FROM customers
UNION ALL
SELECT
    'products',
    MAX(last_updated),
    TIMESTAMPDIFF(HOUR,MAX(last_updated),CURRENT_TIMESTAMP)
FROM products
UNION ALL
SELECT
    'orders',
    MAX(last_updated),
    TIMESTAMPDIFF(HOUR,MAX(last_updated),CURRENT_TIMESTAMP)
FROM orders;

-- ============================================================
-- 15. AUTOMATED QUALITY RESULT TABLE
-- ============================================================

CREATE TABLE data_quality_results (
    check_id INT AUTO_INCREMENT PRIMARY KEY,
    check_name VARCHAR(150) NOT NULL,
    dimension VARCHAR(50) NOT NULL,
    failed_records INT NOT NULL,
    total_records INT NOT NULL,
    pass_rate DECIMAL(6,2) NOT NULL,
    status VARCHAR(10) NOT NULL,
    checked_at DATETIME NOT NULL
);

-- ============================================================
-- 16. AUTOMATED QUALITY RULES
-- ============================================================

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Customer email completeness',
    'COMPLETENESS',
    SUM(CASE WHEN email IS NULL OR TRIM(email)='' THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100 * SUM(CASE WHEN email IS NOT NULL AND TRIM(email)<>'' THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE WHEN email IS NULL OR TRIM(email)='' THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM customers;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Customer code uniqueness',
    'UNIQUENESS',
    COUNT(*)-COUNT(DISTINCT customer_code),
    COUNT(*),
    ROUND(100*COUNT(DISTINCT customer_code)/COUNT(*),2),
    CASE WHEN COUNT(*)=COUNT(DISTINCT customer_code)
         THEN 'PASS' ELSE 'FAIL' END,
    NOW()
FROM customers;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Product price validity',
    'VALIDITY',
    SUM(CASE WHEN unit_price IS NULL OR unit_price<=0 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE WHEN unit_price>0 THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE WHEN unit_price IS NULL OR unit_price<=0 THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM products;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Order quantity validity',
    'VALIDITY',
    SUM(CASE WHEN quantity IS NULL OR quantity<=0 THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE WHEN quantity>0 THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE WHEN quantity IS NULL OR quantity<=0 THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM orders;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Order customer referential integrity',
    'CONSISTENCY',
    SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE WHEN c.customer_id IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE WHEN c.customer_id IS NULL THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Order product referential integrity',
    'CONSISTENCY',
    SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE WHEN p.product_id IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM orders o
LEFT JOIN products p ON o.product_id=p.product_id;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Customer email format',
    'VALIDITY',
    SUM(CASE
        WHEN email IS NULL OR email NOT REGEXP
        '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE
        WHEN email REGEXP
        '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE
            WHEN email IS NULL OR email NOT REGEXP
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM customers;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Order status allowed values',
    'VALIDITY',
    SUM(CASE
        WHEN order_status NOT IN ('COMPLETED','PENDING','CANCELLED')
             OR order_status IS NULL
        THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE
        WHEN order_status IN ('COMPLETED','PENDING','CANCELLED')
        THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE
            WHEN order_status NOT IN ('COMPLETED','PENDING','CANCELLED')
                 OR order_status IS NULL
            THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM orders;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Order date validity',
    'VALIDITY',
    SUM(CASE WHEN order_date IS NULL OR order_date>CURRENT_DATE THEN 1 ELSE 0 END),
    COUNT(*),
    ROUND(100*SUM(CASE WHEN order_date<=CURRENT_DATE THEN 1 ELSE 0 END)/COUNT(*),2),
    CASE
        WHEN SUM(CASE WHEN order_date IS NULL OR order_date>CURRENT_DATE THEN 1 ELSE 0 END)=0
        THEN 'PASS' ELSE 'FAIL'
    END,
    NOW()
FROM orders;

INSERT INTO data_quality_results
(check_name,dimension,failed_records,total_records,pass_rate,status,checked_at)
SELECT
    'Product code uniqueness',
    'UNIQUENESS',
    COUNT(*)-COUNT(DISTINCT product_code),
    COUNT(*),
    ROUND(100*COUNT(DISTINCT product_code)/COUNT(*),2),
    CASE WHEN COUNT(*)=COUNT(DISTINCT product_code)
         THEN 'PASS' ELSE 'FAIL' END,
    NOW()
FROM products;

-- ============================================================
-- 17. QUALITY RESULTS
-- ============================================================

SELECT *
FROM data_quality_results
ORDER BY check_id;

-- ============================================================
-- 18. OVERALL QUALITY SCORE
-- ============================================================

SELECT
    COUNT(*) AS total_checks,
    SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END) AS passed_checks,
    SUM(CASE WHEN status='FAIL' THEN 1 ELSE 0 END) AS failed_checks,
    ROUND(
        100*SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END)/COUNT(*),2
    ) AS quality_score,
    CASE
        WHEN SUM(CASE WHEN status='FAIL' THEN 1 ELSE 0 END)=0
            THEN 'PASS'
        WHEN SUM(CASE WHEN status='FAIL' THEN 1 ELSE 0 END)
             <= COUNT(*)*0.20
            THEN 'WARN'
        ELSE 'FAIL'
    END AS overall_status
FROM data_quality_results;

-- ============================================================
-- 19. QUALITY SCORE BY DIMENSION
-- ============================================================

SELECT
    dimension,
    COUNT(*) AS checks,
    SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN status='FAIL' THEN 1 ELSE 0 END) AS failed,
    ROUND(
        100*SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END)/COUNT(*),2
    ) AS dimension_score
FROM data_quality_results
GROUP BY dimension
ORDER BY dimension_score;

-- ============================================================
-- 20. FAILED CHECK SUMMARY
-- ============================================================

SELECT
    check_name,
    dimension,
    failed_records,
    total_records,
    pass_rate,
    status
FROM data_quality_results
WHERE status='FAIL'
ORDER BY failed_records DESC;

-- ============================================================
-- 21. RECORD-LEVEL CUSTOMER QUALITY REPORT
-- ============================================================

SELECT
    customer_id,
    customer_code,
    customer_name,
    CASE
        WHEN email IS NULL OR TRIM(email)='' THEN 'FAIL'
        WHEN email NOT REGEXP
             '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
            THEN 'FAIL'
        WHEN city IS NULL OR TRIM(city)='' THEN 'FAIL'
        WHEN customer_status NOT IN ('ACTIVE','INACTIVE') THEN 'FAIL'
        WHEN signup_date>CURRENT_DATE THEN 'FAIL'
        ELSE 'PASS'
    END AS customer_quality_status
FROM customers
ORDER BY customer_id;

-- ============================================================
-- 22. RECORD-LEVEL ORDER QUALITY REPORT
-- ============================================================

SELECT
    o.order_id,
    o.order_number,
    CASE
        WHEN c.customer_id IS NULL THEN 'FAIL'
        WHEN p.product_id IS NULL THEN 'FAIL'
        WHEN o.quantity IS NULL OR o.quantity<=0 THEN 'FAIL'
        WHEN o.unit_price IS NULL OR o.unit_price<=0 THEN 'FAIL'
        WHEN o.order_date IS NULL OR o.order_date>CURRENT_DATE THEN 'FAIL'
        WHEN o.order_status NOT IN ('COMPLETED','PENDING','CANCELLED') THEN 'FAIL'
        WHEN ABS(o.unit_price-p.unit_price)>0.01 THEN 'FAIL'
        ELSE 'PASS'
    END AS order_quality_status
FROM orders o
LEFT JOIN customers c ON o.customer_id=c.customer_id
LEFT JOIN products p ON o.product_id=p.product_id
ORDER BY o.order_id;

-- ============================================================
-- 23. QUALITY VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_data_quality_summary AS
SELECT
    check_id,
    check_name,
    dimension,
    failed_records,
    total_records,
    pass_rate,
    status,
    checked_at
FROM data_quality_results;

SELECT *
FROM vw_data_quality_summary;

-- ============================================================
-- 24. PRACTICE QUESTIONS
-- ============================================================

-- Q1. Find customers with missing phone numbers.
-- Q2. Find duplicate customer codes.
-- Q3. Find duplicate product codes.
-- Q4. Find invalid customer statuses.
-- Q5. Find invalid product statuses.
-- Q6. Find orders with missing customers.
-- Q7. Find orders with missing products.
-- Q8. Find products with non-positive prices.
-- Q9. Find orders with non-positive quantities.
-- Q10. Find invalid email addresses.
-- Q11. Find future-dated customer records.
-- Q12. Find future-dated orders.
-- Q13. Find order/product price mismatches.
-- Q14. Calculate quality score for each table.
-- Q15. Calculate quality score by dimension.
-- Q16. Find the dimension with the lowest score.
-- Q17. Find all failed quality rules.
-- Q18. Build an overall PASS/WARN/FAIL report.

-- ============================================================
-- END OF DAY 87
-- ============================================================
