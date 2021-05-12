-- DDL model cars for development/test in DROP/CREATE mode
drop table if exists tbl_modeles;
create table tbl_modeles(
	id int generated always as identity -- by default as identity 
		constraint pk_tbl_modeles primary key,
	marque varchar(25) NOT NULL,
	annee smallint NULL,
	prix decimal(9,2) NULL
);