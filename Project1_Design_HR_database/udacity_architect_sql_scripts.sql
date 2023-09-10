--DDL------------------

CREATE TABLE Employee (
	employee_id VARCHAR(20),
	employee_name VARCHAR(50),
	email VARCHAR(50),
	hire_date DATE,
	manager_id VARCHAR(20) NULL,
	manager_name VARCHAR(50),
	CONSTRAINT Employee_pkey PRIMARY KEY (employee_id, manager_name, hire_date)
);



INSERT INTO Employee(employee_id, employee_name, email, hire_date, manager_name)
select distinct emp_id, emp_nm, email, hire_dt, manager FROM proj_stg;


update Employee
set manager_id = hd3.manager_id 
from (
		select distinct e.employee_id , e.manager_name , hd2.manager_id, e.hire_date 
		from  Employee e
		left join (select emp_id , manager , hire_dt, e.employee_id as manager_id
				from proj_stg hd 
				left join employee e on hd.manager = e.employee_name ) hd2
		on e.employee_id = hd2.emp_id and e.hire_date = hd2.hire_dt
		) hd3
where Employee.employee_id = hd3.employee_id and Employee.hire_date = hd3.hire_date and Employee.manager_name = hd3.manager_name



CREATE TABLE Job (
	job_id SERIAL PRIMARY KEY,
	job_title VARCHAR(50)
);


INSERT INTO Job(job_title)
SELECT DISTINCT job_title FROM proj_stg;


CREATE TABLE Department (
	department_id SERIAL PRIMARY KEY,
	department VARCHAR(50)
);


INSERT INTO Department(department) 
SELECT DISTINCT department_nm FROM proj_stg;


CREATE TABLE Salary (
	salary_id SERIAL PRIMARY KEY,
	salary FLOAT
);


INSERT INTO Salary(salary)
SELECT distinct salary FROM proj_stg;



CREATE TABLE location (
	location_id SERIAL PRIMARY KEY,
	address VARCHAR(500),
	location VARCHAR(50),
	state VARCHAR(50),
	city VARCHAR(50)
);


INSERT INTO Location(address, location, state, city)
SELECT DISTINCT address, location, state, city FROM proj_stg;



CREATE TABLE Education_Level (
	education_level_id SERIAL PRIMARY KEY,
	education_level VARCHAR(50)
);


INSERT INTO education_level(education_level)
SELECT DISTINCT education_lvl FROM proj_stg;



CREATE TABLE Employment (
	employee_id VARCHAR(20), 
	location_id INTEGER REFERENCES LOCATION(location_id), 
	job_id INTEGER REFERENCES JOB(job_id),
	department_id INTEGER REFERENCES DEPARTMENT(department_id), 
	salary_id INTEGER REFERENCES SALARY(salary_id), 
	education_level_id INTEGER REFERENCES EDUCATION_LEVEL(education_level_id), 
	start_date DATE, 
	end_date DATE,
	CONSTRAINT Employment_pkey PRIMARY KEY (employee_id, job_id, start_date)
);


INSERT INTO Employment(employee_id, location_id, job_id, department_id, salary_id, education_level_id, start_date, end_date)
SELECT DISTINCT hd.emp_id, l.location_id, j.job_id, d.department_id, s.salary_id, el.education_level_id, hd.start_dt, hd.end_dt
	FROM proj_stg AS hd
	JOIN employee AS e
	ON e.employee_id = hd.emp_id
	JOIN location AS l
	ON l.location = hd.location
	JOIN department AS d
	ON d.department = hd.department_nm
	JOIN salary AS s
	ON s.salary = hd.salary
	JOIN education_level AS el
	ON el.education_level = hd.education_lvl
	JOIN job AS j 
	ON j.job_title = hd.job_title



--CRUD------------------

/*Question 1: Return a list of employees with Job Titles and Department Names*/
	
SELECT e.employee_id, j.job_title, d.department
FROM employment AS e
JOIN job AS j
ON j.job_id = e.job_id
JOIN department AS d
ON d.department_id = e.department_id;

/*Question 2: Insert Web Programmer as a new job title*/

INSERT INTO job(job_title) VALUES ('Web Programmer');

select * from job j 
where job_title = 'Web Programmer'


/*Question 3: Correct the job title from web programmer to web developer*/

UPDATE job SET job_title='Web Developer' WHERE job_title='Web Programmer';

select * from job j 
where job_title = 'Web Developer'


/*Question 4: Delete the job title Web Developer from the database*/

DELETE FROM job WHERE job_title='Web Developer'

select * from job j 
where job_title = 'Web Developer'


/*Question 5: How many employees are in each department?*/

SELECT d.department, COUNT(e.employee_id) as number_of_employee
FROM employment AS e 
JOIN department AS d
ON d.department_id = e.department_id
GROUP BY d.department;


/*Question 6: Write a query that returns current and past jobs (include employee name, job title, 
 * department, manager name, start and end date for position) for employee Toni Lembeck.*/
with manager_table as (
	select distinct e.manager_id , e2.employee_name as manager_name
	from employee e
	join (select employee_id, employee_name from EMPLOYEE) e2 
	on e.manager_id = e2.employee_id 
)
SELECT DISTINCT e.employee_name, j.job_title, d.department, mt.manager_name, f.start_date, f.end_date
FROM employment AS f
JOIN employee AS e
ON e.employee_id = f.employee_id
JOIN department AS d
ON d.department_id = f.department_id
JOIN job AS j
ON j.job_id = f.job_id
join manager_table mt
on e.manager_id = mt.manager_id 
WHERE e.employee_name = 'Toni Lembeck';