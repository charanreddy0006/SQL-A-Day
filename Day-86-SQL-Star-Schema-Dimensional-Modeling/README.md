# SQL-A-Day — Day 86: SQL Star Schema & Dimensional Modeling

---

## 📌 Topic

**SQL Star Schema & Dimensional Modeling**

Star schema is a core Data Warehousing and Data Engineering concept.

It organizes analytical data into:

- **Fact tables** — measurable business events
- **Dimension tables** — descriptive information about those events

```text
                    dim_date
                       |
                       |
dim_customer ---- fact_sales ---- dim_product
                       |
                       |
                    dim_store
```

---

## 🎯 Learning Objectives

By completing Day 86, you will understand:

- Dimensional modeling
- Fact tables
- Dimension tables
- Star schema
- Fact-table grain
- Surrogate keys
- Foreign keys
- Measures
- Analytical joins
- Drill-down analysis
- Revenue and profit reporting
- Star schema vs Snowflake schema
- OLTP vs Data Warehouse

---

# ⭐ What Is a Star Schema?

A star schema has a central fact table connected directly to dimension tables.

```text
           dim_date
              |
dim_customer--fact_sales--dim_product
              |
           dim_store
```

The fact table stores measurable events. Dimensions provide the context for analyzing those events.

---

# 📊 Fact Table

The project uses:

```text
fact_sales
```

It contains:

```text
sales_key
date_key
customer_key
product_key
store_key
order_id
quantity
unit_price
discount_amount
sales_amount
cost_amount
profit_amount
```

Measures include:

```text
quantity
sales_amount
cost_amount
profit_amount
```

---

# 📐 Fact Table Grain

The most important design decision is the **grain**.

For this project:

> **One row in `fact_sales` represents one product line sold in one sales order.**

For example:

```text
ORD1001
 ├── Laptop
 └── Wireless Mouse
```

creates two fact rows.

Always define grain before building a fact table.

---

# 📚 Dimension Tables

Day 86 uses four dimensions:

```text
dim_date
dim_customer
dim_product
dim_store
```

## dim_date

Contains:

```text
date_key
full_date
day_number
month_number
month_name
quarter_number
year_number
week_number
```

This supports time-based analysis.

## dim_customer

Contains:

```text
customer_key
customer_id
customer_name
city
state
customer_segment
```

## dim_product

Contains:

```text
product_key
product_id
product_name
category
subcategory
brand
unit_price
```

## dim_store

Contains:

```text
store_key
store_id
store_name
city
state
region
```

---

# 🔑 Surrogate Keys

Dimensions use warehouse-generated keys such as:

```text
customer_key
product_key
store_key
```

Example:

```text
customer_key | customer_id
1            | C001
2            | C002
```

The business identifier is `customer_id`, while the warehouse identifier is `customer_key`.

---

# 🔗 Foreign Keys

The fact table connects to dimensions using foreign keys:

```text
fact_sales
    |
    ├── date_key
    ├── customer_key
    ├── product_key
    └── store_key
```

Example:

```sql
JOIN dim_product p
    ON f.product_key = p.product_key
```

---

# 💰 Measures

Measures are values that can normally be aggregated.

Examples:

```text
quantity
sales_amount
cost_amount
profit_amount
```

Common operations:

```sql
SUM()
AVG()
MIN()
MAX()
COUNT()
```

---

# 📈 Analytical Queries

## Total Revenue

```sql
SELECT SUM(sales_amount) AS total_sales
FROM fact_sales;
```

## Sales by Product

```sql
SELECT
    p.product_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
JOIN dim_product p
    ON f.product_key=p.product_key
GROUP BY p.product_key,p.product_name
ORDER BY total_sales DESC;
```

## Sales by Customer

```sql
SELECT
    c.customer_name,
    c.customer_segment,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key=c.customer_key
GROUP BY c.customer_key,c.customer_name,c.customer_segment
ORDER BY total_sales DESC;
```

## Monthly Sales

```sql
SELECT
    d.year_number,
    d.month_name,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
JOIN dim_date d
    ON f.date_key=d.date_key
GROUP BY d.year_number,d.month_number,d.month_name
ORDER BY d.year_number,d.month_number;
```

---

# 🔎 Drill-Down Analysis

A dimensional model supports hierarchical analysis:

```text
Year
 ↓
Month
 ↓
Category
 ↓
Product
```

For example:

```text
2026
  ↓
March
  ↓
Electronics
  ↓
Laptop Pro 14
```

This is common in BI and analytics systems.

---

# 💹 Profit Margin

```text
Profit Margin =
Profit / Revenue × 100
```

SQL:

```sql
SELECT
    p.category,
    SUM(f.sales_amount) revenue,
    SUM(f.profit_amount) profit,
    ROUND(
        SUM(f.profit_amount) /
        NULLIF(SUM(f.sales_amount),0) * 100,
        2
    ) profit_margin_percent
FROM fact_sales f
JOIN dim_product p
    ON f.product_key=p.product_key
GROUP BY p.category;
```

---

# 🧮 Average Order Value

```text
AOV = Total Revenue / Number of Orders
```

```sql
SELECT
    ROUND(SUM(order_total)/COUNT(*),2) AS average_order_value
FROM (
    SELECT order_id,SUM(sales_amount) order_total
    FROM fact_sales
    GROUP BY order_id
) x;
```

---

