# GSoC 2026 — Animint2 Tests (AZ9tumas)

This file contains the links to my completed tests for the **Animated interactive ggplots (animint2)** project.

## Easy test

### Human Development Index Plot
- Rendered visualization: [Human Development Index Plot](https://az9tumas.github.io/r-testing/hdi_visualization/)   
- Source code repo: [HDI Plot Source Code](https://github.com/AZ9tumas/r-testing/blob/main/HumanProgressIndex_Visualization/viz1.R)

### Life Expectancy Plot
- Rendered visualization: [Life Expectancy Plot](https://az9tumas.github.io/r-testing/test_visualization/)   
- Source code repo: [Life Expectancy Plot Source Code](https://github.com/AZ9tumas/r-testing/blob/main/test_visualization_code/test.R)

## Medium test

### Buffon's Needle
- Rendered visualization: <https://az9tumas.github.io/r-testing/buffons/>
- Source code repo: <https://github.com/AZ9tumas/r-testing/blob/main/buffons_code/buffons.R>

### Bisection Root Finding
- Rendered visualization: <https://az9tumas.github.io/r-testing/bisection/>
- Source code repo: <https://github.com/AZ9tumas/r-testing/blob/main/bisectionRoot_code/bisection.R>

### Galton's Board - example 1
- Rendered visualization: <https://az9tumas.github.io/r-testing/galton-animint/>
- Source code repo: <https://github.com/AZ9tumas/r-testing/tree/main/galton_example1_code>

### Galton's Board - example 2
- Rendered visualization: <https://az9tumas.github.io/r-testing/galton2/>
- Source code repo: <https://github.com/AZ9tumas/r-testing/blob/main/galton_example2_code/galton2.R>
- Ports of animation examples wiki entry: <https://github.com/tdhock/animint/wiki/Ports-of-animation-examples>

## Notes
> Show an example of an error that you see when animint2 is loaded/attached at the same time as standard ggplot2.

When both `animint2` and `ggplot2` are loaded in the same R session, it will result in **function masking** because `animint2` is a fork of `ggplot2`. Many identically named functions will be masked (example `geom_point`, etc.)

The exact error:
```
Registered S3 methods overwritten by 'ggplot2':
  method                   from    
  drawDetails.zeroGrob     animint2
  grobHeight.absoluteGrob  animint2
  grobHeight.zeroGrob      animint2
  grobWidth.absoluteGrob   animint2
  grobWidth.zeroGrob       animint2
  grobX.absoluteGrob       animint2
  grobY.absoluteGrob       animint2
  heightDetails.titleGrob  animint2
  heightDetails.zeroGrob   animint2
  makeContext.dotstackGrob animint2
  print.ggplot2_bins       animint2
  print.rel                animint2
  widthDetails.titleGrob   animint2
  widthDetails.zeroGrob    animint2

Attaching package: 'ggplot2'

The following objects are masked from 'package:animint2':

    %+%, %+replace%, aes, aes_, aes_all, aes_auto, aes_q, aes_string,
    ...

```
