-- Day 74: SQL Spatial & Geospatial Data
-- MySQL 8+
DROP DATABASE IF EXISTS spatial_delivery_lab;
CREATE DATABASE spatial_delivery_lab;
USE spatial_delivery_lab;

CREATE TABLE delivery_centers (
    center_id INT PRIMARY KEY AUTO_INCREMENT,
    center_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    location POINT SRID 4326 NOT NULL,
    SPATIAL INDEX idx_center_location (location)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    address VARCHAR(255) NOT NULL,
    location POINT SRID 4326 NOT NULL,
    INDEX idx_customer_city (city),
    SPATIAL INDEX idx_customer_location (location)
);

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY AUTO_INCREMENT,
    driver_name VARCHAR(100) NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    status ENUM('AVAILABLE','BUSY','OFFLINE') NOT NULL,
    current_location POINT SRID 4326 NOT NULL,
    SPATIAL INDEX idx_driver_location (current_location)
);

CREATE TABLE delivery_zones (
    zone_id INT PRIMARY KEY AUTO_INCREMENT,
    zone_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    boundary POLYGON SRID 4326 NOT NULL,
    SPATIAL INDEX idx_zone_boundary (boundary)
);

CREATE TABLE delivery_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    center_id INT NOT NULL,
    driver_id INT NULL,
    order_status ENUM('PLACED','ASSIGNED','OUT_FOR_DELIVERY','DELIVERED','CANCELLED') NOT NULL,
    delivery_location POINT SRID 4326 NOT NULL,
    order_date DATETIME NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (center_id) REFERENCES delivery_centers(center_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    SPATIAL INDEX idx_order_location (delivery_location),
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_center (center_id),
    INDEX idx_order_status (order_status)
);

INSERT INTO delivery_centers (center_name, city, location) VALUES
('Central Hyderabad Hub','Hyderabad',ST_GeomFromText('POINT(78.4867 17.3850)',4326)),
('Hitech City Hub','Hyderabad',ST_GeomFromText('POINT(78.3772 17.4435)',4326)),
('Secunderabad Hub','Hyderabad',ST_GeomFromText('POINT(78.4983 17.4399)',4326)),
('Gachibowli Hub','Hyderabad',ST_GeomFromText('POINT(78.3489 17.4401)',4326));

INSERT INTO customers (customer_name,city,address,location) VALUES
('Arjun Reddy','Hyderabad','Banjara Hills',ST_GeomFromText('POINT(78.4483 17.4126)',4326)),
('Priya Nair','Hyderabad','Madhapur',ST_GeomFromText('POINT(78.3915 17.4483)',4326)),
('Rahul Sharma','Hyderabad','Kukatpally',ST_GeomFromText('POINT(78.3996 17.4849)',4326)),
('Sneha Rao','Hyderabad','Gachibowli',ST_GeomFromText('POINT(78.3489 17.4401)',4326)),
('Vikram Kumar','Hyderabad','Secunderabad',ST_GeomFromText('POINT(78.4983 17.4399)',4326)),
('Ananya Singh','Hyderabad','Begumpet',ST_GeomFromText('POINT(78.4671 17.4436)',4326)),
('Kiran Patel','Hyderabad','Kondapur',ST_GeomFromText('POINT(78.3647 17.4580)',4326)),
('Meera Das','Hyderabad','Jubilee Hills',ST_GeomFromText('POINT(78.4071 17.4325)',4326)),
('Rohit Verma','Hyderabad','Mehdipatnam',ST_GeomFromText('POINT(78.4305 17.3968)',4326)),
('Divya Iyer','Hyderabad','Uppal',ST_GeomFromText('POINT(78.5591 17.4065)',4326));

INSERT INTO drivers (driver_name,vehicle_type,status,current_location) VALUES
('Driver A','Bike','AVAILABLE',ST_GeomFromText('POINT(78.3900 17.4450)',4326)),
('Driver B','Bike','BUSY',ST_GeomFromText('POINT(78.4500 17.4200)',4326)),
('Driver C','Van','AVAILABLE',ST_GeomFromText('POINT(78.5000 17.4400)',4326)),
('Driver D','Bike','AVAILABLE',ST_GeomFromText('POINT(78.3500 17.4380)',4326)),
('Driver E','Van','OFFLINE',ST_GeomFromText('POINT(78.5600 17.4100)',4326));

INSERT INTO delivery_zones (zone_name,city,boundary) VALUES
('Central Zone','Hyderabad',ST_GeomFromText('POLYGON((78.4200 17.3800,78.5200 17.3800,78.5200 17.4500,78.4200 17.4500,78.4200 17.3800))',4326)),
('West Zone','Hyderabad',ST_GeomFromText('POLYGON((78.3200 17.4100,78.4300 17.4100,78.4300 17.5000,78.3200 17.5000,78.3200 17.4100))',4326)),
('East Zone','Hyderabad',ST_GeomFromText('POLYGON((78.5100 17.3700,78.6000 17.3700,78.6000 17.4500,78.5100 17.4500,78.5100 17.3700))',4326));

