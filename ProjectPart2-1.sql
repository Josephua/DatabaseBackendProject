-- Part 2

-- (I)

-- a) Winner(precinct) Show who won this precinct, Trump or Biden. Show what 
-- percentage of total votes went to the winner. Show what the final number of total 
-- votes was in this precinct.

DELIMITER //
DROP PROCEDURE IF EXISTS Winner;
CREATE PROCEDURE Winner(IN precinctname varchar(255), OUT winner varchar(255), OUT percentage double, OUT totalvotes2 int)
	BEGIN
		SELECT IF(Biden>Trump, "Biden", "Trump"), IF(Biden>Trump, (Biden/totalvotes), (Trump/totalvotes)), totalvotes INTO winner, percentage, totalvotes2
			FROM Penna -- try an if statement
			WHERE precinct = precinctname AND Timestamp IN (SELECT MAX(Timestamp) FROM Penna);
	END; //
DELIMITER ;

CALL Winner('Adams Township No. 1 Voting Precinct', @winner, @percent, @totalvotes);
SELECT @winner, @percent, @totalvotes;

-- b) RankALL(precinct) Show the numerical rank of this precinct in terms of the 
-- number of total votes it received (at the last timestamp) among all precincts in the 
-- database

DELIMITER //
DROP PROCEDURE IF EXISTS RankALL;
CREATE PROCEDURE RankALL(IN precinctname varchar(255))
    BEGIN
			SELECT vote_rank, totalvotes
			FROM (SELECT totalvotes,precinct,Trump,Biden,
					RANK() over (
					ORDER BY totalvotes DESC
					)vote_rank 
					FROM Penna
					WHERE Timestamp = '2020-11-11 21:50:46') rankTable
			WHERE precinct = precinctname;
    END; //
DELIMITER ;

CALL RankALL('Adams Township No. 1 Voting Precinct');

-- c) RankCounty(precinct) Show the numerical rank of this precinct in terms of the 
-- number of total votes it received (at the last timestamp) among all precincts in the 
-- county this precinct belongs to

DELIMITER //
DROP PROCEDURE IF EXISTS RankCounty;
CREATE PROCEDURE RankCounty(IN precinctname varchar(255))
    BEGIN
		SELECT vote_rank, totalvotes
			FROM (SELECT totalvotes,precinct,Trump,Biden,
					RANK() over (
					ORDER BY totalvotes DESC
					)vote_rank 
					FROM Penna
					WHERE Timestamp = '2020-11-11 21:50:46' AND locality = (SELECT DISTINCT locality 
						FROM Penna 
                        WHERE precinct = precinctname)) rankTable
			WHERE precinct = precinctname;
	END; //
DELIMITER ;

CALL RankCounty('Adams Township No. 1 Voting Precinct');

-- d) PlotPrecinct(precinct) Show a timeseries graph plotting the three attributes 
-- totalvotes, Trump, Biden as the Timestamps progress (X-axis for Timestamp, Y-axis 
-- for votes) for the given precinct. 

DELIMITER //
DROP PROCEDURE IF EXISTS PlotPrecinct;
CREATE PROCEDURE PlotPrecinct(IN precinctname varchar(255))
    BEGIN
		SELECT Timestamp AS X, totalvotes AS Y1, Trump AS Y2, Biden AS Y3
			FROM Penna
			WHERE precinct = precinctname
            ORDER BY Timestamp ASC;
	END; //
DELIMITER ;

-- To graders: Instead of doing 3 individual plots for each total votes, Trump, and Biden, I made a plot using all 3 of them.

CALL PlotPrecinct('Adams Township No. 1 Voting Precinct');

-- (e) EarliestPrecinct(vote_count) Show the first precinct to reach vote_count (i.e., the 
-- input) total votes as well as the timestamp when it occurred.  If multiple precincts have 
-- reached the input value at the timestamp, return the precinct from among those with the 
-- most total votes.

DELIMITER //
DROP PROCEDURE IF EXISTS EarliestPrecinct;
CREATE PROCEDURE EarliestPrecinct(IN vote_count int)
    BEGIN
		SELECT Timestamp, precinct, totalvotes
			FROM Penna
			WHERE totalvotes > vote_count AND Timestamp = (SELECT MIN(Timestamp) FROM Penna WHERE totalvotes > vote_count);
	END; //
DELIMITER ;

CALL EarliestPrecinct(1000);
CALL EarliestPrecinct(850);

-- (II)

