-- Day 12 : DELETE Statement

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2)
);

INSERT INTO employees
VALUES
(101,'John',50000),
(102,'David',60000),
(103,'Emma',55000),
(104,'Robert',70000);

-- Display records
SELECT * FROM employees;

-- Delete employee with ID 102
DELETE FROM employees
WHERE emp_id = 102;

-- Display records after deletion
SELECT * FROM employees;

-- Delete employee named Emma
DELETE FROM employees
WHERE emp_name = 'Emma';

-- Display final records
SELECT * FROM employees;