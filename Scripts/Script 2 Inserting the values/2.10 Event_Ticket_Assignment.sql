/* EventSphere Event Management Database Schema

Script 2.10: Populating the Event_Ticket_Assignment Table 
Created by: Arpita Deb
Dated: 2024-09-08 12:55:09.127
About: DML Commands to insert values in the Event_Ticket_Assignment Table

*/

-- Initiating the database
USE [EventSphere Database];


/* Inserting the values

**************************************

NOTE: I accidentally deleted the actual INSERT statement for inserting ticket_id, attendee_id, event_id where there might have been some criteria 
which limited the number of records from 19 billion to about 4 Million. However, the later part of the script works correctly and needs no changes.

**************************************
*/

INSERT INTO Event_Ticket_Assignment (ticket_id, attendee_id, event_id)
SELECT TOP 15000000
    NEWID(),  -- Generate a unique GUID for ticket_id
    A.attendee_id,  -- Randomly selected attendee_id
    E.event_id -- Event ID to which the attendee is assigned
FROM 
    (SELECT attendee_id 
     FROM Attendee 
     ) AS A  -- Randomly order attendees
CROSS JOIN 
    (SELECT event_id, event_type_id 
     FROM Event) AS E  -- All event IDs



-- Setting the expiry date of the ticket to the end_date of the event (in case the event lasts longer than one day), otherwise set it to the start_date

UPDATE [dbo].[Event_Ticket_Assignment] 
SET expiry_date = COALESCE(B.end_date, B.start_date)
FROM Event_Ticket_Assignment A
	JOIN Event B
		ON A.event_ID = B.Event_ID


-- Updating the ticket_type from Event_ticket table

WITH CTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RowNum,
        COUNT(*) OVER () AS TotalRows
    FROM 
        Event_Ticket_Assignment
)
UPDATE CTE
SET [ticket_type]= CASE
						WHEN RowNum <= (TotalRows * 10 / 100) THEN ('Early-Bird')
						WHEN RowNum <= (TotalRows * 30 / 100) THEN ('Student')
						WHEN RowNum <= (TotalRows * 40 / 100) THEN ('All-Access')
						WHEN RowNum <= (TotalRows * 50 / 100) THEN ('Virtual-Ticket')
						WHEN RowNum <= (TotalRows * 60 / 100) THEN ('Group-Ticket')
						WHEN RowNum <= (TotalRows * 70 / 100) THEN ('Day-Pass')
						WHEN RowNum <= (TotalRows * 85 / 100) THEN ('VIP')
						ELSE 'General-Admission'
					END;


-- Updating the ticket price 
UPDATE [dbo].[Event_Ticket_Assignment]
SET Price = ET.[price]
FROM [dbo].[Event_Tickets] ET
JOIN [dbo].[Event_Ticket_Assignment] ETA ON ETA.event_id = ET.event_ID AND ETA.ticket_type = ET.ticket_type


SELECT * FROM [dbo].[Event_Ticket_Assignment]


-- In the event table, we have some events that's been cancelled. So naturally no tickets will be sold for them. So I've removed those events from the table.

DELETE
FROM [dbo].[Event_Ticket_Assignment] 
WHERE event_ID IN (SELECT event_ID FROM event WHERE status = 'Cancelled')

