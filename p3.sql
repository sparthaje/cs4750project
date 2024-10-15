-- CS 4750: Database Systems
-- P3 SQL Basics

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)


-- ------------------------------------------------------------------------
-- ---------------------------- CREATING TABLES ---------------------------
-- ------------------------------------------------------------------------

-- Users table
CREATE TABLE Users (
    uid INTEGER PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

-- FollowingList table
CREATE TABLE FollowingList (
    following_uid INTEGER,
    followed_uid INTEGER,
    PRIMARY KEY (following_uid, followed_uid),
    FOREIGN KEY (following_uid) REFERENCES Users(uid),
    FOREIGN KEY (followed_uid) REFERENCES Users(uid),
    CHECK (following_uid != followed_uid)
);

-- Artist table
CREATE TABLE Artist (
    artist_id INTEGER PRIMARY KEY,
    stage_name VARCHAR(100) NOT NULL UNIQUE
);

-- Album table
CREATE TABLE Album (
    album_id INTEGER PRIMARY KEY,
    artist_id INTEGER NOT NULL,
    title VARCHAR(100) NOT NULL,
    date DATE NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
    CHECK (date <= CURRENT_DATE)
);

-- Song table
CREATE TABLE Song (
    sid INTEGER PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    duration INTEGER NOT NULL,
    album_id INTEGER NOT NULL,
    FOREIGN KEY (album_id) REFERENCES Album(album_id),
    CHECK (duration > 0)
);

-- Post table
CREATE TABLE Post (
    pid INTEGER PRIMARY KEY,
    uid INTEGER NOT NULL,
    sid INTEGER NOT NULL,
    caption VARCHAR(280),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uid) REFERENCES Users(uid),
    FOREIGN KEY (sid) REFERENCES Song(sid)
    CHECK (caption IS NULL OR LENGTH(TRIM(caption)) > 0)
);

-- Repost table
CREATE TABLE Repost (
    uid INTEGER,
    pid INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (uid, pid),
    FOREIGN KEY (uid) REFERENCES Users(uid),
    FOREIGN KEY (pid) REFERENCES Post(pid)
);

-- Like table
CREATE TABLE Like (
    pid INTEGER,
    uid INTEGER,
    PRIMARY KEY (pid, uid),
    FOREIGN KEY (pid) REFERENCES Post(pid),
    FOREIGN KEY (uid) REFERENCES Users(uid)
);

-- SuperLike table
CREATE TABLE SuperLike (
    pid INTEGER,
    uid INTEGER,
    date DATE NOT NULL,
    PRIMARY KEY (pid, uid),
    FOREIGN KEY (pid) REFERENCES Post(pid),
    FOREIGN KEY (uid) REFERENCES Users(uid),
    UNIQUE (uid, date)
);

-- Comment table
CREATE TABLE Comment (
    pid INTEGER,
    uid INTEGER,
    cid INTEGER,
    message VARCHAR(280) NOT NULL,
    PRIMARY KEY (pid, uid, cid),
    FOREIGN KEY (pid) REFERENCES Post(pid),
    FOREIGN KEY (uid) REFERENCES Users(uid)
);

-- UserProfile table
CREATE TABLE UserProfile (
    uid INTEGER PRIMARY KEY,
    bio VARCHAR(500),
    location VARCHAR(100),
    FOREIGN KEY (uid) REFERENCES Users(uid)
);

-- SavedMusic table
CREATE TABLE SavedMusic (
    uid INTEGER,
    sid INTEGER,
    PRIMARY KEY (uid, sid),
    FOREIGN KEY (uid) REFERENCES Users(uid),
    FOREIGN KEY (sid) REFERENCES Song(sid)
);

-- ------------------------------------------------------------------------
-- ---------------------------- INSERTING DATA ----------------------------
-- ------------------------------------------------------------------------

