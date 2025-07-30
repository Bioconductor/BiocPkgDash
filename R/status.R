statusServer <- function(id, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$status_out <- plotly::renderPlotly(
                BiocPkgDash::pkgStatusPlot(
                    data = data()
                )
            )
            output$status_table <- DT::renderDataTable(
                DT::datatable(
                    BiocPkgDash::pkgStatusTable(
                        data = data()
                    ),
                    escape = FALSE,
                    rownames = FALSE,
                    options = list(
                        dom = "ftp",
                        pageLength = 16,
                        lengthChange = FALSE,
                        paging = TRUE
                    )
                )
            )
        }
    )
}

statusUI <- function(id, label = "status") {
    ns <- NS(id)
    tagList(
        shinybiocloader::withLoader(
            plotly::plotlyOutput(ns("status_out")),
            loader = "biocspin"
        ),
        DT::dataTableOutput(ns("status_table"))
    )
}
