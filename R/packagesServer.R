packagesServer <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            parsedPkgs <- reactive({
                if (!is.null(input$packages) && nzchar(input$packages)) {
                    pkgs <- strsplit(input$packages, ",\\s*")[[1]]
                    Filter(nzchar, pkgs)
                } else {
                    character(0)
                }
            })
            return(parsedPkgs)
        }
    )
}

