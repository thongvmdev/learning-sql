# SQL > Many-to-Many Relationships

## Overview

Many-to-many relationships are a bit trickier than one-to-many relationships, but they're essential for modeling complex real-world scenarios.

## Examples of Many-to-Many Relationships

- **Books <-> Authors**: A book can have multiple authors, and an author can write multiple books
- **Blog Posts <-> Tags**: A post can have multiple tags, and a tag can be applied to multiple posts
- **Students <-> Classes**: A student can enroll in multiple classes, and a class can have multiple students

## Why Junction Tables Are Essential

### The Problem Without a Junction Table

When modeling many-to-many relationships, you might be tempted to avoid junction tables, but this creates serious problems:

#### ❌ Bad Approach 1: Store Multiple Values in One Column

```sql
-- Series Table (BAD DESIGN)
id | title  | reviewer_ids
---|--------|-------------
1  | Archer | 1,2,3,4,5
2  | Fargo  | 2,5
```

**Problems:**

1. **Violates First Normal Form** - Cannot store multiple values in one field
2. **Cannot query efficiently** - How do you find all series reviewed by reviewer #2?
3. **Cannot enforce foreign keys** - Database cannot validate the IDs
4. **No place for relationship data** - Where do you store the rating?
5. **Hard to update** - Adding/removing a reviewer requires string manipulation

#### ❌ Bad Approach 2: Duplicate Rows

```sql
-- Series Table (BAD DESIGN)
id | title  | reviewer_id | rating
---|--------|-------------|--------
1  | Archer | 1           | 8.0
1  | Archer | 2           | 7.5
1  | Archer | 3           | 8.5
2  | Fargo  | 2           | 9.1
2  | Fargo  | 5           | 9.7
```

**Problems:**

1. **Data redundancy** - Series info (title, year, genre) duplicated for each review
2. **Update anomalies** - Changing "Archer" to "Archer Season 1" requires updating multiple rows
3. **Delete anomalies** - Deleting all reviews loses the series data
4. **Insert anomalies** - Cannot add a series without a reviewer
5. **Wastes storage** - Duplicating series data unnecessarily

### ✅ The Correct Solution: Junction Table

```sql
-- Three separate tables (GOOD DESIGN)

Series Table:
id | title  | released_year | genre
---|--------|---------------|----------
1  | Archer | 2009          | Animation
2  | Fargo  | 2014          | Drama

Reviewers Table:
id | first_name | last_name
---|------------|----------
1  | Thomas     | Stoneman
2  | Wyatt      | Skaggs

Reviews Table (Junction):
id | series_id | reviewer_id | rating
---|-----------|-------------|--------
1  | 1         | 1           | 8.0
2  | 1         | 2           | 7.5
3  | 2         | 2           | 9.1
```

**Benefits:**

1. **No Data Duplication**
   - Series data stored once
   - Reviewer data stored once
   - Only the relationship is duplicated (which is necessary)

2. **Easy to Query**

   ```sql
   -- Find all reviewers for a series
   SELECT * FROM reviewers r
   JOIN reviews rv ON r.id = rv.reviewer_id
   WHERE rv.series_id = 1;

   -- Find all series reviewed by a reviewer
   SELECT * FROM series s
   JOIN reviews rv ON s.id = rv.series_id
   WHERE rv.reviewer_id = 2;
   ```

3. **Store Relationship-Specific Data**
   - The `rating` belongs to the **relationship** between a series and reviewer
   - Junction table is the perfect place for it
   - Can add more relationship data: `review_date`, `comment`, etc.

4. **Data Integrity with Foreign Keys**

   ```sql
   FOREIGN KEY (series_id) REFERENCES series(id)
   FOREIGN KEY (reviewer_id) REFERENCES reviewers(id)
   ```

5. **Flexible Updates**

   ```sql
   -- Add a review: just insert one row
   INSERT INTO reviews (series_id, reviewer_id, rating)
   VALUES (1, 3, 8.5);

   -- Remove a review: just delete one row
   DELETE FROM reviews WHERE id = 2;

   -- No impact on series or reviewer data!
   ```

### Real-World Example: Students & Classes

**Problem:** Where do you store the grade?

- Cannot store it in Students table (one student has many classes)
- Cannot store it in Classes table (one class has many students)

**Solution:** Junction table stores the relationship data

```sql
Students Table:          Classes Table:           Enrollments (Junction):
--------------          ---------------          ------------------------
student_id              class_id                 student_id | class_id | grade
name                    class_name               -----------|----------|-------
                                                 1          | 101      | A
                                                 1          | 102      | B+
                                                 2          | 101      | A-
```

The `grade` belongs to the **enrollment** (the relationship), not to the student or class alone.

### Summary: Why Junction Tables Are Mandatory

**Junction tables solve:**

- ✅ Data normalization (no duplication)
- ✅ Referential integrity (foreign keys)
- ✅ Storage for relationship-specific data
- ✅ Efficient queries
- ✅ Easy maintenance (add/remove/update relationships)

