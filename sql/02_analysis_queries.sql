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
FROM bookings.ticket_flights
GROUP BY fare_conditions
ORDER BY total_revenue DESC;
