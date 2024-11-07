-- CS 4750: Database Systems
-- P4 Advanced SQL

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)

-- 1. Return total likes on a specific post, useful for rendering like count on a post

CREATE FUNCTION GetTotalLikes(post_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_likes INT;
    SELECT COUNT(*) INTO total_likes
    FROM Like
    WHERE pid = post_id;
    RETURN total_likes;
END;

-- 2. Return total followers a user has and how many they follow, useful for rendering information on a user page
CREATE FUNCTION GetUserFollowerCountWithFollowing(user_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE follower_count INT;
    DECLARE following_count INT;
    
    -- Get follower count
    SELECT COUNT(*) INTO follower_count
    FROM FollowingList
    WHERE followed_uid = user_id;

    -- Get following count
    SELECT COUNT(*) INTO following_count
    FROM FollowingList
    WHERE following_uid = user_id;

    -- Return both counts as a formatted string
    RETURN CONCAT('Followers: ', follower_count, ', Following: ', following_count);
END;

-- 3. Return if a song has been saved by a user, useful for rendering different icons on a song to know if its already been saved
CREATE FUNCTION IsSongSavedByUser(user_id INT, song_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE is_saved BOOLEAN;
    SET is_saved = EXISTS (
        SELECT 1 
        FROM SavedMusic 
        WHERE uid = user_id AND sid = song_id
    );
    RETURN is_saved;
END;