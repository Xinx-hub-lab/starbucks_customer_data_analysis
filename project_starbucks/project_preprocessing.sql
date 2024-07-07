
###########################################################################################################
#######################################   Project : Starbucks Customer Data    #####################################
###########################################################################################################
CREATE SCHEMA project;
USE project;


/* PREPROCESSING / CLEANING */

##########################
### PROTFOLIO TABLE ###
##########################

-- preprocess and create new table
	-- one hot encoding for channels column
	-- upper case + trim for offer_type
CREATE TABLE portfolio_proc AS
SELECT 
	reward, 
	difficulty, 
	duration, 
    id AS offer_id, 
    offer_type_proc AS offer_type, 
    channel_web, 
    channel_mobile, 
    channel_email,
    channel_social
FROM(
	SELECT *, 
		TRIM(UPPER(offer_type)) AS offer_type_proc,
		CASE WHEN JSON_CONTAINS(channels, '["web"]') THEN 1 ELSE 0 END AS channel_web,
		CASE WHEN JSON_CONTAINS(channels, '["mobile"]') THEN 1 ELSE 0 END AS channel_mobile,
		CASE WHEN JSON_CONTAINS(channels, '["email"]') THEN 1 ELSE 0 END AS channel_email,
		CASE WHEN JSON_CONTAINS(channels, '["social"]') THEN 1 ELSE 0 END AS channel_social
	FROM portfolio
) 
AS process_table1;


-- view the processed dataset
SELECT * FROM portfolio_proc;





##########################
### PROFILE TABLE ###
##########################

-- inspectation
SELECT * FROM profile;
SELECT DISTINCT gender FROM profile;



-- there will be error: ERROR CODE 1292 Truncated incorrect INTEGER value: '' when creating the new table
-- need to turn off mysql strict mode 
-- refer to (https://stackoverflow.com/questions/40881773/how-to-turn-on-off-mysql-strict-mode-in-localhost-xampp)

-- if we see STRICT_TRANS_TABLES, then it's in strict mode
SHOW VARIABLES LIKE 'sql_mode';  

-- turn off strict mode
set sql_mode='NO_ENGINE_SUBSTITUTION'; 




-- preprocessing and create a new table
	-- replace empty strings to 'U' for gender, TRIM(), UPPER(), the order of TRIM and UPPER does not matter
    -- became_member convert to date and extract year
    -- change income to int or float, replace empty strings '' with NULL or 0, generate both in case they are both needed
	-- rename the columns
DROP TABLE profile_proc;
CREATE TABLE profile_proc AS
SELECT
	CASE WHEN gender IN ('F','M','O') THEN TRIM(UPPER(gender)) ELSE 'U' END AS gender,
    age,
    id AS customer_id,
    CAST(became_member_on AS date) AS became_member_on,
    YEAR(CAST(became_member_on AS date)) AS became_member_on_year,
    CAST(income AS signed) AS income_zero,
    CAST(NULLIF(income, '') AS signed) AS income_null
FROM profile
WHERE age != 118;
-- delete 2175 records with age = 118, as these customers provides no info in gender and income


-- view processed profile dataset
SELECT * FROM profile_proc;

-- check if there are duplicated records
SELECT COUNT(DISTINCT customer_id) FROM profile_proc; 




##########################
### TRANSCRIPT TABLE ###
##########################


-- inspectation
SELECT * FROM transcript;

-- see the unique json keys
SELECT DISTINCT JSON_KEYS(value) FROM transcript;

-- see the records with amount at key and the key matching values larger than 30
-- include another quote as there is space between 'offer' and 'id'
-- VALUE -> and JSON_VALUE() are the same thing
SELECT * FROM transcript WHERE JSON_VALUE(value, '$.amount') > 30;
SELECT * FROM transcript WHERE JSON_VALUE(value, '$."offer id"') = '9b98b8c7a33c4b65b9aebfe6a799e6d9'; 
SELECT * FROM transcript WHERE VALUE -> '$."offer id"' = '9b98b8c7a33c4b65b9aebfe6a799e6d9';
	
        
-- extract value in JSON with keys as 'offer id'
SELECT 
	VALUE -> '$."offer id"' value_offer_id
FROM transcript;


-- records with keys as amount that is not NULL
SELECT
	VALUE -> '$.amount' value_amount
FROM transcript
WHERE VALUE -> '$.amount' IS NOT NULL;


-- count for unique offer id
SELECT 
	JSON_EXTRACT(VALUE, '$."offer id"') AS value_offer_id,
    COUNT(*) AS offer_trans_count
FROM transcript
GROUP BY JSON_EXTRACT(VALUE, '$."offer id"'); -- GROUP BY is executed before SELECT


-- find people with extracted amount > 10 and SUM amount > 100
SELECT 
	person,
    SUM(JSON_EXTRACT(VALUE, '$.amount')) AS sum_spending
FROM transcript
WHERE JSON_EXTRACT(VALUE, '$.amount') > 10
GROUP BY person
HAVING SUM(JSON_EXTRACT(VALUE, '$.amount')) > 100; -- WHERE is executed before GROUP BY; order is WHERE, GROUP BY, HAVING, SELECT





-- preprocessing and create a new table
	-- turn JSON columns to columns, delete the quotes "" that were also extracted
    -- use COALESCE to create a column with offer_id as value, if NULL then use 'offer id' as the value, otherwise NULL 
DROP TABLE transcript_proc;
CREATE TABLE transcript_proc AS
SELECT
	person AS customer_id,
    event,
    COALESCE(
		REPLACE(VALUE -> ' $."offer id" ','"' ,''), 
		REPLACE(VALUE -> ' $."offer_id" ','"' ,'') )  as offer_id,
    VALUE -> '$.amount' AS amount,
    VALUE -> '$.reward' AS reward,
    time
FROM transcript
WHERE person IN (SELECT customer_id FROM profile_proc);
	-- we have filtered out people 118 years old, the above line applied this filter as well
	



-- view processed transcript dataset
SELECT * FROM transcript_proc;
SELECT * FROM transcript_proc WHERE customer_id = '94de646f7b6041228ca7dec82adb97d2';

-- show number of records per person
SELECT customer_id, COUNT(*) FROM transcript_proc GROUP BY customer_id ORDER BY COUNT(*) DESC;




-- preprocessing step 2: 
	-- try if time column can be converted to datetime
    
CREATE TABLE transcript_proc_temp AS
SELECT 
	a.*,
    b.became_member_on,
    DATE_ADD(b.became_member_on, INTERVAL a.time HOUR) AS time_dt
FROM transcript_proc a 
LEFT JOIN profile_proc b ON a.customer_id = b.customer_id;

	-- there are 2 keys, 'offer id' and 'offer_id', go back to replace 'offer_id' as well, use COALESCE()
select * from transcript where person='94de646f7b6041228ca7dec82adb97d2' and event='offer completed';


