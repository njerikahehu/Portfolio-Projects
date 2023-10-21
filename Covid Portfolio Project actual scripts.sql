SELECT *
FROM [Portfolio Project].[dbo].[CovidDeaths]
Where continent is not null
ORDER BY 3,4


--SELECT *
--FROM [Portfolio Project].[dbo].[CovidVaccinations]
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].[dbo].[CovidDeaths]
order by 1,2

--total cases vs total deaths
SELECT Location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM [Portfolio Project].[dbo].[CovidDeaths]
Where location like '%states%'
and continent is not null
order by 1,2

-- totalcases vs population 
-- % of population that got covid
SELECT Location, date, total_cases, population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
Where location like '%states%'
and continent is not null
order by 1,2

-- countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount , 
MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentPopulationInfected
FROM [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc

-- countries with highest deathcount per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- By Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--global numbers
SELECT date,
       SUM(new_cases) AS total_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM[Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2

-- Total new cases and new deaths accross the globe
SELECT 
       SUM(new_cases) AS total_new_cases,
       SUM(new_deaths) AS total_new_deaths,
       (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0) AS DeathPercentage
--(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM[Portfolio Project].[dbo].[CovidDeaths]
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

----Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project].[dbo].[CovidDeaths] dea
Join  [Portfolio Project].[dbo].[CovidVaccinations] vac
	ON dea.location = vac. location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM [Portfolio Project].[dbo].[CovidDeaths] dea
    JOIN [Portfolio Project].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
  FROM PopvsVac

  --creating a view
Create View RollingPeopleVaccinated as
SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM [Portfolio Project].[dbo].[CovidDeaths] dea
    JOIN [Portfolio Project].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

 --temp table
Drop table if exists #PercentPopulationVacinnated
 Create Table #PercentPopulationVacinnated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVacinnated
 SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM [Portfolio Project].[dbo].[CovidDeaths] dea
    JOIN [Portfolio Project].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
   -- WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population)*100
  FROM #PercentPopulationVacinnated


  --creating view to store data for later visualizations

  Create View PercentPopulationVacinnated as
  SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM [Portfolio Project].[dbo].[CovidDeaths] dea
    JOIN [Portfolio Project].[dbo].[CovidVaccinations] vac
    ON dea.location = vac.location
    AND dea.date = vac.date
   WHERE dea.continent IS NOT NULL
   --order by 2,3

Select *
From PercentPopulationVacinnated