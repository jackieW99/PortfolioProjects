Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows percentage of population got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
From PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Countries with highest infection rate compared to population
Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location,population
order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing continents with highest death count per population
-- Variation thats used for drill
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


--Correct version for continent
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is null
Group by location
order by TotalDeathCount desc


-- Global Numbers
Select Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercent
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


-- Looking at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
and dea.Location like '%states%'
order by 2,3

-- Use CTE

With PopvsVac(Continent, Location, Date , Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
and dea.Location like '%states%'
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
and dea.Location like '%states%'

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location , dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
and dea.Location like '%states%'


Select * 
From PercentPopulationVaccinated