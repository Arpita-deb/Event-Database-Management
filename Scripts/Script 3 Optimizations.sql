/* EventSphere Event Management Database Schema

Script 2.3: Optimizations
Created by: Arpita Deb
Dated: 2024-09-13 10:07:43.803
About: DML Commands to add indexes, views, functions etc in the database tables

*/

-- Initiating the database
USE [EventSphere Database];




-- 1. **************************** CLUSTERED AND NON CLUSTERED INDEXES **********************************



--A) CLUSTERED INDEX

-- In [Event_Employee] Table on event_ID, employee_ID since they uniquely identifies a row
CREATE CLUSTERED INDEX EventEmployeeID_idx ON [dbo].[Event_Employee](event_ID, employee_ID)

-- In [Event_Partner] Table on event_ID, partner_ID since they uniquely identifies a row
CREATE CLUSTERED INDEX EventPartnerID_idx ON [dbo].[Event_Partner](event_ID, partner_ID)



--B) NON CLUSTERED INDEX
-- In [Attendee] Table on first_name,last_name
CREATE NONCLUSTERED INDEX AttendeeName_idx ON [dbo].[Attendee](first_name,last_name)

-- In [Employee] Table on Organization_ID 
CREATE NONCLUSTERED INDEX OrganizationID_idx ON [dbo].[Employee](organization_ID)

-- In [Employee] Table on first_name,last_name
CREATE NONCLUSTERED INDEX EmployeeName_idx ON [dbo].[Employee](first_name,last_name)

-- In [Event] Table on Organization_ID 
CREATE NONCLUSTERED INDEX OrganizationID_idx ON [dbo].[Event](organization_ID)

-- In [Event] Table on Venue_ID 
CREATE NONCLUSTERED INDEX VenueID_idx ON [dbo].[Event](venue_ID)

-- In [Event] Table on event_type_ID 
CREATE NONCLUSTERED INDEX EventTypeID_idx ON [dbo].[Event](event_type_ID)

-- In [Event_Ticket_Assignment] Table on attendee_ID 
CREATE NONCLUSTERED INDEX AttendeeID_idx ON [dbo].[Event_Ticket_Assignment](attendee_ID)

-- In [Event_Ticket_Assignment] Table on event_ID 
CREATE NONCLUSTERED INDEX EventID_idx ON [dbo].[Event_Ticket_Assignment](event_ID)

-- In [Venue Table] on address_line, city, state, postal_code, country
CREATE NONCLUSTERED INDEX AddressID_idx ON [dbo].[Venue](address_line, city, state, postal_code, country)




-- 2. **************************** LOOKUP TABLE (CALENDER) **********************************


CREATE TABLE [EventSphere Database].dbo.Calendar
(
DateValue DATE
, DayoftheWeek INT
, DayOfWeekName VARCHAR(9)
, DayofMonth INT
, MonthNumber INT
, MonthName VARCHAR(9)
, YearNum INT
, WeekdayFlag TINYINT
, HolidayFlag TINYINT
)


-- Inserting date values using RECURSIVE CTE

WITH Dates AS
(
SELECT
 CAST('01-01-2014' AS DATE) AS MyDate

UNION ALL

SELECT
	DATEADD(DAY, 1, MyDate)
FROM 
	Dates
WHERE 
	MyDate < CAST('12-31-2024' AS DATE)
)
INSERT INTO [EventSphere Database].dbo.Calendar
(DateValue)

SELECT
	MyDate
FROM 
	Dates
OPTION (MAXRECURSION 4500)

select top 10 * from [dbo].[Calendar];


--Updating the NULL fields in Calendar table
UPDATE [EventSphere Database].dbo.Calendar
SET
		DayoftheWeek = DATEPART(WEEKDAY, DateValue)
		, DayOfWeekName = FORMAT(DateValue, 'dddd')
		, DayofMonth = DAY(DateValue)
		, MonthNumber = MONTH(DateValue)
		, MonthName = FORMAT(DateValue, 'MMMM')
		, YearNum = YEAR(DateValue)

