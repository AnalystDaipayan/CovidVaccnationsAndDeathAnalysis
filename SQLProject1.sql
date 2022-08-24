-- Displaying complete data present in the tables - Covid Deaths and Covid Vaccinations

SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL                                      --Ignoring Null Continents
ORDER BY 3,4;			                                         

SELECT * FROM PortfolioProject..CoivdVaccinations
WHERE continent IS NOT NULL										 
ORDER BY 3,4;													 -- Arranging the details by Location Name and Date



-- Displaying Important Parameters - Location, Date, Total_Cases, New_Cases, Total_Deaths, Population

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;



-- Finding the Death Percentage of India
-- Depicting your Chances of Death by COVID in India

SELECT location, date, total_cases, total_deaths, ROUND((CAST (total_deaths AS INT)/total_cases)*100,3) as 'Death Percentage'			--Rounding off the Value to 3 Decimal Places and Casting the data type of Total_Deaths Column to Int
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' and continent IS NOT NULL
ORDER BY [Death Percentage] DESC;

  

-- Finding the Infection Percentage of India
-- Depicting percentage of Population that got COVID in India

SELECT location, date, Population, total_cases, ROUND((CAST (total_deaths AS INT)/Population)*100,2) as 'Infection Percentage'
FROM PortfolioProject..CovidDeaths
WHERE location = 'India' and continent IS NOT NULL
ORDER BY [Infection Percentage] DESC;



-- Highest Infection Percentage Rate of various locations in the World

SELECT location, population, MAX(total_cases) AS 'Highest Infection Count', MAX(ROUND((CAST (total_deaths AS INT)/Population)*100,2)) AS 'Highest Infection Rate'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Highest Infection Rate] DESC;



-- Highest Death Percentage Rate of various locations in the World

SELECT location, population, MAX(total_cases) AS 'Highest Infection Count', MAX(CAST (total_deaths AS INT)) AS 'Highest Death Count', MAX(ROUND((CAST (total_deaths AS INT)/Population)*100,2)) AS 'Highest Death Rate'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY [Highest Death Rate] DESC;



-- Finding the Total Death Counts in Different Continents

SELECT continent, MAX(CAST(total_deaths AS INT)) AS 'Total_Death_Count'
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;



-- Total Cases and Total Deaths reported all over the Globe

SELECT SUM(new_cases) AS 'TOTAL_CASES', SUM(CAST(new_deaths as INT)) AS 'TOTAL_DEATHS', ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,3) AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY [Death Percentage] DESC;


-- Total Cases and Total Deaths Day by Day Report across the Globe

SELECT date, SUM(new_cases) AS 'TOTAL_CASES', SUM(CAST(new_deaths as INT)) AS 'TOTAL_DEATHS', ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,3) AS 'Death Percentage'
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY [Death Percentage] DESC;



-- Joining Covid Deaths and Covid Vaccination Tables

SELECT *
FROM PortfolioProject..CovidDeaths CovDe
JOIN PortfolioProject..CoivdVaccinations CovVa
ON CovDe.location = CovVa.location											--Joining the tables on Location 
AND CovDe.date = CovVa.date;												--and Date



-- Number of People Vaccinated across the different locations each day

SELECT CovDe.continent, CovDe.location, CovDe.date, CovDe.population, CovVa.new_vaccinations
FROM PortfolioProject..CovidDeaths CovDe
JOIN PortfolioProject..CoivdVaccinations CovVa
		ON CovDe.location = CovVa.location											
		AND CovDe.date = CovVa.date
WHERE CovDe.continent IS NOT NULL
ORDER BY 2,3 ASC;



-- Finding the Increase in the Vaccinations in each continent Day by Day report
-- Impleming the query to do a Rolling Count w.r.t to each continent

SELECT CovDe.continent, CovDe.location, CovDe.date, CovDe.population,
	   SUM(CAST(CovVa.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovDe.location ORDER BY CovDe.location, CovDe.date) AS 'Rolling_Count_New_Vaccinations'           --USing WINDOW FUNCTIONS Concepts
FROM PortfolioProject..CovidDeaths CovDe
JOIN PortfolioProject..CoivdVaccinations CovVa
		ON CovDe.location = CovVa.location											
		AND CovDe.date = CovVa.date
WHERE CovDe.continent IS NOT NULL
ORDER BY 2,3 ASC;



-- Analysing the Vaccination Percentage of various locations W.R.T their Population

WITH PopVSVac (continent, location, date, population, new_vaccinations, Rolling_Count_New_Vaccinations)															   -- Using CTE Expressions in order to implement our custom column 'Rolling_Count_New_Vaccinations'
AS 
( SELECT CovDe.continent, CovDe.location, CovDe.date, CovDe.population, CovVa.new_Vaccinations,
	   SUM(CAST(CovVa.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovDe.location ORDER BY CovDe.location, CovDe.date) AS 'Rolling_Count_New_Vaccinations'           
FROM PortfolioProject..CovidDeaths CovDe
JOIN PortfolioProject..CoivdVaccinations CovVa
		ON CovDe.location = CovVa.location											
		AND CovDe.date = CovVa.date
WHERE CovDe.continent IS NOT NULL
)
SELECT location, population, MAX(ROUND((Rolling_Count_New_Vaccinations/population)*100,3)) AS 'Vaccination_Percentage'											   -- Reason of Implementing CTE Expression in order to make this possible
FROM PopVSVac
GROUP BY location,population
ORDER BY Vaccination_Percentage DESC;														  



-- Another Way of Analysing the Above Query by Creating a Temporary Table

DROP TABLE IF EXISTS PercentOfPopulationVaccinated
CREATE TABLE PercentOfPopulationVaccinated(
			Continent nvarchar(255),
			Location nvarchar(255),
			Date datetime,
			Population float,
			New_vaccinations float,
			Rolling_Count_New_Vaccinations float
)
INSERT INTO PercentOfPopulationVaccinated
SELECT CovDe.continent, CovDe.location, CovDe.date, CovDe.population, CovVa.new_Vaccinations,
	   SUM(CAST(CovVa.new_vaccinations AS BIGINT)) OVER (PARTITION BY CovDe.location ORDER BY CovDe.location, CovDe.date) AS 'Rolling_Count_New_Vaccinations'           
FROM PortfolioProject..CovidDeaths CovDe
JOIN PortfolioProject..CoivdVaccinations CovVa
		ON CovDe.location = CovVa.location											
		AND CovDe.date = CovVa.date
WHERE CovDe.continent IS NOT NULL

SELECT location, population, MAX(ROUND((Rolling_Count_New_Vaccinations/population)*100,3)) AS 'Vaccination_Percentage'											   -- Reason of Implementing CTE Expression
FROM PercentOfPopulationVaccinated
GROUP BY location,population
ORDER BY Vaccination_Percentage DESC;	

