-- Day 36 : Subqueries

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    age INT
);

INSERT INTO employees VALUES
(101,'John','HR',50000,25),
(102,'David','IT',70000,30),
(103,'Emma','Finance',55000,28),
(104,'Robert','IT',85000,35),
(105,'Sophia','Finance',65000,29),
(106,'James','HR',45000,24);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Salary Greater Than Average Salary
--------------------------------------------------

SELECT emp_name, salary
FROM employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM employees
);

--------------------------------------------------
-- Example 2 : Employees in IT Department
--------------------------------------------------

SELECT emp_name, department
FROM employees
WHERE department =
(
    SELECT department
    FROM employees
    WHERE emp_name = 'David'
);

--------------------------------------------------
-- Example 3 : Employees with Maximum Salary
--------------------------------------------------

SELECT emp_name, salary
FROM employees
WHERE salary =
(
    SELECT MAX(salary)
    FROM employees
);

--------------------------------------------------
-- Example 4 : Subquery in FROM
--------------------------------------------------

SELECT AVG(salary) AS Average_Salary
FROM
(
    SELECT salary
    FROM employees
    WHERE department = 'IT'
) AS IT_Salaries;

--------------------------------------------------
-- Example 5 : Multi-row Subquery
--------------------------------------------------

SELECT emp_name, department
FROM employees
WHERE department IN
(
    SELECT department
    FROM employees
    WHERE salary > 60000
);