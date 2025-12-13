/*
Covid-19 Data Exploration

Skills used:
Joins, CTEs, Temp Tables, Window Functions,
Aggregate Functions, Creating Views, Converting Data Types
*/

-- Raw data check

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by location, date


-- Select base data we will work with

Select
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by location, date


-- Total Cases vs Total Deaths
-- Likelihood of dying if you contract Covid in a country

Select
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / NULLIF(total_cases, 0)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
  and continent is not null
Order by location, date


-- Total Cases vs Population
-- Percentage of population infected with Covid

Select
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Order by location, date


-- Countries with Highest Infection Rate compared to Population

Select
    location,
    population,
    MAX(total_cases) as HighestInfectionCount,
    MAX((total_cases / population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count

Select
    location,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Breaking things down by continent
-- Continents with highest death count

Select
    continent,
    MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select
    SUM(new_cases) as TotalCases,
    SUM(CAST(new_deaths as int)) as TotalDeaths,
    (SUM(CAST(new_deaths as int)) / NULLIF(SUM(new_cases), 0)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null


-- Total Population vs Vaccinations
-- Rolling count of people vaccinated

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
Order by dea.location, dea.date


-- Using CTE to calculate vaccination percentage

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
    (RollingPeopleVaccinated / population) * 100 as PercentVaccinated
From PopvsVac


-- Using Temp Table for vaccination analysis

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations as int))
        OVER (Partition by dea.location Order by dea.date)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null

Select
    *,
    (RollingPeopleVaccinated / population) * 100 as PercentVaccinated
From #PercentPopulationVaccinated


-- Creating View for later visualizations

Create View PercentPopulationVaccinated as
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
