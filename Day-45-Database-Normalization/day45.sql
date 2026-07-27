-- Day 45 : Database Normalization

CREATE DATABASE college_db;

USE college_db;

--------------------------------------------------
-- Unnormalized Table
--------------------------------------------------

CREATE TABLE student_courses(
    student_id INT,
    student_name VARCHAR(50),
    course_name VARCHAR(50),
    faculty_name VARCHAR(50)
);

INSERT INTO student_courses VALUES
(101,'John','DBMS','Dr. Smith'),
(101,'John','Python','Dr. Kumar'),
(102,'Emma','DBMS','Dr. Smith'),
(103,'David','Java','Dr. Brown');

SELECT * FROM student_courses;

--------------------------------------------------
-- First Normal Form (1NF)
--------------------------------------------------

-- Each column contains atomic values.
-- No repeating groups.

--------------------------------------------------
-- Second Normal Form (2NF)
--------------------------------------------------

CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);

CREATE TABLE courses(
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    faculty_name VARCHAR(50)
);

CREATE TABLE enrollments(
    student_id INT,
    course_id INT,
    PRIMARY KEY(student_id, course_id),
    FOREIGN KEY(student_id) REFERENCES students(student_id),
    FOREIGN KEY(course_id) REFERENCES courses(course_id)
);

--------------------------------------------------
-- Insert Data
--------------------------------------------------

INSERT INTO students VALUES
(101,'John'),
(102,'Emma'),
(103,'David');

INSERT INTO courses VALUES
(1,'DBMS','Dr. Smith'),
(2,'Python','Dr. Kumar'),
(3,'Java','Dr. Brown');

INSERT INTO enrollments VALUES
(101,1),
(101,2),
(102,1),
(103,3);

--------------------------------------------------
-- Display Normalized Data
--------------------------------------------------

SELECT
s.student_name,
c.course_name,
c.faculty_name
FROM enrollments e
JOIN students s
ON e.student_id=s.student_id
JOIN courses c
ON e.course_id=c.course_id;