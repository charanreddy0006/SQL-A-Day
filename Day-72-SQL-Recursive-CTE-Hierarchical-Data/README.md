Day 72 — SQL Recursive CTEs & Hierarchical Data

Project

SQL-A-Day — Day 72

Topic: Recursive CTEs and Hierarchical Data

Database: sql_recursive_hierarchy_lab

SQL Dialect: MySQL 8+

Files

Day-72-SQL-Recursive-CTE-Hierarchical-Data/
│
├── day72.sql
└── README.md

1. Overview

Day 72 focuses on one of the most useful SQL features for hierarchical data:

WITH RECURSIVE

Many real-world datasets naturally form parent-child relationships.

Examples include:

Company organization charts
Employee-manager relationships
Product categories
Folder structures
File systems
Comment threads
Bill of materials
Geographical hierarchies
Menu structures
Dependency trees
Account hierarchies

A normal self-join is useful when the number of levels is known.

A recursive CTE is useful when the hierarchy can contain an unknown or variable number of levels.

2. Learning Objectives

By completing Day 72, you should understand:

Common Table Expressions

Recursive CTEs

Anchor members

Recursive members

Parent-child relationships

Self-referencing foreign keys

Root nodes

Leaf nodes

Ancestors

Descendants

Hierarchy levels

Hierarchy paths

Downward traversal

Upward traversal

Organization trees

Category trees

Recursive sequence generation

Recursive date generation

Depth limiting

Recursive query performance

Hierarchy data quality

Practical data-engineering use cases

3. What Is a CTE?

CTE stands for:

Common Table Expression

A CTE creates a temporary named result set that can be referenced by the query that follows it.

Basic syntax:

WITH employee_data AS (
    SELECT *
    FROM employees
)
SELECT *
FROM employee_data;

A CTE improves readability by separating a complex query into logical sections.

4. What Is a Recursive CTE?

A recursive CTE is a CTE that refers to itself.

General pattern:

WITH RECURSIVE hierarchy AS (

    -- Anchor member
    SELECT ...

    UNION ALL

    -- Recursive member
    SELECT ...
    FROM table
    JOIN hierarchy
        ON ...

)
SELECT *
FROM hierarchy;

The recursive CTE repeatedly applies the recursive member to newly discovered rows.

5. Anchor Member

The anchor member defines where recursion begins.

For an employee organization, the root employee is the CEO.

Example:

SELECT
    employee_id,
    employee_name,
    manager_id,
    0 AS hierarchy_level
FROM employees
WHERE manager_id IS NULL;

The CEO becomes:

Level 0

6. Recursive Member

The recursive member finds the next level.

Example:

SELECT
    e.employee_id,
    e.employee_name,
    e.manager_id,
    eh.hierarchy_level + 1
FROM employees AS e
JOIN employee_hierarchy AS eh
    ON e.manager_id = eh.employee_id;

This means:

Find employees whose manager
is the employee from the previous level.

7. How Recursion Works

Consider:

CEO
 |
 +-- CTO
      |
      +-- Engineering Manager
              |
              +-- Software Engineer

The recursive CTE processes:

Iteration 1
CEO

Iteration 2
CTO

Iteration 3
Engineering Manager

Iteration 4
Software Engineer

The process continues until the recursive query produces no additional matching rows.

8. Project Structure

The project contains:

Day-72-SQL-Recursive-CTE-Hierarchical-Data/
│
├── day72.sql
└── README.md

The SQL file contains practical examples for:

Employee hierarchy
Category hierarchy
Ancestor traversal
Descendant traversal
Hierarchy paths
Level calculations
Recursive sequences
Recursive dates
Depth limiting
Hierarchical analytics

9. Employee Hierarchy

The main table is:

employees

Important columns:

employee_id
employee_name
job_title
department
manager_id
salary
joined_date

The most important column for hierarchy traversal is:

manager_id

10. Self-Referencing Foreign Key

The employee table contains:

FOREIGN KEY (manager_id)
REFERENCES employees(employee_id)

This means an employee's manager is another employee in the same table.

The relationship is:

employees
    │
    ├── employee_id
    │
    └── manager_id
            ↓
       employee_id

This is called a self-referencing relationship.

11. Root Node

A root node has no parent.

In the employee hierarchy:

WHERE manager_id IS NULL

returns the root employee.

Conceptually:

CEO
└── manager_id = NULL

12. Parent and Child

Suppose:

Anil Sharma
    ↓
Meera Rao

Anil is the parent.

Meera is the child.

The database represents this as:

