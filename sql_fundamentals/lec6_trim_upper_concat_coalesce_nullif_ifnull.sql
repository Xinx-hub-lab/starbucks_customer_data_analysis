

-- Data Preprocessing
USE Exercise1;

-- TRIM()
SELECT name, TRIM(name) AS no_space_name  FROM student WHERE TRIM(name)='Taylor,Swift';


-- LTRIM () or RTRIM(): trim for only left or right
SELECT name, LTRIM(name) AS no_left_space_name FROM student;


-- replace(column, replace FROM , replace to ) 
SELECT classname , REPLACE(classname, ' ' ,'') FROM class; 



-- upper() : upper case
-- lower() : lower case
SELECT * FROM student WHERE UPPER(name)='SARAH';
SELECT * FROM student WHERE TRIM(UPPER(name)) = 'TAYLOR,SWIFT';



-- concat(): concat strings
SELECT 
	Name, Age,
	CONCAT(Name, Age, '@school.edu' ) AS new_email
FROM student;
    
SELECT 
	CONCAT(name, '_' , age , '@' , 'gmail.com') AS email
FROM student;



-- concat_ws(seperator, col1,col2...), only one type of separator
SELECT 
	Name, Age,
	CONCAT_WS(',' , name, age ) AS new_email
FROM student;
-- concat_ws() is more rigorous than concat()



-- Case statement: good for splitting / segmenting 
SELECT 
	age,
	CASE WHEN Age >= 20 AND Age <=23 THEN 'young_student' 
		WHEN Age > 23 AND Age <=24 THEN 'middle-young_student'
		ELSE 'old_studeent' END  AS student_age_explain
 FROM student;
 
 SELECT 
	Grades,
	 CASE WHEN Grades='A' THEN 100 
		WHEN Grades='B' THEN 80
		ELSE 60 END AS grades_score
 FROM class;
 
 
 
 -- NULL VALUE
 SELECT * FROM class WHERE grades IS NULL ;
 
 
 -- ISNULL() : return 1 (true) if value is null , if not nuull THEN return 0 (false)
 SELECT *, ISNULL(grades) AS grades_has_null FROM class WHERE ISNULL(grades)=1;
 
 
 -- COALESCE () : return the first not null values
 -- 'UNKNOWN' is the constant string for NULL value, if no constant stated, the value is NULL
 SELECT *, COALESCE(studentID, Grades, 'UNKNOWN') AS has_value FROM class;
 
 
 -- IFNULL() : return alternative/default value if  value is null 
 SELECT * , IFNULL(Grades, 0) AS new_grades FROM class;
 
 
 -- NULLIF() : compare two values , if they are equal return null, if they are not equal return the first value (new_grade)
 -- usage, e.g.: compare to see if there is a difference between new and old address
 SELECT 
	* , 
    IFNULL(Grades, 0) AS new_grades, 
    NULLIF( IFNULL(Grades, 0), grades) AS compare 
FROM class;
 
 
 

 
 