--Updating the WeekdayFlag in Calendar table
UPDATE [EventSphere Database].dbo.Calendar
SET
WeekdayFlag = 
		CASE 
			WHEN DayOfWeekName IN ('Saturday', 'Sunday') THEN 1 
			ELSE 0 
		END


/* Update HolidayFlag in Calendar table 
		New Year's Day (January 1)
		Christmas Day (December 25)
		Thanksgiving Day (Fourth Thursday in November)
*/

UPDATE [EventSphere Database].dbo.Calendar
SET
HolidayFlag =
	CASE
		WHEN (MonthNumber = 12 AND DayOfMonth = 25) -- Christmas Day (December 25th) 
		OR (MonthNumber = 1 AND DayOfMonth = 1)  -- New year's day (January 1st)
		OR (DayOfWeekName = 'Thursday' AND MonthNumber = 11 AND DayofMonth > 21 and DayofMonth <= 28) -- Thanksgiving Day (Fourth Thursday in November)
		THEN 1
		ELSE 0
	END

-- Test Query
SELECT * FROM Calendar;




-- 3. **************************** VIEWS **********************************

/*
1. What are the most frequent queries executed by junior analysts that involve multiple tables, and how can they be simplified using views?
Suggestion: Create a view combining Event, Venue, Attendee, and Event_Type for quickly retrieving event details with attendee and venue info.
*/

CREATE VIEW dbo.EventDetails AS

SELECT Event_ID = E.event_ID,
		Event_type = [event_type_name],
		Start_date = [start_date],
		End_date= [end_date],
		Estimated_budget = [estimated_budget],
		Total_expenditure = [total_expenditure],
		Status = [status],
		Estimated_attendance = [estimated_attendance],
		Actual_attendance = [actual_attendance],
		Venue_ID = V.[venue_ID],
		Capacity = [capacity],
		Venue_Address_line = V.[address_line],
		Venue_city = V.city,
		Venue_state = V.state ,
		Venue_country = V.country, 
		Venue_postal_code = V.postal_code,
		Attendee_ID = A.[attendee_ID],
		Attendee_Name = A.[first_name] + ' ' + A.last_name,
		Email = [email],
		Phone = [phone],
		Ticket_ID = [ticket_ID],
		Ticket_type = [ticket_type],
		Price = [price]
FROM 
	[dbo].[Event] E
JOIN 
	[dbo].[Event_Type] ET ON E.event_type_ID = ET.event_type_ID
JOIN 
	[dbo].[Venue] V ON V.venue_ID = E.venue_ID
JOIN 
	[dbo].[Event_Ticket_Assignment] ETA ON ETA.event_ID = E.event_ID
JOIN 
	[dbo].[Attendee] A ON A.attendee_ID = ETA.attendee_ID


-- Test Query
SELECT * 
FROM [dbo].[EventDetails]
ORDER BY Start_date, Event_ID, Event_type

/*
2. Can you provide a quick way for analysts to view which employees are assigned to specific events and their tasks?
Suggestion: A view combining Event_Employee, Employee, and Event will allow analysts to see employee assignments and the status of tasks for each event.
*/


CREATE VIEW EmployeePerEvent AS

SELECT Event_ID = EE.event_ID,
	Host_organization = O.name,
	Event_start_date = EV.start_date,
	Event_end_date = EV.end_date,
	Employee_ID = EM.employee_ID,
	Employee_name = EM.first_name + ' ' + EM.last_name,
	Job_title = EM.job_title,
	Task = EE.task,
	Task_start_date = EE.start_date,
	Task_deadline = EE.deadline,
	Task_completion_flag = EE.task_completed
FROM 
	[dbo].[Event_Employee] EE
JOIN 
	[dbo].[Event] EV ON EV.event_ID = EE.event_ID
JOIN 
	[dbo].[Employee] EM ON EE.employee_ID = EM.employee_ID
JOIN 
	[dbo].[Organization] O ON EV.organization_ID = O.organization_ID


-- Test Query
SELECT Event_ID, Employee_name, Task
FROM [dbo].[EmployeePerEvent]
WHERE Task_completion_flag = 0
ORDER BY 1;

