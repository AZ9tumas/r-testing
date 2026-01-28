
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

series <- seq(a, b, length.out = 100)

plotdf <- data.frame(
  x = series,
  y = f(series)
)

plot <- ggplot() + 
  geom_path(mapping = aes(x = x, y = y), 
             data = plotdf) 

viz <- animint(plot)
viz
