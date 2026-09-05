-- ============================================================
-- DAY 79: MySQL FULL-TEXT SEARCH & RELEVANCE RANKING
-- MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS mysql_fulltext_search_lab;
CREATE DATABASE mysql_fulltext_search_lab;
USE mysql_fulltext_search_lab;

-- ============================================================
-- 1. ARTICLES TABLE
-- ============================================================

DROP TABLE IF EXISTS articles;

CREATE TABLE articles (
    article_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    published_at DATETIME NOT NULL,
    is_published BOOLEAN NOT NULL DEFAULT TRUE,

    FULLTEXT INDEX ft_articles_title_content (title, content)
);

INSERT INTO articles
(title, content, category, author, published_at, is_published)
VALUES
('Introduction to Data Engineering',
 'Data engineering focuses on collecting, transforming, storing, and delivering reliable data for analytics and machine learning. Modern data engineers work with SQL, Python, pipelines, warehouses, and distributed systems.',
 'Data Engineering', 'Aarav', '2026-08-01 09:00:00', TRUE),

('Building Reliable ETL Pipelines',
 'ETL pipelines extract data from source systems, transform it into useful formats, and load it into analytical storage. Reliable pipelines require validation, monitoring, retries, logging, and good data quality practices.',
 'Data Engineering', 'Bhavya', '2026-08-05 10:30:00', TRUE),

('SQL Query Optimization',
 'SQL query optimization improves database performance by reducing unnecessary work. Developers should understand execution plans, filtering, joins, indexes, and efficient query design.',
 'SQL', 'Charan', '2026-08-10 11:15:00', TRUE),

('Understanding Cloud Data Warehouses',
 'Cloud data warehouses provide scalable analytical storage. They are commonly used for business intelligence, reporting, large-scale SQL analytics, and data engineering workloads.',
 'Cloud', 'Divya', '2026-08-12 14:00:00', TRUE),

('Python for Data Engineers',
 'Python is widely used by data engineers for automation, ingestion, data processing, API integration, validation, and pipeline orchestration.',
 'Python', 'Eshan', '2026-08-15 09:45:00', TRUE),

('Data Quality and Validation',
 'Good data quality means data is accurate, complete, consistent, timely, and valid. Data validation helps identify bad records before they affect downstream analytics.',
 'Data Engineering', 'Farah', '2026-08-18 16:20:00', TRUE),

('Machine Learning Data Preparation',
 'Machine learning systems depend on high quality training data. Data engineers help prepare datasets, remove invalid records, transform features, and build repeatable data pipelines.',
 'Machine Learning', 'Gautham', '2026-08-20 13:10:00', TRUE),

('Streaming Data Pipelines',
 'Streaming pipelines process events continuously instead of waiting for large batches. Event streaming is useful for real-time analytics, monitoring, recommendations, and operational systems.',
 'Streaming', 'Harini', '2026-08-22 18:00:00', TRUE),

('Database Transactions',
 'Transactions group database operations into a logical unit of work. Reliable transaction processing helps protect data consistency when multiple operations must succeed together.',
 'Databases', 'Ishaan', '2026-08-24 12:00:00', TRUE),

('Observability for Data Pipelines',
 'Pipeline observability combines logs, metrics, traces, freshness checks, and alerts to help data teams understand whether pipelines are healthy and reliable.',
 'Data Engineering', 'Jahnavi', '2026-08-26 08:30:00', TRUE),

('Secure Data Platforms',
 'Secure data platforms use authentication, authorization, encryption, auditing, least privilege, and careful handling of sensitive information.',
 'Security', 'Kiran', '2026-08-28 15:00:00', TRUE),

('Data Lake Architecture',
 'A data lake can store large volumes of raw and processed data in different formats. Good lake architecture includes ingestion, organization, metadata, governance, and lifecycle management.',
 'Architecture', 'Lavanya', '2026-08-30 17:45:00', TRUE);

-- ============================================================
-- 2. BASIC FULL-TEXT SEARCH
-- ============================================================

SELECT article_id, title, category
FROM articles
WHERE MATCH(title, content)
      AGAINST('data engineering');

-- ============================================================
-- 3. NATURAL LANGUAGE MODE + RELEVANCE
-- ============================================================

SELECT
    article_id,
    title,
    MATCH(title, content)
        AGAINST('data engineering' IN NATURAL LANGUAGE MODE) AS relevance
FROM articles
WHERE MATCH(title, content)
      AGAINST('data engineering' IN NATURAL LANGUAGE MODE)
ORDER BY relevance DESC;

-- ============================================================
-- 4. SINGLE TERM SEARCH
-- ============================================================

SELECT
    article_id,
    title,
    MATCH(title, content) AGAINST('pipeline') AS relevance
FROM articles
WHERE MATCH(title, content) AGAINST('pipeline')
ORDER BY relevance DESC;

-- ============================================================
-- 5. MULTI-WORD SEARCH + RANKING
-- ============================================================

SELECT
    article_id,
    title,
    category,
    MATCH(title, content) AGAINST('data pipeline') AS relevance
FROM articles
WHERE MATCH(title, content) AGAINST('data pipeline')
ORDER BY relevance DESC;

-- ============================================================
-- 6. SEARCH ONLY PUBLISHED ARTICLES
-- ============================================================

SELECT
    article_id,
    title,
    category,
    published_at
FROM articles
WHERE is_published = TRUE
  AND MATCH(title, content) AGAINST('data')
ORDER BY published_at DESC;

-- ============================================================
-- 7. BOOLEAN MODE: BOTH TERMS REQUIRED
-- ============================================================

SELECT article_id, title
FROM articles
WHERE MATCH(title, content)
      AGAINST('+data +pipeline' IN BOOLEAN MODE);

