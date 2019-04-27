USE sakila;

/*1a. Display the first and last names of all actors from the table actor.*/
select first_name as "First Name", last_name as "Last Name"
from actor;

/*1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.*/
select UPPER(concat(first_name, " ", last_name)) as "Actor Name" 
from actor;

/*2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information?*/
select actor_id as "ID number", first_name "First Name", last_name as "Last Name"
from actor 
where first_name = "Joe";

/*2b. Find all actors whose last name contain the letters GEN: */
select * 
from actor
where last_name like "%GEN%";

/* 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order: */
select * 
from actor
where last_name like "%LI%"
order by last_name, first_name;

/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China: */
select country_id, country 
from country
where country IN ("Afghanistan", "Bangladesh", "China")
order by country asc;

/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant). */
ALTER TABLE actor 
ADD description blob;

/* 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.*/
ALTER TABLE actor
DROP COLUMN description;

/* 4a. List the last names of actors, as well as how many actors have that last name.*/
select last_name, count(*) AS "No Of Actors having the Last name"
from actor
group by last_name;

/* 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/
select last_name, count(*) AS "No Of Actors having the Last name"
from actor
group by last_name
having count(*) >= 2;

/* 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record. */
update actor set first_name = "HARPO"
where last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, 
if the first name of the actor is currently HARPO, change it to GROUCHO. */
update actor set first_name = "GROUCHO"
where last_name = "WILLIAMS";

/* 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html */
DESCRIBE sakila.address;

/*  6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:*/
select first_name, last_name, address
from address sa 
INNER JOIN staff ss ON sa.address_id = ss.address_id;

/* 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment. */
select s.staff_id, s.first_name, s.last_name, p.amount, p.payment_date
from staff s
INNER JOIN payment p ON p.staff_id = s.staff_id
and p.payment_date LIKE '2005-08%';

/*6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.*/
select f.title as "Film Title", count(fa.actor_id) as "Number of actors" from film f  
INNER JOIN  film_actor fa ON f.film_id = fa.film_id
group by f.title;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
select f.title, count(i.inventory_id) as "Number of copies" from film f  
INNER JOIN  inventory i ON f.film_id = i.film_id
where f.title = "Hunchback Impossible";

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name:*/
select c.first_name, c.last_name, sum(p.amount) as "Total Paid" from payment p
INNER JOIN customer c ON p.customer_id = c.customer_id
group by p.customer_id
order by c.last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters K and Q whose language is English.*/
select f.title from film f
where f.title like 'K%' or f.title like 'Q%'
and f.language_id IN (select l.language_id from language l where l.name = "English");

/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/
select a.first_name, a.last_name from actor a
where a.actor_id IN (select fa.actor_id from film_actor fa
					 where fa.film_id IN (select f.film_id from film f
										  where f.title = "Alone Trip")
					)
order by a.last_name;

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.*/
select c.first_name, c.last_name, c.email from customer c
INNER JOIN address a ON a.address_id = c.address_id
INNER JOIN city ci ON ci.city_id = a.city_id
INNER JOIN country cy ON cy.country_id = ci.country_id
where cy.country = "Canada";

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
select f.title from film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category ca ON fc.category_id = ca.category_id
where ca.name = "Family"
order by f.title;

/*7e. Display the most frequently rented movies in descending order.*/
select f.title, count(r.rental_id) as "No of times rented" from film f
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
group by f.title
order by count(r.rental_id) desc;

/*7f. Write a query to display how much business, in dollars, each store brought in.*/
select s.store_id, sum(p.amount) as "Business in Dollars" from payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON i.inventory_id = r.inventory_id
INNER JOIN store s ON i.store_id = s.store_id
group by s.store_id desc;

/*7g. Write a query to display for each store its store ID, city, and country.*/
select s.store_id, ci.city as "City", cy.country as "Country" from store s
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country cy ON ci.country_id = cy.country_id
order by s.store_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the 
following tables: category, film_category, inventory, payment, and rental.)*/
select c.name as "Genre", sum(p.amount) as "Gross Revenue" from category c 
INNER JOIN film_category f ON c.category_id = f.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
group by c.name 
order by sum(p.amount) desc
LIMIT 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
create view TopFiveGenresRevenue AS 
select c.name as "Genre", sum(p.amount) as "Gross Revenue" from category c 
INNER JOIN film_category f ON c.category_id = f.category_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
INNER JOIN payment p ON r.rental_id = p.rental_id
group by c.name 
order by sum(p.amount) desc
LIMIT 5;

/*8b. How would you display the view that you created in 8a?*/
select * from TopFiveGenresRevenue;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW TopFiveGenresRevenue;



















