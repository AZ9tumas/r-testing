library(ggplot2)
library(animint2)

n <- 12
ball.count <- 150

peg_coordinates <- list()

count <- 1
for (y in seq(n, 0, by = -1)) {
  for (x in seq(y, 2 * n - y, by = 2)){
    print(c(x, y))
    peg_coordinates[[count]] <- data.frame(x = x, y = y)
    count <- count + 1
  }
}

peg.df <- do.call(rbind, peg_coordinates)
text.df <- data.frame(y = rep(0, n), x = seq(1, 2 * n - 1, by = 2), label = 1:n)

# get the balls simulated
ball.state <- list(list(x = n, y = n - 1))
simulation.list <- list(data.frame(x = n, y = n - 1, itr = 1))
slot.count <- list()

# in the (n + ball.count)th iteration we see all balls go in
# last ball reaches the last level at (n + ball.count - 1)th iteration
for (i in 2:(n + ball.count)){
  next_ball_state <- list()

  # iterate over the last itr balls
  for (j in seq_along(ball.state)){
    ball <- ball.state[[j]]
    # decide
    if (ball$y == 0){
      # remove the ball from the state
      slot.count[[ball$x]] <- ifelse(is.null(slot.count[[ball$x]]), 1, slot.count[[ball$x]] + 1)
    } else {
      # random chance
      if (runif(1) < 0.5){
        # left
        ball$x = ball$x - 1
      } else {
        # right
        ball$x = ball$x + 1
      }
      ball$y = ball$y - 1
      next_ball_state[[length(next_ball_state) + 1]] <- ball
      simulation.list[[length(simulation.list) + 1]] <- data.frame(x = ball$x, y = ball$y, itr = i)
    }
  }

  ball.state <- next_ball_state

  # add the new ball to the state
  if (i <= ball.count){
    ball.state[[length(ball.state) + 1]] <- list(x = n, y = n - 1)
    simulation.list[[length(simulation.list) + 1]] <- data.frame(x = n, y = n - 1, itr = i)
  }
}

simulation.df <- do.call(rbind, simulation.list)

print("Slot count:")
print(slot.count)

pegviz1 <- ggplot() +
  
  geom_point(data = peg.df, aes(x = x, y = y), size = 5, shape = 21, color = "green") + 
  geom_point(data = simulation.df, aes(x = x, y = y), showSelected = "itr", size = 5, color = "black") +
  
  geom_text(data = text.df, aes(x = x, y = y, label = label)) +

  theme(
    axis.line = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background = element_rect(fill = "transparent", colour = NA)
  )

animint2dir(list(
  pegs = pegviz1,
  duration = list(frame = 150),
  time = list(variable="itr", ms=150)
), out.dir = "galton-animint")