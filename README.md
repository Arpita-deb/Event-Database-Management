# Event Management Database Design

![Purple Minimalist Brush Personal LinkedIn Banner](https://github.com/user-attachments/assets/a58137a8-5e4d-45d3-a631-a2c563a58a22)

## Introduction:

### About the company:

EventSphere Solutions is a mid-sized corporate event management company specializing in organizing internal conferences, product launches, training sessions, and corporate retreats for large enterprises. The company handles multiple events simultaneously, with each event having its own set of tasks, attendees, and specific requirements.

### Business Problem:

To streamline operations and ensure all details are properly tracked, CorpEvent Solutions needs a centralized database to manage all aspects of their events.

### Objectives:

The primary objective of this event management database is to provide an efficient, user-friendly system for organizing, tracking, and managing corporate events for a mid-sized event management company. This database will centralize the management of event details, attendees, venues, and tasks, ensuring that the company can seamlessly plan and execute events while maintaining clear records and accountability.

### Target users:

1. Event Managers: Responsible for planning and overseeing the entire event, including scheduling, task assignment, and coordination with venues.
2. Administrative Staff: Assists in managing attendee registrations, communication, and logistics.
3. Venue Coordinators: Ensures that venues are properly booked, prepared, and equipped for the events.
4. Task Managers: Oversees specific event-related tasks such as catering, technical setup, or guest coordination.
5. Executives: May require access to high-level reports and summaries of event performance, attendance, and financials.

### Procedure:

* Part 1 : Database Schema Design
* Part 2 : Implementing the database in SQL Server using Data Definition Language (DDL)
* Part 3 : Populate the database using Data Manipulation Language (DML)
* Part 4 : Optimize the database by creating index, views, stored procedures and user defined functions 
  
## Steps:

### Part 1 : Database Schema Design

**1. Entities:**

The entitities and relations between them will give us a **conceptual design** of the database.
  
  * Event: _event_id (pk), event_type_id (fk), organization_id (fk), venue_id (fk), estimated_budget, total_expenditure, description, start_date, end_date, status, estimated_attendance, actual_attendance_
  
  * Venue: _venue_id (pk), capacity, address_line, city, state, postal_code, country, online_flag_
  
  * Attendee: _attendee_id (pk), first_name, last_name, email, phone_
  
  * Ticket: _ticket_id (pk), event_id (fk), price, ticket_type_
  
  * Employee: _employee_id (pk), organization_id (fk), first_name, last_name, job_title, email_
  
  * Organization: _organization_id (pk), name, contact_person, phone, email_
  
  * Partner: _partner_id (pk), name, email, phone_
  
  * Event_Type: _event_type_id (pk), event_type_name_
  
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
![EventSphere Event Management Database schema](https://github.com/user-attachments/assets/968cc36b-a49c-49f3-9820-fb7c75246be2)


### Part 2 : Implementing the database in SQL Server using Data Definition Language (DDL)

**Creating the database and the tables:**

Using Data Definition Language (DDL), the EventSphere Database and its leaf tables are created. The script is available in the Script folder.


### Part 3 : Populating the database using Data Manipulation Language (DML)

Using Data Manipulation Language (DML), the EventSphere Database and its leaf tables are populated with synthetic data. The script is available in the Script folder. 

Most of the data is generated through Mockaroo, which enabled me to simulate the real world scenario by generating random demographhic data for employees, attendees, numbers in ranges etc faster. In some cases, demographic data has been inserted from another database such as in Employee and Attendee table.

Here in addition to simple INSERT and UPDATE Statements, complex calculations has been performed to generate more data points (in case of 'Event' table). These calculations are used to create records for budget, number of attendees and dates for different type of events (eg. virtual, in person, seminar, product lauch etc).


#### Data Description:

**1. Event Table**

  * Size: 955 rows, 12 columns

  * Purpose: The Event table stores all the essential details about each event, such as the hosting organization, event date, type, venue, budget, attendee count, and current status.

  * Importance: This table is crucial for analyzing trends, like which types of events are most common, which organizations host the most events, and how event budgets are managed. The data helps in planning future events, controlling costs, and understanding venue utilization. By tracking a decade's worth of data (2010-2024), companies can make data-driven decisions to improve event planning and execution.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT PRIMARY KEY NOT NULL | Unique identifier of event |
|  event_Type_ID | INT NOT NULL | FOREIGN KEY to the Event_Type table |
|  organization_ID | INT NOT NULL | FOREIGN KEY to the Organization table |
|  venue_ID | INT NOT NULL | FOREIGN KEY to the Venue table |
|  start_date | DATE NOT NULL | Start date of the event |
|  end_date | DATE NULL | End date of the event |
|  estimated_budget | MONEY NULL | Estimated budget of the event |
|  total_expenditure | MONEY NULL | Actual budget of the event |
|  description | TEXT NULL | Optional description / title of the event |
|  status | VARCHAR(20) NULL | 'Complete', 'Cancelled', 'Scheduled', 'Re-Scheduled' |
|  estimated_attendance | INT NULL | Estimated Number of attendees attended the event |
|  actual_attendance | INT NULL | Actual Number of attendees attending the event |

**2. Venue** 

  * Size: 458 rows, 8 columns

  * Purpose: The Venue table records details about each venue, including its capacity, geographic location, and whether it's a physical location or a virtual space. There is a special venue id 757 is associated with Virtual Events. It doesn't have any geographic location but its comparatively high capacity suggests that a large number of people can attend an online event (e.g. Webinar or a Virtual Event).

  * Importance: This table helps organizations choose the right venue based on event type and expected attendance. It also allows for efficient management of venue logistics across different countries. Knowing the capacity and location of venues helps in planning events that match the size and location preferences of the attendees, including virtual events.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  venue_ID | INT PRIMARY KEY NOT NULL | Unique identifier of venue |
|  capacity | INT NOT NULL | Capacity of the venue (number of people they can accomodate) |
|  address_line | VARCHAR(60) NULL | Street Address of the venue |
|  city | VARCHAR(30) NULL | City |
|  state | VARCHAR(30) NULL | State |
|  postal_code | VARCHAR(15) NULL | Postal Code |
|  country | VARCHAR(30) NULL | Country |
|  online_flag | BIT | 0 = Offline Event, 1 = Online Event |
  
**3. Attendee**

  * Size: 19,972 rows, 5 columns

  * Purpose: The Attendee table contains information on people who have attended events, including their names and contact details.

  * Importance: This table is vital for keeping in touch with past attendees, sending invitations for future events, and understanding the demographic makeup of event participants. By maintaining accurate records of attendees, companies can build relationships with clients and prospects, improving event outreach and engagement.

| Column | Datatype | Description |
| :--- | :--- | :--- |
| attendee_ID | INT PRIMARY KEY NOT NULL | Unique identifier of attendee |
| first_name  | VARCHAR(50) NOT NULL | First Name |
| last_name | VARCHAR(50) NOT NULL | Last Name |
| email| VARCHAR(50) NOT NULL | Email |
| phone | VARCHAR(25) NULL | Phone number |

**4. Employee** 

* Size: 647 rows, 6 columns

* Purpose: The Employee table tracks employees who work for the organizations hosting the events, including their names, job titles, and contact information.

* Importance: This table ensures that the right employees are assigned to the right events and tasks, improving the efficiency and success of event management. By having a comprehensive record of employees, organizations can easily manage staff assignments for events, ensuring that all necessary roles are filled.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  employee_ID | INT PRIMARY KEY NOT NULL | Unique identifier of employee |
|  organization_ID | INT NOT NULL | FOREIGN KEY to the Organization table |
|  first_name | VARCHAR(50) NOT NULL | First Name |
|  last_name | VARCHAR(50) NOT NULL | Last Name |
|  job_title | VARCHAR(50) NOT NULL | Job title |
|  email | VARCHAR(50) NOT NULL | Email |

**5. Organization**

  * Size: 154 rows, 5 columns
  
  * Purpose: The Organization table lists all organizations that host events, along with their contact details.
  
  * Importance: This table is essential for managing which organizations are involved in hosting events and ensuring that each event is tied to a single host organization. This centralized data helps in coordinating event logistics and communication with hosting organizations, simplifying event planning.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  organization_ID | INT PRIMARY KEY NOT NULL | Unique identifier of organization |
|  name | VARCHAR(50) NOT NULL | Name of the organization |
|  contact_person | VARCHAR(50) | Contact Person for that organization |
|  email | VARCHAR(50) NOT NULL | Email |
|  phone | VARCHAR(25) NULL | Phone number |

**6. Partner**

*  Size: 183 rows, 5 columns

*  Purpose: The Partner table records details about partners that provide services for events, such as sponsors, vendors, and marketing partners.

*  Importance: This table is crucial for managing relationships with external partners who contribute to the success of events but are not the primary hosts. By tracking partner involvement, companies can ensure all aspects of an event are covered, from sponsorships to catering, enhancing overall event quality.


| Column | Datatype | Description |
| :--- | :--- | :--- |
|  partner_ID | INT PRIMARY KEY  NOT NULL | Unique identifier of Partner |
|  name | VARCHAR(50) NOT NULL | Name of the Partner |
|  email | VARCHAR(50) NOT NULL | Email |
|  phone | VARCHAR(25) NULL | Phone number |

**7. Event_Type**

 * Size: 10 rows, 2 columns

 * Purpose: The Event_Type table categorizes events into types, such as Virtual, In-Person, Conference, Workshop, etc.
 
 * Importance: Understanding the type of event is key to planning the budget, duration, and expected attendance. This classification helps companies tailor their planning and resources to the specific needs of each event type, improving efficiency and effectiveness.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_type_ID | INT PRIMARY KEY NOT NULL | Unique Identifier of event_type table |
|  event_type_name | VARCHAR(50) NULL | Types of events  |

**8. Event_Partner**

*  Size: 1,315 rows, 3 columns

* Purpose: The Event_Partner table links events with their respective partners, including the role each partner plays (e.g. Marketing Partner, Vendor, Sponsor, Catering Partner, Technology Partner etc).

* Importance: This junction table is essential for managing the many-to-many relationships between events and partners, ensuring that all roles are clearly defined and tracked. By keeping track of partner roles, companies can ensure that all necessary services are provided, contributing to the smooth execution of events.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table |
|  partner_ID | INT NOT NULL | FOREIGN KEY to the Partner table |
|  role | VARCHAR(50) NOT NULL | Role of the Partner |

**9. Event_Employee**

  * Size: 37,107 rows, 6 columns

  * Purpose: The Event_Employee table links employees to the events they work on, including their assigned tasks and task completion status.
  
  * Importance: This table is crucial for assigning and tracking employee responsibilities (e.g., Venue setup, Social media promotion, IT support, Security arrangements, Ticketing issues etc), ensuring that all event tasks are completed on time. By monitoring employee involvement, companies can ensure that events are well-staffed and that all tasks are managed effectively.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table |
|  employee_ID | INT NOT NULL | FOREIGN KEY to the Employee table |
|  task | VARCHAR(120) NULL | Name of the Task |
|  start_date | DATE NULL | Start date of the task |
|  deadline | DATE NULL | Deadline for the task |
|  task_completed | BIT NULL | 0 = Not Completed, 1 = Completed |

**10. Event_Ticket_Assignment**

* Size: 396,140 rows, 7 columns

* Purpose: The Event_Ticket_Assignment table records each ticket issued to attendees, including ticket type, purchase date, and price. There are 8 types of tickets: Early-Bird, Student, All-Access, Virtual-Ticket, Group-Ticket, Day-Pass, General-Admission and VIP and each ticket has its associated price. Such as an VIP ticket will cost higher than a Student Ticket etc.

* Importance: This table is vital for managing ticket sales, tracking revenue, and ensuring that attendees have valid tickets for events. By centralizing ticket data, companies can manage ticket distribution and sales more effectively, improving revenue tracking and attendee management.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  ticket_ID | GUID PRIMARY KEY | Unique Identifier of the Ticket table |
|  attendee_ID | INT NOT NULL | FOREIGN KEY to the Attendee table |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table |
|  purchase_date | DATE NULL | Date of purchasing the ticket |
|  expiry_date | DATE NULL | Expiry date of the ticket |
|  price | MONEY NULL | Price of the ticket ($) |
|  ticket_type | VARCHAR(50) NULL | Type of the ticket ('Early-Bird','Student','All-Access','Virtual-Ticket','Group-Ticket','Day-Pass','General-Admission',VIP') |


**11. Event_Tickets**

* Size: 7,640 rows, 4 columns

* Purpose: The Event_Tickets table lists all possible combinations of events and ticket types, along with their prices. This table is not used for any joining but is used to insert values in the Event_Ticket_Assignment table, so _it is not included in the ERD Diagram._

* Importance: This reference table is used to update ticket prices in the Event_Ticket_Assignment table, ensuring consistency in pricing. By having a predefined list of ticket prices, companies can streamline the ticketing process, making it easier to manage and update ticket sales across events.

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT NOT NULL | FOREIGN KEY to the Event table|
|  ticket_ID | VARCHAR(32) NULL | Unique identifier of ticket |
|  price | MONEY NOT NULL | Price of the ticket ($) |
|  ticket_type| VARCHAR(50) NOT NULL | Type of the ticket ('Early-Bird','Student','All-Access','Virtual-Ticket','Group-Ticket','Day-Pass','General-Admission',VIP') |



### Part 4 : Optimizing the database by creating index, views, stored procedures and user defined functions 
  
**1. Indexes:**

Added Clustered and Non-clustered indexes in various columns in the tables that are most likely to be queried against or joined with other tables. 

**2. Look-up Table:**

Created a look-up table Calender with Recursive CTE which contain 10 years' dates from Jan 1st, 2014 to Dec 31st, 2024. This table can be joined with Event and Event_Ticket_Assignment tables to perform a range of date calculations.

**3. Views:**

Created 4 Views in the database system that facilitates easy and quick analysis without repeatedly joining multiple tables.

   * dbo.EventDetails - To view combining Event, Venue, Attendee, and Event_Type for quickly retrieving event details with attendee and venue info.

   * dbo.EmployeePerEvent - To provide a quick way for analysts to view which employees are assigned to specific events and their tasks

   * dbo.VenueCapacityLimits - To identify events that are close to their venue capacity limits

   * dbo.DeadlineTracker - To track and view overdue tasks or tasks close to their deadlines for event employees

**4. User Defined Functions:**

  * dbo.ufnCurrentDate() - An User Defined Function (UDF) that returns the current date and that can be used to calculate the days left for the eevnts to start

**5. Table Valued Functions:**

  * dbo.ufn_EventsByEventType(EventType) - A TVF to compute the total revenue from tickets across all events per event type
   
**6.  Created 3 Stored Procedures:**

   * dbo.PartnersReport - To provide a list of partners who contributed to events over a certain budget threshold
   * dbo.TopPerformingTickets - To automate the generation of reports on ticket sales performance (price, type, and sales per event)
   * dbo.BudgetPerformance - To track event budget performance (Estimated vs Actual) across all events efficiently


## Summary:

1. **Objective Identification**: Defined the database's purpose, including its primary users, and the key functions—reporting, event management, venue tracking, attendee and task organization—to ensure successful event execution.

2. **Requirement Gathering**: Collected all necessary data requirements, focusing on essential entities like event details, host organizations, event dates, locations, partners, budgets, attendees, tickets, and tasks.

3. **Database Creation Process**: Organized the project into four phases, addressing each phase sequentially.

   - **Phase 1: Database Schema Design**: 
     - Designed the conceptual, logical, and physical database models.
     - The conceptual model outlined entity relationships, while the logical model defined columns, data types, and junction tables for many-to-many relationships.
     - The physical design included primary and foreign keys to link entities, with normalization to reduce data redundancy.

   - **Phase 2: Implementation in SQL Server**: 
     - Created 11 tables using SQL Server's Data Definition Language (DDL).

   - **Phase 3: Data Population**: 
     - Populated tables with realistic synthetic data, including demographic, geographic, and numerical information (budgets, attendee counts, ticket prices, dates) using Data Manipulation Language (DML). Mockaroo was used to generate random datasets.

   - **Phase 4: Database Optimization**: 
     - Added clustered and non-clustered indexes for frequently queried columns, views for quicker analysis, and stored procedures and user-defined functions for advanced analytics.

4. **Conclusion**: Highlighted a few limitations and shared resources that aided the case study. All SQL scripts, documentation, and a comprehensive report were uploaded to GitHub.


## Limitations:

1. One important limitation of this database is that for some tables like attendee, event, or tickets its not properly scaled.
2. There might appear some discrepency in record count when applying aggregate functions or joins.
3. There is discrepency in actual_attendance from Event table and the count of attendees/tickets from the Ticket_Attendee table which should return the same number of attendees but it doesn't. 

## Resources:

* [An Event Management Data Model](https://vertabelo.com/blog/how-to-plan-and-run-events-an-event-management-data-model/)
* [How to Design a Database for Event Management](https://www.geeksforgeeks.org/how-to-design-a-database-for-event-management/)
* [What is a Database Schema | Lucidchart](https://www.lucidchart.com/pages/database-diagram/database-schema)
* [Building an Event Management System: Designing the Blueprint, Crafting the Schema, and Executing with SQL](https://medium.com/@tatibaevmurod/building-an-event-management-system-designing-the-blueprint-crafting-the-schema-and-executing-43ad2e45568e)
* [Data Modeling: Conceptual vs Logical vs Physical Data Model](https://online.visual-paradigm.com/knowledge/visual-modeling/conceptual-vs-logical-vs-physical-data-model/)
