

######################## SQL Statement Fundamental I  #########################
-- how to import a csv
-- how to execute a statement or multiple statement
-- learn to read error message



USE SQL_BOOTCAMP;
-- direct to the right library, otherwise when referring a dataset, you have to use 'SQL_BOOTCAMP.customer' instead of just 'customer'


/* SELECT; DISTINCT; COUNT; WHERE; ORDER BY*/
SELECT * FROM customer ; 
-- SELECT all records (*)

SELECT customer_id,  `customer_first-name` ,  customer_since  FROM customer ; 
-- The '``' can help to specify the variable with special symbols, e.g. here we have '-', it also applies for spaces ` `

SELECT DISTINCT birth_year FROM customer; 
-- get DISTINCT values as a column

SELECT COUNT(DISTINCT product_category)  FROM product;
-- get counts of DISTINCT values IN product_category as a value / cell

SELECT DISTINCT product_category FROM product;

SELECT * FROM product WHERE product_category='Coffee' AND product_type='Drip coffee';
-- WHERE for conditions
 
SELECT * FROM product WHERE NOT product_category='Coffee' ; 
-- SELECT product_category is NOT coffee
-- != or WHERE NOT, they are the same

SELECT * FROM product WHERE product_category='Coffee' OR product_type='Drip coffee';

SELECT * FROM product WHERE product_category='Loose Tea' AND (product_type='Black Tea' OR product_type='Chia Tea' );

SELECT * FROM product WHERE product_category IN ('Coffee','Tea');
-- values FROM a SET

SELECT * FROM product WHERE product_category NOT IN ('Coffee','Tea');
 
SELECT * FROM customer ORDER BY birth_year DESC, customer_since DESC;
-- ORDER BY default is ascendINg ORDER

SELECT * FROM customer WHERE home_store= 5 ORDER BY birth_year DESC LIMIT 5; 
-- LIMIT 5 is similar to head(5)
-- ORDER BY has to be written before LIMIT

SELECT * FROM customer;



/* UPDATE; DELETE; TRUNCATE; DROP*/
UPDATE customer
SET customer_email = 'new@gmail.com'
WHERE customer_id =1 ; 
-- UPDATE record manually with a WHERE clause
-- usually a WHERE clause is needed, other wise all values in a field will be updated, be extra careful

-- Error Code: 1175. You are using safe UPDATE mode and you tried to UPDATE a table without a WHERE that uses a KEY column.  
-- To disable safe mode, toggle the option IN Preferences -> SQL Editor and reconnect.	0.0019 sec

DELETE FROM customer WHERE customer_id =1 ; 
-- delete a row WHERE customer_id = 1

TRUNCATE Customer_Sample; 
-- clean out / delete ALL RECORDS in the table, table empty but REMAINS

DROP TABLE Customer_Sample; 
-- delete the whole table, the container / table itself disappear


/* Functions and Clauses: COUNT; MAX; SUM; LIKE */
SELECT MAX(birth_year) FROM customer;

SELECT COUNT(*) FROM customer; 
-- find out the count 

SELECT COUNT(*) FROM customer WHERE home_store= 5; 

SELECT COUNT(home_store) FROM customer ; 

SELECT SUM(current_wholesale_price) FROM product;

SELECT COUNT(*) AS NUMBEROFCOLUMNS FROM INformation_schema.COLUMNS
WHERE TABLE_NAME ='product'; 
-- find the number of columns of a dataset



SELECT * FROM customer WHERE  upper(`customer_first-name`)  LIKE '%WA%'; 
-- 'K%' start with K ; '%elly' end with elly ; '

SELECT * FROM customer WHERE  customer_email LIKE '%.edu'; 
-- fINd customer as a student

SELECT * FROM customer WHERE  customer_email NOT LIKE 'A%s'; 
-- 'A%s' start with A and end with s

SELECT * FROM customer WHERE  customer_email  LIKE 'n__%';  
-- LIKE is NOT case sensitive, A and a are the same
-- experiment with the followINg:
	-- SELECT * FROM customer WHERE upper(customer_email)  LIKE '_a%';  

SELECT * FROM customer WHERE  customer_email  LIKE 'c%m'; -- 'c%m' start with c and end with m

SELECT * FROM customer WHERE  `customer_first-name`  LIKE 'K_ll___ey'; 

SELECT * FROM customer ;

SELECT * FROM product;


