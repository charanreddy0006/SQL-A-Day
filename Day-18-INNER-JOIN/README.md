# Day 18 - INNER JOIN

# Introduction

In relational databases, data is often stored in multiple related tables instead of one large table.

To retrieve related information from two or more tables, SQL provides JOIN operations.

The most commonly used JOIN is **INNER JOIN**.

INNER JOIN returns only the rows that have matching values in both tables.

It is one of the most frequently used SQL concepts in interviews, backend development, data analysis, and business reporting.

---

# What is a JOIN?

A JOIN combines rows from two or more tables based on a related column.

For example:

Students Table

| student_id | student_name | department_id |
| ---------- | ------------ | ------------- |
| 101        | Chakri       | 2             |
| 102        | Ram          | 1             |
| 103        | Ravi         | 3             |

Departments Table

| department_id | department_name         |
| ------------- | ----------------------- |
| 1             | Computer Science        |
| 2             | Artificial Intelligence |
| 3             | Electronics             |

Both tables are connected using **department_id**.

---

# Why Do We Need INNER JOIN?

Without INNER JOIN, we only know the department ID.

Example:

| student_name | department_id |
| ------------ | ------------- |
| Chakri       | 2             |

After INNER JOIN:

| student_name | department_name         |
| ------------ | ----------------------- |
| Chakri       | Artificial Intelligence |

This makes the data meaningful and easier to understand.

---

# Syntax

```sql
SELECT column_names
FROM table1
INNER JOIN table2
ON table1.common_column = table2.common_column;
```

---

# Understanding the Query

```sql
SELECT
students.student_name,
departments.department_name
FROM students
INNER JOIN departments
ON students.department_id = departments.department_id;
```

### SELECT

Chooses the columns to display.

### FROM

Specifies the first table.

### INNER JOIN

Combines rows from the second table.

### ON

Defines the matching condition.

Only rows with matching department IDs are returned.

---

# Using Table Aliases

Instead of writing long table names:

```sql
students.student_name
```

Use aliases:

```sql
SELECT
s.student_name,
d.department_name
FROM students AS s
INNER JOIN departments AS d
ON s.department_id = d.department_id;
```

This makes queries shorter and easier to read.

---

# Expected Output

| student_name | department_name         |
| ------------ | ----------------------- |
| Chakri       | Artificial Intelligence |
| Ram          | Computer Science        |
| Ravi         | Electronics             |
| Krishna      | Artificial Intelligence |

---

# Real World Applications

## College Management

Students ← Departments

Display each student with their department.

---

## Banking

Accounts ← Customers

Display account details with customer names.

---

## E-Commerce

Products ← Categories

Display product names with category names.

---

## Hospital Management

Patients ← Doctors

Display patient details with assigned doctor names.

---

# Advantages of INNER JOIN

* Combines related data
* Removes unnecessary duplication
* Produces meaningful reports
* Essential for relational databases
* Frequently used in SQL interviews

---

# Common Mistakes

## Wrong Join Condition

Incorrect:

```sql
ON students.student_id = departments.department_id;
```

Always join using related columns.

Correct:

```sql
ON students.department_id = departments.department_id;
```

---

## Forgetting the ON Clause

An INNER JOIN must include the ON clause to specify how the tables are related.

---

# Practice Queries

```sql
SELECT
students.student_name,
departments.department_name
FROM students
INNER JOIN departments
ON students.department_id = departments.department_id;

SELECT
s.student_name,
d.department_name
FROM students AS s
INNER JOIN departments AS d
ON s.department_id = d.department_id;
```

---

# Interview Questions

## What is INNER JOIN?

INNER JOIN returns only the rows that have matching values in both tables.

---

## Which clause specifies the relationship between tables?

The ON clause.

---

## Can INNER JOIN use aliases?

Yes. Table aliases make JOIN queries shorter and easier to read.

---

# Summary

Today I learned:

* JOIN
* INNER JOIN
* ON Clause
* Table Aliases in JOIN
* Combining Multiple Tables
* Real-World Applications

INNER JOIN is one of the most important SQL concepts because it allows data from multiple related tables to be combined into meaningful results.