-- Create users
INSERT INTO Users (uid, username, email) VALUES
(1, 'john_doe', 'john@example.com'),
(2, 'jane_smith', 'jane@example.com'),
(3, 'mike_johnson', 'mike@example.com'),
(4, 'emily_brown', 'emily@example.com'),
(5, 'david_wilson', 'david@example.com'),
(6, 'chris_evans', 'chris@example.com'),
(7, 'susan_clark', 'susan@example.com'),
(8, 'peter_parker', 'peter@example.com'),
(9, 'bruce_wayne', 'bruce@example.com'),
(10, 'clark_kent', 'clark@example.com'),
(11, 'tony_stark', 'tony@example.com'),
(12, 'natasha_romanoff', 'natasha@example.com'),
(13, 'steve_rogers', 'steve@example.com'),
(14, 'wanda_maximoff', 'wanda@example.com'),
(15, 'bruce_banner', 'bruceb@example.com'),
(16, 'thor_odinson', 'thor@example.com'),
(17, 'loki_laufeyson', 'loki@example.com'),
(18, 'peter_quill', 'peterq@example.com'),
(19, 'gamora_zen', 'gamora@example.com'),
(20, 'drax_destroyer', 'drax@example.com'),
(21, 'rocket_raccoon', 'rocket@example.com'),
(22, 'groot_tree', 'groot@example.com'),
(23, 'scott_lang', 'scott@example.com'),
(24, 'hope_van', 'hope@example.com'),
(25, 'sam_wilson', 'sam@example.com'),
(26, 'bucky_barnes', 'bucky@example.com'),
(27, 'tchalla_blackpanther', 'tchalla@example.com'),
(28, 'shuri_blackpanther', 'shuri@example.com'),
(29, 'pepper_potts', 'pepper@example.com'),
(30, 'happy_hogan', 'happy@example.com'),
(31, 'nick_fury', 'nick@example.com'),
(32, 'maria_hill', 'maria@example.com'),
(33, 'phil_coulson', 'phil@example.com'),
(34, 'carol_danvers', 'carol@example.com'),
(35, 'rhodey_war_machine', 'rhodey@example.com');

-- Insert UserProfile entries
INSERT INTO UserProfile (uid, bio, location) VALUES
(1, 'Bio for john@example.com', 'Virginia'),
(2, 'Bio for jane@example.com', 'Virginia'),
(3, 'Bio for mike@example.com', 'Virginia'),
(4, 'Bio for emily@example.com', 'Virginia'),
(5, 'Bio for david@example.com', 'Virginia'),
(6, 'Bio for chris@example.com', 'Virginia'),
(7, 'Bio for susan@example.com', 'Virginia'),
(8, 'Bio for peter@example.com', 'Virginia'),
(9, 'Bio for bruce@example.com', 'Virginia'),
(10, 'Bio for clark@example.com', 'Virginia'),
(11, 'Bio for tony@example.com', 'Virginia'),
(12, 'Bio for natasha@example.com', 'New York'),
(13, 'Bio for steve@example.com', 'Virginia'),
(14, 'Bio for wanda@example.com', 'Virginia'),
(15, 'Bio for bruceb@example.com', 'Virginia'),
(16, 'Bio for thor@example.com', 'Virginia'),
(17, 'Bio for loki@example.com', 'Virginia'),
(18, 'Bio for peterq@example.com', 'Virginia'),
(19, 'Bio for gamora@example.com', 'Virginia'),
(20, 'Bio for drax@example.com', 'Virginia'),
(21, 'Bio for rocket@example.com', 'Virginia'),
(22, 'Bio for groot@example.com', 'Virginia'),
(23, 'Bio for scott@example.com', 'Virginia'),
(24, 'Bio for hope@example.com', 'Virginia'),
(25, 'Bio for sam@example.com', 'Virginia'),
(26, 'Bio for bucky@example.com', 'Virginia'),
(27, 'Bio for tchalla@example.com', 'Virginia'),
(28, 'Bio for shuri@example.com', 'Virginia'),
(29, 'Bio for pepper@example.com', 'Virginia'),
(30, 'Bio for happy@example.com', 'Virginia'),
(31, 'Bio for nick@example.com', 'Virginia'),
(32, 'Bio for maria@example.com', 'Virginia'),
(33, 'Bio for phil@example.com', 'Virginia'),
(34, 'Bio for carol@example.com', 'Virginia'),
(35, 'Bio for rhodey@example.com', 'Virginia');


