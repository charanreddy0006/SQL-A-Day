-- Day 52 : Window Functions

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
-- Example 1 : ROW_NUMBER()
--------------------------------------------------

SELECT
emp_name,
department,
salary,
ROW_NUMBER() OVER(ORDER BY salary DESC) AS Row_Num
FROM employees;

--------------------------------------------------
-- Example 2 : RANK()
--------------------------------------------------

SELECT
emp_name,
salary,
RANK() OVER(ORDER BY salary DESC) AS Salary_Rank
FROM employees;

--------------------------------------------------
-- Example 3 : DENSE_RANK()
--------------------------------------------------

SELECT
emp_name,
salary,
DENSE_RANK() OVER(ORDER BY salary DESC) AS Dense_Rank
FROM employees;

--------------------------------------------------
-- Example 4 : PARTITION BY
--------------------------------------------------

SELECT
emp_name,
department,
salary,
ROW_NUMBER() OVER(
PARTITION BY department
ORDER BY salary DESC
) AS Dept_Rank
FROM employees;

--------------------------------------------------
-- Example 5 : Running Total
--------------------------------------------------

SELECT
emp_name,
salary,
SUM(salary) OVER(
ORDER BY emp_id
) AS Running_Total
FROM employees;