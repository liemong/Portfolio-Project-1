-- Dataset is from range 03/01/2020 to 26/04/2023
-- Exploring the data set and creating some views to make visualisations in Tableau


-- Exploring data by country

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got COVID
SELECT 
	Location, 
	Date, 
	Population, 
	total_cases, 
	(total_cases/population)*100 AS PercentPopulationWithCOVID
FROM PortfolioProject..CovidData
ORDER BY 
	Location, 
	Date


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of death from contracting COVID
SELECT 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidData
WHERE 
	total_cases > 0
ORDER BY 
	Location, 
	Date


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT 
	Location, 
	Population, 
	MAX(total_cases) AS HighestCOVIDCases, 
	MAX((total_cases/population))*100 AS PercentPopulationWithCOVID
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE ''
GROUP BY 
	Location, 
	Population
ORDER BY 
	PercentPopulationWithCOVID DESC

-- Showing Countries with the Highest Deaths from COVID per Population

SELECT 
	Location, 
	MAX(total_deaths) as TotalDeaths 
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE ''
GROUP BY 
	Location
ORDER BY 
	TotalDeaths DESC

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of death from contracting COVID over time
SELECT 
	Location, 
	Population, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidData
WHERE 
	total_cases > 0
ORDER BY 
	Location, 
	Date

-- Looking at what percent of the population is vaccinated by country
SELECT 
	Location,
	Continent,
	MAX(population) AS population,
	MAX(people_vaccinated) AS people_partially_vaccinated,
	MAX(people_fully_vaccinated) AS people_fully_vaccinated,
	MAX(people_vaccinated/population) AS '% pop_partially_vaccinated', 
	MAX(people_fully_vaccinated/population) AS '% pop_fully_vaccinated'
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE '' -- The null values were put as blanks for this column
GROUP BY 
	continent,location;


-- Looking at GDP vs People vaccinated per 100
SELECT 
	Location,
	Continent,
	MAX(people_vaccinated_per_hundred) AS people_vaccinated_per_hundred,
	MAX(gdp_per_capita) AS gdp_per_capita
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE '' 
GROUP BY 
	continent,location
ORDER BY 
	MAX(people_vaccinated_per_hundred) DESC


-- Exploring data by continent
SELECT 
	Location, 
	Population, 
	MAX(total_cases) AS HighestCOVIDCases, 
	MAX((total_cases/population))*100 AS PercentPopulationWithCOVID
FROM PortfolioProject..CovidData
WHERE 
	continent LIKE '' AND 
	Location NOT IN ('World','European Union','High Income','Upper middle income','Lower middle income', 'Low income')
GROUP BY 
	Location, 
	Population
ORDER BY 
	PercentPopulationWithCOVID DESC


SELECT 
	location, 
	MAX(total_deaths) as TotalDeaths 
FROM PortfolioProject..CovidData
WHERE 
	Continent LIKE '' AND 
	Location NOT IN ('World','European Union','High Income','Upper middle income','Lower middle income', 'Low income')
GROUP BY 
	location
ORDER BY 
	TotalDeaths DESC


-- Using CTE to look at rolling % of people vaccinated by country
WITH PopvsVac
AS
(
SELECT 
	Location, 
	Continent, 
	Date, 
	Population, 
	New_Vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY Location ORDER BY Location, Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidData
WHERE 
	Continent NOT LIKE '' 
)
SELECT 
	*, 
	(RollingPeopleVaccinated/population)*100 AS '% RollingPeopleVaccinated'
FROM PopvsVac


-- Creating views from some queries that may be used for visuals

-- Creating view comparing % of population that is partially vaccinated vs % of population that is fully vaccinated by country
DROP VIEW IF EXISTS PartialvsFullVacc
USE PortfolioProject
GO
CREATE VIEW PartialvsFullVacc AS
SELECT 
	Location,
	Continent,
	MAX(population) AS population,
	MAX(people_vaccinated) AS people_partially_vaccinated,
	MAX(people_fully_vaccinated) AS people_fully_vaccinated,
	MAX(people_vaccinated/population) AS '% pop_partially_vaccinated', 
	MAX(people_fully_vaccinated/population) AS '% pop_fully_vaccinated'
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE '' 
GROUP BY 
	continent,
	location;
GO


-- Creating view that compares the GDP per capita and people vaccinated per 100 by country
DROP VIEW IF EXISTS GDPvsVacc
USE PortfolioProject
GO
CREATE VIEW GDPvsVacc AS
SELECT 
	Location,
	Continent,
	MAX(people_vaccinated_per_hundred) AS people_vaccinated_per_hundred,
	MAX(gdp_per_capita) AS gdp_per_capita
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE '' 
GROUP BY 
	continent,
	location
GO


-- Creating view to show rolling % of people vaccinated over time by location
DROP VIEW IF EXISTS RollingPopVacc
USE PortfolioProject
GO
CREATE VIEW RollingPopVacc AS
WITH PopvsVac
AS
(
SELECT 
	Location, 
	Continent, 
	Date, 
	Population, 
	New_Vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY Location ORDER BY Location, Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidData
WHERE 
	Continent NOT LIKE ''
)
SELECT 
	*, 
	(RollingPeopleVaccinated/population)*100 AS '% RollingPeopleVaccinated'
FROM PopvsVac
GO


-- Creating view for mortality rate from COVID 
DROP VIEW IF EXISTS CovidDeathRate
USE PortfolioProject
GO
CREATE VIEW CovidDeathRate AS
SELECT 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidData
WHERE total_cases > 0
GO


-- Creating view for global deaths from COVID
DROP VIEW IF EXISTS CovidDeathByLocation
USE PortfolioProject
GO
CREATE VIEW CovidDeathByLocation AS
SELECT 
	Location, 
	MAX(total_deaths) AS total_deaths
FROM PortfolioProject..CovidData
WHERE 
	continent NOT LIKE '' 
GROUP BY 
	Location
GO