-- Insert Artists
INSERT INTO Artist (artist_id, stage_name) VALUES
(1, 'The Silent Echo'),
(2, 'Lunar Dreams'),
(3, 'Neon Nights'),
(4, 'Electric Waves'),
(5, 'Celestial Beats'),
(6, 'Retro Vibes'),
(7, 'Urban Symphony'),
(8, 'Crimson Sky'),
(9, 'Silver Haze'),
(10, 'Golden Horizon'),
(11, 'Moonlit Shadows'),
(12, 'Stellar Pulse'),
(13, 'Ocean Breeze'),
(14, 'Thunder Strikes'),
(15, 'Radiant Glow'),
(16, 'Mystic Flare'),
(17, 'Velvet Sound'),
(18, 'Frozen Sunset'),
(19, 'Galactic Groove'),
(20, 'Echo Chamber'),
(21, 'Prismatic Rain'),
(22, 'Shattered Glass'),
(23, 'Phoenix Rising'),
(24, 'Burning Ember'),
(25, 'Whispered Secrets'),
(26, 'Emerald Dawn'),
(27, 'Sapphire Dreams'),
(28, 'Crystalline Echoes'),
(29, 'Silent Thunder'),
(30, 'Golden Phoenix');

-- Insert Albums
INSERT INTO Album (album_id, artist_id, title, date) VALUES
(1, 1, 'Echoes of Silence', '2022-03-12'),
(2, 2, 'Lunar Eclipse', '2021-06-25'),
(3, 3, 'Neon Skies', '2023-01-15'),
(4, 4, 'Waveforms', '2022-11-10'),
(5, 5, 'Beats of the Cosmos', '2023-02-18'),
(6, 6, 'Retro Journey', '2021-12-03'),
(7, 7, 'City Vibes', '2023-08-05'),
(8, 8, 'Crimson Reign', '2021-05-20'),
(9, 9, 'Haze of Silver', '2023-07-01'),
(10, 10, 'Horizon Peaks', '2022-04-17'),
(11, 11, 'Moonlit Dance', '2021-10-28'),
(12, 12, 'Pulse of the Stars', '2023-03-21'),
(13, 13, 'Ocean’s Rhythm', '2022-12-09'),
(14, 14, 'Storm Surge', '2022-05-22'),
(15, 15, 'Glow of the Night', '2023-09-15'),
(16, 16, 'Flare of the Mystic', '2021-09-14'),
(17, 17, 'Soundscapes', '2022-06-19'),
(18, 18, 'Frozen Horizon', '2023-02-08'),
(19, 19, 'Groove of the Galaxy', '2021-11-30'),
(20, 20, 'Echoes from the Depth', '2022-07-12'),
(21, 21, 'Rainfall Symphony', '2021-08-03'),
(22, 22, 'Broken Glass', '2023-05-25'),
(23, 23, 'Rise of the Phoenix', '2022-10-11'),
(24, 24, 'Ember of the Flame', '2021-03-22'),
(25, 25, 'Secrets in the Wind', '2023-06-14'),
(26, 26, 'Emerald Glow', '2022-01-16'),
(27, 27, 'Dreams of the Sapphire', '2021-04-07'),
(28, 28, 'Crystal Echoes', '2023-08-27'),
(29, 29, 'Thunderous Silence', '2022-02-05'),
(30, 30, 'Phoenix Flight', '2021-12-19'),
(31, 1, 'Global Rhymes', '2020-1-19');

-- Insert Songs
INSERT INTO Song (sid, title, duration, album_id) VALUES
(1, 'Silent Waves', 240, 1),
(2, 'Lunar Tide', 195, 2),
(3, 'Neon Nightfall', 210, 3),
(4, 'Electric Pulse', 185, 4),
(5, 'Cosmic Journey', 200, 5),
(6, 'Retro Beats', 178, 6),
(7, 'City Lights', 230, 7),
(8, 'Crimson Sunset', 215, 8),
(9, 'Silver Lining', 225, 9),
(10, 'Golden Dawn', 190, 10),
(11, 'Moonlit Whisper', 205, 11),
(12, 'Pulse of Time', 220, 12),
(13, 'Ocean Breeze', 245, 13),
(14, 'Storm Rider', 210, 14),
(15, 'Radiant Glow', 195, 15),
(16, 'Mystic Waves', 200, 16),
(17, 'Velvet Nights', 180, 17),
(18, 'Frozen Echo', 220, 18),
(19, 'Galactic Drift', 205, 19),
(20, 'Echo Chamber', 215, 20),
(21, 'Prismatic Light', 195, 21),
(22, 'Shattered Dreams', 220, 22),
(23, 'Phoenix Flight', 240, 23),
(24, 'Ember Glow', 195, 24),
(25, 'Whispers in the Dark', 205, 25),
(26, 'Emerald Sky', 210, 26),
(27, 'Sapphire Night', 190, 27),
(28, 'Crystal Clear', 225, 28),
(29, 'Thunderous Roar', 215, 29),
(30, 'Golden Phoenix', 200, 30),
(31, 'Echoes in Silence', 230, 1),
(32, 'Lunar Glow', 220, 2),
(33, 'Neon Dreams', 205, 3),
(34, 'Wavebreaker', 190, 4),
(35, 'Celestial Beats', 200, 5),
(36, 'Retro Future', 185, 6),
(37, 'Symphony of the City', 210, 7),
(38, 'Crimson Storm', 195, 8),
(39, 'Silver Horizon', 215, 9),
(40, 'Golden Waves', 225, 10),
(41, 'Moonlit Serenade', 190, 11),
(42, 'Stellar Rhythm', 195, 12),
(43, 'Breeze of Time', 205, 13),
(44, 'Thunder Strikes Twice', 240, 14),
(45, 'Glow of Stars', 195, 15),
(46, 'Mystic Dream', 210, 16),
(47, 'Velvet Silence', 225, 17),
(48, 'Frozen Flame', 200, 18),
(49, 'Galactic Pulse', 210, 19),
(50, 'Echoes of the Heart', 215, 20);


