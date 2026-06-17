-- Day 10 : SQL Aliases

CREATE DATABASE college_db;

USE college_db;

CREATE TABLE students(
    student_id INT,
    student_name VARCHAR(50),
    branch VARCHAR(20)
);

INSERT INTO students
VALUES
(1,'Chakri','AIML'),
(2,'Ram','CSE'),
(3,'Ravi','ECE');

-- Display all records
SELECT * FROM students;

-- Column Alias
SELECT student_name AS Name
FROM students;

-- Multiple Column Aliases
SELECT
student_id AS ID,
student_name AS Name,
branch AS Department
FROM students;

-- Alias with Space
SELECT student_name AS 'Student Name'
FROM students;

-- Table Alias
SELECT s.student_name
FROM students AS s;