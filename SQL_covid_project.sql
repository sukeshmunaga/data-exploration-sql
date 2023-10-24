use PortfolioProject



--select data that we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


-- Change total_cases to INT
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_cases INT;

-- Change total_deaths to INT
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths INT;

DELETE FROM PortfolioProject..CovidDeaths
WHERE total_cases = 0;



--looking at Total Cases vs Total Deaths
--showing likelihood ratio of dying due to covid
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CAST((total_deaths*100.0 / total_cases)  AS FLOAT) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY location;

--looking at Total cases vs Population
--showing what percentage of people got affected by covid

SELECT
    location,
    date,
    total_cases,
    population,
    CAST((total_cases*100.0 / population)  AS FLOAT) AS affected_percentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
ORDER BY location,date;

--breaking down things based on continent with the highest death count
SELECT
    continent,
    max(cast(total_deaths as int)) as highestdeaths
FROM PortfolioProject..CovidDeaths
where continent is  not null
group by continent
order by highestdeaths desc


--looking at countries with highest infection rate compared to population
SELECT
    location,
    max(total_cases) as highest_infection,
    population,
    CAST((max(total_cases)*100.0 / population)  AS FLOAT) AS highest_infected_percentage
FROM PortfolioProject..CovidDeaths
group by location,population
order by highest_infected_percentage desc

--showing coutries with highest death count per population
SELECT
    location,
    max(total_deaths) as highestdeaths
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by highestdeaths desc



--global numbers
SELECT sum(cast(new_cases as int)) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,
    CAST(sum(cast(new_deaths as int))*100.0 /sum(cast(new_cases as int))  AS FLOAT) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
ORDER BY 1,2;

DELETE FROM PortfolioProject..CovidDeaths
WHERE new_cases = 0;


--looking at total population vs total vaccinations
with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date )as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location and dea.date = vac.date
	where dea.continent is not null
	)
--order by 2,3)
select *,(RollingPeopleVaccinated/population)* 100 from popvsvac


--temp table

drop table #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(continent nvarchar (255),
location nvarchar(255),
date datetime ,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date )as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location and dea.date = vac.date
	--where dea.continent is not null

select *,(RollingPeopleVaccinated/population)* 100 from #PercentPopulationVaccinated

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date )as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths dea join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated