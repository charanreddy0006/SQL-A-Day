# Day 07 - ORDER BY Clause

# Introduction

The ORDER BY clause is used to sort records in a table.

By default, data may not appear in a meaningful order. ORDER BY helps us arrange data in ascending or descending order.

Sorting data is one of the most common operations in SQL and is used extensively in reports, dashboards, and business applications.

---

# Why Do We Need ORDER BY?

Consider the following student table:

| student_id | student_name | age |
| ---------- | ------------ | --- |
| 5          | Arjun        | 22  |
| 2          | Ram          | 21  |
| 1          | Chakri       | 20  |
| 4          | Krishna      | 20  |
| 3          | Ravi         | 19  |

The records are not arranged properly.

Using ORDER BY allows us to sort the data.

---

# Syntax

```sql
SELECT column_name
FROM table_name
ORDER BY column_name;
```

---

# Ascending Order (ASC)

Ascending order means:

* Numbers: Smallest to Largest
* Text: A to Z

### Example

```sql
SELECT *
FROM students
ORDER BY student_id;
```

or

```sql
SELECT *
FROM students
ORDER BY student_id ASC;
```

### Output

| student_id | student_name |
| ---------- | ------------ |
| 1          | Chakri       |
| 2          | Ram          |
| 3          | Ravi         |
| 4          | Krishna      |
| 5          | Arjun        |

ASC is the default order.

---

# Descending Order (DESC)

Descending order means:

* Numbers: Largest to Smallest
* Text: Z to A

### Example

```sql
SELECT *
FROM students
ORDER BY student_id DESC;
```

### Output

| student_id | student_name |
| ---------- | ------------ |
| 5          | Arjun        |
| 4          | Krishna      |
| 3          | Ravi         |
| 2          | Ram          |
| 1          | Chakri       |

---

# Sorting Text Data

### Example

```sql
SELECT *
FROM students
ORDER BY student_name;
```

### Output

| student_name |
| ------------ |
| Arjun        |
| Chakri       |
| Krishna      |
| Ram          |
| Ravi         |

Names are arranged alphabetically.

---

# Sorting by Age

### Example

```sql
SELECT *
FROM students
ORDER BY age DESC;
```

### Output

| student_name | age |
| ------------ | --- |
| Arjun        | 22  |
| Ram          | 21  |
| Chakri       | 20  |
| Krishna      | 20  |
| Ravi         | 19  |

---

# Sorting by Multiple Columns

SQL can sort using more than one column.

### Example

```sql
SELECT *
FROM students
ORDER BY branch, student_name;
```

First sorts by branch, then by student name.

---

# ASC vs DESC

| ASC           | DESC              |
| ------------- | ----------------- |
| Small → Large | Large → Small     |
| A → Z         | Z → A             |
| Default Order | Must be specified |

---

# Real World Applications

## E-Commerce

```sql
SELECT *
FROM products
ORDER BY price DESC;
```

Display expensive products first.

---

## Banking

```sql
SELECT *
FROM accounts
ORDER BY balance DESC;
```

Display highest account balances first.

---

## College Management

```sql
SELECT *
FROM students
ORDER BY student_name;
```

Display students alphabetically.

---

## Hospital Systems

```sql
SELECT *
FROM patients
ORDER BY age DESC;
```

Display oldest patients first.

---

# Common Mistakes

## Wrong Column Name

Incorrect:

```sql
SELECT *
FROM students
ORDER BY name;
```

If the actual column is student_name, SQL will generate an error.

---

## Using ORDER BY Before FROM

Incorrect:

```sql
SELECT *
ORDER BY student_name
FROM students;
```

Correct:

```sql
SELECT *
FROM students
ORDER BY student_name;
```

---

# Practice Queries

```sql
SELECT *
FROM students
ORDER BY student_id;

SELECT *
FROM students
ORDER BY student_id DESC;

SELECT *
FROM students
ORDER BY student_name;

SELECT *
FROM students
ORDER BY age DESC;
```

---

# Interview Questions

## What is ORDER BY?

ORDER BY is used to sort records in ascending or descending order.

---

## What is the default sorting order?

Ascending (ASC).

---

## Which keyword is used for descending order?

DESC.

---

# Summary

Today I learned:

* ORDER BY Clause
* ASC (Ascending Order)
* DESC (Descending Order)
* Sorting Numbers
* Sorting Text
* Sorting Multiple Columns

ORDER BY is one of the most important SQL clauses for organizing and presenting data in a meaningful way.
