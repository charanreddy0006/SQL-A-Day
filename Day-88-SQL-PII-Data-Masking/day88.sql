-- Day 88: SQL PII Data Masking & Privacy Protection
-- MySQL 8.0+ | Synthetic learning data only
CREATE DATABASE IF NOT EXISTS sql_pii_privacy_lab;
USE sql_pii_privacy_lab;

DROP VIEW IF EXISTS vw_customer_safe;
DROP TABLE IF EXISTS customer_access_log;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(150),
  phone VARCHAR(25),
  national_id VARCHAR(30),
  birth_date DATE,
  city VARCHAR(80),
  account_balance DECIMAL(12,2),
  consent_marketing BOOLEAN NOT NULL DEFAULT FALSE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customers VALUES
(1,'Aarav Shah','aarav.shah@example.com','+91-9876543210','ABCDE1234F','1998-04-12','Rajkot',24500.50,TRUE,'2026-01-10 09:15:00'),
(2,'Diya Patel','diya.patel@example.com','+91-9123456780','FGHIJ5678K','2001-09-03','Ahmedabad',8300.00,FALSE,'2026-02-18 13:40:00'),
(3,'Kabir Mehta','kabir.mehta@example.com','+91-9988776655','LMNOP9012Q','1995-12-25','Surat',119999.99,TRUE,'2026-03-02 17:05:00'),
(4,'Anaya Joshi','anaya.joshi@example.com','+91-9012345678','RSTUV3456W','2003-06-17','Vadodara',1250.75,FALSE,'2026-04-21 11:20:00'),
(5,'Ishaan Desai','ishaan.desai@example.com','+91-9090909090','XYZAB7890C','1989-01-30','Rajkot',50200.00,TRUE,'2026-05-11 08:30:00');

CREATE TABLE customer_access_log (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  accessed_by VARCHAR(100) NOT NULL,
  access_purpose VARCHAR(200) NOT NULL,
  accessed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customer_access_log (customer_id, accessed_by, access_purpose) VALUES
(1,'support_agent_01','Customer requested account assistance'),
(2,'analyst_02','Monthly aggregate reporting'),
(3,'fraud_team_01','Fraud investigation');

-- 1. Inspect columns that may contain personal information.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = DATABASE() AND table_name = 'customers'
ORDER BY ordinal_position;

-- 2. Mask email addresses; handle missing/malformed values.
SELECT customer_id,
 CASE
   WHEN email IS NULL OR email = '' THEN NULL
   WHEN LOCATE('@', email) <= 1 THEN '***'
   ELSE CONCAT(LEFT(email,1),'***',SUBSTRING(email,LOCATE('@',email)))
 END AS masked_email
FROM customers;

-- 3. Show only the last four characters of a phone number.
SELECT customer_id, CONCAT('******',RIGHT(phone,4)) AS masked_phone
FROM customers WHERE phone IS NOT NULL;

-- 4. Mask a national identifier.
SELECT customer_id, CONCAT('*****',RIGHT(national_id,4)) AS masked_national_id
FROM customers WHERE national_id IS NOT NULL;

-- 5. Create a privacy-safer view for routine reports.
CREATE OR REPLACE VIEW vw_customer_safe AS
SELECT customer_id,
 CONCAT(LEFT(full_name,1),'***') AS masked_name,
 CASE WHEN email IS NULL OR email = '' THEN NULL
      ELSE CONCAT(LEFT(email,1),'***',SUBSTRING(email,LOCATE('@',email))) END AS masked_email,
 CASE WHEN phone IS NULL OR phone = '' THEN NULL
      ELSE CONCAT('******',RIGHT(phone,4)) END AS masked_phone,
 CASE WHEN national_id IS NULL OR national_id = '' THEN NULL
      ELSE CONCAT('*****',RIGHT(national_id,4)) END AS masked_national_id,
 TIMESTAMPDIFF(YEAR,birth_date,CURDATE()) AS age_years,
 city,
 CASE WHEN account_balance < 10000 THEN 'Under 10K'
      WHEN account_balance < 50000 THEN '10K-50K'
      ELSE '50K and above' END AS balance_band,
 consent_marketing, DATE(created_at) AS signup_date
FROM customers;

SELECT * FROM vw_customer_safe ORDER BY customer_id;

-- 6. Prefer aggregate reports when individual identities are unnecessary.
SELECT city, COUNT(*) AS customer_count,
       AVG(account_balance) AS average_balance,
       SUM(consent_marketing = TRUE) AS marketing_opt_in_count
FROM customers GROUP BY city ORDER BY customer_count DESC;

-- 7. Use age bands instead of exposing exact birth dates.
SELECT CASE
  WHEN TIMESTAMPDIFF(YEAR,birth_date,CURDATE()) < 25 THEN 'Under 25'
  WHEN TIMESTAMPDIFF(YEAR,birth_date,CURDATE()) < 40 THEN '25-39'
  WHEN TIMESTAMPDIFF(YEAR,birth_date,CURDATE()) < 60 THEN '40-59'
  ELSE '60+' END AS age_band, COUNT(*) AS customers
FROM customers GROUP BY age_band ORDER BY age_band;

-- 8. Review access metadata.
SELECT log_id, customer_id, accessed_by, access_purpose, accessed_at
FROM customer_access_log ORDER BY accessed_at DESC;

-- 9. Find repeated access for review.
SELECT accessed_by, COUNT(*) AS access_count,
       MIN(accessed_at) AS first_access, MAX(accessed_at) AS last_access
FROM customer_access_log GROUP BY accessed_by HAVING COUNT(*) > 1;

-- 10. Data minimization: only fields needed for eligibility.
SELECT customer_id, city, consent_marketing
FROM customers WHERE consent_marketing = TRUE;

-- 11. Missing-value-aware display.
SELECT customer_id,
 COALESCE(NULLIF(email,''),'[not provided]') AS email_status,
 CASE WHEN phone IS NULL OR phone = '' THEN '[not provided]'
      ELSE CONCAT('******',RIGHT(phone,4)) END AS phone_display
FROM customers;

-- Practice:
-- A. Show only the domain of each email.
-- B. Count customers by city and marketing consent.
-- C. Find missing national IDs without returning the IDs themselves.
-- D. Query access logs from the last 30 days.
-- E. Explain why masking is not a replacement for permissions.

-- Optional cleanup:
-- DROP VIEW IF EXISTS vw_customer_safe;
-- DROP TABLE IF EXISTS customer_access_log;
-- DROP TABLE IF EXISTS customers;
-- DROP DATABASE IF EXISTS sql_pii_privacy_lab;
