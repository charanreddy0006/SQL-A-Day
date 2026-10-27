-- ================================================================
-- Day 94 — SQL Data Sampling & Approximate Analytics (MySQL 8.0+)
-- ================================================================
-- Self-contained practice database with deterministic sampling,
-- approximate estimates, uncertainty, stratification, and exact checks.

CREATE DATABASE IF NOT EXISTS sql_sampling_day94;
USE sql_sampling_day94;

DROP TABLE IF EXISTS order_sample;
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT NOT NULL PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_tier VARCHAR(10) NOT NULL,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL,
    is_large_order TINYINT(1) NOT NULL
);

-- Generate 1,000 reproducible synthetic orders.
INSERT INTO orders
    (order_id, customer_id, customer_tier, order_date, order_amount, is_large_order)
WITH RECURSIVE sequence_numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM sequence_numbers WHERE n < 1000
)
SELECT
    n,
    10000 + MOD(n * 37, 240),
    CASE WHEN MOD(n, 10) < 2 THEN 'Gold'
         WHEN MOD(n, 10) < 6 THEN 'Silver'
         ELSE 'Bronze' END,
    DATE_ADD('2026-01-01', INTERVAL MOD(n * 13, 273) DAY),
    CAST(25 + MOD(n * 73, 1975) + MOD(n * 19, 100) / 100 AS DECIMAL(10,2)),
    CASE WHEN MOD(n * 73, 1975) >= 1000 THEN 1 ELSE 0 END
FROM sequence_numbers;

-- Inspect the population definition and its exact metrics.
SELECT COUNT(*) AS population_n,
       SUM(order_amount) AS exact_revenue,
       AVG(order_amount) AS exact_average,
       MIN(order_date) AS first_date,
       MAX(order_date) AS last_date
FROM orders;

-- 1. Deterministic hash-based sample, approximately 10%.
-- CRC32 is a checksum; inspect distribution and validate for real data.
CREATE TABLE order_sample AS
SELECT order_id, customer_id, customer_tier, order_date,
       order_amount, is_large_order
FROM orders
WHERE MOD(CRC32(CAST(order_id AS CHAR)), 100) < 10;

SELECT (SELECT COUNT(*) FROM orders) AS population_n,
       COUNT(*) AS sample_n,
       ROUND(COUNT(*) / (SELECT COUNT(*) FROM orders), 4) AS observed_fraction
FROM order_sample;

SELECT order_id, customer_tier, order_amount
FROM order_sample ORDER BY order_id LIMIT 20;

-- 2. Estimate average and total; compute approximate SE and 95% interval.
-- Expansion estimate assumes an equal-probability 10% sample.
WITH sample_stats AS (
    SELECT COUNT(*) AS sample_n,
           AVG(order_amount) AS sample_mean,
           SUM(order_amount) AS sample_sum,
           STDDEV_SAMP(order_amount) AS sample_sd
    FROM order_sample
), population_stats AS (
    SELECT COUNT(*) AS population_n FROM orders
)
SELECT p.population_n,
       s.sample_n,
       ROUND(s.sample_n / p.population_n, 4) AS observed_fraction,
       ROUND(s.sample_mean, 2) AS estimated_average,
       ROUND(s.sample_sum / 0.10, 2) AS estimated_population_revenue,
       ROUND(s.sample_sd / SQRT(s.sample_n)
         * SQRT((p.population_n - s.sample_n) / (p.population_n - 1)), 2)
         AS approximate_standard_error,
       ROUND(s.sample_mean - 1.96 * (s.sample_sd / SQRT(s.sample_n)
         * SQRT((p.population_n - s.sample_n) / (p.population_n - 1))), 2)
         AS approximate_95pct_ci_lower,
       ROUND(s.sample_mean + 1.96 * (s.sample_sd / SQRT(s.sample_n)
         * SQRT((p.population_n - s.sample_n) / (p.population_n - 1))), 2)
         AS approximate_95pct_ci_upper
FROM sample_stats AS s CROSS JOIN population_stats AS p;

-- 3. Estimate a population proportion and count of large orders.
WITH sample_proportion AS (
    SELECT AVG(is_large_order) AS estimated_share FROM order_sample
)
SELECT ROUND(sp.estimated_share, 4) AS estimated_share,
       ROUND(sp.estimated_share * pop.population_n, 0) AS estimated_count
FROM sample_proportion AS sp
CROSS JOIN (SELECT COUNT(*) AS population_n FROM orders) AS pop;

-- 4. Stratified view: hash sample by tier, then report tier estimates.
-- Weight stratum means by stratum population size for an overall mean.
WITH tier_sample AS (
    SELECT * FROM orders
    WHERE MOD(CRC32(CAST(order_id AS CHAR)), 100) < 10
), tier_stats AS (
    SELECT o.customer_tier,
           COUNT(*) AS tier_population_n,
           COUNT(ts.order_id) AS tier_sample_n,
           AVG(ts.order_amount) AS tier_sample_mean
    FROM orders AS o
    LEFT JOIN tier_sample AS ts ON ts.order_id = o.order_id
    GROUP BY o.customer_tier
)
SELECT customer_tier,
       tier_population_n,
       tier_sample_n,
       ROUND(tier_sample_n / tier_population_n, 4) AS observed_tier_fraction,
       ROUND(tier_sample_mean, 2) AS estimated_tier_average
FROM tier_stats ORDER BY customer_tier;

WITH tier_sample AS (
    SELECT * FROM orders
    WHERE MOD(CRC32(CAST(order_id AS CHAR)), 100) < 10
), tier_stats AS (
    SELECT o.customer_tier,
           COUNT(*) AS tier_population_n,
           AVG(ts.order_amount) AS tier_sample_mean
    FROM orders AS o
    LEFT JOIN tier_sample AS ts ON ts.order_id = o.order_id
    GROUP BY o.customer_tier
)
SELECT ROUND(SUM(tier_population_n * tier_sample_mean)
             / SUM(tier_population_n), 2) AS stratified_weighted_mean_estimate
FROM tier_stats;

-- 5. Exact answers for comparison with the estimates above.
SELECT COUNT(*) AS exact_population_n,
       SUM(order_amount) AS exact_revenue,
       AVG(order_amount) AS exact_average,
       AVG(is_large_order) AS exact_large_order_share,
       SUM(is_large_order) AS exact_large_order_count
FROM orders;

-- 6. Easy to understand on small tables, but often costly at scale:
-- RAND() is evaluated per row and random ordering can require sorting.
SELECT order_id, customer_tier, order_amount
FROM orders ORDER BY RAND() LIMIT 10;

-- Practice: change < 10 to < 5 (about 5%) or < 20 (about 20%).
-- A second reproducible sample can use a fixed salt:
-- SELECT order_id FROM orders
-- WHERE MOD(CRC32(CONCAT('day94-experiment-2:', order_id)), 100) < 10;
