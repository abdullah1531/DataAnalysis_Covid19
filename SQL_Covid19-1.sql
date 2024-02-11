SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%Hungary%'
and continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
order by 1,2

-- Countries with hoghest Infection Rates compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
Group by Location, population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- Let's break things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- continents with highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
group by date
order by 1,2

-- overall across the world

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%Hungary%'
where continent is not null
--group by date
order by 1,2

-- Total Population vs Vaccinations

Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
order by 2,3

-- Use CTE
with PopvsVac (Continent, Date, Location, Population, New_Vaccinations, RollingPeopleVaccinated)

as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
--order by 2,3
)

Select * , (RollingPeopleVaccinated / Population)*100
From PopvsVac

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
--where death.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated / Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for visulaizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated