# Todos

### **Step by step: dont for a day**

[x] Binary Search
[x] B-Tree Structure
[x] Binary Search vs B-Tree
[x] Putting It All Together
[x] How BS work in B-Tree

[x] B+Tree (Database Reality)
[x] Linked List: should understand > JS B-Tree + Binary Search & JS B+Tree, Code JS Linked List > Then DB Proccess

- [x] Index type

  > Clustered x
  > Non-Clustered Indexes (Secondary Index) x
  > Covering Indexes x

- **[x] Composite Indexes & Leftmost Prefix:**

  > [x] Why/How
  > [x] How
  > [x] Leftmost Prefix

---

## 1. Binary Search

Binary search is a fast algorithm for finding an item in a **sorted** list.

### The Concept

Instead of checking every item one by one (linear search), binary search:

1. Looks at the middle item
2. Eliminates half of the remaining items
3. Repeats until found

### Example: Finding a Number

Let's find **42** in this sorted array:

```
Array: [5, 12, 18, 23, 31, 42, 56, 67, 78, 89, 95]
Index:  0   1   2   3   4   5   6   7   8   9  10
```

**Step-by-step process:**

```
Step 1: Check middle
  Left = 0, Right = 10
  Middle = (0 + 10) / 2 = 5
  Array[5] = 42
  Found! ✓

In this case, we got lucky on first try.
```

**Let's try finding 67:**

```
Array: [5, 12, 18, 23, 31, 42, 56, 67, 78, 89, 95]

Step 1: Check middle
  Left = 0, Right = 10
  Middle = 5
  Array[5] = 42
  67 > 42, so search RIGHT half

Step 2: Check middle of right half
  Left = 6, Right = 10
  Middle = (6 + 10) / 2 = 8
  Array[8] = 78
  67 < 78, so search LEFT half

Step 3: Check middle of remaining
  Left = 6, Right = 7
  Middle = (6 + 7) / 2 = 6
  Array[6] = 56
  67 > 56, so search RIGHT half

Step 4: Only one element left
  Left = 7, Right = 7
  Middle = 7
  Array[7] = 67
  Found! ✓

Total comparisons: 4 (vs 8 if we searched linearly)
```

### Binary Search Code

```javascript
function binarySearch(arr, target) {
  let left = 0
  let right = arr.length - 1

  while (left <= right) {
    console.log('loop', { left, right })
    let middle = Math.floor((left + right) / 2)

    if (arr[middle] === target) {
      return middle // Found!
    } else if (arr[middle] < target) {
      left = middle + 1 // Search right half
    } else {
      right = middle - 1 // Search left half
    }
  }

  return -1 // Not found
}

// Example
const numbers = [5, 12, 18, 23, 31, 42, 56, 67, 78, 89, 95]
const result = binarySearch(numbers, 67)
console.log(`Found at index: ${result}`) // Output: Found at index: 7
```

### Visual Representation

```

Finding 67 in [5, 12, 18, 23, 31, 42, 56, 67, 78, 89, 95]

Step 1: [5, 12, 18, 23, 31, |42|, 56, 67, 78, 89, 95]
67 > 42, go right →

Step 2: [56, 67, |78|, 89, 95]
67 < 78, go left ←

Step 3: [56, |67|]
67 > 56, go right →

Step 4: [|67|]
Found!

```

### Time Complexity

- **Linear Search**: O(n) - might check all n items
- **Binary Search**: O(log n) - halves the search space each time

```

Array size Linear Search Binary Search
10 10 steps 4 steps
100 100 steps 7 steps
1,000 1,000 steps 10 steps
1,000,000 1,000,000 steps 20 steps
1,000,000,000 1 billion steps 30 steps

```

**Key requirement**: Array must be **sorted**!
**Simple Example**:

- Bank has 10 million customer accounts (sorted by account number)
- Customer calls: "My account is 8234567"
- Without binary search:
- Teller checks 8 million accounts (minutes!)
- Customer waits... 😤
- With binary search:
- System finds account in 23 steps (milliseconds!)
- Customer happy! 😊

---

## 2. B-Tree Structure

A B-Tree is like binary search, but instead of splitting into 2 parts, it splits into **many parts**. This makes it perfect for databases.

