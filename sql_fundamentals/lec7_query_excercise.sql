

USE Exercise1;


-- 1. SELECT the student who is FROM city Syracuse
SELECT * 
FROM Student 
WHERE city='Syracuse'  
	OR REPLACE(City,'Syracuse123','Syracuse') = 'Syracuse'; -- REPLACE syracuse123 to syracuse


-- 2. Show student who is in History OR Math class and join_dt before 2018-06-01
SELECT DISTINCT name 
FROM Student 
INNER JOIN Class ON Student.studentID = Class.studentID
WHERE TRIM(Classname) IN ('History','Math') AND 
	join_dt < '2018-06-01' AND 
	name IS NOT NULL; 
-- when showing to manager, it is preferred to show a single distinct name with no NULL values


-- use LEFT JOIN, the same
SELECT DISTINCT name 
FROM student 
LEFT JOIN class ON Student.studentID = Class.studentID
WHERE TRIM(Classname) IN ('History','Math') AND 
	join_dt < '2018-06-01' AND 
	name IS NOT NULL;
-- it is recommended to use LEFT JOIN since it makes more sense to consider student as the main entity for filtering


SELECT * 
FROM Student 
INNER JOIN Class ON Student.studentID = Class.studentID
WHERE TRIM(Classname) IN ('History','Math') AND 
	join_dt < '2018-06-01';


SELECT * 
FROM class 
WHERE TRIM(Classname) IN ('Art','English','History');
-- same as TRIM(Classname) = 'English' or TRIM(Classname) = 'History' or TRIM(Classname) = 'Art'  ; 



-- 3. Show student who played Baseball and get grades A in any of the class
SELECT student.name 
FROM student 
LEFT JOIN class ON student.studentID=class.studentID
WHERE SportTeam='Baseball' AND Grades='A';
-- student.* = *; student.name = name


-- 4. How many DISTINCT student with grade=C (in any class)? 
SELECT COUNT(DISTINCT studentID) 
FROM class 
WHERE grades='C';


-- 5. How many student per each SportTeam?
SELECT 
	SportTeam, 
	COUNT(DISTINCT studentID) 
FROM student
WHERE SportTeam IS NOT NULL 
GROUP BY SportTeam;
-- filter out rows with NULL in SportTeam column


-- 6. How many student per Sportteam and city?
SELECT 
	SportTeam, 
	city, 
    COUNT(DISTINCT studentID) AS count 
FROM student 
WHERE SportTeam IS NOT NULL 
	AND city IS NOT NULL 
GROUP BY SportTeam, City 
ORDER BY COUNT(DISTINCT studentID) DESC; 
-- it is better to include ORDER BY for reporting


-- 7. Show city that has equal or more than 2 students
SELECT 
	city, 
	COUNT(DISTINCT studentID) AS student_count 
FROM student 
GROUP BY city
HAVING student_count >=2;
-- HAVING execute after SELECT


-- 8. Show class that has less than 3 student and has a valid student name (not NULL) 
SELECT 
	a.classname,
    COUNT(DISTINCT a.studentid) as student_count
FROM class a
LEFT JOIN student b ON a.studentid = b.studentid
WHERE b.name IS NOT NULL
GROUP BY a.classname
HAVING student_count < 3 AND 
	classname IS NOT NULL;
-- it is better to specify a or b for columns selected


-- 9. Show each class with how many different grades
SELECT 
	classname, 
	count(DISTINCT grades) diff_grades
FROM class
WHERE classname IS NOT NULL
GROUP BY classname;
-- AS is not necessary


-- 10. Show student with how many different class that has a valid classname and student name
SELECT 
	TRIM(UPPER(a.name)), 
    COUNT(DISTINCT b.ClassName) AS ct_diff_class
FROM student a LEFT JOIN class b
ON a.studentID = b.studentID 
WHERE a.name IS NOT NULL
GROUP BY a.name;


-- 11. What is the average age in each sport team
SELECT 
	sportteam, 
    AVG(age)
FROM student
WHERE sportteam IS NOT NULL
GROUP BY sportteam;



-- 12. Show how many student per class that student has join after 2018-01-01
SELECT 
	classname, 
	COUNT(DISTINCT student.name) AS ct_student 
FROM class 
LEFT JOIN student ON class.studentID = student.studentID 
WHERE join_dt > '2018-01-01' AND 
	classname IS NOT NULL AND 
    class.studentID IS NOT NULL
GROUP BY clASsname;



