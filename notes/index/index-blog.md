# From Binary Search to B-Trees: How Database Indexes Find Bank Accounts Fast

If you picture a bank with millions of accounts, the slow way to look up account **8234567** is to scan every row. The fast way is to keep account numbers sorted and cut the search space in half at every step—that is **binary search** in memory—or store a **B-Tree** (in practice almost always a **B+Tree**) on disk so each read pulls a whole **page** of keys and you need far fewer seeks.

This post walks through:

- **Binary search** on sorted keys and why it is not enough on disk alone  
- **B-Tree intuition**: many keys per node, shallow height, fewer random reads  
- **Terminology and rules** (order, fan-out, min fill)  
- **Search, insert, update, delete** at the index level  
- **Disk I/O**, buffer cache, and how engines pick **page size** and **branching factor**

Examples use **numeric bank account IDs** throughout.

---

## 1. Binary Search (Sorted Data Only)

Binary search finds a value in a **sorted** array by repeatedly looking at the middle element and discarding half of the remaining range.

### The idea

1. Compare the target to the middle element.  
2. If equal, done. If the target is larger, search the right half; if smaller, search the left half.  
3. Repeat until you find the value or the range is empty.

**Complexity:** Each step halves the remaining range, so the number of comparisons is **O(log₂ n)** for **n** keys. That is excellent for CPU cost in RAM.

### Example: finding an account key in a sorted list

Suppose we store **internal lookup keys** (not full rows) in a sorted array—the same logic applies whether the key is `8234567` or `42`:

```
Keys:   [5, 12, 18, 23, 31, 42, 56, 67, 78, 89, 95]
Index:   0   1   2   3   4   5   6   7   8   9  10
```

**Find 42** (lucky first step):

```
Left = 0, Right = 10 → Middle = 5 → Keys[5] = 42 → Found.
```

**Find 67**:

```
Step 1: Middle = 5 → 42 < 67 → search right [6..10]
Step 2: Middle = 8 → 78 > 67 → search left [6..7]
Step 3: Middle = 6 → 56 < 67 → search right [7..7]
Step 4: Middle = 7 → 67 → Found.
```

### Why banks care (numbers, not text)

- **10 million** accounts, sorted by account number.  
- Linear scan: up to **10 million** comparisons.  
- Binary search: about **log₂(10⁷) ≈ 24** comparisons in the sorted array.

So the *algorithm* is cheap in RAM. The *problem* for a database is that **disk** is slow and **random** access is much worse than sequential access. A structure that needs **one pointer hop per comparison** can still be I/O-bound: each hop may miss the buffer pool and trigger a **seek** (milliseconds), while a comparison in RAM is nanoseconds.

### Code sketch

```javascript
function binarySearch(arr, target) {
  let left = 0
  let right = arr.length - 1

  while (left <= right) {
    const middle = Math.floor((left + right) / 2)
    if (arr[middle] === target) return middle
    if (arr[middle] < target) left = middle + 1
    else right = middle - 1
  }
  return -1
}
```

---

## 2. B-Tree: Many-Way Search on Disk

A **B-Tree** generalizes binary search: each node holds **many sorted keys** and **many children**, so one disk **page** can route you toward the next page in a single read. The goal is to **minimize random disk I/O**, not to minimize comparison count alone.

### Why not “just” a binary search tree?

- **Disk access** is measured in milliseconds; **RAM** in nanoseconds.  
- A skinny binary tree may need **one child pointer per level**; if each level’s node is on a different page, a lookup can cost **height** random reads.  
- A B-Tree packs **hundreds of keys per node** (one node ≈ one **page**), so **height** stays small: a point lookup touches **few pages** along the root-to-leaf path.

### B+Tree (what you usually get in MySQL / PostgreSQL)

Most relational engines implement a **B+Tree** variant:

- **All row keys** (or `(key, pointer)` pairs) live in **leaves**; internal nodes only hold **separator keys** to guide the search.  
- **Leaves** are often linked **left-to-right** so **range scans** (`WHERE account_number BETWEEN …`) can walk the leaf level without bouncing up and down the tree.