### Why Not Just Binary Search Trees?

Binary search trees work well in memory, but databases store data on disk:

- **Disk access is SLOW** (milliseconds)
- **Memory access is FAST** (nanoseconds)
- **Want to minimize disk reads**

Solution: Store multiple keys in each node, read more data per disk access.

### B-Tree Properties

A B-Tree of order **m** has these rules:

1. Each node can have **up to m children**
2. Each node (except root) has **at least m/2 children**
3. All leaf nodes are at the **same level** (balanced)
4. Keys within nodes are **sorted**
5. A node with k children has **k-1 keys**

### Simple Example: B-Tree of Order 3

Let's build a B-Tree step by step. Each node can hold **2 keys** (order 3 = max 3 children = 2 keys).

#### Insert: 10

```

[10]

```

#### Insert: 20

```

[10, 20]

```

#### Insert: 30 (Node Full! Must Split)

```

Before: [10, 20, 30] (too many!)

After split:
[20] ← Root (middle key moves up)
/ \
 [10] [30] ← Leaves

```

**Why 20 goes up?** Middle key gets promoted to parent.

#### Insert: 40

```

        [20]
       /    \
    [10]    [30, 40]

```

#### Insert: 50 (Right leaf full! Split again)

```

Before:
[20]
/ \
 [10] [30, 40, 50] (too many!)

After split:
[20, 40] ← 40 promoted to root
/ | \
 [10] [30] [50]

```

#### Insert: 15, 25, 35

```

        [20, 40]
       /    |    \

[10,15] [25,30,35] [50]
↑
This is full!

```

#### Insert: 32 (Middle leaf full! Split)

```

Before: [25, 30, 35] tries to add 32
[25, 30, 32, 35] (too many!)

After split:
[20, 30, 40] ← 30 promoted
/ | | \
 [10,15] [25] [32,35] [50]

```

### Complete B-Tree Example

Let's build a B-Tree with more data (order 5 = max 4 keys per node):

**Insert: 10, 20, 30, 40, 50, 60, 70, 80, 90**

```

Final B-Tree:

                    [50]                    ← Root
                   /    \
              [30]        [70]              ← Internal nodes
            /     \      /     \
        [10,20] [40] [60] [80,90]           ← Leaf nodes

```

### Searching in B-Tree

**Find 60 in the tree above:**

```

Step 1: Start at ROOT [50]
60 > 50, go to RIGHT child

Step 2: At node [70]
60 < 70, go to LEFT child

Step 3: At node [60]
Found! ✓

Total nodes visited: 3 (= height of tree)

```

**Find 75 (not in tree):**

```

Step 1: Start at ROOT [50]
75 > 50, go to RIGHT child

Step 2: At node [70]
75 > 70, go to RIGHT child

Step 3: At node [80, 90]
75 not in [80, 90]
Not found!

Total nodes visited: 3

```

### B-Tree Code

```js
class BTreeNode {
  constructor(order) {
    this.order = order // Maximum children
    this.keys = [] // Sorted keys
    this.children = [] // Child pointers
    this.isLeaf = true
  }

  search(key) {
    // Find position where key should be
    let i = 0
    while (i < this.keys.length && key > this.keys[i]) {
      i += 1
    }

    // Found the key
    if (i < this.keys.length && key === this.keys[i]) {
      return true
    }

    // If leaf node, key doesn't exist
    if (this.isLeaf) {
      return false
    }

    // Recursively search in child
    return this.children[i].search(key)
  }
}

// Example usage
class BTree {
  constructor(order) {
    this.root = new BTreeNode(order)
    this.order = order
  }

  search(key) {
    return this.root.search(key)
  }
}

// Create B-Tree of order 3
const tree = new BTree(3)
// ... insert operations ...
const found = tree.search(60)
```

### Visual Search Process

```
Searching for 'emma@company.com' in email index:

                    [jane@...]                 Level 0 (Root)
                   /          \
          [charlie@...]      [mike@...]        Level 1
         /        |    \        |      \
    [alice@] [emma@] [grace@] [kelly@] [oscar@]  Level 2 (Leaves)
    [bob@]   [frank@] [henry@] [leo@]   [paul@]

Step 1: At [jane@...]
  'emma' < 'jane', go LEFT

Step 2: At [charlie@...]
  'emma' > 'charlie', go RIGHT (2nd child)

Step 3: At [emma@, frank@]
  'emma' == 'emma', FOUND! ✓

Disk reads: 3 (one per level)
```

