# Instagram Database Clone - Progress Tracker

Track your progress through the Instagram database schema design project. Check off items as you complete them.

**Start Date:** **\*\***\_**\*\***  
**Target Completion:** **\*\***\_**\*\***

---

## 📋 Phase 1: Schema Creation & Setup

### Environment Setup

- [ ] Start MySQL/PostgreSQL database
- [ ] Create database: `CREATE DATABASE instagram_clone;`
- [ ] Switch to database: `USE instagram_clone;`
- [ ] Verify connection working

---

### Create Tables (Do in this order!)

#### v Step 1: Users Table

- [x] Create `users` table with all fields
- [x] Verify structure: `DESCRIBE users;`
- [x] Test: Insert 1 sample user
- [x] Test: Try inserting duplicate username (should fail)
- [x] Understand why: Username has UNIQUE constraint

**Key Learning:**

- Auto-increment primary key
- UNIQUE constraint on username
- TIMESTAMP DEFAULT NOW()

---

#### v Step 2: Photos Table

- [x] Create `photos` table with all fields
- [x] Verify foreign key to users
- [x] Test: Insert 2-3 photos for your test user
- [x] Test: Try inserting photo with invalid user_id (should fail)
- [x] Understand why: Foreign key constraint

**Key Learning:**

- Foreign key: `user_id → users(id)`
- One-to-Many relationship (one user, many photos)

---

#### v Step 3: Comments Table

- [x] Create `comments` table with all fields
- [x] Verify TWO foreign keys (user_id AND photo_id)
- [x] Test: Insert 3-4 comments
- [x] Test: Insert multiple comments from same user on same photo (should work!)
- [x] Understand why: Comments are entities, not pure relationships

**Key Learning:**

- Comments have their own ID (not composite key)
- TWO foreign keys create "triangle relationship"
- Same user can comment multiple times on same photo

---

#### v Step 4: Likes Table

- [x] Create `likes` table with composite primary key
- [x] Verify: `SHOW CREATE TABLE likes;` (check composite PK)
- [x] Test: Insert a like (user likes photo)
- [x] Test: Try inserting same like again (should fail!)
- [x] Understand why: Composite PK prevents duplicates

**Key Learning:**

- Composite primary key: `(user_id, photo_id)`
- No separate ID needed
- Many-to-Many relationship

---

#### v Step 5: Follows Table

- [x] Create `follows` table with composite primary key
- [x] Verify: Both foreign keys point to `users` table
- [x] Test: Insert a follow relationship
- [x] Test: Try following same person twice (should fail!)
- [x] Test: Try following yourself (should fail if CHECK added)
- [x] Understand why: Self-referential Many-to-Many

**Key Learning:**

- Self-referential relationship (users → users)
- `follower_id` vs `followee_id` naming
- Composite PK: `(follower_id, followee_id)`

---

#### v Step 6: Tags & Photo_Tags Tables

- [x] Create `tags` table
- [x] Verify: UNIQUE constraint on tag_name
- [x] Create `photo_tags` junction table
- [x] Verify: Composite PK on (photo_id, tag_id)
- [x] Test: Insert 5-10 tags
- [x] Test: Link photos to tags via photo_tags
- [x] Test: Try adding same tag to photo twice (should fail!)

**Key Learning:**

- Normalized design (tag stored once, used many times)
- Many-to-Many between photos and tags
- Junction table with composite PK

---

### Verify Complete Schema

- [ ] Run: `SHOW TABLES;` (should show 7 tables)
- [ ] Check each table structure
- [ ] Verify all foreign keys working
- [ ] Take a screenshot of your ERD diagram

**Tables checklist:**

- [ ] users
- [ ] photos
- [ ] comments
- [ ] likes
- [ ] follows
- [ ] tags
- [ ] photo_tags

---

## 📊 Phase 2: Insert Realistic Sample Data

### Insert Users (Target: 15-20 users)

- [ ] Insert at least 15 users with varied created_at dates
- [ ] Use realistic usernames
- [ ] Spread dates across 2-3 months

**Goal Distribution:**

- [ ] 2-3 "early adopter" users (oldest accounts)
- [ ] 8-10 "regular" users
- [ ] 3-4 "new" users (recent signups)

**Verify:**

```sql
SELECT COUNT(*) FROM users;  -- Should be 15-20
SELECT MIN(created_at), MAX(created_at) FROM users;  -- Date range
```

