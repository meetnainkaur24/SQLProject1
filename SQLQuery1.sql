select *
From [Portfolio Projects].dbo.CovidDeaths$
where continent is not null
Order By 3,4

--select *
--From [Portfolio Projects].dbo.CovidVaccinations$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Projects].dbo.CovidDeaths$
Order By 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
From [Portfolio Projects].dbo.CovidDeaths$
where continent is not null
Where location like '%states%'
Order By 1,2

select Location, date, population, total_cases, (total_cases/population)*100 as casespercent
From [Portfolio Projects].dbo.CovidDeaths$
Where location like '%india%'
Order By 1,2

select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Projects].dbo.CovidDeaths$
Group By Location, Population
Order By PercentPopulationInfected desc

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Projects].dbo.CovidDeaths$
where continent is not null
Group By Location
Order  By TotalDeathCount desc

select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Projects].dbo.CovidDeaths$
where continent is not null
Group By Continent
Order  By TotalDeathCount desc

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Projects].dbo.CovidDeaths$
where continent is null
Group By Location
Order  By TotalDeathCount desc


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercent
From [Portfolio Projects].dbo.CovidDeaths$
where continent is not null
--group by Date
Order By 1,2


With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
    From [Portfolio Projects].dbo.CovidDeaths$ dea
    Join [Portfolio Projects].dbo.CovidVaccinations$ vac
        on dea.location = vac.location
        and dea.date = vac.date
    where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)* 100 as PercentageVaccinated
From PopvsVac



Drop Table if exists #PercentPopulationVaccinated
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
    Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
    From [Portfolio Projects].dbo.CovidDeaths$ dea
    Join [Portfolio Projects].dbo.CovidVaccinations$ vac
        on dea.location = vac.location
        and dea.date = vac.date
    where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)* 100 as PercentageVaccinated
From #PercentPopulationVaccinated


Create View PercentPopulationVaccinated as
    