# ⭐ Star Schema vs Snowflake Schema

## Star Schema

```text
           dim_date
              |
dim_customer--fact--dim_product
              |
           dim_store
```

Dimensions are generally more denormalized.

### Advantages

- Simple queries
- Fewer joins
- Easy to understand
- BI-friendly
- Good analytical performance

## Snowflake Schema

Dimensions are further normalized.

```text
fact_sales
    |
dim_product
    |
dim_category
    |
dim_department
```

### Advantages

- Less duplicated dimension data
- More normalized

### Disadvantages

- More joins
- More complex queries

| Feature | Star | Snowflake |
|---|---|---|
| Dimensions | More denormalized | More normalized |
| Joins | Fewer | More |
| Query complexity | Lower | Higher |
| BI friendliness | High | Medium |
| Redundancy | Higher | Lower |

---

# 🏭 OLTP vs Data Warehouse

## OLTP

Used for operational transactions:

```text
Create order
Update customer
Process payment
```

Usually highly normalized.

## Data Warehouse

Used for analytics:

```text
Revenue by month
Profit by product
Sales by region
Customer analysis
```

Uses fact and dimension modeling.

---

# 🔄 Data Engineering Pipeline

```text
Source Systems
      |
      v
Raw Data
      |
      v
Staging
      |
      v
Transformations
      |
      v
Facts + Dimensions
      |
      v
Data Warehouse
      |
      v
BI / Analytics
```

These concepts are relevant to systems such as:

```text
Airflow
dbt
Spark
Snowflake
Redshift
BigQuery
Databricks
Athena
```

---

# 🧪 Practice Questions

### Beginner

1. Find total revenue.
2. Find total profit.
3. Find total units sold.
4. Find revenue by product.
5. Find revenue by category.

### Intermediate

6. Find revenue by customer segment.
7. Find monthly revenue.
8. Find revenue by store.
9. Find profit margin by category.
10. Find the top 5 products by revenue.
11. Find the top 5 customers by revenue.
12. Find average order value.
13. Find each customer's total number of orders.

### Advanced

14. Find the highest-revenue category for every month.
15. Find the top customer in each segment.
16. Find stores above average store revenue.
17. Find products that were never sold.
18. Find each customer's first purchase date.
19. Calculate each category's percentage contribution to total revenue.
20. Build a report containing:

```text
Year
Month
Region
Category
Revenue
Profit
```

---

# 💡 Interview Questions

### 1. What is a star schema?

A warehouse design where a central fact table connects directly to dimension tables.

### 2. What is a fact table?

A table containing measurable business events and dimension keys.

### 3. What is a dimension table?

A table containing descriptive attributes used to analyze facts.

### 4. What is grain?

The exact meaning of one row in a fact table.

### 5. Why is grain important?

It prevents ambiguous measurements and incorrect aggregations.

### 6. What is a surrogate key?

A warehouse-generated key used to uniquely identify a dimension record.

### 7. What is a measure?

A numeric business value that can usually be aggregated.

Examples:

```text
sales
quantity
cost
profit
```

### 8. Star schema vs Snowflake?

Star schema generally keeps dimensions more denormalized and requires fewer joins, while Snowflake schema normalizes dimensions further.

---

# ⚠️ Common Mistakes

### Mistake 1 — Not defining grain

Always state:

> One fact row represents ______.

Here:

> One fact row represents one product line sold in one order.

### Mistake 2 — Joining on the wrong key

Use:

```sql
f.product_key = p.product_key
```

### Mistake 3 — Double counting orders

If an order contains multiple product lines, don't use:

```sql
COUNT(*)
```

to count orders.

Use:

```sql
COUNT(DISTINCT order_id)
```

### Mistake 4 — Ignoring fact-table grain

Always understand what one row represents before calculating metrics.

---

# 📁 Project Structure

```text
Day-86-SQL-Star-Schema-Dimensional-Modeling/
│
├── day86.sql
└── README.md
```

---

# ▶️ How to Run

Open MySQL Workbench, MySQL Shell, or VS Code with your MySQL connection.

Run:

```sql
SOURCE path/to/day86.sql;
```

The script creates:

```text
sql_star_schema_lab
```

with:

```text
dim_date
dim_customer
dim_product
dim_store
fact_sales
```

---

# 🔑 Key Takeaways

```text
Dimension
    ↓
Describes the business

Fact
    ↓
Stores measurable events

Grain
    ↓
Defines what one fact row means

Star Schema
    ↓
Fact + Dimensions

Measures
    ↓
Revenue / Quantity / Cost / Profit

Dimensions
    ↓
Customer / Product / Store / Date
```

---

# 🚀 Day 86 Summary

- ✅ Dimensional modeling
- ✅ Star schema
- ✅ Fact tables
- ✅ Dimension tables
- ✅ Fact-table grain
- ✅ Surrogate keys
- ✅ Foreign keys
- ✅ Measures
- ✅ Analytical joins
- ✅ Drill-down analysis
- ✅ Revenue analysis
- ✅ Profit analysis
- ✅ Star vs Snowflake schema
- ✅ OLTP vs Data Warehouse
- ✅ Data Engineering warehouse architecture

---

# 📌 Git Commands

```bash
git add .
git commit -m "Day 86 - SQL Star Schema Dimensional Modeling"
git push
```

**SQL-A-Day — Day 86 🔥**
