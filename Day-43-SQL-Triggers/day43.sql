-- Day 43 : SQL Triggers

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
(103,'Emma',55000);

--------------------------------------------------
-- Audit Table
--------------------------------------------------

CREATE TABLE employee_audit(
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    action_type VARCHAR(20),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--------------------------------------------------
-- Display Data
--------------------------------------------------

SELECT * FROM employees;

--------------------------------------------------
-- Example 1 : AFTER INSERT Trigger
--------------------------------------------------

DELIMITER //

CREATE TRIGGER trg_after_insert
AFTER INSERT
ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit(emp_id, action_type)
    VALUES(NEW.emp_id, 'INSERT');
END //

DELIMITER ;

--------------------------------------------------
-- Test INSERT Trigger
--------------------------------------------------

INSERT INTO employees
VALUES(104,'Sophia',65000);

SELECT * FROM employee_audit;

--------------------------------------------------
-- Example 2 : AFTER UPDATE Trigger
--------------------------------------------------

DELIMITER //

CREATE TRIGGER trg_after_update
AFTER UPDATE
ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit(emp_id, action_type)
    VALUES(NEW.emp_id, 'UPDATE');
END //

DELIMITER ;

UPDATE employees
SET salary = 72000
WHERE emp_id = 102;

--------------------------------------------------
-- Example 3 : AFTER DELETE Trigger
--------------------------------------------------

DELIMITER //

CREATE TRIGGER trg_after_delete
AFTER DELETE
ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit(emp_id, action_type)
    VALUES(OLD.emp_id, 'DELETE');
END //

DELIMITER ;

DELETE FROM employees
WHERE emp_id = 103;

--------------------------------------------------
-- Display Audit Records
--------------------------------------------------

SELECT * FROM employee_audit;

--------------------------------------------------
-- Drop Trigger
--------------------------------------------------

DROP TRIGGER IF EXISTS trg_after_insert;