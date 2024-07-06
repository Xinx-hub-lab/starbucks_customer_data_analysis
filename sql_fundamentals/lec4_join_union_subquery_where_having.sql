###########################################################################################################
#######################################   EXERCISE    #######################################################
###########################################################################################################

USE Exercise1;


####################### CREATE TABLE ############################

--  Prepare Student and Class Table 
CREATE TABLE Student (
	studentID  	INT NOT NULL, 
	name    	VARCHAR(40), 
	Age 		INT,
	City 		VARCHAR(40),
	join_dt 	Date, 
	SportTeam 	VARCHAR(40)
);

-- insert datapoints into Student table
INSERT INTO Student (studentID, name, Age, City, join_dt, SportTeam)
VALUES (1, 'Amy,Liaw', '21', 'Syracuse123', '2015-01-04','Lacrosse'),
				(2, 'Sarah', '25', 'Syracuse', '2019-03-05','Baseball'),
				(3, 'Jimmy,Kimmel', '25', 'Boston', '2015-02-23','Baseball'),
                (4, NULL, '23', NULL, '2018-03-03','Basketball'),
                (5, 'Lady,Gaga', NULL,'Boston', '2010-10-10',NULL),
                (6, '   Taylor,Swift', 20,'Syracuse', '2020-03-04','Baseball');

CREATE TABLE Class (
	ClassID 	INT NOT NULL,
	ClassName   VARCHAR(40), 
	studentID   INT, 
	Grades 		VARCHAR(3) 
);

INSERT INTO Class (ClassID, ClassName, studentID, Grades)
VALUES (1, 'History', 2, 'A'),
				(2, 'History', 3, 'A'),
				(3, 'History', 4, 'B'),
                (4, NULL, 2, 'B'),
                (5, ' Math', 2,'C'),
                (6, ' Math', 3,'B'),
                (7, ' Art', NULL, NULL),
                (8, ' English', 2,'C'),
                (9, ' English', 6,'B');




			
-- column name alias using AS
SELECT * , 'Building1' AS location FROM class;  -- This is creating a column 'location' with 'Building 1' as the constant value 
SELECT ClassName AS AMY_ClassName FROM class  ;


-- NULL value
SELECT * FROM Student WHERE 
name IS NOT NULL AND 
age > 21;              
            
            

####################### JOIN ############################

SELECT * FROM class;
SELECT * FROM student;


/* inner join */
SELECT *
FROM student a
INNER JOIN class b ON a.studentID=b.studentID;

-- Consider OUTER JOIN like including with cases of (NULL = valueB, valueA = valueB, valueA = NULL), 
	-- since NULL value can equal to any value; 
	-- whereas INNER JOIN are only including cases of (valueA = a valueB), 
	-- eliminating cases of (valueA = NULL, NULL = valueB).



/* full outer join */
-- UNION and UNION ALL
SELECT * FROM Student a LEFT JOIN class b ON a.studentid=b.studentid
UNION 
SELECT * FROM Student a RIGHT JOIN Class b ON a.studentid=b.studentid;

SELECT * FROM Student a LEFT JOIN class b ON a.studentid=b.studentid
UNION ALL
SELECT * FROM Student a RIGHT JOIN Class b ON a.studentid=b.studentid;

-- how UNION ALL works: append rowwise whenever we have a the record, like: 1,2,3,4,1,2,3
	-- these records comes FROM two tables, they are appended though they may have duplicates
	-- UNION on the other hand only append when there is a new value, meaning no duplicates, like 1,2,3,4, we do NOT have 1,2,3 anymore

-- UNION is for concatenating, OUTER JOIN is for merging:
	-- the difference between UNION and OUTER JOIN, See the link for more details: 
	-- (https://stackoverflow.com/questions/905379/what-is-the-difference-between-join-and-union)

-- However, OUTER JOIN does not work in MySQL, so we have to use UNION (not UNION ALL, be careful) like the 1st query above

-- UNION ALL and UNION is different in UNION ALL is concatenating the FULL LEFT JOIN and FULL RIGHT JOIN,
	-- which means it has duplicated records, which are exactly the records in the intersection / INNER JOIN



/* left join / left outer join */
SELECT * FROM student LEFT JOIN class ON student.studentID = class.studentID;

-- for student ID appear in the LEFT but not in the RIGHT table, 
	-- values will display as NULL for that record without eliminating it from the result
-- for student ID that appear in the RIGHT table but not in the LEFT table, 
	-- the records will be eliminated.



/* left join if NULL / left outer join if NULL */
SELECT * 
FROM student LEFT JOIN class ON student.studentID=class.studentID WHERE class.classID IS NULL; 

-- The difference between left join and left join if NULL is that left join includes the intersection
	-- left join included (valueA = valueB, valueA = NULL) and left join if NULL included only (valueA = NULL)



/* right join */
SELECT  a.Name , b. studentid , b.ClassName FROM student a RIGHT JOIN class b ON a.studentID=b.studentID; 
-- the table is constructed like: we see 'history' and studentid = 2 in record 1, then we find the student id = 2 name and concatenate 
	-- filp the resuly table and think of the sample right join table


-- using alias table name to retrieve column as needed
SELECT a.name, a.Age, b.classname, b.grades 
FROM Student AS a LEFT JOIN Class AS b ON a.studentID=b.studentID WHERE b.classID IS NULL;




####################### Subquery ############################

-- NOT IN return empty records when compare against unknown value (NULL) 
	-- think of NULL as a value that can turn to any value, like NULL can equal to 1,2,3,...etc.
    -- thus, if NULL cannot compare with any value, since it can equal to anything 
    
SELECT * FROM Student WHERE StudentID NOT in 
	(
	SELECT  StudentID FROM Class WHERE StudentID is NOT null
    ) ; 
    
-- equivalent to 
SELECT * FROM Student WHERE StudentID NOT in ( 2,3,4,6 ) ; 




####################### Aggregation ############################

SELECT classname, grades ,count(distinct studentid) as ct_student  FROM class group by classname, grades;
SELECT City , count(distinct NAME) as ct_student, max(age), min(age) FROM Student group by City;

-- if we use * when group by, there will be an error, 
-- since group by canNOT help to display values in columns that are NOT used for group by

-- NOTE: 
-- we have to include the column used for group by as the first column in SELECT
-- the columns in SELECT has to be aggregation, such as COUNT, MAX, MIN, etc.
-- if there is a column not in group by selected, then there will be an error


####################### Having v.s. WHERE ############################

SELECT classname ,count(distinct studentid) as ct_student  FROM class 
WHERE ClassName is  NOT null 
group by classname
having ct_student > 1;

-- HAVING can be used for filtering after GROUP BY, WHERE is NOT applicable after GROUP BY


