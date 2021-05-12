--show search_path
-- DDL model cars for development/test in DROP/CREATE mode

-- with id serial
drop table if exists tbl_modeles;
create table tbl_modeles(
 	id serial constraint pk_tbl_modeles primary key,
 	marque varchar(25) NOT NULL,
 	annee smallint NULL,
 	prix decimal(9,2) NULL
);

-- with id generated as identity
drop table if exists tbl_modeles;
create table tbl_modeles(
	id int generated always as identity -- by default as identity 
		constraint pk_tbl_modeles primary key,
	marque varchar(25) NOT NULL,
	annee smallint NULL,
	prix decimal(9,2) NULL
);

insert into tbl_modeles (marque) values ('Ferrari');
insert into tbl_modeles (marque, annee, prix) values ('Toyota', 2014, 10000.21);
insert into tbl_modeles (id,marque) values (100,'Honda');
insert into tbl_modeles (marque) values ('Renault');

select * from tbl_modeles;

select nextval('tbl_modeles_id_seq'::regclass);
select currval('tbl_modeles_id_seq');
select setval('tbl_modeles_id_seq', 100);

select * from pg_sequences;
select * from pg_tables where tableowner='u_vehicule';
select * from pg_indexes where schemaname='sc_vehicules';