-- a) PrecinctsWon(candidate) List precincts the candidate won displaying both the 
-- vote difference between the two candidates and the total votes the candidate 
-- received. Order the list by the vote difference.

DELIMITER //
DROP PROCEDURE IF EXISTS PrecinctsWon;
CREATE PROCEDURE PrecinctsWon(IN candidate varchar(255))
	BEGIN
		IF candidate = 'Biden' THEN (SELECT precinct, ABS(Biden - Trump) AS votediff, Biden 
			FROM Penna
			WHERE Biden > Trump AND Timestamp = '2020-11-11 21:50:46')
            ORDER BY votediff DESC;
		END IF;
		IF candidate = 'Trump' THEN (SELECT precinct, ABS(Biden - Trump) AS votediff, Trump
			FROM Penna
			WHERE Biden < Trump AND Timestamp = '2020-11-11 21:50:46')
            ORDER BY votediff DESC;
		END IF;
	END; //
DELIMITER ;

CALL PrecinctsWon('Trump');

-- (b) PrecinctsWonCount(candidate) Show the count of how many precincts the 
-- candidate won.

DELIMITER //
DROP PROCEDURE IF EXISTS PrecinctsWonCount;
CREATE PROCEDURE PrecinctsWonCount(IN candidate varchar(255))
	BEGIN
		IF candidate = 'Biden' THEN (SELECT COUNT(*)
			FROM Penna
			WHERE Biden > Trump AND Timestamp = '2020-11-11 21:50:46');
		END IF;
		IF candidate = 'Trump' THEN (SELECT COUNT(*)
			FROM Penna
			WHERE Biden < Trump AND Timestamp = '2020-11-11 21:50:46');
		END IF;
	END; //
DELIMITER ;

CALL PrecinctsWonCount('Biden');
CALL PrecinctsWonCount('Trump');

-- (c) PrecinctsFullLead(candidate) List precincts which the candidate held a lead 
-- for at every timestamp

DELIMITER //
DROP PROCEDURE IF EXISTS PrecinctsFullLead;
CREATE PROCEDURE PrecinctsFullLead(IN candidate varchar(255))
	BEGIN
		IF candidate = 'Biden' THEN (SELECT Timestamp, precinct
			FROM Penna
			WHERE Biden > Trump);
		END IF;
		IF candidate = 'Trump' THEN (SELECT Timestamp, precinct
			FROM Penna
			WHERE Biden < Trump);
		END IF;
	END; //
DELIMITER ;

CALL PrecinctsFullLead('Biden');
CALL PrecinctsFullLead('Trump');

SELECT DISTINCT Timestamp AS X, COUNT(Biden) AS Y
			FROM Penna
            GROUP BY Timestamp
            ORDER BY Timestamp ASC;

-- (d) PlotCandidate(candidate) Show a timeseries plot for the candidate plotting the 
-- number of votes that candidate received at each timestamp

DELIMITER //
DROP PROCEDURE IF EXISTS PlotCandidate;
CREATE PROCEDURE PlotCandidate(IN candidate varchar(255))
    BEGIN
		IF candidate = 'Biden' THEN (SELECT DISTINCT Timestamp AS X, SUM(Biden) AS Y
			FROM Penna
            GROUP BY Timestamp
            ORDER BY Timestamp ASC);
		END IF;
		IF candidate = 'Trump' THEN (SELECT DISTINCT Timestamp AS X, SUM(Trump) AS Y
			FROM Penna
            GROUP BY Timestamp
            ORDER BY Timestamp ASC);
		END IF;
	END; //
DELIMITER ;

CALL PlotCandidate('Biden');
CALL PlotCandidate('Trump');

-- e) PrecinctsWonCategory() Create a stored procedure based on a defined  
-- precinct category which is a subset of all precincts (i.e. Townships, Wards, etc), it 
-- is up to you how many of these procedures you want to define.  For example, you 
-- might create a stored procedure PrecinctsWonTownships() which will use all the 
-- township precincts.  For each procedure, return the name of the candidate who 
-- won that category of precincts as well as vote difference and the total votes of 
-- each candidate in that category.

DELIMITER //
DROP PROCEDURE IF EXISTS PrecinctsWonTownships;
CREATE PROCEDURE PrecinctsWonTownships()
	BEGIN
		SELECT IF (SUM(Biden) > SUM(Trump), "Biden", "Trump"), ABS(SUM(Biden) - SUM(Trump)), SUM(Trump), SUM(Biden)
			FROM Penna
			WHERE (precinct LIKE '%twp%' OR precinct LIKE '%township%') AND Timestamp = '2020-11-11 21:50:46'
			GROUP BY Timestamp;
	END; //
