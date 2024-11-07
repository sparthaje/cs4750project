-- CS 4750: Database Systems
-- P4 Advanced SQL

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)


-- Index 1: Posts by timestamp
-- This will help with retrieving recent posts and feed generation
CREATE INDEX idx_post_timestamp
ON Post(timestamp DESC);

-- Index 2: Song search by title
-- This will optimize song search functionality
CREATE INDEX idx_song_title
ON Song(title)
INCLUDE (duration, album_id);

-- Index 3: User search by username
-- This will help with user search and @ mentions
CREATE INDEX idx_user_username
ON Users(username)
INCLUDE (email);
