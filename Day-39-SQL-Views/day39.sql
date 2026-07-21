-- Day 39 : SQL Views

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
    city VARCHAR(30)
);

INSERT INTO employees VALUES
(101,'John','HR',50000,'Delhi'),
(102,'David','IT',70000,'Mumbai'),
(103,'Emma','Finance',55000,'Bangalore'),
(104,'Robert','IT',85000,'Hyderabad'),
(105,'Sophia','Finance',65000,'Chennai'),
(106,'James','HR',45000,'Pune');

--------------------------------------------------
-- Display Table
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Create View
--------------------------------------------------

CREATE VIEW employee_details AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employees;

--------------------------------------------------
-- View Data
--------------------------------------------------

SELECT * FROM employee_details;

--------------------------------------------------
-- Example 2 : View with Condition
--------------------------------------------------

CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    salary
FROM employees
WHERE department = 'IT';

SELECT * FROM it_employees;

--------------------------------------------------
-- Example 3 : Update Through View
--------------------------------------------------

UPDATE employee_details
SET salary = 72000
WHERE emp_id = 102;

SELECT * FROM employees;

--------------------------------------------------
-- Example 4 : Drop View
--------------------------------------------------

DROP VIEW it_employees;