DELIMITER ;

CALL PrecinctsWonTownships();

DELIMITER //
DROP PROCEDURE IF EXISTS PrecinctsWonWards;
CREATE PROCEDURE PrecinctsWonWards()
	BEGIN
		SELECT IF (SUM(Biden) > SUM(Trump), "Biden", "Trump"), ABS(SUM(Biden) - SUM(Trump)), SUM(Trump), SUM(Biden)
			FROM Penna
			WHERE (precinct LIKE '%ward%') AND Timestamp = '2020-11-11 21:50:46'
			GROUP BY Timestamp;
	END; //
DELIMITER ;

CALL PrecinctsWonWards();

DELIMITER //
DROP PROCEDURE IF EXISTS PrecinctsWonBoroughs;
CREATE PROCEDURE PrecinctsWonBoroughs()
	BEGIN
		SELECT IF (SUM(Biden) > SUM(Trump), "Biden", "Trump"), ABS(SUM(Biden) - SUM(Trump)), SUM(Trump), SUM(Biden)
			FROM Penna
			WHERE (precinct LIKE '%borough%') AND Timestamp = '2020-11-11 21:50:46'
			GROUP BY Timestamp;
	END; //
DELIMITER ;

CALL PrecinctsWonBoroughs();

-- III

-- a) TotalVotes(timestamp, category) This stored procedure will take a category as 
-- input in the form of either ALL, Trump or Biden.  The procedure should show an 
-- ordered list of precincts by either totalvote, Trump, or Biden (based on the input 
-- category) at that timestamp.

DELIMITER //
DROP PROCEDURE IF EXISTS TotalVotes;
CREATE PROCEDURE TotalVotes(IN ts timestamp, IN category varchar(255))
	BEGIN
		IF category = 'ALL' THEN (SELECT precinct, totalvotes
			FROM Penna
            WHERE Timestamp = ts);
		END IF;
        IF category = 'Trump' THEN (SELECT precinct, Trump
			FROM Penna
            WHERE Timestamp = ts);
		END IF;
        IF category = 'Biden' THEN (SELECT precinct, Biden
			FROM Penna
            WHERE Timestamp = ts);
		END IF;
    END; //
DELIMITER ;

CALL TotalVotes('2020-11-11 21:50:46', 'ALL');
CALL TotalVotes('2020-11-11 21:50:46', 'Trump');
CALL TotalVotes('2020-11-11 21:50:46', 'Biden');

-- (b) GainDelta(timestamp) Using the timestamp preceding the input timestamp, 
-- return DELTA representing the amount of time passed since that preceding 
-- timestamp as well as GAIN, the number of additional votes gained since that 
-- preceding timestamp. Also return the ratio GAIN/DELTA,

DELIMITER //
DROP PROCEDURE IF EXISTS GainDelta;
CREATE PROCEDURE GainDelta(IN ts timestamp)
	BEGIN
		SET @prior := (SELECT MAX(Timestamp) FROM Penna WHERE Timestamp < ts);
        SET @delta := (SELECT TIMESTAMPDIFF(SECOND, @prior, ts));
        SET @gain := (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = ts) - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = @prior);
        SET @ratio := (SELECT (@gain/@delta));
        
        SELECT @delta, @gain, @ratio;
    END; //
DELIMITER ;

CALL GainDelta('2020-11-04 09:39:44');

-- (c) RankTimestamp() Rank all timestamps by the above GAIN/DELTA ratio in 
-- descending order 

DELIMITER //
DROP PROCEDURE IF EXISTS RankTimestamp;
CREATE PROCEDURE RankTimestamp()
	BEGIN
		DROP TABLE IF EXISTS rankTable;
		CREATE TABLE rankTable
			(
			id int NOT NULL AUTO_INCREMENT,
			Timestamp timestamp NOT NULL,
			sumVotes int NOT NULL,
			PRIMARY KEY (id),
			UNIQUE INDEX id_unique (id ASC) VISIBLE
		);
    
		INSERT INTO rankTable(Timestamp, sumVotes)
		SELECT DISTINCT Timestamp, SUM(totalvotes)
		FROM Penna
		GROUP BY Timestamp
		ORDER BY Timestamp ASC;

		SELECT t1.Timestamp, ((t2.sumVotes - t1.sumvotes)/TIMESTAMPDIFF(SECOND, t1.timestamp, t2.timestamp)) AS ratio 
			FROM rankTable t1, rankTable t2 
			WHERE t2.id = t1.id + 1
			ORDER BY ratio DESC;
    END; //
