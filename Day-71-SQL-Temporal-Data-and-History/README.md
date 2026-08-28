Day 71 — SQL Temporal Data, History Tracking, Auditing & SCD Type 2

Project

SQL-A-Day — Day 71

Topic: Temporal Data, History Tracking, Auditing & Slowly Changing Dimensions

Database: sql_temporal_history_lab

SQL Dialect: MySQL 8+

Files

Day-71-SQL-Temporal-Data-and-History/
│
├── day71.sql
└── README.md

1. Overview

Day 71 introduces a new area of SQL: time-aware and historical data management.

A normal table usually represents the current state of an entity.

For example:

Customer 1
City = Hyderabad

Real systems often need more information:

Where was the customer last month?
When did the address change?
What was the previous address?
Who changed the record?
What was the product price at a particular date?

These requirements lead to:

Temporal Data
History Tables
Audit Logs
Record Versioning
Point-in-Time Queries
SCD Type 1
SCD Type 2
Historical Analytics

2. Learning Objectives

By completing Day 71, you should understand:

Temporal data

Historical data

Current versus historical records

Effective dates

valid_from

valid_to

is_current

Point-in-time queries

History tables

Audit logs

JSON audit values

Record versioning

SCD Type 1

SCD Type 2

Valid-time concepts

Transaction-time concepts

Historical price tracking

Historical customer tracking

Window functions over history

ROW_NUMBER()

LAG()

Change detection

Data-quality checks

Overlapping validity periods

Temporal query patterns

Data-warehouse use cases

3. What Is Temporal Data?

Temporal data is data associated with time.

Instead of storing only:

Customer → Hyderabad

a temporal design can store:

Customer 1

Mumbai
2025-01-05 → 2025-04-10

Bengaluru
2025-04-10 → 2025-07-15

Hyderabad
2025-07-15 → Current

This makes it possible to reconstruct the customer's state at different points in time.

4. Current Data vs Historical Data

A current-state table might contain:

customer_id | city
------------+----------
1           | Hyderabad

A history table can contain:

customer_id | city       | valid_from | valid_to
------------+------------+------------+------------
1           | Mumbai     | Jan 05     | Apr 10
1           | Bengaluru  | Apr 10     | Jul 15
1           | Hyderabad  | Jul 15     | NULL

The current table gives the latest state.

The history table gives the sequence of states.

5. Why Historical Data Matters

Historical information is important in:

Banking
Finance
Insurance
E-commerce
CRM
ERP
Data Warehousing
Auditing
Compliance
Analytics

Examples:

Customer address changes
Product price changes
Employee department changes
Account status changes
Customer classification changes
Configuration changes

6. Project Architecture

The project contains:

customers
     │
     ▼
customer_history


products
     │
     ▼
product_price_history


audit_log

The overall idea is:

Current Data
     │
     ├──────────────► Historical Versions
     │
     └──────────────► Audit Events

7. Main Tables

customers

Stores the current customer state.

Important columns:

customer_id
customer_name
email
city
state
customer_status
created_at
updated_at

customer_history

Stores customer versions.

Important columns:

history_id
customer_id
city
state
valid_from
valid_to
is_current
change_type
changed_at
changed_by

products

Stores current product information.

product_price_history

Stores product price versions.

audit_log

Stores generic change information.

8. Effective Dating

History records commonly use:

valid_from
valid_to

For example:

valid_from = 2025-04-10
valid_to   = 2025-07-15

means that the version is valid during that period.

The current version uses:

valid_to = NULL

in this project.

9. Point-in-Time Query

A point-in-time query asks:

What was true at a particular timestamp?

The general pattern is:

WHERE valid_from <= :as_of_time
AND (
    valid_to IS NULL
    OR valid_to > :as_of_time
)

This is one of the most important temporal SQL patterns.

10. Example

Suppose a customer has:

Mumbai
Jan 05 → Apr 10

Bengaluru
Apr 10 → Jul 15