Meera.manager_id = Anil.employee_id

This simple structure can represent a complete organization.

13. Direct Reports

A direct report is an employee who immediately reports to a manager.

Example:

SELECT *
FROM employees
WHERE manager_id = 2;

This returns only immediate children.

It does not automatically return grandchildren.

14. Complete Organization Tree

The main recursive query begins at:

CEO

and repeatedly finds:

employee.manager_id
=
previous employee.employee_id

The result contains:

employee_id
employee_name
job_title
department
manager_id
hierarchy_level
hierarchy_path

15. Example Organization Tree

The sample data represents a hierarchy similar to:

Anil Sharma
├── Meera Rao
│   ├── Arjun Reddy
│   │   ├── Kiran Kumar
│   │   ├── Divya Patel
│   │   └── Rohit Das
│   └── Priya Nair
│       ├── Asha Menon
│       └── Varun Gupta
├── Vikram Singh
│   └── Rahul Verma
│       └── Pooja Shah
└── Neha Kapoor
    └── Sneha Iyer
        └── Manoj Rao

The recursive CTE can discover every level automatically.

16. Hierarchy Level

The project calculates:

hierarchy_level

The root begins at:

0

Direct reports are:

1

Their reports are:

2

and so on.

The recursive expression is:

hierarchy_level + 1

17. Hierarchy Path

A hierarchy path represents the complete route from the root to a node.

Example:

Anil Sharma
    ->
Meera Rao
    ->
Arjun Reddy
    ->
Kiran Kumar

The project creates these paths using:

CONCAT()

This is useful for reports and debugging.

18. Indented Tree

The project uses:

REPEAT()

to create indentation.

Conceptually:

CEO
    CTO
        Engineering Manager
            Software Engineer

The number of indentation levels comes from:

hierarchy_level

19. Descendants

Descendants are all nodes below a selected node.

For example:

Manager
├── Employee A
│   └── Employee B
└── Employee C

The descendants are:

Employee A
Employee B
Employee C

20. Finding Descendants

The recursive process is:

Start with direct children
        ↓
Find their children
        ↓
Find the next level
        ↓
Continue

This is useful for:

Organization reporting
Category expansion
Account hierarchies
Dependency trees

21. Ancestors

Ancestors are nodes above a selected node.

For example:

Employee
    ↑
Manager
    ↑
Director
    ↑
CEO

The employee's ancestors are:

Manager
Director
CEO

22. Upward Traversal

To move upward through an employee hierarchy, the recursive query follows:

employee
    ↓
manager_id
    ↓
manager.employee_id

This is the reverse direction of descendant traversal.

23. Management Chain

For an employee deep in an organization:

Employee
↑
Manager
↑
Senior Manager
↑
CTO
↑
CEO

The recursive CTE can retrieve the complete chain.

This is useful for:

Approval workflows
Organization charts
Reporting structures
Access-control analysis

24. Employee Path to CEO

A management path can be generated as:

Manoj Rao
    ->
Sneha Iyer
    ->
Neha Kapoor
    ->
Anil Sharma

This makes it easy to identify the reporting chain.

25. Hierarchy Level Counts

Recursive results can be aggregated.

For example:

Level 0 → number of employees
Level 1 → number of employees
Level 2 → number of employees
Level 3 → number of employees

This provides a high-level view of organization depth.

26. Finding a Specific Level

Once hierarchy levels have been calculated:

WHERE hierarchy_level = 2

can return only employees at that depth.

This is useful when building:

Management-level reports
Organization summaries
Tree visualizations

27. Leaf Nodes

A leaf node has no children.

In the employee hierarchy:

Employee
    ↓
No direct reports

The project identifies leaf employees using a LEFT JOIN.

Leaf detection is useful in:

Tree structures
Category systems
File systems
Organization analysis

28. Manager Detection

A manager is an employee whose ID appears in another employee's:

manager_id

The project demonstrates how to find all such managers using a self-join.

29. Direct Report Count

The project calculates:

manager
direct_report_count

This answers:

How many employees directly report to this manager?

This is different from the total number of descendants.

30. Direct Reports vs Descendants

Consider:

CEO
└── Manager
    └── Employee

The CEO has:

1 direct report

but:

2 total descendants

Recursive CTEs can calculate both concepts.

31. Counting Total Descendants

The project creates a recursive relationship between every employee and every employee below that employee.

Then it aggregates the result.

This allows questions such as:

How many people are under the CTO?

How many people are under an Engineering Manager?

Which manager has the largest organization?

32. Engineering Subtree