INSERT INTO Post (pid, uid, sid, caption) VALUES
(1, 1, 1, 'Loving this silent vibe from Silent Waves!'),
(2, 2, 3, 'Neon Dreams is perfect for late-night thoughts.'),
(3, 3, 5, 'Cosmic Journey is out of this world!'),
(4, 4, 7, 'City Lights really sets the mood for an evening drive.'),
(5, 5, 10, 'Golden Dawn gives such a hopeful feeling.'),
(6, 6, 13, 'Ocean Breeze is so relaxing, a must-listen!'),
(7, 7, 17, 'Velvet Nights, perfect for chilling out.'),
(8, 1, 3, 'Neon Dreams is perfect for late-night thoughts.'),
(9, 8, 20, 'Echo Chamber is mind-blowing!'),
(10, 9, 25, 'Whispers in the Dark gives me chills'),
(11, 10, 30, 'Golden Phoenix is pure fire!'),
(12, 11, 35, 'Retro Future takes me back in time'),
(13, 12, 40, 'Golden Waves is so soothing'),
(14, 13, 45, 'Glow of Stars lights up my night'),
(15, 14, 50, 'Echoes of the Heart resonates with me'),
(16, 15, 2, 'Lunar Tide is out of this world'),
(17, 16, 4, 'Electric Pulse gets me energized'),
(18, 17, 6, 'Retro Beats is my new jam'),
(19, 18, 8, 'Crimson Sunset paints my evening'),
(20, 19, 11, 'Moonlit Whisper is hauntingly beautiful'),
(21, 20, 14, 'Storm Rider takes me on a journey'),
(22, 21, 16, 'Mystic Waves is truly enchanting'),
(23, 22, 18, 'Frozen Echo chills me to the bone'),
(24, 23, 21, 'Prismatic Light brightens my day'),
(25, 24, 23, 'Phoenix Flight makes me feel reborn'),
(26, 25, 26, 'Emerald Sky is a visual treat'),
(27, 26, 28, 'Crystal Clear sounds so pure'),
(28, 27, 31, 'Echoes in Silence speaks volumes'),
(29, 28, 33, 'Neon Dreams colors my imagination'),
(30, 29, 36, 'Retro Future is a blast from the past');


-- Insert Likes
INSERT INTO Like (pid, uid) VALUES
(1, 2),  -- User 2 liked Post 1
(2, 3),
(3, 4),
(4, 5),
(5, 6),
(6, 7),
(7, 8),
(8, 9),
(9, 10),
(10, 11),
(11, 12), 
(12, 13),
(13, 14),
(14, 15),
(15, 16),
(16, 17),
(17, 18), 
(18, 19), 
(19, 20),
(20, 21),
(21, 22),
(22, 23), 
(23, 24), 
(24, 25), 
(25, 26),
(26, 27),
(27, 28),
(28, 29),
(29, 30),
(30, 1);

