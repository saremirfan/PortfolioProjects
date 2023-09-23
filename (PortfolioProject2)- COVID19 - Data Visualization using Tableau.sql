/* Queries used for Tableau Data Visualization */


-- 1.


SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE location like '%states%' // You could input any state here to find out specifics
WHERE continent is null 
AND CASE
		WHEN location LIKE '%income%' THEN 0  -- This line helps to exclude income levels values that keep appearing in location and keep changing values of total cases, deaths and death percentage
		ELSE 1
	END = 1
-- GROUP BY date
ORDER BY 1,2


-- 2. 


-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe


SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE location like '%states%' // You could input any state here to find out specifics
WHERE continent is null 
AND CASE
        WHEN location LIKE '%income%' THEN 0  -- This line helps to exclude income levels values that keep appearing in location
        ELSE 1
    END = 1 
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


-- 3.


SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE location like '%states%' // You could input any state here to find out specifics
WHERE  
	CASE
        WHEN location LIKE '%income%' THEN 0  -- This line helps to exclude income levels values that keep appearing in location
        ELSE 1
    END = 1
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


-- 4.


SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1..OWIDCOVID19Deaths
-- WHERE location like '%states%' // You could input any state here to find out specifics
WHERE	
	CASE
        WHEN location LIKE '%income%' THEN 0  -- This line helps to exclude income levels values that keep appearing in location
        ELSE 1
    END = 1
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc