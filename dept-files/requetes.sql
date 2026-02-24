--q2

select code,nom 
from departements 
where prefecture = 'Bourges';

--q3

select code,d.nom,prefecture,r.nom 
from regions r, departements d 
where r.rid = d.rid;

--q4

select r.nom,chefLieu,code,d.nom,prefecture 
from regions r,departements d 
where r.rid = d.rid 
order by r.nom asc;

--q5

select code,d.nom,prefecture 
from regions r, departements d 
where r.rid = d.rid and r.nom = 'Centre-Val de Loire';

--q6

select count(*) as nb 
from voisins;

--q7

drop view if exists voisinsSym; 
create view voisinsSym as
select rid1, rid2 from voisins
UNION
select rid2 as rid1, rid1 as rid2 from voisins; 
select * from voisinsSym;

--q7 bis
select count(*) as nb_total_voisins
from voisinsSym;
--Le résultat (46)  est le double du résultat précédent (23) ce qui est coherent parce que pour chaque ville on a ajouté son sym

--q8
drop view if exists voisinsSymNoms; 
create view voisinsSymNoms as select r1.nom as Region1, r2.nom as Region2 
from regions r1,regions r2,voisinsSym v 
where r1.rid=v.rid1 and r2.rid=v.rid2; 
select * from voisinsSymNoms;

--q8 bis
select r.nom as region, count(v.Region2) as nb_voisins
from regions r
left join voisinsSymNoms v on v.Region1 = r.nom
group by r.nom
order by nb_voisins desc;

--q9
--Critiques:
--Il y'a des champs multi‑valeurs dans une cellule : une “commune” peut contenir plusieurs communes (séparées par virgules, “et”, tirets, parenthèses, arrondissements…) et ça viole la 1ere forme normale (valeurs atomiques) et complique les jointures.

--q10

select departement,commune,quartier 
from zus 
where commune LIKE '%(%)';
--Ce choix de stockage mélange deux informations différentes dans un même champ (commune + code département)
--donc ce n'est plus atomique. ça peut rendre les jointures difficiles. Je trouve mieux de séparer les 2 attributs, une colonne pour le nom de la commune et une autre pour son code_departement. 

--q11
drop view if exists zus_pref; 
create view zus_pref as 
	select departement,commune,quartier 
	from zus,departements 
	where commune = prefecture  
	or commune like prefecture || ' %'
	or commune like prefecture || ',%'
	or commune like '%, ' || prefecture
	or commune like '%,  ' || prefecture
	or commune like '%-' || prefecture; 
select * from zus_pref;

--q11 bis
select count(*) as nb,'Total' as type
from zus
UNION ALL
select count(*) as nb, 'Oui' as type
from zus_pref
UNION ALL
select count(*) as nb, 'Non' as type
from zus
where (departement,commune,quartier) not in (select departement,commune,quartier from zus_pref);

--q12
select d.code, d.nom as departement, r.nom as region, count(z.quartier) as nb_zus
from departements d
join regions r on r.rid = d.rid
left join zus z on z.departement = d.nom
group by d.code, d.nom, r.nom
order by nb_zus DESC, d.nom ASC;

--q13
select r.nom, count(*) as nb_zus_reg 
from zus z, departements d, regions r 
where z.departement = d.nom and d.rid = r.rid 
group by r.rid 
order by nb_zus_reg desc;

--q14V1
select r.nom
from regions r
where not exists (
	select * 
	from departements d 
	where d.rid = r.rid and not exists (
      		select *
      		from zus z
      		where z.departement = d.nom
    	)
);

--q14V2
select r.nom
from regions r
join departements d on d.rid = r.rid
left join zus z on z.departement = d.nom
group by r.rid, r.nom
having count(DISTINCT d.code)
     = count(DISTINCT CASE WHEN z.quartier IS NOT NULL THEN d.code END);
