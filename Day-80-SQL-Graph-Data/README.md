Day 80 — SQL Graph Data & Path Queries

📌 Overview

Welcome to Day 80 of my SQL-A-Day journey 🚀

Today I am learning how relational tables can represent graph data and how SQL can be used to explore relationships, traverse connected entities, and analyze paths.

Graph-shaped data appears when the important relationship is:

Entity → Relationship → Entity

Examples include:

Cities connected by roads

Users connected by friendships

Servers connected by dependencies

Products connected to components

Services connected to other services

Locations connected by routes

Accounts connected through transfers

Today's project uses a city and road network to demonstrate these concepts.

🎯 Learning Goals

By the end of Day 80, I should understand:

What graph data is.

What nodes and edges represent.

Directed graph relationships.

How to model a graph using SQL tables.

How to find direct neighbors.

How to find incoming and outgoing connections.

How recursive CTEs can traverse a graph.

How to build paths.

How to prevent repeated nodes in a path.

How to find candidate paths between two nodes.

How to find a minimum-hop path.

How to find a shortest-distance path.

How to find a fastest path.

How SQL can perform basic graph analytics.

When a dedicated graph system may be more appropriate.

1. What is a Graph?

A graph is a collection of:

Nodes
+
Edges

Node

A node represents an entity.

In today's project:

Hyderabad
Bengaluru
Chennai
Pune
Mumbai
Delhi

are nodes.

Edge

An edge represents a relationship between two nodes.

For example:

Hyderabad → Bengaluru

represents a route from Hyderabad to Bengaluru.

2. Simple Graph Example

A graph can look like:

          Bengaluru
         ↗         ↘
Hyderabad           Chennai
     ↘              ↗
       Visakhapatnam

The cities are nodes.

The connections are edges.

3. Representing a Graph in SQL

A common relational design uses two tables:

graph_nodes
graph_edges

graph_nodes

Stores entities:

node_id
node_name
node_type

graph_edges

Stores relationships:

edge_id
from_node_id
to_node_id
relationship_type
distance_km
travel_minutes

The edge table contains two references to the node table:

from_node_id
to_node_id

This creates the relationship:

Node A
  ↓
Edge
  ↓
Node B

This is commonly called an edge-list representation.

4. Directed Graphs

Today's project uses a directed graph.

If the table contains:

Hyderabad → Bengaluru

that represents one direction.

It does not automatically create:

Bengaluru → Hyderabad

If the application needs both directions, both edges can be stored.

5. Undirected Graphs

An undirected relationship means:

A ↔ B

In a relational edge table, one practical representation is:

A → B
B → A

For example:

Mumbai ↔ Pune

could be represented using two rows:

Mumbai → Pune
Pune → Mumbai

The appropriate model depends on the application.

6. Today's Database

The SQL file creates:

sql_graph_lab

and two main tables:

graph_nodes
graph_edges

The sample graph contains cities such as:

Hyderabad
Bengaluru
Chennai
Pune
Mumbai
Delhi
Jaipur
Ahmedabad
Kolkata
Visakhapatnam

Each route also stores:

distance_km
travel_minutes

This allows us to perform weighted path analysis.

7. Finding Direct Neighbors

Suppose we want cities directly reachable from Hyderabad.

We can query:

SELECT
    t.node_name,
    e.distance_km,
    e.travel_minutes
FROM graph_edges e
JOIN graph_nodes t
    ON t.node_id = e.to_node_id
WHERE e.from_node_id = 1;

The result represents the immediate neighbors of Hyderabad.

Conceptually:

Hyderabad
    ↓
Directly reachable cities

8. Finding Incoming Neighbors

We can reverse the lookup.

For example:

Which cities can directly reach Mumbai?

Use:

WHERE e.to_node_id = 5

This examines incoming edges instead of outgoing edges.

9. Graph Degree

The number of connections of a node is commonly called its degree.

For a directed graph we can consider:

Outgoing degree
Incoming degree

Outgoing degree:

COUNT(e.edge_id)

where:

e.from_node_id = n.node_id

Incoming degree:

COUNT(e.edge_id)

where:

e.to_node_id = n.node_id

This can help identify highly connected nodes.

10. Why Recursive CTEs Are Useful

Consider this graph:

A → B
B → C
C → D
D → E

If we want all nodes reachable from A, we need to repeatedly follow the relationships:

A → B
B → C
C → D
D → E

The number of hops may not be known beforehand.

A recursive CTE is useful because it can repeatedly process the next level.

11. Basic Graph Traversal

Example:

WITH RECURSIVE reachable AS (
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
    JOIN reachable r
        ON e.from_node_id = r.node_id
    WHERE r.hop < 10
)
SELECT *
FROM reachable;

The query:

