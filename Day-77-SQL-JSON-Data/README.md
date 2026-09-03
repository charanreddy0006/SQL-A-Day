Day 77 — SQL JSON Data & JSON Querying

Welcome to Day 77 of SQL-A-Day 🚀

Today we learn how to work with JSON data inside MySQL.

Modern applications, APIs, event systems, and data pipelines frequently work with semi-structured JSON. MySQL allows JSON to be stored and queried directly while still giving us normal SQL capabilities.

Topic

SQL JSON Data & JSON Querying

Today we learn:

MySQL JSON data type

JSON_OBJECT()

JSON_ARRAY()

JSON_EXTRACT()

->

->>

JSON_VALUE()

JSON_SET()

JSON_INSERT()

JSON_REPLACE()

JSON_REMOVE()

JSON_CONTAINS()

JSON_CONTAINS_PATH()

JSON_KEYS()

JSON_LENGTH()

JSON_VALID()

JSON_TYPE()

JSON_DEPTH()

JSON_TABLE()

JSON filtering and analytics

Generated columns

Indexing JSON-derived values

1. What Is JSON?

JSON stands for JavaScript Object Notation. It is a lightweight format for representing structured and semi-structured information.

Example:

{
  "name": "Arjun",
  "age": 22,
  "city": "Hyderabad"
}

JSON supports strings, numbers, booleans, null, objects, and arrays.

2. Why Use JSON in SQL?

Some application data is flexible and does not have exactly the same fields for every record.

For example, a login event may contain:

{
  "device": {
    "type": "mobile",
    "os": "Android"
  },
  "location": {
    "city": "Hyderabad"
  },
  "browser": "Chrome"
}

A purchase event may instead contain:

{
  "payment": {
    "method": "UPI"
  },
  "coupon": "WELCOME20",
  "items": []
}

JSON is useful for flexible metadata, event attributes, API payloads, and optional attributes.

Core business attributes such as customer_id, order_id, order_date, and order_status are still often better represented as relational columns.

3. Today's Project

We build a Customer Event & Product Metadata Analytics Lab.

Database:

sql_json_lab

Tables:

customers
products
customer_events
orders

The design intentionally combines:

Relational data
      +
JSON metadata

This is a common pattern in real applications and data pipelines.

4. JSON Data Type

The customer_events table contains:

 event_metadata JSON NOT NULL

The orders table contains:

 order_metadata JSON NOT NULL

Example order metadata:

{
  "payment": {
    "method": "UPI",
    "provider": "GooglePay"
  },
  "shipping": {
    "method": "EXPRESS",
    "city": "Hyderabad"
  },
  "coupon": "SUMMER10",
  "items": []
}

5. JSON Paths

MySQL uses JSON paths to locate values inside documents.

For:

{
  "device": {
    "type": "mobile"
  }
}

the path to type is:

$.device.type

The $ represents the root.

Examples:

$.device
$.device.type
$.device.os
$.location.city
$.payment.method
$.items

6. JSON_OBJECT()

Create a JSON object:

SELECT JSON_OBJECT(
    'name', 'Charan',
    'role', 'Data Engineer',
    'skills', JSON_ARRAY('SQL', 'Python', 'Spark')
);

This is useful when SQL needs to produce JSON for an application or API.

7. JSON_ARRAY()

Create an array:

SELECT JSON_ARRAY(
    'SQL',
    'Python',
    'Spark',
    'Flink'
);

Conceptually:

[
  "SQL",
  "Python",
  "Spark",
  "Flink"
]

8. JSON_EXTRACT()

Extract a value using a JSON path:

SELECT
    event_id,
    JSON_EXTRACT(
        event_metadata,
        '$.device.type'
    ) AS device_type
FROM customer_events;

9. The -> Operator

The short form of JSON extraction is:

event_metadata->'$.device.type'

Example:

SELECT
    event_id,
    event_metadata->'$.device.type' AS device_type
FROM customer_events;

10. The ->> Operator

->> extracts a JSON scalar as an unquoted SQL value.

