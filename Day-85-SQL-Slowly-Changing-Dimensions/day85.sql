-- SQL-A-Day - Day 85
-- Topic: Slowly Changing Dimensions (SCD)
-- MySQL 8+

DROP DATABASE IF EXISTS sql_scd_lab;
CREATE DATABASE sql_scd_lab;
USE sql_scd_lab;

-- 1. SOURCE DATA
CREATE TABLE customers_source (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    segment VARCHAR(50),
    updated_at DATETIME NOT NULL
);

INSERT INTO customers_source VALUES
(101,'Aarav Sharma','aarav@example.com','Rajkot','Premium','2026-01-10 09:00:00'),
(102,'Diya Patel','diya@example.com','Ahmedabad','Standard','2026-01-12 10:30:00'),
(103,'Rohan Mehta','rohan@example.com','Vadodara','Premium','2026-01-15 11:00:00'),
(104,'Anaya Shah','anaya@example.com','Surat','Standard','2026-01-18 14:20:00');

SELECT * FROM customers_source;

-- 2. SCD TYPE 1: OVERWRITE
CREATE TABLE dim_customer_type1 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    segment VARCHAR(50),
    updated_at DATETIME NOT NULL
);

INSERT INTO dim_customer_type1
SELECT * FROM customers_source;

UPDATE dim_customer_type1
SET city='Ahmedabad', updated_at='2026-02-01 09:00:00'
WHERE customer_id=101;

SELECT * FROM dim_customer_type1;

-- 3. SCD TYPE 2: FULL HISTORY
CREATE TABLE dim_customer_type2 (
    customer_sk INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    segment VARCHAR(50),
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NULL,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uq_customer_version(customer_id, valid_from),
    INDEX idx_customer_current(customer_id, is_current),
    INDEX idx_customer_dates(customer_id, valid_from, valid_to)
);

INSERT INTO dim_customer_type2
(customer_id,customer_name,email,city,segment,valid_from,valid_to,is_current)
SELECT customer_id,customer_name,email,city,segment,updated_at,NULL,TRUE
FROM customers_source;

SELECT * FROM dim_customer_type2 ORDER BY customer_id,valid_from;

-- 4. INCOMING CHANGES
CREATE TABLE customer_changes (
    change_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(100),
    segment VARCHAR(50),
    changed_at DATETIME NOT NULL
);

INSERT INTO customer_changes
(customer_id,customer_name,email,city,segment,changed_at)
VALUES
(101,'Aarav Sharma','aarav@example.com','Ahmedabad','Premium','2026-02-01 09:00:00'),
(102,'Diya Patel','diya@example.com','Ahmedabad','Premium','2026-02-05 10:00:00'),
(103,'Rohan Mehta','rohan@example.com','Pune','Premium','2026-02-08 12:00:00'),
(104,'Anaya Shah','anaya@example.com','Surat','Premium','2026-02-12 15:00:00'),
(105,'Kabir Joshi','kabir@example.com','Mumbai','Standard','2026-02-15 09:30:00');

SELECT * FROM customer_changes ORDER BY changed_at;

-- 5. DETECT CHANGES
SELECT s.customer_id,d.customer_sk,d.city old_city,s.city new_city,
       d.segment old_segment,s.segment new_segment
FROM customer_changes s
JOIN dim_customer_type2 d
  ON s.customer_id=d.customer_id AND d.is_current=TRUE
WHERE NOT (
    s.customer_name <=> d.customer_name
    AND s.email <=> d.email
    AND s.city <=> d.city
    AND s.segment <=> d.segment
);

-- 6. CLOSE CHANGED OLD VERSIONS
UPDATE dim_customer_type2 d
JOIN customer_changes c
  ON d.customer_id=c.customer_id AND d.is_current=TRUE
SET d.valid_to=c.changed_at,d.is_current=FALSE
WHERE NOT (
    d.customer_name <=> c.customer_name
    AND d.email <=> c.email
    AND d.city <=> c.city
    AND d.segment <=> c.segment
);

