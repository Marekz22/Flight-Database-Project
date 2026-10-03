-- ====================================================================
-- Flight Delays Analysis
-- ====================================================================

-- 1. Top 10 flights with the longest departure delay
SELECT 
    flight_id,
    flight_no,
    scheduled_departure,
    actual_departure,
    ROUND(EXTRACT(EPOCH FROM (actual_departure - scheduled_departure)) / 60) AS departure_delay_minutes
FROM flights
WHERE status = 'Arrived'
ORDER BY departure_delay_minutes DESC
LIMIT 10;

-- 2. Average departure delay by airport
SELECT 
    departure_airport,
    COUNT(*) AS total_flights,
    ROUND(EXTRACT(EPOCH FROM AVG(actual_departure - scheduled_departure)) / 60, 2) AS avg_delay_minutes
FROM flights
WHERE status = 'Arrived'
GROUP BY departure_airport
ORDER BY avg_delay_minutes DESC;

-- Average departure delay by airport and city (arrived flights only)
SELECT 
    f.departure_airport,
    a.city->>'en' AS city,
    a.airport_name->>'en' AS airport_name,
    COUNT(*) AS total_flights,
    ROUND(
        EXTRACT(EPOCH FROM AVG(f.actual_departure - f.scheduled_departure)) / 60,
        2
    ) AS avg_delay_minutes
FROM flights f
JOIN airports_data a ON f.departure_airport = a.airport_code
WHERE f.status = 'Arrived'
GROUP BY 
    f.departure_airport,
    a.city->>'en',
    a.airport_name->>'en'
ORDER BY avg_delay_minutes DESC;

-- ====================================================================
-- Revenue & Fare Class Analysis
-- ====================================================================

-- Revenue and market share by fare class (using window functions)
SELECT 
    fare_conditions,
    COUNT(*) AS total_tickets,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS average_ticket_price,
    ROUND((SUM(amount) / SUM(SUM(amount)) OVER () * 100), 2) AS revenue_share_pct
FROM ticket_flights
GROUP BY fare_conditions
ORDER BY total_revenue DESC;

-- ====================================================================
-- Flight Occupancy (Load Factor) Analysis
-- ====================================================================

-- Calculate aircraft capacity, boarded passengers, and load factor percentage
WITH airplane_capacity AS (
    SELECT 
        aircraft_code,
        COUNT(*) AS total_seats
    FROM bookings.seats
    GROUP BY aircraft_code
),
flight_passengers AS (
    SELECT 
        flight_id,
        COUNT(*) AS boarded_passengers
    FROM bookings.boarding_passes
    GROUP BY flight_id
)
SELECT 
    f.flight_id,
    f.flight_no,
    ac.total_seats,
    fp.boarded_passengers,
    ROUND((fp.boarded_passengers::numeric / ac.total_seats::numeric) * 100, 2) AS load_factor_pct
FROM flights f
JOIN airplane_capacity ac 
    ON f.aircraft_code = ac.aircraft_code
JOIN flight_passengers fp 
    ON f.flight_id = fp.flight_id
WHERE f.status = 'Arrived'
ORDER BY load_factor_pct DESC
LIMIT 10;
