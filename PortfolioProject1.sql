SELECT *
FROM PortfolioProject1..OWIDCOVID19Deaths
WHERE continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using for project


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..OWIDCOVID19Deaths
WHERE continent is not null
ORDER BY 1,2


-- We will be looking at the Total Cases of COVID19 vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in the United States


SELECT location, date, total_cases,total_deaths, 
	(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
	from PortfolioProject1..OWIDCOVID19Deaths
WHERE Location like '%state%' and continent is not null -- You could input any state here to find out specifics
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population has gotten COVID


SELECT location,date, total_cases, population,
    CASE
        WHEN TRY_CAST(total_cases AS FLOAT) = 0 THEN 0  -- Handle division by zero
        ELSE (TRY_CAST(total_cases AS FLOAT) * 100.0) / TRY_CAST(population AS FLOAT)
    END AS PercentPopulationInfected
FROM PortfolioProject1..OWIDCOVID19Deaths
WHERE Location LIKE '%state%' and continent is not null -- You could input any state here to find out specifics
ORDER BY 1, 2


-- Looking at countries with the highest Infection Rate compared to Population


SELECT location, population, MAX(total_cases) as HighestInfectionCount,
    CASE
        WHEN TRY_CAST(MAX(total_cases) AS FLOAT) = 0 THEN 0  -- Handle division by zero
        ELSE (TRY_CAST(MAX(total_cases) AS FLOAT) * 100.0) / TRY_CAST(population AS FLOAT)
    END AS PercentPopulationInfected
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE Location LIKE '%states%' // You could input any state here to find out specifics
WHERE continent is not null
GROUP by Location, Population
ORDER BY PercentPopulationInfected desc


-- Looking at Countries with Highest Death Count per Population


SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE Location LIKE '%states%' // You could input any state here to find out specifics
WHERE continent is not null
GROUP by Location
ORDER BY TotalDeathCount desc


-- Lets break things down by continent // Shows continents with the highest death count per population


SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE Location LIKE '%states%' // You could input any state here to find out specifics
WHERE continent is null 
AND CASE
        WHEN location LIKE '%income%' THEN 0  -- This line helps to exclude income levels values that keep appearing in location
        ELSE 1
    END = 1
GROUP by location
ORDER BY TotalDeathCount desc


-- Global Case Numbers


SELECT
    SUM(new_cases) AS TotalNewCases,
    SUM(CAST(new_deaths AS INT)) AS TotalNewDeaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0 -- This function helps to handle division by zero because I kept getting errors for it
        ELSE (SUM(CAST(new_deaths AS INT)) * 100.0) / SUM(new_cases)
    END AS DeathPercentage
FROM PortfolioProject1..OWIDCOVID19Deaths
WHERE continent IS NOT NULL
	-- GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
-- I have created short hand names for the "FROM" files to make it easier on myself (dea and vac)


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by 
	dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..OWIDCOVID19Deaths dea
	Join PortfolioProject1..OWIDCOVID19Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using a CTE


With PopVsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by 
	dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..OWIDCOVID19Deaths dea
	Join PortfolioProject1..OWIDCOVID19Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100 -- Showcases percent of population that is vaccinated
From PopvsVac


-- Using a Temp Table


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by 
	dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..OWIDCOVID19Deaths dea
	Join PortfolioProject1..OWIDCOVID19Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100 -- Showcases percent of population that is vaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later data visualizations in Tableau

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by 
	dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
	-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject1..OWIDCOVID19Deaths dea
	Join PortfolioProject1..OWIDCOVID19Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- Order by 2,3


Select *
From PercentPopulationVaccinated
