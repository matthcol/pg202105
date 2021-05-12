SELECT *
FROM movies
WHERE to_tsvector('english', title) @@ to_tsquery('english', 'star & war');

create index idx_movies_title_words on movies using gin (to_tsvector('english', title));

insert into movies (title, year) values ('The War of Stars', 2021);
update movies set title = 'The War of Roses' where id = 12771924;

show default_text_search_config;

delete from play where id_movie % 2 = 0;

-- code stocké : procedure, function, triggers
call addmovies(30, 'Rocky');
select * from movies where title like 'Rocky%';

select count(distinct id_director) from movies;

create or replace function nb_directors() returns integer
as $$
declare
	v_nb_director integer;
begin
	select count(distinct id_director) into v_nb_director from movies;
	return v_nb_director;
end
$$ language plpgsql;

select nb_directors();

-----------------------------------------------------
-- CODE STOCKE  -------------------------------------
-- https://www.postgresql.org/docs/13/plpgsql.html  --
-----------------------------------------------------

------- triggers ----------------
-- https://www.postgresql.org/docs/13/sql-createtrigger.html
-- https://www.postgresql.org/docs/13/plpgsql-trigger.html

drop table tbl_log_movies;
create table tbl_log_movies (
	id serial primary key,
	username varchar(20),
	dml_timestamp timestamp with time zone,
	id_movie integer
); 

select CURRENT_TIMESTAMP;
select current_user;
insert into tbl_log_movies (username, dml_timestamp, id_movie) values ('movie', CURRENT_TIMESTAMP, 1);
select * from tbl_log_movies;


create or replace function fun_log_dml_movies() returns trigger
as $$
declare
	v_id_movie integer;
begin
	if TG_OP = 'INSERT' then 
		v_id_movie := NEW.id;
	else -- update, delete
		v_id_movie := OLD.id;
	end if;
	insert into tbl_log_movies (username, dml_timestamp, id_movie) values (current_user, CURRENT_TIMESTAMP, v_id_movie);
-- 	if TG_OP = 'INSERT' or TG_OP = 'UPDATE' then 
-- 		return  NEW;
-- 	else -- delete
-- 		return OLD;
-- 	end if; 
	-- return NEW or OLD only for before/insetead of triggers
	return NULL;
end
$$ language plpgsql;

create trigger trg_log_dml_movies
after insert or update or delete
on movies
for each row
execute function fun_log_dml_movies();


insert into movies (title, year) values ('Mission Impossible', 1996); -- id: 12771956
select * from tbl_log_movies;
update movies set genres=' Action,Thriller' where id = 12771956
	returning *;
delete from movies where id = 12771956
	returning id, title;
update movies set genres='Boxing' where title like 'Rocky%'
	returning *;
select * from tbl_log_movies;

-- same example on all tables
drop table if exists tbl_log_dml;
create table tbl_log_dml (
	id serial primary key,
	username varchar(20),
	dml_timestamp timestamp with time zone,
	id_object integer,
	tablename varchar(30),
	dml_op varchar(10)
); 

create or replace function fun_log_dml() returns trigger
as $$
declare
	v_id_object integer;
	v_tablename varchar := NULL;
begin
	if TG_OP = 'INSERT' then 
		v_id_object := NEW.id;
	else -- update, delete
		v_id_object := OLD.id;
	end if;
	insert into tbl_log_dml (username, dml_timestamp, id_object, tablename, dml_op) 
		values (current_user, CURRENT_TIMESTAMP, v_id_object, TG_TABLE_SCHEMA || '.' || TG_TABLE_NAME, TG_OP);
	return NULL;
end
$$ language plpgsql;

create trigger trg_log_dml_movies2
after insert or update or delete
on movies for each row
execute function fun_log_dml();

create trigger trg_log_dml_movies2
after insert or update or delete
on stars for each row
execute function fun_log_dml();

create trigger trg_log_dml_movies2
after insert or update or delete
on play for each row
execute function fun_log_dml();

insert into stars (name) values ('Bob Odenkirk');
select * from tbl_log_dml;

-- views --
create view vw_movies_2000s as select * from movies where year between 2000 and 2009;

select * from vw_movies_2000s;
-- update ok car 1 table + toutes les colonnes obligatoires sont dans la vue (id, title, year)
update vw_movies_2000s set genres='Sci-Fi' where id='499549';  -- avatar de 2009
select * from vw_movies_2000s where title like 'Avatar';

create view vw_movies_directors as
select m.*, s.name
from movies m join stars s on m.id_director = s.id;

select * from vw_movies_directors where title like 'Avatar';
update vw_movies_directors set genres='Adventure' where id='499549';

insert into vw_movies_directors (title, year, name) values ('Avatar 2', 2022, 'James Cameron');

-- trigger instead of --

create or replace function fun_insert_movie_director() returns trigger
as $$
declare
	v_id_director integer;
	v_id_movie integer;
begin
	-- strict => exception si 0 ou >1 results
	select id into strict v_id_director from stars where name = NEW.name;
	insert into movies (title, year, id_director) values (NEW.title, NEW.year, v_id_director)
		returning id into v_id_movie;
	NEW.id = v_id_movie;
	NEW.id_director = v_id_director;
	return NEW;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
			-- TODO : insert new director in table stars
            RAISE EXCEPTION 'director % not found', NEW.name;
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'director % not unique', NEW.name;
end
$$ language plpgsql;

create trigger trg_insert_movie_director
instead of insert on vw_movies_directors
for each row
execute function fun_insert_movie_director();

