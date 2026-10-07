# SQL-A-Day — Day 87
# SQL Data Quality Engineering & Automated Validation

---

## 📌 Topic

**SQL Data Quality Engineering & Automated Validation**

A data pipeline can successfully ingest and transform data while still producing incorrect results.

Data quality engineering adds validation rules that answer:

> **Is this data reliable enough to use?**

Day 87 builds a practical MySQL-based quality framework covering completeness, uniqueness, validity, consistency, referential integrity, business rules, freshness, and automated quality scoring.

---

# 🎯 Learning Objectives

By completing this project, you will understand:

- Data profiling
- Completeness checks
- Duplicate detection
- Uniqueness validation
- Primary-key style checks
- Format validation
- Domain validation
- Numeric range validation
- Date validation
- Referential integrity
- Orphan-record detection
- Cross-table consistency
- Business-rule validation
- Data freshness
- Automated quality results
- PASS / FAIL classification
- Overall quality scoring
- Record-level quality reporting

---

# 🧠 What Is Data Quality?

Data quality describes how suitable data is for its intended use.

Important dimensions include:

```text
Completeness
     ↓
Are required values present?

Uniqueness
     ↓
Are unwanted duplicates present?

Validity
     ↓
Do values follow the expected rules?

Consistency
     ↓
Do related data sources agree?

Integrity
     ↓
Do relationships point to real records?

Timeliness
     ↓
Is the data fresh enough?
```

---

# 🏗️ Day 87 Architecture

```text
                 SOURCE TABLES
                      │
        ┌─────────────┼─────────────┐
        │             │             │
    Customers      Products       Orders
        │             │             │
        └─────────────┼─────────────┘
                      ↓
              QUALITY RULES
                      │
       ┌──────────────┼──────────────┐
       │              │              │
 Completeness     Validity      Consistency
       │              │              │
       └──────────────┼──────────────┘
                      ↓
             QUALITY RESULTS
                      │
              ┌───────┴───────┐
              ↓               ↓
            PASS          FAIL / WARN
              │               │
              └───────┬───────┘
                      ↓
                QUALITY SCORE
```

---

# 🗃️ Project Database

The SQL script creates:

```text
sql_data_quality_lab
```

Tables:

```text
customers
products
orders
data_quality_results
```

View:

```text
vw_data_quality_summary
```

---

# 1️⃣ Completeness

Completeness checks whether required attributes are present.

Example:

```sql
SELECT *
FROM customers
WHERE email IS NULL
   OR TRIM(email)='';
```

This identifies customers without an email address.

Another example:

```sql
SELECT *
FROM customers
WHERE city IS NULL
   OR TRIM(city)='';
```

---

# 2️⃣ Uniqueness

Business keys should generally not have unintended duplicates.

For example:

```text
customer_code
product_code
order_number
```

Duplicate customer codes:

```sql
SELECT
    customer_code,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_code
HAVING COUNT(*) > 1;
```

If rows are returned, the business key contains duplicates.

---

# 3️⃣ Primary-Key Validation

A primary key should satisfy:

```text
NOT NULL
+
UNIQUE
```

Example:

```sql
SELECT *
FROM customers
WHERE customer_id IS NULL;
```

And:

```sql
SELECT
    customer_id,
    COUNT(*) AS row_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

Together these checks identify primary-key-style violations.

---

# 4️⃣ Format Validation

SQL can validate common data formats.

For example, email:

```sql
SELECT *
FROM customers
WHERE email IS NOT NULL
  AND email NOT REGEXP
      '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
```

Phone number:

```sql
SELECT *
FROM customers
WHERE phone IS NULL
   OR phone NOT REGEXP '^[0-9]{10}$';
```

These are basic format checks rather than proof that the contact information is actually usable.

---

# 5️⃣ Domain Validation

A column may have a limited set of valid values.

For customer status:

```text
ACTIVE
INACTIVE
```

SQL:

```sql
SELECT *
FROM customers
WHERE customer_status NOT IN ('ACTIVE','INACTIVE')
   OR customer_status IS NULL;
```

For order status:

```text
COMPLETED
PENDING
CANCELLED
```

---

# 6️⃣ Numeric Validation

Business numbers often have natural ranges.

Product price:

```text
price > 0
```

Order quantity:

```text
quantity > 0
```

Example:

```sql
SELECT *
FROM products
WHERE unit_price IS NULL
   OR unit_price <= 0;
```

And:

```sql
SELECT *
FROM orders
WHERE quantity IS NULL
   OR quantity <= 0;
```

---

# 7️⃣ Date Validation

A signup date should not normally be in the future.

```sql
SELECT *
FROM customers
WHERE signup_date IS NULL
   OR signup_date > CURRENT_DATE;
```

Orders should also not be future-dated in this project:

```sql
SELECT *
FROM orders
WHERE order_date IS NULL
   OR order_date > CURRENT_DATE;