-- 7. INSERT NEW TYPE 2 VERSIONS
INSERT INTO dim_customer_type2
(customer_id,customer_name,email,city,segment,valid_from,valid_to,is_current)
SELECT c.customer_id,c.customer_name,c.email,c.city,c.segment,c.changed_at,NULL,TRUE
FROM customer_changes c
LEFT JOIN dim_customer_type2 d
  ON c.customer_id=d.customer_id AND d.valid_from=c.changed_at
WHERE d.customer_sk IS NULL;

SELECT * FROM dim_customer_type2 ORDER BY customer_id,valid_from;

-- 8. CURRENT RECORDS
SELECT * FROM dim_customer_type2
WHERE is_current=TRUE ORDER BY customer_id;

-- 9. HISTORICAL RECORDS
SELECT * FROM dim_customer_type2
WHERE is_current=FALSE ORDER BY customer_id,valid_from;

-- 10. POINT-IN-TIME REPORT
SELECT customer_id,customer_name,city,segment,valid_from,valid_to
FROM dim_customer_type2
WHERE '2026-02-06 12:00:00' >= valid_from
  AND (valid_to IS NULL OR '2026-02-06 12:00:00' < valid_to)
ORDER BY customer_id;

-- 11. VERSION COUNTS
SELECT customer_id,COUNT(*) version_count,COUNT(*)-1 change_count
FROM dim_customer_type2
GROUP BY customer_id ORDER BY customer_id;

-- 12. CUSTOMERS WHO CHANGED CITY
SELECT customer_id,COUNT(DISTINCT city) city_count
FROM dim_customer_type2
GROUP BY customer_id
HAVING COUNT(DISTINCT city)>1;

-- 13. LATEST VERSION
WITH ranked AS (
    SELECT d.*,ROW_NUMBER() OVER(
        PARTITION BY customer_id ORDER BY valid_from DESC
    ) rn
    FROM dim_customer_type2 d
)
SELECT customer_id,customer_name,city,segment,valid_from
FROM ranked WHERE rn=1 ORDER BY customer_id;

-- 14. SCD TYPE 3: CURRENT + PREVIOUS VALUE
CREATE TABLE dim_customer_type3 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    current_city VARCHAR(100),
    previous_city VARCHAR(100),
    current_segment VARCHAR(50),
    previous_segment VARCHAR(50),
    updated_at DATETIME NOT NULL
);

INSERT INTO dim_customer_type3
SELECT customer_id,customer_name,city,NULL,segment,NULL,updated_at
FROM customers_source;

UPDATE dim_customer_type3
SET previous_city=current_city,
    current_city='Ahmedabad',
    updated_at='2026-02-01 09:00:00'
WHERE customer_id=101;

UPDATE dim_customer_type3
SET previous_segment=current_segment,
    current_segment='Enterprise',
    updated_at='2026-03-01 10:00:00'
WHERE customer_id=101;

SELECT * FROM dim_customer_type3;

-- 15. SCD TYPE 2 DATA QUALITY CHECKS

-- More than one current version
SELECT customer_id,COUNT(*) current_count
FROM dim_customer_type2
WHERE is_current=TRUE
GROUP BY customer_id
HAVING COUNT(*)>1;

-- Current row incorrectly having valid_to
SELECT * FROM dim_customer_type2
WHERE is_current=TRUE AND valid_to IS NOT NULL;

-- Historical row missing valid_to
SELECT * FROM dim_customer_type2
WHERE is_current=FALSE AND valid_to IS NULL;

-- Invalid date ranges
SELECT * FROM dim_customer_type2
WHERE valid_to IS NOT NULL AND valid_to<=valid_from;

-- 16. PRACTICE QUESTIONS
-- Q1. Find customers with more than one historical version.
-- Q2. Find the first city of every customer.
-- Q3. Find customers whose city changed.
-- Q4. Find the current segment of every customer.
-- Q5. Find versions valid during February 2026.
-- Q6. Find the customer with the highest number of versions.
-- Q7. Find customers whose city and segment changed.
-- Q8. Calculate the duration of each historical version.
-- Q9. Find previous city using LAG().
-- Q10. Build customer_id, first_city, current_city, number_of_changes.

-- END OF DAY 85
