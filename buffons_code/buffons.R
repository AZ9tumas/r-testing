library(ggplot2)
library(animint2)
library(data.table)

# const params
ITR_COUNT <- 350
t <- 1
l <- 1
xmax <- 10
ymax <- 10

# calculate the data
data_list <- list()

# helpers
check_cross <- function (ystart, yend){
    return (as.integer(ystart / t) != as.integer(yend / t))
}

# locals
cross_count <- 0

# main
for (i in 1:ITR_COUNT) {
    x <- runif(1, min = 0, max = ymax)[[1]]
    y <- runif(1, min = 0, max = ymax)[[1]]
    theta <- runif(1, min = 0, max = pi)[[1]]
    
    xstart <- x - (l / 2) * cos(theta)
    ystart <- y - (l / 2) * sin(theta)
    xend <- x + (l / 2) * cos(theta)
    yend <- y + (l / 2) * sin(theta)

    cross <- as.integer(check_cross(ystart, yend))
    cross_count <- cross_count + cross
    pi_estimate <- ifelse(cross_count != 0, (2 * l * i) / (t * cross_count), 0)
    
    data_list[[i]] <- data.frame(
        x0 = x,
        y0 = y,
        theta = theta,
        xstart = xstart,
        ystart = ystart,
        xend = xend,
        yend = yend,
        cross = ifelse(cross, "miss", "hit"),
        pi_est = pi_estimate,
        itr = i
    )
}

dt <- rbindlist(data_list)
required <- dt[1:ITR_COUNT, 4:8, with = FALSE]
ndt <- rbindlist(
    lapply(1:ITR_COUNT, function(i) cbind(required[1:i], itr = i))
)

# actual plotting

plot <- ggplot() +
    xlim(0, xmax) +
    ylim(0, ymax) +
    
    geom_hline(yintercept = 1:10, linewidth = 0.1, color = "#c1daf5") +

    geom_segment(mapping = aes(x = xstart, y = ystart, xend = xend, yend = yend, color = cross),
                data = ndt, showSelected = "itr") +

    scale_color_manual(
        values = c("miss" = "#0d3a6b", "hit" = "#4283c9"),
        labels = c("Miss", "Hit"),
        name = "Result"
    ) +

    labs(title = "Buffon's Needle Simulation", subtitle = paste("Total Drops:", ITR_COUNT), x = "", y = "") +
    
    theme_light(base_size = 14)

err_plot <- ggplot() +
    ylim(2, 5) +

    labs(title = "Pi Estimate", x = "Iteration Count", y = "Estimated Pi") +

    geom_vline(mapping = aes(xintercept = itr), color = "#70a4db", alpha = 0.6, showSelected = "itr", data = dt, linewidth = 0.1) +
    
    geom_line(mapping = aes(y = pi_est, x = itr), color = "#70a4db", data = dt) +
    
    geom_point(mapping = aes(y = pi_est, x = itr, color = cross), data = dt) +

    geom_text(mapping = aes(x = itr, y = pi_est, label = pi_est), data = dt, showSelected = "itr", size = 15) +

    geom_hline(yintercept = pi, color = "#174271", linewidth = 0.35) +

    scale_color_manual(
        values = c("miss" = "#0d3a6b", "hit" = "#4283c9"),
        labels = c("Miss", "Hit"),
        name = "Result"
    ) +
    
    theme_light(base_size = 14)

# animint stuff
viz <- animint(
  title = "Buffon's Needle",
  source = plot,
  errplot = err_plot,
  duration = list(frame = 250),
  time = list(variable="itr", ms=100)
)


animint2dir(viz, out.dir = "buffons", open.browser = TRUE)

