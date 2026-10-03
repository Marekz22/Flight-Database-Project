-- ====================================================================
-- Analytical View: Flight Operations & Details
-- ====================================================================

CREATE OR REPLACE VIEW bookings.v_flight_analytics AS
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
    arr.city->>'en' AS arrival_city
FROM bookings.flights f
JOIN bookings.aircrafts_data ad 
    ON f.aircraft_code = ad.aircraft_code
JOIN bookings.airports_data dep 
    ON f.departure_airport = dep.airport_code
JOIN bookings.airports_data arr 
    ON f.arrival_airport = arr.airport_code;
