-- Day 13 : Aggregate Functions

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
(104,'Robert',70000),
(105,'Sophia',65000);

-- Count Employees
SELECT COUNT(*) AS Total_Employees
FROM employees;

-- Total Salary
SELECT SUM(salary) AS Total_Salary
FROM employees;

-- Average Salary
SELECT AVG(salary) AS Average_Salary
FROM employees;

-- Highest Salary
SELECT MAX(salary) AS Highest_Salary
FROM employees;

-- Lowest Salary
SELECT MIN(salary) AS Lowest_Salary
FROM employees;