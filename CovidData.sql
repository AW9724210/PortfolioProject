select * from CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location in ('vietnam', 'united States')
order by 1,2

--Total cases vs Pop
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from CovidDeaths
where location in ('vietnam', 'united States')
	and continent is not null
order by 1,2

--Countries wwith highest infection rate
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--Countries wwith highest death rate
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--Continent with highest death rate
select location, max(cast(total_deaths as int)) as HighestDeathCount
from CovidDeaths
where continent is null
and location not in ('world', 'upper middle income', 'high income', 'lower middle income', 'low income', 'european union')
group by location
order by 2 desc
--
with PopvsVac --(continent, location, date, population,new_vaccinations, acc_vaccination)
as
(
select 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) acc_vaccination
from CovidDeaths dea
join CovidVaccination vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 1,2
)
select *, (acc_vaccination/population)*100 as percentage_vaccinated
from popvsvac

--create view
create view percentage_vaccinated as 
select 
	dea.continent
	,dea.location
	,dea.date
	,dea.population
	,vac.new_vaccinations
	,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) acc_vaccination
from CovidDeaths dea
join CovidVaccination vac
	on dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null