-- creating the main HR table to store employee-level data
CREATE TABLE hrdata
(
    emp_no int8 PRIMARY KEY,               -- Unique employee ID
    gender varchar(6) NOT NULL,            -- Employee gender
    marital_status varchar(50),            -- Marital status
    age_band varchar(50),                  -- Age group (e.g., 20–30, 30–40)
    age int8,                              -- Employee age
    department varchar(50),                -- Department name
    education varchar(50),                 -- Education level
    education_field varchar(50),           -- Field of education
    job_role varchar(50),                  -- Job role/title
    business_travel varchar(50),           -- Business travel frequency
    employee_count int8,                   -- Count flag (used for aggregation)
    attrition varchar(50),                 -- Attrition status (Yes/No)
    attrition_label varchar(50),           -- Attrition label for reporting
    job_satisfaction int8,                 -- Job satisfaction rating (1–4)
    active_employee int8                   -- Active employee indicator
);

SELECT * FROM hrdata
-- importing data from CSV file into the hrdata table
-- (optional if the data is already imported using the standard method)
	--COPY hrdata 
	--FROM 'C:\Users\HP\Desktop\Full Stack Projects\HR Analytics Dashboard\hrdata.csv' 
	--DELIMITER ',' 
	--CSV HEADER;


-- calculating total number of employees with a bachelor's degree
SELECT 
    SUM(employee_count) AS employee_count 
FROM hrdata
--WHERE education = 'Bachelor''s Degree';
--WHERE Department = 'R&D'; -- total number of employees in the specific department
--WHERE education_field = 'Marketing' -- filtering total number of employees for specific education field


-- counting how many employees have left the company (attrition = 'Yes' and 'No')
SELECT 
    COUNT(attrition) AS attrition_count 
FROM hrdata 
WHERE attrition = 'Yes'
	--AND education = 'High School' -- counting employees who left with this education level
	--AND education_field = 'Medical' -- counting employees who left with this education field/major subjects
	--AND department = 'R&D'; -- counting employees who left with specific department


-- calculating overall attrition rate as a percentage (including specific department which is optional)
SELECT 
    ROUND(
        (
            (SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes' AND department = 'Sales') 
            / SUM(employee_count)
        ) * 100, 
    2) AS attrition_rate
FROM hrdata
WHERE department = 'Sales';


-- calculating number of active male employees (total male employees minus male attrition)
SELECT 
    SUM(employee_count) 
    - (SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes' AND gender = 'Male') 
    AS active_employee
FROM hrdata
WHERE gender = 'Male';


-- calculating number of active employees (overall)
SELECT 
    (SELECT SUM(employee_count) FROM hrdata) 
    - COUNT(attrition) AS active_employee 
FROM hrdata
WHERE attrition = 'Yes';



-- calculating average age of employees
SELECT 
    ROUND(AVG(age), 0) AS average_age 
FROM hrdata;



-- analyzing attrition count by gender
SELECT 
    gender, 
    COUNT(attrition) AS attrition_count 
FROM hrdata
WHERE attrition = 'Yes' --AND education = 'High School' --analyzing with specific education level
GROUP BY gender
ORDER BY COUNT(attrition);


-- analyzing department-wise attrition and its percentage contribution
SELECT 
    department, 
    COUNT(attrition) AS attrition_count,
    ROUND(
        (
            CAST(COUNT(attrition) AS numeric) 
            / (SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes'
				--AND gender = 'Female'
			)
        ) * 100, 
    2) AS pct
FROM hrdata
WHERE attrition = 'Yes' --AND gender = 'Female'
GROUP BY department 
ORDER BY COUNT(attrition) DESC;


-- counting number of employees by age
SELECT 
    age,  
    SUM(employee_count) AS employee_count 
FROM hrdata
GROUP BY age
ORDER BY age;


-- analyzing attrition based on education field
SELECT 
    education_field, 
    COUNT(attrition) AS attrition_count 
FROM hrdata
WHERE attrition = 'Yes' --AND department = 'Sales'
GROUP BY education_field
ORDER BY COUNT(attrition) DESC;


-- analyzing attrition rate by gender across different age bands
SELECT 
    age_band, 
    gender, 
    COUNT(attrition) AS attrition,
    ROUND(
        (
            CAST(COUNT(attrition) AS numeric) 
            / (SELECT COUNT(attrition) FROM hrdata WHERE attrition = 'Yes')
        ) * 100, 
    2) AS pct
FROM hrdata
WHERE attrition = 'Yes'
GROUP BY age_band, gender
ORDER BY age_band, gender DESC;


-- enabling tablefunc extension to use crosstab()
CREATE EXTENSION IF NOT EXISTS tablefunc; --extenson already exists


-- creating a pivot table for job satisfaction by job role
SELECT *
FROM crosstab(
    'SELECT job_role, job_satisfaction, SUM(employee_count)
     FROM hrdata
     GROUP BY job_role, job_satisfaction
     ORDER BY job_role, job_satisfaction'
) AS ct(
    job_role varchar(50), 
    one numeric, 
    two numeric, 
    three numeric, 
    four numeric
)
ORDER BY job_role;
