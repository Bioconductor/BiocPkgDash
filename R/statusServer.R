statusServer <- function(id, pkgtype, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$status_out <- plotly::renderPlotly(
                BiocPkgDash::pkgStatusPlot(
                    pkgType = pkgtype(),
                    data = data()
                )
            )
            output$status_table <- DT::renderDataTable(
                DT::datatable(
                    BiocPkgDash::pkgStatusTable(
                        pkgType = pkgtype(),
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
