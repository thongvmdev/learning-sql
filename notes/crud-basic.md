# MySQL - The Basics of CRUD

## What is CRUD?

CRUD stands for:

- **C**reate
- **R**ead
- **U**pdate
- **D**elete

These are the four basic operations for persistent storage.

---

## Create

### INSERT INTO Syntax

```sql
INSERT INTO cats (name, age)
VALUES ('Taco', 14);
```

### Setting Up Our Example Table

First, let's start with a clean slate:

```sql
DROP TABLE cats;
```

Then create a new table:

```sql
CREATE TABLE cats
(
    cat_id INT AUTO_INCREMENT,
    name   VARCHAR(100),
    breed  VARCHAR(100),
    age    INT,
    PRIMARY KEY (cat_id)
);
```

### Insert Sample Data

```sql
INSERT INTO cats(name, breed, age)
VALUES ('Ringo', 'Tabby', 4),
       ('Cindy', 'Maine Coon', 10),
       ('Dumbledore', 'Maine Coon', 11),
       ('Egg', 'Persian', 4),
       ('Misty', 'Tabby', 13),
       ('George Michael', 'Ragdoll', 9),
       ('Jackson', 'Sphynx', 7);
```

---

## Read

**How do we retrieve and search data?**

### SELECT Statement

Basic syntax:

```sql
SELECT * FROM cats;
```

The `*` means "Give Me All Columns"

### SELECT Specific Columns

You can specify which columns you want:

```sql
SELECT name FROM cats;
```

```sql
SELECT age FROM cats;
```

```sql
SELECT name, age FROM cats;
```

### The WHERE Clause

The WHERE clause allows us to be specific about what data we want. We'll use WHERE all the time, not just with SELECT.

**Examples:**

```sql
SELECT * FROM cats WHERE age=4;
```

```sql
SELECT * FROM cats WHERE name='Egg';
```

### Exercises

1. **Select name and breed for all cats:**

```sql
SELECT name, breed FROM cats;
```

Expected output:

```
+----------------+------------+
| name           | breed      |
+----------------+------------+
| Ringo          | Tabby      |
| Cindy          | Maine Coon |
| Dumbledore     | Maine Coon |
| Egg            | Persian    |
| Misty          | Tabby      |
| George Michael | Ragdoll    |
| Jackson        | Sphynx     |
+----------------+------------+
```

2. **Select just the Tabby cats (name and age):**

```sql
SELECT name, age FROM cats WHERE breed='Tabby';
```

Expected output:

```
+-------+-----+
| name  | age |
+-------+-----+
| Ringo | 4   |
| Misty | 13  |
+-------+-----+
```

3. **Select cats where cat_id is same as age:**

```sql
SELECT cat_id, age FROM cats WHERE cat_id=age;
```

Expected output:

```
+--------+-----+
| cat_id | age |
+--------+-----+
| 4      | 4   |
| 7      | 7   |
+--------+-----+
```

### Aliases

Aliases make results easier to read:

```sql
SELECT cat_id AS id, name FROM cats;
```

Output:

```
+----+----------------+
| id | name           |
+----+----------------+
| 1  | Ringo          |
| 2  | Cindy          |
| 3  | Dumbledore     |
| 4  | Egg            |
| 5  | Misty          |
| 6  | George Michael |
| 7  | Jackson        |
+----+----------------+
```

---

## Update

**How do we alter existing data?**

### UPDATE Syntax

```sql
UPDATE cats SET breed='Shorthair'
WHERE breed='Tabby';
```

```sql
UPDATE cats SET age=14
WHERE name='Misty';
```

### ⚠️ A Good Rule of Thumb

**Try SELECTing before you UPDATE**

Always run a SELECT query first to verify which rows will be affected before running your UPDATE.

### Exercises

1. **Change Jackson's name to "Jack":**

```sql
UPDATE cats SET name='Jack'
WHERE name='Jackson';
```

2. **Change Ringo's breed to "British Shorthair":**

```sql
UPDATE cats SET breed='British Shorthair'
WHERE name='Ringo';
```

3. **Update both Maine Coons' ages to be 12:**

```sql
UPDATE cats SET age=12
WHERE breed='Maine Coon';
```

---

## Delete

**Time to learn to delete things**

### DELETE Syntax

```sql
DELETE FROM cats WHERE name='Egg';
```

### ⚠️ Warning: Deleting All Rows

```sql
DELETE FROM cats;
```

This deletes ALL cats! Always run SELECT first to double check what you're about to delete.

### Exercises

1. **DELETE all 4 year old cats:**

```sql
DELETE FROM cats WHERE age=4;
```

2. **DELETE cats whose age is the same as their cat_id:**

```sql
DELETE FROM cats WHERE cat_id=age;
```

3. **DELETE all cats:**

```sql
DELETE FROM cats;
```

---

## Summary

- **CREATE**: Use `INSERT INTO` to add new rows
- **READ**: Use `SELECT` with `WHERE` clauses to retrieve data
- **UPDATE**: Use `UPDATE` with `SET` and `WHERE` to modify existing data
- **DELETE**: Use `DELETE FROM` with `WHERE` to remove data

**Remember**: Always be careful with UPDATE and DELETE operations. Test with SELECT first!
