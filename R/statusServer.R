statusServer <- function(id, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$status_out <- plotly::renderPlotly(
                BiocPkgDash::pkgStatusPlot(
                    data = data()
                )
            )
        }
    )
}
