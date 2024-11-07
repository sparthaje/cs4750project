-- CS 4750: Database Systems
-- P4 Advanced SQL

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)

-- Users table
CREATE TABLE Users (
    uid INTEGER PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
    -- Initally was going to use OAuth for sign-in, but for encryption going to add a password field
    password VARCHAR(255) NOT NULL
);


-- NOTE: These would be called from the application layer where the encryption 
--       key wil be pulled from a secrets server or environment variable. Also,
--       rather than a normal decrypt to retrieve the password you would encrypt
--       the submitted password and compare it to what is stored in the DB. 

-- Insert user with encrypted password
INSERT INTO Users (username, email, password)
VALUES 
    ('user1', 'user1@example.com', AES_ENCRYPT('user1password', 'my_secret_key'));


-- Retrieve the decrypted password for a user
SELECT username, email, AES_DECRYPT(password, 'my_secret_key') AS decrypted_password
FROM Users
WHERE username = 'user1';