Hyderabad
Jul 15 → NULL

Question:

Where was the customer on May 1?

Answer:

Bengaluru

because:

Apr 10 <= May 1
May 1 < Jul 15

11. Current Version

The project identifies the current history row with:

is_current = TRUE

Example:

SELECT *
FROM customer_history
WHERE is_current = TRUE;

The composite index:

(customer_id, is_current)

supports this type of access pattern.

12. Closing an Old Version

When a record changes, the old version is closed.

Conceptually:

Old Version
     ↓
valid_to = change time
     ↓
is_current = FALSE

Example:

UPDATE customer_history
SET
    valid_to = '2025-04-10 10:00:00',
    is_current = FALSE
WHERE customer_id = 1
AND is_current = TRUE;

The old data remains available.

13. Creating a New Version

After closing the old version:

New Version
     ↓
valid_from = change time
valid_to   = NULL
is_current = TRUE

This creates a new historical version instead of destroying the old one.

14. Record Versioning

Versioning means storing multiple versions of the same logical entity.

Example:

Customer ID = 1

Version 1 → Mumbai
Version 2 → Bengaluru
Version 3 → Hyderabad

The:

history_id

uniquely identifies each version.

15. History Table Benefits

History tables provide:

Auditability
Historical reporting
Change analysis
Point-in-time reconstruction
Debugging
Compliance support
Data lineage

16. Product Price History

Product pricing is a common temporal-data use case.

Example:

Laptop Pro 14

85000
   ↓
92000
   ↓
88000

The system can answer:

What is the current price?
What was the price in June?
When did the price change?
Who changed it?
How much did the price change?

17. Historical Price Query

The project demonstrates:

SELECT
    product_id,
    old_price,
    new_price,
    valid_from,
    valid_to
FROM product_price_history
WHERE product_id = 1
AND valid_from <= '2025-06-01 00:00:00'
AND (
    valid_to IS NULL
    OR valid_to > '2025-06-01 00:00:00'
);

This retrieves the price version active at that time.

18. Audit Logs

A history table answers:

What versions existed?

An audit log focuses on:

What action happened?
Who performed it?
When did it happen?
What were the old values?
What were the new values?

The project implements a generic audit table.

19. Audit Log Structure

The table contains:

audit_id
table_name
record_id
action_type
old_values
new_values
changed_at
changed_by

Example:

table_name = products
record_id = 1
action_type = UPDATE

old_values:
{"price": 85000}

new_values:
{"price": 92000}

changed_by:
pricing_admin

20. JSON Audit Values

The project uses MySQL's:

JSON

data type.

Example:

JSON_OBJECT(
    'price', 85000
)

This is useful for generic audit logging because different tables can have different columns.

21. Reading JSON

The project demonstrates:

JSON_EXTRACT()

and:

JSON_UNQUOTE()

Example:

JSON_UNQUOTE(
    JSON_EXTRACT(old_values, '$.price')
)

This extracts a value from the JSON document.

22. Audit vs History

They are related but have different purposes.

History

Focuses on:

What versions existed?

Audit

Focuses on:

What action happened?
Who did it?
When did it happen?
What changed?

A production system may use both.

23. SCD

SCD means:

Slowly Changing Dimension

It is a data-warehousing concept used when dimension attributes change over time.

Examples:

Customer city
Customer state
Customer segment
Employee department
Store location
Product classification

24. SCD Type 1

SCD Type 1 overwrites the old value.

Before:

Customer 1
City = Mumbai

After:

Customer 1
City = Hyderabad

The old value is no longer stored in the current table.

Example:

UPDATE customers
SET city = 'Hyderabad'
WHERE customer_id = 1;

25. SCD Type 1 Advantages

Simple
Easy to implement
Easy to query
Lower storage requirements
Good for current-state reporting

26. SCD Type 1 Disadvantages

Historical values are lost
Point-in-time analysis is difficult
Previous states cannot be reconstructed

