-- Day 02: Databases and Tables

-- Create Database
CREATE DATABASE company_db;

-- Show Databases
SHOW DATABASES;

-- Use Database
USE company_db;

-- Create Table
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2)
);

-- Show Tables
SHOW TABLES;

-- Describe Table
DESC employees;