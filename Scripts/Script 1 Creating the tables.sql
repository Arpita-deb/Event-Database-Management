/* EventSphere Event Management Database Schema

Script 1: Database and Table creation 
Created by: Arpita Deb
Dated: 2024-09-08 00:16:20.873
About: DDL Commands to create the EventSphere Event Management Database and 11 Tables with respective constraints

*/

-- Creating the database
DROP DATABASE [EventSphere Database];
CREATE DATABASE [EventSphere Database];


-- Initiating the database
USE [EventSphere Database];


-- Table 1:Event

DROP TABLE Event;

CREATE TABLE Event 
(
  event_ID INT PRIMARY KEY IDENTITY(1,1),
  event_Type_ID INT FOREIGN KEY REFERENCES Event_Type(event_Type_ID) NOT NULL,
  organization_ID INT FOREIGN KEY REFERENCES Organization(organization_ID) NOT NULL,
  venue_ID INT FOREIGN KEY REFERENCES Venue(venue_ID) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  budget_estimated MONEY NULL,
  total_expenditure MONEY NULL,
  description TEXT NULL,
  status VARCHAR(20) NULL,
  estimated_attendance INT NULL,
  actual_attendance INT NULL
);


-- Table 2: Venue

DROP TABLE Venue;

CREATE TABLE Venue
(
  venue_ID INT PRIMARY KEY IDENTITY(300,1) NOT NULL,
  capacity INT NOT NULL, 
  address_line VARCHAR(60) NULL,
  city VARCHAR(30) NULL, 
  state VARCHAR(30) NULL, 
  postal_code VARCHAR(15) NULL, 
  country VARCHAR(30) NULL
);

ALTER TABLE Venue
ADD OnlineFlag BIT;

-- Table 3: Attendee

DROP TABLE Attendee;

CREATE TABLE Attendee 
(
  attendee_ID  INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  first_name  VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  phone VARCHAR(25) NULL
);

-- Table 4: Event_Tickets

DROP TABLE Event_Tickets; 


CREATE TABLE Event_Tickets 
(
event_ID INT NOT NULL,
ticket_ID VARCHAR(32) NOT NULL,
ticket_type VARCHAR(50),
price MONEY
)

ALTER TABLE Event_Tickets
ADD CONSTRAINT PK_ticket_ID
PRIMARY KEY(ticket_ID);



-- Table 5: Employee 

DROP TABLE Employee ;

CREATE TABLE Employee 
(
  employee_ID  INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
  organization_ID  INT FOREIGN KEY REFERENCES Organization(organization_ID) NOT NULL,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  job_title VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL
);

-- Table 6: Organization 

DROP TABLE Organization; 

CREATE TABLE Organization 
(
  organization_ID INT PRIMARY KEY IDENTITY(200,1) NOT NULL,
  name VARCHAR(50) NOT NULL,
  contact_person VARCHAR(50) ,
  email VARCHAR(50) NOT NULL,
  phone VARCHAR(25) NULL
);

-- Table 7: Partner 

DROP TABLE Partner;

CREATE TABLE Partner 
(
  partner_ID INT PRIMARY KEY IDENTITY(500,1) NOT NULL,
  name VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  phone VARCHAR(25) NULL
);

-- Table 8: Event_Type

CREATE TABLE Event_Type 
(
  event_type_ID INT PRIMARY KEY IDENTITY(200,1) NOT NULL,
  event_type_name VARCHAR(50) NULL,
);


-- Table 9: Event_Partner Junction table: one event many partners, one partner many events

DROP TABLE Event_Partner;

CREATE TABLE Event_Partner
(
  event_ID INT FOREIGN KEY REFERENCES Event(Event_ID) NOT NULL,
  partner_ID INT FOREIGN KEY REFERENCES Partner(Partner_ID) NOT NULL,
  role VARCHAR(50) NOT NULL
);


-- Table 10: Event_Employee Junction table: one employee many events, one event many employees

DROP TABLE Event_Employee; 

CREATE TABLE Event_Employee 
(
  event_ID INT FOREIGN KEY REFERENCES Event(Event_ID) NOT NULL,
  employee_ID INT FOREIGN KEY REFERENCES Employee(Employee_ID) NOT NULL,
  task VARCHAR(120) NULL,
  start_date DATE NULL,
  deadline DATE NULL,
  task_completed BIT NULL
);

-- Table 11: Event_Ticket_Assignment junction table: one attendee many events, one event many attendees

DROP TABLE Event_Ticket_Assignment;

CREATE TABLE Event_Ticket_Assignment 
(
    ticket_id UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY, -- GUID as the primary key
    attendee_id INT FOREIGN KEY REFERENCES Attendee(attendee_id) ,                               
    event_id INT FOREIGN KEY REFERENCES Event(event_id),                                
    purchase_date DATETIME NULL,                          
    expiry_date DATETIME NULL,                             
    Price MONEY NULL,
	ticket_type VARCHAR(50) NULL
);
