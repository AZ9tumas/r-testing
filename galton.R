library(ggplot2)
library(animint2)

n <- 12
count <- 1

peg_coordinates <- list()

for (y in seq(n, 0, by = -1)) {
    for (x in seq(y, 2 * n - y, by = 2)){
        print(c(x, y))
        peg_coordinates[[count]] <- data.frame(x = x, y = y)
        count <- count + 1
    }
}

peg.df <- do.call(rbind, peg_coordinates)
text.df <- data.frame(y = rep(0, n), x = seq(1, 2 * n - 1, by = 2), label = 1:n)

pegviz1 <- ggplot() +
  geom_point(data = peg.df, aes(x = x, y = y), size = 5, shape = 21, color = "green") + 
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
    pegs = pegviz1
), out.dir = "galton-animint")

