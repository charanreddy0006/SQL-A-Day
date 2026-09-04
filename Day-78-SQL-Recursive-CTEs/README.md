Day 78 - SQL Recursive CTEs & Hierarchical Data

Welcome to Day 78 of my SQL-A-Day journey 🚀

Today I am learning one of the most useful advanced SQL techniques for working with hierarchical and tree-structured data: Recursive Common Table Expressions (Recursive CTEs).

Recursive CTEs are especially useful when data has relationships such as:

Employee → Manager

Category → Parent Category

Folder → Parent Folder

Organization → Department

Product → Component

Comment → Parent Comment

Location → Parent Location

1. What is a Recursive CTE?

A Recursive CTE is a Common Table Expression that refers to itself.

A normal CTE builds a temporary result from a query.

A recursive CTE goes one step further:

Start with an initial row or set of rows.

Find the next related rows.

Repeat the process.

Stop when no more rows satisfy the recursive condition.

The general structure in MySQL is:

WITH RECURSIVE cte_name AS (
    -- Anchor query
    SELECT ...

    UNION ALL

    -- Recursive query
    SELECT ...
    FROM some_table
    JOIN cte_name
        ON ...
)
SELECT *
FROM cte_name;

The two important parts are:

Anchor Query

The anchor query defines where recursion starts.

For an employee hierarchy, this might be the CEO:

SELECT *
FROM employees
WHERE manager_id IS NULL;

Recursive Query

The recursive query finds the next level:

SELECT e.*
FROM employees e
JOIN employee_tree et
    ON e.manager_id = et.employee_id;

2. Why Recursive CTEs Matter

Traditional SQL is excellent when the number of relationship levels is known.

For example:

CEO
 └── CTO
      └── Engineering Manager
           └── Data Lead
                └── Data Engineer

Without recursion, you would have to write separate joins for each level.

Something like:

CEO
JOIN manager
JOIN manager
JOIN manager
JOIN employee

But what if tomorrow the organization has 20 levels?

Writing 20 joins would be difficult and inflexible.

A recursive CTE lets SQL repeatedly follow the relationship.

Level 0 → CEO
Level 1 → CTO
Level 2 → Engineering Manager
Level 3 → Data Lead
Level 4 → Data Engineer

This makes hierarchical queries much easier to maintain.

3. Today's Project

Today's database is:

sql_recursive_cte_lab

The main table is:

employees

It contains:

employee_id
employee_name
job_title
manager_id
salary
department

The important column is:

manager_id

It points back to another employee.

For example:

Charan → Bhavya
Bhavya → Anil

This creates a tree.

4. Employee Hierarchy

The sample organization looks approximately like this:

Anil - CEO
│
├── Bhavya - CTO
│   │
│   ├── Charan - Engineering Manager
│   │   ├── Divya - Data Engineering Lead
│   │   │   ├── Eshan
│   │   │   └── Farah
│   │   │
│   │   ├── Gautham
│   │   └── Harini
│   │
│   ├── Ishaan - Senior Developer
│   │   ├── Jahnavi
│   │   └── Kiran
│   │
│   └── Lavanya - QA Lead
│       ├── Manoj
│       └── Nandini

This is exactly the kind of structure where recursive SQL becomes valuable.

5. First Recursive CTE

The first query starts from the CEO.

WITH RECURSIVE employee_tree AS (
    SELECT
        employee_id,
        employee_name,
        job_title,
        manager_id,
        0 AS depth,
        CAST(employee_name AS CHAR(1000)) AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.job_title,
        e.manager_id,
        et.depth + 1,
        CONCAT(et.hierarchy_path, ' -> ', e.employee_name)
    FROM employees e
    INNER JOIN employee_tree et
        ON e.manager_id = et.employee_id
)
SELECT *
FROM employee_tree
ORDER BY hierarchy_path;

6. Understanding the Recursion

The anchor query finds:

Anil

because Anil has no manager.

The recursive query then finds employees whose:

manager_id = Anil.employee_id

That gives:

Bhavya

Then the recursive query uses Bhavya to find:

Charan
Ishaan
Lavanya

Then it continues:

Charan
   ↓
Divya
Gautham
Harini

Ishaan
   ↓
Jahnavi
Kiran

Lavanya
   ↓
Manoj
Nandini

The recursion continues until there are no more employees below the current level.

7. Depth

Depth tells us how far a row is from the root.

Example:

Anil       → depth 0
Bhavya     → depth 1
Charan     → depth 2
Divya      → depth 3
Eshan      → depth 4

We calculate it using:

et.depth + 1

This is useful when displaying or filtering hierarchical data.

For example:

WHERE depth <= 3

can be used to restrict traversal to a certain number of levels.

8. Hierarchy Paths

A recursive CTE can also construct a complete path.

Example:

Anil -> Bhavya -> Charan -> Divya -> Eshan

The path is built using:

CONCAT(
    et.hierarchy_path,
    ' -> ',
    e.employee_name
)

This is useful for:

Organization charts

Breadcrumb navigation

Folder paths

Category navigation

