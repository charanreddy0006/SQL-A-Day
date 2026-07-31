-- Day 49 : Student Management System

CREATE DATABASE student_management;

USE student_management;

--------------------------------------------------
-- Students Table
--------------------------------------------------

CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    department VARCHAR(30)
);

--------------------------------------------------
-- Courses Table
--------------------------------------------------

CREATE TABLE courses(
    course_id INT PRIMARY KEY,
    course_name VARCHAR(50),
    faculty_name VARCHAR(50)
);

--------------------------------------------------
-- Enrollments Table
--------------------------------------------------

CREATE TABLE enrollments(
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    FOREIGN KEY(student_id) REFERENCES students(student_id),
    FOREIGN KEY(course_id) REFERENCES courses(course_id)
);

--------------------------------------------------
-- Insert Students
--------------------------------------------------

INSERT INTO students VALUES
(101,'John','john@gmail.com','CSE'),
(102,'Emma','emma@gmail.com','AI'),
(103,'David','david@gmail.com','IT');

--------------------------------------------------
-- Insert Courses
--------------------------------------------------

INSERT INTO courses VALUES
(1,'Database Management','Dr. Smith'),
(2,'Python Programming','Dr. Kumar'),
(3,'Machine Learning','Dr. Brown');

--------------------------------------------------
-- Insert Enrollments
--------------------------------------------------

INSERT INTO enrollments VALUES
(1001,101,1,'2026-07-31'),
(1002,101,2,'2026-07-31'),
(1003,102,3,'2026-07-31'),
(1004,103,1,'2026-07-31');

--------------------------------------------------
-- Display Tables
--------------------------------------------------

SELECT * FROM students;

SELECT * FROM courses;

SELECT * FROM enrollments;

--------------------------------------------------
-- JOIN Query
--------------------------------------------------

SELECT
s.student_name,
c.course_name,
c.faculty_name,
e.enrollment_date
FROM enrollments e
JOIN students s
ON e.student_id=s.student_id
JOIN courses c
ON e.course_id=c.course_id;

--------------------------------------------------
-- Aggregate Query
--------------------------------------------------

SELECT
department,
COUNT(*) AS Total_Students
FROM students
GROUP BY department;

--------------------------------------------------
-- View
--------------------------------------------------

CREATE VIEW student_course_view AS
SELECT
s.student_name,
c.course_name,
c.faculty_name
FROM enrollments e
JOIN students s
ON e.student_id=s.student_id
JOIN courses c
ON e.course_id=c.course_id;

SELECT * FROM student_course_view;

--------------------------------------------------
-- Index
--------------------------------------------------

CREATE INDEX idx_student_name
ON students(student_name);

--------------------------------------------------
-- Stored Procedure
--------------------------------------------------

DELIMITER //

CREATE PROCEDURE ShowStudents()
BEGIN
SELECT * FROM students;
END //

DELIMITER ;

CALL ShowStudents();

--------------------------------------------------
-- Trigger
--------------------------------------------------

CREATE TABLE student_log(
log_id INT AUTO_INCREMENT PRIMARY KEY,
student_id INT,
action_type VARCHAR(20),
action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //

CREATE TRIGGER trg_student_insert
AFTER INSERT
ON students
FOR EACH ROW
BEGIN
INSERT INTO student_log(student_id,action_type)
VALUES(NEW.student_id,'INSERT');
END //

DELIMITER ;

INSERT INTO students VALUES
(104,'Sophia','sophia@gmail.com','CSE');

SELECT * FROM student_log;

--------------------------------------------------
-- Transaction
--------------------------------------------------

START TRANSACTION;

UPDATE students
SET department='AI & ML'
WHERE student_id=103;

COMMIT;