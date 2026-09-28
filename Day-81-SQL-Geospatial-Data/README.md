# Day 81 — SQL Geospatial Data & Spatial Queries

SQL is not limited to rows, columns, numbers, and text. Modern databases can also work with **geographic and geometric data** such as locations, distances, boundaries, and service areas.

Today we learn how MySQL can store and query spatial data using **GIS (Geographic Information System)** features.

---

## 🎯 Today's Goal

By the end of Day 81, you should understand:

- What spatial data is
- What `POINT` and `POLYGON` represent
- What SRID means
- How to store latitude/longitude in MySQL
- How to calculate distance between locations
- How to find nearby locations
- How to find nearest and farthest locations
- How point-in-polygon queries work
- How `ST_Within()`, `ST_Contains()` and `ST_Intersects()` work
- How spatial indexes are created
- How geospatial SQL is used in real applications

---

## 🗺️ What Is Geospatial Data?

**Geospatial data** represents information connected to a physical location.

Examples:

- GPS coordinates
- Cities
- Delivery locations
- Airports
- Roads
- Service areas
- District boundaries
- Delivery zones

A geographic point can be represented as:

```text
POINT(longitude latitude)
```

Example:

```text
POINT(78.4867 17.3850)
```

---

## 📌 GIS in SQL

GIS stands for:

> **Geographic Information System**

A spatial database allows SQL to work with location-based information.

Instead of storing latitude and longitude as unrelated numbers, we can store a spatial point:

```sql
POINT(78.4867 17.3850)
```

MySQL provides spatial data types and functions for working with this information.

---

## 🧱 Important Spatial Data Types

| Type | Purpose |
|---|---|
| `POINT` | A single location |
| `LINESTRING` | A line or path |
| `POLYGON` | A closed area/boundary |
| `MULTIPOINT` | Multiple points |
| `MULTILINESTRING` | Multiple lines |
| `MULTIPOLYGON` | Multiple polygons |
| `GEOMETRY` | General spatial type |

For today's project we mainly use:

- `POINT`
- `POLYGON`

---

## 📍 POINT

A `POINT` represents one location.

Example:

```sql
POINT(78.4867 17.3850)
```

For geographic coordinates, the usual order is:

```text
POINT(longitude latitude)
```

So:

```text
Longitude = 78.4867
Latitude  = 17.3850
```

---

## 🌍 SRID

SRID means:

> **Spatial Reference System Identifier**

It identifies the coordinate reference system associated with spatial data.

For GPS-style geographic coordinates, a commonly used reference system is:

```text
SRID 4326
```

This corresponds to **WGS 84**, widely used for latitude/longitude data.

Example:

```sql
ST_GeomFromText(
    'POINT(78.4867 17.3850)',
    4326
);
```

The coordinate reference system matters because the same numeric coordinates can represent different spatial systems.

---

## 🏗️ Creating a Spatial Column

Example:

```sql
CREATE TABLE cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(100),
    location POINT NOT NULL SRID 4326
);
```

---

## ➕ Inserting Spatial Data

```sql
INSERT INTO cities (city_name, location)
VALUES (
    'Hyderabad',
    ST_GeomFromText(
        'POINT(78.4867 17.3850)',
        4326
    )
);
```

---

## 👀 Displaying Spatial Data

Use:

```sql
SELECT
    city_name,
    ST_AsText(location)
FROM cities;
```

`ST_AsText()` converts a spatial value into readable WKT (Well-Known Text).

---

## 📐 Extracting Latitude and Longitude

```sql
SELECT
    city_name,
    ST_Longitude(location) AS longitude,
    ST_Latitude(location) AS latitude
FROM cities;
```

This is useful when an application needs the coordinates separately.

---

## 📏 Calculating Distance

One of the most useful geospatial operations is calculating the distance between two locations.

MySQL provides:

```sql
ST_Distance_Sphere()
```

Example:

```sql
SELECT
    ST_Distance_Sphere(
        city1.location,
        city2.location
    ) AS distance_meters
FROM cities city1
JOIN cities city2
    ON city1.city_name = 'Hyderabad'
   AND city2.city_name = 'Bengaluru';
```

The result is in **meters**.

To convert to kilometers:

```sql
ST_Distance_Sphere(...) / 1000
```

---

## 🚗 Real-World Example: Nearby Cities

Suppose an application wants to find cities within 700 km of Hyderabad.

```sql
SELECT
    city_name,
    ST_Distance_Sphere(
        (SELECT location
         FROM cities
         WHERE city_name = 'Hyderabad'),
        location
    ) / 1000 AS distance_km
FROM cities
WHERE city_name <> 'Hyderabad'
ORDER BY distance_km;
```

A distance limit can then be applied:

```sql
WHERE ST_Distance_Sphere(...) <= 700000
```

Because:

```text
700 km = 700,000 meters
```

---

## 📍 Nearest Location

A common location-based query is:

> Find the nearest store, customer, city, or driver.

Pattern:

