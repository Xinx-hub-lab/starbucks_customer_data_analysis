

USE Exercise1;

-- 1. how many customer are sign up in the home_store  3 ? 
SELECT 
	COUNT(DISTINCT customer_id) 
FROM customer 
WHERE home_store=3;



-- 2. what are the most common name?
SELECT 
	`customer_first-name`, 
	COUNT(DISTINCT customer_id) AS name_count 
FROM customer 
GROUP BY `customer_first-name` 
ORDER BY name_count DESC 
LIMIT 10;


-- 3.  how many different birth_year?
SELECT 
	COUNT(DISTINCT birth_year) 
AS ct_birth_yr 
FROM customer;


-- 4. extract year only from 'birthdate' column 
WITH a AS (
	SELECT 
		birthdate, 
		CAST( birthdate AS date ) AS birthdate_datetype , 
		YEAR(CAST( birthdate AS date )) AS birthdate_year,
        CAST(YEAR(CAST( birthdate AS date )) AS CHAR) as birthdate_year_char
	FROM customer
)
SELECT 
	COUNT(DISTINCT birthdate_year_char) 
AS ct_birth_yr 
FROM a; -- CAST cannot have ' ' between CAST and (
-- we must turn year to char since COUNT(DISTINCT) cannot identify datetime types of data


-- approach 2 
SELECT COUNT(DISTINCT birthdate_year) FROM(
	SELECT 
		birthdate , 
		CAST( birthdate AS date ) AS birthdate_datetype , 
		YEAR(CAST( birthdate AS date )) AS birthdate_year
	FROM customer
) AS a ;
-- you have to name the new datASet created by subquery that follows the FROM

-- approach 3 : LEFT(string, number_of_chars)
SELECT birthdate, LEFT(birthdate,4) AS birthdate_yr FROM customer; 
	-- make sure the string format of date has the same appearance

-- approach 4  : SUBSTRING(string, start, LENGTH) 
SELECT birthdate, SUBSTRING(birthdate, 1, 4) AS birthdate_yr FROM customer;


-- approach 5 : locate(SUBSTRING, string, start)
SELECT birthdate, LEFT( birthdate, LOCATE('-', birthdate)-1) AS birthdate_first_occurence FROM customer; 
	-- start from 1, not 0, different from Python
    -- LOCATE() function returns the position of the FIRST occurrence of a substring in a string




-- 5. what's the youngest and oldes age?
SELECT 
	MAX(birth_year), 
	MIN(birth_year) 
FROM customer;

SELECT 
	2021 - MAX(birth_year) AS youngest_age, 
	2021 - MIN(birth_year) AS oldest_age
FROM customer; 



-- 6. seperate name to first and last name
SELECT 
	`customer_first-name`, 
	LOCATE(' ', `customer_first-name`),
	SUBSTRING(`customer_first-name`, 
		1, LOCATE(' ', `customer_first-name`)-1) AS first_name,
	LENGTH(SUBSTRING(`customer_first-name`, 
		1, LOCATE(' ', `customer_first-name`)-1)),
	SUBSTRING(`customer_first-name`, 
		LOCATE(' ', `customer_first-name`)+1, LENGTH(`customer_first-name`)) AS last_name
FROM customer;

-- approach 2 :
SELECT 
	`customer_first-name`,
	LEFT(`customer_first-name` , 
		LOCATE(' ', `customer_first-name`)-1) AS first_name,
	LENGTH(`customer_first-name`) AS total_length,
    RIGHT(`customer_first-name`, 
		LENGTH(`customer_first-name`) - LOCATE(' ' , `customer_first-name`)) AS last_name
FROM customer; -- right( col_name, lASt x digit >> total LENGTH - position of the 'space' 



SELECT * FROM customer;




-- 7. what's the profit (retailprice - wholesale)  product_category='Coffee'
SELECT 
	current_wholesale_price,
	current_retail_price,
	CAST(
		SUBSTRING(current_retail_price, 2 , LENGTH(current_retail_price)) -- remove $ 
		AS DECIMAL(4,2) -- gives total of 4 digits, 2 of which are allowed after decimal point
		) - current_wholesale_price AS profit 
FROM product
WHERE product_category = 'Coffee';

-- approach 2 :
SELECT 
	current_wholesale_price, 
	current_retail_price,
	REPLACE(current_retail_price, '$', '') AS rm_sign_retail_price
FROM product;




-- how many different unit of measure? -- lb, oz, ?
SELECT DISTINCT unit_of_measure FROM product;




