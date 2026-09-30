# Day 83 — SQL Cohort Analysis & Retention Analytics

Today we learn a very practical and less-common SQL analytics concept:

> **Cohort Analysis & Retention Analytics**

Instead of asking only **how many users are active**, cohort analysis asks:

> **What happened to the users who joined during the same period?**

This is widely used in SaaS, e-commerce, mobile apps, subscriptions, marketplaces, product analytics, and data-engineering/analytics-engineering pipelines.

---

## 🎯 Today's Goal

You will learn:

- Cohorts and cohort assignment
- Cohort size
- Activity months
- Lifecycle month numbers
- Retention rate
- Retention matrices
- Monthly Active Users
- Cohort revenue
- Revenue per user
- Reactivation
- Customer lifecycle
- Lifetime revenue

---

## 🧠 What Is a Cohort?

A cohort is a group of users sharing a common starting characteristic.

The most common example is **signup month**:

```text
January 2026 cohort
February 2026 cohort
March 2026 cohort
April 2026 cohort
```

Users are analyzed according to when they entered the system.

---

## 📅 Cohort Month vs Activity Month

These are different.

```text
Signup month = when the user joined
Activity month = when the user was active
```

Example:

```text
Signup: January
Activity: March

Cohort = January
Activity month = March
Lifecycle month = 2
```

---

## 🔢 Lifecycle Month

We can convert calendar activity into a relative lifecycle number:

```text
Month 0 → Signup month
Month 1 → First month after signup
Month 2 → Second month after signup
Month 3 → Third month after signup
```

SQL:

```sql
TIMESTAMPDIFF(
    MONTH,
    cohort_month,
    activity_month
)
```

---

## 📊 Cohort Size

Cohort size is the number of users who joined in a given cohort.

```sql
SELECT
    DATE_FORMAT(signup_date,'%Y-%m-01') AS cohort_month,
    COUNT(*) AS cohort_size
FROM users
GROUP BY DATE_FORMAT(signup_date,'%Y-%m-01');
```

---

## 🔥 Retention

Retention measures how many users from a cohort remain active later.

Formula:

```text
Retention %
=
Retained Users
---------------- × 100
Cohort Size
```

Example:

```text
100 users joined
70 returned in Month 1

Retention = 70%
```

---

## 📈 Retention Matrix

A typical retention matrix looks like:

```text
Cohort       M0      M1      M2      M3
------------------------------------------
January      100%    70%     55%     42%
February     100%    75%     60%     48%
March        100%    68%     51%      -
```

This makes lifecycle behavior easy to analyze.

---

## 🧩 Why COUNT(DISTINCT) Matters

A single user can generate many events:

```text
login
purchase
login
purchase
logout
```

Those are five events but still only **one user**.

Therefore retention queries normally use:

```sql
COUNT(DISTINCT user_id)
```

---

## 👥 Monthly Active Users

MAU answers:

> How many unique users were active during a calendar month?

```sql
SELECT
    DATE_FORMAT(activity_date,'%Y-%m-01') AS activity_month,
    COUNT(DISTINCT user_id) AS active_users
FROM user_activity
GROUP BY DATE_FORMAT(activity_date,'%Y-%m-01');
```

MAU is a calendar metric; cohort retention is a lifecycle metric.

---

## 💰 Cohort Revenue

We can connect user cohorts with revenue:

```text
Cohort
   ↓
Users
   ↓
Activity
   ↓
Revenue
```

The SQL file calculates revenue by cohort and lifecycle month.

---

## 💵 Revenue Per User

```text
Revenue Per User
=
Cohort Revenue
----------------
Cohort Users
```

SQL:

```sql
ROUND(
    SUM(a.revenue) / COUNT(DISTINCT u.user_id),
    2
)
```

This helps compare cohorts of different sizes.

---

## 🔄 Reactivation

A user can become inactive and later return.

Example:

```text
January → Active
February → Active
March → No activity
April → Active
```

April can be treated as a reactivation according to the chosen definition.

The project uses:

```sql
LAG()
```

to compare consecutive active months.

If the gap is greater than one month, the query identifies a possible reactivation.

---

## 🚦 Lifecycle State

Users can be classified according to their latest activity:

```text
ACTIVE
INACTIVE
NO_ACTIVITY
```

The SQL file demonstrates this using an analysis month.

---

## 💎 Lifetime Revenue

Lifetime revenue is the total recorded revenue for a user:

```sql
SELECT
    user_id,
    SUM(revenue) AS lifetime_revenue
FROM user_activity
GROUP BY user_id;
```

This is useful for customer-value analysis.

---

## 🏗️ Data Engineering Connection

Cohort analysis fits naturally into an analytics pipeline:

```text
Application Events
       ↓
      S3
       ↓
    ETL / ELT
       ↓
 Data Warehouse
       ↓
 Clean Activity Tables
       ↓
 Cohort SQL Models
       ↓
 Retention Tables
       ↓
 BI Dashboard
```

A realistic warehouse model might look like:

```text
dim_users
    +
fct_user_activity
    ↓
cohort_retention
    ↓
dashboard
```

This is a practical example of SQL being used beyond basic querying.

---

## 🌍 Real-World Applications

### SaaS

Analyze:

```text
Signup
 ↓
Activation
 ↓
Month 1 retention
 ↓
Month 3 retention
 ↓
Long-term retention
```

### E-Commerce

Compare customers acquired in different months and measure:

- Repeat purchases
- Revenue
- Retention
- Reactivation

### Mobile Apps

Measure:

- Day 1 retention
- Day 7 retention
- Day 30 retention

### Subscription Products

Analyze:

```text
Signup
 ↓
Subscription
 ↓
Renewal
 ↓
Churn
 ↓
Reactivation
```

---

## ⚠️ Important Points

### 1. Cohort and activity month are different

Always distinguish:

```text
Signup month
```

from:

```text
Activity month
```

### 2. Use DISTINCT users

Multiple events from one user should not become multiple retained users.

### 3. Month 0 is normally the acquisition period

```text
Month 0 = signup month
```

### 4. Define "active" carefully

Activity could mean:

- Login
- Purchase
- App open
- Subscription
- Transaction
- Any meaningful business event

The business definition matters.

### 5. Retention and churn are related but different

Retention asks who remained active.

Churn asks who stopped being active according to a defined rule.

---

## 🧪 Practice Questions

### Beginner

1. Calculate cohort sizes.
2. Find activity months for every user.
3. Calculate lifecycle month.
4. Count retained users by cohort.
5. Calculate monthly active users.

### Intermediate

6. Calculate Month-1 retention.
7. Calculate Month-2 retention.
8. Build a retention matrix.
9. Calculate revenue by cohort.
10. Calculate revenue per cohort user.

### Advanced

11. Detect reactivated users.
12. Calculate lifecycle days.
13. Find lifetime revenue.
14. Identify users active in signup month but inactive in Month 1.
15. Build a complete cohort report containing:
    - cohort size
    - retained users
    - retention %
    - revenue
    - revenue per user

---

## 💼 Interview Questions

### 1. What is cohort analysis?

Analyzing groups of users who share a common starting characteristic, such as signup month.

### 2. What is a cohort?

A group of users sharing a common characteristic or starting period.

### 3. What is retention?

The percentage of a cohort that remains active during a later period.

### 4. Why use COUNT(DISTINCT user_id)?

Because one user can generate many events but should normally count once as an active user.

### 5. What is Month 0?

The cohort's initial period, usually the signup month.

### 6. What is reactivation?

A return to activity after a period of inactivity according to the selected business definition.

### 7. What is MAU?

Monthly Active Users — unique users active during a calendar month.

### 8. What is cohort revenue?

Revenue generated by users belonging to a particular cohort.

### 9. What is lifetime revenue?

Total recorded revenue generated by a user over the available activity history.

### 10. Why is cohort analysis useful?

It reveals how groups of users behave throughout their lifecycle instead of mixing users acquired at different times.

---

## 🛠️ Project Structure

```text
Day-83-SQL-Cohort-Retention-Analytics/
│
├── day83.sql
└── README.md
```

---

## ▶️ How to Run

Make sure MySQL 8.x is installed and running.

Open MySQL Workbench, MySQL CLI, or your SQL extension in VS Code.

Run:

```sql
SOURCE path/to/day83.sql;
```

The script creates:

```text
sql_cohort_lab
```

with:

```text
users
user_activity
```

---

## 📚 What You Learned

```text
Users
  ↓
Signup Date
  ↓
Cohort Assignment
  ↓
Activity
  ↓
Lifecycle Month
  ↓
Retention
  ↓
Retention Matrix
  ↓
Revenue Analysis
  ↓
Reactivation
  ↓
Customer Lifecycle
```

---

## 🚀 Day 83 Summary

**Topic:** SQL Cohort Analysis & Retention Analytics

**Main concepts:**

- Cohort assignment
- Cohort size
- Activity months
- Lifecycle months
- Retention
- Retention percentage
- Retention matrix
- MAU
- Cohort revenue
- Revenue per user
- Reactivation
- Lifecycle state
- Lifetime revenue
- Analytics engineering patterns

---

## 📈 SQL-A-Day Progress

```text
Day 83 / SQL-A-Day
███████████████████████████████████████████████████████████████████████████████████████
```

**83 days of SQL learning completed! 🔥**

---

## 🔗 Git Commands

```bash
git add .
git commit -m "Day 83 - SQL Cohort Retention Analytics"
git push
```

**Day 83 complete. 🚀**
