library(ggplot2)
library(animint2)
library(data.table)

n <- 3
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
text.df <- data.frame(y = rep(0, n + 1), x = seq(n, 3 * n, by = 2), label = 1:(n + 1))

pegviz <- ggplot() + 
    labs(title = "Galton Board Example 2") + 
    
    geom_point(data = peg.df, aes(x = x, y = y), size = 5.5, color = "green") +
    geom_text(data = text.df, aes(x = x, y = y, label = label)) +

    geom_hline(aes(yintercept = (n - 0.5)), color = "steelblue") +

    
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
