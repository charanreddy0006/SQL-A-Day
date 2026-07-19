-- Day 37 : Correlated Subqueries

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
(103,'Emma','HR',60000),
(104,'Robert','IT',85000),
(105,'Sophia','Finance',65000),
(106,'James','Finance',55000);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Employees earning above
-- department average salary
--------------------------------------------------

SELECT e1.emp_name,
       e1.department,
       e1.salary
FROM employees e1
WHERE salary >
(
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e1.department = e2.department
);

--------------------------------------------------
-- Example 2 : Highest Paid Employee
-- in Each Department
--------------------------------------------------

SELECT e1.*
FROM employees e1
WHERE salary =
(
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e1.department = e2.department
);

--------------------------------------------------
-- Example 3 : EXISTS
--------------------------------------------------

SELECT DISTINCT e1.department
FROM employees e1
WHERE EXISTS
(
    SELECT *
    FROM employees e2
    WHERE e1.department = e2.department
      AND salary > 80000
);

--------------------------------------------------
-- Example 4 : NOT EXISTS
--------------------------------------------------

SELECT DISTINCT e1.department
FROM employees e1
WHERE NOT EXISTS
(
    SELECT *
    FROM employees e2
    WHERE e1.department = e2.department
      AND salary > 90000
);