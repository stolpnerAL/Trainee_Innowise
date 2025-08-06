
--Display the number of films in each category, sorted in descending order.

  WITH films_categories AS (
SELECT f.film_id,
       c.category_id,
	   c.name AS category
  FROM film AS f
  JOIN film_category AS fc
    ON f.film_id = fc.film_id
  JOIN category AS c
    ON fc.category_id = c.category_id)

SELECT category,
       COUNT(1) AS film_cnt
  FROM films_categories
 GROUP BY category
 ORDER BY 2 desc
--Display the top 10 actors whose films were rented the most, sorted in descending order.

  WITH best_actors AS (
SELECT CONCAT(a.first_name, ' ',  a.last_name) AS actor,
       SUM(f.rental_rate) AS rented
  FROM actor AS a
  JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
  JOIN film AS f
    ON fa.film_id = f.film_id
 GROUP BY 1
 ORDER BY 2 DESC)

 SELECT actor 
  FROM best_actors
  LIMIT 10
 
	   
--Display the category of films that generated the highest revenue.


  WITH cte AS (
SELECT p.amount,
       c.name AS category
  FROM payment AS p
  JOIN rental AS l
    ON p.rental_id = l.rental_id
  JOIN inventory AS i
    ON l.inventory_id = i.inventory_id
  JOIN film_category AS fc
    ON i.film_id = fc.film_id
  JOIN category AS c
    ON fc.category_id = c.category_id)
	
SELECT category,
       SUM(amount) AS revenue 
  FROM cte
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 1
--Display the titles of films not present in the inventory. 
--Write the query without using the IN operator.


SELECT f.title,
       i.inventory_id
  FROM film AS f
  LEFT JOIN inventory AS i
    ON f.film_id = i.film_id
 WHERE i.inventory_id IS NULL
 
--Display the top 3 actors who appeared the most in films within the "Children" category. If multiple actors have the same count, include all.

  WITH task_5 AS (
SELECT CONCAT (a.first_name, ' ', a.last_name) AS actor,
       COUNT(f.film_id) AS cnt,
	   c.name
  FROM actor AS a
  JOIN film_actor AS fa
    ON a.actor_id = fa.actor_id
  JOIN film AS f
    ON fa.film_id = f.film_id
  JOIN film_category AS fc
    ON f.film_id = fc.film_id
  JOIN category AS c
    ON fc.category_id = c.category_id
 WHERE c.name = 'Children'
 GROUP BY 1, 3) 

SELECT actor 
  FROM task_5
 ORDER BY cnt DESC
 LIMIT 3 
--Display cities with the count of active and inactive customers (active = 1).
--Sort by the count of inactive customers in descending order.

SELECT c.city,
       SUM(cu.active) AS active,
       COUNT(*) - SUM(cu.active) AS inactive
FROM city AS c
JOIN address AS a ON c.city_id = a.city_id
JOIN customer AS cu ON a.address_id = cu.address_id
GROUP BY 1
ORDER BY 3 DESC;
  WITH addresses_cities AS (
SELECT a.address_id,
       ci.city,
       cu.customer_id
  FROM address AS a
  JOIN city AS ci 
    ON a.city_id = ci.city_id
  JOIN customer AS cu
    ON a.address_id = cu.address_id),

       rental_data AS (
SELECT c.name AS category_name,
       ac.city,
       SUM(f.rental_duration) AS total_rent,
       CASE WHEN ac.city LIKE 'a%' THEN 'starts_with_a'
            WHEN ac.city LIKE '%-%' THEN 'contains_hyphen'
        END AS city_type
  FROM category AS c
  JOIN film_category AS fc 
    ON c.category_id = fc.category_id
  JOIN film AS f 
    ON fc.film_id = f.film_id
  JOIN inventory AS i 
    ON f.film_id = i.film_id
  JOIN rental AS r 
    ON i.inventory_id = r.inventory_id
  JOIN addresses_cities AS ac 
    ON r.customer_id = ac.customer_id
 WHERE ac.city LIKE 'a%' OR ac.city LIKE '%-%'
 GROUP BY c.name, ac.city, city_type),

       max_rents AS (
SELECT city_type,
   MAX(total_rent) AS max_rent
  FROM rental_data
 GROUP BY city_type)

SELECT r.category_name
  FROM rental_data r
  JOIN max_rents AS m 
    ON r.city_type = m.city_type AND r.total_rent = m.max_rent
 ORDER BY r.city_type
