-- Day 11 : UPDATE Statement

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
(103,'Emma',55000);

-- Display records before update
SELECT * FROM employees;

-- Update salary of employee 101
UPDATE employees
SET salary = 65000
WHERE emp_id = 101;

-- Display records after update
SELECT * FROM employees;

-- Update employee name
UPDATE employees
SET emp_name = 'Michael'
WHERE emp_id = 102;

SELECT * FROM employees;