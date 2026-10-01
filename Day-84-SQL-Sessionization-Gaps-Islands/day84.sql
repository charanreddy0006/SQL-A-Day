-- Day 84 - SQL Sessionization & Gaps-and-Islands
-- MySQL 8.x

DROP DATABASE IF EXISTS sql_sessionization_lab;
CREATE DATABASE sql_sessionization_lab;
USE sql_sessionization_lab;

CREATE TABLE user_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_time DATETIME NOT NULL,
    event_type VARCHAR(30) NOT NULL,
    page VARCHAR(100)
);

INSERT INTO user_events (user_id,event_time,event_type,page) VALUES
(1,'2026-09-01 09:00:00','page_view','/home'),
(1,'2026-09-01 09:08:00','page_view','/products'),
(1,'2026-09-01 09:17:00','click','/products'),
(1,'2026-09-01 09:29:00','purchase','/checkout'),
(1,'2026-09-01 11:10:00','page_view','/home'),
(1,'2026-09-01 11:22:00','page_view','/products'),
(1,'2026-09-01 11:35:00','logout','/account'),
(2,'2026-09-01 10:00:00','page_view','/home'),
(2,'2026-09-01 10:12:00','click','/search'),
(2,'2026-09-01 10:25:00','page_view','/product/10'),
(2,'2026-09-01 13:00:00','page_view','/home'),
(2,'2026-09-01 13:09:00','click','/products'),
(2,'2026-09-01 15:30:00','page_view','/home'),
(3,'2026-09-01 08:30:00','page_view','/home'),
(3,'2026-09-01 08:45:00','page_view','/blog'),
(3,'2026-09-01 09:05:00','click','/blog'),
(3,'2026-09-01 09:28:00','page_view','/article/1'),
(3,'2026-09-01 09:50:00','page_view','/article/2'),
(3,'2026-09-01 12:00:00','page_view','/home');

SELECT * FROM user_events ORDER BY user_id,event_time,event_id;

-- Previous event and inactivity gap
WITH ordered AS (
    SELECT *,
           LAG(event_time) OVER (
             PARTITION BY user_id ORDER BY event_time,event_id
           ) previous_event_time
    FROM user_events
)
SELECT event_id,user_id,event_time,event_type,previous_event_time,
       CASE WHEN previous_event_time IS NULL THEN NULL
            ELSE TIMESTAMPDIFF(MINUTE,previous_event_time,event_time)
       END gap_minutes
FROM ordered
ORDER BY user_id,event_time,event_id;

-- Mark session boundaries: >30 minutes = new session
WITH ordered AS (
    SELECT *,
           LAG(event_time) OVER (
             PARTITION BY user_id ORDER BY event_time,event_id
           ) previous_event_time
    FROM user_events
)
SELECT event_id,user_id,event_time,event_type,
       CASE WHEN previous_event_time IS NULL THEN 1
            WHEN TIMESTAMPDIFF(MINUTE,previous_event_time,event_time)>30 THEN 1
            ELSE 0 END new_session_flag
FROM ordered
ORDER BY user_id,event_time,event_id;

-- Assign session numbers with a running SUM
CREATE OR REPLACE VIEW sessionized_events AS
WITH ordered AS (
    SELECT *,
           LAG(event_time) OVER (
             PARTITION BY user_id ORDER BY event_time,event_id
           ) previous_event_time
    FROM user_events
),
marked AS (
    SELECT *,
           CASE WHEN previous_event_time IS NULL THEN 1
                WHEN TIMESTAMPDIFF(MINUTE,previous_event_time,event_time)>30 THEN 1
                ELSE 0 END new_session_flag
    FROM ordered
)
SELECT event_id,user_id,event_time,event_type,page,
       SUM(new_session_flag) OVER (
         PARTITION BY user_id
         ORDER BY event_time,event_id
         ROWS UNBOUNDED PRECEDING
       ) session_number
FROM marked;

SELECT * FROM sessionized_events ORDER BY user_id,event_time,event_id;

-- Session summary
SELECT user_id,session_number,
       MIN(event_time) session_start,
       MAX(event_time) session_end,
       TIMESTAMPDIFF(MINUTE,MIN(event_time),MAX(event_time)) duration_minutes,
       COUNT(*) event_count
FROM sessionized_events
GROUP BY user_id,session_number
ORDER BY user_id,session_number;

-- Unique session IDs
SELECT user_id,session_number,
       CONCAT(user_id,'-',session_number) session_id,
       COUNT(*) event_count
FROM sessionized_events
GROUP BY user_id,session_number
ORDER BY user_id,session_number;

