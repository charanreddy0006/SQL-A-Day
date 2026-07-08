-- Day 26 : NOT Operator

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

----------------------------------------------------
-- Example 1 : Employees NOT in HR Department
----------------------------------------------------

SELECT *
FROM employees
WHERE NOT department = 'HR';

----------------------------------------------------
-- Example 2 : Employees NOT older than 30
----------------------------------------------------

SELECT *
FROM employees
WHERE NOT age > 30;

----------------------------------------------------
-- Example 3 : Employees NOT in Finance
----------------------------------------------------

SELECT *
FROM employees
WHERE NOT department = 'Finance';

----------------------------------------------------
-- Example 4 : NOT with AND
----------------------------------------------------

SELECT *
FROM employees
WHERE NOT (department = 'IT' AND salary > 70000);

----------------------------------------------------
-- Example 5 : Using !=
----------------------------------------------------

SELECT *
FROM employees
WHERE department != 'HR';

----------------------------------------------------
-- Example 6 : Using <>
----------------------------------------------------

SELECT *
FROM employees
WHERE department <> 'HR';