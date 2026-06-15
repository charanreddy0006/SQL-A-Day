# Day 08 - DISTINCT Keyword

# Introduction

The DISTINCT keyword is used to remove duplicate values from query results.

When a table contains repeated values, DISTINCT helps us retrieve only unique records.

It is commonly used in reporting, analytics, and data exploration.

---

# What is DISTINCT?

DISTINCT is used with the SELECT statement to display unique values.

### Syntax

```sql
SELECT DISTINCT column_name
FROM table_name;
```

---

# Why Do We Need DISTINCT?

Consider the following table:

| student_id | student_name | branch |
| ---------- | ------------ | ------ |
| 1          | Chakri       | AIML   |
| 2          | Ram          | CSE    |
| 3          | Ravi         | AIML   |
| 4          | Krishna      | CSE    |
| 5          | Arjun        | AIML   |

If we execute:

```sql
SELECT branch
FROM students;
```

Output:

```text
AIML
CSE
AIML
CSE
AIML
```

Notice that branch names are repeated.

To display only unique branch names:

```sql
SELECT DISTINCT branch
FROM students;
```

Output:

```text
AIML
CSE
```

---

# DISTINCT on a Single Column

### Example

```sql
SELECT DISTINCT branch
FROM students;
```

Returns unique branch values only.

---

# DISTINCT on Multiple Columns

DISTINCT can be applied to multiple columns.

### Example

```sql
SELECT DISTINCT student_name, branch
FROM students;
```

SQL treats the combination of both columns as unique.

---

# Difference Between SELECT and DISTINCT

## SELECT

```sql
SELECT branch
FROM students;
```

Returns all values including duplicates.

---

## DISTINCT

```sql
SELECT DISTINCT branch
FROM students;
```

Returns only unique values.

---

# Real World Applications

## E-Commerce

```sql
SELECT DISTINCT category
FROM products;
```

Display unique product categories.

---

## Banking

```sql
SELECT DISTINCT city
FROM customers;
```

Display cities where customers live.

---

## College Management

```sql
SELECT DISTINCT branch
FROM students;
```

Display available branches.

---

## Hospital Management

```sql
SELECT DISTINCT department
FROM doctors;
```

Display unique hospital departments.

---

# Advantages of DISTINCT

* Removes duplicate values
* Produces cleaner reports
* Helps in data analysis
* Improves readability

---

# Common Mistakes

## Forgetting DISTINCT

Incorrect:

```sql
SELECT branch
FROM students;
```

Produces duplicate values.

---

## Expecting DISTINCT to Remove Duplicate Rows Automatically

DISTINCT only removes duplicates in selected columns.

---

# Practice Queries

```sql
SELECT DISTINCT branch
FROM students;

SELECT DISTINCT student_name
FROM students;

SELECT DISTINCT student_name, branch
FROM students;
```

---

# Interview Questions

## What is DISTINCT in SQL?

DISTINCT is used to retrieve unique values by removing duplicate records from query results.

---

## Can DISTINCT be used with multiple columns?

Yes. SQL checks the combination of all selected columns.

---

## Is DISTINCT used with INSERT?

No. DISTINCT is used with SELECT statements.

---

# Summary

Today I learned:

* DISTINCT Keyword
* Removing Duplicate Values
* Unique Records
* DISTINCT on Single Column
* DISTINCT on Multiple Columns
* Real World Uses of DISTINCT

DISTINCT is a powerful SQL keyword used to clean and analyze data by eliminating duplicate values from query results.
