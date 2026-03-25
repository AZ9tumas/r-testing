library(animint2)

# read in final_data.csv
final_data <- read.csv("HumanProgressIndex_Visualization/final_data.csv")

unique(final_data$region)

better_data <- subset(final_data, region != "" & !is.na(hdi) & !is.na(le) & !is.na(eys) & !is.na(gni) & !is.na(pop))
final_data <- better_data
# [1] "country"       "region"        "hdicode"       "hdi_rank_2022"
# [5] "hdi"           "le"            "eys"           "gni"   
# [9] "pop"           "year"

# eys - expected years of schooling
# gni - gross national income
# le - life expectancy
# hdi - human development index

colnames(final_data)

head(final_data, 5)

hdiplot1 <- ggplot() +

    geom_hline(mapping = aes(yintercept = eys, key = country), data = final_data,
        showSelected = c("year", "country"), alpha = 0.3) +

    geom_vline(mapping = aes(xintercept = year, key = year), data = final_data,
        showSelected = "year", alpha = 0.3) +

    geom_path(mapping = aes(x = year, y = eys, color = region, group = country, tooltip=country), 
        data = final_data, clickSelects = "country", alpha = 0.65) +

    geom_point(mapping = aes(x = year, y = eys,
                color = region, group = country, fill = region,
                size = pop, tooltip=country, key = country), 
        data = final_data, showSelected = c("year", "country"), clickSelects="country") +
    
    geom_text(mapping = aes(x = year, y = eys, label=country, key=country), data=final_data,
        showSelected = c("year", "country"), clickSelects="country") +

    labs(x = "Year", y = "Expected Years of Schooling", title = "Expected Years of Schooling Plots")

life_expt <- ggplot() +

    geom_hline(mapping = aes(yintercept = le, key = country), data = final_data,
        showSelected = c("year", "country"), alpha = 0.3) +

    geom_vline(mapping = aes(xintercept = year, key = year), data = final_data,
        showSelected = "year", alpha = 0.3) +

    geom_path(mapping = aes(x = year, y = le, color = region, group = country, tooltip=country), 
        data = final_data, clickSelects = "country", alpha = 0.65) +

    geom_point(mapping = aes(x = year, y = le,
                color = region, group = country, fill = region,
                size = pop, tooltip=country, key = country), 
        data = final_data, showSelected = c("year", "country"), clickSelects="country") +
    
    geom_text(mapping = aes(x = year, y = le, label=country, key=country), data=final_data,
        showSelected = c("year", "country"), clickSelects="country") +


    labs(x = "Year", y = "Life Expectancy", title = "Life Expectancy Plots")

gniplot <- ggplot() +

    geom_hline(mapping = aes(yintercept = gni, key = country), data = final_data,
        showSelected = c("year", "country"), alpha = 0.3) +

    geom_vline(mapping = aes(xintercept = year, key = year), data = final_data,
        showSelected = "year", alpha = 0.3) +

    geom_path(mapping = aes(x = year, y = gni, color = region, group = country, tooltip=country), 
        data = final_data, clickSelects = "country", alpha = 0.65) +

    geom_point(mapping = aes(x = year, y = gni,
                color = region, group = country, fill = region,
                size = pop, tooltip=country, key = country), 
        data = final_data, showSelected = c("year", "country"), clickSelects="country") +

    geom_text(mapping = aes(x = year, y = gni, label=country, key=country), data=final_data,
        showSelected = c("year", "country"), clickSelects="country") +

    labs(x = "Year", y = "Gross National Income", title = "Gross National Income Plots")

viz <- list(
    hdiplot = hdiplot1,
    lifeexpt = life_expt,
    gniplot = gniplot,
    duration = list(year = 1000),
    time = list(variable="year", ms=1000)
)

animint2dir(viz, out.dir = "hdi_visualization")