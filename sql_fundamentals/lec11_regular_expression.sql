###########################################################################################################
#######################################   PRACTICE  -  Regular Expression #######################################
###########################################################################################################


CREATE SCHEMA Exercise2;
USE Exercise2;

--  Prepare ugly table
CREATE TABLE ugly_table (
	studentID  INT NOT NULL, 
	name VARCHAR(40), 
	age INT,
	city VARCHAR(40),
	join_dt DATE, 
	sportTeam VARCHAR(40),
	team VARCHAR(40)
);

TRUNCATE ugly_table;

-- insert datapoints into Student table
INSERT INTO ugly_table 
	(studentID, name, age, city, join_dt, sportTeam,team)
VALUES 
	(1, 'Amy,Liaw', '21', 'Syracuse123', '2015-01-04','Lacrosse','TEAM1_GROUPA'),
	(2, 'Sarah100', '25', '456Syracuse', '2019-03-05','Baseball','TEAM2_GROUPA'),
	(3, 'Jimmy,Kimmel200', '25', '@@@@4545Boston', '2015-02-23','Baseball','TEAM3_GROUPB'),
    (4, 'A00MY', '23', NULL, '2018-03-03','Basketball','TEAM1_GROUPB'),
    (5, 'Lady,Gaga300', 78,'Boston!235', '2010-10-10',NULL,'TEAM5_GROUPA'),
    (6, ' 500Taylor,Swift', 99,'Syracuse', '2020-03-04','Baseball','TEAM6_GROUPB');

SELECT * FROM ugly_table;


###############################################################################
-- Test the following with (https://regex101.com/)

-- return name has 100 or 200
SELECT * FROM ugly_table WHERE name REGEXP '100|200';

-- return name has 00, no matter there is text before and after 00
SELECT * FROM ugly_table WHERE name REGEXP '.00';

-- use LIKE to get the same result;
SELECT * FROM ugly_table WHERE name LIKE '%00%';

-- return name with 'H' or '5'
-- return if match to any value in [ ] , [H5] >> H|5
SELECT * FROM ugly_table WHERE name REGEXP '[H|5]';
SELECT * FROM ugly_table WHERE name REGEXP '[H5]'; -- = [H | 5]  match to any of value

-- return if match to any value in [ ] , [0-9] >> 0|1|2|3|4...|9
SELECT * FROM ugly_table WHERE name REGEXP '[0-9]';

-- return if match any value between A - B; we can also use A-Z
SELECT * FROM ugly_table WHERE name REGEXP '[A-B]';

-- if one of value in a column doesn't match to any value within [ ] , it will return
-- In SET THEORY, the value in a column must be a subset of the set in bracket; having intersections is not enough
SELECT * FROM ugly_table WHERE age REGEXP '[^1234]';
	-- 25 is returned, 2 is in the bracket but 5 is not; 
SELECT * FROM ugly_table WHERE name REGEXP '[^amy01]';
	-- A00MY is not returned since it is a subset of regular expression specified

-- we want (TEAM 1 or TEAM2) and (GROUPA or GROUP B)
SELECT * FROM ugly_table WHERE team REGEXP 'TEAM[13]_GROUP[AB]';

-- (^) : return records that STARTS with 'A' 
SELECT * FROM ugly_table WHERE name REGEXP '^A';

-- ($) : return records ENDS with 'a'
SELECT * FROM ugly_table WHERE name REGEXP '0$';

-- return value having 'a' and 'w' as consecutive characters
select * from ugly_table where name REGEXP '[a][w]';
	-- valid: 	0aw, wwaw, awd
    -- invalid: a_w, addw, a0w


###############################################################################
SELECT * FROM ugly_table;

-- clean name column
SELECT
	name,
    LOCATE(',', name)
FROM ugly_table; -- return the index of comma in each character sequence

SELECT 
	name,
    LOCATE(',', name),
    CASE WHEN LOCATE(',', name) = 0 THEN TRIM(UPPER(REGEXP_REPLACE(name, '[^A-Za-z]', '')))
		ELSE TRIM(UPPER(REGEXP_REPLACE(name, '[^A-Za-z]', ' '))) END AS new_name
FROM ugly_table;



-- clean column city
SELECT 
	city,
    TRIM(UPPER(REGEXP_REPLACE(city, '[^A-Za-z]', '')))
FROM ugly_table;


-- preprocess and create a new table
DROP TABLE ugly_table_proc;
TRUNCATE TABLE ugly_table_proc;

CREATE TABLE ugly_table_proc AS
SELECT 
	CASE WHEN LOCATE(',', name) = 0 THEN TRIM(UPPER(REGEXP_REPLACE(name, '[^A-Za-z]', '')))
		ELSE TRIM(UPPER(REGEXP_REPLACE(name, '[^A-Za-z]', ' '))) END AS name,
    age,
    TRIM(UPPER(REGEXP_REPLACE(city, '[^A-Za-z]', ''))) AS city,
    join_dt AS join_date,
    UPPER(sportteam) AS sportteam,
    team
FROM ugly_table;

SELECT * FROM ugly_table_proc;


