/*Inspecting the data*/
select * from literacy
select * from population

---number of rows into our dataset

select count(*) from literacy
/*Total literacy count 640*/

select count(*) from population
/*Total literacy count 640*/

--- dataset from jhakhand and bihar
select * from literacy where state in ('Jhakhand', 'Bihar');

---Population in India
select sum(population) as "Total Population in India" from population;
/*Total Population: 1,201 million*/

---Average Growth in India state wise
select state, round(avg(growth)*100, 2) as "Average Growth Rate" from literacy group by state order by state;

---avg sex ratio in India state wise
select state, round(avg(sex_ratio), 0) as Average_Sex_Ratio from literacy group by state order by Average_Sex_Ratio desc;
/*Kerala has the highest average sex ration in India*/

--avg literacy rate
select state, round(avg(literacy), 0) as Average_Literacy_Rate from literacy
group by state having round(avg(literacy), 0)>90 order by Average_Literacy_Rate desc;
/*Kerala and Lakshadeep has average literacy rate more then 90*/

--- top 3 state showing highest growth rate
select state, round(avg(growth*100),2) as avg_growth_rate from literacy group by state order by avg_growth_rate desc limit 3;
/*Nagaland, Dadra and Nagar Haveli & Daman and Diu has the highest growth rate*/

---bottom 3 state showing lowest growth rate
select state, round(avg(growth*100),2) as avg_growth_rate from literacy group by state order by avg_growth_rate asc limit 3;
/*Lakshadweep, Kerala & Andaman And Nicobar Islands has the lowest growth rate*/


---top and bottom 3 states in literacy state
drop table if exists topstates;
create table topstates
( state varchar(40),
  topstate float
)

insert into topstates
select state, round(avg(literacy),0) avg_literacy_ratio from literacy 
group by state order by avg_literacy_ratio desc;

select limit 3 * from topstates order by topstates.topstate desc;
/*Kerala, Lakshadweep & Mizoram has the highest literacy rate*/

---bottom states
drop table if exists bottomstates
create table bottomstates
( state varchar(255),
  bottomstate float
)

insert into bottomstates
select state, round(avg(literacy),2) avg_literacy_ratio from literacy
group by state order by avg_literacy_ratio asc

select * from bottomstates order by bottomstates.bottomstate asc
/*Bihar, Arunachal Pradesh & Rajasthan has the lowest literacy rate*/

--union operator
select * from(
select top 3 * from topstates order by topstates.topstate desc) a
UNION
select * from(
select top 3 * from bottomstates order by bottomstates.bottomstate asc) b;

--- states starting with letter a or ending with d
select state from literacy where lower(state) like 'a%' or lower(state) like '%d'

---joining both table

--- Total count of males and females
-- males = population/(sex_ratio+1)
--females = population - (population/(sex_ratio+1))
select d.state, sum(d.Males) Total_Males, sum(d.females) Total_females from
(select c.district, c.state state, round(c.population/(c.sex_ratio+1), 0) Males, round((c.population*c.sex_ratio)/(c.sex_ratio+1), 0) Females from
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from literacy a INNER JOIN population b on a.district = b.district)c ) d
group by d.state order by d.state

---Total Literacy rate
--total literate ppl / population = literacy_ratio
--total literate ppl = literacy_ratio * population
--total iliterate ppl = (1-literacy_ratio)*population
select d.state, sum(d.literate_people) total_literate_people, sum(d.iliterate_people) total_iliterate_people from
(select c.district, c.state, round(c.literacy_ratio*c.population,0) literate_people, round((1-c.literacy_ratio)*c.population, 0) iliterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from literacy a INNER JOIN population b on a.district = b.district)c ) d
group by d.state order by d.state

---Population in previous census
--population = previous_census + growth * previous_census
-- previous_census = population/(1+growth)

select sum(e.tot_prevcen_pop) previous_census_population, sum(e.curr_pop) current_population from
(select d.state, sum(previous_census_population) as tot_prevcen_pop, sum(d.population) curr_pop from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.population from
(select a.district, a.state, a.growth growth, b.population from literacy a INNER JOIN population b on a.district = b.district) c) d
group by d.state order by d.state) e
/*previous_census_population has population of 1005 million & current_population has population of 1184 million*/

--Population vs area

select round(m.total_area/m.previous_census_population,4) Prevcen_vs_area, round(m.total_area/m.current_population,4) currpop_vs_area from
(select y.*, z.* from(
select '1' as keyy, f.* from
(select sum(e.tot_prevcen_pop) previous_census_population, sum(e.curr_pop) current_population from
(select d.state, sum(previous_census_population) as tot_prevcen_pop, sum(d.population) curr_pop from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.population from
(select a.district, a.state, a.growth growth, b.population from literacy a INNER JOIN population b on a.district = b.district) c) d
group by d.state order by d.state) e) f) y inner join
(select '1' as keyy, x.* from
(select sum(area_km2) Total_area from population)x )z on y.keyy = z.keyy) m
/*Prevcen_vs_area is 0.0031 and currpop_vs_area is 0.0027*/

---top 3 districts from each state with higher literacy rate
select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from literacy) a
where a.rnk in(1,2,3) order by state






