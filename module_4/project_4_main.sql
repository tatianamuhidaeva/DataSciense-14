WITH 
-- перелеты из Анапы в зимний период
flights AS
  (SELECT *
   FROM dst_project.flights
   WHERE departure_airport = 'AAQ'
     AND (date_trunc('month', scheduled_departure) in ('2017-01-01',
                                                       '2017-02-01',
                                                       '2017-12-01'))
     AND status not in ('Cancelled') 
  ), 
-- количество мест в каждом классе самолета
aircrafts AS
  (SELECT ac.aircraft_code AS aircraft_code,
          ac.model AS model,
          ac.range,
          count(s.seat_no) AS sum_seats,
          count(CASE
                    WHEN s.fare_conditions = 'Economy' THEN s.fare_conditions
                END) AS seat_economy,
          count(CASE
                    WHEN s.fare_conditions = 'Comfort' THEN s.fare_conditions
                END) AS seat_comfort,
          count(CASE
                    WHEN s.fare_conditions = 'Business' THEN s.fare_conditions
                END) AS seat_business
   FROM dst_project.aircrafts ac
   JOIN dst_project.seats AS s ON ac.aircraft_code=s.aircraft_code
   GROUP BY ac.aircraft_code
  ),
  -- Стоимость билетов в самолетах по классу и количество таких билетов
   craft_class_prices AS
  (SELECT f.aircraft_code,
          tf.fare_conditions,
          tf.amount,
          count(tf.amount) AS count_amount
   FROM flights f
   JOIN dst_project.ticket_flights AS tf ON f.flight_id=tf.flight_id
   GROUP BY f.aircraft_code,
            tf.fare_conditions,
            tf.amount
   ORDER BY f.aircraft_code,
            tf.fare_conditions,
            count(tf.amount) DESC
  ),
  -- таблица с базовой стоимостью билета (исключаются цены, которые встречаются реже других в соответствующей группе)
  basic_prices AS
  (SELECT cc1.aircraft_code,
       cc1.fare_conditions,
       cc1.amount AS base_amount
	FROM craft_class_prices AS cc1
	JOIN
	  (SELECT aircraft_code,
			  fare_conditions,
			  max(count_amount) AS max_counts
	   FROM craft_class_prices
	   GROUP BY aircraft_code,
				fare_conditions) AS cc2 ON cc1.count_amount=cc2.max_counts
   ),

	--распределение мест в самолотеах по классам и цены по классам
	ticket_flights AS
  (SELECT f.flight_id,
          count(CASE
                    WHEN tf.fare_conditions = 'Economy' THEN tf.fare_conditions
                END) AS ticket_economy,
          count(CASE
                    WHEN tf.fare_conditions = 'Comfort' THEN tf.fare_conditions
                END) AS ticket_comfort,
          count(CASE
                    WHEN tf.fare_conditions = 'Business' THEN tf.fare_conditions
                END) AS ticket_business,
          ROUND(avg(CASE
                        WHEN tf.fare_conditions = 'Economy' THEN bp.base_amount
                    END), 2) AS price_economy,
          ROUND(avg(CASE
                        WHEN tf.fare_conditions = 'Comfort' THEN bp.base_amount
                    END), 2) AS price_comfort,
          ROUND(avg(CASE
                        WHEN tf.fare_conditions = 'Business' THEN bp.base_amount
                    END), 2) AS price_business,
   			sum(tf.amount) AS flight_price
   FROM flights f
   JOIN dst_project.ticket_flights AS tf ON f.flight_id=tf.flight_id
   JOIN basic_prices AS bp ON (f.aircraft_code=bp.aircraft_code and tf.fare_conditions=bp.fare_conditions)
   GROUP BY f.flight_id
  )
-- end WITH


-- Main request
SELECT f.flight_id AS flight_id,
       dep_a.city AS depart_city,
       dep_a.longitude AS depart_lon,
       dep_a.latitude AS depart_lat,
       arr_a.city AS arrival_city,
       arr_a.longitude AS arrival_lon,
       arr_a.latitude AS arrival_lat,
	   f.scheduled_departure AS scheduled_departure,
	   
--        (f.scheduled_departure - f.actual_departure) AS flight_duration,
       (f.scheduled_arrival - f.scheduled_departure) AS flight_duration,
       ac.model AS ac_model,
       ac.range AS ac_range,
--        ac.fuel_consump AS ac_fuel_consump,
--        ac.fuel_price AS ac_fuel_price,
       ac.seat_economy AS ac_economy,
       ac.seat_comfort AS ac_comfort,
       ac.seat_business AS ac_business,
       tf.ticket_economy,
       tf.ticket_comfort,
       tf.ticket_business,
       tf.price_economy,
       tf.price_comfort,
       tf.price_business,
	   tf.flight_price
FROM flights AS f
JOIN dst_project.airports AS dep_a ON dep_a.airport_code = 'AAQ'
JOIN dst_project.airports AS arr_a ON arr_a.airport_code = f.arrival_airport
JOIN aircrafts AS ac ON f.aircraft_code=ac.aircraft_code
LEFT JOIN ticket_flights AS tf ON f.flight_id=tf.flight_id
order by scheduled_departure

