--Total Population Vs Total fully vaccinated (Country-wise)

select cd.location, max(cd.population) as TotalPopulation, max(cv.people_fully_vaccinated) as PopulationFullyVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
group by cd.location
order by 1



--Total Population Vs Total fully vaccinated (Continent-wise)

with ContVsVac (Continent, Location, TotalVaccination)
AS
(
select continent, location, max(people_fully_vaccinated) as TotalVaccination
from PortfolioProject..CovidVaccinations
where continent is not null
group by continent, location
)
select continent, sum(convert(float,TotalVaccination)) as PopulationVaccinated
from ContVsVac
group by continent


--Total Population Vs Total fully vaccinated (Worldwide)
WITH WorldPopVsVac (location, population, Vaccination)
AS
(
select cd.location, max(cd.population) as TotalPopulation, max(cv.people_fully_vaccinated) as PopulationFullyVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
group by cd.location
)
SELECT SUM(population) as Total_World_Population, SUM(CONVERT(float, Vaccination)) as Total_World_Vaccination
FROM WorldPopVsVac


---Vaccination percentage as per income 
WITH IncomeVsVac (location, population, vaccination)
as
(
select cd.location, max(cd.population) as TotalPopulation, max(cv.people_fully_vaccinated) as TotalVaccination
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.location not in ('North America', 'Asia','Africa','Oceania','South America', 'Europe','World','International','European Union')
and cd.continent is null
group by cd.location
)
Select *, (vaccination/population) * 100 as VaccinatedPopulationPercent
from IncomeVsVac


---Countrwise vaccination percentage
WITH GeoVacPercentage(country, population, pop_vaccinated)
AS
(
select cd.location, max(cd.population) as TotalPopulation, max(cv.people_fully_vaccinated) as PopulationFullyVaccinated
from PortfolioProject..CovidDeaths as cd
join PortfolioProject..CovidVaccinations as cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
group by cd.location
)
select *, (pop_vaccinated/population) * 100 as PercentVaccinated
from GeoVacPercentage
order by 1