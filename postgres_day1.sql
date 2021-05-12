-- schema serie with owner user movie
CREATE SCHEMA serie
    AUTHORIZATION movie;
	
-- create new database on theme cars (french names)
CREATE DATABASE db_vehicules ENCODING = 'UTF8';  -- ISO-8859-1/ISO-8859-15/CP1252 sur 1 octet
select * from pg_database;

CREATE user u_vehicule WITH	LOGIN PASSWORD 'password';
alter user u_vehicule set search_path=sc_vehicules;

-- on db db_vehicules
create schema sc_vehicules authorization u_vehicule;
