-- Day 17 : PRIMARY KEY and FOREIGN KEY

CREATE DATABASE college_db;

USE college_db;

-- Parent Table
CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

-- Child Table
CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    age INT CHECK(age >= 17),
    department_id INT,
    FOREIGN KEY (department_id)
    REFERENCES departments(department_id)
);

-- Insert Departments
INSERT INTO departments
VALUES
(1,'Computer Science'),
(2,'Artificial Intelligence'),
(3,'Electronics');

-- Insert Students
INSERT INTO students
VALUES
(101,'Chakri',20,2),
(102,'Ram',19,1),
(103,'Ravi',21,3);

-- Display Tables
SELECT * FROM departments;

SELECT * FROM students;