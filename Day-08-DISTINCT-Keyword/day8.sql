-- Day 08 : DISTINCT Keyword

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
(3,'Ravi','AIML'),
(4,'Krishna','CSE'),
(5,'Arjun','AIML');

-- Display all branches
SELECT branch
FROM students;

-- Display unique branches
SELECT DISTINCT branch
FROM students;

-- Display unique student names
SELECT DISTINCT student_name
FROM students;