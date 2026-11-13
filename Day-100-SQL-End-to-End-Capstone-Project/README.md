# Day 100 — End-to-End SQL Capstone: Retail Sales Analytics

<text></text>

**Series:** SQL-A-Day — Final Day  
**Database:** MySQL 8.0+  
**Main script:** `day100.sql`  
**Project database:** `sql_day100_capstone`

---

## 🎯 Project overview

Welcome to Day 100! This final project brings together the SQL concepts practiced throughout the SQL-A-Day journey.

You will work with a small retail/e-commerce dataset and answer practical business questions using SQL. The goal is not to learn one isolated command today. It is to demonstrate how to move from a relational schema and raw records to validated data, analytical queries, reusable reporting, and business insights.

### Business scenario

A retail company wants to understand:
- How much revenue comes from delivered orders?
- Which products and categories perform best?
- Which customers contribute the most revenue?
- How are sales changing month by month?
- Which customers have not purchased?
- How can the company segment customers using their purchase activity?

## 1. Learning objectives

By completing this capstone, you will practice:

1. Designing related tables with primary and foreign keys.
2. Using data types, constraints, and default values.
3. Inserting and validating relational data.
4. Combining tables with `INNER JOIN` and `LEFT JOIN`.
5. Summarizing data with aggregate functions.
6. Filtering grouped results with `HAVING`.
7. Writing subqueries and common table expressions (CTEs).
8. Applying window functions and ranking.
9. Analyzing sales by month and category.
10. Creating reusable SQL views.
11. Translating business questions into SQL reports.

## 2. Database schema

The project uses four tables:

| Table | Purpose |
|---|---|
| `customers` | Customer profile and location |
| `products` | Product catalog, price, and stock |
| `orders` | Order header, customer, date, and status |
| `order_items` | Products, quantities, and prices captured at sale |

### Relationship overview

```text
CUSTOMERS
---------
customer_id (PK)
customer_name
city
state
signup_date
email
      |
      | 1 to many
      v
ORDERS
------
order_id (PK)
customer_id (FK)
order_date
order_status
      |
      | 1 to many
      v
ORDER_ITEMS
-----------
order_item_id (PK)
order_id (FK)
product_id (FK)
quantity
unit_price_at_sale
      ^
      | many to 1
      |
PRODUCTS
--------
product_id (PK)
product_name
category
unit_price
stock_quantity
```

The `unit_price_at_sale` field stores the price recorded for that order item. It is used for historical revenue calculations rather than assuming the current product catalog price is always the price paid.

## 3. How to run the project

1. Install and start MySQL Server 8.0 or later.
2. Open `day100.sql` in VS Code, MySQL Workbench, or another MySQL client.
3. Connect to your local MySQL server.
4. Execute the script.
5. Inspect the result sets produced by each section.
6. Modify the queries and complete the final challenges.

The script creates and rebuilds the practice tables in `sql_day100_capstone`. It drops the four project tables at the beginning so that the sample lab can be run again from a clean state. **Do not point this script at a database containing your own important data.**

## 4. Project workflow

### Step 1 — Create the schema

The script creates four related tables and defines:
- Primary keys.
- Foreign keys.
- `NOT NULL` and `UNIQUE` constraints.
- `CHECK` constraints for valid quantities, prices, and order statuses.

### Step 2 — Load sample data

The project inserts sample customers, products, orders, and order items. The dataset includes multiple cities, product categories, months, and order statuses so that you can practice different reporting queries.

### Step 3 — Run data quality checks

You will check for duplicate emails, orphan orders, invalid quantities, and invalid prices.

The foreign keys and constraints prevent several invalid records from being inserted, while validation queries help demonstrate how analysts inspect data quality.

### Step 4 — Calculate business metrics

The script calculates:
- Order counts by status.
- Revenue from delivered orders.
- Revenue by customer.
- Revenue and units sold by product.
- Revenue by product category.
- Monthly delivered revenue.

**Revenue definition used in this project:** quantity multiplied by `unit_price_at_sale`, for order records whose status is `DELIVERED`. This is a simplified learning definition, not a complete accounting or finance definition.

### Step 5 — Use advanced analytical SQL

You will use a CTE to calculate customer revenue and compare it with the average customer revenue. You will use `DENSE_RANK()` to rank products within each category.