Example:

SELECT
    event_id,
    event_metadata->>'$.device.type' AS device_type
FROM customer_events;

It is especially convenient in WHERE, GROUP BY, and reporting queries.

11. JSON_VALUE()

Another way to extract a scalar value is:

SELECT
    event_id,
    JSON_VALUE(
        event_metadata,
        '$.device.type'
    ) AS device_type
FROM customer_events;

12. Extract Nested JSON

For:

{
  "location": {
    "city": "Hyderabad",
    "country": "India"
  }
}

we can write:

SELECT
    event_id,
    event_metadata->>'$.location.city' AS city,
    event_metadata->>'$.location.country' AS country
FROM customer_events;

13. Filter Using JSON

JSON values can be used in normal SQL predicates:

SELECT
    event_id,
    customer_id,
    event_type
FROM customer_events
WHERE event_metadata->>'$.device.type' = 'mobile';

This finds mobile-device events.

14. JSON_CONTAINS_PATH()

Check whether a JSON path exists:

SELECT
    event_id,
    JSON_CONTAINS_PATH(
        event_metadata,
        'one',
        '$.device'
    ) AS has_device
FROM customer_events;

one means at least one supplied path should exist.

all means all supplied paths should exist.

Example:

JSON_CONTAINS_PATH(
    event_metadata,
    'all',
    '$.device',
    '$.location'
)

15. JSON_CONTAINS()

Check whether JSON contains a value:

SELECT
    event_id,
    event_type
FROM customer_events
WHERE JSON_CONTAINS(
    event_metadata,
    '"summer_sale"',
    '$.campaign'
);

16. JSON_LENGTH()

For arrays, JSON_LENGTH() tells us how many elements are present.

SELECT
    event_id,
    JSON_LENGTH(
        event_metadata->'$.items'
    ) AS item_count
FROM customer_events
WHERE event_type = 'PURCHASE';

17. JSON_KEYS()

Inspect the keys in a JSON object:

SELECT
    event_id,
    JSON_KEYS(event_metadata) AS top_level_keys
FROM customer_events;

This is useful when exploring an unfamiliar JSON structure.

18. Modify JSON With JSON_SET()

JSON_SET() adds or replaces a value.

SELECT JSON_SET(
    '{"name":"Arjun","city":"Hyderabad"}',
    '$.membership',
    'GOLD'
);

It can also update an existing JSON path.

19. JSON_INSERT()

JSON_INSERT() inserts a value when the path does not already exist.

UPDATE customer_events
SET event_metadata = JSON_INSERT(
    event_metadata,
    '$.session_id',
    'SESSION-1001'
)
WHERE event_id = 1;

20. JSON_REPLACE()

JSON_REPLACE() replaces an existing value.

UPDATE customer_events
SET event_metadata = JSON_REPLACE(
    event_metadata,
    '$.browser',
    'Chrome Mobile'
)
WHERE event_id = 1;

It does not create a missing path.

21. JSON_REMOVE()

Remove a JSON value:

UPDATE customer_events
SET event_metadata = JSON_REMOVE(
    event_metadata,
    '$.ip'
)
WHERE event_id = 1;

22. Query Order Metadata

Extract payment information:

SELECT
    order_id,
    order_metadata->>'$.payment.method' AS payment_method,
    order_metadata->>'$.payment.provider' AS provider
FROM orders;

Extract shipping information:

SELECT
    order_id,
    order_metadata->>'$.shipping.method' AS shipping_method,
    order_metadata->>'$.shipping.city' AS shipping_city
FROM orders;

23. Filter Orders by JSON

Example:

SELECT
    order_id,
    customer_id
FROM orders
WHERE order_metadata->>'$.payment.method' = 'UPI';

JSON attributes can therefore be used like normal SQL filter values.

24. JSON Arrays

An order can contain an array such as:

{
  "items": [
    {
      "product_id": 1,
      "quantity": 1,
      "price": 1299
    },
    {
      "product_id": 2,
      "quantity": 1,
      "price": 49
    }
  ]
}