Reporting structures

9. Finding Descendants

Suppose we want every employee below the CTO.

Start with the CTO:

WHERE employee_id = 2

Then recursively find everyone reporting to the current employee.

WITH RECURSIVE descendants AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS relative_depth
    FROM employees
    WHERE employee_id = 2

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        d.relative_depth + 1
    FROM employees e
    JOIN descendants d
        ON e.manager_id = d.employee_id
)
SELECT *
FROM descendants
WHERE employee_id <> 2;

This returns employees at every level below the CTO.

10. Limiting Recursive Depth

Sometimes we don't want the entire subtree.

For example, find only two levels below the CTO.

WITH RECURSIVE descendants AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS relative_depth
    FROM employees
    WHERE employee_id = 2

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        d.relative_depth + 1
    FROM employees e
    JOIN descendants d
        ON e.manager_id = d.employee_id
    WHERE d.relative_depth < 2
)
SELECT *
FROM descendants;

The condition:

WHERE d.relative_depth < 2

controls how far recursion travels.

11. Finding Ancestors

Recursive CTEs can work in the opposite direction too.

Instead of going:

Manager → Employee

we can go:

Employee → Manager → Manager's Manager

For example, find the management chain for Eshan.

WITH RECURSIVE management_chain AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        job_title,
        0 AS level_from_employee
    FROM employees
    WHERE employee_id = 5

    UNION ALL

    SELECT
        m.employee_id,
        m.employee_name,
        m.manager_id,
        m.job_title,
        mc.level_from_employee + 1
    FROM employees m
    JOIN management_chain mc
        ON mc.manager_id = m.employee_id
)
SELECT *
FROM management_chain;

The result follows:

Eshan
↓
Divya
↓
Charan
↓
Bhavya
↓
Anil

12. Recursive CTE + Aggregation

One powerful technique is combining recursion with aggregation.

For example:

How many people are under each manager?

The recursive query can discover the complete subtree.

Then COUNT() can calculate the number of employees.

SELECT
    root.employee_name,
    COUNT(h.employee_id) - 1 AS total_subordinates
...

This gives us a useful organization-management report.

13. Calculating Hierarchy Salary

We can also calculate the total salary represented by an employee's complete hierarchy.

For example:

Manager salary
+
Direct reports
+
Reports of direct reports
+
...

A recursive CTE discovers all descendants and SUM() calculates the total.

SUM(h.salary) AS hierarchy_salary

This can be useful for:

Workforce planning

Management cost analysis

Budget planning

Organizational analytics

14. Leaf Nodes

A leaf employee is someone who manages nobody.

For example:

Eshan
Farah
Gautham
Harini

These are the end nodes of the tree.

A simple self-join can find them:

SELECT
    e.employee_id,
    e.employee_name
FROM employees e
LEFT JOIN employees child
    ON child.manager_id = e.employee_id
WHERE child.employee_id IS NULL;

Recursive CTEs are especially useful when we need to traverse from roots to these leaves.

15. Recursive CTEs for Categories

Hierarchical data isn't limited to employees.

Today's SQL file also creates:

categories

Example:

Electronics
├── Computers
│   ├── Laptops
│   │   ├── Gaming Laptops
│   │   └── Business Laptops
│   └── Desktops
│
└── Accessories
    ├── Keyboards
    └── Mice

The same recursive technique can generate:

Electronics / Computers / Laptops / Gaming Laptops

This is useful in e-commerce systems.

16. Real-World Applications

Recursive CTEs are useful in many data-engineering and software systems.

Organization Systems

CEO → Director → Manager → Employee

E-Commerce

Electronics → Computers → Laptops

File Systems

Root → Documents → Projects → SQL

Product Manufacturing

Product
 ├── Component A
 │   └── Raw Material
 └── Component B

Social Platforms

Comment
 └── Reply
      └── Reply

Geographic Hierarchies

Country
 └── State
      └── City
           └── Area

17. Recursive CTE for Date Generation

Recursive CTEs can also generate a sequence of dates.

Example:

WITH RECURSIVE calendar AS (
    SELECT DATE('2026-09-01') AS calendar_date

    UNION ALL

    SELECT calendar_date + INTERVAL 1 DAY
    FROM calendar
    WHERE calendar_date < DATE('2026-09-10')
)
SELECT *
FROM calendar;

This produces:

2026-09-01
2026-09-02
2026-09-03
...
2026-09-10

This technique can be useful when building reporting calendars or filling missing dates in analytical reports.

18. Recursive CTE for Number Generation

We can also generate numbers:

WITH RECURSIVE numbers AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numbers
    WHERE n < 20
)
SELECT n
FROM numbers;

Result:

1
2
3
...
20

This is useful for demonstrations, test data, calendar generation, and some analytical queries.

19. Important Recursive CTE Structure

Remember this pattern:

WITH RECURSIVE cte_name AS (

    -- 1. Starting point
    SELECT ...

    UNION ALL

    -- 2. Next level
    SELECT ...
    FROM table_name
    JOIN cte_name
        ON ...

)
SELECT *
FROM cte_name;

