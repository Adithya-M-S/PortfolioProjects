--The data is taken from https://ourworldindata.org/covid-deaths and divided into two tables(CovidDeaths and CovidVaccinations)

Select *
From PortfolioProject..CovidDeaths
where continent is not Null
order by 3,4



--Select data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not Null
order by 1,2


--Looking at Total cases vs Total deathss
-- Shoes the likelihood of dying if you catch COVID in India

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%India%' and  continent is not Null
order by 1,2

-- Looking at total cases vs population

Select location, date, total_cases, population,(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where location like '%India%' and  continent is not Null
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select  location,population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where continent is not Null
group by location,population
order by PercentagePopulationInfected desc

-- Shwong countries with highest death count

Select  location,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not Null
group by location
order by TotalDeathCount desc

-- Breakdown by continent
-- Shwong the continients wih hihes death count


Select  continent,Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not Null
group by continent
order by TotalDeathCount desc




-- Global numbers

Select continent,Max(date), Max(total_cases) TotalCases, Max(total_deaths) TotalDeaths, (Max(total_deaths)/Max(total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by Continent,DeathPercentage desc

-- Looking ast total populatiom vs vaccination

Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,sum(cast(CV.new_vaccinations as float)) over (Partition by CD.location order by CD.location,CD.date) Rolling_new_vaccination
from PortfolioProject..CovidDeaths CD
join  PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not NULL
order by 2,3

-- Use CTE

with PopvsVac (Continent,Location,Population,New_Vaccination,RollingPeopleVaccinated)
as
(Select CD.continent,CD.location,CD.population,CV.new_vaccinations
,sum(cast(CV.new_vaccinations as float)) over (Partition by CD.location order by CD.location,CD.date) Rolling_new_vaccination
from PortfolioProject..CovidDeaths CD
join  PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not NULL
)
select *,(RollingPeopleVaccinated/Population)*100 PercentRollingPeopleVaccinated
from PopvsVac
--where Location = 'Albania'

-- Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,sum(cast(CV.new_vaccinations as float)) over (Partition by CD.location order by CD.location,CD.date) Rolling_new_vaccination
from PortfolioProject..CovidDeaths CD
join  PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not NULL
select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualisation


Create View PercentPopulationVaccinated as
Select CD.continent,CD.location,CD.date,CD.population,CV.new_vaccinations
,sum(cast(CV.new_vaccinations as float)) over (Partition by CD.location order by CD.location,CD.date) Rolling_new_vaccination
from PortfolioProject..CovidDeaths CD
join  PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not NULL

select * 
from PercentPopulationVaccinated

drop view PercentPopulationVaccinated