27. SCD Type 2

SCD Type 2 preserves historical versions.

Instead of:

Mumbai → Hyderabad

it stores:

Mumbai
Jan → Apr

Hyderabad
Apr → Current

The project demonstrates this approach using customer_history.

28. SCD Type 2 Structure

Typical columns include:

Business key
Dimension attributes
valid_from
valid_to
is_current

This project uses:

customer_id
customer_name
email
city
state
customer_status
valid_from
valid_to
is_current

29. SCD Type 2 Workflow

When a value changes:

Current Version
      ↓
Close Current Version
      ↓
Set valid_to
      ↓
Set is_current = FALSE
      ↓
Insert New Version
      ↓
Set valid_from
      ↓
Set valid_to = NULL
      ↓
Set is_current = TRUE

30. SCD Type 1 vs Type 2

Feature

SCD Type 1

SCD Type 2

Keeps history

No

Yes

Overwrites values

Yes

No

Point-in-time analysis

Limited

Yes

Storage

Lower

Higher

Complexity

Lower

Higher

Historical reporting

Weak

Strong

31. Valid Time

Valid time represents when a fact is considered valid in the modeled business context.

Example:

Customer lived in Bengaluru

Valid From:
2025-04-10

Valid To:
2025-07-15

32. Transaction Time

Transaction time describes when the database recorded information.

For example:

Business event:
April 10

Database records the event:
April 11

These are different concepts.

This project mainly demonstrates effective-date history and audit timestamps rather than a complete bitemporal implementation.

33. ROW_NUMBER() on History

The project uses:

ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY valid_from
)

This assigns a version number.

Example:

Customer 1
Version 1
Version 2
Version 3

This is useful when analyzing historical sequences.

34. LAG()

LAG() allows the current historical row to access a previous row.

Example:

LAG(city) OVER (
    PARTITION BY customer_id
    ORDER BY valid_from
)

This makes it possible to compare:

Previous City
Current City

35. Change Detection

The project uses LAG() to identify changes.

Conceptually:

Previous Value
      ↓
Compare
      ↓
Current Value
      ↓
Different?
      ↓
Change Detected

This can be useful in:

Data quality
Analytics
Auditing
Change reporting
ETL pipelines

36. Detecting State Changes

The same approach can identify:

Mumbai → Maharashtra
Bengaluru → Karnataka
Hyderabad → Telangana

and determine when the state changed.

37. Data Quality Rules

Temporal systems should enforce or monitor rules such as:

One current version per entity
No overlapping validity periods
valid_from < valid_to
Historical versions should have a closing time
Current versions should normally have valid_to = NULL

38. Overlapping Periods

Bad history:

Version A
Jan 01 → Jun 01

Version B
May 01 → Aug 01

The periods overlap.

Then a point-in-time query for:

May 15

could return multiple versions.

That creates ambiguity.

39. Overlap Detection

The project includes a query that compares historical versions for the same customer.

It detects whether:

Period A overlaps Period B

This is an important temporal-data quality check.

40. Current Version Validation

The project checks for:

is_current = TRUE
AND valid_to IS NOT NULL

This can identify inconsistent current rows.

41. Historical Version Validation

The project also checks:

is_current = FALSE
AND valid_to IS NULL

This can identify historical versions that were not properly closed.

42. Transactions and History

In production, updating current data and history should generally be treated as one logical operation.

Conceptually:

BEGIN
   ↓
Close Old Version
   ↓
Update Current Record
   ↓
Insert New Version
   ↓
Insert Audit Record
   ↓
COMMIT

If an error occurs:

ROLLBACK

This helps keep current and historical data consistent.

43. Production SCD Type 2 Pattern

A typical pipeline is:

Incoming Data
      ↓
Compare With Current Version
      ↓
Changed?
   ↙       ↘
 No        Yes
 ↓           ↓
