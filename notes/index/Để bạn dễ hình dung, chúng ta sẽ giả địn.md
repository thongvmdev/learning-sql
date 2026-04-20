Để bạn dễ hình dung, chúng ta sẽ giả định một thiết lập cực kỳ đơn giản cho cây B+Tree này:

- **Bậc của cây (Order) $m = 3$**: Nghĩa là mỗi node chứa tối đa **2 keys**. Nếu thêm key thứ 3, node sẽ bị quá tải (overflow) và phải **Split** (tách).
- **Quy tắc Split (Tách node):**
  - **Tại Leaf Node (Node lá):** Khi tách, key ở giữa sẽ được đưa lên node cha, **nhưng vẫn được giữ lại bản sao ở node lá bên phải** (vì node lá phải chứa đầy đủ dữ liệu).
  - **Tại Internal Node (Node trung gian):** Key ở giữa được đưa lên node cha và **bị xóa** ở node hiện tại (chỉ đóng vai trò chỉ đường).

---

### Bước 1: Insert ID 1 và 2

Lúc này cây còn trống, chúng ta chỉ việc thêm vào node gốc (cũng là node lá).

**Kết quả:**
`[ (1, email1), (2, email2) ]`

- **Trạng thái:** Node chưa đầy (2/2 keys).
- **Giải thích:** Dữ liệu được sắp xếp tăng dần theo ID.

---

### Bước 2: Insert ID 3 (Xảy ra Split đầu tiên)

Node lá hiện tại `[1, 2]` đã đầy. Khi thêm ID 3, node tạm thời là `[1, 2, 3]`.

**Quy tắc Split tại Lá:**

1. Chọn phần tử giữa là **ID 2**.
2. Đưa ID 2 lên làm **Root** mới.
3. Tách thành 2 node lá: Lá trái `[1]` và Lá phải `[2, 3]`. (Lưu ý ID 2 xuất hiện ở cả hai nơi).

**Kết quả:**

```text
      [ 2 ]  <-- Root (Chỉ đường)
     /     \
[ (1) ] -> [ (2), (3) ]  <-- Leaf Nodes (Chứa data thực)
```

---

### Bước 3: Insert ID 4

ID 4 lớn hơn Root (2), nên nó sẽ được đưa vào node lá bên phải. Node lá bên phải đang là `[2, 3]`, thêm 4 thành `[2, 3, 4]`.

**Quy tắc Split tại Lá:**

1. Chọn phần tử giữa là **ID 3**.
2. Đưa ID 3 lên node cha (Root).
3. Tách node lá phải thành: `[2]` và `[3, 4]`.

**Kết quả:**

```text
        [ 2 | 3 ]  <-- Root giờ có 2 keys
       /    |    \
[ (1) ] -> [ (2) ] -> [ (3), (4) ]
```

- **Giải thích:** Lúc này Root vẫn chứa được (tối đa 2 keys), nên chưa cần tách Root.

---

### Bước 4: Insert ID 5 (Xảy ra Split tại Root)

ID 5 lớn hơn 3, nên vào node lá cuối cùng. Node đó đang là `[3, 4]`, thêm 5 thành `[3, 4, 5]`.

**Tách node lá `[3, 4, 5]`:**

1. Đưa **ID 4** lên node cha.
2. Node cha (Root) lúc này tạm thời trở thành `[2, 3, 4]`. **Quá tải!**

**Quy tắc Split tại Internal Node (Root):**

1. Chọn phần tử giữa là **ID 3**.
2. Đưa ID 3 lên làm **Root mới** (Level mới).
3. ID 3 **không** được giữ lại ở các node con bên dưới (khác với node lá).
4. Tách Root cũ thành 2 node trung gian: `[2]` và `[4]`.

**Kết quả cuối cùng:**

```text
             [ 3 ]             <-- New Root (Level 0)
           /       \
       [ 2 ]       [ 4 ]       <-- Internal Nodes (Level 1)
      /     \     /     \
[ (1) ] -> [ (2) ] -> [ (3) ] -> [ (4), (5) ] <-- Leaf Nodes (Level 2)
```

## **Js Code**

