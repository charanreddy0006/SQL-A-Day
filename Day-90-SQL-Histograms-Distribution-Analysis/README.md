# Day 90 — SQL Histograms & Distribution Analysis

---

## 🎯 Overview

Totals and averages do not tell the whole story. A product catalog may contain many inexpensive products and a few premium products. Customer activity may also be concentrated among a small number of frequent buyers.

This MySQL project creates frequency tables, price histograms, value bands, quartile-like groups, monthly distributions, and an exploratory outlier check.

**Database:** MySQL 8.0+  
**Project:** `sql_distribution_lab`  
**Main file:** `day90.sql`

---

## 📚 Learning Objectives

- Profile values using `COUNT`, `MIN`, `MAX`, and `AVG`.
- Create business-friendly ranges with `CASE`.
- Build fixed-width histogram buckets with `FLOOR`.
- Analyze purchase-frequency distributions.
- Use `NTILE(4)` for quartile-like grouping.
- Understand the IQR outlier-screening rule.
- Compare monthly sales counts and revenue.
- Interpret buckets carefully and avoid conclusions from tiny samples.

---

## 🧠 Key Concepts

### Distribution
A distribution describes how values are spread. It helps answer questions such as whether most products are low-priced, whether a few sales dominate revenue, and how frequently customers purchase.

### Frequency table
A frequency table counts observations in each category or bucket.

### Histogram
A histogram groups numeric values into ranges and counts the values in each range. This SQL project produces bucket counts that can be plotted later in a dashboard or spreadsheet.

### Quartiles and `NTILE(4)`
Quartiles split ordered observations into four roughly equal-sized groups. `NTILE(4)` assigns rows to four groups based on the specified ordering. With a small dataset, these are approximate groups, not necessarily the same as a statistical percentile calculation with interpolation.

### IQR outlier screening
The interquartile range is `Q3 - Q1`. A common exploratory rule flags values below `Q1 - 1.5 × IQR` or above `Q3 + 1.5 × IQR`. It is a screening heuristic, not proof that a value is erroneous.

---

## 🗂️ Project Structure

```text
Day-90-SQL-Histograms-Distribution-Analysis/
├── day90.sql
└── README.md
```

---

## 🛠️ Run the Project

1. Start MySQL 8.0 or later.
2. Open `day90.sql` in MySQL Workbench or VS Code.
3. Execute the script from top to bottom.
4. Inspect the histogram, quartile, outlier, and monthly-sales result sets.

The dataset is synthetic and intentionally small so you can inspect each result easily.

---

## 1. Profile Before Bucketing

Start by checking the count, minimum, maximum, and average. These metrics help you choose useful bucket boundaries. An average alone may hide skew or rare high values.

---

## 2. Create Business-Friendly Bands

The `CASE` query groups prices into readable ranges such as `Under 1K`, `1K-4,999`, and `15K and above`.

Use boundaries that make sense for the business question. Arbitrary ranges can hide important patterns.

---

## 3. Build a Fixed-Width Histogram

The expression `FLOOR(list_price / 10000)` assigns each price to a bucket of width 10,000.

Narrow buckets reveal more detail but can look noisy. Wider buckets are simpler but may hide variation. The SQL also creates a readable range label for each bucket.

---

## 4. Analyze Sale-Value Distribution

The script calculates net sale value as:

`quantity × unit_price × (1 - discount_pct / 100)`

It then groups sale values into small, medium, large, and very-large bands. This helps explore transaction sizes and whether high-value sales are unusual.

---

## 5. Customer Purchase-Frequency Distribution

The customer-frequency query uses a `LEFT JOIN`, so customers with zero purchases remain in the result. An inner join would exclude those customers and could distort the overall distribution.

---

## 6. Quartile-Like Groups

`NTILE(4) OVER (ORDER BY list_price)` assigns products to four groups. The summary query reports each group's minimum and maximum price.

`NTILE` makes groups with roughly equal row counts; the value ranges can differ significantly. For rigorous statistical work, define and validate the percentile method required by the analysis.

---

## 7. Outlier Screening

The script uses approximate first- and third-quartile boundaries from the `NTILE(4)` groups and applies the IQR rule.

Because the sample contains only ten products, treat this as a learning demonstration. In real analysis, use a representative dataset and investigate flagged values instead of automatically deleting them.

---

## 8. Monthly Sales Distribution

The monthly summary groups transactions by year and month, reporting both sale count and net revenue. This is useful for exploring changes in transaction volume and revenue over time.

---

## 🌍 Real-World Applications

- Product pricing and transaction-size analysis.
- Customer segmentation by activity frequency.
- Inventory and product portfolio analysis.
- Exploratory data analysis before dashboard development.
- Finding unusual numeric values for investigation.
- Preparing distribution metrics for business intelligence.

---

## ⚠️ Common Mistakes

1. Choosing bucket boundaries without checking the data range.
2. Using bucket widths that hide useful patterns.
3. Treating an outlier as an error without investigation.
4. Excluding zero-activity customers from frequency analysis.
5. Treating `NTILE(4)` as an exact statistical percentile.
6. Drawing broad conclusions from a small sample.
7. Confusing transaction counts with unique-customer counts.

---

## 🧪 Practice Questions

1. Create quantity bands for sales.
2. Build a histogram of customer signup months.
3. Compare price bands across product categories.
4. Find products assigned to the highest quartile group.
5. Explain how bucket width changes the histogram.
6. Compare monthly sale counts with monthly revenue.
7. Explain why `NTILE(4)` may differ from a percentile calculation.
8. Discuss why an outlier needs investigation rather than automatic deletion.

---

## 🎤 Interview Questions

**1. What is a histogram?**  
A distribution summary that groups numeric values into ranges and counts the observations in each range.

**2. Why analyze distributions instead of only averages?**  
Averages can hide skew, outliers, and clusters.

**3. How can SQL create histogram buckets?**  
Use an expression such as `FLOOR(value / bucket_width)` and group by the bucket.

**4. What does `NTILE(4)` do?**  
It assigns ordered rows to four groups that are as evenly sized as possible.

**5. What is the IQR rule?**  
A common screening rule flags values outside `Q1 - 1.5 × IQR` and `Q3 + 1.5 × IQR`.

**6. Does an outlier always mean bad data?**  
No. It may be a valid rare event, a data issue, or a meaningful business signal.

**7. Why include customers with zero purchases?**  
They are part of the customer population and matter when describing overall purchase frequency.

---

## ✅ Key Takeaways

- Profile values before choosing bucket boundaries.
- Use `CASE` for business-friendly bands and `FLOOR` for fixed-width buckets.
- Use `NTILE(4)` for convenient quartile-like grouping.
- Treat IQR outliers as candidates for investigation.
- Define whether a metric counts rows, transactions, or customers.
- Small samples help learning but do not support strong general conclusions.

---

## 📁 GitHub Commit

```bash
git add .
git commit -m "Day 90 - SQL Histograms Distribution Analysis"
git push
```

**Repository folder:** `Day-90-SQL-Histograms-Distribution-Analysis`

Day 90 completed — keep your SQL-A-Day journey moving! 🚀
