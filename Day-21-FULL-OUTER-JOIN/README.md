# Day 21 - FULL OUTER JOIN (MySQL Alternative)

# Introduction

In previous lessons, we learned:

- INNER JOIN
- LEFT JOIN
- RIGHT JOIN

Today we'll learn **FULL OUTER JOIN**.

A FULL OUTER JOIN returns **all rows from both tables**.

If there is a match, SQL combines the rows.

If there is no match, SQL displays NULL for the missing side.

---

# What is FULL OUTER JOIN?

FULL OUTER JOIN returns:

- All matching rows
- All rows from the left table
- All rows from the right table

No data from either table is ignored.

---

# Does MySQL Support FULL OUTER JOIN?

No.

Unlike SQL Server and PostgreSQL, **MySQL does not provide a FULL OUTER JOIN keyword**.

To achieve the same result, we combine:

- LEFT JOIN
- RIGHT JOIN
- UNION

---

# Syntax in MySQL

```sql
SELECT columns
FROM table1
LEFT JOIN table2
ON table1.id = table2.id

UNION

SELECT columns
FROM table1
RIGHT JOIN table2
ON table1.id = table2.id;
```

---

# Example Tables

## Students

| student_id | student_name | department_id |
|------------|--------------|---------------|
|101|Chakri|2|
|102|Ram|1|
|103|Ravi|3|
|104|Krishna|2|
|105|Ajay|NULL|

---

## Departments

| department_id | department_name |
|---------------|-----------------|
|1|Computer Science|
|2|Artificial Intelligence|
|3|Electronics|
|4|Mechanical|

Notice:

- Ajay has no department.
- Mechanical department has no students.

---

# FULL OUTER JOIN Result

| Student | Department |
|----------|------------|
|Chakri|Artificial Intelligence|
|Ram|Computer Science|
|Ravi|Electronics|
|Krishna|Artificial Intelligence|
|Ajay|NULL|
|NULL|Mechanical|

This output includes every row from both tables.

---

# Difference Between JOIN Types

| JOIN | Result |
|------|--------|
| INNER JOIN | Only matching rows |
| LEFT JOIN | All left rows + matching right rows |
| RIGHT JOIN | All right rows + matching left rows |
| FULL OUTER JOIN | All rows from both tables |

---

# Why UNION?

The LEFT JOIN returns all rows from the left table.

The RIGHT JOIN returns all rows from the right table.

UNION combines both results and automatically removes duplicate rows.

---

# Real-World Applications

## College Management

Display all students and all departments, including departments with no students and students without departments.

---

## Banking

Display all customers and all bank accounts, even if one has no matching record.

---

## E-Commerce

Display all products and all categories, including products without categories and categories without products.

---

## Hospital Management

Display all doctors and all patients, even if they are not assigned to each other.

---

# Common Mistakes

## Trying to Use FULL OUTER JOIN Directly

Incorrect in MySQL:

```sql
SELECT *
FROM students
FULL OUTER JOIN departments
ON students.department_id = departments.department_id;
```

This generates an error because MySQL does not support FULL OUTER JOIN.

---

## Forgetting UNION

Using only LEFT JOIN or only RIGHT JOIN does not produce a full outer join result.

Both queries must be combined using UNION.

---

# Practice Queries

```sql
SELECT
s.student_name,
d.department_name
FROM students s
LEFT JOIN departments d
ON s.department_id = d.department_id

UNION

SELECT
s.student_name,
d.department_name
FROM students s
RIGHT JOIN departments d
ON s.department_id = d.department_id;
```

---

# Interview Questions

## Does MySQL support FULL OUTER JOIN?

No.

---

## How can FULL OUTER JOIN be achieved in MySQL?

By combining LEFT JOIN and RIGHT JOIN using UNION.

---

## Why is UNION used?

UNION merges the results of both queries and removes duplicate rows.

---

# Summary

Today I learned:

- FULL OUTER JOIN
- MySQL Limitation
- UNION
- LEFT JOIN + RIGHT JOIN
- Combining Results
- Difference Between All JOIN Types

Although MySQL does not directly support FULL OUTER JOIN, it can be implemented using LEFT JOIN, RIGHT JOIN, and UNION.