```js
class BPlusTreeNode {
  constructor(isLeaf = false) {
    this.isLeaf = isLeaf
    this.keys = []
    this.values = [] // Chỉ dùng cho leaf node
    this.children = [] // Chỉ dùng cho internal node
    this.next = null // Con trỏ nối các leaf nodes
  }
}

class BPlusTree {
  constructor(m = 3) {
    this.root = new BPlusTreeNode(true)
    this.m = m // Bậc của cây
  }

  // Hàm chèn dữ liệu
  insert(key, value) {
    console.log(`--- Inserting ID: ${key} ---`)
    let root = this.root

    // Nếu root đầy, tiến hành tách root (làm tăng chiều cao cây)
    if (root.keys.length === this.m - 1) {
      let newRoot = new BPlusTreeNode(false)
      newRoot.children.push(this.root)
      this.splitChild(newRoot, 0)
      this.root = newRoot
    }
    this.insertNonFull(this.root, key, value)
    this.printTree()
  }

  insertNonFull(node, key, value) {
    let i = node.keys.length - 1

    if (node.isLeaf) {
      // Chèn vào node lá và sắp xếp
      while (i >= 0 && key < node.keys[i]) {
        i--
      }
      node.keys.splice(i + 1, 0, key)
      node.values.splice(i + 1, 0, value)
    } else {
      // Tìm con thích hợp để đi xuống
      while (i >= 0 && key < node.keys[i]) {
        i--
      }
      i++
      if (node.children[i].keys.length === this.m - 1) {
        this.splitChild(node, i)
        if (key > node.keys[i]) i++
      }
      this.insertNonFull(node.children[i], key, value)
    }
  }

  splitChild(parent, index) {
    let m = this.m
    let fullNode = parent.children[index]
    let newNode = new BPlusTreeNode(fullNode.isLeaf)
    let midIndex = Math.floor(m / 2)
    let midKey = fullNode.keys[midIndex]

    // Tách keys và liên kết
    if (fullNode.isLeaf) {
      // Quy tắc Leaf: Giữ key trung tâm ở node lá bên phải
      newNode.keys = fullNode.keys.splice(midIndex)
      newNode.values = fullNode.values.splice(midIndex)
      newNode.next = fullNode.next
      fullNode.next = newNode
    } else {
      // Quy tắc Internal: Đẩy key trung tâm lên, không giữ lại ở con
      newNode.keys = fullNode.keys.splice(midIndex + 1)
      newNode.children = fullNode.children.splice(midIndex + 1)
      fullNode.keys.pop() // Xóa key trung tâm khỏi node cũ
    }

    parent.keys.splice(index, 0, midKey)
    parent.children.splice(index + 1, 0, newNode)
  }

  // Hàm in cấu trúc cây cơ bản để quan sát
  printTree() {
    let levels = []
    let traverse = (node, depth) => {
      levels[depth] = levels[depth] || []
      levels[depth].push(`[${node.keys.join('|')}]`)
      if (!node.isLeaf) {
        node.children.forEach((child) => traverse(child, depth + 1))
      }
    }
    traverse(this.root, 0)
    levels.forEach((lvl, i) => console.log(`Level ${i}: ${lvl.join('  ')}`))
    console.log('----------------------------')
  }

  // Tìm kiếm theo khoảng: WHERE key BETWEEN low AND high
  rangeSearch(low, high) {
    // Bước 1: Tìm leaf node chứa `low`
    let node = this.root
    while (!node.isLeaf) {
      let i = 0
      while (i < node.keys.length && low >= node.keys[i]) {
        i++
      }
      node = node.children[i]
    }

    // Bước 2: Quét sang phải qua linked list
    const results = []
    while (node !== null) {
      for (let i = 0; i < node.keys.length; i++) {
        if (node.keys[i] > high) return results // Vượt range → dừng
        if (node.keys[i] >= low) {
          results.push({ key: node.keys[i], value: node.values[i] })
        }
      }
      node = node.next // Nhảy sang leaf kế tiếp
    }
    return results
  }

  // Tìm kiếm một phần tử: WHERE key = target
  search(key) {
    // Bước 1: Đi từ root xuống leaf, tại mỗi internal node chọn hướng rẽ
    let node = this.root
    while (!node.isLeaf) {
      let i = 0
      while (i < node.keys.length && key >= node.keys[i]) {
        i++
      }
      node = node.children[i]
    }

    // Bước 2: Binary search trong leaf node (như MySQL InnoDB)
    let lo = 0, hi = node.keys.length - 1
    while (lo <= hi) {
      const mid = (lo + hi) >> 1
      if (node.keys[mid] === key) return { key, value: node.values[mid] }
      if (node.keys[mid] < key) lo = mid + 1
      else hi = mid - 1
    }
    return null
  }
}

// --- TEST CASE ---
const tree = new BPlusTree(3)
const users = [
  { id: 1, email: 'user1@gmail.com' },
  { id: 2, email: 'user2@gmail.com' },
  { id: 3, email: 'user3@gmail.com' },
  { id: 4, email: 'user4@gmail.com' },
  { id: 5, email: 'user5@gmail.com' },
]

users.forEach((u) => tree.insert(u.id, u.email))

// Inspect toàn bộ cây trong Chrome DevTools (expand để xem shared references)
console.log('--- Full Tree Object ---')
console.log(tree)

// Inspect từng leaf node và linked list
console.log('--- Leaf Linked List ---')
let leaf = tree.root
while (!leaf.isLeaf) leaf = leaf.children[0]  // đi xuống leaf đầu tiên
while (leaf) {
  console.log('Leaf:', leaf.keys, leaf.values, '→ next:', leaf.next?.keys ?? null)
  leaf = leaf.next
}

// Verify shared reference (cùng object, không phải copy)
console.log('--- Shared Reference Check ---')
const leaf1 = tree.root.children[0].children[0]
const leaf2_via_next = leaf1.next
const leaf2_via_children = tree.root.children[0].children[1]
console.log('leaf2 via next === leaf2 via children[1]:', leaf2_via_next === leaf2_via_children)

console.log('--- Range Search: id BETWEEN 2 AND 4 ---')
console.log(tree.rangeSearch(2, 4))

console.log('--- Point Search: id = 3 ---')
console.log(tree.search(3))

console.log('--- Point Search: id = 99 (không tồn tại) ---')
console.log(tree.search(99))
```

