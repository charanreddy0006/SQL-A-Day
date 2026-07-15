# Day 33 - IFNULL() and COALESCE()

# Introduction

In SQL, NULL represents missing or unknown data.

Sometimes, displaying NULL in reports or applications is not user-friendly.

Instead of showing NULL, we may want to display:

- "Not Available"
- "Unknown"
- "No Contact"
- "N/A"

SQL provides IFNULL() and COALESCE() functions for this purpose.

---

# What is IFNULL()?

IFNULL() checks whether a value is NULL.

If the value is NULL, it returns another value specified by us.

Otherwise, it returns the original value.

---

# Syntax

```sql
IFNULL(column_name, replacement_value)
```

---

# Example

```sql
SELECT
emp_name,
IFNULL(email,'Email Not Available')
FROM employees;
```

### Output

| Employee | Email |
|-----------|----------------------|
|John|john@gmail.com|
|David|Email Not Available|
|Emma|emma@gmail.com|
|Robert|Email Not Available|

---

# What is COALESCE()?

COALESCE() returns the first non-NULL value from a list of values.

Unlike IFNULL(), it can check multiple columns.

---

# Syntax

```sql
COALESCE(value1,value2,value3,...)
```

SQL checks values from left to right.

The first non-NULL value is returned.

---

# Example

```sql
SELECT
emp_name,
COALESCE(phone,email,'No Contact Information')
FROM employees;
```

### Output

| Employee | Contact |
|-----------|--------------------|
|John|9876543210|
|David|9876543211|
|Emma|emma@gmail.com|
|Robert|No Contact Information|

---

# Difference Between IFNULL() and COALESCE()

| IFNULL() | COALESCE() |
|-----------|------------|
|Accepts only 2 arguments|Accepts multiple arguments|
|MySQL-specific|ANSI SQL Standard|
|Simpler for one replacement|Better for multiple fallback values|

---

# When Should We Use IFNULL()?

Use IFNULL() when:

- You only need one replacement value.
- Working mainly with MySQL.

Example:

```sql
IFNULL(email,'Not Available')
```

---

# When Should We Use COALESCE()?

Use COALESCE() when:

- You want to check multiple columns.
- You need better portability across databases.

Example:

```sql
COALESCE(phone,email,'No Contact')
```

---

# Real-World Applications

## Banking

Display "No Email" if a customer email is missing.

---

## E-Commerce

Display "No Product Image" if an image is unavailable.

---

## College Management

Display "Marks Not Uploaded" if marks are NULL.

---

## Hospital Management

Display "Insurance Not Available" if insurance details are missing.

---

# Common Mistakes

## Confusing IFNULL() and IS NULL

IS NULL is used to filter rows.

IFNULL() replaces NULL values.

---

## Using IFNULL() with Multiple Values

Incorrect

```sql
IFNULL(phone,email,'No Contact')
```

Correct

```sql
COALESCE(phone,email,'No Contact')
```

---

# Practice Queries

```sql
SELECT
emp_name,
IFNULL(email,'Email Not Available')
FROM employees;

SELECT
emp_name,
COALESCE(phone,email,'No Contact')
FROM employees;
```

---

# Interview Questions

## What is IFNULL()?

IFNULL() replaces NULL with a specified value.

---

## What is COALESCE()?

COALESCE() returns the first non-NULL value from a list.

---

## Which function accepts multiple arguments?

COALESCE().

---

## Which function is ANSI SQL Standard?

COALESCE().

---

# Summary

Today I learned:

- IFNULL()
- COALESCE()
- Replacing NULL Values
- Difference Between IFNULL() and COALESCE()
- Real-World Applications

IFNULL() and COALESCE() make SQL query results cleaner and more user-friendly by replacing NULL values with meaningful text.