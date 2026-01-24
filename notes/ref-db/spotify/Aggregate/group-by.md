# SQL GROUP BY Clause > Step-by-Step Guide

## Introduction

`GROUP BY` is one of the most powerful SQL clauses. It allows you to **group rows** that have the same values in specified columns, then apply aggregate functions to each group separately.

---

## Sample Data

For all examples, we'll use this `books` table:

| id  | title          | author_lname | author_fname | pages | released_year |
| --- | -------------- | ------------ | ------------ | ----- | ------------- |
| 1   | Harry Potter 1 | Rowling      | J.K.         | 309   | 1997          |
| 2   | Harry Potter 2 | Rowling      | J.K.         | 341   | 1998          |
| 3   | Harry Potter 3 | Rowling      | J.K.         | 435   | 1999          |
| 4   | Harry Potter 4 | Rowling      | J.K.         | 636   | 2000          |
| 5   | The Shining    | King         | Stephen      | 447   | 1977          |
| 6   | It             | King         | Stephen      | 1138  | 1986          |
| 7   | Misery         | King         | Stephen      | 370   | 1987          |
| 8   | 1984           | Orwell       | George       | 328   | 1949          |

---

## Basic Syntax

```sql
SELECT column_name, AGGREGATE_FUNCTION(column)
FROM table_name
GROUP BY column_name;
```

---

## How GROUP BY Works: Step-by-Step

Let's break down this query:

```sql
SELECT
    author_lname,
    COUNT(*) AS books_written,
    SUM(pages) AS total_pages
FROM books
GROUP BY author_lname;
```

### Step 1: FROM - Load All Rows

SQL first loads **all rows** from the `books` table into memory.

**Result after Step 1:**

| id  | title          | author_lname | author_fname | pages | released_year |
| --- | -------------- | ------------ | ------------ | ----- | ------------- |
| 1   | Harry Potter 1 | Rowling      | J.K.         | 309   | 1997          |
| 2   | Harry Potter 2 | Rowling      | J.K.         | 341   | 1998          |
| 3   | Harry Potter 3 | Rowling      | J.K.         | 435   | 1999          |
| 4   | Harry Potter 4 | Rowling      | J.K.         | 636   | 2000          |
| 5   | The Shining    | King         | Stephen      | 447   | 1977          |
| 6   | It             | King         | Stephen      | 1138  | 1986          |
| 7   | Misery         | King         | James        | 370   | 1987          |
| 8   | 1984           | Orwell       | George       | 328   | 1949          |

_8 rows loaded_

---

### Step 2: GROUP BY - Create Logical Groups

SQL organizes rows into **groups** based on unique values in `author_lname`.

**Result after Step 2: 3 Groups Created**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 1: author_lname = 'Rowling'  (4 rows)                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  1 | Harry Potter 1           | Rowling      | J.K.         | 309   | 1997  │
│  2 | Harry Potter 2           | Rowling      | J.K.         | 341   | 1998  │
│  3 | Harry Potter 3           | Rowling      | J.K.         | 435   | 1999  │
│  4 | Harry Potter 4           | Rowling      | J.K.         | 636   | 2000  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 2: author_lname = 'King'  (3 rows)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  5 | The Shining              | King         | Stephen      | 447   | 1977  │
│  6 | It                       | King         | Stephen      | 1138  | 1986  │
│  7 | Misery                   | King         | James      | 370   | 1987  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 3: author_lname = 'Orwell'  (1 row)                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  8 | 1984                     | Orwell       | George       | 328   | 1949  │
└─────────────────────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 1: author_fname+author_lname = 'J.K. Rowling'  (4 rows)                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  1 | Harry Potter 1           | Rowling      | J.K.         | 309   | 1997  │
│  2 | Harry Potter 2           | Rowling      | J.K.         | 341   | 1998  │
│  3 | Harry Potter 3           | Rowling      | J.K.         | 435   | 1999  │
│  4 | Harry Potter 4           | Rowling      | J.K.         | 636   | 2000  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 2: author_fname+author_lname = 'Stephen King'  (3 rows)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  5 | The Shining              | King         | Stephen      | 447   | 1977  │
│  6 | It                       | King         | Stephen      | 1138  | 1986  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 3: author_fname+author_lname = 'James King'  (3 rows)                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  7 | Misery                   | King         | James      | 370   | 1987  │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│ GROUP 4: author_fname+author_lname = 'George Orwell'  (1 row)                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ id | title                    | author_lname | author_fname | pages | year  │
│  8 | 1984                     | Orwell       | George       | 328   | 1949  │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Key Point:** Each group contains **complete rows** with ALL columns from the original table.

---

### Step 3: SELECT - Process Each Group

SQL now processes `SELECT author_lname, COUNT(*), SUM(pages)` for **each group**:

**GROUP 1 (Rowling):**

```
author_lname = 'Rowling'
COUNT(*)     = 4                              (4 rows in group)
SUM(pages)   = 309 + 341 + 435 + 636 = 1721
```

→ Result row: `| Rowling | 4 | 1721 |`

