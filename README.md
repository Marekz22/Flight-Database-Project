# Flight-Database-Project
A complete analytics project built on a relational airline booking database. The project includes SQL analysis, ERD diagram, documentation, and Power BI dashboard.
![Executive Dashboard Overview](docs/Executive%20Dashboard%20Overview.png)
#


### Project Structure
* **ERD diagram** (Entity Relationship Diagram)
* **Table descriptions** & Data Dictionary
* **SQL scripts** (Views, window functions, and data quality checks)
* **Power BI dashboard** (`.pbix` with Figma UI integration)
* **Documentation**
#

## ERD Diagram
![Database ERD](docs/ERD.png)
It shows relationships between:
bookings
tickets
ticket_flights
flights
airports_data
aircrafts_data
seats
boarding_passes
#

## Table Relationships (Technical Overview)

- **bookings → tickets (1:N)**  
  One booking can contain multiple tickets.

- **tickets → ticket_flights (1:N)**  
  One ticket can be used for multiple flights (connections).

- **flights → ticket_flights (1:N)**  
  One flight has multiple tickets.

- **flights → airports_data (1:N)**  
  Each flight has one departure airport and one arrival airport.

- **flights → aircrafts_data (1:N)**  
  One aircraft can operate multiple flights.

- **aircrafts_data → seats (1:N)**  
  One aircraft has multiple seats.

- **tickets → boarding_passes (1:N)**  
  One ticket can have multiple boarding passes.

- **flights → boarding_passes (1:N)**  
  One flight has multiple passengers.
#

## SQL Analysis
SQL scripts are located in /sql/.
01_data_quality_checks.sql
02_analysis_queries.sql
#

## Power BI Dashboard
The Power BI file dashboard.pbix is located in /powerbi/.
Dashboard includes:
revenue by flight
seat occupancy
flight delays
route popularity
aircraft utilization
### Interactive Features & UI

**Filter Panel (Bookmarks & Selection):**
![Filter Panel](docs/filter_panel.png)

**Dynamic Drilldown Tooltip:**
![Daily Tooltip](docs/tooltip_drilldown.png)
#

---

## UI/UX Design System (Figma)
The visual hierarchy, layout grid, and glassmorphism containers were prototyped in **Figma** prior to building the report in Power BI.

### Main Canvas Layout
![Figma Main Layout](docs/figma_dashboard_layout.png)

### Tooltip Canvas Layout
![Figma Tooltip Layout](docs/figma_tooltip_layout.png)

---

<details>
<summary><b> Click to view full DAX Measures Dictionary (20 measures)</b></summary>

<br>

| Measure Name | Description | Expression |
| :--- | :--- | :--- |
| **Total Flights** | Total count of scheduled and operated flight legs in the dataset. | `COUNTROWS('bookings v_flight_analytics')` |
| **Total Revenue** | Aggregate ticket revenue across all fare classes (converted to EUR). | `SUM('bookings v_flight_financials'[total_revenue]) / 70` |
| **Total Tickets Sold** | Total volume of passenger tickets sold across the network. | `SUM('bookings v_flight_financials'[tickets_sold])` |
| **Avg Ticket Price** | Average yield / revenue generated per individual sold ticket. | `DIVIDE([Total Revenue], [Total Tickets Sold])` |
| **Avg Departure Delay** | Mean departure delay across operations (in minutes). | `AVERAGE('bookings v_flight_analytics'[departure_delay_min])` |
| **Delayed Flights** | Count of completed flights departing with a delay greater than 15 minutes. | `CALCULATE([Total Flights], 'bookings v_flight_analytics'[departure_delay_min] > 15, 'bookings v_flight_analytics'[status] = "Arrived")` |
| **Delayed Flights %** | Share of arrived flights delayed by more than 15 minutes. | `DIVIDE([Delayed Flights], [Finished Flights])` |
| **Cancelled Flights** | Total count of flights that were cancelled before departure. | `CALCULATE([Total Flights], 'bookings v_flight_analytics'[status] = "Cancelled")` |
| **Cancelled Flights %** | Proportion of total network flights resulting in cancellation. | `DIVIDE([Cancelled Flights], [Total Flights])` |
| **Finished Flights** | Total count of successfully completed flights (status 'Arrived'). | `CALCULATE([Total Flights], 'bookings v_flight_analytics'[status] = "Arrived")` |
| **On-Time Flights** | Count of arrived flights departing within the industry standard 15-minute buffer. | `CALCULATE([Total Flights], 'bookings v_flight_analytics'[departure_delay_min] <= 15, 'bookings v_flight_analytics'[status] = "Arrived")` |
| **On-Time %** | Operational punctuality rate (flights departing on schedule / total completed). | `DIVIDE([On-Time Flights], [Finished Flights])` |
| **Economy Revenue** | Revenue contribution from Economy class cabin bookings (EUR). | `SUM('bookings v_flight_financials'[economy_revenue]) / 70` |
| **Comfort Revenue** | Revenue contribution from Comfort / Premium Economy bookings (EUR). | `SUM('bookings v_flight_financials'[comfort_revenue]) / 70` |
| **Business Revenue** | High-yield revenue contribution from Business class bookings (EUR). | `SUM('bookings v_flight_financials'[business_revenue]) / 70` |
| **Avg Revenue per Flight** | Average commercial revenue generated per scheduled flight leg. | `DIVIDE([Total Revenue], [Total Flights])` |
| **Total seats** | Total physical aircraft seating capacity across scheduled departures. | `SUM('bookings v_flight_analytics'[total_seats])` |
| **Load Factor %** | Passenger capacity utilization rate on completed flights. | `CALCULATE(DIVIDE([Total Tickets Sold], [Total seats]), 'bookings v_flight_analytics'[status] = "Arrived")` |
| **Avg Delay 10D Rolling** | 10-day moving average of departure delays to smooth operational volatility. | `CALCULATE([Avg Departure Delay], DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]), -10, DAY))` |
| **Revenue 10D Rolling** | 10-day moving average of daily revenue to detect commercial trends. | `AVERAGEX(DATESINPERIOD(Dim_Date[Date], MAX(Dim_Date[Date]), -10, DAY), [Total Revenue])` |

</details>

## Documentation
Located in /docs/:


