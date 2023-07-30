-- Skills Used: Joins, Aggregate Functions, Convert and Cast Functions, CTE'S,
-- Temp Tables, Views


Select * 
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

Select Continent, location, date, total_cases, new_cases, total_deaths, population 
From CovidPortfolioProject..CovidDeaths
Where continent is not null
Order by 2, 3

--Total Death Vs Population

Select Continent, Location, date, population, total_deaths, 
(total_deaths / population) * 100 as DeathPercentagePerPopulation
From CovidPortfolioProject..CovidDeaths
where continent is not null 
order by 2, 3 

--Total deaths vs total cases

Select Continent, location, date, total_cases, total_deaths
,(convert(float,total_deaths)/convert(float, total_cases))*100 
as Death_Percentage_PerTotalCases_PerDay
from CovidPortfolioProject..CovidDeaths
where continent is not null
order by 2,3

--Population Vs Total Cases

Select Continent,location, date, population , total_cases,
(convert(float,total_cases) / population)*100 as RateOfInfection
From CovidPortfolioProject..CovidDeaths
where continent is not null 
group by Continent,location, date, population , total_cases
order by 2, 3


--Max Cases each country have reached and the percentage to the population

Select Continent,location, Max(convert(float,total_cases)) as MaxCasesPerCountry
, Max((total_cases/population))*100 as RateOfTotalCasesPerCountry
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by Continent,location
order by 3 desc

--Max death each country have reached and the percentage to the population

Select Continent,location, Max(convert(float,total_deaths)) as MaxDeathsPerCountry
, Max((total_deaths/population))*100 as RateOfTotalDeathsPerCountry
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by  Continent,location
order by 3 desc

--Breaking Things By Continent

--Max Cases each continent have reached and the percentage to the population

Select  Continent, Max(convert(float,total_cases)) as MaxCasesPerContinent
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by  Continent
order by MaxCasesPerContinent desc


--Max death each Continent have reached and the percentage to the population

Select  continent, Max(convert(float,total_deaths)) as MaxDeathsPerContinent
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by  continent
order by MaxDeathsPerContinent desc

--Global Numbers

Select SUM(new_cases) GlobalCases , SUM(CONVERT(float,new_deaths)) GlobalDeaths,
(SUM(CONVERT(float,new_deaths))/SUM(new_cases))*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null
--and location = 'Egypt'
--group by location
order by 1, 2


-- Vaccinated table--

Select *
from CovidPortfolioProject..CovidVaccine
order by 3, 4


-- Total vaccinations Vs Population 

Select continent, location, date, population, total_vaccinations
from CovidPortfolioProject..CovidVaccine
where continent is not null
and total_vaccinations is not null
order by 2,3 

-- Total vaccination Vs Total Cases

Select dea.continent, dea.location, dea.date, dea.total_cases, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location order by 
dea.location , dea.date) as RollingPeopleVccinated
from CovidPortfolioProject..CovidDeaths as dea
join CovidPortfolioProject..CovidVaccine as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- CTE Table to show The Rate of people vaccinated to the population
With PopVsVac (continent, location, date, population, new_vaccinations
, RollingPeopleVccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.total_cases, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location order by 
dea.location , dea.date) as RollingPeopleVccinated
from CovidPortfolioProject..CovidDeaths as dea
join CovidPortfolioProject..CovidVaccine as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVccinated/population)*100 as RateOfPeopleVaccinated
from PopVsVac

--Temp Table to calculate the above partition by

Drop Table if exists #RatePeopleVccinated 
Create Table #RatePeopleVccinated
(continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVccinated numeric
)

Insert Into #RatePeopleVccinated
Select dea.continent, dea.location, dea.date, dea.total_cases, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location order by 
dea.location , dea.date) as RollingPeopleVccinated
from CovidPortfolioProject..CovidDeaths as dea
join CovidPortfolioProject..CovidVaccine as vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select *, (RollingPeopleVccinated/population)*100 as RateOfVaccinatedPeople
FROM #RatePeopleVccinated
order by 2


-- people vaccinated Vs Total Vaccinations && People fully Vaccinated Vs people vaccinated
Select continent, location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated
from CovidPortfolioProject..CovidVaccine
where continent is not null
order by 1, 2

-- CTE SHOWS the rate of the above select statement
with VacRates (continent, location, date, total_vaccinations ,people_vaccinated
,people_fully_vaccinated) 
as
(
Select continent, location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated
from CovidPortfolioProject..CovidVaccine
where continent is not null
)
Select *, (people_vaccinated/cast(total_vaccinations as float))*100 as RateOfPeopleVaccinated,
(people_fully_vaccinated/cast(people_vaccinated as float))*100 as RateOfPeopleFullyVaccinated
from VacRates
where people_fully_vaccinated is not null


-- Temp Table for the rate of vaccinations above
Drop Table if exists #RateOfVaccinations
CREATE TABLE #RateOfVaccinations
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
total_vaccinations numeric,
people_vaccinated numeric,
people_fully_vaccinated numeric
)

INSERT INTO #RateOfVaccinations
Select continent, location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated
from CovidPortfolioProject..CovidVaccine
--where continent is not null

Select *, (people_vaccinated/cast(total_vaccinations as float))*100 as RateOfPeopleVaccinated,
(people_fully_vaccinated/cast(people_vaccinated as float))*100 as RateOfPeopleFullyVaccinated
from #RateOfVaccinations
where people_fully_vaccinated is not null
And continent is not null


-- creating view to store data for later visualization

Create View percentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.total_cases, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition By dea.location order by 
dea.location , dea.date) as RollingPeopleVccinated
from CovidPortfolioProject..CovidDeaths as dea
join CovidPortfolioProject..CovidVaccine as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Create View Global_Numbers as 
Select SUM(new_cases) GlobalCases , SUM(CONVERT(float,new_deaths)) GlobalDeaths,
(SUM(CONVERT(float,new_deaths))/SUM(new_cases))*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null
--and location = 'Egypt'
--group by location

Create View ContinentCases as
Select  Continent, Max(convert(float,total_cases)) as MaxCasesPerContinent
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by  Continent
--order by MaxCasesPerContinent desc

Create View ContinentDeaths as
Select  continent, Max(convert(float,total_deaths)) as MaxDeathsPerContinent
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by  continent
--order by MaxDeathsPerContinent desc
