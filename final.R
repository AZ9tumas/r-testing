library(animint2)

series1 <- seq(0, 2 * pi, length.out = 100)

df <- data.frame(
  x = c(series1, series1),
  y = c(sin(series1), cos(series1)),
  f = c(rep("sin", 100), rep("cos", 100))
)

plot1 <- ggplot() +
  geom_path(mapping = aes(x = x, y = y, group = f, color = f, tooltip = f), 
            data = df) + 
  geom_point(mapping = aes(x = x, y = y, group = f, color = f, tooptip = f),
             data = df, showSelected = "x") + 
  geom_vline(mapping = aes(xintercept = x, alpha = 0.15), linetype = "dashed", 
             data = data.frame(x = series1), showSelected = "x")

viz <- animint(plot1, duration = list(x = 100))
viz$time <- list(variable="x", ms=100)
viz

