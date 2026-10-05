# SQL-A-Day — Day 85: Slowly Changing Dimensions (SCD)

---

## 📌 Topic

**Slowly Changing Dimensions (SCD)** are a Data Warehousing technique for handling changes in dimension attributes while deciding how much historical information should be retained.

Example:

```text
Customer 101
Rajkot
   ↓
Ahmedabad
```

The main question is whether `Rajkot` should be lost or preserved.

---

## 🎯 Learning Objectives

By completing this project you will understand:

- Dimension tables
- SCD Type 1
- SCD Type 2
- SCD Type 3
- Surrogate keys
- `valid_from`
- `valid_to`
- `is_current`
- Change detection
- Historical versions
- Point-in-time reporting
- SCD data-quality checks
- Data-warehouse ETL/ELT patterns

---

## 🧠 What Is a Dimension?

A dimension describes business entities in a data warehouse.

Examples:

```text
Customer Dimension
Product Dimension
Employee Dimension
Store Dimension
Date Dimension
```

A customer dimension may contain:

```text
customer_id
customer_name
email
city
segment
```

When one of these attributes changes, an SCD strategy determines what happens.

---

# 🔄 SCD Types

```text
                 Slowly Changing Dimensions
                           │
            ┌──────────────┼──────────────┐
            │              │              │
         Type 1          Type 2         Type 3
            │              │              │
        Overwrite      Full History   Limited History
            │              │              │
       Old value lost   New version    Current + Previous
```

---

# 1️⃣ SCD Type 1 — Overwrite

Type 1 replaces the old value.

Before:

```text
customer_id | city
101         | Rajkot
```

After:

```text
customer_id | city
101         | Ahmedabad
```

The old value is not retained.

### SQL

```sql
UPDATE dim_customer_type1
SET city='Ahmedabad'
WHERE customer_id=101;
```

### When to use it

Use Type 1 when:

- History is not required.
- You are correcting bad data.
- Only the latest state matters.
- You do not need historical reporting.

---

# 2️⃣ SCD Type 2 — Full History

Type 2 creates a new row/version whenever tracked attributes change.

Example:

```text
customer_id | city       | valid_from | valid_to   | is_current
101         | Rajkot     | 2026-01-10 | 2026-02-01 | 0
101         | Ahmedabad  | 2026-02-01 | NULL       | 1
```

The complete history is preserved.

---

## 🏷️ Surrogate Key

A Type 2 dimension commonly uses a surrogate key:

```text
customer_sk
```

Example:

```text
customer_sk | customer_id | city
1           | 101         | Rajkot
2           | 101         | Ahmedabad
```

The business/customer ID remains `101`, while each historical version gets a different surrogate key.

---

## 📅 valid_from

Defines when a version becomes active.

```text
valid_from = 2026-02-01
```

---

## 📅 valid_to

Defines when a version stops being active.

The current version commonly has:

```text
valid_to = NULL
```

---

## 🚦 is_current

Identifies the active version.

```text
customer_id | city       | is_current
101         | Rajkot     | FALSE
101         | Ahmedabad  | TRUE
```

---

# 🔍 Detecting Changes

The incoming source record can be compared with the current dimension record.

```sql
SELECT
    s.customer_id,
    d.city AS old_city,
    s.city AS new_city
FROM customer_changes s
JOIN dim_customer_type2 d
  ON s.customer_id=d.customer_id
 AND d.is_current=TRUE
WHERE NOT (
    s.customer_name <=> d.customer_name
    AND s.email <=> d.email
    AND s.city <=> d.city
    AND s.segment <=> d.segment
);
```

The MySQL `<=>` operator performs a NULL-safe comparison.

---

# 🔄 Type 2 ETL Flow

```text
Source
  │
  ▼
Compare with current dimension
  │
  ├── No change ──► Do nothing
  │
  └── Changed
        │
        ▼
   Close old version
        │
        ▼
   Insert new version
        │
        ▼
   Mark new version current
```

---

# 🔒 Closing an Old Version

```sql
UPDATE dim_customer_type2
SET
    valid_to='2026-02-01 09:00:00',
    is_current=FALSE
WHERE customer_id=101
  AND is_current=TRUE;
```

The historical record remains in the table.

---

# ➕ Inserting the New Version

```sql
INSERT INTO dim_customer_type2
(
    customer_id,
    customer_name,
    email,
    city,
    segment,
    valid_from,
    valid_to,
    is_current
)
VALUES
(
    101,
    'Aarav Sharma',
    'aarav@example.com',
    'Ahmedabad',
    'Premium',
    '2026-02-01 09:00:00',
    NULL,
    TRUE
);
```

---

# 🕐 Point-in-Time Reporting

One major advantage of Type 2 is historical reporting.

For example:

> Which customer version was valid on February 6, 2026?

```sql
SELECT
    customer_id,
    customer_name,
    city,
    segment
FROM dim_customer_type2
WHERE '2026-02-06 12:00:00' >= valid_from
  AND (
      valid_to IS NULL
      OR '2026-02-06 12:00:00' < valid_to
  );
```

This allows historical reports to use the correct dimension state for a particular point in time.

---

# 3️⃣ SCD Type 3 — Limited History

Type 3 stores the current value plus a limited previous value.

Example:

```text
customer_id | current_city | previous_city
101         | Ahmedabad    | Rajkot
```

If the customer later moves to Mumbai:

```text
current_city  = Mumbai
previous_city = Ahmedabad
```

The older Rajkot value is no longer retained.

Therefore:

