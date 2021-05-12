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

select *  from pg_stat_activity where usename in ('movie', 'matthias');
select * from pg_stat_statements where query like '%movies%';
create extension pg_stat_statements;
select pg_reload_conf();
drop extension pg_stat_statements;

select relation, pid, mode, granted  from pg_locks where relation in (
	select oid from pg_class where relname = 'movies') order by pid;
	
select pg_terminate_backend(8740);	
select * from pg_statistic;
select * from pg_stats;
SELECT attname, inherited, n_distinct,
       array_to_string(most_common_vals, E'\n') as most_common_vals
FROM pg_stats
WHERE tablename = 'movies';


-- locks on transactions
select * from pg_locks where relation = (select oid from pg_class where relname = 'stars')
order by pid;

-- en cours : RowExclusiveLock + AccessShareLock
-- en attente : RowExclusiveLock + ExclusiveLock

select pg_terminate_backend('8560');
select pg_terminate_backend('12876'); -- sûr d'arreter
select pg_cancel_backend('12876');  -- trop gentil 

-- edition fichier postgresql.conf
-- connections
listen_addresses = '*'	
port = 5432				
max_connections = 100
-- wal
wal_level = replica
archive_mode = on	
archive_command = 'copy "%p" "C:\\PGDATA\\BackupWAL\\%f"'		# command to use to archive a logfile segment
-- force finalisation of wal : checkpoint_timeout = 5min
-- force rotation for archiving wal : archive_timeout = 600 # en secondes 





