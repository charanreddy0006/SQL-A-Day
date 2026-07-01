# Day 20 - RIGHT JOIN

# Introduction

Yesterday we learned **LEFT JOIN**, which returns all records from the left table.

Today we'll learn **RIGHT JOIN**, which returns all records from the right table.

If there is no matching record in the left table, SQL returns **NULL** for the left table columns.

Although RIGHT JOIN is less commonly used than LEFT JOIN, understanding it helps you write flexible SQL queries and perform better in interviews.

---

# What is RIGHT JOIN?

RIGHT JOIN returns:

- All rows from the right table.
- Matching rows from the left table.
- NULL values for rows in the left table when no match exists.

---

# Syntax

```sql
SELECT column_names
FROM table1
RIGHT JOIN table2
ON table1.common_column = table2.common_column;
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

Notice that:

- Student **Ajay** has no department.
- **Mechanical** department has no students.

---

# RIGHT JOIN Example

```sql
SELECT
s.student_name,
d.department_name
FROM students s
RIGHT JOIN departments d
ON s.department_id = d.department_id;
```

### Output

| Student | Department |
|----------|------------|
|Ram|Computer Science|
|Chakri|Artificial Intelligence|
|Krishna|Artificial Intelligence|
|Ravi|Electronics|
|NULL|Mechanical|

The Mechanical department is displayed even though no student belongs to it.

---

# Understanding RIGHT JOIN

Think of two tables:

```
Students           Departments

Left Table         Right Table
```

RIGHT JOIN keeps:

- ✔ All rows from the **Departments** table.
- ✔ Matching rows from the **Students** table.
- ✔ NULL where no student exists.

---

# LEFT JOIN vs RIGHT JOIN

| LEFT JOIN | RIGHT JOIN |
|------------|------------|
|Returns all rows from the left table|Returns all rows from the right table|
|Missing right-side data becomes NULL|Missing left-side data becomes NULL|
|Most commonly used|Less commonly used|

---

# Can RIGHT JOIN Be Replaced?

Yes.

Most SQL developers prefer LEFT JOIN because it is easier to read.

For example:

```sql
SELECT
d.department_name,
s.student_name
FROM departments d
LEFT JOIN students s
ON d.department_id = s.department_id;
```

This produces the same result as the previous RIGHT JOIN query.

---

# Real-World Applications

## College Management

Display all departments, even if no students are enrolled.

---

## Banking

Display all bank branches, even if they have no customers.

---

## E-Commerce

Display all product categories, even if no products exist.

---

## Hospital Management

Display all departments, even if no patients are admitted.

---

# Common Mistakes

## Confusing Table Order

RIGHT JOIN always returns every row from the **right table**.

Changing the table order changes the result.

---

## Wrong Join Condition

Incorrect:

```sql
ON students.student_id = departments.department_id;
```

Correct:

```sql
ON students.department_id = departments.department_id;
```

---

# Practice Queries

```sql
SELECT
s.student_name,
d.department_name
FROM students s
RIGHT JOIN departments d
ON s.department_id = d.department_id;

SELECT
d.department_name,
s.student_name
FROM departments d
LEFT JOIN students s
ON d.department_id = s.department_id;
```

Run both queries and compare the output.

---

# Interview Questions

## What is RIGHT JOIN?

RIGHT JOIN returns all rows from the right table and matching rows from the left table.

---

## What happens when there is no matching row?

SQL returns NULL for the columns of the left table.

---

## Which JOIN is more commonly used in real projects?

LEFT JOIN is generally more common because it is easier to understand and write.

---

# Summary

Today I learned:

- RIGHT JOIN
- Difference between LEFT JOIN and RIGHT JOIN
- RIGHT Table
- NULL Values
- Comparing RIGHT JOIN with LEFT JOIN
- Real-world Applications

RIGHT JOIN helps retrieve all records from the right table while including matching records from the left table. Understanding both LEFT JOIN and RIGHT JOIN makes it easier to work with relational databases.