/* EventSphere Event Management Database Schema

Script 2.11 Populating the Event_Employee Table 
Created by: Arpita Deb
Dated: 2024-09-08 12:55:09.127
About: DML Commands to insert values in the Event_Employee Table 

*/

-- Initiating the database
USE [EventSphere Database];

-- 11. Event_Employee

/* INSERTING THE EVENT_ID, EMPLOYEE_ID COLUMNS
Since there are about 300 employee per organization, not all employee can be associated with each event which is impractical 
(moreover, it scales up the number of rows into millions).
Therefore, I added only a subset of the employee for each event (between 80 and 10) based on event type.
*/



-- Step 1: Create a CTE that selects events and randomly assigns a subset of employees
WITH EmployeeAssignments AS (
    SELECT
        E.event_ID, 
		E.event_Type_ID, 
		Emp.job_title,
        Emp.employee_ID,
        ROW_NUMBER() OVER (PARTITION BY E.event_ID ORDER BY NEWID()) AS RowNum
    FROM 
        [EventSphere Database].[dbo].[Event] E
    JOIN 
        [EventSphere Database].[dbo].[Employee] Emp ON Emp.organization_ID = E.organization_ID
    WHERE 
        E.event_ID IN (SELECT DISTINCT event_ID FROM [EventSphere Database].[dbo].[Event]) AND
		-- I excluded employees with these job titles as they're most unlikely to be directly working on events
		Emp.job_title NOT IN ('Janitor', 'Administrative Officer', 'Executive Secretary', 'Chief Executive Officer', 'Chief Financial Officer','Vice President of Engineering', 'Vice President of Production', 'Vice President of Sales' , 'VP Accounting','VP Marketing', 'Director of Sales','VP Product Management','VP Quality Control','VP Sales' , 'Buyer', 'Social Worker')

)

-- Step 2: Insert into event_employee table, limiting the number of employees per event
INSERT INTO [EventSphere Database].[dbo].[event_employee] 
(event_ID, employee_ID)
SELECT 
    EA.event_ID, 
    EA.employee_ID
FROM 
    EmployeeAssignments EA
WHERE 
    EA.RowNum <= (SELECT CAST(RAND(CHECKSUM(NEWID())) * (60 - 15) + 10 AS INT))
	AND EA.event_type_ID IN (203, 201, 202, 207); -- based on event type, employee number is changed between the range of 10 - 60



-- Setting the deadline to the start date of the event
UPDATE [dbo].[Event_Employee]
SET deadline = e.start_date
FROM [dbo].[Event] e
JOIN [dbo].[Event_Employee] em 
ON em.event_ID = e.event_ID



-- Setting the start_date of the Event_Employee table 7-20 days prior to the deadline
WITH CTE AS (
    SELECT 
        EE.*,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM 
        [dbo].[Event_Employee] EE
	JOIN [dbo].[Event] E ON EE.event_ID = E.event_ID
	WHERE E.event_Type_ID = 204
)
UPDATE CTE
SET [start_date] = CASE 
                    WHEN RowNum <= (TotalRows * 30 / 100) THEN DATEADD(DAY, -20, [deadline]) -- Can change the number of days need to shift from the deadline
					WHEN RowNum <= (TotalRows * 80 / 100) THEN DATEADD(DAY, -15, [deadline]) -- Can change the number of days need to shift from the deadline
					ELSE DATEADD(DAY,-7, [deadline])-- Can change the number of days need to shift from the deadline
                 END;


-- Updating the tasks: To distribute unique tasks to each employee per event without adding extra rows

-- Step 1: Setting up a temp table to hold the tasks
CREATE TABLE #Tasks (
    task_id INT IDENTITY(1,1),
    task_name VARCHAR(255)
);

INSERT INTO #Tasks (task_name)
VALUES 
    ('Venue setup'),
    ('Equipment setup'),
    ('Event teardown'),
    ('Feedback collection'),
    ('Post-event reporting'),
    ('Expense tracking'),
    ('Budget management'),
    ('Vendor payments'),
    ('Security arrangements'),
    ('Health and safety compliance'),
    ('Emergency protocols'),
    ('Registration management'),
    ('Ticketing issues'),
    ('Customer service'),
    ('Coordinate with caterers'),
    ('Manage attendee meals and refreshments'),
    ('VIP guest management'),
    ('Social media promotion'),
    ('Email campaigns'),
    ('Design and distribute promotional materials'),
    ('AV setup and management'),
    ('Live streaming setup'),
    ('IT support'),
    ('Speaker coordination'),
    ('Program scheduling'),
    ('On-stage management');


-- Step 2: Updating the event_employee table with random tasks
UPDATE event_employee
SET task= T.task_name
FROM (
    SELECT 
        ee.event_id, 
        ee.employee_id,
        T.task_name,
        ROW_NUMBER() OVER (PARTITION BY ee.event_id ORDER BY NEWID()) AS rn, --  rn = rank of each task for a given event.
        COUNT(*) OVER (PARTITION BY ee.event_id) AS total_rows, -- total_rows = number of employees per event
        COUNT(*) OVER (PARTITION BY ee.event_id, T.task_name) AS task_count -- task_count= Number of tasks available
    FROM event_employee ee
    CROSS JOIN #Tasks T -- this gives a cartesian product of over 9 million rows of records 
) AS T
WHERE event_employee.event_id = T.event_id
  AND event_employee.employee_id = T.employee_id
  AND T.rn <= (T.total_rows / T.task_count); -- here the number of records are limited by ensuring that only a limited number of tasks (up to the number of employees) are selected for each event.

-- Step 3: Dropping the temp table
DROP TABLE #Tasks;

-- Updating the task completed with 85% complete ad 15% incomplete tasks
WITH CTE AS (
    SELECT 
        EE.*,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM 
        [dbo].[Event_Employee] EE
)
UPDATE CTE
SET [task_completed] = CASE 
							WHEN RowNum <= (TotalRows * 85/ 100) THEN 1 
							ELSE 0
                       END;

-- About 18K records had NULL entries for tasks. So I filled them using the below query.
-- Create the temporary table and insert values
CREATE TABLE #Tasks (task_name NVARCHAR(255));

INSERT INTO #Tasks (task_name)
VALUES 
    ('Venue setup'),
    ('Equipment setup'),
    ('Event teardown'),
    ('Feedback collection'),
    ('Post-event reporting'),
    ('Expense tracking'),
    ('Budget management'),
    ('Vendor payments'),
    ('Security arrangements'),
    ('Health and safety compliance'),
    ('Emergency protocols'),
    ('Registration management'),
    ('Ticketing issues'),
    ('Customer service'),
    ('Coordinate with caterers'),
    ('Manage attendee meals and refreshments'),
    ('VIP guest management'),
    ('Social media promotion'),
    ('Email campaigns'),
    ('Design and distribute promotional materials'),
    ('AV setup and management'),
    ('Live streaming setup'),
    ('IT support'),
    ('Speaker coordination'),
    ('Program scheduling'),
    ('On-stage management');

-- Update the Event_Employee table with values from the #Tasks table
UPDATE E
SET E.task = T.task_name
FROM [dbo].[Event_Employee] E
JOIN #Tasks T ON E.task IS NULL

-- Dropping the temp table
DROP TABLE #Tasks


SELECT * FROM Event_Employee;