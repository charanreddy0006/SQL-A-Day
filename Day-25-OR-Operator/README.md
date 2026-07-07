# Day 25 - OR Operator

# Introduction

The OR operator is used to combine two or more conditions in a SQL query.

Unlike the AND operator, the OR operator returns a row if **at least one condition is TRUE**.

The OR operator is commonly used with the WHERE clause when we want more flexible filtering.

---

# What is the OR Operator?

The OR operator joins multiple conditions together.

A record is returned if **any one** of the conditions is TRUE.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE condition1
OR condition2;
```

---

# Why Do We Need OR?

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

- Employees from the HR department
- **OR** employees from the IT department

Instead of writing separate queries, we can use OR.

---

# Example 1

```sql
SELECT *
FROM employees
WHERE department = 'HR'
OR department = 'IT';
```

### Output

| Employee | Department |
|----------|------------|
| John | HR |
| Emma | HR |
| David | IT |
| Robert | IT |

All HR and IT employees are returned.

---

# Example 2

```sql
SELECT *
FROM employees
WHERE salary > 70000
OR age > 30;
```

### Output

| Employee | Salary | Age |
|----------|---------|-----|
| Robert | 80000 | 35 |

Robert satisfies both conditions.

---

# Example 3

```sql
SELECT *
FROM employees
WHERE department = 'Finance'
OR age < 25;
```

### Output

| Employee | Department | Age |
|----------|------------|-----|
| Sophia | Finance | 29 |
| James | Finance | 24 |

Sophia matches the department condition.

James matches both conditions.

---

# How OR Works

Think of OR like this:

Condition 1 = TRUE

OR

Condition 2 = FALSE

↓

Result = TRUE ✅

Only when **all conditions are FALSE** does SQL exclude the row.

---

# AND vs OR

| AND | OR |
|-----|----|
| All conditions must be TRUE | At least one condition must be TRUE |
| Produces more specific results | Produces broader results |

Example:

```sql
WHERE department = 'IT'
AND salary > 70000;
```

Returns only employees satisfying both conditions.

```sql
WHERE department = 'IT'
OR salary > 70000;
```

Returns employees satisfying either condition.

---

# Real-World Applications

## Banking

Find customers from Hyderabad **or** Bengaluru.

---

## E-Commerce

Display products in the Electronics category **or** priced below ₹1000.

---

## College Management

Find students from the AIML branch **or** students with CGPA above 9.0.

---

## Hospital Management

Find patients admitted to Cardiology **or** Neurology.

---

# Common Mistakes

## Using OR Instead of AND

OR returns more rows because only one condition needs to be TRUE.

Always choose the operator based on the requirement.

---

## Forgetting Quotes Around Text

Incorrect:

```sql
WHERE department = HR
```

Correct:

```sql
WHERE department = 'HR'
```

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE department = 'HR'
OR department = 'IT';

SELECT *
FROM employees
WHERE salary > 70000
OR age > 30;

SELECT *
FROM employees
WHERE department = 'Finance'
OR age < 25;
```

---

# Interview Questions

## What is the OR operator?

The OR operator combines multiple conditions and returns rows if at least one condition is TRUE.

---

## What is the difference between AND and OR?

AND requires all conditions to be TRUE.

OR requires only one condition to be TRUE.

---

## Can OR be used with WHERE?

Yes. It is commonly used with the WHERE clause.

---

# Summary

Today I learned:

- OR Operator
- WHERE with OR
- Multiple Conditions
- Difference Between AND and OR
- Real-World Applications

The OR operator helps retrieve records when one or more specified conditions are satisfied.