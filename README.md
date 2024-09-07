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

* **1. Entities:**

  * Event: event_id (pk), event_type_id (fk), organization_id (fk), venue_id (fk), budget_estimated, budget_actual, description, start_date, end_date, status, estimated_attendance, actual_attendance
  
  * Venue: venue_id (pk), capacity, address_line, city, state, zip_code, country
  
  * Attendee: attendee_id (pk), first_name, last_name, email, phone
  
  * Ticket: ticket_id (pk), event_id (fk), price, ticket_type
  
  * Employee: employee_id (pk), organization_id (fk), first_name, last_name, job_title, email
  
  * Organization: organization_id (pk), name, contact_person, phone, email
  
  * Partner: partner_id (pk), name, email, phone
  
  * Event_Type: event_type_id (pk), event_type_name
  
  * Event_Partner Junction: event_id (fk), partner_id (fk), role
  
  * Ticket_Attendee Junction: ticket_id (fk), attendee_id, purchase_date, expiry_date
  
  * Event_Employee Junction: event_id,  employee_id, task, start_date, deadline, task_completed
  
* **2. Relations:**

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

* **3. Database Normalization:**
All the tables are normalized upto 3rd normal form. A detailed description of the Normalization Process is available [here]().

* **4. Entity Relation Diagram (ERD):**

![EventSphere Event Management Database schema (1)](https://github.com/user-attachments/assets/f5df2a5c-f12c-446a-ae95-770985262b1f)
