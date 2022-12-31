--Query information pertaining to the COVID19 pandemic during the 1st year.
--Dataset retreived from http://ourworldindata.org/covid-deaths
--Uses data from two tables: CovidDeaths and CovidVaccinations

--SELECT Data that will will be used for part of this project:
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Explore Total Covid Cases vs Total Covid Deaths in the 1st year of the pandemic
--Percentage of covid deaths compared to reported cases in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2

--Explore Total Covid Cases vs Population in the 1st year of the pandemic
--Infection rate for the population of the United States per day
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2

--Display countries with highest infection rates compared to population during the 1st year of the pandemic
SELECT Location, Population, MAX(total_cases) AS HighestInfectionRate, ROUND(MAX((total_cases/Population))*100, 2) AS TopInfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY TopInfectionRate desc

--Display countries with the highest death count compared to population during the 1st year of the pandemic
SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Display Total Death count by continent during the first year of the pandemic
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Calculate total global numbers during the 1st year of the pandemic
SELECT SUM(new_cases) AS TotalGlobalCases, SUM(CAST(new_deaths AS int)) AS TotalGlobalDeaths, ROUND(SUM(CAST(new_deaths AS int))/SUM(new_cases)*100, 2) AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Display total population vs vaccination rate per day
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingVaccCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
ORDER BY 2, 3

--Create CTE for to display total population vs vaccination rate per day
WITH PopvsVacc (continent, location, date, population, new_vaccinations, RollingVaccCount)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingVaccCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null
)
SELECT *, ROUND((RollingVaccCount/Population) *100, 2)
FROM PopvsVacc

--CREATE Temp Table to display total population vs vaccination rate per day
DROP TABLE IF exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(coninent nvarchar(255), location nvarchar(255), date datetime, population numeric,
new_vaccinations numeric, RollingVaccCount numeric)

INSERT INTO #PercentPopVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingVaccCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null

SELECT *, ROUND((RollingVaccCount/Population) *100, 2)
FROM #PercentPopVaccinated

--Create view to store data for the percentage of the population vaccinated
CREATE VIEW PercentPopVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS int)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,
	DEA.date) AS RollingVaccCount
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent is not null

--Create view to store data for the countries with highest infection rates compared to population during the 1st year of the pandemic
CREATE VIEW HighInfectionRate AS
SELECT Location, Population, MAX(total_cases) AS HighestInfectionRate, ROUND(MAX((total_cases/Population))*100, 2) AS TopInfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location, Population