Think of it as:

START
  ↓
FIND NEXT
  ↓
FIND NEXT
  ↓
FIND NEXT
  ↓
STOP

20. Recursive CTE vs Normal CTE

Feature

Normal CTE

Recursive CTE

Temporary query result

✅

✅

References itself

❌

✅

Hierarchical data

Limited

Excellent

Tree traversal

❌

✅

Parent-child traversal

Difficult

Natural

Date/number generation

Possible

Very useful

Multiple levels

Fixed

Dynamic

21. Recursive CTE vs Multiple Self-JOINs

Suppose a company has:

CEO
 ↓
Director
 ↓
Manager
 ↓
Lead
 ↓
Engineer

With self-joins, you might need:

employees e1
JOIN employees e2
JOIN employees e3
JOIN employees e4
JOIN employees e5

But if the hierarchy grows, the query must change.

A recursive CTE can handle an arbitrary number of levels within the recursion limit.

This makes recursive CTEs much more flexible for tree traversal.

22. Important Safety Considerations ⚠️

1. Always have a stopping condition

Bad recursive logic can generate too many rows.

For example, number generation should have:

WHERE n < 100

2. Watch for cycles

A hierarchy should not contain:

A → B
B → C
C → A

That creates a cycle.

Database design and application validation should prevent invalid hierarchical relationships.

3. Be careful with large hierarchies

Recursive queries over millions of hierarchical relationships can be expensive.

Always consider:

Indexing parent keys

Restricting the starting node

Limiting recursion depth

Selecting only required columns

23. MySQL Version

The examples in this project use:

MySQL 8.0+

Recursive CTE support is required.

24. Data Engineering Connection

Recursive CTEs are especially interesting for data engineering because hierarchical structures frequently appear in real datasets.

A data engineer might receive:

employee_id
manager_id

and need to produce:

employee_id
manager_name
hierarchy_level
full_path
subordinate_count
team_salary

Instead of processing every level separately in Python, Spark, or another application layer, SQL can perform the hierarchy traversal directly when the database is the appropriate processing layer.

25. Practice Questions 🧠

Try solving these without looking at the SQL file.

Easy

Display the complete employee hierarchy.

Show employee depth.

Find all employees who report directly to Bhavya.

Find all leaf employees.

Generate numbers from 1 to 100.

Medium

Find every employee below the CTO.

Find the management chain for Jahnavi.

Build a complete path for every employee.

Find the number of subordinates under every manager.

Find all categories below Electronics.

Advanced

Calculate total salary under every manager.

Find the deepest employee in the organization.

Return only employees within three levels of the CEO.

Build a category breadcrumb for every category.

Generate a calendar for an entire month and include the day name.

26. Interview Questions 🎯

Q1. What is a recursive CTE?

A recursive CTE is a CTE that references itself to repeatedly process related rows.

Q2. What are the two parts of a recursive CTE?

The:

Anchor member

Recursive member

Q3. Why is UNION ALL commonly used?

The anchor query produces the starting rows, while the recursive query adds subsequent rows. UNION ALL preserves those rows without unnecessary duplicate elimination.

Q4. What problems are recursive CTEs good at solving?

They are particularly useful for:

Hierarchies

Trees

Parent-child relationships

Organizational structures

Category structures

Recursive paths

Number/date generation

Q5. What happens if recursion does not terminate?

The query can continue until MySQL's recursion limit is reached and may consume significant resources.

Q6. Can recursive CTEs find ancestors as well as descendants?

Yes.

You can recursively move:

Parent → Child

or:

Child → Parent

depending on the join condition.

Q7. What is a leaf node?

A node that has no children.

For an employee hierarchy, a leaf employee manages nobody.

27. Project Structure

Day-78-SQL-Recursive-CTEs/
│
├── day78.sql
└── README.md

28. How to Run

Open MySQL and execute:

SOURCE path/to/day78.sql;

Or open day78.sql in VS Code and execute the statements using your MySQL extension.

The script creates:

sql_recursive_cte_lab

and all required tables and sample data.

29. Git Commands

After adding the Day 78 folder:

git add .

Commit:

git commit -m "Day 78 - SQL Recursive CTEs"

Push:

git push

Commit Message

Day 78 - SQL Recursive CTEs

30. Summary

Today I learned how to use Recursive CTEs to traverse hierarchical data.

Key concepts:

Recursive CTE syntax

Anchor query

Recursive query

WITH RECURSIVE

Employee hierarchies

Parent-child relationships

Descendant traversal

Ancestor traversal

Hierarchy depth

Hierarchy paths

Subordinate counting

Hierarchy salary calculations

Category trees

Date generation

Number generation

Recursion limits

Cycle considerations

The most important pattern to remember is:

WITH RECURSIVE tree AS (
    SELECT ...

    UNION ALL

    SELECT ...
    FROM table
    JOIN tree
        ON ...
)
SELECT *
FROM tree;

Day 78 complete! 🚀

Tomorrow's availability issue is handled by completing this day's work today, while keeping the repository and commit sequence as Day 78.