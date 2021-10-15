
select *
From SQLproject..CovidDeaths
Where continent is not null
Order by 3,4

select *
From SQLproject..CovidVacinations
Where continent is not null
Order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths,population
From SQLproject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From SQLproject..CovidDeaths
where location like '%states' and continent is not null
Order by 1,2

--looking at the total cases vs population
--shows what percentage of population got Covid
Select location, date, total_cases, population,(total_cases/population)*100 as CovidPercentage
From SQLproject..CovidDeaths
--where location like 'Egypt' 
Order by 1,2


-- looking at countries with highest infection rate to population
Select location, population, MAX(total_cases) as HighestInfectuinCount, MAX((total_cases)/population)*100 as PercentPopulationInfected
From SQLproject..CovidDeaths
--where location like 'Egypt'
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc


--showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLproject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Let's break things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLproject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc


--showing the continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From SQLproject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--Golbal numbers
--death percentage across the world
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From SQLproject..CovidDeaths
--where location like '%states' and 
where continent is not null
--group by date
Order by 1,2

--death percetange every day
Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_death,
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From SQLproject..CovidDeaths
--where location like '%states' and 
where continent is not null
group by date
Order by 1,2

--Lookinh at total population vs vaccinations
select death.continent, death.location , death.date ,death.population, vacs.new_vaccinations
,SUM(convert(int,vacs.new_vaccinations)) OVER (Partition by death.location Order by death.location,death.date) 
as RollingPeopleVaccinated, (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
From SQLproject..CovidDeaths death
join SQLproject..CovidVacinations vacs
	on death.location = vacs.location
	and death.date = vacs.date
where death.continent is not null
order by 2,3


-- use cte

with PopVsVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
as
(
select death.continent, death.location , death.date ,death.population, vacs.new_vaccinations
,SUM(convert(int,vacs.new_vaccinations)) OVER (Partition by death.location Order by death.location,death.date) 
as RollingPeopleVaccinated--, (RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
From SQLproject..CovidDeaths death
join SQLproject..CovidVacinations vacs
	on death.location = vacs.location
	and death.date = vacs.date
where death.continent is not null
--order by 2,3
)
--Select *,(RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
--from PopVsVac

--PeopleVaccinatedPercentage for each country
Select location,max((RollingPeopleVaccinated/population)*100) as PeopleVaccinatedPercentage
from PopVsVac
group by location 




-- Temp table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select death.continent, death.location , death.date ,death.population, vacs.new_vaccinations
,SUM(cast(vacs.new_vaccinations as int)) OVER (Partition by death.location Order by death.location,death.date) 
as RollingPeopleVaccinated
From SQLproject..CovidDeaths death
join SQLproject..CovidVacinations vacs
	on death.location = vacs.location
	and death.date = vacs.date
where death.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
from #PercentPopulationVaccinated



--Creating view to store data for later visualizations

Create view PercentPopilationVaccinated as 
select death.continent, death.location , death.date ,death.population, vacs.new_vaccinations
,SUM(cast(vacs.new_vaccinations as int)) OVER (Partition by death.location Order by death.location,death.date) 
as RollingPeopleVaccinated
From SQLproject..CovidDeaths death
join SQLproject..CovidVacinations vacs
	on death.location = vacs.location
	and death.date = vacs.date
where death.continent is not null
--order by 2,3