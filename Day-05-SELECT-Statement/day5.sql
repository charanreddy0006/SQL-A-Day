-- Day 05 : SELECT Statement

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

-- Display specific columns
SELECT student_name, branch
FROM students;

-- Display only student names
SELECT student_name
FROM students;