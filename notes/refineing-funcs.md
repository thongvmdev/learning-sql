# Refining Selections

More Weapons In The Arsenal

## Goal / Purpose

This guide teaches you how to refine and control your SQL queries beyond basic SELECT statements. You'll learn essential techniques to:

- **Filter out duplicates** with `DISTINCT`
- **Sort results** in meaningful ways using `ORDER BY`
- **Limit result sets** with `LIMIT` for pagination and top-N queries
- **Search with patterns** using `LIKE` wildcards for flexible text matching

By mastering these SQL clauses, you'll be able to write more precise queries, improve data presentation, and efficiently retrieve exactly the information you need from your database.

**Prerequisites:** Basic understanding of SELECT statements and working with a `books` table.

---

## Setup: Adding New Books

First, let's add some test data to work with:

```sql
INSERT INTO books
(title, author_fname, author_lname, released_year, stock_quantity, pages)
VALUES ('10% Happier', 'Dan', 'Harris', 2014, 29, 256),
('fake_book', 'Freida', 'Harris', 2001, 287, 428),
('Lincoln In The Bardo', 'George', 'Saunders', 2017, 1000, 367);
```

---

## DISTINCT

The `DISTINCT` keyword removes duplicate values from results.

### Basic Usage

```sql
SELECT DISTINCT author_lname FROM books;
```

This returns only unique author last names.

### Challenge: What About DISTINCT Full Names?

How would you get distinct full names (first and last name combinations)?

---

## ORDER BY

Sorting Our Results

### Basic Sorting

```sql
SELECT author_lname FROM books ORDER BY author_lname;
```

### Ascending By Default

By default, `ORDER BY` sorts in **ascending** order (A-Z, 0-9).

### Descending Order

You can change the sort order to descending:

```sql
SELECT author_lname FROM books ORDER BY author_lname DESC;
```

### Sorting Numbers

```sql
SELECT released_year FROM books ORDER BY released_year;
```

### Sorting by Column Position

You can use column numbers instead of names:

```sql
SELECT title, author_fname, author_lname
FROM books ORDER BY 2;
```

This sorts by the 2nd column (`author_fname`).

### Multiple Column Sorting

Sort by multiple columns - first by one, then by another:

```sql
SELECT author_fname, author_lname FROM books
ORDER BY author_lname, author_fname;
```

This sorts by last name first, then by first name within each last name group.

---

## LIMIT

The `LIMIT` clause restricts the number of rows returned.

### Basic LIMIT

Get the 5 most recent books:

```sql
SELECT title, released_year FROM books
ORDER BY released_year DESC LIMIT 5;
```

### LIMIT with Offset (Starting Position)

```sql
SELECT title, released_year FROM books
ORDER BY released_year DESC LIMIT 0,5;
```

- First number (0) = starting position
- Second number (5) = number of rows to return

### Skip Rows with Offset

```sql
SELECT title, released_year FROM books
ORDER BY released_year DESC LIMIT 5,7;
```

This skips the first 5 rows and returns the next 7 rows.

### Getting All Remaining Rows

```sql
SELECT * FROM tbl LIMIT 95,18446744073709551615;
```

---

## LIKE

`LIKE` is used in a `WHERE` clause to **search text patterns**.

```sql
SELECT *
FROM users
WHERE name LIKE 'A%';
```

👉 “Give me users whose name starts with **A**”

---

### 2️⃣ The two wildcards (super important)

### 🔹 `%` — _any number of characters_ (including zero)

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

### 🔹 `_` — _exactly one character_

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

✔ `john`

✔ `joan`

❌ `jon`

---

### 3️⃣ Common `LIKE` patterns (memorize these)

### ✅ Starts with

```sql
WHERE email LIKE 'admin%';
```

### ✅ Ends with

```sql
WHERE email LIKE '%@gmail.com';
```

### ✅ Contains

```sql
WHERE description LIKE '%error%';
```

### ✅ Fixed length

```sql
WHERE code LIKE 'AB___';  -- exactly 5 chars
```

---

### 4️⃣ `LIKE` with `NOT`

```sql
SELECT *
FROM users
WHERE name NOT LIKE '%test%';
```

➡ exclude test data (very common in production)

---

### 5️⃣ `LIKE` is case-sensitive or not?

⚠️ **Depends on DB & collation**

### MySQL (default)

- ❌ Case-sensitive? → **NO**

```sql
'SQL' LIKE '%sql%'  -- TRUE
```

### PostgreSQL

- ❌ Case-sensitive? → **YES**

