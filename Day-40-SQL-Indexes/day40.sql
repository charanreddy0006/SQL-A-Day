-- Day 40 : SQL Indexes

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John','john@gmail.com','HR',50000),
(102,'David','david@gmail.com','IT',70000),
(103,'Emma','emma@gmail.com','Finance',55000),
(104,'Robert','robert@gmail.com','IT',85000),
(105,'Sophia','sophia@gmail.com','Finance',65000),
(106,'James','james@gmail.com','HR',45000);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Create Index
--------------------------------------------------

CREATE INDEX idx_employee_name
ON employees(emp_name);

--------------------------------------------------
-- Search using Indexed Column
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name='David';

--------------------------------------------------
-- Example 2 : Create UNIQUE Index
--------------------------------------------------

CREATE UNIQUE INDEX idx_employee_email
ON employees(email);

--------------------------------------------------
-- Search Using Email
--------------------------------------------------

SELECT *
FROM employees
WHERE email='emma@gmail.com';

--------------------------------------------------
-- Example 3 : Drop Index
--------------------------------------------------

DROP INDEX idx_employee_name
ON employees;

--------------------------------------------------
-- Example 4 : Show Indexes
--------------------------------------------------

SHOW INDEX
FROM employees;