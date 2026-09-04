-- ============================================================
-- DAY 78: SQL RECURSIVE CTEs & HIERARCHICAL DATA
-- Database: MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS sql_recursive_cte_lab;
CREATE DATABASE sql_recursive_cte_lab;
USE sql_recursive_cte_lab;

-- ============================================================
-- 1. EMPLOYEE HIERARCHY
-- ============================================================

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    salary DECIMAL(12,2) NOT NULL,
    department VARCHAR(100) NOT NULL,
    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

INSERT INTO employees
(employee_id, employee_name, job_title, manager_id, salary, department)
VALUES
(1,  'Anil',    'CEO',                    NULL, 180000, 'Executive'),
(2,  'Bhavya',  'CTO',                    1,    140000, 'Technology'),
(3,  'Charan',  'Engineering Manager',    2,    105000, 'Technology'),
(4,  'Divya',   'Data Engineering Lead',  3,     95000, 'Data'),
(5,  'Eshan',   'Data Engineer',          4,     70000, 'Data'),
(6,  'Farah',   'Data Engineer',          4,     72000, 'Data'),
(7,  'Gautham', 'Software Engineer',      3,     76000, 'Engineering'),
(8,  'Harini',  'Software Engineer',      3,     78000, 'Engineering'),
(9,  'Ishaan',  'Senior Developer',       2,     98000, 'Technology'),
(10, 'Jahnavi', 'Developer',              9,     68000, 'Engineering'),
(11, 'Kiran',   'Developer',              9,     66000, 'Engineering'),
(12, 'Lavanya', 'QA Lead',                2,     90000, 'Quality'),
(13, 'Manoj',   'QA Engineer',            12,     65000, 'Quality'),
(14, 'Nandini', 'QA Engineer',            12,     64000, 'Quality');

-- Basic hierarchy
SELECT *
FROM employees
ORDER BY employee_id;

-- ============================================================
-- 2. BASIC RECURSIVE CTE: BUILD THE ORGANIZATION TREE
-- ============================================================

WITH RECURSIVE employee_tree AS (
    -- Anchor query: start from the root employee
    SELECT
        employee_id,
        employee_name,
        job_title,
        manager_id,
        salary,
        department,
        0 AS depth,
        CAST(employee_name AS CHAR(1000)) AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive query: find employees reporting to each employee
    SELECT
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.manager_id,
        e.salary,
        e.department,
        et.depth + 1,
        CONCAT(et.hierarchy_path, ' -> ', e.employee_name)
    FROM employees e
    INNER JOIN employee_tree et
        ON e.manager_id = et.employee_id
)
SELECT
    employee_id,
    employee_name,
    job_title,
    manager_id,
    department,
    salary,
    depth,
    hierarchy_path
FROM employee_tree
ORDER BY hierarchy_path;

-- ============================================================
-- 3. DISPLAY THE TREE WITH INDENTATION
-- ============================================================

WITH RECURSIVE employee_tree AS (
    SELECT
        employee_id,
        employee_name,
        job_title,
        manager_id,
        0 AS depth
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.manager_id,
        et.depth + 1
    FROM employees e
    JOIN employee_tree et
        ON e.manager_id = et.employee_id
)
SELECT
    employee_id,
    CONCAT(REPEAT('    ', depth), employee_name) AS employee_tree,
    job_title,
    depth
FROM employee_tree
ORDER BY depth, employee_id;

-- ============================================================
-- 4. FIND ALL DESCENDANTS OF A PARTICULAR EMPLOYEE
-- Example: employee 2 (Bhavya)
-- ============================================================

WITH RECURSIVE descendants AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS relative_depth
    FROM employees
    WHERE employee_id = 2

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        d.relative_depth + 1
    FROM employees e
    JOIN descendants d
        ON e.manager_id = d.employee_id
)
SELECT *
FROM descendants
WHERE employee_id <> 2
ORDER BY relative_depth, employee_id;

-- ============================================================
-- 5. FIND ALL DESCENDANTS UP TO A DEPTH
-- Example: only 2 levels below employee 2
-- ============================================================

