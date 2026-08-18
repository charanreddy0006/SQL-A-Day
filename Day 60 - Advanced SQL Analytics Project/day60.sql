-- Day 60 - Advanced SQL Analytics Project
-- SQL-A-Day

CREATE DATABASE IF NOT EXISTS sql_analytics;

USE sql_analytics;

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
-- 3. BASIC DATA EXPLORATION
-- ============================================

SELECT *
FROM employees;

SELECT
emp_id,
emp_name,
department,
salary
FROM employees;

-- ============================================
-- 4. BASIC AGGREGATE ANALYSIS
-- ============================================

SELECT COUNT(*) AS total_employees
FROM employees;

SELECT AVG(salary) AS average_salary
FROM employees;

SELECT MAX(salary) AS highest_salary
FROM employees;

SELECT MIN(salary) AS lowest_salary
FROM employees;

SELECT SUM(salary) AS total_salary
FROM employees;

-- ============================================
-- 5. DEPARTMENT ANALYSIS
-- ============================================

SELECT
department,
COUNT(*) AS employee_count
FROM employees
GROUP BY department;

SELECT
department,
AVG(salary) AS average_salary
FROM employees
GROUP BY department;

SELECT
department,
MAX(salary) AS highest_salary
FROM employees
GROUP BY department;

SELECT
department,
MIN(salary) AS lowest_salary
FROM employees
GROUP BY department;

SELECT
department,
SUM(salary) AS total_salary
FROM employees
GROUP BY department;

-- ============================================
-- 6. HAVING
-- ============================================

SELECT
department,
AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 70000;

-- ============================================
-- 7. SALARY ANALYSIS
-- ============================================

SELECT
emp_id,
emp_name,
department,
salary
FROM employees
ORDER BY salary DESC;

SELECT *
FROM employees
WHERE salary > (
SELECT AVG(salary)
FROM employees
);

SELECT *
FROM employees
WHERE salary = (
SELECT MAX(salary)
FROM employees
);

SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
SELECT MAX(salary)
FROM employees
);

-- ============================================
-- 8. WINDOW FUNCTIONS - RANK
-- ============================================

SELECT
emp_name,
department,
salary,
RANK() OVER (
ORDER BY salary DESC
) AS salary_rank
FROM employees;

-- ============================================
-- 9. DEPARTMENT-WISE RANKING
-- ============================================

SELECT
emp_name,
department,
salary,
RANK() OVER (
PARTITION BY department
ORDER BY salary DESC
) AS department_rank
FROM employees;

-- ============================================
-- 10. ROW_NUMBER
-- ============================================

SELECT
emp_name,
department,
salary,
ROW_NUMBER() OVER (
ORDER BY salary DESC
) AS row_number
FROM employees;

-- ============================================
-- 11. DENSE_RANK
-- ============================================

SELECT
emp_name,
department,
salary,
DENSE_RANK() OVER (
ORDER BY salary DESC
) AS salary_rank
FROM employees;

-- ============================================
-- 12. TOP THREE EMPLOYEES
-- ============================================

SELECT *
FROM (
SELECT
emp_name,
department,
salary,
RANK() OVER (
ORDER BY salary DESC
) AS salary_rank
FROM employees
) AS ranked_employees
WHERE salary_rank <= 3;

-- ============================================
-- 13. TOP EMPLOYEE FROM EACH DEPARTMENT
-- ============================================

WITH ranked_employees AS (
SELECT
emp_name,
department,
salary,
RANK() OVER (
PARTITION BY department
ORDER BY salary DESC
) AS department_rank
FROM employees
)
SELECT *
FROM ranked_employees
WHERE department_rank = 1;

-- ============================================
-- 14. DEPARTMENT AVERAGE COMPARISON
-- ============================================

SELECT
emp_name,
department,
salary,
AVG(salary) OVER (
PARTITION BY department
) AS department_average,
salary - AVG(salary) OVER (
PARTITION BY department
) AS salary_difference
FROM employees;

-- ============================================
-- 15. LAG
-- ============================================

SELECT
emp_name,
salary,
LAG(salary) OVER (
ORDER BY salary
) AS previous_salary
FROM employees;

-- ============================================
-- 16. LEAD
-- ============================================

SELECT
emp_name,
salary,
LEAD(salary) OVER (
ORDER BY salary
) AS next_salary
FROM employees;

