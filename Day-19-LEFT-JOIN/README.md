# Day 19 - LEFT JOIN

# Introduction

Yesterday we learned **INNER JOIN**, which returns only matching records from both tables.

Today we'll learn **LEFT JOIN**, which returns **all records from the left table** and only the matching records from the right table.

If there is no matching record in the right table, SQL returns **NULL**.

LEFT JOIN is extremely useful in reporting and business analytics because we often need to display every record from one table, even if related data does not exist.

---

# What is LEFT JOIN?

LEFT JOIN returns:

- All rows from the left table
- Matching rows from the right table
- NULL for unmatched rows

---

# Syntax

```sql
SELECT column_names
FROM table1
LEFT JOIN table2
ON table1.column = table2.column;
```

---

# Example Tables

## Departments

| department_id | department_name |
|--------------|-----------------|
|1|Computer Science|
|2|Artificial Intelligence|
|3|Electronics|
|4|Mechanical|

---

## Students

| student_id | student_name | department_id |
|-----------|--------------|---------------|
|101|Chakri|2|
|102|Ram|1|
|103|Ravi|3|
|104|Krishna|2|

Notice:

Mechanical department has **no students**.

---

# INNER JOIN Result

```sql
SELECT
s.student_name,
d.department_name
FROM students s
INNER JOIN departments d
ON s.department_id = d.department_id;
```

Output

| Student | Department |
|---------|------------|
|Chakri|Artificial Intelligence|
|Ram|Computer Science|
|Ravi|Electronics|
|Krishna|Artificial Intelligence|

Mechanical department is **missing** because there are no matching students.

---

# LEFT JOIN Result

```sql
SELECT
d.department_name,
s.student_name
FROM departments d
LEFT JOIN students s
ON d.department_id = s.department_id;
```

Output

| Department | Student |
|------------|---------|
|Computer Science|Ram|
|Artificial Intelligence|Chakri|
|Artificial Intelligence|Krishna|
|Electronics|Ravi|
|Mechanical|NULL|

Now Mechanical department appears even though there are no students.

---

# Understanding LEFT JOIN

Imagine two circles.

```
        Departments            Students

       ( Left Table )      ( Right Table )

LEFT JOIN keeps:

✔ All rows from Departments

✔ Matching rows from Students

❌ Unmatched student rows are ignored
```

---

# Difference Between INNER JOIN and LEFT JOIN

| INNER JOIN | LEFT JOIN |
|------------|-----------|
|Returns only matching rows|Returns all rows from the left table|
|Ignores unmatched rows|Displays unmatched left rows with NULL values|
|Used when matching data is required|Used when all left table data must be shown|

---

# When Should We Use LEFT JOIN?

Use LEFT JOIN when you want:

- All departments, even if no employees exist
- All customers, even if no orders exist
- All products, even if never sold
- All students, even if no attendance record exists

---

# Real-World Applications

## College Management

Display all departments, including those without students.

---

## Banking

Display all customers, even if they don't have an account.

---

## E-Commerce

Display all products, even if no orders have been placed.

---

## Hospital

Display all doctors, even if they have no assigned patients.

---

# Common Mistakes

## Wrong Table Order

LEFT JOIN always keeps every row from the **left table**.

Changing the table order changes the result.

---

## Wrong Join Condition

Incorrect

```sql
ON students.student_id = departments.department_id;
```

Correct

```sql
ON students.department_id = departments.department_id;
```

---

# Practice Queries

```sql
SELECT
d.department_name,
s.student_name
FROM departments d
LEFT JOIN students s
ON d.department_id = s.department_id;
```

---

# Interview Questions

## What is LEFT JOIN?

LEFT JOIN returns all rows from the left table and matching rows from the right table.

---

## What happens when there is no matching row?

SQL returns NULL for the right table columns.

---

## Which table's rows are always returned?

The left table.

---

# Summary

Today I learned:

- LEFT JOIN
- LEFT Table
- Right Table
- NULL Values
- Difference between INNER JOIN and LEFT JOIN
- Real-world Applications

LEFT JOIN is one of the most commonly used SQL joins because it ensures that all records from the left table are returned, even when no related records exist in the right table.