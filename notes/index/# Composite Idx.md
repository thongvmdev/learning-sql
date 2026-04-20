# Composite indexes in MySQL: one query, one tree, why order matters

You have a `comments` table and a filter on two columns. A composite index is often the difference between touching a handful of index pages and scanning thousands of rows. This post walks through **why column order matches the query**, how InnoDB’s **B+tree** (and its **leaf linked list**) make point and range access fast, what **`EXPLAIN`** is telling you, and what happens when you only have single-column indexes.

---

## TL;DR

- A composite index `(photo_id, user_id)` sorts keys as **tuples** in the index tree, not as two unrelated columns.
- The optimizer can use the index efficiently when the `WHERE` clause uses a **left prefix** of the index: `photo_id` alone, or `photo_id` and `user_id` together—not `user_id` alone (for this order).
- **Point lookup**: one root-to-leaf traversal, then match `(A, B)`.
- **Range on `photo_id`**: land on the first `(A, …)` key, then walk **leaf siblings** in order until `photo_id` changes—no repeated tree probes for each row.
- **Secondary indexes** in InnoDB still point to the **clustered (PK) index**, so “find row” often means an extra PK lookup unless the query is **covering**.
- Without a composite index, MySQL may use **one** single-column index and **filter the rest in memory**, or use **index merge**—usually more work than one well-chosen composite index.

---

## The problem

**Table**

```sql
CREATE TABLE comments (
  id BIGINT PRIMARY KEY,
  photo_id BIGINT,
  user_id BIGINT,
  content TEXT
);
```

**Query**

```sql
SELECT *
FROM comments
WHERE photo_id = A AND user_id = B;
```

**Goal:** return every comment **by user B on photo A**.

---

## The fix: one index, both predicates in order

```sql
CREATE INDEX idx_photo_user ON comments(photo_id, user_id);
```

### Why `(photo_id, user_id)` and not the reverse?

The index is ordered **left to right** as a single sort key: first by `photo_id`, then by `user_id` for ties. Your equality predicates are `photo_id = A AND user_id = B`, which is exactly a **full prefix** of `(photo_id, user_id)`.

| Predicate in `WHERE` | Uses `idx_photo_user` well? |
| ---------------------- | --------------------------- |
| `photo_id = A` | Yes (prefix) |
| `photo_id = A AND user_id = B` | Yes (full prefix for this query) |
| `user_id = B` only | No (skips leading `photo_id`) |

Rule of thumb: **put the column that narrows the most (or appears alone in important queries) on the left**, as long as it still matches your left-prefix patterns.

---

## What InnoDB actually stores: B+tree keys

InnoDB stores secondary indexes as a **B+tree**. Conceptually each index entry is:

```text
(photo_id, user_id) → primary key (id)  →  then clustered index lookup for full row
```

So the index does not duplicate the whole row; it stores the indexed columns plus enough to find the row (the PK for InnoDB secondary indexes).

### Toy data

```text
(10,1), (10,2), (10,3),
(20,1), (20,2),
(30,1)
```

### Simplified build (splits are illustrative)

After a few inserts, a split might separate leaves like:

```text
[(10,1), (10,2)]   [(10,3), (20,1)]
```

with a parent separator (conceptually) guiding search toward the correct leaf. What matters for the story: **all keys in every leaf stay sorted** by `(photo_id, user_id)`.

Final leaf chain (sorted order):

```text
[ (10,1), (10,2) ] → [ (10,3), (20,1) ] → [ (20,2), (30,1) ]
```

---

## Linked leaves: why range scans are cheap

A B+tree’s **leaves** are linked in key order. That is how the engine walks “all rows for `photo_id = 10`” without doing a new tree descent for every row.

```text
Leaf1 → Leaf2 → Leaf3  (increasing key order)
```

**Point query** `WHERE photo_id = 10 AND user_id = 2`:

1. Traverse root → internal nodes → leaf (binary search within pages).
2. Land in the leaf that would contain `(10, 2)`.
3. Compare keys; on match, read PK from the index entry and **look up the row** in the clustered index (typical for `SELECT *`).

**Range query** `WHERE photo_id = 10`:

1. Find the **first** leaf position for `(10, -∞)`.
2. Scan forward along the leaf chain: `(10,1)`, `(10,2)`, `(10,3)`…
3. Stop when the next key has `photo_id ≠ 10`.

That pattern is “**one seek + sequential leaf walk**,” which is much cheaper than “random seek per row” for large hot ranges.

---

## Reading `EXPLAIN` (illustrative)

You might see something like:

```text
type: ref
key: idx_photo_user
key_len: 16
ref: const,const
rows: 1
```

**How to read it (high level):**

