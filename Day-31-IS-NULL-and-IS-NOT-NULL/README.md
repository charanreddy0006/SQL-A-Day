# Day 31 - IS NULL and IS NOT NULL

# Introduction

In SQL, sometimes information is unknown or not available.

For example:

- A customer has not entered their phone number.
- An employee has not provided an email address.
- A student has not submitted their marks.

In these situations, SQL stores the value as **NULL**.

NULL does not mean zero or an empty string.

It simply means **the value is unknown or missing**.

---

# What is NULL?

NULL represents missing, unknown, or unavailable data.

Example:

| Employee | Email |
|----------|----------------|
| John | john@gmail.com |
| David | NULL |

David's email is unknown.

---

# Syntax

## IS NULL

```sql
SELECT *
FROM table_name
WHERE column_name IS NULL;
```

Returns rows where the value is NULL.

---

## IS NOT NULL

```sql
SELECT *
FROM table_name
WHERE column_name IS NOT NULL;
```

Returns rows where the value exists.

---

# Why Can't We Use = NULL?

Incorrect

```sql
SELECT *
FROM employees
WHERE email = NULL;
```

This returns no rows.

Correct

```sql
SELECT *
FROM employees
WHERE email IS NULL;
```

SQL provides the IS NULL operator specifically for checking NULL values.

---

# Example 1 - IS NULL

```sql
SELECT *
FROM employees
WHERE email IS NULL;
```

Output

| Employee | Email |
|----------|--------|
| David | NULL |
| Robert | NULL |
| James | NULL |

---

# Example 2 - IS NOT NULL

```sql
SELECT *
FROM employees
WHERE email IS NOT NULL;
```

Returns employees whose email addresses are available.

---

# Example 3 - Phone Number is NULL

```sql
SELECT *
FROM employees
WHERE phone IS NULL;
```

Returns employees without phone numbers.

---

# Example 4 - Multiple NULL Conditions

```sql
SELECT *
FROM employees
WHERE email IS NULL
AND phone IS NULL;
```

Returns employees missing both email and phone.

---

# Difference Between NULL, 0 and ''

| Value | Meaning |
|-------|---------|
| NULL | Unknown or missing value |
| 0 | Numeric zero |
| '' | Empty string (no characters) |

Example

Age = 0

Means age is zero.

Age = NULL

Means age is unknown.

Name = ''

Means the name field is empty.

---

# Real-World Applications

## Banking

Find customers who have not provided an email.

```sql
WHERE email IS NULL;
```

---

## E-Commerce

Find products without images.

```sql
WHERE image_url IS NULL;
```

---

## College Management

Find students whose marks are not uploaded.

```sql
WHERE marks IS NULL;
```

---

## Hospital Management

Find patients whose insurance details are missing.

```sql
WHERE insurance_number IS NULL;
```

---

# Common Mistakes

## Using = NULL

Incorrect

```sql
WHERE email = NULL;
```

Correct

```sql
WHERE email IS NULL;
```

---

## Confusing NULL with Empty String

NULL

Means the value is unknown.

''

Means the value exists but contains no characters.

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE email IS NULL;

SELECT *
FROM employees
WHERE email IS NOT NULL;

SELECT *
FROM employees
WHERE phone IS NULL;

SELECT *
FROM employees
WHERE phone IS NOT NULL;
```

---

# Interview Questions

## What is NULL?

NULL represents missing or unknown data.

---

## Which operator checks NULL values?

IS NULL

---

## Which operator checks non-NULL values?

IS NOT NULL

---

## Can we use = NULL?

No.

We must use IS NULL.

---

# Summary

Today I learned:

- NULL
- IS NULL
- IS NOT NULL
- Difference between NULL, 0 and ''
- Why = NULL does not work
- Real-World Applications

Handling NULL values correctly is an essential SQL skill because missing data is common in real-world databases.