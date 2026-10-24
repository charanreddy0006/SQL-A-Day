-- Day 93: SQL Relational Division & "For All" Queries
-- MySQL 8.0+ | Project: sql_relational_division_lab
-- Question: Which suppliers provide ALL currently required parts?
-- Run in a development environment; this script recreates lab tables.

CREATE DATABASE IF NOT EXISTS sql_relational_division_lab;
USE sql_relational_division_lab;

DROP VIEW IF EXISTS vw_required_parts_coverage;
DROP TABLE IF EXISTS supplier_parts;
DROP TABLE IF EXISTS required_parts;
DROP TABLE IF EXISTS parts;
DROP TABLE IF EXISTS suppliers;

CREATE TABLE suppliers (
  supplier_id INT PRIMARY KEY,
  supplier_name VARCHAR(100) NOT NULL,
  country VARCHAR(60) NOT NULL
);
CREATE TABLE parts (
  part_id INT PRIMARY KEY,
  part_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE required_parts (
  part_id INT PRIMARY KEY,
  FOREIGN KEY (part_id) REFERENCES parts(part_id)
);
CREATE TABLE supplier_parts (
  supplier_id INT NOT NULL,
  part_id INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  lead_days INT NOT NULL CHECK (lead_days >= 0),
  PRIMARY KEY (supplier_id, part_id),
  FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
  FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

INSERT INTO suppliers VALUES
(1,'Apex Components','India'),(2,'BluePeak Supply','Germany'),
(3,'CoreWorks','India'),(4,'Delta Industrial','Japan'),
(5,'Evergreen Parts','USA');
INSERT INTO parts VALUES
(101,'Brake Sensor'),(102,'Control Unit'),(103,'Power Module'),
(104,'Thermal Probe'),(105,'Cable Harness');
INSERT INTO required_parts VALUES (101),(102),(103);
INSERT INTO supplier_parts VALUES
(1,101,12.50,3),(1,102,85.00,5),(1,103,42.00,4),(1,104,9.50,2),
(2,101,11.90,6),(2,102,82.00,4),(2,104,8.75,3),
(3,101,13.00,2),(3,102,79.00,3),(3,103,40.00,3),(3,105,4.20,1),
(4,101,10.50,7),(4,103,39.50,6),(5,104,8.25,2),(5,105,3.90,2);

-- 1. Inspect the current required set.
SELECT rp.part_id, p.part_name
FROM required_parts rp JOIN parts p ON p.part_id = rp.part_id
ORDER BY rp.part_id;

-- 2. Relational division using double NOT EXISTS.
-- Keep a supplier if no required part is missing from its offerings.
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE NOT EXISTS (
  SELECT 1
  FROM required_parts rp
  WHERE NOT EXISTS (
    SELECT 1
    FROM supplier_parts sp
    WHERE sp.supplier_id = s.supplier_id
      AND sp.part_id = rp.part_id
  )
)
ORDER BY s.supplier_id;

-- 3. Alternative using GROUP BY and HAVING.
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
LEFT JOIN supplier_parts sp ON sp.supplier_id = s.supplier_id
LEFT JOIN required_parts rp ON rp.part_id = sp.part_id
GROUP BY s.supplier_id, s.supplier_name
HAVING COUNT(DISTINCT rp.part_id) = (SELECT COUNT(*) FROM required_parts)
ORDER BY s.supplier_id;

-- 4. Coverage report for every supplier.
SELECT s.supplier_id, s.supplier_name,
       COUNT(DISTINCT rp.part_id) AS required_parts_supplied,
       (SELECT COUNT(*) FROM required_parts) AS required_parts_total,
       CASE WHEN COUNT(DISTINCT rp.part_id) = (SELECT COUNT(*) FROM required_parts)
            THEN 'COMPLETE' ELSE 'INCOMPLETE' END AS coverage_status
FROM suppliers s
LEFT JOIN supplier_parts sp ON sp.supplier_id = s.supplier_id
LEFT JOIN required_parts rp ON rp.part_id = sp.part_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY required_parts_supplied DESC, s.supplier_id;

-- 5. A reusable coverage view.
CREATE VIEW vw_required_parts_coverage AS
SELECT s.supplier_id, s.supplier_name,
       COUNT(DISTINCT rp.part_id) AS required_parts_supplied,
       (SELECT COUNT(*) FROM required_parts) AS required_parts_total
FROM suppliers s
LEFT JOIN supplier_parts sp ON sp.supplier_id = s.supplier_id
LEFT JOIN required_parts rp ON rp.part_id = sp.part_id
GROUP BY s.supplier_id, s.supplier_name;

SELECT supplier_id, supplier_name
FROM vw_required_parts_coverage
WHERE required_parts_supplied = required_parts_total
ORDER BY supplier_id;

-- 6. "At least one required part" (existential condition).
SELECT DISTINCT s.supplier_id, s.supplier_name
FROM suppliers s
JOIN supplier_parts sp ON sp.supplier_id = s.supplier_id
JOIN required_parts rp ON rp.part_id = sp.part_id
ORDER BY s.supplier_id;

-- 7. Suppliers with none of the required parts.
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE NOT EXISTS (
  SELECT 1 FROM supplier_parts sp
  JOIN required_parts rp ON rp.part_id = sp.part_id
  WHERE sp.supplier_id = s.supplier_id
)
ORDER BY s.supplier_id;

-- 8. Exact set equality: all required parts AND no extra offered parts.
-- Extra offerings are normally valid; this is a stricter, different rule.
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE NOT EXISTS (
  SELECT 1 FROM required_parts rp
  WHERE NOT EXISTS (
    SELECT 1 FROM supplier_parts sp
    WHERE sp.supplier_id = s.supplier_id AND sp.part_id = rp.part_id
  )
)
AND NOT EXISTS (
  SELECT 1 FROM supplier_parts sp
  WHERE sp.supplier_id = s.supplier_id
    AND NOT EXISTS (
      SELECT 1 FROM required_parts rp WHERE rp.part_id = sp.part_id
    )
)
ORDER BY s.supplier_id;

-- 9. Empty-set edge case. Classical "for all" logic means every supplier
-- qualifies if there are no required parts (vacuous truth).
START TRANSACTION;
DELETE FROM required_parts;
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE NOT EXISTS (
  SELECT 1 FROM required_parts rp
  WHERE NOT EXISTS (
    SELECT 1 FROM supplier_parts sp
    WHERE sp.supplier_id = s.supplier_id AND sp.part_id = rp.part_id
  )
)
ORDER BY s.supplier_id;

-- Business-rule alternative: require the requirement set to be non-empty.
SELECT s.supplier_id, s.supplier_name
FROM suppliers s
WHERE EXISTS (SELECT 1 FROM required_parts)
  AND NOT EXISTS (
    SELECT 1 FROM required_parts rp
    WHERE NOT EXISTS (
      SELECT 1 FROM supplier_parts sp
      WHERE sp.supplier_id = s.supplier_id AND sp.part_id = rp.part_id
    )
  )
ORDER BY s.supplier_id;

-- Restore the original requirement set for repeatable practice.
INSERT INTO required_parts VALUES (101),(102),(103);
COMMIT;

-- Practice:
-- A. Suppliers offering every required part with lead_days <= 4.
-- B. Suppliers offering every required part with unit_price < 50.
-- C. Find the cheapest supplier for each required part.
-- D. Replace the required set with parts 101 and 104 and rerun division.
-- E. Express the "all" condition using both methods.
