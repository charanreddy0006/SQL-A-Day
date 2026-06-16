# Day 09 - LIMIT Clause

# Introduction

The LIMIT clause is used to restrict the number of rows returned by a query.

Instead of displaying all records from a table, LIMIT allows us to display only a specified number of rows.

This is extremely useful when working with large datasets.

---

# What is LIMIT?

LIMIT is used with SELECT statements to control how many rows should be returned.

### Syntax

```sql
SELECT column_name
FROM table_name
LIMIT number;
```

---

# Why Do We Need LIMIT?

Consider a table containing thousands of student records.

Using:

```sql
SELECT * FROM students;
```

returns every row.

Sometimes we only need a few rows.

Example:

```sql
SELECT *
FROM students
LIMIT 5;
```

This returns only the first 5 rows.

---

# Example Table

| student_id | student_name | branch |
| ---------- | ------------ | ------ |
| 1          | Chakri       | AIML   |
| 2          | Ram          | CSE    |
| 3          | Ravi         | ECE    |
| 4          | Krishna      | AIML   |
| 5          | Arjun        | CSE    |
| 6          | Kiran        | ECE    |
| 7          | Sai          | AIML   |

---

# LIMIT 3

```sql
SELECT *
FROM students
LIMIT 3;
```

Output:

| student_id | student_name |
| ---------- | ------------ |
| 1          | Chakri       |
| 2          | Ram          |
| 3          | Ravi         |

Only the first three rows are displayed.

---

# LIMIT 5

```sql
SELECT *
FROM students
LIMIT 5;
```

Returns the first five records.

---

# LIMIT with Specific Columns

```sql
SELECT student_name
FROM students
LIMIT 2;
```

Output:

| student_name |
| ------------ |
| Chakri       |
| Ram          |

---

# LIMIT with ORDER BY

LIMIT is commonly used with ORDER BY.

Example:

```sql
SELECT *
FROM students
ORDER BY student_id DESC
LIMIT 3;
```

Output:

Displays the latest three records.

---

# Real World Applications

## E-Commerce

```sql
SELECT *
FROM products
LIMIT 10;
```

Display first 10 products.

---

## Banking

```sql
SELECT *
FROM transactions
LIMIT 5;
```

Display recent transactions.

---

## Social Media

```sql
SELECT *
FROM posts
LIMIT 20;
```

Display first 20 posts.

---

## College Management

```sql
SELECT *
FROM students
LIMIT 10;
```

Display first 10 student records.

---

# Advantages of LIMIT

* Faster query execution
* Reduces unnecessary data
* Useful for testing queries
* Improves performance on large datasets

---

# Common Mistakes

## Using LIMIT Without SELECT

Incorrect:

```sql
LIMIT 5;
```

LIMIT must be used with SELECT.

---

## Expecting LIMIT to Sort Data

LIMIT only restricts rows.

For sorting, use ORDER BY.

---

# Practice Queries

```sql
SELECT *
FROM students
LIMIT 3;

SELECT *
FROM students
LIMIT 5;

SELECT student_name
FROM students
LIMIT 2;

SELECT *
FROM students
ORDER BY student_id DESC
LIMIT 3;
```

---

# Interview Questions

## What is LIMIT used for?

LIMIT is used to restrict the number of rows returned by a query.

---

## Can LIMIT be used with ORDER BY?

Yes. It is commonly used together to retrieve top or latest records.

---

## Does LIMIT sort data?

No. LIMIT only restricts the number of rows.

Sorting is done using ORDER BY.

---

# Summary

Today I learned:

* LIMIT Clause
* Restricting Query Results
* LIMIT with SELECT
* LIMIT with ORDER BY
* Real World Applications
* Advantages of LIMIT

LIMIT is a powerful SQL clause used to control the amount of data returned from a query and improve query performance.
