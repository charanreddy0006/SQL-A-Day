# Day 27 - IN Operator

# Introduction

The IN operator is used to compare a column against multiple values.

Instead of writing multiple OR conditions, the IN operator allows us to write cleaner, shorter, and more readable SQL queries.

The IN operator is one of the most frequently used filtering operators in SQL.

---

# What is the IN Operator?

The IN operator checks whether a value exists in a list of values.

If the value matches any value in the list, the row is returned.

---

# Syntax

```sql
SELECT column_name
FROM table_name
WHERE column_name IN (value1, value2, value3);
```

---

# Why Do We Need IN?

Suppose we want employees from:

- HR
- IT
- Finance

Without IN:

```sql
SELECT *
FROM employees
WHERE department = 'HR'
OR department = 'IT'
OR department = 'Finance';
```

This works, but the query becomes long as more values are added.

Using IN:

```sql
SELECT *
FROM employees
WHERE department IN ('HR','IT','Finance');
```

This is much shorter and easier to read.

---

# Example 1 - IN with Text Values

```sql
SELECT *
FROM employees
WHERE department IN ('HR','IT');
```

### Output

| Employee | Department |
|----------|------------|
| John | HR |
| Emma | HR |
| David | IT |
| Robert | IT |

Only employees belonging to HR or IT are displayed.

---

# Example 2 - IN with Numeric Values

```sql
SELECT *
FROM employees
WHERE emp_id IN (101,103,106);
```

Only employees with these IDs are displayed.

---

# Example 3 - NOT IN

The NOT IN operator excludes values.

```sql
SELECT *
FROM employees
WHERE department NOT IN ('HR','IT');
```

Output:

| Employee | Department |
|----------|------------|
| Sophia | Finance |
| James | Finance |

HR and IT employees are excluded.

---

# Example 4 - IN with Age

```sql
SELECT *
FROM employees
WHERE age IN (24,28,35);
```

Returns employees whose age is 24, 28, or 35.

---

# Example 5 - IN with Salary

```sql
SELECT *
FROM employees
WHERE salary IN (60000,80000);
```

Returns employees whose salary is either 60000 or 80000.

---

# IN vs OR

Using OR

```sql
WHERE department='HR'
OR department='IT'
OR department='Finance';
```

Using IN

```sql
WHERE department IN ('HR','IT','Finance');
```

Both produce the same result.

However, IN is shorter, cleaner, and easier to maintain.

---

# Real-World Applications

## Banking

Display customers from selected cities.

```sql
WHERE city IN ('Hyderabad','Delhi','Mumbai');
```

---

## E-Commerce

Display products from selected categories.

```sql
WHERE category IN ('Electronics','Mobiles','Laptops');
```

---

## College Management

Display students from selected branches.

```sql
WHERE branch IN ('CSE','AIML','IT');
```

---

## Hospital Management

Display patients admitted to selected departments.

```sql
WHERE department IN ('Cardiology','Neurology');
```

---

# Common Mistakes

## Forgetting Parentheses

Incorrect

```sql
WHERE department IN 'HR','IT';
```

Correct

```sql
WHERE department IN ('HR','IT');
```

---

## Forgetting Quotes Around Text Values

Incorrect

```sql
WHERE department IN (HR,IT);
```

Correct

```sql
WHERE department IN ('HR','IT');
```

---

# Practice Queries

```sql
SELECT *
FROM employees
WHERE department IN ('HR','Finance');

SELECT *
FROM employees
WHERE emp_id IN (101,104);

SELECT *
FROM employees
WHERE department NOT IN ('IT');
```

---

# Interview Questions

## What is the IN operator?

The IN operator checks whether a value matches any value in a list.

---

## Why is IN preferred over multiple OR conditions?

Because it makes queries shorter, cleaner, and easier to read.

---

## What is NOT IN?

NOT IN returns rows whose values are not present in the specified list.

---

# Summary

Today I learned:

- IN Operator
- NOT IN Operator
- IN with Text Values
- IN with Numeric Values
- Difference Between IN and OR
- Real-World Applications

The IN operator is an efficient way to compare a column against multiple values and is widely used in SQL queries.