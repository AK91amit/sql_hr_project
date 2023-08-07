-- data cleaning

create database hr;

use hr;

select * from hr;

ALTER TABLE hr
CHANGE COLUMN id employee_id VARCHAR(20) NULL;

SELECT birthdate from hr;

set sql_safe_updates = 0;

update hr
set birthdate  = case
when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
else null
end;

alter table hr
modify column birthdate date;

update hr
set hire_date  = case
when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
else null
end;

alter table hr
modify column hire_date date;

update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate !='';

 alter table hr
modify column termdate date;

describe hr;

alter table hr
add column age int;

update hr
set age = timestampdiff(year,birthdate,curdate());

select 
min(age) as youngest, max(age) as oldest
from hr;

select count(*)
from hr
where age = 20;

--tasks

-- gender breakdown in company
select gender, count(*)
from hr 
where age >=20 and termdate = '0000-00-00'
group by gender;

-- race breakdown in company
select race, count(*)
from hr 
where age >=20 and termdate = '0000-00-00'
group by race
order by count(*) desc;

-- age distribution in company
select
case 
when age >= 20 and age < 30 then '20s'
when age >= 30 and age < 40 then '30s'
when age >= 40 and age < 50 then '40s'
when age >= 50 and age < 60 then '50s'
else '60s'
end as age_group, gender,
count(*) as count
from hr
where age >=20 and termdate = '0000-00-00'
group by age_group, gender
order by age_group, gender;

-- employees at headquarters vs remote locations
select location, count(*) as count 
from hr
where age >=20 and termdate = '0000-00-00'
group by location
order by count(*) desc;

-- avg length of years for employees in company who have been terminated
select
round(avg(datediff(termdate, hire_date))/365,0) as avg_years
from hr
where termdate <= curdate() and termdate <> '0000-00-00' and age >= 20;

-- gender distribution across departments and job titles
select department, gender, count(*) as count
from hr
where age >=20 and termdate = '0000-00-00'
group by department, gender
order by department;

-- distribution of job titles
select jobtitle, count(*) as count
from hr
where age >=20 and termdate = '0000-00-00'
group by jobtitle
order by count(*) desc;

-- department with highest terminated rate
select department, total_count, terminated_count, terminated_count/total_count as terminated_rate
from(select department, count(*) as total_count,
sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >= 20
group by department) as subquery
order by terminated_rate desc;

select department, count(*) as total_count,
sum(case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as terminated_count
from hr
where age >= 20
group by department;

-- distribution of employees by cities and state
select location_state, location_city, count(*) as count
from hr
where age >=20 and termdate = '0000-00-00'
group by location_state, location_city
order by count(*) desc;

-- company employee count change over time based on hire_date and termdate
select year, hire, termination, hire - termination as net_change,
round((hire - termination)/hire * 100,2) as net_change_percent
from( select
        year(hire_date) as year,
        count(*) as hire,
        sum( case when termdate <> '0000-00-00' and termdate <= curdate() then 1 else 0 end) as termination
        from hr
        where age >= 20
        group by year(hire_date)
        ) as subquery
order by year asc;

-- tenure stay in departments
select department, round(avg(datediff(termdate,hire_date)/365),2) as avg_tenure
from hr
where termdate <> '0000-00-00' and termdate <= curdate() and age >= 20
group by department
order by avg_tenure desc;






