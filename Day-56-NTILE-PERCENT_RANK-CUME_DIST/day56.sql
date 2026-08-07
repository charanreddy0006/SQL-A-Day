-- Day 56 : NTILE(), PERCENT_RANK(), CUME_DIST()

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John','HR',50000),
(102,'David','IT',70000),
(103,'Emma','Finance',55000),
(104,'Robert','IT',85000),
(105,'Sophia','Finance',65000),
(106,'James','HR',45000),
(107,'Alice','IT',70000),
(108,'Michael','Finance',90000);

--------------------------------------------------
-- Display Employees
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : NTILE()
--------------------------------------------------

SELECT
emp_name,
salary,
NTILE(4) OVER(
ORDER BY salary DESC
) AS Salary_Quartile
FROM employees;

--------------------------------------------------
-- Example 2 : PERCENT_RANK()
--------------------------------------------------

SELECT
emp_name,
salary,
PERCENT_RANK() OVER(
ORDER BY salary
) AS Percent_Rank
FROM employees;

--------------------------------------------------
-- Example 3 : CUME_DIST()
--------------------------------------------------

SELECT
emp_name,
salary,
CUME_DIST() OVER(
ORDER BY salary
) AS Cumulative_Distribution
FROM employees;

--------------------------------------------------
-- Example 4 : Department-wise Quartiles
--------------------------------------------------

SELECT
emp_name,
department,
salary,
NTILE(2) OVER(
PARTITION BY department
ORDER BY salary DESC
) AS Department_Group
FROM employees;

--------------------------------------------------
-- Example 5 : Top Salary Analysis
--------------------------------------------------

SELECT
emp_name,
salary,
PERCENT_RANK() OVER(
ORDER BY salary DESC
) AS Salary_Percentile
FROM employees;