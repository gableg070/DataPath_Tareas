
use db_universities;

# Primer enunciado 

SELECT u.university_name , (uy.pct_international_students) as Porcentaje_internacional, uy.num_students, uy.year
FROM university_year uy
inner join university u on uy.university_id = u.id
where uy.year = (Select max(year) from university_year)
order by Porcentaje_internacional desc
limit 3;

# Segundo enunciado 

select distinct u.university_name, rc.criteria_name , an3.year, an3.score, an2.year, 
an2.score, ur.year, ur.score
from university_ranking_year ur
inner join university u on ur.university_id = u.id 
inner join ranking_criteria rc on ur.ranking_criteria_id = rc.id
inner join university_ranking_year an2 on ur.university_id = an2.university_id and ur.year = an2.year + 1
inner join university_ranking_year an3 on ur.university_id = an3.university_id and ur.year = an3.year + 2
where ur.year  >= (select MAX(year) from university_ranking_year)
and ur.score > an2.score
and an2.score > an3.score
group by u.university_name, rc.criteria_name;

# Tercer Enunciado 

WITH TopUniversidades AS (
  SELECT u.university_name as Universidad, (Sum(ur.score)/Count(rc.id)) as top, ur.year as ultimo_anio
  FROM university_ranking_year ur
  inner join university u on ur.university_id = u.id 
  inner join ranking_criteria rc on ur.ranking_criteria_id = rc.id
  where ur.year = (select MAX(year) from university_ranking_year)
  GROUP BY Universidad 
  ORDER BY top DESC
  LIMIT 5
)

select distinct c.country_name as Pais_Top_universidad,  y.pct_international_students porcentaje_internacional, ur.year from university_ranking_year ur 
inner join university u on ur.university_id = u.id
inner join university_year y on u.id = y.university_id
inner join country c on c.id = u.country_id
where u.university_name in (select Universidad from TopUniversidades)
and ur.year = (select MAX(year) from university_ranking_year)
group by Pais_Top_universidad
order by porcentaje_internacional desc;

# Cuarto Enunciado 

With sistema_mayores_criterios as (
select rs.id as ID, rs.system_name as Sistema, count(rc.criteria_name) as total_criterios from ranking_system rs 
inner join ranking_criteria rc on rs.id = rc.ranking_system_id
group by rs.system_name
order by total_criterios desc
limit 1
), 

obtener_criterios as (
	select rc.ranking_system_id, rc.id ID , rc.criteria_name Name from ranking_criteria rc
    where rc.ranking_system_id = ( select ID from sistema_mayores_criterios)
),

obtener_anio_reciente as (
select distinct ur.year anio
from university_ranking_year ur
inner join university u on ur.university_id = u.id
inner join obtener_criterios oc on ur.ranking_criteria_id = oc.ID
order by anio desc
limit 1 )

select (select Sistema from sistema_mayores_criterios) as Sistema, 
(select total_criterios from sistema_mayores_criterios) as Cantidad_criterios,
 u.university_name as Universidad, Sum(ur.score) as Total_puntaje_en_sistema, ur.year as Anio
from university_ranking_year ur
inner join university u on ur.university_id = u.id
inner join ranking_criteria oc on ur.ranking_criteria_id = oc.ID
where ur.year = (select anio from obtener_anio_reciente) 
and ur.ranking_criteria_id in (select ID from obtener_criterios)
group by ur.university_id
order by Total_puntaje_en_sistema desc
limit 1;

# Quinto Enunciado 

WITH TopUniversidad AS (
  SELECT u.id id , u.university_name as Universidad, (Sum(ur.score)) as top, ur.year as ultimo_anio
  FROM university_ranking_year ur
  inner join university u on ur.university_id = u.id 
  inner join ranking_criteria rc on ur.ranking_criteria_id = rc.id
  where ur.year = (select MAX(year) from university_ranking_year)
  GROUP BY Universidad 
  ORDER BY top DESC
  LIMIT 1
),

Pais_Uni as (
select c.country_name as Pais, u.country_id Cid, tp.top, ur.year from university_ranking_year ur 
inner join university u on ur.university_id = u.id
inner join university_year y on u.id = y.university_id
inner join country c on c.id = u.country_id
inner join TopUniversidad tp on u.id = tp.id
where ur.year = (select MAX(year) from university_ranking_year)
group by pais
limit 1)


select rs.system_name nombre_sistema,
 (select Universidad from TopUniversidad) TopUniversidad,
 (select Pais from Pais_Uni) as Pais,
 Avg(ur.score) as Promedio,
 ur.year from ranking_system rs
inner join ranking_criteria rc on rs.id = rc.ranking_system_id
inner join university_ranking_year ur on rc.id = ur.ranking_criteria_id 
inner join university u on u.id = ur.university_id
where u.country_id = (select Cid from Pais_Uni)
and ur.year = (select MAX(year) from university_ranking_year)
group by nombre_sistema
order by Promedio desc;





