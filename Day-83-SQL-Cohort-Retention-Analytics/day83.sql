-- Day 83 - SQL Cohort Analysis & Retention Analytics
-- MySQL 8.x

DROP DATABASE IF EXISTS sql_cohort_lab;
CREATE DATABASE sql_cohort_lab;
USE sql_cohort_lab;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    signup_date DATE NOT NULL
);

INSERT INTO users VALUES
(1,'Aarav','2026-01-05'),(2,'Diya','2026-01-12'),(3,'Rohan','2026-01-20'),
(4,'Meera','2026-02-03'),(5,'Kabir','2026-02-11'),(6,'Anaya','2026-02-25'),
(7,'Ishaan','2026-03-04'),(8,'Sara','2026-03-18'),(9,'Vihaan','2026-03-22'),
(10,'Tara','2026-04-02'),(11,'Arjun','2026-04-16'),(12,'Nisha','2026-04-27');

CREATE TABLE user_activity (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    activity_date DATE NOT NULL,
    activity_type VARCHAR(30) NOT NULL,
    revenue DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO user_activity (user_id,activity_date,activity_type,revenue) VALUES
(1,'2026-01-05','purchase',120),(1,'2026-01-18','login',0),(1,'2026-02-07','purchase',80),(1,'2026-03-10','login',0),(1,'2026-04-12','purchase',150),
(2,'2026-01-12','purchase',100),(2,'2026-02-14','login',0),(2,'2026-03-08','purchase',60),
(3,'2026-01-20','purchase',200),(3,'2026-01-28','login',0),(3,'2026-02-20','purchase',90),(3,'2026-04-15','login',0),
(4,'2026-02-03','purchase',110),(4,'2026-03-04','purchase',75),(4,'2026-04-09','login',0),
(5,'2026-02-11','purchase',180),(5,'2026-02-25','purchase',40),(5,'2026-03-16','purchase',90),(5,'2026-04-18','purchase',120),
(6,'2026-02-25','purchase',130),(6,'2026-04-20','login',0),
(7,'2026-03-04','purchase',160),(7,'2026-04-03','purchase',95),(7,'2026-05-07','purchase',110),
(8,'2026-03-18','purchase',140),(8,'2026-03-29','login',0),(8,'2026-05-12','purchase',75),
(9,'2026-03-22','purchase',220),(9,'2026-04-21','login',0),
(10,'2026-04-02','purchase',100),(10,'2026-05-04','purchase',80),
(11,'2026-04-16','purchase',170),(11,'2026-06-05','purchase',100),
(12,'2026-04-27','purchase',125),(12,'2026-05-20','login',0);

-- 1. Assign cohorts
SELECT user_id,user_name,signup_date,
       DATE_FORMAT(signup_date,'%Y-%m-01') AS cohort_month
FROM users ORDER BY signup_date;

-- 2. Cohort sizes
SELECT DATE_FORMAT(signup_date,'%Y-%m-01') AS cohort_month,
       COUNT(*) AS cohort_size
FROM users
GROUP BY DATE_FORMAT(signup_date,'%Y-%m-01')
ORDER BY cohort_month;

-- 3. Unique activity months
SELECT DISTINCT user_id,
       DATE_FORMAT(activity_date,'%Y-%m-01') AS activity_month
FROM user_activity
ORDER BY user_id,activity_month;

-- 4. Cohort + activity month + lifecycle month
WITH activity AS (
    SELECT DISTINCT
        u.user_id,
        DATE_FORMAT(u.signup_date,'%Y-%m-01') AS cohort_month,
        DATE_FORMAT(a.activity_date,'%Y-%m-01') AS activity_month
    FROM users u JOIN user_activity a ON u.user_id=a.user_id
)
SELECT user_id,cohort_month,activity_month,
       TIMESTAMPDIFF(MONTH,cohort_month,activity_month) AS month_number
FROM activity
ORDER BY cohort_month,user_id,activity_month;

-- 5. Retained users by cohort/month
WITH activity AS (
    SELECT DISTINCT
        u.user_id,
        DATE_FORMAT(u.signup_date,'%Y-%m-01') AS cohort_month,
        DATE_FORMAT(a.activity_date,'%Y-%m-01') AS activity_month
    FROM users u JOIN user_activity a ON u.user_id=a.user_id
)
SELECT cohort_month,
       TIMESTAMPDIFF(MONTH,cohort_month,activity_month) AS month_number,
       COUNT(DISTINCT user_id) AS retained_users
FROM activity
GROUP BY cohort_month,
         TIMESTAMPDIFF(MONTH,cohort_month,activity_month)
ORDER BY cohort_month,month_number;

-- 6. Retention percentage
WITH cohort_sizes AS (
    SELECT DATE_FORMAT(signup_date,'%Y-%m-01') cohort_month,COUNT(*) cohort_size
    FROM users GROUP BY DATE_FORMAT(signup_date,'%Y-%m-01')
),
activity AS (
    SELECT DISTINCT u.user_id,
           DATE_FORMAT(u.signup_date,'%Y-%m-01') cohort_month,
           DATE_FORMAT(a.activity_date,'%Y-%m-01') activity_month
    FROM users u JOIN user_activity a ON u.user_id=a.user_id
),
retention AS (
    SELECT cohort_month,
           TIMESTAMPDIFF(MONTH,cohort_month,activity_month) month_number,
           COUNT(DISTINCT user_id) retained_users
    FROM activity
    GROUP BY cohort_month,TIMESTAMPDIFF(MONTH,cohort_month,activity_month)
)
SELECT r.cohort_month,r.month_number,r.retained_users,c.cohort_size,
       ROUND(100.0*r.retained_users/c.cohort_size,2) retention_pct
FROM retention r JOIN cohort_sizes c ON r.cohort_month=c.cohort_month
ORDER BY r.cohort_month,r.month_number;

-- 7. Retention matrix
WITH sizes AS (
    SELECT DATE_FORMAT(signup_date,'%Y-%m-01') cohort_month,COUNT(*) cohort_size
    FROM users GROUP BY DATE_FORMAT(signup_date,'%Y-%m-01')
),
activity AS (
    SELECT DISTINCT u.user_id,
           DATE_FORMAT(u.signup_date,'%Y-%m-01') cohort_month,
           TIMESTAMPDIFF(MONTH,
             DATE_FORMAT(u.signup_date,'%Y-%m-01'),
             DATE_FORMAT(a.activity_date,'%Y-%m-01')) month_number
    FROM users u JOIN user_activity a ON u.user_id=a.user_id
),
r AS (
    SELECT cohort_month,month_number,COUNT(DISTINCT user_id) retained_users
    FROM activity GROUP BY cohort_month,month_number
)
SELECT r.cohort_month,
 ROUND(100*SUM(CASE WHEN month_number=0 THEN retained_users ELSE 0 END)/s.cohort_size,2) month_0_pct,
 ROUND(100*SUM(CASE WHEN month_number=1 THEN retained_users ELSE 0 END)/s.cohort_size,2) month_1_pct,
 ROUND(100*SUM(CASE WHEN month_number=2 THEN retained_users ELSE 0 END)/s.cohort_size,2) month_2_pct,
 ROUND(100*SUM(CASE WHEN month_number=3 THEN retained_users ELSE 0 END)/s.cohort_size,2) month_3_pct,
 ROUND(100*SUM(CASE WHEN month_number=4 THEN retained_users ELSE 0 END)/s.cohort_size,2) month_4_pct,
 ROUND(100*SUM(CASE WHEN month_number=5 THEN retained_users ELSE 0 END)/s.cohort_size,2) month_5_pct
FROM r JOIN sizes s ON r.cohort_month=s.cohort_month
GROUP BY r.cohort_month,s.cohort_size
ORDER BY r.cohort_month;

-- 8. Monthly active users
SELECT DATE_FORMAT(activity_date,'%Y-%m-01') activity_month,
       COUNT(DISTINCT user_id) active_users
FROM user_activity
GROUP BY DATE_FORMAT(activity_date,'%Y-%m-01')
ORDER BY activity_month;

-- 9. Monthly revenue
SELECT DATE_FORMAT(activity_date,'%Y-%m-01') activity_month,
       COUNT(DISTINCT user_id) active_users,
       ROUND(SUM(revenue),2) revenue
FROM user_activity
GROUP BY DATE_FORMAT(activity_date,'%Y-%m-01')
ORDER BY activity_month;

-- 10. Revenue by cohort and lifecycle month
SELECT DATE_FORMAT(u.signup_date,'%Y-%m-01') cohort_month,
       TIMESTAMPDIFF(MONTH,
         DATE_FORMAT(u.signup_date,'%Y-%m-01'),
         DATE_FORMAT(a.activity_date,'%Y-%m-01')) month_number,
       ROUND(SUM(a.revenue),2) revenue
FROM users u JOIN user_activity a ON u.user_id=a.user_id
GROUP BY cohort_month,month_number
ORDER BY cohort_month,month_number;

-- 11. Lifetime revenue
SELECT u.user_id,u.user_name,
       ROUND(SUM(a.revenue),2) lifetime_revenue
FROM users u JOIN user_activity a ON u.user_id=a.user_id
GROUP BY u.user_id,u.user_name
ORDER BY lifetime_revenue DESC;

-- 12. Reactivation detection
WITH monthly_activity AS (
    SELECT DISTINCT user_id,DATE_FORMAT(activity_date,'%Y-%m-01') activity_month
    FROM user_activity
),
with_previous AS (
    SELECT user_id,activity_month,
           LAG(activity_month) OVER(PARTITION BY user_id ORDER BY activity_month) previous_month
    FROM monthly_activity
)
SELECT user_id,activity_month AS reactivated_month,
       previous_month,
       TIMESTAMPDIFF(MONTH,previous_month,activity_month) inactive_month_gap
FROM with_previous
WHERE previous_month IS NOT NULL
  AND TIMESTAMPDIFF(MONTH,previous_month,activity_month)>1
ORDER BY user_id,activity_month;

-- 13. Lifecycle state as of June 2026
SET @analysis_month='2026-06-01';

WITH last_activity AS (
    SELECT user_id,MAX(DATE_FORMAT(activity_date,'%Y-%m-01')) last_active_month
    FROM user_activity GROUP BY user_id
)
SELECT u.user_id,u.user_name,
       DATE_FORMAT(u.signup_date,'%Y-%m-01') cohort_month,
       l.last_active_month,
       CASE
         WHEN l.last_active_month=@analysis_month THEN 'ACTIVE'
         WHEN l.last_active_month<@analysis_month THEN 'INACTIVE'
         ELSE 'NO_ACTIVITY'
       END lifecycle_state
FROM users u LEFT JOIN last_activity l ON u.user_id=l.user_id
ORDER BY u.user_id;

-- 14. First/latest activity and lifecycle days
SELECT u.user_id,u.user_name,
       MIN(a.activity_date) first_activity,
       MAX(a.activity_date) latest_activity,
       DATEDIFF(MAX(a.activity_date),MIN(a.activity_date)) lifecycle_days
FROM users u JOIN user_activity a ON u.user_id=a.user_id
GROUP BY u.user_id,u.user_name;

-- 15. Cohort revenue per user
SELECT DATE_FORMAT(u.signup_date,'%Y-%m-01') cohort_month,
       COUNT(DISTINCT u.user_id) users,
       ROUND(SUM(a.revenue),2) total_revenue,
       ROUND(SUM(a.revenue)/COUNT(DISTINCT u.user_id),2) revenue_per_user
FROM users u JOIN user_activity a ON u.user_id=a.user_id
GROUP BY cohort_month
ORDER BY cohort_month;

-- PRACTICE
-- 1. Find month-1 retention for every cohort.
-- 2. Find month-2 retention for every cohort.
-- 3. Build a month 0-6 retention matrix.
-- 4. Find each cohort's total revenue.
-- 5. Find users active in signup month but inactive in month 1.
-- 6. Find reactivated users.
-- 7. Calculate revenue per retained user by cohort/month.
-- 8. Find each user's lifetime revenue.
-- 9. Calculate monthly active users.
-- 10. Build a complete cohort report.

-- End of Day 83
