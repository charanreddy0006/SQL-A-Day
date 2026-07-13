-- Day 31 : IS NULL and IS NOT NULL

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    email VARCHAR(100),
    phone VARCHAR(15)
);

INSERT INTO employees VALUES
(101,'John','HR','john@gmail.com','9876543210'),
(102,'David','IT',NULL,'9876543211'),
(103,'Emma','HR','emma@gmail.com',NULL),
(104,'Robert','IT',NULL,NULL),
(105,'Sophia','Finance','sophia@gmail.com','9876543212'),
(106,'James','Finance',NULL,'9876543213');

-- Display all records
SELECT * FROM employees;

--------------------------------------------------
-- Employees whose email is NULL
--------------------------------------------------

SELECT *
FROM employees
WHERE email IS NULL;

--------------------------------------------------
-- Employees whose email is NOT NULL
--------------------------------------------------

SELECT *
FROM employees
WHERE email IS NOT NULL;

--------------------------------------------------
-- Employees whose phone number is NULL
--------------------------------------------------

SELECT *
FROM employees
WHERE phone IS NULL;

--------------------------------------------------
-- Employees whose phone number is NOT NULL
--------------------------------------------------

SELECT *
FROM employees
WHERE phone IS NOT NULL;

--------------------------------------------------
-- Employees whose email AND phone are NULL
--------------------------------------------------

SELECT *
FROM employees
WHERE email IS NULL
AND phone IS NULL;