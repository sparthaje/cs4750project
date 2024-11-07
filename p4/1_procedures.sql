-- CS 4750: Database Systems
-- P4 Advanced SQL

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)


-- 1. Add follower
--    Purpose: Add a follower to the user's FollowingList
--    Use Case: When the follow button get's clicked on a user profile this method can be called to store this interaction

CREATE PROCEDURE AddFollower(
    IN following_uid INT,
    IN followed_uid INT
)
BEGIN
    -- Prevent self-following
    IF following_uid = followed_uid THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A user cannot follow themselves';
    ELSE
        INSERT INTO FollowingList (following_uid, followed_uid)
        VALUES (following_uid, followed_uid);
    END IF;
END;

-- 2. Add a song to a users saved music list
--    Purpose: Store the relation between a song and a specific user's saved list
--    Use Case: When the user sees a song they like, they should be able to click one button to add it to their list, this sql method can handle that
CREATE PROCEDURE AddSongToSavedMusic(
    IN uid INT,
    IN sid INT
)
BEGIN
    INSERT INTO SavedMusic (uid, sid)
    VALUES (uid, sid);
END;

-- 3. Get all posts from a specific user
--    Purpose: Returns all posts from a user
--    Use Case: This procedure is valuable for user profile pages, showing all original posts and reposts ordered by timestamp in a single query
CREATE PROCEDURE GetUserPosts(
    IN uid INT
)
BEGIN
    SELECT p.pid, p.caption, p.timestamp, s.title AS song_title
    FROM Post p
    JOIN Song s ON p.sid = s.sid
    WHERE p.uid = uid

    UNION ALL

    SELECT rp.pid, p.caption, rp.timestamp, s.title AS song_title
    FROM Repost rp
    JOIN Post p ON rp.pid = p.pid
    JOIN Song s ON p.sid = s.sid
    WHERE rp.uid = uid
    ORDER BY timestamp DESC
END;

-- TESTING
CALL AddFollower(1, 2);
CALL AddSongToSavedMusic(3, 101);
CALL GetUserPosts(1);