- **`key: idx_photo_user`** — the optimizer chose your composite index.
- **`ref: const,const`** — two equality constants bound to the index (here, both columns).
- **`key_len`** — how many bytes of the index prefix are used; **it depends on column types and nullability**. For two **non-null `BIGINT`** columns in the index, **16** (8 + 8) is a plausible value—not 8 unless only one `BIGINT` column participates in the range scan or the access path differs. Treat `key_len` as a **fact check** that your mental model matches the plan, not as a fixed magic number.
- **`type: ref`** — index lookup driven by equality predicates (typical for this pattern).
- **`rows`** — optimizer estimate; low is good when it matches reality.

When both columns are used with `=` and the index order matches, you usually get **efficient index access** for this query shape.

---

## When there is no composite index

Suppose you only have:

```sql
CREATE INDEX idx_photo ON comments(photo_id);
CREATE INDEX idx_user ON comments(user_id);
```

Same query:

```sql
SELECT *
FROM comments
WHERE photo_id = A AND user_id = B;
```

### Strategy A: pick one index (very common)

Example: use `idx_photo`.

1. Seek to `photo_id = A` and read **all** matching index entries (could be thousands).
2. For each candidate, check `user_id = B` (CPU filter).
3. For each surviving row, follow to the PK / row (I/O).

If `photo_id = A` matches **10,000** rows, you pay for scanning those entries (and likely many row lookups), even if only **one** row matches both predicates.

### Strategy B: index merge (possible, not a panacea)

The optimizer can sometimes combine `idx_photo` and `idx_user` (intersection/union-style plans depending on version and predicates). That still means **extra work**: multiple index scans, merge bookkeeping, and usually **row fetches** afterward. For “both equalities on the same table,” a single composite index is usually simpler and faster.

### Complexity at a glance

| Approach | What you pay |
| -------- | ------------ |
| Single-column index + filter | Scan many rows on the leading index, filter the second column after |
| Index merge | Two index scans + merge + lookups |
| Composite `(photo_id, user_id)` | One seek to `(A, B)` (or a short contiguous run if not unique) |

**Numeric intuition (illustrative):** 1M rows, 10K rows per `photo_id`, 5K rows per `user_id`. Without a composite index you might scan **10K** index entries on `photo_id`. With `(photo_id, user_id)` you seek directly into the `(A, B)` neighborhood—on the order of **log N** page touches for the seek, not O(number of comments on the photo).

---

## Two trees vs one tree

**Without** a composite index you have two unrelated orderings:

```text
idx_photo:  photo_id → PK
idx_user:   user_id  → PK
```

**With** `(photo_id, user_id)` you get **one physical sort order** in that index:

```text
(photo_id, user_id) → PK
```

Practical consequence: for a fixed `photo_id`, index entries are **already sorted by `user_id`**, which helps ordered pagination, range conditions on `user_id` *after* fixing `photo_id`, and some aggregation patterns—without an extra sort step when the plan lines up.

---

## When a composite index does not help

- **Skipping the left column:** `WHERE user_id = B` cannot use `idx_photo_user` as a B+tree seek on the leading `photo_id`.
- **Wrong order for your workload:** `INDEX(user_id, photo_id)` optimizes `user_id`-first patterns; your `photo_id` + `user_id` equality query may become a wide scan on `user_id` instead.
- **Over-indexing:** every index costs writes and cache; add composites for **proven** query paths.

---

## Mental model (single paragraph)

A composite index is not “two indexes glued together.” It is **one sorted key space** `(c1, c2, …)` stored in a **B+tree**, with **linked leaves** for cheap ordered scans. Your `WHERE` clause should supply a **left prefix** of that key if you want the seek to be selective. **Filtering happens along the access path** when the index matches; otherwise the engine **fetches wide** and filters later.

---

## Summary table

| Topic | Without composite (typical) | With composite `(photo_id, user_id)` |
| ----- | --------------------------- | ------------------------------------ |
| Index match | Often only one column | Both equalities in index order |
| Rows touched | Many candidates on one column | Small, targeted range |
| CPU filtering | Higher | Lower |
| I/O | More index + row reads | Fewer, more direct |
| Predictability | Depends on selectivity | Usually more stable |

**One line:** without a composite index you often **look up broad, then filter narrow**; with the right composite index you **seek narrow in the tree**.

---

## Further reading

- **Covering indexes** — include columns needed by `SELECT` so the secondary index alone satisfies the query and avoids PK lookups where possible.
- **Clustered vs secondary** — why `SELECT *` tends to cost more than covering `SELECT id` / narrow projections.
- **Wrong order** — `(user_id, photo_id)` vs `(photo_id, user_id)` and how `EXPLAIN` shows range vs ref.
- **When the optimizer ignores your index** — statistics, wrong types (`VARCHAR` vs numeric), functions on columns (`WHERE UPPER(x) = …`), or low selectivity making a full table scan look cheaper.

These topics are where textbook B+tree explanations meet production tuning.