```sql
SELECT
    city_name,
    ST_Distance_Sphere(
        reference_point,
        location
    ) AS distance
FROM cities
ORDER BY distance
LIMIT 1;
```

This pattern is useful for:

- Food delivery
- Cab applications
- Store locators
- Hospital finders
- Logistics
- Ride-sharing systems

---

## 🏪 Delivery Location Example

The project contains a `delivery_points` table.

Each customer has:

```text
customer_name
address
location
```

Now SQL can answer:

> Which customers are within 5 km of a restaurant?

Example:

```sql
SET @reference_point =
    ST_GeomFromText('POINT(78.4867 17.3850)', 4326);
```

Then:

```sql
SELECT
    customer_name,
    address,
    ST_Distance_Sphere(
        @reference_point,
        location
    ) / 1000 AS distance_km
FROM delivery_points
WHERE ST_Distance_Sphere(
        @reference_point,
        location
      ) <= 5000
ORDER BY distance_km;
```

---

# 🟦 POLYGON

A `POLYGON` represents an area.

It can represent:

- Delivery zones
- City boundaries
- Sales territories
- Campus areas
- Service regions
- Geofences

Example:

```sql
ST_GeomFromText(
    'POLYGON((
        78.43 17.36,
        78.55 17.36,
        78.55 17.46,
        78.43 17.46,
        78.43 17.36
    ))',
    0
)
```

The first and last coordinate close the polygon.

---

# 🎯 Point-in-Polygon Queries

A very useful spatial question is:

> Is this location inside this area?

MySQL provides:

```sql
ST_Within()
```

Example:

```sql
SELECT
    d.customer_name,
    z.zone_name
FROM delivery_points d
JOIN delivery_zones z
    ON ST_Within(
        ST_Transform(d.location, 0),
        z.boundary
    );
```

This can be used for:

- Delivery coverage
- Taxi zones
- Sales territories
- Campus boundaries
- Service areas

---

# 📦 ST_Contains()

`ST_Contains()` checks whether one geometry contains another.

Example:

```sql
SELECT zone_name
FROM delivery_zones
WHERE ST_Contains(
    boundary,
    @local_point
);
```

Conceptually:

```text
Polygon
┌──────────────────────┐
│                      │
│       ● Point        │
│                      │
└──────────────────────┘
```

The polygon contains the point.

---

# 🔗 ST_Intersects()

`ST_Intersects()` checks whether two geometries have a spatial intersection.

Example:

```sql
SELECT
    d.customer_name,
    z.zone_name
FROM delivery_points d
JOIN delivery_zones z
    ON ST_Intersects(
        ST_Transform(d.location, 0),
        z.boundary
    );
```

---

# 🧭 WKT

WKT means:

> **Well-Known Text**

It is a standard text representation of spatial objects.

Examples:

```text
POINT(78.4867 17.3850)
```

```text
LINESTRING(
    78.48 17.38,
    78.50 17.40
)
```

```text
POLYGON((
    78.43 17.36,
    78.55 17.36,
    78.55 17.46,
    78.43 17.46,
    78.43 17.36
))
```

---

# 📊 Important Spatial Functions

| Function | Purpose |
|---|---|
| `ST_GeomFromText()` | Create geometry from WKT |
| `ST_AsText()` | Convert geometry to WKT |
| `ST_Latitude()` | Get latitude |
| `ST_Longitude()` | Get longitude |
| `ST_Distance_Sphere()` | Calculate spherical distance |
| `ST_Within()` | Check whether geometry is within another |
| `ST_Contains()` | Check whether one geometry contains another |
| `ST_Intersects()` | Check whether geometries intersect |
| `ST_Transform()` | Transform geometry to another SRID |

---

# ⚡ Spatial Index

Spatial columns can use spatial indexes.

Example:

```sql
CREATE TABLE delivery_zones (
    zone_id INT PRIMARY KEY AUTO_INCREMENT,
    zone_name VARCHAR(100),
    boundary POLYGON NOT NULL SRID 0,
    SPATIAL INDEX idx_zone_boundary (boundary)
);
```

Spatial indexes are useful for large spatial datasets and geographic searches.

> Spatial indexing is different from the ordinary B-tree indexing covered in earlier days.

---

# 🧠 Geospatial Query Patterns

### 1. Nearest location

```sql
ORDER BY ST_Distance_Sphere(...)
LIMIT 1;
```

### 2. Nearby locations

```sql
WHERE ST_Distance_Sphere(...) <= radius
```

### 3. Inside a zone

```sql
ST_Within(point, polygon)
```

### 4. Polygon contains point

```sql
ST_Contains(polygon, point)
```

### 5. Spatial intersection

```sql
ST_Intersects(geometry1, geometry2)
```

---

# 🚚 Real-World Applications

## Food Delivery

```text
Customer
   ↓
GPS location
   ↓
Nearby restaurants
   ↓
Distance calculation
   ↓
Delivery availability
```

## Ride Sharing

