Day 63 - Online Store Sales & Inventory Management System

SQL-A-Day

A practical MySQL mini project for managing an online store's customers, products, orders, payments, inventory, and sales analytics.

Project Overview

This project simulates the database layer of an online shopping platform.

The database manages:

Customers

Product categories

Products

Inventory

Orders

Order items

Payments

Sales analysis

Customer analysis

Inventory monitoring

Business reports

Audit information

Objectives

Design a relational database.

Create related tables.

Use primary and foreign keys.

Insert realistic sample data.

Analyze sales and revenue.

Analyze customer spending.

Monitor inventory.

Generate business reports.

Practice JOINs and aggregate functions.

Practice subqueries and CTEs.

Practice window functions.

Create reusable views.

Create indexes.

Use triggers for inventory auditing.

Use stored procedures.

Demonstrate transactions.

Technologies

MySQL

SQL

Relational Database Design

JOINs

Aggregate Functions

Subqueries

CTEs

Window Functions

Views

Indexes

Triggers

Stored Procedures

Transactions

Project Structure

Day-63-Online-Store-Sales-Management/
│
├── README.md
└── day63.sql

Database

Database name:

online_store

The SQL file creates the database automatically.

Database Tables

The project contains these main tables:

categories
customers
products
inventory
orders
order_items
payments

An additional audit table is used:

inventory_audit

Entity Relationships

categories
    |
    | 1
    |
    | N
products
    |
    | 1
    |
    | 1
inventory

customers
    |
    | 1
    |
    | N
orders
    |
    | 1
    |
    | N
order_items
    |
    | N
    |
    | 1
products

orders
    |
    | 1
    |
    | 1
payments

Categories

The categories table stores product categories.

Columns:

category_id
category_name
description

Example categories:

Laptops

Smartphones

Audio

Accessories

Smart Home

Customers

The customers table stores customer information.

Columns:

customer_id
customer_name
email
phone
city
registration_date

Customer email addresses are unique.

Products

The products table stores product information.

Columns:

product_id
product_name
category_id
price
supplier
created_at

Every product belongs to a category.

Inventory

The inventory table manages available stock.

Columns:

inventory_id
product_id
stock_quantity
reorder_level
last_restocked

Each product has one inventory record.

Orders

The orders table stores customer orders.

Columns:

order_id
customer_id
order_date
status

Order statuses:

Pending
Processing
Shipped
Delivered
Cancelled

Order Items

The order_items table stores the products included in orders.

Columns:

order_item_id
order_id
product_id
quantity
unit_price

An order can contain multiple products.

Payments

The payments table stores payment information.

Columns:

payment_id
order_id
payment_date
amount
payment_method
payment_status

Payment methods:

Card
UPI
Net Banking
Cash on Delivery

Inventory Audit

The inventory_audit table records inventory changes.

Columns:

audit_id
product_id
old_stock
new_stock
change_type
changed_at

The audit information is generated automatically by a trigger.

Constraints

The project uses:

PRIMARY KEY

FOREIGN KEY

UNIQUE

NOT NULL

CHECK

DEFAULT

Example:

CHECK (price > 0)

Sample Data

The database contains:

5 product categories

10 customers

15 products

15 inventory records

15 initial orders

Multiple order items

15 payments

The sample data allows realistic reporting and analytics.

Basic SQL Operations

The project demonstrates:

CREATE DATABASE
CREATE TABLE
INSERT
SELECT
UPDATE
DELETE

Product Catalog

Products and categories are combined using JOIN.

SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    p.price,
    p.supplier
FROM products p
JOIN categories c
    ON p.category_id = c.category_id;

This produces a complete product catalog.

Order Details

Order information can be combined with customers and products.

SELECT
    o.order_id,
    c.customer_name,
    o.order_date,
    o.status,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id;

Total Revenue

Revenue is calculated using:

SUM(quantity * unit_price)

Example:

SELECT
    SUM(quantity * unit_price) AS total_revenue
FROM order_items;

Total Orders

SELECT COUNT(*) AS total_orders
FROM orders;

Average Order Value

The project calculates order totals first and then calculates their average.

SELECT
    AVG(order_total) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(quantity * unit_price) AS order_total
    FROM order_items
    GROUP BY order_id
) AS order_summary;

Revenue by Category

SELECT
    c.category_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN categories c
    ON p.category_id = c.category_id
GROUP BY c.category_id,c.category_name
ORDER BY revenue DESC;

This identifies the highest-revenue categories.

Product Sales

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC;

This shows product sales performance.

Top Customers

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_spent DESC;

This identifies high-value customers.

Low Stock Report

SELECT
    p.product_id,
    p.product_name,
    i.stock_quantity,
    i.reorder_level
FROM inventory i
JOIN products p
    ON i.product_id = p.product_id
WHERE i.stock_quantity <= i.reorder_level
ORDER BY i.stock_quantity;

This identifies products that need attention.

Order Status Analysis

SELECT
    status,
    COUNT(*) AS order_count
FROM orders
GROUP BY status;

This provides an overview of order processing.

Payment Analysis

SELECT
    payment_method,
    COUNT(*) AS transactions,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_method
ORDER BY total_amount DESC;

This analyzes payment method usage.

Subquery

The project finds products priced above the average product price.

SELECT
    product_name,
    price
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
)
ORDER BY price DESC;

CTE

A Common Table Expression is used for product sales analysis.

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id,p.product_name
)
SELECT *
FROM product_sales
ORDER BY revenue DESC;

