-- Day 19 : LEFT JOIN

CREATE DATABASE college_db;

USE college_db;

-- Parent Table
CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

-- Child Table
CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    age INT,
    department_id INT,
    FOREIGN KEY(department_id)
    REFERENCES departments(department_id)
);

-- Insert Departments
INSERT INTO departments VALUES
(1,'Computer Science'),
(2,'Artificial Intelligence'),
(3,'Electronics'),
(4,'Mechanical');

-- Insert Students
INSERT INTO students VALUES
(101,'Chakri',20,2),
(102,'Ram',19,1),
(103,'Ravi',21,3),
(104,'Krishna',20,2);

-- View Tables
SELECT * FROM departments;

SELECT * FROM students;

-- INNER JOIN
SELECT
s.student_name,
d.department_name
FROM students AS s
INNER JOIN departments AS d
ON s.department_id = d.department_id;

-- LEFT JOIN
SELECT
d.department_name,
s.student_name
FROM departments AS d
LEFT JOIN students AS s
ON d.department_id = s.department_id;