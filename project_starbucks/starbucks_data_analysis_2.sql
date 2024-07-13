
###########################################################################################################
#######################################   Project : Starbucks Customer Data    #####################################
###########################################################################################################

CREATE SCHEMA IF NOT EXISTS project;
USE project;

/* DATA ANALYSIS II: */

SELECT * FROM profile_proc LIMIT 10;
SELECT * FROM portfolio_proc LIMIT 10;
SELECT * FROM transcript_proc_temp LIMIT 10;



-- which type of offer attract user to complete offer? 
-- get completed rate for each specific offer
-- in eda we have completed percentage for each offer type: BOGO 0.4426 < DISCOUNT 0.4722

CREATE TABLE IF NOT EXISTS offer_response_analysis AS
SELECT 
	d.*,
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
		offer_id,
        offer_type,
		SUM(CASE WHEN offer_received_count >0 THEN offer_received_count END) AS received_count,
		SUM(CASE WHEN offer_received_count = offer_viewed_count AND
				offer_viewed_count = offer_completed_count AND
				offer_completed_count >0 THEN offer_completed_count END) AS completed_count
	FROM offer_event_ct_table
	GROUP BY offer_id
	HAVING offer_id IS NOT NULL
) AS c
LEFT JOIN portfolio_proc d ON c.offer_id = d.offer_id
WHERE (completed_count / received_count) > 0.4
ORDER BY completed_percentage DESC;
-- listed 5 offers with completing percentage > 0.4
-- test with ANOVA and ANCOVA
-- channel_mobile, channel_social, reward are significant predictors



-- get customers response rate
SELECT 
	customer_id,
	SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS received,
	SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) AS viewed,
	SUM(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) AS completed,
	SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) / SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS view_precentage,
	SUM(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) / SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END)  AS completed_percentage
FROM transcript_proc_temp a
LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id
WHERE offer_type != 'informational'
GROUP BY customer_id
ORDER BY completed_percentage DESC;



-- get specific offer type response rate for each customer, 
-- select top 1000 customers with highest overall completed_percentage
-- approach 1:
SELECT 
	customer_id,
    received,
    viewed,
    completed,
    view_percentage,
    completed_percentage,
    CASE
        WHEN bogo_complete_percentage IS NOT NULL AND discount_complete_percentage IS NOT NULL THEN
            JSON_OBJECT('BOGO', bogo_complete_percentage, 'DISCOUNT', discount_complete_percentage)
        WHEN bogo_complete_percentage IS NOT NULL THEN
            JSON_OBJECT('BOGO', bogo_complete_percentage)
        WHEN discount_complete_percentage IS NOT NULL THEN
            JSON_OBJECT('DISCOUNT', discount_complete_percentage)
        ELSE
            JSON_OBJECT()
    END AS completed_percentage_by_offer_type
FROM(
	SELECT 
		customer_id,
		SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS received,
		SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) AS viewed,
		SUM(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) AS completed,
		SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) / 
			SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS view_percentage,
		SUM(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) / 
			SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END)  AS completed_percentage,
		SUM(CASE WHEN event='offer completed' AND b.offer_type = 'BOGO' THEN 1 ELSE 0 END) /
			SUM(CASE WHEN event='offer received' AND b.offer_type = 'BOGO' THEN 1 ELSE 0 END) AS bogo_complete_percentage,
		SUM(CASE WHEN event='offer completed' AND b.offer_type = 'DISCOUNT' THEN 1 ELSE 0 END) /
			SUM(CASE WHEN event='offer received' AND b.offer_type = 'DISCOUNT' THEN 1 ELSE 0 END) AS discount_complete_percentage
	FROM transcript_proc_temp a
	LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id
	WHERE offer_type != 'informational'
	GROUP BY customer_id
    ORDER BY completed_percentage DESC
) AS a;


-- approach 2
DROP TABLE customer_response_analysis;
CREATE TABLE IF NOT EXISTS customer_response_analysis AS
SELECT 
	a.customer_id,
    age,
    gender,
    income_zero,
    income_null,
	SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS received,
	SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) AS viewed,
	SUM(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) AS completed,
	SUM(CASE WHEN event='offer viewed' THEN 1 ELSE 0 END) / 
		SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END) AS view_percentage,
	SUM(CASE WHEN event='offer completed' THEN 1 ELSE 0 END) / 
		SUM(CASE WHEN event='offer received' THEN 1 ELSE 0 END)  AS completed_percentage,
	SUM(CASE WHEN event='offer completed' AND b.offer_type = 'BOGO' THEN 1 ELSE 0 END) /
		SUM(CASE WHEN event='offer received' AND b.offer_type = 'BOGO' THEN 1 ELSE 0 END) AS bogo_complete_percentage,
	SUM(CASE WHEN event='offer completed' AND b.offer_type = 'DISCOUNT' THEN 1 ELSE 0 END) /
		SUM(CASE WHEN event='offer received' AND b.offer_type = 'DISCOUNT' THEN 1 ELSE 0 END) AS discount_complete_percentage
