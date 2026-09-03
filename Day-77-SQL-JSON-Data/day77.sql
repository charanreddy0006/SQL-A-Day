-- DAY 77 - SQL JSON DATA & JSON QUERYING
-- MySQL 8+

DROP DATABASE IF EXISTS sql_json_lab;
CREATE DATABASE sql_json_lab;
USE sql_json_lab;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    city VARCHAR(80) NOT NULL,
    customer_status ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(120) NOT NULL,
    category VARCHAR(80) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE customer_events (
    event_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_time DATETIME NOT NULL,
    event_metadata JSON NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    order_status ENUM('PENDING','SHIPPED','DELIVERED','CANCELLED') NOT NULL,
    order_metadata JSON NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1,'Arjun Reddy','arjun@example.com','Hyderabad','ACTIVE'),
(2,'Priya Sharma','priya@example.com','Bengaluru','ACTIVE'),
(3,'Ravi Kumar','ravi@example.com','Chennai','ACTIVE'),
(4,'Sneha Patel','sneha@example.com','Mumbai','ACTIVE'),
(5,'Kiran Rao','kiran@example.com','Pune','INACTIVE'),
(6,'Ananya Singh','ananya@example.com','Delhi','ACTIVE'),
(7,'Vikram Das','vikram@example.com','Kolkata','ACTIVE'),
(8,'Meera Nair','meera@example.com','Vizag','SUSPENDED');

INSERT INTO products VALUES
(1,'Laptop Pro','Electronics',1299.00),
(2,'Wireless Mouse','Electronics',49.00),
(3,'Mechanical Keyboard','Electronics',119.00),
(4,'Office Chair','Furniture',349.00),
(5,'Standing Desk','Furniture',599.00),
(6,'USB-C Hub','Accessories',79.00);

INSERT INTO customer_events VALUES
(1,1,'LOGIN','2026-09-01 09:10:00',JSON_OBJECT('device',JSON_OBJECT('type','mobile','os','Android','version','14'),'location',JSON_OBJECT('city','Hyderabad','country','India'),'browser','Chrome','ip','10.10.1.15')),
(2,1,'PRODUCT_VIEW','2026-09-01 09:15:00',JSON_OBJECT('product_id',1,'source','homepage','device',JSON_OBJECT('type','mobile','os','Android'),'campaign','summer_sale')),
(3,1,'ADD_TO_CART','2026-09-01 09:20:00',JSON_OBJECT('product_id',1,'quantity',1,'source','recommendation','coupon','SUMMER10')),
(4,2,'LOGIN','2026-09-01 10:00:00',JSON_OBJECT('device',JSON_OBJECT('type','desktop','os','Windows'),'location',JSON_OBJECT('city','Bengaluru','country','India'),'browser','Edge')),
(5,2,'PRODUCT_VIEW','2026-09-01 10:12:00',JSON_OBJECT('product_id',3,'source','search','search_term','keyboard','device',JSON_OBJECT('type','desktop','os','Windows'))),
(6,3,'LOGIN','2026-09-01 11:30:00',JSON_OBJECT('device',JSON_OBJECT('type','mobile','os','iOS'),'location',JSON_OBJECT('city','Chennai','country','India'),'browser','Safari')),
(7,3,'PURCHASE','2026-09-01 11:45:00',JSON_OBJECT('payment',JSON_OBJECT('method','UPI','provider','PhonePe'),'coupon','WELCOME20','items',JSON_ARRAY(JSON_OBJECT('product_id',2,'quantity',2,'price',49),JSON_OBJECT('product_id',3,'quantity',1,'price',119)))),
(8,4,'LOGIN','2026-09-01 12:00:00',JSON_OBJECT('device',JSON_OBJECT('type','tablet','os','Android'),'location',JSON_OBJECT('city','Mumbai','country','India'),'browser','Chrome')),
(9,5,'PRODUCT_VIEW','2026-09-01 13:15:00',JSON_OBJECT('product_id',4,'source','recommendation','device',JSON_OBJECT('type','mobile','os','Android'),'campaign','office_upgrade')),
(10,6,'PURCHASE','2026-09-01 14:10:00',JSON_OBJECT('payment',JSON_OBJECT('method','CARD','provider','Visa'),'coupon','NEWUSER','items',JSON_ARRAY(JSON_OBJECT('product_id',4,'quantity',1,'price',349)))),
(11,7,'LOGIN','2026-09-01 15:00:00',JSON_OBJECT('device',JSON_OBJECT('type','desktop','os','Linux'),'location',JSON_OBJECT('city','Kolkata','country','India'),'browser','Firefox')),
(12,8,'PRODUCT_VIEW','2026-09-01 16:30:00',JSON_OBJECT('product_id',5,'source','homepage','device',JSON_OBJECT('type','mobile','os','Android')));

