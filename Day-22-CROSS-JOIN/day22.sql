-- Day 22 : CROSS JOIN

CREATE DATABASE college_db;

USE college_db;

-- Students Table
CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);

-- Courses Table
CREATE TABLE courses(
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50)
);

-- Insert Students
INSERT INTO students VALUES
(101,'Chakri'),
(102,'Ram'),
(103,'Ravi');

-- Insert Courses
INSERT INTO courses VALUES
(1,'Python'),
(2,'SQL'),
(3,'Java');

-- Display Tables
SELECT * FROM students;

SELECT * FROM courses;

-- CROSS JOIN
SELECT
s.student_name,
c.course_name
FROM students AS s
CROSS JOIN courses AS c;