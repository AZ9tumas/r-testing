library(ggplot2)
library(animint2)
library(data.table)

n <- 8
ball.count <- 250

peg_coordinates <- list()

count <- 1
for (y in seq(2 * n, n, by = -1)) {
  for (x in seq(y, 4 * n - y, by = 2)){
    peg_coordinates[[count]] <- data.frame(x = x, y = y)
    count <- count + 1
  }
}

for (y in seq(n - 1, 0, by = -1)) {
    for (x in seq(n, 3 * n, by = 1)){
        if (y %% 2 != x %% 2){
            next
        }
        peg_coordinates[[count]] <- data.frame(x = x, y = y)
        count <- count + 1
    }
}

peg.df <- do.call(rbind, peg_coordinates)
text.df <- data.frame(y = rep(0, n + (n%%2)), x = seq(n + (!(n%%2)), 3 * n, by = 2), label = 1:(n + (n%%2)))

ball.state <- list(list(x = 2 * n, y = 2 * n - 1))
simulation.list <- list(data.frame(x = 2 * n, y = 2 * n - 1, itr = 1))

slot.count2 <- integer(n + (n%%2))
slot.history2 <- list(data.frame(itr = 1, slot = seq_len(n + (n%%2)), count = slot.count2))

slot.count1 <- integer(n + (n%%2))
slot.history1 <- list(data.frame(itr = 1, slot = seq_len(n + (n%%2)), count = slot.count1))

for (i in 2:(2 * n + ball.count)){
  next_ball_state <- list()

  for (j in seq_along(ball.state)){
    ball <- ball.state[[j]]
    slot.index <- (ball$x - n) %/% 2 + 1

    if (ball$y == 0){
      slot.count2[slot.index] <- slot.count2[slot.index] + 1
    } else {
      if (ball$y == n) {
        slot.count1[slot.index] <- slot.count1[slot.index] + 1
      }
      # range
      if (ball$x == n){
        ball$x = n + 1
      } else if (ball$x == 3 * n){
        ball$x = 3 * n - 1
      } else {
        ball$x = ifelse(runif(1) < 0.5, ball$x - 1, ball$x + 1)
      }

      ball$y = ball$y - 1
      next_ball_state[[length(next_ball_state) + 1]] <- ball
      simulation.list[[length(simulation.list) + 1]] <- data.frame(x = ball$x, y = ball$y, itr = i)
    }
  }

  ball.state <- next_ball_state

  if (i <= ball.count){
    ball.state[[length(ball.state) + 1]] <- list(x = 2 * n, y = 2 * n - 1)
    simulation.list[[length(simulation.list) + 1]] <- data.frame(x = 2 * n, y = 2 * n - 1, itr = i)
  }

  slot.history2[[length(slot.history2) + 1]] <- data.frame(
    itr = i,
    slot = seq_len(n + (n%%2)),
    count = slot.count2
  )

  slot.history1[[length(slot.history1) + 1]] <- data.frame(
    itr = i,
    slot = seq_len(n + (n%%2)),
    count = slot.count1
  )
}

simulation.dt <- rbindlist(simulation.list)
slot.dt1 <- rbindlist(slot.history1)
slot.dt2 <- rbindlist(slot.history2)

pegviz <- ggplot() + 
    labs(title = "Demonstration of the Galton Box, example 2") + 
    
    geom_point(data = peg.df, aes(x = x, y = y), size = 4, fill = "#7a7a7a", color = "#5a5a5a") +

    geom_point(data = simulation.dt, aes(x = x, y = y),
      color = "#e63946", showSelected = "itr",
      size = 5, alpha = 0.85) +

    geom_text(data = text.df, aes(x = x, y = y, label = label),
      size = 4, fontface = "bold", color = "#333333") +

    geom_hline(aes(yintercept = (n - 0.5)), color = "#457b9d", size = 1.2, linetype = "dashed") +
    geom_hline(aes(yintercept = (-0.5)), color = "#e76f51", size = 1.2, linetype = "dashed") +

    
    theme(
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
        
        panel.background = element_rect(fill = "#fafafa", colour = NA),
        plot.background = element_rect(fill = "#fafafa", colour = NA)
    )

slotviz1 <- ggplot() +
  labs(title = "Upper Section — Ball Distribution", x = "Slot Number", y = "Number of Balls") +

  geom_bar(data = slot.dt1, aes(x = factor(slot), y = count), showSelected = "itr", 
    fill = "#457b9d", color = "#1d3557", stat = "identity", position = "identity") +
  
  theme_light(base_size = 14) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))

slotviz2 <- ggplot() +
  labs(title = "Lower Section — Ball Distribution", x = "Slot Number", y = "Number of Balls") +

  geom_bar(data = slot.dt2, aes(x = factor(slot), y = count), showSelected = "itr", 
    fill = "#e76f51", color = "#9c3a22", stat = "identity", position = "identity") +
  
  theme_light(base_size = 14) +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5))

animint2dir(list(
  pegviz = pegviz,
  slotviz1 = slotviz1,
  slotviz2 = slotviz2,
  duration = list(frame = 100),
  time = list(variable="itr", ms=100),
  title = "Galton Board — Two-Stage Simulation"
), out.dir = "galton2")