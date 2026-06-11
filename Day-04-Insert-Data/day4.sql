-- Day 04 : INSERT Statement

CREATE DATABASE employee_db;

USE employee_db;

CREATE TABLE employees(
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2)
);

INSERT INTO employees
VALUES
(101,'Chakri',500000),
(102,'Sai',60000),
(103,'Pavan',55000);

SELECT * FROM employees;