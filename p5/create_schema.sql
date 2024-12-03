-- CS 4750: Database Systems
-- P3 SQL Basics

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)


-- ------------------------------------------------------------------------
-- ---------------------------- CREATING TABLES ---------------------------
-- ------------------------------------------------------------------------

PRAGMA foreign_keys = ON;

-- Users table
CREATE TABLE Users (
    uid INTEGER PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL UNIQUE
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