-- Query 1
SELECT DISTINCT s_ID, STUDENT.name FROM (STUDENT JOIN TAKES USING (s_ID))
JOIN (INSTRUCTOR JOIN TEACHES USING (i_ID))
USING (course_id, sec_id, semester, year)
WHERE INSTRUCTOR.name = 'Katz'
ORDER BY name ASC;

-- Query 2
SELECT s_ID, round((sum(credits * points)/sum(credits)), 2) AS GradePointAverage
FROM ((COURSE JOIN TAKES USING (course_id)) JOIN STUDENT USING (s_id)) 
JOIN GRADE_POINTS USING (grade)
GROUP BY s_id
ORDER BY GradePointAverage DESC;

-- Query 3
SELECT course_id, sec_id, count(s_ID) AS Count FROM SECTION NATURAL JOIN TAKES
WHERE SEMESTER = 'Fall'
AND YEAR = '2009'
GROUP BY course_id, sec_id
ORDER BY Count DESC;

-- Query 4
SELECT course_id, sec_id FROM (SELECT course_id, sec_id, count(*) AS Enrollment FROM TAKES WHERE SEMESTER = 'Fall' AND YEAR = '2009' GROUP BY course_id, sec_id)
WHERE Enrollment >= ALL 
(SELECT count(*) FROM TAKES WHERE SEMESTER = 'Fall' AND YEAR = '2009' GROUP BY course_id, sec_id);

-- Query 5
SELECT name, count(DISTINCT course_id) AS result FROM INSTRUCTOR NATURAL JOIN TEACHES

(SELECT name, n FROM (SELECT INSTRUCTOR.name, count(DISTINCT TEACHES.course_id) AS n 
FROM TEACHES INNER JOIN INSTRUCTOR ON TEACHES.i_id = INSTRUCTOR.i_id GROUP BY INSTRUCTOR.name ORDER BY count(DISTINCT TEACHES.course_id) DESC, name))
WHERE rownum <= 4;

-- Query 6
SELECT semester, year, count(course_id) NumberOfCourses FROM SECTION
GROUP BY semester, year
ORDER BY count(course_id) DESC, SEMESTER DESC
WHERE rownum <= 3;

-- Query 7


-- Query 8
SELECT INSTRUCTOR.name, count(TAKES.s_id) AS Enrollment FROM INSTRUCTOR
INNER JOIN TEACHES ON INSTRUCTOR.i_id = TEACHES.i_id
INNER JOIN TAKES ON TAKES.course_id = TEACHES.course_id 
    AND TAKES.sec_id = TEACHES.sec_id
    AND TAKES.semester = TEACHES.semester
    AND TAKES.year = TEACHES.year
Group by INSTRUCTOR.i_id, INSTRUCTOR.name
ORDER BY Enrollment DESC
FETCH FIRST 4 ROWS ONLY;

-- Query 9
SELECT dept_name, course_id FROM (DEPARTMENT JOIN COURSE USING (dept_name))
WHERE dept_name = 'Comp. Sci.' OR dept_name = 'History'
GROUP BY dept_name, course_id
ORDER BY course_id;

-- Query 10
SELECT COURSE.course_id, COURSE.dept_name, PREREQ.prereq_id, C.dept_name
FROM COURSE INNER JOIN PREREQ ON COURSE.course_id = PREREQ.course_id
INNER JOIN COURSE C ON C.course_id = PREREQ.course_id
AND C.dept_name <> COURSE.dept_name
ORDER BY COURSE.course_id ASC;
