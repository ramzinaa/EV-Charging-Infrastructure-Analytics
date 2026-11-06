
-- ==========================================
-- EV CHARGING INFRASTRUCTURE ANALYTICS
-- Complete SQL Analysis
-- ==========================================

USE ev_charging_analytics;


-- 1. TOTAL NUMBER OF STATIONS
SELECT
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new;


-- 2. STATE-WISE STATION COUNT
SELECT
    State,
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new
GROUP BY State
ORDER BY Total_Stations DESC;


-- 3. TOP 10 CHARGING OPERATORS
SELECT
    CPO,
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new
GROUP BY CPO
ORDER BY Total_Stations DESC
LIMIT 10;


-- 4. GOVERNMENT VS PRIVATE OWNERSHIP
SELECT
    Ownership,
    COUNT(*) AS Total_Stations,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_stations_new),
        2
    ) AS Percentage
FROM bee_ev_stations_new
GROUP BY Ownership
ORDER BY Total_Stations DESC;


-- 5. TOP 20 STATE-DISTRICT COMBINATIONS
SELECT
    State,
    District,
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new
GROUP BY State, District
ORDER BY Total_Stations DESC
LIMIT 20;


-- 6. STATE-WISE DISTRICT COVERAGE AND AVERAGE
SELECT
    State,
    COUNT(DISTINCT District) AS Districts_Covered,
    COUNT(*) AS Total_Stations,
    ROUND(
        COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT District), 0),
        2
    ) AS Avg_Stations_Per_District
FROM bee_ev_stations_new
GROUP BY State
ORDER BY Avg_Stations_Per_District DESC;


-- 7. STATE-WISE SHARE OF NATIONAL STATIONS
SELECT
    State,
    COUNT(*) AS Total_Stations,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_stations_new),
        2
    ) AS National_Share_Percent
FROM bee_ev_stations_new
GROUP BY State
ORDER BY National_Share_Percent DESC;


-- 8. DISTRICTS WITH THE FEWEST RECORDED STATIONS
SELECT
    State,
    District,
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new
GROUP BY State, District
ORDER BY Total_Stations ASC
LIMIT 20;


-- 9. OPERATOR-WISE STATE PRESENCE
SELECT
    CPO,
    COUNT(DISTINCT State) AS States_Covered,
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new
GROUP BY CPO
ORDER BY Total_Stations DESC;


-- 10. STATE-WISE GOVERNMENT AND PRIVATE COMPARISON
SELECT
    State,
    SUM(CASE
        WHEN Ownership = 'Govt.' THEN 1
        ELSE 0
    END) AS Government_Stations,
    SUM(CASE
        WHEN Ownership = 'Private' THEN 1
        ELSE 0
    END) AS Private_Stations,
    COUNT(*) AS Total_Stations
FROM bee_ev_stations_new
GROUP BY State
ORDER BY Total_Stations DESC;


-- 11. DATA QUALITY CHECK: MISSING VALUES
SELECT
    SUM(CASE WHEN State IS NULL OR TRIM(State) = ''
        THEN 1 ELSE 0 END) AS Missing_State,
    SUM(CASE WHEN District IS NULL OR TRIM(District) = ''
        THEN 1 ELSE 0 END) AS Missing_District,
    SUM(CASE WHEN CPO IS NULL OR TRIM(CPO) = ''
        THEN 1 ELSE 0 END) AS Missing_Operator,
    SUM(CASE WHEN Latitude IS NULL OR Longitude IS NULL
        THEN 1 ELSE 0 END) AS Missing_Coordinates
FROM bee_ev_stations_new;


-- 12. CHECK DUPLICATE STATION IDS
SELECT
    Station_ID,
    COUNT(*) AS ID_Count
FROM bee_ev_stations_new
GROUP BY Station_ID
HAVING COUNT(*) > 1;


-- 13. STATE RANKING BY TOTAL STATIONS
SELECT
    State,
    COUNT(*) AS Total_Stations,
    DENSE_RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS State_Rank
FROM bee_ev_stations_new
GROUP BY State
ORDER BY State_Rank;


-- 14. TOP 10 DISTRICTS OVERALL
SELECT
    State,
    District,
    COUNT(*) AS Total_Stations,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_stations_new),
        2
    ) AS National_Share_Percent
FROM bee_ev_stations_new
GROUP BY State, District
ORDER BY Total_Stations DESC
LIMIT 10;


USE ev_charging_analytics;

CREATE TABLE bee_ev_clean (
    CPO TEXT,
    Ownership VARCHAR(50),
    State VARCHAR(100),
    District VARCHAR(100),
    City VARCHAR(100),
    Location TEXT,
    Latitude DOUBLE,
    Longitude DOUBLE,
    Charger_Type VARCHAR(50),
    Charger_Rating_kW DOUBLE,
    Connector_Rating_kW DOUBLE,
    Num_Connectors INT,
    Current_Type VARCHAR(50),
    Connector_Standard TEXT,
    Is_LEV VARCHAR(20),
    Power_Class VARCHAR(50),
    Repeat_Count INT,
    Connectors_Raw TEXT,
    Bulk_Repeat VARCHAR(20)
);

SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE
'C:/Users/Ramseena M/Downloads/bee_ev_clean.csv'
INTO TABLE ev_charging_analytics.bee_ev_clean
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    CPO,
    Ownership,
    State,
    District,
    City,
    Location,
    Latitude,
    Longitude,
    Charger_Type,
    Charger_Rating_kW,
    Connector_Rating_kW,
    Num_Connectors,
    Current_Type,
    Connector_Standard,
    Is_LEV,
    Power_Class,
    Repeat_Count,
    Connectors_Raw,
    Bulk_Repeat
);