**Without them, you get:**

- ❌ Data duplication
- ❌ Update/delete/insert anomalies
- ❌ Poor query performance
- ❌ No referential integrity
- ❌ Difficult maintenance

This is why junction tables are a **fundamental pattern** in relational database design!

## Case Study: TV Show Reviewing Application

### Database Schema

We'll build a TV show reviewing application with three main tables:

#### 1. Series Table

```sql
id             INT
title          VARCHAR
released_year  INT
genre          VARCHAR
```

#### 2. Reviewers Table

```sql
id          INT
first_name  VARCHAR
last_name   VARCHAR
```

#### 3. Reviews Table (Junction Table)

```sql
id           INT
rating       DECIMAL
series_id    INT (Foreign Key)
reviewer_id  INT (Foreign Key)
```

### Sample Data Structure

**Series:**
| id | title | released_year | genre |
|----|-------|---------------|-------|
| 1 | Archer | 2009 | Animation |
| 2 | Fargo | 2014 | Drama |

**Reviewers:**
| id | first_name | last_name |
|----|------------|-----------|
| 1 | Blue | Steele |
| 2 | Wyatt | Earp |

**Reviews:**
| id | rating | reviewer_id | series_id |
|----|--------|-------------|-----------|
| 1 | 8.9 | 1 | 2 |
| 2 | 9.5 | 2 | 2 |

## Inserting Sample Data

### Insert Series Data

```sql
INSERT INTO series (title, released_year, genre) VALUES
('Archer', 2009, 'Animation'),
('Arrested Development', 2003, 'Comedy'),
("Bob's Burgers", 2011, 'Animation'),
('Bojack Horseman', 2014, 'Animation'),
("Breaking Bad", 2008, 'Drama'),
('Curb Your Enthusiasm', 2000, 'Comedy'),
("Fargo", 2014, 'Drama'),
('Freaks and Geeks', 1999, 'Comedy'),
('General Hospital', 1963, 'Drama'),
('Halt and Catch Fire', 2014, 'Drama'),
('Malcolm In The Middle', 2000, 'Comedy'),
('Pushing Daisies', 2007, 'Comedy'),
('Seinfeld', 1989, 'Comedy'),
('Stranger Things', 2016, 'Drama');
```

### Insert Reviewers Data

```sql
INSERT INTO reviewers (first_name, last_name) VALUES
('Thomas', 'Stoneman'),
('Wyatt', 'Skaggs'),
('Kimbra', 'Masters'),
('Domingo', 'Cortes'),
('Colt', 'Steele'),
('Pinkie', 'Petit'),
('Marlon', 'Crafford');
```

### Insert Reviews Data

```sql
INSERT INTO reviews(series_id, reviewer_id, rating) VALUES
(1,1,8.0),(1,2,7.5),(1,3,8.5),(1,4,7.7),(1,5,8.9),
(2,1,8.1),(2,4,6.0),(2,3,8.0),(2,6,8.4),(2,5,9.9),
(3,1,7.0),(3,6,7.5),(3,4,8.0),(3,3,7.1),(3,5,8.0),
(4,1,7.5),(4,3,7.8),(4,4,8.3),(4,2,7.6),(4,5,8.5),
(5,1,9.5),(5,3,9.0),(5,4,9.1),(5,2,9.3),(5,5,9.9),
(6,2,6.5),(6,3,7.8),(6,4,8.8),(6,2,8.4),(6,5,9.1),
(7,2,9.1),(7,5,9.7),
(8,4,8.5),(8,2,7.8),(8,6,8.8),(8,5,9.3),
(9,2,5.5),(9,3,6.8),(9,4,5.8),(9,6,4.3),(9,5,4.5),
(10,5,9.9),
(13,3,8.0),(13,4,7.2),
(14,2,8.5),(14,3,8.9),(14,4,8.9);
```

## Query Examples

### 1. Basic Join - Series and Ratings

```sql
SELECT title, rating
FROM series
JOIN reviews ON series.id = reviews.series_id;
```

**Sample Output:**
| title | rating |
|----------------------|--------|
| Archer | 8.0 |
| Archer | 7.5 |
| Archer | 8.5 |
| Arrested Development | 8.1 |
| Bob's Burgers | 7.0 |

### 2. Average Rating Per Series

```sql
SELECT title, AVG(rating) AS avg_rating
FROM series
JOIN reviews ON series.id = reviews.series_id
GROUP BY series.id
ORDER BY avg_rating;
```

**Sample Output:**
| title | avg_rating |
|----------------------|------------|
| General Hospital | 5.38000 |
| Bob's Burgers | 7.52000 |
| Seinfeld | 7.60000 |
| Bojack Horseman | 7.94000 |
| Breaking Bad | 9.36000 |
| Fargo | 9.40000 |
| Halt and Catch Fire | 9.90000 |

### 3. Reviewers and Their Ratings

