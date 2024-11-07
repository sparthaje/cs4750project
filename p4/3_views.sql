-- CS 4750: Database Systems
-- P4 Advanced SQL

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)

-- 1. A view that gives a list of albums, useful for rendering music library
CREATE VIEW ArtistAlbumsView AS
SELECT 
    a.stage_name AS artist_name,
    al.title AS album_title,
    al.date AS release_date
FROM Artist a
JOIN Album al ON a.artist_id = al.artist_id;

-- 2. A view of posts that also includes the number of likes it has and the song referenced
CREATE VIEW PostLikesView AS
SELECT 
    p.pid AS post_id,
    p.caption AS post_caption,
    COUNT(l.uid) AS total_likes,
    p.sid AS song_id,
    s.title AS song_title
FROM 
    Post p
LEFT JOIN Like l ON p.pid = l.pid
JOIN Song s ON p.sid = s.sid
GROUP BY 
    p.pid, p.caption, p.sid, s.title;

-- 3. View a users saved music in one page
CREATE VIEW UserSavedMusicView AS
SELECT 
    u.username AS user_username,
    up.bio AS user_bio,
    up.location AS user_location,
    s.title AS song_title,
    s.sid AS song_id
FROM 
    SavedMusic sm
JOIN Users u ON sm.uid = u.uid
JOIN Song s ON sm.sid = s.sid
LEFT JOIN UserProfile up ON u.uid = up.uid;