---

## Comparison: Binary Search vs B-Tree

| Feature       | Binary Search        | B-Tree                  |
| ------------- | -------------------- | ----------------------- |
| Structure     | Array (linear)       | Tree (hierarchical)     |
| Splits        | 2 parts (left/right) | Many parts (m children) |
| Best for      | Memory/RAM           | Disk/Database           |
| Keys per node | 1                    | Multiple (m-1)          |
| Updates       | Hard (shift array)   | Easier (tree structure) |

### Why Databases Use B-Trees

**Example: 1 million records**

**Binary Search Tree** (2-way split):

- Height = log₂(1,000,000) ≈ 20 levels
- Disk reads needed: **20**

**B-Tree** (order 100 = 99 keys per node):

- Height = log₁₀₀(1,000,000) ≈ 3 levels
- Disk reads needed: **3**

**Savings: 20 → 3 disk reads** (each disk read is ~10ms, so 200ms → 30ms!)

---

## Putting It All Together

### How Binary Search Relates to B-Trees

```
Binary Search:
One sorted array, check middle, split in half

    [5, 12, 18, 23, 31, |42|, 56, 67, 78, 89, 95]
         ← left half       middle      right half →

B-Tree:
Multiple sorted arrays in tree nodes, check all keys, split many ways

              [42, 78]          ← Check both keys
            /    |    \
    [5,12,18] [56,67] [89,95]  ← Each node is like mini binary search
```

### The Connection to Database Indexes

Now you can see why databases use B-Trees for indexes:

1. **Each B-Tree node** = one disk page (4KB-16KB)
2. **Packed with many keys** = fewer disk reads
3. **Balanced structure** = consistent performance
4. **Sorted keys** = binary search within each node
5. **Leaf nodes linked** = efficient range scans

```sql
-- When you create an index:
CREATE INDEX idx_email ON employees(email);

-- MySQL builds a B-Tree where:
-- - Each node contains multiple email values (sorted)
-- - Searching uses binary search within each node
-- - Tree navigation minimizes disk reads
-- - All operations are O(log_m n) where m = keys per node
```

---

## 3. B+Tree (What Databases Actually Use!)

While B-Trees are great, databases actually use a variation called **B+Tree**. This is THE data structure behind almost all database indexes (MySQL, PostgreSQL, Oracle, SQL Server).

### Key Differences: B-Tree vs B+Tree

| Feature               | B-Tree                         | B+Tree                                  |
| --------------------- | ------------------------------ | --------------------------------------- |
| Data storage          | Every node (internal + leaves) | **Only leaf nodes**                     |
| Internal nodes        | Store keys + data              | **Only keys** (navigation)              |
| Leaf nodes            | Not connected                  | **Linked list** (doubly-linked)         |
| Range queries         | Must traverse tree repeatedly  | **Fast sequential scan** through leaves |
| Space efficiency      | Less keys per internal node    | **More keys** per internal node         |
| All data at one level | No                             | **Yes** (all leaves at same depth)      |

### Why B+Tree is Better for Databases

**1. Internal nodes only store keys** → More keys fit in one disk page → Shorter tree → Fewer disk reads

**2. Leaf nodes linked together** → Range queries (`WHERE age BETWEEN 20 AND 30`) are MUCH faster

**3. All data at leaf level** → Consistent, predictable performance

### B+Tree Structure Example

Let's build a B+Tree (order 3) with the same data as before:

**Insert: 10, 20, 30, 40, 50**

```
Final B+Tree:

            [30]                    ← Internal node (KEYS ONLY, no data!)
           /    \
       [10, 20, 30] ←→ [40, 50]    ← Leaf nodes (linked!)
       ↑                     ↑
    Actual data           Actual data
    stored here          stored here
```

**Key observations:**

- Internal node `[30]` only stores the key for navigation
- Leaf nodes `[10, 20, 30]` and `[40, 50]` store actual data/row pointers
- Leaf nodes are linked with `←→` for sequential access
- Notice `30` appears in BOTH internal node and leaf (this is normal!)

