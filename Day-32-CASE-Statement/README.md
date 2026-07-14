# Day 32 - CASE Statement

# Introduction

The CASE statement is used to perform conditional logic in SQL.

It works similarly to the **if-else statement** found in programming languages.

Using CASE, we can display different values depending on different conditions.

CASE is commonly used in:

- Reports
- Dashboards
- Data Analysis
- Salary Classification
- Student Grades
- Business Intelligence

---

# What is CASE?

CASE checks conditions one by one.

When a condition becomes TRUE, SQL returns the corresponding result.

If no condition is TRUE, the ELSE block is executed.

---

# Syntax

```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ELSE result
END
```

---

# Why Do We Need CASE?

Suppose employees have different salaries.

Instead of displaying only numbers,

```
85000
70000
50000
```

We can classify them as

```
High Salary
Medium Salary
Low Salary
```

This makes reports much easier to understand.

---

# Example 1 - Salary Classification

```sql
SELECT
emp_name,
salary,
CASE
    WHEN salary >= 80000 THEN 'High Salary'
    WHEN salary >= 60000 THEN 'Medium Salary'
    ELSE 'Low Salary'
END AS Salary_Category
FROM employees;
```

### Output

| Employee | Salary | Category |
|-----------|---------|------------|
|John|50000|Low Salary|
|David|70000|Medium Salary|
|Robert|85000|High Salary|

---

# Example 2 - Age Classification

```sql
CASE
WHEN age < 25 THEN 'Young'
WHEN age BETWEEN 25 AND 30 THEN 'Adult'
ELSE 'Senior'
END
```

Output

| Age | Category |
|------|----------|
|24|Young|
|25|Adult|
|30|Adult|
|35|Senior|

---

# Example 3 - Department Names

Instead of abbreviations,

```
HR
IT
```

Display

```
Human Resources
Information Technology
```

using CASE.

---

# Example 4 - CASE with ORDER BY

CASE can also control sorting.

Example:

```sql
ORDER BY
CASE
WHEN department='IT' THEN 1
WHEN department='Finance' THEN 2
WHEN department='HR' THEN 3
END;
```

Employees will appear in the order:

1. IT
2. Finance
3. HR

instead of alphabetical order.

---

# CASE vs IF

| CASE | IF |
|------|----|
|ANSI SQL Standard|MySQL-specific|
|Works in most databases|Works mainly in MySQL|
|Preferred for portability|Useful only in MySQL|

---

# Real-World Applications

## Banking

Classify customers

- Premium
- Gold
- Silver

based on account balance.

---

## E-Commerce

Display product prices as

- Budget
- Mid-Range
- Premium

---

## College Management

Convert marks into grades.

```
90+ = A
80+ = B
70+ = C
```

---

## Hospital

Classify patients as

- Critical
- Stable
- Normal

---

# Common Mistakes

## Forgetting END

Incorrect

```sql
CASE
WHEN salary>50000 THEN 'High'
```

Correct

```sql
CASE
WHEN salary>50000 THEN 'High'
END
```

---

## Forgetting ELSE

ELSE is optional.

However, adding ELSE makes queries easier to understand because every row gets a result.

---

# Practice Queries

```sql
SELECT
emp_name,
salary,
CASE
WHEN salary>=80000 THEN 'High'
WHEN salary>=60000 THEN 'Medium'
ELSE 'Low'
END AS Category
FROM employees;

SELECT
emp_name,
department,
CASE
WHEN department='HR' THEN 'Human Resources'
WHEN department='IT' THEN 'Information Technology'
ELSE 'Other'
END
FROM employees;
```

---

# Interview Questions

## What is CASE?

CASE is a conditional expression used to implement if-else logic in SQL.

---

## Can CASE be used inside SELECT?

Yes.

---

## Can CASE be used inside ORDER BY?

Yes.

---

## Is CASE standard SQL?

Yes.

CASE is supported by almost every relational database.

---

# Summary

Today I learned:

- CASE Statement
- WHEN
- THEN
- ELSE
- END
- CASE with SELECT
- CASE with ORDER BY
- Salary Classification
- Real-World Applications

The CASE statement allows SQL queries to make decisions and display meaningful results based on conditions.