-- ============================================
-- 17. SALARY DIFFERENCE USING LAG
-- ============================================

SELECT
emp_name,
salary,
salary - LAG(salary) OVER (
ORDER BY salary
) AS salary_difference
FROM employees;

-- ============================================
-- 18. DEPARTMENT SUMMARY USING CTE
-- ============================================

WITH department_summary AS (
SELECT
department,
COUNT(*) AS employee_count,
AVG(salary) AS average_salary,
MAX(salary) AS highest_salary,
MIN(salary) AS lowest_salary
FROM employees
GROUP BY department
)
SELECT *
FROM department_summary;

-- ============================================
-- 19. HIGH SALARY EMPLOYEES USING CTE
-- ============================================

WITH salary_data AS (
SELECT
AVG(salary) AS average_salary
FROM employees
)
SELECT
e.emp_name,
e.department,
e.salary
FROM employees e
CROSS JOIN salary_data s
WHERE e.salary > s.average_salary;

-- ============================================
-- 20. EXPERIENCE ANALYSIS
-- ============================================

SELECT
emp_name,
department,
experience,
salary
FROM employees
ORDER BY experience DESC;

SELECT *
FROM employees
WHERE experience >= 5;

-- ============================================
-- 21. CITY ANALYSIS
-- ============================================

SELECT
city,
COUNT(*) AS employee_count
FROM employees
GROUP BY city
ORDER BY employee_count DESC;

SELECT
city,
AVG(salary) AS average_salary
FROM employees
GROUP BY city
ORDER BY average_salary DESC;

-- ============================================
-- 22. SALARY CLASSIFICATION
-- ============================================

SELECT
emp_name,
salary,
CASE
WHEN salary >= 90000 THEN 'High'
WHEN salary >= 70000 THEN 'Medium'
ELSE 'Low'
END AS salary_category
FROM employees;

-- ============================================
-- 23. DEPARTMENT PERFORMANCE
-- ============================================

SELECT
department,
COUNT(*) AS employees,
SUM(salary) AS total_salary,
AVG(salary) AS average_salary,
MAX(salary) AS maximum_salary,
MIN(salary) AS minimum_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC;

-- ============================================
-- 24. BUSINESS QUESTION:
-- DEPARTMENT WITH HIGHEST AVERAGE SALARY
-- ============================================

SELECT
department,
AVG(salary) AS average_salary
FROM employees
GROUP BY department
ORDER BY average_salary DESC
LIMIT 1;

-- ============================================
-- 25. BUSINESS QUESTION:
-- HIGHEST-PAID EMPLOYEE
-- ============================================

SELECT
emp_name,
department,
salary
FROM employees
ORDER BY salary DESC
LIMIT 1;

-- ============================================
-- 26. BUSINESS QUESTION:
-- EMPLOYEES ABOVE COMPANY AVERAGE
-- ============================================

SELECT
emp_name,
department,
salary
FROM employees
WHERE salary > (
SELECT AVG(salary)
FROM employees
);

-- ============================================
-- 27. BUSINESS QUESTION:
-- DEPARTMENT WITH MOST EMPLOYEES
-- ============================================

SELECT
department,
COUNT(*) AS employee_count
FROM employees
GROUP BY department
ORDER BY employee_count DESC
LIMIT 1;

-- ============================================
-- 28. ADVANCED DEPARTMENT ANALYSIS
-- ============================================

WITH department_data AS (
SELECT
department,
COUNT(*) AS employee_count,
AVG(salary) AS average_salary,
SUM(salary) AS total_salary
FROM employees
GROUP BY department
)
SELECT
department,
employee_count,
average_salary,
total_salary,
RANK() OVER (
ORDER BY average_salary DESC
) AS department_salary_rank
FROM department_data;

-- ============================================
-- 29. FINAL EMPLOYEE ANALYTICS REPORT
-- ============================================

SELECT
emp_name,
department,
city,
salary,
experience,
CASE
WHEN salary >= 90000 THEN 'High'
WHEN salary >= 70000 THEN 'Medium'
ELSE 'Low'
END AS salary_category,
RANK() OVER (
PARTITION BY department
ORDER BY salary DESC
) AS department_rank
FROM employees
ORDER BY department, department_rank;

-- ============================================
-- END OF DAY 60
-- ============================================
