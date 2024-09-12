# Event Management Database Design

## Introduction:

### Business Problem:

EventSphere Solutions is a mid-sized corporate event management company specializing in organizing internal conferences, product launches, training sessions, and corporate retreats for large enterprises. The company handles multiple events simultaneously, with each event having its own set of tasks, attendees, and specific requirements. To streamline operations and ensure all details are properly tracked, CorpEvent Solutions needs a centralized database to manage all aspects of their events.

### Objectives:

The primary objective of this event management database is to provide an efficient, user-friendly system for organizing, tracking, and managing corporate events for a mid to large-sized company. This database will centralize the management of event details, attendees, venues, and tasks, ensuring that the company can seamlessly plan and execute events while maintaining clear records and accountability.

### Target users:

1. Event Managers: Responsible for planning and overseeing the entire event, including scheduling, task assignment, and coordination with venues.
2. Administrative Staff: Assists in managing attendee registrations, communication, and logistics.
3. Venue Coordinators: Ensures that venues are properly booked, prepared, and equipped for the events.
4. Task Managers: Oversees specific event-related tasks such as catering, technical setup, or guest coordination.
5. Executives: May require access to high-level reports and summaries of event performance, attendance, and financials.

### Methodologies:

* Part 1 : Database Schema Design
* Part 2 : Implementing the database in SQL Server using Data Definition Language (DDL)
* Part 3 : Populate the database using Data Manipulation Language (DML)
* Part 4 : Optimize the database by creating index, views, stored procedures and user defined functions 
  
## Steps:

### Part 1 : Database Schema Design

**1. Entities:**
The entitities and relations between them will give us a **conceptual design** of the database.
  
  * Event: _event_id (pk), event_type_id (fk), organization_id (fk), venue_id (fk), budget_estimated, budget_actual, description, start_date, end_date, status, estimated_attendance, actual_attendance_
  
  * Venue: _venue_id (pk), capacity, address_line, city, state, zip_code, country_
  
  * Attendee: _attendee_id (pk), first_name, last_name, email, phone_
  
  * Ticket: _ticket_id (pk), event_id (fk), price, ticket_type_
  
  * Employee: _employee_id (pk), organization_id (fk), first_name, last_name, job_title, email_
  
  * Organization: _organization_id (pk), name, contact_person, phone, email_
  
  * Partner: _partner_id (pk), name, email, phone_
  
  * Event_Type: _event_type_id (pk), event_type_name_
  
  * Event_Partner Junction: _event_id (fk), partner_id (fk), role_
  
  * Ticket_Attendee Junction: _ticket_id (fk), attendee_id, purchase_date, expiry_date_
  
  * Event_Employee Junction: _event_id,  employee_id, task, start_date, deadline, task_completed_
  
**2. Relations:**

  * Event with Event_Type: _Many-to-One (M:1)_

    Each event is associated with a specific event type (e.g., conference, concert, workshop), but each event type can have multiple events. 
  
  * Event with Venue: _Many-to-One (M:1)_
  
    Each event takes place at a specific venue, but a venue can host multiple events. 
  
  * Event with Partner: _Many-to-Many (M:M)_
  
    An event can have multiple partners, and each partner can be associated with a multiple events.
  
  * Event with Organization: _Many-to-One (M:1)_
  
    Each event is hosted by one organization but one organization can host multiple events. 

  * Employee with Organization: _Many-to-One (M:1)_
  
    Each employee works for one organization but one organization can have multiple employees.
  
  * Event with Employee: _Many-to-Many (M:M)_
  
    Each event can have multiple employees assigned to it, and each employee can be associated with multiple events. 
  
  * Event with Ticket: _One-to-Many (1:M)_
  
    Each event can offer multiple types of tickets (e.g., VIP, General Admission). But one type of ticket can belong to only one event.
  
  * Ticket with Attendee: _Many-to-Many (M:M)_
  
    Each ticket can be purchased by multiple attendees and each attendee can have multiple tickets. 