Ignore     Close Old Version
              ↓
          Insert New Version
              ↓
          Record Audit Event

44. Detecting Whether Data Changed

Suppose current data is:

City = Mumbai
State = Maharashtra

Incoming data is:

City = Hyderabad
State = Telangana

The attributes changed.

For SCD Type 2:

Close old version
Insert new version

If the incoming values are identical:

No new historical version is required

45. Business Key and History Key

A logical customer can remain identified by:

customer_id

while every historical version receives:

history_id

Example:

history_id | customer_id | city
-----------+-------------+-----------
1          | 1           | Mumbai
2          | 1           | Bengaluru
3          | 1           | Hyderabad

The business entity is still:

customer_id = 1

46. Temporal Query Pattern

Remember this pattern:

WHERE valid_from <= :as_of_time
AND (
    valid_to IS NULL
    OR valid_to > :as_of_time
)

It answers:

What was true at that point in time?

47. Current-State Query Pattern

For the current version:

WHERE is_current = TRUE

This is simple and can be efficiently indexed.

48. Full History Query

To retrieve all versions:

SELECT *
FROM customer_history
WHERE customer_id = 1
ORDER BY valid_from;

This reconstructs the customer's history.

49. Historical Reporting

With historical data, SQL can answer:

How many times did a customer change city?

Which customers changed state?

What was a customer's city in June?

What was a product's price in May?

Which products increased in price?

How long did a customer remain in a particular location?

50. Data Engineering Connection

SCD Type 2 is strongly connected to data engineering.

It is commonly used in:

ETL
ELT
Data Warehouses
Dimensional Modeling
Analytics Platforms
Lakehouse Systems

A typical pipeline is:

Source
  ↓
Extract
  ↓
Transform
  ↓
Compare Current Dimension
  ↓
Close Old Version
  ↓
Insert New Version
  ↓
Analytics

51. Temporal Data in Warehouses

A data warehouse often needs historical truth.

Instead of asking only:

What is true now?

analysts may ask:

What was true at the time of the transaction?

Historical dimensions make these analyses possible.

52. Historical Analytics Examples

Possible reports include:

Customer state distribution by month
Customer movement between cities
Historical product prices
Price increase analysis
Customer segment changes
Historical employee departments

53. Performance Considerations

History tables can become much larger than current tables.

For example:

Current customers
= 1 million rows

History
= potentially several million rows

Therefore, production history tables may require:

Indexes
Partitioning
Archiving
Retention policies
Efficient date filtering
Storage planning

54. Useful History Indexes

The project includes:

(customer_id)
(customer_id, is_current)
(customer_id, valid_from, valid_to)
(valid_from)
(valid_to)

These support common historical access patterns.

55. History Table Growth

Frequent changes create many versions:

1 customer
    ↓
many changes
    ↓
many history rows

This should be considered when designing a production system.

56. Audit Retention

Audit data may also grow continuously.

Production systems should define appropriate:

Retention
Archival
Storage
Access controls
Indexing

The exact policy depends on business requirements.

57. Day 71 Exercises

Exercise 1

Create history for customer 3.

Move the customer:

Mumbai
   ↓
Pune
   ↓
Hyderabad

Exercise 2

Answer:

Where was customer 3 on 2025-06-01?

Use a point-in-time query.

Exercise 3

Change the price of:

Smartphone X

three times.

Create a complete price history.

Exercise 4

Find:

Products whose price increased by more than 10%.

Exercise 5

Find:

Customers with more than one historical version.

Exercise 6

Use:

LAG()

to identify previous and current customer locations.

Exercise 7

Find:

Customers who changed state.

Exercise 8

Write a query that detects overlapping validity periods.

58. Interview Questions

What is temporal data?

Data associated with time, allowing historical or time-based analysis.

What is a history table?

A table that preserves previous and/or current versions of logical records.

What is a point-in-time query?

A query that retrieves the version valid at a specified time.

What is SCD?

Slowly Changing Dimension.

