-- Day 18 : INNER JOIN

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
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);

-- Insert Departments
INSERT INTO departments VALUES
(1,'Computer Science'),
(2,'Artificial Intelligence'),
(3,'Electronics');

-- Insert Students
INSERT INTO students VALUES
(101,'Chakri',20,2),
(102,'Ram',19,1),
(103,'Ravi',21,3),
(104,'Krishna',20,2);

-- View both tables
SELECT * FROM departments;

SELECT * FROM students;

-- INNER JOIN
SELECT
students.student_id,
students.student_name,
departments.department_name
FROM students
INNER JOIN departments
ON students.department_id = departments.department_id;

-- Using Aliases
SELECT
s.student_name,
d.department_name
FROM students AS s
INNER JOIN departments AS d
ON s.department_id = d.department_id;