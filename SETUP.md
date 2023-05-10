
# Install rTisane and its dependencies
<!-- Installing rTisane from CRAN should auto install Python + Tisane: https://cran.r-project.org/web/packages/reticulate/vignettes/python_dependencies.html. 
If not automatically installed, install miniconda using Reticulate -->
1. Install python.
Note: Reticulate installs and uses miniconda from a path like "~/Library/r-miniconda-arm64"
```R
install.packages("reticulate")
library(reticulate)
reticulate::install_miniconda() 
```

2. Install Python libraries/dependencies
```R
py_install("dash", pip=TRUE)
py_install("dash_daq", pip=TRUE)
py_install("dash_bootstrap_components", pip=TRUE)
py_install("flask", pip=TRUE)
py_install("plotly", pip=TRUE)
py_install("tisanecodegenerator", pip=TRUE)

import("dash")
import("dash_daq")
import("dash_bootstrap_components")
import("flask")
import("plotly")
import("tisanecodegenerator")

# TODO: Get rid of this dependency
py_install("pandas", pip=TRUE)
import("pandas")
```

# To run all disambiguation processes in the default web browser instead of RStudio's internal browser
1. Add to Rprofile (at "~/.Rprofile")
```R
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
```
2. Source at the start of the R session
```R
source("~/.Rprofile")
```

# Should not need: To make sure rTisane finds the conceptual model disambiguation interface
```R
source("conceptualDisambiguation/app.R")
```


