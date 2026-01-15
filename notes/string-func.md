# MySQL String Functions - Complete Guide

A comprehensive guide to working with string functions in MySQL, with practical examples and exercises.

---

## Quick Tip: Running SQL Files

Before we dive into string functions, here's a helpful tip for running SQL files:

```sql
source file_name.sql
```

This command allows you to execute an entire SQL file at once, which is useful for running multiple queries or setting up your database.

---

## 1. CONCAT - Combining Strings

The `CONCAT()` function combines multiple strings into one.

### Basic Syntax

```sql
CONCAT(x, y, z)
```

### Combining Columns

Let's say you have separate columns for first and last names:

```sql
SELECT
    author_fname,
    author_lname
FROM books;
```

To display full names instead of separate columns:

```sql
SELECT
    CONCAT(author_fname, ' ', author_lname) AS full_name
FROM books;
```

**Result:**

- Dave Eggers
- Jhumpa Lahiri
- Neil Gaiman

### Mixing Columns and Text

You can combine columns with literal text:

```sql
CONCAT(column, 'text', anotherColumn, 'more text')
```

**Example:**

```sql
SELECT
    CONCAT(author_fname, ' ', author_lname) AS full_name
FROM books;
```

---

## 2. CONCAT_WS - Concat With Separator

`CONCAT_WS()` is a variation that lets you specify a separator that will be placed between all arguments.

### Syntax

```sql
CONCAT_WS(separator, str1, str2, ...)
```

### Example

```sql
SELECT
    CONCAT_WS(' - ', title, author_fname, author_lname) AS book_info
FROM books;
```

This is cleaner than using `CONCAT()` with separators between each argument!

---

## 3. SUBSTRING (or SUBSTR) - Working with Parts of Strings

The `SUBSTRING()` function extracts a portion of a string. You can also use `SUBSTR()` as a shorthand.

### Extracting from Position with Length

```sql
SELECT SUBSTRING('Hello World', 1, 4);
-- Result: 'Hell'
```

**Note:** MySQL uses 1-based indexing (starts counting from 1, not 0)

### Extracting from Position to End

```sql
SELECT SUBSTRING('Hello World', 7);
-- Result: 'World'
```

### Using Negative Indexes

```sql
SELECT SUBSTRING('Hello World', -3);
-- Result: 'rld'
```

Negative numbers count from the end of the string!

### Practical Example - Short Titles

```sql
SELECT
    SUBSTRING(title, 1, 10) AS short_title
FROM books;
```

**Result:**

```
The Namesa...
Norse Myth...
American G...
```

---

## 4. REPLACE - Substituting Parts of Strings

The `REPLACE()` function substitutes all occurrences of a substring with another string.

### Syntax

```sql
REPLACE(string, from_string, to_string)
```

### Basic Example

```sql
SELECT REPLACE('Hello World', 'Hell', '%$#@');
-- Result: '%$#@o World'
```

### Practical Example

```sql
SELECT
    REPLACE('cheese bread coffee milk', ' ', ' and ');
-- Result: 'cheese and bread and coffee and milk'
```

### Real Use Case

```sql
SELECT
    REPLACE(title, ' ', '->') AS formatted_title
FROM books;
```

---

## 5. REVERSE - Flipping Strings

Super straightforward! `REVERSE()` reverses the order of characters in a string.

```sql
SELECT REVERSE('Hello World');
-- Result: 'dlroW olleH'
```

---

## 6. CHAR_LENGTH - Counting Characters

`CHAR_LENGTH()` returns the number of characters in a string.

```sql
SELECT CHAR_LENGTH('Hello World');
-- Result: 11
```

### Practical Example

```sql
SELECT
    title,
    CHAR_LENGTH(title) AS character_count
FROM books;
```

---

## 7. UPPER() and LOWER() - Changing Case

These functions change the case of strings.

### UPPER() - Convert to Uppercase

```sql
SELECT UPPER('Hello World');
-- Result: 'HELLO WORLD'
```

### LOWER() - Convert to Lowercase

```sql
SELECT LOWER('Hello World');
-- Result: 'hello world'
```

### Practical Example

```sql
SELECT
    UPPER(CONCAT(author_fname, ' ', author_lname)) AS full_name_caps
FROM books;
```

---

## Practice Exercises