The project demonstrates starting a recursive query from a specific employee:

Meera Rao

instead of starting from the CEO.

This produces only the hierarchy under that selected node.

The same pattern can be used for:

Department trees
Regional trees
Category branches
Account branches

33. Hierarchical Salary Analysis

Recursive CTE results can be combined with aggregate functions.

The project calculates:

hierarchy_level
employee count
total salary
average salary

This demonstrates that recursive query results can be processed like normal relational data.

34. Category Hierarchy

The second major dataset is:

categories

with:

category_id
category_name
parent_category_id

The sample category tree is:

Electronics
├── Computers
│   ├── Laptops
│   │   ├── Gaming Laptops
│   │   └── Business Laptops
│   └── Desktops
├── Monitors
│   └── 4K Monitors
└── Accessories
    ├── Keyboards
    │   └── Mechanical Keyboards
    └── Mice

35. Category Tree Traversal

The same recursive CTE technique works for categories.

The anchor finds:

parent_category_id IS NULL

The recursive member finds:

child.parent_category_id
=
parent.category_id

This demonstrates that recursive CTEs are a general hierarchy technique.

36. Category Descendants

The project finds all categories below:

Computers

The result can include:

Laptops
Gaming Laptops
Business Laptops
Desktops

This pattern is common in e-commerce systems.

37. Category Ancestors

Starting from:

Gaming Laptops

the query can move upward:

Gaming Laptops
        ↑
Laptops
        ↑
Computers
        ↑
Electronics

This can be used to build category breadcrumbs.

38. Breadcrumbs

An e-commerce application might display:

Electronics
>
Computers
>
Laptops
>
Gaming Laptops

A recursive query can retrieve the hierarchy needed to construct this breadcrumb.

39. Recursive Number Generation

Recursive CTEs are not limited to trees.

The project generates:

1
2
3
...
20

using a recursive CTE.

The stopping condition is:

WHERE number < 20

40. Recursive Date Generation

The project also generates a sequence of dates:

2025-01-01
2025-01-02
2025-01-03
...
2025-01-15

This technique can be useful when creating calendar datasets.

41. Recursion Termination

A recursive query must be able to stop.

For generated numbers:

WHERE number < 20

is the stopping condition.

For a hierarchy, recursion normally stops when:

No child rows remain.

Without proper control, recursive queries can become expensive or hit the database recursion limit.

42. Depth Limiting

The project demonstrates:

WHERE et.level < 3

This limits the maximum hierarchy depth processed by the query.

Depth limiting is useful when:

Only a few levels are required
The hierarchy is very deep
You need predictable execution

43. Recursive CTE Performance

Recursive queries can become expensive for large datasets.

Important considerations include:

Indexes
Hierarchy depth
Number of nodes
Branching factor
Join conditions
Duplicate traversal
Cycles
Result size

44. Indexing Hierarchical Data

The project creates:

idx_employees_manager

on:

manager_id

and:

idx_categories_parent

on:

parent_category_id

These columns are important because recursive traversal repeatedly searches for children.

45. Why Index Parent References?

A recursive relationship commonly performs logic similar to:

child.manager_id = parent.employee_id

or:

child.parent_category_id = parent.category_id

Indexing the parent-reference column helps the database find matching child rows efficiently.

46. Self Join vs Recursive CTE

Self Join

Good when the number of levels is known.

Example:

Employee
  ↓
Manager

Recursive CTE

Better when the depth is variable.

Example:

Employee
 ↓
Manager
 ↓
Director
 ↓
VP
 ↓
CEO

Recursive CTEs avoid writing separate joins for every possible level.

47. Recursive CTE vs Stored Procedure

A stored procedure can implement loops and procedural logic.

A recursive CTE allows hierarchical traversal directly inside a SQL query.

For many hierarchy-reporting problems, the recursive CTE is concise and declarative.

48. Cycles

A valid hierarchy normally follows an acyclic structure.

A problematic relationship would be:

A
↓
B
↓
C
↓
A

This creates a cycle.

Applications that allow user-defined parent relationships should validate against cycles.

49. Hierarchy Data Quality

Useful validation rules include:

Parent should exist.
Root nodes should have NULL parent references.
Cycles should not exist.
Unexpected orphan nodes should be detected.
Hierarchy depth should be reasonable.

The foreign keys in this project prevent references to nonexistent parents.

50. Orphan Records

An orphan is a record whose expected parent does not exist.

For example:

Employee 20
manager_id = 999

when employee 999 does not exist.

The foreign key prevents this type of invalid reference.

51. Real-World Applications

