/* EventSphere Event Management Database Schema

Script 2.10: Populating the Event_Tickets Junction Table
Created by: Arpita Deb
Dated: 2024-09-08 12:55:09.127
About: DML Commands to insert values in the Event_Tickets Junction Table

*/

-- Initiating the database
USE [EventSphere Database];

-- 10. Event_Ticket junction table
-- The ticket_id will be a combination of Event ID and the Ticket type (like '1001 - VIP', '1983 - Student' etc)
-- To do that I need to create a temp table to hold all the ticket types and their respective prices and then concatenate these values with the Event_ID column which I did with the code below.

-- Step 1: Temp table holding different kinds of ticket types

CREATE TABLE #Ticket_Type
(
ticket_type_ID INT identity(1,1),
ticket_type VARCHAR(50),
price MONEY
)

INSERT INTO #Ticket_Type(ticket_type, price)
VALUES ('General-Admission', 35.69),
('VIP', 215.80),
('Early-Bird', 26.70),
('Student', 15.15),
('All-Access', 225.33),
('Day-Pass',50.35),
('Group-Ticket', 90.00),
('Virtual-Ticket', 17.50)

-- Step 2: Inserting the values into the junction tables 
-- The CROSS JOIN gives all the combinations of tickets for all kinds of tickets

INSERT INTO Event_Tickets (event_ID, ticket_ID, ticket_type, price)
SELECT 
    e.event_ID, 
    CAST(e.event_ID AS VARCHAR) + ' - ' + t.ticket_type,
	t.ticket_type,
	t.Price
FROM 
    Event e
CROSS JOIN 
    #Ticket_Type t;

-- Step 3: Dropping the temp table

DROP TABLE #Ticket_Type


-- One drawback of this table is that for all the events the total sum of ticket price remains same.
-- Therefore, I updated the price column by multiplying it with a random value between 0 and 1 to add variability in the dataset

UPDATE Event_Tickets
SET price = (SELECT ROUND([price] * RAND(CHECKSUM(NEWID())), 2)) 
