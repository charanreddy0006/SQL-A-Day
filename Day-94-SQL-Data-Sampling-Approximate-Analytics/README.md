# Day 94 — SQL Data Sampling & Approximate Analytics

**Today's goal:** Estimate population metrics from a carefully selected subset of rows, while understanding what the estimate can and cannot tell you.

## Why this matters

A representative sample can answer exploratory questions faster than scanning a very large table. Sampling is not simply taking the first few rows: selection bias and uncertainty matter. This project creates a repeatable sample, estimates an average and population total, calculates an approximate confidence interval, compares with exact results, and explores stratification.

## What you'll learn

1. Population versus sample and defining eligible rows.
2. Deterministic hash sampling with `CRC32()` and a stable key.
3. Expansion estimates for population totals.
4. Standard error, a 95% interval, and finite population correction.
5. Stratified sampling and weighted averages.
6. Why estimates must be labeled and validated.

## MySQL compatibility

Examples target **MySQL 8.0+**. MySQL has no general `SELECT ... TABLESAMPLE` clause. The script uses `CRC32()` on a stable row key with a modulo filter for repeatability. `CRC32()` is a checksum, not a cryptographic or formal statistical hash; validate its distribution against your chosen data. For a small table, `ORDER BY RAND() LIMIT n` is easy to understand, but can require random evaluation and sorting across many rows, so it is not suitable for very large tables.

## Project files

| File | Description |
|---|---|
| `day94.sql` | Self-contained schema, generated dataset, and guided queries |
| `README.md` | Concepts, interpretation, practice, and interview questions |

## Run it

1. Open MySQL Workbench or another MySQL 8.0+ client.
2. Run `day94.sql` from top to bottom.
3. Compare sample estimates with exact metrics at the end.
4. Try 5% and 20% sample thresholds.

The script creates `sql_sampling_day94` and drops/recreates only its own `orders` and `order_sample` tables.

## Sampling workflow

```text
Define eligible population → select stable key and rate → create sample → estimate with uncertainty → compare and inspect bias
```

### Repeatable sampling

```sql
MOD(CRC32(CAST(order_id AS CHAR)), 100) < 10
```

The expression maps each key to one of 100 buckets and selects 10, for an approximately 10% sample. The same key is selected every run. Use a unique, stable key and check for correlation with data patterns. A fixed salt such as `CONCAT('experiment-2:', order_id)` can create a second repeatable sample.

### Estimate totals

For an equal-probability sample with inclusion fraction `p`:

```text
estimated population total = sample total / p
```

A 10% sample sum multiplied by 10 estimates the population sum. It is not an exact accounting total.

### Estimate mean and uncertainty

For simple random sampling without replacement, an approximate standard error is:

```text
SE(mean) = sample standard deviation / SQRT(sample size)
           * SQRT((population size - sample size) / (population size - 1))
```

The second factor is the finite population correction. The script uses `mean ± 1.96 × SE` as an approximate 95% interval. This normal approximation can be weak for tiny samples, highly skewed data, clustered rows, or unequal inclusion probabilities.

### Stratified sampling

If a group is rare, a simple sample may not include enough members to analyze it. Selecting within segments ensures representation. To combine segment means into a population-wide estimate, weight each mean by its population count; do not average segment means unless groups are equal in size or that is the intended metric.

## What to look for

- The sample size should be near, but not necessarily exactly, 10%.
- Estimated revenue should be near the exact total, but need not match.
- A single sample may miss its approximate interval.
- Segment estimates can vary more when few rows were sampled.
- A larger sample usually reduces uncertainty.

## Common mistakes

- Taking the first N rows and assuming they represent the population.
- Treating `ORDER BY RAND()` as cheap at scale.
- Sampling with an unstable or non-unique key.
- Ignoring key correlation or eligibility filters.
- Calling an estimate exact or replacing exact financial reporting with it.
- Combining strata without population weights.
- Treating a confidence interval as a guarantee.

## Practice challenges

1. Change the threshold from 10 to 5 buckets. How do sample size and standard error change?
2. Use a different fixed salt and compare estimated revenue.
3. Add a `region` column and compare simple versus stratified samples.
4. Estimate the count of orders over 1,000 from the sample proportion, then compare to exact.
5. Sample one month. What if IDs were assigned chronologically?
6. Research inverse-probability (Horvitz–Thompson) weighting for unequal selection probabilities.

## Interview questions

1. What is the difference between a population and a sample?
2. Why can taking the first 1,000 rows cause selection bias?
3. Why are deterministic samples useful for debugging?
4. How do you estimate a population total from an equal-probability sample?
5. What assumptions affect a confidence interval?
6. When is stratified sampling preferable?
7. Why is `ORDER BY RAND()` often costly?
8. Why shouldn't approximate totals replace exact financial totals?

## GitHub commit for Day 94

Extract the ZIP into your `SQL-A-Day` repository and run from its root:

```bash
git add Day-94-SQL-Data-Sampling-Approximate-Analytics
git commit -m "Day 94 - SQL Data Sampling and Approximate Analytics"
git push
```

## Further reading

- [MySQL 8.0 Mathematical Functions (`CRC32()` and `RAND()`)](https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html)
- [MySQL 8.0 Aggregate Functions (`STDDEV_SAMP()`)](https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions-and-modifiers.html)
- [MySQL 8.0 Function Call Optimization (`RAND()` evaluation)](https://dev.mysql.com/doc/refman/8.0/en/function-optimization.html)

**Day 94 complete — turn a carefully designed sample into a transparent, repeatable estimate.**
