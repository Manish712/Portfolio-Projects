SELECT * FROM portfolioproject.coviddeaths;
SELECT * FROM portfolioproject.covidvaccinations;
SET SQL_SAFE_UPDATES = 0;
UPDATE portfolioproject.coviddeaths
SET date = STR_TO_DATE(date,'%d-%m-%Y')
where date is not null;

-- death percentage across location
select location,date,total_cases,new_cases,total_deaths,population,(total_deaths/total_cases)*100 as deathPercen
from portfolioproject.coviddeaths;

-- shows what percentage of population got covid
select location,date,total_cases,population,(total_cases/population)*100 as populationAffected
from portfolioproject.coviddeaths;

-- looking at countries with highest infection rate
select location,max(total_cases) as highestinfection ,population,max((total_cases/population))*100 as populationAffected
from portfolioproject.coviddeaths
group by location,population;

-- showing countries with highest death count
-- in mysql we have to use unsigned instead of int
select location,max(cast(total_deaths as unsigned))  as deathsbycovid ,population,max((total_deaths/population))*100 as populationAffected
from portfolioproject.coviddeaths
where continent is not null
group by location,population;

-- by location
select location,max(cast(total_deaths as unsigned))  as deathsbycovid 
from portfolioproject.coviddeaths
where continent is  null
group by location;

-- by continent
select continent,max(cast(total_deaths as unsigned))  as deathsbycovid 
from portfolioproject.coviddeaths
where continent is  null
group by continent;

select *
from portfolioproject.coviddeaths dea
join portfolioproject.covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From portfolioproject.CovidDeaths dea
Join portfolioproject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations,unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From portfolioproject.CovidDeaths dea
Join portfolioproject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;
