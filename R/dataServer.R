dataServer <- function(id, data) {
    moduleServer(
        id,
        function(input, output, session) {
            colsOfInterest <- c(
                "Package",
                "Version",
                "License",
                "NeedsCompilation",
                "Title",
                "hasREADME",
                "hasNEWS",
                "hasINSTALL",
                "hasLICENSE",
                "dependencyCount"
            )
            output$data_out <- DT::renderDataTable({
                DT::datatable(
                    BiocPkgDash:::renderMaintained(
                        data = data()
                    )[, colsOfInterest],
                    rownames = FALSE,
                    options = list(
                        dom = "ftp",
                        pageLength = 20,
                        paging = TRUE
                    )
                )
            })
        }
    )
}