DELIMITER ;

CALL RankTimestamp();

-- (d) VotesPerDay(day) Show votes for Biden, Trump, and total votes that occurred on 
-- just day (i.e., day should be an input between 03 and 11 corresponding to the day of the 
-- timestamp) 

DELIMITER //
DROP PROCEDURE IF EXISTS VotesPerDay;
CREATE PROCEDURE VotesPerDay(IN perDay varchar(255))
	BEGIN
		IF perDay = '03' THEN (SELECT totalvotes, Trump, Biden
			FROM Penna
            WHERE Timestamp = '2020-11-03 19:47:21')
            LIMIT 1;
		END IF;
        IF perDay = '04' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-04 23:50:41') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-03 19:47:21')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-04 23:50:41') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-03 19:47:21')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-04 23:50:41') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-03 19:47:21')) AS BidenDiff;
		END IF;
        IF perDay = '05' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-05 00:16:15') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-04 23:50:41')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-05 00:16:15') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-04 23:50:41')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-05 00:16:15') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-04 23:50:41')) AS BidenDiff;
		END IF;
        IF perDay = '06' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-06 23:51:43') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-05 00:16:15')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-06 23:51:43') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-05 00:16:15')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-06 23:51:43') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-05 00:16:15')) AS BidenDiff;
		END IF;
        IF perDay = '07' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-07 23:06:36') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-06 23:51:43')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-07 23:06:36') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-06 23:51:43')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-07 23:06:36') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-06 23:51:43')) AS BidenDiff;
		END IF;
        IF perDay = '08' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-08 22:49:03') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-07 23:06:36')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-08 22:49:03') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-07 23:06:36')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-08 22:49:03') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-07 23:06:36')) AS BidenDiff;
		END IF;
        IF perDay = '09' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-09 23:44:13') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-08 22:49:03')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-09 23:44:13') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-08 22:49:03')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-09 23:44:13') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-08 22:49:03')) AS BidenDiff;
		END IF;
        IF perDay = '10' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-10 23:31:18') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-09 23:44:13')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-10 23:31:18') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-09 23:44:13')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-10 23:31:18') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-09 23:44:13')) AS BidenDiff;
		END IF;
        IF perDay = '11' THEN SELECT 
			((SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-11 21:50:46') - (SELECT SUM(totalvotes) FROM Penna WHERE Timestamp = '2020-11-10 23:31:18')) AS voteDiff,
            ((SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-11 21:50:46') - (SELECT SUM(Trump) FROM Penna WHERE Timestamp = '2020-11-10 23:31:18')) AS TrumpDiff,
            ((SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-11 21:50:46') - (SELECT SUM(Biden) FROM Penna WHERE Timestamp = '2020-11-10 23:31:18')) AS BidenDiff;
		END IF;
    END; //
DELIMITER ;

CALL VotesPerDay('03');
CALL VotesPerDay('04');
CALL VotesPerDay('05');
CALL VotesPerDay('06');
CALL VotesPerDay('07');
CALL VotesPerDay('08');
CALL VotesPerDay('09');
CALL VotesPerDay('10');
CALL VotesPerDay('11');

-- IV

-- Suspicious or Interesting Data
-- Is there anything suspicious about the data, some form of “look what I have found” type  
-- information? Justify why it might be suspicious - do not just submit a random query.  
-- Show some interest in data and imagine that you are an election fraud investigator. 
-- Give a query, result - and explanation why it is suspicious.  

-- Timeline of Trump vs Biden voters in Lehigh County in Pennsylvania
SELECT * FROM Penna;
SELECT Timestamp, SUM(Trump), SUM(Biden)
	FROM Penna
    WHERE locality LIKE "%Lehigh%"
    GROUP BY Timestamp
    ORDER BY Timestamp ASC;
    
-- Lehigh County is one of the counties that had Trump winning in the first day and Biden 
-- winning in the last day. I assume that the final vote count is correct as Hillary Clinton
-- won the county by almost seven thousand votes and the total vote count of the county in 
-- the 2016 election was about 160,000 votes, which the first day in the 2020 election for
-- Lehigh County was 132,000 votes, and that is also excluding third party. However, what I
-- can't understand is why couldn't they tally all the votes on the 4th on November and not
-- incremently increase it day by day. It's been done in the 2016 election, why can't they
-- do it here. 


