library(animint2)

df <- data.frame(x = 1:10, y = 1:10)

common.data <- data.frame(
  x = c(15,18,21, 5,7,9,11, 1,3,5,7,9),
  y = c(10,20,30, 50,100,150,200, 5,15,25,35,45),
  set = c(rep("few",3), rep("medium",4), rep("many",5))
)

bar <- ggplot() + 
    geom_bar(aes(x, y, color = set), position = "identity",
        showSelected = "set", clickSelects = "set",
        data = common.data, stat = "identity")

point <- ggplot() + 
    geom_point(aes(x, y, color = set),
        showSelected = "set", clickSelects = "set",
        data = common.data)

animint2dir(list(
    barplot = bar + labs(title = "No axis updates"),
    barplotx = bar + theme_animint(update_axes = "x") + labs(title = "X axis updates"),

    pointplot = point + labs(title = "No axis updates"),
    pointplotx = point + theme_animint(update_axes = "x") + labs(title = "X axis updates"),

    selector.types = list(set = "single")
), out.dir = "bar-axes-demo", open.browser = TRUE)