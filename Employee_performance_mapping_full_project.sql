CREATE DATABASE employee;
use employee;

CREATE TABLE proj_table(
PROJECT_ID CHAR(10) PRIMARY KEY,
PROJ_NAME	VARCHAR(100),
DOMAIN	    VARCHAR(100),
START_DATE	 DATE,
CLOSURE_DATE DATE,
DEV_QTR	    CHAR(10),
STATUS      VARCHAR(50)
);

CREATE TABLE emp_record_table(
EMP_ID	   CHAR(10) PRIMARY KEY,
FIRST_NAME	VARCHAR(100),
LAST_NAME	VARCHAR(100),
GENDER	    CHAR(5),
ROLE	    VARCHAR(100),
DEPT	    VARCHAR(100),
EXP	        INT,
COUNTRY	    VARCHAR(100),
CONTINENT	VARCHAR(100),
SALARY	    INT,
EMP_RATING	INT,
MANAGER_ID	CHAR(10),
PROJ_ID     CHAR(10),
FOREIGN KEY (PROJ_ID) REFERENCES Proj_table(PROJECT_ID)
);

CREATE TABLE data_science_team(
EMP_ID	    CHAR(10) PRIMARY KEY,
FIRST_NAME  VARCHAR(100),
LAST_NAME	VARCHAR(100),
GENDER	    CHAR(5),
ROLE	    VARCHAR(100),
DEPT	    VARCHAR(100),
EXP	         INT,
COUNTRY	    VARCHAR(100),
CONTINENT   VARCHAR(100),
FOREIGN KEY (EMP_ID) REFERENCES emp_record_table(EMP_ID)
);

ALTER TABLE emp_record_table
ADD CONSTRAINT fk_manager
FOREIGN KEY (MANAGER_ID) REFERENCES emp_record_table(EMP_ID);

-- load the csv file 
-- go to table and click on data import and select the csv files

-- Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, andmake a list of employees and details of their department

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table;

-- Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is:
-- • less than two

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING < 2;

-- Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is:
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
 WHERE EMP_RATING > 4;
 
 -- Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is:
 -- • between two and four
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING BETWEEN 2 AND 4 ;

-- Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in theFinancedepartment from the employee table and then give the resultant column alias as NAME.

SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME
FROM emp_record_table
WHERE DEPT = 'Finance';

-- Write a query to list only those employees who have someone reporting to them. Also, show the number of reporters (including the President).

SELECT 
    e.EMP_ID AS MANAGER_ID, 
    CONCAT(e.FIRST_NAME, ' ', e.LAST_NAME) AS MANAGER_NAME, 
    COUNT(r.EMP_ID) AS NUMBER_OF_REPORTERS
FROM emp_record_table e
LEFT JOIN emp_record_table r
    ON e.EMP_ID = r.MANAGER_ID
WHERE r.EMP_ID IS NOT NULL
GROUP BY e.EMP_ID, e.FIRST_NAME, e.LAST_NAME;

-- Write a query to list down all the employees from the healthcare and finance departments using union. Take data from the employee record table.

SELECT EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM emp_record_table
WHERE DEPT = 'Healthcare'

UNION ALL

SELECT EMP_ID, FIRST_NAME, LAST_NAME, DEPT
FROM emp_record_table
WHERE DEPT = 'Finance';

/* Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
Also include the respective employee rating along with the max emp rating for the department.*/

SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EMP_RATING,  MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_EMP_RATING
FROM emp_record_table
ORDER BY DEPT, EMP_RATING DESC;

-- Write a query to calculate the minimum and the maximum salary of the employees in each role. Take data from the employee record table.

SELECT ROLE, 
    MIN(SALARY) AS MIN_SALARY, 
    MAX(SALARY) AS MAX_SALARY
FROM emp_record_table
GROUP BY ROLE;

-- Write a query to assign ranks to each employee based on their experience. Take data from the employee record table.

SELECT 
EMP_ID, 
FIRST_NAME, 
LAST_NAME, 
ROLE, 
EXP, 
RANK() OVER (ORDER BY EXP DESC) AS RANKING
FROM emp_record_table
ORDER BY RANKING;

-- Write a query to create a view that displays employees in various countries whose salary is more than six thousand.Take data from the employee record table.

CREATE VIEW High_Salary_Employees AS
SELECT 
    EMP_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    COUNTRY, 
    SALARY
FROM emp_record_table
WHERE SALARY > 6000;

SELECT * FROM High_Salary_Employees;

-- Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.

SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EXP
FROM emp_record_table
WHERE EXP > (
    SELECT 10
);

-- Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. Take data from the employee record table.

DELIMITER //

CREATE PROCEDURE Get_Employees_With_Experience()
BEGIN
    SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, EXP
    FROM emp_record_table
    WHERE EXP > 3;
END //

DELIMITER ;

CALL Get_Employees_With_Experience();

/* Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data science team matches the organization’s 
set standard
The standard is given as follows:
• Employee with experience less than or equal to 2 years, assign 'JUNIOR DATA SCIENTIST’
• Employee with experience of 2 to 5 years, assign 'ASSOCIATE DATA SCIENTIST’
• Employee with experience of 5 to 10 years, assign 'SENIOR DATA SCIENTIST’
• Employee with experience of 10 to 12 years, assign 'LEAD DATA SCIENTIST’,
• Employee with experience of 12 to 16 years, assign 'MANAGER' */

DELIMITER //

CREATE FUNCTION Check_Job_Profile(exp INT) 
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE job_profile VARCHAR(100);

    IF exp <= 2 THEN
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp > 2 AND exp <= 5 THEN
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp > 5 AND exp <= 10 THEN
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF exp > 10 AND exp <= 12 THEN
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSEIF exp > 12 AND exp <= 16 THEN
        SET job_profile = 'MANAGER';
    ELSE
        SET job_profile = 'OTHER';
    END IF;

    RETURN job_profile;
END //

DELIMITER ;

SELECT 
    EMP_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    ROLE AS ASSIGNED_ROLE, 
    Check_Job_Profile(EXP) AS STANDARD_ROLE,
    CASE 
        WHEN ROLE = Check_Job_Profile(EXP) THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS STATUS
FROM data_science_team;

-- Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.

CREATE INDEX idx_first_name ON emp_record_table(FIRST_NAME);

SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT 
FROM emp_record_table
WHERE FIRST_NAME = 'Eric';

EXPLAIN SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT 
FROM emp_record_table
WHERE FIRST_NAME = 'Eric';

-- Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).

SELECT 
    EMP_ID, 
    FIRST_NAME, 
    LAST_NAME, 
    SALARY, 
    EMP_RATING, 
    (0.05 * SALARY * EMP_RATING) AS BONUS
FROM emp_record_table;

-- Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.

SELECT 
    CONTINENT, 
    COUNTRY, 
    AVG(SALARY) AS AVERAGE_SALARY
FROM emp_record_table
GROUP BY CONTINENT, COUNTRY
ORDER BY CONTINENT, COUNTRY;