---

### Insert Photos (Target: 50-100 photos)

- [ ] Insert photos for users (varied distribution)
- [ ] Some users have many photos (10+)
- [ ] Some users have few photos (1-3)
- [ ] Some users have NO photos (inactive)

**Goal Distribution:**

- [ ] 2-3 power users: 10-15 photos each
- [ ] 6-8 regular users: 3-8 photos each
- [ ] 4-5 inactive users: 0 photos

**Verify:**

```sql
-- Check distribution
SELECT user_id, COUNT(*) as photo_count
FROM photos
GROUP BY user_id
ORDER BY photo_count DESC;

-- Find users with no photos
SELECT u.username
FROM users u
LEFT JOIN photos p ON u.id = p.user_id
WHERE p.id IS NULL;
```

---

### Insert Comments (Target: 100-150 comments)

- [ ] Add comments across various photos
- [ ] Some photos have many comments (10+)
- [ ] Some photos have no comments
- [ ] At least 2-3 users should comment TWICE on the same photo

**Goal:**

- [ ] Varied comment lengths
- [ ] Realistic comment text (not just "test comment 1")
- [ ] Create "engagement hotspots" (popular photos with many comments)

**Verify:**

```sql
-- Photos with most comments
SELECT photo_id, COUNT(*) as comment_count
FROM comments
GROUP BY photo_id
ORDER BY comment_count DESC
LIMIT 5;

-- Users who comment twice on same photo
SELECT user_id, photo_id, COUNT(*)
FROM comments
GROUP BY user_id, photo_id
HAVING COUNT(*) > 1;
```

---

### Insert Likes (Target: 200-300 likes)

- [ ] Add likes across photos
- [ ] Create a "viral" photo with 30+ likes
- [ ] Some photos should have 0 likes
- [ ] Some users should be "active likers" (like 50+ photos)
- [ ] Create 1 "bot" user who likes EVERY photo

**Goal Distribution:**

- [ ] 1-2 viral photos: 30+ likes each
- [ ] 10-15 popular photos: 10-20 likes each
- [ ] 20-30 regular photos: 2-10 likes each
- [ ] 10-20 unpopular photos: 0-1 likes

**Verify:**

```sql
-- Most liked photos
SELECT photo_id, COUNT(*) as like_count
FROM likes
GROUP BY photo_id
ORDER BY like_count DESC
LIMIT 5;

-- Check for bot (user who liked ALL photos)
SELECT user_id, COUNT(*) as likes_given
FROM likes
GROUP BY user_id
HAVING likes_given = (SELECT COUNT(*) FROM photos);
```

---

### Insert Follows (Target: 50-80 relationships)

- [ ] Create follow relationships
- [ ] Include 5-10 mutual follows
- [ ] Create 1-2 "influencer" users (20+ followers)
- [ ] Create 2-3 users with 0 followers
- [ ] Create varied follower/following ratios

**Goal:**

- [ ] At least 5 mutual follow pairs
- [ ] 1 user with 20+ followers (popular)
- [ ] 1 user following 20+ people (active follower)
- [ ] 2-3 users with 0 followers (new/inactive)

**Verify:**

```sql
-- Find mutual follows
SELECT
    f1.follower_id,
    f1.followee_id,
    'Mutual' as status
FROM follows f1
JOIN follows f2
    ON f1.follower_id = f2.followee_id
    AND f1.followee_id = f2.follower_id
WHERE f1.follower_id < f1.followee_id;

-- Follower counts
SELECT
    followee_id,
    COUNT(*) as followers
FROM follows
GROUP BY followee_id
ORDER BY followers DESC;
```

---

### Insert Tags (Target: 20-30 tags, 100+ mappings)

