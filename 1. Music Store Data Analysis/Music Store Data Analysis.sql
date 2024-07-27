--Set 1 - Easy

-- Who is the senior most employee based on job title?
select * from employee
order by levels desc
limit 1;

-- Which countries have the most invoices?
select count (*) as c, billing_country from invoice
group by billing_country
order by c desc

-- What are the top 3 values of invoice?
select total from invoice
order by total desc
limit 3;

-- Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--totals
select billing_city, sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1;

-- Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) from customer
join invoice on
customer.customer_id = invoice.customer_id
group by customer.customer_id
order by sum(invoice.total) desc
limit 1;


-- Set 2 - Moderate

-- Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with  A
select distinct email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email asc;

-- OR

select distinct email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in (
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email asc

-- Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock band
select artist.name, count(genre.name) from genre
join track on genre.genre_id = track.genre_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
where genre.name like 'Rock'
group by artist.name
order by count(genre.name) desc
limit 10;

-- Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc

-- Set 3 - Advanced

-- Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent
select customer.customer_id, customer.first_name, customer.last_name, artist.name, sum(invoice_line.unit_price * invoice_line.quantity) as TotalSpent from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
where artist.name like 'Queen'
group by customer.customer_id, customer.first_name, customer.last_name, artist.name
order by TotalSpent desc

-- OR (Using CTE)
	
with best_selling_artist as(
	select artist.artist_id, artist.name, sum(invoice_line.unit_price * invoice_line.quantity) as TotalSales from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by artist.artist_id, artist.name
	order by TotalSales desc
	limit 1
)
select customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.name, sum(invoice_line.unit_price * invoice_line.quantity) as TotalSpent from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join best_selling_artist on album.artist_id = best_selling_artist.artist_id
group by customer.customer_id, customer.first_name, customer.last_name, best_selling_artist.name
order by TotalSpent desc

-- We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genre
with popular_genre as(
	select count(invoice_line.quantity), customer.country, genre.name, genre.genre_id ,
	row_number() over(partition by customer.country order by count(invoice_line.quantity)  desc) as RowNo
	from customer
	join invoice on customer.customer_id = invoice.customer_id
	join invoice_line on invoice.invoice_id = invoice_line.invoice_id
	join track on invoice_line.track_id = track.track_id
	join genre on track.genre_id = genre.genre_id
	group by customer.country, genre.name, genre.genre_id
	order by customer.country asc
	)
select * from popular_genre where RowNo<=1


