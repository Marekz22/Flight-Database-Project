-- ====================================================================
-- Analytical View: Flight Operations & Details
-- ====================================================================

CREATE OR REPLACE VIEW bookings.v_flight_analytics AS
WITH airplane_capacity AS (
    SELECT 
        aircraft_code,
        COUNT(*) AS total_seats
    FROM bookings.seats
    GROUP BY aircraft_code
)
SELECT 
    f.flight_id,
    f.flight_no,
    f.status,
    f.scheduled_departure,
    f.scheduled_arrival,
    f.actual_departure,
    f.actual_arrival,
    ROUND(
        EXTRACT(EPOCH FROM 
            CASE 
                WHEN f.status = 'Arrived' THEN f.actual_departure - f.scheduled_departure 
                ELSE NULL 
            END
        ) / 60, 0
    ) AS departure_delay_min,
    ad.aircraft_code,
    ad.model->>'en' AS aircraft_model,
    f.departure_airport,
    dep.airport_name->>'en' AS departure_airport_name,
    dep.city->>'en' AS departure_city,
    f.arrival_airport,
    arr.airport_name->>'en' AS arrival_airport_name,
    arr.city->>'en' AS arrival_city,
	ac.total_seats
FROM bookings.flights f
JOIN bookings.aircrafts_data ad 
    ON f.aircraft_code = ad.aircraft_code
JOIN bookings.airports_data dep 
    ON f.departure_airport = dep.airport_code
JOIN bookings.airports_data arr 
    ON f.arrival_airport = arr.airport_code
LEFT JOIN airplane_capacity ac
	ON f.aircraft_code=ac.aircraft_code

-- ====================================================================
-- Analytical View: Flight Financials Summary
-- ====================================================================

CREATE OR REPLACE VIEW bookings.v_flight_financials AS
SELECT 
    flight_id,
    COUNT(*) AS tickets_sold,
    SUM(amount) AS total_revenue,
    SUM(
        CASE WHEN fare_conditions = 'Economy' THEN amount ELSE 0 END
    ) AS economy_revenue,
    SUM(
        CASE WHEN fare_conditions = 'Business' THEN amount ELSE 0 END
    ) AS business_revenue,
    SUM(
        CASE WHEN fare_conditions = 'Comfort' THEN amount ELSE 0 END
    ) AS comfort_revenue
FROM bookings.ticket_flights
GROUP BY flight_id;
