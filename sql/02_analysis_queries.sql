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