### Complete B+Tree Example

**Insert: 5, 10, 15, 20, 25, 30, 35, 40, 45, 50**

```
Final B+Tree (order 3):

                    [20, 35]                          ← Root (internal)
                   /    |    \
              [10]    [25, 30]   [45]                 ← Internal nodes
             /   \     /  |  \    /  \
        [5,10] [15,20] [25] [30,35] [40,45,50]        ← Leaf nodes (linked)
           ↔      ↔     ↔     ↔       ↔               ← Doubly-linked list
```

**Important notes:**

- Keys in internal nodes are **copied up** (not moved)
- All actual data is in leaf nodes
- Leaves form a linked list: `[5,10] ↔ [15,20] ↔ [25] ↔ [30,35] ↔ [40,45,50]`

### Searching in B+Tree

**Find 25:**

```
Step 1: Start at root [20, 35]
  25 > 20 and 25 < 35, go to MIDDLE child

Step 2: At internal node [25, 30]
  25 == 25, go to LEFT child (first child)

Step 3: At leaf [25]
  Found! Return data pointer ✓

Disk reads: 3
```

**Find 18 (not in tree):**

```
Step 1: Start at root [20, 35]
  18 < 20, go to LEFT child

Step 2: At internal node [10]
  18 > 10, go to RIGHT child

Step 3: At leaf [15, 20]
  18 not in [15, 20]
  Not found!

Disk reads: 3 (same as successful search)
```

### Range Queries: Where B+Tree Shines!

This is the HUGE advantage of B+Tree over B-Tree.

**Find all values between 15 and 35:**

```
In B-Tree: Must traverse tree multiple times
  Root → find 15 → back to root → find 20 → back to root → find 25...
  VERY inefficient!

In B+Tree: Navigate to start, then follow linked list
```

**Step-by-step in B+Tree:**

```
                    [20, 35]
                   /    |    \
              [10]    [25, 30]   [45]
             /   \     /  |  \    /  \
        [5,10] [15,20] [25] [30,35] [40,45,50]
           ↔      ↔     ↔     ↔       ↔

Step 1: Navigate to first value (15)
  Root [20,35] → 15 < 20 → go left
  [10] → 15 > 10 → go right
  Arrive at leaf [15, 20]

Step 2: Follow linked list until end value (35)
  [15, 20] → return 15, 20
     ↓ (follow link)
  [25] → return 25
     ↓ (follow link)
  [30, 35] → return 30, 35

Done! No tree traversal needed after finding start!

Result: [15, 20, 25, 30, 35]
```

This is why SQL queries like this are fast:

```sql
SELECT * FROM users
WHERE age BETWEEN 20 AND 30
ORDER BY age;

-- With B+Tree index on 'age':
-- 1. Navigate to age=20 in tree
-- 2. Follow leaf links until age=30
-- 3. Already sorted (natural order of B+Tree)
```

### Visual Comparison: Range Query

```
B-Tree (inefficient for range queries):
        [30]
       /    \
   [10,20]  [40,50,60]

To get values 10-50:
  Search 10: Root → left → found
  Search 20: Root → left → found  ← Back to root!
  Search 30: Root → found
  Search 40: Root → right → found ← Back to root!
  Search 50: Root → right → found ← Back to root!

Many tree traversals!

---

B+Tree (efficient for range queries):
        [30]
       /    \
  [10,20,30] ← [40,50,60]
      ↔           ↔

To get values 10-50:
  Search 10: Root → left → found
  Then: 10 → 20 → 30 → 40 → 50  ← Just follow links!

One tree traversal + simple linked list walk!
```

### Why This Matters for Databases

```sql
-- These queries are FAST with B+Tree indexes:

-- Range query
SELECT * FROM orders
WHERE order_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Sorting (leaves already sorted + linked)
SELECT * FROM users ORDER BY email;

-- Range with ORDER BY (best case!)
SELECT * FROM products
WHERE price BETWEEN 10 AND 100
ORDER BY price;  -- Free! Already in order
```

### B+Tree Code (Python - Simplified)