Use `ILIKE` instead:

```sql
WHERE name ILIKE '%sql%';
```

### MySQL (force case-sensitive)

```sql
WHERE BINARY name LIKE 'Admin%';
```

---

### 6️⃣ `LIKE` vs `=` (important difference)

```sql
WHERE name = 'John'
```

➡ exact match only

```sql
WHERE name LIKE 'John'
```

➡ same as `=`

But:

```sql
WHERE name LIKE 'John%'
```

➡ John, Johnny, Johnson

---

### 7️⃣ `LIKE` with numbers ❌ (common mistake)

```sql
WHERE age LIKE '2%'; -- ❌ bad idea
```

Why?

- `LIKE` is for **strings**
- DB may cast implicitly (slow & risky)

✅ Correct:

```sql
WHERE age BETWEEN 20 AND 29;
```

---

### 8️⃣ Escaping `%` and `_`

What if your data **actually contains** `%` or `_`?

Use `ESCAPE`.

```sql
SELECT *
FROM coupons
WHERE code LIKE '50\%%' ESCAPE '\';
```

Matches:

✔ `50%OFF`

---

### 9️⃣ Performance ⚠️ (very important in real apps)

### 🚀 Fast

```sql
WHERE name LIKE 'Jo%';
```

✔ can use index

### 🐌 Slow

```sql
WHERE name LIKE '%Jo%';
```

❌ full table scan

👉 Rule of thumb:

> **Leading `%` kills index usage**

---

### 🔟 `LIKE` with `GROUP BY` / `HAVING`

Filter **before** grouping:

```sql
SELECT author, COUNT(*)
FROM books
WHERE title LIKE '%SQL%'
GROUP BY author;
```

Filter **after** aggregation:

```sql
SELECT author, COUNT(*) AS total
FROM books
GROUP BY author
HAVING author LIKE 'A%';
```

---

### 1️⃣1️⃣ `LIKE` vs `REGEXP`

| Feature          | LIKE | REGEXP |
| ---------------- | ---- | ------ |
| Simple           | ✅   | ❌     |
| Fast             | ✅   | ❌     |
| Complex patterns | ❌   | ✅     |

Example REGEXP:

```sql
WHERE name REGEXP '^[A-Z][a-z]+$';
```

Use `LIKE` **90% of the time**.

---

### 1️⃣2️⃣ Real-world examples

### Emails

```sql
WHERE email LIKE '%@company.com';
```

### Search box

```sql
WHERE title LIKE CONCAT('%', :keyword, '%');
```

### Soft delete

```sql
WHERE username NOT LIKE 'deleted_%';
```

---

### 🧠 Mental model (easy way to remember)

> `LIKE` = string **pattern matching**
> `%` = many characters
> `_` = one character

If you want, next we can:

- 🔥 Practice with tricky exercises
- ⚖️ Compare `LIKE` vs `FULLTEXT`
- 🧪 Debug common interview questions
- 🗃️ Optimize `LIKE` queries with indexes

Just tell me 😄

---

## Practice Exercises

### Exercise 1: Select All Story Collections

Find titles that contain 'stories':

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

### Exercise 2: Find The Longest Book

Print out the title and page count:

**Expected Output:**

```
+-------------------------------------------+-------+
| title                                     | pages |
+-------------------------------------------+-------+
| The Amazing Adventures of Kavalier & Clay |   634 |
+-------------------------------------------+-------+
```

### Exercise 3: Most Recent Books Summary

Print a summary containing the title and year, for the 3 most recent books:

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

### Exercise 4: Find Books with Space in Author Last Name

Find all books with an author_lname that contains a space (" "):

**Expected Output:**

```
+----------------------+----------------+
| title                | author_lname   |
+----------------------+----------------+
| Oblivion: Stories    | Foster Wallace |
| Consider the Lobster | Foster Wallace |
+----------------------+----------------+
```

**Don't Cheat!** Use LIKE to find the space.

### Exercise 5: Find The 3 Books With The Lowest Stock

Select title, year, and stock:

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

### Exercise 6: Sort by Author and Title

Print title and author_lname, sorted first by author_lname and then by title:

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

### Exercise 7: Create Uppercase Message

Make this happen - sorted alphabetically by last name:

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

---

## Summary

Key SQL clauses for refining selections:

- **DISTINCT** - Remove duplicate values
- **ORDER BY** - Sort results (ASC/DESC)
- **LIMIT** - Restrict number of rows returned
- **LIKE** - Pattern matching with wildcards (% and \_)

These tools give you powerful control over how you query and display data!