INSERT INTO orders VALUES
(101,1,'2026-09-01 09:30:00','DELIVERED',JSON_OBJECT('payment',JSON_OBJECT('method','UPI','provider','GooglePay'),'shipping',JSON_OBJECT('method','EXPRESS','city','Hyderabad'),'coupon','SUMMER10','items',JSON_ARRAY(JSON_OBJECT('product_id',1,'quantity',1,'price',1299),JSON_OBJECT('product_id',2,'quantity',1,'price',49)))),
(102,2,'2026-09-01 10:30:00','SHIPPED',JSON_OBJECT('payment',JSON_OBJECT('method','CARD','provider','Visa'),'shipping',JSON_OBJECT('method','STANDARD','city','Bengaluru'),'coupon',NULL,'items',JSON_ARRAY(JSON_OBJECT('product_id',3,'quantity',1,'price',119)))),
(103,3,'2026-09-01 11:50:00','DELIVERED',JSON_OBJECT('payment',JSON_OBJECT('method','UPI','provider','PhonePe'),'shipping',JSON_OBJECT('method','STANDARD','city','Chennai'),'coupon','WELCOME20','items',JSON_ARRAY(JSON_OBJECT('product_id',2,'quantity',2,'price',49),JSON_OBJECT('product_id',3,'quantity',1,'price',119)))),
(104,4,'2026-09-01 12:20:00','CANCELLED',JSON_OBJECT('payment',JSON_OBJECT('method','CARD','provider','Mastercard'),'shipping',JSON_OBJECT('method','STANDARD','city','Mumbai'),'cancellation_reason','CUSTOMER_REQUEST','items',JSON_ARRAY(JSON_OBJECT('product_id',4,'quantity',1,'price',349)))),
(105,6,'2026-09-01 14:20:00','DELIVERED',JSON_OBJECT('payment',JSON_OBJECT('method','CARD','provider','Visa'),'shipping',JSON_OBJECT('method','EXPRESS','city','Delhi'),'coupon','NEWUSER','items',JSON_ARRAY(JSON_OBJECT('product_id',4,'quantity',1,'price',349))));

-- Basic inspection
SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS products FROM products;
SELECT COUNT(*) AS events FROM customer_events;
SELECT COUNT(*) AS orders FROM orders;
SELECT event_id,event_type,event_metadata FROM customer_events;

-- JSON creation
SELECT JSON_OBJECT('name','Charan','role','Data Engineer','skills',JSON_ARRAY('SQL','Python','Spark')) AS generated_json;
SELECT JSON_ARRAY('SQL','Python','Spark','Flink') AS skills;

-- Extraction
SELECT event_id,JSON_EXTRACT(event_metadata,'$.device.type') AS device_type FROM customer_events;
SELECT event_id,event_metadata->'$.device.type' AS device_type FROM customer_events;
SELECT event_id,event_metadata->>'$.device.type' AS device_type FROM customer_events;
SELECT event_id,JSON_VALUE(event_metadata,'$.device.type') AS device_type FROM customer_events;
SELECT event_id,event_metadata->>'$.location.city' AS city,event_metadata->>'$.location.country' AS country,event_metadata->>'$.browser' AS browser FROM customer_events;

-- Filtering/searching JSON
SELECT event_id,customer_id,event_type FROM customer_events WHERE event_metadata->>'$.device.type'='mobile';
SELECT event_id,customer_id,event_type FROM customer_events WHERE event_metadata->>'$.location.city'='Hyderabad';
SELECT event_id,JSON_CONTAINS_PATH(event_metadata,'one','$.device') AS has_device FROM customer_events;
SELECT event_id,JSON_CONTAINS_PATH(event_metadata,'all','$.device','$.location') AS has_both FROM customer_events;
SELECT event_id,event_type FROM customer_events WHERE JSON_CONTAINS(event_metadata,'"summer_sale"','$.campaign');
SELECT event_id,JSON_LENGTH(event_metadata->'$.items') AS item_count FROM customer_events WHERE event_type='PURCHASE';
SELECT event_id,JSON_KEYS(event_metadata) AS top_level_keys FROM customer_events;

-- JSON modification
SELECT JSON_SET('{"name":"Arjun","city":"Hyderabad"}','$.membership','GOLD') AS updated_json;
UPDATE customer_events SET event_metadata=JSON_SET(event_metadata,'$.source','web_app') WHERE event_id=1;
UPDATE customer_events SET event_metadata=JSON_INSERT(event_metadata,'$.session_id','SESSION-1001') WHERE event_id=1;
UPDATE customer_events SET event_metadata=JSON_REPLACE(event_metadata,'$.browser','Chrome Mobile') WHERE event_id=1;
UPDATE customer_events SET event_metadata=JSON_REMOVE(event_metadata,'$.ip') WHERE event_id=1;
SELECT event_id,event_metadata FROM customer_events WHERE event_id=1;

-- Order JSON
SELECT order_id,order_metadata->>'$.payment.method' AS payment_method,order_metadata->>'$.payment.provider' AS provider FROM orders;
SELECT order_id,order_metadata->>'$.shipping.method' AS shipping_method,order_metadata->>'$.shipping.city' AS shipping_city FROM orders;
SELECT order_id,customer_id FROM orders WHERE order_metadata->>'$.payment.method'='UPI';
SELECT order_id,order_metadata->>'$.coupon' AS coupon FROM orders WHERE order_metadata->>'$.coupon' IS NOT NULL;

-- JSON_TABLE: convert arrays to relational rows
SELECT o.order_id,item.product_id,item.quantity,item.price
FROM orders o
JOIN JSON_TABLE(o.order_metadata,'$.items[*]' COLUMNS(
    product_id INT PATH '$.product_id',
    quantity INT PATH '$.quantity',
    price DECIMAL(10,2) PATH '$.price'
)) item;

SELECT o.order_id,p.product_name,p.category,item.quantity,item.price,item.quantity*item.price AS line_total
FROM orders o
JOIN JSON_TABLE(o.order_metadata,'$.items[*]' COLUMNS(
    product_id INT PATH '$.product_id',
    quantity INT PATH '$.quantity',
    price DECIMAL(10,2) PATH '$.price'
)) item ON TRUE
JOIN products p ON p.product_id=item.product_id;

SELECT o.order_id,SUM(item.quantity*item.price) AS calculated_order_value
FROM orders o
JOIN JSON_TABLE(o.order_metadata,'$.items[*]' COLUMNS(
    quantity INT PATH '$.quantity',
    price DECIMAL(10,2) PATH '$.price'
)) item ON TRUE
GROUP BY o.order_id;

-- JSON analytics
SELECT event_metadata->>'$.device.type' AS device_type,COUNT(*) AS event_count
FROM customer_events GROUP BY event_metadata->>'$.device.type' ORDER BY event_count DESC;

SELECT event_metadata->>'$.location.city' AS city,COUNT(*) AS event_count
FROM customer_events
WHERE JSON_CONTAINS_PATH(event_metadata,'one','$.location.city')
GROUP BY event_metadata->>'$.location.city' ORDER BY event_count DESC;

SELECT event_metadata->>'$.campaign' AS campaign,COUNT(*) AS event_count
FROM customer_events WHERE event_metadata->>'$.campaign' IS NOT NULL
GROUP BY event_metadata->>'$.campaign';

SELECT order_metadata->>'$.payment.method' AS payment_method,COUNT(*) AS order_count
FROM orders GROUP BY order_metadata->>'$.payment.method' ORDER BY order_count DESC;

SELECT order_metadata->>'$.shipping.method' AS shipping_method,COUNT(*) AS order_count
FROM orders GROUP BY order_metadata->>'$.shipping.method';

SELECT o.customer_id,item.product_id,SUM(item.quantity) AS total_quantity
FROM orders o
JOIN JSON_TABLE(o.order_metadata,'$.items[*]' COLUMNS(
    product_id INT PATH '$.product_id',
    quantity INT PATH '$.quantity'
)) item ON TRUE
WHERE o.order_status='DELIVERED'
GROUP BY o.customer_id,item.product_id
ORDER BY o.customer_id,total_quantity DESC;

-- Relational + JSON
SELECT c.customer_id,c.customer_name,c.city,e.event_type,
       e.event_metadata->>'$.device.type' AS device_type,
       e.event_metadata->>'$.location.city' AS event_city
FROM customers c JOIN customer_events e ON e.customer_id=c.customer_id
ORDER BY c.customer_id,e.event_time;

-- Generated column + index for a frequently queried JSON attribute
ALTER TABLE customer_events ADD COLUMN device_type VARCHAR(30)
GENERATED ALWAYS AS (event_metadata->>'$.device.type') STORED;
CREATE INDEX idx_customer_events_device_type ON customer_events(device_type);
SELECT event_id,customer_id,event_type,device_type FROM customer_events WHERE device_type='mobile';
EXPLAIN SELECT event_id,customer_id,event_type FROM customer_events WHERE device_type='mobile';

-- JSON metadata inspection
SELECT JSON_VALID('{"name":"Arjun","city":"Hyderabad"}') AS valid_json;
SELECT JSON_VALID('{invalid json}') AS invalid_json;
SELECT JSON_TYPE('{"name":"Arjun"}') AS object_type;
SELECT JSON_TYPE('[1,2,3]') AS array_type;
SELECT JSON_DEPTH('{"device":{"type":"mobile","os":"Android"}}') AS json_depth;
SELECT JSON_LENGTH('{"name":"Arjun","city":"Hyderabad","age":22}') AS object_member_count;

-- Practice 1
SELECT event_id,customer_id,event_type,event_metadata->>'$.device.os' AS operating_system
FROM customer_events WHERE device_type='desktop';

-- Practice 2
SELECT order_id,customer_id,order_metadata->>'$.payment.provider' AS payment_provider
FROM orders WHERE order_metadata->>'$.payment.method'='UPI';

-- Practice 3
SELECT order_id,JSON_LENGTH(order_metadata->'$.items') AS item_count
FROM orders WHERE JSON_LENGTH(order_metadata->'$.items')>1;

-- Practice 4
SELECT o.order_id,item.product_id,item.quantity,item.price
FROM orders o
JOIN JSON_TABLE(o.order_metadata,'$.items[*]' COLUMNS(
    product_id INT PATH '$.product_id',
    quantity INT PATH '$.quantity',
    price DECIMAL(10,2) PATH '$.price'
)) item ON TRUE;

-- Practice 5
SELECT item.product_id,p.product_name,SUM(item.quantity) AS total_quantity_sold
FROM orders o
JOIN JSON_TABLE(o.order_metadata,'$.items[*]' COLUMNS(
    product_id INT PATH '$.product_id',quantity INT PATH '$.quantity'
)) item ON TRUE
JOIN products p ON p.product_id=item.product_id
WHERE o.order_status='DELIVERED'
GROUP BY item.product_id,p.product_name
ORDER BY total_quantity_sold DESC;

-- Practice 6
SELECT DISTINCT c.customer_id,c.customer_name,o.order_metadata->>'$.coupon' AS coupon
FROM customers c JOIN orders o ON o.customer_id=c.customer_id
WHERE o.order_metadata->>'$.coupon' IS NOT NULL;

-- Final inspection
SELECT event_id,customer_id,event_type,event_metadata,device_type
FROM customer_events ORDER BY event_id;

-- END OF DAY 77
