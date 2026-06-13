# Day 06 - WHERE Clause

# Introduction

The WHERE clause is used to filter records from a table.

Instead of displaying all rows, WHERE allows us to retrieve only the rows that satisfy a specific condition.

The WHERE clause is one of the most important SQL concepts because real-world applications rarely need all records at once.

---

# Why Do We Need WHERE?

Consider a table containing thousands of student records.

Without WHERE:

```sql
SELECT * FROM students;
```

All records will be displayed.

But what if we only want AIML students?

We use:

```sql
SELECT *
FROM students
WHERE branch = 'AIML';
```

This returns only AIML students.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE condition;
```

---

# Example Table

| student_id | student_name | branch | age |
| ---------- | ------------ | ------ | --- |
| 1          | Chakri       | AIML   | 20  |
| 2          | Ram          | CSE    | 21  |
| 3          | Ravi         | ECE    | 19  |
| 4          | Krishna      | AIML   | 20  |
| 5          | Arjun        | CSE    | 22  |

---

# Equality Operator (=)

Used to find exact matches.

Example:

```sql
SELECT *
FROM students
WHERE branch = 'AIML';
```

Output:

| student_id | student_name | branch | age |
| ---------- | ------------ | ------ | --- |
| 1          | Chakri       | AIML   | 20  |
| 4          | Krishna      | AIML   | 20  |

---

# Greater Than (>)

Returns values greater than a specified number.

Example:

```sql
SELECT *
FROM students
WHERE age > 20;
```

Output:

| student_name | age |
| ------------ | --- |
| Ram          | 21  |
| Arjun        | 22  |

---

# Less Than (<)

Returns values smaller than a specified number.

Example:

```sql
SELECT *
FROM students
WHERE age < 21;
```

Output:

| student_name | age |
| ------------ | --- |
| Chakri       | 20  |
| Ravi         | 19  |
| Krishna      | 20  |

---

# Greater Than or Equal To (>=)

Example:

```sql
SELECT *
FROM students
WHERE age >= 20;
```

---

# Less Than or Equal To (<=)

Example:

```sql
SELECT *
FROM students
WHERE age <= 20;
```

---

# Not Equal To (!=)

Example:

```sql
SELECT *
FROM students
WHERE branch != 'CSE';
```

Returns all students except CSE students.

---

# Real World Applications

## Banking

```sql
SELECT *
FROM accounts
WHERE balance > 100000;
```

Find high-value accounts.

---

## E-Commerce

```sql
SELECT *
FROM products
WHERE price < 1000;
```

Find affordable products.

---

## College Management

```sql
SELECT *
FROM students
WHERE branch = 'AIML';
```

Display AIML students.

---

## Hospital Management

```sql
SELECT *
FROM patients
WHERE age > 60;
```

Display senior citizen patients.

---

# Common Mistakes

## Missing Quotes Around Text

Incorrect:

```sql
SELECT *
FROM students
WHERE branch = AIML;
```

Correct:

```sql
SELECT *
FROM students
WHERE branch = 'AIML';
```

---

## Using Wrong Column Name

Incorrect:

```sql
SELECT *
FROM students
WHERE name = 'Chakri';
```

If the actual column is student_name, SQL will generate an error.

---

# Practice Queries

```sql
SELECT *
FROM students
WHERE branch = 'AIML';

SELECT *
FROM students
WHERE age > 20;

SELECT *
FROM students
WHERE age < 21;

SELECT *
FROM students
WHERE student_id = 1;
```

---

# Interview Questions

## What is the purpose of the WHERE clause?

The WHERE clause is used to filter records based on specified conditions.

---

## Can WHERE be used with SELECT?

Yes. It is commonly used with SELECT to retrieve specific records.

---

## What operator is used for equality?

The = operator.

---

# Summary

Today I learned:

* WHERE Clause
* Filtering Records
* Equality Operator (=)
* Greater Than (>)
* Less Than (<)
* Greater Than or Equal To (>=)
* Less Than or Equal To (<=)
* Not Equal To (!=)

The WHERE clause is one of the most frequently used SQL features and is essential for retrieving meaningful data from databases.
