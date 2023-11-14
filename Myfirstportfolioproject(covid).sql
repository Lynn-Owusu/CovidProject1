
Select *
From PortfolioProject.dbo.[Covid Deaths]
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.[Covid Vaccinations]
--order by 3,4

--Select the data we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.[Covid Deaths]
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CONVERT(float ,total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
From PortfolioProject.dbo.[Covid Deaths]
Where Location like '%africa%'
--Where continent is not null
order by 1,2

--Looking for Total cases vs Population
 

--Looking at countries with highest infection rate compared to population
Select location, Population, MAX(total_cases) as HighestInfectedCount, MAX((CONVERT(float ,total_cases)/NULLIF(CONVERT(float, population),0)))*100 as 
PercentPopulationInfected
From PortfolioProject.dbo.[Covid Deaths]
--Where Location like '%africa%'
Where continent is not null
Group by location, Population
order by PercentPopulationInfected desc

--Showing countries with Highest death count per Population

Select location, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject.dbo.[Covid Deaths]
--Where Location like '%africa%'
Where continent is null
Group by location
order by Totaldeathcount desc

--LET'S BREAK IT OUT BY CONTINENT
--Showing the continents with the highest death counts

Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
From PortfolioProject.dbo.[Covid Deaths]
--Where Location like '%africa%'
Where continent is not null
Group by continent
order by Totaldeathcount desc

--GLOBAL NUMBERS


Select SUM(new_cases)as total_cases, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(total_deaths as int))/  NULLIF(SUM(new_cases), 0) as DeathPercentage
From PortfolioProject.dbo.[Covid Deaths]
Where Location like '%africa%'
--Where continent is not null
--Group By date
Order by 1,2



--Looking at total populations vs total vaccinations

--USE CTE

With PopvsVac(Continent, Location, date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) SOVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/popualtion)*100
From PortfolioProject.dbo.[Covid Deaths] dea
Join PortfolioProject.dbo.[Covid Vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists  #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/popualtion)*100
From PortfolioProject.dbo.[Covid Deaths] dea
Join PortfolioProject.dbo.[Covid Vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3
Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

          
--Create view to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/popualtion)*100
From PortfolioProject.dbo.[Covid Deaths] dea
Join PortfolioProject.dbo.[Covid Vaccinations] vac
On dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated



