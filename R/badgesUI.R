badgesUI <- function(id, label = "badges") {
    ns <- NS(id)
    tagList(
        shinycssloaders::withSpinner(
            DT::dataTableOutput(ns("badge_out")),
            type = 5,
            color = "#1a81c2"
        )
    )
}