insert into vw_movies_directors (title, year, name) values ('Avatar 2', 2022, 'James Cameron');
insert into vw_movies_directors (title, year, name) values ('Avatar 3', 2022, 'Steve McQueen');
insert into vw_movies_directors (title, year, name) values ('Avatar 3', 2022, 'Matthias');
insert into vw_movies_directors (title, year, name) values ('Avatar 4', 2022, 'James Cameron') returning *;
select * from vw_movies_directors where title like 'Avatar %';
delete from movies where title like 'Avatar %';


alter table stars add column nb_direct integer;
select * from stars;

select id_director, count(id) as nb_direct
from movies
where id_director is not null
group by id_director
order by nb_direct desc;

drop procedure prc_update_stars_nb_direct;

create or replace function prc_update_stars_nb_direct(nb_stars out integer)
as $$
declare
	v_row_star record;
begin
	nb_stars := 0;
	-- cursor implicite
	for v_row_star in 
		select id_director, count(id) as nb_direct
		from movies
		where id_director is not null
		group by id_director
	loop
		update stars set nb_direct = v_row_star.nb_direct where id = v_row_star.id_director;
		nb_stars := nb_stars + 1;
	end loop;
	-- GET DIAGNOSTICS nb_stars = ROW_COUNT;
	-- nb_stars := ROW_COUNT;
end
$$ language plpgsql;

do
$$
declare
	v_nb_stars integer;
begin 
	select prc_update_stars_nb_direct() into v_nb_stars;
	raise notice 'Nb stars updated: %', v_nb_stars;
end
$$ language plpgsql;

select prc_update_stars_nb_direct();


select * from stars where name in ('Alfred Hitchcock', 'James Cameron');

-- idem en mode cursor
create or replace function fun_update_stars_nb_direct2(
	p_year smallint,
	p_nb_stars out integer)
as $$
declare
	v_row_star record;
	v_cursor_counts  cursor (pc_year smallint) for 
		select id_director, count(id) as nb_direct
		from movies
		where 
			id_director is not null
			and year = pc_year
		group by id_director;
begin
	p_nb_stars := 0;
	-- cursor explicite
	for v_row_star in v_cursor_counts(p_year)  -- open once, fetch into each iteration
	loop
		update stars set nb_direct = v_row_star.nb_direct where id = v_row_star.id_director;
		p_nb_stars := p_nb_stars + 1;
	end loop;  --close cursor
end
$$ language plpgsql;

select fun_update_stars_nb_direct2(2020::smallint);


-- transactions
insert into stars (name) values ('Jean Reno');
insert into stars (name) values ('Bourvil');
commit; rollback;  -- ATTENTION:  aucune transaction en cours
select * from stars where name in ('Jean Reno', 'Bourvil');

begin;  -- start a new transaction
insert into stars (name) values ('Fernandel');
select * from stars where name in ('Fernandel');
rollback; commit;
select * from stars where name in ('Fernandel');

select * from stars where name in ('Jean Reno', 'Bourvil', 'Fernandel', 'Louis de Funes');


-- transaction 1
begin;  -- start a new transaction
update stars set birthdate = '1900-01-01' where id = 11749108;
select * from stars where name in ('Jean Reno', 'Bourvil', 'Fernandel', 'Louis de Funes');
update stars set birthdate = '1900-01-01' where id = 11749106;
select * from stars where name in ('Jean Reno', 'Bourvil', 'Fernandel', 'Louis de Funes');
commit;

-- transaction 2 en // de 1
begin;  -- start a new transaction
update stars set birthdate = '1900-03-03' where id = 11749106;
select * from stars where name in ('Jean Reno', 'Bourvil', 'Fernandel', 'Louis de Funes');
update stars set birthdate = '1900-03-03' where id = 11749108;
select * from stars where name in ('Jean Reno', 'Bourvil', 'Fernandel', 'Louis de Funes');
commit;

begin;  -- start a new transaction
insert into stars (name) values ('Fernandel') returning id; -- 11749109
rollback;

-- fichiers de jounalisations
call addmovies(100000, 'Rambo');
select * from movies where title like 'Rambo%';

call addmovies(100000, 'Harry Potter');
select * from movies where title like 'Harry Potter%';

-- partitioning
drop table play;
drop table movies cascade;

create table movies (
	id serial,
	title varchar(250) not null,
	year smallint not null,
	duration smallint null,
	genres varchar(200) null,
	synopsis text null,
	poster_uri varchar(300),
	id_director int null,
	constraint pk_movies primary key (id, year)
) PARTITION BY RANGE (year);

create table movies_hist (
	id serial,
	title varchar(250) not null,
	year smallint not null,
	duration smallint null,
	genres varchar(200) null,
	synopsis text null,
	poster_uri varchar(300),
	id_director int null,
	constraint pk_movies_hist primary key (id, year)
) PARTITION BY RANGE (year);


CREATE TABLE movies_2000s PARTITION OF movies
    FOR VALUES FROM (2000) TO (2009);
CREATE TABLE movies_2010s PARTITION OF movies
    FOR VALUES FROM (2010) TO (2019);
CREATE TABLE movies_2020s PARTITION OF movies
    FOR VALUES FROM (2020) TO (2029);


insert into movies (title, year) values ('Rambo', 2000);
insert into movies (title, year) values ('Rocky', 2015);

select * from movies;
select * from movies_2000s;
select * from movies_2010s;
select * from movies_2020s;
alter table movies detach partition movies_2000s; 
alter table movies attach partition movies_2000s
    FOR VALUES FROM (2000) TO (2009);
alter table movies_hist attach partition movies_2000s
    FOR VALUES FROM (2000) TO (2009);
select * from movies_hist;

update movies set year = 2025 where id = 3;

select * from movies where id = 3;










