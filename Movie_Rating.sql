/* The schema of the database:

	Movie ( mID, title, year, director )
	English: There is a movie with ID number mID, a title, a release year, and a director.

	Reviewer ( rID, name )
	English: The reviewer with ID number rID has a certain name.

	Rating ( rID, mID, stars, ratingDate )
	English: The reviewer rID gave the movie mID a number of stars rating (1-5) on a certain ratingDate. 

*/

/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');

.mode column
.headers ON

/***************************** SQL Movie-Rating Query Exercises (core set) *****************************/
/*******************************************************************************************************/

-- Q1 Find the titles of all movies directed by Steven Spielberg. 
Select  tile
From Movie
Where director = ' Steven Spielberg';

-- Q2 Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
Select year
From Movie 
Where mID in (Select mID From Rating Where stars = '4' or stars = '5')
order by year;

-- Q3 Find the titles of all movies that have no ratings. 
Select title 
From Movie, Rating 
Where Movie.mID = Rating.mID and Rating.stars is Null;

-- Q4 Some reviewers didn't provide a date with their rating. 
--    Find the names of all reviewers who have ratings with a NULL value for the date. 
Select name 
From Reviewer, Rating 
Where Reviewer.rID = Rating.rID and ratingDate is null;

-- Q5 Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. 
--    Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
Select name, title, stars, ratingDate
From Reviewer, Movie, Rating
Where Movie.mID = Rating.mID and Reviewer.rID = Rating.rID
Order by name, title, stars;

-- Q6 For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, 
--    return the reviewer's name and the title of the movie. 
select name, title 
from Reviewer, Movie, Rating, Rating r2
where Rating.mID=Movie.mID and Reviewer.rID = Rating.rID
and Rating.rID = r2.rID and r2.mID = Movie.mID
and Rating.stars < r2.stars and Rating.ratingDate < r2.ratingDate;
group by name, title having count(*) = 1;

-- Q7 For each movie that has at least one rating, find the highest number of stars that movie received. 
--    Return the movie title and number of stars. Sort by movie title.
Select title, stars From Movie, Rating
Where Movie.mID = Rating.mID
Group by Rating.mID 
having max(stars)
order by title;

-- Q8 For each movie, return the title and the 'rating spread', that is,the difference between highest and lowest ratings given to that movie.
--    Sort by rating spread from highest to lowest, then by movie title. 
select title, m.spread
from movie, (select mID, max(stars) - min(stars) as spread
  from Rating group by mID) m
where movie.mID = m.mID
order by m.diff DESC, title;

