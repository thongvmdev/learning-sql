DELIMITER $$

CREATE PROCEDURE InsertMillionUsers()
BEGIN
    DECLARE i INT DEFAULT 1;
    
    -- Tắt kiểm tra khóa ngoại và autocommit để tăng tốc tối đa
    SET autocommit = 0;
    SET unique_checks = 0;
    SET foreign_key_checks = 0;

    WHILE i <= 1000000 DO
        -- Insert theo lô 1000 dòng để tránh tràn bộ nhớ nhưng vẫn đảm bảo tốc độ
        INSERT INTO usersidx (username, created_at) 
        VALUES (CONCAT('user_', i), FROM_UNIXTIME(UNIX_TIMESTAMP('2026-01-01 00:00:00') + FLOOR(RAND() * 31536000)));
        
        -- Cứ mỗi 10.000 dòng thì Commit một lần để giải phóng buffer
        IF (MOD(i, 10000) = 0) THEN
            COMMIT;
        END IF;
        
        SET i = i + 1;
    END WHILE;

    COMMIT; -- Commit phần còn lại
    
    -- Bật lại các thiết lập mặc định
    SET autocommit = 1;
    SET unique_checks = 1;
    SET foreign_key_checks = 1;
END$$

DELIMITER ;

-- Gọi Procedure để bắt đầu insert
CALL InsertMillionUsers();

-- Xóa Procedure sau khi dùng xong (tùy chọn)
-- DROP PROCEDURE IF EXISTS InsertMillionUsers;