SELECT COUNT(*) AS Total_Charger_Records
FROM ev_charging_analytics.bee_ev_clean;

SELECT *
FROM ev_charging_analytics.bee_ev_clean
LIMIT 10;

#AC vs DC analysis
SELECT
    Current_Type,
    COUNT(*) AS Total_Chargers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_clean),
        2
    ) AS Percentage
FROM bee_ev_clean
GROUP BY Current_Type
ORDER BY Total_Chargers DESC;

#Power Class Anaysis
SELECT
    Power_Class,
    COUNT(*) AS Total_Chargers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_clean),
        2
    ) AS Percentage
FROM bee_ev_clean
GROUP BY Power_Class
ORDER BY Total_Chargers DESC;

#Government vs Private charger analysis
SELECT
    Ownership,
    Current_Type,
    COUNT(*) AS Total_Chargers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_clean),
        2
    ) AS Overall_Percentage
FROM bee_ev_clean
GROUP BY Ownership, Current_Type
ORDER BY Ownership, Total_Chargers DESC;

#LEV vs Non-LEV analysis
SELECT
    Is_LEV,
    COUNT(*) AS Total_Chargers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM bee_ev_clean),
        2
    ) AS Percentage
FROM bee_ev_clean
GROUP BY Is_LEV
ORDER BY Total_Chargers DESC;

SELECT
    Power_Class,
    COUNT(*) AS LEV_Chargers,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM bee_ev_clean
         WHERE Is_LEV = 'True'),
        2
    ) AS Percentage_Within_LEV
FROM bee_ev_clean
WHERE Is_LEV = 'True'
GROUP BY Power_Class
ORDER BY LEV_Chargers DESC;

SELECT
    COUNT(*) AS Total_Rows,

    SUM(CASE
        WHEN State IS NULL OR TRIM(State) = ''
        THEN 1 ELSE 0
    END) AS Missing_State,

    SUM(CASE
        WHEN District IS NULL OR TRIM(District) = ''
        THEN 1 ELSE 0
    END) AS Missing_District,

    SUM(CASE
        WHEN CPO IS NULL OR TRIM(CPO) = ''
        THEN 1 ELSE 0
    END) AS Missing_Operator,

    SUM(CASE
        WHEN Current_Type IS NULL OR TRIM(Current_Type) = ''
        THEN 1 ELSE 0
    END) AS Missing_Current_Type,

    SUM(CASE
        WHEN Charger_Rating_kW IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Power_Rating,

    SUM(CASE
        WHEN Latitude IS NULL OR Longitude IS NULL
        THEN 1 ELSE 0
    END) AS Missing_Coordinates

FROM bee_ev_clean;

SELECT
    State,
    COUNT(*) AS Total_Stations,
    COUNT(DISTINCT District) AS Districts_Recorded,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*)
         FROM bee_ev_stations_new),
        2
    ) AS National_Station_Share_Percent,
    ROUND(
        COUNT(*) * 1.0 /
        NULLIF(COUNT(DISTINCT District), 0),
        2
    ) AS Avg_Stations_Per_Recorded_District
FROM bee_ev_stations_new
GROUP BY State
ORDER BY Total_Stations ASC;


USE ev_charging_analytics;

WITH state_summary AS (
    SELECT
        State,
        COUNT(*) AS Total_Stations,
        COUNT(DISTINCT District) AS Districts_Recorded
    FROM bee_ev_stations_new
    GROUP BY State
),
national_totals AS (
    SELECT
        SUM(Total_Stations) AS National_Stations,
        SUM(Districts_Recorded) AS State_District_Total
    FROM state_summary
),
coverage AS (
    SELECT
        s.State,
        s.Total_Stations,
        s.Districts_Recorded,
        ROUND(
            s.Total_Stations * 100.0 /
            n.National_Stations, 2
        ) AS Station_Share_Percent,
        ROUND(
            s.Districts_Recorded * 100.0 /
            n.State_District_Total, 2
        ) AS Recorded_District_Share_Percent
    FROM state_summary s
    CROSS JOIN national_totals n
)
SELECT
    State,
    Total_Stations,
    Districts_Recorded,
    Station_Share_Percent,
    Recorded_District_Share_Percent,
    ROUND(
        Recorded_District_Share_Percent - Station_Share_Percent,
        2
    ) AS Relative_Coverage_Difference
FROM coverage
ORDER BY Relative_Coverage_Difference DESC;

SELECT
    Station_ID,
    COUNT(*) AS ID_Count
FROM bee_ev_stations_new
GROUP BY Station_ID
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS Total_Stations,

    SUM(CASE
        WHEN Latitude < 6 OR Latitude > 38
          OR Longitude < 68 OR Longitude > 98
        THEN 1 ELSE 0
    END) AS Coordinates_Outside_India_Bounds,

    SUM(CASE
        WHEN Chargers IS NULL OR Chargers <= 0
        THEN 1 ELSE 0
    END) AS Invalid_Charger_Count,

    SUM(CASE
        WHEN Max_kW IS NULL OR Max_kW <= 0
        THEN 1 ELSE 0
    END) AS Invalid_Max_Power
FROM bee_ev_stations_new;