-- Q9 Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980.
--    (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after.
--    Don't just calculate the overall average rating before and after 1980.) 
select t1.average - t2.average
from (select avg(s) as average
		from (select avg(stars) as s, mID 
			from Rating, Movie 
			where year < '1980' and Rating.mID = Movie.mID
			group by mID
			)  
		) t1,
	  (select avg(s) as average
	  	from (select avg(stars) as s, mID
	  		from Rating, Movie
	  		where year > '1980' and Rating.mID = Movie.mID
	  		group by mID
	  		)
		) t2;


/***************************** SQL Movie-Rating Query Exercises (extra) ********************************/
/*******************************************************************************************************/

-- Q1 Find the names of all reviewers who rated Gone with the Wind.
select distinct name
from reviewer, rating, movie
where reviewer.rID = rating.rID and rating.mID = movie.mID 
and title = 'Gone with the Wind';

-- Q2 For any rating where the reviewer is the same as the director of the movie, return the reviewer name,
--    movie title, and number of stars. 
select name, title, stars
from reviewer, movie, rating
where reviewer.rID = rating.rID and
rating.mID = movie.mID and name = director;

-- Q3 Return all reviewer names and movie names together in a single list, alphabetized. 
--    (Sorting by the first name of the reviewer and first word in the title is fine; 
--    no need for special processing on last names or removing "The".) 
select name from reviewer 
union 
select title from movie 
order by name, title;

-- Q4 Find the titles of all movies not reviewed by Chris Jackson. 
select title from movie
where mID not in (select mID from reviewer, rating
	where rating.rID = reviewer.rID and name = 'Chris Jackson');

-- Q5 For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
--    Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. 
--    For each pair, return the names in the pair in alphabetical order.
select distinct r1.name, r2.name
from reviewer r1, reviewer r2, rating a1, rating a2
where a1.mID = a2.mID
and r1.rID = a1.rID
and r2.rID = a2.rID
and r1.name < r2.name
order by r1.name, r2.name;

-- Q6 For each rating that is the lowest (fewest stars) currently in the database,
--    return the reviewer name, movie title, and number of stars.
select name, title, stars
from reviewer, rating, movie
where reviewer.rID = rating.rID
and rating.mID = movie.mID
and stars = (select min(stars) from rating);

-- Q7 List movie titles and average ratings, from highest-rated to lowest-rated.
--    If two or more movies have the same average rating, list them in alphabetical order. 
select title, avg(stars)
from movie, rating
where movie.mID = rating.mID
group by rating.mID
order by avg(stars) DESC, title;

-- Q8 Find the names of all reviewers who have contributed three or more ratings.
--    (As an extra challenge, try writing the query without HAVING or without COUNT.) 

--using having and count()
select name
from reviewer, (select rID 
		from rating 
		group by rID 
		having count(*) > 2) as T 
where reviewer.rID = T.rID;
 
-- using count()
select name
from reviewer, (select rID, count(*) as sum
   		from rating 
   		group by rID) as T
where reviewer.rID = T.rID and T.sum > 2;

 -- rate 3 distinct movies
select name
from reviewer
where (select count(distinct mID) 
       from rating
       where reviewer.rID = rating.rID) >= 3;
       
-- Q9 Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. 
--    Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 

-------with count()
select distinct title, director
from movie m1
where (select count(*) from movie m2 where m1.director = m2.director) > 1
order by director, title;

select title, director
from Movie
where director in (select director
from Movie
group by director
having count(*) > 1)
order by director, title

-------without count()
select m1.title, m1.director
from movie m1, movie m2
where m1.director = m2.director and m1.mID <> m2.mID
order by m1.director, m1.title;
   
-- Q10 Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
--     (Hint: This query is more difficult to write in SQLite than other systems; 
--     you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
select title, T.highest
from movie, (select mID, max(average) as highest 
	     from (
	     	  select mID, avg(stars) as average 
	     	  from rating 
	     	  group by mID
	     	  )
	     ) as T 
where movie.mID = T.mID;

select title, avg(stars) as average
from movie 
inner join rating using(mID)
group by mID
having average = (
	select max(average_avg) as highest
	from (
		select title, avg(stars) as average_avg
		from movie 
		inner join rating using(mID)
		group by mID
	)
);
	
-- Q11 Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
--     (Hint: This query may be more difficult to write in SQLite than other systems; 
--     you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.)
select title, T.lowest 
from movie, (select mID, min(average) as lowest 
	     from(
	     	  select mID, avg(stars) as average 
	     	  from rating 
	     	  group by mID
	     	  )
	     ) as T 
where movie.mID = T.mID;

-- Q12 For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, 
--     and the value of that rating. Ignore movies whose director is NULL. 
select director, title, max(stars)
from movie
inner join rating using(mID)
where director is not null
group by director;


/***************************** SQL Movie-Rating Modification Exercises *********************************/
/*******************************************************************************************************/

-- Q1 Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into reviewer values(209, 'Roger Ebert);

-- Q2 Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL.
insert into rating  
select rID,mID,5,null from reviewer, movie  
where name="James Cameron";

-- Q3 For all movies that have an average rating of 4 stars or higher, add 25 to the release year. 
--    (Update the existing tuples; don't insert new tuples.)
Update movie 
set year = year + 5
where mID in (select mID 
	      from (
	      	    select avg(stars) as average, movie.mID
	      	    from rating, movie
	      	    where movie.mID = rating.mID
	      	    group by mID 
	      	    having average >= 4
	      	    )
);

-- Q4 Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
delete from rating
where stars < 4 and 
      mID in (select mID  from movie where year < 1970 or year > 2000);
