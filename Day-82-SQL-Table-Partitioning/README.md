# Day 82 — SQL Table Partitioning

Today we learn **SQL Table Partitioning**, an important database and data-engineering concept for working with large tables.

---

## 🎯 Today's Goal

By the end of Day 82, you should understand:

- Table partitioning
- Why large tables can be partitioned
- `RANGE`
- `RANGE COLUMNS`
- `LIST COLUMNS`
- `HASH`
- `KEY`
- Partition pruning
- `MAXVALUE`
- Partition metadata
- Partition maintenance
- Partitioning vs indexing
- Partitioning vs sharding

---

## 🧠 What Is Table Partitioning?

Partitioning divides a large logical table into smaller physical pieces called **partitions**.

For example:

```text
sales
│
├── 2024
├── 2025
├── 2026
└── future
```

The application still works with one logical table:

```sql
SELECT *
FROM sales;
```

MySQL manages the underlying partitions.

---

## 📌 Why Use Partitioning?

Partitioning can be useful for very large tables where queries frequently filter on a natural partition key.

Common examples:

- Sales by year
- Logs by month
- Events by date
- Customers by region
- Large event streams
- Time-series data
- Analytics workloads

Partitioning is **not automatically faster**. The strategy must match the workload.

---

# 🔥 Partition Pruning

**Partition pruning** means eliminating partitions that cannot contain rows matching a query.

Example:

```sql
SELECT *
FROM sales_range
WHERE sale_date >= '2026-01-01'
  AND sale_date < '2027-01-01';
```

Conceptually:

```text
Query
  ↓
Partition pruning
  ↓
Relevant partitions
  ↓
Rows
```

This can reduce the amount of data examined.

---

# 🧱 RANGE Partitioning

`RANGE` assigns rows to partitions according to ranges.

Example:

