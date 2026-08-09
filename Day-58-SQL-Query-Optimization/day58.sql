-- Day 58 : SQL Query Optimization

CREATE DATABASE optimization_db;

USE optimization_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    city VARCHAR(50)
);

--------------------------------------------------
-- Insert Sample Data
--------------------------------------------------

INSERT INTO employees VALUES
(101,'John','HR',50000,'Rajkot'),
(102,'David','IT',70000,'Ahmedabad'),
(103,'Emma','Finance',55000,'Surat'),
(104,'Robert','IT',85000,'Mumbai'),
(105,'Sophia','Finance',65000,'Delhi'),
(106,'James','HR',45000,'Rajkot'),
(107,'Alice','IT',70000,'Pune'),
(108,'Michael','Finance',90000,'Mumbai'),
(109,'Daniel','IT',95000,'Ahmedabad'),
(110,'Olivia','HR',60000,'Surat');

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : EXPLAIN
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;

--------------------------------------------------
-- Example 2 : Create Index
--------------------------------------------------

CREATE INDEX idx_salary
ON employees(salary);

--------------------------------------------------
-- Example 3 : Check Index Usage
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;

--------------------------------------------------
-- Example 4 : Index on Department
--------------------------------------------------

CREATE INDEX idx_department
ON employees(department);

EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';

--------------------------------------------------
-- Example 5 : Composite Index
--------------------------------------------------

CREATE INDEX idx_department_salary
ON employees(department, salary);

EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT'
AND salary > 70000;

--------------------------------------------------
-- Example 6 : ORDER BY
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
ORDER BY salary DESC;

--------------------------------------------------
-- Example 7 : JOIN
--------------------------------------------------

CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(30)
);

INSERT INTO departments VALUES
(1,'HR'),
(2,'IT'),
(3,'Finance');

ALTER TABLE employees
ADD department_id INT;

UPDATE employees
SET department_id =
CASE
    WHEN department = 'HR' THEN 1
    WHEN department = 'IT' THEN 2
    WHEN department = 'Finance' THEN 3
END;

--------------------------------------------------
-- Index Foreign Key Column
--------------------------------------------------

CREATE INDEX idx_department_id
ON employees(department_id);

--------------------------------------------------
-- Explain JOIN
--------------------------------------------------

EXPLAIN
SELECT
e.emp_name,
d.department_name,
e.salary
FROM employees e
JOIN departments d
ON e.department_id = d.department_id;

--------------------------------------------------
-- Example 8 : Select Only Required Columns
--------------------------------------------------

EXPLAIN
SELECT
emp_name,
salary
FROM employees
WHERE department = 'IT';

--------------------------------------------------
-- Example 9 : Avoid SELECT *
--------------------------------------------------

SELECT
emp_name,
salary,
city
FROM employees
WHERE salary > 70000;

--------------------------------------------------
-- View Existing Indexes
--------------------------------------------------

SHOW INDEX FROM employees;