The **split / merge / search** intuition is the same as for a classic B-Tree; the difference is *where* payloads live and how **ranges** are supported. This article says “B-Tree” for the general idea and calls out **B+Tree** where it matters for real systems.

---

## 3. Core Terminology

| Term | Meaning |
|------|--------|
| **Node** | One block of keys and child pointers, usually stored as one **page** on disk. |
| **Key** | A value used for ordering and routing (e.g. `account_number`). |
| **Children** | Pointers to child nodes (for internal nodes). |
| **Root** | The top node; every search starts here. |
| **Leaf** | A node with no children below it (in B+Trees, data entries are here). |
| **Order (m)** | Upper bound on **fan-out**: at most **m** children per node (definitions vary slightly by textbook). |
| **Fan-out** | Typical number of children per node when the tree is healthily filled—drives **height**. |

---

## 4. How “Order” and Balance Rules Work

Definitions vary slightly by textbook; the following matches common database explanations:

1. **Maximum children = m** → at most **m − 1 keys** in a node (typical convention).  
2. **Minimum children** (except root): at least **⌈m/2⌉** children, so the tree stays **dense** and **shallow**; empty-ish nodes are merged or refilled.  
3. **Root**: may have fewer children (e.g. **2** as minimum when not a single-node tree).  
4. **Balance**: all leaves at the **same depth** (same number of steps from root).  
5. **Sorted keys** in every node; for internal nodes, keys act as **boundaries** between subtrees.

**Example:** **Order 3** → at most **3** children → at most **2** keys per node. That is the size used in many pen-and-paper diagrams.

**Order in production:** **m** is not hand-picked as “3”. It falls out of **how many key+pointer entries fit in one page** (e.g. 8 KB or 16 KB). Larger **m** → **shorter height** → **fewer levels** → **fewer page reads** for a point lookup.

---

## 5. How Order Relates to Page Size (Back-of-the-Envelope)

Engines align **node size** with **storage page size** (often 4 KB–16 KB) so each node read is one efficient I/O unit.

Suppose:

- Page size = **4096 bytes**  
- Each index entry uses **8 bytes** for the key and **8 bytes** for a child pointer (toy numbers; real rows add overhead, metadata, and alignment)

One internal entry is roughly **key + pointer** between separators; a simple model ignores headers and gets:

- Usable space ≈ **4096** bytes  
- Per-key slot ≈ **16** bytes → **4096 / 16 = 256** entries per page  

So **m** can be on the order of **hundreds**—not 3. That single figure explains why B-Trees keep **height** tiny for huge tables.

---

## 6. How Binary Search Works *Inside* a B-Tree Node

At each node, keys are sorted. After the page is loaded into RAM, the engine finds the correct **child** or **leaf position** with **binary search** on that small array (or a linear scan when the count is tiny).

**Pattern:**

1. **Internal node:** find the interval the target falls into: keys partition the space **(−∞, K₁), [K₁, K₂), …** (exact boundary rules depend on duplicate handling). Follow the corresponding **child** pointer.  
2. **Leaf node:** binary search checks whether the account number exists; if not, **not found**.

Globally you traverse **height** levels; locally each level is **O(log of keys in that page)** comparisons in RAM—cheap compared to a disk miss.

**Small routing example:** search for **6000123** in a node holding sorted keys `[5000000, 5500000, 7000000]`:

- `6000123` falls between `5500000` and `7000000` → follow the **middle** child.  
That is the same “narrow the range” idea as binary search, extended to **many** boundaries per page.

---

## 7. Full Search Walkthrough (Bank Account IDs)

Consider this **conceptual** tree (keys are account identifiers in thousands for readability):

```
              [4000 | 8000]
           /        |        \
      [2000]     [6000]    [10000]
     /     \     /    \     /     \
[1000] [3000] [5000] [7000] [9000] [11000]
```

**Find 7000:**

