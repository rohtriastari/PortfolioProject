--select * from Portfolio..CovidVaccinations order by 3,4

--select data that we are going to use
--select Location,date,total_cases,new_cases,total_deaths,population from Portfolio..CovidDeaths order by 1,2

--1 total cases vs total deaths per location --> the percentage
--shows likelihood of dying if you contract covid in your country
select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as percentage
from Portfolio..CovidDeaths
where location like '%indonesia%'
order by 1,2

--loking at the total cases vs the populations
select Location,date,total_cases,population,(total_cases/population)*100 as percentage
from Portfolio..CovidDeaths
where location like '%indonesia%'
order by 1,2

--looking at countries with highest infection rate compared to population
select Location,population,max(total_cases) as HighestInfectionCount, 
	max(total_cases/population)*100 as PercentPopulationInfected
from Portfolio..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--showing countries with Highest Death Count Per Population
select Location,max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--break things by continent
--select continent, TotalDeathCount from (
--select continent,max(cast(total_deaths as int)) as TotalDeathCount
--from Portfolio..CovidDeaths
--where continent is not null
--group by continent
----order by TotalDeathCount desc
--union all
--select location as continent,max(cast(total_deaths as int)) as TotalDeathCount
--from Portfolio..CovidDeaths
--where continent is null
--group by location)a
--order by TotalDeathCount desc

-- Global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
	SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2



select * 
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
order by 3,4

-- looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
	--it means for every location add each of new_vaccinations and has to be ordered by date as well to understand that yes every day, add it
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
	as RollingPeopleVaccinated
	--it means for every location add each of new_vaccinations and has to be ordered by date as well to understand that yes every day, add it
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac 
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null

)
select *,(RollingPeopleVaccinated/population)*100 from PopVsVac
order by 2,3


	