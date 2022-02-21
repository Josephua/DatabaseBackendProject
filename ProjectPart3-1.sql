-- Part 3

-- (a) The sum of votes for Trump and Biden cannot be larger than totalvotes
SELECT DISTINCT 'false' AS 'Returns'  
	FROM Penna
    WHERE ((Trump + Biden) > totalvotes)
UNION
SELECT DISTINCT 'true' AS 'Returns'  
	FROM Penna
    WHERE !((Trump + Biden) > totalvotes);

-- (b) There cannot be any tuples with timestamps later than Nov 11 and earlier than Nov 3

SELECT DISTINCT 'false' AS 'Returns'  
	FROM Penna p
    WHERE (DATE(p.timestamp) < '2020-11-03' OR DATE(p.timestamp) > '2020-11-11')
UNION
SELECT DISTINCT 'true' AS 'Returns'  
	FROM Penna p
    WHERE !(DATE(p.timestamp) < '2020-11-03' OR DATE(p.timestamp) > '2020-11-11');

-- (c) Neither totalvotes, Trump’s votes nor Biden’s votes for any precinct and at any 
-- timestamp after 2020-11-05 00:00:00 will be smaller than the same attribute at the 
-- timestamp 2020-11-05 00:00:00 for that precinct. 

SELECT DISTINCT 'false' AS 'Returns'  
	FROM Penna p1 JOIN (SELECT * FROM Penna WHERE Timestamp = "2020-11-05 00:16:15") p2
    WHERE p1.precinct = p2.precinct AND p1.timestamp > p2.timestamp AND (p1.Trump < p2.Trump AND p1.Biden < p2.Biden AND p1.totalvotes < p2.totalvotes)
UNION
SELECT DISTINCT 'true' AS 'Returns'  
	FROM Penna p1 JOIN (SELECT * FROM Penna WHERE Timestamp = "2020-11-05 00:16:15") p2
    WHERE p1.precinct = p2.precinct AND p1.timestamp > p2.timestamp AND !(p1.Trump < p2.Trump AND p1.Biden < p2.Biden AND p1.totalvotes < p2.totalvotes);