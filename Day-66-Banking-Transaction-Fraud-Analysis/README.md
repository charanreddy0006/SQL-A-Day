# Day 66 — Banking Transaction & Fraud Analysis System

## 📌 Project Overview

Day 66 focuses on building a practical banking database and using SQL for transaction analytics and fraud detection.

The project models customers, bank accounts, transaction categories, transactions, and fraud alerts.

The main goal is to move beyond basic CRUD queries and use SQL for financial analysis, customer spending analysis, transaction monitoring, risk classification, and suspicious transaction detection.

---

## 🎯 Objectives

- Design a relational banking database.
- Manage customer information.
- Manage bank accounts.
- Store transaction categories.
- Record credit and debit transactions.
- Analyze customer spending.
- Analyze account activity.
- Generate transaction reports.
- Classify transaction risk.
- Detect suspicious transactions.
- Detect high-value transactions.
- Detect unusual transaction locations.
- Detect unusual night-time transactions.
- Analyze rapid transaction sequences.
- Create fraud alerts.
- Use CTEs and window functions.
- Practice SQL views and indexes.

---

## 🗂️ Database

**Database Name:** `banking_fraud_analysis`

**SQL Dialect:** `MySQL 8+`

---

## 📁 Project Structure

```text
Day-66-Banking-Transaction-Fraud-Analysis/
│
├── README.md
└── day66.sql
```

---

## 🏦 Database Tables

### 1. Customers

Stores customer information.

```text
customer_id
customer_code
customer_name
email
phone
city
customer_status
created_at
```

### 2. Accounts

Stores customer bank accounts.

```text
account_id
account_number
customer_id
account_type
balance
account_status
opened_at
```

### 3. Transaction Categories

Stores transaction categories such as Salary, Shopping, Food, Utility, Transfer, ATM Withdrawal, Bill Payment, and Investment.

### 4. Transactions

Stores banking transactions.

```text
transaction_id
transaction_reference
account_id
category_id
transaction_type
amount
transaction_datetime
merchant_name
location
channel
transaction_status
```

Transaction types:

```text
Credit
Debit
```

Channels:

```text
ATM
POS
Online
Mobile
Branch
```

Statuses:

```text
Success
Failed
Pending
Reversed
```

### 5. Fraud Alerts

Stores suspicious transaction alerts.

```text
alert_id
transaction_id
alert_type
risk_score
alert_status
detected_at
```

Risk scores range from `0` to `100`.

---

## 🔗 Table Relationships

```text
Customers
    │
    └── Accounts
            │
            └── Transactions
                    │
                    ├── Transaction Categories
                    │
                    └── Fraud Alerts
```

---

## 🧠 SQL Concepts Practiced

```text
SELECT
WHERE
ORDER BY
GROUP BY
HAVING
INNER JOIN
LEFT JOIN
CASE
COALESCE
COUNT
SUM
DATE
TIME
DATE_FORMAT
TIMESTAMPDIFF
CTE
LAG
RANK
Window Functions
Subqueries
Views
Indexes
Fraud Detection
Risk Classification
```

---

## 💳 Credit and Debit Analysis

Transactions are divided into Credit and Debit transactions.

The project calculates total credit and debit amounts using aggregation functions.

---

## 👤 Customer Spending Analysis

The project calculates successful debit spending for every customer.

This helps identify high-spending customers and compare customer transaction activity.

---

## 📊 Transaction Category Analysis

Transactions are grouped by category and analyzed using `COUNT()` and `SUM()`.

This provides transaction volume and total value for different banking activities.

---

## 📅 Monthly Transaction Analysis

Transactions are grouped by month using:

```sql
DATE_FORMAT(transaction_datetime, '%Y-%m')
```

This provides monthly transaction volume and value.

---

## 🏷️ CASE-Based Risk Classification

Transactions are classified using `CASE` based on their amount.

```text
100000 or more → Critical
50000 or more  → High
20000 or more  → Medium
Below 20000    → Low
```

This demonstrates how SQL can convert raw data into business-friendly categories.

---

## 🌙 Night-Time Transaction Detection

Transactions between `11:00 PM` and `5:00 AM` are identified.

Night-time activity can be combined with other rules to identify transactions that deserve investigation.

---

## 💰 High-Value Transaction Detection

Transactions of `50,000` or more are identified and reported with customer, account, amount, date, and location information.

---

## ⚠️ Fraud Detection Rules

### Rule 1 — High-Value Night Transaction

Detects successful transactions that are both high-value and performed during night hours.

### Rule 2 — Large Debit Transaction

Detects successful debit transactions of `100000` or more.

### Rule 3 — Unusual Location

Compares the customer's registered city with the transaction location to identify activity outside the customer's normal registered location.

### Rule 4 — Rapid Transaction Sequence

The SQL file demonstrates `LAG()` to compare consecutive transactions for the same account and analyze short transaction intervals.

---

## 📈 LAG()

`LAG()` retrieves information from a previous transaction.

Example:

```sql
LAG(amount) OVER (
    PARTITION BY account_id
    ORDER BY transaction_datetime
)
```

