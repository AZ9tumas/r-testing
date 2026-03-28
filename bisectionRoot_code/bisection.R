
library(ggplot2)
library(animint2)

f <- function(x) x ** 3 + x ** 2 - 2 * x + 2
errf <- function(x) abs(f(x))
lowerlim <- -3
upperlim <- 0
n_iterations <- 15

history_list <- list()
error_list <- list()

a <- lowerlim
b <- upperlim

# calculation
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
  
  error_list[[i]] <- data.frame(
    itr = i,
    err = errf(c)
  )
  
  if (f(a) * f(c) < 0) {
    b <- c
  } else if (f(b) * f(c) < 0) {
    a <- c
  }
}

error_list

df <- do.call(rbind, history_list)
errdf <- do.call(rbind, error_list)

series <- seq(-10, 10, length.out = 500)

plotdf <- data.frame(
  x = series,
  y = f(series)
)

# The actual plotting
plot <- ggplot() +
  labs(title = "Bisection Root Finding Method", x = "x", y = "f(x)") + 
  annotate("text", x = 0.8, y = 4.5,
           label = "f(x) == x^3 + x^2 - 2*x + 2",
           parse = TRUE, size = 14, color = "#2e3440") +
  geom_path(mapping = aes(x = x, y = y), 
             data = plotdf, color = "#2e3440") + 
  
  # the green
  geom_vline(mapping = aes(xintercept = c), 
             data = df, linewidth = 0.5, color = "green", showSelected = 'itr') +
  
  # text
  geom_text(mapping = aes(x = c, y = 0, label = sprintf("c = %.2f", c)), 
            data = df, fontface = "bold", size = 12,
            color = "#2d5a27", showSelected = 'itr') + 
  
  # the red lines
  geom_vline(mapping = aes(xintercept = a), 
             data = df, linetype = "dashed", color = "#bf616a", showSelected = 'itr') + 
  geom_vline(mapping = aes(xintercept = b), 
             data = df, linetype = "dashed", color = "#bf616a", showSelected = 'itr') +
  
  # limits
  scale_y_continuous(limits = c(-2, 5)) +
  scale_x_continuous(limits = c(-3, 2)) + 
  
  # themes
  theme_linedraw(base_size = 14)

itr_df <- data.frame(itr = 1:n_iterations)

err.plot <- ggplot() + 
  labs(title = "Error analysis", y = "Error range", x = "Iteration") +
  annotate("text", x = 11.5, y = 3.5,
           label = "err(x) = abs(f(c))",
           parse = TRUE, size = 15.5, color = "#2e3440") +
  geom_path(mapping = aes(x = itr, y = err), data = errdf) + 
  geom_point(mapping = aes(x = itr, y = err), data = errdf, clickSelects = 'itr') + 

  geom_vline(mapping = aes(xintercept = itr), data = errdf, 
    showSelected = 'itr', alpha = 1, color = "lightblue") + 

  # vertical lines for the err plot
  geom_vline(mapping = aes(xintercept = itr), data = itr_df, clickSelects = 'itr', alpha = 0.65) + 
  # theming
  theme_linedraw(base_size = 14)

# animint stuff
viz <- animint(
  title = "Bisection Method Animation",
  source = plot,
  errorplot = err.plot,
  #duration = list(itr = 250),
  time = list(variable="itr", ms=1000)
)

animint2dir(viz, out.dir = "bisection", open.browser = TRUE)

#animint2pages(viz, out.dir = "bisection_test", github_repo = "bisection_test")
animint2::animint2pages(
  list(
    viz = plot,
    errorviz = err.plot,
    #duration = list(itr = 250),
    time = list(variable = "itr", ms = 1000),
    title = "Bisection Method Animation",
    source = "https://github.com/AZ9tumas/bisection-method-animation"
  ),
  github_repo = "bisection-method-animation"
)