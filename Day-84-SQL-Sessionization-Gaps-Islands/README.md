# Day 84 — SQL Sessionization & Gaps-and-Islands

Today we learn a powerful analytical SQL pattern:

> **Sessionization + Gaps-and-Islands**

Instead of treating every event independently, we turn timestamped events into meaningful **user sessions**.

This is useful in web analytics, mobile apps, e-commerce, clickstream processing, IoT, logs, and data-engineering pipelines.

---

## 🎯 Today's Goal

Learn:

- Sessionization
- Session timeout rules
- `LAG()`
- Time-gap calculation
- Session boundary detection
- Running `SUM()`
- Session IDs
- Session duration
- Entry/exit pages
- Session conversion
- Gaps-and-islands
- Consecutive activity analysis

---

## 🧠 What Is Sessionization?

Suppose a user produces:

```text
09:00
09:08
09:17
09:29
11:10
11:22
11:35
```

With a **30-minute inactivity timeout**:

```text
Session 1
09:00
09:08
09:17
09:29

       ↓ 101-minute gap

Session 2
11:10
11:22
11:35
```

A raw event stream becomes meaningful sessions.

---

## ⏱️ Session Timeout

For this project:

```text
gap <= 30 minutes → same session
gap > 30 minutes  → new session
```

The timeout is a business rule and can be changed.

---

## 🔍 Step 1 — Previous Event

Use:

```sql
LAG(event_time) OVER (
    PARTITION BY user_id
    ORDER BY event_time,event_id
)
```

Example:

```text
Current    Previous
09:00      NULL
09:08      09:00
09:17      09:08
09:29      09:17
11:10      09:29
```

---

## 📐 Step 2 — Calculate the Gap

```sql
TIMESTAMPDIFF(
    MINUTE,
    previous_event_time,
    event_time
)
```

Example:

```text
09:29 → 11:10
Gap = 101 minutes
```

Because:

```text
101 > 30
```

a new session begins.

---

## 🚦 Step 3 — Mark Session Boundaries

Create:

```text
1 = new session
0 = same session
```

Example:

```text
09:00 → 1
09:08 → 0
09:17 → 0
09:29 → 0
11:10 → 1
11:22 → 0
11:35 → 0
```

---

## 🔢 Step 4 — Create Session Numbers

A running sum turns:

```text
1 0 0 0 1 0 0
```

into:

```text
1 1 1 1 2 2 2
```

SQL:

```sql
SUM(new_session_flag) OVER (
    PARTITION BY user_id
    ORDER BY event_time,event_id
    ROWS UNBOUNDED PRECEDING
)
```

### Core pattern

```text
Events
  ↓
LAG()
  ↓
Previous event
  ↓
Time gap
  ↓
Boundary flag
  ↓
Running SUM()
  ↓
Session number
```

---

## 🆔 Session IDs

A session number is unique only within a user.

Therefore:

```sql
CONCAT(user_id,'-',session_number)
```

can create identifiers such as:

```text
1-1
1-2
2-1
2-2
```

---

## ⏳ Session Duration

For each session:

```sql
MIN(event_time) → session_start
MAX(event_time) → session_end
```

Duration:

```sql
TIMESTAMPDIFF(
    MINUTE,
    MIN(event_time),
    MAX(event_time)
)
```

---

## 📊 Session Analytics

Once events have session numbers, SQL can calculate:

- Total sessions
- Sessions per user
- Average session duration
- Average events per session
- Purchase sessions
- Conversion rate
- Entry pages
- Exit pages
- Longest sessions

---

## 🛒 Session Conversion

A session containing:

```text
page_view
click
purchase
```

can be considered converted.

Formula:

```text
Session Conversion Rate
=
Converted Sessions
------------------- × 100
Total Sessions
```

SQL uses:

```sql
MAX(event_type='purchase')
```

to identify whether a session contains a purchase.

---

## 🚪 Entry and Exit Pages

Example:

```text
/home
   ↓
/products
   ↓
/product/10
   ↓
/checkout
```

Result:

```text
Entry = /home
Exit  = /checkout
```

`ROW_NUMBER()` identifies the first and last event.

---

# 🧩 Gaps-and-Islands

Sessionization is a practical example of the broader:

> **Gaps-and-Islands pattern**

An **island** is a consecutive group.

A **gap** separates groups.

```text
Group A
1
2
3

GAP

Group B
7
8
9
```

A common SQL approach is:

```text
LAG()
  +
CASE
  +
Running SUM()
```

---

## 📅 Consecutive-Day Analysis

The same pattern can find activity streaks.

Example:

```text
Sep 1
Sep 2
Sep 3

Sep 8
Sep 9
```

These become:

```text
Island 1 → Sep 1 to Sep 3
Island 2 → Sep 8 to Sep 9
```

Useful for:

- Login streaks
- Daily active streaks
- Consecutive purchases
- Machine uptime
- Attendance
- IoT availability

---

# 🌍 Real-World Applications

### Web Analytics