Now let's practice! Try to solve these exercises before looking at the solutions.

### Exercise 1: Reverse and Uppercase

**Challenge:** Reverse and uppercase the following sentence:

```
"Why does my cat look at me with such hatred?"
```

<details>
<summary>Solution</summary>

```sql
SELECT
    UPPER(REVERSE('Why does my cat look at me with such hatred?'));
-- Result: '?DERTAH HCUS HTIW EM TA KOOL TAC YM SEOD YHW'
```

</details>

---

### Exercise 2: Multiple Functions

**Challenge:** What does this print out?

```sql
SELECT
    REPLACE(
        CONCAT('I', ' ', 'like', ' ', 'cats'),
        ' ',
        '-'
    );
```

<details>
<summary>Solution</summary>

```sql
-- Result: 'I-like-cats'
```

</details>

---

### Exercise 3: Replace Spaces in Titles

**Challenge:** Replace spaces in book titles with '->'

```sql
SELECT
    REPLACE(title, ' ', '->') AS formatted_title
FROM books;
```

**Expected Output:**

```
The->Namesake
Norse->Mythology
American->Gods
Interpreter->of->Maladies
```

---

### Exercise 4: Forward and Backward

**Challenge:** Print author last names forwards and backwards

```sql
SELECT
    author_lname AS forwards,
    REVERSE(author_lname) AS backwards
FROM books;
```

**Expected Output:**

```
| forwards        | backwards       |
|----------------|-----------------|
| Lahiri         | irihaL          |
| Gaiman         | namiaG          |
| Eggers         | sreggE          |
```

---

### Exercise 5: Full Names in Caps

**Challenge:** Display full author names in uppercase

```sql
SELECT
    UPPER(CONCAT(author_fname, ' ', author_lname)) AS 'full name in caps'
FROM books;
```

**Expected Output:**

```
JHUMPA LAHIRI
NEIL GAIMAN
DAVE EGGERS
MICHAEL CHABON
PATTI SMITH
```

---

### Exercise 6: Book Blurbs

**Challenge:** Create a sentence: "{title} was released in {year}"

```sql
SELECT
    CONCAT(title, ' was released in ', released_year) AS blurb
FROM books;
```

**Expected Output:**

```
The Namesake was released in 2003
Norse Mythology was released in 2016
American Gods was released in 2001
```

---

### Exercise 7: Title Length

**Challenge:** Print book titles and their character count

```sql
SELECT
    title,
    CHAR_LENGTH(title) AS 'character count'
FROM books;
```

**Expected Output:**

```
| title                          | character count |
|-------------------------------|----------------|
| The Namesake                   | 12             |
| Norse Mythology                | 15             |
| American Gods                  | 13             |
```

---

### Exercise 8: Complex Formatting (Final Challenge!)

**Challenge:** Create a formatted output showing:

- Short title (first 10 characters + '...')
- Author (last name, first name)
- Quantity with text

```sql
SELECT
    CONCAT(SUBSTRING(title, 1, 10), '...') AS 'short title',
    CONCAT(author_lname, ',', author_fname) AS author,
    CONCAT(stock_quantity, ' in stock') AS quantity
FROM books;
```

**Expected Output:**

```
| short title    | author       | quantity      |
|---------------|--------------|---------------|
| American G... | Gaiman,Neil  | 12 in stock   |
| A Heartbre... | Eggers,Dave  | 104 in stock  |
```

---

## Summary

You've now learned the essential MySQL string functions:

- **CONCAT** / **CONCAT_WS** - Combine strings
- **SUBSTRING** / **SUBSTR** - Extract parts of strings
- **REPLACE** - Substitute text within strings
- **REVERSE** - Flip strings backwards
- **CHAR_LENGTH** - Count characters
- **UPPER** / **LOWER** - Change case

These functions can be combined to create powerful queries for formatting and manipulating text data in your database!

---

## Pro Tips

1. **Combine functions** - You can nest functions inside each other for complex operations
2. **Use aliases** - Always use `AS` to give your calculated columns meaningful names
3. **Test incrementally** - When building complex queries, test each function separately first
4. **Remember indexing** - MySQL uses 1-based indexing (starts at 1, not 0)
5. **Practice, practice, practice!** - The best way to master these functions is to use them regularly

Happy querying! 🚀