```sql
SELECT first_name, last_name, rating
FROM reviewers
JOIN reviews ON reviewers.id = reviews.reviewer_id;
```

**Sample Output:**
| first_name | last_name | rating |
|------------|-----------|--------|
| Thomas | Stoneman | 8.0 |
| Thomas | Stoneman | 8.1 |
| Wyatt | Skaggs | 7.5 |
| Kimbra | Masters | 8.5 |

### 4. Finding Unreviewed Series

```sql
SELECT title AS unreviewed_series
FROM series
LEFT JOIN reviews ON series.id = reviews.series_id
WHERE rating IS NULL;
```

**Sample Output:**
| unreviewed_series |
|-----------------------|
| Malcolm In The Middle |
| Pushing Daisies |

### 5. Average Rating by Genre

```sql
SELECT genre, AVG(rating) AS avg_rating
FROM series
JOIN reviews ON series.id = reviews.series_id
GROUP BY genre;
```

**Sample Output:**
| genre | avg_rating |
|-----------|------------|
| Animation | 7.86000 |
| Comedy | 8.16250 |
| Drama | 8.04375 |

### 6. Comprehensive Reviewer Statistics

```sql
SELECT
    first_name,
    last_name,
    COUNT(rating) AS COUNT,
    IFNULL(MIN(rating), 0) AS MIN,
    IFNULL(MAX(rating), 0) AS MAX,
    IFNULL(AVG(rating), 0) AS AVG,
    CASE
        WHEN COUNT(rating) > 0 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END AS STATUS
FROM reviewers
LEFT JOIN reviews ON reviewers.id = reviews.reviewer_id
GROUP BY reviewers.id;
```

**Sample Output:**
| first_name | last_name | COUNT | MIN | MAX | AVG | STATUS |
|------------|-----------|-------|-----|-----|---------|----------|
| Thomas | Stoneman | 5 | 7.0 | 9.5 | 8.02000 | ACTIVE |
| Wyatt | Skaggs | 9 | 5.5 | 9.3 | 7.80000 | ACTIVE |
| Kimbra | Masters | 9 | 6.8 | 9.0 | 7.98889 | ACTIVE |
| Colt | Steele | 10 | 4.5 | 9.9 | 8.77000 | ACTIVE |
| Marlon | Crafford | 0 | 0.0 | 0.0 | 0.00000 | INACTIVE |

### 7. Three-Way Join - Series, Reviews, and Reviewers

```sql
SELECT
    title,
    rating,
    CONCAT(first_name, ' ', last_name) AS reviewer
FROM series
JOIN reviews ON series.id = reviews.series_id
JOIN reviewers ON reviews.reviewer_id = reviewers.id
ORDER BY title;
```

**Sample Output:**
| title | rating | reviewer |
|----------------------|--------|-----------------|
| Archer | 8.0 | Thomas Stoneman |
| Archer | 7.7 | Domingo Cortes |
| Archer | 8.5 | Kimbra Masters |
| Arrested Development | 8.4 | Pinkie Petit |
| Arrested Development | 9.9 | Colt Steele |
| Bob's Burgers | 7.0 | Thomas Stoneman |

## Advanced Topics

### MySQL Views

Views are virtual tables based on the result of a SQL statement. They can simplify complex queries and provide a layer of abstraction.

```sql
CREATE VIEW series_ratings AS
SELECT title, AVG(rating) AS avg_rating
FROM series
JOIN reviews ON series.id = reviews.series_id
GROUP BY series.id;
```

### GROUP BY with HAVING

The `HAVING` clause filters grouped results (unlike `WHERE` which filters rows before grouping).

```sql
SELECT genre, AVG(rating) AS avg_rating
FROM series
JOIN reviews ON series.id = reviews.series_id
GROUP BY genre
HAVING avg_rating > 8.0;
```

### GROUP BY with ROLLUP

`ROLLUP` generates subtotals and grand totals in grouped results.

```sql
SELECT genre, COUNT(*) AS total
FROM series
GROUP BY genre WITH ROLLUP;
```

## SQL Modes

SQL modes control how MySQL handles various SQL syntax and validation rules.

### Viewing Current SQL Modes

```sql
-- View global SQL mode
SELECT @@GLOBAL.sql_mode;

-- View session SQL mode
SELECT @@SESSION.sql_mode;
```

### Setting SQL Modes

```sql
-- Set global SQL mode
SET GLOBAL sql_mode = 'modes';

-- Set session SQL mode
SET SESSION sql_mode = 'modes';
```

## Key Takeaways

1. **Junction Tables**: Many-to-many relationships require a junction table (like `reviews`) that connects two tables with foreign keys
2. **Complex Joins**: You can join multiple tables to get comprehensive data
3. **Aggregation**: Use aggregate functions with `GROUP BY` to analyze patterns in many-to-many relationships
4. **NULL Handling**: Use `LEFT JOIN` and `IFNULL` to handle cases where relationships don't exist
5. **Status Tracking**: Use `CASE` statements to derive status fields based on relationship data
