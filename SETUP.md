Should auto install Python + Tisane: https://cran.r-project.org/web/packages/reticulate/vignettes/python_dependencies.html. 
If not automatically installed, install miniconda using Reticulate
```R
install.packages("reticulate")
library(reticulate)
reticulate::install_miniconda() 
```