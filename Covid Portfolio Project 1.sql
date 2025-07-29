-- Table of new cases and total deaths 
SELECT country, date, population, total_cases, new_cases, total_deaths
FROM compactCovidDeaths11
ORDER BY 1,2


--Likelihood of dying if sb affected by Covid base of countries
SELECT country, date, total_cases, total_deaths, Round(total_deaths/total_cases,2)*100 as pre_caseVSdeaths
FROM compactCovidDeaths11
WHERE total_cases > 0 AND country LIKE '%states%'
ORDER by 1,2


-- percentage of tptal deaths vs population AND sum of covid cases
SELECT country,population, SUM(new_cases) as sum_cases, SUM(new_deaths) as SUM_deathhs 
,Round( SUM(new_deaths)/ SUM(new_cases), 5)*100 as death_prc 
, Round( SUM(new_deaths)/ population, 5)*100 as death_prc_pop
FROM compactCovidDeaths11
GROUP BY country, population
HAVING SUM(new_cases) > 0 -- AND country like '%satate%'
order by death_prc desc


-- Total cases and deaths in the US va population
SELECT country, population, date, total_cases, total_deaths 
FROM compactCovidDeaths11
where country like '%states'
GROUP BY country, population, date, total_cases, total_deaths 
ORDER by date


-- highest infection rates vs population
SELECT country, population
,Round( SUM(new_cases)/ population, 5)*100 as infection_rate
FROM compactCovidDeaths11
where population > 0 AND population is not NULL -- country like '%states'
GROUP BY country, population
ORDER BY infection_rate desc

-- Global Numbers
-- import CovidVaccinations11 

SELECT *
from CovidVaccinations11

-- populaton vaccinated
SELECT vac.continent, dea.country , dea. date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations ) OVER(partition by dea.country order by dea.country , dea.date) as sum_new_vac
--, Round(sum_new_vac/dea.population,5)*100 as prc_total_vac
from compactCovidDeaths11 dea
join CovidVaccinations11 vac
    on dea.country = vac.country
    and dea.date = vac.date
WHERE dea.country is not NULL
And dea.date is not NULL   
ORDER BY country , date

-- using  Covid Deaths
SELECT *
FROM compactCovidDeaths11


-- using CTE to sum of new vaccinations and its percentage vs population
with PopVsVac (CONTINENT, COUNTRY, DATE, POPULATION, NEW_VACCINATION, sum_new_vac)
AS
(
    SELECT vac.continent, dea.country , dea. date, dea.population, vac.new_vaccinations 
    , SUM(vac.new_vaccinations ) OVER(partition by dea.country order by dea.country , dea.date) as sum_new_vac
    --, Round(sum_new_vac/dea.population,5)*100 as prc_total_vac
    from compactCovidDeaths11 dea
    join CovidVaccinations11 vac
    on dea.country = vac.country
    and dea.date = vac.date
WHERE dea.country is not NULL
And dea.date is not NULL   
--ORDER BY country , date
)
SELECT * , Round(sum_new_vac/population,5)*100 as prc_total_vac
FROM PopVsVac



-- using temo table to sum of new vaccinations and its percentage vs population
DROP TABLE if EXISTS #PopulationVSvaccinations
CREATE TABLE #PopulationVSvaccinations
(
   CONTINENT nvarchar(max),
   COUNTRY nvarchar(max),
   date date,
   population float,
   New_vaccinations FLOAT,
   sum_new_vac FLOAT 
)
INSERT into #PopulationVSvaccinations
SELECT vac.continent, dea.country , dea. date, dea.population, vac.new_vaccinations 
    , SUM(vac.new_vaccinations ) OVER(partition by dea.country order by  dea.date) as sum_new_vac
    --, Round(sum_new_vac/dea.population,5)*100 as prc_total_vac
    from compactCovidDeaths11 dea
    join CovidVaccinations11 vac
    on dea.country = vac.country
    and dea.date = vac.date
WHERE dea.country is not NULL
And dea.date is not NULL   
--ORDER BY country , date
SELECT * , Round(sum_new_vac/population,5)*100 as prc_total_vac
FROM #PopulationVSvaccinations


-- Creating view to store data for later visualizations
CREATE VIEW PopulationVSvaccinations AS
SELECT vac.continent, dea.country , dea. date, dea.population, vac.new_vaccinations 
    , SUM(vac.new_vaccinations ) OVER(partition by dea.country order by  dea.date) as sum_new_vac
    --, Round(sum_new_vac/dea.population,5)*100 as prc_total_vac
    from compactCovidDeaths11 dea
    join CovidVaccinations11 vac
    on dea.country = vac.country
    and dea.date = vac.date
WHERE dea.country is not NULL
And dea.date is not NULL   
