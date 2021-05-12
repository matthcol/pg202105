select * from pg_database;
select oid, * from pg_database;
-- db_movies with oid "16498"

select * from pg_tables;
select * from pg_indexes;
-- objects tables (r), indexes (i), sequences (S) of schema movie
-- oid : id de l'objet
-- relname : name of object
-- relnamespace : oid du schema
-- relowner : oid du user owner
-- relkind : type de l'object (table, sequence, index, ...)
-- relfilenode : name of the file (can change after vacuum full)
select * from pg_class 
where -- relname !~ '^pg_.*';
	relnamespace = (select oid from pg_namespace where nspname = 'movie');
-- table movies with oid "16511" 120 ko with _fsm & _vm
vacuum  movie.movies; -- maj _fsm et _vm
vacuum full movie.movies;  -- copy data in new file
vacuum full; -- db_movies

-- table play : 3 568 Ko before vacuum full (after delete 1/2 rows)
vacuum movie.play;
vacuum full movie.play; -- new file size 1536 ko


-- tbs
CREATE TABLESPACE tbs_cars_sellings
  OWNER postgres
  LOCATION 'C:\PGDATA\OtherDisk\PG_TBS';
  
GRANT CREATE ON TABLESPACE tbs_cars_sellings TO u_vehicule;  

select * from pg_class 
where 
	relnamespace = (select oid from pg_namespace where nspname = 'sc_vehicules');
	
select * from pg_tablespace;
-- no directory stored but links in pgdata/pg_tblspc



