create table tbl_achats (
	id serial constraint pk_tbl_achats primary key,
	id_modele int,
	date_achat date
) tablespace tbs_cars_sellings;
-- droit refusé pour le tablespace tbs_cars_sellings
-- ok after grant create on tablespace ...