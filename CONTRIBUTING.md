## Debugging tips 
```R
library(devtools)
add browser() checkpoint
rlang::with_interactive(test_active_file())
```


For testing shiny Apps
```R
# Add to ~/.Rprofile to prevent Shiny from opening new RStudio internal browser each time
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
```