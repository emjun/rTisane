#' Infer has relationships from a study design
#'
#' This function infers has relationships from a study design.
#' @param design 
#' @keywords
# infer_has_relationships()
infer_has_relationships <- function(design){
    # Get all variables in design
    vars <- get_all_vars(design=design)

    has_relationships <- list()

    for (v in vars) {
        # Assert that v is a Measure
        stopifnot(inherits(v, "Measure"))
        # Construct has relationship
        has_relat = has(unit=v@unit, measure=v, numberOfInstances=v@numberOfInstances)

        has_relationships <- append(has_relationships, has_relat)
    }

    # Get all moderating variables
    for (r in design@relationships) {
        if (is(r, "Moderates")) {
            m_units = list()
            for (m in r@moderators) {
                if (is(m, "Measure")) {
                    m_units <- append(m_units, m@unit)
                } else {
                    err_msg <- paste("Moderator is of type", typeof(m), collapse=" ")
                    stop(err_msg)
                }
                # else if (is(m, "Unit")) {
                #     m_units <- append(m_units, m)
                # }
                    
            }
            # Create name
            m_names = list()
            for (m in r@moderators) {
                m_names <- append(m_names, m@name)
            }
            name = paste(m_names, collapse="_X_")
            # Calculate cardinality
            m_cardinality = as.integer(-1) # Need to calculate
            # for (m in r@moderators) {
            #     if ()
            #     m_cardinality = m_cardinality * m@cardinality
            # }
        
            var <- ModerationNominal(
                units=m_units, name=name, cardinality=m_cardinality, moderators=r@moderators
            )  
            # Construct has relationships
            for (u in m_units) {
                has_relat = has(unit=u, measure=var, numberOfInstances=as.integer(1))
                has_relationships <- append(has_relationships, has_relat)
            }
        }
    }

    # Return has_relationships
    has_relationships
}