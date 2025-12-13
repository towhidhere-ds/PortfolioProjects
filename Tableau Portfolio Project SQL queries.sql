/*
Queries used for Tableau Project
*/


-- 1. Global numbers
-- Total cases, total deaths, and death percentage

Select
    SUM(new_cases) as TotalCases,
    SUM(CAST(new_deaths as int)) as TotalDeaths,
    (SUM(CAST(new_deaths as int)) / NULLIF(SUM(new_cases), 0)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by TotalCases, TotalDeaths


-- Just a double check based on the data provided
-- Numbers are extremely close, so we keep the first query
-- Second query includes "International" location

/*
Select
    SUM(new_cases) as TotalCases,
    SUM(CAST(new_deaths as int)) as TotalDeaths,
    (SUM(CAST(new_deaths as int)) / NULLIF(SUM(new_cases), 0)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'World'
Order by TotalCases, TotalDeaths
*/


-- 2. Total death count by continent
-- Excluding World, European Union, and International for consistency
-- European Union is part of Europe

Select
    location,
    SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
  and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc


-- 3. Countries with highest infection rate compared to population

Select
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


-- 4. Infection rate over time by country

Select
    location,
    population,
    date,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc




-- Queries originally explored but excluded
-- Kept here for reference


-- 5. Total vaccinations by country over time

Select
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    MAX(vac.total_vaccinations) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
Group by dea.continent, dea.location, dea.date, dea.population
Order by dea.continent, dea.location, dea.date


-- 6. Global numbers (same as query #1)

Select
    SUM(new_cases) as TotalCases,
    SUM(CAST(new_deaths as int)) as TotalDeaths,
    (SUM(CAST(new_deaths as int)) / NULLIF(SUM(new_cases), 0)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by TotalCases, TotalDeaths


-- 7. Total death count by continent (revisited)

Select
    location,
    SUM(CAST(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
  and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc


-- 8. Population vs total cases

Select
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc


-- 9. Base table for timeline visual

Select
    location,
    date,
    population,
    total_cases,
    total_deaths
From PortfolioProject..CovidDeaths
Where continent is not null
Order by location, date


-- 10. Population vs vaccinations using CTE

With PopvsVac as
(
    Select
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations as int))
            OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
    From PortfolioProject..CovidDeaths dea
    Join PortfolioProject..CovidVaccinations vac
        On dea.location = vac.location
       and dea.date = vac.date
    Where dea.continent is not null
)
Select
    *,
    (RollingPeopleVaccinated / population) * 100 as PercentPeopleVaccinated
From PopvsVac


-- 11. Infection rate over time (final check)

Select
    location,
    population,
    date,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc
