# General tips
## Setting up local environment
Create an environment setup script that loads dependencies that are helpful for running and debugging rTisane programs. For example, I have a `env_setup.R` file that contains the following: 
```R 
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)

library(shiny)
library(plotly)

# For development
devtools::load_all()
```

## Debugging test cases
1. Use the `devtools` package.
```R
library(devtools)
```
2. Add a checkpoint in code
```R
...
browser()
...
```
3. In the console, run tests interactively. Without calling the below line of code, the `browser()` checkpoints are ignored. 
```R
rlang::with_interactive(test_active_file())
```

## Running Shiny apps 
- Tip 1: Open any Shiny apps in the default web browser (e.g., Firefox, Chrome, etc.) and do not open in the RStudio browser.
```R
# Add to ~/.Rprofile to prevent Shiny from opening new RStudio internal browser each time
options(shiny.launch.browser = .rs.invokeShinyWindowExternal)
```

# Tips to testing specific parts of the system
## Code generation 
Note: The code generation module relies on a separate Python package, [tisanecodegenerator](https://github.com/emjun/tisaneCodeGenerator). If there are bugs in the code generator module, [file issues here](https://github.com/emjun/tisaneCodeGenerator/issues). 

<!-- If the bug or unexpected behavior is not found in the code generation module and related to how the input JSON to or the output code from the module are used... -->