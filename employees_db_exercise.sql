-- This is an exercise project that I did after enrolling an online course abou SQL in Data Analytics and Business Intelligence.
-- In the end of the course, there was a final project question that we have to solve in order to complete the course that enlight most of our SQL knowledge.
-- From employees database, there are 10 exercise questions that I will try to answer using SQL sript below.

-- 1. Find the average salary of male and female employees in each department
SELECT 
	d.dept_name, 
	e.gender, 
    AVG(s.salary)
FROM 
	salaries s 
		JOIN 
    employees e ON s.emp_no = e.emp_no
		JOIN
	dept_emp de ON e.emp_no = de.emp_no
		JOIN
	departments d ON d.dept_no = de.dept_no
GROUP BY de.dept_no, e.gender
ORDER BY de.dept_no
;

-- 2. Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number
SELECT
	MIN(de.dept_no)
FROM
	dept_emp de;
    
    SELECT
	MAX(de.dept_no)
FROM
	dept_emp de;
    
-- 3. Obtain a table containing the following three fields for all individuals whose employee number is not greater than 10040: 
-- - employee number 
-- - the lowest department number among the departments where the employee has worked in 
-- - assign '110022' as 'manager' to all individuals whose employee number is lower than or equal to 10020, and '110039' to those whose number is between 10021 and 10040 inclusive. 
SELECT
    emp_no,
    (SELECT
            MIN(dept_no)
        FROM
            dept_emp de
        WHERE
            e.emp_no = de.emp_no) dept_no,
    CASE
        WHEN emp_no <= 10020 THEN '110022'
        ELSE '110039'
    END AS manager
FROM
    employees e
WHERE
    emp_no <= 10040; 
    
-- 4. Retrieve a list of all employees that have been hired in 2000
SELECT 
    *
FROM
    employees
WHERE
    YEAR(hire_date) = 2000
;

-- 5a. Retrieve a list of all employees from the ‘titles’ table who are engineers. 
-- 5b. Repeat the exercise, this time retrieving a list of all employees from the ‘titles’ table who are senior engineers. 
SELECT 
    *
FROM
    titles t
        JOIN
    employees e ON e.emp_no = t.emp_no
WHERE
    title LIKE ('%engineer%')
;
SELECT 
    *
FROM
    titles t
        JOIN
    employees e ON e.emp_no = t.emp_no
WHERE
    title LIKE ('%senior engineer%')
   ;
   
-- 6.Create a procedure that asks you to insert an employee number and that will obtain an output containing 
--   the same number, as well as the number and name of the last department the employee has worked in. 
--   Then, call the procedure for employee number 10010.
DROP PROCEDURE IF EXISTS last_dept;

DELIMITER $$
CREATE PROCEDURE last_dept (in p_emp_no integer)
BEGIN
SELECT
	e.emp_no,
    d.dept_no,
    d.dept_name
FROM
	employees e
		JOIN
	dept_emp de ON e.emp_no = de.emp_no
		JOIN
	departments d ON d.dept_no = de.dept_no
WHERE
	e.emp_no = p_emp_no
		AND de.from_date = (SELECT
			MAX(from_date)
		FROM 
			dept_emp
		WHERE
			emp_no = p_emp_no);
END$$
DELIMITER ;

CALL employees.last_dept(10010);

-- 7. How many contracts have been registered in the ‘salaries’ table with duration of more than one year and 
--    of value higher than or equal to $100,000? 
SELECT 
    COUNT(emp_no)
FROM
    salaries s
WHERE
    salary >= 100000
        AND DATEDIFF(to_date, from_date) > 365
;

-- 8. Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set the 
--    hire date to equal the current date. Format the output appropriately (YY-mm-dd). 
DROP TRIGGER IF EXISTS t_hire_date;

DELIMITER $$
CREATE TRIGGER t_hire_date
BEFORE INSERT ON employees

FOR EACH ROW
BEGIN
	DECLARE today DATE;
    SELECT date_format(sysdate(), '%Y-%m-%d') INTO today;
    
	IF NEW.hire_date > today THEN
		SET NEW.hire_date = today;
	END IF;
END $$

DELIMITER ;

-- 9.Define a function that retrieves the largest contract salary value of an employee. Apply it to employee number 11356. 
--   In addition, what is the lowest contract salary value of the same employee? You may want to create a new function that to obtain the result. 
DROP FUNCTION IF EXISTS f_highest_salary;

DELIMITER $$
CREATE FUNCTION f_highest_salary (p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

DECLARE v_highest_salary DECIMAL(10,2);

SELECT
    MAX(s.salary)
INTO v_highest_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;

RETURN v_highest_salary;
END$$

DELIMITER ;

SELECT f_highest_salary(11356);


DROP FUNCTION IF EXISTS f_lowest_salary;

DELIMITER $$
CREATE FUNCTION f_lowest_salary (p_emp_no INTEGER) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

DECLARE v_lowest_salary DECIMAL(10,2);

SELECT
    MIN(s.salary)
INTO v_lowest_salary FROM
    employees e
        JOIN
    salaries s ON e.emp_no = s.emp_no
WHERE
    e.emp_no = p_emp_no;

RETURN v_lowest_salary;
END$$

DELIMITER ;

SELECT f_lowest_salary(11356);

-- 10. Based on the previous exercise, you can now try to create a third function that also accepts a second 
--     parameter. Let this parameter be a character sequence. Evaluate if its value is 'min' or 'max' and based on 
--     that retrieve either the lowest or the highest salary, respectively (using the same logic and code structure 
--     from Exercise 9). If the inserted value is any string value different from ‘min’ or ‘max’, let the function 
--     return the difference between the highest and the lowest salary of that employee.
DROP FUNCTION IF EXISTS f_salary;

DELIMITER $$
CREATE FUNCTION f_salary (p_emp_no INTEGER, p_min_or_max VARCHAR(10)) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN

DECLARE v_salary_info DECIMAL (10,2);

SELECT
	CASE
		WHEN p_min_or_max = 'max' THEN MAX(salary)
        WHEN p_min_or_max = 'min' THEN MIN(salary)
        ELSE MAX(salary)-MIN(salary)
	END AS salary_info

INTO v_salary_info FROM
	employees e
		JOIN
	salaries s ON e.emp_no = s.emp_no
WHERE e.emp_no = p_emp_no;

RETURN v_salary_info;
END$$

DELIMITER ;

SELECT employees.f_salary(11356, 'min');
SELECT employees.f_salary(11356, 'max');

-- Thank you for checking my exercise project up until the end. I hope you have a nice day :)