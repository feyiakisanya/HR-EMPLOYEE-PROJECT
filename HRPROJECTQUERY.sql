select * from [dbo].[Human Resources];

----------------DATA CLEANING------

---rename emp_id to employee_id---- 

exec sp_rename 'dbo.Human Resources.emp_id' , 'employee_id', 'column';

select age from [dbo].[Human Resources];

---ADDING 'AGE' COLUMN TO DATASET---
alter table [dbo].[Human Resources] add age int;
 
set age= datediff (year, birthdate, GETDATE());

select birthdate, age from [Human Resources];
select MIN(age) as youngest, MAX(age) as oldest
from [Human Resources];

select COUNT(*) from [Human Resources] where age <18;

----update termdate---
UPDATE [dbo].[Human Resources]
SET termdate =
CASE 
        WHEN termdate IS NOT NULL AND termdate != '' 
        THEN CONVERT(DATETIME, REPLACE(termdate, ' UTC', ''))
        ELSE '0000-00-00'
    END
WHERE termdate IS NOT NULL AND termdate != '';

select termdate from [Human Resources];
alter table [dbo].[Human Resources]
alter column termdate date;

UPDATE [dbo].[Human Resources]
SET termdate= '2025-01-01'
where termdate IS NULL;

SELECT ISNULL(TRY_CAST(termdate AS DATE), '2025-01-01') 
FROM [Human Resources];





-----What is the gender breakdown of employees in the company?----
select gender, count (*) as count from [Human Resources]
where termdate = '2025-01-01' 
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company---
select race, count (*) as racecount 
from [dbo].[Human Resources]
where termdate = '2025-01-01' 
group  by race ORDER BY COUNT(*) desc;

 ---3. What is the age distribution of employees in the company?----
 select MIN(age) as youngest,
 MAX(age) as oldest from [Human Resources] 
 where termdate = '2025-01-01';
 
 
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 18 AND 24 THEN '18-24'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS count
FROM 
    [Human Resources]
WHERE 
    termdate = '2025-01-01' 
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 18 AND 24 THEN '18-24'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 25 AND 34 THEN '25-34'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 35 AND 44 THEN '35-44'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 45 AND 54 THEN '45-54'
        WHEN DATEDIFF(YEAR, birthdate, GETDATE()) BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END
ORDER BY 
    age_group;

	----
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS count
FROM 
    [Human Resources]
WHERE 
    termdate = '2025-01-01'
GROUP BY 
    gender,
    CASE 
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END
ORDER BY 
    gender, age_group;


 -- 4. How many employees work at headquarters versus remote locations?---

 select hire_date from [Human Resources];
 select location, count(*) as count 
 from [Human Resources] 
 where termdate = '2025-01-01'
 group by location;

 -- 5. What is the average length of employment for employees who have been terminated?--
SELECT 
    round(AVG(DATEDIFF(DAY, hire_date, termdate))/365,0) AS avg_employment_length_in_years
FROM 
    [Human Resources]
WHERE 
    termdate = '2025-01-01'; 


 -- 6. How does the gender distribution vary across departments and job titles?
 select department, gender, count(*) as count
 from [dbo].[Human Resources]
 where termdate = '2025-01-01'
 group by department,  gender
 order by department;

 
-- 7. What is the distribution of job titles across the company?

select jobtitle, count(*) as jobtitlecount
from [Human Resources]
where termdate ='2025-01-01'
group  by jobtitle
order by jobtitle desc;


-- 8. Which department has the highest turnover rate?
WITH DepartmentTurnover AS (
    SELECT 
        department,
        COUNT(*) AS total_employees,
        SUM(CASE WHEN termdate IS NOT NULL THEN 1 ELSE 0 END) AS terminated_employees
    FROM 
        [Human Resources]
    GROUP BY 
        department
)
SELECT 
    department,
    total_employees, 
    terminated_employees, 
    CASE 
        WHEN total_employees = 0 THEN 0  
        ELSE ROUND(terminated_employees * 1.0 / total_employees * 100, 0)  
    END AS turnover_rate_percentage
FROM 
    DepartmentTurnover
ORDER BY 
   department DESC;

--9What is the distribution of employees across locations by city and state?

select location_state, count (*) as state_count
from [dbo].[Human Resources] 
WHERE termdate = '2025-01-01'
group by location_state
order by state_count desc;

----- 10. How has the company's employee count changed over time based on hire and term dates?
WITH YearlyStats AS (
    SELECT
        YEAR(hire_date) AS hire_year,
        COUNT(CASE WHEN hire_date IS NOT NULL THEN 1 END) AS hires,
        COUNT(CASE WHEN termdate IS NOT NULL AND YEAR(termdate) = YEAR(hire_date) THEN 1 END) AS terminations
    FROM [Human Resources]
    WHERE hire_date IS NOT NULL
    GROUP BY YEAR(hire_date)
)
SELECT 
    hire_year,
    hires,
    terminations,
    (hires - terminations) AS net_change,
    CASE 
        WHEN hires = 0 THEN 0
        ELSE ROUND(((hires - terminations) * 1.0 / hires) * 100, 2)
    END AS net_change_percent
FROM 
    YearlyStats
ORDER BY 
    hire_year asc;
---11. What is the tenure distribution for each department?--

select department,ROUND(AVG(DATEDIFF(DAY, hire_date, 
                        CASE 
                            WHEN termdate IS NULL THEN GETDATE() 
                            ELSE termdate 
                        END) / 365), 0) as avg_tenure
from [Human Resources] where termdate <= getdate() and termdate <> '2025-01-01'
group by department;


