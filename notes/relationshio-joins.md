# Relationships and Joins in SQL

## Introduction

So far, we've been working with very simple data. But that's about to change. Real-world data is messy and interrelated. Think about the relationships between:

- **Books** and **Authors**
- **Books** and **Genres**
- **Customers** and **Orders**
- **Books** and **Reviews**
- **Books** and **Versions**

Understanding how to model and query these relationships is crucial for working with real databases.

---

## Relationship Basics

There are three fundamental types of relationships in database design:

1. **One-to-One Relationship**
2. **One-to-Many Relationship** (Most Common)
3. **Many-to-Many Relationship**

In this guide, we'll focus primarily on the **One-to-Many** relationship, which is the most common pattern you'll encounter.

---

## One-to-Many: The Most Common Relationship

### Example: Customers & Orders

Let's say we want to store:

- A customer's first and last name
- A customer's email
- The date of the purchase
- The price of the order

### The Wrong Way: One Table

You might be tempted to put everything in a single table:

| first_name | last_name | email            | order_date   | amount |
| ---------- | --------- | ---------------- | ------------ | ------ |
| Boy        | George    | george@gmail.com | '2016/02/10' | 99.99  |
| Boy        | George    | george@gmail.com | '2017/11/11' | 35.50  |
| George     | Michael   | gm@gmail.com     | '2014/12/12' | 800.67 |
| George     | Michael   | gm@gmail.com     | '2015/01/03' | 12.50  |
| David      | Bowie     | david@gmail.com  | NULL         | NULL   |
| Blue       | Steele    | blue@gmail.com   | NULL         | NULL   |

**This is NOT a good idea!** Why?

- Data duplication (customer info repeated for each order)
- Wasted storage space
- Difficult to update customer information
- NULL values for customers without orders

### The Right Way: Two Tables

Instead, we create two separate tables:

#### Customers Table

| customer_id | first_name | last_name | email            |
| ----------- | ---------- | --------- | ---------------- |
| 1           | Boy        | George    | george@gmail.com |
| 2           | George     | Michael   | gm@gmail.com     |
| 3           | David      | Bowie     | david@gmail.com  |
| 4           | Blue       | Steele    | blue@gmail.com   |

#### Orders Table

| order_id | order_date   | amount | customer_id |
| -------- | ------------ | ------ | ----------- |
| 1        | '2016/02/10' | 99.99  | 1           |
| 2        | '2017/11/11' | 35.50  | 1           |
| 3        | '2014/12/12' | 800.67 | 2           |
| 4        | '2015/01/03' | 12.50  | 2           |

### Understanding Keys

- **PRIMARY KEY**: A unique identifier for each row in a table (e.g., `customer_id` in the Customers table, `order_id` in the Orders table)
- **FOREIGN KEY**: A column that references the primary key of another table (e.g., `customer_id` in the Orders table references `customer_id` in the Customers table)

The `customer_id` in the Orders table is a **foreign key** that creates the relationship between customers and their orders.

---

## Joins: Combining Data from Multiple Tables

Once you have related data in separate tables, you need a way to combine them. That's where **JOINs** come in.

### INNER JOIN

**INNER JOIN** selects all records from both tables where the join condition is met. It only returns rows that have matching values in both tables.

```sql
SELECT *
FROM customers
JOIN orders
ON customers.id = orders.customer_id;
```

**Visual Representation:**

```
Select all records from A and B where the join condition is met
```

**Result:** Only customers who have orders will appear in the result set.

### LEFT JOIN

**LEFT JOIN** selects everything from the left table (first table mentioned), along with any matching records from the right table. If there's no match, NULL values are returned for the right table columns.

**Visual Representation:**

```
Select everything from A, along with any matching records in B
```

**Result:** All customers appear, even if they have no orders (order columns will be NULL).

### RIGHT JOIN

**RIGHT JOIN** selects everything from the right table (second table mentioned), along with any matching records from the left table. If there's no match, NULL values are returned for the left table columns.

**Visual Representation:**

```
Select everything from B, along with any matching records in A
```

**Result:** All orders appear, even if the customer doesn't exist in the customers table (customer columns will be NULL).

---

## Practice Exercise: Students and Papers

Let's practice with a real example!

### Schema Design

Create two tables:

#### STUDENTS Table

- `id` (primary key)
- `first_name`

#### PAPERS Table

- `id` (primary key)
- `title`
- `grade`
- `student_id` (foreign key referencing students.id)

### Insert Data

```sql
INSERT INTO students (first_name) VALUES
('Caleb'), ('Samantha'), ('Raj'), ('Carlos'), ('Lisa');

INSERT INTO papers (student_id, title, grade) VALUES
(1, 'My First Book Report', 60),
(1, 'My Second Book Report', 75),
(2, 'Russian Lit Through The Ages', 94),
(2, 'De Montaigne and The Art of The Essay', 98),
(4, 'Borges and Magical Realism', 89);
```

