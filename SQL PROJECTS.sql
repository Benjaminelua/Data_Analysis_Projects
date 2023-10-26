--SELECT * FROM PortfolioProjects..CovidVacination
--ORDER BY 3, 4

SELECT * FROM [dbo].[CovidDeaths]

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
ORDER BY 1,2

-- looking at the percentage of total death to total  cases recorded in nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
FROM PortfolioProjects..CovidDeaths
where location like 'Nigeria'
ORDER BY 1,2

CREATE VIEW PERCENTAGEOFDEATHSINNIGERIA AS
-- looking at the percentage of total death to total  cases recorded in nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
FROM PortfolioProjects..CovidDeaths
where location like 'Nigeria'
--ORDER BY 1,2

--looking at total cases recorded vs populationn
SELECT location, date,population, total_cases, (total_cases/population) * 100 as Casespercentage
FROM PortfolioProjects..CovidDeaths
where location like 'Nigeria'
ORDER BY 1,2

CREATE VIEW NIGERIACASES AS
--looking at total cases recorded vs populationn
SELECT location, date,population, total_cases, (total_cases/population) * 100 as Casespercentage
FROM PortfolioProjects..CovidDeaths
where location like 'Nigeria'
--ORDER BY 1,2

--looking at countries with highest infections
SELECT location, population, MAX(total_cases)AS HighestInfections, MAX((total_cases/population)) * 100 AS PercentageofpopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population
ORDER BY PercentageofpopulationInfected desc

CREATE VIEW PERCENTAGEOFCASESPERPOPULATIONS AS 
--looking at countries with highest infections
SELECT location, population, MAX(total_cases)AS HighestInfections, MAX((total_cases/population)) * 100 AS PercentageofpopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population
--ORDER BY PercentageofpopulationInfected desc

--looking at countries with highest deathcount
SELECT location, MAX(CAST( total_deaths AS INT))AS DEATHCOUNT
FROM PortfolioProjects..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location
ORDER BY DEATHCOUNT DESC

SELECT * FROM COUNTRYCOUNTS

CREATE VIEW COUNTRYCOUNTS AS
SELECT location, MAX(CAST( total_deaths AS INT))AS DEATHCOUNT
FROM PortfolioProjects..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY location
--ORDER BY DEATHCOUNT DESC

-- BREAKING IT DOWN BY CONTINENT
SELECT  location, MAX(CAST( total_deaths AS INT))AS DEATHCOUNT
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY DEATHCOUNT DESC

SELECT * FROM DEATHSPERCONTINENT

CREATE VIEW DEATHSPERCONTINENT AS
-- BREAKING IT DOWN BY CONTINENT
SELECT  location, MAX(CAST( total_deaths AS INT))AS DEATHCOUNT
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NULL
GROUP BY location
--ORDER BY DEATHCOUNT DESC

--showing the continent with highest death 
SELECT  continent, MAX(CAST( total_deaths AS INT))AS DEATHCOUNT
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DEATHCOUNT DESC

CREATE VIEW CONTINENTSPERDEATHS AS 

--showing the continent with highest death 
SELECT  continent, MAX(CAST( total_deaths AS INT))AS DEATHCOUNT
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY DEATHCOUNT DESC

SELECT * FROM CONTINENTSPERDEATHS

--GLOBAL FIGURES PER DATES
SELECT  date, SUM(new_cases )AS TOTALCASES, SUM(CAST( total_deaths AS INT))AS TOTALDEATHS,
SUM(CAST( total_deaths AS INT))/SUM(new_cases) *100 AS PERCENTAGEOFDEATHS
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

CREATE VIEW GLOBALFIGURESPERDATE AS
--GLOBAL FIGURES PER DATES
SELECT  date, SUM(new_cases )AS TOTALCASES, SUM(CAST( total_deaths AS INT))AS TOTALDEATHS,
SUM(CAST( total_deaths AS INT))/SUM(new_cases) *100 AS PERCENTAGEOFDEATHS
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
--ORDER BY 1,2

SELECT * FROM GLOBALFIGURESPERDATE


