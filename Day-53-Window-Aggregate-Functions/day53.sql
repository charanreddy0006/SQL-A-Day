-- Day 53 : Window Aggregate Functions

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
(107,'Alice','IT',70000);

--------------------------------------------------
-- Display Employees
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : SUM() OVER()
--------------------------------------------------

SELECT
emp_name,
salary,
SUM(salary) OVER() AS Total_Salary
FROM employees;

--------------------------------------------------
-- Example 2 : AVG() OVER()
--------------------------------------------------

SELECT
emp_name,
salary,
AVG(salary) OVER() AS Average_Salary
FROM employees;

--------------------------------------------------
-- Example 3 : COUNT() OVER()
--------------------------------------------------

SELECT
emp_name,
COUNT(*) OVER() AS Total_Employees
FROM employees;

--------------------------------------------------
-- Example 4 : Department Average Salary
--------------------------------------------------

SELECT
emp_name,
department,
salary,
AVG(salary) OVER(
PARTITION BY department
) AS Department_Average
FROM employees;

--------------------------------------------------
-- Example 5 : Running Total
--------------------------------------------------

SELECT
emp_id,
emp_name,
salary,
SUM(salary) OVER(
ORDER BY emp_id
) AS Running_Total
FROM employees;

--------------------------------------------------
-- Example 6 : MIN() and MAX()
--------------------------------------------------

SELECT
emp_name,
salary,
MIN(salary) OVER() AS Minimum_Salary,
MAX(salary) OVER() AS Maximum_Salary
FROM employees;

--------------------------------------------------
-- Example 7 : Moving Average
--------------------------------------------------

SELECT
emp_id,
emp_name,
salary,
AVG(salary) OVER(
ORDER BY emp_id
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS Moving_Average
FROM employees;