1. **Root** `[4000 | 8000]`: `7000` is greater than `4000` and less than `8000` → take the **middle** child (the subtree for the **6000** branch in the drawing—your diagram’s middle internal node is `[6000]`).  
2. **Internal** `[6000]`: `7000 > 6000` → go **right** to the leaf `[7000]`.  
3. **Leaf** `[7000]`: found.

**What happened:** at each level you did **one page’s worth** of routing (binary search inside the page), then **one pointer follow** to the next page. Total **page touches ≈ tree height** (if each node is one page and nothing is cached).

---

## 8. Disk Reads, Height, and Cache

### One read ≈ one page (first-order model)

- Loading a node usually means reading **one page** into the **buffer pool**.  
- A **point query** walks **root → … → leaf**, so **cold-cache** cost is often modeled as **O(height)** page reads.

### Height scales with fan-out

If every internal node had **t** children (branching factor), a rough bound is:

**h ≈ log_t(n)** for **n** keys (base depends on whether you count children or keys; the shape is what matters).

**Illustrative table** (assuming a **high** fan-out such that each level multiplies the covered row count by ~100–1000; real numbers depend on key size and page size):

| Approximate rows | Typical height (order of magnitude) |
|------------------|--------------------------------------|
| 10³ (1K)         | ~2–3 levels                          |
| 10⁶ (1M)         | ~3–4 levels                          |
| 10⁹ (1B)         | ~4–6 levels                          |

So B-Trees stay **shallow** compared to binary trees on disk.

### Production caveats

- **Root and hot internal pages** stay in **RAM** → **0** physical reads for those steps.  
- **Range queries** scan **many leaf pages** (often sequential), not just height.  
- **Clustered index** (InnoDB primary key): leaf **is** the table row layout for that key.  
- **Secondary index**: leaf usually stores **(key, primary key or row id)** → may need an extra **lookup** to the clustered index or heap.

---

## 9. Insert: Leaf First, Then Split, Then Cascade

Think of an index on **`account_number`**. Each entry is conceptually **`(account_number → pointer or PK)`**.

### Steps

1. Search from root to the **leaf** where the new key belongs.  
2. Insert in **sorted order** in that leaf.  
3. If the leaf **overflows** (more keys than allowed for one node): **split** the leaf into two nodes, choose a **separator** (often the **median** key in textbook splits), and **insert that separator into the parent**.  
4. If the **parent** overflows, split it too—**cascade upward**.  
5. If the **root** splits, a **new root** is created with two children → **height increases by one**.

### Tiny example (order 3, max 2 keys per node)

Insert **10**, **20**, **30** → when **30** arrives, the node `[10, 20]` cannot fit three keys in one node:

```
After 10, 20:  [10, 20]

After 30 (split — promote middle key 20):
        [20]
       /    \
    [10]    [30]
```

**Cascade:** if the parent also becomes overfull after receiving **20**, split the parent the same way, possibly creating a **new root**. That is how the structure stays **balanced** without rebalancing passes over the whole tree.

---

## 10. Query (Search)

1. Start at **root**.  
2. Binary search (or scan) on the node’s keys to pick the **child** until you reach a leaf.  
3. On the leaf: key found → follow **pointer** to the row (or read the row directly in a clustered index); not found → **no match**.

**Example (order-5 style, up to 4 keys per node):**

```
                    [50]
                   /    \
              [30]        [70]
            /     \      /     \
        [10,20] [40] [60] [80,90]
```

- Find **60**: from `50` go right; from `70` go left to `[60]` → found.  
- Find **75**: descend to leaf `[80,90]` → **not found**.

**Disk read model:** one page per level along the path when the cache does not hold those pages.

---

## 11. Update

- **Non-key columns change** (name, balance): update the **row** only; the **index entry for `account_number`** is unchanged.  
- **Indexed key changes** (e.g. correcting an account number): logically **delete the old key** from the index and **insert the new key**—so you pay **delete + insert** cost in the tree.

---

## 12. Delete: Underflow, Borrow, Merge

