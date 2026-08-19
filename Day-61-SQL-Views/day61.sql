-- Day 61 - SQL Views
-- SQL-A-Day

CREATE DATABASE IF NOT EXISTS sql_views;

USE sql_views;

-- ============================================
-- 1. CREATE EMPLOYEES TABLE
-- ============================================

DROP TABLE IF EXISTS employees;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    department VARCHAR(30) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    city VARCHAR(50),
    experience INT,
    joining_year INT
);

-- ============================================
-- 2. INSERT SAMPLE DATA
-- ============================================

INSERT INTO employees
(emp_id, emp_name, department, salary, city, experience, joining_year)
VALUES
(101, 'John', 'IT', 70000, 'Ahmedabad', 3, 2023),
(102, 'David', 'IT', 85000, 'Mumbai', 5, 2021),
(103, 'Emma', 'HR', 55000, 'Surat', 2, 2024),
(104, 'Robert', 'Finance', 90000, 'Mumbai', 6, 2020),
(105, 'Sophia', 'Finance', 75000, 'Delhi', 4, 2022),
(106, 'James', 'HR', 60000, 'Rajkot', 3, 2023),
(107, 'Alice', 'IT', 95000, 'Pune', 7, 2019),
(108, 'Michael', 'Finance', 80000, 'Mumbai', 5, 2021),
(109, 'Daniel', 'IT', 65000, 'Ahmedabad', 2, 2024),
(110, 'Olivia', 'HR', 70000, 'Surat', 4, 2022);

-- ============================================
-- 3. VIEW ALL EMPLOYEES
-- ============================================

SELECT *
FROM employees;

-- ============================================
-- 4. CREATE A SIMPLE VIEW
-- ============================================

CREATE VIEW employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees;

-- ============================================
-- 5. DISPLAY VIEW
-- ============================================

SELECT *
FROM employee_view;

-- ============================================
-- 6. VIEW SELECTED COLUMNS
-- ============================================

CREATE VIEW employee_basic_view AS
SELECT
    emp_id,
    emp_name,
    department,
    city
FROM employees;

SELECT *
FROM employee_basic_view;

-- ============================================
-- 7. VIEW WITH WHERE CONDITION
-- ============================================

CREATE VIEW it_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary,
    experience
FROM employees
WHERE department = 'IT';

SELECT *
FROM it_employee_view;

-- ============================================
-- 8. HIGH SALARY EMPLOYEE VIEW
-- ============================================

CREATE VIEW high_salary_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees
WHERE salary >= 80000;

SELECT *
FROM high_salary_view;

-- ============================================
-- 9. VIEW WITH ORDER BY
-- ============================================

CREATE VIEW salary_view AS
SELECT
    emp_name,
    department,
    salary
FROM employees
ORDER BY salary DESC;

SELECT *
FROM salary_view;

-- ============================================
-- 10. DEPARTMENT SUMMARY VIEW
-- ============================================

CREATE VIEW department_summary_view AS
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    MAX(salary) AS highest_salary,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY department;

SELECT *
FROM department_summary_view;

-- ============================================
-- 11. CITY SUMMARY VIEW
-- ============================================

CREATE VIEW city_summary_view AS
SELECT
    city,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM employees
GROUP BY city;

SELECT *
FROM city_summary_view;

-- ============================================
-- 12. VIEW WITH CASE
-- ============================================

CREATE VIEW salary_category_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    CASE
        WHEN salary >= 90000 THEN 'High'
        WHEN salary >= 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;

SELECT *
FROM salary_category_view;

-- ============================================
-- 13. VIEW WITH EXPERIENCE
-- ============================================

CREATE VIEW experienced_employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    experience,
    salary
FROM employees
WHERE experience >= 5;

SELECT *
FROM experienced_employee_view;

-- ============================================
-- 14. VIEW WITH CALCULATED COLUMN
-- ============================================

CREATE VIEW employee_analysis_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    experience,
    salary / 12 AS monthly_salary
FROM employees;

SELECT *
FROM employee_analysis_view;

-- ============================================
-- 15. QUERYING A VIEW WITH WHERE
-- ============================================

SELECT *
FROM employee_view
WHERE department = 'IT';

-- ============================================
-- 16. QUERYING A VIEW WITH ORDER BY
-- ============================================

SELECT *
FROM employee_view
ORDER BY salary DESC;

-- ============================================
-- 17. QUERYING A VIEW WITH AGGREGATE FUNCTION
-- ============================================

SELECT
    AVG(salary) AS average_salary
FROM employee_view;

-- ============================================
-- 18. QUERYING A VIEW WITH GROUP BY
-- ============================================

SELECT
    department,
    COUNT(*) AS employee_count
FROM employee_view
GROUP BY department;

-- ============================================
-- 19. UPDATE DATA THROUGH A SIMPLE VIEW
-- ============================================

UPDATE employee_view
SET salary = 72000
WHERE emp_id = 101;

SELECT *
FROM employee_view
WHERE emp_id = 101;

-- ============================================
-- 20. CREATE OR REPLACE VIEW
-- ============================================

CREATE OR REPLACE VIEW employee_view AS
SELECT
    emp_id,
    emp_name,
    department,
    salary,
    city
FROM employees;

SELECT *
FROM employee_view;

-- ============================================
-- 21. ALTER VIEW
-- ============================================

ALTER VIEW employee_basic_view AS
SELECT
    emp_id,
    emp_name,
    department,
    city,
    salary
FROM employees;

SELECT *
FROM employee_basic_view;

-- ============================================
-- 22. SHOW VIEWS
-- ============================================

SHOW FULL TABLES
WHERE TABLE_TYPE = 'VIEW';

-- ============================================
-- 23. SHOW CREATE VIEW
-- ============================================

SHOW CREATE VIEW employee_view;

-- ============================================
-- 24. DROP A VIEW
-- ============================================

CREATE VIEW temporary_employee_view AS
SELECT *
FROM employees;

SELECT *
FROM temporary_employee_view;

DROP VIEW temporary_employee_view;

-- ============================================
-- 25. DROP MULTIPLE VIEWS
-- ============================================

DROP VIEW IF EXISTS
    employee_analysis_view,
    experienced_employee_view,
    salary_category_view;

-- ============================================
-- 26. FINAL DEPARTMENT REPORT
-- ============================================

SELECT *
FROM department_summary_view
ORDER BY average_salary DESC;

-- ============================================
-- 27. FINAL HIGH SALARY REPORT
-- ============================================

SELECT
    emp_name,
    department,
    salary
FROM high_salary_view
ORDER BY salary DESC;

-- ============================================
-- 28. FINAL EMPLOYEE REPORT
-- ============================================

SELECT
    emp_id,
    emp_name,
    department,
    salary,
    city
FROM employee_view
ORDER BY department, salary DESC;

-- ============================================
-- END OF DAY 61
-- ============================================