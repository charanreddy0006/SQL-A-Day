-- ============================================================
-- DAY 80: SQL GRAPH DATA & PATH QUERIES
-- MySQL 8+
-- ============================================================

DROP DATABASE IF EXISTS sql_graph_lab;
CREATE DATABASE sql_graph_lab;
USE sql_graph_lab;

-- ============================================================
-- 1. GRAPH DATA MODEL
-- Nodes = entities
-- Edges = relationships
-- ============================================================

DROP TABLE IF EXISTS graph_edges;
DROP TABLE IF EXISTS graph_nodes;

CREATE TABLE graph_nodes (
    node_id INT PRIMARY KEY,
    node_name VARCHAR(100) NOT NULL,
    node_type VARCHAR(50) NOT NULL
);

CREATE TABLE graph_edges (
    edge_id INT PRIMARY KEY AUTO_INCREMENT,
    from_node_id INT NOT NULL,
    to_node_id INT NOT NULL,
    relationship_type VARCHAR(50) NOT NULL,
    distance_km DECIMAL(10,2) NOT NULL,
    travel_minutes INT NOT NULL,
    FOREIGN KEY (from_node_id) REFERENCES graph_nodes(node_id),
    FOREIGN KEY (to_node_id) REFERENCES graph_nodes(node_id),
    CHECK (from_node_id <> to_node_id),
    UNIQUE (from_node_id, to_node_id)
);

-- ============================================================
-- 2. GRAPH NODES
-- ============================================================

INSERT INTO graph_nodes (node_id, node_name, node_type)
VALUES
(1, 'Hyderabad', 'CITY'),
(2, 'Bengaluru', 'CITY'),
(3, 'Chennai', 'CITY'),
(4, 'Pune', 'CITY'),
(5, 'Mumbai', 'CITY'),
(6, 'Delhi', 'CITY'),
(7, 'Jaipur', 'CITY'),
(8, 'Ahmedabad', 'CITY'),
(9, 'Kolkata', 'CITY'),
(10, 'Visakhapatnam', 'CITY');

-- ============================================================
-- 3. DIRECTED GRAPH EDGES
-- ============================================================

INSERT INTO graph_edges
(from_node_id, to_node_id, relationship_type, distance_km, travel_minutes)
VALUES
(1, 2, 'ROAD', 570, 600),
(1, 3, 'ROAD', 630, 690),
(1, 10, 'ROAD', 620, 720),
(1, 4, 'ROAD', 560, 610),
(2, 3, 'ROAD', 350, 390),
(2, 4, 'ROAD', 840, 900),
(2, 5, 'ROAD', 980, 1050),
(3, 10, 'ROAD', 800, 900),
(3, 9, 'ROAD', 1660, 1800),
(4, 5, 'ROAD', 150, 180),
(4, 6, 'ROAD', 1450, 1560),
(4, 8, 'ROAD', 1200, 1320),
(5, 6, 'ROAD', 1400, 1500),
(5, 8, 'ROAD', 530, 600),
(6, 7, 'ROAD', 280, 330),
(6, 9, 'ROAD', 1500, 1620),
(7, 8, 'ROAD', 660, 720),
(8, 5, 'ROAD', 530, 600),
(10, 9, 'ROAD', 1150, 1260),
(9, 6, 'ROAD', 1500, 1620);

-- ============================================================
-- 4. DISPLAY ALL EDGES
-- ============================================================

SELECT
    e.edge_id,
    f.node_name AS from_city,
    t.node_name AS to_city,
    e.relationship_type,
    e.distance_km,
    e.travel_minutes
FROM graph_edges e
JOIN graph_nodes f
    ON f.node_id = e.from_node_id
JOIN graph_nodes t
    ON t.node_id = e.to_node_id
ORDER BY e.edge_id;

-- ============================================================
-- 5. DIRECT NEIGHBORS
-- Hyderabad -> directly reachable cities
-- ============================================================

SELECT
    t.node_id,
    t.node_name,
    e.distance_km,
    e.travel_minutes
FROM graph_edges e
JOIN graph_nodes t
    ON t.node_id = e.to_node_id
WHERE e.from_node_id = 1
ORDER BY e.distance_km;

-- ============================================================
-- 6. INCOMING NEIGHBORS
-- Cities that directly reach Mumbai
-- ============================================================

SELECT
    f.node_id,
    f.node_name,
    e.distance_km
FROM graph_edges e
JOIN graph_nodes f
    ON f.node_id = e.from_node_id
WHERE e.to_node_id = 5
ORDER BY e.distance_km;

-- ============================================================
-- 7. OUTGOING CONNECTION COUNT
-- ============================================================

SELECT
    n.node_id,
    n.node_name,
    COUNT(e.edge_id) AS outgoing_connections
FROM graph_nodes n
LEFT JOIN graph_edges e
    ON e.from_node_id = n.node_id
GROUP BY n.node_id, n.node_name
ORDER BY outgoing_connections DESC, n.node_id;

-- ============================================================
-- 8. INCOMING CONNECTION COUNT
-- ============================================================

