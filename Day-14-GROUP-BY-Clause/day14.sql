-- Day 14 : GROUP BY Clause

CREATE DATABASE company_db;

USE company_db;

CREATE TABLE employees(
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John','HR',50000),
(102,'David','IT',70000),
(103,'Emma','HR',55000),
(104,'Robert','IT',80000),
(105,'Sophia','Finance',65000),
(106,'James','Finance',60000);

-- Display all records
SELECT * FROM employees;

-- Count employees in each department
SELECT department,
COUNT(*) AS Total_Employees
FROM employees
GROUP BY department;

-- Total salary by department
SELECT department,
SUM(salary) AS Total_Salary
FROM employees
GROUP BY department;

-- Average salary by department
SELECT department,
AVG(salary) AS Average_Salary
FROM employees
GROUP BY department;

-- Highest salary in each department
SELECT department,
MAX(salary) AS Highest_Salary
FROM employees
GROUP BY department;

-- Lowest salary in each department
SELECT department,
MIN(salary) AS Lowest_Salary
FROM employees
GROUP BY department;