```text
Type 2 → Complete history
Type 3 → Limited history
```

---

# 🆚 Type 1 vs Type 2 vs Type 3

| Feature | Type 1 | Type 2 | Type 3 |
|---|---|---|---|
| Old value preserved | ❌ | ✅ | Partially |
| Full history | ❌ | ✅ | ❌ |
| New row created | ❌ | ✅ | ❌ |
| Complexity | Low | Medium/High | Medium |
| Historical reporting | ❌ | ✅ | Limited |
| Storage | Low | Higher | Low |

---

# 🏢 Real-World Applications

### Customer address

```text
Rajkot
  ↓
Ahmedabad
  ↓
Mumbai
```

Type 2 can preserve the complete history.

### Employee department

```text
Engineering
  ↓
Data Engineering
  ↓
AI/ML
```

Historical department assignments can be retained.

### Customer segment

```text
Standard
  ↓
Premium
  ↓
Enterprise
```

Historical segments can be preserved for analytics.

---

# 📊 SCD in a Data Engineering Pipeline

```text
Source Systems
      │
      ▼
    Extract
      │
      ▼
   Staging
      │
      ▼
Compare Changes
      │
      ▼
SCD Transformation
      │
      ▼
Dimension Table
      │
      ▼
Data Warehouse
      │
      ▼
BI / Analytics
```

SCD concepts are relevant when working with platforms and tools such as:

- Snowflake
- BigQuery
- Redshift
- Databricks
- Spark
- dbt
- Airflow

---

# 🧪 Data Quality Checks

### More than one current version

```sql
SELECT customer_id, COUNT(*) AS current_count
FROM dim_customer_type2
WHERE is_current=TRUE
GROUP BY customer_id
HAVING COUNT(*)>1;
```

Ideally this returns zero rows.

### Current row with `valid_to`

```sql
SELECT *
FROM dim_customer_type2
WHERE is_current=TRUE
  AND valid_to IS NOT NULL;
```

### Historical row without `valid_to`

```sql
SELECT *
FROM dim_customer_type2
WHERE is_current=FALSE
  AND valid_to IS NULL;
```

### Invalid date range

```sql
SELECT *
FROM dim_customer_type2
WHERE valid_to IS NOT NULL
  AND valid_to<=valid_from;
```

---

# 💡 Interview Questions

### 1. What is an SCD?

A technique for managing changes to dimension attributes over time.

### 2. What is SCD Type 1?

Overwrite the existing value without retaining history.

### 3. What is SCD Type 2?

Create a new version of the dimension record and preserve the old version.

### 4. What is SCD Type 3?

Store the current value and limited previous history.

### 5. Which type gives complete history?

**Type 2.**

### 6. Why use a surrogate key?

Each historical version needs its own unique dimension-row identifier.

### 7. What do `valid_from` and `valid_to` represent?

The validity period of a dimension version.

### 8. Why use `is_current`?

To quickly identify the active dimension version.

---

# 🧪 Practice Questions

1. Find all current customers.
2. Find all historical records.
3. Count versions for every customer.
4. Find customers with more than one version.
5. Find the first city of every customer.
6. Find customers whose city changed.
7. Find customers whose segment changed.
8. Find the customer with the most versions.
9. Calculate the duration of each historical version.
10. Find the latest version using `ROW_NUMBER()`.
11. Find versions valid during February 2026.
12. Detect customers whose city and segment changed.
13. Find customers who changed cities more than once.
14. Detect overlapping validity periods.
15. Build:

```text
customer_id
first_city
current_city
number_of_changes
```

---

# ⚠️ Common Mistakes

### Mistake 1 — Updating Type 2 directly

```sql
UPDATE dim_customer_type2
SET city='Ahmedabad'
WHERE customer_id=101;
```

This destroys the historical value.

### Mistake 2 — Forgetting to close the old version

Type 2 normally requires:

```text
Close old version
       +
Insert new version
```

### Mistake 3 — Multiple current versions

A customer should normally have only one:

```text
is_current = TRUE
```

record.

### Mistake 4 — Invalid validity ranges

Avoid:

```text
valid_from = 2026-05-01
valid_to   = 2026-04-01
```

---

# 📁 Project Structure

```text
Day-85-SQL-Slowly-Changing-Dimensions/
│
├── day85.sql
└── README.md
```

---

# ▶️ How to Run

Open MySQL Workbench, MySQL Shell, or your VS Code SQL environment.

Run:

```sql
SOURCE path/to/day85.sql;
```

The script creates:

```text
sql_scd_lab
```

---

# 🔑 Remember

```text
SCD Type 1
    ↓
Overwrite
    ↓
No history

SCD Type 2
    ↓
New row/version
    ↓
Complete history

SCD Type 3
    ↓
Current + previous
    ↓
Limited history
```

For Data Engineering, **SCD Type 2 is particularly important** because it allows analytical systems to understand how dimension attributes changed over time.

---

# 🚀 Day 85 Summary

- ✅ Slowly Changing Dimensions
- ✅ SCD Type 1
- ✅ SCD Type 2
- ✅ SCD Type 3
- ✅ Surrogate keys
- ✅ `valid_from`
- ✅ `valid_to`
- ✅ `is_current`
- ✅ Change detection
- ✅ Historical versions
- ✅ Point-in-time reporting
- ✅ Data-quality validation
- ✅ Data warehouse applications

---

# 📌 Git Commands

```bash
git add .
git commit -m "Day 85 - SQL Slowly Changing Dimensions"
git push
```

**85 Days of SQL 🔥**
