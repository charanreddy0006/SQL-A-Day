# Day 24 - AND Operator

# Introduction

The AND operator is used to combine two or more conditions in a SQL query.

When using AND, **every condition must be TRUE** for a row to be returned.

The AND operator is commonly used with the WHERE clause to filter data more precisely.

---

# What is the AND Operator?

The AND operator joins multiple conditions together.

A record is returned only if **all conditions are satisfied**.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE condition1
AND condition2;
```

---

# Why Do We Need AND?

Suppose we have the following employee table:

| Employee | Department | Salary | Age |
|----------|------------|---------|-----|
| John | HR | 50000 | 25 |
| David | IT | 70000 | 30 |
| Emma | HR | 55000 | 28 |
| Robert | IT | 80000 | 35 |
| Sophia | Finance | 65000 | 29 |
| James | Finance | 60000 | 24 |

Now imagine we want:

- Only IT employees
- And salary greater than 70000

One condition is not enough.

We combine both conditions using AND.

---

# Example 1

```sql
SELECT *
FROM employees
WHERE department = 'IT'
AND salary > 70000;
```

Output:

| Employee | Department | Salary |
|----------|------------|---------|
| Robert | IT | 80000 |

Only Robert satisfies both conditions.

---

# Example 2

```sql
SELECT *
FROM employees
WHERE department = 'HR'
AND age > 25;
```

Output:

| Employee | Department | Age |
|----------|------------|-----|
| Emma | HR | 28 |

Emma belongs to HR and is older than 25.

---

# Example 3

```sql
SELECT *
FROM employees
WHERE department = 'Finance'
AND salary > 60000;
```

Output:

| Employee | Salary |
|----------|---------|
| Sophia | 65000 |

---

# How AND Works

Think of AND like this:

Condition 1 = TRUE

AND

Condition 2 = TRUE

↓

Result = TRUE ✅

If even one condition is FALSE, the row is not returned.

---

# Real-World Applications

## Banking

Find customers whose account balance is greater than ₹50,000 **and** account status is Active.

---

## E-Commerce

Find products in the Electronics category **and** price less than ₹20,000.

---

## College Management

Find students in the AIML branch **and** CGPA greater than 8.5.

---

## Hospital Management

Find patients older than 60 **and** admitted to the Cardiology department.

---

# Common Mistakes

## Using AND when OR is needed

AND requires all conditions to be true.

If only one condition needs to be true, use OR instead.

---

## Incorrect Column Names

Always verify that the column names in the WHERE clause exist in the table.

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE department = 'IT'
AND salary > 70000;

SELECT *
FROM employees
WHERE department = 'HR'
AND age > 25;

SELECT *
FROM employees
WHERE department = 'Finance'
AND salary > 60000;
```

---

# Interview Questions

## What is the AND operator?

The AND operator combines multiple conditions, and all conditions must be TRUE for a row to be returned.

---

## Can AND be used with WHERE?

Yes. AND is commonly used with the WHERE clause.

---

## Which operator requires every condition to be TRUE?

AND.

---

# Summary

Today I learned:

- AND Operator
- Multiple Conditions
- WHERE with AND
- Filtering Records
- Real-World Applications

The AND operator helps retrieve highly specific data by ensuring that every condition in the query is satisfied.