WITH RECURSIVE descendants AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS relative_depth
    FROM employees
    WHERE employee_id = 2

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        d.relative_depth + 1
    FROM employees e
    JOIN descendants d
        ON e.manager_id = d.employee_id
    WHERE d.relative_depth < 2
)
SELECT *
FROM descendants
WHERE employee_id <> 2
ORDER BY relative_depth, employee_id;

-- ============================================================
-- 6. FIND THE MANAGEMENT CHAIN FOR AN EMPLOYEE
-- Example: employee 5 (Eshan)
-- ============================================================

WITH RECURSIVE management_chain AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        job_title,
        0 AS level_from_employee
    FROM employees
    WHERE employee_id = 5

    UNION ALL

    SELECT
        m.employee_id,
        m.employee_name,
        m.manager_id,
        m.job_title,
        mc.level_from_employee + 1
    FROM employees m
    JOIN management_chain mc
        ON mc.manager_id = m.employee_id
)
SELECT *
FROM management_chain
ORDER BY level_from_employee;

-- ============================================================
-- 7. BUILD A BREADCRUMB / FULL MANAGEMENT PATH
-- ============================================================

WITH RECURSIVE management_chain AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        CAST(employee_name AS CHAR(1000)) AS management_path
    FROM employees
    WHERE employee_id = 5

    UNION ALL

    SELECT
        m.employee_id,
        m.employee_name,
        m.manager_id,
        CONCAT(m.employee_name, ' -> ', mc.management_path)
    FROM employees m
    JOIN management_chain mc
        ON mc.manager_id = m.employee_id
)
SELECT management_path
FROM management_chain
ORDER BY CHAR_LENGTH(management_path) DESC
LIMIT 1;

-- ============================================================
-- 8. CALCULATE SUBORDINATE COUNTS FOR EACH MANAGER
-- ============================================================

WITH RECURSIVE hierarchy AS (
    SELECT
        employee_id AS root_manager_id,
        employee_id,
        manager_id
    FROM employees

    UNION ALL

    SELECT
        h.root_manager_id,
        e.employee_id,
        e.manager_id
    FROM hierarchy h
    JOIN employees e
        ON e.manager_id = h.employee_id
)
SELECT
    root.employee_id,
    root.employee_name,
    COUNT(h.employee_id) - 1 AS total_subordinates
FROM hierarchy h
JOIN employees root
    ON root.employee_id = h.root_manager_id
GROUP BY root.employee_id, root.employee_name
ORDER BY total_subordinates DESC, root.employee_id;

-- ============================================================
-- 9. CALCULATE TOTAL SALARY UNDER EACH MANAGER
-- Includes the manager's own salary.
-- ============================================================

WITH RECURSIVE hierarchy AS (
    SELECT
        employee_id AS root_employee_id,
        employee_id,
        salary
    FROM employees

    UNION ALL

    SELECT
        h.root_employee_id,
        e.employee_id,
        e.salary
    FROM hierarchy h
    JOIN employees e
        ON e.manager_id = h.employee_id
)
SELECT
    root.employee_id,
    root.employee_name,
    root.salary AS own_salary,
    SUM(h.salary) AS hierarchy_salary
FROM hierarchy h
JOIN employees root
    ON root.employee_id = h.root_employee_id
GROUP BY root.employee_id, root.employee_name, root.salary
ORDER BY hierarchy_salary DESC;

-- ============================================================
-- 10. FIND LEAF EMPLOYEES
-- Employees who do not manage anyone.
-- ============================================================

SELECT
    e.employee_id,
    e.employee_name,
    e.job_title
FROM employees e
LEFT JOIN employees child
    ON child.manager_id = e.employee_id
WHERE child.employee_id IS NULL
ORDER BY e.employee_id;

-- ============================================================
-- 11. CATEGORY HIERARCHY
-- Recursive CTEs are useful beyond employee structures.
-- ============================================================

DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);

INSERT INTO categories
(category_id, category_name, parent_category_id)
VALUES
(1,  'Electronics',       NULL),
(2,  'Computers',          1),
(3,  'Laptops',            2),
(4,  'Gaming Laptops',     3),
(5,  'Business Laptops',   3),
(6,  'Desktops',           2),
(7,  'Accessories',        1),
(8,  'Keyboards',          7),
(9,  'Mice',               7),
(10, 'Mobile Phones',      NULL),
(11, 'Android Phones',     10),
(12, 'iOS Phones',         10);

