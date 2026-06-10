-- Day 03: SQL Data Types

CREATE DATABASE datatype_db;

USE datatype_db;

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date DATE,
    login_time TIME,
    created_at DATETIME
);

DESC employees;