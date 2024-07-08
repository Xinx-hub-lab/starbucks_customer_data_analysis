
###########################################################################################################
#######################################   Project : Starbucks Customer Data    #####################################
###########################################################################################################

CREATE SCHEMA IF NOT EXISTS project;
USE project;

/* DATA ANALYSIS II: */


-- porfolio table background knowledge, how many offer? max duration, min duration per offer_type? difficulty? rewards?

-- JSON_ARRAYAGG()
	-- merge all channels in an array, displayed in a single column
-- SELECT 
-- 	offer_type,
--     JSON_ARRAYAGG(channels) AS combined_channels
-- FROM portfolio
-- GROUP BY offer_type;  -- see all channels for each offer_type



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
-- difficulty is the required spending or action, reward is for customer


SELECT * 
FROM (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY offer_type ORDER BY difficulty DESC) AS difficulty_rank
	FROM portfolio_proc
	) AS c;

-- extract duration rank1 and rank 2 to do further analysis
SELECT
	offer_type,
	MAX(CASE WHEN difficulty_rank = 1 THEN duration END) AS rank1_duration,
	MAX(CASE WHEN difficulty_rank = 2 THEN duration END) AS rank2_duration
FROM (
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY offer_type ORDER BY difficulty DESC) AS difficulty_rank
	FROM portfolio_proc
	) AS a 
GROUP BY offer_type;



-- which type of offer attract user to complete offer? 
-- why other discount type not as many completed?
-- view but not completed?
with a as(
select offer_id, count(*) as ct_offer_used from transcript_proc where event='offer completed' group by offer_id
)
select * from a left join portfolio_proc b on a.offer_id = b.offer_id order by ct_offer_used desc;


-- demongrphic of user who complete offer more

with a as (select person,
sum(case when event='offer received' then 1 else 0 end) as received,
sum(case when event='offer viewed' then 1 else 0 end) as viewed,
sum(case when event='offer completed' then 1 else 0 end) as completed,
sum(case when event='offer viewed' then 1 else 0 end) / sum(case when event='offer received' then 1 else 0 end) as view_precentage,
sum(case when event='offer completed' then 1 else 0 end) / sum(case when event='offer received' then 1 else 0 end)  as completed_percentage
from transcript_proc  a
group by person
)

-- -- age group
-- select 
-- case when age < 30 then 'lessthan30'
-- when age >=30 and age <40 then '30_40'
-- when age >=40 and age <50 then '40_50'
-- when age >=50 and age <60 then '50_60'
-- when age >=60 and age <70 then '60_70'
-- when age >=70 then 'greaterthan70'
-- else null end as age_group,
-- count(*) as ct_per_agegroup,
-- count(*) / (select count(*) from a where completed_percentage >=0.8) as percentage_per_agegroup
-- from a left join profile_proc on person=customer_id
-- where completed_percentage >=0.8
-- group by age_group
-- order by percentage_per_agegroup desc;



-- gender 



-- demography of people who experience all process : gender
WITH event_agg_table 
AS (
	SELECT customer_id, json_arrayagg(event) AS combined_event 
	FROM (SELECT DISTINCT customer_id, event FROM transcript_proc) a 
    GROUP BY customer_id
) 
SELECT DISTINCT 
	gender,
	count(*) OVER(PARTITION BY gender) AS gender_ct,
	count(*) OVER() AS total_ct,
	count(*) OVER(PARTITION BY gender) / count(*) OVER()  AS `gender_%`
FROM event_agg_table a
LEFT JOIN profile_proc b ON a.customer_id = b.customer_id
WHERE JSON_CONTAINS(combined_event, JSON_ARRAY('offer received','offer viewed','offer completed')) = 1;
-- F: 0.4486; M: 0.5363; O: 0.01
 

-- try with income range (self-determine) , what's the percentage of peope who experience all process vice versa


-- offer_completed 
SELECT 
	customer_id,
	SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS ct_OfferReceived,
	SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) AS ct_OfferViewed,
	sum(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) AS ct_Completed
FROM transcript_proc
GROUP BY customer_id; -- rate : %view, %completed 
 
SELECT *  FROM transcript_proc;