WITH RECURSIVE category_tree AS (
    SELECT
        category_id,
        category_name,
        parent_category_id,
        0 AS depth,
        CAST(category_name AS CHAR(1000)) AS category_path
    FROM categories
    WHERE parent_category_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.depth + 1,
        CONCAT(ct.category_path, ' / ', c.category_name)
    FROM categories c
    JOIN category_tree ct
        ON c.parent_category_id = ct.category_id
)
SELECT
    category_id,
    category_name,
    depth,
    category_path
FROM category_tree
ORDER BY category_path;

-- ============================================================
-- 12. FIND ALL CATEGORIES UNDER "Computers"
-- ============================================================

WITH RECURSIVE category_subtree AS (
    SELECT
        category_id,
        category_name,
        parent_category_id,
        0 AS depth
    FROM categories
    WHERE category_id = 2

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        c.parent_category_id,
        cs.depth + 1
    FROM categories c
    JOIN category_subtree cs
        ON c.parent_category_id = cs.category_id
)
SELECT *
FROM category_subtree
WHERE category_id <> 2
ORDER BY depth, category_id;

-- ============================================================
-- 13. RECURSIVE CTE FOR DATE GENERATION
-- Useful in reporting and calendar-style data processing.
-- ============================================================

WITH RECURSIVE calendar AS (
    SELECT DATE('2026-09-01') AS calendar_date

    UNION ALL

    SELECT calendar_date + INTERVAL 1 DAY
    FROM calendar
    WHERE calendar_date < DATE('2026-09-10')
)
SELECT
    calendar_date,
    DAYNAME(calendar_date) AS day_name,
    DAYOFWEEK(calendar_date) AS day_number
FROM calendar;

-- ============================================================
-- 14. GENERATE A NUMBER SERIES
-- ============================================================

WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 20
)
SELECT n
FROM numbers;

-- ============================================================
-- 15. RECURSIVE CTE + AGGREGATION
-- Number of employees and salary under each department leader.
-- ============================================================

WITH RECURSIVE employee_tree AS (
    SELECT
        employee_id AS root_id,
        employee_id,
        department,
        salary
    FROM employees

    UNION ALL

    SELECT
        et.root_id,
        e.employee_id,
        e.department,
        e.salary
    FROM employee_tree et
    JOIN employees e
        ON e.manager_id = et.employee_id
)
SELECT
    root.employee_name AS manager,
    root.job_title,
    COUNT(et.employee_id) - 1 AS people_below,
    SUM(et.salary) AS total_team_salary
FROM employee_tree et
JOIN employees root
    ON root.employee_id = et.root_id
GROUP BY root.employee_id, root.employee_name, root.job_title
HAVING COUNT(et.employee_id) > 1
ORDER BY total_team_salary DESC;

-- ============================================================
-- 16. PRACTICE QUERIES
-- Try these without looking at the solutions.
-- ============================================================

-- Q1. Display the complete employee hierarchy with depth and path.

-- Q2. Find every employee working below the CTO.

-- Q3. Find the management chain for employee 10.

-- Q4. Find the employee with the largest number of subordinates.

-- Q5. Find all leaf employees.

-- Q6. Display every category and its complete category path.

-- Q7. Find all categories below Electronics.

-- Q8. Generate dates from 2026-09-01 through 2026-09-30.

-- Q9. Generate numbers from 1 through 100.

-- Q10. Calculate the total salary represented by each employee's entire hierarchy.

-- ============================================================
-- 17. IMPORTANT NOTES
-- ============================================================

-- MySQL recursive CTEs require MySQL 8.0+.

-- The general structure is:
--
-- WITH RECURSIVE cte_name AS (
--     anchor_query
--     UNION ALL
--     recursive_query
-- )
-- SELECT *
-- FROM cte_name;

-- Always make sure the recursive query eventually stops.
-- A bad recursive condition can create an extremely large result
-- or hit MySQL's recursion limit.

-- Hierarchical tables should normally prevent cycles such as:
-- Employee A -> B -> C -> A
-- using application validation and database design constraints.

-- ============================================================
-- END OF DAY 78
-- ============================================================