What is SCD Type 1?

It overwrites an old value and does not preserve the previous version.

What is SCD Type 2?

It creates a new version and preserves the previous version.

Why use valid_from and valid_to?

They define the validity period of a version.

What does is_current mean?

It identifies the current version in this history-table design.

What is an audit log?

A record describing changes, including action, timestamp, old values, new values, and user.

Why use JSON for audit values?

It provides a flexible way to store old and new values for different tables.

What is LAG() useful for?

Comparing a historical row with its previous row.

Why are overlapping periods a problem?

They can make point-in-time results ambiguous.

59. Day 70 vs Day 71

Day 70

Query Optimization
      ↓
EXPLAIN
      ↓
Execution Plans
      ↓
Indexes
      ↓
JOIN Optimization
      ↓
Sargability

Day 71

Temporal Data
      ↓
History
      ↓
Versioning
      ↓
Point-in-Time Queries
      ↓
Audit Logs
      ↓
SCD Type 1
      ↓
SCD Type 2
      ↓
Historical Analytics

Day 71 introduces a new direction toward:

Data Engineering
Data Warehousing
Dimensional Modeling
Historical Analytics

60. Key Takeaways

1. Current data is not always enough.
2. Historical data preserves previous states.
3. Temporal designs associate records with time.
4. valid_from identifies the beginning of a version.
5. valid_to identifies the end of a version.
6. NULL valid_to can represent the current version.
7. Point-in-time queries retrieve historically valid rows.
8. History tables support historical reporting.
9. Audit logs record change events.
10. JSON can store flexible audit values.
11. SCD Type 1 overwrites values.
12. SCD Type 2 preserves versions.
13. ROW_NUMBER() can number historical versions.
14. LAG() can compare previous values.
15. Temporal systems should avoid overlapping periods.
16. History tables can grow significantly.
17. Appropriate indexes help temporal queries.
18. Transactions help keep current and history data consistent.
19. SCD Type 2 is important in data warehousing.
20. Historical data enables point-in-time analytics.

61. Completion Checklist

[ ] Created temporal database
[ ] Created customers table
[ ] Created customer_history table
[ ] Created products table
[ ] Created product_price_history table
[ ] Created audit_log table
[ ] Inserted sample data
[ ] Created initial history
[ ] Updated customer history
[ ] Updated product price history
[ ] Practiced point-in-time queries
[ ] Practiced current-version queries
[ ] Practiced historical reports
[ ] Practiced JSON audit data
[ ] Practiced SCD Type 1
[ ] Practiced SCD Type 2
[ ] Practiced ROW_NUMBER()
[ ] Practiced LAG()
[ ] Detected historical changes
[ ] Checked current-version consistency
[ ] Checked historical-version consistency
[ ] Checked overlapping periods
[ ] Generated audit summaries

62. Final Lesson

The central lesson of Day 71 is:

Current Data
     +
Historical Data
     +
Time
     +
Audit Information
     =
Traceable Data

For data warehousing:

SCD Type 1
→ Keep the latest value

SCD Type 2
→ Keep the historical versions

The most important temporal SQL pattern is:

WHERE valid_from <= :as_of_time
AND (
    valid_to IS NULL
    OR valid_to > :as_of_time
)

This allows SQL to answer:

"What was true at that point in time?"

That question is fundamental to historical databases, auditing systems, data warehouses, and data engineering.

63. Next Learning Direction

A natural progression is:

Day 72
Advanced Recursive CTEs
        ↓
Day 73
Stored Procedures
        ↓
Day 74
Triggers and Automated Auditing
        ↓
Day 75
Transactions, Locks and Isolation Levels
        ↓
Day 76
SQL Data Warehousing
        ↓
Day 77
Fact and Dimension Tables
        ↓
Day 78
Advanced SCD Type 2 Pipeline

Day 71 establishes the foundation for working with historical, auditable, and time-aware data in real-world SQL systems.