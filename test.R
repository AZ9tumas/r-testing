# Plot A: The Line Chart

# Tasks : Select a country to show its path ~ Section 3.1.

library(animint2)
names(WorldBank)
WorldBank$Region <- sub(" (all income levels)", "", WorldBank$region, fixed = TRUE)

world_bank <- subset(WorldBank, is.finite(fertility.rate) & is.finite(life.expectancy))
world_bank <- subset(world_bank, select = c(
  Region, country, year, fertility.rate, life.expectancy, lending, population, income
))

world_bank_1975 <- subset(world_bank, year == 1975)
world_bank_before_1975 <- subset(world_bank, year <= 1975)

getDataRange <- function(yearstart, range){
  return (subset(world_bank, year >= yearstart & year <= yearstart + range))
}

fertilityplot <- ggplot() + 
  geom_point(mapping = aes(x = life.expectancy, y = fertility.rate,
                          color = Region, group = country, fill = Region,
                          tooltip=country, key = country), 
             data = getDataRange(1970, 10), showSelected = "year", clickSelects="country") +
  
  geom_text(aes(x = life.expectancy, y = fertility.rate, label = country, key = country), 
            data = getDataRange(1970, 10), showSelected = c("year", "country")) +
  
  geom_path(mapping = aes(x = life.expectancy, y = fertility.rate,
                          color = Region, group = country, 
                          tooltip=country), 
            data = getDataRange(1970, 10), showSelected = "country") +
  ggtitle("Life Expectancy vs Fertility Rate with Labels")

animint2dir(list(
  viz1 = fertilityplot,
  source = fertilityplot,
  duration = list(frame = 250),
  time = list(variable="year", ms=1000),
  title = "Life Expectancy vs Fertility Rate"
), out.dir = "test")

# Add geoms that show the selected year: a geom_text() on the scatterplot