Recursive CTEs can be used for:

Organization charts
Product categories
Folder structures
File systems
Bill of materials
Comment threads
Account hierarchies
Menu structures
Geographical regions
Dependency graphs

52. Data Engineering Connection

Hierarchical SQL is useful in data engineering because source systems frequently contain parent-child relationships.

A data pipeline may need to:

Extract source hierarchy
        ↓
Traverse hierarchy
        ↓
Calculate depth
        ↓
Build paths
        ↓
Flatten hierarchy
        ↓
Load analytical data

Recursive CTEs can perform the traversal step.

53. Analytics Connection

Once hierarchy data has been flattened, analysts can calculate:

Employees per manager
Total salary under manager
Category sizes
Number of descendants
Hierarchy depth
Management span

54. Core Recursive CTE Pattern

The most important pattern from Day 72 is:

WITH RECURSIVE hierarchy AS (

    -- Anchor
    SELECT ...
    FROM table
    WHERE parent_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT ...
    FROM table AS child
    JOIN hierarchy AS parent
        ON child.parent_id = parent.id
)
SELECT *
FROM hierarchy;

Learn this structure carefully.

It is the foundation for most recursive hierarchy queries.

55. Downward Traversal

Downward traversal follows:

Parent
  ↓
Child
  ↓
Grandchild
  ↓
Great-grandchild

Typical relationship:

child.parent_id = parent.id

This is used for:

Descendants
Organization trees
Category expansion

56. Upward Traversal

Upward traversal follows:

Child
  ↑
Parent
  ↑
Grandparent

This is used for:

Ancestors
Management chains
Category breadcrumbs

57. Path Construction

Paths can be constructed using:

CONCAT()

Example:

CONCAT(
    parent.path,
    ' -> ',
    child.name
)

Result:

CEO -> CTO -> Engineering Manager -> Engineer

58. Recursive CTE and Window Functions

Recursive results can also be combined with window functions.

For example, after generating a hierarchy, you can use:

ROW_NUMBER()
RANK()
DENSE_RANK()
LAG()
LEAD()

for further analysis.

The important concept is:

Recursive CTE
      ↓
Hierarchical result
      ↓
Analytical functions

59. MySQL Recursion Limit

MySQL controls recursive CTE depth through:

cte_max_recursion_depth

Very deep hierarchies can therefore require appropriate configuration.

A query should still have sensible termination logic.

60. Practical Exercise 1

Add:

employee_id = 16

and make the employee report to:

Kiran Kumar

Run the complete hierarchy query again.

Observe the new hierarchy level.

61. Practical Exercise 2

Find every descendant of:

Meera Rao

Then calculate:

total descendants

62. Practical Exercise 3

Find the complete management chain of:

Manoj Rao

The conceptual result should contain:

Manoj Rao
↑
Sneha Iyer
↑
Neha Kapoor
↑
Anil Sharma

63. Practical Exercise 4

Add:

Ultrawide Monitors

under:

Monitors

Then regenerate the category tree.

64. Practical Exercise 5

Generate:

1 → 100

using a recursive CTE.

Make sure the recursive query has a safe termination condition.

65. Practical Exercise 6

Generate every date in a month using:

WITH RECURSIVE

Then use the generated calendar as the source for another query.

66. Interview Questions

What is a CTE?

A Common Table Expression is a temporary named result set used within a SQL statement.

What is a recursive CTE?

A CTE that references itself to process recursive or hierarchical data.

What are the two main parts of a recursive CTE?

The:

Anchor member

and:

Recursive member

What is an anchor member?

The starting query that provides the initial rows.

What is the recursive member?

The query that uses the previous recursive result to find additional rows.

What is hierarchical data?

Data organized through parent-child relationships.

What is a root node?

A node without a parent.

What is a leaf node?

A node without children.

What are descendants?

All nodes below a selected node.

What are ancestors?

All nodes above a selected node.

Why index manager_id?

Because recursive traversal repeatedly searches for employees using the manager relationship.

What is a self-referencing foreign key?

A foreign key that references another row in the same table.

67. Common Mistakes

Mistake 1 — Missing the anchor

The recursive CTE needs a valid starting point.

Mistake 2 — Missing termination logic

Uncontrolled recursion can become expensive or exceed the configured recursion limit.

Mistake 3 — Joining in the wrong direction

The join determines whether the hierarchy is traversed upward or downward.

Mistake 4 — Ignoring cycles

Circular relationships can cause recursive processing problems.

Mistake 5 — Forgetting indexes

Large hierarchies may become slow without appropriate indexes.

