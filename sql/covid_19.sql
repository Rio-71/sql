select * from coviddeaths order by 3,4;

select * from covidvaccinations order by 3,4;

select location,dates, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

--Total cases vs total deaths
select location, dates, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
order by 1,2;
--Total cases vs total deaths for particular location
select location, dates, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
where location like '%States%'
order by 1,2;

-- Total cases vs Population
select location, dates, total_cases, population, (total_deaths/population)*100 as Infect_Percentage
from coviddeaths
order by 1,2;
--Infect_percentage for particular location
select location, dates, total_cases, population, (total_deaths/population)*100 as Infect_Percentage
from coviddeaths
where location like 'Ind%'
order by 1,2;

--countries with highest infection rate wrt population
select location, population, max(total_cases) as HighestInfectionCount, max((total_deaths/population))*100 as High_Infect_Percentage
from coviddeaths
group by location, population
order by High_Infect_Percentage desc;

--countries with highest death count wrt population
select location, max(total_deaths) as TotalDeathCount
from coviddeaths
where total_deaths is not null
group by location
order by TotalDeathCount desc;

--continents with highest death count wrt population
select continent, max(total_deaths) as TotalDeathCount
from coviddeaths
where total_deaths is not null and continent is not null --and continent = 'Africa'
group by continent
order by TotalDeathCount desc;

--covid cases globally
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from coviddeaths
where continent is not null and total_cases is not null and total_deaths is not null
order by 1,2;

--Population vs vaccinations

Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Dates) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.dates = vac.dates
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac AS (
    SELECT
        dea.continent,
        dea.location,
        dea.dates,
        dea.population,
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Dates) AS RollingPeopleVaccinated
    FROM
        CovidDeaths dea
    JOIN
        CovidVaccinations vac ON dea.location = vac.location
                             AND dea.dates = vac.dates
    WHERE
        dea.continent IS NOT NULL
)

SELECT
    pv.*,
    (pv.RollingPeopleVaccinated / pv.Population) * 100 AS VaccinationRatePercentage
FROM
    PopvsVac pv;


-- Using Temp Table to perform Calculation on Partition By in previous query
-- Step 1: Drop the table if it exists
DROP TABLE PercentPopulationVaccinated;

-- Step 2: Create the table
CREATE TABLE PercentPopulationVaccinated (
    Continent NVARCHAR2(255),
    Location NVARCHAR2(255),
    Dates DATE,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Step 3: Insert data into the table
INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.dates,
    dea.population,
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Dates) AS RollingPeopleVaccinated
FROM
    coviddeaths dea
JOIN
    covidvaccinations vac ON dea.location = vac.location
                          AND dea.dates = vac.dates;

-- Step 4: Retrieve data from the table

SELECT
    PercentPopulationVaccinated.*,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

GRANT CREATE VIEW TO SCOTT;

Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.dates, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Dates) as RollingPeopleVaccinated
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.dates = vac.dates
where dea.continent is not null;
























