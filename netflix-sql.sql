--Netflix Project
create table netflix_movies(
	show_id	varchar(10) primary key,
	type varchar(10),	
	title varchar(150),	
	director varchar(250),	
	casts varchar(1000),	
	country	varchar(150),
	date_added varchar(50),
	release_year int,	
	rating	varchar(10),
	duration varchar(15),	
	listed_in varchar(100),
	description varchar(500)
);

select * from netflix_movies;

select count(*) as total_rows from netflix_movies;

select distinct type from netflix_movies;


-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
select  type, count(*) as total_count 
from netflix_movies group by type;

--2. Find the most common rating for movies and TV shows
select type,rating, count(*)
from netflix_movies group by 1,2 
order by 1,3 desc;

select type,rating, count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix_movies group by 1,2; 

with cte as(
select type,rating, count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix_movies group by 1,2
)
select type, rating from cte where ranking = 1;

--3. List all movies released in a specific year (e.g., 2020)
select type, title, release_year
from netflix_movies where  type = 'Movie' and release_year = 2020;

select title from netflix_movies 
where type = 'Movie' and release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix
select  country, count(show_id) as most_content 
from netflix_movies group by country order by country ;

select string_to_array(country,',') as new_country
from netflix_movies;

select unnest(string_to_array(country,',')) as new_country
from netflix_movies;

select unnest(string_to_array(country,',')) as new_country,
count(show_id) as most_content
from netflix_movies group by 1 order by 2 desc;

select unnest(string_to_array(country,',')) as new_country,
count(show_id) as most_content
from netflix_movies group by 1 order by 2 desc limit 5;

--5. Identify the longest movie
select title, duration 
from netflix_movies 
where type = 'Movie' order by duration desc;

select title, duration 
from netflix_movies 
where type = 'Movie'
and duration = (select max(duration) from netflix_movies);

--6. Find content added in the last 5 years

select current_date - interval '5 years' from netflix_movies;

select date_added,
to_date(date_added, 'Month DD, YYYY')
from netflix_movies;

select *
from netflix_movies
where 
(to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years');

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select type,title, director from netflix_movies where director = 'Rajiv Chilaka';

select type,title, director from netflix_movies where director like '%Rajiv Chilaka%';

select type,title, director from netflix_movies where director ilike '%Rajiv Chilaka%'; --ilike case sensitivity

--8. List all TV shows with more than 5 seasons

select type, title from netflix_movies 
where type = 'TV Show' and duration > '5 Seasons';

select type, title,duration
from netflix_movies 
where type = 'TV Show' and split_part(duration,' ',1)::numeric > 5;

--9. Count the number of content items in each genre

select listed_in, count(*)
from netflix_movies group by listed_in order by count(*) desc;

select 
unnest(string_to_array(listed_in,',')) as genre, count(show_id) as total_content
from netflix_movies
group by 1 order by 2 desc;
--10.Find each year and the average numbers of content release in India on netflix
--return top 5 year with highest avg content release!
select country,to_date(date_added,'Month DD, YYYY') as date
from netflix_movies where country = 'India';

select extract(year from to_date(date_added,'Month DD, YYYY')) as year, count(*) as yearly_content
from netflix_movies where country = 'India'
group by 1 order by 2 desc;

select extract(year from to_date(date_added,'Month DD, YYYY')) as year, count(*) as yearly_content,
count(*)::numeric/(select count(*) from netflix_movies where country = 'India')::numeric * 100 as ave_content_per_year
from netflix_movies where country = 'India'
group by 1 order by 2 desc;

select extract(year from to_date(date_added,'Month DD, YYYY')) as year, count(*) as yearly_content,
round(count(*)::numeric/(select count(*) from netflix_movies where country = 'India')::numeric * 100,2) as ave_content_per_year
from netflix_movies where country = 'India'
group by 1 order by 2 desc;

--11. List all movies that are documentaries
select * from netflix_movies where listed_in ilike '%documentaries%';

--12. Find all content without a director

select * from netflix_movies where director is null;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix_movies where casts ilike '%salman khan%' 
and release_year > extract(year from current_date) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select --show_id, casts,
unnest(string_to_array(casts,',')) as actor,
count(*) as total_content
from netflix_movies
where country ilike '%india%'
group by 1
order by 2 desc
limit 10;


--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.

select * from netflix_movies
where description ilike '%kill%'
or description ilike '%violence%'

select *,
case 
	when description ilike '%kill%' 
		 or 
		 description ilike '%violence%' then 'Bad'
	else 'Good'
end category
from netflix_movies;



with cte as(

	select *,
	case 
		when description ilike '%kill%' 
			 or 
			 description ilike '%violence%' then 'Bad'
		else 'Good'
	end category
	from netflix_movies
)

select category, count(*) as total_count
from cte
group by 1;










