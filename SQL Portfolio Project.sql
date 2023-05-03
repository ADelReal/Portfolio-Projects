

SELECT *
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO STARTING WITH

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS. TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN TH UNITED STATES

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 AS Death_Percentage
FROM [Portfolio Project]..Covid_Deaths
WHERE location LIKE '%STATES%' AND continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION INFECTED WITH COVID GOBALLY

SELECT location, date, population, total_cases, (total_cases / population) * 100 AS Percent_population_Infected
FROM [Portfolio Project]..Covid_Deaths
ORDER BY 1,2

-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases / population)) * 100 AS Percent_population_Infected
FROM [Portfolio Project]..Covid_Deaths
GROUP BY location, population
ORDER BY Percent_population_Infected DESC

--COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_death_count DESC

--BREAKING THINGS DOWN BY CONTINENT
--SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_death_count
FROM [Portfolio Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_death_count DESC

-- GLOBAL NUMBERS

--TOTAL POPULATION VS. VACCINATIONS
--SHOWING PERCENTAGE OF POPULATION THAT HAS RECIEVED AT LEAST ONE COVID VACCINE

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations
FROM [Portfolio Project]..Covid_Deaths AS deaths
JOIN [Portfolio Project]..Covid_Vaccinations AS vacs
	ON deaths.location = vacs.location 
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

--UNSING CTE TO PERFORM CALCULATION ON PARTITION BY IN PERVIOUS QUERY

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccination, [Rolling People Vaccination])
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(INT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM [Portfolio Project]..Covid_Deaths AS deaths
JOIN [Portfolio Project]..Covid_Vaccinations AS vacs
	ON deaths.location = vacs.location 
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL
)

SELECT *, ([Rolling People Vaccination] / Population) * 100
From PopVsVac

--USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

DROP TABLE IF EXISTS #Perfect_Population_Vaccinated
CREATE TABLE #Perfect_Population_Vaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Perfect_Population_Vaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(INT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM [Portfolio Project]..Covid_Deaths AS deaths
JOIN [Portfolio Project]..Covid_Vaccinations AS vacs
	ON deaths.location = vacs.location 
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL

SELECT *, (Rolling_People_Vaccinated / Population) * 100
From #Perfect_Population_Vaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW [Percent Population Vaccinated] AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(INT, vacs.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS [Rolling People Vaccinated]
FROM [Portfolio Project]..Covid_Deaths AS deaths
JOIN [Portfolio Project]..Covid_Vaccinations AS vacs
	ON deaths.location = vacs.location 
	AND deaths.date = vacs.date
WHERE deaths.continent IS NOT NULL