-- Overall session metrics
WITH sessions AS (
    SELECT user_id,session_number,
           MIN(event_time) session_start,
           MAX(event_time) session_end,
           TIMESTAMPDIFF(MINUTE,MIN(event_time),MAX(event_time)) duration_minutes,
           COUNT(*) event_count
    FROM sessionized_events
    GROUP BY user_id,session_number
)
SELECT COUNT(*) total_sessions,
       COUNT(DISTINCT user_id) users_with_sessions,
       ROUND(AVG(duration_minutes),2) avg_session_duration_minutes,
       ROUND(AVG(event_count),2) avg_events_per_session
FROM sessions;

-- Sessions containing a purchase
SELECT user_id,session_number,
       MIN(event_time) session_start,
       MAX(event_time) session_end,
       COUNT(*) event_count
FROM sessionized_events
GROUP BY user_id,session_number
HAVING SUM(event_type='purchase')>0
ORDER BY session_start;

-- Session conversion rate
WITH sessions AS (
    SELECT user_id,session_number,
           MAX(event_type='purchase') converted
    FROM sessionized_events
    GROUP BY user_id,session_number
)
SELECT COUNT(*) total_sessions,
       SUM(converted) converted_sessions,
       ROUND(100.0*SUM(converted)/COUNT(*),2) session_conversion_pct
FROM sessions;

-- Entry and exit page
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER(
             PARTITION BY user_id,session_number
             ORDER BY event_time,event_id
           ) first_rank,
           ROW_NUMBER() OVER(
             PARTITION BY user_id,session_number
             ORDER BY event_time DESC,event_id DESC
           ) last_rank
    FROM sessionized_events
)
SELECT user_id,session_number,
       MAX(CASE WHEN first_rank=1 THEN page END) entry_page,
       MAX(CASE WHEN last_rank=1 THEN page END) exit_page
FROM ranked
GROUP BY user_id,session_number
ORDER BY user_id,session_number;

-- Event types per session
SELECT user_id,session_number,
       SUM(event_type='page_view') page_views,
       SUM(event_type='click') clicks,
       SUM(event_type='purchase') purchases,
       SUM(event_type='logout') logouts
FROM sessionized_events
GROUP BY user_id,session_number
ORDER BY user_id,session_number;

-- Longest session for every user
WITH sessions AS (
    SELECT user_id,session_number,
           MIN(event_time) session_start,
           MAX(event_time) session_end,
           TIMESTAMPDIFF(MINUTE,MIN(event_time),MAX(event_time)) duration_minutes
    FROM sessionized_events
    GROUP BY user_id,session_number
),
ranked AS (
    SELECT *,ROW_NUMBER() OVER(
        PARTITION BY user_id ORDER BY duration_minutes DESC,session_start
    ) rn
    FROM sessions
)
SELECT user_id,session_number,session_start,session_end,duration_minutes
FROM ranked WHERE rn=1 ORDER BY user_id;

-- Sessions per user
SELECT user_id,COUNT(DISTINCT session_number) total_sessions
FROM sessionized_events
GROUP BY user_id
ORDER BY total_sessions DESC,user_id;

-- Gaps-and-islands: consecutive activity dates
WITH ordered AS (
    SELECT event_id,user_id,event_time,DATE(event_time) event_date,
           LAG(DATE(event_time)) OVER(
             PARTITION BY user_id ORDER BY event_time,event_id
           ) previous_date
    FROM user_events
),
marked AS (
    SELECT *,
           CASE WHEN previous_date IS NULL THEN 1
                WHEN DATEDIFF(event_date,previous_date)>1 THEN 1
                ELSE 0 END new_island
    FROM ordered
),
numbered AS (
    SELECT *,
           SUM(new_island) OVER(
             PARTITION BY user_id ORDER BY event_time,event_id
           ) island_id
    FROM marked
)
SELECT user_id,island_id,
       MIN(event_date) island_start,
       MAX(event_date) island_end,
       COUNT(*) events
FROM numbered
GROUP BY user_id,island_id
ORDER BY user_id,island_id;

-- Practice:
-- 1. Change timeout from 30 to 20 minutes.
-- 2. Find average events/session for each user.
-- 3. Find the longest session overall.
-- 4. Find users with at least 2 sessions.
-- 5. Find sessions containing both click and purchase.
-- 6. Calculate conversion rate per user.
-- 7. Find longest inactivity gap per user.
-- 8. Find users active on at least 3 consecutive days.
-- 9. Build a daily report: date, users, sessions, events, purchases.
-- 10. Build a reusable session fact table.

-- End of Day 84