```

---

# 8️⃣ Referential Integrity

Orders reference customers and products.

```text
orders.customer_id
       ↓
customers.customer_id
```

An order referencing a customer that doesn't exist is called an **orphan record**.

Find orphan customers:

```sql
SELECT
    o.order_id,
    o.order_number,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id=c.customer_id
WHERE c.customer_id IS NULL;
```

Similarly, orphan products can be found by joining against `products`.

---

# 9️⃣ Cross-Table Consistency

Some rules require multiple tables.

For example, suppose:

```text
Product price = ₹28,000
```

but an order contains:

```text
Order price = ₹5,000
```

The data is inconsistent under the simplified business rule used here.

```sql
SELECT
    o.order_id,
    o.unit_price AS order_price,
    p.unit_price AS product_price
FROM orders o
JOIN products p
    ON o.product_id=p.product_id
WHERE ABS(o.unit_price-p.unit_price)>0.01;
```

---

# 🔟 Business Rules

Technical constraints are not enough.

Business rules are also important.

Example:

> Active customers should have an email.

```sql
SELECT *
FROM customers
WHERE customer_status='ACTIVE'
  AND (email IS NULL OR TRIM(email)='');
```

Another rule:

> Completed orders must have a positive quantity.

```sql
SELECT *
FROM orders
WHERE order_status='COMPLETED'
  AND quantity<=0;
```

---

# 🕐 Data Freshness

Data can be valid but stale.

A freshness check can calculate how long it has been since the latest update.

```sql
SELECT
    MAX(last_updated) AS latest_update,
    TIMESTAMPDIFF(
        HOUR,
        MAX(last_updated),
        CURRENT_TIMESTAMP
    ) AS hours_since_update
FROM orders;
```

This concept is important in scheduled data pipelines.

---

# 📊 Data Quality Result Table

The project creates:

```text
data_quality_results
```

Columns:

```text
check_id
check_name
dimension
failed_records
total_records
pass_rate
status
checked_at
```

Example:

```text
Customer email completeness
        ↓
Failed records = 1
Total records  = 10
Pass rate      = 90%
Status         = FAIL
```

This turns individual SQL checks into structured quality metadata.

---

# 🚦 PASS / FAIL

A rule can be converted into a simple pipeline-friendly status.

```sql
CASE
    WHEN failed_records=0 THEN 'PASS'
    ELSE 'FAIL'
