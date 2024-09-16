/* EventSphere Event Management Database Schema

Script 2.4: Populating the Attendee Table
Created by: Arpita Deb
Dated: 2024-09-08 12:55:09.127
About: DML Commands to insert values in the Attendee Table

*/

-- Initiating the database
USE [EventSphere Database];



-- 4.Attendee

-- Inserting first_name, last_name, email and phone number from AdventureWorks Database Tables (Person,EmailAddress & PersonPhone) into the Attendee table

INSERT INTO [EventSphere Database].dbo.Attendee
(   first_name
    ,last_name
    ,email
    ,phone
)
SELECT  FirstName AS first_name,
	LastName AS last_name,
	EmailAddress AS email,
	PhoneNumber AS phone
FROM [AdventureWorks2022].[Person].[Person] P 
JOIN [AdventureWorks2022].[Person].[EmailAddress] E ON P.[BusinessEntityID] = E.[BusinessEntityID]
JOIN [AdventureWorks2022].[Person].[PersonPhone] PH ON P.BusinessEntityID = PH.BusinessEntityID
;

-- Setting the phone Null for a few random attendees

UPDATE [dbo].[Attendee]
SET [phone] = NULL
WHERE [attendee_ID] IN (12333, 12345, 17863, 12321, 11198, 235, 18735, 3456, 987, 998, 890, 456, 34, 567, 54, 876, 12427, 7648, 11900, 10000, 12)


SELECT * FROM [dbo].[Attendee]