-- Insert SuperLikes
INSERT INTO SuperLike (pid, uid, date) VALUES
(1, 3, '2023-10-10'), -- User 3 super liked Post 1 on 2023-10-10
(1, 8, '2023-10-10'), (2, 4, '2023-10-11'), (3, 5, '2023-10-12'), (4, 6, '2023-10-13'), (5, 7, '2023-10-14'), (6, 8, '2023-10-15'), (7, 9, '2023-10-16'), (8, 10, '2023-10-17'),
(9, 11, '2023-10-18'), (10, 12, '2023-10-19'), (11, 13, '2023-10-20'),
(12, 14, '2023-10-21'), (13, 15, '2023-10-22'), (14, 16, '2023-10-23'),
(15, 17, '2023-10-24'), (16, 18, '2023-10-25'), (17, 19, '2023-10-26'),
(18, 20, '2023-10-27'), (19, 21, '2023-10-28'), (20, 22, '2023-10-29'),
(21, 23, '2023-10-30'), (22, 24, '2023-10-31'), (23, 25, '2023-11-01'),
(24, 26, '2023-11-02'), (25, 27, '2023-11-03'), (26, 28, '2023-11-04'),
(27, 29, '2023-11-05'), (28, 30, '2023-11-06'), (29, 1, '2023-11-07'), (30, 1, '2023-11-08');

-- Insert Following relationships
INSERT INTO FollowingList (following_uid, followed_uid) VALUES
(2, 1),  -- User 2 follows User 1
(3, 1), 
(4, 1), 
(5, 1), 
(6, 1), 
(7, 1), 
(8, 1), 
(9, 1), 
(10, 1),
(11, 1),
(12, 1),
(13, 1),
(14, 1),
(15, 1),
(16, 1),
(17, 1),
(18, 1),
(19, 1), (20, 1), (21, 1), (22, 1), (23, 1), (24, 1), (25, 1),
(26, 1), (27, 1), (28, 1), (29, 1), (30, 1),
(1, 2), (3, 2), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),
(9, 2), (10, 2), (11, 2), (12, 2);


-- Insert into reposts table with current timestamps
INSERT INTO Repost (uid, pid) VALUES
(1, 6), (2, 5), (3, 4), (4, 3), (5, 2), (6, 1), (7, 5),
(8, 6), (9, 7), (10, 8), (11, 9), (12, 10),
(13, 11), (14, 12), (15, 13), (16, 14), (17, 15),
(18, 16), (19, 17), (20, 18), (21, 19), (22, 20),
(23, 21), (24, 22), (25, 23), (26, 24), (27, 25),
(28, 26), (29, 27), (30, 28);


INSERT INTO Comment (cid, pid, uid, message) VALUES
(1, 1, 2, 'This is a great post! Thanks for sharing!'),
(2, 2, 3, 'I agree, Neon Dreams is fantastic!'),
(3, 3, 4, 'Cosmic Journey takes me to another dimension'),
(4, 4, 5, 'City Lights is perfect for my commute'),
(5, 5, 6, 'Golden Dawn always lifts my spirits'),
(6, 6, 7, 'Ocean Breeze is my go-to relaxation track'),
(7, 7, 8, 'Velvet Nights puts me in a great mood'),
(8, 8, 9, 'I can''t get enough of Neon Dreams'),
(9, 9, 10, 'Echo Chamber is truly mind-bending'),
(10, 10, 11, 'Whispers in the Dark is hauntingly beautiful'),
(11, 11, 12, 'Golden Phoenix is absolutely epic'),
(12, 12, 13, 'Retro Future makes me nostalgic'),
(13, 13, 14, 'Golden Waves calms my soul'),
(14, 14, 15, 'Glow of Stars is breathtaking'),
(15, 15, 16, 'Echoes of the Heart speaks to me'),
(16, 16, 17, 'Lunar Tide is out of this world'),
(17, 17, 18, 'Electric Pulse gets me moving'),
(18, 18, 19, 'Retro Beats is my new favorite'),
(19, 19, 20, 'Crimson Sunset sets the perfect mood'),
(20, 20, 21, 'Moonlit Whisper is so atmospheric'),
(21, 21, 22, 'Storm Rider is an adrenaline rush'),
(22, 22, 23, 'Mystic Waves transports me'),
(23, 23, 24, 'Frozen Echo gives me chills'),
(24, 24, 25, 'Prismatic Light brightens my day'),
(25, 25, 26, 'Phoenix Flight is empowering'),
(26, 26, 27, 'Emerald Sky is a masterpiece'),
(27, 27, 28, 'Crystal Clear sounds so pure'),
(28, 28, 29, 'Echoes in Silence is profound'),
(29, 29, 30, 'Neon Dreams fuels my imagination'),
(30, 29, 30, 'Neon Dreams fuels my imagination');

