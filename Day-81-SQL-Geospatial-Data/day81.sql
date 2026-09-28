-- ============================================================
-- Day 81 - SQL Geospatial Data & Spatial Queries
-- MySQL 8.x
-- ============================================================

DROP DATABASE IF EXISTS sql_geospatial_lab;
CREATE DATABASE sql_geospatial_lab;
USE sql_geospatial_lab;

-- 1. Geographic locations
CREATE TABLE cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    location POINT NOT NULL SRID 4326,
    SPATIAL INDEX idx_city_location (location)
);

INSERT INTO cities (city_name, country, location) VALUES
('Hyderabad', 'India', ST_GeomFromText('POINT(78.4867 17.3850)', 4326)),
('Bengaluru', 'India', ST_GeomFromText('POINT(77.5946 12.9716)', 4326)),
('Mumbai', 'India', ST_GeomFromText('POINT(72.8777 19.0760)', 4326)),
('Delhi', 'India', ST_GeomFromText('POINT(77.1025 28.7041)', 4326)),
('Chennai', 'India', ST_GeomFromText('POINT(80.2707 13.0827)', 4326)),
('Pune', 'India', ST_GeomFromText('POINT(73.8567 18.5204)', 4326));

SELECT city_id, city_name, country, ST_AsText(location) AS coordinates
FROM cities;

-- 2. Extract latitude and longitude
SELECT
    city_name,
    ST_Longitude(location) AS longitude,
    ST_Latitude(location) AS latitude
FROM cities;

-- 3. Distance between two cities
SELECT
    c1.city_name AS city_1,
    c2.city_name AS city_2,
    ROUND(ST_Distance_Sphere(c1.location, c2.location) / 1000, 2) AS distance_km
FROM cities c1
JOIN cities c2
    ON c1.city_name = 'Hyderabad'
   AND c2.city_name = 'Bengaluru';

-- 4. Distance from Hyderabad to every city
SELECT
    city_name,
    ROUND(
        ST_Distance_Sphere(
            (SELECT location FROM cities WHERE city_name = 'Hyderabad'),
            location
        ) / 1000, 2
    ) AS distance_from_hyderabad_km
FROM cities
WHERE city_name <> 'Hyderabad'
ORDER BY distance_from_hyderabad_km;

-- 5. Cities within 700 km of Hyderabad
SELECT
    city_name,
    ROUND(
        ST_Distance_Sphere(
            (SELECT location FROM cities WHERE city_name = 'Hyderabad'),
            location
        ) / 1000, 2
    ) AS distance_km
FROM cities
WHERE city_name <> 'Hyderabad'
  AND ST_Distance_Sphere(
        (SELECT location FROM cities WHERE city_name = 'Hyderabad'),
        location
      ) <= 700000
ORDER BY distance_km;

-- 6. Nearest city to Hyderabad
SELECT
    city_name,
    ROUND(
        ST_Distance_Sphere(
            (SELECT location FROM cities WHERE city_name = 'Hyderabad'),
            location
        ) / 1000, 2
    ) AS distance_km
FROM cities
WHERE city_name <> 'Hyderabad'
ORDER BY distance_km
LIMIT 1;

-- 7. Delivery locations
CREATE TABLE delivery_points (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    address VARCHAR(255),
    location POINT NOT NULL SRID 4326,
    SPATIAL INDEX idx_delivery_location (location)
);

INSERT INTO delivery_points (customer_name, address, location) VALUES
('Rahul', 'Banjara Hills', ST_GeomFromText('POINT(78.4483 17.4156)', 4326)),
('Ananya', 'Madhapur', ST_GeomFromText('POINT(78.3915 17.4483)', 4326)),
('Vikram', 'Secunderabad', ST_GeomFromText('POINT(78.5018 17.4399)', 4326)),
('Meera', 'Gachibowli', ST_GeomFromText('POINT(78.3489 17.4401)', 4326)),
('Arjun', 'Kukatpally', ST_GeomFromText('POINT(78.4139 17.4849)', 4326));

-- 8. Delivery points within 5 km of a reference point
SET @reference_point =
    ST_GeomFromText('POINT(78.4867 17.3850)', 4326);

SELECT
    customer_name,
    address,
    ROUND(ST_Distance_Sphere(@reference_point, location) / 1000, 2) AS distance_km