**GROUP 2 (King):**

```
author_lname = 'King'
COUNT(*)     = 3                              (3 rows in group)
SUM(pages)   = 447 + 1138 + 370 = 1955
```

→ Result row: `| King | 3 | 1955 |`

**GROUP 3 (Orwell):**

```
author_lname = 'Orwell'
COUNT(*)     = 1                              (1 row in group)
SUM(pages)   = 328
```

→ Result row: `| Orwell | 1 | 328 |`

---

### Step 4: Final Result

Each group is collapsed into **one row**:

| author_lname | books_written | total_pages |
| ------------ | ------------- | ----------- |
| Rowling      | 4             | 1721        |
| King         | 3             | 1955        |
| Orwell       | 1             | 328         |

**Summary:**

| Original Rows | Groups Created | Final Rows |
| ------------- | -------------- | ---------- |
| 8             | 3              | 3          |

---

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Original books table                        │
│                        (8 rows)                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ GROUP BY author_lname
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Group 1     │    │  Group 2     │    │  Group 3     │
│  "Rowling"   │    │  "King"      │    │  "Orwell"    │
│  (4 rows)    │    │  (3 rows)    │    │  (1 row)     │
│  all columns │    │  all columns │    │  all columns │
└──────────────┘    └──────────────┘    └──────────────┘
        │                     │                     │
        ▼ SELECT              ▼ SELECT              ▼ SELECT
┌────────────────┐  ┌────────────────┐  ┌────────────────┐
│ Rowling|4|1721 │  │ King  |3|1955  │  │ Orwell|1|328   │
└────────────────┘  └────────────────┘  └────────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
              ┌─────────────────────────────────┐
              │         Final Result            │
              │  author_lname | count | pages   │
              │  Rowling      | 4     | 1721    │
              │  King         | 3     | 1955    │
              │  Orwell       | 1     | 328     │
              └─────────────────────────────────┘
```

---

## SQL Execution Order

**Written order:**

```sql
SELECT → FROM → GROUP BY
```

**Actual execution order:**

```sql
FROM → GROUP BY → SELECT
```

This is why you can use column aliases in `ORDER BY` but not in `WHERE`.

---

## Multiple Aggregate Functions

Since groups contain **all columns**, you can apply different aggregates:

```sql
SELECT
    author_lname,
    COUNT(*) AS books_written,
    SUM(pages) AS total_pages,
    AVG(pages) AS avg_pages,
    MIN(released_year) AS first_book,
    MAX(released_year) AS latest_book
FROM books
GROUP BY author_lname;
```

**Result:**

| author_lname | books_written | total_pages | avg_pages | first_book | latest_book |
| ------------ | ------------- | ----------- | --------- | ---------- | ----------- |
| Rowling      | 4             | 1721        | 430.25    | 1997       | 2000        |
| King         | 3             | 1955        | 651.67    | 1977       | 1987        |
| Orwell       | 1             | 328         | 328.00    | 1949       | 1949        |

---

## GROUP BY Multiple Columns

You can group by multiple columns to create more specific groups:

```sql
SELECT
    author_lname,
    author_fname,
    COUNT(*) AS books_written
FROM books
GROUP BY author_lname, author_fname;
```

This creates groups based on **unique combinations** of `author_lname` AND `author_fname`.

---

## The SELECT Rule

After `GROUP BY`, you can only `SELECT`:

1. **Columns in GROUP BY clause** (the grouping keys)
2. **Aggregate functions** applied to other columns

```sql
-- ❌ ERROR: title is not in GROUP BY and not aggregated
SELECT author_lname, title
FROM books
GROUP BY author_lname;

-- ✅ OK: title is aggregated with MAX()
SELECT author_lname, MAX(title) AS last_title_alphabetically
FROM books
GROUP BY author_lname;

-- ✅ OK: all non-aggregated columns are in GROUP BY
SELECT author_lname, author_fname, COUNT(*)
FROM books
GROUP BY author_lname, author_fname;
```

**Why?** Because each group may contain multiple different values for non-grouped columns. SQL doesn't know which one to pick.

---

## Key Takeaways

| Concept             | Description                                               |
| ------------------- | --------------------------------------------------------- |
| **GROUP BY**        | Splits rows into logical groups based on column values    |
| **Groups contain**  | Complete rows with ALL columns from original table        |
| **Aggregates**      | Process each group separately, return one value per group |
| **Final result**    | One row per group                                         |
| **SELECT rule**     | Only grouped columns or aggregate functions allowed       |
| **Execution order** | FROM → GROUP BY → SELECT                                  |

---

## Common Use Cases

```sql
-- Count items per category
SELECT category, COUNT(*) FROM products GROUP BY category;

-- Total sales per customer
SELECT customer_id, SUM(amount) FROM orders GROUP BY customer_id;

-- Average rating per product
SELECT product_id, AVG(rating) FROM reviews GROUP BY product_id;

-- Find most recent order per customer
SELECT customer_id, MAX(order_date) FROM orders GROUP BY customer_id;
```