```python
class BPlusTreeNode:
    def __init__(self, order, is_leaf=False):
        self.order = order
        self.keys = []
        self.children = []  # For internal nodes OR data pointers for leaf
        self.is_leaf = is_leaf
        self.next_leaf = None  # Link to next leaf (for range queries)
        self.prev_leaf = None  # Link to previous leaf

class BPlusTree:
    def __init__(self, order):
        self.root = BPlusTreeNode(order, is_leaf=True)
        self.order = order

    def search(self, key):
        """Search for a single key"""
        return self._search_helper(self.root, key)

    def _search_helper(self, node, key):
        # Find position
        i = 0
        while i < len(node.keys) and key > node.keys[i]:
            i += 1

        if node.is_leaf:
            # Leaf node: check if key exists
            if i < len(node.keys) and node.keys[i] == key:
                return node.children[i]  # Return data pointer
            return None
        else:
            # Internal node: navigate to child
            return self._search_helper(node.children[i], key)

    def range_query(self, start_key, end_key):
        """Efficient range query using leaf links"""
        results = []

        # Find leaf node containing start_key
        leaf = self._find_leaf(start_key)

        # Walk through linked leaves
        while leaf is not None:
            for i, key in enumerate(leaf.keys):
                if start_key <= key <= end_key:
                    results.append((key, leaf.children[i]))
                elif key > end_key:
                    return results  # Done!

            leaf = leaf.next_leaf  # Move to next leaf

        return results

    def _find_leaf(self, key):
        """Navigate to leaf node"""
        node = self.root
        while not node.is_leaf:
            i = 0
            while i < len(node.keys) and key > node.keys[i]:
                i += 1
            node = node.children[i]
        return node

# Example usage
tree = BPlusTree(order=3)
# ... insert operations ...

# Single search
result = tree.search(25)

# Range query (THIS IS THE MAGIC!)
range_results = tree.range_query(15, 35)
print(range_results)  # Fast! Just follows leaf links
```

### Memory vs Disk: Why B+Tree Wins

**Example: 1 million records, each node = 4KB disk page**

```
B-Tree (order 200):
- Internal nodes: ~100 keys + 100 data pointers
- Larger internal nodes → fewer keys → taller tree
- Height: ~4 levels
- Range query: Multiple tree traversals

B+Tree (order 200):
- Internal nodes: ~200 keys only (no data!)
- Smaller internal nodes → more keys → shorter tree
- Height: ~3 levels
- Range query: One tree traversal + leaf scan
- Leaf nodes: Continuous, linked → great for disk prefetch

Savings:
- Fewer disk reads for single lookups
- MUCH faster range queries
- Better cache utilization
```

### Real Database Example: MySQL InnoDB

```sql
CREATE TABLE users (
    id INT PRIMARY KEY,
    email VARCHAR(255),
    age INT,
    INDEX idx_age (age)
);

-- When you query:
SELECT * FROM users WHERE age BETWEEN 20 AND 30;

-- MySQL uses B+Tree index on 'age':
-- 1. Navigate tree to age=20 leaf
-- 2. Scan leaves: 20 → 21 → 22 → ... → 30
-- 3. For each age value, get row data
```

**Internal structure (simplified):**

```
B+Tree on 'age' column:

                [35, 65]                  ← Internal (only ages)
               /    |    \
          [20]   [45, 55]  [75]           ← Internal (only ages)
         /   \    /  |  \   /  \
     [18,20] [25,30,35] [45] ...          ← Leaves (age + row pointer)
        ↔       ↔        ↔                ← Linked for range scans
```

---

## 4. Clustered vs Non-Clustered Indexes

This is CRITICAL to understand how databases organize data!

### Clustered Index

A **clustered index** determines the **physical order** of data rows in the table.

**Key facts:**

- Table data IS stored in the index (leaf nodes contain actual rows)
- A table can have **ONLY ONE** clustered index
- Usually the **primary key** (in MySQL InnoDB, PRIMARY KEY IS the clustered index)
- Other indexes reference this index (not the raw table)

### Non-Clustered Index (Secondary Index)

A **non-clustered index** is a separate B+Tree structure that points to the data.

**Key facts:**

- Stored separately from table data
- Leaf nodes contain **pointers** (usually primary key value)
- A table can have **MANY** non-clustered indexes
- Requires extra lookup to get full row data (unless covered)

