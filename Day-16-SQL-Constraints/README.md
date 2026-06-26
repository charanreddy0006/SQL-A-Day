# Day 16 - SQL Constraints

# Introduction

SQL Constraints are rules applied to table columns that control the type of data allowed in a table.

Constraints help maintain data accuracy, consistency, and integrity by preventing invalid data from being inserted or updated.

Almost every real-world database uses constraints to ensure reliable data.

---

# What are SQL Constraints?

A constraint is a rule that restricts the type of data that can be stored in a table.

Constraints help:

* Prevent duplicate data
* Prevent missing values
* Maintain relationships
* Improve data quality

---

# Why Do We Need Constraints?

Imagine a student database.

Without constraints:

* Two students could have the same Student ID.
* A student name could be left empty.
* A student's age could be entered as -5.

Constraints prevent these kinds of errors.

---

# Types of Constraints Learned Today

* PRIMARY KEY
* NOT NULL
* UNIQUE
* DEFAULT
* CHECK

---

# 1. PRIMARY KEY

A PRIMARY KEY uniquely identifies every row in a table.

### Properties

* Must be unique
* Cannot contain NULL values
* Only one PRIMARY KEY is allowed per table

### Example

```sql
student_id INT PRIMARY KEY
```

Valid:

| student_id |
| ---------- |
| 101        |
| 102        |
| 103        |

Invalid:

```text
101
101
```

Duplicate values are not allowed.

---

# 2. NOT NULL

NOT NULL ensures that a column must always contain a value.

### Example

```sql
student_name VARCHAR(50) NOT NULL
```

Valid:

```text
Chakri
Ram
```

Invalid:

```text
NULL
```

---

# 3. UNIQUE

UNIQUE ensures that all values in a column are different.

### Example

```sql
email VARCHAR(100) UNIQUE
```

Valid:

```text
chakri@gmail.com
ram@gmail.com
```

Invalid:

```text
ram@gmail.com
ram@gmail.com
```

---

# 4. DEFAULT

DEFAULT assigns a value automatically if no value is provided.

### Example

```sql
branch VARCHAR(20) DEFAULT 'CSE'
```

If branch is not supplied during insertion:

```sql
INSERT INTO students(student_id, student_name, email, age)
VALUES(102,'Ram','ram@gmail.com',19);
```

Stored value:

```text
branch = CSE
```

---

# 5. CHECK

CHECK validates data before it is stored.

### Example

```sql
age INT CHECK(age >= 17)
```

Valid:

```text
18
20
25
```

Invalid:

```text
15
-3
```

The database rejects invalid values.

---

# Complete Example

```sql
CREATE TABLE students(
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    branch VARCHAR(20) DEFAULT 'CSE',
    age INT CHECK(age >= 17)
);
```

---

# Real World Applications

## Banking

* Account Number → PRIMARY KEY
* Customer Name → NOT NULL

---

## E-Commerce

* Product ID → PRIMARY KEY
* Product Name → NOT NULL
* Product SKU → UNIQUE

---

## College Management

* Student ID → PRIMARY KEY
* Student Name → NOT NULL
* Email → UNIQUE
* Branch → DEFAULT
* Age → CHECK

---

## Hospital Management

* Patient ID → PRIMARY KEY
* Patient Name → NOT NULL
* Phone Number → UNIQUE

---

# Common Mistakes

## Duplicate Primary Keys

Incorrect:

```sql
student_id = 101
student_id = 101
```

---

## Forgetting NOT NULL

Trying to insert NULL into a required column causes an error.

---

## Violating UNIQUE

Duplicate email addresses are not allowed.

---

## Invalid CHECK Values

Trying to insert an age less than 17 violates the CHECK constraint.

---

# Practice Queries

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    branch VARCHAR(20) DEFAULT 'CSE',
    age INT CHECK(age >= 17)
);

SELECT * FROM students;
```

---

# Interview Questions

## What are SQL Constraints?

Rules that restrict the type of data allowed in a table.

---

## Can a PRIMARY KEY contain NULL?

No.

---

## What is the difference between PRIMARY KEY and UNIQUE?

PRIMARY KEY:

* Only one per table
* Cannot contain NULL

UNIQUE:

* Multiple UNIQUE constraints can exist
* Typically allows NULL values (database-dependent)

---

## What is the purpose of DEFAULT?

It automatically inserts a predefined value when no value is provided.

---

# Summary

Today I learned:

* SQL Constraints
* PRIMARY KEY
* NOT NULL
* UNIQUE
* DEFAULT
* CHECK

Constraints are essential for maintaining accurate, reliable, and consistent data in relational databases.
