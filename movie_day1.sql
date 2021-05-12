-- schema movie
select count(*) from movies;
select count(*) from movie.movies;

show search_path
-- "$user", public

-- schema public
select * from languages;
select * from public.languages;

-- schema serie
select * from series; -- la relation « series » n'existe pas
select * from serie.series;

-- for this session only
set search_path="$user",public,serie
show search_path  -- "$user", public, serie
select * from series;

-- set search_path permanently
alter user movie set search_path="$user",public,serie;

select 0.1::numeric, 0.1::numeric * 3;
select 0.1::real, 0.1::real * 3; -- 0.1 (10) = 0.000110011001100..

select * from stars where birthdate = '1930-03-24';
select * from stars where birthdate = '24/03/1930'::date;
select * from stars where birthdate = '01/06/1926'; -- 1er juin avec DMY
select * from stars where birthdate = '06/01/1926'; -- 1er juin avec MDY

show datestyle;
set datestyle=ISO,MDY;
set datestyle=SQL,DMY; -- input+output

select CURRENT_USER, CURRENT_DATE, CURRENT_TIMESTAMP, CURRENT_TIME;

select * from stars where extract(year from birthdate)  = 1930;
select name, to_char(birthdate, 'DD TMMonth YYYY') from stars where name='Steve McQueen';

select CURRENT_DATE, CURRENT_DATE + 7; 
select '2021-02-28'::date + 1, '2020-02-28'::date + 1; 
select ('2021-02-28'::date + interval '2 days')::date; 

select current_date - '2021-02-28'::date;

select current_timestamp - '2021-02-28 12:00:00'::timestamp;

-- text function : lower, upper, substring, left, right
select upper(name) from stars;

select max(length(title)) from movies;
select title from movies where length(title) = (select max(length(title)) from movies);

select 'été' < 'étuve';
select 'mañana' < 'mano'; -- true in French, False in Spanish

select 'Port Louis' < '東京';  -- meaning ??

select * from pg_database;
show lc_collate; -- "French_France.1252"
show lc_ctype; -- "French_France.1252"

