FROM delivery_points
WHERE ST_Distance_Sphere(@reference_point, location) <= 5000
ORDER BY distance_km;

-- 9. Local delivery zones
-- SRID 0 is used for this simple planar teaching example.
CREATE TABLE delivery_zones (
    zone_id INT PRIMARY KEY AUTO_INCREMENT,
    zone_name VARCHAR(100) NOT NULL,
    boundary POLYGON NOT NULL SRID 0,
    SPATIAL INDEX idx_zone_boundary (boundary)
);

INSERT INTO delivery_zones (zone_name, boundary) VALUES
('Central Zone',
 ST_GeomFromText('POLYGON((78.43 17.36,78.55 17.36,78.55 17.46,78.43 17.46,78.43 17.36))', 0)),
('West Zone',
 ST_GeomFromText('POLYGON((78.30 17.39,78.43 17.39,78.43 17.50,78.30 17.50,78.30 17.39))', 0));

SELECT zone_id, zone_name, ST_AsText(boundary) AS boundary
FROM delivery_zones;

-- 10. Point-in-polygon
SELECT
    d.customer_name,
    d.address,
    z.zone_name
FROM delivery_points d
JOIN delivery_zones z
    ON ST_Within(ST_Transform(d.location, 0), z.boundary);

-- 11. Check whether a zone contains a specific point
SET @local_point = ST_GeomFromText('POINT(78.48 17.41)', 0);

SELECT zone_name
FROM delivery_zones
WHERE ST_Contains(boundary, @local_point);

-- 12. Spatial intersection
SELECT
    d.customer_name,
    d.address,
    z.zone_name
FROM delivery_points d
JOIN delivery_zones z
    ON ST_Intersects(ST_Transform(d.location, 0), z.boundary);

-- 13. Coordinate bounding-box filter
SET @min_lon = 78.35;
SET @max_lon = 78.55;
SET @min_lat = 17.35;
SET @max_lat = 17.50;

SELECT
    customer_name,
    address,
    ST_Longitude(location) AS longitude,
    ST_Latitude(location) AS latitude
FROM delivery_points
WHERE ST_Longitude(location) BETWEEN @min_lon AND @max_lon
  AND ST_Latitude(location) BETWEEN @min_lat AND @max_lat;

-- 14. Pairwise city distances
SELECT
    c1.city_name AS city_1,
    c2.city_name AS city_2,
    ROUND(ST_Distance_Sphere(c1.location, c2.location) / 1000, 2) AS distance_km
FROM cities c1
JOIN cities c2 ON c1.city_id < c2.city_id
ORDER BY distance_km;

-- 15. Farthest city from Hyderabad
SELECT
    city_name,
    ROUND(
        ST_Distance_Sphere(
            (SELECT location FROM cities WHERE city_name = 'Hyderabad'),
            location
        ) / 1000, 2
    ) AS distance_km
FROM cities
WHERE city_name <> 'Hyderabad'
ORDER BY distance_km DESC
LIMIT 1;

-- 16. Nearest delivery customer to Hyderabad
SELECT
    d.customer_name,
    d.address,
    ROUND(
        ST_Distance_Sphere(
            (SELECT location FROM cities WHERE city_name = 'Hyderabad'),
            d.location
        ) / 1000, 2
    ) AS distance_km
FROM delivery_points d
ORDER BY distance_km
LIMIT 1;

-- 17. Geographic summary
SELECT
    MIN(ST_Latitude(location)) AS min_latitude,
    MAX(ST_Latitude(location)) AS max_latitude,
    MIN(ST_Longitude(location)) AS min_longitude,
    MAX(ST_Longitude(location)) AS max_longitude
FROM cities;

-- 18. Practice
-- 1. Find all cities within 1000 km of Mumbai.
-- 2. Find the nearest city to Chennai.
-- 3. Find all delivery customers within 3 km of Hyderabad.
-- 4. Find which delivery zone contains POINT(78.40, 17.45).
-- 5. Display every city pair and its distance in km.
-- 6. Find the farthest delivery point from Hyderabad.
-- 7. Order delivery points by distance from Bengaluru.
-- 8. Filter delivery points by a longitude/latitude bounding box.
-- 9. Count delivery points in each zone.
-- 10. Create another polygon and identify points inside it.

-- ============================================================
-- End of Day 81
-- ============================================================
