CREATE DATABASE Worldcup;

USE Worldcup;

show tables;

select * from batters;

-- Droping Unessential columns
ALTER TABLE Batters
DROP COLUMN Bowled_by;

ALTER TABLE Batters
DROP COLUMN MyUnknownColumn;

-- Q1 Finding the top scores in the tournamnet

SELECT Batsmen,R as Runs
FROM Batters
ORDER BY Runs DESC
LIMIT 10;

-- Q2 Finding players who score most 4s

SELECT Batsmen, SUM(4s) as Fours
FROM Batters
GROUP BY Batsmen
ORDER BY Fours DESC
LIMIT 10;

-- Q2 Finding players who score most 6s

SELECT Batsmen, SUM(6s) as Sixes
FROM Batters
GROUP BY Batsmen
ORDER BY Sixes DESC
LIMIT 10;

--  Q4 Most Total Runs scored by Individual Batsmen

SELECT Batsmen, SUM(R) as Runs
FROM Batters
GROUP BY Batsmen
ORDER BY Runs DESC
LIMIT 10;

-- Q5 Total Runs made by each teams

SELECT Team,SUM(R) as TotalRuns
FROM Batters
GROUP BY Team
ORDER BY TotalRuns DESC;

-- Q6 Total Runs conceded by each teams

SELECT Against,SUM(R) as TotalRuns
FROM Batters
GROUP BY Against
ORDER BY TotalRuns DESC;

-- Q7 Finding number of centuries by each team

WITH CTE as(
SELECT Team,R 
FROM Batters
WHERE R>=100)
SELECT Team,COUNT(Team) as Centuries
FROM CTE 
GROUP BY Team;

-- Q8  To get the scores of any match 

DELIMITER //

CREATE PROCEDURE MatchScores(team1 VARCHAR(255), team2 VARCHAR(255))	
BEGIN
    SELECT Team, SUM(R) AS Runs, COUNT(Team)-1 AS Wickets
    FROM Batters
    WHERE (Team = team1 AND Against = team2) OR (Team = team2 AND Against = team1)
    GROUP BY Team;
END//

DELIMITER ;

CALL MatchScores('England', 'India');

-- Q9 Finding Individual Player Report of a Batsmen

DELIMITER //

CREATE PROCEDURE BatsmenReport(player VARCHAR(255))
BEGIN
	SELECT Batsmen,SUM(R) as R,SUM(B) as B, SUM(4s) as 4s,SUM(6s) as 6s,ROUND(AVG(SR),2) as SR
	FROM Batters 
	WHERE Batsmen=player
	GROUP BY Batsmen;
END//

DELIMITER ;

CALL BatsmenReport("Virat Kohli");


-- Q10 Finding top scorer of each team

SELECT Batsmen,R as Runs,Team
FROM Batters b1
WHERE R = (
    SELECT MAX(R)
    FROM Batters b2
    WHERE b1.Team = b2.Team
)
ORDER BY Runs DESC;

-- Q11 Displaying Batting Scoreboard of a team

With CTE AS
(SELECT *,concat(Team,"-",Against) as vs
FROM Batters)
SELECT Batsmen,Out_by,R,B,4s,6s,ROUND(SR,2) as SR
 FROM CTE 
WHERE vs="England-India" OR vs="India-England";

-- Q12 Finding the players who got duck

SELECT * FROM batters
WHERE R=0 AND Out_by!="not out";


-- Q13 Finding Batting reports of each player of the team

SELECT Batsmen,SUM(R) as R,SUM(B) as B, SUM(4s) as 4s,SUM(6s) as 6s,ROUND(AVG(SR),2) as SR
FROM Batters 
WHERE Team="India"
GROUP BY Batsmen;

-- Q14 Finding the powerhitter players

SELECT Batsmen,R,B,4s,6s,SR
FROM Batters
WHERE SR>200 AND B>10
ORDER BY SR DESC;

-- Q15 Finding the best Highest run scorer of each innings

SELECT Batsmen, R, vs
FROM (
    SELECT Batsmen, R, CONCAT(Team,"-",Against) AS vs,
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Team,"-",Against) ORDER BY R DESC) AS row_num
    FROM Batters
) AS subquery
WHERE row_num = 1;

-- Q16 Finding number of matches in each stadium

SELECT Stadium,COUNT(Stadium) 
FROM Matches
GROUP BY Stadium;

-- Q17 Finding which player got most Man-of-the-matches award

SELECT Motm,COUNT(Motm) Cnt
FROM Matches
GROUP BY Motm
ORDER BY Cnt DESC;

-- Q18 Finding which team took most of the wickets

SELECT Team_1,SUM(T2_W) as W
FROM Matches
GROUP BY Team_1
ORDER BY W DESC;	

-- Q19 Finding number of times a team scored greater than 300

WITH CTE AS
(SELECT Team_1,T1_Runs
FROM Matches
WHERE T1_Runs>300)
SELECT Team_1 as Team,COUNT(Team_1) as Cnt
FROM CTE
GROUP BY Team_1
ORDER BY Cnt DESC;

-- Q20 Finding Won_by numbers

SELECT Won_by,COUNT(Won_by) as Cnt
FROM Matches
GROUP BY Won_by
ORDER BY Cnt DESC;

-- Q21 Finding Won_by for each team

SELECT Winner,Won_by,COUNT(Won_by) as Cnt
FROM Matches
GROUP BY Winner,Won_by
ORDER BY Winner,Cnt DESC;

-- Q22 Displaying the Points Table

SELECT Winner,
    COUNT(Winner) AS Wins,2*COUNT(Winner) as Pts
FROM Matches
GROUP BY Winner
ORDER BY Pts DESC;

-- Q23 Finding number of times a team lost in the tournamnet

WITH CTE AS 
(SELECT Winner,
    CASE 
        WHEN Team_1 = Winner THEN Team_2 
        ELSE Team_1 
    END AS Lost
FROM Matches)
SELECT Lost as Team,COUNT(Lost) as Cnt
FROM CTE
GROUP BY Lost;



-- Q24 Finding the top 10 wicket takers

SELECT Bowler,SUM(W) as Wickets
FROM Bowlers
GROUP BY Bowler
ORDER BY Wickets DESC
LIMIT 10;

-- Q25 Finding the best bowling figures of the tournament

WITH CTE AS
(SELECT Bowler,W,R,RANK() OVER(partition by Against ORDER BY W DESC) as Rnk
FROM Bowlers)
SELECT Bowler,W,R FROM CTE 
WHERE Rnk=1;

-- Q26 Couting number of batsmen 

SELECT COUNT(DISTINCT Batsmen) as Cnt
FROM Batters;

-- Q27 Couting number of bowlers

SELECT COUNT(DISTINCT Bowler) as Cnt
FROM Bowlers;




    
