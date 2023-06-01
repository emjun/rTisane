
# Updated: 

### Python 
1. `brew install python`

2. Install `virtualenv`. In terminal: 
```
pip3 install virtualenv
```

3. Create virutalenv. In terminal: 
```
virtualenv rTisane-env # rTisane-env is the name of the env
```

4. Source virtualenv. In terminal: 
```
source rTisane-env/bin/activate
```

Now you're working in the virtualenv!

5. Install Python dependencies: 
```
pip3 install dash
pip3 install dash_daq
pip3 install dash_bootstrap_components
pip3 install flask
pip3 install plotly
pip3 install tisanecodegenerator
pip3 install numpy
```
### R
1. Install `reticulate`
```R
install.packages("reticulate")
library(reticulate)
reticulate::use_virtualenv("./rTisane-env")
```
Check Python installation: `reticulate::py_discover_config()`
python, libpython, etc. should have a path

2. Install more R dependencies: 
```R
install.packages("devtools")
install.packages("magrittr")
install.packages("shinyjs")
install.packages("shiny")
install.packages("dagitty")
install.packages("igraph")

library(devtools)
library(magrittr) # for pipe %>%
library(shinyjs)
library(shiny)
library(dagitty)
library(igraph)
```

<!-- 4. Install Python libraries/dependencies
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
``` -->

### Use rTisane!
1. Always show disambiguation interfaces in the browser
```R
source("~/.Rprofile")
```
4. Load rTisane
```R
# Use local build of rTisane (under development)
devtools::load_all()
# For conceptual model disambiguation
source("conceptualDisambiguation/app.R")
```



==========
# Install rTisane and its dependencies
<!-- Installing rTisane from CRAN should auto install Python + Tisane: https://cran.r-project.org/web/packages/reticulate/vignettes/python_dependencies.html. 
If not automatically installed, install miniconda using Reticulate -->
1. Install python.
Note: Reticulate installs and uses miniconda from a path like "~/Library/r-miniconda-arm64"
```R
install.packages("reticulate")
library(reticulate)
reticulate::install_miniconda() 
# Help with install: https://github.com/rstudio/reticulate/issues/637
```

```R
library(magrittr) # for pipe %>%

# For disambiguation
install.packages("shinyjs")
library(shinyjs)
library(shiny)

# Use local build of rTisane (under development)
library(devtools)
devtools::load_all()
# For conceptual model disambiguation
source("conceptualDisambiguation/app.R")
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
# Setup Python virtualenv to use in project: 
Follow instructions: https://support.posit.co/hc/en-us/articles/360023654474-Installing-and-Configuring-Python-with-RStudio


## To set up 
Create python virtualenv
