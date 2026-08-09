# Day 58 - SQL Query Optimization & EXPLAIN

## Introduction

SQL Query Optimization is the process of improving a SQL query so that it executes efficiently while producing the same correct result.

Optimization becomes especially important when working with large databases.

A query that works quickly on a small table may become slow when millions of rows are stored.

---

# Why Query Optimization Matters

Poorly optimized queries can cause:

- Slow applications
- High CPU usage
- Excessive memory usage
- High disk I/O
- Database bottlenecks
- Poor user experience

Optimized queries can provide:

- Faster response times
- Lower resource usage
- Better scalability
- Improved application performance

---

# What is EXPLAIN?

`EXPLAIN` shows how MySQL plans to execute a query.

Example:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE salary > 70000;