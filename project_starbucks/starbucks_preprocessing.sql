
###########################################################################################################
#######################################   Project : Starbucks Customer Data    #####################################
###########################################################################################################

CREATE SCHEMA IF NOT EXISTS project;
USE project;


/* PREPROCESSING / CLEANING */

##########################
### PROTFOLIO TABLE ###
##########################

-- preprocess and create new table
	-- one hot encoding for channels column
	-- upper case + trim for offer_type
DROP TABLE IF EXISTS portfolio_proc;
CREATE TABLE portfolio_proc AS
SELECT 
    reward, 
    difficulty, 
    duration, 
    id AS offer_id, 
    TRIM(UPPER(offer_type)) AS offer_type, 
    CASE WHEN JSON_CONTAINS(channels, '["web"]') THEN 1 ELSE 0 END AS channel_web,
    CASE WHEN JSON_CONTAINS(channels, '["mobile"]') THEN 1 ELSE 0 END AS channel_mobile,
    CASE WHEN JSON_CONTAINS(channels, '["email"]') THEN 1 ELSE 0 END AS channel_email,
    CASE WHEN JSON_CONTAINS(channels, '["social"]') THEN 1 ELSE 0 END AS channel_social
FROM portfolio;


-- view the processed dataset
SELECT * FROM portfolio_proc;





##########################
### PROFILE TABLE ###
##########################

-- inspectation
SELECT * FROM profile;
SELECT DISTINCT gender FROM profile;

-- Disable strict mode to handle invalid integer values
SHOW VARIABLES LIKE 'sql_mode';  
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
SELECT DISTINCT JSON_KEYS(value) FROM transcript;

-- Examples of extracting and querying JSON values
SELECT * FROM transcript WHERE JSON_VALUE(value, '$.amount') > 30;
SELECT * FROM transcript WHERE JSON_VALUE(value, '$."offer id"') = '9b98b8c7a33c4b65b9aebfe6a799e6d9'; 
SELECT * FROM transcript WHERE VALUE -> '$."offer id"' = '9b98b8c7a33c4b65b9aebfe6a799e6d9';


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
DROP TABLE transcript_proc_temp;
CREATE TABLE transcript_proc_temp AS
SELECT 
	a.*,
    b.became_member_on,
    DATE_ADD(b.became_member_on, INTERVAL a.time HOUR) AS time_dt
FROM transcript_proc a 
LEFT JOIN profile_proc b ON a.customer_id = b.customer_id;

	-- there are 2 keys, 'offer id' and 'offer_id', go back to replace 'offer_id' as well, use COALESCE()
select * from transcript where person='94de646f7b6041228ca7dec82adb97d2' and event='offer completed';




