statusUI <- function(id, label = "status") {
    ns <- NS(id)
    tagList(
        plotly::plotlyOutput(ns("status_out")),
        DT::dataTableOutput(ns("status_table"))
    )
}