/*
3. How can we help analysts identify events that are close to their venue capacity limits?
Suggestion: A view or function that calculates the percentage of venue capacity used by comparing actual attendance to venue capacity, highlighting events that are overbooked or nearing full capacity.
*/
CREATE VIEW VenueCapacityLimits AS

SELECT Event_ID = E.event_ID,
	Venue_ID = V.venue_ID,
	Attendance = E.actual_attendance, 
	Venue_Capacity = V.capacity,
	[Percent_of_Venue_capacity] = CAST(CAST(E.actual_attendance AS FLOAT) * 100/ CAST(V.capacity AS FLOAT) AS NUMERIC(36, 2))
FROM 
	[dbo].[Event] E
JOIN 
	[dbo].[Venue] V ON E.venue_ID = V.venue_ID


-- Test Query
SELECT * 
FROM 
	[dbo].[VenueCapacityLimits]
WHERE 
	[Percent_of_Venue_capacity] < 50
ORDER BY 
	Percent_of_Venue_capacity DESC;

/*
4. What’s the best way to track and view overdue tasks or tasks close to their deadlines for event employees?
Suggestion: A view or function that returns all tasks where the Deadline is past or within a specific timeframe (e.g., 7 days) and are marked as incomplete.
*/

CREATE VIEW DeadlineTracker AS

SELECT EventID = [event_ID]
      ,Employee_ID = [employee_ID]
      ,Task = [task]
      , Start_date = [start_date]
      ,Deadline = [deadline]
      , Days_to_deadline = DATEDIFF(DAY,[start_date], [deadline])
      , Status = CASE WHEN [task_completed] = 0 THEN 'Incomplete' ELSE 'Complete' END
FROM 
	[EventSphere Database].[dbo].[Event_Employee]

-- Test Query
SELECT *
FROM 
	[dbo].[DeadlineTracker]
WHERE
	[Days_to_deadline] = 7 AND [Status] = 'Incomplete';




-- 4. **************************** FUNCTIONS **********************************

/*
1. How many days left for the future events to take place?
Suggestion: An User Defined Function (UDF) that returns the current date and that can be used to calculate the days left for the eevnts to start from that day on.
*/

-- Creating the User Defined Function which returns the current date without timestamp
-- It will return the current date the users using this query

CREATE FUNCTION dbo.ufnCurrentDate()

RETURNS DATE

AS

BEGIN

	RETURN CAST(GETDATE() AS DATE)

END

-- Using the UDF in a query
-- Showing the events that fall between today and the last event date in the database


SELECT [event_ID],
       [start_date],
       Days_remained = DATEDIFF(DAY, Today,[start_date]) -- days left for the events to start
FROM
(
		SELECT *, 
			Today = dbo.ufnCurrentDate(), -- calling the UDF
			Last_event_date = MAX([start_date]) OVER() -- last event date in the database
		FROM [dbo].[Event]
) C
WHERE 
	[start_date] BETWEEN Today AND Last_event_date -- filtering events that haven't yet took place
ORDER BY 3;



/*
2. What’s the best way to compute the total revenue from tickets across all events per event type?
Suggestion: Use a table-valued function (TVF) to return the event_ID, host organization, total revenue from tickets along with its start and ebd date.
*/


CREATE FUNCTION dbo.ufn_EventsByEventType(@EventType NVARCHAR(15))

RETURNS TABLE

AS

RETURN
(
	SELECT
			Event_ID = E.[event_ID],
			Host = O.name,
			Total_revenue_from_tickets = SUM([price]),
			Event_start_date = [start_date],
			Event_end_date = [end_date]
	FROM 
		[dbo].[Event] E
	JOIN 
		[dbo].[Event_Type] ET ON ET.event_type_ID = E.event_type_ID
	JOIN 
		[dbo].[Organization] O ON E.organization_ID = O.organization_ID
	JOIN 
		[dbo].[Event_Ticket_Assignment] ETA ON ETA.event_ID = E.event_ID
	WHERE 
		LOWER([event_type_name]) = LOWER(@EventType)
	GROUP BY 
		E.[event_ID], O.name, E.event_type_ID, [end_date], [start_date]
)



