
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
SELECT MIN(income_null), MAX(income_null) from profile_proc;
SELECT 
	CASE WHEN income_zero <60000 THEN 'low_income'
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
-- bogo, 4 (buy one get one); informational 2; discount 4; total; 10

-- statistics for reward, difficulty, and duration
SELECT 
    MIN(reward) AS reward_min,
    MAX(reward) AS reward_max,
    MIN(difficulty) AS difficulty_min,
    MAX(difficulty) AS difficulty_max,
    MIN(duration) AS duration_min,
    MAX(duration) AS duration_max
FROM portfolio_proc;


-- unique combinations of difficulty/reward for each offer_type
SELECT 
	offer_type,
    JSON_OBJECTAGG(difficulty, reward) AS 'difficulty/reward'
FROM portfolio_proc
GROUP BY offer_type;



##########################
### TRANSCRIPT TABLE ###
##########################

-- inspection
SELECT * FROM transcript_proc LIMIT 10;
SELECT * FROM transcript_proc_temp LIMIT 10;

SELECT COUNT(DISTINCT customer_id) FROM transcript_proc_temp; -- 14825
SELECT COUNT(DISTINCT customer_id) FROM profile_proc; -- 14825


-- distinct event
SELECT DISTINCT(event) FROM transcript_proc_temp;
-- offer received, offer viewed,  offer complete, transaction



-- check if AMOUNT only appears in any event type
SELECT DISTINCT event, amount
FROM transcript_proc_temp
ORDER BY event, amount;
-- real number only appears when event = transaction;


-- check if REWARD is not NULL only when offer completed
SELECT DISTINCT event, reward
FROM transcript_proc_temp
ORDER BY event, reward;
-- valid values only appear when event = offer completed


-- get offer type and offer total count each customer received 
SELECT 
	a.customer_id, 
	COUNT(DISTINCT a.offer_id, a.time_dt) AS offer_received_count,
	JSON_ARRAYAGG(b.offer_type) AS combined_offer_type,
    MAX(COUNT(DISTINCT a.offer_id, a.time_dt)) OVER() AS offer_received_count_max, 
    MIN(COUNT(DISTINCT a.offer_id, a.time_dt)) OVER() AS offer_received_count_min 
FROM transcript_proc_temp a
LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id
WHERE event = 'offer received'
GROUP BY customer_id;
-- max offer count is 6, min count as 1



-- get the percentage of offer delivered
SELECT
    b.offer_type,
    COUNT(a.offer_id),
	COUNT(a.offer_id) / (SELECT COUNT(*) FROM transcript_proc_temp WHERE event = 'offer received')
FROM transcript_proc_temp a
LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id
WHERE event = 'offer received'
GROUP BY b.offer_type;
-- BOGO 0.3990; DISCOUNT: 0,4010; INFORMATIONAL: 0.2



-- check the offer completed percentage for each offer type
-- (offer received > offer viewed > offer complete)
SELECT 
	offer_type,
    received_count,
    completed_count,
    (completed_count / received_count) AS completed_percentage
FROM(
	WITH offer_event_ct_table AS (
		SELECT 
			a.customer_id,
			a.offer_id,
			b.offer_type,
			SUM(CASE WHEN event = 'offer received' THEN 1 ELSE 0 END) AS offer_received_count,
			SUM(CASE WHEN event = 'offer viewed' THEN 1 ELSE 0 END) AS offer_viewed_count,
			SUM(CASE WHEN event = 'offer completed' THEN 1 ELSE 0 END) AS offer_completed_count,
			SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS transaction_count
		FROM transcript_proc_temp a
		LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id
		GROUP BY customer_id, offer_id
	) 
	SELECT 
		offer_type,
		SUM(CASE WHEN offer_received_count >0 THEN offer_received_count END) AS received_count,
		SUM(CASE WHEN offer_received_count = offer_viewed_count AND
				offer_viewed_count = offer_completed_count AND
				offer_completed_count >0 THEN offer_completed_count END) AS completed_count
	FROM offer_event_ct_table
	GROUP BY offer_type
	HAVING offer_type IS NOT NULL
) AS c;
-- completed percentage: BOGO 0.4426 < DISCOUNT 0.4722



-- How many customer experience all process
-- customer can be considered as valuable individual to provide offer if at least one offer is completed
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





