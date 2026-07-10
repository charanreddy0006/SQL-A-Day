# Day 28 - BETWEEN Operator

# Introduction

The BETWEEN operator is used to retrieve values that fall within a specified range.

It works with:

- Numbers
- Dates
- Text

The BETWEEN operator includes both the starting value and the ending value.

It is commonly used in reports, dashboards, payroll systems, banking applications, and data analysis.

---

# What is the BETWEEN Operator?

BETWEEN checks whether a value lies within a given range.

If the value falls between the starting and ending values (inclusive), the row is returned.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE column_name BETWEEN value1 AND value2;
```

---

# Why Do We Need BETWEEN?

Suppose we want employees whose salary is between ₹55,000 and ₹75,000.

Without BETWEEN:

```sql
SELECT *
FROM employees
WHERE salary >= 55000
AND salary <= 75000;
```

Using BETWEEN:

```sql
SELECT *
FROM employees
WHERE salary BETWEEN 55000 AND 75000;
```

BETWEEN is shorter and easier to read.

---

# Example 1 - BETWEEN with Numbers

```sql
SELECT *
FROM employees
WHERE salary BETWEEN 55000 AND 75000;
```

This returns employees whose salary is between ₹55,000 and ₹75,000.

---

# Example 2 - BETWEEN with Age

```sql
SELECT *
FROM employees
WHERE age BETWEEN 25 AND 30;
```

Returns employees whose age is between 25 and 30 years.

---

# Example 3 - BETWEEN with Dates

```sql
SELECT *
FROM employees
WHERE joining_date
BETWEEN '2022-01-01'
AND '2023-12-31';
```

Returns employees who joined during 2022 and 2023.

---

# Example 4 - BETWEEN with Text

```sql
SELECT *
FROM employees
WHERE emp_name BETWEEN 'D' AND 'S';
```

Returns employee names alphabetically between D and S.

---

# Example 5 - NOT BETWEEN

```sql
SELECT *
FROM employees
WHERE salary NOT BETWEEN 55000 AND 75000;
```

Returns employees whose salary is outside the specified range.

---

# BETWEEN vs AND

Without BETWEEN

```sql
WHERE salary >= 55000
AND salary <= 75000;
```

Using BETWEEN

```sql
WHERE salary BETWEEN 55000 AND 75000;
```

Both queries produce the same result.

BETWEEN is cleaner and more readable.

---

# Important Note

BETWEEN includes both boundary values.

Example:

```sql
WHERE salary BETWEEN 55000 AND 75000;
```

Includes:

- 55000 ✅
- 75000 ✅

---

# Real-World Applications

## Banking

Display transactions between two dates.

```sql
WHERE transaction_date
BETWEEN '2025-01-01'
AND '2025-12-31';
```

---

## E-Commerce

Display products priced between ₹500 and ₹1000.

```sql
WHERE price BETWEEN 500 AND 1000;
```

---

## College Management

Display students whose marks are between 80 and 90.

```sql
WHERE marks BETWEEN 80 AND 90;
```

---

## Hospital Management

Display patients admitted between two dates.

```sql
WHERE admission_date
BETWEEN '2025-01-01'
AND '2025-01-31';
```

---

# Common Mistakes

## Reversing the Range

Incorrect

```sql
WHERE salary BETWEEN 75000 AND 55000;
```

Always write the smaller value first.

---

## Forgetting That BETWEEN is Inclusive

BETWEEN includes both the starting and ending values.

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE salary BETWEEN 55000 AND 75000;

SELECT *
FROM employees
WHERE age BETWEEN 25 AND 30;

SELECT *
FROM employees
WHERE joining_date
BETWEEN '2022-01-01'
AND '2023-12-31';

SELECT *
FROM employees
WHERE salary NOT BETWEEN 55000 AND 75000;
```

---

# Interview Questions

## What is the BETWEEN operator?

BETWEEN is used to retrieve values within a specified range.

---

## Does BETWEEN include the starting and ending values?

Yes. BETWEEN is inclusive.

---

## Can BETWEEN be used with dates?

Yes. It works with numbers, dates, and text.

---

## What is NOT BETWEEN?

It returns values outside the specified range.

---

# Summary

Today I learned:

- BETWEEN Operator
- NOT BETWEEN
- BETWEEN with Numbers
- BETWEEN with Dates
- BETWEEN with Text
- Difference Between BETWEEN and AND
- Real-World Applications

The BETWEEN operator is a clean and efficient way to filter values within a specified range.