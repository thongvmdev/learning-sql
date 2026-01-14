# INSERT - Adding Data to Your Tables

## Basic INSERT Syntax

```sql
INSERT INTO cats(name, age)
VALUES ('Jetson', 7);
```

**Note:** Both single quotes `'` and double quotes `"` work in SQL for string values.

### Formatting Variations

All of these are valid:

```sql
-- One line
INSERT INTO cats(name, age) VALUES ("Jetson", 7);

-- Multi-line
INSERT INTO cats
(name, age)
VALUES
("jetson", 7);
```

## Important: Order Matters!

When inserting data, the VALUES must match the column order you specify:

```sql
INSERT INTO cats (age, name)
VALUES (12, 'Victoria');
```

Here, `12` goes to `age` and `'Victoria'` goes to `name`.

## Viewing Your Data

To verify your insertions worked:

```sql
SELECT * FROM cats;
```

## Multiple INSERT

Insert multiple rows in a single statement:

```sql
INSERT INTO cats(name, age)
VALUES
  ('Charlie', 10),
  ('Sadie', 3),
  ('Lazy Bear', 1);
```

## Checking Errors

To view errors and warnings:

```sql
SHOW WARNINGS;
```

---

## NULL Values

### What is NULL?

- NULL means "The Value Is Not Known"
- **NULL Does Not Mean Zero!**
- NULL represents the absence of a value

### The Problem

Without constraints, you can insert incomplete data:

```sql
-- This works but leaves age as NULL
INSERT INTO cats(name)
VALUES ('Bean');

-- This even works, leaving everything as NULL!
INSERT INTO cats()
VALUES ();
```

---

## NOT NULL Constraint

### Preventing NULL Values

```sql
CREATE TABLE cats2 (
  name VARCHAR(100) NOT NULL,
  age INT NOT NULL
);
```

Now the table shows:

| Field | Type         | Null | Key | Default | Extra |
| ----- | ------------ | ---- | --- | ------- | ----- |
| name  | varchar(100) | NO   |     | NULL    |       |
| age   | int(11)      | NO   |     | NULL    |       |

**Note:** The Default shows NULL but the Null column says NO - this means if you try to insert NULL, it will be rejected.

---

## DEFAULT Values

### Setting Default Values

```sql
CREATE TABLE cats3 (
  name VARCHAR(100) DEFAULT 'unnamed',
  age INT DEFAULT 99
);
```

### Combining NOT NULL with DEFAULT

```sql
CREATE TABLE cats4 (
  name VARCHAR(100) NOT NULL DEFAULT 'unnamed',
  age INT NOT NULL DEFAULT 99
);
```

**Why both?** Without NOT NULL, you can still manually set values to NULL:

```sql
-- This works without NOT NULL constraint
INSERT INTO cats3(name, age)
VALUES(NULL, 3);
```

---

## Primary Keys

### The Problem: Duplicate Rows

Without a unique identifier, you can have duplicate rows:

| Name  | Breed | Age |
| ----- | ----- | --- |
| Monty | Tabby | 10  |
| Monty | Tabby | 10  |
| Monty | Tabby | 10  |
| Monty | Tabby | 10  |

### The Solution: Primary Key

A Primary Key is a unique identifier for each row:

| Name  | Breed | Age | CatID |
| ----- | ----- | --- | ----- |
| Monty | Tabby | 10  | 1     |
| Monty | Tabby | 10  | 2     |
| Monty | Tabby | 10  | 3     |
| Monty | Tabby | 10  | 4     |

### Creating a Primary Key

**Method 1:**

```sql
CREATE TABLE unique_cats (
  cat_id INT NOT NULL PRIMARY KEY,
  name VARCHAR(100),
  age INT
);
```

**Method 2:**

```sql
CREATE TABLE unique_cats (
  cat_id INT NOT NULL,
  name VARCHAR(100),
  age INT,
  PRIMARY KEY(cat_id)
);
```

**Note:** NOT NULL is redundant with PRIMARY KEY - Primary Keys cannot be NULL!

```sql
CREATE TABLE unique_cats (
  cat_id INT,
  name VARCHAR(100),
  age INT,
  PRIMARY KEY(cat_id)
);
```

---

## AUTO_INCREMENT

Automatically increment the ID for each new row:

```sql
CREATE TABLE unique_cats3 (
  cat_id INT AUTO_INCREMENT,
  name VARCHAR(100),
  age INT,
  PRIMARY KEY (cat_id)
);
```

The `cat_id` will automatically increment (1, 2, 3, 4...) for each new cat inserted.

---

## Practice Exercises

### Exercise 1: Create a People Table

Create a table with:

- `first_name` - 20 char limit
- `last_name` - 20 char limit
- `age`

### Exercise 2: Insert Single Rows

Insert Tina:

```sql
INSERT INTO people(first_name, last_name, age)
VALUES ('Tina', 'Belcher', 13);
```

Insert Bob:

```sql
INSERT INTO people(first_name, last_name, age)
VALUES ('Bob', 'Belcher', 42);
```

### Exercise 3: Multiple Insert

Insert multiple people at once:

```sql
INSERT INTO people(first_name, last_name, age)
VALUES
  ('Linda', 'Belcher', 45),
  ('Phillip', 'Frond', 38),
  ('Calvin', 'Fischoeder', 70);
```

---

## Complete Example: Employees Table

Define an Employees table with:

- `id` - number (automatically increments) and primary key
- `last_name` - text, mandatory
- `first_name` - text, mandatory
- `middle_name` - text, not mandatory
- `age` - number, mandatory
- `current_status` - text, mandatory, defaults to 'employed'

### Solution:

```sql
CREATE TABLE employees (
  id INT AUTO_INCREMENT PRIMARY KEY,
  last_name VARCHAR(100) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  middle_name VARCHAR(100),
  age INT NOT NULL,
  current_status VARCHAR(100) NOT NULL DEFAULT 'employed'
);
```

---

## Key Takeaways

1. **INSERT** adds data to tables
2. Column order matters when inserting
3. Use **NOT NULL** to prevent NULL values
4. Use **DEFAULT** to set default values
5. Use **PRIMARY KEY** for unique identifiers
6. Use **AUTO_INCREMENT** to automatically generate IDs
7. Use **SHOW WARNINGS** to check for errors
8. Multiple rows can be inserted in one statement
