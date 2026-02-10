
library(data.table)
library(ggplot2)
library(animint2)

ITERATION_COUNT <- 105

sample_data <- list()

t <- 1
l <- 1
xmax <- 10
ymax <- 10

check_cross <- function (ystart, yend){
  return (as.integer(ystart / t) != as.integer(yend / t))
}

cross_count <- 0

for (i in 1:ITERATION_COUNT) {
  x <- runif(1, min = 0, max = ymax)[[1]]
  y <- runif(1, min = 0, max = ymax)[[1]]
  theta <- runif(1, min = 0, max = pi)[[1]]
  
  xstart <- x - (l / 2) * cos(theta)
  ystart <- y - (l / 2) * sin(theta)
  xend <- x + (l / 2) * cos(theta)
  yend <- y + (l / 2) * sin(theta)
  
  is_cross <- as.integer(check_cross(ystart, yend))
  cross_count <- cross_count + is_cross
  
  pi_estimate <- 0
  
  if (cross_count != 0){
    pi_estimate <- (2 * l * i) / (t * cross_count)
  }
  
  sample_data[[i]] <- data.frame(
    x0 = x, 
    y0 = y,
    theta = theta,
    xstart = xstart,
    ystart = ystart,
    xend = xend,
    yend = yend,
    cross = ifelse(is_cross, "miss", "hit"),
    pi_est = pi_estimate,
    itr = i + 1,
    err = abs(pi - pi_estimate) / pi
  )
}

df <- do.call(rbind, sample_data)
dt <- as.data.table(df)
cumulative_dt <- rbindlist(
  lapply(1:ITERATION_COUNT, function(i) cbind(dt[1:i], frame = i))
)

# actual plotting

plot <- ggplot() + 
  geom_hline(yintercept = 1:10, 
             linewidth = 0.1,
             color = "#c1daf5") +
  
  geom_segment(mapping = aes(x = xstart, y = ystart, xend = xend, yend = yend, color = cross),
               data = cumulative_dt, showSelected = "frame") + 
  
  scale_color_manual(
    values = c("miss" = "#0d3a6b", "hit" = "#4283c9"), 
    labels = c("Miss", "Hit"),              
    name = "Result"
  ) +
  labs(title = "Buffon's Needle Simulation", subtitle = paste("Total Drops:", ITERATION_COUNT), x = "", y = "") +
  theme_linedraw(base_size = 14)

err_plot <- ggplot() + 
  labs(title = "Error analysis", x = "Iteration Count", y = "Error (Normalized)") +
  geom_vline(mapping = aes(xintercept = itr), color = "#70a4db", alpha = 0.6, showSelected = "frame", data = cumulative_dt)
  geom_line(mapping = aes(y = err, x = itr), color = "#70a4db", data = cumulative_dt) +
  geom_point(mapping = aes(y = err, x = itr, color = cross), data = cumulative_dt) +
  scale_color_manual(
    values = c("miss" = "#0d3a6b", "hit" = "#4283c9"), 
    labels = c("Miss", "Hit"),              
    name = "Result"
  ) +
  theme_linedraw(base_size = 14)

# animint stuff
viz <- animint(
  title = "Buffon's Needle",
  source = plot,
  errplot = err_plot,
  #duration = list(frame = 250),
  time = list(variable="frame", ms=1000)
)


animint2dir(viz, out.dir = "buffons_test", open.browser = TRUE)