FROM transcript_proc_temp a
LEFT JOIN portfolio_proc b ON a.offer_id = b.offer_id
LEFT JOIN profile_proc c ON a.customer_id = c.customer_id
WHERE offer_type != 'informational'
GROUP BY customer_id
ORDER BY completed_percentage DESC;
-- warning comes from rounding  (the column is not rounded, 0.3333 would cause warnings)


	
-- age group response rate
SELECT 
	CASE WHEN age < 30 THEN 'lessthan30'
		WHEN age >=30 AND age <40 THEN '30_40'
		WHEN age >=40 AND age <50 THEN '40_50'
		WHEN age >=50 AND age <60 THEN '50_60'
		WHEN age >=60 AND age <70 THEN '60_70'
		WHEN age >=70 THEN 'greaterthan70'
		ELSE NULL END AS age_group,
	COUNT(*) AS ct_per_agegroup,
	COUNT(*) / (SELECT COUNT(*) FROM customer_response_analysis WHERE completed_percentage >=0.8) AS percentage_per_agegroup
FROM customer_response_analysis
WHERE completed_percentage >=0.8
GROUP BY age_group
ORDER BY percentage_per_agegroup DESC;



-- gender specific response rate
-- approach 1
WITH event_agg_table 
AS (
	SELECT customer_id, JSON_ARRAYAGG(event) AS combined_event 
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



-- approach 2 with filtering on completed_percentage >=0.8
SELECT 
	gender,
	COUNT(*) AS ct_per_gender,
	COUNT(*) / (SELECT COUNT(*) FROM customer_response_analysis WHERE completed_percentage >=0.8) AS percentage_per_gender
FROM customer_response_analysis
WHERE completed_percentage >=0.8
GROUP BY gender
ORDER BY percentage_per_gender DESC;
-- F: 0.5099; M: 0.4716; O: 0.0186
 

-- try with income range
SELECT 
	CASE WHEN income_zero <60000 THEN 'low_income'
		WHEN income_zero >= 60000 AND income_zero<100000 THEN 'medium_income'
		ELSE  'high_income' END AS income_group,
	COUNT(*) AS ct_per_incomegroup,
	COUNT(*) / (SELECT COUNT(*) FROM customer_response_analysis WHERE completed_percentage >=0.8) AS percentage_per_incomegroup
FROM customer_response_analysis
WHERE completed_percentage >=0.8
GROUP BY income_group
ORDER BY percentage_per_incomegroup DESC;
-- medium: 0.5841; low: 0.3183; high: 0.0976



-- get specific group with highest percentage of complete
-- consider 3 predictors
SELECT 
	gender,
	CASE WHEN income_zero <60000 THEN 'low_income'
		WHEN income_zero >= 60000 AND income_zero<100000 THEN 'medium_income'
		ELSE  'high_income' END AS income_group,
	CASE WHEN age < 30 THEN 'lessthan30'
		WHEN age >=30 AND age <40 THEN '30_40'
		WHEN age >=40 AND age <50 THEN '40_50'
		WHEN age >=50 AND age <60 THEN '50_60'
		WHEN age >=60 AND age <70 THEN '60_70'
		WHEN age >=70 THEN 'greaterthan70'
		ELSE NULL END AS age_group,
	COUNT(*) / (SELECT COUNT(*) FROM customer_response_analysis WHERE completed_percentage >=0.8) AS percentage_per_group
FROM customer_response_analysis
WHERE completed_percentage >=0.8
GROUP BY gender, income_group, age_group
ORDER BY percentage_per_group DESC;



-- target offers for top segments above
CREATE TABLE target_customer_offers AS
SELECT 
	customer_id,
    offer_ids
FROM(
	WITH target_customer AS (
		SELECT 
			customer_id
		FROM customer_response_analysis
		WHERE completed_percentage >= 0.8
		  AND income_null >= 60000
		  AND income_null < 100000
		  AND age >= 40
	)
	SELECT DISTINCT
		t.customer_id, 
		JSON_ARRAYAGG(t.offer_id) AS offer_ids
	FROM transcript_proc_temp t
	JOIN target_customer tc ON t.customer_id = tc.customer_id
	LEFT JOIN portfolio_proc p ON t.offer_id = p.offer_id
	WHERE event = 'offer completed'
	GROUP BY t.customer_id
) AS a;




-- select the 5 top offers
SELECT 
	offer_id,
    offer_type,
    duration,
    completed_percentage 
FROM offer_response_analysis;




-- see min and max amount
SELECT MIN(amount), MAX(amount) FROM transcript_proc_temp;

-- additional: sum transaction amount for each group
SELECT 
	gender,
	CASE WHEN income_zero <60000 THEN 'low_income'
		WHEN income_zero >= 60000 AND income_zero<100000 THEN 'medium_income'
		ELSE  'high_income' END AS income_group,
	CASE WHEN age < 30 THEN 'lessthan30'
		WHEN age >=30 AND age <40 THEN '30_40'
		WHEN age >=40 AND age <50 THEN '40_50'
		WHEN age >=50 AND age <60 THEN '50_60'
		WHEN age >=60 AND age <70 THEN '60_70'
		WHEN age >=70 THEN 'greaterthan70'
		ELSE NULL END AS age_group,
	SUM(amount) AS sum_transaction_amount
FROM transcript_proc_temp a
LEFT JOIN profile_proc b ON a.customer_id = b.customer_id
WHERE event = 'transaction'
GROUP BY gender, income_group, age_group
ORDER BY sum_transaction_amount DESC;




