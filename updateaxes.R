library(animint2)

mtcars$cyl <- as.factor(mtcars$cyl)
no_updates <- ggplot() + geom_point(aes(mpg, disp, colour=cyl), data = mtcars)
update_x <- no_updates + theme_animint(update_axes=c("x"))
update_y <- no_updates + theme_animint(update_axes=c("y"))
update_xy <- no_updates + theme_animint(update_axes=c("x","y"))

viz <- list(
  neither=no_updates,
  x=update_x,
  y=update_y,
  both=update_xy,
  selector.types=list(cyl="single")
)

animint2dir(viz, out.dir="update-axes-demo", open.browser=TRUE)