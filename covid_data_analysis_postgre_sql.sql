-- Created a database named covid19 in pgAdmin 4
-- Creating three tables covid_19_india age_group_details and testing_labs inside the DB


CREATE TABLE covid_19_india (
    Sno SERIAL PRIMARY KEY,
    Date DATE,
    Time TIME,
    State_UnionTerritory VARCHAR(255),
    ConfirmedIndianNational INTEGER,
    ConfirmedForeignNational INTEGER,
    Cured INTEGER,
    Deaths INTEGER,
    Confirmed INTEGER
);


CREATE TABLE age_group_details (
    Sno SERIAL PRIMARY KEY,
    AgeGroup VARCHAR(255),
    TotalCases INTEGER,
    Percentage NUMERIC
);


CREATE TABLE testing_labs (
    Lab VARCHAR(255),
    Address VARCHAR(255),
    Pincode VARCHAR(20),
    City VARCHAR(255),
    State VARCHAR(255),
    Type VARCHAR(255)
);

select * from covid_19_india;
select * from age_group_details;
select * from testing_labs;


UPDATE age_group_details
SET AgeGroup = '10-19'
WHERE AgeGroup = 'Oct-19';


-- Total Confirmed Cases by State:
SELECT State_UnionTerritory, SUM(Confirmed) AS TotalConfirmed
FROM covid_19_india
GROUP BY State_UnionTerritory;

-- Date with the Highest Total Confirmed Cases:
SELECT Date, MAX(Confirmed) AS HighestConfirmed
FROM covid_19_india
GROUP BY Date;

-- Age Group with the Highest Percentage of Cases:
SELECT AgeGroup, MAX(Percentage) AS HighestPercentage
FROM age_group_details
GROUP BY AgeGroup
ORDER BY AgeGroup;

-- Cumulative Percentage of Cases Across Age Groups:
SELECT AgeGroup, TotalCases, Percentage,
       SUM(Percentage) OVER (ORDER BY Sno) AS CumulativePercentage
FROM age_group_details
ORDER BY Sno;

-- States with the Highest Daily Increase in Confirmed Cases:
SELECT Date, State_UnionTerritory,
       Confirmed - LAG(Confirmed, 1, 0) OVER (PARTITION BY State_UnionTerritory ORDER BY Date) AS DailyIncrease
FROM covid_19_india
ORDER BY State_UnionTerritory, Date;

-- Top 10 states with the highest cumulative number of confirmed COVID-19 cases:
SELECT State_UnionTerritory, SUM(Confirmed) AS TotalConfirmed
FROM covid_19_india
GROUP BY State_UnionTerritory
ORDER BY TotalConfirmed DESC
LIMIT 10;

-- Analyzing the correlation between daily confirmed cases and daily deaths:
SELECT Date,
    CORR(Confirmed, Deaths) AS Correlation
FROM covid_19_india
GROUP BY Date
ORDER BY Date;

-- Total Deaths by State:
SELECT State_UnionTerritory, SUM(Deaths) AS TotalDeaths
FROM covid_19_india
GROUP BY State_UnionTerritory;

-- ICMR Testing Labs in Each State:
SELECT State, COUNT(Lab) AS LabCount
FROM testing_labs
GROUP BY State;

-- Top 10 States with the Highest Death Rates:
SELECT
    distinct(State_UnionTerritory),
    Confirmed,
    Deaths,
    CASE
        WHEN Confirmed = 0 THEN 0 -- Handle the case where Confirmed is zero
        ELSE Deaths::NUMERIC / Confirmed * 100
    END AS DeathRate
FROM
    covid_19_india
ORDER BY DeathRate desc
LIMIT 10;

-- List Testing Labs and Their City in a Specific State:  
SELECT
    tl.Lab,
    tl.City,
	tl.State
FROM
    testing_labs tl
ORDER BY City, State;

-- Predict future trends in confirmed COVID-19 cases using time series analysis:
WITH daily_cases AS (
    SELECT
        Date,
        Confirmed,
        LAG(Confirmed) OVER (ORDER BY Date) AS lag_confirmed
    FROM
        covid_19_india
    ORDER BY
        Date
)

SELECT
    Date,
    Confirmed,
    COALESCE(
        0.1 * Confirmed + 0.9 * lag_confirmed,
        Confirmed
    ) AS PredictedConfirmed
FROM
    daily_cases
ORDER BY
    Date;


--  effectiveness of various testing labs in identifying COVID-19 cases:
SELECT testing_labs.Lab, 
       SUM(covid_19_india.Confirmed) AS TotalConfirmed,
       testing_labs.Type, 
       covid_19_india.State_UnionTerritory
FROM covid_19_india
JOIN testing_labs
ON covid_19_india.State_UnionTerritory = testing_labs.State
GROUP BY testing_labs.Lab, 
         testing_labs.Type,   
         covid_19_india.State_UnionTerritory
ORDER BY TotalConfirmed DESC;





