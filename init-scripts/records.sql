USE instagram_clone;

-- =======================
-- 0) Dọn dữ liệu cũ
-- =======================
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE photo_tags;
TRUNCATE TABLE tags;
TRUNCATE TABLE follows;
TRUNCATE TABLE likes;
TRUNCATE TABLE comments;
TRUNCATE TABLE photos;
TRUNCATE TABLE users;

SET FOREIGN_KEY_CHECKS = 1;

-- =======================
-- 1) Tối ưu session
-- =======================
SET autocommit = 0;
SET unique_checks = 0;
SET foreign_key_checks = 0;

-- =======================
-- 2) Tạo bảng digits & seq_1m
-- =======================
DROP TEMPORARY TABLE IF EXISTS digits;
CREATE TEMPORARY TABLE digits (d TINYINT NOT NULL PRIMARY KEY);
INSERT INTO digits(d) VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

DROP TABLE IF EXISTS seq_1m;
CREATE TABLE seq_1m (
  n INT NOT NULL PRIMARY KEY
);

INSERT INTO seq_1m(n)
SELECT
  (a.d
   + b.d * 10
   + c.d * 100
   + d.d * 1000
   + e.d * 10000
   + f.d * 100000) + 1 AS n
FROM digits a
CROSS JOIN digits b
CROSS JOIN digits c
CROSS JOIN digits d
CROSS JOIN digits e
CROSS JOIN digits f;

-- =======================
-- 3) Config số lượng
-- =======================
SET @NUM_USERS  = 50000;
SET @NUM_PHOTOS = 200000;
SET @NUM_LIKES  = 1000000;

-- =======================
-- 4) Insert users (50k)
-- =======================
INSERT INTO users (username, created_at)
SELECT
  CONCAT('user_', LPAD(n, 6, '0')) AS username,
  NOW() - INTERVAL (n % 365) DAY AS created_at
FROM seq_1m
WHERE n <= @NUM_USERS;

-- =======================
-- 5) Insert photos (200k)
-- =======================
INSERT INTO photos (image_url, user_id, created_at)
SELECT
  CONCAT('https://img.test/', n, '.jpg') AS image_url,
  ((n - 1) % @NUM_USERS) + 1 AS user_id,
  NOW() - INTERVAL (n % 365) DAY AS created_at
FROM seq_1m
WHERE n <= @NUM_PHOTOS;

-- =======================
-- 6) Insert likes (1,000,000)
-- =======================
INSERT INTO likes (user_id, photo_id, created_at)
SELECT
  ((( ( (n - 1) % @NUM_USERS) * 13) % @NUM_USERS) + 1) AS user_id,
  ((( ( (n - 1) DIV @NUM_USERS) * 37) % @NUM_PHOTOS) + 1) AS photo_id,
  NOW() - INTERVAL (n % 365) DAY AS created_at
FROM seq_1m
WHERE n <= @NUM_LIKES;

-- =======================
-- 7) Commit & restore
-- =======================
COMMIT;

SET foreign_key_checks = 1;
SET unique_checks = 1;
SET autocommit = 1;

-- =======================
-- 8) Kiểm tra số record
-- =======================
SELECT 'users'  AS tbl, COUNT(*) AS cnt FROM users
UNION ALL
SELECT 'photos' AS tbl, COUNT(*) AS cnt FROM photos
UNION ALL
SELECT 'likes'  AS tbl, COUNT(*) AS cnt FROM likes;