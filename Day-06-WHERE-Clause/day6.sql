-- Day 06 : WHERE Clause

CREATE DATABASE college_db;

USE college_db;

CREATE TABLE students(
    student_id INT,
    student_name VARCHAR(50),
    branch VARCHAR(20),
    age INT
);

INSERT INTO students
VALUES
(1,'Chakri','AIML',20),
(2,'Ram','CSE',21),
(3,'Ravi','ECE',19),
(4,'Krishna','AIML',20),
(5,'Arjun','CSE',22);

-- Display all records
SELECT * FROM students;

-- Students from AIML
SELECT *
FROM students
WHERE branch = 'AIML';

-- Student with ID 1
SELECT *
FROM students
WHERE student_id = 1;

-- Students older than 20
SELECT *
FROM students
WHERE age > 20;

-- Students younger than 21
SELECT *
FROM students
WHERE age < 21;