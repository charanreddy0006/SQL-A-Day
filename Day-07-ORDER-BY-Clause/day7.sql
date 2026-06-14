-- Day 07 : ORDER BY Clause

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
(5,'Arjun','CSE',22),
(2,'Ram','CSE',21),
(1,'Chakri','AIML',20),
(4,'Krishna','AIML',20),
(3,'Ravi','ECE',19);

-- Display all records
SELECT * FROM students;

-- Sort by student_id ascending
SELECT *
FROM students
ORDER BY student_id;

-- Sort by student_id descending
SELECT *
FROM students
ORDER BY student_id DESC;

-- Sort by name alphabetically
SELECT *
FROM students
ORDER BY student_name;

-- Sort by age descending
SELECT *
FROM students
ORDER BY age DESC;