SELECT
    n.node_id,
    n.node_name,
    COUNT(e.edge_id) AS incoming_connections
FROM graph_nodes n
LEFT JOIN graph_edges e
    ON e.to_node_id = n.node_id
GROUP BY n.node_id, n.node_name
ORDER BY incoming_connections DESC, n.node_id;

-- ============================================================
-- 9. RECURSIVE GRAPH TRAVERSAL
-- Find nodes reachable from Hyderabad.
-- ============================================================

WITH RECURSIVE reachable AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop,
        CAST(CONCAT('1 -> ', e.to_node_id) AS CHAR(1000)) AS path
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        r.hop + 1,
        CONCAT(r.path, ' -> ', e.to_node_id)
    FROM graph_edges e
    JOIN reachable r
        ON e.from_node_id = r.node_id
    WHERE r.hop < 10
)
SELECT
    r.node_id,
    n.node_name,
    r.hop,
    r.path
FROM reachable r
JOIN graph_nodes n
    ON n.node_id = r.node_id
ORDER BY r.hop, r.node_id;

-- ============================================================
-- 10. PATH TRAVERSAL WITH CYCLE PREVENTION
-- ============================================================

WITH RECURSIVE paths AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop,
        CAST('1' AS CHAR(1000)) AS visited_nodes,
        CAST(
            CONCAT(
                (SELECT node_name FROM graph_nodes WHERE node_id = 1),
                ' -> ',
                (SELECT node_name
                 FROM graph_nodes
                 WHERE node_id = e.to_node_id)
            ) AS CHAR(2000)
        ) AS city_path,
        e.distance_km AS total_distance_km
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        p.hop + 1,
        CONCAT(p.visited_nodes, ',', e.to_node_id),
        CONCAT(
            p.city_path,
            ' -> ',
            n.node_name
        ),
        p.total_distance_km + e.distance_km
    FROM graph_edges e
    JOIN paths p
        ON e.from_node_id = p.node_id
    JOIN graph_nodes n
        ON n.node_id = e.to_node_id
    WHERE p.hop < 10
      AND FIND_IN_SET(e.to_node_id, p.visited_nodes) = 0
)
SELECT
    node_id,
    hop,
    city_path,
    total_distance_km
FROM paths
ORDER BY hop, total_distance_km;

-- ============================================================
-- 11. ALL PATHS: HYDERABAD -> DELHI
-- ============================================================

WITH RECURSIVE city_paths AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop,
        CAST('Hyderabad' AS CHAR(2000)) AS city_path,
        e.distance_km AS total_distance_km,
        CAST('1' AS CHAR(1000)) AS visited_nodes
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        cp.hop + 1,
        CONCAT(cp.city_path, ' -> ', n.node_name),
        cp.total_distance_km + e.distance_km,
        CONCAT(cp.visited_nodes, ',', e.to_node_id)
    FROM city_paths cp
    JOIN graph_edges e
        ON e.from_node_id = cp.node_id
    JOIN graph_nodes n
        ON n.node_id = e.to_node_id
    WHERE cp.hop < 10
      AND FIND_IN_SET(e.to_node_id, cp.visited_nodes) = 0
)
SELECT
    city_path,
    hop,
    total_distance_km
FROM city_paths
WHERE node_id = 6
ORDER BY hop, total_distance_km;

-- ============================================================
-- 12. SHORTEST PATH BY NUMBER OF HOPS
-- ============================================================

WITH RECURSIVE city_paths AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop,
        CAST('Hyderabad' AS CHAR(2000)) AS city_path,
        CAST('1' AS CHAR(1000)) AS visited_nodes
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        cp.hop + 1,
        CONCAT(cp.city_path, ' -> ', n.node_name),
        CONCAT(cp.visited_nodes, ',', e.to_node_id)
    FROM city_paths cp
    JOIN graph_edges e
        ON e.from_node_id = cp.node_id
    JOIN graph_nodes n
        ON n.node_id = e.to_node_id
    WHERE cp.hop < 10
      AND FIND_IN_SET(e.to_node_id, cp.visited_nodes) = 0
)
SELECT
    city_path,
    hop
FROM city_paths
WHERE node_id = 6
ORDER BY hop
LIMIT 1;

-- ============================================================
-- 13. SHORTEST PATH BY TOTAL DISTANCE
-- ============================================================

WITH RECURSIVE city_paths AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop,
        CAST('Hyderabad' AS CHAR(2000)) AS city_path,
        e.distance_km AS total_distance_km,
        CAST('1' AS CHAR(1000)) AS visited_nodes
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        cp.hop + 1,
        CONCAT(cp.city_path, ' -> ', n.node_name),
        cp.total_distance_km + e.distance_km,
        CONCAT(cp.visited_nodes, ',', e.to_node_id)
    FROM city_paths cp
    JOIN graph_edges e
        ON e.from_node_id = cp.node_id
    JOIN graph_nodes n
        ON n.node_id = e.to_node_id
    WHERE cp.hop < 10
      AND FIND_IN_SET(e.to_node_id, cp.visited_nodes) = 0
)
SELECT
    city_path,
    hop,
    total_distance_km