```text
Passenger
   ↓
Location
   ↓
Nearby drivers
   ↓
Distance calculation
```

## Logistics

Geospatial SQL can help determine:

- Nearest warehouse
- Delivery areas
- Service coverage
- Distance between locations

## Retail

A store locator can answer:

> Which stores are closest to the customer?

## Geofencing

A geofence defines a geographic area and can be used to determine whether a device or delivery point is inside that boundary.

---

# ⚠️ Important Things to Remember

### 1. Longitude comes before latitude

Use:

```text
POINT(longitude latitude)
```

---

### 2. Distance units matter

`ST_Distance_Sphere()` returns distance in **meters**.

```text
meters / 1000 = kilometers
```

---

### 3. SRID matters

Spatial operations depend on the coordinate reference system.

For GPS-style geographic coordinates, `4326` is commonly used.

---

### 4. Geographic and planar calculations are different

Geographic coordinates represent positions on Earth, while planar coordinates treat space as a flat coordinate system.

Do not casually mix geometries with incompatible SRIDs.

---

### 5. Spatial data is more than latitude and longitude

GIS databases can represent:

```text
POINT
LINESTRING
POLYGON
MULTIPOINT
MULTIPOLYGON
```

---

# 🧪 Practice Questions

### Beginner

1. Display all cities with their latitude and longitude.
2. Display the coordinates of Mumbai.
3. Calculate the distance between Hyderabad and Chennai.
4. Find all cities within 1000 km of Mumbai.
5. Find the nearest city to Bengaluru.

### Intermediate

6. Find the farthest delivery point from Hyderabad.
7. Find all delivery points within 3 km of Hyderabad.
8. Order all delivery points by distance from Bengaluru.
9. Find the zone containing a given point.
10. Count delivery points in each zone.

### Advanced

11. Calculate the distance between every pair of cities.
12. Find the nearest delivery customer to every city.
13. Create a new delivery polygon and find all points inside it.
14. Find points that intersect a given service area.
15. Build a query that first applies a coordinate bounding box and then performs an exact distance check.

---

# 💼 Interview Questions

### 1. What is geospatial data?

Data representing geographic or geometric information such as points, paths, and areas.

### 2. What is a POINT?

A spatial object representing one location.

### 3. What is a POLYGON?

A spatial object representing a closed area or boundary.

### 4. What does SRID mean?

Spatial Reference System Identifier. It identifies the coordinate reference system associated with spatial data.

### 5. What is SRID 4326?

A widely used geographic coordinate reference system based on WGS 84.

### 6. What does `ST_Distance_Sphere()` do?

It calculates the spherical distance between two geographic points and returns the result in meters.

### 7. What is `ST_Within()`?

It checks whether one geometry is within another geometry.

### 8. What is `ST_Contains()`?

It checks whether one geometry contains another geometry.

### 9. What is `ST_Intersects()`?

It checks whether two geometries spatially intersect.

### 10. What is a spatial index?

An index designed to improve spatial search operations on spatial data.

---

# 🛠️ Project Structure

```text
Day-81-SQL-Geospatial-Data/
│
├── day81.sql
└── README.md
```

---

# ▶️ How to Run

Make sure MySQL 8.x is installed and running.

Open MySQL Workbench, MySQL CLI, or your SQL extension in VS Code.

Run:

```sql
SOURCE path/to/day81.sql;
```

Or open `day81.sql` and execute the complete script.

The script creates:

```text
sql_geospatial_lab
```

with:

```text
cities
delivery_points
delivery_zones
```

---

# 📚 What You Learned

```text
POINT
   ↓
Latitude + Longitude
   ↓
SRID
   ↓
Distance
   ↓
Nearby Search
   ↓
POLYGON
   ↓
Point-in-Polygon
   ↓
Spatial Relationships
   ↓
Spatial Index
```

The key idea is that SQL can answer not only:

> "What data matches this condition?"

but also:

> "What data is geographically close to this location?"

---

# 🚀 Day 81 Summary

**Topic:** SQL Geospatial Data & Spatial Queries

**Main concepts:**

- Spatial data
- GIS
- `POINT`
- `POLYGON`
- WKT
- SRID
- SRID 4326
- `ST_Distance_Sphere()`
- `ST_Within()`
- `ST_Contains()`
- `ST_Intersects()`
- `ST_Transform()`
- Spatial indexes
- Nearby-location queries
- Point-in-polygon queries
- Geofencing concepts

---

# 📈 SQL-A-Day Progress

```text
Day 81 / SQL-A-Day
█████████████████████████████████████████████████████████████████████████████████████
```

**81 days of SQL learning completed! 🔥**

---

# 🔗 Git Commands

```bash
git add .
git commit -m "Day 81 - SQL Geospatial Data"
git push
```

---

## 🔥 Keep Going

Day 81 adds an important real-world dimension to SQL: **location-aware data processing**.

From relational data to spatial analysis, SQL is useful for modern applications, logistics, maps, delivery systems, and data engineering workflows.

**Day 81 complete. 🚀**