### Visual Comparison

**Clustered Index (Primary Key):**

```sql
CREATE TABLE users (
    id INT PRIMARY KEY,      ← Clustered index in InnoDB
    name VARCHAR(100),
    email VARCHAR(255)
);
```

```
Clustered B+Tree on 'id':

                    [500]
                   /     \
                [250]     [750]
               /   \      /   \
         [100,250] [300,500] [600,750] [800,900]  ← Leaves contain FULL ROWS
            ↔         ↔         ↔         ↔

Leaf [100, 250] contains:
  id=100, name='Alice', email='alice@...'  ← Full row data
  id=250, name='Bob', email='bob@...'      ← Full row data
```

**Non-Clustered Index (Secondary):**

```sql
CREATE INDEX idx_email ON users(email);  ← Non-clustered index
```

```
Secondary B+Tree on 'email':

                    ['mike@...']
                   /            \
            ['charlie@...']    ['zoe@...']
               /      \           /      \
         ['alice@...'] ['david@...'] ...     ← Leaves contain email + PRIMARY KEY
              ↔              ↔

Leaf ['alice@...', 'charlie@...'] contains:
  'alice@...' → id=100    ← Just email + pointer to clustered index
  'charlie@...' → id=305  ← Just email + pointer to clustered index
```

### How Queries Work

**Query 1: Using clustered index (fast!)**

```sql
SELECT * FROM users WHERE id = 100;
```

```
1. Navigate clustered B+Tree to id=100
2. Leaf node contains FULL row
3. Return data
4. Done! (1 index lookup)
```

**Query 2: Using non-clustered index (slower)**

```sql
SELECT * FROM users WHERE email = 'alice@example.com';
```

```
1. Navigate secondary B+Tree on 'email'
2. Find 'alice@example.com' → get id=100
3. Navigate clustered B+Tree to id=100  ← Extra lookup!
4. Get full row data
5. Done! (2 index lookups - "bookmark lookup")
```

This extra lookup is called a **"bookmark lookup"** or **"clustered index lookup"**.

### Visual: Two-Step Lookup

```
Step 1: Secondary index (email)
                    ['mike@...']
                   /            \
            ['charlie@...']    ['zoe@...']
               /
         ['alice@...']  ← Found! email='alice@...' → id=100

Step 2: Clustered index (id)
                    [500]
                   /
                [250]
               /
         [100,250]  ← Navigate to id=100, get full row
          ↑
      id=100, name='Alice', email='alice@...', age=25, ...
```

### MySQL InnoDB Specifics

**Primary key = Clustered index:**

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,  -- Clustered index (data stored here)
    user_id INT,
    order_date DATE,
    amount DECIMAL(10,2),
    INDEX idx_user (user_id),  -- Secondary index (stores user_id + order_id)
    INDEX idx_date (order_date) -- Secondary index (stores order_date + order_id)
);
```

**Physical storage:**

```
Clustered B+Tree (order_id):
  Leaves = Complete table rows
  [order_id=1, user_id=100, order_date='2024-01-01', amount=99.99]
  [order_id=2, user_id=101, order_date='2024-01-02', amount=49.99]
  ...

Secondary B+Tree (user_id):
  Leaves = user_id + order_id (primary key)
  [user_id=100, order_id=1]
  [user_id=100, order_id=5]
  [user_id=101, order_id=2]
  ...

Secondary B+Tree (order_date):
  Leaves = order_date + order_id (primary key)
  [order_date='2024-01-01', order_id=1]
  [order_date='2024-01-02', order_id=2]
  ...
```

### Choosing the Right Clustered Index Key

**Good clustered index:**

- Auto-incrementing ID (sequential inserts)
- Frequently searched column
- Used in joins

**Bad clustered index:**

- Random UUIDs (causes page splits)
- Frequently updated column (expensive!)
- Very wide column (wastes space in secondary indexes)

**Example:**

```sql
-- Good: Sequential primary key
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,  -- ✓ Sequential inserts
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP
);

