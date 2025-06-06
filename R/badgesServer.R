badgesServer <- function(id, version, data) {
    moduleServer(
        id,
        function(input, output, session) {
            output$badge_out <- DT::renderDataTable({
                DT::datatable(
                    badgesDF(
                        version = version(),
                        data = data()
                    ),
                    escape = FALSE,
                    rownames = FALSE,
                    options = list(
                        dom = "ftp",
                        pageLength = 20,
                        lengthChange = FALSE,
                        paging = TRUE
                    )
                )
            })
        }
    )
}
