-- Day 27 : IN Operator

CREATE DATABASE company_db;

USE company_db;

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
(103,'Emma','HR',55000,28),
(104,'Robert','IT',80000,35),
(105,'Sophia','Finance',65000,29),
(106,'James','Finance',60000,24);

-- Display all employees
SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Employees from HR, IT and Finance
--------------------------------------------------

SELECT *
FROM employees
WHERE department IN ('HR','IT','Finance');

--------------------------------------------------
-- Example 2 : Employees with ID 101,103 and 106
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_id IN (101,103,106);

--------------------------------------------------
-- Example 3 : Employees NOT in HR and IT
--------------------------------------------------

SELECT *
FROM employees
WHERE department NOT IN ('HR','IT');

--------------------------------------------------
-- Example 4 : Employees with age 24,28 or 35
--------------------------------------------------

SELECT *
FROM employees
WHERE age IN (24,28,35);

--------------------------------------------------
-- Example 5 : Employees with salary 60000 or 80000
--------------------------------------------------

SELECT *
FROM employees
WHERE salary IN (60000,80000);