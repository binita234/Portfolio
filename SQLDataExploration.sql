/****** Script for Select command from SSMS  ******/
	
SELECT		*
FROM		[PortfolioProject].[dbo].[CovidVaccinations]
ORDER BY	3,4

SELECT		*
FROM		[PortfolioProject].[dbo].[CovidDeaths]
ORDER BY	3,4

  -- Select Data that we are going to be using

SELECT		location,
		date,
		total_cases,
		new_cases,
		total_deaths, 
		population
FROM		PortfolioProject..CovidDeaths
ORDER BY	1,2

--Looking at Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT		[location],
		[date],
		(total_deaths/total_cases)* 100 AS DeathPercentage
FROM		PortfolioProject..CovidDeaths
WHERE		location like '%states%'
ORDER BY	1,2

--Looking at Total Cases VS Population
-- Shows that what percentage of population got Covid

SELECT		[location],
		[date],
		[Population],
		total_cases, 
		(total_cases/population)* 100 AS CovidPopulationPercentage
FROM		PortfolioProject..CovidDeaths
WHERE		[location] like '%states%'
ORDER BY	1,2

--Looking at countries with highest infection rate compared to Population

SELECT		location,
		Population,
		MAX(total_cases) HighestInfectionCount,
		MAX(total_cases/population)* 100 AS CovidPopulationPercentage
FROM		PortfolioProject..CovidDeaths	
GROUP BY	location,Population
ORDER BY	CovidPopulationPercentage DESC


--Showing Countries with Highest Death Count per Population

SELECT		location,
		(MAX(CAST(total_deaths AS int))/Population)* 100 AS DeathCountPerPopulation
FROM		PortfolioProject..CovidDeaths	
GROUP BY	location,population
ORDER BY	DeathCountPerPopulation DESC

SELECT		location,
		(MAX(CAST(total_deaths AS int))) AS DeathCountPerPopulation
FROM		PortfolioProject..CovidDeaths	
GROUP BY	location
ORDER BY	DeathCountPerPopulation DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

SELECT		continent,
		(MAX(CAST(total_deaths AS int))) AS DeathCountPerPopulation
FROM		PortfolioProject..CovidDeaths	
WHERE		continent IS NOT NULL
GROUP BY	continent
ORDER BY	DeathCountPerPopulation DESC


--Global Numbers

 SELECT		date,
		SUM(new_cases) total_cases,
		SUM(CAST(new_deaths AS INT)) total_deaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 as DeathPercentage
FROM		PortfolioProject..CovidDeaths
WHERE		continent is not null
GROUP BY	date
ORDER BY	1,2

-- Looking at Total Population VS Vaccinations

SELECT		dea.continent,
		dea.location,
		dea.date, 
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.Date) AS RollingPeopleVaccinated
FROM		PortfolioProject..CovidDeaths dea
JOIN		PortfolioProject.. CovidVaccinations  vac
ON		dea.location = vac.location
AND		dea.date= vac.date
WHERE		dea.continent IS NOT NULL
ORDER BY	2,3


SELECT		dea.continent,
		dea.location,
		dea.date, 
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.Date) RollingPeopleVaccinated
FROM		PortfolioProject..CovidDeaths dea
JOIN		PortfolioProject.. CovidVaccinations  vac
ON		dea.location = vac.location
AND		dea.date= vac.date
WHERE		dea.continent IS NOT NULL
ORDER BY	2,3


-- USE CTE

WITH		PopVSVac (Continent, Location, Date, Population ,new_vaccinations, RollingPeopleVaccinated)
AS 
(
			SELECT		dea.continent,
					dea.location,
					dea.date, 
					dea.population,
					vac.new_vaccinations,
					SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.Date) RollingPeopleVaccinated
			FROM		PortfolioProject..CovidDeaths dea
			JOIN		PortfolioProject.. CovidVaccinations  vac
			ON		dea.location = vac.location
			AND		dea.date= vac.date
			WHERE		dea.continent IS NOT NULL
)

SELECT		*,
		(RollingPeopleVaccinated/Population)* 100 AS RollingPeopleVacPerPop
FROM		PopVSVac

--TEMP TABLE

DROP	TABLE IF EXISTS #PercentPopulationVaccinated
CREATE	TABLE	#PercentPopulationVaccinated
(
		[Continent]					NVARCHAR(255), 
		[Location]					NVARCHAR(255), 
		[Date]						DATETIME, 
		[Population]					NUMERIC ,
		[new_vaccinations]				NUMERIC, 
		[RollingPeopleVaccinated]			NUMERIC
)

INSERT	INTO		#PercentPopulationVaccinated
SELECT			dea.continent,
			dea.location,
			dea.date, 
			dea.population,
			vac.new_vaccinations,
			SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.Date) RollingPeopleVaccinated
FROM			PortfolioProject..CovidDeaths dea
JOIN			PortfolioProject.. CovidVaccinations  vac
ON			dea.location = vac.location
AND			dea.date     = vac.date
WHERE			dea.continent IS NOT NULL

SELECT			*,
			(RollingPeopleVaccinated/Population)* 100 AS RollingPeopleVacPerPop
FROM			#PercentPopulationVaccinated


--  Creating View to store data for later visualization

CREATE	VIEW	vw_PercentPopulationVaccinated 
AS	 
SELECT			dea.continent,
			dea.location,
			dea.date, 
			dea.population,
			vac.new_vaccinations,
			SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location,dea.Date) RollingPeopleVaccinated
FROM			PortfolioProject..CovidDeaths dea
JOIN			PortfolioProject.. CovidVaccinations  vac
ON			dea.location = vac.location
AND			dea.date     = vac.date
WHERE			dea.continent IS NOT NULL


SELECT			*
FROM			vw_PercentPopulationVaccinated
