Day 79 — MySQL Full-Text Search & Relevance Ranking

📌 Overview

Welcome to Day 79 of my SQL-A-Day journey 🚀

Today I am learning MySQL Full-Text Search, a powerful SQL feature for searching text using:

FULLTEXT indexes

MATCH()

AGAINST()

Natural-language search

Boolean search

Relevance scores

Phrase search

Prefix search

Search result ranking

Instead of treating text search as a simple substring problem, Full-Text Search provides database-level functionality designed for word-oriented searches.

🎯 Learning Goals

By the end of Day 79, I should understand:

What Full-Text Search is.

Why FULLTEXT indexes are useful.

How MATCH() works.

How AGAINST() works.

Natural-language search.

Boolean search.

Required and excluded terms.

Phrase searching.

Prefix searching.

Relevance ranking.

Combining text search with normal SQL filters.

Building a simple article/product search.

When a dedicated search engine may be more appropriate.

1. What is Full-Text Search?

Full-Text Search is a MySQL feature designed to search words and phrases inside text columns.

A normal SQL query might use:

WHERE content LIKE '%data%'

Full-Text Search uses:

MATCH(title, content)
AGAINST('data engineering')

The second approach is specifically designed for text-search workloads and can provide a relevance score.

2. Why Use Full-Text Search?

Suppose we have thousands or millions of articles.

A user enters:

data engineering

A useful search system should be able to:

Search
  ↓
Find matching documents
  ↓
Calculate relevance
  ↓
Rank results
  ↓
Return the best results

MySQL Full-Text Search provides many of these capabilities directly inside the database.

3. Today's Database

The SQL script creates:

mysql_fulltext_search_lab

The main table is:

articles

Columns:

article_id
title
content
category
author
published_at
is_published

The searchable columns are:

title
content

4. Creating a FULLTEXT Index

The table contains:

FULLTEXT INDEX ft_articles_title_content
    (title, content)

This creates a Full-Text index for the title and content.

The search can then use:

MATCH(title, content)
AGAINST('data engineering')

For indexed full-text searching, the columns in MATCH() should correspond to the columns covered by the appropriate FULLTEXT index.

5. MATCH()

MATCH() specifies the text columns that should be searched.

Example:

MATCH(title, content)

It tells MySQL:

Search the title and content fields.

6. AGAINST()

AGAINST() specifies the search expression.

Example:

AGAINST('data engineering')

Together:

MATCH(title, content)
AGAINST('data engineering')

means:

Search the title and content for the supplied search terms.

7. Basic Full-Text Search

Example:

SELECT
    article_id,
    title,
    category
FROM articles
WHERE MATCH(title, content)
      AGAINST('data engineering');

This returns articles that match the search expression.

8. Relevance Ranking ⭐

One of the most useful features is obtaining a relevance score.

SELECT
    article_id,
    title,
    MATCH(title, content)
        AGAINST('data engineering') AS relevance
FROM articles
WHERE MATCH(title, content)
      AGAINST('data engineering')
ORDER BY relevance DESC;

The score can be used to rank the search results.

Conceptually:

Higher relevance
       ↓
Better match
       ↓
Lower relevance

For an application, this can be used to put stronger matches at the top.

9. Natural-Language Mode

MySQL supports natural-language full-text searching.

Example:

MATCH(title, content)
AGAINST(
    'data engineering'
    IN NATURAL LANGUAGE MODE
)

Complete query:

SELECT
    article_id,
    title,
    MATCH(title, content)
        AGAINST(
            'data engineering'
            IN NATURAL LANGUAGE MODE
        ) AS relevance
FROM articles
WHERE MATCH(title, content)
      AGAINST(
          'data engineering'
          IN NATURAL LANGUAGE MODE
      )
ORDER BY relevance DESC;

Natural-language mode is useful when we want MySQL's relevance-based text-search behavior.

10. Boolean Full-Text Search

Boolean mode gives us more explicit control over the search.

Example:

MATCH(title, content)
AGAINST('+data +pipeline' IN BOOLEAN MODE)

This requires both terms.

data      → required
pipeline  → required

11. Required Terms with +

In Boolean mode:

+data

means the term is required.

Example:

AGAINST('+data +pipeline' IN BOOLEAN MODE)

Conceptually:

data AND pipeline

12. Excluding Terms with -

Boolean mode can exclude a term.

Example:

AGAINST('+data -machine' IN BOOLEAN MODE)

Conceptually:

data must exist
machine must not exist

This is useful when an application needs more precise filtering.

13. Exact Phrase Search

A phrase can be searched using double quotes in Boolean mode:

AGAINST('"data engineering"' IN BOOLEAN MODE)

This searches for the phrase:

data engineering

