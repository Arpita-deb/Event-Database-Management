# EventSphere Event Management Database Design

## Introduction:

### Business Problem:

PrimeTime Event Solutions is a mid-sized corporate event management company specializing in organizing internal conferences, product launches, training sessions, and corporate retreats for large enterprises. The company handles multiple events simultaneously, with each event having its own set of tasks, attendees, and specific requirements. To streamline operations and ensure all details are properly tracked, CorpEvent Solutions needs a centralized database to manage all aspects of their events.

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

**1. Creating the database and the tables:**

Using Data Definition Language (DDL), the EventSphere Database and its leaf tables are created. The script is available in the Script folder.

**2. Populating the tables:**

Using Data Manipulation Language (DML), the EventSphere Database and its leaf tables are created. The script is available in the Script folder. 

Most of the data is generated through Mockaroo, which enabled me to simulate the real world scenario by generating random demographhic data for employees, attendees, numbers in ranges etc faster. 

Here in addition to simple INSERT and UPDATE Statements, complex calculations has been performed to generate more data points (in case of 'Event' table). These calculations are used to create records for budget, number of attendees and dates for different type of events (eg. virtual, in person, seminar, product lauch etc).

**3. Data Description:**

1. Event

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT PRIMARY KEY | Unique identifier of event |
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
  
2. Venue

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
  
3. Attendee

| Column | Datatype | Description |
| :--- | :--- | :--- |
| attendee_ID | INT PRIMARY KEY NOT NULL ||
| first_name  | VARCHAR(50) NOT NULL ||
| last_name | VARCHAR(50) NOT NULL ||
| email| VARCHAR(50) NOT NULL ||
| phone | VARCHAR(25) NULL ||

4. Ticket

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  ticket_ID |INT PRIMARY KEY NOT NULL ||
|  event_ID |INT FOREIGN KEY REFERENCES Event(Event_ID ||
|  price| MONEY NOT NULL||
|  ticket_type| VARCHAR(20) NOT NULL ||

5. Employee

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  employee_ID | INT PRIMARY KEY NOT NULL ||
| organization_ID | INT FOREIGN KEY REFERENCES Organization(organization_ID) NOT NULL ||
|  first_name |VARCHAR(50) NOT NULL ||
| last_name| VARCHAR(50) NOT NULL ||
|  job_title |VARCHAR(50) NOT NULL ||
|  email |VARCHAR(50) NOT NULL ||

6. Organization

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  organization_ID |INT PRIMARY KEY NOT NULL ||
|  name |VARCHAR(50) NOT NULL ||
|  contact_person |VARCHAR(50) ||
|  email |VARCHAR(50) NOT NULL ||
|  phone |VARCHAR(25) NULL ||

7. Partner

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  partner_ID |INT PRIMARY KEY  NOT NULL ||
| name |VARCHAR(50) NOT NULL ||
|  email |VARCHAR(50) NOT NULL ||
|  phone |VARCHAR(25) NULL ||

8. Event_Type

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_type_ID INT PRIMARY KEY NOT NULL ||
|  event_type_name VARCHAR(50) NULL ||

9. Event_Partner

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID |INT FOREIGN KEY REFERENCES Event(Event_ID) NOT NULL ||
|  partner_ID |INT FOREIGN KEY REFERENCES Partner(Partner_ID) NOT NULL ||
|  role |VARCHAR(50) NOT NULL ||

10. Event_Employee

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  event_ID | INT FOREIGN KEY REFERENCES Event(Event_ID) NOT NULL ||
|  employee_ID | INT FOREIGN KEY REFERENCES Employee(Employee_ID) NOT NULL ||
|  task | VARCHAR(120) NOT NULL ||
|  start_date | DATE NOT NULL ||
|  deadline | DATE NULL ||
|  task_completed | BIT NOT NULL ||

11. Ticket_Attendee

| Column | Datatype | Description |
| :--- | :--- | :--- |
|  ticket_ID | INT FOREIGN KEY REFERENCES  Ticket(ticket_ID) NOT NULL ||
|  attendee_ID | INT FOREIGN KEY REFERENCES Attendee(attendee_ID) NOT NULL ||
|  purchase_date | DATE NOT NULL ||
|  expiry_date | DATE NULL ||
