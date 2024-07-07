
###########################################################################################################
#######################################   PRACTICE  -  Window Functions Exercise  #######################################
###########################################################################################################

USE Exercise1;
ALTER TABLE 201904_sales_reciepts RENAME TO receipts;


SELECT * FROM receipts;
SELECT COUNT(*) FROM receipts; -- 49894


#########################################################
-- analysis target at the difference between instore and outstore sales

SELECT DISTINCT(instore_yn) FROM receipts;
-- Y or N

SELECT COUNT(*) FROM receipts WHERE instore_yn IS NULL;
-- 0 NULLs in instore_yn field

SELECT COUNT(*) FROM receipts WHERE instore_yn = '';
-- 0 empty values in instore_yn field

-- two ways of idemtifying space values
SELECT COUNT(*) FROM receipts_proc WHERE instore_yn = ' ';
SELECT COUNT(*) FROM receipts_proc WHERE TRIM(instore_yn) = '';
-- 294 record having space as values



-- convert transaction_date to date
-- impute space / unknown values in instore_yn as U otherwise trim() + upper()
SELECT CAST(transaction_date AS DATE) AS transaction_date_proc FROM receipts;
DROP TABLE receipts_proc;
CREATE TABLE receipts_proc AS
SELECT 
	CAST(transaction_date AS DATE) AS transaction_date_proc, 
	CASE WHEN TRIM(UPPER(instore_yn)) IN ('Y', 'N') THEN TRIM(UPPER(instore_yn)) ELSE 'U' END AS instore_yn_proc,
    line_item_amount 
FROM receipts;


SELECT DISTINCT(transaction_date_proc) FROM receipts_proc;
-- 04/01/2019 - 04/29/2019

-- check processed dataset
SELECT * FROM receipts_proc;
SELECT COUNT(*) FROM receipts_proc WHERE TRIM(instore_yn_proc) = '';





#########################################################
-- WINDOW FRAME SUM () + LAST_VALUE ()
-- count cumulated sales ordered by date and partitioned by instore_yn
-- if just targeting sum of sales for different category of instore_yn, then GROUP BY can do.
-- UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ensures LAST_VALUE looks at the entire partition
SELECT 
	transaction_date_proc,
    instore_yn_proc,
    line_item_amount,
    cum_sales_by_storeyn,
    LAST_VALUE(cum_sales_by_storeyn) OVER(PARTITION BY instore_yn_proc ORDER BY transaction_date_proc
											ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_cum_sales_by_storeyn
FROM(
	SELECT 
		transaction_date_proc,
		instore_yn_proc,
		line_item_amount,
		SUM(line_item_amount) OVER(PARTITION BY instore_yn_proc ORDER BY transaction_date_proc 
									ROWS UNBOUNDED PRECEDING) AS cum_sales_by_storeyn
	FROM receipts_proc
) AS a;
-- Y: 116833; N:115530; U: 1272



-- WINDOW FRAME AVG ()
-- see average sales in every 3 days
SELECT 
	transaction_date_proc,
	instore_yn_proc,
    sum_sale_per_day,
    AVG(sum_sale_per_day) OVER(ORDER BY transaction_date_proc
								ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS running_sales
FROM(
	SELECT 
		transaction_date_proc,
		instore_yn_proc,
		SUM(line_item_amount) AS sum_sale_per_day
	FROM receipts_proc
	GROUP BY transaction_date_proc
) AS b
ORDER BY running_sales DESC;
-- largest average sales happens between 04/16/2019 - 04/18/2019



-- LAG()
-- see the difference between consecutive days
SELECT 
	transaction_date_proc,
    instore_yn_proc,
    sum_sale_per_day,
    LAG(sum_sale_per_day) OVER(ORDER BY transaction_date_proc) AS sum_sale_per_day_pre,
    LAG(sum_sale_per_day) OVER(ORDER BY transaction_date_proc) - sum_sale_per_day AS sum_sale_diff
FROM(
	SELECT 
		transaction_date_proc,
		instore_yn_proc,
		SUM(line_item_amount) AS sum_sale_per_day
	FROM receipts_proc
	GROUP BY transaction_date_proc
) AS c;




