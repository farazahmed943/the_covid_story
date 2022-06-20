select top 100 * from portfolio_project..CovidDeaths WHERE continent IS NOT NULL;

--Show columns from Table CovidDeaths
Select * from INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths';

--Show column details from Table CovidVaccination
Select * from INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidVaccinations';

--Selecting subset from CovidDeaths Table
SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolio_project..CovidDeaths
order by 1,2;

-- Deaths Vs Cases
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS casuality_percentage
FROM portfolio_project..CovidDeaths
WHERE location like '%india%'
order by 1,2;

--Looking at Total Cases Vs Population
SELECT location, date, total_cases, population , ROUND((total_cases/population)*100,2) AS case_percent
FROM portfolio_project..CovidDeaths
WHERE location like '%india%'
order by 1,2;

--Countries having highest infection rate w.r.t population'
SELECT location,population, MAX(total_cases) as highestinfectioncount, ROUND(MAX(total_cases/population)*100,2) AS percentpopulation_infected
FROM CovidDeaths
GROUP BY location,population
Order By percentpopulation_infected DESC;

--Death Rate
Select location, MAX(total_cases) as highestinfectioncount, MAX(CAST (total_deaths as INT)) as highestdeathcount, (MAX(CAST (total_deaths as INT))/MAX(total_cases))*100 as death_percent
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY highestinfectioncount DESC;

-- Continent wise death percentage
Select continent, MAX(total_cases) as highestinfectioncount, MAX(CAST (total_deaths as INT)) as highestdeathcount, (MAX(CAST (total_deaths as INT))/MAX(total_cases))*100 as death_percent
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY highestinfectioncount DESC;

---Global numbers
SELECT  SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as death_percentage
FROM CovidDeaths
WHERE continent is not null
--group by date
order by 1,2

--Joining Tables
Select * 
from portfolio_project..CovidVaccinations vac
Join portfolio_project..CovidDeaths dea
On vac.location = dea.location AND vac.date = dea.date

-- Total population and vaccination
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) rolling_vac_sum
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 6 DESC

-- Extracting data using CTE
with popvac as
(SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) rolling_vac_sum
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, (rolling_vac_sum/population)*100 as vac_pop_percentage
from popvac order by vac_pop_percentage DESC

--Create Table
DROP Table if exists Popvac
Create Table Popvac
(
Continent nvarchar(255),
Locaton nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO Popvac
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) rolling_vac_sum
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

SELECT * FROM Popvac

--Creating View for visualization purposes.
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) rolling_vac_sum
FROM portfolio_project..CovidDeaths dea
join portfolio_project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


