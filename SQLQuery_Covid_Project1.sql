
--Total Cases vs Total Deaths (country-specific)
SELECT location,date,
		total_cases, total_deaths,
		(total_deaths/total_cases)*100 AS CaseDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2


--Total Cases vs Population
SELECT location,date,population,
		total_cases, 
		(total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%kingdom%'
ORDER BY 1,2


--Countries with highest infection rate compared to population
SELECT location,population,
		MAX(total_cases) AS HighestInfectionCount, 
		(MAX(total_cases)/population)*100 AS PopulationInfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location , population
ORDER BY PopulationInfectionPercentage DESC


--Countries with highest death count compared to population
SELECT location, population,
		MAX(cast(total_deaths as int)) AS HighestDeathCount, 
		(MAX(cast(total_deaths as int))/population)*100 AS PopulationDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location ,population
ORDER BY PopulationDeathPercentage DESC



--Continent with highest infection rate compared to population
SELECT location,population,
		MAX(total_cases) AS HighestInfectionCount, 
		(MAX(total_cases)/population)*100 AS ContinentInfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location , population
ORDER BY ContinentInfectionPercentage DESC


--Continent with highest death count
SELECT continent,
		MAX(cast(total_deaths as int)) AS TotalDeathCount 		
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers daily
SELECT date,
		sum(new_cases) AS CasesOnDay,
		sum(cast(new_deaths as int)) AS DeathsOnDay,
		(sum(cast(new_deaths as int))/sum(new_cases))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Total population vs Vaccination (using CTE)

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, CummulativeVaccinated)
AS
(
SELECT dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(float,vac.new_vaccinations)) OVER 
									(PARTITION BY dea.location
									ORDER BY dea.location,dea.date) AS CummulativeVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (CummulativeVaccinated/Population)*100 AS VaccinatedPopulation
FROM PopvsVac



--Total population vs Vaccination (using Temp Table)
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
CummulativeVaccinated float
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,	dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativeVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *, (CummulativeVaccinated/Population)*100 AS VaccinatedPopulation
FROM #PercentPopulationVaccinated


--Total population vs Vaccination (creatIng View)

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,	dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS CummulativeVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
