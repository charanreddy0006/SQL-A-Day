-- Day 59 : Advanced SQL Indexing

CREATE DATABASE indexing_db;

USE indexing_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    city VARCHAR(50),
    email VARCHAR(100) UNIQUE
);

--------------------------------------------------
-- Insert Data
--------------------------------------------------

INSERT INTO employees VALUES
(101,'John','HR',50000,'Rajkot','john@gmail.com'),
(102,'David','IT',70000,'Ahmedabad','david@gmail.com'),
(103,'Emma','Finance',55000,'Surat','emma@gmail.com'),
(104,'Robert','IT',85000,'Mumbai','robert@gmail.com'),
(105,'Sophia','Finance',65000,'Delhi','sophia@gmail.com'),
(106,'James','HR',45000,'Rajkot','james@gmail.com'),
(107,'Alice','IT',70000,'Pune','alice@gmail.com'),
(108,'Michael','Finance',90000,'Mumbai','michael@gmail.com'),
(109,'Daniel','IT',95000,'Ahmedabad','daniel@gmail.com'),
(110,'Olivia','HR',60000,'Surat','olivia@gmail.com');

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- 1. Primary Key Index
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE emp_id = 104;

--------------------------------------------------
-- 2. Unique Index
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE email = 'robert@gmail.com';

--------------------------------------------------
-- 3. Single-Column Index
--------------------------------------------------

CREATE INDEX idx_salary
ON employees(salary);

EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;

--------------------------------------------------
-- 4. Department Index
--------------------------------------------------

CREATE INDEX idx_department
ON employees(department);

EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';

--------------------------------------------------
-- 5. Composite Index
--------------------------------------------------

CREATE INDEX idx_department_salary
ON employees(department, salary);

EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT'
AND salary > 70000;

--------------------------------------------------
-- 6. Leftmost Prefix Example
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE department = 'IT';

--------------------------------------------------
-- Composite Index: Second Column Only
--------------------------------------------------

EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;

--------------------------------------------------
-- 7. ORDER BY with Index
--------------------------------------------------

EXPLAIN
SELECT
emp_name,
salary
FROM employees
ORDER BY salary;

--------------------------------------------------
-- 8. Covering Index
--------------------------------------------------

CREATE INDEX idx_department_salary_name
ON employees(department, salary, emp_name);

EXPLAIN
SELECT
department,
salary,
emp_name
FROM employees
WHERE department = 'IT';

--------------------------------------------------
-- 9. View All Indexes
--------------------------------------------------

SHOW INDEX FROM employees;

--------------------------------------------------
-- 10. Drop an Index
--------------------------------------------------

DROP INDEX idx_salary
ON employees;

--------------------------------------------------
-- Verify Indexes
--------------------------------------------------

SHOW INDEX FROM employees;