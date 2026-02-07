# Mastering SQL Query Refinement: Your Complete Guide to DISTINCT, ORDER BY, LIMIT, and LIKE

> **Level up your SQL game**: Learn the essential techniques to write precise, powerful queries that go beyond basic SELECT statements

## Introduction

So you've learned the basics of `SELECT` statements—great! But if you're still writing queries that return messy, unsorted data with duplicates scattered everywhere, you're only scratching the surface of what SQL can do.

In this comprehensive guide, we'll explore four powerful SQL clauses that will transform your queries from basic to professional:

- **`DISTINCT`** - Eliminate duplicate values and get clean results
- **`ORDER BY`** - Sort your data in meaningful ways (ascending or descending)
- **`LIMIT`** - Control result size for pagination and top-N queries
- **`LIKE`** - Perform flexible pattern matching with wildcards

By the end of this tutorial, you'll be writing queries that are precise, efficient, and production-ready. Let's dive in!

**Prerequisites:** Basic understanding of SELECT statements. We'll be using a `books` table for our examples.

---

## Table of Contents

1. [Getting Started: Sample Data Setup](#setup-adding-new-books)
2. [DISTINCT: Removing Duplicates](#distinct)
3. [ORDER BY: Sorting Results](#order-by)
4. [LIMIT: Controlling Result Size](#limit)
5. [LIKE: Pattern Matching Magic](#like)
6. [Practice Exercises](#practice-exercises)
7. [Summary & Next Steps](#summary)

---

## Getting Started: Sample Data Setup

Before we dive into the good stuff, let's populate our `books` table with some test data. Run this quick insert:

```sql
INSERT INTO books
(title, author_fname, author_lname, released_year, stock_quantity, pages)
VALUES ('10% Happier', 'Dan', 'Harris', 2014, 29, 256),
('fake_book', 'Freida', 'Harris', 2001, 287, 428),
('Lincoln In The Bardo', 'George', 'Saunders', 2017, 1000, 367);
```

Now we're ready to explore!

---

## 1. DISTINCT: Eliminating Duplicates

### The Problem

Ever run a query and gotten the same value repeated dozens of times? That's where `DISTINCT` comes to the rescue. It filters out duplicate values, giving you only unique results.

### Basic Usage

Let's say you want to see all the unique author last names in your database:

```sql
SELECT DISTINCT author_lname FROM books;
```

Instead of getting "Harris" twenty times (if you have twenty books by various Harris authors), you'll see it just once. Clean and simple!

### Level Up: DISTINCT with Multiple Columns

Here's a common interview question: **How do you get distinct full names (first and last name combinations)?**

```sql
SELECT DISTINCT author_fname, author_lname FROM books;
```

When you use `DISTINCT` with multiple columns, SQL looks at the **combination** of values. So "Dan Harris" and "Freida Harris" would both appear, even though they share a last name.

**Pro Tip:** `DISTINCT` applies to the entire row of selected columns, not individual columns.

---

## 2. ORDER BY: Sorting Your Results

### Why Sorting Matters

Unsorted data is chaotic. Whether you're building a report or just trying to make sense of your results, `ORDER BY` is your best friend for organizing data.

### Basic Sorting: Alphabetical Order

```sql
SELECT author_lname FROM books ORDER BY author_lname;
```

This gives you authors sorted alphabetically from A to Z. Simple, clean, effective.

### ASC vs DESC: Understanding Sort Direction

By default, `ORDER BY` sorts in **ascending** order:
- For text: A → Z
- For numbers: 0 → 9
- For dates: oldest → newest

Want to reverse it? Just add `DESC`:

```sql
SELECT author_lname FROM books ORDER BY author_lname DESC;
```

Now you'll see authors from Z to A.

### Sorting Numbers and Dates

It works the same way for numerical data:

```sql
SELECT title, released_year FROM books 
ORDER BY released_year;
```

This shows you books from oldest to newest. Add `DESC` to see the newest first.

### Pro Shortcut: Sorting by Column Position

Here's a neat trick—you can use column numbers instead of names:

```sql
SELECT title, author_fname, author_lname
FROM books ORDER BY 2;
```

This sorts by the **2nd column** in your SELECT list (`author_fname`). Handy for quick queries, but use column names in production code for clarity!

### Multi-Level Sorting

The real power of `ORDER BY` comes when you sort by multiple columns:

```sql
SELECT author_fname, author_lname FROM books
ORDER BY author_lname, author_fname;
```

**How it works:**
1. First, sort by `author_lname` 
2. Within each last name group, sort by `author_fname`

So you'll see all the "Harris" authors grouped together, with "Dan Harris" before "Freida Harris".

**Real-world example:** Think of a phone book—sorted by last name, then first name. That's multi-level sorting!

---

## 3. LIMIT: Taking Control of Result Size

### Why LIMIT Matters

Returning 1 million rows is rarely useful. `LIMIT` lets you say "just give me the top 10" or "show me page 2 of results." Essential for pagination and performance.

### Basic LIMIT: Top-N Queries

Want the 5 most recent books? Combine `ORDER BY` with `LIMIT`:

```sql
SELECT title, released_year FROM books
ORDER BY released_year DESC LIMIT 5;
```

**What happens here:**
1. Sort all books by year (newest first)
2. Take only the top 5 results

This is called a "top-N query" and it's incredibly common in real applications.

### Pagination with OFFSET

Here's where `LIMIT` gets really powerful—pagination!

```sql
SELECT title, released_year FROM books
ORDER BY released_year DESC LIMIT 0, 5;
```

**Syntax breakdown:**
- First number (0) = **offset** (starting position, 0-indexed)
- Second number (5) = **limit** (how many rows to return)

This gives you rows 1-5.

### Building a Pagination System

Want page 2? Skip the first 5 rows:

```sql
SELECT title, released_year FROM books
ORDER BY released_year DESC LIMIT 5, 7;
```

This returns rows 6-12 (skips first 5, returns next 7).

**Real-world usage:**
```sql
-- Page 1: LIMIT 0, 20
-- Page 2: LIMIT 20, 20
-- Page 3: LIMIT 40, 20
```

### Advanced Tip: Getting All Remaining Rows

Need everything after row 95?

```sql
SELECT * FROM tbl LIMIT 95, 18446744073709551615;
```

That giant number is MySQL's max value for BIGINT UNSIGNED. Essentially means "give me everything from position 95 onward."

---

## 4. LIKE: Pattern Matching Magic

### The Power of Flexible Searching

`LIKE` is one of SQL's most powerful features for text searches. Instead of exact matches, you can search for patterns.

`LIKE` is used in a `WHERE` clause to **search text patterns**.

```sql
SELECT *
FROM users
WHERE name LIKE 'A%';
```

👉 “Give me users whose name starts with **A**”

---

### Understanding the Two Wildcards

These are the building blocks of pattern matching in SQL:

### Wildcard #1: `%` (The Percent Sign)

The `%` wildcard matches **any number of characters** (including zero)

| Pattern | Meaning                    |
| ------- | -------------------------- |
| `'A%'`  | Starts with A              |
| `'%A'`  | Ends with A                |
| `'%A%'` | Contains A                 |
| `'A%B'` | Starts with A, ends with B |

**Example**

```sql
SELECT * FROM books
WHERE title LIKE '%SQL%';
```

➡ titles that contain “SQL”

---

### Wildcard #2: `_` (The Underscore)

The `_` wildcard matches **exactly one character**. It's more precise than `%`.

| Pattern | Meaning                 |
| ------- | ----------------------- |
| `'A_'`  | A + 1 character         |
| `'A__'` | A + 2 characters        |
| `'_a%'` | second character is `a` |

**Example**

```sql
SELECT * FROM users
WHERE username LIKE 'jo_n';
```

**Matches:**
- ✔ `john` (4 characters, 3rd is any char)
- ✔ `joan` (4 characters, 3rd is 'a')

**Doesn't match:**
- ❌ `jon` (only 3 characters)
- ❌ `jordan` (6 characters)

---

### Common LIKE Patterns to Memorize

Here are the patterns you'll use most often in real-world applications:

#### Pattern 1: Starts With

```sql
WHERE email LIKE 'admin%';
```
Finds: admin@site.com, admin123, administrator

#### Pattern 2: Ends With

```sql
WHERE email LIKE '%@gmail.com';
```
Finds: All Gmail addresses

#### Pattern 3: Contains

```sql
WHERE description LIKE '%error%';
```
Finds: Any description containing "error" (great for log filtering!)

#### Pattern 4: Fixed Length

```sql
WHERE code LIKE 'AB___';  -- exactly 5 chars total
```
Finds: AB123, ABxyz (but not AB12 or AB1234)

---

### Using LIKE with NOT

Need to exclude certain patterns? Combine `LIKE` with `NOT`:

```sql
SELECT *
FROM users
WHERE name NOT LIKE '%test%';
```

**Translation:** "Give me all users whose name does NOT contain 'test'"

**Pro tip:** This is incredibly common in production for filtering out test accounts, deleted users, or dummy data!

---

### Case Sensitivity: An Important Gotcha

**Question:** Is `LIKE` case-sensitive?  
**Answer:** It depends on your database!

#### MySQL (Default Behavior)
**Case-sensitive?** NO

```sql
'SQL' LIKE '%sql%'  -- Returns TRUE
```

MySQL's default collation is case-insensitive, so 'SQL', 'sql', and 'Sql' are treated the same.

#### PostgreSQL
**Case-sensitive?** YES

Use `ILIKE` for case-insensitive matching:

```sql
WHERE name ILIKE '%sql%';  -- Case-insensitive
WHERE name LIKE '%sql%';   -- Case-sensitive
```

#### MySQL (Force Case-Sensitive)

Need case-sensitive matching in MySQL?

```sql
WHERE BINARY name LIKE 'Admin%';
```

This only matches "Admin" (not "admin" or "ADMIN").

---

### LIKE vs = : Understanding the Difference

This trips up a lot of beginners:

**Using the equals operator:**
```sql
WHERE name = 'John'
```
**Result:** Exact match only. Name must be exactly "John".

**Using LIKE without wildcards:**
```sql
WHERE name LIKE 'John'
```
**Result:** Same as `=`. Exact match only.

**Using LIKE with wildcards:**
```sql
WHERE name LIKE 'John%'
```
**Result:** Matches John, Johnny, Johnson, Johnathan, etc.

**Key takeaway:** Without wildcards, `LIKE` behaves like `=`. The power comes from using `%` and `_`.

---

### Common Mistake: Using LIKE with Numbers

Here's a mistake I see constantly:

```sql
WHERE age LIKE '2%'; -- ❌ Bad practice!
```

**Why is this wrong?**
- `LIKE` is designed for **string** matching, not numbers
- Your database may implicitly cast the number to a string (slow!)
- This bypasses any indexes on the column

**The right way:**
```sql
WHERE age BETWEEN 20 AND 29;
```

**Remember:** Use `LIKE` for text, use numeric operators (`=`, `>`, `<`, `BETWEEN`) for numbers.

---

### Escaping Special Characters

**Problem:** What if your data literally contains `%` or `_` characters?

**Example:** You're searching for coupon codes that start with "50%"

**Solution:** Use the `ESCAPE` clause to treat wildcards as literal characters:

```sql
SELECT *
FROM coupons
WHERE code LIKE '50\%%' ESCAPE '\';
```

**How it works:**
- `\%` = literal percent sign (not a wildcard)
- Last `%` = wildcard (matches anything after)

**Matches:**
- ✔ `50%OFF`
- ✔ `50%DISCOUNT`

**Doesn't match:**
- ❌ `50OFF` (missing the percent sign)

---

### Performance Considerations (Critical for Production!)

Not all `LIKE` queries are created equal. Performance varies dramatically based on wildcard placement:

#### Fast Query (Index-Friendly)

```sql
WHERE name LIKE 'Jo%';
```

**Why it's fast:** The database can use an index because the pattern has a fixed starting point.

**Speed:** ⚡ Lightning fast, even with millions of rows

---

#### Slow Query (Full Table Scan)

```sql
WHERE name LIKE '%Jo%';
```

**Why it's slow:** Leading `%` means the database can't use an index—it must scan every single row.

**Speed:** 🐌 Slow, gets worse as table grows

---

#### The Golden Rule

> **Leading `%` kills index usage**

**Best practices:**
- ✅ `WHERE name LIKE 'Jo%'` — Index friendly
- ✅ `WHERE name LIKE 'John_'` — Index friendly
- ❌ `WHERE name LIKE '%Jo%'` — Full table scan
- ❌ `WHERE name LIKE '%Jo'` — Full table scan

If you must search for patterns anywhere in the string, consider using **full-text search** indexes (FULLTEXT in MySQL, tsvector in PostgreSQL).

---

### Using LIKE with GROUP BY and HAVING

You can use `LIKE` in both `WHERE` and `HAVING` clauses:

#### Filter BEFORE Grouping (WHERE)

```sql
SELECT author, COUNT(*)
FROM books
WHERE title LIKE '%SQL%'
GROUP BY author;
```

**Use case:** "Show me how many SQL books each author has written"

#### Filter AFTER Aggregation (HAVING)

```sql
SELECT author, COUNT(*) AS total
FROM books
GROUP BY author
HAVING author LIKE 'A%';
```

**Use case:** "Group books by author, but only show authors whose name starts with A"

**Key difference:** `WHERE` filters individual rows, `HAVING` filters grouped results.

---

### LIKE vs REGEXP: When to Use Which

For complex pattern matching, you might encounter regular expressions:

| Feature               | LIKE         | REGEXP       |
| --------------------- | ------------ | ------------ |
| Learning curve        | Easy ✅      | Complex ❌   |
| Performance           | Fast ⚡      | Slower 🐌    |
| Simple patterns       | Perfect ✅   | Overkill ❌  |
| Complex patterns      | Limited ❌   | Powerful ✅  |
| Industry usage        | 90% of cases | 10% of cases |

**LIKE example:**
```sql
WHERE email LIKE '%@gmail.com';
```

**REGEXP example:**
```sql
WHERE name REGEXP '^[A-Z][a-z]+$';
```

**My recommendation:** Use `LIKE` for 90% of your needs. Only reach for `REGEXP` when you need complex pattern matching (like validating formats, extracting substrings, etc.).

---

### Real-World LIKE Examples

Let's look at practical scenarios you'll encounter in production:

#### Example 1: Company Email Filter

```sql
SELECT * FROM users
WHERE email LIKE '%@company.com';
```

**Use case:** Find all employees with company email addresses

#### Example 2: Dynamic Search Box

```sql
SELECT * FROM products
WHERE title LIKE CONCAT('%', :keyword, '%');
```

**Use case:** Building a search feature where `:keyword` is user input

#### Example 3: Soft Delete Pattern

```sql
SELECT * FROM users
WHERE username NOT LIKE 'deleted_%';
```

**Use case:** Exclude soft-deleted users (those prefixed with "deleted_")

#### Example 4: Phone Number Validation

```sql
SELECT * FROM contacts
WHERE phone LIKE '___-___-____';
```

**Use case:** Find phone numbers in format XXX-XXX-XXXX (exactly 12 characters)

---

### Quick Reference: Mental Model

Remember these core concepts:

> **`LIKE`** = String pattern matching  
> **`%`** = Any number of characters (0 or more)  
> **`_`** = Exactly one character  
> **Leading `%`** = Kills index performance  
> **No wildcards** = Same as `=`

---

## Put Your Knowledge to the Test

Now that you've learned the theory, it's time to practice! These exercises will reinforce everything we've covered.

### Exercise 1: Select All Story Collections

**Task:** Find all book titles that contain the word 'stories' (hint: use `LIKE`!)

**Expected Output:**

```
+-----------------------------------------------------+
| title                                               |
+-----------------------------------------------------+
| What We Talk About When We Talk About Love: Stories |
| Where I'm Calling From: Selected Stories            |
| Oblivion: Stories                                   |
+-----------------------------------------------------+
```

**Skills tested:** `LIKE` with wildcards, case-insensitive matching

---

### Exercise 2: Find The Longest Book

**Task:** Find the book with the most pages. Display the title and page count.

**Expected Output:**

```
+-------------------------------------------+-------+
| title                                     | pages |
+-------------------------------------------+-------+
| The Amazing Adventures of Kavalier & Clay |   634 |
+-------------------------------------------+-------+
```

**Skills tested:** `ORDER BY` with `DESC`, `LIMIT 1`

---

### Exercise 3: Most Recent Books Summary

**Task:** Create a summary in the format "Title - Year" for the 3 most recent books.

**Expected Output:**

```
+-----------------------------+
| summary                     |
+-----------------------------+
| Lincoln In The Bardo - 2017 |
| Norse Mythology - 2016      |
| 10% Happier - 2014          |
+-----------------------------+
```

**Skills tested:** `CONCAT` (or `||`), `ORDER BY`, `LIMIT`

**Hint:** You'll need to combine the title and year with ` - ` between them.

---

### Exercise 4: Find Books with Space in Author Last Name

**Task:** Find all books where the author's last name contains a space character.

**Expected Output:**

```
+----------------------+----------------+
| title                | author_lname   |
+----------------------+----------------+
| Oblivion: Stories    | Foster Wallace |
| Consider the Lobster | Foster Wallace |
+----------------------+----------------+
```

**Skills tested:** `LIKE` pattern matching

**Challenge:** Don't cheat! You must use `LIKE` to find the space.

---

### Exercise 5: Find The 3 Books With The Lowest Stock

**Task:** Find the 3 books with the lowest stock quantity. Display title, year, and stock.

**Expected Output:**

```
+-----------------------------------------------------+---------------+----------------+
| title                                               | released_year | stock_quantity |
+-----------------------------------------------------+---------------+----------------+
| American Gods                                       |          2001 |             12 |
| Where I'm Calling From: Selected Stories            |          1989 |             12 |
| What We Talk About When We Talk About Love: Stories |          1981 |             23 |
+-----------------------------------------------------+---------------+----------------+
```

**Skills tested:** `ORDER BY` with `ASC` (or default), `LIMIT`

**Use case:** Inventory management—find books that need restocking!

---

### Exercise 6: Sort by Author and Title

**Task:** Display title and author last name, sorted by author last name first, then by title.

**Expected Output:**

```
+-----------------------------------------------------+----------------+
| title                                               | author_lname   |
+-----------------------------------------------------+----------------+
| What We Talk About When We Talk About Love: Stories | Carver         |
| Where I'm Calling From: Selected Stories            | Carver         |
| The Amazing Adventures of Kavalier & Clay           | Chabon         |
| White Noise                                         | DeLillo        |
| A Heartbreaking Work of Staggering Genius           | Eggers         |
| A Hologram for the King: A Novel                    | Eggers         |
| The Circle                                          | Eggers         |
| Consider the Lobster                                | Foster Wallace |
| Oblivion: Stories                                   | Foster Wallace |
| American Gods                                       | Gaiman         |
| Coraline                                            | Gaiman         |
| Norse Mythology                                     | Gaiman         |
| 10% Happier                                         | Harris         |
| fake_book                                           | Harris         |
| Interpreter of Maladies                             | Lahiri         |
| The Namesake                                        | Lahiri         |
| Lincoln In The Bardo                                | Saunders       |
| Just Kids                                           | Smith          |
| Cannery Row                                         | Steinbeck      |
+-----------------------------------------------------+----------------+
```

**Skills tested:** Multi-column sorting with `ORDER BY`

**Real-world use case:** Creating organized catalogs, reports, or alphabetical listings.

---

### Exercise 7: Create Uppercase Message

**Task:** Create an uppercase message in the format "MY FAVORITE AUTHOR IS [FULL NAME]!" sorted by last name.

**Expected Output:**

```
+---------------------------------------------+
| yell                                        |
+---------------------------------------------+
| MY FAVORITE AUTHOR IS RAYMOND CARVER!       |
| MY FAVORITE AUTHOR IS RAYMOND CARVER!       |
| MY FAVORITE AUTHOR IS MICHAEL CHABON!       |
| MY FAVORITE AUTHOR IS DON DELILLO!          |
| MY FAVORITE AUTHOR IS DAVE EGGERS!          |
| MY FAVORITE AUTHOR IS DAVE EGGERS!          |
| MY FAVORITE AUTHOR IS DAVE EGGERS!          |
| MY FAVORITE AUTHOR IS DAVID FOSTER WALLACE! |
| MY FAVORITE AUTHOR IS DAVID FOSTER WALLACE! |
| MY FAVORITE AUTHOR IS NEIL GAIMAN!          |
| MY FAVORITE AUTHOR IS NEIL GAIMAN!          |
| MY FAVORITE AUTHOR IS NEIL GAIMAN!          |
| MY FAVORITE AUTHOR IS FREIDA HARRIS!        |
| MY FAVORITE AUTHOR IS DAN HARRIS!           |
| MY FAVORITE AUTHOR IS JHUMPA LAHIRI!        |
| MY FAVORITE AUTHOR IS JHUMPA LAHIRI!        |
| MY FAVORITE AUTHOR IS GEORGE SAUNDERS!      |
| MY FAVORITE AUTHOR IS PATTI SMITH!          |
| MY FAVORITE AUTHOR IS JOHN STEINBECK!       |
+---------------------------------------------+
```

**Skills tested:** String functions (`UPPER`, `CONCAT`), sorting

**Challenge level:** Advanced—this combines multiple concepts!

**Hints:**
- Use `UPPER()` to convert text to uppercase
- Use `CONCAT()` to build the message
- Don't forget to sort by `author_lname`

---

## Summary: Your SQL Toolkit Just Got Bigger

Congratulations! You've just added four powerful tools to your SQL arsenal. Let's recap what you've learned:

### The Four Essential Clauses

1. **`DISTINCT`** - Eliminate duplicate values
   - Returns only unique combinations of selected columns
   - Perfect for finding unique items in your data

2. **`ORDER BY`** - Sort results in meaningful ways
   - Default is ascending (ASC), use DESC for descending
   - Can sort by multiple columns
   - Essential for creating organized reports

3. **`LIMIT`** - Control the size of your result set
   - Ideal for top-N queries ("show me the top 10")
   - Powers pagination systems
   - Use with OFFSET for page-by-page navigation

4. **`LIKE`** - Flexible pattern matching with wildcards
   - `%` matches any number of characters
   - `_` matches exactly one character
   - Perfect for search features and text filtering
   - **Remember:** Leading `%` impacts performance!

### What's Next?

Now that you've mastered query refinement, you're ready for more advanced topics:

- **Aggregate Functions** - `COUNT()`, `SUM()`, `AVG()`, `MAX()`, `MIN()`
- **Joins** - Combining data from multiple tables
- **Subqueries** - Queries within queries
- **Indexes** - Optimizing query performance
- **Transactions** - Ensuring data integrity

Keep practicing with the exercises above, and don't hesitate to experiment with your own queries. The best way to learn SQL is by writing it!

---

**Did you find this guide helpful?** The key to mastery is practice. Try modifying the exercises, creating your own variations, and applying these techniques to real-world scenarios.

Happy querying!
