-- Part 4

-- a) For each table in your database scheme you should create three log tables and three 
-- triggers. These tables will be called Updated Tuples, Inserted Tuples and Deleted Tuples. 
-- All three tables should have the same schema as the original table and should store any 
-- tuples which were updated (store them as they were before the update), any tuples which 
-- were inserted, and any tuples which were deleted in their corresponding tables.  The 
-- triggers should populate these tables upon each update/insertion/deletion. There will be one 
-- trigger for the update operation, one trigger for the insert operation and one trigger for the 
-- delete operation.

-- Updated Tuples

DROP TABLE testTable;
CREATE TABLE testTable
	AS SELECT ID, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump FROM Penna;
SELECT * FROM testTable;

DROP TABLE IF EXISTS UpdatedLog;
CREATE TABLE UpdatedLog
	(
    ID int,
    Timestamp timestamp,
    state varchar(10),
    locality varchar(255),
    precinct varchar(255),
    geo  varchar(255),
    totalvotes int,
    Biden int,
    Trump int
    );
    
DELIMITER //
	DROP TRIGGER IF EXISTS updateTrigger;
	CREATE TRIGGER updateTrigger
	AFTER UPDATE ON testTable
	FOR EACH ROW
    BEGIN
		IF old.Timestamp <> new.Timestamp THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
		ELSEIF old.state <> new.state THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
		ELSEIF old.locality <> new.locality THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
		ELSEIF old.precinct <> new.precinct THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
		ELSEIF old.geo <> new.geo THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
		ELSEIF old.totalvotes <> new.totalvotes THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
        ELSEIF old.Biden <> new.Biden THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
        ELSEIF old.Trump <> new.Trump THEN
			INSERT INTO UpdatedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
		END IF;
	END; //
DELIMITER ;

UPDATE testTable
	SET Biden = Biden + 100  
	WHERE precinct = 'Adams Township - Dunlo Voting Precinct';
    
UPDATE testTable
	SET Trump = Trump + 0  
	WHERE precinct = 'Adams Township - Dunlo Voting Precinct';

SELECT * from testTable;
SELECT * from UpdatedLog;

-- Inserted Tuples

DROP TABLE testTable;
CREATE TABLE testTable
	AS SELECT ID, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump FROM Penna;
SELECT * FROM testTable;

DROP TABLE IF EXISTS insertedLog;
CREATE TABLE insertedLog
	(
    ID int,
    Timestamp timestamp,
    state varchar(10),
    locality varchar(255),
    precinct varchar(255),
    geo  varchar(255),
    totalvotes int,
    Biden int,
    Trump int
    );
    
DELIMITER //
	DROP TRIGGER IF EXISTS insertTrigger;
	CREATE TRIGGER insertTrigger
	AFTER INSERT ON testTable
	FOR EACH ROW
    BEGIN
		INSERT INTO insertedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
		VALUES (new.id, new.Timestamp, new.state, new.locality, new.precinct, new.geo, new.totalvotes, new.Biden, new.Trump);
	END; //
DELIMITER ;

INSERT INTO testTable (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
			VALUES (-1, '2020-11-06 15:38:36', 'PA', 'Lackawanna', 'Scranton', 'Scranton', 200, 50, 150);
            
SELECT * from testTable ORDER BY ID ASC;
SELECT * from insertedLog;

-- Deleted Tuples

DROP TABLE testTable;
CREATE TABLE testTable
	AS SELECT ID, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump FROM Penna;
SELECT * FROM testTable;

DROP TABLE IF EXISTS deletedLog;
CREATE TABLE deletedLog
	(
    ID int,
    Timestamp timestamp,
    state varchar(10),
    locality varchar(255),
    precinct varchar(255),
    geo  varchar(255),
    totalvotes int,
    Biden int,
    Trump int
    );
    
DELIMITER //
	DROP TRIGGER IF EXISTS deleteTrigger;
	CREATE TRIGGER deleteTrigger
	AFTER DELETE ON testTable
	FOR EACH ROW
    BEGIN
		INSERT INTO deletedLog (id, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump)
		VALUES (old.id, old.Timestamp, old.state, old.locality, old.precinct, old.geo, old.totalvotes, old.Biden, old.Trump);
	END; //
DELIMITER ;

DELETE FROM testTable WHERE precinct = "Harrisburg";

SELECT * from deletedLog;
SELECT * from testTable ORDER BY ID ASC;

-- MoveVotes(Precinct, Timest, CoreCandidate, Number_of_Moved_Votes)
-- a) Precinct – one of the existing precincts
-- b) Timest must be existing timestamp. If Timest does not appear in Penna than MoveVotes 
-- should display a message “Unknown Timestamp”. 
-- c) The Number_of_Moved_Votes  parameter  (always positive integer) shows the number 
-- of votes to be moved from the CoreCandidate to another candidate and it cannot be 
-- larger than number of votes that the CoreCandidate has at the Timestamp.  If this is the 
-- case MoveVotes () should display a message “Not enough votes”.  
-- d) Of course if CoreCandidate is neither Trump nor Biden, MoveVotes() should say 
-- “Wrong Candidate”. 
-- After you are done with exceptions, you should move the Number_of_Moved_Votes from 
-- CoreCandidate to another candidate (there are only two) and do it not just for this Timestamp 
-- (the first parameter) but also for all T>Timestamp, that is all future timestamps in the given 
-- precinct. 
-- For example MoveVotes(Red Hill, 2020-11-06 15:38:36, ’Trump’, 100) will remove 100 votes 
-- from Trump and move it to Biden at 2020-11-06 15:38:36 and all future timestamps after that in 
-- the Red Hill precinct. 

