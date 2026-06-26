-- Day 16 : SQL Constraints

CREATE DATABASE college_db;

USE college_db;

CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    branch VARCHAR(20) DEFAULT 'CSE',
    age INT CHECK (age >= 17)
);

-- Insert valid records
INSERT INTO students
VALUES
(101, 'Chakri', 'chakri@gmail.com', 'AIML', 20);

INSERT INTO students(student_id, student_name, email, age)
VALUES
(102, 'Ram', 'ram@gmail.com', 19);

-- Display records
SELECT * FROM students;

-- Examples (Do NOT execute these, they will generate errors)

-- Duplicate PRIMARY KEY
-- INSERT INTO students VALUES(101,'Ravi','ravi@gmail.com','ECE',21);

-- NULL value for NOT NULL column
-- INSERT INTO students(student_id,email,branch,age)
-- VALUES(103,'abc@gmail.com','IT',20);

-- Duplicate UNIQUE value
-- INSERT INTO students VALUES(104,'David','ram@gmail.com','IT',22);

-- CHECK constraint violation
-- INSERT INTO students VALUES(105,'John','john@gmail.com','IT',15);