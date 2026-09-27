CREATE OR REPLACE VIEW vw_dim_employee AS
SELECT*,
	case 
		when age between 18 and 25 then '18-25'
        when age between 26 and 35 then '26-35'
        when age between 36 and 45 then '46-55'
        when age between 46 and 55 then '46-55'
        when age > 55 then '55+'
	end as Age_Bucket
from dim_employee;

CREATE OR REPLACE VIEW vw_fact_workload AS
SELECT*
from fact_workload;

CREATE OR REPLACE VIEW vw_fact_record AS
SELECT*,
	case
		when Years_At_Company between 0 and 4 then '0-4'
        when Years_At_Company between 5 and 10 then '5-10'
        when Years_At_Company between 11 and 15 then '11-15'
        when Years_At_Company between 15 and 20 then '15-20'
        when Years_At_Company > 20 then '20+'
	end as Years_bucket
from fact_record;


