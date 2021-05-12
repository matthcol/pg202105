-- change password of user postgres
ALTER USER postgres	PASSWORD 'passw@rd';
-- remove password of user movie (need other auth method : peer/trust/ldap/...)	
alter user movie password null;

-- user fan for read only access
create user fan login password null;
alter user fan set search_path=movie;
grant usage on schema movie to fan;
-- table by table
grant select on movie.movies to fan;
grant select on movie.stars to fan;
grant select on movie.play to fan;
-- revoke privilege
revoke select on movie.movies from fan;

-- better: all table at once
grant select on all tables in schema movie to fan; -- table + view

------------------------------------------------------------------
-- user u_movie_admin
create user u_movie_admin LOGIN password null;
alter user u_movie_admin set search_path=movie;
grant usage on schema movie to u_movie_admin;
grant all privileges on all tables in schema movie to u_movie_admin;
-- for insert in tables with generated with sequence,
-- we need usage privilege on sequence objects
grant usage on all sequences in schema movie to u_movie_admin;