DROP TABLE testPenna;
CREATE TABLE testPenna
	AS SELECT ID, Timestamp, state, locality, precinct, geo, totalvotes, Biden, Trump FROM Penna;

DELIMITER //
DROP PROCEDURE IF EXISTS MoveVotes;
CREATE PROCEDURE MoveVotes(IN Precinct varchar(255), IN Timest timestamp, IN CoreCandidate varchar(10), IN Number_of_Moved_Votes int)
	sp: BEGIN
		-- a)
		IF ((SELECT COUNT(*) FROM testPenna p WHERE p.precinct = Precinct) = 0) THEN
			SELECT 'Unknown Precinct' AS error;
            LEAVE sp;
		END IF;
        -- b)
		IF ((SELECT COUNT(*) FROM testPenna p WHERE p.Timestamp = Timest) = 0) THEN
			SELECT 'Unknown Timestamp' AS error;
            LEAVE sp;
		END IF;
        -- c)
        IF (CoreCandidate = 'Biden') THEN
			SET @Biden = (SELECT SUM(Biden) FROM testPenna t WHERE t.timestamp = Timest AND t.precinct = Precinct);
            IF (Number_of_Moved_Votes > @Biden) THEN
				SELECT 'Not enough votes' AS error;
				LEAVE sp;
			END IF;
		ELSEIF (CoreCandidate = 'Trump') THEN
			SET @Trump = (SELECT SUM(Trump) FROM testPenna t WHERE t.timestamp = Timest AND t.precinct = Precinct);
            IF (Number_of_Moved_Votes > @Trump) THEN
				SELECT 'Not enough votes' AS error;
				LEAVE sp;
			END IF;
		END IF;
        -- d)
        IF (CoreCandidate != 'Biden' AND CoreCandidate != 'Trump') THEN
			SELECT 'Wrong Candidate' AS error;
			LEAVE sp;
		END IF;
        -- main code
        IF (CoreCandidate = 'Biden') THEN
			UPDATE testPenna t
            SET t.Biden = t.Biden - Number_of_Moved_Votes, t.Trump = t.Trump + Number_of_Moved_Votes
            WHERE t.precinct = Precinct AND t.Timestamp >= timest;
		ELSEIF (CoreCandidate = 'Trump') THEN
			UPDATE testPenna t
            SET t.Trump = t.Trump - Number_of_Moved_Votes, t.Biden = t.Biden + Number_of_Moved_Votes
            WHERE t.precinct = Precinct AND t.Timestamp >= timest;
		END IF;
    END; //
DELIMITER ;

SELECT Trump FROM testPenna WHERE timestamp = '2020-11-04 03:58:36' AND precinct = 'Adams Township - Dunlo Voting Precinct';

SELECT * FROM testPenna;
CALL MoveVotes('Adams Township - Dunlo Voting Precinct', '2020-11-04 03:58:36', 'Trump', 100);
CALL MoveVotes('Adams Township - Dunlo Voting Precinct', '2020-11-04 03:58:36', 'Biden', 100);
CALL MoveVotes('Scranton', '2020-11-04 03:58:36', 'Trump', 100);
CALL MoveVotes('Adams Township - Dunlo Voting Precinct', '2020-11-04 05:58:36', 'Trump', 100);
CALL MoveVotes('Adams Township - Dunlo Voting Precinct', '2020-11-04 03:58:36', 'Jeb Bush', 100);
CALL MoveVotes('Adams Township - Dunlo Voting Precinct', '2020-11-04 03:58:36', 'Trump', 300);