-- Day 09 : LIMIT Clause

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
(3,'Ravi','ECE'),
(4,'Krishna','AIML'),
(5,'Arjun','CSE'),
(6,'Kiran','ECE'),
(7,'Sai','AIML');

-- Display all records
SELECT * FROM students;

-- Display first 3 records
SELECT *
FROM students
LIMIT 3;

-- Display first 5 records
SELECT *
FROM students
LIMIT 5;

-- Display first 2 student names
SELECT student_name
FROM students
LIMIT 2;