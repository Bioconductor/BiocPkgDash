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
