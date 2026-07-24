-- Day 42 : SQL Functions

CREATE DATABASE company_db;

USE company_db;

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2)
);

INSERT INTO employees VALUES
(101,'John',50000),
(102,'David',70000),
(103,'Emma',55000),
(104,'Robert',85000),
(105,'Sophia',65000);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Create Function
--------------------------------------------------

DELIMITER //

CREATE FUNCTION CalculateBonus(emp_salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN emp_salary * 0.10;
END //

DELIMITER ;

--------------------------------------------------
-- Call Function
--------------------------------------------------

SELECT
    emp_name,
    salary,
    CalculateBonus(salary) AS Bonus
FROM employees;

--------------------------------------------------
-- Example 2 : Tax Calculation Function
--------------------------------------------------

DELIMITER //

CREATE FUNCTION CalculateTax(emp_salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN emp_salary * 0.05;
END //

DELIMITER ;

SELECT
    emp_name,
    salary,
    CalculateTax(salary) AS Tax
FROM employees;

--------------------------------------------------
-- Example 3 : Drop Function
--------------------------------------------------

DROP FUNCTION IF EXISTS CalculateBonus;