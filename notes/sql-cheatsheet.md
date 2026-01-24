# SQL Cheatsheet

A quick reference guide for all essential SQL commands with examples.

---

## Table of Contents

- [Database Operations](#database-operations)
- [Table Operations](#table-operations)
- [Data Types](#data-types)
- [Constraints](#constraints)
- [CRUD Operations](#crud-operations)
- [Filtering Data](#filtering-data)
- [Sorting & Limiting](#sorting--limiting)
- [String Functions](#string-functions)
- [Numeric Functions](#numeric-functions)
- [Date & Time Functions](#date--time-functions)
- [Aggregate Functions](#aggregate-functions)
- [Grouping Data](#grouping-data)
- [Joins](#joins)
- [Subqueries](#subqueries)
- [Set Operations](#set-operations)
- [Views](#views)
- [Indexes](#indexes)
- [Transactions](#transactions)

---

## Database Operations

### CREATE DATABASE

Create a new database.

```sql
CREATE DATABASE shop;
CREATE DATABASE IF NOT EXISTS shop;
```

### DROP DATABASE

Delete a database (irreversible).

```sql
DROP DATABASE shop;
DROP DATABASE IF EXISTS shop;
```

### USE DATABASE

Select a database to work with.

```sql
USE shop;
```

### SHOW DATABASES

List all databases.

```sql
SHOW DATABASES;
```

---

## Table Operations

### CREATE TABLE

Create a new table with columns.

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### DROP TABLE

Delete a table (irreversible).

```sql
DROP TABLE users;
DROP TABLE IF EXISTS users;
```

### TRUNCATE TABLE

Delete all rows but keep table structure.

```sql
TRUNCATE TABLE users;
```

### ALTER TABLE

Modify table structure.

```sql
-- Add column
ALTER TABLE users ADD phone VARCHAR(20);

-- Drop column
ALTER TABLE users DROP COLUMN phone;

-- Modify column type
ALTER TABLE users MODIFY age SMALLINT;

-- Rename column
ALTER TABLE users RENAME COLUMN name TO full_name;

-- Rename table
ALTER TABLE users RENAME TO customers;

-- Add constraint
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- Drop constraint
ALTER TABLE users DROP CONSTRAINT unique_email;
```

### DESCRIBE / DESC

Show table structure.

```sql
DESCRIBE users;
DESC users;
SHOW COLUMNS FROM users;
```

### SHOW TABLES

List all tables in current database.

```sql
SHOW TABLES;
```

---

## Data Types

### Numeric Types

| Type           | Description            | Range                |
| -------------- | ---------------------- | -------------------- |
| `TINYINT`      | Very small integer     | -128 to 127          |
| `SMALLINT`     | Small integer          | -32,768 to 32,767    |
| `INT`          | Standard integer       | -2.1B to 2.1B        |
| `BIGINT`       | Large integer          | -9.2E18 to 9.2E18    |
| `DECIMAL(p,s)` | Fixed-point number     | Precision p, scale s |
| `FLOAT`        | Single-precision float | ~7 decimal digits    |
| `DOUBLE`       | Double-precision float | ~15 decimal digits   |

```sql
price DECIMAL(10, 2)    -- 10 digits total, 2 after decimal
quantity INT UNSIGNED   -- Only positive numbers (0 to 4.2B)
```

### String Types

| Type         | Description            | Max Length        |
| ------------ | ---------------------- | ----------------- |
| `CHAR(n)`    | Fixed-length string    | 255 characters    |
| `VARCHAR(n)` | Variable-length string | 65,535 characters |
| `TEXT`       | Long text              | 65,535 characters |
| `MEDIUMTEXT` | Medium-length text     | 16MB              |
| `LONGTEXT`   | Very long text         | 4GB               |

```sql
status CHAR(1)           -- Always 1 character
name VARCHAR(100)        -- Up to 100 characters
description TEXT         -- Long text content
```

### Date/Time Types

| Type        | Format              | Example                |
| ----------- | ------------------- | ---------------------- |
| `DATE`      | YYYY-MM-DD          | '2024-01-15'           |
| `TIME`      | HH:MM:SS            | '14:30:00'             |
| `DATETIME`  | YYYY-MM-DD HH:MM:SS | '2024-01-15 14:30:00'  |
| `TIMESTAMP` | YYYY-MM-DD HH:MM:SS | Auto-converts timezone |
| `YEAR`      | YYYY                | 2024                   |

```sql
birth_date DATE
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
```

### Other Types

| Type      | Description                          |
| --------- | ------------------------------------ |
| `BOOLEAN` | TRUE or FALSE (stored as TINYINT(1)) |
| `ENUM`    | One value from a list                |
| `SET`     | Multiple values from a list          |
| `JSON`    | JSON document                        |
| `BLOB`    | Binary large object                  |

```sql
is_active BOOLEAN DEFAULT TRUE
status ENUM('pending', 'active', 'inactive')
tags SET('tech', 'news', 'sports')
metadata JSON
```

---

## Constraints

### PRIMARY KEY

Unique identifier for each row.

```sql
-- Single column
id INT PRIMARY KEY

-- Or define separately
PRIMARY KEY (id)

-- Composite primary key
PRIMARY KEY (user_id, product_id)
```

### FOREIGN KEY

Reference to another table's primary key.

```sql
-- Creates relationship between tables
customer_id INT,
FOREIGN KEY (customer_id) REFERENCES customers(id)

-- With cascade options
FOREIGN KEY (customer_id) REFERENCES customers(id)
    ON DELETE CASCADE      -- Delete related rows
    ON UPDATE CASCADE      -- Update related rows

-- Other options: SET NULL, RESTRICT, NO ACTION
```

### NOT NULL

Column cannot be empty.

```sql
name VARCHAR(100) NOT NULL
```

### UNIQUE

All values must be different.

```sql
email VARCHAR(100) UNIQUE
```

### DEFAULT

Set default value if not provided.

```sql
status VARCHAR(20) DEFAULT 'active'
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

### CHECK

Validate data before inserting.

```sql
age INT CHECK (age >= 0 AND age <= 150)
price DECIMAL(10,2) CHECK (price > 0)
```

### AUTO_INCREMENT

Automatically generate sequential numbers.

```sql
id INT AUTO_INCREMENT PRIMARY KEY
```

---

## CRUD Operations

### INSERT - Create Data

```sql
-- Single row
INSERT INTO users (name, email, age)
VALUES ('John Doe', 'john@email.com', 25);

-- Multiple rows
INSERT INTO users (name, email, age)
VALUES
    ('Jane Doe', 'jane@email.com', 30),
    ('Bob Smith', 'bob@email.com', 35);

-- Insert from another table
INSERT INTO archive_users (name, email)
SELECT name, email FROM users WHERE status = 'inactive';
```

### SELECT - Read Data

```sql
-- All columns
SELECT * FROM users;

-- Specific columns
SELECT name, email FROM users;

-- With alias
SELECT name AS full_name, email AS contact FROM users;

-- Distinct values (no duplicates)
SELECT DISTINCT status FROM users;

-- Calculated columns
SELECT name, price, quantity, price * quantity AS total FROM orders;
```

### UPDATE - Modify Data

```sql
-- Update single column
UPDATE users SET age = 26 WHERE id = 1;

-- Update multiple columns
UPDATE users SET name = 'John Smith', age = 27 WHERE id = 1;

-- Update all rows (dangerous!)
UPDATE users SET status = 'active';

-- Update with calculation
UPDATE products SET price = price * 1.1;  -- 10% increase
```

### DELETE - Remove Data

```sql
-- Delete specific rows
DELETE FROM users WHERE id = 1;

-- Delete with condition
DELETE FROM users WHERE status = 'inactive';

-- Delete all rows (dangerous!)
DELETE FROM users;
```

---

## Filtering Data

### WHERE Clause

Filter rows based on conditions.

```sql
SELECT * FROM users WHERE age > 25;
SELECT * FROM users WHERE status = 'active';
```

### Comparison Operators

| Operator    | Description           | Example                |
| ----------- | --------------------- | ---------------------- |
| `=`         | Equal                 | `age = 25`             |
| `<>` / `!=` | Not equal             | `status <> 'inactive'` |
| `<`         | Less than             | `price < 100`          |
| `>`         | Greater than          | `quantity > 0`         |
| `<=`        | Less than or equal    | `age <= 30`            |
| `>=`        | Greater than or equal | `rating >= 4`          |

### Logical Operators

```sql
-- AND: Both conditions must be true
SELECT * FROM users WHERE age > 20 AND status = 'active';

-- OR: At least one condition must be true
SELECT * FROM users WHERE age < 20 OR age > 60;

-- NOT: Negate condition
SELECT * FROM users WHERE NOT status = 'inactive';

-- Combining operators (use parentheses)
SELECT * FROM users WHERE (age > 25 AND status = 'active') OR role = 'admin';
```

### BETWEEN

Range of values (inclusive).

```sql
SELECT * FROM products WHERE price BETWEEN 10 AND 50;
SELECT * FROM orders WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';
```

### IN / NOT IN

Match any value in a list.

```sql
SELECT * FROM users WHERE status IN ('active', 'pending');
SELECT * FROM users WHERE id NOT IN (1, 2, 3);
```

### LIKE / NOT LIKE

Pattern matching for strings.

```sql
-- % matches any sequence of characters
SELECT * FROM users WHERE name LIKE 'John%';     -- Starts with 'John'
SELECT * FROM users WHERE name LIKE '%son';      -- Ends with 'son'
SELECT * FROM users WHERE name LIKE '%oh%';      -- Contains 'oh'

-- _ matches exactly one character
SELECT * FROM users WHERE name LIKE 'J_hn';      -- J + any char + hn

-- Combine patterns
SELECT * FROM users WHERE email LIKE '%@gmail.%';
```

### IS NULL / IS NOT NULL

Check for NULL values.

```sql
SELECT * FROM users WHERE phone IS NULL;
SELECT * FROM users WHERE email IS NOT NULL;
```

### EXISTS

Check if subquery returns any rows.

```sql
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders WHERE customer_id = c.id);
```

---

## Sorting & Limiting

### ORDER BY

Sort results.

```sql
-- Ascending (default)
SELECT * FROM users ORDER BY name;
SELECT * FROM users ORDER BY name ASC;

-- Descending
SELECT * FROM users ORDER BY created_at DESC;

-- Multiple columns
SELECT * FROM users ORDER BY status ASC, created_at DESC;

-- By column position
SELECT name, age FROM users ORDER BY 2;  -- Sort by age (2nd column)
```

### LIMIT

Restrict number of results.

```sql
-- First N rows
SELECT * FROM users LIMIT 10;

-- Skip rows (pagination)
SELECT * FROM users LIMIT 10 OFFSET 20;  -- Skip 20, get next 10

-- Alternative syntax
SELECT * FROM users LIMIT 20, 10;        -- Same as above
```

---

## String Functions

### CONCAT / CONCAT_WS

Combine strings.

```sql
-- Basic concatenation
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM users;

-- With separator
SELECT CONCAT_WS(' - ', title, author, year) AS book_info FROM books;
```

### SUBSTRING / SUBSTR

Extract part of string.

```sql
SELECT SUBSTRING('Hello World', 1, 5);    -- 'Hello' (start at 1, length 5)
SELECT SUBSTRING('Hello World', 7);       -- 'World' (from position 7 to end)
SELECT SUBSTRING('Hello World', -5);      -- 'World' (last 5 characters)
```

### REPLACE

Replace text within string.

```sql
SELECT REPLACE('Hello World', 'World', 'SQL');  -- 'Hello SQL'
SELECT REPLACE(email, '@old.com', '@new.com') FROM users;
```

### UPPER / LOWER

Change case.

```sql
SELECT UPPER('hello');   -- 'HELLO'
SELECT LOWER('HELLO');   -- 'hello'
```

### TRIM / LTRIM / RTRIM

Remove whitespace.

```sql
SELECT TRIM('  hello  ');    -- 'hello'
SELECT LTRIM('  hello');     -- 'hello'
SELECT RTRIM('hello  ');     -- 'hello'
```

### LENGTH / CHAR_LENGTH

Count characters.

```sql
SELECT CHAR_LENGTH('Hello');   -- 5 (characters)
SELECT LENGTH('Hello');        -- 5 (bytes, same for ASCII)
```

### LEFT / RIGHT

Extract from start or end.

```sql
SELECT LEFT('Hello World', 5);   -- 'Hello'
SELECT RIGHT('Hello World', 5);  -- 'World'
```

### REVERSE

Reverse string.

```sql
SELECT REVERSE('Hello');  -- 'olleH'
```

### LPAD / RPAD

Pad string to specified length.

```sql
SELECT LPAD('42', 5, '0');   -- '00042'
SELECT RPAD('Hi', 5, '!');   -- 'Hi!!!'
```

---

## Numeric Functions

### ROUND / CEIL / FLOOR

Round numbers.

```sql
SELECT ROUND(3.567, 2);   -- 3.57
SELECT ROUND(3.5);        -- 4
SELECT CEIL(3.1);         -- 4 (round up)
SELECT FLOOR(3.9);        -- 3 (round down)
```

### ABS

Absolute value.

```sql
SELECT ABS(-15);  -- 15
```

### MOD

Remainder of division.

```sql
SELECT MOD(10, 3);  -- 1
SELECT 10 % 3;      -- 1 (alternative)
```

### POWER / SQRT

Power and square root.

```sql
SELECT POWER(2, 3);  -- 8
SELECT SQRT(16);     -- 4
```

### RAND

Random number (0 to 1).

```sql
SELECT RAND();                    -- Random decimal
SELECT FLOOR(RAND() * 100);       -- Random 0-99
SELECT * FROM users ORDER BY RAND() LIMIT 1;  -- Random row
```

---

## Date & Time Functions

### Current Date/Time

```sql
SELECT NOW();              -- '2024-01-15 14:30:00'
SELECT CURDATE();          -- '2024-01-15'
SELECT CURTIME();          -- '14:30:00'
SELECT CURRENT_TIMESTAMP;  -- '2024-01-15 14:30:00'
```

### Extract Date Parts

```sql
SELECT YEAR('2024-01-15');     -- 2024
SELECT MONTH('2024-01-15');    -- 1
SELECT DAY('2024-01-15');      -- 15
SELECT HOUR('14:30:00');       -- 14
SELECT MINUTE('14:30:00');     -- 30
SELECT SECOND('14:30:00');     -- 0
SELECT DAYNAME('2024-01-15');  -- 'Monday'
SELECT MONTHNAME('2024-01-15');-- 'January'
SELECT DAYOFWEEK('2024-01-15');-- 2 (1=Sunday)
SELECT DAYOFYEAR('2024-01-15');-- 15
```

### DATE_FORMAT

Format date as string.

```sql
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d');          -- '2024-01-15'
SELECT DATE_FORMAT(NOW(), '%M %d, %Y');         -- 'January 15, 2024'
SELECT DATE_FORMAT(NOW(), '%W, %M %d at %h:%i %p'); -- 'Monday, January 15 at 02:30 PM'
```

Common format codes:

- `%Y` - 4-digit year
- `%y` - 2-digit year
- `%M` - Month name
- `%m` - Month number (01-12)
- `%d` - Day (01-31)
- `%H` - Hour 24h (00-23)
- `%h` - Hour 12h (01-12)
- `%i` - Minutes (00-59)
- `%s` - Seconds (00-59)
- `%p` - AM/PM
- `%W` - Weekday name

### Date Arithmetic

```sql
-- Add/subtract intervals
SELECT DATE_ADD('2024-01-15', INTERVAL 7 DAY);    -- '2024-01-22'
SELECT DATE_SUB('2024-01-15', INTERVAL 1 MONTH);  -- '2023-12-15'

-- Alternative syntax
SELECT '2024-01-15' + INTERVAL 1 YEAR;            -- '2025-01-15'

-- Difference between dates
SELECT DATEDIFF('2024-12-31', '2024-01-01');      -- 365 (days)
SELECT TIMESTAMPDIFF(MONTH, '2024-01-01', '2024-06-15'); -- 5 (months)
```

---

## Aggregate Functions

### COUNT

Count rows.

```sql
SELECT COUNT(*) FROM users;                  -- All rows (including NULL)
SELECT COUNT(email) FROM users;              -- Non-NULL values only
SELECT COUNT(DISTINCT status) FROM users;    -- Unique values
```

### SUM

Total of numeric column.

```sql
SELECT SUM(price) FROM orders;
SELECT SUM(quantity * price) AS total_revenue FROM order_items;
```

### AVG

Average of numeric column.

```sql
SELECT AVG(price) FROM products;
SELECT ROUND(AVG(rating), 2) AS avg_rating FROM reviews;
```

### MIN / MAX

Smallest/largest value.

```sql
SELECT MIN(price), MAX(price) FROM products;
SELECT MIN(created_at) AS oldest, MAX(created_at) AS newest FROM users;
```

---

## Grouping Data

### GROUP BY

Group rows with same values.

```sql
-- Count per group
SELECT status, COUNT(*) AS count FROM users GROUP BY status;

-- Multiple aggregates
SELECT
    category,
    COUNT(*) AS products,
    AVG(price) AS avg_price,
    SUM(quantity) AS total_stock
FROM products
GROUP BY category;

-- Group by multiple columns
SELECT
    year,
    month,
    SUM(sales) AS total_sales
FROM orders
GROUP BY year, month;
```

### HAVING

Filter groups (like WHERE but for aggregates).

```sql
-- Filter after grouping
SELECT status, COUNT(*) AS count
FROM users
GROUP BY status
HAVING COUNT(*) > 10;

-- Combine WHERE and HAVING
SELECT category, AVG(price) AS avg_price
FROM products
WHERE status = 'active'
GROUP BY category
HAVING AVG(price) > 50;
```

### WITH ROLLUP

Add subtotals and grand total.

```sql
SELECT category, SUM(price) AS total
FROM products
GROUP BY category WITH ROLLUP;
-- Result includes NULL row with grand total
```

---

## Joins

### INNER JOIN

Only matching rows from both tables.

```sql
SELECT users.name, orders.amount
FROM users
INNER JOIN orders ON users.id = orders.user_id;

-- Short syntax
SELECT u.name, o.amount
FROM users u
JOIN orders o ON u.id = o.user_id;
```

### LEFT JOIN

All from left table + matching from right.

```sql
SELECT u.name, o.amount
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;
-- Users without orders will have NULL for amount
```

### RIGHT JOIN

All from right table + matching from left.

```sql
SELECT u.name, o.amount
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;
-- Orders without users will have NULL for name
```

### FULL OUTER JOIN

All rows from both tables (MySQL workaround).

```sql
-- MySQL doesn't have FULL OUTER JOIN, use UNION
SELECT u.name, o.amount FROM users u LEFT JOIN orders o ON u.id = o.user_id
UNION
SELECT u.name, o.amount FROM users u RIGHT JOIN orders o ON u.id = o.user_id;
```

### CROSS JOIN

Every combination (Cartesian product).

```sql
SELECT colors.name, sizes.name
FROM colors
CROSS JOIN sizes;
-- If colors has 3 rows and sizes has 4, result has 12 rows
```

### SELF JOIN

Join table with itself.

```sql
-- Find employees and their managers
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### Multiple Joins

```sql
SELECT
    u.name AS user,
    o.id AS order_id,
    p.name AS product
FROM users u
JOIN orders o ON u.id = o.user_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id;
```

---

## Subqueries

### Subquery in WHERE

```sql
-- Find users with above-average age
SELECT * FROM users
WHERE age > (SELECT AVG(age) FROM users);

-- Find users who have orders
SELECT * FROM users
WHERE id IN (SELECT DISTINCT user_id FROM orders);
```

### Subquery in FROM

```sql
-- Use subquery as a table
SELECT category, avg_price
FROM (
    SELECT category, AVG(price) AS avg_price
    FROM products
    GROUP BY category
) AS category_stats
WHERE avg_price > 100;
```

### Subquery in SELECT

```sql
-- Add calculated column
SELECT
    name,
    price,
    (SELECT AVG(price) FROM products) AS avg_price,
    price - (SELECT AVG(price) FROM products) AS diff_from_avg
FROM products;
```

### Correlated Subquery

Subquery references outer query.

```sql
-- Find products priced above their category average
SELECT p.name, p.price, p.category
FROM products p
WHERE p.price > (
    SELECT AVG(price) FROM products WHERE category = p.category
);
```

---

## Set Operations

### UNION

Combine results (removes duplicates).

```sql
SELECT name FROM users
UNION
SELECT name FROM admins;
```

### UNION ALL

Combine results (keeps duplicates).

```sql
SELECT name FROM users
UNION ALL
SELECT name FROM admins;
```

### INTERSECT

Rows in both results (MySQL 8.0.31+).

```sql
SELECT name FROM users
INTERSECT
SELECT name FROM premium_users;
```

### EXCEPT

Rows in first but not second (MySQL 8.0.31+).

```sql
SELECT name FROM users
EXCEPT
SELECT name FROM banned_users;
```

---

## Views

### CREATE VIEW

Virtual table based on query.

```sql
CREATE VIEW active_users AS
SELECT id, name, email
FROM users
WHERE status = 'active';

-- Use like regular table
SELECT * FROM active_users;
```

### CREATE OR REPLACE VIEW

Update existing view.

```sql
CREATE OR REPLACE VIEW active_users AS
SELECT id, name, email, created_at
FROM users
WHERE status = 'active';
```

### DROP VIEW

Remove view.

```sql
DROP VIEW active_users;
DROP VIEW IF EXISTS active_users;
```

---

## Indexes

### CREATE INDEX

Speed up queries.

```sql
-- Single column index
CREATE INDEX idx_email ON users(email);

-- Multi-column index
CREATE INDEX idx_name ON users(last_name, first_name);

-- Unique index
CREATE UNIQUE INDEX idx_email ON users(email);
```

### DROP INDEX

Remove index.

```sql
DROP INDEX idx_email ON users;
```

### SHOW INDEXES

List indexes on table.

```sql
SHOW INDEX FROM users;
```

---

## Transactions

### Basic Transaction

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;    -- Save changes
-- or
ROLLBACK;  -- Undo changes
```

### SAVEPOINT

Partial rollback.

```sql
START TRANSACTION;

INSERT INTO orders VALUES (...);
SAVEPOINT order_created;

INSERT INTO order_items VALUES (...);
-- Something went wrong with items
ROLLBACK TO order_created;  -- Undo only items

COMMIT;  -- Order is still saved
```

### Isolation Levels

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Options: READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE
```

---

## Quick Reference Card

### Query Order of Execution

```
1. FROM       - Choose tables
2. JOIN       - Combine tables
3. WHERE      - Filter rows
4. GROUP BY   - Group rows
5. HAVING     - Filter groups
6. SELECT     - Choose columns
7. DISTINCT   - Remove duplicates
8. ORDER BY   - Sort results
9. LIMIT      - Limit results
```

### Common Patterns

```sql
-- Pagination
SELECT * FROM users ORDER BY id LIMIT 10 OFFSET 20;

-- Search
SELECT * FROM products WHERE name LIKE '%keyword%';

-- Date range
SELECT * FROM orders WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';

-- Top N per group (MySQL 8.0+)
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
    FROM products
)
SELECT * FROM ranked WHERE rn <= 3;

-- Handle NULL
SELECT COALESCE(nickname, name, 'Anonymous') AS display_name FROM users;
SELECT IFNULL(phone, 'N/A') AS phone FROM users;
```

---

## Tips & Best Practices

1. **Always use WHERE with UPDATE/DELETE** - Avoid accidental mass changes
2. **Test with SELECT first** - Before UPDATE/DELETE, run SELECT to see affected rows
3. **Use aliases** - Make queries readable with `AS`
4. **Index foreign keys** - Speed up JOIN queries
5. **Avoid SELECT \*** - Specify columns for better performance
6. **Use transactions** - For multiple related changes
7. **Handle NULL** - Use IS NULL, IFNULL, COALESCE appropriately

---

_Last updated: January 2026_
