.mode box
PRAGMA foreign_keys = on;

drop table if exists zus;
drop table if exists voisins;
drop table if exists departements;
drop table if exists regions;


create table regions (
	rid char(5) primary key,
	nom varchar(60),
	chefLieu varchar(60)
);

create table departements (
	code numeric(3) primary key,
	nom varchar(60) UNIQUE,
	prefecture varchar(60),
	rid char(5),
	foreign key (rid) references regions
);

create table voisins (
	rid1 char(5),
	rid2 char(5),
	primary key (rid1,rid2),
	foreign key (rid1) references regions,
	foreign key (rid2) references regions
);

create table zus (
	departement varchar(60),
	commune varchar(60),
	quartier varchar(60),
	primary key(departement,commune,quartier),
	foreign key (departement) references departements(nom)
);

.separator ','
.import 'regions.csv' regions
.import 'departements.csv' departements
.import 'voisins.csv' voisins
.separator ';'
.import 'zus.csv' zus