- [ ] Create 20-30 common tags (#food, #sunset, #travel, etc.)
- [ ] Link photos to tags via `photo_tags`
- [ ] Each photo should have 2-5 tags
- [ ] Some tags should be very popular (used 20+ times)
- [ ] Some tags should be rare (used 1-2 times)

**Goal Distribution:**

- [ ] 5-8 "trending" tags: used 20+ times
- [ ] 10-15 "common" tags: used 5-15 times
- [ ] 5-8 "rare" tags: used 1-3 times

**Verify:**

```sql
-- Most popular tags
SELECT
    t.tag_name,
    COUNT(*) as usage_count
FROM photo_tags pt
JOIN tags t ON pt.tag_id = t.id
GROUP BY t.id
ORDER BY usage_count DESC
LIMIT 10;

-- Orphaned tags (created but never used)
SELECT t.*
FROM tags t
LEFT JOIN photo_tags pt ON t.id = pt.tag_id
WHERE pt.tag_id IS NULL;
```

---

## 🎯 Phase 3: Practice SQL Challenge Queries

Work through each challenge. For each one:

1. Try to write it yourself FIRST (without looking at solution)
2. Compare with provided solution
3. Run and verify results
4. Understand WHY each part of the query is needed

---

### Challenge 1: Find the 5 Oldest Users

- [ ] Attempt query yourself (no peeking!)
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: ORDER BY + LIMIT pattern

**Your Result:**

```
User 1: _____________ (joined: _________)
User 2: _____________ (joined: _________)
User 3: _____________ (joined: _________)
User 4: _____________ (joined: _________)
User 5: _____________ (joined: _________)
```

**Concepts Used:**

- [ ] ORDER BY
- [ ] LIMIT
- [ ] created_at sorting

---

### Challenge 2: Most Popular Registration Day

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: DAYNAME() function, GROUP BY

**Your Result:**

```
Most popular day: _____________ (count: _______)
```

**Concepts Used:**

- [ ] DAYNAME() function
- [ ] GROUP BY
- [ ] COUNT() aggregate
- [ ] ORDER BY DESC
- [ ] LIMIT 1

---

### Challenge 3: Find Inactive Users

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and verify results
- [ ] Understand: LEFT JOIN + WHERE NULL pattern

**Your Result:**

```
Inactive users found: ______
Examples: ____________, ____________, ____________
```

**Concepts Used:**

- [ ] LEFT JOIN (why not INNER JOIN?)
- [ ] WHERE IS NULL
- [ ] Finding "missing" relationships

---

### Challenge 4: Most Likes on a Single Photo

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: Multiple JOINs + GROUP BY + COUNT

**Your Result:**

```
Winner: _____________
Photo: _____________
Total Likes: _______
```

**Concepts Used:**

- [ ] INNER JOIN (multiple tables)
- [ ] COUNT(\*) with GROUP BY
- [ ] ORDER BY aggregate
- [ ] Getting username from user_id via JOIN

---

### Challenge 5: Average User Posts

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: Subqueries for division

**Your Result:**

```
Average posts per user: _______
```

**Concepts Used:**

- [ ] Subqueries
- [ ] Division in SELECT
- [ ] Aggregate functions

**Bonus Challenge:**

- [ ] Try alternative approach: `SELECT AVG(photo_count) FROM (...)`
- [ ] Compare results - do they match?

---

### Challenge 6: Top 5 Most Used Hashtags

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: JOIN through junction table

**Your Result:**

```
Top 5 hashtags:
1. _____________ (used _____ times)
2. _____________ (used _____ times)
3. _____________ (used _____ times)
4. _____________ (used _____ times)
5. _____________ (used _____ times)
```

**Concepts Used:**

- [ ] Joining through junction table (photo_tags)
- [ ] GROUP BY tags.id
- [ ] COUNT(\*) on junction table
- [ ] ORDER BY aggregate DESC

---

### Challenge 7: Find Bot Accounts (Liked Every Photo)

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: HAVING with subquery comparison

**Your Result:**

```
Bot accounts found: _______
Usernames: _____________
```

**Concepts Used:**

- [ ] GROUP BY user
- [ ] HAVING clause (vs WHERE)
- [ ] Subquery in HAVING
- [ ] COUNT(\*) comparison

**Test Setup:**

- [ ] Create a "bot" user if you don't have one
- [ ] Make them like every single photo
- [ ] Verify query catches them

---

### Challenge 8: Find Users Who Never Commented

- [ ] Attempt query yourself
- [ ] Compare with solution
- [ ] Run and record results
- [ ] Understand: Similar to Challenge 3 pattern

**Your Result:**

```
Users who never commented: _______
Examples: _____________, _____________, _____________
```

**Concepts Used:**

- [ ] LEFT JOIN
- [ ] WHERE IS NULL
- [ ] Finding "missing" relationships

**Compare:**

- [ ] How is this different from Challenge 3?
- [ ] Can a user be in both results? (no photos AND no comments)

---

### Challenge 9: MEGA CHALLENGE - Bot & Celebrity Percentage

- [ ] Read through solution slowly
- [ ] Break it down into parts:
  - [ ] Understand inner subquery (find users with no comments)
  - [ ] Understand outer query (count total vs inactive)
  - [ ] Understand final calculation (percentage)
- [ ] Run and record results
- [ ] Verify manually: Calculate percentage by hand

**Your Result:**

```
Total users: _______
Inactive users: _______
Percentage: _______%
```

**Concepts Used:**

- [ ] Nested subqueries
- [ ] Derived tables (FROM subquery)
- [ ] Percentage calculation
- [ ] LEFT JOIN with WHERE NULL

**Bonus:**

- [ ] Modify to find users who commented on EVERY photo
- [ ] Calculate percentage of BOTH groups combined

---

## 🧪 Phase 4: Test & Verify Understanding

### Data Integrity Checks

- [ ] No orphaned photos (photos without valid user)
- [ ] No orphaned comments (comments without valid user or photo)
- [ ] No duplicate usernames
- [ ] No duplicate likes (same user + photo)
- [ ] No duplicate follows
- [ ] No self-follows (if CHECK constraint added)

**Run These Verification Queries:**

```sql
-- 1. Orphaned photos check
SELECT COUNT(*) FROM photos p
LEFT JOIN users u ON p.user_id = u.id
WHERE u.id IS NULL;
-- Should return: 0

-- 2. Duplicate usernames check
SELECT username, COUNT(*)
FROM users
GROUP BY username
HAVING COUNT(*) > 1;
-- Should return: 0 rows

-- 3. Duplicate likes check
SELECT user_id, photo_id, COUNT(*)
FROM likes
GROUP BY user_id, photo_id
HAVING COUNT(*) > 1;
-- Should return: 0 rows
```

---

### Relationship Verification

- [ ] Every photo has an owner (can find via JOIN)
- [ ] Every comment has both user and photo (can JOIN both)
- [ ] Every like references valid user and photo
- [ ] Every follow references valid users
- [ ] Every photo_tag references valid photo and tag

---

### Foreign Key Tests

- [ ] Try deleting a user with photos (what happens?)
- [ ] Try deleting a photo with comments (what happens?)
- [ ] Try deleting a tag that's in use (what happens?)
- [ ] Document the cascade behavior

**Notes:**

```
When I delete a user:
- Their photos: _______________
- Their comments: _____________
- Their likes: ________________
- Their follows: ______________
```

---

## 📈 Phase 5: Additional Practice Queries

### Aggregation Practice

- [ ] Count total photos per user
- [ ] Count total comments per photo
- [ ] Count total likes per photo
- [ ] Count followers per user
- [ ] Count following per user
- [ ] Average rating per series (if you added ratings)

### Multi-Table JOIN Practice

- [ ] Get photos with owner username and like count
- [ ] Get comments with commenter name and photo owner name
- [ ] Get users with their stats (photos, comments, likes, followers)

### Subquery Practice

- [ ] Find photos with above-average likes
- [ ] Find users who follow more people than they have followers
- [ ] Find tags used more than the average tag

---

## 🚀 Phase 6: Advanced Topics

### Compare Tag Solutions

- [ ] Understand pros/cons of Solution 1 (string tags)
- [ ] Understand pros/cons of Solution 2 (unnormalized)
- [ ] Understand pros/cons of Solution 3 (normalized)
- [ ] Write down when you'd use each approach

**Decision Matrix:**

```
Solution 1 (String): Use when _______________
Solution 2 (Two tables): Use when _______________
Solution 3 (Three tables): Use when _______________
```

---

### Design Decisions Review

- [ ] Why composite PK for likes vs ID for comments?
- [ ] Why self-referential table for follows?
- [ ] Why separate tags table vs embedded in photos?
- [ ] Why NOT NULL on user_id in photos?
- [ ] Why UNIQUE on username?

---

### Optimization

- [ ] Add indexes on foreign keys
- [ ] Add indexes on created_at fields
- [ ] Run EXPLAIN on slow queries
- [ ] Optimize using indexes

```sql
-- Add these indexes
CREATE INDEX idx_photos_user_id ON photos(user_id);
CREATE INDEX idx_comments_photo_id ON comments(photo_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_likes_photo_id ON likes(photo_id);
CREATE INDEX idx_photos_created_at ON photos(created_at);
```

- [ ] Test query performance before/after indexes

---

### Practice > Note

- Challenge 1,2,4