rather than simply treating the words as unrelated search terms.

14. Prefix Search

Boolean mode supports prefix searching with *.

Example:

AGAINST('engin*' IN BOOLEAN MODE)

This can match words beginning with the specified prefix.

Prefix searching can be useful for some search-box and autocomplete-style scenarios.

15. Full-Text Search + Category Filter

Full-text search can be combined with ordinary SQL conditions.

Example:

SELECT
    article_id,
    title,
    category,
    MATCH(title, content)
        AGAINST('data pipeline') AS relevance
FROM articles
WHERE category = 'Data Engineering'
  AND MATCH(title, content)
      AGAINST('data pipeline')
ORDER BY relevance DESC;

This combines:

Text search
+
Category filtering
+
Relevance ranking

16. Full-Text Search + Date Filter

We can also filter by date:

SELECT
    article_id,
    title,
    published_at,
    MATCH(title, content)
        AGAINST('data') AS relevance
FROM articles
WHERE published_at >= '2026-08-15'
  AND MATCH(title, content)
      AGAINST('data')
ORDER BY relevance DESC;

This is useful for applications where search results should also respect a time period.

17. Product Search Example 🛒

The project also contains a:

products

table.

Example products include:

Data Engineering Laptop
SQL Developer Keyboard
Cloud Computing Laptop
Data Analytics Monitor
Python Programming Book

The product name and description have a FULLTEXT index.

We can search them using:

SELECT
    product_id,
    product_name,
    price,
    MATCH(product_name, description)
        AGAINST('data engineering') AS relevance
FROM products
WHERE MATCH(product_name, description)
      AGAINST('data engineering')
ORDER BY relevance DESC;

This creates a simple database-powered product search.

18. Product Search + Price

We can combine search relevance with business rules:

SELECT
    product_id,
    product_name,
    price,
    MATCH(product_name, description)
        AGAINST('programming') AS relevance
FROM products
WHERE price < 90000
  AND MATCH(product_name, description)
      AGAINST('programming')
ORDER BY relevance DESC, price ASC;

Now the result considers both:

Search relevance
+
Price

19. Building an Application Search Query

Imagine a website has a search box.

The user searches:

cloud data

The backend can run:

SELECT
    article_id,
    title,
    category,
    author,
    published_at,
    MATCH(title, content)
        AGAINST('cloud data') AS relevance
FROM articles
WHERE is_published = TRUE
  AND MATCH(title, content)
      AGAINST('cloud data')
ORDER BY relevance DESC,
         published_at DESC
LIMIT 10;

The application receives the top 10 matching articles.

The architecture looks like:

User
  ↓
Search Box
  ↓
Backend
  ↓
MySQL FULLTEXT
  ↓
Relevance Ranking
  ↓
Top Results

20. FULLTEXT vs LIKE

Feature

LIKE

FULLTEXT

Simple substring matching

✅

Not the main purpose

Word-oriented search

Limited

✅

Relevance ranking

❌

✅

Boolean operators

❌

✅

Phrase search

Limited

✅

Prefix search

Pattern-based

✅ in Boolean mode

Specialized text-search index

❌

✅

Example:

WHERE content LIKE '%pipeline%'

versus:

WHERE MATCH(title, content)
      AGAINST('pipeline');

They solve different problems.

21. FULLTEXT Search Modes

Two important modes used in today's project are:

Natural Language

IN NATURAL LANGUAGE MODE

Useful for relevance-oriented natural-language searching.

Boolean

IN BOOLEAN MODE

Useful when the query needs operators such as:

+
-
*
"phrase"

22. Useful Boolean Syntax

Syntax

Meaning

+word

Word is required

-word

Word is excluded

"phrase"

Search a phrase

word*

Prefix search

Examples:

+data

-data

"data engineering"

engin*

23. Title-Only Search

The project also demonstrates a separate FULLTEXT index on:

title

Then we can search only titles:

SELECT
    article_id,
    title,
    MATCH(title) AGAINST('data') AS title_relevance
FROM articles
WHERE MATCH(title) AGAINST('data')
ORDER BY title_relevance DESC;

This is useful when title matches need to be searched independently.

24. Checking FULLTEXT Indexes

Use:

SHOW INDEX FROM articles;

This allows us to inspect the indexes created on the table.

25. EXPLAIN and Full-Text Search

Today's SQL also connects Full-Text Search with query analysis:

EXPLAIN
SELECT
    article_id,
    title
FROM articles
WHERE MATCH(title, content)
      AGAINST('data pipeline');

This is useful when investigating how MySQL executes the search query.

Performance should always be tested with realistic data volumes.

26. Data Engineering Connection 🚀

Full-Text Search can be useful in data platforms that contain large amounts of text.

