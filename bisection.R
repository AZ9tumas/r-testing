
library(animint2)

f <- function(x) x ** 2 - 3
a <- -5
b <- 5
n_iterations <- 10

history_list <- list()

for (i in 1:n_iterations) {
  c <- (a + b) / 2
  
  history_list[[i]] <- data.frame(
    itr  = i,
    a    = a,
    b    = b,
    c    = c,
    f_a  = f(a),
    f_b  = f(b),
    f_c  = f(c)
  )
  
  if (f(a) * f(c) < 0) {
    b <- c
  } else if (f(b) * f(c) < 0) {
    a <- c
  }
}

df <- do.call(rbind, history_list)

series <- seq(5, -5, length.out = 100)

plotdf <- data.frame(
  x = series,
  y = f(series)
)

plot <- ggplot() + 
  geom_path(mapping = aes(x = x, y = y), 
             data = plotdf) + 
  # the axis
  geom_hline(mapping = aes(yintercept = 0), data = df, linetype = "dashed", color = "grey") + 
  geom_vline(mapping = aes(xintercept = 0), data = df, linetype = "dashed", color = "grey") +
  
  # the green
  geom_vline(mapping = aes(xintercept = c), data = df, linewidth = 0.5, color = "green", showSelected = 'itr') +
  geom_text(mapping = aes(x = c, y = 0, label = sprintf("c_%.2f", c)), data = df, fontface = "bold",
            color = "blue", showSelected = 'itr') + 
  
  # the red lines
  geom_vline(mapping = aes(xintercept = a), data = df, linetype = "dashed", color = "red", showSelected = 'itr') + 
  geom_vline(mapping = aes(xintercept = b), data = df, linetype = "dashed", color = "red", showSelected = 'itr')
  

viz <- animint(plot, duration=list(itr = 250))
viz$time <- list(variable="itr", ms=1000, loop = FALSE)
viz