```text
Raw clickstream
      ↓
Sessionization
      ↓
User sessions
      ↓
Conversion analysis
```

### Mobile Apps

```text
App opened
 ↓
Screen viewed
 ↓
Button clicked
 ↓
Purchase
```

### E-Commerce

Analyze:

```text
Landing
 ↓
Product
 ↓
Cart
 ↓
Checkout
 ↓
Purchase
```

### IoT / Automotive

Vehicle events can be grouped into continuous operating sessions:

```text
vehicle online
 ↓
GPS event
 ↓
sensor event
 ↓
sensor event
 ↓
vehicle offline
```

---

# 🏗️ Data Engineering Connection

A realistic pipeline:

```text
Application / IoT Events
          ↓
         Kafka
          ↓
          S3
          ↓
    Data Warehouse
          ↓
     Raw Event Table
          ↓
      Sessionization
          ↓
    Session Fact Table
          ↓
      BI Dashboard
```

Possible warehouse flow:

```text
fct_events
    ↓
sessionized_events
    ↓
fct_sessions
    ↓
analytics dashboard
```

---

# ⚠️ Important Points

### 1. Ordering matters

Use:

```sql
ORDER BY event_time,event_id
```

so events with identical timestamps have deterministic ordering.

### 2. Timeout is a business rule

30 minutes is only an example.

### 3. Duplicate events matter

Real pipelines often deduplicate events before sessionization.

### 4. Late-arriving events matter

Events arriving out of order can change session boundaries and may require reprocessing.

### 5. Sessionization is not a SQL transaction

A user session is an analytics concept.

A database transaction uses:

```text
BEGIN
COMMIT
ROLLBACK
```

They are unrelated concepts.

---

# 🧪 Practice Questions

### Beginner

1. Change the timeout from 30 to 20 minutes.
2. Display the previous event for every user.
3. Calculate every event's gap.
4. Count sessions per user.
5. Calculate average events per session.

### Intermediate

6. Find the longest session for every user.
7. Find sessions containing a purchase.
8. Calculate session conversion rate.
9. Find entry and exit pages.
10. Find users with at least two sessions.

### Advanced

11. Find the longest inactivity gap per user.
12. Find users active on at least three consecutive days.
13. Build a daily report with:
    - date
    - unique users
    - sessions
    - events
    - purchases
14. Calculate conversion rate per user.
15. Build a reusable session fact table.

---

# 💼 Interview Questions

### 1. What is sessionization?

Grouping a sequence of events into sessions according to an inactivity or business rule.

### 2. Why is `LAG()` useful?

It lets us compare an event with the previous event.

### 3. Why use a running `SUM()`?

A cumulative sum of boundary flags creates sequential session numbers.

### 4. What is gaps-and-islands?

A SQL technique for identifying consecutive groups separated by gaps.

### 5. What creates a new session?

In this project, an inactivity gap greater than 30 minutes.

### 6. Why include `event_id` in ordering?

It provides deterministic ordering when timestamps are identical.

### 7. What is session duration?

Time between the first and last event in a session.

### 8. What is session conversion rate?

The percentage of sessions satisfying a conversion condition such as containing a purchase.

### 9. Can late events affect sessionization?

Yes. Out-of-order events can change session boundaries.

### 10. Is sessionization the same as a database transaction?

No. Sessionization groups analytical events; transactions provide database consistency.

---

# 🛠️ Project Structure

```text
Day-84-SQL-Sessionization-Gaps-Islands/
│
├── day84.sql
└── README.md
```

---

# ▶️ How to Run

Make sure MySQL 8.x is installed and running.

Open MySQL Workbench, MySQL CLI, or your SQL extension in VS Code.

Run:

```sql
SOURCE path/to/day84.sql;
```

The script creates:

```text
sql_sessionization_lab
```

with:

```text
user_events
sessionized_events
```

---

# 📚 What You Learned

```text
Raw Events
    ↓
LAG()
    ↓
Previous Event
    ↓
Time Gap
    ↓
Session Boundary
    ↓
Running SUM()
    ↓
Session Number
    ↓
Session Analytics
```

And the broader pattern:

```text
Gaps + Islands
      ↓
Consecutive Groups
```

---

# 🚀 Day 84 Summary

**Topic:** SQL Sessionization & Gaps-and-Islands

**Main concepts:**

- Event streams
- Sessionization
- Session timeout
- `LAG()`
- `TIMESTAMPDIFF()`
- Session boundary detection
- Running `SUM()`
- Session IDs
- Session duration
- Entry/exit pages
- Session conversion
- Gaps-and-islands
- Consecutive-day analysis
- Event-stream analytics

---

# 📈 SQL-A-Day Progress

```text
Day 84 / SQL-A-Day
████████████████████████████████████████████████████████████████████████████████████████
```

**84 days of SQL learning completed! 🔥**

---

# 🔗 Git Commands

```bash
git add .
git commit -m "Day 84 - SQL Sessionization and Gaps Islands"
git push
```

**Day 84 complete. 🚀**
