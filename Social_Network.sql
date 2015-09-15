/* The schema is
  Highschooler ( ID, name, grade )
  English: There is a high school student with unique ID and a given first name in a certain grade.

  Friend ( ID1, ID2 )
  English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is in the Friend table, so is (456, 123). 

  Likes ( ID1, ID2 )
  English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456) is in the Likes table, there is no guarantee that (456, 123) is also present. 
*/

/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;

/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);

/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);

insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;

insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);

/************************************SQL Social-Network Query Exercises (core set)************************************/
/*********************************************************************************************************************/
-- Q1 Find the names of all students who are friends with someone named Gabriel. 
select name
from highschooler
where ID in(select ID1 
            from friend 
            where ID2 in 
              (select ID 
              from highschooler 
              where name = 'Gabriel'
              )
            );

-- Q2 For every student who likes someone 2 or more grades younger than themselves, 
--    return that student's name and grade, and the name and grade of the student they like. 
select hname, hgrade, lname, lgrade
from (select h1.name as hname, h1.grade as hgrade, h2.name as lname, h2.grade as lgrade
      from highschooler h1, highschooler h2, likes
      where h1.ID = ID1 and h2.ID = ID2
            and h1.grade - h2.grade >= 2
      );

-- Q3 For every pair of students who both like each other, return the name and grade of both students. 
--    Include each pair only once, with the two names in alphabetical order.
select h1.name, h1.grade, h2.name, h2.grade
from highschooler h1, highschooler h2, likes l1, likes l2
where l1.ID1 = l2.ID2 and l2.ID1 = l1.ID2 
      and h1.ID = l1.ID1 and h2.ID = l1.ID2
      and h1.name < h2.name;

-- Q4 Find all students who do not appear in the Likes table (as a student who likes or is liked) and 
--    return their names and grades. Sort by grade, then by name within each grade.
select name, grade
from highschooler
where ID not in (select ID1 from likes union select ID2 from likes)
order by grade, name;

-- Q5 For every situation where student A likes student B, but we have no information about whom B likes 
--    (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. 
select h1.name, h1.grade, h2.name, h2.grade
from highschooler h1, highschooler h2, likes
where h1.ID = ID1 and h2.ID = ID2 
      and h2.ID not in (select ID1 from likes);

-- Q6 Find names and grades of students who only have friends in the same grade. 
--    Return the result sorted by grade, then by name within each grade. 
select name, grade
from highschooler
where ID not in (select ID1 
                 from friend, highschooler h1, highschooler h2 
                 where h1.ID = ID1 and h2.ID = ID2 
                       and h1.grade <> h2.grade)
order by grade, name;

-- Q7 For each student A who likes a student B where the two are not friends, 
--    find if they have a friend C in common (who can introduce them!). 
--    For all such trios, return the name and grade of A, B, and C. 
select distinct h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
from highschooler h1, highschooler h2, highschooler h3, friend f1, friend f2, likes
where h1.ID = likes.ID1 and h2.ID = likes.ID2
      and h2.ID not in (select friend.ID2 from friend where h1.ID = friend.ID1)
      and h1.ID = f1.ID1 and h2.ID = f2.ID1
      and f1.ID2 = h3.ID and f2.ID2 = h3.ID;

-- Q8 Find the difference between the number of students in the school and the number of different first names. 
select count(distinct ID) - count(distinct name) 
from highschooler;

-- Q9 Find the name and grade of all students who are liked by more than one other student. 
select name, grade 
from highschooler
where ID in (select ID2 
             from likes 
             group by ID2 
             having count(distinct ID1) > 1
            );

select name, grade
from highschooler,
    (select ID2, count(ID2) as num from likes group by ID2)
where num > 1 and ID2 = ID;


/***************************************SQL Social-Network Query Exercises (extra)************************************/
/*********************************************************************************************************************/
-- Q1 For every situation where student A likes student B, but student B likes a different student C, 
--    return the names and grades of A, B, and C. 
select h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
from highschooler h1, highschooler h2, highschooler h3, likes l1, likes l2
where h1.ID = l1.ID1 and h2.ID = l1.ID2 and h2.ID = l2.ID1 and h3.ID = l2.ID2
      and l1.ID1 <> l2.ID2;

select h1.name, h1.grade, h2.name, h2.grade, h3.name, h3.grade
from highschooler h1, highschooler h2, highschooler h3, likes l1, likes l2
where h1.ID = l1.ID1 and l1.ID2 = h2.ID and h3.ID = l2.ID2 
and l1.ID1 <> l2.ID2 and l1.ID2 = l2.ID1;

-- Q2 Find those students for whom all of their friends are in different grades from themselves. 
--    Return the students' names and grades. 
select name, grade 
from highschooler
where ID not in (select h1.ID from highschooler h1, highschooler h2, friend
                 where h1.ID = ID1 and h2.ID = ID2 and h1.grade = h2.grade);

-- Q3 What is the average number of friends per student? (Your result should be just one number.)
select avg(counts)
from (select count(ID2) as counts
      from friend
      group by ID1
     );

-- Q4 Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. 
--    Do not count Cassandra, even though technically she is a friend of a friend.
select count(distinct f1.ID2) + count(distinct f2.ID2) 
from highschooler, friend f1, friend f2
where name = 'Cassandra'
      and ID = f1.ID1 -- direct friend
      and f1.ID2 = f2.ID1 -- friends of friends of
      and f2.ID1 <> ID
      and f2.ID2 <> ID;

-- Q5 Find the name and grade of the student(s) with the greatest number of friends.
select name, grade 
from highschooler, (select ID1, max(counts) 
                    from (
                          select ID1, count(*) as counts 
                          from friend group by ID1
                          )
                   ) T
where ID = T.ID1 ;
