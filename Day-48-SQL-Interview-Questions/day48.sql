-- Day 48 : SQL Interview Questions

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John','HR',50000),
(102,'David','IT',70000),
(103,'Emma','Finance',55000),
(104,'Robert','IT',85000),
(105,'Sophia','Finance',65000),
(106,'James','HR',45000);

--------------------------------------------------
-- Q1 : Display All Employees
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Q2 : Employees with Salary > 60000
--------------------------------------------------

SELECT *
FROM employees
WHERE salary > 60000;

--------------------------------------------------
-- Q3 : Employees in IT Department
--------------------------------------------------

SELECT *
FROM employees
WHERE department = 'IT';

--------------------------------------------------
-- Q4 : Highest Salary
--------------------------------------------------

SELECT MAX(salary) AS Highest_Salary
FROM employees;

--------------------------------------------------
-- Q5 : Average Salary
--------------------------------------------------

SELECT AVG(salary) AS Average_Salary
FROM employees;

--------------------------------------------------
-- Q6 : Employee Count by Department
--------------------------------------------------

SELECT department,
COUNT(*) AS Total_Employees
FROM employees
GROUP BY department;

--------------------------------------------------
-- Q7 : Employees Sorted by Salary
--------------------------------------------------

SELECT *
FROM employees
ORDER BY salary DESC;

--------------------------------------------------
-- Q8 : Second Highest Salary
--------------------------------------------------

SELECT MAX(salary) AS Second_Highest
FROM employees
WHERE salary <
(
SELECT MAX(salary)
FROM employees
);

--------------------------------------------------
-- Q9 : Employees Between Salary Range
--------------------------------------------------

SELECT *
FROM employees
WHERE salary BETWEEN 50000 AND 70000;

--------------------------------------------------
-- Q10 : Employee Name Starts with 'J'
--------------------------------------------------

SELECT *
FROM employees
WHERE emp_name LIKE 'J%';