### Exercise 1: INNER JOIN

Print all students with their papers (only students who have submitted papers):

**Expected Output:**

| first_name | title                                 | grade |
| ---------- | ------------------------------------- | ----- |
| Samantha   | De Montaigne and The Art of The Essay | 98    |
| Samantha   | Russian Lit Through The Ages          | 94    |
| Carlos     | Borges and Magical Realism            | 89    |
| Caleb      | My Second Book Report                 | 75    |
| Caleb      | My First Book Report                  | 60    |

**Solution:**

```sql
SELECT first_name, title, grade
FROM students
JOIN papers
ON students.id = papers.student_id
ORDER BY grade DESC;
```

### Exercise 2: LEFT JOIN

Print all students with their papers (including students who haven't submitted any papers):

**Expected Output:**

| first_name | title                                 | grade |
| ---------- | ------------------------------------- | ----- |
| Caleb      | My First Book Report                  | 60    |
| Caleb      | My Second Book Report                 | 75    |
| Samantha   | Russian Lit Through The Ages          | 94    |
| Samantha   | De Montaigne and The Art of The Essay | 98    |
| Raj        | NULL                                  | NULL  |
| Carlos     | Borges and Magical Realism            | 89    |
| Lisa       | NULL                                  | NULL  |

**Solution:**

```sql
SELECT first_name, title, grade
FROM students
LEFT JOIN papers
ON students.id = papers.student_id
ORDER BY grade DESC;
```

### Exercise 3: LEFT JOIN with IFNULL

Print all students with their papers, showing "MISSING" for title and 0 for grade if they haven't submitted any papers:

**Expected Output:**

| first_name | title                                 | grade |
| ---------- | ------------------------------------- | ----- |
| Caleb      | My First Book Report                  | 60    |
| Caleb      | My Second Book Report                 | 75    |
| Samantha   | Russian Lit Through The Ages          | 94    |
| Samantha   | De Montaigne and The Art of The Essay | 98    |
| Raj        | MISSING                               | 0     |
| Carlos     | Borges and Magical Realism            | 89    |
| Lisa       | MISSING                               | 0     |

**Solution:**

```sql
SELECT
    first_name,
    IFNULL(title, 'MISSING') AS title,
    IFNULL(grade, 0) AS grade
FROM students
LEFT JOIN papers
ON students.id = papers.student_id
ORDER BY grade DESC;
```

### Exercise 4: Calculate Average Grades

Print each student's first name and their average grade:

**Expected Output:**

| first_name | average |
| ---------- | ------- |
| Samantha   | 96.0000 |
| Carlos     | 89.0000 |
| Caleb      | 67.5000 |
| Raj        | 0       |
| Lisa       | 0       |

**Solution:**

```sql
SELECT
    first_name,
    IFNULL(AVG(grade), 0) AS average
FROM students
LEFT JOIN papers
ON students.id = papers.student_id
GROUP BY students.id, first_name
ORDER BY average DESC;
```

### Exercise 5: Add Passing Status

Print each student's first name, average grade, and passing status (PASSING if average >= 75, FAILING otherwise):

**Expected Output:**

| first_name | average | passing_status |
| ---------- | ------- | -------------- |
| Samantha   | 96.0000 | PASSING        |
| Carlos     | 89.0000 | PASSING        |
| Caleb      | 67.5000 | FAILING        |
| Raj        | 0       | FAILING        |
| Lisa       | 0       | FAILING        |

**Solution:**

```sql
SELECT
    first_name,
    IFNULL(AVG(grade), 0) AS average,
    CASE
        WHEN IFNULL(AVG(grade), 0) >= 75 THEN 'PASSING'
        ELSE 'FAILING'
    END AS passing_status
FROM students
LEFT JOIN papers
ON students.id = papers.student_id
GROUP BY students.id, first_name
ORDER BY average DESC;
```

---

## Key Takeaways

1. **Normalize your data**: Split related data into separate tables to avoid duplication and maintain data integrity.

2. **Use Foreign Keys**: Create relationships between tables using foreign keys that reference primary keys in other tables.

3. **Choose the Right JOIN**:

   - Use **INNER JOIN** when you only want matching records
   - Use **LEFT JOIN** when you want all records from the left table, even without matches
   - Use **RIGHT JOIN** when you want all records from the right table, even without matches

4. **Handle NULL values**: Use functions like `IFNULL()` or `COALESCE()` to provide default values when joins don't find matches.

5. **Aggregate with GROUP BY**: When using aggregate functions like `AVG()`, `COUNT()`, or `SUM()` with joins, remember to use `GROUP BY` to group results appropriately.

---

## Next Steps

Now that you understand one-to-many relationships and basic joins, you're ready to explore:

- Many-to-many relationships
- Self-joins
- Complex join conditions
- Performance optimization with indexes

Happy querying! 🚀