-- TOTAL GLOBAL FIGURES
SELECT  SUM(new_cases )AS TOTALCASES, SUM(CAST( total_deaths AS INT))AS TOTALDEATHS,
SUM(CAST( total_deaths AS INT))/SUM(new_cases) *100 AS PERCENTAGEOFDEATHS
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

CREATE VIEW GLOBALFIGURES AS
-- TOTAL GLOBAL FIGURES
SELECT  SUM(new_cases )AS TOTALCASES, SUM(CAST( total_deaths AS INT))AS TOTALDEATHS,
SUM(CAST( total_deaths AS INT))/SUM(new_cases) *100 AS PERCENTAGEOFDEATHS
FROM PortfolioProjects..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
--ORDER BY 1,2
SELECT * FROM GLOBALFIGURES

-- looking at total population vs vacinations
SELECT   DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VACINE.new_vaccinations,
 SUM(CAST(VACINE.new_vaccinations AS INT)) OVER (PARTITION BY DEATH.location ORDER BY DEATH.location, DEATH.date) AS ROLLINGUP 
FROM PortfolioProjects..CovidDeaths DEATH
JOIN PortfolioProjects..CovidVacination VACINE
 ON DEATH.location = VACINE.location
 AND DEATH.date = VACINE.date
 WHERE DEATH.continent IS NOT NULL  
 ORDER BY 2,3

--USING CTE
WITH POPULATIONVSVACINES (CONTINENT, LOCATION, DATE, POPULATION, NEW_VACCINATION, ROLLINGUP)
AS (-- looking at total population vs vacinations
SELECT   DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VACINE.new_vaccinations,
 SUM(CAST(VACINE.new_vaccinations AS INT)) OVER (PARTITION BY DEATH.location ORDER BY DEATH.location, DEATH.date) AS ROLLINGUP 
FROM PortfolioProjects..CovidDeaths DEATH
JOIN PortfolioProjects..CovidVacination VACINE
 ON DEATH.location = VACINE.location
 AND DEATH.date = VACINE.date
 WHERE DEATH.continent IS NOT NULL  
 --ORDER BY 2,3
 )
SELECT *, (ROLLINGUP/POPULATION)*100 
FROM POPULATIONVSVACINES

--USING TEMP TABLE
CREATE TABLE #PERCENTAGEPOPULATIONVACCINATED(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEWVACCINATIONS NUMERIC,
ROLLINGUP NUMERIC,
)

INSERT INTO #PERCENTAGEPOPULATIONVACCINATED
SELECT   DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VACINE.new_vaccinations,
 SUM(CAST(VACINE.new_vaccinations AS INT)) OVER (PARTITION BY DEATH.location ORDER BY DEATH.location, DEATH.date) AS ROLLINGUP 
FROM PortfolioProjects..CovidDeaths DEATH
JOIN PortfolioProjects..CovidVacination VACINE
 ON DEATH.location = VACINE.location
 AND DEATH.date = VACINE.date
 WHERE DEATH.continent IS NOT NULL  
 --ORDER BY 2,3

SELECT *,(ROLLINGUP/POPULATION)*100 AS PERCENTAGEOFROLLINGUP 
FROM #PERCENTAGEPOPULATIONVACCINATED


CREATE VIEW  PERCENTAGEPOPULATIONVACCINATED AS 
SELECT   DEATH.continent, DEATH.location, DEATH.date, DEATH.population, VACINE.new_vaccinations,
 SUM(CAST(VACINE.new_vaccinations AS INT)) OVER (PARTITION BY DEATH.location ORDER BY DEATH.location, DEATH.date) AS ROLLINGUP 
FROM PortfolioProjects..CovidDeaths DEATH
JOIN PortfolioProjects..CovidVacination VACINE
 ON DEATH.location = VACINE.location
 AND DEATH.date = VACINE.date
 WHERE DEATH.continent IS NOT NULL  
 --ORDER BY 2,3

 SELECT * FROM PERCENTAGEPOPULATIONVACCINATED


 select location, date
 from[dbo].[CovidDeaths]
 order by location

 SELECT location, date, new_vaccinations from[dbo].[CovidVacination]
 order by location
