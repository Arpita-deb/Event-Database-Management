/* EventSphere Event Management Database Schema

Script 2.1: Populating the Event_Type Table
Created by: Arpita Deb
Dated: 2024-09-08 12:55:09.127
About: DML Commands to insert values in the Event_Type Table

*/

-- Initiating the database
USE [EventSphere Database];

-- 1. Event_Type

INSERT INTO 
	[dbo].[Event_Type]([event_type_name]) 
VALUES 
	('Virtual'),('In-Person'),('Hybrid'),('Conference'), ('Workshop'),('Webinar'),('Seminar'),('Trade Show'),('Networking Event'),('Product Launch')

SELECT * FROM [dbo].[Event_Type];