-- Bad: Random UUID as primary key
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,  -- ✗ Random UUIDs cause fragmentation
    email VARCHAR(255),
    created_at TIMESTAMP
);
```

### Performance Implications

**Scenario 1: Query uses primary key**

```sql
SELECT * FROM users WHERE id = 100;
-- Cost: 1 index lookup (direct to clustered index)
```

**Scenario 2: Query uses secondary index + needs other columns**

```sql
SELECT * FROM users WHERE email = 'alice@example.com';
-- Cost: 2 index lookups (secondary index → clustered index)
```

**Scenario 3: Query uses secondary index + only needs indexed column (covered!)**

```sql
SELECT email FROM users WHERE email = 'alice@example.com';
-- Cost: 1 index lookup (covered by secondary index, no clustered lookup needed)
```

### Table Without Primary Key (MySQL)

```sql
CREATE TABLE logs (
    message TEXT,
    created_at TIMESTAMP
);
-- No primary key specified!
```

**What happens:**

- MySQL InnoDB creates a **hidden 6-byte clustered index** (row ID)
- You can't access or control it
- Performance suffers
- **Always define a primary key!**

---

## [5. Composite Indexes & Leftmost Prefix Rule](# Composite Idx.md)

A **composite index** (multi-column index) is an index on multiple columns. Understanding how they work is crucial for query optimization!

### Creating Composite Indexes

```sql
CREATE INDEX idx_name_age ON users(last_name, first_name, age);
```

This creates a B+Tree where keys are ordered by:

1. `last_name` first
2. Then `first_name` (within same last_name)
3. Then `age` (within same last_name + first_name)

### How Composite Index is Stored

```
Index on (last_name, first_name, age):

Sorted like a phone book:
  ('Garcia', 'Ana', 25)
  ('Garcia', 'Carlos', 30)
  ('Garcia', 'Carlos', 35)    ← Same last_name + first_name, sorted by age
  ('Johnson', 'Alice', 28)
  ('Johnson', 'Bob', 40)
  ('Smith', 'David', 22)
  ('Smith', 'Emma', 29)
  ('Wilson', 'Frank', 45)
```

### The Leftmost Prefix Rule

**Critical concept:** You can use a composite index for queries on:

- Just the **first column**
- The **first + second columns**
- All columns
- **But NOT** just the second or third column alone!

**Example with index on `(last_name, first_name, age)`:**

```sql
-- ✓ Can use index (leftmost prefix)
SELECT * FROM users WHERE last_name = 'Smith';

-- ✓ Can use index (leftmost prefix)
SELECT * FROM users WHERE last_name = 'Smith' AND first_name = 'Emma';

-- ✓ Can use index (all columns)
SELECT * FROM users WHERE last_name = 'Smith' AND first_name = 'Emma' AND age = 29;

-- ✓ Can use index (leftmost prefix, even with range on last column)
SELECT * FROM users WHERE last_name = 'Smith' AND first_name = 'Emma' AND age > 25;

-- ✗ CANNOT use index (skips last_name)
SELECT * FROM users WHERE first_name = 'Emma';

-- ✗ CANNOT use index (skips last_name)
SELECT * FROM users WHERE age = 29;

-- ⚠️  Can use index for last_name, but NOT for age (first_name skipped)
SELECT * FROM users WHERE last_name = 'Smith' AND age > 25;
```

### Visual: Why Leftmost Prefix Matters

```
Index on (last_name, first_name, age):

  ('Garcia', 'Ana', 25)
  ('Garcia', 'Carlos', 30)
  ('Garcia', 'Carlos', 35)
  ('Johnson', 'Alice', 28)
  ('Smith', 'David', 22)
  ('Smith', 'Emma', 29)
  ('Wilson', 'Frank', 45)

Query: WHERE first_name = 'Emma'
  Problem: Data is NOT sorted by first_name primarily
  'Emma' could be anywhere (need full scan)
  ✗ Index useless

Query: WHERE last_name = 'Smith'
  Data IS sorted by last_name first
  Can binary search for 'Smith'
  ✓ Index useful

Query: WHERE last_name = 'Smith' AND first_name = 'Emma'
  Find 'Smith' (sorted), then within 'Smith', find 'Emma' (sorted)
  ✓ Index very useful
```

### Column Order Matters!

```sql
-- Index 1: (last_name, first_name, age)
CREATE INDEX idx1 ON users(last_name, first_name, age);

