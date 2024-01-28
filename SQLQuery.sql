--select *
--from PortfolioProject..coviddeaths$
--order by 3,4


--select *
--from PortfolioProject.dbo.covidvaccinations$
--order by 3,4

--Essencial columns
--select location, date, population, total_cases, new_cases, total_deaths
--from PortfolioProject..coviddeaths$
--order by 1,2

----total cases vs total deaths
select location, date, population,total_cases, total_deaths, CONVERT (float, total_deaths) / CONVERT(float, total_cases) as Death_percentage
from PortfolioProject..coviddeaths$
where location like '%states%'
order by 1,2

--total cases vs population
--select location, date, population, total_cases, (total_cases/population)*100 as Cases_percentage
--from PortfolioProject..coviddeaths$
--order by 1,2

--Max infected cases vs population
select location, population,date, max(total_cases) as max_infected, max((total_cases/population))*100 as Maxcases_percentage
from PortfolioProject..coviddeaths$
group by location, population,date
order by Maxcases_percentage desc
--where location = 'india'
--Group by location, population

--Highest death per population(Location)
select location, max(convert(float,total_deaths)) as Totaldeath_Count
from PortfolioProject..coviddeaths$
where continent is not null
Group by location
order by Totaldeath_Count desc
--(Continent)
select continent, max(convert(float,total_deaths)) as Totaldeath_Count
from PortfolioProject..coviddeaths$
where continent is not null
Group by continent
order by Totaldeath_Count desc

--New deaths percentage
select date, sum(new_cases) as Total_newcases , sum(new_deaths) as Total_newdeaths, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as Total_newdeathpercentage
from PortfolioProject..coviddeaths$
where continent is not null
group by date
order by 1

select sum(new_cases) as Total_newcases , sum(new_deaths) as Total_newdeaths, sum(new_deaths)/nullif(sum(new_cases), 0)*100 as Total_newdeathpercentage
from PortfolioProject..coviddeaths$
where continent is not null
order by 1,2

--Total population vs new_vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as Rollingtotalvaccinations
from PortfolioProject..coviddeaths$ as dea
join PortfolioProject..covidvaccinations$ as vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE
with popvsvac (continent, location, date, population, new_vaccinations, Rollingtotalvaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as Rollingtotalvaccinations
from PortfolioProject..coviddeaths$ as dea
join PortfolioProject..covidvaccinations$ as vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rollingtotalvaccinations/population)*100
from popvsvac

--Use temp table

create table #Percentpopulationvaccination
 (
continent nvarchar(220),
location nvarchar(220),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingtotalvaccinations numeric
)


 insert into #Percentpopulationvaccination
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as Rollingtotalvaccinations
from PortfolioProject..coviddeaths$ as dea
join PortfolioProject..covidvaccinations$ as vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (Rollingtotalvaccinations/population)*100
from #Percentpopulationvaccination

--Creating view data to visualize later

CREATE VIEW Percentpopulationvaccination as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(Convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as Rollingtotalvaccinations
from PortfolioProject..coviddeaths$ as dea
join PortfolioProject..covidvaccinations$ as vac
on dea.location = vac.location and
   dea.date = vac.date
where dea.continent is not null
--order by 2,3

SELECT *
FROM Percentpopulationvaccination




