
###########################################################################################################
#######################################   Project : Starbucks Customer Data    #####################################
###########################################################################################################

CREATE SCHEMA IF NOT EXISTS project;
USE project;

/* DATA ANALYSIS I: EDA */ 


##########################
### PROFILE TABLE ###
##########################

-- customer info gathering
SELECT * FROM profile_proc LIMIT 10;
SELECT DISTINCT gender FROM profile_proc;

-- total customer number: 17000
SELECT COUNT(*) FROM profile_proc; 

-- see the percentage of different gender: F-0.41; M-0.57; O; 0.01
SELECT 
	gender, 
	COUNT(gender), 
    (SELECT COUNT(*) FROM profile_proc),
    (COUNT(gender) / (SELECT COUNT(*) FROM profile_proc))
FROM profile_proc 
GROUP BY gender; 

-- find count for all ages
SELECT 
	age,
    COUNT(age)
FROM profile_proc
GROUP BY age
ORDER BY age DESC; 
-- 2175 for 118 yrs old


-- Check for customers with unknown gender and missing income
SELECT * FROM profile_proc WHERE age = 118 AND gender='U' AND income_null IS NULL;
-- all 2175 customer has unknown gender and missing income value, go back to preprocessing to eliminate these records
-- all delected records are exactly the records that has missing value in gender


-- age range
SELECT MIN(age), MAX(age) FROM profile_proc; 
-- range: 18-101


-- Check for null values in age
SELECT COUNT(*) FROM profile_proc WHERE age IS NULL; 
-- no null values in age


-- age distribution percentage, on < 30 , 30-40 , 50-60 , 60-70,  70-80 , 80+
SELECT 
	age,
    CASE WHEN age < 30 THEN 'less_than_30'
		WHEN age >= 30 AND age < 40 THEN '30_40'
        WHEN age >= 40 AND age < 50 THEN '40_50'
        WHEN age >= 50 AND age < 60 THEN '50_60'
        WHEN age >= 60 AND age < 70 THEN '60_70'
        WHEN age >=70 THEN  'greater_than_70' 
        ELSE NULL END AS age_group,
	COUNT(*) OVER() AS total_count,
	COUNT(*) OVER(PARTITION BY 
		CASE WHEN age < 30 THEN 'less_than_30'
			WHEN age >= 30 AND age < 40 THEN '30_40'
			WHEN age >= 40 AND age < 50 THEN '40_50'
			WHEN age >= 50 AND age < 60 THEN '50_60'
			WHEN age >= 60 AND age < 70 THEN '60_70'
			WHEN age >=70 THEN  'greater_than_70' 
			ELSE NULL END
		) / count(*) OVER() AS age_group_percentage
FROM profile_proc;
-- <30: 0.11; 30-40: 0.1; 40-50: 0.15; 50-60: 0.24; 60-70: 0.20; >70: 0.19; 


-- find the time frame: 2013-2018 July
SELECT MIN(became_member_on), MAX(became_member_on) FROM profile_proc; 


-- get cumulative membership growth
SELECT 
	became_member_on_year, 
    COUNT(*) AS member_year_count,
	SUM(COUNT(*)) OVER(ORDER BY became_member_on_year) AS cumulative_member_count
FROM profile_proc
GROUP BY became_member_on_year
ORDER BY became_member_on_year;



-- get yearly growth
SELECT 
	became_member_on_year,
    COUNT(became_member_on_year),
    COUNT(became_member_on_year) / (SELECT COUNT(*) FROM profile_proc) AS member_year_percentage
FROM profile_proc
GROUP BY became_member_on_year
ORDER BY member_year_percentage;  
-- range between 2013-2018, 2017 has the largest yearly increase


-- get monthly growth
SELECT 
	MONTH(became_member_on) AS became_member_on_month,
    COUNT(*) / COUNT(DISTINCT became_member_on_year) AS member_month_avg_count
FROM profile_proc
GROUP BY MONTH(became_member_on)
ORDER BY member_month_avg_count DESC;
	-- Member added top count months: 8, 10, 12, 1


-- income distribution by groups
SELECT 
	CASE WHEN income_zero <=60000 THEN 'low_income'
		WHEN income_zero >= 60000 AND income_zero<100000 THEN 'medium_income'
		ELSE  'high_income' END AS income_group,
	COUNT(*) AS ct_per_incomegroup,
	COUNT(*) / (SELECT COUNT(*) FROM profile_proc) AS percentage_per_incomegroup
FROM profile_proc
GROUP BY income_group;





##########################
### PROTFOLIO TABLE ###
##########################

-- inspection
SELECT * FROM portfolio_proc LIMIT 10;

-- count for different offer types
SELECT offer_type, COUNT(offer_id) FROM portfolio_proc GROUP BY offer_type; 
-- bogo, 4 (buy one get one); informational 2; discount 4

-- statistics for reward, difficulty, and duration
SELECT 
    AVG(reward) AS reward_avg,
    STDDEV(reward) AS reward_stddev,
    MIN(reward) AS reward_min,
    MAX(reward) AS reward_max,
    AVG(difficulty) AS difficulty_avg,
    STDDEV(difficulty) AS difficulty_stddev,
    MIN(difficulty) AS difficulty_min,
    MAX(difficulty) AS difficulty_max,
    AVG(duration) AS duration_avg,
    STDDEV(duration) AS duration_stddev,
    MIN(duration) AS duration_min,
    MAX(duration) AS duration_max
FROM portfolio_proc;


##########################
### TRANSCRIPT TABLE ###
##########################

-- inspection
SELECT * FROM transcript_proc LIMIT 10;
SELECT count(DISTINCT customer_id) FROM transcript_proc; -- 14825
SELECT count(DISTINCT customer_id) FROM profile_proc; -- 14825


-- distinct event
SELECT DISTINCT(event) FROM transcript_proc;
-- offer received, offer viewed,  offer complete, transaction


-- How many customer experience all process
-- (offer received > offer viewed > offer complete)
WITH event_agg_table AS (
	SELECT 
		customer_id, 
        JSON_ARRAYAGG(event) AS combined_event 
	FROM (SELECT DISTINCT customer_id, event FROM transcript_proc) AS a 
    GROUP BY customer_id
)
SELECT 
	COUNT(*) AS completed_count,
    COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM transcript_proc) AS completed_percentage
FROM event_agg_table 
WHERE JSON_CONTAINS(combined_event, JSON_ARRAY('offer received','offer viewed','offer completed')) = 1;
-- 11916 customer has experience all 3 event / 14824 = 80.38%


-- percentage of offer completed for each offer type
WITH event_agg_table2 AS (
	SELECT 
		a.offer_id, 
        b.offer_type, 
        a.event
	FROM transcript_proc a 
    LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id;
)






