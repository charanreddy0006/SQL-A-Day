-- Day 41 : Stored Procedures

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
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : Simple Stored Procedure
--------------------------------------------------

DELIMITER //

CREATE PROCEDURE ShowEmployees()
BEGIN
    SELECT * FROM employees;
END //

DELIMITER ;

--------------------------------------------------
-- Execute Procedure
--------------------------------------------------

CALL ShowEmployees();

--------------------------------------------------
-- Example 2 : Procedure with IN Parameter
--------------------------------------------------

DELIMITER //

CREATE PROCEDURE GetDepartmentEmployees(IN dept_name VARCHAR(30))
BEGIN
    SELECT *
    FROM employees
    WHERE department = dept_name;
END //

DELIMITER ;

--------------------------------------------------
-- Execute Procedure
--------------------------------------------------

CALL GetDepartmentEmployees('IT');

--------------------------------------------------
-- Example 3 : Procedure with OUT Parameter
--------------------------------------------------

DELIMITER //

CREATE PROCEDURE GetEmployeeCount(OUT total INT)
BEGIN
    SELECT COUNT(*) INTO total
    FROM employees;
END //

DELIMITER ;

SET @count = 0;

CALL GetEmployeeCount(@count);

SELECT @count AS Total_Employees;

--------------------------------------------------
-- Example 4 : Drop Procedure
--------------------------------------------------

DROP PROCEDURE IF EXISTS ShowEmployees;