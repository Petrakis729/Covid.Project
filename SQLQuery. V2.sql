select * from [dbo].[CovidDeaths]
where location = 'Greece'

--Select data htta we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from [dbo].[CovidDeaths]
order by 1,2

--Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
from [dbo].[CovidDeaths]
where location = 'United States' and total_cases is not null
order by 1,2

--Looking at the total cases vs population
Select location, date, population, total_cases, (total_cases / population) * 100 as population_percentage
from [dbo].[CovidDeaths]
where location = 'United States' and total_cases is not null
order by 1,2

--Countries with the highest infection rate
Select location, population, max(total_cases) as highest_infection_count, max((total_cases / population)) * 100 as percent_population_infected
from [dbo].[CovidDeaths]
where total_cases is not null
group by location, population
order by percent_population_infected desc

--Countries with the highest death rate
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where total_cases is not null and continent is not null
group by location
order by TotalDeathCount desc

--Lets break things by Continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from [dbo].[CovidDeaths]
where total_cases is not null and continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage           --total_cases, total_deaths, (total_deaths / total_cases) * 100 as death_percentage
from [dbo].[CovidDeaths]
where total_cases is not null and continent is not null 
--group by date
order by 1,2



--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as RollingVaccinations 
from [dbo].[CovidDeaths] as dea join
[dbo].[CovidVaccinations] as vac 
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null and dea.total_cases is not null
order by 2,3


--USE CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingVaccinations)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as RollingVaccinations 
from [dbo].[CovidDeaths] as dea join
[dbo].[CovidVaccinations] as vac 
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null and dea.total_cases is not null
--order by 2,3
)
select *, (RollingVaccinations/population)*100
from PopvsVac
order by 2,3



--TEMP TABLE

drop table if exists #PersentPopulationVaccinated
create table #PersentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinations numeric
)

INSERT INTO #PersentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingvaccinations
from [dbo].[CovidDeaths] as dea join
[dbo].[CovidVaccinations] as vac 
on dea.location = vac.location and dea.date = vac.date 
--where dea.continent is not null
--where dea.total_cases is not null
--order by 2,3

select *, (rollingvaccinations/population)*100
from #PersentPopulationVaccinated 


--Create view for later visuallizations
create view RollingVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as RollingVaccinations 
from [dbo].[CovidDeaths] as dea join
[dbo].[CovidVaccinations] as vac 
on dea.location = vac.location and dea.date = vac.date 
where dea.continent is not null and dea.total_cases is not null

select *, (RollingVaccinations/population)*100
from PopvsVac

