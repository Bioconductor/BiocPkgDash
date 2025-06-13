pkgsServer <- function(id, reset_signal) {
    moduleServer(
        id,
        function(input, output, session) {
            packages <- reactiveVal(character(0L))
            observeEvent(
                input$submit_pkgs,
                {
                    if (nzchar(input$packages)) {
                        pkgs <- strsplit(input$packages, ",\\s*")[[1]]
                        parsed_pkgs <- Filter(nzchar, pkgs)
                    } else {
                        parsed_pkgs <- character(0L)
                    }
                    packages(parsed_pkgs)
                }
            )
            observeEvent(
                reset_signal(),
                {
                    updateTextAreaInput(
                        session = session,
                        inputId = "packages",
                        value = ""
                    )
                    packages(character(0L))
                }
            )
            return(packages)
        }
    )
}

pkgsUI <- function(id, label = "packages") {
    ns <- NS(id)
    tagList(
        textAreaInput(
            inputId = ns("packages"),
            label = "Enter package names:",
            value = "",
            placeholder = "BiocGenerics, BiocStyle, BiocBaseUtils, ...",
            rows = 6,
            width = "100%"
        ),
        actionButton(
            inputId = ns("submit_pkgs"),
            label = "Submit",
            class = "btn-primary"
        )
    )
}
