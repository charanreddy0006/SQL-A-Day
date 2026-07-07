-- Day 25 : OR Operator

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

-- Employees from HR or IT
SELECT *
FROM employees
WHERE department = 'HR'
OR department = 'IT';

-- Employees with salary greater than 70000 or age greater than 30
SELECT *
FROM employees
WHERE salary > 70000
OR age > 30;

-- Employees from Finance or age less than 25
SELECT *
FROM employees
WHERE department = 'Finance'
OR age < 25;