For analytics, we often want:

JSON array
    ↓
individual objects
    ↓
SQL rows

25. JSON_TABLE() — The Most Important Part of Day 77

JSON_TABLE() converts JSON into a relational table-like result.

Example:

SELECT
    o.order_id,
    item.product_id,
    item.quantity,
    item.price
FROM orders AS o
JOIN JSON_TABLE(
    o.order_metadata,
    '$.items[*]'
    COLUMNS (
        product_id INT PATH '$.product_id',
        quantity INT PATH '$.quantity',
        price DECIMAL(10,2) PATH '$.price'
    )
) AS item ON TRUE;

Conceptually:

JSON
  ↓
JSON_TABLE()
  ↓
Rows and columns

26. Why JSON_TABLE() Matters for Data Engineering

Suppose an API sends:

{
  "customer_id": 101,
  "items": [
    {
      "product_id": 10,
      "quantity": 2
    },
    {
      "product_id": 20,
      "quantity": 3
    }
  ]
}

A data pipeline may need:

customer_id | product_id | quantity
------------------------------------
101         | 10         | 2
101         | 20         | 3

JSON_TABLE() provides a bridge between semi-structured data and relational analytics.

27. JSON_TABLE() With Relational Tables

We can join extracted JSON rows with products:

SELECT
    o.order_id,
    p.product_name,
    item.quantity,
    item.price,
    item.quantity * item.price AS line_total
FROM orders AS o
JOIN JSON_TABLE(
    o.order_metadata,
    '$.items[*]'
    COLUMNS (
        product_id INT PATH '$.product_id',
        quantity INT PATH '$.quantity',
        price DECIMAL(10,2) PATH '$.price'
    )
) AS item ON TRUE
JOIN products AS p
    ON p.product_id = item.product_id;

This combines relational and semi-structured data in one query.

28. Calculate Order Value From JSON

SELECT
    o.order_id,
    SUM(item.quantity * item.price) AS calculated_order_value
FROM orders AS o
JOIN JSON_TABLE(
    o.order_metadata,
    '$.items[*]'
    COLUMNS (
        quantity INT PATH '$.quantity',
        price DECIMAL(10,2) PATH '$.price'
    )
) AS item ON TRUE
GROUP BY o.order_id;

This is a practical JSON analytics pattern.

29. JSON Analytics

JSON values can be grouped and aggregated.

Device analytics

SELECT
    event_metadata->>'$.device.type' AS device_type,
    COUNT(*) AS event_count
FROM customer_events
GROUP BY event_metadata->>'$.device.type'
ORDER BY event_count DESC;

Payment analytics

SELECT
    order_metadata->>'$.payment.method' AS payment_method,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_metadata->>'$.payment.method';

Campaign analytics

SELECT
    event_metadata->>'$.campaign' AS campaign,
    COUNT(*) AS event_count
FROM customer_events
WHERE event_metadata->>'$.campaign' IS NOT NULL
GROUP BY event_metadata->>'$.campaign';

30. JSON + Relational Data

A useful hybrid query is:

SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    e.event_type,
    e.event_metadata->>'$.device.type' AS device_type,
    e.event_metadata->>'$.location.city' AS event_city
FROM customers AS c
JOIN customer_events AS e
    ON e.customer_id = c.customer_id;

Here we use normal relational columns and JSON attributes together.

31. Generated Columns for JSON

If a JSON attribute is queried frequently, it can be exposed through a generated column:

ALTER TABLE customer_events
ADD COLUMN device_type VARCHAR(30)
GENERATED ALWAYS AS (
    event_metadata->>'$.device.type'
) STORED;

Now we can query:

SELECT
    event_id,
    customer_id,
    event_type,
    device_type
FROM customer_events
WHERE device_type = 'mobile';

32. Index a JSON-Derived Value

The generated column can be indexed:

CREATE INDEX idx_customer_events_device_type
ON customer_events(device_type);

Then inspect it:

EXPLAIN
SELECT
    event_id,
    customer_id,
    event_type