Window Function

Products are ranked according to revenue.

WITH product_revenue AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY p.product_id,p.product_name
)
SELECT
    product_name,
    revenue,
    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank
FROM product_revenue;

Views

The project creates three views:

sales_summary
product_performance
low_stock_report

Views make frequently used reports easier to query.

Sales Summary View

The sales_summary view provides:

Order date

Total orders

Units sold

Revenue

Product Performance View

The product_performance view provides:

Product

Category

Units sold

Revenue

Low Stock View

The low_stock_report view provides:

Product

Category

Current stock

Reorder level

Indexes

Indexes are created on frequently accessed columns:

products.category_id
orders.customer_id
orders.order_date
order_items.product_id
order_items.order_id
payments.payment_status

Indexes can improve lookup performance when appropriate.

Inventory Trigger

An AFTER UPDATE trigger records inventory changes.

CREATE TRIGGER after_inventory_update
AFTER UPDATE ON inventory
FOR EACH ROW
BEGIN
    IF OLD.stock_quantity <> NEW.stock_quantity THEN
        INSERT INTO inventory_audit
        (product_id,old_stock,new_stock,change_type)
        VALUES
        (NEW.product_id,OLD.stock_quantity,NEW.stock_quantity,'STOCK_UPDATE');
    END IF;
END;

Automatic Inventory Reduction

A second trigger reduces inventory when a new order item is inserted.

CREATE TRIGGER after_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;

This demonstrates automation in a real-world database.

Stored Procedures

The project contains:

GetCustomerOrders
GetLowStockProducts

These procedures provide reusable database operations.

Customer Orders Procedure

CALL GetCustomerOrders(1);

This retrieves the order history of a specific customer.

Low Stock Procedure

CALL GetLowStockProducts();

This returns products that are at or below their reorder level.

Transactions

The project also demonstrates transaction processing.

START TRANSACTION;

INSERT INTO orders(customer_id,status)
VALUES (4,'Processing');

INSERT INTO order_items
(order_id,product_id,quantity,unit_price)
VALUES (1,10,1,8999);

COMMIT;

If an operation fails, a transaction can use:

ROLLBACK;

Dashboard Metrics

The final dashboard query calculates:

Total orders

Customers with orders

Total units sold

Total revenue

Average item revenue

These metrics could later be displayed in a web dashboard.

Top 5 Products

The project identifies the five highest-revenue products.

SELECT
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id,p.product_name
ORDER BY revenue DESC
LIMIT 5;

Top 5 Customers

The project identifies the five customers with the highest spending.

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

Business Questions

The project answers:

What is total revenue?

How many orders exist?

What is average order value?

Which products sell the most?

Which products generate the most revenue?

Which categories generate the most revenue?

Who are the top customers?

Which customers place multiple orders?

Which products have low stock?

Which products are out of stock?

Which payment methods are most used?

What is the order status distribution?

Which cities generate the most revenue?

Which products cost more than average?

What are the top five products?

What are the top five customers?

How can inventory changes be audited?

How can stock be automatically reduced after an order?

SQL Concepts Practiced

Database Design
Primary Keys
Foreign Keys
Constraints
INSERT
SELECT
UPDATE
DELETE
WHERE
ORDER BY
GROUP BY
HAVING
JOIN
Subqueries
CTEs
Aggregate Functions
Window Functions
RANK
Views
Indexes
Triggers
Stored Procedures
Transactions
COMMIT
ROLLBACK

Aggregate Functions

Used functions:

COUNT()
SUM()
AVG()
MIN()
MAX()

JOIN Relationships

The project demonstrates:

customers → orders
orders → order_items
order_items → products
products → categories
products → inventory
orders → payments

Real-World Application

The database can represent the backend database of an online shopping application.

A larger application could follow:

Frontend
    ↓
Backend API
    ↓
MySQL
    ↓
Customers
Products
Orders
Inventory
Payments

Future Improvements

Possible future features:

Product reviews

Product ratings

Coupons

Discounts

Shipping information

Delivery tracking

Returns

Refunds

Supplier management

Purchase orders

Tax calculation

Loyalty points

Profit analysis

Monthly reports

Customer segmentation

Advanced inventory forecasting

Learning Outcomes

After completing this project, I practiced:

Relational database design

Database relationships

Constraints

Multi-table JOINs

Aggregation

Business analytics

Subqueries

CTEs

Window functions

Views

Indexes

Triggers

Stored procedures

Transactions

Inventory management

Sales analysis

Customer analysis

Business reporting

How to Run

Step 1

Open MySQL Workbench or another MySQL client.

Step 2

Open:

day63.sql

Step 3

Run the complete script.

The script will:

Create the database.

Create all tables.

Add constraints.

Insert sample data.

Run analytical queries.

Create views.

Create indexes.

Create triggers.

Create stored procedures.

Demonstrate a transaction.

Generate final reports.

Git Commands

git add .

git commit -m "Day 63 - Online Store Sales and Inventory Management System"

git push

Project Status

Day: 63
Project: Online Store Sales & Inventory Management System
Database: MySQL
Type: SQL Mini Project
Status: Completed

SQL-A-Day Progress

Day 59 - Advanced SQL Indexing
Day 60 - Advanced SQL Analytics Project
Day 61 - SQL Views
Day 62 - SQL Triggers
Day 63 - Online Store Sales & Inventory Management System

Author

Charan Kumar Reddy

B.Tech CSE - AI & ML

SQL-A-Day Learning Repository