INSERT INTO SavedMusic (uid, sid) VALUES
(2, 2), (3, 3), (4, 4), (5, 5), (6, 6),
(7, 7), (8, 8), (9, 9), (10, 10), (11, 11),
(12, 12), (13, 13), (14, 14), (15, 15), (16, 16),
(17, 17), (18, 18), (19, 19), (20, 20), (21, 21),
(22, 22), (23, 23), (24, 24), (25, 25), (26, 26),
(27, 27), (28, 28), (29, 29), (30, 30);

-- ------------------------------------------------------------------------
-- ----------------------- DESCRIPTIVE QUERIES ----------------------------
-- ------------------------------------------------------------------------

SELECT "1. Count the total number of users in this platform" AS Result;  -- Print description for query
SELECT COUNT(uid) AS total_users
FROM Users;

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "2. Find the average duration (seconds) of song added in the platform" AS Result;  -- Print description for query
SELECT AVG(duration) AS avg_song_duration
FROM Song;

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "3. Find which user has posted the most posts" AS Result;  -- Print description for query
SELECT u.username, COUNT(p.pid) AS post_count
FROM Users u
JOIN Post p ON u.uid = p.uid
GROUP BY u.username
HAVING COUNT(p.pid) = (
    SELECT MAX(post_count)
    FROM (SELECT COUNT(pid) AS post_count FROM Post GROUP BY uid) AS post_counts
);

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "4. Find posts which include songs longer than the average duration" AS Result;  -- Print description for query
SELECT p.caption, s.title, s.duration
FROM Post p
JOIN Song s ON p.sid = s.sid
WHERE s.duration > (SELECT AVG(duration) FROM Song);

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "5. Get number of likes per post" AS Result;  -- Print description for query
SELECT p.pid, COUNT(l.uid) AS total_likes
FROM Post p
LEFT JOIN Like l ON p.pid = l.pid
GROUP BY p.pid;

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "6. Find the most liked post (list all ties)" AS Result;  -- Print description for query
WITH PostLikeCounts AS (
    SELECT p.pid, COUNT(l.uid) AS like_count
    FROM Post p
    LEFT JOIN Like l ON p.pid = l.pid
    GROUP BY p.pid
)
SELECT p.pid, plc.like_count, p.caption
FROM PostLikeCounts plc
JOIN Post p ON plc.pid = p.pid
WHERE plc.like_count = (SELECT MAX(like_count) FROM PostLikeCounts);

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "7. Find all posts with more than one super like on the same date" AS Result;  -- Print description for query
SELECT p.pid, p.caption, sl.date, COUNT(sl.uid) AS super_like_count
FROM Post p
JOIN SuperLike sl ON p.pid = sl.pid
GROUP BY p.pid, p.caption, sl.date
HAVING COUNT(sl.uid) > 1;

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "8. Find the arist who has the most albums on the MusicTwitter Platform" AS Result;  -- Print description for query
SELECT a.stage_name, COUNT(al.album_id) AS album_count
FROM Artist a
JOIN Album al ON a.artist_id = al.artist_id
GROUP BY a.stage_name
HAVING COUNT(al.album_id) = (
    SELECT MAX(album_count)
    FROM (SELECT COUNT(album_id) AS album_count FROM Album GROUP BY artist_id) AS album_counts
);

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "9. Find the user(s) with the most followers taking into account ties" AS Result;  -- Print description for query
WITH FollowerCounts AS (
    SELECT followed_uid, COUNT(following_uid) AS follower_count
    FROM FollowingList
    GROUP BY followed_uid
)
SELECT u.uid, u.username, fc.follower_count
FROM FollowerCounts fc
JOIN Users u ON fc.followed_uid = u.uid
WHERE fc.follower_count = (SELECT MAX(follower_count) FROM FollowerCounts);

SELECT CHAR(10) AS Result;  -- put a line break between each query

SELECT "10. List distribution of locations for users" AS Result;  -- Print description for query
SELECT location, COUNT(uid) AS user_count
FROM UserProfile
GROUP BY location
ORDER BY user_count DESC;
