#' Get all the variables in the design
#'
#' This function gathers a list of all variables in a study design. 
#' @param design Design. 
#' @return List of all variables
#' @keywords
# infer_has_relationships()
get_all_vars <- function(design){
    # Combine all variables in design
    vars <- append(design@ivs, design@dv)
    # var_names <- list()
    # for (v in vars) {
    #     var_names <- append(var_names, v@name)
    # }
    # stopifnot(length(vars) == length(var_names))

    # # Return tuple of variables and their names
    # (vars, var_names)

    # Return list of all variables
    vars
}