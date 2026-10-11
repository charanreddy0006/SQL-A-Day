-- Day 89: SQL Deduplication & Survivorship Rules
-- MySQL 8.0+ | Synthetic data for learning
CREATE DATABASE IF NOT EXISTS sql_deduplication_lab;
USE sql_deduplication_lab;

DROP VIEW IF EXISTS vw_duplicate_email_groups;
DROP TABLE IF EXISTS merge_audit;
DROP TABLE IF EXISTS customer_staging;

CREATE TABLE customer_staging (
  staging_id INT PRIMARY KEY,
  source_system VARCHAR(30) NOT NULL,
  source_customer_id VARCHAR(30),
  full_name VARCHAR(100),
  email VARCHAR(150),
  phone VARCHAR(25),
  city VARCHAR(80),
  loyalty_points INT,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  last_updated_at DATETIME,
  ingested_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO customer_staging VALUES
(1,'CRM','CRM-101','Aarav Shah','aarav.shah@example.com','+91-9876543210','Rajkot',120,TRUE,'2026-08-01 10:00:00','2026-08-01 10:05:00'),
(2,'WEB','WEB-501','Aarav Shah','AARAV.SHAH@example.com','+91-9876543210','Rajkot',120,TRUE,'2026-08-03 09:00:00','2026-08-03 09:05:00'),
(3,'CRM','CRM-102','Diya Patel','diya.patel@example.com','+91-9123456780','Ahmedabad',80,TRUE,'2026-08-04 11:30:00','2026-08-04 11:35:00'),
(4,'WEB','WEB-502','Diya P Patel','diya.patel@example.com',NULL,'Ahmedabad',80,FALSE,'2026-08-05 08:30:00','2026-08-05 08:35:00'),
(5,'MOBILE','APP-900','Kabir Mehta','kabir.mehta@example.com','+91-9988776655','Surat',45,TRUE,'2026-08-02 15:00:00','2026-08-02 15:05:00'),
(6,'CRM','CRM-103','Kabir Mehta','kabir.mehta@example.com','+91-9988776655','Surat',50,TRUE,'2026-08-06 12:00:00','2026-08-06 12:05:00'),
(7,'WEB','WEB-503','Ishita Rao','ishita.rao@example.com','+91-9000011111','Rajkot',20,TRUE,'2026-08-01 07:00:00','2026-08-01 07:10:00'),
(8,'CRM','CRM-104','Ishita Rao','ishita.rao@example.com','+91-9000011111','Rajkot',20,TRUE,'2026-08-07 16:00:00','2026-08-07 16:05:00'),
(9,'WEB','WEB-504','Rohan Shah','rohan.shah@example.com',NULL,'Junagadh',10,FALSE,'2026-08-02 10:00:00','2026-08-02 10:10:00'),
(10,'CRM','CRM-105','Rohan Shah','rohan.shah@example.com','+91-9111122222','Junagadh',15,TRUE,'2026-08-08 09:00:00','2026-08-08 09:05:00'),
(11,'MOBILE','APP-901','Meera Joshi','meera.joshi@example.com','+91-9222233333','Vadodara',65,TRUE,'2026-08-09 14:00:00','2026-08-09 14:05:00'),
(12,'CRM','CRM-106','Meera Joshi','meera.joshi@example.com','+91-9222233333','Vadodara',65,TRUE,'2026-08-10 09:00:00','2026-08-10 09:05:00');

CREATE TABLE merge_audit (
  audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  survivor_staging_id INT NOT NULL,
  duplicate_staging_id INT NOT NULL,
  merge_reason VARCHAR(255) NOT NULL,
  reviewed_by VARCHAR(100),
  reviewed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 1. Inspect raw source records.
SELECT * FROM customer_staging ORDER BY staging_id;

-- 2. Normalize fields for comparison without changing source values.
SELECT staging_id,
       LOWER(TRIM(email)) AS normalized_email,
       REGEXP_REPLACE(phone, '[^0-9]', '') AS normalized_phone,
       REGEXP_REPLACE(LOWER(TRIM(full_name)), '[[:space:]]+', ' ') AS normalized_name
FROM customer_staging;

-- 3. Exact duplicate candidate groups by normalized email.
SELECT LOWER(TRIM(email)) AS normalized_email,
       COUNT(*) AS record_count,
       GROUP_CONCAT(staging_id ORDER BY staging_id) AS staging_ids
FROM customer_staging
WHERE email IS NOT NULL AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;

-- 4. Rank records using verification, recency, completeness, and tie-breaker.
WITH scored AS (
  SELECT c.*,
    ((email IS NOT NULL AND TRIM(email) <> '') +
     (phone IS NOT NULL AND TRIM(phone) <> '') +
     (city IS NOT NULL AND TRIM(city) <> '') +
     (full_name IS NOT NULL AND TRIM(full_name) <> '')) AS completeness_score
  FROM customer_staging c
),
ranked AS (
  SELECT scored.*,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(TRIM(email))
      ORDER BY is_verified DESC, last_updated_at DESC,
               completeness_score DESC, staging_id ASC
    ) AS survivor_rank
  FROM scored
  WHERE email IS NOT NULL AND TRIM(email) <> ''
)
SELECT staging_id, source_system, full_name, email, phone, city,
       is_verified, last_updated_at, completeness_score, survivor_rank
FROM ranked
ORDER BY normalized_email, survivor_rank;

-- 5. Select one survivor per normalized-email group.
WITH ranked AS (
  SELECT c.*,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(TRIM(email))
      ORDER BY is_verified DESC, last_updated_at DESC, staging_id ASC
    ) AS rn
  FROM customer_staging c
  WHERE email IS NOT NULL AND TRIM(email) <> ''
)
SELECT staging_id, full_name, email, phone, city, loyalty_points
FROM ranked WHERE rn = 1
ORDER BY staging_id;

