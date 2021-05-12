-- clean previous schema/user (dev/test only)
drop schema if exists sc_vehicules CASCADE;
drop user if exists u_vehicule;
-- create user
CREATE user u_vehicule LOGIN PASSWORD 'password';
-- create schema
create schema sc_vehicules authorization u_vehicule;
alter user u_vehicule set search_path=sc_vehicules;
-- play rest of script as u_vehicule
set role u_vehicule;
-- search_path is not up to date yet
set search_path=sc_vehicules;

\i ddl_vehicules.sql
\i data_vehicules.sql