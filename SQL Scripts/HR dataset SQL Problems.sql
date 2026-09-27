# 1.1 Analyze salary trends over tenure and department

(select
	e.Department,
    round(avg(r.years_at_company),2) as Avg_Tenure,
    round(avg(r.Monthly_Salary),2) as Avg_Pay
from dim_employee as e
inner join fact_record as r
on e.Employee_ID = r.Employee_ID
group by
	e.Department
order by
	Avg_Pay desc
limit 3)
union 
(select
	e.Department,
    round(avg(r.years_at_company),2) as Avg_Tenure,
    round(avg(r.Monthly_Salary),2) as Avg_Pay
from dim_employee as e
inner join fact_record as r
on e.Employee_ID = r.Employee_ID
group by
	e.Department
order by
	Avg_Pay desc
limit 3
offset 6);


# 1.2 Identify most common education levels per role
with cte as(
select
	Job_Title,
    Education_Level,
    count(Employee_ID) as No_of_Employees,
    rank() over(partition by Job_Title order by count(Employee_ID) desc) as Education_Level_Rank
from dim_employee
group by
	Job_Title,
    Education_Level
)
select
	Job_Title,
    Education_Level,
    No_of_Employees,
    Education_Level_Rank
from cte
where 
    Education_Level_Rank = 1;
    
# 1.3 Determine the impact of remote work on performance
select
	w.Remote_Work_Frequency,
    round(avg(w.Employee_Satisfaction_Score),2) as Average_Satisfaction_Score,
    round(avg(r.Performance_Score),2) as Average_Performance_Score
from fact_record as r
inner join fact_workload as w
on r.Employee_ID = w.Employee_ID
group by
	w.Remote_Work_Frequency;
    
# 1.4 Top performers per department
with cte as(
select
	e.Employee_ID,
    e.Name,
    e.department,
    r.Performance_Score,
    r.Years_At_Company,
    round((w.Projects_Handled/r.Years_At_Company),2) as Average_Projects_Handled_per_year,
    dense_rank() over(partition by e.department order by r.Performance_Score desc, (w.Projects_Handled/r.Years_At_Company) desc, r.Years_At_Company asc) as Employee_rank
from dim_employee as e
inner join fact_record as r
on r.Employee_ID = e.Employee_ID
inner join fact_workload as w
on e.Employee_ID = w.Employee_ID
where r.Resigned = 0
and
r.Years_At_Company >= 3
)
select
	Employee_ID,
    Name,
    department,
    Performance_Score,
    Years_At_Company,
    Average_Projects_Handled_per_year
from cte
order by
	Performance_Score desc,
    Average_Projects_Handled_per_year desc,
    Years_At_Company asc;
#where Employee_rank =1;

# 1.5 Employees underperforming:  Useable for downsizing
with cte as(
select
	e.Employee_ID,
    e.Name,
    e.department,
    r.Performance_Score,
    r.Years_At_Company,
    round((w.Projects_Handled/r.Years_At_Company),2) as Average_Projects_Handled_per_year,
    dense_rank() over(partition by e.department order by r.Performance_Score asc, (w.Projects_Handled/r.Years_At_Company) asc, r.Years_At_Company desc) as Employee_rank
from dim_employee as e
inner join fact_record as r
on r.Employee_ID = e.Employee_ID
inner join fact_workload as w
on e.Employee_ID = w.Employee_ID
where r.Resigned = 0
and
r.Years_At_Company > 3
)
select
	Employee_ID,
    Name,
    department,
    Performance_Score,
    Years_At_Company,
    Average_Projects_Handled_per_year
from cte
where Employee_rank < 50;


# 1.6: Analyze employee retention trends
with cte as(
select
	e.Employee_ID,
    e.Age,
    r.Resigned,
    case
		when e.age between 18 and 30 then '18-30'
        when e.age between 31 and 45 then '31-45'
        else '45-60'
	end as Age_group
from dim_employee as e
inner join fact_record as r
on r.Employee_ID = e.Employee_ID
)
select
	Age_group,
    sum(Resigned) as Count_Resignation,
    round(sum(Resigned)*100/count(Resigned),2) as Resign_Percent
from cte
group by
	Age_group;
    
# 1.7 Department-wise education level distribution
select
	Department,
    sum(case when education_level = 'Bachelor' then 1 else 0 end)as Bachelor,
    sum(case when education_level = 'High School' then 1 else 0 end)as High_School,
    sum(case when education_level = 'Master' then 1 else 0 end)as Master,
    sum(case when education_level = 'PhD' then 1 else 0 end)as PhD
from dim_employee
group by
	Department;
    
    
# 1.8 Year-wise hiring trends in the company
select
	Year(Hire_Date) as Year,
    count(Employee_ID) as Hiring_count
from fact_record
group by
	Year(Hire_Date);
    
# 1.9 Gender distribution across departments
select
	Department,
    sum(case when gender = 'Male' then 1 else 0 end)*100/count(Employee_ID) as Male_Percentage,
    sum(case when gender = 'Female' then 1 else 0 end)*100/count(Employee_ID) as Female_Percentage
from dim_employee
group by
	Department;