Starts at Hyderabad.

Finds its neighbors.

Finds neighbors of those nodes.

Continues until the depth limit is reached.

12. Understanding Hops

A hop represents one edge traversal.

Example:

Hyderabad → Bengaluru

has:

1 hop

And:

Hyderabad → Bengaluru → Chennai

has:

2 hops

The recursive query uses:

r.hop + 1

to track the traversal depth.

13. Building a Path

Knowing that a destination is reachable is useful.

Knowing how it was reached is even more useful.

For example:

Hyderabad → Pune → Mumbai → Delhi

The SQL project constructs paths using:

CONCAT(
    cp.city_path,
    ' -> ',
    n.node_name
)

This produces a human-readable route.

14. Cycle Problem ⚠️

Graphs can contain cycles.

For example:

A → B
B → C
C → A

If we keep following edges:

A → B → C → A → B → C → ...

we can repeatedly revisit the same nodes.

Therefore, recursive graph traversal needs a termination strategy.

Today's project tracks visited node IDs using a path string and checks them with:

FIND_IN_SET()

15. Finding All Paths Between Two Cities

Suppose we want:

Hyderabad → Delhi

There may be multiple candidate paths.

For example:

Hyderabad → Pune → Delhi

and:

Hyderabad → Bengaluru → Mumbai → Delhi

A recursive CTE can enumerate candidate paths.

The project calculates:

hop count
total distance
path

for each candidate.

16. Shortest Path by Number of Hops

Sometimes the definition of shortest is:

Use the fewest edges.

Example:

Path A:
A → B → C → D

has:

3 hops

while:

Path B:
A → E → D

has:

2 hops

Path B is shorter by hop count.

The SQL can select:

ORDER BY hop
LIMIT 1;

17. Shortest Path by Distance 📍

Fewest hops does not necessarily mean shortest physical distance.

Example:

Route A:
3 hops
500 km

Route B:
2 hops
900 km

Route B has fewer hops.

Route A has the shorter distance.

Today's edges contain:

distance_km

so each candidate path can calculate:

total_distance_km

Then:

ORDER BY total_distance_km
LIMIT 1;

selects the shortest-distance candidate.

18. Fastest Path ⏱️

Distance and travel time are different.

A longer route might be faster.

Today's edges contain:

travel_minutes

The recursive query adds the travel time of each edge:

cp.total_minutes + e.travel_minutes

Then:

ORDER BY total_minutes
LIMIT 1;

selects the fastest candidate path.

19. Three Different Meanings of "Shortest"

This is an important concept:

Fewest hops
      ≠
Shortest distance
      ≠
Fastest travel time

For example:

Path

Hops

Distance

Time

A

2

900 km

700 min

B

3

500 km

550 min

Depending on the business requirement:

Hop-based → A

Distance-based → B

Time-based → B

The metric must be chosen based on the actual problem.

20. Two-Hop Queries

If we know the exact number of hops, ordinary joins can sometimes be simpler.

For example:

Hyderabad
   ↓
City A
   ↓
City B

is a two-hop relationship.

We can use:

graph_edges e1
JOIN graph_edges e2

This is useful when the number of levels is fixed.

21. Recursive CTE vs Fixed JOINs

Requirement

Suitable Approach

Direct relationship

JOIN

2 fixed hops

Multiple JOINs

3 fixed hops

Multiple JOINs

Unknown number of hops

Recursive CTE

Large complex graph

Consider graph-specific technology

22. Graph Analytics

Once graph data is stored, we can calculate useful metrics.

Most Connected City

Find the node with the largest outgoing degree.

Reachability

Find every city reachable from Hyderabad.

Minimum Hops

Find the smallest number of edges needed to reach a destination.

Shortest Distance

Find the candidate path with the smallest total distance.

Fastest Route

Find the candidate path with the smallest total travel time.

23. Data Engineering Applications 🚀

Graph-shaped relationships appear in many real-world systems.

Social Networks

User → Friend → Friend

Recommendation Systems

User → Product → Similar Product

Microservices

Service A → Service B → Service C

Infrastructure

Server → Service → Database

Transportation

City → Road → City

Supply Chains

Supplier → Factory → Warehouse → Customer

Dependency Analysis

Application → Library → Dependency

24. Graph Modeling Pattern

A common relational graph design is:

nodes
-----
node_id
node_name
node_type

and:

edges
-----
edge_id
from_node_id
to_node_id
relationship_type
weight

In today's project, the weight-related columns are:

distance_km
travel_minutes

This allows the same graph to be analyzed using different cost metrics.

25. Important Algorithmic Limitation ⚠️

The SQL queries in this project demonstrate graph traversal and candidate-path enumeration.

They are excellent for learning how graph problems can be expressed in SQL.