FROM city_paths
WHERE node_id = 6
ORDER BY total_distance_km
LIMIT 1;

-- ============================================================
-- 14. FASTEST PATH BY TRAVEL TIME
-- ============================================================

WITH RECURSIVE city_paths AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop,
        CAST('Hyderabad' AS CHAR(2000)) AS city_path,
        e.travel_minutes AS total_minutes,
        CAST('1' AS CHAR(1000)) AS visited_nodes
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        cp.hop + 1,
        CONCAT(cp.city_path, ' -> ', n.node_name),
        cp.total_minutes + e.travel_minutes,
        CONCAT(cp.visited_nodes, ',', e.to_node_id)
    FROM city_paths cp
    JOIN graph_edges e
        ON e.from_node_id = cp.node_id
    JOIN graph_nodes n
        ON n.node_id = e.to_node_id
    WHERE cp.hop < 10
      AND FIND_IN_SET(e.to_node_id, cp.visited_nodes) = 0
)
SELECT
    city_path,
    hop,
    total_minutes
FROM city_paths
WHERE node_id = 6
ORDER BY total_minutes
LIMIT 1;

-- ============================================================
-- 15. MOST CONNECTED CITIES
-- ============================================================

SELECT
    n.node_id,
    n.node_name,
    COUNT(e.edge_id) AS outgoing_connections
FROM graph_nodes n
LEFT JOIN graph_edges e
    ON e.from_node_id = n.node_id
GROUP BY n.node_id, n.node_name
ORDER BY outgoing_connections DESC
LIMIT 5;

-- ============================================================
-- 16. EXACTLY TWO-HOP CONNECTIONS
-- ============================================================

SELECT DISTINCT
    n2.node_name AS destination_city
FROM graph_edges e1
JOIN graph_edges e2
    ON e2.from_node_id = e1.to_node_id
JOIN graph_nodes n2
    ON n2.node_id = e2.to_node_id
WHERE e1.from_node_id = 1
ORDER BY destination_city;

-- ============================================================
-- 17. MINIMUM HOPS TO EVERY REACHABLE CITY
-- ============================================================

WITH RECURSIVE reachability AS (
    SELECT
        e.to_node_id AS node_id,
        1 AS hop
    FROM graph_edges e
    WHERE e.from_node_id = 1

    UNION ALL

    SELECT
        e.to_node_id,
        r.hop + 1
    FROM graph_edges e
    JOIN reachability r
        ON e.from_node_id = r.node_id
    WHERE r.hop < 10
)
SELECT
    n.node_name,
    MIN(r.hop) AS minimum_hops_from_hyderabad
FROM reachability r
JOIN graph_nodes n
    ON n.node_id = r.node_id
GROUP BY n.node_id, n.node_name
ORDER BY minimum_hops_from_hyderabad, n.node_name;

-- ============================================================
-- 18. ROUTES LONGER THAN 1000 KM
-- ============================================================

SELECT
    f.node_name AS from_city,
    t.node_name AS to_city,
    e.distance_km
FROM graph_edges e
JOIN graph_nodes f
    ON f.node_id = e.from_node_id
JOIN graph_nodes t
    ON t.node_id = e.to_node_id
WHERE e.distance_km > 1000
ORDER BY e.distance_km DESC;

-- ============================================================
-- 19. GRAPH STATISTICS
-- ============================================================

SELECT
    relationship_type,
    COUNT(*) AS edge_count,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    ROUND(AVG(travel_minutes), 2) AS avg_travel_minutes
FROM graph_edges
GROUP BY relationship_type;

-- ============================================================
-- 20. PRACTICE QUESTIONS
-- ============================================================

-- Q1. Find all cities directly reachable from Bengaluru.

-- Q2. Find all cities that can directly reach Mumbai.

-- Q3. Count outgoing connections for every city.

-- Q4. Find every city reachable from Hyderabad.

-- Q5. Find all paths from Hyderabad to Delhi.

-- Q6. Find the path with the fewest hops from Hyderabad to Delhi.

-- Q7. Find the shortest-distance path from Hyderabad to Delhi.

-- Q8. Find the fastest path from Hyderabad to Delhi.

-- Q9. Find cities reachable from Hyderabad within 2 hops.

-- Q10. Find the five cities with the most outgoing connections.

-- Q11. Find all routes longer than 1000 km.

-- Q12. Calculate the minimum number of hops from Hyderabad
--      to every reachable city.

-- ============================================================
-- 21. IMPORTANT NOTES
-- ============================================================

-- Nodes = entities
-- Edges = relationships
--
-- Directed:
-- A -> B
--
-- does not automatically mean:
-- B -> A
--
-- Recursive CTEs can enumerate candidate paths.
--
-- For very large graphs, candidate-path enumeration can become
-- expensive. Dedicated graph algorithms or graph-processing
-- systems may be more suitable for production workloads.

-- ============================================================
-- END OF DAY 80
-- ============================================================
