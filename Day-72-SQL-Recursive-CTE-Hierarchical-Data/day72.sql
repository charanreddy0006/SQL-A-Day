-- ================================================================
-- SQL-A-Day - DAY 72
-- Topic: Recursive CTEs & Hierarchical Data
-- Database: sql_recursive_hierarchy_lab
-- SQL Dialect: MySQL 8+
-- ================================================================

DROP DATABASE IF EXISTS sql_recursive_hierarchy_lab;
CREATE DATABASE sql_recursive_hierarchy_lab;
USE sql_recursive_hierarchy_lab;

-- ================================================================
-- 1. EMPLOYEE HIERARCHY
-- ================================================================

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    salary DECIMAL(12,2) NOT NULL,
    joined_date DATE NOT NULL,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    INDEX idx_employees_manager (manager_id),
    INDEX idx_employees_department (department)
) ENGINE=InnoDB;

-- ================================================================
-- 2. INSERT HIERARCHICAL EMPLOYEE DATA
-- ================================================================

INSERT INTO employees
(employee_id, employee_name, job_title, department, manager_id, salary, joined_date)
VALUES
(1, 'Anil Sharma', 'Chief Executive Officer', 'Executive', NULL, 250000, '2018-01-10');

INSERT INTO employees
(employee_id, employee_name, job_title, department, manager_id, salary, joined_date)
VALUES
(2, 'Meera Rao', 'Chief Technology Officer', 'Technology', 1, 180000, '2019-03-15'),
(3, 'Vikram Singh', 'Chief Financial Officer', 'Finance', 1, 175000, '2019-05-20'),
(4, 'Neha Kapoor', 'Chief Operating Officer', 'Operations', 1, 170000, '2020-02-12');

INSERT INTO employees
(employee_id, employee_name, job_title, department, manager_id, salary, joined_date)
VALUES
(5, 'Arjun Reddy', 'Engineering Manager', 'Engineering', 2, 130000, '2020-06-01'),
(6, 'Priya Nair', 'Engineering Manager', 'Engineering', 2, 128000, '2020-08-15'),
(7, 'Rahul Verma', 'Finance Manager', 'Finance', 3, 120000, '2021-01-10'),
(8, 'Sneha Iyer', 'Operations Manager', 'Operations', 4, 115000, '2021-04-20');

INSERT INTO employees
(employee_id, employee_name, job_title, department, manager_id, salary, joined_date)
VALUES
(9, 'Kiran Kumar', 'Senior Software Engineer', 'Engineering', 5, 95000, '2021-07-01'),
(10, 'Divya Patel', 'Software Engineer', 'Engineering', 5, 82000, '2022-01-15'),
(11, 'Rohit Das', 'Software Engineer', 'Engineering', 5, 80000, '2022-03-10'),
(12, 'Asha Menon', 'Senior Software Engineer', 'Engineering', 6, 94000, '2021-09-12'),
(13, 'Varun Gupta', 'Software Engineer', 'Engineering', 6, 81000, '2022-04-18'),
(14, 'Pooja Shah', 'Financial Analyst', 'Finance', 7, 72000, '2022-06-25'),
(15, 'Manoj Rao', 'Operations Analyst', 'Operations', 8, 68000, '2022-08-01');

-- ================================================================
-- 3. BASIC EMPLOYEE DATA
-- ================================================================

SELECT employee_id, employee_name, job_title, department, manager_id
FROM employees
ORDER BY employee_id;

-- ================================================================
-- 4. ROOT EMPLOYEES
-- ================================================================

SELECT employee_id, employee_name, job_title
FROM employees
WHERE manager_id IS NULL;

-- ================================================================
-- 5. DIRECT REPORTS OF EMPLOYEE 2
-- ================================================================

SELECT employee_id, employee_name, job_title, department
FROM employees
WHERE manager_id = 2
ORDER BY employee_id;

-- ================================================================
-- 6. COMPLETE ORGANIZATION TREE
-- ================================================================

WITH RECURSIVE employee_hierarchy AS (
    SELECT
        employee_id,
        employee_name,
        job_title,
        department,
        manager_id,
        0 AS hierarchy_level,
        CAST(employee_name AS CHAR(1000)) AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.department,
        e.manager_id,
        eh.hierarchy_level + 1,
        CONCAT(eh.hierarchy_path, ' -> ', e.employee_name)
    FROM employees AS e
    INNER JOIN employee_hierarchy AS eh
        ON e.manager_id = eh.employee_id
)
SELECT
    employee_id,
    employee_name,
    job_title,
    department,
    manager_id,
    hierarchy_level,
    hierarchy_path