-- ============================================================
-- 8. BOOLEAN MODE: REQUIRED + EXCLUDED TERM
-- ============================================================

SELECT article_id, title
FROM articles
WHERE MATCH(title, content)
      AGAINST('+data -machine' IN BOOLEAN MODE);

-- ============================================================
-- 9. BOOLEAN MODE: EXACT PHRASE
-- ============================================================

SELECT article_id, title
FROM articles
WHERE MATCH(title, content)
      AGAINST('"data engineering"' IN BOOLEAN MODE);

-- ============================================================
-- 10. BOOLEAN MODE: PREFIX SEARCH
-- ============================================================

SELECT article_id, title
FROM articles
WHERE MATCH(title, content)
      AGAINST('engin*' IN BOOLEAN MODE);

-- ============================================================
-- 11. FULL-TEXT SEARCH + CATEGORY FILTER
-- ============================================================

SELECT
    article_id,
    title,
    category,
    MATCH(title, content) AGAINST('data pipeline') AS relevance
FROM articles
WHERE category = 'Data Engineering'
  AND MATCH(title, content) AGAINST('data pipeline')
ORDER BY relevance DESC;

-- ============================================================
-- 12. FULL-TEXT SEARCH + DATE FILTER
-- ============================================================

SELECT
    article_id,
    title,
    published_at,
    MATCH(title, content) AGAINST('data') AS relevance
FROM articles
WHERE published_at >= '2026-08-15'
  AND MATCH(title, content) AGAINST('data')
ORDER BY relevance DESC;

-- ============================================================
-- 13. PRODUCT SEARCH
-- ============================================================

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,

    FULLTEXT INDEX ft_products_name_description
        (product_name, description)
);

INSERT INTO products
(product_name, description, category, price)
VALUES
('Data Engineering Laptop',
 'Powerful laptop for SQL development, Python programming, ETL pipelines, cloud tools, and analytics workloads.',
 'Computers', 85000),

('SQL Developer Keyboard',
 'Mechanical keyboard designed for developers who spend long hours writing SQL and application code.',
 'Accessories', 6500),

('Cloud Computing Laptop',
 'High performance laptop suitable for cloud development, containers, programming, and data engineering.',
 'Computers', 92000),

('Data Analytics Monitor',
 'Large display designed for dashboards, analytics, coding, and data visualization.',
 'Monitors', 28000),

('Python Programming Book',
 'Practical guide to Python programming, automation, data processing, and engineering workflows.',
 'Books', 1200);

SELECT
    product_id,
    product_name,
    price,
    MATCH(product_name, description)
        AGAINST('data engineering') AS relevance
FROM products
WHERE MATCH(product_name, description)
      AGAINST('data engineering')
ORDER BY relevance DESC;

-- ============================================================
-- 14. PRODUCT SEARCH + PRICE FILTER
-- ============================================================

SELECT
    product_id,
    product_name,
    price,
    MATCH(product_name, description)
        AGAINST('programming') AS relevance
FROM products
WHERE price < 90000
  AND MATCH(product_name, description)
      AGAINST('programming')
ORDER BY relevance DESC, price ASC;

-- ============================================================
-- 15. SEARCH RESULTS FOR AN APPLICATION
-- ============================================================

SELECT
    article_id,
    title,
    category,
    author,
    published_at,
    MATCH(title, content) AGAINST('cloud data') AS relevance
FROM articles
WHERE is_published = TRUE
  AND MATCH(title, content) AGAINST('cloud data')
ORDER BY relevance DESC, published_at DESC
LIMIT 10;

-- ============================================================
-- 16. TITLE-ONLY FULL-TEXT INDEX
-- ============================================================

ALTER TABLE articles
ADD FULLTEXT INDEX ft_articles_title (title);

SELECT
    article_id,
    title,
    MATCH(title) AGAINST('data') AS title_relevance
FROM articles
WHERE MATCH(title) AGAINST('data')
ORDER BY title_relevance DESC;

-- ============================================================
-- 17. CHECK FULL-TEXT INDEXES
-- ============================================================

SHOW INDEX FROM articles;

-- ============================================================
-- 18. EXPLAIN FULL-TEXT SEARCH
-- ============================================================

EXPLAIN
SELECT article_id, title
FROM articles
WHERE MATCH(title, content)
      AGAINST('data pipeline');

-- ============================================================
-- 19. PRACTICE QUERIES
-- ============================================================

-- Q1. Search articles for "Python".

-- Q2. Search articles for "data engineering"
--     and order by relevance.

-- Q3. Find articles containing both "data" and "pipeline"
--     using BOOLEAN MODE.

-- Q4. Find articles containing "data" but excluding "machine".

-- Q5. Search for the exact phrase "data quality".

-- Q6. Find products related to "cloud".

-- Q7. Find products related to "programming"
--     costing less than 10000.

-- Q8. Search for "data pipeline" and return the top 5 results.

-- Q9. Search only article titles for "SQL".

-- Q10. Return title, category, relevance, and date
--      for a search term of your choice.

-- ============================================================
-- 20. QUICK SYNTAX REFERENCE
-- ============================================================

-- Natural language:
-- MATCH(column1, column2)
-- AGAINST('search terms');

-- Boolean:
-- MATCH(column1, column2)
-- AGAINST('+data -machine' IN BOOLEAN MODE);

-- Exact phrase:
-- MATCH(column1, column2)
-- AGAINST('"data engineering"' IN BOOLEAN MODE);

-- Prefix:
-- MATCH(column1, column2)
-- AGAINST('engin*' IN BOOLEAN MODE);

-- ============================================================
-- END OF DAY 79
-- ============================================================