---

## Range Search: `id BETWEEN 2 AND 4`

Cây sau khi insert xong 5 users:

```text
             [ 3 ]                              ← Level 0 (Root)
           /       \
       [ 2 ]       [ 4 ]                        ← Level 1 (Internal)
      /     \     /     \
[ (1) ] → [ (2) ] → [ (3) ] → [ (4|5) ]        ← Level 2 (Leaf, nối nhau qua next)
```

### Bước 1: Tìm leaf chứa `low = 2` — O(log n)

Đi từ Root xuống, tại mỗi internal node so sánh `low` với các keys để chọn hướng rẽ:

```js
while (!node.isLeaf) {
  let i = 0
  while (i < node.keys.length && low >= node.keys[i]) i++
  node = node.children[i]
}
```

| Đang ở node | Keys | So sánh `low=2` | Rẽ hướng |
|-------------|------|-----------------|----------|
| Root `[3]` | `[3]` | 2 < 3 → `i` dừng ở 0 | `children[0]` → `[2]` |
| Internal `[2]` | `[2]` | 2 ≥ 2 → `i` tăng lên 1 | `children[1]` → Leaf `[(2)]` |

**Đến Leaf `[(2)]`** — đây là điểm bắt đầu.

---

### Bước 2: Quét sang phải qua linked list — O(k)

Từ đây không leo lên root nữa, chỉ đi thẳng theo `node.next`:

```js
while (node !== null) {
  for (let i = 0; i < node.keys.length; i++) {
    if (node.keys[i] > high) return results  // Vượt range → dừng
    if (node.keys[i] >= low) results.push(...)
  }
  node = node.next  // Nhảy sang leaf kế tiếp
}
```

| Leaf node | Keys | Hành động |
|-----------|------|-----------|
| `[(2)]` | `2` | 2 ≥ 2 và 2 ≤ 4 → **thu thập** `(2, user2@gmail.com)` → đi `next` |
| `[(3)]` | `3` | 3 ≥ 2 và 3 ≤ 4 → **thu thập** `(3, user3@gmail.com)` → đi `next` |
| `[(4\|5)]` | `4` | 4 ≥ 2 và 4 ≤ 4 → **thu thập** `(4, user4@gmail.com)` |
| `[(4\|5)]` | `5` | 5 > 4 → **dừng lại**, return |

### Kết quả

```js
[
  { key: 2, value: 'user2@gmail.com' },
  { key: 3, value: 'user3@gmail.com' },
  { key: 4, value: 'user4@gmail.com' },
]
```

### Tại sao Linked List hiệu quả hơn?

| | B-Tree (không có `next`) | B+Tree (có `next`) |
|---|---|---|
| Tìm điểm đầu | O(log n) | O(log n) |
| Mỗi key tiếp theo | O(log n) — leo lại từ root | O(1) — đi `next` |
| **Tổng với k kết quả** | **O(k × log n)** | **O(log n + k)** |

---

## Point Search: `id = 3`

Tìm đúng một phần tử — đây là trường hợp `WHERE id = 3`.

### Bước 1: Đi từ Root xuống Leaf — O(log n)

Logic rẽ nhánh giống hệt Range Search, chỉ khác là không cần linked list ở bước 2:

