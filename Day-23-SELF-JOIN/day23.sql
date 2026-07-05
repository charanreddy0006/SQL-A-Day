-- Day 23 : SELF JOIN

CREATE DATABASE company_db;

USE company_db;

-- Employee Table
CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT
);

-- Insert Employees
INSERT INTO employees VALUES
(1,'John',NULL),
(2,'David',1),
(3,'Emma',1),
(4,'Robert',2),
(5,'Sophia',2),
(6,'James',3);

-- View Table
SELECT * FROM employees;

-- SELF JOIN
SELECT
e.emp_name AS Employee,
m.emp_name AS Manager
FROM employees AS e
LEFT JOIN employees AS m
ON e.manager_id = m.emp_id;