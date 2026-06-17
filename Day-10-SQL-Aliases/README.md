# Day 10 - SQL Aliases (AS Keyword)

# Introduction

An Alias is a temporary name given to a column or table during query execution.

Aliases make query results easier to read and understand.

They do not change the actual name of the column or table in the database.

Aliases exist only for the duration of the query.

---

# What is an Alias?

An alias is an alternative name assigned to a column or table.

### Example

Without Alias:

```sql
SELECT student_name
FROM students;
```

Output:

| student_name |
| ------------ |
| Chakri       |
| Ram          |
| Ravi         |

---

With Alias:

```sql
SELECT student_name AS Name
FROM students;
```

Output:

| Name   |
| ------ |
| Chakri |
| Ram    |
| Ravi   |

---

# Alias for Columns

Column aliases improve readability.

### Syntax

```sql
SELECT column_name AS alias_name
FROM table_name;
```

### Example

```sql
SELECT student_name AS Name
FROM students;
```

---

# Multiple Column Aliases

### Example

```sql
SELECT
student_id AS ID,
student_name AS Name,
branch AS Department
FROM students;
```

Output:

| ID | Name   | Department |
| -- | ------ | ---------- |
| 1  | Chakri | AIML       |
| 2  | Ram    | CSE        |
| 3  | Ravi   | ECE        |

---

# Alias with Spaces

Aliases can contain spaces by using quotes.

### Example

```sql
SELECT student_name AS 'Student Name'
FROM students;
```

Output:

| Student Name |
| ------------ |
| Chakri       |
| Ram          |
| Ravi         |

---

# Table Aliases

Aliases can also be used for tables.

### Syntax

```sql
SELECT column_name
FROM table_name AS alias_name;
```

### Example

```sql
SELECT s.student_name
FROM students AS s;
```

Here:

* students = actual table name
* s = alias

---

# Why Use Table Aliases?

Table aliases make queries shorter and easier to write.

This becomes extremely useful when working with:

* Joins
* Multiple tables
* Complex queries

---

# Real World Applications

## Employee Database

```sql
SELECT employee_name AS Name
FROM employees;
```

---

## Product Database

```sql
SELECT product_name AS Product
FROM products;
```

---

## Banking System

```sql
SELECT account_number AS AccountNo
FROM accounts;
```

---

## College Management System

```sql
SELECT student_name AS Student
FROM students;
```

---

# Advantages of Aliases

* Improves readability
* Makes reports user-friendly
* Reduces query length
* Useful in joins
* Makes column names professional

---

# Common Mistakes

## Thinking Alias Changes Column Name

Incorrect understanding:

Alias only changes the displayed name.

The actual database column remains unchanged.

---

## Forgetting Quotes Around Multi-Word Aliases

Incorrect:

```sql
SELECT student_name AS Student Name;
```

Correct:

```sql
SELECT student_name AS 'Student Name';
```

---

# Practice Queries

```sql
SELECT student_name AS Name
FROM students;

SELECT student_id AS ID,
student_name AS Name
FROM students;

SELECT student_name AS 'Student Name'
FROM students;

SELECT s.student_name
FROM students AS s;
```

---

# Interview Questions

## What is an Alias in SQL?

An alias is a temporary name given to a column or table during query execution.

---

## Does Alias change the actual column name?

No. It only changes the displayed name in query results.

---

## Which keyword is commonly used for aliases?

AS

---

# Summary

Today I learned:

* SQL Aliases
* AS Keyword
* Column Aliases
* Table Aliases
* Multi-Word Aliases
* Real World Applications

Aliases help make SQL queries cleaner, shorter, and more readable.
