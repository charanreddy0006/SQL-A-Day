-- Day 50 : Employee Management System

CREATE DATABASE employee_management;

USE employee_management;

--------------------------------------------------
-- Departments Table
--------------------------------------------------

CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

INSERT INTO departments VALUES
(1,'HR'),
(2,'IT'),
(3,'Finance');

--------------------------------------------------
-- Employees Table
--------------------------------------------------

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    department_id INT,
    FOREIGN KEY(department_id)
    REFERENCES departments(department_id)
);

INSERT INTO employees VALUES
(101,'John','john@gmail.com',50000,1),
(102,'David','david@gmail.com',70000,2),
(103,'Emma','emma@gmail.com',65000,3),
(104,'Sophia','sophia@gmail.com',80000,2);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM departments;
SELECT * FROM employees;

--------------------------------------------------
-- JOIN Example
--------------------------------------------------

SELECT
e.emp_id,
e.emp_name,
d.department_name,
e.salary
FROM employees e
JOIN departments d
ON e.department_id=d.department_id;

--------------------------------------------------
-- Aggregate Query
--------------------------------------------------

SELECT
d.department_name,
COUNT(e.emp_id) AS Total_Employees,
AVG(e.salary) AS Average_Salary
FROM departments d
LEFT JOIN employees e
ON d.department_id=e.department_id
GROUP BY d.department_name;

--------------------------------------------------
-- Create View
--------------------------------------------------

CREATE VIEW employee_report AS
SELECT
e.emp_name,
d.department_name,
e.salary
FROM employees e
JOIN departments d
ON e.department_id=d.department_id;

SELECT * FROM employee_report;

--------------------------------------------------
-- Create Index
--------------------------------------------------

CREATE INDEX idx_emp_name
ON employees(emp_name);

--------------------------------------------------
-- Stored Procedure
--------------------------------------------------

DELIMITER //

CREATE PROCEDURE GetEmployeesByDepartment(IN dept VARCHAR(50))
BEGIN
    SELECT
    e.emp_name,
    e.salary,
    d.department_name
    FROM employees e
    JOIN departments d
    ON e.department_id=d.department_id
    WHERE d.department_name=dept;
END //

DELIMITER ;

CALL GetEmployeesByDepartment('IT');

--------------------------------------------------
-- Audit Table
--------------------------------------------------

CREATE TABLE employee_log(
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    action_type VARCHAR(20),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- Trigger
--------------------------------------------------

DELIMITER //

CREATE TRIGGER trg_employee_insert
AFTER INSERT
ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_log(emp_id,action_type)
    VALUES(NEW.emp_id,'INSERT');
END //

DELIMITER ;

INSERT INTO employees VALUES
(105,'James','james@gmail.com',55000,1);

SELECT * FROM employee_log;

--------------------------------------------------
-- Transaction Example
--------------------------------------------------

START TRANSACTION;

UPDATE employees
SET salary=salary+5000
WHERE emp_id=102;

COMMIT;

--------------------------------------------------
-- Final Report
--------------------------------------------------

SELECT * FROM employee_report;