FROM employee_hierarchy
ORDER BY hierarchy_path;

-- ================================================================
-- 7. ORGANIZATION TREE WITH INDENTATION
-- ================================================================

WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, employee_name, job_title, manager_id, 0 AS hierarchy_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.job_title, e.manager_id,
           eh.hierarchy_level + 1
    FROM employees AS e
    INNER JOIN employee_hierarchy AS eh
        ON e.manager_id = eh.employee_id
)
SELECT
    employee_id,
    CONCAT(REPEAT('    ', hierarchy_level), employee_name) AS organization_tree,
    job_title,
    hierarchy_level
FROM employee_hierarchy
ORDER BY employee_id;

-- ================================================================
-- 8. ALL DESCENDANTS OF EMPLOYEE 2
-- ================================================================

WITH RECURSIVE descendants AS (
    SELECT employee_id, employee_name, job_title, manager_id,
           1 AS distance_from_manager
    FROM employees
    WHERE manager_id = 2

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.job_title, e.manager_id,
           d.distance_from_manager + 1
    FROM employees AS e
    INNER JOIN descendants AS d
        ON e.manager_id = d.employee_id
)
SELECT *
FROM descendants
ORDER BY distance_from_manager, employee_id;

-- ================================================================
-- 9. ALL DESCENDANTS OF EMPLOYEE 5
-- ================================================================

WITH RECURSIVE descendants AS (
    SELECT employee_id, employee_name, job_title, manager_id,
           1 AS level_from_manager
    FROM employees
    WHERE manager_id = 5

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.job_title, e.manager_id,
           d.level_from_manager + 1
    FROM employees AS e
    INNER JOIN descendants AS d
        ON e.manager_id = d.employee_id
)
SELECT *
FROM descendants
ORDER BY level_from_manager, employee_id;

-- ================================================================
-- 10. MANAGEMENT CHAIN FOR EMPLOYEE 10
-- ================================================================

WITH RECURSIVE management_chain AS (
    SELECT employee_id, employee_name, job_title, manager_id,
           0 AS distance_from_employee
    FROM employees
    WHERE employee_id = 10

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.job_title, e.manager_id,
           mc.distance_from_employee + 1
    FROM employees AS e
    INNER JOIN management_chain AS mc
        ON e.employee_id = mc.manager_id
)
SELECT *
FROM management_chain
ORDER BY distance_from_employee;

-- ================================================================
-- 11. MANAGEMENT PATH FOR EMPLOYEE 10
-- ================================================================

WITH RECURSIVE management_chain AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        CAST(employee_name AS CHAR(1000)) AS management_path
    FROM employees
    WHERE employee_id = 10

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        CONCAT(mc.management_path, ' <- ', e.employee_name)
    FROM employees AS e
    INNER JOIN management_chain AS mc
        ON e.employee_id = mc.manager_id
)
SELECT *
FROM management_chain
ORDER BY employee_id;

-- ================================================================
-- 12. HIERARCHY LEVEL COUNTS
-- ================================================================

WITH RECURSIVE employee_levels AS (
    SELECT employee_id, employee_name, manager_id, 0 AS hierarchy_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id,
           el.hierarchy_level + 1
    FROM employees AS e
    INNER JOIN employee_levels AS el
        ON e.manager_id = el.employee_id
)
SELECT hierarchy_level, COUNT(*) AS employee_count
FROM employee_levels
GROUP BY hierarchy_level
ORDER BY hierarchy_level;

-- ================================================================
-- 13. EMPLOYEES AT LEVEL 2
-- ================================================================

WITH RECURSIVE employee_levels AS (
    SELECT employee_id, employee_name, manager_id, 0 AS hierarchy_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id,
           el.hierarchy_level + 1
    FROM employees AS e
    INNER JOIN employee_levels AS el
        ON e.manager_id = el.employee_id
)
SELECT employee_id, employee_name, hierarchy_level
FROM employee_levels
WHERE hierarchy_level = 2
ORDER BY employee_id;

-- ================================================================
-- 14. TOTAL DESCENDANTS FOR EACH EMPLOYEE
-- ================================================================