Mistake 6 — Confusing direct reports with descendants

A direct report is one level away.

A descendant can be many levels away.

68. Day 71 vs Day 72

Day 71

Temporal Data
      ↓
History
      ↓
Versioning
      ↓
Point-in-Time Queries
      ↓
Auditing
      ↓
SCD Type 1
      ↓
SCD Type 2

Day 72

Recursive CTEs
      ↓
Parent-Child Relationships
      ↓
Hierarchy Traversal
      ↓
Ancestors
      ↓
Descendants
      ↓
Hierarchy Paths
      ↓
Tree Analytics

Day 72 introduces recursive and hierarchical SQL after working with temporal and historical data on Day 71.

69. Key Takeaways

1. Recursive CTEs are useful for hierarchical data.
2. A recursive CTE contains an anchor and recursive member.
3. The anchor defines where recursion begins.
4. The recursive member finds the next level.
5. Parent-child relationships can be traversed recursively.
6. manager_id can represent an employee hierarchy.
7. parent_category_id can represent a category hierarchy.
8. hierarchy_level represents tree depth.
9. hierarchy_path represents the route through a hierarchy.
10. Descendants are nodes below a selected node.
11. Ancestors are nodes above a selected node.
12. Leaf nodes have no children.
13. Root nodes have no parent.
14. Recursive CTEs can generate number sequences.
15. Recursive CTEs can generate date ranges.
16. Recursive queries need safe termination.
17. Deep recursion may require depth management.
18. Indexing parent-reference columns helps traversal.
19. Cycles should be prevented or handled.
20. Recursive SQL is useful in data engineering.
21. Recursive results can be aggregated.
22. Recursive results can be used for analytical reporting.
23. Hierarchy paths can be generated dynamically.
24. The same recursive pattern can work across different domains.

70. Completion Checklist

[ ] Created the recursive hierarchy database
[ ] Created employees table
[ ] Created self-referencing foreign key
[ ] Inserted employee hierarchy
[ ] Found root employees
[ ] Found direct reports
[ ] Built complete organization tree
[ ] Calculated hierarchy levels
[ ] Built hierarchy paths
[ ] Found descendants
[ ] Found ancestors
[ ] Built management chains
[ ] Found leaf employees
[ ] Found managers
[ ] Counted direct reports
[ ] Counted total descendants
[ ] Performed salary analysis by level
[ ] Created category hierarchy
[ ] Traversed category tree
[ ] Found category descendants
[ ] Found category ancestors
[ ] Generated number sequence
[ ] Generated date sequence
[ ] Practiced depth limiting
[ ] Reviewed recursive query performance
[ ] Reviewed hierarchy data quality

71. Final Lesson

The most important feature from Day 72 is:

WITH RECURSIVE

A hierarchy such as:

Parent
  ↓
Child
  ↓
Grandchild
  ↓
Great-grandchild

can be traversed without manually writing a separate query for every level.

The core pattern is:

WITH RECURSIVE hierarchy AS (

    SELECT ...
    FROM table
    WHERE parent_id IS NULL

    UNION ALL

    SELECT ...
    FROM table AS child
    JOIN hierarchy AS parent
        ON child.parent_id = parent.id
)
SELECT *
FROM hierarchy;

Once this pattern becomes familiar, many hierarchy-related SQL problems become significantly easier to solve.

72. Real-World Perspective

Recursive CTEs can answer practical questions such as:

Who reports directly to this manager?

Who indirectly reports to this manager?

Who manages this employee?

Who is above this employee?

Which categories exist under this category?

What is the breadcrumb path?

How deep is this hierarchy?

How many descendants does this node have?

Which manager has the largest organization?

What is the total salary under a manager?

These problems occur frequently in:

Enterprise applications
E-commerce platforms
ERP systems
CRM systems
Data warehouses
Analytics platforms
Data engineering pipelines

Day 72 therefore adds an important practical SQL skill:

Turning parent-child relationships
into queryable hierarchical structures.

73. Final Day 72 Summary

WITH RECURSIVE
       ↓
Start at an anchor
       ↓
Find related rows
       ↓
Repeat recursively
       ↓
Calculate levels
       ↓
Build paths
       ↓
Analyze the hierarchy

The key idea is:

SQL can traverse trees.

Instead of treating every hierarchy level as a separate query, recursive CTEs allow the database to repeatedly apply the same relationship until the hierarchy has been traversed.

This makes WITH RECURSIVE one of the most valuable SQL features for hierarchical data, reporting, analytics, and data engineering.