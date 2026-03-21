library(ggplot2)
library(animint2)
library(data.table)

n <- 4
ball.count <- 10

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
slot.count <- integer(n + (n%%2))
slot.history <- list(data.frame(itr = 1, slot = seq_len(n + (n%%2)), count = slot.count))

for (i in 2:(2 * n + ball.count)){
  next_ball_state <- list()

  for (j in seq_along(ball.state)){
    ball <- ball.state[[j]]

    if (ball$y == 0){
      slot.index <- (ball$x - n) %% 2 + (n %% 2)
      slot.count[slot.index] <- slot.count[slot.index] + 1
    } else {
      # range
      
    }
  }
}

pegviz <- ggplot() + 
    labs(title = "Galton Board Example 2") + 
    
    geom_point(data = peg.df, aes(x = x, y = y), size = 5.5, color = "green") +
    geom_text(data = text.df, aes(x = x, y = y, label = label)) +

    geom_hline(aes(yintercept = (n - 0.5)), color = "steelblue") +
    geom_hline(aes(yintercept = (-0.5)), color = "orange") +

    
    theme(
        axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        
        panel.background = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA)
    )

animint2dir(list(
  pegviz = pegviz
), out.dir = "galton2")