WITH RECURSIVE hierarchy AS (
    SELECT employee_id AS root_employee_id, employee_id
    FROM employees

    UNION ALL

    SELECT h.root_employee_id, e.employee_id
    FROM hierarchy AS h
    INNER JOIN employees AS e
        ON e.manager_id = h.employee_id
)
SELECT
    h.root_employee_id AS employee_id,
    e.employee_name,
    COUNT(h.employee_id) - 1 AS total_descendants
FROM hierarchy AS h
INNER JOIN employees AS e
    ON e.employee_id = h.root_employee_id
GROUP BY h.root_employee_id, e.employee_name
ORDER BY total_descendants DESC, employee_id;

-- ================================================================
-- 15. LEAF EMPLOYEES
-- ================================================================

SELECT
    e.employee_id,
    e.employee_name,
    e.job_title,
    e.department
FROM employees AS e
LEFT JOIN employees AS child
    ON child.manager_id = e.employee_id
WHERE child.employee_id IS NULL
ORDER BY e.employee_id;

-- ================================================================
-- 16. MANAGERS
-- ================================================================

SELECT DISTINCT
    manager.employee_id,
    manager.employee_name,
    manager.job_title
FROM employees AS manager
INNER JOIN employees AS employee
    ON employee.manager_id = manager.employee_id
ORDER BY manager.employee_id;

-- ================================================================
-- 17. DIRECT REPORT COUNT
-- ================================================================

SELECT
    manager.employee_id,
    manager.employee_name,
    COUNT(employee.employee_id) AS direct_report_count
FROM employees AS manager
LEFT JOIN employees AS employee
    ON employee.manager_id = manager.employee_id
GROUP BY manager.employee_id, manager.employee_name
ORDER BY direct_report_count DESC;

-- ================================================================
-- 18. ENGINEERING TREE FROM CTO
-- ================================================================

WITH RECURSIVE engineering_tree AS (
    SELECT employee_id, employee_name, job_title, manager_id,
           department, 0 AS hierarchy_level
    FROM employees
    WHERE employee_id = 2

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.job_title, e.manager_id,
           e.department, et.hierarchy_level + 1
    FROM employees AS e
    INNER JOIN engineering_tree AS et
        ON e.manager_id = et.employee_id
)
SELECT *
FROM engineering_tree
ORDER BY hierarchy_level, employee_id;

-- ================================================================
-- 19. SALARY ANALYSIS BY HIERARCHY LEVEL
-- ================================================================

WITH RECURSIVE employee_levels AS (
    SELECT employee_id, employee_name, salary, manager_id, 0 AS hierarchy_level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.salary, e.manager_id,
           el.hierarchy_level + 1
    FROM employees AS e
    INNER JOIN employee_levels AS el
        ON e.manager_id = el.employee_id
)
SELECT
    hierarchy_level,
    COUNT(*) AS employees,
    SUM(salary) AS total_salary,
    ROUND(AVG(salary), 2) AS average_salary
FROM employee_levels
GROUP BY hierarchy_level
ORDER BY hierarchy_level;

-- ================================================================
-- 20. CATEGORY HIERARCHY
-- ================================================================

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id),
    INDEX idx_categories_parent (parent_category_id)
) ENGINE=InnoDB;

INSERT INTO categories (category_id, category_name, parent_category_id)
VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Laptops', 2),
(4, 'Gaming Laptops', 3),
(5, 'Business Laptops', 3),
(6, 'Desktops', 2),
(7, 'Monitors', 1),
(8, '4K Monitors', 7),
(9, 'Accessories', 1),
(10, 'Keyboards', 9),
(11, 'Mechanical Keyboards', 10),
(12, 'Mice', 9);

-- ================================================================
-- 21. CATEGORY TREE
-- ================================================================

WITH RECURSIVE category_tree AS (
    SELECT
        category_id,
        category_name,
        parent_category_id,
        0 AS category_level,
        CAST(category_name AS CHAR(1000)) AS category_path
    FROM categories
    WHERE parent_category_id IS NULL

    UNION ALL

    SELECT
        c.category_id,
        c.category_name,
        c.parent_category_id,
        ct.category_level + 1,
        CONCAT(ct.category_path, ' -> ', c.category_name)
    FROM categories AS c
    INNER JOIN category_tree AS ct
        ON c.parent_category_id = ct.category_id
)
SELECT *
FROM category_tree
ORDER BY category_path;