-- Test Query
SELECT DISTINCT Host,
	Total_Revenue = SUM(Total_revenue_from_tickets) OVER(PARTITION BY Host),
	Overall_Revenue = SUM(Total_revenue_from_tickets) OVER(),
	[Percent of Overall_Revenue] = FORMAT(SUM(Total_revenue_from_tickets) OVER(PARTITION BY Host) / SUM(Total_revenue_from_tickets) OVER(), 'p')
FROM 
	ufn_EventsByEventType('Seminar')
ORDER BY 
	4 DESC;




-- 5. **************************** STORED PROCEDURES **********************************

/*
1. How do you provide a list of partners who contributed to events over a certain budget threshold?
Suggestion: A stored procedure that takes a budget threshold as input and returns a list of partners involved in events that meet or exceed the threshold.
*/

CREATE PROCEDURE dbo.PartnersReport(@Budget_Threshold MONEY) 

AS

BEGIN
		SELECT 
			Partner = P.[name], 
			Event_counts = COUNT(EP.[event_ID]),
			Total_estimated_budget = SUM([estimated_budget])
		FROM 
			[dbo].[Event_Partner] EP
		JOIN 
			[dbo].[Event] E ON EP.event_ID = E.event_ID
		JOIN 
			[dbo].[Partner] P ON P.partner_ID = EP.partner_ID
		GROUP BY 
			P.[name]
		HAVING 
			SUM([estimated_budget]) >= @Budget_Threshold -- filtering only those events whose total budget is greater than $80000
		ORDER BY 
			3 DESC;
END

-- Test Query
EXEC dbo.PartnersReport 200000;


/*
2. How can you automate the generation of reports on ticket sales performance (price, type, and sales per event)?
Suggestion: A stored procedure that summarizes ticket sales by event, including total sales, average ticket price, and most popular ticket types.
*/

CREATE PROCEDURE dbo.TopPerformingTickets (@TopN INT)

AS

BEGIN
		WITH Ticket_Summary AS
		(
		SELECT Event_ID = [event_ID], 
			Ticket_type = [ticket_type],
			Average_price = AVG([price]),
			Total_sales = SUM([price]),
			Tickets_sold = COUNT([ticket_ID]),
			Rank_by_avg_price = ROW_NUMBER() OVER(PARTITION BY [event_ID] ORDER BY AVG([price]) DESC),
			Rank_by_num_tickets = ROW_NUMBER() OVER(PARTITION BY [event_ID] ORDER BY COUNT([ticket_ID]) DESC)
		FROM [dbo].[Event_Ticket_Assignment]
		GROUP BY [event_ID],[ticket_type]
		) 
		SELECT Event_ID, 
			Ranks_by = 'Average Ticket Price',
			Ticket_type,
			Average_price,
			Tickets_sold,
			Total_sales
		FROM
		Ticket_Summary
		WHERE Rank_by_avg_price <= @TopN
		
		UNION ALL

		SELECT Event_ID, 
			Ranks_by = 'Number of Tickets Sold',
			Ticket_type,
			Average_price,
			Tickets_sold,
			Total_sales
		FROM
		Ticket_Summary
		WHERE Rank_by_num_tickets <= @TopN
		ORDER BY 1

END


-- Test Query
EXEC [dbo].[TopPerformingTickets] 3;


/*

3. How can you track event budget performance (Estimated vs Actual) across all events efficiently?
Suggestion: A stored procedure can be created to calculate the budget variance and flag any events where actual expenditure exceeds the estimated budget.

*/
CREATE PROCEDURE dbo.BudgetPerformance

AS

BEGIN 

		SELECT 
		Event_ID = [event_ID],
		Estimated_budget = [estimated_budget],
		Actual_expenditure = [total_expenditure],
		Budget_variance = [estimated_budget] - [total_expenditure],
		Overbudget_flag = CASE 
					WHEN
						[estimated_budget] < [total_expenditure] 
					THEN 1
					ELSE 0
				  END
		FROM
			[dbo].[Event]

END


-- Test Query
EXEC BudgetPerformance;