FROM customer_events
WHERE device_type = 'mobile';

This is useful when a JSON attribute becomes a frequent filter.

33. JSON_VALID()

Check whether text is valid JSON:

SELECT JSON_VALID(
    '{"name":"Arjun","city":"Hyderabad"}'
);

Invalid example:

SELECT JSON_VALID(
    '{invalid json}'
);

This is useful when validating incoming data.

34. JSON_TYPE()

Check the JSON value type:

SELECT JSON_TYPE('{"name":"Arjun"}');

and:

SELECT JSON_TYPE('[1,2,3]');

Common JSON types include:

OBJECT
ARRAY
STRING
INTEGER
DOUBLE
BOOLEAN
NULL

35. JSON_DEPTH()

JSON_DEPTH() reports the nesting depth of a JSON document.

SELECT JSON_DEPTH(
    '{"device":{"type":"mobile","os":"Android"}}'
);

It can help when exploring deeply nested documents.

36. Common Mistakes

Mistake 1 — Treating JSON as plain text

Use MySQL JSON functions instead of manually manipulating JSON strings.

Mistake 2 — Confusing -> and ->>

Remember:

->   JSON value
->>  scalar value as an unquoted SQL value

Mistake 3 — Putting everything into JSON

Core business attributes are often better as relational columns.

Mistake 4 — Ignoring JSON paths

These are different:

$.device
$.device.type
$.device.os

Mistake 5 — Ignoring missing paths

Not every event type necessarily contains the same metadata.

Mistake 6 — Ignoring indexing

Frequently filtered JSON attributes may need an appropriate indexing strategy.

Mistake 7 — Forgetting JSON_TABLE()

For arrays of objects, JSON_TABLE() is often the cleanest way to produce relational rows.

37. Practice Queries

Practice 1 — Desktop Events

SELECT
    event_id,
    customer_id,
    event_type,
    event_metadata->>'$.device.os' AS operating_system
FROM customer_events
WHERE device_type = 'desktop';

Practice 2 — UPI Orders

SELECT
    order_id,
    customer_id,
    order_metadata->>'$.payment.provider' AS payment_provider
FROM orders
WHERE order_metadata->>'$.payment.method' = 'UPI';

Practice 3 — Orders With Multiple Items

SELECT
    order_id,
    JSON_LENGTH(order_metadata->'$.items') AS item_count
FROM orders
WHERE JSON_LENGTH(order_metadata->'$.items') > 1;

Practice 4 — Extract Order Items

SELECT
    o.order_id,
    item.product_id,
    item.quantity,
    item.price
FROM orders AS o
JOIN JSON_TABLE(
    o.order_metadata,
    '$.items[*]'
    COLUMNS (
        product_id INT PATH '$.product_id',
        quantity INT PATH '$.quantity',
        price DECIMAL(10,2) PATH '$.price'
    )
) AS item ON TRUE;

Practice 5 — Total Quantity Sold

SELECT
    item.product_id,
    p.product_name,
    SUM(item.quantity) AS total_quantity_sold
FROM orders AS o
JOIN JSON_TABLE(
    o.order_metadata,
    '$.items[*]'
    COLUMNS (
        product_id INT PATH '$.product_id',
        quantity INT PATH '$.quantity'
    )
) AS item ON TRUE
JOIN products AS p
    ON p.product_id = item.product_id
WHERE o.order_status = 'DELIVERED'
GROUP BY item.product_id, p.product_name
ORDER BY total_quantity_sold DESC;

Practice 6 — Customers Who Used Coupons

SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    o.order_metadata->>'$.coupon' AS coupon
FROM customers AS c
JOIN orders AS o
    ON o.customer_id = c.customer_id
WHERE o.order_metadata->>'$.coupon' IS NOT NULL;

38. What You Should Understand After Day 77

By the end of this day, you should understand:

JSON Basics

JSON objects

JSON arrays

Nested JSON

JSON paths

MySQL JSON data type

JSON Extraction

JSON_EXTRACT()

->

->>

JSON_VALUE()

