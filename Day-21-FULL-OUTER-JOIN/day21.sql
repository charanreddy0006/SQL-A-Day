-- Day 21 : FULL OUTER JOIN (MySQL)

CREATE DATABASE college_db;

USE college_db;

-- Students Table
CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    department_id INT
);

-- Departments Table
CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

-- Insert Departments
INSERT INTO departments VALUES
(1,'Computer Science'),
(2,'Artificial Intelligence'),
(3,'Electronics'),
(4,'Mechanical');

-- Insert Students
INSERT INTO students VALUES
(101,'Chakri',2),
(102,'Ram',1),
(103,'Ravi',3),
(104,'Krishna',2),
(105,'Ajay',NULL);

-- Display Tables
SELECT * FROM students;
SELECT * FROM departments;

-- LEFT JOIN
SELECT
s.student_name,
d.department_name
FROM students s
LEFT JOIN departments d
ON s.department_id = d.department_id

UNION

-- RIGHT JOIN
SELECT
s.student_name,
d.department_name
FROM students s
RIGHT JOIN departments d
ON s.department_id = d.department_id;