This allows consecutive transactions to be compared.

---

## 🧮 Running Debit Total

A window function calculates the running debit total for each account.

This shows how spending accumulates over time.

---

## 🏆 Customer Spending Ranking

Customers are ranked according to total successful debit spending using `RANK()`.

---

## 🧩 Common Table Expressions

The project uses CTEs with the `WITH` keyword to organize multi-step analytical queries.

A customer risk summary is created by calculating transaction count and debit amount before assigning a risk level.

---

## 🚨 Fraud Alerts

Suspicious transactions are stored in the `fraud_alerts` table.

Each alert contains:

```text
Transaction
Alert Type
Risk Score
Alert Status
Detection Time
```

Alert statuses include:

```text
Open
Investigating
Confirmed
Dismissed
```

---

## 📋 Fraud Alert Report

A joined report displays customer, transaction, alert type, risk score, status, and detection time.

The results are ordered by risk score.

---

## 🏦 Account Transaction Summary

The project generates account-level statistics containing:

```text
Account Number
Customer
Transaction Count
Total Credits
Total Debits
```

---

## 👁️ SQL VIEW

The project creates a view named:

```text
transaction_details
```

The view combines customers, accounts, transactions, and transaction categories for easier reporting.

---

## ⚡ Indexes

Indexes are created for commonly searched columns:

```text
account_id + transaction_datetime
amount
transaction_status
location
risk_score
```

Indexes can improve query performance as transaction data grows.

---

## 📊 Banking Dashboard

The final dashboard query provides:

```text
Total Customers
Total Accounts
Total Transactions
Successful Transactions
Total Credits
Total Debits
Total Fraud Alerts
Highest Risk Score
```

---

## 🧪 Questions Answered

1. How many customers are in the bank?
2. How many accounts exist?
3. What is the total transaction volume?
4. What is the total credit amount?
5. What is the total debit amount?
6. Which customers spend the most?
7. Which transaction categories have the highest volume?
8. Which transactions are high value?
9. Which transactions occur at night?
10. Which transactions occur outside the customer's city?
11. Which transactions have a high risk level?
12. Which accounts have the highest debit activity?
13. Which customers have the highest spending rank?
14. Which transactions may represent rapid suspicious activity?
15. How many fraud alerts were generated?
16. Which customers have the highest fraud risk?
17. What is the running debit total for each account?
18. What was the previous transaction amount for an account?
19. What is the monthly transaction volume?
20. What is the overall banking transaction summary?

---

## 🛠️ Technologies Used

```text
MySQL 8+
SQL
Relational Database
MySQL Workbench
```

---

## ▶️ How to Run

Open MySQL Workbench or the MySQL command-line client.

Open:

```text
day66.sql
```

Execute the complete script.

The script will:

```text
1. Drop the old database if it exists.
2. Create the banking_fraud_analysis database.
3. Create all tables.
4. Add primary and foreign keys.
5. Insert sample data.
6. Run transaction analysis queries.
7. Run fraud detection queries.
8. Create fraud alerts.
9. Create the transaction_details view.
10. Create indexes.
11. Run the final banking dashboard query.
```

---

## 📚 Learning Outcome

After completing Day 66, I practiced how SQL can be used for real-world banking analytics.

The project demonstrates how SQL can support transaction monitoring, customer spending analysis, risk classification, fraud-alert generation, and reporting.

The major concepts practiced are:

```text
CTEs
CASE
LAG()
RANK()
Window Functions
Running Totals
Date/Time Functions
Aggregations
Joins
Subqueries
Views
Indexes
Risk Classification
Fraud Detection
Transaction Monitoring
```

---

## ⚠️ Important Note

The fraud detection rules in this project are educational examples. Real banking fraud detection systems use much more sophisticated rules, real-time monitoring, behavioral profiling, device intelligence, geolocation, machine learning, and regulatory controls.

This project focuses on understanding how SQL can support the analytical side of transaction monitoring.

---

## 🚀 Future Improvements

- Stored procedures for fraud detection.
- Triggers for automatic alerts.
- More advanced transaction velocity rules.
- Customer transaction behavior profiles.
- Merchant risk scoring.
- Device-level transaction tracking.
- Geographic distance calculations.
- Fraud investigation workflow.
- Automated daily reports.
- Advanced fraud scoring.
- Machine learning integration.
- Real-time transaction processing.
- Role-based database access.
- Audit logging.

---

## 📝 Day 66 Summary

**Project:** Banking Transaction & Fraud Analysis System

**Database:** `banking_fraud_analysis`

**Main Focus:** Banking transaction analytics and SQL-based fraud detection.

### Major New Concepts

```text
CASE
CTE
LAG()
RANK()
Window Functions
Running Totals
Risk Classification
Fraud Detection
Transaction Monitoring
Views
Indexes
```

---

## 📅 SQL-A-Day

**Day 66 completed ✅**

```text
Day 66
Banking Transaction & Fraud Analysis System
```

Continuing the SQL-A-Day journey with practical, real-world SQL projects.