1. Find the **leaf** that holds the key and **remove** it.  
2. If the node still satisfies the **minimum fill** rule, done.  
3. If it **underflows**:  
   - **Borrow** a key from a **sibling** through the parent (rotate keys and separators), **or**  
   - **Merge** with a sibling: combine entries and **pull down** a key from the parent.  
4. If the parent becomes too small, repeat **upward**; the **root** may disappear if its last children merge, and **height can decrease**.

Deletes are fiddlier than inserts; engines add **heuristics** (prefer borrow vs merge), **lazy deletion** flags, and **B+Tree** leaf chaining to keep ranges fast.

---

## 13. Why B-Trees Feel “Instant” for OLTP Lookups

1. **High fan-out:** hundreds of keys per page → each level covers a huge slice of the key space.  
2. **Small height:** **log with a large base** (fan-out) grows slowly with **n**.  
3. **Few random reads:** point lookups touch **few pages** along one path—exactly what you want when **disk seeks** dominate.

Together, that is why indexed lookups on millions of rows are often **a handful of page accesses** (and often **all cached**).

---

## 14. Worked Examples (Numeric): Building and Searching

### B-Tree of order 3 (max 2 keys per node)

Account IDs inserted in order: **10**, **20**, **30**, **40**, **50**, **15**, **25**, **35**, **32** — keys read as **account_number** values.

**After several steps (abbreviated):**

```
        [20, 40]
       /    |    \
 [10,15] [25] [32,35] [50]
```

(Exact shape depends on your split choice when a node fills; the point is **splits propagate** and keep **balance**.)

### Larger order (order 5 → up to 4 keys per node)

Insert account IDs: **10, 20, 30, 40, 50, 60, 70, 80, 90**.

```
                    [50]
                   /    \
              [30]        [70]
            /     \      /     \
        [10,20] [40] [60] [80,90]
```

**Query** mapping **60** to a toy “full” account id: three node visits as shown—**height** visits in the uncached model.

---

## 15. Comparison: Binary Search vs B-Tree

| Feature | Binary search (sorted array) | B-Tree / B+Tree (index on disk) |
|--------|------------------------------|----------------------------------|
| Structure | One contiguous sorted array | Tree of **pages** |
| Branching | 2 halves per step | Up to **m** children per node |
| Best when | RAM, static or batch-updated data | Large **n**, **random** lookups, **few seeks** |
| Updates | Inserts/deletes can shift **O(n)** | **Splits / merges** along one path **O(height)** |
| Reads (model) | Often one array in memory | **≈ height** page reads per point query (cold) |

---

## 16. Putting It Together: Indexes on `account_number`

```sql
CREATE INDEX idx_account_number ON accounts (account_number);
```

Roughly, the database:

1. Maintains a **B+Tree** (conceptually a B-Tree family index) where nodes are **pages** of sorted **account numbers** and pointers.  
2. **Lookup** walks the tree: **O(height)** page accesses, **binary search inside each page** after load.  
3. **Insert/Delete** preserve balance with **splits/merges**.  
4. **Cold** point queries ≈ **height** reads; **warm** cache makes most steps RAM-only.

### Operation summary

| Operation | What the index does |
|----------|---------------------|
| **Search** | Root to leaf using separators; binary search inside each page. |
| **Insert** | Leaf insert; split on overflow; promote separator; cascade to new root if needed. |
| **Update (key unchanged)** | Often **no index change**; only table row updates. |
| **Update (key changed)** | **Delete old + insert new** in the index. |
| **Delete** | Remove at leaf; borrow or merge; shrink height if root collapses. |

**Summary line:** Binary search minimizes comparisons **inside** each sorted block; a B-Tree / B+Tree stacks those blocks into a **shallow** tree so **disk** does **few random page reads** per lookup—what you want when millions of **numeric** keys must resolve in milliseconds.

---

*Derived from `notes/Index.md` (Binary Search & B-Tree sections) and expanded with terminology, B+Tree context, page-size intuition, height scaling, full search walkthrough, detailed insert/delete behavior, and operation summary.*