### Step 6 — Segment customers

A `CASE` expression assigns customers to high-, medium-, and low-value segments based on their delivered revenue. Customers without delivered purchases are placed in a separate segment.

The thresholds are illustrative business rules chosen for this practice dataset.

### Step 7 — Create a reusable view

The view `vw_monthly_sales` stores the monthly delivered-sales aggregation as a reusable query definition.

### Step 8 — Produce an executive summary

The final section produces overall KPIs, the top five customers by delivered revenue, and the top five products by units sold.

## 5. Key SQL concepts used

| Concept | How it is used |
|---|---|
| `CREATE TABLE` | Build the relational schema |
| Primary and foreign keys | Define entity identity and relationships |
| `INSERT` | Load the sample dataset |
| `CHECK`, `UNIQUE`, `NOT NULL` | Enforce data rules |
| `INNER JOIN` | Combine related records |
| `LEFT JOIN` | Preserve customers with no matching delivered order |
| `GROUP BY` | Aggregate by customer, product, category, and month |
| Aggregate functions | Calculate counts, sums, and averages |
| `HAVING` | Filter grouped results (extend the practice queries) |
| Subquery | Compare customer revenue to an overall average |
| CTE | Organize multi-step analytical queries |
| Window function | Rank products within categories |
| `CASE` | Assign customer segments |
| View | Reuse monthly reporting logic |
| `ORDER BY` and `LIMIT` | Produce top-N reports |

## 6. Business questions to answer

Use the existing tables to answer these questions:

1. What is the total delivered revenue?
2. Which customer has the highest delivered revenue?
3. Which product generated the most delivered revenue?
4. Which category sold the most units?
5. Which month had the highest delivered revenue?
6. How many orders were cancelled?
7. Which customers have never placed an order?
8. Which products have never appeared in a delivered order?
9. What is the average value of a delivered order?
10. Which customers have placed more than one delivered order?

Be careful when calculating order-level totals: joining order headers to order items can create multiple rows per order. Use `COUNT(DISTINCT order_id)` when counting orders after joining to line items.

## 7. Final challenges

Complete these independently after running the supplied queries:

- **Challenge 1:** Find customers who have never placed an order.
- **Challenge 2:** Find products that have never appeared in a delivered order.
- **Challenge 3:** Calculate average delivered order value.
- **Challenge 4:** Find each customer's first delivered order date.
- **Challenge 5:** Calculate month-over-month revenue change.
- **Challenge 6:** Find the highest-revenue product in each category.
- **Challenge 7:** Compare order counts by city.
- **Challenge 8:** Identify customers with more than one delivered order.

For extra practice, add a new product, customer, and order, then rerun the reports to see how the results change.

## 8. Important analysis notes

- Cancelled, placed, paid, and shipped orders are excluded from the delivered-revenue calculations in this project.
- `unit_price_at_sale` is used to preserve the price associated with each line item.
- The sample data is intentionally small and designed for learning, not statistical conclusions.
- The monthly report groups by calendar month using `DATE_FORMAT`.
- The customer segmentation thresholds are examples and should be justified against real business goals in a real project.
- The script targets MySQL 8.0+ and uses features such as CTEs and window functions.

## 9. Suggested GitHub repository presentation

After completing the project, your repository can present the 100-day journey as a collection of daily SQL lessons and practice projects.

For the final day, keep these two files together:

```text
Day-100-SQL-End-to-End-Capstone-Project/
├── day100.sql
└── README.md
```

Before pushing:
1. Run the script in your MySQL environment.
2. Review the output of the KPI and ranking queries.
3. Complete at least a few final challenges.
4. Update the README with any additional insights you personally discover.
5. Commit and push the final Day 100 folder.

## 10. Final takeaway

You have reached Day 100. The most important skill is not memorizing SQL syntax; it is learning to translate a business question into a clear, correct, and efficient query.

This capstone is your opportunity to demonstrate that complete workflow:

**Design → Load → Validate → Query → Analyze → Report**

Congratulations on completing your 100-day SQL learning series! 🏆

---

## GitHub commit

```bash
git add .
git commit -m "Day 100 - End-to-End SQL Capstone Project"
git push
```

**Suggested final repository milestone:** `SQL-A-Day — 100 Days of SQL Practice Completed`
