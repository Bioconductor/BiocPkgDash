badgesUI <- function(id, label = "badges") {
    ns <- NS(id)
    tagList(
        shinycustomloader::withLoader(
            DT::dataTableOutput(ns("badge_out")),
            type = "html",
            loader = "dnaspin"
        )
    )
}