| Đang ở node | Keys | So sánh `key=3` | Rẽ hướng |
|-------------|------|-----------------|----------|
| Root `[3]` | `[3]` | 3 ≥ 3 → `i` tăng lên 1 | `children[1]` → Internal `[4]` |
| Internal `[4]` | `[4]` | 3 < 4 → `i` dừng ở 0 | `children[0]` → Leaf `[(3)]` |

**Đến Leaf `[(3)]`**.

### Bước 2: Binary Search trong Leaf — O(log m)

Vì keys trong leaf **luôn được sắp xếp tăng dần**, ta dùng binary search thay vì duyệt tuần tự (như MySQL InnoDB thực tế làm):

```js
let lo = 0, hi = node.keys.length - 1
while (lo <= hi) {
  const mid = (lo + hi) >> 1          // lấy index giữa (>> 1 = chia 2)
  if (node.keys[mid] === key) return { key, value: node.values[mid] }
  if (node.keys[mid] < key) lo = mid + 1
  else hi = mid - 1
}
return null
```

**Ví dụ tìm `id = 3` trong Leaf `[(3)]`:**

```
keys = [3],  lo = 0,  hi = 0

Vòng 1:
  mid = (0 + 0) >> 1 = 0
  keys[0] = 3 === key(3) → TÌM THẤY!
  return { key: 3, value: 'user3@gmail.com' }
```

### Trường hợp không tồn tại: `id = 99`

**Đi từ root xuống:**

| Đang ở node | Keys | So sánh `key=99` | Rẽ hướng |
|-------------|------|------------------|----------|
| Root `[3]` | `[3]` | 99 ≥ 3 → `i = 1` | `children[1]` → Internal `[4]` |
| Internal `[4]` | `[4]` | 99 ≥ 4 → `i = 1` | `children[1]` → Leaf `[(4\|5)]` |

**Binary search trong Leaf `[(4|5)]`:**

```
keys = [4, 5],  lo = 0,  hi = 1

Vòng 1:
  mid = (0 + 1) >> 1 = 0
  keys[0] = 4 < key(99) → lo = mid + 1 = 1

Vòng 2:
  mid = (1 + 1) >> 1 = 1
  keys[1] = 5 < key(99) → lo = mid + 1 = 2

lo(2) > hi(1) → thoát vòng lặp → return null
```

### Kết quả

```js
// tree.search(3)
{ key: 3, value: 'user3@gmail.com' }

// tree.search(99)
null
```

### Tại sao Binary Search tốt hơn `indexOf`?

| | `indexOf` (Linear) | Binary Search |
|---|---|---|
| Cách hoạt động | Duyệt từ trái sang phải | Chia đôi mỗi bước |
| Độ phức tạp | O(m) | O(log m) |
| Leaf 10 keys | Tối đa 10 bước | Tối đa 4 bước |
| Leaf 100 keys | Tối đa 100 bước | Tối đa 7 bước |
| Leaf 1000 keys | Tối đa 1000 bước | Tối đa 10 bước |

InnoDB dùng page 16KB, mỗi leaf chứa hàng trăm rows — binary search ở đây tiết kiệm đáng kể.

### So sánh Point Search vs Range Search

| | Point Search | Range Search |
|---|---|---|
| Mục tiêu | 1 phần tử chính xác | Nhiều phần tử trong khoảng |
| Tìm trong leaf | Binary search — O(log m) | Binary search điểm đầu, rồi scan |
| Dùng linked list? | Không cần | Có — quét qua `next` |
| Độ phức tạp | O(log n × log m) | O(log n × log m + k) |
| Ví dụ SQL | `WHERE id = 3` | `WHERE id BETWEEN 2 AND 4` |

---

### Tổng kết các quy tắc bạn vừa thấy:

1.  **Tính cân bằng:** Cây luôn phát triển từ dưới lên trên khi Root bị tách, đảm bảo khoảng cách từ Root đến mọi Lá luôn bằng nhau.
2.  **Tính liên kết:** Bạn có thấy các mũi tên `->` ở hàng cuối không? Đó là Linked List giúp bạn tìm `ID từ 2 đến 5` cực nhanh mà không cần quay lại Root.
3.  **Sự khác biệt Index/Data:** Ở bước cuối, ID 3 nằm ở Root chỉ để "chỉ hướng" (lớn hơn hoặc bằng 3 thì rẽ phải). Dữ liệu thực sự của ID 3 nằm ở Node lá bên dưới.

Bạn có muốn thử mô phỏng trường hợp **Delete (Xóa)** một ID không? Xóa trong B+Tree thú vị hơn vì nó có quy tắc "mượn" hoặc "gộp" node đấy!
