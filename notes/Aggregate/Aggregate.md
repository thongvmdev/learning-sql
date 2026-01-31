# SQL Aggregate Functions > A Complete Guide

## Introduction

Aggregate functions are powerful SQL tools that allow you to perform calculations on sets of rows and return a single result. They're essential for data analysis, reporting, and gaining insights from your database. In this guide, we'll explore the most commonly used aggregate functions and how to leverage them effectively.

## Table of Contents

- [COUNT Function](#count-function)
- [MIN and MAX Functions](#min-and-max-functions)
- [SUM Function](#sum-function)
- [AVG Function](#avg-function)
- [GROUP BY Clause](#group-by-clause)
- [HAVING Clause](#having-clause)
- [Practical Examples](#practical-examples)

---

## COUNT Function

The `COUNT()` function returns the number of rows that match a specified criterion.

### Basic Syntax

```sql
COUNT(*)        -- Counts all rows including NULL values
COUNT(column)   -- Counts non-NULL values in a column
COUNT(DISTINCT column)  -- Counts unique non-NULL values
```

### Examples

**Count all records:**

```sql
SELECT COUNT(*) FROM books;
```

**Count non-NULL values:**

```sql
SELECT COUNT(author_fname) FROM books;
```

**Count unique values:**

```sql
SELECT COUNT(DISTINCT author_fname) FROM books;
```

**Count with conditions:**

```sql
SELECT COUNT(*) FROM books WHERE title LIKE '%the%';
```

### Key Points

- `COUNT(*)` includes NULL values
- `COUNT(column)` excludes NULL values
- Use `DISTINCT` to count unique values only
- Can be combined with WHERE clause for conditional counting

---

## MIN and MAX Functions

These functions return the minimum and maximum values from a column.

### Basic Syntax

```sql
MIN(column)  -- Returns the smallest value
MAX(column)  -- Returns the largest value
```

### Examples

**Find minimum and maximum:**

```sql
SELECT MIN(released_year) FROM books;
SELECT MAX(pages) FROM books;
```

**Combine multiple aggregates:**

```sql
SELECT
    MIN(released_year) AS earliest,
    MAX(released_year) AS latest
FROM books;
```

**MIN/MAX with strings:**

```sql
SELECT MIN(author_fname) FROM books;  -- Returns alphabetically first
SELECT MAX(title) FROM books;         -- Returns alphabetically last
```

### Key Points

- Works with numeric, date, and string data types
- For strings, uses alphabetical ordering
- Returns NULL if no rows match the condition
- Cannot be used directly with WHERE to filter the result (use subqueries instead)

---

## SUM Function

The `SUM()` function calculates the total sum of a numeric column.

### Basic Syntax

```sql
SUM(column)  -- Returns the sum of all values in the column
```

### Examples

**Calculate total:**

```sql
SELECT SUM(pages) FROM books;
```

**Sum with conditions:**

```sql
SELECT SUM(pages)
FROM books
WHERE author_lname = 'Gaiman';
```

**Sum with calculations:**

```sql
SELECT SUM(quantity * price) AS total_revenue
FROM order_items;
```

### Key Points

- Only works with numeric columns
- Ignores NULL values
- Can perform calculations within SUM()
- Returns NULL if no rows match

---

## AVG Function

The `AVG()` function calculates the average value of a numeric column.

### Basic Syntax

```sql
AVG(column)  -- Returns the average of all non-NULL values
```

### Examples

**Calculate average:**

```sql
SELECT AVG(pages) FROM books;
```

**Average with grouping:**

```sql
SELECT
    author_lname,
    AVG(pages) AS avg_pages
FROM books
GROUP BY author_lname;
```

**Rounded average:**

```sql
SELECT ROUND(AVG(pages), 2) AS avg_pages
FROM books;
```

### Key Points

- Only works with numeric data
- Automatically excludes NULL values from calculation
- Use `ROUND()` to control decimal places
- Can be combined with other aggregate functions

---

## GROUP BY Clause

The `GROUP BY` clause groups rows that have the same values into summary rows. It's typically used with aggregate functions.

### Basic Syntax

```sql
SELECT column1, AGGREGATE_FUNCTION(column2)
FROM table
GROUP BY column1;
```

### Examples

**Group by single column:**

```sql
SELECT
    author_lname,
    COUNT(*) AS books_written
    -- SUM(pages) AS total_pages,      -- sums pages column
    -- AVG(pages) AS avg_pages,        -- averages pages column
    -- MIN(released_year) AS first_book,
    -- MAX(released_year) AS latest_book
FROM books
GROUP BY author_lname;
```

| author_lname | books_written | total_pages | avg_pages | first_book | latest_book |
| ------------ | ------------- | ----------- | --------- | ---------- | ----------- |
| Lahiri       | 2             | 489         | 244.5     | 1996       | 2003        |
| Gaiman       | 3             | 1025        | 341.67    | 2001       | 2017        |

**Group by multiple columns:**

```sql
SELECT
    author_fname,
    author_lname,
    COUNT(*) AS books_count
FROM books
GROUP BY author_fname, author_lname;
```

**Complex grouping with multiple aggregates:**

```sql
SELECT
    author_lname,
    COUNT(*) AS books_written,
    MIN(released_year) AS first_book,
    MAX(released_year) AS latest_book,
    AVG(pages) AS avg_pages
FROM books
GROUP BY author_lname;
```

**Group with calculated fields:**

```sql
SELECT
    released_year,
    COUNT(*) AS books_count,
    AVG(pages) AS avg_pages
FROM books
GROUP BY released_year
ORDER BY released_year;
```

### Key Points

- All non-aggregated columns in SELECT must be in GROUP BY
- Multiple columns can be grouped together
- The order of columns in GROUP BY can affect performance
- Use meaningful column aliases for better readability

---

## HAVING Clause

The `HAVING` clause filters groups after aggregation. It's like WHERE but for grouped data.

### HAVING vs WHERE

- **WHERE**: Filters rows BEFORE grouping
- **HAVING**: Filters groups AFTER aggregation

### Basic Syntax

```sql
SELECT column1, AGGREGATE_FUNCTION(column2)
FROM table
GROUP BY column1
HAVING AGGREGATE_FUNCTION(column2) condition;
```

### Examples

**Filter groups by count:**

```sql
SELECT
    author_lname,
    COUNT(*) AS books_count
FROM books
GROUP BY author_lname
HAVING COUNT(*) > 1;
```

**Execution flow:**

1. FROM books: Scan the books table
2. GROUP BY author_lname: Group rows by last name (creates one group per unique author_lname)
3. COUNT(\*) AS books_count: Count rows in each group
4. HAVING COUNT(\*) > 1: Filter groups - only keep groups with count > 1
5. SELECT: Return author_lname and books_count for remaining groups

Result: Only authors who have written MORE than 1 book are returned.
Authors with exactly 1 book (or 0 books) are excluded.

**Filter by average:**

```sql
SELECT
    author_lname,
    AVG(pages) AS avg_pages
FROM books
GROUP BY author_lname
HAVING AVG(pages) > 200;
```

**Combining WHERE and HAVING:**

```sql
SELECT
    author_lname,
    COUNT(*) AS books_count,
    AVG(pages) AS avg_pages
FROM books
WHERE released_year > 2000
GROUP BY author_lname
HAVING COUNT(*) >= 2;
```

**Execution flow (SQL logical order):**

1. FROM books: Scan/read from books table
2. WHERE released_year > 1995: Filter individual rows BEFORE grouping
   (Only books released after 1995 are considered)
3. GROUP BY author_lname: Group filtered rows by last name
   - Creates one group per unique author_lname
   - Calculates COUNT(\*) and AVG(pages) for each group
4. HAVING COUNT(\*) >= 2: Filter groups AFTER aggregation
   (Only keep groups with 2+ books)
5. SELECT: Return author_lname, books_count, avg_pages for remaining groups

Result: Authors who have written 2+ books released after 1995.
Note: WHERE filters rows, HAVING filters groups.

### Key Points

- HAVING must be used with GROUP BY
- Can use aggregate functions in HAVING clause
- WHERE filters before grouping, HAVING filters after
- HAVING is executed after GROUP BY

---

## Practical Examples

### Example 1: Sales Analysis

```sql
SELECT
    product_category,
    COUNT(*) AS total_orders,
    SUM(quantity) AS total_units_sold,
    ROUND(AVG(price), 2) AS avg_price,
    SUM(quantity * price) AS total_revenue
FROM orders
WHERE order_date >= '2023-01-01'
GROUP BY product_category
HAVING SUM(quantity * price) > 10000
ORDER BY total_revenue DESC;
```

### Example 2: Student Performance

**Scenario:** You're a teacher who needs to generate a report card showing each student's average grade and their pass/fail status. Even students who haven't submitted any papers should appear in the report.

**The Challenge:**

- Some students might not have submitted any papers yet (NULL grades)
- We need to calculate averages and determine passing status
- The report should be sorted by performance

**The Solution:**

```sql
SELECT
    students.first_name,
    IFNULL(AVG(grade), 0) AS average,
    CASE
        WHEN AVG(grade) >= 75 THEN 'PASSING'
        ELSE 'FAILING'
    END AS status
FROM students
LEFT JOIN papers ON students.id = papers.student_id
GROUP BY students.id, students.first_name
ORDER BY average DESC;
```

**Breaking It Down:**

1. **`LEFT JOIN`** - Ensures all students appear in results, even those without submissions
2. **`IFNULL(AVG(grade), 0)`** - Replaces NULL averages with 0 for students with no papers
3. **`CASE` Statement** - Assigns pass/fail status based on a 75% threshold
4. **`GROUP BY students.id, students.first_name`** - Aggregates grades per student
5. **`ORDER BY average DESC`** - Ranks students from highest to lowest performance

**Key Takeaway:** This pattern combines multiple SQL concepts to handle real-world edge cases—students without grades are included with a 0 average rather than being excluded from the report.

### Example 3: Author Statistics

```sql
SELECT
    CONCAT(author_fname, ' ', author_lname) AS author,
    COUNT(*) AS books_written,
    MIN(released_year) AS first_publication,
    MAX(released_year) AS latest_publication,
    MAX(pages) AS longest_book,
    ROUND(AVG(pages), 0) AS avg_pages
FROM books
GROUP BY author_fname, author_lname
HAVING books_written > 1
ORDER BY books_written DESC;
```

### Example 4: Yearly Summary

```sql
SELECT
    released_year AS year,
    COUNT(*) AS '# of books',
    AVG(pages) AS 'avg pages'
FROM books
GROUP BY released_year
ORDER BY released_year DESC;
```

---

## Best Practices

### 1. Always Use Meaningful Aliases

```sql
-- Good
SELECT COUNT(*) AS total_books FROM books;

-- Avoid
SELECT COUNT(*) FROM books;
```

### 2. Handle NULL Values

```sql
-- Use IFNULL or COALESCE to handle NULL values
SELECT
    first_name,
    IFNULL(AVG(grade), 0) AS average
FROM students
LEFT JOIN papers ON students.id = papers.student_id
GROUP BY students.id, first_name;
```

### 3. Order of Execution

Remember the SQL query execution order:

1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
7. LIMIT

### 4. Performance Considerations

- Use WHERE to filter data before grouping (more efficient)
- Index columns used in GROUP BY
- Limit the result set when possible
- Consider using subqueries for complex aggregations

### 5. Group By All Non-Aggregated Columns

```sql
-- Correct
SELECT
    author_fname,
    author_lname,
    COUNT(*) AS books
FROM books
GROUP BY author_fname, author_lname;

-- May cause errors
SELECT
    author_fname,
    author_lname,
    COUNT(*) AS books
FROM books
GROUP BY author_fname;  -- Missing author_lname
```

---

## Common Mistakes to Avoid

### 1. Using Aggregate Functions in WHERE Clause

```sql
-- Wrong
SELECT author_lname, COUNT(*)
FROM books
WHERE COUNT(*) > 1  -- ERROR!
GROUP BY author_lname;

-- Correct
SELECT author_lname, COUNT(*)
FROM books
GROUP BY author_lname
HAVING COUNT(*) > 1;
```

### 2. Forgetting GROUP BY

```sql
-- Wrong
SELECT author_lname, COUNT(*)
FROM books;  -- ERROR!

-- Correct
SELECT author_lname, COUNT(*)
FROM books
GROUP BY author_lname;
```

### 3. Mixing Aggregated and Non-Aggregated Columns

```sql
-- Wrong (in strict SQL mode)
SELECT author_lname, title, COUNT(*)
FROM books
GROUP BY author_lname;  -- title is not aggregated or grouped

-- Correct
SELECT author_lname, COUNT(*) AS book_count
FROM books
GROUP BY author_lname;
```

---

## Summary

Aggregate functions are essential tools in SQL for data analysis and reporting:

- **COUNT()**: Count rows or non-NULL values
- **MIN()/MAX()**: Find minimum and maximum values
- **SUM()**: Calculate totals
- **AVG()**: Calculate averages
- **GROUP BY**: Group rows with same values
- **HAVING**: Filter groups after aggregation

### Quick Reference Card

| Function      | Purpose               | NULL Handling |
| ------------- | --------------------- | ------------- |
| COUNT(\*)     | Count all rows        | Includes NULL |
| COUNT(column) | Count non-NULL values | Excludes NULL |
| MIN(column)   | Find minimum value    | Excludes NULL |
| MAX(column)   | Find maximum value    | Excludes NULL |
| SUM(column)   | Calculate sum         | Excludes NULL |
| AVG(column)   | Calculate average     | Excludes NULL |

---

## Additional Resources

### Practice Exercises

1. Find the author who has written the most books
2. Calculate the average number of pages per author
3. Find years where more than 2 books were published
4. List authors with books over 300 pages on average
5. Find the longest book by each author

### Further Reading

- MySQL Documentation on Aggregate Functions
- SQL Performance Tuning with GROUP BY
- Advanced Grouping Techniques (ROLLUP, CUBE)
- Window Functions vs Aggregate Functions

---

**Note**: The examples in this guide assume a MySQL database. Syntax may vary slightly for other database systems (PostgreSQL, SQL Server, Oracle, etc.)

**Pro Tip**: Always test your queries with a small dataset first to ensure they produce the expected results before running them on production data.