-- Index 2: (age, last_name, first_name)
CREATE INDEX idx2 ON users(age, last_name, first_name);
```

These are COMPLETELY DIFFERENT indexes!

```sql
-- Query A: Benefits from idx1, NOT idx2
SELECT * FROM users WHERE last_name = 'Smith';

-- Query B: Benefits from idx2, NOT idx1
SELECT * FROM users WHERE age > 25;

-- Query C: Benefits from BOTH (but differently)
SELECT * FROM users WHERE last_name = 'Smith' AND age = 29;
  -- idx1: Uses last_name, but then needs scan within 'Smith' for age=29
  -- idx2: Uses age, but then needs scan within age=29 for last_name='Smith'
```

### Choosing Column Order

**General rules:**

1. **Equality first, range last**
2. **High selectivity first** (unique/nearly unique values)
3. **Most frequently queried first**

**Example:**

```sql
-- Bad order (range first)
CREATE INDEX idx_bad ON orders(amount, status, user_id);
-- Query: WHERE status='completed' AND user_id=100 AND amount > 50
-- Problem: amount is range, but status (equality) comes after

-- Good order (equality first, range last)
CREATE INDEX idx_good ON orders(status, user_id, amount);
-- Query: WHERE status='completed' AND user_id=100 AND amount > 50
-- Efficient: Uses status (equal), user_id (equal), amount (range) in order
```

### Real-World Examples

**Scenario 1: E-commerce orders**

```sql
-- Common queries:
-- 1. Orders by specific user
-- 2. Orders by user in date range
-- 3. Orders by user with specific status

-- Best composite index:
CREATE INDEX idx_orders ON orders(user_id, order_date, status);

-- Works efficiently for:
WHERE user_id = 100                                  -- ✓
WHERE user_id = 100 AND order_date > '2024-01-01'    -- ✓
WHERE user_id = 100 AND status = 'completed'         -- ✓ (partial)
WHERE user_id = 100 AND order_date > '2024-01-01' AND status = 'completed'  -- ✓

-- Does NOT work for:
WHERE order_date > '2024-01-01'                      -- ✗
WHERE status = 'completed'                           -- ✗
```

**Scenario 2: User search**

```sql
-- Common queries:
-- 1. Find users by last name
-- 2. Find users by full name
-- 3. Find users by name and age range

-- Best composite index:
CREATE INDEX idx_users ON users(last_name, first_name, age);

-- Efficient:
WHERE last_name = 'Smith'                                           -- ✓
WHERE last_name = 'Smith' AND first_name = 'John'                   -- ✓
WHERE last_name = 'Smith' AND first_name = 'John' AND age BETWEEN 20 AND 30  -- ✓

-- Not efficient:
WHERE first_name = 'John'                                           -- ✗
WHERE age BETWEEN 20 AND 30                                         -- ✗
```

### Index Skip Scan (Advanced)

Modern databases (Oracle, PostgreSQL 13+, MySQL 8.0.13+) can sometimes use composite indexes even when leftmost prefix is missing, but it's inefficient:

```sql
Index on (status, user_id, order_date)

Query: WHERE user_id = 100 AND order_date > '2024-01-01'
-- Skips 'status' column

Traditional: Full table scan
Modern optimizer: "Skip scan" - scan through each status value
  WHERE status='pending' AND user_id=100 AND order_date > '2024-01-01'
  WHERE status='completed' AND user_id=100 AND order_date > '2024-01-01'
  WHERE status='cancelled' AND user_id=100 AND order_date > '2024-01-01'
  ...
```

**Still much slower than proper leftmost prefix!** Don't rely on this.

### Multiple Indexes vs One Composite Index

```sql
-- Option 1: Separate indexes
CREATE INDEX idx_last_name ON users(last_name);
CREATE INDEX idx_first_name ON users(first_name);

-- Option 2: Composite index
CREATE INDEX idx_name ON users(last_name, first_name);
```

**For query: `WHERE last_name = 'Smith' AND first_name = 'John'`**

- **Option 1**: Database might use one index or try to merge both (index merge) - often slower
- **Option 2**: Single, efficient lookup - **much better!**

**Rule of thumb:** If columns are commonly queried together, use a composite index.

---
