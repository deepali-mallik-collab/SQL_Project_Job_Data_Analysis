SELECT 
    COUNT(job_id),
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM 
    job_postings_fact   
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;


/*
Label new column as follows:
- 'Anywhere' jos as 'Remote'
- 'New York, NY' jos as 'NYC'
- Otherwise all other job locations as 'Other'
- how many data analyst jobs are in each category 
*/


SELECT
    COUNT(job_id) AS job_count,
      CASE
        WHEN salary_year_avg > 110000 THEN 'High Salary'
        WHEN salary_year_avg BETWEEN 80000 AND 110000 THEN 'Standard Salary'
        ELSE 'Low Salary'
    END AS salary_category    
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    salary_category
ORDER BY
    job_count DESC;


/*subquery to find all jobs posted in January */
SELECT *
FROM ( -- start of subquery
SELECT * 
FROM job_postings_fact 
WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) -- end of subquery
AS january_jobs;

WITH january_jobs AS ( -- CTE definition starts here
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1 
) -- CTE definition ends here

SELECT * 
FROM january_jobs;


-- find the company names that are offering jobs without any degree requirement. we are extracting data from job_postings_fact table and company_dim table. we will join these two tables on company_id column. we will filter the results where job_no_degree_mention is true.
SELECT 
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE company_id IN (
    SELECT 
    company_id
FROM 
    job_postings_fact
WHERE
    job_no_degree_mention = TRUE
ORDER BY
    company_id
    )


/*
Find the companies that have the most job openings.
- Get the total number of job postings per company id (job_postings_fact table)
- Return the total number of jobs with the company name (from company_dim table)
*/

WITH company_job_count AS (
SELECT
    company_id,
    COUNT(*) AS total_jobs
FROM
    job_postings_fact
GROUP BY
    company_id
)

SELECT company_dim.name AS company_name,
        company_job_count.total_jobs
FROM 
    company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    company_job_count.total_jobs DESC;

/* Practice Problem 1
Question: Find the top 5 skills that are most frequently mentioned
in job postings. Use a subquery to find the skill IDs with the
highest counts in the skills_job_dim table and then join this result
with the skills_dim table to get the skill names.
*/

WITH skill_counts AS (
    SELECT
        skill_id,
        COUNT(*) AS skill_count
    FROM
        skills_job_dim
    GROUP BY
        skill_id
    ORDER BY
        skill_count DESC
        LIMIT 5
)
SELECT
    skills_dim.skills,
    skill_counts.skill_count
FROM
    skill_counts
JOIN skills_dim ON skill_counts.skill_id = skills_dim.skill_id
ORDER BY
    skill_counts.skill_count DESC


/* Practice Problem 2
Question
Determine the size category (Small, Medium, or Large) for each
company by first identfying the number of job postings they have.
Use a subquery to calculate the total job postings per company.
A company is considered Small if it has less than 10 job postings,
Medium if the number of job postings is between 10 and 50, and
Large if it has more than 50 job postings. 
Implement a subquery to aggregate job counts per company before
classifying them based on size.
*/

SELECT 
    company_id,
    CASE
        WHEN job_count < 10 THEN 'Small'
        WHEN job_count BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Large'
    END AS company_size 
FROM (
    SELECT
        company_id,
        COUNT(*) AS job_count   
    FROM
        job_postings_fact
    GROUP BY
        company_id
) AS company_job_counts
ORDER BY
    company_size;


/* Practice Problem 3
Question:
Find the count of the number of remote job postings per skill
    - Display the top 5 skills by their demand in remote jobs with role 'Data Analyst'
    - Include skill ID, name, and count of postings requiring the skill 
*/

SELECT
    job_postings.job_id,
    skill_id,
    job_postings.job_work_from_home
FROM   
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE 
    job_postings.job_work_from_home = TRUE;


SELECT
    skill_id,
    COUNT(*) AS skill_count
FROM   
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE 
    job_postings.job_work_from_home = TRUE
GROUP BY
    skill_id;

-- CTEs query

WITH remote_job_skills AS (
  SELECT
    skill_id,
    COUNT(*) AS skill_count
FROM   
    skills_job_dim AS skills_to_job
INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
WHERE 
    job_postings.job_work_from_home = TRUE AND
    job_postings.job_title_short = 'Data Analyst'
GROUP BY
    skill_id
) 
SELECT 
    skills.skill_id,
    skills.skills,
    skill_count
FROM remote_job_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;

-- Get jobs and companies from january 
SELECT 
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION -- combine another table

-- Get jobs and companies from february
SELECT 
    job_title_short,
    company_id,
    job_location
FROM february_jobs

UNION --combine another table

-- Get jobs and companies from march
SELECT 
    job_title_short,
    company_id,
    job_location
FROM march_jobs;


-- Get jobs and companies from january 
SELECT 
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION ALL -- combine another table

-- Get jobs and companies from february
SELECT 
    job_title_short,
    company_id,
    job_location
FROM february_jobs

UNION ALL--combine another table

-- Get jobs and companies from march
SELECT 
    job_title_short,
    company_id,
    job_location
FROM march_jobs;

/* UNION OPERATORS
- UNION
- UNION ALL

Practice Problem 1:
Steps:
- Find job postings from first quarter that have a salary > 70,000
- Combine job posting tables from the first quarter of 2023 (Jan-Mar)
- Gets job postings with an average yearly salary > 70,000
*/


SELECT 
    job_title_short,
    job_location,
    job_via,
    job_posted_date::DATE,
    salary_year_avg
FROM(
SELECT *
FROM january_jobs
UNION ALL
SELECT * 
FROM february_jobs
UNION ALL
SELECT *
FROM march_jobs
) AS quarter1_job_postings
WHERE
    salary_year_avg > 70000 AND
    job_title_short = 'Data Analyst'
ORDER BY 
   salary_year_avg DESC;

/*
Question:
- Get the corresponding skill and skill type for each job posting in Q1
- Include those without any skills, too
- WHy? Look at the skills and the type for each job in the first quarter that has a salary > $70,000
*/

SELECT 
    q1_jobs.job_id,
    q1_jobs.job_title_short,
    skills.skills,
    skills.type
FROM (
    SELECT
        *
    FROM(
        SELECT *
        FROM january_jobs
        UNION ALL
        SELECT * 
        FROM february_jobs
        UNION ALL
        SELECT *
        FROM march_jobs
    ) AS quarter1_job_postings
    WHERE
        salary_year_avg > 70000 AND
        job_title_short = 'Data Analyst'
) AS q1_jobs
LEFT JOIN skills_job_dim AS skills_to_job ON q1_jobs.job_id = skills_to_job.job_id
LEFT JOIN skills_dim AS skills ON skills_to_job.skill_id = skills.skill_id
ORDER BY
    q1_jobs.job_id;