-- 6. Missing identifiers should be reviewed, not automatically merged.
SELECT staging_id, source_system, full_name, phone, city
FROM customer_staging
WHERE email IS NULL OR TRIM(email) = '';

-- 7. Duplicate phone candidate groups after removing formatting.
SELECT REGEXP_REPLACE(phone, '[^0-9]', '') AS normalized_phone,
       COUNT(*) AS record_count,
       GROUP_CONCAT(staging_id ORDER BY staging_id) AS staging_ids
FROM customer_staging
WHERE phone IS NOT NULL AND TRIM(phone) <> ''
GROUP BY REGEXP_REPLACE(phone, '[^0-9]', '')
HAVING COUNT(*) > 1;

-- 8. Secondary candidate rule: same normalized name and city.
SELECT REGEXP_REPLACE(LOWER(TRIM(full_name)), '[[:space:]]+', ' ') AS normalized_name,
       LOWER(TRIM(city)) AS normalized_city,
       COUNT(*) AS record_count,
       GROUP_CONCAT(staging_id ORDER BY staging_id) AS staging_ids
FROM customer_staging
GROUP BY REGEXP_REPLACE(LOWER(TRIM(full_name)), '[[:space:]]+', ' '),
         LOWER(TRIM(city))
HAVING COUNT(*) > 1;

-- 9. Reusable view of duplicate email groups.
CREATE OR REPLACE VIEW vw_duplicate_email_groups AS
SELECT LOWER(TRIM(email)) AS normalized_email,
       COUNT(*) AS duplicate_count,
       GROUP_CONCAT(staging_id ORDER BY staging_id) AS staging_ids
FROM customer_staging
WHERE email IS NOT NULL AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(*) > 1;
SELECT * FROM vw_duplicate_email_groups;

-- 10. Produce a review list: selected survivor beside each other candidate.
WITH ranked AS (
  SELECT staging_id, email,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(TRIM(email))
      ORDER BY is_verified DESC, last_updated_at DESC, staging_id ASC
    ) AS rn,
    FIRST_VALUE(staging_id) OVER (
      PARTITION BY LOWER(TRIM(email))
      ORDER BY is_verified DESC, last_updated_at DESC, staging_id ASC
    ) AS survivor_id
  FROM customer_staging
  WHERE email IS NOT NULL AND TRIM(email) <> ''
)
SELECT survivor_id, staging_id AS candidate_duplicate_id, email, rn
FROM ranked WHERE rn > 1
ORDER BY survivor_id, candidate_duplicate_id;

-- 11. Find same-email records with conflicting phone values.
SELECT LOWER(TRIM(email)) AS normalized_email,
       COUNT(DISTINCT NULLIF(REGEXP_REPLACE(phone, '[^0-9]', ''), '')) AS distinct_phones,
       GROUP_CONCAT(staging_id ORDER BY staging_id) AS staging_ids
FROM customer_staging
WHERE email IS NOT NULL AND TRIM(email) <> ''
GROUP BY LOWER(TRIM(email))
HAVING COUNT(DISTINCT NULLIF(REGEXP_REPLACE(phone, '[^0-9]', ''), '')) > 1;

-- 12. Record a reviewed merge decision only after human validation.
-- INSERT INTO merge_audit
-- (survivor_staging_id, duplicate_staging_id, merge_reason, reviewed_by)
-- VALUES (2, 1, 'Same normalized email; verified and newest record selected', 'reviewer_name');

SELECT * FROM merge_audit ORDER BY reviewed_at DESC;

-- Practice:
-- A. Add source-system priority to the survivor ranking.
-- B. Rank by completeness before recency and compare the result.
-- C. Find duplicate normalized phones where emails differ.
-- D. Explain why a matching name is not proof of identity.
-- E. Design a canonical customer table with a stable customer_id.

-- Optional cleanup:
-- DROP VIEW IF EXISTS vw_duplicate_email_groups;
-- DROP TABLE IF EXISTS merge_audit;
-- DROP TABLE IF EXISTS customer_staging;
-- DROP DATABASE IF EXISTS sql_deduplication_lab;