-- ================================================================
-- 22. CATEGORY DESCENDANTS OF COMPUTERS
-- ================================================================

WITH RECURSIVE category_descendants AS (
    SELECT category_id, category_name, parent_category_id, 1 AS depth
    FROM categories
    WHERE parent_category_id = 2

    UNION ALL

    SELECT c.category_id, c.category_name, c.parent_category_id,
           cd.depth + 1
    FROM categories AS c
    INNER JOIN category_descendants AS cd
        ON c.parent_category_id = cd.category_id
)
SELECT *
FROM category_descendants
ORDER BY depth, category_id;

-- ================================================================
-- 23. CATEGORY ANCESTORS OF GAMING LAPTOPS
-- ================================================================

WITH RECURSIVE category_ancestors AS (
    SELECT category_id, category_name, parent_category_id, 0 AS distance
    FROM categories
    WHERE category_id = 4

    UNION ALL

    SELECT c.category_id, c.category_name, c.parent_category_id,
           ca.distance + 1
    FROM categories AS c
    INNER JOIN category_ancestors AS ca
        ON c.category_id = ca.parent_category_id
)
SELECT *
FROM category_ancestors
ORDER BY distance;

-- ================================================================
-- 24. CATEGORY LEVEL COUNTS
-- ================================================================

WITH RECURSIVE category_levels AS (
    SELECT category_id, category_name, parent_category_id, 0 AS category_level
    FROM categories
    WHERE parent_category_id IS NULL

    UNION ALL

    SELECT c.category_id, c.category_name, c.parent_category_id,
           cl.category_level + 1
    FROM categories AS c
    INNER JOIN category_levels AS cl
        ON c.parent_category_id = cl.category_id
)
SELECT category_level, COUNT(*) AS category_count
FROM category_levels
GROUP BY category_level
ORDER BY category_level;

-- ================================================================
-- 25. GENERATE NUMBERS WITH RECURSIVE CTE
-- ================================================================

WITH RECURSIVE numbers AS (
    SELECT 1 AS number
    UNION ALL
    SELECT number + 1
    FROM numbers
    WHERE number < 20
)
SELECT number
FROM numbers;

-- ================================================================
-- 26. GENERATE DATES WITH RECURSIVE CTE
-- ================================================================

WITH RECURSIVE dates AS (
    SELECT DATE('2025-01-01') AS calendar_date
    UNION ALL
    SELECT calendar_date + INTERVAL 1 DAY
    FROM dates
    WHERE calendar_date < '2025-01-15'
)
SELECT calendar_date
FROM dates;

-- ================================================================
-- 27. MANAGEMENT PATH FOR MANOJ RAO
-- ================================================================

WITH RECURSIVE management_path AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        CAST(employee_name AS CHAR(1000)) AS path
    FROM employees
    WHERE employee_id = 15

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        CONCAT(e.employee_name, ' -> ', mp.path)
    FROM employees AS e
    INNER JOIN management_path AS mp
        ON e.employee_id = mp.manager_id
)
SELECT *
FROM management_path
ORDER BY employee_id;

-- ================================================================
-- 28. ALL EMPLOYEES UNDER CEO
-- ================================================================

WITH RECURSIVE organization AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE employee_id = 1

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, o.level + 1
    FROM employees AS e
    INNER JOIN organization AS o
        ON e.manager_id = o.employee_id
)
SELECT *
FROM organization
WHERE employee_id <> 1
ORDER BY level, employee_id;

-- ================================================================
-- 29. DEPTH-LIMITED RECURSION
-- ================================================================

WITH RECURSIVE employee_tree AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, et.level + 1
    FROM employees AS e
    INNER JOIN employee_tree AS et
        ON e.manager_id = et.employee_id
    WHERE et.level < 3
)
SELECT *
FROM employee_tree
ORDER BY level, employee_id;

-- ================================================================
-- 30. FINAL HIERARCHY SUMMARY
-- ================================================================

WITH RECURSIVE hierarchy AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.employee_name, e.manager_id, h.level + 1
    FROM employees AS e
    INNER JOIN hierarchy AS h
        ON e.manager_id = h.employee_id
)
SELECT
    MAX(level) AS maximum_hierarchy_depth,
    COUNT(*) AS total_employees
FROM hierarchy;

-- ================================================================
-- END OF DAY 72
-- ================================================================
