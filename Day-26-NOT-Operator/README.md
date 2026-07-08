# Day 26 - NOT Operator

# Introduction

The NOT operator is used to reverse a condition.

It returns records that **do not satisfy** a specified condition.

The NOT operator is commonly used with the WHERE clause to exclude particular rows from query results.

---

# What is the NOT Operator?

The NOT operator negates a condition.

If a condition is TRUE, NOT makes it FALSE.

If a condition is FALSE, NOT makes it TRUE.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE NOT condition;
```

---

# Why Do We Need NOT?

Suppose we have the following employee table.

| Employee | Department | Salary | Age |
|----------|------------|---------|-----|
| John | HR | 50000 | 25 |
| David | IT | 70000 | 30 |
| Emma | HR | 55000 | 28 |
| Robert | IT | 80000 | 35 |
| Sophia | Finance | 65000 | 29 |
| James | Finance | 60000 | 24 |

Now imagine we want:

- Employees who are **not** in the HR department.

Instead of selecting HR employees, we can simply exclude them.

---

# Example 1

```sql
SELECT *
FROM employees
WHERE NOT department = 'HR';
```

### Output

| Employee | Department |
|----------|------------|
| David | IT |
| Robert | IT |
| Sophia | Finance |
| James | Finance |

HR employees are excluded.

---

# Example 2

```sql
SELECT *
FROM employees
WHERE NOT age > 30;
```

This returns employees whose age is **30 or below**.

---

# Example 3

```sql
SELECT *
FROM employees
WHERE NOT department = 'Finance';
```

Finance employees are excluded.

---

# NOT with AND

```sql
SELECT *
FROM employees
WHERE NOT (department='IT' AND salary>70000);
```

This excludes employees who satisfy both conditions.

---

# Difference Between NOT, != and <>

All three can be used to exclude values.

Using NOT

```sql
WHERE NOT department='HR';
```

Using !=

```sql
WHERE department != 'HR';
```

Using <>

```sql
WHERE department <> 'HR';
```

All three produce the same result in MySQL.

However, **<>** is the SQL standard operator and works across different database systems.

---

# How NOT Works

Condition:

```
department = 'HR'
```

Result:

```
TRUE
```

After applying NOT:

```
NOT TRUE

↓

FALSE
```

Therefore, the row is excluded.

---

# Real-World Applications

## Banking

Display customers who are **not** from Hyderabad.

---

## E-Commerce

Display products **not** in the Electronics category.

---

## College Management

Display students **not** in the AIML branch.

---

## Hospital Management

Display patients **not** admitted to the ICU.

---

# Common Mistakes

## Forgetting Parentheses

Incorrect

```sql
WHERE NOT department='IT'
AND salary>70000;
```

Correct

```sql
WHERE NOT (department='IT' AND salary>70000);
```

Parentheses make the condition easier to understand.

---

## Confusing NOT with !=

NOT can negate entire expressions.

!= compares two values.

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE NOT department='HR';

SELECT *
FROM employees
WHERE NOT age>30;

SELECT *
FROM employees
WHERE department <> 'Finance';

SELECT *
FROM employees
WHERE department != 'Finance';
```

---

# Interview Questions

## What is the NOT operator?

The NOT operator reverses a condition.

---

## What does NOT do?

It returns rows that do **not** satisfy a condition.

---

## Difference between != and <> ?

In MySQL both behave the same.

However, **<>** is the ANSI SQL standard operator.

---

## Can NOT be used with AND and OR?

Yes.

NOT can be combined with both operators.

---

# Summary

Today I learned:

- NOT Operator
- WHERE NOT
- NOT with AND
- != Operator
- <> Operator
- Difference between NOT and !=
- Real-World Applications

The NOT operator is used to exclude rows by reversing a condition. It is one of the most useful filtering operators in SQL.