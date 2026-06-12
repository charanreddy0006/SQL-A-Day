# Day 05 - SELECT Statement

## Introduction

The SELECT statement is used to retrieve data from a table.

It is one of the most frequently used SQL commands because databases are valuable only when we can access and analyze the stored information.

The SELECT statement allows us to:

* View all records
* View specific columns
* Analyze stored data
* Generate reports
* Search information

---

# What is SELECT?

SELECT is a Data Query Language (DQL) command.

It is used to fetch data from a database table.

### Syntax

```sql
SELECT column_name
FROM table_name;
```

---

# Selecting All Columns

To display every column and every row:

```sql
SELECT * FROM students;
```

### Explanation

* SELECT = Retrieve data
* * = All columns
* FROM = Specify the table
* students = Table name

### Output

| student_id | student_name | branch |
| ---------- | ------------ | ------ |
| 1          | Chakri       | AIML   |
| 2          | Ram          | CSE    |
| 3          | Ravi         | ECE    |

---

# Selecting Specific Columns

Instead of displaying all columns, we can choose specific columns.

### Example

```sql
SELECT student_name, branch
FROM students;
```

### Output

| student_name | branch |
| ------------ | ------ |
| Chakri       | AIML   |
| Ram          | CSE    |
| Ravi         | ECE    |

---

# Selecting a Single Column

### Example

```sql
SELECT student_name
FROM students;
```

### Output

| student_name |
| ------------ |
| Chakri       |
| Ram          |
| Ravi         |

---

# Understanding SELECT Components

## SELECT

Used to choose data.

Example:

```sql
SELECT student_name
```

---

## FROM

Specifies the table.

Example:

```sql
FROM students
```

---

## *

Means all columns.

Example:

```sql
SELECT *
FROM students;
```

---

# Why Use SELECT?

SELECT helps us:

* View records
* Generate reports
* Analyze data
* Search information
* Support decision-making

Without SELECT, data stored in databases cannot be viewed.

---

# Real World Applications

## Banking Systems

```sql
SELECT *
FROM accounts;
```

View customer accounts.

---

## E-Commerce

```sql
SELECT product_name, price
FROM products;
```

Display products.

---

## College Management Systems

```sql
SELECT student_name, branch
FROM students;
```

Display student information.

---

## Hospital Systems

```sql
SELECT patient_name
FROM patients;
```

Display patient records.

---

# Common Mistakes

## Wrong Table Name

Incorrect:

```sql
SELECT *
FROM student;
```

If the table name is students, SQL will generate an error.

---

## Wrong Column Name

Incorrect:

```sql
SELECT name
FROM students;
```

If the column is student_name, SQL will generate an error.

---

# Practice Queries

```sql
SELECT * FROM students;

SELECT student_name
FROM students;

SELECT student_name, branch
FROM students;
```

---

# Interview Questions

## What is SELECT in SQL?

SELECT is used to retrieve data from a database table.

---

## What does * mean in SELECT *?

It represents all columns of the table.

---

## What is the purpose of FROM?

FROM specifies the table from which data will be retrieved.

---

# Summary

Today I learned:

* SELECT Statement
* SELECT *
* Selecting Specific Columns
* Selecting Single Columns
* FROM Clause
* Retrieving Data from Tables

The SELECT statement is the foundation of querying databases and is one of the most important SQL commands.