Documentation

Search technical documentation

Support Tickets

Find tickets mentioning a problem

Knowledge Bases

Search articles and guides

Product Catalogs

Search product descriptions

Internal Applications

Search reports, documents, and records

27. When Should We Use a Dedicated Search Engine?

MySQL Full-Text Search can be a very good choice for many applications.

However, a dedicated search platform may be more appropriate when the system requires advanced capabilities such as:

Large distributed search infrastructure

Fuzzy matching

Advanced linguistic processing

Sophisticated ranking

Advanced autocomplete

Large-scale faceting

The engineering principle is:

Use the simplest search technology that satisfies the application's requirements.

28. Common Mistakes ⚠️

Mistake 1 — Forgetting the FULLTEXT index

Make sure the appropriate text columns have a FULLTEXT index.

Mistake 2 — Treating FULLTEXT like LIKE

These are different:

LIKE '%data%'

and:

MATCH(title, content)
AGAINST('data')

Mistake 3 — Forgetting Boolean mode

If you use Boolean operators such as:

+
-
*

use:

IN BOOLEAN MODE

when appropriate.

Mistake 4 — Ignoring relevance

If relevance is selected, it can be used for ranking:

ORDER BY relevance DESC;

Mistake 5 — Testing only tiny datasets

A search query that works well on 10 rows should still be tested against realistic production-scale data.

29. Practice Queries 🧠

Try solving these before looking at the SQL file.

Easy

Search articles for Python.

Search articles for data.

Return article titles and relevance for pipeline.

Search products for cloud.

Display the FULLTEXT indexes on articles.

Medium

Find articles containing both data and pipeline.

Find articles containing data but excluding machine.

Search for the exact phrase data engineering.

Search using the prefix engin*.

Search products for programming and order by relevance.

Advanced

Return only published articles matching a search.

Combine search relevance with a category filter.

Combine search relevance with a date filter.

Return only the top 5 results.

Build a product-search query combining relevance and price.

30. Interview Questions 🎯

Q1. What is MySQL Full-Text Search?

It is a MySQL feature designed for searching text columns using FULLTEXT indexes and MATCH() ... AGAINST().

Q2. What is the difference between LIKE and FULLTEXT?

LIKE performs pattern matching, while FULLTEXT provides specialized word-oriented text searching with features such as relevance ranking and Boolean search.

Q3. What does MATCH() do?

It specifies the text columns that should be searched.

Q4. What does AGAINST() do?

It specifies the search expression and optional search mode.

Q5. What is relevance?

Relevance is a score produced by the full-text search that can be used to rank matching rows.

Q6. What is Boolean Full-Text Search?

It allows search operators such as:

+
-
*
"phrase"

to control matching.

Q7. What does +data mean?

It makes data a required search term in Boolean mode.

Q8. What does -machine mean?

It excludes rows containing the specified term in Boolean full-text search.

Q9. What is a FULLTEXT index?

It is a specialized MySQL index used to support full-text searching of text columns.

Q10. Can FULLTEXT search multiple columns?

Yes.

For example:

MATCH(title, content)
AGAINST('data engineering');

31. Project Structure

Day-79-MySQL-Full-Text-Search/
│
├── day79.sql
└── README.md

32. How to Run

Make sure you are using MySQL 8+.

Open:

day79.sql

in VS Code or MySQL Workbench.

You can also execute it using:

SOURCE path/to/day79.sql;

The script creates:

mysql_fulltext_search_lab

and inserts the sample articles and products.

33. GitHub Progress

Day 77 → SQL JSON Data & JSON Querying
Day 78 → SQL Recursive CTEs & Hierarchical Data
Day 79 → MySQL Full-Text Search & Relevance Ranking

🔥 The SQL-A-Day journey continues!

34. Git Commands

Add the Day 79 folder:

git add .

Commit:

git commit -m "Day 79 - MySQL Full-Text Search"

Push:

git push

Commit Message

Day 79 - MySQL Full-Text Search

35. Summary

Today I learned how to implement database-level text searching with MySQL.

Key concepts:

FULLTEXT indexes

MATCH()

AGAINST()

Natural-language search

Boolean search

Required terms

Excluded terms

Phrase searching

Prefix searching

Relevance ranking

Search result ordering

Combining text search with SQL filters

Article search

Product search

Search performance

When to consider dedicated search systems

The most important pattern is:

SELECT
    title,
    MATCH(title, content)
        AGAINST('data pipeline') AS relevance
FROM articles
WHERE MATCH(title, content)
      AGAINST('data pipeline')
ORDER BY relevance DESC;

This gives us a simple relevance-ranked search system directly inside MySQL.

🚀 Day 79 Complete!