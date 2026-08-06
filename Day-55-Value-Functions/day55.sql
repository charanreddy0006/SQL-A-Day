-- Day 55 : FIRST_VALUE(), LAST_VALUE(), NTH_VALUE()

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
(102,'James','HR',45000),
(103,'David','IT',70000),
(104,'Robert','IT',85000),
(105,'Alice','IT',70000),
(106,'Emma','Finance',55000),
(107,'Sophia','Finance',65000);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : FIRST_VALUE()
--------------------------------------------------

SELECT
emp_name,
department,
salary,
FIRST_VALUE(salary)
OVER(
PARTITION BY department
ORDER BY salary DESC
) AS Highest_Department_Salary
FROM employees;

--------------------------------------------------
-- Example 2 : LAST_VALUE()
--------------------------------------------------

SELECT
emp_name,
department,
salary,
LAST_VALUE(salary)
OVER(
PARTITION BY department
ORDER BY salary DESC
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS Lowest_Department_Salary
FROM employees;

--------------------------------------------------
-- Example 3 : NTH_VALUE()
--------------------------------------------------

SELECT
emp_name,
department,
salary,
NTH_VALUE(salary,2)
OVER(
PARTITION BY department
ORDER BY salary DESC
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS Second_Highest_Salary
FROM employees;

--------------------------------------------------
-- Example 4 : Company Highest Salary
--------------------------------------------------

SELECT
emp_name,
salary,
FIRST_VALUE(salary)
OVER(
ORDER BY salary DESC
) AS Company_Highest
FROM employees;

--------------------------------------------------
-- Example 5 : Company Lowest Salary
--------------------------------------------------

SELECT
emp_name,
salary,
LAST_VALUE(salary)
OVER(
ORDER BY salary
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
) AS Company_Lowest
FROM employees;