```sql
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

Important:

```sql
PARTITION p2026 VALUES LESS THAN (2027)
```

means values for 2026 belong to `p2026`; the upper boundary is exclusive.

---

# 📆 RANGE COLUMNS

MySQL also supports:

```sql
PARTITION BY RANGE COLUMNS (order_date)
```

This is especially useful for dates.

Example:

```sql
PARTITION BY RANGE COLUMNS (order_date) (
    PARTITION p2025 VALUES LESS THAN ('2026-01-01'),
    PARTITION p2026 VALUES LESS THAN ('2027-01-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);
```

---

# 🏷️ LIST COLUMNS

List partitioning is useful when rows belong to known categories.

Example:

```text
NORTH
SOUTH
EAST
WEST
```

SQL:

```sql
PARTITION BY LIST COLUMNS (region_code) (
    PARTITION p_north VALUES IN ('NORTH'),
    PARTITION p_south VALUES IN ('SOUTH'),
    PARTITION p_east VALUES IN ('EAST'),
    PARTITION p_west VALUES IN ('WEST')
);
```

---

# 🔢 HASH Partitioning

Hash partitioning distributes rows using a hash calculation.

Example:

```sql
PARTITION BY HASH (user_id)
PARTITIONS 4;
```

Conceptually:

```text
user_id
   ↓
Hash
   ↓
┌────┬────┬────┬────┐
│ P0 │ P1 │ P2 │ P3 │
└────┴────┴────┴────┘
```

It is useful when you want distribution rather than meaningful date/category ranges.

---

# 🔑 KEY Partitioning

MySQL also provides:

```sql
PARTITION BY KEY (user_id)
PARTITIONS 4;
```

MySQL determines the key-based hashing mechanism.

Example:

```sql
CREATE TABLE users_key (
    user_id BIGINT NOT NULL,
    user_name VARCHAR(100),
    created_at DATETIME,
    PRIMARY KEY (user_id)
)
PARTITION BY KEY (user_id)
PARTITIONS 4;
```

---

# 📊 Partitioning Types

| Type | Main Idea | Typical Use |
|---|---|---|
| `RANGE` | Divide by ranges | Years, numeric ranges |
| `RANGE COLUMNS` | Divide by column ranges | Dates |
| `LIST` | Divide by known values | Categories |
| `LIST COLUMNS` | Divide by column values | Regions/status |
| `HASH` | Hash-based distribution | Even distribution |
| `KEY` | MySQL key-based distribution | Distributed rows |

---

# 🔍 Inspecting Partitions

MySQL exposes partition metadata through:

```sql
information_schema.PARTITIONS
```

Example:

```sql
SELECT
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_METHOD,
    PARTITION_EXPRESSION,
    TABLE_ROWS
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE()
  AND PARTITION_NAME IS NOT NULL;
```

This is useful for database administration and troubleshooting.

---

# 🎯 Querying a Specific Partition

You can explicitly query a partition:

```sql
SELECT *
FROM sales_range PARTITION (p2026);
```

For normal application queries, it is usually better to query the table and let MySQL determine relevant partitions.

---

# 🚀 MAXVALUE

`MAXVALUE` acts as a catch-all upper boundary.

Example:

```sql
PARTITION p_future VALUES LESS THAN (MAXVALUE)
```

Conceptually:

```text
2024 → p2024
2025 → p2025
2026 → p2026
other future values → p_future
```

This is useful for maintaining time-based partitions.

---

# 🔄 Maintaining Partitions

Suppose a table contains:

```text
p2026_01
p2026_02
p2026_03
p_future
```

A future partition can be created by reorganizing the `MAXVALUE` partition:

```sql
ALTER TABLE monthly_sales
REORGANIZE PARTITION p_future INTO (
    PARTITION p2026_09 VALUES LESS THAN ('2026-10-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);
```

This is a common pattern for rolling time-based partitions.

---

# ⚠️ TRUNCATE PARTITION

A partition can be emptied:

```sql
ALTER TABLE monthly_sales
TRUNCATE PARTITION p2026_01;
```

This removes rows from that partition.

⚠️ The command is intentionally commented out in `day82.sql` because it is destructive.

---

# ⚠️ DROP PARTITION

A partition can also be removed:

```sql
ALTER TABLE monthly_sales
DROP PARTITION p2026_01;
```

This removes the partition and its data.

⚠️ Also destructive.

---

# 🧩 Partitioning vs Indexing

These are different concepts.

### Indexing

```text
Table
 ↓
Index
 ↓
Matching rows
```

### Partitioning

```text
Table
 ↓
┌────────┬────────┬────────┐
│ P1     │ P2     │ P3     │
└────────┴────────┴────────┘
```

Partitioning can be combined with indexes, but it does not replace them.

---

# ⚡ Partitioning vs Sharding

### Partitioning

Usually divides data within a database/table structure:

```text
One table
   ↓
Multiple partitions
```

### Sharding

Distributes data across multiple database nodes:

```text
Application
    ↓
 ┌───┴────┐
Node 1  Node 2
```

They are different techniques.

---

# 🏗️ Data Engineering Example

Imagine an event platform producing:

```text
500 million events per year
```

A table might contain:

```text
event_id
user_id
event_type
event_time
payload
```

A date-based design could be:

```text
events
│
├── 2024
├── 2025
├── 2026
└── future
```

Then a query such as:

```sql
SELECT COUNT(*)
FROM events
WHERE event_time >= '2026-01-01'
  AND event_time < '2027-01-01';
```

has a natural partitioning key.

This pattern is common in:

- Data engineering
- Analytics
- Event systems
- Logs
- IoT
- Financial data
- Data warehouses

---

# ⚠️ Important Things to Remember

### 1. Choose the partition key carefully

It should match important query patterns.

### 2. More partitions does not automatically mean better performance

Partition design must match the workload.

### 3. Partition pruning matters

Queries using the partition key can potentially benefit from pruning.

### 4. Partitioning does not replace indexes

Appropriate indexes may still be required.

### 5. Partition maintenance matters

Time-based partitions often require adding future partitions and removing old ones.

### 6. Primary and unique keys have partitioning restrictions

MySQL has specific rules regarding unique keys and partitioning columns.

---

# 🧪 Practice Questions

### Beginner

1. Create a table partitioned by year from 2023 to 2027.
2. Create monthly `RANGE COLUMNS` partitions for one year.
3. Find total revenue for 2026.
4. Query only the 2025 partition.
5. Inspect `information_schema.PARTITIONS`.

### Intermediate

6. Create a `LIST COLUMNS` table for product categories.
7. Create a HASH-partitioned table with 8 partitions.
8. Create a KEY-partitioned user table.
9. Add a future partition to a date-partitioned table.
10. Use `EXPLAIN` to study partition pruning.

### Advanced

11. Design partitions for five years of event data.
12. Decide whether RANGE, LIST, or HASH is suitable for different datasets.
13. Design a monthly rolling-partition strategy.
14. Explain partitioning versus sharding.
15. Explain how partitioning and indexing can work together.

---

# 💼 Interview Questions

### 1. What is table partitioning?

Dividing a large logical table into smaller physical partitions while keeping it accessible as one table.

### 2. Why is partitioning used?

It can improve manageability and, for suitable queries, reduce the amount of data examined.

### 3. What is partition pruning?

Eliminating partitions that cannot contain rows matching a query.

### 4. What is RANGE partitioning?

Rows are assigned according to value ranges.

### 5. What is LIST partitioning?

Rows are assigned according to predefined values.

### 6. What is HASH partitioning?

Rows are distributed according to a hash calculation.

### 7. What is KEY partitioning?

MySQL performs key-based partitioning using its internal hashing mechanism.

### 8. What is MAXVALUE?

A special upper boundary that catches values not matched by earlier range partitions.

### 9. Is partitioning the same as indexing?

No. They are different mechanisms that can complement each other.

### 10. Is partitioning the same as sharding?

No. Partitioning generally divides data within a database/table structure, while sharding distributes data across database nodes.

---

# 🛠️ Project Structure

```text
Day-82-SQL-Table-Partitioning/
│
├── day82.sql
└── README.md
```

---

# ▶️ How to Run

Make sure MySQL 8.x is installed and running.

Open MySQL Workbench, MySQL CLI, or your SQL extension in VS Code.

Run:

```sql
SOURCE path/to/day82.sql;
```

The script creates:

```text
sql_partitioning_lab
```

with examples for:

```text
sales_range
orders_by_date
customers_by_region
events_hash
users_key
monthly_sales
```

---

# 📚 What You Learned

```text
Large Table
    ↓
Partitioning Strategy
    ↓
┌──────────┬──────────┬──────────┐
│ Partition│ Partition│ Partition│
│    1     │    2     │    3     │
└──────────┴──────────┴──────────┘
             ↓
      Partition Pruning
             ↓
       Less Data Examined
```

Key concepts:

- Table partitioning
- RANGE partitioning
- RANGE COLUMNS
- LIST COLUMNS
- HASH partitioning
- KEY partitioning
- Partition pruning
- MAXVALUE
- Partition metadata
- Partition maintenance
- Partition vs index
- Partition vs sharding

---

# 🚀 Day 82 Summary

**Topic:** SQL Table Partitioning

**Main focus:** Understanding how large tables can be divided into manageable partitions and how partitioning strategies support large-scale data workloads.

---

# 📈 SQL-A-Day Progress

```text
Day 82 / SQL-A-Day
██████████████████████████████████████████████████████████████████████████████████████
```

**82 days of SQL learning completed! 🔥**

---

# 🔗 Git Commands

```bash
git add .
git commit -m "Day 82 - SQL Table Partitioning"
git push
```

**Day 82 complete. 🚀**