**3. Database Normalization:**
All the tables are normalized upto 3rd normal form. A detailed description of the Normalization Process is available [here](https://docs.google.com/document/d/1BYkai8_n01Gea65rLc9-pHJJNjlRuXk4NA_NqB9BUo0/edit?usp=sharing).

**4. Entity Relation Diagram (ERD):**

This is the **logical design** of the database.
![EventSphere Event Management Database schema (1)](https://github.com/user-attachments/assets/f5df2a5c-f12c-446a-ae95-770985262b1f)


### Part 2 : Implementing the database in SQL Server using Data Definition Language (DDL)

**Creating the database and the tables:**

Using Data Definition Language (DDL), the EventSphere Database and its leaf tables are created. The script is available in the Script folder.

### Part 3 : Populating the database using Data Manipulation Language (DML)

Using Data Manipulation Language (DML), the EventSphere Database and its leaf tables are populated with synthetic data. The script is available in the Script folder. 

Most of the data is generated through Mockaroo, which enabled me to simulate the real world scenario by generating random demographhic data for employees, attendees, numbers in ranges etc faster. In some cases, demographic data has been inserted from another database such as in Employee and Attendee table.

Here in addition to simple INSERT and UPDATE Statements, complex calculations has been performed to generate more data points (in case of 'Event' table). These calculations are used to create records for budget, number of attendees and dates for different type of events (eg. virtual, in person, seminar, product lauch etc).

**3. Data Description:**

1. Event - 955 rows 12 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT PRIMARY KEY NOT NULL | Unique identifier of event |
|  event_Type_ID | INT NOT NULL | FOREIGN KEY to the Event_Type table |
|  organization_ID | INT NOT NULL | FOREIGN KEY to the Organization table |
|  venue_ID | INT NOT NULL | FOREIGN KEY to the Venue table |
|  start_date | DATE NOT NULL | Start date of the event |
|  end_date | DATE NULL | End date of the event |
|  budget_estimated | MONEY NULL | Estimated budget of the event |
|  budget_actual | MONEY NULL | Actual budget of the event |
|  description | TEXT NULL | Optional description / title of the event |
|  status| VARCHAR(20) NULL | 'Complete', 'Cancelled', 'Scheduled', 'Re-Scheduled' |
|  estimated_attendance | INT NULL | Estimated Number of attendees attended the event |
|  actual_attendance | INT NULL | Actual Number of attendees attending the event |
  
2. Venue - 457 rows 8 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  venue_ID | INT PRIMARY KEY NOT NULL | Unique identifier of venue |
|  capacity | INT NOT NULL | Capacity of the venue (number of people they can accomodate) |
|  address_line | VARCHAR(60) NULL | Street Address of the venue |
|  city | VARCHAR(30) NOT NULL | City |
|  state | VARCHAR(30) NOT NULL | State |
|  postal_code | VARCHAR(15) NOT NULL | Postal Code |
|  country | VARCHAR(30) NOT NULL | Country |
|  OnlineFlag | BIT | 0 = Offline Event, 1 = Online Event |
  
3. Attendee - 19,972 rows 5 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
| attendee_ID | INT PRIMARY KEY NOT NULL | Unique identifier of attendee |
| first_name  | VARCHAR(50) NOT NULL | First Name |
| last_name | VARCHAR(50) NOT NULL | Last Name |
| email| VARCHAR(50) NOT NULL | Email |
| phone | VARCHAR(25) NULL | Phone number |

4. Event_Tickets* - 7,640 rows 4 Columns

[*Note: This is a special table which gives all the possible combinations of events and ticket types with their associated price. This table has been used later to update ticket price for each attendee and events in Event_Ticket_Assignment table.]

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table|
|  ticket_ID | VARCHAR(32) NULL | Unique identifier of ticket |
|  price | MONEY NOT NULL | Price of the ticket ($) |
|  ticket_type| VARCHAR(50) NOT NULL | Type of the ticket ('Early-Bird','Student','All-Access','Virtual-Ticket','Group-Ticket','Day-Pass','General-Admission',VIP') |

5. Employee - 45,017 rows 6 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  employee_ID | INT PRIMARY KEY NOT NULL | Unique identifier of employee |
|  organization_ID | INT NOT NULL | FOREIGN KEY to the Organization table |
|  first_name | VARCHAR(50) NOT NULL | First Name |
|  last_name | VARCHAR(50) NOT NULL | Last Name |
|  job_title | VARCHAR(50) NOT NULL | Job title |
|  email | VARCHAR(50) NOT NULL | Email |

6. Organization - 154 rows 5 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  organization_ID | INT PRIMARY KEY NOT NULL | Unique identifier of organization |
|  name | VARCHAR(50) NOT NULL | Name of the organization |
|  contact_person | VARCHAR(50) | Contact Person for that organization |
|  email | VARCHAR(50) NOT NULL | Email |
|  phone | VARCHAR(25) NULL | Phone number |

7. Partner - 183 rows 5 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  partner_ID | INT PRIMARY KEY  NOT NULL | Unique idenitfier of Partner |
|  name | VARCHAR(50) NOT NULL | Name of the Partner |
|  email | VARCHAR(50) NOT NULL | Email |
|  phone | VARCHAR(25) NULL | Phone number |

8. Event_Type - 10 rows 2 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_type_ID | INT PRIMARY KEY NOT NULL | Unique Identifier of event_type table |
|  event_type_name | VARCHAR(50) NULL | Types of events (Virtual, In-Person, Hybrid, Conference, Workshop, Webinar, Seminar, Trade Show, Networking Event, Product Launch) |

9. Event_Partner - 1,315 rows 3 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table |
|  partner_ID | INT NOT NULL | FOREIGN KEY to the Partner table |
|  role | VARCHAR(50) NOT NULL | Role of the Partner |

10. Event_Employee - 37,107 rows 6 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table |
|  employee_ID | INT NOT NULL | FOREIGN KEY to the Employee table |
|  task | VARCHAR(120) NULL | Name of the Task |
|  start_date | DATE NULL | Start date of the task |
|  deadline | DATE NULL | Deadline for the task |
|  task_completed | BIT NULL | 0 = Not Completed, 1 = Completed |

11. Event_Ticket_Assignment - 4,63,720 rows 7 columns

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  ticket_ID | GUID PRIMARY KEY | Unique Identifier of the Ticket table |
|  attendee_ID | INT NOT NULL | FOREIGN KEY to the Attendee table |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table |
|  purchase_date | DATE NULL | Date of purchasing the ticket |
|  expiry_date | DATE NULL | Expiry date of the ticket |
|  price | MONEY NULL | Price of the ticket ($) |
|  ticket_type | VARCHAR(50) NULL | Type of the ticket ('Early-Bird','Student','All-Access','Virtual-Ticket','Group-Ticket','Day-Pass','General-Admission',VIP') |

### Part 4 : Optimizing the database by creating index, views, stored procedures and user defined functions 
  

## Resources:

* [An Event Management Data Model](https://vertabelo.com/blog/how-to-plan-and-run-events-an-event-management-data-model/)
* [How to Design a Database for Event Management](https://www.geeksforgeeks.org/how-to-design-a-database-for-event-management/)
* [What is a Database Schema | Lucidchart](https://www.lucidchart.com/pages/database-diagram/database-schema)
* [Building an Event Management System: Designing the Blueprint, Crafting the Schema, and Executing with SQL](https://medium.com/@tatibaevmurod/building-an-event-management-system-designing-the-blueprint-crafting-the-schema-and-executing-43ad2e45568e)

## Limitations:

1. One important limitation of this database is that for some tables like attendee, event, or tickets its not properly scaled.
2. There might appear some discrepency in record count when applying aggregate functions or joins.
3. There is discrepency in actual_attendance from Event table and the count of attendees/tickets from the Ticket_Attendee table which should return the same number of attendees but it doesn't. 
