
###########################################################################################################
#######################################   Project : Starbucks Customer Data    #####################################
###########################################################################################################



#####################################################################
#################### DATA ANALYSIS I   #################################
#####################################################################

##########################
### PROFILE TABLE ###
##########################

-- customer info gathering
SELECT * FROM profile_proc;
SELECT min(became_member_on), max(became_member_on) FROM profile_proc; -- 2013-2018 July

SELECT COUNT(*) FROM profile_proc; -- 17000

SELECT 
	gENDer, 
	COUNT(gENDer), 
    (SELECT COUNT(*) FROM profile_proc),
    (COUNT(gENDer) / (SELECT COUNT(*) FROM profile_proc))
FROM profile_proc 
GROUP BY gENDer; -- see the percentage of different gENDer

SELECT 
	age,
    COUNT(age)
FROM profile_proc
GROUP BY age
ORDER BY age DESC; -- 2175 for 118 yrs old

SELECT * FROM profile_proc WHERE age = 118 AND gENDer='U' AND income_null IS NULL;
	-- all 2175 customer hAS unknown gENDer and missing income value
	-- hence we should remove the 118 years old customer id ( adjusted in the create table step )
    
-- age GROUP would be a good way to process age variable
SELECT min(age), max(age) FROM profile_proc; -- range: 18-101
SELECT COUNT(*) FROM profile_proc WHERE age IS NULL; -- no null values in age
	-- but we still have to consider to use identification of NULL if new records were added to databASe in the future

-- age distribution percentage, on < 30 , 30-40 , 50-60 , 60-70,  70-80 , 80+
SELECT 
	age,
    CASE WHEN age < 30 THEN 'less_than_30'
		WHEN age >= 30 AND age < 40 THEN '30_40'
        WHEN age >= 40 AND age < 50 THEN '40_50'
        WHEN age >= 50 AND age < 60 THEN '50_60'
        WHEN age >= 60 AND age < 70 THEN '60_70'
        WHEN age >=70 THEN  'greater_than_70' 
        ELSE NULL END AS age_GROUP,
	COUNT(*) OVER() AS total_count,
	COUNT(*) OVER(PARTITION BY 
		CASE WHEN age < 30 THEN 'less_than_30'
			WHEN age >= 30 AND age < 40 THEN '30_40'
			WHEN age >= 40 AND age < 50 THEN '40_50'
			WHEN age >= 50 AND age < 60 THEN '50_60'
			WHEN age >= 60 AND age < 70 THEN '60_70'
			WHEN age >=70 THEN  'greater_than_70' 
			ELSE NULL END
		) / count(*) OVER() AS age_GROUP_percentage
FROM profile_proc;
	-- ELSE NULL is for records having NULL AS value in age column, reASonably the age_GROUP should be NULL too
	-- the command after PARTITION BY should not be age_GROUP since there are problems with excution order


-- become_member_on's YEARMONTH  distribution percentage
-- examples
SELECT 
	became_member_on, 
	EXTRACT(YEAR_MONTH FROM became_member_on) AS date_v1,
    DATE_FORMAT(became_member_on, '%Y-%m') AS date_v2
FROM profile_proc;
	-- DATE_FORMAT can directly change the format of the date, which delete the info of day

-- get cumulative membership growth
SELECT 
	became_member_on_year, 
    COUNT(*) AS member_year_count,
	SUM(COUNT(*)) OVER(ORDER BY became_member_on_year) AS cumulative_member_count
FROM profile_proc
GROUP BY became_member_on_year
ORDER BY became_member_on_year;


-- SELECT 
-- 	became_member_on,
-- 	YEAR(became_member_on),
--     EXTRACT(YEAR FROM became_member_on),
--     COUNT(*) OVER() AS total_count,
--     COUNT(*) OVER(PARTITION BY YEAR(became_member_on))
-- FROM profile_proc;
	-- YEAR and EXTRACT(YEAR FROM) does the same tASk, YEAR may be preferred 

-- get yearly growth
SELECT 
	became_member_on_year,
    COUNT(became_member_on_year),
    COUNT(became_member_on_year) / (SELECT COUNT(*) FROM profile_proc) AS member_year_percentage
FROM profile_proc
GROUP BY became_member_on_year
ORDER BY member_year_percentage;  -- range between 2013-2018, 2017 hAS the largest yearly increASe
	-- ORDER BY executes after SELECT

-- get monthly growth
SELECT 
	MONTH(became_member_on) AS became_member_on_month,
    COUNT(*) / COUNT(DISTINCT became_member_on_year) AS member_month_avg_count
FROM profile_proc
GROUP BY MONTH(became_member_on)
ORDER BY member_month_avg_count DESC;
	-- Member added top count months: 8, 10, 12, 1
	-- Aug: coincides with the back-to-school seASon, starbucks may offer more discounts for students
    -- Oct: Halloween, fall seASon discount
    -- Dec: holiday seASon promotions
    -- Jan: New year promotions




##########################
### PROTFOLIO TABLE ###
##########################

-- porfolio table background knowledge, how many offer? max duration, min duration per offer_type? difficulty? rewards?
SELECT * FROM portfolio_proc;

SELECT offer_type, COUNT(offer_id) FROM portfolio_proc GROUP BY offer_type; 
	-- bogo, 4 (buy one get one); informational 2; discount 4

-- JSON_ARRAYAGG()
SELECT 
	offer_type,
    JSON_ARRAYAGG(channels) AS combined_channels
FROM portfolio
GROUP BY offer_type;  -- see all channels for each offer_type

SELECT 
	customer_id,
    JSON_ARRAYAGG(event) AS combined_event
FROM (SELECT DISTINCT customer_id, event FROM transcript_proc) AS a
GROUP BY customer_id; 
	-- see if there are customers experiencng all 4 events
    -- DISTINCT is see the DISTINCT combination of customer and event

SELECT * FROM portfolio_proc;

SELECT 
	offer_type,
    JSON_OBJECTAGG(difficulty, reward) AS 'difficulty/reward'
FROM portfolio
GROUP BY offer_type; -- aggregate to get the unique combinations of difficulty/reward for each offer_type

SELECT * 
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY offer_type ORDER BY difficulty DESC) AS difficulty_rank
	FROM portfolio_proc
	) AS c
WHERE difficulty_rank = 1;

-- extract duration rank1 and rank 2 to do further analysis
SELECT
	offer_type,
	max(CASE WHEN difficulty_rank = 1 THEN duration END) AS rank1_duration,
	max(CASE WHEN difficulty_rank = 2 THEN duration END) AS rank2_duration
FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY offer_type ORDER BY difficulty DESC) AS difficulty_rank
	FROM portfolio_proc
	) AS a 
GROUP BY offer_type;




#####################################################################
#################### DATA ANALYSIS II   ################################
#####################################################################

##########################
### TRANSCRIPT TABLE ###
##########################

SELECT count(DISTINCT customer_id) FROM transcript_proc; -- 14825
SELECT count(DISTINCT customer_id) FROM profile_proc; -- 14825

-- How many customer experience all process
-- (offer received > offer viewed > offer complete)
-- HOMEWORK : What is the percentage?   11915 customer hAS experience all 3 event / 14824
WITH event_agg_table 
AS (
SELECT person, JSON_ARRAYAGG(event) AS combined_event 
FROM (SELECT DISTINCT person, event FROM transcript_proc) a GROUP BY person
)
 
SELECT count(*)
FROM event_agg_table 
WHERE JSON_CONTAINS(
	combined_event, JSON_ARRAY('offer received','offer viewed','offer completed')
    ) = 1; -- combined_Event includes all three process, which return True =1 

-- demography of people who experience all process : gENDer
-- HOMEWORK : try with income range (self-determine) , what's the percentage of peope who experience all process vice versa
WITH event_agg_table 
AS (
SELECT person, json_arrayagg(event) AS combined_event 
FROM (SELECT DISTINCT person, event FROM transcript_proc) a GROUP BY person
)
 
SELECT DISTINCT 
	gENDer,
	count(*) OVER(PARTITION BY gENDer) AS gENDer_ct,
	count(*) OVER() AS total_ct,
	count(*) OVER(PARTITION BY gENDer) / count(*) OVER()  AS `gENDer_%`
FROM event_agg_table 
LEFT JOIN profile_proc ON person = customer_id
WHERE JSON_CONTAINS(
	combined_event, JSON_ARRAY('offer received','offer viewed','offer completed')
    ) = 1;
 
 
-- offer_completed 
SELECT 
	person,
	SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS ct_OfferReceived,
	SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) AS ct_OfferViewed,
	sum(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) AS ct_Completed
FROM transcript_proc
GROUP BY customer_id; -- rate : %view, %completed 
 
SELECT *  FROM transcript_proc;

