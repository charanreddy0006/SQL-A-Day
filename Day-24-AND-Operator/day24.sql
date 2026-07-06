-- Day 24 : AND Operator

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

-- Employees in IT department with salary greater than 70000
SELECT *
FROM employees
WHERE department = 'IT'
AND salary > 70000;

-- Employees in HR department older than 25
SELECT *
FROM employees
WHERE department = 'HR'
AND age > 25;

-- Finance employees with salary greater than 60000
SELECT *
FROM employees
WHERE department = 'Finance'
AND salary > 60000;