select 
	s.*,  -- tte colone de la table stars 
	count(m.id) as nb_movies
from 
	movies m 
	join stars s on m.id_director = s.id
group by s.id  --, s.name, s.birthdate, s.deathdate  -- par primary key de stars
order by nb_movies desc;


select 
	s.*,  -- tte colone de la table stars 
	count(m.id) as nb_movies,
	coalesce(sum(m.duration), 0) as total_duration
from 
	stars s
	left join movies m  on m.id_director = s.id
--where lower(s.name) = 'steve mcqueen'	
-- where s.name = 'Steve McQueen'	
-- where s.name ~* 'steve mcqueen'   -- regexp
where s.name ilike 'steve mcqueen'   -- insensitive case like
group by s.id  --, s.name, s.birthdate, s.deathdate  -- par primary key de stars
order by nb_movies desc;


select 
	s.*, -- tte colonne de la table stars
	count(m.id) as nb_movies,
	string_agg(m.title, ', ') as titles
from 
	movies m
	join stars s
on m.id_director = s.id
group by s.id -- par primary key de stars
having count(m.id) = 5;

select 
	rank() over (order by m.duration desc nulls last) rg, 
	count(*) over (partition by m.id_director range current row) nb_movies,
	(select count(*) from play p where p.id_actor = m.id_director) nb_plays,
	m.* 
from movies m 
-- where m.year = 2010
order by nb_movies desc;

update movies set duration = 100 where id = 1634106;


select * from movies where title ='The Man Who Knew Too Much';

select * 
from 
	movies m
	join stars s on m.id_director = s.id
where m.title ='The Man Who Knew Too Much';

select * from stars where id = 33;
select * from stars where name = 'Steve McQueen';
select * from stars where name ilike 'steve mcqueen';
select * from stars where name like 'Steve %';
select * from stars where lower(name) = 'steve mcqueen';

select * from stars where birthdate between '1930-01-01' and '1930-03-31';
select * from movies where year = 2010;
select * from movies order by year;
select * from movies m where m.id_director = 33;

drop index idx_stars_name;
-- create index idx_stars_name on stars(name); -- binary tree index
create index idx_stars_name on stars(lower(name)); 
create index idx_stars_bdate on stars(birthdate); 
create index idx_movies_iddirector on movies(id_director);
create index idx_movies_year on movies(year);   -- 1400 films sur 140 ans => 10 films par entree d'index



select * from pg_indexes where schemaname='movie'; 

-- binary tree index : coût O(log(n))
-- n = 1000 => 10
-- n = 1000000 => 20
-- n = 1G => 30

-- sort cost : n log(n)
-- n = 1000 => 10 000
-- n = 1 000 000 => 20 000 000
-- n = 1G => 30G 



