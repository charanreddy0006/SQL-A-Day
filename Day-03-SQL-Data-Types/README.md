# Day 03 - SQL Data Types

## Introduction

Data Types define the kind of data that can be stored in a table column. Choosing the correct data type improves storage efficiency, data accuracy, and query performance.

For example:

* Employee ID should store numbers.
* Employee Name should store text.
* Joining Date should store dates.
* Salary should store decimal values.

Therefore, SQL provides different data types for different kinds of information.

---

# What is a Data Type?

A Data Type specifies the type of value that a column can hold.

Example:

```sql
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50)
);
```

Here:

* emp_id stores numbers.
* emp_name stores text.

---

# Numeric Data Types

Numeric data types store numbers.

## INT

Stores whole numbers.

### Example

```sql
emp_id INT
```

Values:

```text
1
100
5000
```

---

## BIGINT

Stores very large whole numbers.

### Example

```sql
mobile_number BIGINT
```

Values:

```text
9876543210
123456789012
```

---

## DECIMAL

Stores exact decimal values.

### Example

```sql
salary DECIMAL(10,2)
```

Values:

```text
50000.00
65000.50
75000.75
```

Used for:

* Salary
* Banking Applications
* Financial Calculations

---

## FLOAT

Stores approximate decimal values.

### Example

```sql
temperature FLOAT
```

Values:

```text
35.5
42.8
19.7
```

---

# String Data Types

String data types store text.

## CHAR

Stores fixed-length text.

### Example

```sql
gender CHAR(1)
```

Values:

```text
M
F
```

---

## VARCHAR

Stores variable-length text.

### Example

```sql
name VARCHAR(50)
```

Values:

```text
John
David
Emma Watson
```

Most commonly used text data type.

---

## TEXT

Stores large amounts of text.

### Example

```sql
description TEXT
```

Used for:

* Comments
* Reviews
* Articles
* Product Descriptions

---

# Date and Time Data Types

## DATE

Stores only dates.

### Format

```text
YYYY-MM-DD
```

### Example

```sql
joining_date DATE
```

Value:

```text
2026-06-09
```

---

## TIME

Stores only time.

### Example

```sql
login_time TIME
```

Value:

```text
09:30:15
```

---

## DATETIME

Stores both date and time.

### Example

```sql
created_at DATETIME
```

Value:

```text
2026-06-09 09:30:15
```

---

## TIMESTAMP

Stores date and time and can automatically track record creation or updates.

Used in:

* Login Systems
* Audit Logs
* Activity Tracking

---

# Boolean Data Type

Stores TRUE or FALSE values.

### Example

```sql
is_active BOOLEAN
```

Values:

```text
TRUE
FALSE
```

---

# Choosing the Right Data Type

| Data            | Recommended Data Type |
| --------------- | --------------------- |
| Employee ID     | INT                   |
| Name            | VARCHAR               |
| Salary          | DECIMAL               |
| Date of Joining | DATE                  |
| Login Time      | TIME                  |
| Description     | TEXT                  |
| Status          | BOOLEAN               |

---

# Practical Example

```sql
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date DATE,
    login_time TIME,
    created_at DATETIME
);
```

---

# Real-World Applications

Data types are used in:

* Banking Systems
* Hospital Management Systems
* E-Commerce Platforms
* Student Management Systems
* Social Media Applications

Selecting the correct data type ensures efficient storage and accurate data processing.

---

# Summary

Today I learned:

* What Data Types are
* INT
* BIGINT
* DECIMAL
* FLOAT
* CHAR
* VARCHAR
* TEXT
* DATE
* TIME
* DATETIME
* TIMESTAMP
* BOOLEAN

Understanding data types is essential because every table column must be assigned an appropriate data type before storing information.