END
```

This makes it possible for an orchestration system to decide whether downstream processing should continue.

---

# 📈 Overall Quality Score

Suppose:

```text
10 total checks
8 passed
2 failed
```

The score is:

```text
80%
```

The project calculates it with:

```sql
SELECT
    COUNT(*) AS total_checks,
    SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END) AS passed_checks,
    SUM(CASE WHEN status='FAIL' THEN 1 ELSE 0 END) AS failed_checks,
    ROUND(
        100 * SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS quality_score
FROM data_quality_results;
```

---

# ⚠️ PASS / WARN / FAIL

The project uses three overall states:

```text
PASS
WARN
FAIL
```

Conceptually:

```text
No failed checks
      ↓
    PASS

Small number of failures
      ↓
    WARN

Large number of failures
      ↓
    FAIL
```

The exact thresholds should be chosen according to business requirements.

---

# 📊 Quality by Dimension

Quality can be summarized by category.

```text
COMPLETENESS
UNIQUENESS
VALIDITY
CONSISTENCY
```

Example:

```sql
SELECT
    dimension,
    COUNT(*) AS checks,
    SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END) AS passed,
    SUM(CASE WHEN status='FAIL' THEN 1 ELSE 0 END) AS failed,
    ROUND(
        100 * SUM(CASE WHEN status='PASS' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS dimension_score
FROM data_quality_results
GROUP BY dimension;
```

This helps identify which quality area needs attention.

---

# 👤 Record-Level Quality

Rule-level results tell us which rule failed.

Record-level reports tell us **which records are problematic**.

Example:

```text
customer_id | customer_name | status
------------|---------------|--------
101         | Aarav Sharma  | PASS
105         | Kabir Joshi   | FAIL
107         | Ishita Rao    | FAIL
```

This is useful for data-cleaning workflows.

---

# 🏭 Data Engineering Pipeline

A real pipeline can follow:

```text
Source
  ↓
Ingestion
  ↓
Raw Layer
  ↓
Data Quality Checks
  ↓
      ┌───────────┐
      │           │
     PASS        FAIL
      │           │
      ↓           ↓
Warehouse     Quarantine
      │
      ↓
Analytics
```

Failed records can be:

- Logged
- Quarantined
- Corrected
- Reprocessed
- Sent to the source team
- Used to trigger an alert

---

# 🔄 SQL + Pipeline Orchestration

In a larger Data Engineering environment:

```text
Airflow
   ↓
Load Data
   ↓
Run SQL Quality Checks
   ↓
Calculate Quality Score
   ↓
   ┌───────────────┐
   │               │
 PASS             FAIL
   │               │
   ↓               ↓
Continue       Stop / Alert
Pipeline       / Quarantine
```

This is one reason data-quality SQL is highly useful for Data Engineers.

---

# 🧠 Data Quality Dimensions

| Dimension | Meaning | Example |
|---|---|---|
| Completeness | Required data exists | Email not NULL |
| Uniqueness | No unwanted duplicates | Customer code unique |
| Validity | Values follow rules | Price > 0 |
| Consistency | Related data agrees | Order price matches product |
| Integrity | Relationships are valid | Customer exists |
| Timeliness | Data is sufficiently fresh | Recent update |

---

# ⚠️ Common Mistakes

### Mistake 1 — Only checking NULL values

A value can be non-NULL but still invalid:

```text
quantity = -10
```

---

### Mistake 2 — Ignoring duplicates

Duplicates can distort:

```text
Customer counts
Order counts
Revenue
Aggregations
```

---

### Mistake 3 — Checking tables independently

Some problems exist only between tables.

```text
orders
   ↓
customers
```

The relationship must also be validated.

---

### Mistake 4 — Treating every failure equally

A missing optional value might be less serious than a broken customer relationship.

Real quality frameworks often assign different severity levels.

---

# 💡 Interview Questions

### 1. What is data quality?

The degree to which data is suitable, reliable, and trustworthy for its intended use.

### 2. What is completeness?

Whether required information is present.

### 3. How do you find duplicates in SQL?

Use:

```sql
GROUP BY
HAVING COUNT(*) > 1
```

### 4. What is an orphan record?

A child record whose referenced parent record does not exist.

### 5. What is data freshness?

The amount of time since data was last updated.

### 6. Why are cross-table quality checks important?

Some problems can only be identified by comparing related tables.

### 7. What is a quality score?

A numerical summary of the success of defined data-quality checks.

### 8. What should happen when a quality rule fails?

Depending on severity, the pipeline may warn, stop, quarantine data, or trigger an alert.

---

# 🧪 Practice Questions

### Beginner

1. Find customers with missing email addresses.
2. Find customers with missing cities.
3. Find duplicate customer codes.
4. Find duplicate product codes.
5. Find invalid customer statuses.
6. Find invalid order statuses.
7. Find products with non-positive prices.
8. Find orders with non-positive quantities.

### Intermediate

9. Find invalid email addresses.
10. Find future customer signup dates.
11. Find future order dates.
12. Find orphan customers.
13. Find orphan products.
14. Find duplicate order numbers.
15. Find order/product price mismatches.

### Advanced

16. Calculate the quality score for every quality rule.
17. Calculate the quality score by dimension.
18. Create an overall PASS/WARN/FAIL result.
19. Find the dimension with the lowest quality score.
20. Build a record-level data-quality report.
21. Find records failing multiple rules.
22. Build a complete quality dashboard query.

---

# 📁 Project Structure

```text
Day-87-SQL-Data-Quality-Engineering/
│
├── day87.sql
└── README.md
```

---

# ▶️ How to Run

Open MySQL Workbench, MySQL Shell, or your VS Code MySQL connection.

Run:

```sql
SOURCE path/to/day87.sql;
```

The script creates:

```text
sql_data_quality_lab
```

and the following objects:

```text
customers
products
orders
data_quality_results
vw_data_quality_summary
```

---

# 🔑 Key Takeaways

```text
Completeness
      ↓
Are required values present?

Uniqueness
      ↓
Are duplicates present?

Validity
      ↓
Are values allowed?

Consistency
      ↓
Do related tables agree?

Integrity
      ↓
Do relationships exist?

Freshness
      ↓
Is the data recent?

Quality Score
      ↓
Can the pipeline continue?
```

---

# 🚀 Day 87 Summary

Today you learned:

- ✅ Data profiling
- ✅ Completeness
- ✅ Uniqueness
- ✅ Duplicate detection
- ✅ Primary-key validation
- ✅ Format validation
- ✅ Domain validation
- ✅ Numeric validation
- ✅ Date validation
- ✅ Referential integrity
- ✅ Orphan-record detection
- ✅ Cross-table consistency
- ✅ Business-rule validation
- ✅ Data freshness
- ✅ Automated quality rules
- ✅ Quality result tables
- ✅ Quality scoring
- ✅ PASS / WARN / FAIL
- ✅ Record-level validation
- ✅ Data Engineering pipeline integration

---

# 📌 GitHub

```bash
git add .
git commit -m "Day 87 - SQL Data Quality Engineering"
git push
```

**SQL-A-Day — Day 87 🔥**
