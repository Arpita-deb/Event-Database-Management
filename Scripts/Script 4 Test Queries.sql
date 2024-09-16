/* EventSphere Event Management Database Schema

Script 2.4: Test Queries
Created by: Arpita Deb
Dated: 2024-09-14 11:52:12.593
About: DQL Commands to query the tables

*/

-- Initiating the database
USE [EventSphere Database];

/*
1. What are the upcoming events scheduled for the next month?

Target User: Event Managers, Executives
Objective: Provide a list of events scheduled within a certain date 
range to help in tracking and preparing for future events.

*/

SELECT [event_ID],
	[start_date], 
	[status]
FROM 
	[dbo].[Event]
WHERE 
	YEAR([start_date]) = 2024 -- Current year = 2024
	AND MONTH([start_date]) = 10;-- Next Month = October

/*
2. Which events are approaching or exceeding the estimated budget?

Target User: Event Managers, Executives
Objective: Identify events whose budget and expenditure ratio is higher than or equal to 90% or 0.9.
Track budget performance by comparing estimated and actual expenditures for each event.
*/

SELECT DISTINCT [Event_ID], 
	[Estimated_budget], 
	[Total_expenditure],
	[Budget_to_Expenditure_Ratio] = CAST([Total_expenditure]/[Estimated_budget] AS NUMERIC(36, 2))  
FROM 
	[dbo].[EventDetails]
WHERE 
	CAST([Total_expenditure]/[Estimated_budget] AS NUMERIC(36, 2)) >= 0.9
ORDER BY 
	4 DESC;

/*
3. Which tasks assigned to employees are overdue or nearing their deadlines?

Target User: Task Managers, Administrative Staff
Objective: Ensure timely completion of tasks by identifying tasks that are behind schedule.
*/

WITH Upcoming_Events AS -- Events happening in the final quarter of 2024 (from Sep to Dec)
(
	SELECT 
		*
	FROM 
		[dbo].[DeadlineTracker]
	WHERE 
		[Deadline] >= '2024-09-01'
)
SELECT 
	[EventID], [Task]
FROM 
	Upcoming_Events
WHERE 
	[Days_to_deadline] <= 7 AND [Status] = 'Incomplete'


/*
4. What is the total number of attendees registered for each event, and how does it compare to venue capacity?

Target User: Venue Coordinators, Event Managers
Objective: Check event attendance against venue capacity to avoid overcrowding or underutilization of space.
*/


WITH Registered_Attendee AS
(
	SELECT Event_ID = [event_ID]
		,Registered_Attendees = COUNT([attendee_ID])
	FROM 
		[dbo].[Event_Ticket_Assignment]
	GROUP BY 
		[event_ID]
),
Venue_Capacity AS
(
	SELECT [Event_ID],
		[Venue_Capacity]
	FROM 
		[dbo].[VenueCapacityLimits] -- using the [VenueCapacityLimits] View
)
SELECT RA.Event_ID, 
	RA.Registered_Attendees, 
	VC.[Venue_Capacity],
	Difference = VC.[Venue_Capacity] - RA.Registered_Attendees -- negative difference shows attendees exceeded the venue capacity limit, positive difference shows otherwise
FROM 
	Registered_Attendee RA 
JOIN 
	Venue_Capacity VC ON RA.Event_ID = VC.[Event_ID]


/*

5. Which events are hosted by a specific partner organization?

Target User: Event Managers, Executives

Objective: Retrieve a list of events that are co-hosted or sponsored by specific partners, 
useful for partner relationship management.

*/

SELECT Event_ID = E.event_ID, 
	Partner_Name = P.name, 
	Partner_Role = EP.role
FROM 
	[dbo].[Event_Partner] EP
JOIN 
	[dbo].[Event] E ON EP.event_ID = E.event_ID
JOIN 
	Partner P ON EP.partner_ID = P.partner_ID
WHERE 
	EP.role = 'Sponsor';


/*
6. What are the tasks assigned to each employee for a given event, and their current completion status?

Target User: Task Managers, Event Managers
Objective: Monitor task assignment and completion to ensure smooth event execution.
*/

SELECT T.[EventID],
 	Employee_name = E.first_name + ' ' + E.last_name,
	[Task],
	[Status]
FROM 
	[dbo].[DeadlineTracker] T 
JOIN 
	[dbo].[Employee] E ON T.[Employee_ID] = E.employee_ID
ORDER BY 1;



/*
7. What is the overall revenue generated from ticket sales for an event?

Target User: Event Managers, Executives
Objective: Summarize ticket sales revenue to evaluate financial performance for each event.

*/

SELECT [Event_ID],
	Revenue_from_Tickets = SUM([Price])
FROM 
	[dbo].[EventDetails]
GROUP BY 
	[Event_ID]
ORDER BY 
	2 DESC;


/*
8. Which employees have been assigned tasks across multiple events, and what are their roles?

Target User: Task Managers, Event Managers
Objective: Track employee workload and ensure even task distribution across events.
*/

SELECT DISTINCT [Employee_ID],
	[Employee_name],
	Event_counts = COUNT([Event_ID]) OVER(PARTITION BY [Employee_ID],[Employee_name]),
	Tasks = STUFF(
					(
						SELECT ', ' + [Task]
						FROM [dbo].[EmployeePerEvent] A
						WHERE A.[employee_ID]= B.Employee_ID
						FOR XML PATH('')
					),
			1,1,'')
FROM 
	[dbo].[EmployeePerEvent] B;


/*
9. What is the average ticket price for each event, broken down by ticket type?

Target User: Administrative Staff, Event Managers
Objective: Analyze pricing strategy by determining the average ticket price for each event and ticket category.
*/

SELECT [event_ID],
	[ticket_type],
	Avg_Ticket_Price = AVG([price])
FROM 
	[dbo].[Event_Ticket_Assignment]
GROUP BY  
	[event_ID], [ticket_type]
ORDER BY 
	1,2;


/*
10. Which venues are being utilized for upcoming events, and are there any venues being overbooked?

Target User: Venue Coordinators, Event Managers
Objective: Monitor venue utilization to prevent double bookings or overbooking of venues.
*/

WITH Upcoming_Events AS -- Events happening in the final quarter of 2024 (from Sep to Dec)
(
	SELECT 
		*
	FROM 
		[dbo].[EventDetails]
	WHERE 
		[Start_date] >= '2024-09-01'
)
SELECT DISTINCT [Event_ID],
		[Venue_ID],
		[Venue_Address_line],
		[Venue_city],[Venue_state],
		[Venue_country],
		[Venue_postal_code]
FROM 
	Upcoming_Events;


/*
11. How many events have been canceled, postponed, or rescheduled in the last year?

Target User: Executives, Event Managers

Objective: Track event cancellations or postponements to assess operational disruptions or changes
in planning.

*/

SELECT Status = [status], 
	Event_Count = COUNT(*)
FROM 
	[dbo].[Event]
WHERE 
	YEAR([start_date]) = 2023
GROUP BY 
	[status];


/*
12. Which events have the highest actual attendance compared to estimated attendance, and how does that impact the event’s success?

Target User: Event Managers, Executives
Objective: Analyze attendance figures and compare them to initial estimates to evaluate the success of each event.
*/

SELECT [event_ID],
	[estimated_attendance],
	[actual_attendance],
	surplus_attendee = [actual_attendance] - [estimated_attendance]
FROM 
	[dbo].[Event]
WHERE 
	[actual_attendance]>[estimated_attendance]
ORDER BY 
	4 DESC;
