-- Create a stored procedure example
DELIMITER //

CREATE PROCEDURE IF NOT EXISTS GetUserPosts(IN userId INT)
BEGIN
    SELECT 
        u.username,
        u.email,
        p.id AS post_id,
        p.title,
        p.status,
        p.created_at
    FROM users u
    LEFT JOIN posts p ON u.id = p.user_id
    WHERE u.id = userId;
END //

-- Create a function example
CREATE FUNCTION IF NOT EXISTS GetUserPostCount(userId INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE post_count INT;
    SELECT COUNT(*) INTO post_count
    FROM posts
    WHERE user_id = userId;
    RETURN post_count;
END //

DELIMITER ;