JSON Searching

JSON_CONTAINS()

JSON_CONTAINS_PATH()

JSON_KEYS()

JSON_LENGTH()

JSON Modification

JSON_SET()

JSON_INSERT()

JSON_REPLACE()

JSON_REMOVE()

JSON Analytics

Filtering JSON

Grouping JSON values

Aggregating JSON attributes

Processing JSON arrays

JSON_TABLE()

Performance

Generated columns

Indexing JSON-derived values

EXPLAIN for JSON-related queries

39. Interview Questions

1. What is JSON?

JSON is a lightweight semi-structured data format based on objects, arrays, and key-value pairs.

2. Why does MySQL support JSON?

It allows relational databases to store and query semi-structured data while still using SQL.

3. What is a JSON path?

A JSON path identifies a location inside a JSON document, such as:

$.device.type

4. What is the difference between -> and ->>?

-> extracts a JSON value, while ->> extracts a JSON scalar as an unquoted SQL value.

5. What is JSON_TABLE()?

JSON_TABLE() converts JSON data into a relational table-like result.

6. Why is JSON_TABLE() useful in data engineering?

It transforms semi-structured JSON into rows and columns suitable for SQL analytics and downstream processing.

7. What is JSON_SET()?

It adds or replaces values at specified JSON paths.

8. What is JSON_INSERT()?

It inserts values when specified paths do not already exist.

9. What is JSON_REMOVE()?

It removes values from specified JSON paths.

10. Should every column be stored as JSON?

No. Important, stable, frequently queried business attributes are often better represented as normal relational columns.

11. How can a JSON attribute be indexed?

One practical approach is to expose the frequently queried JSON value through a generated column and index that column.

12. Why is JSON useful for event data?

Different event types can have different metadata, making JSON useful for flexible event-specific attributes.

40. Data Engineering Connection

JSON appears constantly in data engineering:

API
 ↓
JSON
 ↓
Kafka / Event Stream
 ↓
Data Processing
 ↓
Database / Data Warehouse

A pipeline might receive:

{
  "customer_id": 101,
  "event": "purchase",
  "device": {
    "type": "mobile"
  },
  "items": [
    {
      "product_id": 10,
      "quantity": 2
    }
  ]
}

A data engineer may need to transform it into:

customer_id | event    | device_type | product_id | quantity
-------------------------------------------------------------
101         | purchase | mobile      | 10         | 2

That is exactly the type of transformation demonstrated by JSON_TABLE().

41. Project Structure

Day-77-SQL-JSON-Data/
│
├── day77.sql
└── README.md

42. How to Run

Step 1 — Open MySQL

Use MySQL Workbench, MySQL CLI, VS Code SQLTools, or another MySQL 8+ client.

Step 2 — Open

day77.sql

Step 3 — Execute

The script creates:

sql_json_lab

and inserts sample customers, products, events, and orders.

Step 4 — Study

Pay special attention to:

JSON_EXTRACT()

->

->>

and especially:

JSON_TABLE()

Step 5 — Practice

Modify the JSON queries and create your own analytics.

43. Git Commands

git add .

git commit -m "Day 77 - SQL JSON Data"

git push

44. Final Takeaway

The progression of Day 77 is:

JSON Document
      ↓
JSON Path
      ↓
Extract JSON Values
      ↓
Filter JSON
      ↓
Modify JSON
      ↓
Analyze JSON
      ↓
JSON_TABLE()
      ↓
Relational Rows
      ↓
SQL Analytics

The most important concepts are:

JSON_EXTRACT()

->

->>

and especially:

JSON_TABLE()

JSON_TABLE() is particularly valuable because it bridges semi-structured JSON data and relational SQL analytics.

Day 77 Complete 🚀

SQL-A-Day

Day 77
    ↓
JSON Data
    ↓
JSON Functions
    ↓
Nested JSON
    ↓
JSON Filtering
    ↓
JSON Modification
    ↓
JSON_TABLE()
    ↓
JSON Analytics

Next step: Day 78 — a new SQL topic.