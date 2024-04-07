select *
from CovidDeaths
Where continent is not null
Order by 3,4

select *
from CovidVac

Select location, date, total_cases, total_deaths, population
from CovidDeaths
Order by 1,2


-- looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Nigeria


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like '%Nigeria%'
and total_cases is not null
Order by 1,2


-- Looking at  Total cases vs Population in Nigeria
--Shows what percentage of population got COVID

Select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as Contracted_Percentage
from CovidDeaths
Where location like '%Nigeria%'
Order by 4 desc

--Countries with the highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Contracted_Percentage
from CovidDeaths
Group by location, population
Order by Contracted_Percentage desc

-- African countries with the highest deathcount per population

Select location, population, max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
Where continent = 'Africa'
Group by location, population
Order by Total_Death_Count desc

-- Breaking Things Down by Continent

Select location, max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
Where continent is null
Group by location
Order by Total_Death_Count desc

 
 --Showing the Continent with the Highest DeathCount

 Select location, max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
Where continent is null
Group by location
Order by Total_Death_Count desc


-- Global Numbers (Total Deaths & Overall Death Percentage)

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
Where continent is not null
Order by 1,2


--------------

Select *
from CovidVac
Order by 3,4

Select *
From CovidDeaths as dea
Join CovidVac as vac
	On dea.location = vac.location
	And dea.date = vac.date


---Total Population vs Vaccinations (World)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Cum_NewVac
	From CovidDeaths as dea
Join CovidVac as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
And population is not null
Order by 1,2,3

With TPOPvsTVAC (continent, location, date, population, new_vaccinations, Cum_NewVac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Cum_NewVac
	From CovidDeaths as dea
Join CovidVac as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
And population is not null
-- Order by 1,2,3
)
Select *, (Cum_NewVac/population)*100 Cum_NewVac_Percentage
From TPOPvsTVAC



---Total Population vs Vaccinations (Nigeria)

Select dea.location, dea.date, dea.population, dea.new_deaths, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Cum_NewVac
	From CovidDeaths as dea
Join CovidVac as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.location = 'Nigeria' 
	and population is not null
Order by 2,3


--CTE

With TPOPvsTVAC (location, date, population, new_deaths, new_vaccinations, Cum_NewVac)
as
(Select dea.location, dea.date, dea.population, dea.new_deaths, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Cum_NewVac
	From CovidDeaths as dea
Join CovidVac as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.location = 'Nigeria' 
	and population is not null
--Order by 2,3
)
Select *, (Cum_NewVac/population)*100 Cum_NewVac_Percentage
From TPOPvsTVAC

--Temp Table

Drop table if exists #Cum_NewVac_Percentage
Create Table #Cum_NewVac_Percentage
(location nvarchar(255), date datetime, population nvarchar(255), 
new_deaths numeric, new_vaccinations numeric, Cum_NewVac numeric)
Insert into #Cum_NewVac_Percentage
Select dea.location, dea.date, dea.population, dea.new_deaths, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, dea.date) as Cum_NewVac
	From CovidDeaths as dea
Join CovidVac as vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.location = 'Nigeria' 
	and population is not null
--Order by 2,3

Select *
From #Cum_NewVac_Percentage





--Creating View to Store Data for later visualizations

Create View DeathPercentageNigeria as
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location like '%Nigeria%'
and total_cases is not null
--Order by 1,2


Create View CovidRateNigeria as
Select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as Contracted_Percentage
from CovidDeaths
Where location like '%Nigeria%'
--Order by 4 desc


Create View HighestDeathAfrica as
Select location, population, max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
Where continent = 'Africa'
Group by location, population
--Order by Total_Death_Count desc


Create View WorldDeathRate as
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths
Where continent is not null
--Order by 1,2


Create View TotalDeathWorld as
 Select location, max(cast(total_deaths as int)) as Total_Death_Count
from CovidDeaths
Where continent is null
Group by location
--Order by Total_Death_Count desc