INSERT INTO delivery_orders (customer_id,center_id,driver_id,order_status,delivery_location,order_date) VALUES
(1,1,2,'OUT_FOR_DELIVERY',ST_GeomFromText('POINT(78.4483 17.4126)',4326),'2026-08-01 10:15:00'),
(2,2,1,'ASSIGNED',ST_GeomFromText('POINT(78.3915 17.4483)',4326),'2026-08-01 11:30:00'),
(3,2,1,'DELIVERED',ST_GeomFromText('POINT(78.3996 17.4849)',4326),'2026-08-02 12:00:00'),
(4,4,4,'DELIVERED',ST_GeomFromText('POINT(78.3489 17.4401)',4326),'2026-08-02 13:20:00'),
(5,3,3,'OUT_FOR_DELIVERY',ST_GeomFromText('POINT(78.4983 17.4399)',4326),'2026-08-03 09:40:00'),
(6,3,3,'DELIVERED',ST_GeomFromText('POINT(78.4671 17.4436)',4326),'2026-08-03 15:10:00'),
(7,4,4,'ASSIGNED',ST_GeomFromText('POINT(78.3647 17.4580)',4326),'2026-08-04 10:45:00'),
(8,2,1,'DELIVERED',ST_GeomFromText('POINT(78.4071 17.4325)',4326),'2026-08-04 14:00:00'),
(9,1,2,'PLACED',ST_GeomFromText('POINT(78.4305 17.3968)',4326),'2026-08-05 16:30:00'),
(10,3,3,'PLACED',ST_GeomFromText('POINT(78.5591 17.4065)',4326),'2026-08-05 17:00:00');

-- Inspect spatial data
SELECT customer_id,customer_name,ST_AsText(location) AS location FROM customers;
SELECT customer_name,ST_X(location) AS longitude,ST_Y(location) AS latitude FROM customers;

-- Distance between a customer and center
SELECT c.customer_name,dc.center_name,
       ROUND(ST_Distance(c.location,dc.location),2) AS distance
FROM customers c CROSS JOIN delivery_centers dc
WHERE c.customer_id=1 AND dc.center_id=1;

-- Nearest center
SELECT dc.center_id,dc.center_name,
       ROUND(ST_Distance(c.location,dc.location),2) AS distance
FROM customers c CROSS JOIN delivery_centers dc
WHERE c.customer_id=1
ORDER BY distance LIMIT 1;

-- Customers within 5 km of Hitech City Hub
SELECT c.customer_id,c.customer_name,
       ROUND(ST_Distance(c.location,dc.location),2) AS distance
FROM customers c CROSS JOIN delivery_centers dc
WHERE dc.center_id=2
  AND ST_Distance(c.location,dc.location)<=5000
ORDER BY distance;

-- Nearest available driver to customer 2
SELECT d.driver_id,d.driver_name,d.vehicle_type,
       ROUND(ST_Distance(d.current_location,c.location),2) AS distance
FROM drivers d CROSS JOIN customers c
WHERE c.customer_id=2 AND d.status='AVAILABLE'
ORDER BY distance LIMIT 1;

-- Point in polygon: customer zones
SELECT c.customer_name,z.zone_name
FROM customers c
JOIN delivery_zones z ON ST_Contains(z.boundary,c.location)
ORDER BY c.customer_name;

-- Orders inside zones
SELECT z.zone_name,o.order_id,o.order_status
FROM delivery_zones z
JOIN delivery_orders o ON ST_Contains(z.boundary,o.delivery_location)
ORDER BY z.zone_name,o.order_id;

-- ST_Within
SELECT c.customer_name,z.zone_name
FROM customers c
JOIN delivery_zones z ON ST_Within(c.location,z.boundary)
ORDER BY c.customer_name;

-- Zone intersections
SELECT z1.zone_name AS zone_a,z2.zone_name AS zone_b,
       ST_Intersects(z1.boundary,z2.boundary) AS intersects
FROM delivery_zones z1
CROSS JOIN delivery_zones z2
WHERE z1.zone_id<z2.zone_id;

-- Bounding boxes
SELECT zone_name,ST_AsText(ST_Envelope(boundary)) AS bounding_box
FROM delivery_zones;

-- Zone for every order
SELECT o.order_id,o.order_status,
       COALESCE(z.zone_name,'Outside Defined Zones') AS delivery_zone
FROM delivery_orders o
LEFT JOIN delivery_zones z
  ON ST_Contains(z.boundary,o.delivery_location)
ORDER BY o.order_id;

-- Nearest center for every customer
SELECT c.customer_id,c.customer_name,
       (SELECT dc.center_name
        FROM delivery_centers dc
        ORDER BY ST_Distance(c.location,dc.location)
        LIMIT 1) AS nearest_center
FROM customers c
ORDER BY c.customer_id;

-- Available drivers within 5 km of order 9
SELECT o.order_id,d.driver_name,d.vehicle_type,
       ROUND(ST_Distance(o.delivery_location,d.current_location),2) AS distance
FROM delivery_orders o
CROSS JOIN drivers d
WHERE o.order_id=9
  AND d.status='AVAILABLE'
  AND ST_Distance(o.delivery_location,d.current_location)<=5000
ORDER BY distance;

-- Inspect spatial indexes
SELECT TABLE_NAME,INDEX_NAME,COLUMN_NAME,INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA=DATABASE()
  AND TABLE_NAME IN ('customers','delivery_centers','drivers','delivery_zones','delivery_orders')
ORDER BY TABLE_NAME,INDEX_NAME;

-- Final location intelligence report
SELECT o.order_id,c.customer_name,dc.center_name,
       COALESCE(z.zone_name,'Outside Defined Zones') AS delivery_zone,
       o.order_status,
       ROUND(ST_Distance(o.delivery_location,dc.location),2) AS center_distance
FROM delivery_orders o
JOIN customers c ON c.customer_id=o.customer_id
JOIN delivery_centers dc ON dc.center_id=o.center_id
LEFT JOIN delivery_zones z ON ST_Contains(z.boundary,o.delivery_location)
ORDER BY o.order_id;
