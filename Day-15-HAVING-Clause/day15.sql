-- Day 15 : HAVING Clause

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

-- Departments having more than 1 employee
SELECT department,
COUNT(*) AS Total_Employees
FROM employees
GROUP BY department
HAVING COUNT(*) > 1;

-- Departments with total salary greater than 120000
SELECT department,
SUM(salary) AS Total_Salary
FROM employees
GROUP BY department
HAVING SUM(salary) > 120000;

-- Departments with average salary greater than 60000
SELECT department,
AVG(salary) AS Average_Salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000;