However, enumerating many possible paths can become expensive as a graph becomes large.

A production system with a huge graph may use:

Specialized graph databases

Dijkstra-style algorithms

Other shortest-path algorithms

Graph-processing frameworks

Application-level graph algorithms

Therefore:

Recursive SQL is powerful, but it is not automatically the best solution for every graph workload.

26. Common Mistakes

Mistake 1 — Confusing nodes and edges

Remember:

Node = entity
Edge = relationship

Mistake 2 — Assuming a directed edge works both ways

This:

A → B

does not automatically mean:

B → A

Mistake 3 — Ignoring cycles

A graph can contain:

A → B → C → A

Always consider cycle prevention.

Mistake 4 — Confusing hops and distance

Fewest hops

is not necessarily:

Shortest distance

Mistake 5 — Traversing huge graphs without limits

Recursive traversal can generate a large number of rows.

Consider:

Starting node

Destination node

Maximum depth

Cycle prevention

Dataset size

27. Practice Questions 🧠

Easy

Find all cities directly reachable from Bengaluru.

Find all cities that can directly reach Mumbai.

Count outgoing connections for every city.

Count incoming connections for every city.

Find routes longer than 1000 km.

Medium

Find every city reachable from Hyderabad.

Find cities reachable from Hyderabad within two hops.

Find the minimum number of hops from Hyderabad to every reachable city.

Find the five cities with the most outgoing connections.

Find all paths from Hyderabad to Delhi.

Advanced

Find the path with the fewest hops from Hyderabad to Delhi.

Find the shortest-distance path from Hyderabad to Delhi.

Find the fastest path from Hyderabad to Delhi.

Add a new city and connect it to the graph.

Modify the graph model to represent a social network.

28. Interview Questions 🎯

Q1. What is graph data?

Graph data represents entities as nodes and relationships as edges.

Q2. What is a node?

A node represents an entity such as:

User
City
Server
Product

Q3. What is an edge?

An edge represents a relationship between two nodes.

Example:

A → B

Q4. What is a directed graph?

A graph where the relationship has a direction.

A → B

does not necessarily mean:

B → A

Q5. How can a graph be represented in SQL?

A common design uses:

nodes table
edges table

The edge table stores source and destination node IDs.

Q6. Why are recursive CTEs useful for graph traversal?

They can repeatedly follow relationships when the number of traversal levels is not known in advance.

Q7. What is a cycle?

A cycle occurs when traversal can eventually return to a previously visited node.

Example:

A → B → C → A

Q8. Is the fewest-hop path always the shortest-distance path?

No.

A path with fewer edges can have a larger total distance.

Q9. Can SQL calculate graph paths?

Yes. Recursive SQL can traverse relationships and enumerate candidate paths.

Q10. Should every large graph be processed using SQL?

No. Very large or complex graph workloads may benefit from dedicated graph databases or optimized graph algorithms.

29. Project Structure

Day-80-SQL-Graph-Data/
│
├── day80.sql
└── README.md

30. How to Run

Make sure you are using:

MySQL 8+

Open:

day80.sql

in VS Code, MySQL Workbench, or your MySQL extension.

You can also run:

SOURCE path/to/day80.sql;

The script creates:

sql_graph_lab

and loads the sample graph.

31. GitHub Progress

Day 77 → SQL JSON Data & JSON Querying
Day 78 → SQL Recursive CTEs & Hierarchical Data
Day 79 → MySQL Full-Text Search & Relevance Ranking
Day 80 → SQL Graph Data & Path Queries

🔥 80 days of SQL!

32. Git Commands

Add the Day 80 folder:

git add .

Commit:

git commit -m "Day 80 - SQL Graph Data"

Push:

git push

Commit Message

Day 80 - SQL Graph Data

33. Summary

Today I learned how SQL can represent and analyze graph-shaped data.

Key concepts:

Graphs

Nodes

Edges

Directed graphs

Undirected graph modeling

Edge-list representation

Direct neighbors

Incoming connections

Outgoing connections

Recursive graph traversal

Reachability

Multi-hop relationships

Path construction

Cycle prevention

Minimum-hop paths

Shortest-distance paths

Fastest paths

Graph analytics

Data-engineering applications

Graph algorithm limitations

The most important mental model is:

                  GRAPH
                    │
            ┌───────┴───────┐
            ↓               ↓
          NODES           EDGES
       (entities)     (relationships)
            │               │
            └───────┬───────┘
                    ↓
             Recursive SQL
                    ↓
              Graph Traversal
                    ↓
                Paths
                    ↓
               Analytics

And remember:

Fewest hops
    ≠
Shortest distance
    ≠
Fastest route

The correct metric depends on the business problem.

🚀 Day 80 Complete!