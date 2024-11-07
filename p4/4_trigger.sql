-- CS 4750: Database Systems
-- P4 Advanced SQL

-- Viraj Samant (quf6ks)
-- Shreepa Parthaje (cbf2xv)
-- Rithwik Raman (xak7jw)
-- Surya Shanmugaselvam (amy6zx)

CREATE TABLE ProfanityWords (
    word VARCHAR(50) PRIMARY KEY
);

INSERT INTO ProfanityWords (word) VALUES ('badword1');
INSERT INTO ProfanityWords (word) VALUES ('badword2');

CREATE TRIGGER CheckProfanityInBio
BEFORE UPDATE ON UserProfile
FOR EACH ROW
BEGIN
    -- Check if the new bio contains any prohibited words
    DECLARE profane_found INT;
    
    -- Search for any profane words in the new bio
    SELECT COUNT(*) INTO profane_found
    FROM ProfanityWords p
    WHERE INSTR(LOWER(NEW.bio), LOWER(p.word)) > 0;

    -- If a profane word is found, prevent the update
    IF profane_found > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bio contains prohibited words. Please remove them.';
    END IF;
END;
